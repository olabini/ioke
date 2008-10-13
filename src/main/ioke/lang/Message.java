/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.List;
import java.util.ArrayList;

import org.antlr.runtime.tree.Tree;

import ioke.lang.parser.iokeLexer;
import ioke.lang.parser.iokeParser;

/**
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Message extends IokeObject {
    public static enum Type {EMPTY, MESSAGE, BINARY, BINARY_ASSIGNMENT, TERMINATOR, SEPARATOR};

    private String name;
    private String file;
    private int line;
    private int pos;
    private Type type = Type.MESSAGE;

    private List<Object> arguments = new ArrayList<Object>();

    public Message next;
    public Message prev;

    Message(Runtime runtime, String name, Type type, String documentation) {
        this(runtime, name, null, type);
        this.documentation = documentation;
    }

    public Message(Runtime runtime, String name) {
        this(runtime, name, null);
    }

    public Message(Runtime runtime, String name, Object arg1, Type type) {
        this(runtime, name, arg1);
        this.type = type;
    }

    public Message(Runtime runtime, String name, Object arg1) {
        super(runtime, "<message " + name + ">");
        this.name = name;

        if(runtime.message != null) {
            this.mimics(runtime.message);
        }

        this.file = runtime.system.currentFile();

        if(arg1 != null) {
            arguments.add(arg1);
        }
    }

    public void init() {
        registerMethod(new JavaMethod(runtime, "code", "Returns a code representation of the object") {
                public IokeObject activate(IokeObject context, Message message, IokeObject on) {
                    return new Text(runtime, ((Message)on).code());
                }
            });
    }
    
    public List<Object> getArguments() {
        return arguments;
    }

    public int getArgumentCount() {
        return arguments.size();
    }

    public String getFile() {
        return file;
    }

    public int getLine() {
        return line;
    }

    public int getPosition() {
        return pos;
    }

    void setLine(int line) {
        this.line = line;
    }

    void setPosition(int pos) {
        this.pos = pos;
    }

    @Override
    IokeObject allocateCopy(Message mex, IokeObject context) {
        Message m = new Message(runtime, name);
        m.arguments = new ArrayList<Object>(this.arguments);
        return m;
    }

    public void setNext(Message next) {
        this.next = next;
    }

    public static Message fromTree(Runtime runtime, Tree tree) {
        Message m = null;
        int argStart = 0;
        if(!tree.isNil()) {
            switch(tree.getType()) {
            case iokeParser.StringLiteral:
                m = new Message(runtime, "internal:createText", tree.getText());
                m.setLine(tree.getLine());
                m.setPosition(tree.getCharPositionInLine());
                return m;
            case iokeParser.NumberLiteral:
                m = new Message(runtime, "internal:createNumber", tree.getText());
                m.setLine(tree.getLine());
                m.setPosition(tree.getCharPositionInLine());
                return m;
            case iokeParser.Identifier:
                m = new Message(runtime, tree.getText());
                m.setLine(tree.getLine());
                m.setPosition(tree.getCharPositionInLine());
                return m;
            case iokeParser.Terminator:
                m = new Message(runtime, ";", null, Type.TERMINATOR);
                m.setLine(tree.getLine());
                m.setPosition(tree.getCharPositionInLine());
                return m;
            case iokeParser.Equals:
                m = new Message(runtime, "=", null, Type.BINARY_ASSIGNMENT);
                m.setLine(tree.getLine());
                m.setPosition(tree.getCharPositionInLine());
                return m;
            case iokeParser.Comma:
                m = new Message(runtime, ",", null, Type.SEPARATOR);
                m.setLine(tree.getLine());
                m.setPosition(tree.getCharPositionInLine());
                return m;
            case iokeParser.ComparisonOperator:
                m = new Message(runtime, tree.getText(), null, Type.BINARY);
                m.setLine(tree.getLine());
                m.setPosition(tree.getCharPositionInLine());
                return m;
            case iokeParser.RegularBinaryOperator:
                m = new Message(runtime, tree.getText(), null, Type.BINARY);
                m.setLine(tree.getLine());
                m.setPosition(tree.getCharPositionInLine());
                return m;
            case iokeParser.MESSAGE_SEND_EMPTY:
                m = new Message(runtime, "");
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

        Message head = null;
        List<Message> currents = new ArrayList<Message>();

        for(int i=argStart,j=tree.getChildCount(); i<j; i++) {
            Message created = fromTree(runtime, tree.getChild(i));
            if(created.type == Type.TERMINATOR && head == null && currents.size() == 0) {
                continue;
            }

            if(created.type == Type.SEPARATOR && m != null) {
                m.arguments.add(head);
                currents.clear();
                head = null;
            } else {
                if(currents.size() > 0 && currents.get(0).type == Type.BINARY_ASSIGNMENT) {
                    currents.get(0).arguments.add(null);
                    currents.get(0).arguments.add(null);
                    currents.get(0).arguments.set(0,currents.get(0).prev);

                    currents.get(0).prev.next = null;

                    if(currents.get(0).prev.prev != null) {
                        currents.get(0).prev = currents.get(0).prev.prev;
                        currents.get(0).prev.next = currents.get(0);
                        ((Message)currents.get(0).arguments.get(0)).prev = null;
                    } else {
                        if(currents.get(0).arguments.get(0) == head) {
                            head = currents.get(0);
                        }
                        currents.get(0).prev = null;
                    }

                    currents.get(0).arguments.set(1,created);
                    currents.add(0, created);
                } else if(currents.size() > 0 && currents.get(0).type == Type.BINARY) {
                    currents.get(0).arguments.add(created);
                    currents.add(0, created);
                } else {
                    if(created.type == Type.TERMINATOR && currents.size() > 1) {
                        while(currents.size() > 1) {
                            currents.remove(0);
                        }
                    }
                    created.prev = currents.size() > 0 ? currents.get(0) : null;

                    if(head == null && created.type != Type.TERMINATOR) {
                        head = created;
                    }

                    if(currents.size() > 0) {
                        currents.get(0).next = created;
                        currents.set(0, created);
                    } else {
                        currents.add(0, created);
                    }
                }
            }
        }

        if(m != null && head != null) {
            m.arguments.add(head);
        }

        return m == null ? head : m;
    }

    public String getName() {
        return name;
    }

    public IokeObject getEvaluatedArgument(int index, IokeObject context) {
        Object o = arguments.get(index);
        if(!(o instanceof Message)) {
            return (IokeObject)o;
        }

        return ((Message)o).evaluateCompleteWithoutExplicitReceiver(context, context.getRealContext());
    }

    public Object getArg1() {
        return arguments.get(0);
    }

    public Object getArg2() {
        return arguments.get(1);
    }

    public IokeObject sendTo(IokeObject context, IokeObject recv) {
        return recv.perform(context, this);
    }

    public IokeObject sendTo(IokeObject context, IokeObject recv, IokeObject argument) {
        Message m = (Message)allocateCopy(this, context);
        m.arguments.clear();
        m.arguments.add(argument);
        return recv.perform(context, m);
    }

    public IokeObject evaluateComplete() {
        return evaluateCompleteWith(runtime.getGround());
    }

    public IokeObject evaluateCompleteWith(IokeObject ctx, IokeObject ground) {
        IokeObject current = ground;
        IokeObject lastReal = runtime.getNil();
        Message m = this;
        while(m != null) {
            if(m.name.equals(";")) {
                current = ground;
            } else {
                current = m.sendTo(ctx, current);
                lastReal = current;
            }
            m = m.next;
        }
        return lastReal;
    }

    public IokeObject evaluateCompleteWithoutExplicitReceiver(IokeObject ctx, IokeObject ground) {
        return evaluateCompleteWith(ctx, ctx);
    }

    public IokeObject evaluateCompleteWith(IokeObject ground) {
        return evaluateCompleteWith(ground, ground.getRealContext());
    }

    public int codePositionOf(Message m) {
        if(this == m) {
            return 0;
        }
        StringBuilder base = new StringBuilder();

        currentCode(base);
        
        if(next != null) {
            if(this.type != Type.TERMINATOR) {
                base.append(" ");
            }

            return base.length() + next.codePositionOf(m);
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

            base.append(next.code());
        }

        return base.toString();
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
            base.append(";\n");
        } else {
            base.append(this.name);
            if(arguments.size() > 0) {
                base.append("(");
                String sep = "";
                for(Object o : arguments) {
                    base.append(sep).append(((Message)o).code());
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
        
        if(next != null && !next.name.equals(name)) {
            base.append(" ");
            base.append(next.codeSequenceTo(name));
        }

        return base.toString();

    }

    @Override
    public String representation() {
        return code();
    }
    
    @Override
    public String toString() {
        return code();
    }
}// Message
