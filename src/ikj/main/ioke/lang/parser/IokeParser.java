/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang.parser;

import java.io.Reader;
import java.io.IOException;

import java.util.ArrayList;
import java.util.List;

import ioke.lang.IokeObject;
import ioke.lang.Message;
import ioke.lang.Runtime;
import ioke.lang.Dict;
import ioke.lang.Number;
import ioke.lang.Symbol;
import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class IokeParser {
    public static class SyntaxError extends RuntimeException {
        private final int line;
        private final int character;
        private final String message;

        public SyntaxError(IokeParser outside, String message) {
            this(outside, outside.lineNumber, outside.currentCharacter, message);
        }

        public SyntaxError(IokeParser outside, int line, int character, String message) {
            this.line = line;
            this.character = character;
            this.message = message;
        }

        public String getMessage() {
            return "" + line + ":" + character + ": " + message;
        }
    }

    private final Runtime runtime;
    final Reader reader;

    public IokeParser(Runtime runtime, Reader reader) {
        this.runtime = runtime;
        this.reader = reader;
    }

    public IokeObject parseFully() throws IOException {
        //System.err.println("parseFully()");
        IokeObject result = parseExpressions();
        //System.err.println("-parseFully()");
        return result;
    }

    private IokeObject parseExpressions() throws IOException {
        //System.err.println("parseExpressions()");
        IokeObject c = null;
        IokeObject last = null;
        IokeObject head = null;

        while((c = parseExpression()) != null) {
            if(head == null) {
                head = c;
                last = c;
            } else {
                Message.setNext(last, c);
                Message.setPrev(c, last);
                last = c;
            }
        }

        if(head != null) {
            while(Message.isTerminator(head) && Message.next(head) != null) {
                head = Message.next(head);
                Message.setPrev(head, null);
            }
        }

        //System.err.println("-parseExpressions()");
        return head;
    }

    private List<Object> parseExpressionChain() throws IOException {
        //System.err.println("parseExpressionChain()");
        ArrayList<Object> chain = new ArrayList<Object>();

        IokeObject curr = parseExpressions();
        while(curr != null) {
            chain.add(curr);
            readWhiteSpace();
            int rr = peek();
            if(rr == ',') {
                read();
                curr = parseExpressions();
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

        //System.err.println("-parseExpressionChain()");

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

            //System.err.println(" read(): " + x + " (" + (char)x + ")");
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

        //System.err.println(" read(): " + xx + " (" + (char)xx + ")");
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

    private IokeObject parseExpression() throws IOException {
        //System.err.println("parseExpression()");
        int rr;
        while(true) {
            rr = peek();
            // //System.err.println(" BLARG: " + rr);
            switch(rr) {
            case -1:
                read();
                return null;
            case ',':
            case ')':
            case ']':
            case '}':
                return null;
            case '(':
                read();
                return parseEmptyMessageSend();
            case '[':
                read();
                return parseSquareMessageSend();
            case '{':
                read();
                return parseCurlyMessageSend();
            case '#':
                read();
                switch(peek()) {
                case '{':
                    return parseSetMessageSend();
                case '/':
                    return parseRegexpLiteral('/');
                case '[':
                    return parseText('[');
                case 'r':
                    return parseRegexpLiteral('r');
                case '!':
                    parseComment();
                    break;
                default:
                    return parseOperatorChars('#');
                }
                break;
            case '"':
                read();
                return parseText('"');
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
                return parseNumber(rr);
            case '.':
                read();
                if((rr = peek()) == '.') {
                    return parseRange();
                } else {
                    return parseTerminator('.');
                }
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
                return parseTerminator(rr);
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
                return parseOperatorChars(rr);
            case ':':
                read();
                if(isLetter(rr = peek()) || isIDDigit(rr)) {
                    return parseRegularMessageSend(':');
                } else {
                    return parseOperatorChars(':');
                }
            default:
                read();
                return parseRegularMessageSend(rr);
            }
        }
    }

    private void fail(int l, int c, String message) {
        //System.err.println("GOT FAILURE:");
        SyntaxError re = new SyntaxError(this, l, c, message);
        //        re.printStackTrace();
        throw re;
    }

    private void fail(String message) {
        //System.err.println("GOT FAILURE:");
        SyntaxError re = new SyntaxError(this, message);
        //        re.printStackTrace();
        throw re;
    }

    private void parseCharacter(int c) throws IOException {
        int l = lineNumber;
        int cc = currentCharacter;

        readWhiteSpace();
        int rr = read();
        if(rr != c) {
            fail(l, cc, "Expected: " + (char)c + " got: " + charDesc(rr));
        }
    }

    private IokeObject parseEmptyMessageSend() throws IOException {
        //System.err.println("parseEmptyMessageSend()");
        int l = lineNumber; int cc = currentCharacter-1;
        List<Object> args = parseExpressionChain();
        parseCharacter(')');

        Message m = new Message(runtime, "");
        m.setLine(l);
        m.setPosition(cc);

        IokeObject mx = runtime.createMessage(m);
        Message.setArguments(mx, args);
        //System.err.println("-parseEmptyMessageSend()");
        return mx;
    }

    private IokeObject parseSquareMessageSend() throws IOException {
        //System.err.println("parseSquareMessageSend()");
        int l = lineNumber; int cc = currentCharacter-1;

        int rr = peek();
        int r2 = peek2();

        Message m = new Message(runtime, "[]");
        m.setLine(l);
        m.setPosition(cc);

        IokeObject mx = runtime.createMessage(m);
        if(rr == ']' && r2 == '(') {
            read();
            read();
            List<Object> args = parseExpressionChain();
            parseCharacter(')');
            Message.setArguments(mx, args);
        } else {
            List<Object> args = parseExpressionChain();
            parseCharacter(']');
            Message.setArguments(mx, args);
        }

        //System.err.println("-parseSquareMessageSend()");
        return mx;
    }

    private IokeObject parseCurlyMessageSend() throws IOException {
        //System.err.println("parseCurlyMessageSend()");

        int l = lineNumber; int cc = currentCharacter-1;

        int rr = peek();
        int r2 = peek2();

        Message m = new Message(runtime, "{}");
        m.setLine(l);
        m.setPosition(cc);

        IokeObject mx = runtime.createMessage(m);
        if(rr == '}' && r2 == '(') {
            read();
            read();
            List<Object> args = parseExpressionChain();
            parseCharacter(')');
            Message.setArguments(mx, args);
        } else {
            List<Object> args = parseExpressionChain();
            parseCharacter('}');
            Message.setArguments(mx, args);
        }

        //System.err.println("-parseCurlyMessageSend()");
        return mx;
    }

    private IokeObject parseSetMessageSend() throws IOException {
        //System.err.println("parseSetMessageSend()");

        int l = lineNumber; int cc = currentCharacter-1;

        parseCharacter('{');
        List<Object> args = parseExpressionChain();
        parseCharacter('}');

        Message m = new Message(runtime, "set");
        m.setLine(l);
        m.setPosition(cc);

        IokeObject mx = runtime.createMessage(m);
        Message.setArguments(mx, args);
        //System.err.println("-parseSetMessageSend()");
        return mx;
    }

    private void parseComment() throws IOException {
        //System.err.println("parseComment()");
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


    private IokeObject parseRange() throws IOException {
        //System.err.println("parseRange()");
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
        //System.err.println("-parseRange()");
        return runtime.createMessage(m);
    }

    private IokeObject parseTerminator(int indicator) throws IOException {
        //System.err.println("parseTerminator()");
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

        Message m = new Message(runtime, ".", null, Message.Type.TERMINATOR);
        m.setLine(l);
        m.setPosition(cc);
        //System.err.println("-parseTerminator()");
        return runtime.createMessage(m);
    }

    private void readWhiteSpace() throws IOException {
        //System.err.println("readWhiteSpace()");
        int rr;
        while((rr = peek()) == ' ' ||
              rr == '\u0009' ||
              rr == '\u000b' ||
              rr == '\u000c') {
            read();
        }
    }

    private IokeObject parseRegexpLiteral(int indicator) throws IOException {
        //System.err.println("parseRegexpLiteral()");
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
                            //System.err.println("-parseRegexpLiteral()");
                            return mm;
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
                            //System.err.println("-parseRegexpLiteral()");
                            return mm;
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
                    args.add(parseExpressions());
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

    private IokeObject parseText(int indicator) throws IOException {
        //System.err.println("parseText()");
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
                    return mm;
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
                    return mm;
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
                    args.add(parseExpressions());
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

    private void parseRegexpEscape(StringBuilder sb) throws IOException {
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

    private void parseDoubleQuoteEscape(StringBuilder sb) throws IOException {
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

    private IokeObject parseOperatorChars(int indicator) throws IOException {
        //System.err.println("parseOperatorChars()");

        int l = lineNumber; int cc = currentCharacter-1;

        StringBuilder sb = new StringBuilder();
        sb.append((char)indicator);
        int rr;
        if(indicator == '#') {
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
                default:
                    Message m = new Message(runtime, sb.toString());
                    m.setLine(l);
                    m.setPosition(cc);
                    IokeObject mx = runtime.createMessage(m);
                    if(rr == '(') {
                        read();
                        List<Object> args = parseExpressionChain();
                        parseCharacter(')');
                        Message.setArguments(mx, args);
                    }
                    return mx;
                }
            }
        } else {
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
                case '/':
                case ':':
                case '#':
                    read();
                sb.append((char)rr);
                break;
                default:
                    Message m = new Message(runtime, sb.toString());
                    m.setLine(l);
                    m.setPosition(cc);
                    IokeObject mx = runtime.createMessage(m);

                    int rr2 = rr;
                    readWhiteSpace();
                    rr = peek();

                    if(rr == '(') {
                        read();
                        List<Object> args = parseExpressionChain();
                        parseCharacter(')');
                        Message.setArguments(mx, args);
                        if(rr != rr2) {
                            Message.setType(mx, Message.Type.DETACH);
                        }
                    }
                    return mx;
                }
            }
        }
    }

    private IokeObject parseNumber(int indicator) throws IOException {
        // System.err.println("parseNumber("+indicator+")");
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
        return runtime.createMessage(m);
    }

    private IokeObject parseRegularMessageSend(int indicator) throws IOException {
        //System.err.println("parseRegularMessageSend()");
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
        //System.err.println("creating new message: " + sb.toString());
        int rr2 = rr;
        readWhiteSpace();
        rr = peek();
        if(rr == '(') {
            read();
            List<Object> args = parseExpressionChain();
            parseCharacter(')');
            Message.setArguments(mx, args);
            if(rr != rr2) {
                Message.setType(mx, Message.Type.DETACH);
            }
        }

        //System.err.println("-parseRegularMessageSend() : " + mx);

        return mx;
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
        } else {
            return "" + (char)c + "[" + c + "]";
        }
    }

    public static void main(String[] args) throws Throwable {
        final String filename = args[0];
        System.out.println("Reading of file: \"" + filename + "\"");

        final StringBuilder input = new StringBuilder();
        final java.io.Reader reader = new java.io.FileReader(filename);
        char[] buff = new char[1024];
        int read = 0;
        while(true) {
            read = reader.read(buff);
            input.append(buff,0,read);
            if(read < 1024) {
                break;
            }
        }
        reader.close();

        String s = input.toString();
        Runtime r = new Runtime();
        r.init();
        final long before = System.currentTimeMillis();

        for(int i=0;i<10000;i++) {
            new IokeParser(r, new java.io.StringReader(s)).parseFully();
        }

        final long after = System.currentTimeMillis();
        final long time = after-before;
        final double timeS = (after-before)/1000.0;
        System.out.println("Parsing the file 10000 times took " + time + "ms, or " + timeS + " seconds");
    }
}
