
namespace Ioke.Lang.Parser {
    using Ioke.Lang;
    using Ioke.Lang.Util;
    using System.Collections;
    using System.Collections.Generic;

    public class LevelsCreator : IOperatorShufflerFactory {
        public IOperatorShuffler Create(IokeObject msg, IokeObject context, IokeObject message) {
            return new Levels(msg, context, message);
        }
    }

    public class Levels : IOperatorShuffler {
        public const int OP_LEVEL_MAX = 32;

        private class Level {
            public IokeObject message;
            public enum Type {Attach, Arg, New, Unused};
            public Type type;
            public int precedence;

            public Level(Type type) { this.type = type; }

            public void Attach(IokeObject msg) {
                switch(type) {
                case Type.Attach:
                    Message.SetNext(message, msg);
                    break;
                case Type.Arg:
                    Message.AddArg(message, msg);
                    break;
                case Type.New:
                    message = msg;
                    break;
                case Type.Unused:
                    break;
                }
            }

            public void SetAwaitingFirstArg(IokeObject msg, int precedence) {
                this.type = Type.Arg;
                this.message = msg;
                this.precedence = precedence;
            }

            public void SetAlreadyHasArgs(IokeObject msg) {
                this.type = Type.Attach;
                this.message = msg;
            }

            public void Finish(IList<IokeObject> expressions) {
                if(message != null) {
                    Message.SetNext(message, null);
                    if(message.Arguments.Count == 1) {
                        object arg1 = message.Arguments[0];
                        if(arg1 is IokeObject) { 
                            IokeObject arg = IokeObject.As(arg1, null);
                            if(arg.Name.Length == 0 && arg.Arguments.Count == 1 && Message.GetNext(arg) == null) {
                                int index = expressions.IndexOf(arg);

                                if(index != -1) {
                                    expressions[index] = message;
                                } 
                           
                                message.Arguments.Clear();
                                foreach(object o in arg.Arguments) message.Arguments.Add(o);
                                arg.Arguments.Clear();
                            } else if(!"'".Equals(message.Name) && arg.Name.Equals(".") && Message.GetNext(arg) == null) {
                                message.Arguments.Clear();
                            }
                        }
                    }
                }
                type = Type.Unused;
            }
        }

        Runtime runtime;
        
        IDictionary operatorTable;
        IDictionary trinaryOperatorTable;
        IDictionary invertedOperatorTable;

        IList<Level> stack;
        
        IokeObject _message;
        IokeObject _context;
        
        int currentLevel;
        Level[] pool = new Level[OP_LEVEL_MAX];

        public class OpTable {
            public readonly string name;
            public readonly int precedence;
            public OpTable(string name, int precedence) { this.name = name; this.precedence = precedence; }
        }

        public readonly static ICollection<string> DONT_SEPARATE_ARGUMENTS = new SaneHashSet<string>() {"and", "nand", "or", "xor", "nor"};

        public static OpTable[] defaultOperators = new OpTable[]{
            new OpTable("!",   0),
            new OpTable("?",   0),
            new OpTable("$",   0),
            new OpTable("~",   0),
            new OpTable("#",   0),

            new OpTable("**",  1),

            new OpTable("*",   2),
            new OpTable("/",   2),
            new OpTable("%",   2),

            new OpTable("+",   3),
            new OpTable("-",   3),

            new OpTable("<<",  4),
            new OpTable(">>",  4),

            new OpTable("<=>",  5),
            new OpTable(">",   5),
            new OpTable("<",   5),
            new OpTable("<=",  5),
            new OpTable(">=",  5),
            new OpTable("<>",  5),
            new OpTable("<>>",  5),

            new OpTable("==",  6),
            new OpTable("!=",  6),
            new OpTable("===",  6),
            new OpTable("=~",  6),
            new OpTable("!~",  6),

            new OpTable("&",   7),

            new OpTable("^",   8),

            new OpTable("|",   9),

            new OpTable("&&",  10),
            new OpTable("?&",  10),

            new OpTable("||",  11),
            new OpTable("?|",  11),

            new OpTable("..",  12),
            new OpTable("...",  12),
            new OpTable("=>",  12),
            new OpTable("<->",  12),
            new OpTable("->",  12),
            new OpTable("+>",  12),
            new OpTable("!>",  12),
            new OpTable("&>",  12),
            new OpTable("%>",  12),
            new OpTable("#>",  12),
            new OpTable("@>",  12),
            new OpTable("/>",  12),
            new OpTable("*>",  12),
            new OpTable("?>",  12),
            new OpTable("|>",  12),
            new OpTable("^>",  12),
            new OpTable("~>",  12),
            new OpTable("->>",  12),
            new OpTable("+>>",  12),
            new OpTable("!>>",  12),
            new OpTable("&>>",  12),
            new OpTable("%>>",  12),
            new OpTable("#>>",  12),
            new OpTable("@>>",  12),
            new OpTable("/>>",  12),
            new OpTable("*>>",  12),
            new OpTable("?>>",  12),
            new OpTable("|>>",  12),
            new OpTable("^>>",  12),
            new OpTable("~>>",  12),
            new OpTable("=>>",  12),
            new OpTable("**>",  12),
            new OpTable("**>>",  12),
            new OpTable("&&>",  12),
            new OpTable("&&>>",  12),
            new OpTable("||>",  12),
            new OpTable("||>>",  12),
            new OpTable("$>",  12),
            new OpTable("$>>",  12),

            new OpTable("+=",  13),
            new OpTable("-=",  13),
            new OpTable("**=",  13),
            new OpTable("*=",  13),
            new OpTable("/=",  13),
            new OpTable("%=",  13),
            new OpTable("and",  13),
            new OpTable("nand",  13),
            new OpTable("&=",  13),
            new OpTable("&&=",  13),
            new OpTable("^=",  13),
            new OpTable("or",  13),
            new OpTable("xor",  13),
            new OpTable("nor",  13),
            new OpTable("|=",  13),
            new OpTable("||=",  13),
            new OpTable("<<=", 13),
            new OpTable(">>=", 13),

            new OpTable("<-",  14),

            new OpTable("return", 14),
            new OpTable("import", 14)
        };

