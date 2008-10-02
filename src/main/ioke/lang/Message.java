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
    private String name;
    private Object arg1;
    private Object arg2;
    private List<IokeObject> arguments = new ArrayList<IokeObject>();

    Message next;
    Message prev;

    public Message(Runtime runtime, String name) {
        this(runtime, name, null);
    }

    public Message(Runtime runtime, String name, Object arg1) {
        super(runtime, "<message " + name + ">");
        this.name = name;
        this.arg1 = arg1;
    }
    
    public List<IokeObject> getArguments() {
        return arguments;
    }

    IokeObject allocateCopy() {
        Message m = new Message(runtime, name, arg1);
        m.arg2 = arg2;
        return m;
    }

    public void setNext(Message next) {
        this.next = next;
    }

    public static Message fromTree(Runtime runtime, Tree tree) {
        if(!tree.isNil()) {
            switch(tree.getType()) {
            case iokeParser.StringLiteral:
                return new Message(runtime, "internal:createText", tree.getText());
            case iokeParser.Identifier:
                return new Message(runtime, tree.getText());
            case iokeParser.Terminator:
                return new Message(runtime, ";");
            case iokeParser.Equals:
                return new Message(runtime, "=");
            case iokeParser.Comma:
                return new Message(runtime, ",");
            case iokeParser.MESSAGE_SEND:
                Message m = new Message(runtime, tree.getChild(0).getText());
                Message currentArg = null;
                for(int i=1,j=tree.getChildCount(); i<j; i++) {
                    if(currentArg == null) {
                        currentArg = fromTree(runtime, tree.getChild(i));
                        if(currentArg.name.equals(",")) {
                            currentArg = null;
                        } else {
                            m.arguments.add(currentArg);
                        }
                    } else {
                        currentArg.next = fromTree(runtime, tree.getChild(i));
                        currentArg.next.prev = currentArg;
                        currentArg = currentArg.next;
                    }
                }
                return m;
            default:
                java.lang.System.err.println("NOOOO: Can't handle " + tree + " : " + tree.getType());
            }
            
            return null;
        } else {
            Message head = null;
            List<Message> currents = new ArrayList<Message>();

            for(int i=0,j=tree.getChildCount(); i<j; i++) {
                Message created = fromTree(runtime, tree.getChild(i));


                if(currents.size() > 0 && currents.get(0).name.equals("=")) {
                    currents.get(0).arg1 = currents.get(0).prev;

                    currents.get(0).prev.next = null;

                    if(currents.get(0).prev.prev != null) {
                        currents.get(0).prev = currents.get(0).prev.prev;
                        currents.get(0).prev.next = currents.get(0);
                        ((Message)currents.get(0).arg1).prev = null;
                    } else {
                        if(currents.get(0).arg1 == head) {
                            head = currents.get(0);
                        }
                        currents.get(0).prev = null;
                    }

                    currents.get(0).arg2 = created;
                    currents.add(0, created);
                } else {
                    if(created.name.equals(";") && currents.size() > 1) {
                        currents.remove(0);
                    }
                    created.prev = currents.size() > 0 ? currents.get(0) : null;

                    if(head == null) {
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
            return head;
        }
    }

    public String getName() {
        return name;
    }

    public Object getArg1() {
        return arg1;
    }

    public Object getArg2() {
        return arg2;
    }

    public IokeObject sendTo(Context context, IokeObject recv) {
        return recv.perform(context, this);
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
        if(arg1 != null) {
            return name + "(" + arg1 + ", " + arg2 + ")" + (null == next ? "" : " " + next);
        } else {
            return name + (null == next ? "" : " " + next);
        }
    }
}// Message
