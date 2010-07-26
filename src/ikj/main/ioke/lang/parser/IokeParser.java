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

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class IokeParser {
    private final Runtime runtime;
    private final Reader reader;

    private final IokeObject context;
    private final IokeObject message;

    public static class OpEntry {
        public final String name;
        public final int precedence;
        public OpEntry(String name, int precedence) { 
            this.name = name; 
            this.precedence = precedence;
        }
    }

    public static class OpArity {
        public final String name;
        public final int arity;
        public OpArity(String name, int arity) { 
            this.name = name; 
            this.arity = arity;
        }
    }

    public final static Map<String, OpEntry> DEFAULT_OPERATORS;
    public final static Map<String, OpArity> DEFAULT_ASSIGNMENT_OPERATORS;
    public final static Map<String, OpEntry> DEFAULT_INVERTED_OPERATORS;
    public final static Set<String> DEFAULT_UNARY_OPERATORS = new HashSet(Arrays.asList("-","~","$"));
    public final static Set<String> DEFAULT_ONLY_UNARY_OPERATORS = new HashSet(Arrays.asList("'","''","`",":"));


    private final static void addOpEntry(String name, int precedence, Map<String, OpEntry> current){
        current.put(name, new OpEntry(name, precedence));
    }

    private final static void addOpArity(String name, int arity, Map<String, OpArity> current){
        current.put(name, new OpArity(name, arity));
    }

    static {
        Map<String, OpEntry> operators = new HashMap<String, OpEntry>();

		addOpEntry("!",   0, operators);
		addOpEntry("?",   0, operators);
		addOpEntry("$",   0, operators);
		addOpEntry("~",   0, operators);
		addOpEntry("#",   0, operators);

		addOpEntry("**",  1, operators);

		addOpEntry("*",   2, operators);
		addOpEntry("/",   2, operators);
		addOpEntry("%",   2, operators);

		addOpEntry("+",   3, operators);
		addOpEntry("-",   3, operators);
        addOpEntry("\u2229", 3, operators);
        addOpEntry("\u222A", 3, operators);

		addOpEntry("<<",  4, operators);
		addOpEntry(">>",  4, operators);

		addOpEntry("<=>",  5, operators);
		addOpEntry(">",   5, operators);
		addOpEntry("<",   5, operators);
		addOpEntry("<=",  5, operators);
		addOpEntry("\u2264",  5, operators);
		addOpEntry(">=",  5, operators);
		addOpEntry("\u2265",  5, operators);
		addOpEntry("<>",  5, operators);
		addOpEntry("<>>",  5, operators);
        addOpEntry("\u2282", 5, operators);
        addOpEntry("\u2283", 5, operators);
        addOpEntry("\u2286", 5, operators);
        addOpEntry("\u2287", 5, operators);

		addOpEntry("==",  6, operators);
		addOpEntry("!=",  6, operators);
		addOpEntry("\u2260",  6, operators);
		addOpEntry("===",  6, operators);
		addOpEntry("=~",  6, operators);
		addOpEntry("!~",  6, operators);

		addOpEntry("&",   7, operators);

		addOpEntry("^",   8, operators);

		addOpEntry("|",   9, operators);

		addOpEntry("&&",  10, operators);
		addOpEntry("?&",  10, operators);

		addOpEntry("||",  11, operators);
		addOpEntry("?|",  11, operators);

		addOpEntry("..",  12, operators);
		addOpEntry("...",  12, operators);
		addOpEntry("=>",  12, operators);
		addOpEntry("<->",  12, operators);
		addOpEntry("->",  12, operators);
        addOpEntry("\u2218", 12, operators);
		addOpEntry("+>",  12, operators);
		addOpEntry("!>",  12, operators);
		addOpEntry("&>",  12, operators);
		addOpEntry("%>",  12, operators);
		addOpEntry("#>",  12, operators);
		addOpEntry("@>",  12, operators);
		addOpEntry("/>",  12, operators);
		addOpEntry("*>",  12, operators);
		addOpEntry("?>",  12, operators);
		addOpEntry("|>",  12, operators);
		addOpEntry("^>",  12, operators);
		addOpEntry("~>",  12, operators);
		addOpEntry("->>",  12, operators);
		addOpEntry("+>>",  12, operators);
		addOpEntry("!>>",  12, operators);
		addOpEntry("&>>",  12, operators);
		addOpEntry("%>>",  12, operators);
		addOpEntry("#>>",  12, operators);
		addOpEntry("@>>",  12, operators);
		addOpEntry("/>>",  12, operators);
		addOpEntry("*>>",  12, operators);
		addOpEntry("?>>",  12, operators);
		addOpEntry("|>>",  12, operators);
		addOpEntry("^>>",  12, operators);
		addOpEntry("~>>",  12, operators);
		addOpEntry("=>>",  12, operators);
		addOpEntry("**>",  12, operators);
		addOpEntry("**>>",  12, operators);
		addOpEntry("&&>",  12, operators);
		addOpEntry("&&>>",  12, operators);
		addOpEntry("||>",  12, operators);
		addOpEntry("||>>",  12, operators);
		addOpEntry("$>",  12, operators);
		addOpEntry("$>>",  12, operators);

		addOpEntry("and",  13, operators);
		addOpEntry("nand",  13, operators);
		addOpEntry("or",  13, operators);
		addOpEntry("xor",  13, operators);
		addOpEntry("nor",  13, operators);

		addOpEntry("<-",  14, operators);

		addOpEntry("return", 14, operators);
		addOpEntry("import", 14, operators);

        DEFAULT_OPERATORS = operators;


        Map<String, OpArity> aoperators = new HashMap<String, OpArity>();
        
		addOpArity("=", 2, aoperators);
		addOpArity("+=", 2, aoperators);
		addOpArity("-=", 2, aoperators);
		addOpArity("/=", 2, aoperators);
		addOpArity("*=", 2, aoperators);
		addOpArity("**=", 2, aoperators);
		addOpArity("%=", 2, aoperators);
		addOpArity("&=", 2, aoperators);
		addOpArity("&&=", 2, aoperators);
		addOpArity("|=", 2, aoperators);
		addOpArity("||=", 2, aoperators);
		addOpArity("^=", 2, aoperators);
		addOpArity("<<=", 2, aoperators);
		addOpArity(">>=", 2, aoperators);
		addOpArity("++", 1, aoperators);
        addOpArity("--", 1, aoperators);

        DEFAULT_ASSIGNMENT_OPERATORS = aoperators;


        Map<String, OpEntry> ioperators = new HashMap<String, OpEntry>();

		addOpEntry("\u2208",  12, ioperators);
		addOpEntry("\u2209",  12, ioperators);
		addOpEntry("::",      12, ioperators);
		addOpEntry(":::",     12, ioperators);

        DEFAULT_INVERTED_OPERATORS = ioperators;
    }

    private static class Level {
        public final int precedence;
        public final IokeObject operatorMessage;
        public final Level parent;
        public final boolean unary;
        public final boolean assignment;
        public final boolean inverted;

        public Level(int precedence, IokeObject op, Level parent, boolean unary, boolean assignment, boolean inverted) {
            this.precedence = precedence;
            this.operatorMessage = op;
            this.parent = parent;
            this.unary = unary;
            this.assignment = assignment;
            this.inverted = inverted;
        }

        public String toString() {
            try {
                return "Level<p: " + precedence + ", op: " + ChainContext.msg(operatorMessage) + ", parent: " + parent + ", unary: " + unary + ">";
            } catch(Throwable e) {
            }
            return "";
        }
    }

    private final static class BufferedChain {
        public final BufferedChain parent;
        public final IokeObject last;
        public final IokeObject head;

        public BufferedChain(BufferedChain parent, IokeObject last, IokeObject head) {
            this.parent = parent;
            this.last = last;
            this.head = head;
        }


        public String toString() {
            try {
                return "Chain<parent: " + parent + ", last: " + ChainContext.msg(last) + ", head: " + ChainContext.msg(head) + ">";

            } catch(Throwable e) {
            }
            return "";
        }
    }

    private final static class ChainContext {
        public final ChainContext parent;

        public BufferedChain chains = new BufferedChain(null, null, null);;

        public IokeObject last = null;
        public IokeObject head = null;

        private Level currentLevel = new Level(-1, null, null, false, false, false);

        public ChainContext(ChainContext parent) {
            this.parent = parent;
        }

        public void debug() {
            debug("debug");
        }

        public static String msg(IokeObject msg) throws ControlFlow {
            if(null == msg) {
                return null;
            }
            String s = Message.name(msg);
            String sep = "";
            if(msg.getArguments().size() > 0) {
                s = s + "(";
                for(Object o : msg.getArguments()) {
                    s = s + sep + msg((IokeObject)o);
                    sep = ", ";
                }
                s = s + ")";
            }

            if(Message.next(msg) != null) {
                s = s + " " + msg(Message.next(msg));
            }

            return s;
        }

        public void debug(String tag) {
            debug(tag, false);
        }

        public void debug(String tag, boolean doit) {
            if(doit) {
                try {
                    System.err.println(tag + ":");
                    System.err.println("  head: " + msg(head));
                    System.err.println("  last: " + msg(last));
                    System.err.println("  chains: " + chains);
                    System.err.println("  currentLevel: " + currentLevel);
                } catch(Throwable e) {
                }
            }
        }

        public IokeObject prepareAssignmentMessage() throws ControlFlow {
            debug("+prepareAssignmentMessage");
            if(chains.last != null && chains.last == currentLevel.operatorMessage) {
                if(currentLevel.assignment && head == null) {
                    debug("+assgn assgn");
                    IokeObject assgn = currentLevel.operatorMessage;
                    IokeObject prev = (IokeObject)assgn.getArguments().get(0);
                    assgn.getArguments().clear();
                    pop();
                    currentLevel = currentLevel.parent;

                    IokeObject realPrev = Message.prev(assgn);
                    if(realPrev != null) {
                        Message.setNext(realPrev, prev);
                        if(prev != null) {
                            Message.setPrev(prev, realPrev);
                        }
                        Message.setPrev(assgn, null);
                    }
                    if(head == last) {
                        head = prev;
                    }
                    last = prev;
                    debug("-assgn assgn");
                    return assgn;
                } else if(!currentLevel.assignment) {
                    pop();
                    currentLevel = currentLevel.parent;
                }
            }

            if(last == null) {
                return null;
            }

            IokeObject l = last;
            if(head == l) {
                head = last = null;
            } else {
                last = Message.prev(l);
                Message.setNext(last, null);
            }

            Message.setPrev(l, null);
            Message.setNext(l, null);
            
            debug("-prepareAssignmentMessage");
            return l;
        }
        
        private IokeObject withoutSurroundingBlankMessage(IokeObject inp) throws ControlFlow {
            // if(inp != null && Message.name(inp).equals("") && Message.next(inp) == null && inp.getArguments().size() == 1) {
            //     return (IokeObject)inp.getArguments().get(0);
            // }
            return inp;
        }

        public void add(IokeObject msg) throws ControlFlow {
            // System.err.println("+add(" + Message.name(msg) + ")");
            debug("+add(" + Message.name(msg) + ")");
            if(head == null) {
                head = last = msg;
            } else {
                Message.setNext(last, msg);
                Message.setPrev(msg, last);
                last = msg;
            }

            if(currentLevel.unary) {
                currentLevel.operatorMessage.getArguments().add(pop());
                currentLevel = currentLevel.parent;
            }
            debug("-add");
        }

        public void push(int precedence, IokeObject op, boolean unary, boolean assignment, boolean inverted) {
            debug("+push");
            currentLevel = new Level(precedence, op, currentLevel, unary, assignment, inverted);
            chains = new BufferedChain(chains, last, head);
            last = head = null;
            debug("-push");
        }

        public IokeObject pop() throws ControlFlow {
            debug("+pop");
            if(head != null) {
                while(Message.isTerminator(head) && Message.next(head) != null) {
                    head = Message.next(head);
                    Message.setPrev(head, null);
                }
            }

            IokeObject headToReturn = withoutSurroundingBlankMessage(head);

            head = chains.head;
            last = chains.last;
            chains = chains.parent;

            debug("-pop");
            return headToReturn;
        }

        public void popOperatorsTo(int precedence) throws ControlFlow {
            while((currentLevel.precedence != -1 || currentLevel.unary) && currentLevel.precedence <= precedence) {
                debug("+popOperatorsTo");
                IokeObject arg = pop();
                if(arg != null && Message.isTerminator(arg) && Message.next(arg) == null) {
                    arg = null;
                }

                IokeObject op = currentLevel.operatorMessage;
                if(currentLevel.inverted && Message.prev(op) != null) {
                    Message.setNext(Message.prev(op), null);
                    op.getArguments().add(head);
                    head = arg;
                    Message.setNextOfLast(head, op);
                    last = op;
                } else {
                    if(arg != null) {
                        op.getArguments().add(arg);
                    }
                }
                currentLevel = currentLevel.parent;
                debug("-popOperatorsTo");
            }
        }
    }

    private ChainContext top = new ChainContext(null);

    private final Map<String, OpEntry> operatorTable = new HashMap<String, OpEntry>();
    private final Map<String, OpArity> trinaryOperatorTable = new HashMap<String, OpArity>();
    private final Map<String, OpEntry> invertedOperatorTable = new HashMap<String, OpEntry>();
    private final Set<String> unaryOperators = DEFAULT_UNARY_OPERATORS;
    private final Set<String> onlyUnaryOperators = DEFAULT_ONLY_UNARY_OPERATORS;

    public static interface OpTableCreator {
        Map<Object, Object> create(Runtime runtime);
    }

    public Map<Object, Object> getOpTable(IokeObject opTable, String name, OpTableCreator creator) throws ControlFlow {
        IokeObject operators = IokeObject.as(opTable.findCell(message, context, name), null);
        if(operators != runtime.nul && (IokeObject.data(operators) instanceof Dict)) {
            return Dict.getMap(operators);
        } else {
            Map<Object, Object> result = creator.create(runtime);
            opTable.setCell(name, runtime.newDict(result));
            return result;
        }
    }

    private final void createOrGetOpTables() throws ControlFlow {
        IokeObject opTable = IokeObject.as(runtime.message.findCell(message, context, "OperatorTable"), null);
        if(opTable == runtime.nul) {
            opTable = runtime.newFromOrigin();
            opTable.setKind("Message OperatorTable");
            runtime.message.setCell("OperatorTable", opTable);
        }

        Map<Object, Object> tmpOperatorTable = getOpTable(opTable, "operators", new OpTableCreator() {
                public Map<Object, Object> create(Runtime runtime) {
                    Map<Object, Object> table = new HashMap<Object, Object>();
                    for(OpEntry ot : DEFAULT_OPERATORS.values()) {
                        table.put(runtime.getSymbol(ot.name), runtime.newNumber(ot.precedence));
                    }
                    return table;
                }
            });
        
        Map<Object, Object> tmpTrinaryOperatorTable = getOpTable(opTable, "trinaryOperators", new OpTableCreator() {
                public Map<Object, Object> create(Runtime runtime) {
                    Map<Object, Object> table = new HashMap<Object, Object>();
                    for(OpArity ot : DEFAULT_ASSIGNMENT_OPERATORS.values()) {
                        table.put(runtime.getSymbol(ot.name), runtime.newNumber(ot.arity));
                    }
                    return table;
                }
            });

        Map<Object, Object> tmpInvertedOperatorTable = getOpTable(opTable, "invertedOperators", new OpTableCreator() {
                public Map<Object, Object> create(Runtime runtime) {
                    Map<Object, Object> table = new HashMap<Object, Object>();
                    for(OpEntry ot : DEFAULT_INVERTED_OPERATORS.values()) {
                        table.put(runtime.getSymbol(ot.name), runtime.newNumber(ot.precedence));
                    }
                    return table;
                }
            });

        for(Map.Entry<Object, Object> entry : tmpOperatorTable.entrySet()) {
            addOpEntry(Symbol.getText(entry.getKey()), Number.intValue(entry.getValue()).intValue(), operatorTable);
        }
        for(Map.Entry<Object, Object> entry : tmpTrinaryOperatorTable.entrySet()) {
            addOpArity(Symbol.getText(entry.getKey()), Number.intValue(entry.getValue()).intValue(), trinaryOperatorTable);
        }
        for(Map.Entry<Object, Object> entry : tmpInvertedOperatorTable.entrySet()) {
            addOpEntry(Symbol.getText(entry.getKey()), Number.intValue(entry.getValue()).intValue(), invertedOperatorTable);
        }
    }

    public IokeParser(Runtime runtime, Reader reader, IokeObject context, IokeObject message) throws ControlFlow {
        // System.err.println("--------------------------------------------------------------------------");
        this.runtime = runtime;
        this.reader = reader;
        this.context = context;
        this.message = message;

        createOrGetOpTables();
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

    private int possibleOperatorPrecedence(String name) {
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

    public static void main(String[] args) throws Exception, ControlFlow {
        Runtime r = new Runtime();
        r.init();
        IokeParser p = new IokeParser(r, new StringReader(args[0]), r.ground, r.message);
        System.out.println(ChainContext.msg(p.parseFully()));
        System.out.println();
    }
}
