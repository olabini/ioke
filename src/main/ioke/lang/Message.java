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
    private static enum Type {MESSAGE, BINARY, BINARY_ASSIGNMENT};

    private String name;
    private String file;
    private int line;
    private int pos;
    private Type type = Type.MESSAGE;

    private List<Object> arguments = new ArrayList<Object>();

    Message next;
    Message prev;

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

        this.file = runtime.system.currentFile();

        if(arg1 != null) {
            arguments.add(arg1);
        }
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

    IokeObject allocateCopy() {
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
                m = new Message(runtime, ";");
                m.setLine(tree.getLine());
                m.setPosition(tree.getCharPositionInLine());
                return m;
            case iokeParser.Equals:
                m = new Message(runtime, "=", null, Type.BINARY_ASSIGNMENT);
                m.setLine(tree.getLine());
                m.setPosition(tree.getCharPositionInLine());
                return m;
            case iokeParser.Comma:
                m = new Message(runtime, ",");
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

            if(created.name.equals(",") && m != null) {
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
                    if(created.name.equals(";") && currents.size() > 1) {
                        currents.remove(0);
                    }
                    created.prev = currents.size() > 0 ? currents.get(0) : null;

                    if(head == null && !created.name.equals(";")) {
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

    public IokeObject getEvaluatedArgument(int index, Context context) {
        Object o = arguments.get(index);
        if(!(o instanceof Message)) {
            return (IokeObject)o;
        }

        return ((Message)o).evaluateCompleteWith(context, context);
    }

    public Object getArg1() {
        return arguments.get(0);
    }

    public Object getArg2() {
        return arguments.get(1);
    }

    public IokeObject sendTo(Context context, IokeObject recv) {
        return recv.perform(context, this);
    }

    public IokeObject sendTo(Context context, IokeObject recv, IokeObject argument) {
        Message m = (Message)allocateCopy();
        m.arguments.clear();
        m.arguments.add(argument);
        return recv.perform(context, m);
    }

    public IokeObject evaluateComplete() {
        return evaluateCompleteWith(runtime.getGround());
    }

    public IokeObject evaluateCompleteWith(Context ctx, IokeObject ground) {
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

    public IokeObject evaluateCompleteWith(IokeObject ground) {
        return evaluateCompleteWith(new Context(runtime, ground, "Method activation context for " + name), ground);
    }

    @Override
    public String toString() {
        if(arguments.size() > 0) {
            StringBuilder sb = new StringBuilder();
            String sep = "";
            for(Object o : arguments) {
                sb.append(sep).append(o);
                sep = ", ";
            }
            return name + "(" + sb + ")" + (null == next ? "" : " " + next);
        } else {
            return name + (null == next ? "" : " " + next);
        }
    }
}// Message
