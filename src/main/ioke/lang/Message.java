/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import org.antlr.runtime.tree.Tree;

import ioke.lang.parser.iokeParser;

/**
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Message extends IokeObject {
    private String name;
    private Object arg1;

    Message next;

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
        if(!tree.isNil()) {
            switch(tree.getType()) {
            case iokeParser.StringLiteral:
                return new Message(runtime, "internal:createText", tree.getText());
            case iokeParser.Identifier:
                return new Message(runtime, tree.getText());
            case iokeParser.Terminator:
                return new Message(runtime, ";");
            }
            
            return null;
        } else {
            Message head = null;
            Message current = null;

            for(int i=0,j=tree.getChildCount(); i<j; i++) {
                Message created = fromTree(runtime, tree.getChild(i));
                if(head == null) {
                    head = created;
                }
                if(current != null) {
                    current.next = created;
                }
                current = created;
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

    public IokeObject sendTo(IokeObject recv) {
        return recv.findCell(this.name).activate(this, recv);
    }

    public IokeObject evaluateCompleteWith() {
        return evaluateCompleteWith(runtime.getGround());
    }

    public IokeObject evaluateCompleteWith(IokeObject ground) {
        IokeObject current = ground;
        IokeObject lastReal = runtime.getNil();
        Message m = this;
        while(m != null) {
            if(m.name.equals(";")) {
                current = ground;
            } else {
                current = m.sendTo(current);
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
