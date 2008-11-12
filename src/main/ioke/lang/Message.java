/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.io.Reader;
import java.io.StringReader;

import java.util.List;
import java.util.ArrayList;

import org.antlr.runtime.tree.Tree;

import ioke.lang.parser.iokeLexer;
import ioke.lang.parser.iokeParser;
import ioke.lang.parser.Levels;

import ioke.lang.exceptions.ControlFlow;

import org.antlr.runtime.ANTLRReaderStream;
import org.antlr.runtime.CommonTokenStream;
import org.antlr.runtime.Token;
import org.antlr.runtime.tree.Tree;

/**
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Message extends IokeData {
    public static enum Type {EMPTY, MESSAGE, BINARY, BINARY_ASSIGNMENT, UNARY_ASSIGNMENT, TERMINATOR, SEPARATOR, START_INTERPOLATION, END_INTERPOLATION, MIDDLE_INTERPOLATION};

    private String name;
    private String file;
    private int line;
    private int pos;
    private Type type = Type.MESSAGE;

    private List<Object> arguments = new ArrayList<Object>();

    public IokeObject next;
    public IokeObject prev;

    public Message(Runtime runtime, String name) {
        this(runtime, name, null, Type.MESSAGE);
    }

    Message(Runtime runtime, String name, Type type) {
        this(runtime, name, null, type);
    }

    public Message(Runtime runtime, String name, Object arg1) {
        this(runtime, name, arg1, Type.MESSAGE);
    }

    public Message(Runtime runtime, String name, Object arg1, Type type) {
        this.type = type;
        this.name = name;

        this.file = ((IokeSystem)runtime.system.data).currentFile();

        if(arg1 != null) {
            arguments.add(arg1);
        }
    }

    public static boolean isTerminator(Object message) {
        return ((Message)IokeObject.data(message)).type == Type.TERMINATOR;
    }

    public static void addArg(Object message, Object arg) {
        IokeObject.as(message).getArguments().add(arg);
    }

    public static IokeObject copy(Object message) {
        IokeObject copy = IokeObject.as(message).mimic(null, null);
        copySourceLocation(message, copy);
        Message.setPrev(copy, Message.prev(message));
        Message.setNext(copy, Message.next(message));
        return copy;
    }

    public static void copySourceLocation(Object from, Object to) {
        Message.setFile(to, Message.file(from));
        Message.setLine(to, Message.line(from));
        Message.setPosition(to, Message.position(from));
    }

    public static Object getArg1(IokeObject message) {
        return ((Message)message.data).arguments.get(0);
    }

    public static Object getArg2(IokeObject message) {
        return ((Message)message.data).arguments.get(1);
    }

    public static Type type(IokeObject message) {
        return ((Message)message.data).type;
    }

    public static void setType(IokeObject message, Type type) {
        ((Message)message.data).type = type;
    }

    @Override
    public void init(IokeObject message) {
        message.setKind("Message");
        message.registerMethod(message.runtime.newJavaMethod("Returns a code representation of the object", new JavaMethod("code") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) {
                    return method.runtime.newText(((Message)IokeObject.data(on)).code());
                }
            }));
        message.registerMethod(message.runtime.newJavaMethod("returns the name of this message", new JavaMethod("name") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) {
                    return method.runtime.getSymbol(((Message)IokeObject.data(on)).name);
                }
            }));
        message.registerMethod(message.runtime.newJavaMethod("returns the next message in the chain, or nil", new JavaMethod("next") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) {
                    IokeObject next = ((Message)IokeObject.data(on)).next;
                    if(next == null) {
                        return context.runtime.nil;
                    } else {
                        return next;
                    }
                }
            }));
        message.registerMethod(message.runtime.newJavaMethod("returns true if this message is a keyword parameter or not", new JavaMethod("keyword?") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) {
                    return ((Message)IokeObject.data(on)).isKeyword() ? context.runtime._true : context.runtime._false;
                }
            }));
        message.registerMethod(message.runtime.newJavaMethod("Takes one evaluated argument and sends this message to that argument", new JavaMethod("sendTo") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    IokeObject realReceiver = IokeObject.as(message.getEvaluatedArgument(0, context));
                    return IokeObject.as(on).sendTo(realReceiver, realReceiver);
                }
            }));
        message.registerMethod(message.runtime.newJavaMethod("Takes one evaluated argument and sends this message chain to that argument", new JavaMethod("evaluateOn") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    IokeObject realReceiver = IokeObject.as(message.getEvaluatedArgument(0, context));
                    return IokeObject.as(on).evaluateCompleteWith(realReceiver, realReceiver);
                }
            }));
        message.registerMethod(message.runtime.newJavaMethod("takes one index, and a context and returns the evaluated argument at that index.", new JavaMethod("evalArgAt") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    int index = Number.extractInt(message.getEvaluatedArgument(0, context), message, context);
                    IokeObject newContext = IokeObject.as(message.getEvaluatedArgument(1, context));
                    return IokeObject.as(on).getEvaluatedArgument(index, newContext);
                }
            }));
        message.registerMethod(message.runtime.newJavaMethod("Will rearrange this message and all submessages to follow regular C style operator precedence rules. Will use Message OperatorTable to guide this operation. The operation is mutating, but should not change anything if done twice.", new JavaMethod("shuffleOperators") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) {
                    Levels levels = new Levels(IokeObject.as(on), context, message);
                    List<IokeObject> expressions = new ArrayList<IokeObject>();
                    if(on instanceof IokeObject) {
                        expressions.add(0, IokeObject.as(on));

                        while(expressions.size() > 0) {
                            IokeObject n = expressions.remove(0);
                            do {
                                levels.attach(n, expressions);
                                for(Object o : n.getArguments()) {
                                    if(o instanceof IokeObject) { //Otherwise a pure String parameter to internal:createText
                                        expressions.add(0, IokeObject.as(o));
                                    }
                                }
                            } while((n = Message.next(n)) != null);
                        
                            levels.nextMessage(expressions);
                        }
                    }

                    return on;
                }
            }));
        message.registerMethod(message.runtime.newJavaMethod("Takes one evaluated argument and returns the message resulting from parsing and operator shuffling the resulting message.", new JavaMethod("fromText") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    String code = Text.getText(message.getEvaluatedArgument(0, context));
                    return Message.newFromStream(context.runtime, new StringReader(code));
                }
            }));
    }

    public static void setName(IokeObject message, String name) {
        ((Message)message.data).name = name;
    }

    public static void setArguments(IokeObject message, List<Object> arguments) {
        ((Message)message.data).arguments = arguments;
    }

    public static void setFile(IokeObject message, String file) {
        ((Message)message.data).file = file;
    }

    public static void setLine(IokeObject message, int line) {
        ((Message)message.data).line = line;
    }

    public static void setPosition(IokeObject message, int position) {
        ((Message)message.data).pos = position;
    }

    public static boolean isKeyword(Object message) {
        if((message instanceof IokeObject) && (IokeObject.data(message) instanceof Message)) {
            return ((Message)IokeObject.data(message)).isKeyword();
        } else {
            return false;
        }
    }

    public static boolean hasName(Object message, String name) {
        if((message instanceof IokeObject) && (IokeObject.data(message) instanceof Message)) {
            return Message.name(message).equals(name);
        } else {
            return false;
        }
    }

    public boolean isKeyword() {
        return name.length() > 1 && arguments.size() == 0 && name.charAt(name.length()-1) == ':';
    }

    @Override
    public List<Object> getArguments(IokeObject self) {
        return arguments;
    }

    public void setArguments(List<Object> arguments) {
        this.arguments = arguments;
    }

    @Override
    public int getArgumentCount(IokeObject self) {
        return arguments.size();
    }

    public static String file(Object message) {
        return IokeObject.as(message).getFile();
    }

    public static int line(Object message) {
        return IokeObject.as(message).getLine();
    }

    public static int position(Object message) {
        return IokeObject.as(message).getPosition();
    }

    public static void setFile(Object message, String file) {
        ((Message)IokeObject.data(message)).file = file;
    }

    public static void setLine(Object message, int line) {
        ((Message)IokeObject.data(message)).line = line;
    }

    public static void setPosition(Object message, int pos) {
        ((Message)IokeObject.data(message)).pos = pos;
    }

    @Override
    public String getFile(IokeObject self) {
        return file;
    }

    @Override
    public int getLine(IokeObject self) {
        return line;
    }

    @Override
    public int getPosition(IokeObject self) {
        return pos;
    }

    void setFile(String file) {
        this.file = file;
    }

    void setLine(int line) {
        this.line = line;
    }

    void setPosition(int pos) {
        this.pos = pos;
    }

    @Override
    public IokeData cloneData(IokeObject obj, IokeObject message, IokeObject context) {
        Message m = new Message(obj.runtime, name);
        m.arguments = new ArrayList<Object>(((Message)obj.data).arguments);
        m.type = ((Message)obj.data).type;
        return m;
    }

    public void setNext(IokeObject next) {
        this.next = next;
    }

    public static void opShuffle(IokeObject self) throws ControlFlow {
        // TODO: Should handle stuff that's not been inited at this point...
        self.runtime.opShuffle.sendTo(self.runtime.ground, self);
    }

    public static IokeObject newFromStream(Runtime runtime, Reader reader) throws ControlFlow {
        try {
            iokeParser parser = new iokeParser(new CommonTokenStream(new iokeLexer(new ANTLRReaderStream(reader))));
            Tree t = parser.parseFully();
//                        System.err.println("t: " + t.toStringTree());
            IokeObject m = fromTree(runtime, t);
//                        System.err.println("m: " + m);
//                         System.err.println("m1: " + m);
            opShuffle(m);
//                         System.err.println("m2: " + m);
            return m;
        } catch(RuntimeException e) {
            throw e;
        } catch(Exception e) {
            throw new RuntimeException(e);
        }
    }
    

    public static IokeObject fromTree(Runtime runtime, Tree tree) {
        //        System.err.println(" fromTree(" + tree.toStringTree() + ")");
        Message m = null;
        int argStart = 0;
        if(!tree.isNil()) {
            switch(tree.getType()) {
            case iokeParser.RegexpLiteral: {
                String s = tree.getText();
                int lastIndex = s.lastIndexOf('/');
                m = new Message(runtime, "internal:createPattern", s.substring(2, lastIndex));
                m.arguments.add(s.substring(lastIndex+1));
                m.setLine(tree.getLine());
                m.setPosition(tree.getCharPositionInLine());
                return runtime.createMessage(m);
                }
            case iokeParser.StringLiteral: {
                String s = tree.getText();
                char first = s.charAt(0);
                char last = s.charAt(s.length()-1);
                if(first == '"' && last == '"') {
                    m = new Message(runtime, "internal:createText", s.substring(1, s.length()-1));
                    m.setLine(tree.getLine());
                    m.setPosition(tree.getCharPositionInLine());
                    return runtime.createMessage(m);
                } else {
                    if(first == '}' && last == '"') { // This is an ending
                        m = new Message(runtime, "internal:createText", s.substring(1, s.length()-1), Type.END_INTERPOLATION);
                        m.setLine(tree.getLine());
                        m.setPosition(tree.getCharPositionInLine());
                        return runtime.createMessage(m);
                    } else if(first == '"') { // This is a beginning
                        m = new Message(runtime, "internal:createText", s.substring(1, s.length()-2), Type.START_INTERPOLATION);
                        m.setLine(tree.getLine());
                        m.setPosition(tree.getCharPositionInLine());
                        return runtime.createMessage(m);
                    } else { // This is in the middle
                        m = new Message(runtime, "internal:createText", s.substring(1, s.length()-2), Type.MIDDLE_INTERPOLATION);
                        m.setLine(tree.getLine());
                        m.setPosition(tree.getCharPositionInLine());
                        return runtime.createMessage(m);
                    }
                }
            }
            case iokeParser.NumberLiteral:
                m = new Message(runtime, "internal:createNumber", tree.getText());
                m.setLine(tree.getLine());
                m.setPosition(tree.getCharPositionInLine());
                return runtime.createMessage(m);
            case iokeParser.Identifier:
                m = new Message(runtime, tree.getText());
                m.setLine(tree.getLine());
                m.setPosition(tree.getCharPositionInLine());
                return runtime.createMessage(m);
            case iokeParser.Terminator:
                m = new Message(runtime, ".", null, Type.TERMINATOR);
                m.setLine(tree.getLine());
                m.setPosition(tree.getCharPositionInLine());
                return runtime.createMessage(m);
            case iokeParser.Equals:
                m = new Message(runtime, "=", null, Type.BINARY_ASSIGNMENT);
                m.setLine(tree.getLine());
                m.setPosition(tree.getCharPositionInLine());
                return runtime.createMessage(m);
            case iokeParser.IncDec:
                m = new Message(runtime, tree.getText(), null, Type.UNARY_ASSIGNMENT);
                m.setLine(tree.getLine());
                m.setPosition(tree.getCharPositionInLine());
                return runtime.createMessage(m);
            case iokeParser.Comma:
                m = new Message(runtime, ",", null, Type.SEPARATOR);
                m.setLine(tree.getLine());
                m.setPosition(tree.getCharPositionInLine());
                return runtime.createMessage(m);
            case iokeParser.ComparisonOperator:
                m = new Message(runtime, tree.getText(), null, Type.BINARY);
                m.setLine(tree.getLine());
                m.setPosition(tree.getCharPositionInLine());
                return runtime.createMessage(m);
            case iokeParser.RegularBinaryOperator:
                m = new Message(runtime, tree.getText(), null, Type.BINARY);
                m.setLine(tree.getLine());
                m.setPosition(tree.getCharPositionInLine());
                return runtime.createMessage(m);
            case iokeParser.MESSAGE_SEND_EMPTY:
                m = new Message(runtime, "");
                break;
            case iokeParser.MESSAGE_SEND_SQUARE:
                m = new Message(runtime, "[]");
                break;
            case iokeParser.MESSAGE_SEND_CURLY:
                m = new Message(runtime, "{}");
                break;
            case iokeParser.MESSAGE_SEND:
                m = new Message(runtime, tree.getChild(0).getText());
                argStart = 1;
                break;
            default:
                java.lang.System.err.println("NOOOO: Can't handle " + tree + " : " + tree.getType());
                return null;
            }

            m.setLine(tree.getLine());
            m.setPosition(tree.getCharPositionInLine());
        } 

        IokeObject mx = m == null ? (IokeObject)null : runtime.createMessage(m);

        IokeObject head = null;
        List<IokeObject> currents = new ArrayList<IokeObject>();

        List<List<IokeObject>> oldCurrents = new ArrayList<List<IokeObject>>();
        List<IokeObject> oldHeads = new ArrayList<IokeObject>();
        List<IokeObject> oldMx = new ArrayList<IokeObject>();

        for(int i=argStart,j=tree.getChildCount(); i<j; i++) {
            IokeObject created = fromTree(runtime, tree.getChild(i));

            switch(Message.type(created)) {
            case START_INTERPOLATION:{
                Message mvv = new Message(runtime, "internal:concatenateText");
                mvv.setLine(tree.getLine());
                mvv.setPosition(tree.getCharPositionInLine());
                oldCurrents.add(0, currents);
                oldHeads.add(0, head);
                oldMx.add(0, mx);

                currents = new ArrayList<IokeObject>();
                head = created;
                mx = runtime.createMessage(mvv);

                created = runtime.createMessage(new Message(runtime, ",", null, Type.SEPARATOR));
                break;
            }
            case MIDDLE_INTERPOLATION:
                mx.getArguments().add(head);

                currents.clear();
                head = created;

                created = runtime.createMessage(new Message(runtime, ",", null, Type.SEPARATOR));
                break;
            case END_INTERPOLATION:
                mx.getArguments().add(head);
                mx.getArguments().add(created);

                currents = oldCurrents.remove(0);
                head = oldHeads.remove(0);
                created = mx;
                mx = oldMx.remove(0);
                break;
            }

            if(Message.type(created) == Type.TERMINATOR && head == null && currents.size() == 0) {
                continue;
            }

            if(Message.type(created) == Type.SEPARATOR && mx != null) {
                mx.getArguments().add(head);
                currents.clear();
                head = null;
            } else {
                if(Message.type(created) == Type.TERMINATOR && currents.size() > 1) {
                    while(currents.size() > 1) {
                        currents.remove(0);
                    }
                }
                Message.setPrev(created, currents.size() > 0 ? currents.get(0) : null);

                if(head == null && Message.type(created) != Type.TERMINATOR) {
                    head = created;
                }

                if(currents.size() > 0) {
                    Message.setNextOfLast(currents.get(0), created);
                    currents.set(0, created);
                } else {
                    currents.add(0, created);
                }
            }
        }

        if(mx != null && head != null) {
            mx.getArguments().add(head);
        }

        return mx == null ? head : mx;
    }

    public static String name(Object o) {
        return ((Message)IokeObject.data(o)).name;
    }

    public static List<Object> arguments(Object o) {
        return ((Message)IokeObject.data(o)).arguments;
    }

    @Override
    public String getName(IokeObject self) {
        return name;
    }

    @Override
    public boolean isMessage() {
        return true;
    }

    public static Object getEvaluatedArgument(Object argument, IokeObject context) throws ControlFlow {
        IokeObject o = IokeObject.as(argument);
        if(!o.isMessage()) {
            return o;
        }

        return o.evaluateCompleteWithoutExplicitReceiver(context, context.getRealContext());
    }

    @Override
    public Object getEvaluatedArgument(IokeObject self, int index, IokeObject context) throws ControlFlow {
        return Message.getEvaluatedArgument(arguments.get(index), context);
    }

    @Override
    public List<Object> getEvaluatedArguments(IokeObject self, IokeObject context) throws ControlFlow {
        List<Object> args = new ArrayList<Object>(arguments.size());
        for(Object o : arguments) {
            args.add(getEvaluatedArgument(o, context));
        }
        return args;
    }

    @Override
    public Object sendTo(IokeObject self, IokeObject context, Object recv) throws ControlFlow {
        return IokeObject.perform(recv, context, self);
    }

    @Override
    public Object sendTo(IokeObject self, IokeObject context, Object recv, Object argument) throws ControlFlow {
        IokeObject m = self.allocateCopy(self, context);
        m.getArguments().clear();
        m.getArguments().add(argument);
        return IokeObject.perform(recv, context, m);
    }

    @Override
    public Object sendTo(IokeObject self, IokeObject context, Object recv, Object arg1, Object arg2) throws ControlFlow {
        IokeObject m = self.allocateCopy(self, context);
        m.getArguments().clear();
        m.getArguments().add(arg1);
        m.getArguments().add(arg2);
        return IokeObject.perform(recv, context, m);
    }

    @Override
    public Object sendTo(IokeObject self, IokeObject context, Object recv, List<Object> args) throws ControlFlow {
        IokeObject m = self.allocateCopy(self, context);
        m.getArguments().clear();
        m.getArguments().addAll(args);
        return IokeObject.perform(recv, context, m);
    }

    @Override
    public Object evaluateComplete(IokeObject self) throws ControlFlow {
        return evaluateCompleteWith(self, self.runtime.getGround());
    }

    @Override
    public Object evaluateCompleteWith(IokeObject self, IokeObject ctx, Object ground) throws ControlFlow {
        Object current = ctx;
        Object lastReal = self.runtime.getNil();
        IokeObject m = self;
        while(m != null) {
            String name = m.getName();

            if(name.equals(".")) {
                current = ctx;
            } else if(name.length() > 1 && m.getArguments().size() == 0 && name.charAt(0) == ':') {
                current = self.runtime.getSymbol(name.substring(1));
                lastReal = current;
            } else {
                current = m.sendTo(ctx, current);
                lastReal = current;
            }
            m = Message.next(m);
        }
        return lastReal;
    }

    @Override
    public Object evaluateCompleteWithReceiver(IokeObject self, IokeObject ctx, Object ground, Object receiver) throws ControlFlow {
        Object current = receiver;
        Object lastReal = self.runtime.getNil();
        IokeObject m = self;
        while(m != null) {
            String name = m.getName();

            if(name.equals(".")) {
                current = ctx;
            } else if(name.length() > 0 && name.charAt(0) == ':') {
                current = self.runtime.getSymbol(name.substring(1));
                lastReal = current;
            } else {
                current = m.sendTo(ctx, current);
                lastReal = current;
            }
            m = Message.next(m);
        }
        return lastReal;
    }

    @Override
    public Object evaluateCompleteWithoutExplicitReceiver(IokeObject self, IokeObject ctx, Object ground) throws ControlFlow {
        return evaluateCompleteWith(self, ctx, ctx);
    }

    @Override
    public Object evaluateCompleteWith(IokeObject self, Object ground) throws ControlFlow {
        return evaluateCompleteWith(self, IokeObject.as(ground), IokeObject.getRealContext(ground));
    }

    public static int codePositionOf(IokeObject message, IokeObject m) {
        return ((Message)message.data).codePositionOf(m);
    }

    public static String code(IokeObject message) {
        return ((Message)message.data).code();
    }

    public int codePositionOf(IokeObject m) {
        if(this == m.data) {
            return 0;
        }
        StringBuilder base = new StringBuilder();

        currentCode(base);
        
        if(next != null) {
            if(this.type != Type.TERMINATOR) {
                base.append(" ");
            }

            return base.length() + Message.codePositionOf(next, m);
        }
        throw new RuntimeException("internal error, can't find message: " + m);
    }

    public String code() {
        StringBuilder base = new StringBuilder();

        currentCode(base);
        
        if(next != null) {
            if(this.type != Type.TERMINATOR) {
                base.append(" ");
            }

            base.append(Message.code(next));
        }

        return base.toString();
    }

    public static IokeObject prev(Object message) {
        return ((Message)IokeObject.data(message)).prev;
    }

    public static IokeObject next(Object message) {
        return ((Message)IokeObject.data(message)).next;
    }

    public static void setPrev(IokeObject message, IokeObject prev) {
        ((Message)message.data).prev = prev;
    }

    public static void setNext(IokeObject message, IokeObject next) {
        ((Message)message.data).next = next;
    }

    public static void setNextOfLast(IokeObject message, IokeObject next) {
        while(next(message) != null) {
            message = next(message);
        }
        ((Message)message.data).next = next;
    }

    public static String thisCode(IokeObject message) {
        return ((Message)message.data).thisCode();
    }


    public static String codeSequenceTo(IokeObject message, String name) {
        return ((Message)message.data).codeSequenceTo(name);
    }

    public String thisCode() {
        StringBuilder base = new StringBuilder();

        currentCode(base);
        
        return base.toString();
    }

    private void currentCode(StringBuilder base) {
        if(this.name.equals("internal:createText") && (this.arguments.get(0) instanceof String)) {
            base.append('"').append(this.arguments.get(0)).append('"');
        } else if(this.name.equals("internal:createPattern") && (this.arguments.get(0) instanceof String)) {
            base.append("#/").append(this.arguments.get(0)).append('/').append(this.arguments.get(1));
        } else if(this.name.equals("internal:createNumber") && (this.arguments.get(0) instanceof String)) {
            base.append(this.arguments.get(0));
        } else if(this.type == Type.TERMINATOR) {
            base.append(".\n");
        } else {
            base.append(this.name);
            if(arguments.size() > 0 || this.name.length() == 0) {
                base.append("(");
                String sep = "";
                for(Object o : arguments) {
                    base.append(sep).append(Message.code((IokeObject)o));

                    sep = ", ";
                }
                base.append(")");
            }
        }
    }


    public String codeSequenceTo(String name) {
        if(this.name.equals(name)) {
            return "";
        } 

        StringBuilder base = new StringBuilder();

        currentCode(base);
        
        if(next != null && !next.getName().equals(name)) {
            base.append(" ");
            base.append(Message.codeSequenceTo(next, name));
        }

        return base.toString();

    }

    public String inspect() {
        return code();
    }
    
    @Override
    public String toString(IokeObject self) {
        return code();
    }
}// Message