        public static OpTable[] defaultTrinaryOperators = new OpTable[]{
            new OpTable("=", 2),
            new OpTable("+=", 2),
            new OpTable("-=", 2),
            new OpTable("/=", 2),
            new OpTable("*=", 2),
            new OpTable("**=", 2),
            new OpTable("%=", 2),
            new OpTable("&=", 2),
            new OpTable("&&=", 2),
            new OpTable("|=", 2),
            new OpTable("||=", 2),
            new OpTable("^=", 2),
            new OpTable("<<=", 2),
            new OpTable(">>=", 2),
            new OpTable("++", 1),
            new OpTable("--", 1)
        };

        public static OpTable[] defaultInvertedOperators = new OpTable[]{
            new OpTable("::",  12),
            new OpTable(":::",  12)
        };

        public interface OpTableCreator {
            IDictionary Create(Runtime runtime);
        }

        private class BinaryOpTableCreator : OpTableCreator {
            public IDictionary Create(Runtime runtime) {
                IDictionary table = new SaneHashtable();
                foreach(OpTable ot in defaultOperators) {
                    table[runtime.GetSymbol(ot.name)] = runtime.NewNumber(ot.precedence);
                }
                return table;
            }
        }

        private class TrinaryOpTableCreator : OpTableCreator {
            public IDictionary Create(Runtime runtime) {
                IDictionary table = new SaneHashtable();
                foreach(OpTable ot in defaultTrinaryOperators) {
                    table[runtime.GetSymbol(ot.name)] = runtime.NewNumber(ot.precedence);
                }
                return table;
            }
        }

        private class InvertedOpTableCreator : OpTableCreator {
            public IDictionary Create(Runtime runtime) {
                IDictionary table = new SaneHashtable();
                foreach(OpTable ot in defaultInvertedOperators) {
                    table[runtime.GetSymbol(ot.name)] = runtime.NewNumber(ot.precedence);
                }
                return table;
            }
        }

        public Levels(IokeObject msg, IokeObject context, IokeObject message) {
            this.runtime = context.runtime;
            this._context = context;
            this._message = message;

            IokeObject opTable = IokeObject.As(msg.FindCell(_message, _context, "OperatorTable"), null);
            if(opTable == runtime.nul) {
                opTable = runtime.NewFromOrigin();
                opTable.Kind = "Message OperatorTable";
                runtime.Message.SetCell("OperatorTable", opTable);
                opTable.SetCell("precedenceLevelCount", runtime.NewNumber(OP_LEVEL_MAX));
            }

            this.operatorTable = GetOpTable(opTable, "operators", new BinaryOpTableCreator());
            this.trinaryOperatorTable = GetOpTable(opTable, "trinaryOperators", new TrinaryOpTableCreator());
            this.invertedOperatorTable = GetOpTable(opTable, "invertedOperators", new InvertedOpTableCreator());
            this.stack = new SaneList<Level>();
            this.Reset();
        }
        
        public IDictionary GetOpTable(IokeObject opTable, string name, OpTableCreator creator) {
            IokeObject operators = IokeObject.As(opTable.FindCell(_message, _context, name), null);
            if(operators != runtime.nul && (IokeObject.dataOf(operators) is Dict)) {
                return Dict.GetMap(operators);
            } else {
                var result = creator.Create(runtime);
                opTable.SetCell(name, runtime.NewDict(result));
                return result;
            }
        }

