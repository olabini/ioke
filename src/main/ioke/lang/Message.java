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

    Message next;
    Message prev;

    public Message(Runtime runtime, String name) {
        this(runtime, name, null);
    }

    public Message(Runtime runtime, String name, Object arg1) {
        super(runtime);
        this.name = name;
        this.arg1 = arg1;
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
        return fromTree(runtime, tree, null);
    }

    public static Message fromTree(Runtime runtime, Tree tree, Message prev) {
        if(!tree.isNil()) {
            switch(tree.getType()) {
            case iokeParser.StringLiteral:
                return new Message(runtime, "internal:createText", tree.getText());
            case iokeParser.Identifier:
                return new Message(runtime, tree.getText());
            case iokeParser.Terminator:
                return new Message(runtime, ";");
            case iokeLexer.T16: // '='
                return new Message(runtime, "=");
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
        return evaluateCompleteWith(new Context(runtime, ground), ground);
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
