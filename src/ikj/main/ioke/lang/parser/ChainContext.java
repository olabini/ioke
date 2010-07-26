/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang.parser;

import ioke.lang.IokeObject;
import ioke.lang.Message;
import ioke.lang.exceptions.ControlFlow;

/**
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
final class ChainContext {
    final ChainContext parent;

    BufferedChain chains = new BufferedChain(null, null, null);;

    IokeObject last = null;
    IokeObject head = null;

    Level currentLevel = new Level(-1, null, null, Level.Type.REGULAR);

    ChainContext(ChainContext parent) {
        this.parent = parent;
    }

    IokeObject prepareAssignmentMessage() throws ControlFlow {
        if(chains.last != null && chains.last == currentLevel.operatorMessage) {
            if(currentLevel.type == Level.Type.ASSIGNMENT && head == null) {
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
                return assgn;
            } else if(currentLevel.type != Level.Type.ASSIGNMENT) {
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
            
        return l;
    }

    void add(IokeObject msg) throws ControlFlow {
        if(head == null) {
            head = last = msg;
        } else {
            Message.setNext(last, msg);
            Message.setPrev(msg, last);
            last = msg;
        }

        if(currentLevel.type == Level.Type.UNARY) {
            currentLevel.operatorMessage.getArguments().add(pop());
            currentLevel = currentLevel.parent;
        }
    }

    void push(int precedence, IokeObject op, Level.Type type) {
        currentLevel = new Level(precedence, op, currentLevel, type);
        chains = new BufferedChain(chains, last, head);
        last = head = null;
    }

    IokeObject pop() throws ControlFlow {
        if(head != null) {
            while(Message.isTerminator(head) && Message.next(head) != null) {
                head = Message.next(head);
                Message.setPrev(head, null);
            }
        }

        IokeObject headToReturn = head;

        head = chains.head;
        last = chains.last;
        chains = chains.parent;

        return headToReturn;
    }

    void popOperatorsTo(int precedence) throws ControlFlow {
        while((currentLevel.precedence != -1 || currentLevel.type == Level.Type.UNARY) && currentLevel.precedence <= precedence) {
            IokeObject arg = pop();
            if(arg != null && Message.isTerminator(arg) && Message.next(arg) == null) {
                arg = null;
            }

            IokeObject op = currentLevel.operatorMessage;
            if(currentLevel.type == Level.Type.INVERTED && Message.prev(op) != null) {
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
        }
    }
}// ChainContext
