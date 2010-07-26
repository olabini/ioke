/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang.parser;

import java.io.Reader;
import java.io.StringReader;
import java.io.IOException;

import java.util.Arrays;
import java.util.ArrayList;
import java.util.List;
import java.util.ListIterator;
import java.util.Map;
import java.util.HashMap;
import java.util.Set;
import java.util.HashSet;

import ioke.lang.IokeObject;
import ioke.lang.Message;
import ioke.lang.Runtime;
import ioke.lang.Dict;
import ioke.lang.Number;
import ioke.lang.Symbol;
import ioke.lang.IokeSystem;
import ioke.lang.exceptions.ControlFlow;

import static ioke.lang.parser.Operators.OpEntry;
import static ioke.lang.parser.Operators.OpArity;
import static ioke.lang.parser.Operators.DEFAULT_UNARY_OPERATORS;
import static ioke.lang.parser.Operators.DEFAULT_ONLY_UNARY_OPERATORS;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class IokeParser {
    final Runtime runtime;
    final Reader reader;

    final IokeObject context;
    final IokeObject message;

    ChainContext top = new ChainContext(null);

    final Map<String, OpEntry> operatorTable = new HashMap<String, OpEntry>();
    final Map<String, OpArity> trinaryOperatorTable = new HashMap<String, OpArity>();
    final Map<String, OpEntry> invertedOperatorTable = new HashMap<String, OpEntry>();
    final Set<String> unaryOperators = DEFAULT_UNARY_OPERATORS;
    final Set<String> onlyUnaryOperators = DEFAULT_ONLY_UNARY_OPERATORS;

    public IokeParser(Runtime runtime, Reader reader, IokeObject context, IokeObject message) throws ControlFlow {
        this.runtime = runtime;
        this.reader = reader;
        this.context = context;
        this.message = message;

        Operators.createOrGetOpTables(this);
    }

    public IokeObject parseFully() throws IOException, ControlFlow {
        IokeObject result = parseMessageChain();
        return result;
    }

    private IokeObject parseMessageChain() throws IOException, ControlFlow {
        top = new ChainContext(top);
        while(parseMessage());
        top.popOperatorsTo(999999);
        IokeObject ret = top.pop();
        top = top.parent;
        return ret;
    }

    private List<Object> parseCommaSeparatedMessageChains() throws IOException, ControlFlow {
        ArrayList<Object> chain = new ArrayList<Object>();

        IokeObject curr = parseMessageChain();
        while(curr != null) {
            chain.add(curr);
            readWhiteSpace();
            int rr = peek();
            if(rr == ',') {
                read();
                curr = parseMessageChain();
                if(curr == null) {
                    fail("Expected expression following comma");
                }
            } else {
                if(curr != null && Message.isTerminator(curr) && Message.next(curr) == null) {
                    chain.remove(chain.size()-1);
                }
                curr = null;
            }
        }

        return chain;
    }

    private int lineNumber = 1;
    private int currentCharacter = -1;
    private boolean skipLF = false;

    private int saved2 = -2;
    private int saved = -2;

    private int read() throws IOException {
        if(saved > -2) {
            int x = saved;
            saved = saved2;
            saved2 = -2;

            if(skipLF) {
                skipLF = false;
                if(x == '\n') {
                    return x;
                }
            }

            currentCharacter++;

            switch(x) {
            case '\r':
                skipLF = true;
            case '\n':		/* Fall through */
                lineNumber++;
                currentCharacter = 0;
            }

            return x;
        }

        int xx = reader.read();

        if(skipLF) {
            skipLF = false;
            if(xx == '\n') {
                return xx;
            }
        }

        currentCharacter++;

        switch(xx) {
        case '\r':
            skipLF = true;
        case '\n':		/* Fall through */
            lineNumber++;
            currentCharacter = 0;
        }

        return xx;
    }

    private int peek() throws IOException {
        if(saved == -2) {
            if(saved2 != -2) {
                saved = saved2;
                saved2 = -2;
            } else {
                saved = reader.read();
            }
        }
        return saved;
    }

    private int peek2() throws IOException {
        if(saved == -2) {
            saved = reader.read();
        }
        if(saved2 == -2) {
            saved2 = reader.read();
        }
        return saved2;
    }

    private boolean parseMessage() throws IOException, ControlFlow {
        int rr;
        while(true) {
            rr = peek();
            switch(rr) {
            case -1:
                read();
                return false;
            case ',':
            case ')':
            case ']':
            case '}':
                return false;
            case '(':
                read();
                parseEmptyMessageSend();
                return true;
            case '[':
                read();
                parseOpenCloseMessageSend(']', "[]");
                return true;
            case '{':
                read();
                parseOpenCloseMessageSend('}', "{}");
                return true;
            case '#':
                read();
                switch(peek()) {
                case '{':
                    parseSimpleOpenCloseMessageSend('}', "set");
                    return true;
                case '/':
                    parseRegexpLiteral('/');
                    return true;
                case '[':
                    parseText('[');
                    return true;
                case 'r':
                    parseRegexpLiteral('r');
                    return true;
                case '!':
                    parseComment();
                    break;
                default:
                    parseOperatorChars('#');
                    return true;
                }
                break;
            case '"':
                read();
                parseText('"');
                return true;
            case '0':
            case '1':
            case '2':
            case '3':
            case '4':
            case '5':
            case '6':
            case '7':
            case '8':
            case '9':
                read();
                parseNumber(rr);
                return true;
            case '.':
                read();
                if((rr = peek()) == '.') {
                    parseRange();
                } else {
                    parseTerminator('.');
                }
                return true;
            case ';':
                read();
                parseComment();
                break;
            case ' ':
            case '\u0009':
            case '\u000b':
            case '\u000c':
                read();
                readWhiteSpace();
                break;
            case '\\':
                read();
                if((rr = peek()) == '\n') {
                    read();
                    break;
                } else {
                    fail("Expected newline after free-floating escape character");
                }
            case '\r':
            case '\n':
                read();
                parseTerminator(rr);
                return true;
            case '+':
            case '-':
            case '*':
            case '%':
            case '<':
            case '>':
            case '!':
            case '?':
            case '~':
            case '&':
            case '|':
            case '^':
            case '$':
            case '=':
            case '@':
            case '\'':
            case '`':
            case '/':
                read();
                parseOperatorChars(rr);
                return true;
            case ':':
                read();
                if(isLetter(rr = peek()) || isIDDigit(rr)) {
                    parseRegularMessageSend(':');
                } else {
                    parseOperatorChars(':');
                }
                return true;
            default:
                read();
                parseRegularMessageSend(rr);
                return true;
            }
        }
    }

    private void fail(int l, int c, String message, String expected, String got) throws ControlFlow {
        String file = ((IokeSystem)IokeObject.data(runtime.system)).currentFile();

        final IokeObject condition = IokeObject.as(IokeObject.getCellChain(runtime.condition,
                                                                           this.message,
                                                                           this.context,
                                                                           "Error",
                                                                           "Parser",
                                                                           "Syntax"), this.context).mimic(this.message, this.context);
        condition.setCell("message", this.message);
        condition.setCell("context", this.context);
        condition.setCell("receiver", this.context);

        if(expected != null) {
            condition.setCell("expected", runtime.newText(expected));
        }

        if(got != null) {
            condition.setCell("got", runtime.newText(got));
        }

        condition.setCell("file", runtime.newText(file));
        condition.setCell("line", runtime.newNumber(l));
        condition.setCell("character", runtime.newNumber(c));
        condition.setCell("text", runtime.newText(file + ":" + l + ":" + c + ": " + message));
        runtime.errorCondition(condition);
    }

    private void fail(String message) throws ControlFlow {
        fail(lineNumber, currentCharacter, message, null, null);
    }

    private void parseCharacter(int c) throws IOException, ControlFlow {
        int l = lineNumber;
        int cc = currentCharacter;

        readWhiteSpace();
        int rr = read();
        if(rr != c) {
            fail(l, cc, "Expected: '" + (char)c + "' got: " + charDesc(rr), "" + (char)c, charDesc(rr));
        }
    }


    private boolean isUnary(String name) {
        return unaryOperators.contains(name) && (top.head == null || Message.isTerminator(top.last));
    }

    private static int possibleOperatorPrecedence(String name) {
        if(name.length() > 0) {
            char first = name.charAt(0);
            switch(first) {
            case '|':
                return 9;
            case '^':
                return 8;
            case '&':
                return 7;
            case '<':
            case '>':
                return 5;
            case '=':
            case '!':
            case '?':
            case '~':
            case '$':
                return 6;
            case '+':
            case '-':
                return 3;
            case '*':
            case '/':
            case '%':
                return 2;
            }
        }
        return -1;
    }

    private void possibleOperator(IokeObject mx) throws ControlFlow {
        String name = Message.name(mx);

        if(isUnary(name) || onlyUnaryOperators.contains(name)) {
            top.add(mx);
            top.push(-1, mx, true, false, false);
            return;
        }

        OpEntry op = operatorTable.get(name);
        if(op != null) {
            top.popOperatorsTo(op.precedence);
            top.add(mx);
            top.push(op.precedence, mx, false, false, false);
        } else {
            OpArity opa = trinaryOperatorTable.get(name);
            if(opa != null) {
                if(opa.arity == 2) {
                    IokeObject last = top.prepareAssignmentMessage();
                    mx.getArguments().add(last);
                    top.add(mx);
                    top.push(13, mx, false, true, false);
                } else {
                    IokeObject last = top.prepareAssignmentMessage();
                    mx.getArguments().add(last);
                    top.add(mx);
                }
            } else {
                op = invertedOperatorTable.get(name);
                if(op != null) {
                    top.popOperatorsTo(op.precedence);
                    top.add(mx);
                    top.push(op.precedence, mx, false, false, true);
                } else {
                    int possible = possibleOperatorPrecedence(name);
                    if(possible != -1) {
                        top.popOperatorsTo(possible);
                        top.add(mx);
                        top.push(possible, mx, false, false, false);
                    } else {
                        top.add(mx);
                    }
                }
            }
        }
    }

    private void parseEmptyMessageSend() throws IOException, ControlFlow {
        int l = lineNumber; int cc = currentCharacter-1;
        List<Object> args = parseCommaSeparatedMessageChains();
        parseCharacter(')');

        Message m = new Message(runtime, "");
        m.setLine(l);
        m.setPosition(cc);

        IokeObject mx = runtime.createMessage(m);
        Message.setArguments(mx, args);
        top.add(mx);
    }

    private void parseOpenCloseMessageSend(char end, String name) throws IOException, ControlFlow {
        int l = lineNumber; int cc = currentCharacter-1;

        int rr = peek();
        int r2 = peek2();

        Message m = new Message(runtime, name);
        m.setLine(l);
        m.setPosition(cc);

        IokeObject mx = runtime.createMessage(m);
        if(rr == end && r2 == '(') {
            read();
            read();
            List<Object> args = parseCommaSeparatedMessageChains();
            parseCharacter(')');
            Message.setArguments(mx, args);
        } else {
            List<Object> args = parseCommaSeparatedMessageChains();
            parseCharacter(end);
            Message.setArguments(mx, args);
        }

        top.add(mx);
    }

    private void parseSimpleOpenCloseMessageSend(char end, String name) throws IOException, ControlFlow {
        int l = lineNumber; int cc = currentCharacter-1;

        read();
        List<Object> args = parseCommaSeparatedMessageChains();
        parseCharacter(end);

        Message m = new Message(runtime, name);
        m.setLine(l);
        m.setPosition(cc);

        IokeObject mx = runtime.createMessage(m);
        Message.setArguments(mx, args);

        top.add(mx);
    }

    private void parseComment() throws IOException {
        int rr;
        while((rr = peek()) != '\n' && rr != '\r' && rr != -1) {
            read();
        }
    }

    private final static String[] RANGES = {
        "",
        ".",
        "..",
        "...",
        "....",
        ".....",
        "......",
        ".......",
        "........",
        ".........",
        "..........",
        "...........",
        "............"
    };


    private void parseRange() throws IOException, ControlFlow {
        int l = lineNumber; int cc = currentCharacter-1;

        int count = 2;
        read();
        int rr;
        while((rr = peek()) == '.') {
            count++;
            read();
        }
        String result = null;
        if(count < 13) {
            result = RANGES[count];
        } else {
            StringBuilder sb = new StringBuilder();
            for(int i = 0; i<count; i++) {
                sb.append('.');
            }
            result = sb.toString();
        }

        Message m = new Message(runtime, result);
        m.setLine(l);
        m.setPosition(cc);
        IokeObject mx = runtime.createMessage(m);

        if(rr == '(') {
            read();
            List<Object> args = parseCommaSeparatedMessageChains();
            parseCharacter(')');
            Message.setArguments(mx, args);
            top.add(mx);
        } else {
            possibleOperator(mx);
        }
    }

    private void parseTerminator(int indicator) throws IOException, ControlFlow  {
        int l = lineNumber; int cc = currentCharacter-1;

        int rr;
        int rr2;
        if(indicator == '\r') {
            rr = peek();
            if(rr == '\n') {
                read();
            }
        }

        while(true) {
            rr = peek();
            rr2 = peek2();
            if((rr == '.' && rr2 != '.') ||
               (rr == '\n')) {
                read();
            } else if(rr == '\r' && rr2 == '\n') {
                read(); read();
            } else {
                break;
            }
        }
        
        if(!(top.last == null && top.currentLevel.operatorMessage != null)) {
            top.popOperatorsTo(999999);
        }

        Message m = new Message(runtime, ".", null, true);
        m.setLine(l);
        m.setPosition(cc);
        top.add(runtime.createMessage(m));
    }

    private void readWhiteSpace() throws IOException {
        int rr;
        while((rr = peek()) == ' ' ||
              rr == '\u0009' ||
              rr == '\u000b' ||
              rr == '\u000c') {
            read();
        }
    }

    private void parseRegexpLiteral(int indicator) throws IOException, ControlFlow {
        StringBuilder sb = new StringBuilder();
        boolean slash = indicator == '/';

        int l = lineNumber; int cc = currentCharacter-1;

        read();

        if(!slash) {
            parseCharacter('[');
        }

        int rr;
        String name = "internal:createRegexp";
        List<Object> args = new ArrayList<Object>();

        while(true) {
            switch(rr = peek()) {
            case -1:
                fail("Expected end of regular expression, found EOF");
                break;
            case '/':
                read();
                if(slash) {
                    args.add(sb.toString());
                    Message m = new Message(runtime, "internal:createRegexp");
                    m.setLine(l);
                    m.setPosition(cc);
                    IokeObject mm = runtime.createMessage(m);
                    if(!name.equals("internal:createRegexp")) {
                        Message.setName(mm, name);
                    }
                    Message.setArguments(mm, args);

                    sb = new StringBuilder();
                    while(true) {
                        switch(rr = peek()) {
                        case 'x':
                        case 'i':
                        case 'u':
                        case 'm':
                        case 's':
                            read();
                            sb.append((char)rr);
                            break;
                        default:
                            args.add(sb.toString());
                            top.add(mm);
                            return;
                        }
                    }
                } else {
                    sb.append((char)rr);
                }
                break;
            case ']':
                read();
                if(!slash) {
                    args.add(sb.toString());
                    Message m = new Message(runtime, "internal:createRegexp");
                    m.setLine(l);
                    m.setPosition(cc);
                    IokeObject mm = runtime.createMessage(m);
                    if(!name.equals("internal:createRegexp")) {
                        Message.setName(mm, name);
                    }
                    Message.setArguments(mm, args);
                    sb = new StringBuilder();
                    while(true) {
                        switch(rr = peek()) {
                        case 'x':
                        case 'i':
                        case 'u':
                        case 'm':
                        case 's':
                            read();
                            sb.append((char)rr);
                            break;
                        default:
                            args.add(sb.toString());
                            top.add(mm);
                            return;
                        }
                    }
                } else {
                    sb.append((char)rr);
                }
                break;
            case '#':
                read();
                if((rr = peek()) == '{') {
                    read();
                    args.add(sb.toString());
                    sb = new StringBuilder();
                    name = "internal:compositeRegexp";
                    args.add(parseMessageChain());
                    readWhiteSpace();
                    parseCharacter('}');
                } else {
                    sb.append((char)'#');
                }
                break;
            case '\\':
                read();
                parseRegexpEscape(sb);
                break;
            default:
                read();
                sb.append((char)rr);
                break;
            }
        }
    }

    private void parseText(int indicator) throws IOException, ControlFlow {
        StringBuilder sb = new StringBuilder();
        boolean dquote = indicator == '"';

        int l = lineNumber; int cc = currentCharacter-1;

        if(!dquote) {
            read();
        }

        int rr;
        String name = "internal:createText";
        List<Object> args = new ArrayList<Object>();

        while(true) {
            switch(rr = peek()) {
            case -1:
                fail("Expected end of text, found EOF");
                break;
            case '"':
                read();
                if(dquote) {
                    args.add(sb.toString());
                    Message m = new Message(runtime, "internal:createText");
                    m.setLine(l);
                    m.setPosition(cc);
                    IokeObject mm = runtime.createMessage(m);
                    if(!name.equals("internal:createText")) {
                        for(int i = 0; i<args.size(); i++) {
                            Object o = args.get(i);
                            if(o instanceof String) {
                                Message mx = new Message(runtime, "internal:createText", o);
                                mx.setLine(l);
                                mx.setPosition(cc);
                                IokeObject mmx = runtime.createMessage(mx);
                                args.set(i, mmx);
                            }
                        }
                        Message.setName(mm, name);
                    }
                    Message.setArguments(mm, args);
                    top.add(mm);
                    return;
                } else {
                    sb.append((char)rr);
                }
                break;
            case ']':
                read();
                if(!dquote) {
                    args.add(sb.toString());
                    Message m = new Message(runtime, "internal:createText");
                    m.setLine(l);
                    m.setPosition(cc);
                    IokeObject mm = runtime.createMessage(m);
                    if(!name.equals("internal:createText")) {
                        for(int i = 0; i<args.size(); i++) {
                            Object o = args.get(i);
                            if(o instanceof String) {
                                Message mx = new Message(runtime, "internal:createText", o);
                                mx.setLine(l);
                                mx.setPosition(cc);
                                IokeObject mmx = runtime.createMessage(mx);
                                args.set(i, mmx);
                            }
                        }
                        Message.setName(mm, name);
                    }
                    Message.setArguments(mm, args);
                    top.add(mm);
                    return;
                } else {
                    sb.append((char)rr);
                }
                break;
            case '#':
                read();
                if((rr = peek()) == '{') {
                    read();
                    args.add(sb.toString());
                    sb = new StringBuilder();
                    name = "internal:concatenateText";
                    args.add(parseMessageChain());
                    readWhiteSpace();
                    parseCharacter('}');
                } else {
                    sb.append((char)'#');
                }
                break;
            case '\\':
                read();
                parseDoubleQuoteEscape(sb);
                break;
            default:
                read();
                sb.append((char)rr);
                break;
            }
        }
    }

    private void parseRegexpEscape(StringBuilder sb) throws IOException, ControlFlow {
        sb.append('\\');
        int rr = peek();
        switch(rr) {
        case 'u':
            read();
            sb.append((char)rr);
            for(int i = 0; i < 4; i++) {
                rr = peek();
                if((rr >= '0' && rr <= '9') ||
                   (rr >= 'a' && rr <= 'f') ||
                   (rr >= 'A' && rr <= 'F')) {
                    read();
                    sb.append((char)rr);
                } else {
                    fail("Expected four hexadecimal characters in unicode escape - got: " + charDesc(rr));
                }
            }
            break;
        case '0':
        case '1':
        case '2':
        case '3':
        case '4':
        case '5':
        case '6':
        case '7':
            read();
            sb.append((char)rr);
            if(rr <= '3') {
                rr = peek();
                if(rr >= '0' && rr <= '7') {
                    read();
                    sb.append((char)rr);
                    rr = peek();
                    if(rr >= '0' && rr <= '7') {
                        read();
                        sb.append((char)rr);
                    }
                }
            } else {
                rr = peek();
                if(rr >= '0' && rr <= '7') {
                    read();
                    sb.append((char)rr);
                }
            }
            break;
        case 't':
        case 'n':
        case 'f':
        case 'r':
        case '/':
        case '\\':
        case '\n':
        case '#':
        case 'A':
        case 'd':
        case 'D':
        case 's':
        case 'S':
        case 'w':
        case 'W':
        case 'b':
        case 'B':
        case 'z':
        case 'Z':
        case '<':
        case '>':
        case 'G':
        case 'p':
        case 'P':
        case '{':
        case '}':
        case '[':
        case ']':
        case '*':
        case '(':
        case ')':
        case '$':
        case '^':
        case '+':
        case '?':
        case '.':
        case '|':
            read();
            sb.append((char)rr);
            break;
        case '\r':
            read();
            sb.append((char)rr);
            if((rr = peek()) == '\n') {
                read();
                sb.append((char)rr);
            }
            break;
        default:
            fail("Undefined regular expression escape character: " + charDesc(rr));
            break;
        }
    }

    private void parseDoubleQuoteEscape(StringBuilder sb) throws IOException, ControlFlow {
        sb.append('\\');
        int rr = peek();
        switch(rr) {
        case 'u':
            read();
            sb.append((char)rr);
            for(int i = 0; i < 4; i++) {
                rr = peek();
                if((rr >= '0' && rr <= '9') ||
                   (rr >= 'a' && rr <= 'f') ||
                   (rr >= 'A' && rr <= 'F')) {
                    read();
                    sb.append((char)rr);
                } else {
                    fail("Expected four hexadecimal characters in unicode escape - got: " + charDesc(rr));
                }
            }
            break;
        case '0':
        case '1':
        case '2':
        case '3':
        case '4':
        case '5':
        case '6':
        case '7':
            read();
            sb.append((char)rr);
            if(rr <= '3') {
                rr = peek();
                if(rr >= '0' && rr <= '7') {
                    read();
                    sb.append((char)rr);
                    rr = peek();
                    if(rr >= '0' && rr <= '7') {
                        read();
                        sb.append((char)rr);
                    }
                }
            } else {
                rr = peek();
                if(rr >= '0' && rr <= '7') {
                    read();
                    sb.append((char)rr);
                }
            }
            break;
        case 'b':
        case 't':
        case 'n':
        case 'f':
        case 'r':
        case '"':
        case ']':
        case '\\':
        case '\n':
        case '#':
        case 'e':
            read();
            sb.append((char)rr);
            break;
        case '\r':
            read();
            sb.append((char)rr);
            if((rr = peek()) == '\n') {
                read();
                sb.append((char)rr);
            }
            break;
        default:
            fail("Undefined text escape character: " + charDesc(rr));
            break;
        }
    }

    private void parseOperatorChars(int indicator) throws IOException, ControlFlow {
        int l = lineNumber; int cc = currentCharacter-1;

        StringBuilder sb = new StringBuilder();
        sb.append((char)indicator);
        int rr;
        while(true) {
            rr = peek();
            switch(rr) {
            case '+':
            case '-':
            case '*':
            case '%':
            case '<':
            case '>':
            case '!':
            case '?':
            case '~':
            case '&':
            case '|':
            case '^':
            case '$':
            case '=':
            case '@':
            case '\'':
            case '`':
            case ':':
            case '#':
                read();
                sb.append((char)rr);
                break;
            case '/':
                if(indicator != '#') {
                    read();
                    sb.append((char)rr);
                    break;
                }
                // FALL THROUGH
            default:
                Message m = new Message(runtime, sb.toString());
                m.setLine(l);
                m.setPosition(cc);
                IokeObject mx = runtime.createMessage(m);

                if(rr == '(') {
                    read();
                    List<Object> args = parseCommaSeparatedMessageChains();
                    parseCharacter(')');
                    Message.setArguments(mx, args);
                    top.add(mx);
                } else {
                    possibleOperator(mx);
                }
                return;
            }
        }
    }

    private void parseNumber(int indicator) throws IOException, ControlFlow {
        int l = lineNumber; int cc = currentCharacter-1;
        boolean decimal = false;
        StringBuilder sb = new StringBuilder();
        sb.append((char)indicator);
        int rr = -1;
        if(indicator == '0') {
            rr = peek();
            if(rr == 'x' || rr == 'X') {
                read();
                sb.append((char)rr);
                rr = peek();
                if((rr >= '0' && rr <= '9') ||
                   (rr >= 'a' && rr <= 'f') ||
                   (rr >= 'A' && rr <= 'F')) {
                    read();
                    sb.append((char)rr);
                    rr = peek();
                    while((rr >= '0' && rr <= '9') ||
                          (rr >= 'a' && rr <= 'f') ||
                          (rr >= 'A' && rr <= 'F')) {
                        read();
                        sb.append((char)rr);
                        rr = peek();
                    }
                } else {
                    fail("Expected at least one hexadecimal characters in hexadecimal number literal - got: " + charDesc(rr));
                }
            } else {
                int r2 = peek2();
                if(rr == '.' && (r2 >= '0' && r2 <= '9')) {
                    decimal = true;
                    sb.append((char)rr);
                    sb.append((char)r2);
                    read(); read();
                    while((rr = peek()) >= '0' && rr <= '9') {
                        read();
                        sb.append((char)rr);
                    }
                    if(rr == 'e' || rr == 'E') {
                        read();
                        sb.append((char)rr);
                        if((rr = peek()) == '-' || rr == '+') {
                            read();
                            sb.append((char)rr);
                            rr = peek();
                        }

                        if(rr >= '0' && rr <= '9') {
                            read();
                            sb.append((char)rr);
                            while((rr = peek()) >= '0' && rr <= '9') {
                                read();
                                sb.append((char)rr);
                            }
                        } else {
                            fail("Expected at least one decimal character following exponent specifier in number literal - got: " + charDesc(rr));
                        }
                    }
                }
            }
        } else {
            while((rr = peek()) >= '0' && rr <= '9') {
                read();
                sb.append((char)rr);
            }
            int r2 = peek2();
            if(rr == '.' && r2 >= '0' && r2 <= '9') {
                decimal = true;
                sb.append((char)rr);
                sb.append((char)r2);
                read(); read();

                while((rr = peek()) >= '0' && rr <= '9') {
                    read();
                    sb.append((char)rr);
                }
                if(rr == 'e' || rr == 'E') {
                    read();
                    sb.append((char)rr);
                    if((rr = peek()) == '-' || rr == '+') {
                        read();
                        sb.append((char)rr);
                        rr = peek();
                    }

                    if(rr >= '0' && rr <= '9') {
                        read();
                        sb.append((char)rr);
                        while((rr = peek()) >= '0' && rr <= '9') {
                            read();
                            sb.append((char)rr);
                        }
                    } else {
                        fail("Expected at least one decimal character following exponent specifier in number literal - got: " + charDesc(rr));
                    }
                }
            } else if(rr == 'e' || rr == 'E') {
                decimal = true;
                read();
                sb.append((char)rr);
                if((rr = peek()) == '-' || rr == '+') {
                    read();
                    sb.append((char)rr);
                    rr = peek();
                }

                if(rr >= '0' && rr <= '9') {
                    read();
                    sb.append((char)rr);
                    while((rr = peek()) >= '0' && rr <= '9') {
                        read();
                        sb.append((char)rr);
                    }
                } else {
                    fail("Expected at least one decimal character following exponent specifier in number literal - got: " + charDesc(rr));
                }
            }
        }

        // TODO: add unit specifier here

        Message m = decimal ? new Message(runtime, "internal:createDecimal", sb.toString()) : new Message(runtime, "internal:createNumber", sb.toString());
        m.setLine(l);
        m.setPosition(cc);
        top.add(runtime.createMessage(m));
    }

    private void parseRegularMessageSend(int indicator) throws IOException, ControlFlow {
        int l = lineNumber; int cc = currentCharacter-1;
        StringBuilder sb = new StringBuilder();
        sb.append((char)indicator);
        int rr = -1;
        while(isLetter(rr = peek()) || isIDDigit(rr) || rr == ':' || rr == '!' || rr == '?' || rr == '$') {
            read();
            sb.append((char)rr);
        }
        Message m = new Message(runtime, sb.toString());
        m.setLine(l);
        m.setPosition(cc);
        IokeObject mx = runtime.createMessage(m);

        if(rr == '(') {
            read();
            List<Object> args = parseCommaSeparatedMessageChains();
            parseCharacter(')');
            Message.setArguments(mx, args);
            top.add(mx);
        } else {
            possibleOperator(mx);
        }
    }

    private boolean isLetter(int c) {
        return ((c>='A' && c<='Z') ||
                c=='_' ||
                (c>='a' && c<='z') ||
                (c>='\u00C0' && c<='\u00D6') ||
                (c>='\u00D8' && c<='\u00F6') ||
                (c>='\u00F8' && c<='\u1FFF') ||
                (c>='\u2200' && c<='\u22FF') ||
                (c>='\u27C0' && c<='\u27EF') ||
                (c>='\u2980' && c<='\u2AFF') ||
                (c>='\u3040' && c<='\u318F') ||
                (c>='\u3300' && c<='\u337F') ||
                (c>='\u3400' && c<='\u3D2D') ||
                (c>='\u4E00' && c<='\u9FFF') ||
                (c>='\uF900' && c<='\uFAFF'));
    }

    private boolean isIDDigit(int c) {
        return ((c>='0' && c<='9') ||
                (c>='\u0660' && c<='\u0669') ||
                (c>='\u06F0' && c<='\u06F9') ||
                (c>='\u0966' && c<='\u096F') ||
                (c>='\u09E6' && c<='\u09EF') ||
                (c>='\u0A66' && c<='\u0A6F') ||
                (c>='\u0AE6' && c<='\u0AEF') ||
                (c>='\u0B66' && c<='\u0B6F') ||
                (c>='\u0BE7' && c<='\u0BEF') ||
                (c>='\u0C66' && c<='\u0C6F') ||
                (c>='\u0CE6' && c<='\u0CEF') ||
                (c>='\u0D66' && c<='\u0D6F') ||
                (c>='\u0E50' && c<='\u0E59') ||
                (c>='\u0ED0' && c<='\u0ED9') ||
                (c>='\u1040' && c<='\u1049'));
    }

    private static String charDesc(int c) {
        if(c == -1) {
            return "EOF";
        } else if(c == 9) {
            return "TAB";
        } else if(c == 10 || c == 13) {
            return "EOL";
        } else {
            return "'" + (char)c + "'";
        }
    }
}
