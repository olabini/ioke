/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.List;
import java.util.ArrayList;

import org.antlr.runtime.tree.Tree;

import ioke.lang.parser.iokeLexer;
import ioke.lang.parser.iokeParser;

import ioke.lang.exceptions.ControlFlow;

/**
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Message extends IokeData {
    public static enum Type {EMPTY, MESSAGE, BINARY, BINARY_ASSIGNMENT, UNARY_ASSIGNMENT, TERMINATOR, SEPARATOR};

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

    public boolean isKeyword() {
        return name.length() > 0 && name.charAt(name.length()-1) == ':';
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
        return m;
    }

    public void setNext(IokeObject next) {
        this.next = next;
    }

    public static IokeObject fromTree(Runtime runtime, Tree tree) {
        //        System.err.println(" fromTree(" + tree.toStringTree() + ")");
        Message m = null;
        int argStart = 0;
        if(!tree.isNil()) {
            switch(tree.getType()) {
            case iokeParser.StringLiteral:
                m = new Message(runtime, "internal:createText", tree.getText());
                m.setLine(tree.getLine());
                m.setPosition(tree.getCharPositionInLine());
                return runtime.createMessage(m);
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

        for(int i=argStart,j=tree.getChildCount(); i<j; i++) {
            IokeObject created = fromTree(runtime, tree.getChild(i));
            if(Message.type(created) == Type.TERMINATOR && head == null && currents.size() == 0) {
                continue;
            }

            if(Message.type(created) == Type.SEPARATOR && mx != null) {
                mx.getArguments().add(head);
                currents.clear();
                head = null;
            } else {
                if(currents.size() > 0 && Message.type(currents.get(0)) == Type.BINARY_ASSIGNMENT) {
                    currents.get(0).getArguments().add(null);
                    currents.get(0).getArguments().add(null);
                    currents.get(0).getArguments().set(0,Message.prev(currents.get(0)));

                    Message.setNext(Message.prev(currents.get(0)), null);

                    if(Message.prev(Message.prev(currents.get(0))) != null) {
                        Message.setPrev(currents.get(0), Message.prev(Message.prev(currents.get(0))));
                        Message.setNext(Message.prev(currents.get(0)), currents.get(0));
                        Message.setPrev((IokeObject)currents.get(0).getArguments().get(0), null);
                    } else {
                        if(currents.get(0).getArguments().get(0) == head) {
                            head = currents.get(0);
                        }
                        Message.setPrev(currents.get(0), null);
                    }

                    currents.get(0).getArguments().set(1,created);
                    currents.add(0, created);
                } else if(currents.size() > 0 && Message.type(created) == Type.UNARY_ASSIGNMENT) {
                    IokeObject c = currents.get(0);
                    String _name = c.getName();
                    String _file = c.getFile();
                    int _line = c.getLine();
                    int _pos = c.getPosition();
                    Type _type = Message.type(c);
                    List<Object> _arguments = c.getArguments();
                    
                    Message.setName(c, created.getName());
                    Message.setFile(c, created.getFile());
                    Message.setLine(c, created.getLine());
                    Message.setPosition(c, created.getPosition());
                    Message.setType(c, Message.type(created));
                    Message.setArguments(c, created.getArguments());

                    Message.setName(created, _name);
                    Message.setFile(created, _file);
                    Message.setLine(created, _line);
                    Message.setPosition(created, _pos);
                    Message.setType(created, _type);
                    Message.setArguments(created, _arguments);
                    
                    c.getArguments().add(0, created);
                } else if(currents.size() > 0 && Message.type(currents.get(0)) == Type.BINARY) {
                    currents.get(0).getArguments().add(created);
                    currents.add(0, created);
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
                        Message.setNext(currents.get(0), created);
                        currents.set(0, created);
                    } else {
                        currents.add(0, created);
                    }
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

    public static IokeObject prev(IokeObject message) {
        return ((Message)message.data).prev;
    }

    public static IokeObject next(IokeObject message) {
        return ((Message)message.data).next;
    }

    public static void setPrev(IokeObject message, IokeObject prev) {
        ((Message)message.data).prev = prev;
    }

    public static void setNext(IokeObject message, IokeObject next) {
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
            base.append(this.arguments.get(0));
        } else if(this.name.equals("internal:createNumber") && (this.arguments.get(0) instanceof String)) {
            base.append(this.arguments.get(0));
        } else if(this.type == Type.TERMINATOR) {
            base.append(".\n");
        } else {
            base.append(this.name);
            if(arguments.size() > 0) {
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

    public String representation() {
        return code();
    }
    
    @Override
    public String toString(IokeObject self) {
        return code();
    }
}// Message