        public bool IsInverted(IokeObject messageSymbol) {
            return invertedOperatorTable.Contains(messageSymbol);
        }

        public int LevelForOp(string messageName, IokeObject messageSymbol, IokeObject msg) {
            object value = operatorTable[messageSymbol];
            if(value == null) {
                value = invertedOperatorTable[messageSymbol];
            }

            if(value == null) {
                if(messageName.Length > 0) {
                    char first = messageName[0];
                    switch(first) {
                    case '|':
                        return 9;
                    case '^':
                        return 8;
                    case '&':
                        return 7;
                    case '<':
                    case '>':
                        return 5;
                    case '=':
                    case '!':
                    case '?':
                    case '~':
                    case '$':
                        return 6;
                    case '+':
                    case '-':
                        return 3;
                    case '*':
                    case '/':
                    case '%':
                        return 2;
                    default:
                        return -1;
                    }
                }
            
                return -1;
            }

            return Number.GetValue(value).intValue();
        }

        public int ArgCountForOp(string messageName, IokeObject messageSymbol, IokeObject msg) {
            object value = trinaryOperatorTable[messageSymbol];
            if(value == null) {
                return -1;
            }

            return Number.GetValue(value).intValue();
        }

        public void PopDownTo(int targetLevel, IList<IokeObject> expressions) {
            Level level = null;
            while((level = stack[0]) != null && level.precedence <= targetLevel && level.type != Level.Type.Arg) {
                var obj = stack[0];
                stack.RemoveAt(0);
                obj.Finish(expressions);
                currentLevel--;
            }
        }

        private Level CurrentLevel() {
            return stack[0];
        }

        private void AttachAndReplace(Level self, IokeObject msg) {
            self.Attach(msg);
            self.type = Level.Type.Attach;
            self.message = msg;
        }

        public void AttachToTopAndPush(IokeObject msg, int precedence) {
            Level top = stack[0];
            AttachAndReplace(top, msg);

            Level level = pool[currentLevel++];
            level.SetAwaitingFirstArg(msg, precedence);
            stack.Insert(0, level);
        }
    
        private void Detach(IokeObject msg) {
            IokeObject brackets = runtime.NewMessage("");
            Message.CopySourceLocation(msg, brackets);
            foreach(object arg in msg.Arguments) brackets.Arguments.Add(arg);
            msg.Arguments.Clear();
        
            // Insert the brackets message between msg and its next message
            Message.SetNext(brackets, Message.GetNext(msg));
            Message.SetNext(msg, brackets);
        }

