/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

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
            Message current = null;
            boolean haveTwistedAssignment = false;

            for(int i=0,j=tree.getChildCount(); i<j; i++) {
                Message created = fromTree(runtime, tree.getChild(i));

                if(!haveTwistedAssignment && current != null && current.name.equals("=")) {
                    current.arg1 = current.prev;
                    current.prev.next = null;

                    if(current.prev.prev != null) {
                        current.prev = current.prev.prev;
                        current.prev.next = current;
                        ((Message)current.arg1).prev = null;
                    } else {
                        if(current.arg1 == head) {
                            head = current;
                        }
                        current.prev = null;
                    }

                    current.arg2 = created;
                    haveTwistedAssignment = true;
                } else {
                    created.prev = current;

                    if(head == null) {
                        head = created;
                    }

                    if(current != null) {
                        current.next = created;
                    }

                    current = created;
                    haveTwistedAssignment = false;
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

    public IokeObject evaluateCompleteWith(IokeObject ground) {
        IokeObject current = ground;
        Context ctx = new Context(runtime, ground);
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

    @Override
    public String toString() {
        if(arg1 != null) {
            return name + "(" + arg1 + ") " + (null == next ? "" : next);
        } else {
            return name + " " + (null == next ? "" : next);
        }
    }
}// Message
