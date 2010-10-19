
namespace Ioke.Lang.Parser {
    using Ioke.Lang;

    internal sealed class ChainContext {
        internal readonly ChainContext parent;
        internal BufferedChain chains = new BufferedChain(null, null, null);

        internal IokeObject last;
        internal IokeObject head;

        internal Level currentLevel = new Level(-1, null, null, Level.Type.REGULAR);
        
        internal ChainContext(ChainContext parent) {
            this.parent = parent;
        }

        internal IokeObject PrepareAssignmentMessage() {
            if(chains.last != null && chains.last == currentLevel.operatorMessage) {
                if(currentLevel.type == Level.Type.ASSIGNMENT && head == null) {
                    IokeObject assgn = currentLevel.operatorMessage;
                    IokeObject prev = (IokeObject)assgn.Arguments[0];
                    assgn.Arguments.Clear();
                    Pop();
                    currentLevel = currentLevel.parent;

                    IokeObject realPrev = Message.GetPrev(assgn);
                    if(realPrev != null) {
                        Message.SetNext(realPrev, prev);
                        if(prev != null) {
                            Message.SetPrev(prev, realPrev);
                        }
                        Message.SetPrev(assgn, null);
                    }
                    if(head == last) {
                        head = prev;
                    }
                    last = prev;
                    return assgn;
                } else if(last == null && currentLevel.type != Level.Type.ASSIGNMENT) {
                    Pop();
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
                last = Message.GetPrev(l);
                Message.SetNext(last, null);
            }

            Message.SetPrev(l, null);
            Message.SetNext(l, null);
            
            return l;
        }

        internal void Add(IokeObject msg) {
            if(head == null) {
                head = last = msg;
            } else {
                Message.SetNext(last, msg);
                Message.SetPrev(msg, last);
                last = msg;
            }

            if(currentLevel.type == Level.Type.UNARY) {
                currentLevel.operatorMessage.Arguments.Add(Pop());
                currentLevel = currentLevel.parent;
            }
        }

        internal void Push(int precedence, IokeObject op, Level.Type type) {
            currentLevel = new Level(precedence, op, currentLevel, type);
            chains = new BufferedChain(chains, last, head);
            last = head = null;
        }

        internal IokeObject Pop() {
            if(head != null) {
                while(Message.IsTerminator(head) && Message.GetNext(head) != null) {
                    head = Message.GetNext(head);
                    Message.SetPrev(head, null);
                }
            }

            IokeObject headToReturn = head;
            
            head = chains.head;
            last = chains.last;
            chains = chains.parent;

            return headToReturn;
        }

        internal void PopOperatorsTo(int precedence) {
            while((currentLevel.precedence != -1 || currentLevel.type == Level.Type.UNARY) && currentLevel.precedence <= precedence) {
                IokeObject arg = Pop();
                if(arg != null && Message.IsTerminator(arg) && Message.GetNext(arg) == null) {
                    arg = null;
                }

                IokeObject op = currentLevel.operatorMessage;
                if(currentLevel.type == Level.Type.INVERTED && Message.GetPrev(op) != null) {
                    Message.SetNext(Message.GetPrev(op), null);
                    op.Arguments.Add(head);
                    head = arg;
                    Message.SetNextOfLast(head, op);
                    last = op;
                } else {
                    if(arg != null) {
                        op.Arguments.Add(arg);
                    }
                }
                currentLevel = currentLevel.parent;
            }
        }

    }
}