        public void Attach(IokeObject msg, IList<IokeObject> expressions) {
            string messageName = Message.GetName(msg);
            IokeObject messageSymbol = runtime.GetSymbol(messageName);
            int precedence = LevelForOp(messageName, messageSymbol, msg);
            int argCountForOp = ArgCountForOp(messageName, messageSymbol, msg);
        
            int msgArgCount = msg.Arguments.Count;

            bool inverted = IsInverted(messageSymbol);
        
            /*
            // : "str" bar   becomes   :("str") bar
            // -foo bar      becomes   -(foo) bar
            */
            if(msgArgCount == 0 && Message.GetNext(msg) != null && ((messageName.Equals(":") || messageName.Equals("`") || messageName.Equals("'")) || 
                                                                    (messageName.Equals("-") && Message.GetPrev(msg) == null))) {
                precedence = -1;
                object arg = Message.GetNext(msg);
                Message.SetNext(msg, Message.GetNext(arg));
                Message.SetNext(IokeObject.As(arg, null), null);
                msg.Arguments.Add(arg);
                msgArgCount++;
            }


            if(inverted && (msgArgCount == 0 || Message.typeOf(msg) == Message.Type.DETACH)) {
                if(Message.typeOf(msg) == Message.Type.DETACH) {
                    Detach(msg);
                    msgArgCount = 0;
                }

                IokeObject head = msg;
                while(Message.GetPrev(head) != null && !Message.IsTerminator(Message.GetPrev(head))) {
                    head = Message.GetPrev(head);
                }
            
                if(head != msg) {
                    IokeObject argPart = Message.DeepCopy(head);
            
                    if(Message.GetPrev(msg) != null) {
                        Message.SetNext(Message.GetPrev(msg), null);
                    }
                    Message.SetPrev(msg, null);

                    //                    IokeObject beforeHead = Message.GetPrev(head);
                    msg.Arguments.Add(argPart);

                    IokeObject next = Message.GetNext(msg);

                    IokeObject last = next;
                    while(Message.GetNext(last) != null && !Message.IsTerminator(Message.GetNext(last))) {
                        last = Message.GetNext(last);
                    }
                    IokeObject cont = Message.GetNext(last);
                    Message.SetNext(msg, cont);
                    if(cont != null) {
                        Message.SetPrev(cont, msg);
                    }
                    Message.SetNext(last, msg);
                    Message.SetPrev(msg, last);
            
                    head.Become(next, null, null);
                }
            }

            /*
            // o a = b c . d  becomes  o =(a, b c) . d
            //
            // a      attaching
            // =      msg
            // b c    Message.next(msg)
            */
            if(argCountForOp != -1 && (msgArgCount == 0 || Message.typeOf(msg) == Message.Type.DETACH) && !((Message.GetNext(msg) != null) && Message.GetName(Message.GetNext(msg)).Equals("="))) {
                if(msgArgCount != 0 && Message.typeOf(msg) == Message.Type.DETACH) {
                    Detach(msg);
                    msgArgCount = 0;
                }

                Level currentLevel = CurrentLevel();
                IokeObject attaching = currentLevel.message;
                string setCellName;

                if(attaching == null) { // = b . 
                    IokeObject condition = IokeObject.As(IokeObject.GetCellChain(runtime.Condition, 
                                                                                 _message, 
                                                                                 _context, 
                                                                                 "Error", 
                                                                                 "Parser", 
                                                                                 "OpShuffle"), _context).Mimic(_message, _context);
                    condition.SetCell("message", _message);
                    condition.SetCell("context", _context);
                    condition.SetCell("receiver", _context);
                    condition.SetCell("text", runtime.NewText("Can't create trinary expression without lvalue"));
                    runtime.ErrorCondition(condition);
                }

                // a = b .
                //                string cellName = attaching.Name;
                IokeObject copyOfMessage = Message.Copy(attaching);

                Message.SetPrev(copyOfMessage, null);
                Message.SetNext(copyOfMessage, null);

                attaching.Arguments.Clear();
                // a = b .  ->  a(a) = b .
                Message.AddArg(attaching, copyOfMessage);
            
                setCellName = messageName;
                int expectedArgs = argCountForOp;

                // a(a) = b .  ->  =(a) = b .
                Message.SetName(attaching, setCellName);

                currentLevel.type = Level.Type.Attach;

                // =(a) = b .
                // =(a) = or =("a") = .
                IokeObject mn = Message.GetNext(msg);
            
                if(expectedArgs > 1 && (mn == null || Message.IsTerminator(mn))) { 
                    // TODO: error, "compile error: %s must be followed by a value.", messageName
                }

                if(expectedArgs > 1) { 
                    // =(a) = b c .  ->  =(a, b c .) = b c .
                    Message.AddArg(attaching, mn);

                    // process the value (b c d) later  (=(a, b c d) = b c d .)
                    if(Message.GetNext(msg) != null && !Message.IsTerminator(Message.GetNext(msg))) {
                        expressions.Insert(0, Message.GetNext(msg));
                    }

                    IokeObject last = msg;
                    while(Message.GetNext(last) != null && !Message.IsTerminator(Message.GetNext(last))) {
                        last = Message.GetNext(last);
                    }

                    Message.SetNext(attaching, Message.GetNext(last));
                    Message.SetNext(msg, Message.GetNext(last));
            
                    if(last != msg) {
                        Message.SetNext(last, null);
                    }
                } else {
                    Message.SetNext(attaching, Message.GetNext(msg));
                }
            } else if(Message.IsTerminator(msg)) {
                PopDownTo(OP_LEVEL_MAX-1, expressions);
                AttachAndReplace(CurrentLevel(), msg);
            } else if(precedence != -1) { // An operator
                if(msgArgCount == 0) {
                    PopDownTo(precedence, expressions);
                    AttachToTopAndPush(msg, precedence);
                } else {
                    if(Message.typeOf(msg) == Message.Type.DETACH) {
                        Detach(msg);
                        PopDownTo(precedence, expressions);
                        AttachToTopAndPush(msg, precedence);
                    } else {
                        AttachAndReplace(CurrentLevel(), msg);
                    }
                }
            } else {
                AttachAndReplace(CurrentLevel(), msg);
            }
        }

        public void NextMessage(IList<IokeObject> expressions) {
            while(stack.Count > 0) {
                var o = stack[0];
                stack.RemoveAt(0);
                o.Finish(expressions);
            }
            Reset();
        }

        public void Reset() {
            currentLevel = 1;
            for(int i=0;i<OP_LEVEL_MAX;i++) {
                pool[i] = new Level(Level.Type.Unused);
            }
            Level level = pool[0];
            level.message = null;
            level.type = Level.Type.New;
            level.precedence = OP_LEVEL_MAX;

            stack.Clear();
            stack.Add(pool[0]);
        }
    }
}
