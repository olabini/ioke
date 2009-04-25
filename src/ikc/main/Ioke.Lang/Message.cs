
namespace Ioke.Lang {
    using System;
    using System.Collections;
    using System.Collections.Generic;
    using System.IO;
    using System.Text;
    using Antlr.Runtime;
    using Antlr.Runtime.Tree;
    using Ioke.Lang.Parser;
    using Ioke.Lang.Util;

    public class Message : IokeData {
        public enum Type {MESSAGE, DETACH, TERMINATOR, SEPARATOR, START_INTERPOLATION, START_RE_INTERPOLATION, END_INTERPOLATION, END_RE_INTERPOLATION, MIDDLE_INTERPOLATION, MIDDLE_RE_INTERPOLATION}

        string name;
        string file;
        int line;
        int pos;
        Type type = Type.MESSAGE;

        IList arguments;

        public IokeObject next;
        public IokeObject prev;

        object cached = null;

        public string Name {
            get { return name; }
            set { this.name = value; }
        }

        public string File {
            get { return file; }
            set { this.file = value; }
        }

        public int Line {
            get { return line; }
            set { this.line = value; }
        }

        public int Position {
            get { return pos; }
            set { this.pos = value; }
        }

        public void SetArguments(IList value) {
            this.arguments = value;
        }

        public static bool IsTerminator(object message) {
            return ((Message)IokeObject.dataOf(message)).type == Type.TERMINATOR;
        }

        public static IList GetArguments(object o) {
            return ((Message)IokeObject.dataOf(o)).arguments;
        }

        public static object GetEvaluatedArgument(object argument, IokeObject context) {
            if(!(argument is IokeObject)) {
                return argument;
            }
            
            IokeObject o = IokeObject.As(argument, context);
            if(!o.IsMessage) {
                return o;
            }
            
            return ((Message)IokeObject.dataOf(o)).EvaluateCompleteWithoutExplicitReceiver(o, context, context.RealContext);
        }

        public static Message Wrap(object cachedResult, Runtime runtime) {
            return Wrap("cachedResult", cachedResult, runtime);
        }

        public static Message Wrap(IokeObject cachedResult) {
            return Wrap("cachedResult", cachedResult, cachedResult.runtime);
        }

        public static Message Wrap(string name, object cachedResult, Runtime runtime) {
            Message m = new Message(runtime, name);
            m.cached = cachedResult;
            return m;
        }

        public static IokeObject Copy(object message) {
            IokeObject copy = IokeObject.As(message, null).Mimic(null, null);
            CopySourceLocation(message, copy);
            Message.SetPrev(copy, Message.GetPrev(message));
            Message.SetNext(copy, Message.GetNext(message));
            return copy;
        }

        public static IokeObject DeepCopy(object message) {
            IokeObject copy = IokeObject.As(message, null).Mimic(null, null);
            CopySourceLocation(message, copy);
            Message orgMsg = (Message)IokeObject.dataOf(message);
            Message copyMsg = (Message)IokeObject.dataOf(copy);
        
            copyMsg.type = orgMsg.type;
            copyMsg.cached = orgMsg.cached;

            IList newArgs = new SaneArrayList();
            foreach(object arg in orgMsg.arguments) {
                if(IokeObject.IsObjectMessage(arg)) {
                    newArgs.Add(DeepCopy(arg));
                } else {
                    newArgs.Add(arg);
                }
            }
            copyMsg.arguments = newArgs;

            if(orgMsg.next != null) {
                copyMsg.next = DeepCopy(orgMsg.next);
                Message.SetPrev(orgMsg.next, copy);
            }

            return copy;
        }

        public static void CopySourceLocation(object from, object to) {
            Message.SetFile(to, Message.GetFile(from));
            Message.SetLine(to, Message.GetLine(from));
            Message.SetPosition(to, Message.GetPosition(from));
        }

        public static void CacheValue(object message, object cachedValue) {
            ((Message)IokeObject.dataOf(message)).cached = cachedValue;
        }
        
        public static string GetFile(object message) {
            return IokeObject.As(message, null).File;
        }

        public static int GetLine(object message) {
            return IokeObject.As(message, null).Line;
        }

        public static int GetLine(object message, IokeObject ctx) {
            return IokeObject.As(message, ctx).Line;
        }

        public static int GetPosition(Object message) {
            return IokeObject.As(message, null).Position;
        }

        public static void SetFile(object message, string file) {
            ((Message)IokeObject.dataOf(message)).file = file;
        }

        public static void SetType(object message, Type type) {
            ((Message)IokeObject.dataOf(message)).type = type;
        }

        public static void SetLine(object message, int line) {
            ((Message)IokeObject.dataOf(message)).line = line;
        }

        public static void SetPosition(object message, int pos) {
            ((Message)IokeObject.dataOf(message)).pos = pos;
        }

        public static bool IsKeyword(object message) {
            if((message is IokeObject) && (IokeObject.dataOf(message) is Message)) {
                return ((Message)IokeObject.dataOf(message)).IsKeyword();
            } else {
                return false;
            }
        }

        public static string GetName(object o) {
            return ((Message)IokeObject.dataOf(o)).name;
        }

        public static void SetName(object o, string name) {
            ((Message)IokeObject.dataOf(o)).name = name;
        }

        public static bool HasName(object message, string name) {
            if((message is IokeObject) && (IokeObject.dataOf(message) is Message)) {
                return Message.GetName(message).Equals(name);
            } else {
                return false;
            }
        }

        public bool IsSymbolMessage {
            get { return name.Length > 1 && name[0] == ':'; }
        }

        public bool IsKeyword() {
            return name.Length > 1 && arguments.Count == 0 && name[name.Length-1] == ':';
        }

        public override bool IsMessage {
            get{ return true; }
        }

        public override string GetName(IokeObject self) {
            return name;
        }

        public override string GetFile(IokeObject self) {
            return file;
        }

        public override int GetLine(IokeObject self) {
            return line;
        }

        public override int GetPosition(IokeObject self) {
            return pos;
        }

        public static Type typeOf(IokeObject message) {
            return ((Message)IokeObject.dataOf(message)).type;
        }

        public override IList Arguments(IokeObject self) {
            return arguments;
        }

        public static IokeObject GetPrev(object message) {
            return ((Message)IokeObject.dataOf(message)).prev;
        }

        public static IokeObject GetNext(object message) {
            return ((Message)IokeObject.dataOf(message)).next;
        }

        public static void SetPrev(IokeObject message, IokeObject prev) {
            ((Message)IokeObject.dataOf(message)).prev = prev;
        }

        public static void SetNext(IokeObject message, IokeObject next) {
            ((Message)IokeObject.dataOf(message)).next = next;
        }

        public static void SetNextOfLast(IokeObject message, IokeObject next) {
            while(GetNext(message) != null) {
                message = GetNext(message);
            }
            ((Message)IokeObject.dataOf(message)).next = next;
        }

        public static void AddArg(object message, object arg) {
            IokeObject.As(message, null).Arguments.Add(arg);
        }

        public Message(Runtime runtime, string name) : this(runtime, name, null, Type.MESSAGE) {
        }

        Message(Runtime runtime, string name, Type type) : this(runtime, name, null, type) {
        }

        public Message(Runtime runtime, string name, object arg1) : this(runtime, name, arg1, Type.MESSAGE) {
        }

        public Message(Runtime runtime, string name, object arg1, Type type) {
            this.type = type;
            this.name = name;
            this.arguments = new SaneArrayList();
            this.file = ((IokeSystem)IokeObject.dataOf(runtime.System)).CurrentFile;

            if(arg1 != null) {
                arguments.Add(arg1);
            }
        }

        public override IokeData CloneData(IokeObject obj, IokeObject message, IokeObject context) {
            Message m = new Message(obj.runtime, name);
            m.arguments = new SaneArrayList(((Message)IokeObject.dataOf(obj)).arguments);
            m.type = ((Message)IokeObject.dataOf(obj)).type;
            m.file = ((Message)IokeObject.dataOf(obj)).file;
            m.line = ((Message)IokeObject.dataOf(obj)).line;
            m.pos = ((Message)IokeObject.dataOf(obj)).pos;
            return m;
        }

        public static void OpShuffle(IokeObject self) {
            if(self != null) {
                ((Message)IokeObject.dataOf(self.runtime.opShuffle)).SendTo(self.runtime.opShuffle, self.runtime.Ground, self);
            }
        }

        public static IokeObject NewFromStream(Runtime runtime, TextReader reader, IokeObject message, IokeObject context) {
            try {
                iokeParser parser = new iokeParser(new CommonTokenStream(new iokeLexer(new ANTLRReaderStream(reader))));
//                  Console.Error.WriteLine("parseFully ...");
                ITree t = parser.parseFully();
//                  Console.Error.WriteLine("t: " + t.ToStringTree());

                if(t == null) {
                    Message mx = new Message(runtime, ".", null, Type.TERMINATOR);
                    mx.Line = 0;
                    mx.Position = 0;
                    return runtime.CreateMessage(mx);
                }

                IokeObject m = FromTree(runtime, t);
//                  Console.Error.WriteLine("m: " + m);

//                 Console.Error.WriteLine("m1: " + m);
                OpShuffle(m);
//                 Console.Error.WriteLine("m2: " + m);

                return m;
            } catch(Exception e) {
                runtime.ReportNativeException(e, message, context);
                return null;
            }
        }


        public static IokeObject FromTree(Runtime runtime, ITree tree) {
//             Console.Error.WriteLine(" fromTree(" + tree.ToStringTree() + ")");
            Message m = null;
            int argStart = 0;

            if(!tree.IsNil) {
                switch(tree.Type) {
                case iokeParser.RegexpLiteral: {
                    string s = tree.Text;
                    char first = s[0];
                    char second = s[1];
                    char last = s[s.Length-1];
                    if(first == '#' && last != '{') {
                        if(second == 'r') {
                            int lastIndex = s.LastIndexOf(']');
                            m = new Message(runtime, "internal:createRegexp", s.Substring(3, lastIndex-3));
                            m.arguments.Add(s.Substring(lastIndex+1));
                        } else {
                            int lastIndex = s.LastIndexOf('/');
                            m = new Message(runtime, "internal:createRegexp", s.Substring(2, lastIndex-2));
                            m.arguments.Add(s.Substring(lastIndex+1));
                        }
                        m.Line = tree.Line;
                        m.Position = tree.CharPositionInLine;
                        return runtime.CreateMessage(m);
                    } else if(first == '}' && last == '{') {
                        m = new Message(runtime, "internal:createText", s.Substring(1, s.Length-3), Type.MIDDLE_RE_INTERPOLATION);
                        m.Line = tree.Line;
                        m.Position = tree.CharPositionInLine;
                        return runtime.CreateMessage(m);
                    } else if(first == '}') {
                        int lastIndex = s.LastIndexOf('/');
                        if(lastIndex == -1) {
                            lastIndex = s.LastIndexOf(']');
                        }
                        m = new Message(runtime, "internal:createText", s.Substring(1, lastIndex-1), Type.END_RE_INTERPOLATION);
                        m.arguments.Add(s.Substring(lastIndex+1));
                        m.Line = tree.Line;
                        m.Position = tree.CharPositionInLine;
                        return runtime.CreateMessage(m);
                    } else {
                        m = new Message(runtime, "internal:createText", s.Substring(2, s.Length-4), Type.START_RE_INTERPOLATION);
                        m.Line = tree.Line;
                        m.Position = tree.CharPositionInLine;
                        return runtime.CreateMessage(m);
                    }
                }
                case iokeParser.StringLiteral: {
                    string s = tree.Text;
                    char first = s[0];
                    char last = s[s.Length-1];
                    if(first == '"' && last == '"') {
                        m = new Message(runtime, "internal:createText", s.Substring(1, s.Length-2));
                        m.Line = tree.Line;
                        m.Position = tree.CharPositionInLine;
                        return runtime.CreateMessage(m);
                    } else if(first == '#' && last == ']') {
                        m = new Message(runtime, "internal:createText", s.Substring(2, s.Length-3));
                        m.Line = tree.Line;
                        m.Position = tree.CharPositionInLine;
                        return runtime.CreateMessage(m);
                    } else {
                        if(first == '}' && (last == '"' || last == ']')) { // This is an ending
                            m = new Message(runtime, "internal:createText", s.Substring(1, s.Length-2), Type.END_INTERPOLATION);
                            m.Line = tree.Line;
                            m.Position = tree.CharPositionInLine;
                            return runtime.CreateMessage(m);
                        } else if(first == '"') { // This is a beginning
                            m = new Message(runtime, "internal:createText", s.Substring(1, s.Length-3), Type.START_INTERPOLATION);
                            m.Line = tree.Line;
                            m.Position = tree.CharPositionInLine;
                            return runtime.CreateMessage(m);
                        } else if(first == '#') { // This is a beginning
                            m = new Message(runtime, "internal:createText", s.Substring(2, s.Length-4), Type.START_INTERPOLATION);
                            m.Line = tree.Line;
                            m.Position = tree.CharPositionInLine;
                            return runtime.CreateMessage(m);
                        } else { // This is in the middle
                            m = new Message(runtime, "internal:createText", s.Substring(1, s.Length-3), Type.MIDDLE_INTERPOLATION);
                            m.Line = tree.Line;
                            m.Position = tree.CharPositionInLine;
                            return runtime.CreateMessage(m);
                        }
                    }
                }
                case iokeParser.NumberLiteral:
                    m = new Message(runtime, "internal:createNumber", tree.Text);
                    m.Line = tree.Line;
                    m.Position = tree.CharPositionInLine;
                    return runtime.CreateMessage(m);
                case iokeParser.DecimalLiteral:
                    m = new Message(runtime, "internal:createDecimal", tree.Text);
                    m.Line = tree.Line;
                    m.Position = tree.CharPositionInLine;
                    return runtime.CreateMessage(m);
                case iokeParser.UnitLiteral: {
                    string text = tree.Text;
                    int ending = text.Length-1;
                    while(!Char.IsDigit(text[ending])) {
                        ending--;
                    }
                    Message mex = new Message(runtime, "internal:createNumber", text.Substring(0, ending+1));
                    mex.Line = tree.Line;
                    mex.Position = tree.CharPositionInLine;
                    m = new Message(runtime, "internal:createUnit", runtime.CreateMessage(mex));
                    m.Line = tree.Line;
                    m.Position = tree.CharPositionInLine;
                    return runtime.CreateMessage(m);
                }
                case iokeParser.UnitDecimalLiteral: {
                    string text = tree.Text;
                    int ending = text.Length-1;
                    while(!Char.IsDigit(text[ending])) {
                        ending--;
                    }
                    Message mex = new Message(runtime, "internal:createDecimal", text.Substring(0, ending+1));
                    mex.Line = tree.Line;
                    mex.Position = tree.CharPositionInLine;
                    m = new Message(runtime, "internal:createUnit", mex);
                    m.Line = tree.Line;
                    m.Position = tree.CharPositionInLine;
                    return runtime.CreateMessage(m);
                }
                case iokeParser.Identifier:
                    m = new Message(runtime, tree.Text);
                    m.Line = tree.Line;
                    m.Position = tree.CharPositionInLine;
                    return runtime.CreateMessage(m);
                case iokeParser.Terminator:
                    m = new Message(runtime, ".", null, Type.TERMINATOR);
                    m.Line = tree.Line;
                    m.Position = tree.CharPositionInLine;
                    return runtime.CreateMessage(m);
                case iokeParser.Comma:
                    m = new Message(runtime, ",", null, Type.SEPARATOR);
                    m.Line = tree.Line;
                    m.Position = tree.CharPositionInLine;
                    return runtime.CreateMessage(m);
                case iokeParser.MESSAGE: {
                    string text = tree.GetChild(0).Text;
                    m = new Message(runtime, text);
                    int count = tree.ChildCount;
                    argStart = 1;
                    if(count > 1) {
                        int diff = tree.GetChild(1).CharPositionInLine - (tree.CharPositionInLine+text.Length);
                        if(diff != 0) {
                            m.type = Type.DETACH;
                        }
                        argStart = 2;
                    }

                    break;
                }
                default:
                    Console.Error.WriteLine("ERROR: Can't handle " + tree + " : " + tree.Type);
                    return null;
                }
                
                m.Line = tree.Line;
                m.Position = tree.CharPositionInLine;
            } 

            IokeObject mx = m == null ? (IokeObject)null : runtime.CreateMessage(m);

            object head = null;
            IList<IokeObject> currents = new SaneList<IokeObject>();

            IList<IList<IokeObject>> oldCurrents = new SaneList<IList<IokeObject>>();
            IList<object> oldHeads = new SaneList<object>();
            IList<IokeObject> oldMx = new SaneList<IokeObject>();

            for(int i=argStart,j=tree.ChildCount; i<j; i++) {
                IokeObject created = FromTree(runtime, tree.GetChild(i));

                switch(Message.typeOf(created)) {
                case Type.START_INTERPOLATION:{
                    Message mvv = new Message(runtime, "internal:concatenateText");
                    mvv.Line = tree.Line;
                    mvv.Position = tree.CharPositionInLine;
                    oldCurrents.Insert(0, currents);
                    oldHeads.Insert(0, head);
                    oldMx.Insert(0, mx);

                    currents = new SaneList<IokeObject>();
                    head = created;
                    mx = runtime.CreateMessage(mvv);

                    created = runtime.CreateMessage(new Message(runtime, ",", null, Type.SEPARATOR));
                    break;
                }
                case Type.START_RE_INTERPOLATION:{
                    Message mvv = new Message(runtime, "internal:compositeRegexp");
                    mvv.Line = tree.Line;
                    mvv.Position = tree.CharPositionInLine;
                    oldCurrents.Insert(0, currents);
                    oldHeads.Insert(0, head);
                    oldMx.Insert(0, mx);

                    currents = new SaneList<IokeObject>();
                    head = created.Arguments[0];
                    mx = runtime.CreateMessage(mvv);

                    created = runtime.CreateMessage(new Message(runtime, ",", null, Type.SEPARATOR));
                    break;
                }
                case Type.MIDDLE_INTERPOLATION:
                    mx.Arguments.Add(head);

                    currents.Clear();
                    head = created;

                    created = runtime.CreateMessage(new Message(runtime, ",", null, Type.SEPARATOR));
                    break;
                case Type.MIDDLE_RE_INTERPOLATION:
                    mx.Arguments.Add(head);

                    currents.Clear();
                    head = created.Arguments[0];

                    created = runtime.CreateMessage(new Message(runtime, ",", null, Type.SEPARATOR));
                    break;
                case Type.END_INTERPOLATION:
                    mx.Arguments.Add(head);
                    mx.Arguments.Add(created);

                    currents = oldCurrents[0];
                    oldCurrents.RemoveAt(0);

                    head = oldHeads[0];
                    oldHeads.RemoveAt(0);

                    created = mx;

                    mx = oldMx[0];
                    oldMx.RemoveAt(0);

                    break;
                case Type.END_RE_INTERPOLATION:
                    mx.Arguments.Add(head);
                    mx.Arguments.Add(created.Arguments[0]);
                    mx.Arguments.Add(created.Arguments[1]);

                    currents = oldCurrents[0];
                    oldCurrents.RemoveAt(0);

                    head = oldHeads[0];
                    oldHeads.RemoveAt(0);

                    created = mx;

                    mx = oldMx[0];
                    oldMx.RemoveAt(0);
                    break;
                }

                if(Message.typeOf(created) == Type.TERMINATOR && head == null && currents.Count == 0) {
                    continue;
                }

                if(Message.typeOf(created) == Type.SEPARATOR && mx != null) {
                    mx.Arguments.Add(head);
                    currents.Clear();
                    head = null;
                } else {
                    if(Message.typeOf(created) == Type.TERMINATOR && currents.Count > 1) {
                        while(currents.Count > 1) {
                            currents.RemoveAt(0);
                        }
                    }
                    Message.SetPrev(created, currents.Count > 0 ? currents[0] : null);
                    
                    if(head == null && Message.typeOf(created) != Type.TERMINATOR) {
                        head = created;
                    }

                    if(currents.Count > 0) {
                        Message.SetNextOfLast(currents[0], created);
                        currents[0] = created;
                    } else {
                        currents.Insert(0, created);
                    }
                }
            }

            if(mx != null && head != null) {
                mx.Arguments.Add(head);
            }

            return mx == null ? (IokeObject)head : mx;
        }

        public static string Code(IokeObject message) {
            if(message == null) {
                return "";
            }
            return ((Message)IokeObject.dataOf(message)).Code();
        }

        public static string FormattedCode(IokeObject message, int indent, IokeObject ctx) {
            if(message == null) {
                return "";
            }
            return ((Message)IokeObject.dataOf(message)).FormattedCode(indent, ctx);
        }

        public string FormattedCode(int indent, IokeObject ctx) {
            StringBuilder b = new StringBuilder();

            CurrentFormattedCode(b, indent, ctx);
        
            if(next != null) {
                if(this.type != Type.TERMINATOR) {
                    b.Append(" ");
                }

                b.Append(Message.FormattedCode(next, indent, ctx));
            }

            return b.ToString();
        }
        
        public static string ThisCode(IokeObject message) {
            return ((Message)IokeObject.dataOf(message)).ThisCode();
        }

        public string ThisCode() {
            StringBuilder b = new StringBuilder();
            CurrentCode(b);
            return b.ToString();
        }

        public string Code() {
            StringBuilder b = new StringBuilder();

            CurrentCode(b);
        
            if(next != null) {
                if(this.type != Type.TERMINATOR) {
                    b.Append(" ");
                }
                
                b.Append(Code(next));
            }

            return b.ToString();
        }

        private void CurrentCode(StringBuilder b) {
            if(this.name.Equals("internal:createText") && (this.arguments.Count > 0 && this.arguments[0] is string)) {
                b.Append('"').Append(this.arguments[0]).Append('"');
            } else if(this.name.Equals("internal:createRegexp") && (this.arguments.Count > 0 && this.arguments[0] is string)) {
                b.Append("#/").Append(this.arguments[0]).Append('/').Append(this.arguments[1]);
            } else if(this.name.Equals("internal:createNumber") && (this.arguments.Count > 0 && this.arguments[0] is string)) {
                b.Append(this.arguments[0]);
            } else if(this.name.Equals("internal:createDecimal") && (this.arguments.Count > 0 && this.arguments[0] is string)) {
                b.Append(this.arguments[0]);
            } else if(cached != null && this.name.Equals("cachedResult")) {
                b.Append(cached);
            } else if(this.type == Type.TERMINATOR) {
                b.Append(".\n");
            } else {
                b.Append(this.name);
                if(arguments.Count > 0 || this.name.Length == 0) {
                    b.Append("(");
                    string sep = "";
                    foreach(object o in arguments) {
                        if(!(o is IokeObject) || !(IokeObject.dataOf(o) is Message)) {
                            b.Append(sep).Append(o);
                        } else {
                            b.Append(sep).Append(Code((IokeObject)o));
                        }

                        sep = ", ";
                    }
                    b.Append(")");
                }
            }
        }

        private void CurrentFormattedCode(StringBuilder b, int indent, IokeObject ctx) {
            if(this.name.Equals("internal:createText") && (this.arguments.Count > 0 && this.arguments[0] is string)) {
                b.Append('"').Append(this.arguments[0]).Append('"');
            } else if(this.name.Equals("internal:concatenateText")) {
                b.Append('"');
                for(int i=0;i<this.arguments.Count;i++) {
                    object arg = this.arguments[i];
                    if(Message.GetName(arg).Equals("internal:createText") && (Message.GetArguments(arg).Count > 0 && Message.GetArguments(arg)[0] is string)) {
                        b.Append(Message.GetArguments(arg)[0]);
                    } else {
                        b.Append("#{");
                        b.Append(Message.FormattedCode(IokeObject.As(arg, ctx), 0, ctx));
                        b.Append("}");
                    }
                }
                b.Append('"');
            } else if(this.name.Equals("internal:createRegexp") && (this.arguments.Count > 0 && this.arguments[0] is string)) {
                b.Append("#/").Append(this.arguments[0]).Append('/').Append(this.arguments[1]);
            } else if(this.name.Equals("internal:createNumber") && (this.arguments.Count > 0 && this.arguments[0] is string)) {
                b.Append(this.arguments[0]);
            } else if(this.name.Equals("internal:createDecimal") && (this.arguments.Count > 0 && this.arguments[0] is string)) {
                b.Append(this.arguments[0]);
            } else if(cached != null && this.name.Equals("cachedResult")) {
                b.Append(cached);
            } else if(this.name.Equals("=")) {
                b.Append(this.arguments[0]);
                b.Append(" = ");
                b.Append(Message.FormattedCode(IokeObject.As(this.arguments[1], ctx), indent+2, ctx));
            } else if(this.type == Type.TERMINATOR) {
                b.Append("\n");
                for(int i=0;i<indent;i++) {
                    b.Append(" ");
                }
            } else {
                b.Append(this.name);
                int theLine = line;
                if(arguments.Count > 0 || this.name.Length == 0) {
                    b.Append("(");
                    string sep = "";
                    foreach(object o in arguments) {
                        if(o != null) {
                            b.Append(sep);

                            if(o is string) {
                                b.Append(o);
                            } else {
                                if(Message.GetLine(o, ctx) != theLine) {
                                    int diff = Message.GetLine(o, ctx) - theLine;
                                    theLine += diff;
                                    b.Append("\n");
                                    for(int i=0;i<(indent+2);i++) {
                                        b.Append(" ");
                                    }
                                }

                                b.Append(Message.FormattedCode(IokeObject.As(o, ctx), indent+2, ctx));
                            }

                            sep = ", ";
                        }
                    }
                    b.Append(")");
                }
            }
        }

        public override string ToString(IokeObject self) {
            return Code();
        }

        public IList GetEvaluatedArguments(IokeObject self, IokeObject context) {
            IList args = new SaneArrayList(arguments.Count);
            foreach(object o in arguments) {
                args.Add(GetEvaluatedArgument(o, context));
            }
            return args;
        }

        public object GetEvaluatedArgument(IokeObject message, int index, IokeObject context) {
            return Message.GetEvaluatedArgument(arguments[index], context);
        }

        public object SendTo(IokeObject self, IokeObject context, object recv) {
            if(cached != null) {
                return cached;
            }

            return IokeObject.Perform(recv, context, self);
        }

        public object SendTo(IokeObject self, IokeObject context, object recv, object argument) {
            if(cached != null) {
                return cached;
            }

            IokeObject m = self.AllocateCopy(self, context);
            m.MimicsWithoutCheck(context.runtime.Message);
            m.Arguments.Clear();
            m.Arguments.Add(argument);
            return IokeObject.Perform(recv, context, m);
        }

        public object SendTo(IokeObject self, IokeObject context, object recv, object arg1, object arg2) {
            if(cached != null) {
                return cached;
            }
            
            IokeObject m = self.AllocateCopy(self, context);
            m.MimicsWithoutCheck(context.runtime.Message);
            m.Arguments.Clear();
            m.Arguments.Add(arg1);
            m.Arguments.Add(arg2);
            return IokeObject.Perform(recv, context, m);
        }

        public object SendTo(IokeObject self, IokeObject context, object recv, IList args) {
            if(cached != null) {
                return cached;
            }

            IokeObject m = self.AllocateCopy(self, context);
            m.MimicsWithoutCheck(context.runtime.Message);
            m.Arguments.Clear();
            foreach(object o in args) m.Arguments.Add(o);
            return IokeObject.Perform(recv, context, m);
        }

        public object EvaluateComplete(IokeObject self) {
            IokeObject ctx = self.runtime.Ground;
            object current = ctx;
            object tmp = null;
            object lastReal = self.runtime.nil;
            IokeObject m = self;
            while(m != null) {
                string name = m.Name;

                if(name.Equals(".")) {
                    current = ctx;
                } else if(name.Length > 0 && m.Arguments.Count == 0 && name[0] == ':') {
                    current = self.runtime.GetSymbol(name.Substring(1));
                    Message.CacheValue(m, current);
                    lastReal = current;
                } else {
                    tmp = ((Message)IokeObject.dataOf(m)).SendTo(m, ctx, current);
                    if(tmp != null) {
                        current = tmp;
                        lastReal = current;
                    }
                }
                m = Message.GetNext(m);
            }
            return lastReal;
        }

        public virtual object EvaluateCompleteWith(IokeObject self, IokeObject ctx, object ground) {
            object current = ctx;
            object tmp = null;
            object lastReal = self.runtime.nil;
            IokeObject m = self;
            while(m != null) {
                string name = m.Name;

                if(name.Equals(".")) {
                    current = ctx;
                } else if(name.Length > 0 && m.Arguments.Count == 0 && name[0] == ':') {
                    current = self.runtime.GetSymbol(name.Substring(1));
                    Message.CacheValue(m, current);
                    lastReal = current;
                } else {
                    tmp = ((Message)IokeObject.dataOf(m)).SendTo(m, ctx, current);
                    if(tmp != null) {
                        current = tmp;
                        lastReal = current;
                    }
                }
                m = Message.GetNext(m);
            }
            return lastReal;
        }

        public virtual object EvaluateCompleteWithReceiver(IokeObject self, IokeObject ctx, object ground, object receiver) {
            object current = receiver;
            object tmp = null;
            object lastReal = self.runtime.nil;
            IokeObject m = self;
            while(m != null) {
                string name = m.Name;

                if(name.Equals(".")) {
                    current = ctx;
                } else if(name.Length > 0 && m.Arguments.Count == 0 && name[0] == ':') {
                    current = self.runtime.GetSymbol(name.Substring(1));
                    Message.CacheValue(m, current);
                    lastReal = current;
                } else {
                    tmp = ((Message)IokeObject.dataOf(m)).SendTo(m, ctx, current);
                    if(tmp != null) {
                        current = tmp;
                        lastReal = current;
                    }
                }
                m = Message.GetNext(m);
            }
            return lastReal;
        }

        public object EvaluateCompleteWithoutExplicitReceiver(IokeObject self, IokeObject ctx, object ground) {
            object current = ctx;
            object tmp = null;
            object lastReal = self.runtime.nil;
            IokeObject m = self;
            while(m != null) {
                string name = m.Name;

                if(name.Equals(".")) {
                    current = ctx;
                } else if(name.Length > 0 && m.Arguments.Count == 0 && name[0] == ':') {
                    current = self.runtime.GetSymbol(name.Substring(1));
                    Message.CacheValue(m, current);
                    lastReal = current;
                } else {
                    tmp = ((Message)IokeObject.dataOf(m)).SendTo(m, ctx, current);
                    if(tmp != null) {
                        current = tmp;
                        lastReal = current;
                    }
                }
                m = Message.GetNext(m);
            }
            return lastReal;
        }

        public object EvaluateCompleteWith(IokeObject self, object ground) {
            IokeObject ctx = IokeObject.As(ground, self);
            object current = ctx;
            object tmp = null;
            object lastReal = self.runtime.nil;
            IokeObject m = self;
            while(m != null) {
                string name = m.Name;

                if(name.Equals(".")) {
                    current = ctx;
                } else if(name.Length > 0 && m.Arguments.Count == 0 && name[0] == ':') {
                    current = self.runtime.GetSymbol(name.Substring(1));
                    Message.CacheValue(m, current);
                    lastReal = current;
                } else {
                    tmp = ((Message)IokeObject.dataOf(m)).SendTo(m, ctx, current);
                    if(tmp != null) {
                        current = tmp;
                        lastReal = current;
                    }
                }
                m = Message.GetNext(m);
            }
            return lastReal;
        }

        public override void Init(IokeObject obj) {
            obj.Kind = "Message";
            obj.Mimics(IokeObject.As(obj.runtime.Mixins.GetCell(null, null, "Enumerable"), null), obj.runtime.nul, obj.runtime.nul);

            obj.RegisterMethod(obj.runtime.NewNativeMethod("Will rearrange this message and all submessages to follow regular C style operator precedence rules. Will use Message OperatorTable to guide this operation. The operation is mutating, but should not change anything if done twice.", new NativeMethod.WithNoArguments("shuffleOperators", (method, context, message, on, outer) => {
                            IOperatorShuffler levels = method.runtime.operatorShufflerFactory.Create(IokeObject.As(on, context), context, message);
                            var expressions = new SaneList<IokeObject>();
                            if(on is IokeObject) {
                                expressions.Insert(0, IokeObject.As(on, context));
                                while(expressions.Count > 0) {
                                    IokeObject n = expressions[0];
                                    expressions.RemoveAt(0);
                                    do {
                                        levels.Attach(n, expressions);
                                        foreach(object o in n.Arguments) {
                                            if(o is IokeObject) {
                                                expressions.Insert(0, IokeObject.As(o, context));
                                            }
                                        }
                                    } while((n = Message.GetNext(n)) != null);
                        
                                    levels.NextMessage(expressions);
                                }
                            }
                            
                            return on;
                        })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("Takes one or more evaluated arguments and sends this message chain to where the first argument is ground, and if there are more arguments, the second is the receiver, and the rest will be the arguments", 
                                                               new NativeMethod("evaluateOn", DefaultArgumentsDefinition.builder()
                                                                                .WithRequiredPositional("ground")
                                                                                .WithOptionalPositional("receiver", "ground")
                                                                                .WithRest("arguments")
                                                                                .Arguments,
                                                                                (method, on, args, keywords, context, message) => {
                                                                                    IokeObject messageGround = IokeObject.As(args[0], context);
                                                                                    IokeObject receiver = messageGround;
                                                                                    int size = args.Count;
                                                                                    if(size > 1) {
                                                                                        receiver = IokeObject.As(args[1], context);
                                                                                        if(size > 2) {
                                                                                            IokeObject m = IokeObject.As(on, context).AllocateCopy(IokeObject.As(on, context), context);
                                                                                            m.Arguments.Clear();
                                                                                            for(int ix=2;ix<size;ix++) {
                                                                                                m.Arguments.Add(args[ix]);
                                                                                            }
                                                                                            on = m;
                                                                                        }
                                                                                    }
                    
                                                                                    IokeObject msg = IokeObject.As(on, context);
                                                                                    return ((Message)IokeObject.dataOf(msg)).EvaluateCompleteWithReceiver(msg, messageGround, messageGround, receiver);
                                                                                })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("returns a deep clone of this message chain, starting at the current point.", 
                                                           new TypeCheckingNativeMethod.WithNoArguments("deepCopy", obj,
                                                                                                        (method, on, args, keywords, context, message) => {
                                                                                                            return Message.DeepCopy(on);
                                                                                                        })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("Returns a code representation of the object", 
                                                           new TypeCheckingNativeMethod.WithNoArguments("code", obj,
                                                                                                        (method, on, args, keywords, context, message) => {
                                                                                                            return method.runtime.NewText(((Message)IokeObject.dataOf(on)).Code());
                                                           })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("Returns the unevaluated arguments for this message", 
                                                           new TypeCheckingNativeMethod.WithNoArguments("arguments", obj,
                                                                                                        (method, on, args, keywords, context, message) => {
                                                                                                            return context.runtime.NewList(((Message)IokeObject.dataOf(on)).arguments);
                                                           })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("Returns a formatted code representation of the object", 
                                                           new TypeCheckingNativeMethod.WithNoArguments("formattedCode", obj,
                                                                                                        (method, on, args, keywords, context, message) => {
                                                                                                            return method.runtime.NewText(Message.FormattedCode(IokeObject.As(on, context), 0, context));
                                                           })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("returns the name of this message", 
                                                           new TypeCheckingNativeMethod.WithNoArguments("name", obj,
                                                                                                        (method, on, args, keywords, context, message) => {
                                                                                                            return method.runtime.GetSymbol(((Message)IokeObject.dataOf(on)).name);
                                                           })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("sets the name of the message and then returns that name", 
                                                           new TypeCheckingNativeMethod("name=", TypeCheckingArgumentsDefinition.builder()
                                                                                        .ReceiverMustMimic(obj)
                                                                                        .WithRequiredPositional("newName")
                                                                                        .Arguments,
                                                                                        (method, on, args, keywords, context, message) => {
                                                                                            object o = args[0];
                                                                                            string name = null;
                                                                                            if(IokeObject.dataOf(o) is Symbol) {
                                                                                                name = Symbol.GetText(o); 
                                                                                            } else if(IokeObject.dataOf(o) is Text) {
                                                                                                name = Text.GetText(o);
                                                                                            } else {
                                                                                                name = Text.GetText(IokeObject.ConvertToText(o, message, context, true));
                                                                                            }
                    
                                                                                            Message.SetName(IokeObject.As(on, context), name);
                                                                                            return o;
                                                                                        })));
            
            obj.RegisterMethod(obj.runtime.NewNativeMethod("sets the next pointer of the message and then returns that pointer", 
                                                           new TypeCheckingNativeMethod("next=", TypeCheckingArgumentsDefinition.builder()
                                                                                        .ReceiverMustMimic(obj)
                                                                                        .WithRequiredPositional("newNext")
                                                                                        .Arguments,
                                                                                        (method, on, args, keywords, context, message) => {
                                                                                            object o = args[0];
                                                                                            if(o == context.runtime.nil) {
                                                                                                Message.SetNext(IokeObject.As(on, context), null);
                                                                                            } else {
                                                                                                o = context.runtime.Message.ConvertToThis(o, message, context);
                                                                                                Message.SetNext(IokeObject.As(on, context), IokeObject.As(o, context));
                                                                                            }
                                                                                            return o;
                                                                                        })));
        


            obj.RegisterMethod(obj.runtime.NewNativeMethod("sets the prev pointer of the message and then returns that pointer", 
                                                           new TypeCheckingNativeMethod("prev=", TypeCheckingArgumentsDefinition.builder()
                                                                                        .ReceiverMustMimic(obj)
                                                                                        .WithRequiredPositional("newPrev")
                                                                                        .Arguments,
                                                                                        (method, on, args, keywords, context, message) => {
                                                                                            object o = args[0];
                                                                                            if(o == context.runtime.nil) {
                                                                                                Message.SetPrev(IokeObject.As(on, context), null);
                                                                                            } else {
                                                                                                o = context.runtime.Message.ConvertToThis(o, message, context);
                                                                                                Message.SetPrev(IokeObject.As(on, context), IokeObject.As(o, context));
                                                                                            }
                                                                                            return o;
                                                                                        })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("returns the file name where this message is written", 
                                                           new TypeCheckingNativeMethod.WithNoArguments("filename", obj,
                                                                                                        (method, on, args, keywords, context, message) => {
                                                                                                            return method.runtime.NewText(((Message)IokeObject.dataOf(on)).file);
                                                                                                        })));
        
            obj.RegisterMethod(obj.runtime.NewNativeMethod("returns the line where this message is written", 
                                                           new TypeCheckingNativeMethod.WithNoArguments("line", obj,
                                                                                                        (method, on, args, keywords, context, message) => {
                                                                                                            return method.runtime.NewNumber(((Message)IokeObject.dataOf(on)).line);
                                                                                                        })));
        
            obj.RegisterMethod(obj.runtime.NewNativeMethod("returns the position on the line where this message is written", 
                                                           new TypeCheckingNativeMethod.WithNoArguments("position", obj,
                                                                                                        (method, on, args, keywords, context, message) => {
                                                                                                            return method.runtime.NewNumber(((Message)IokeObject.dataOf(on)).pos);
                                                                                                        })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("returns the next message in the chain, or nil", 
                                                           new TypeCheckingNativeMethod.WithNoArguments("next", obj,
                                                                                                        (method, on, args, keywords, context, message) => {
                                                                                                            IokeObject next = ((Message)IokeObject.dataOf(on)).next;
                                                                                                            if(next == null) {
                                                                                                                return context.runtime.nil;
                                                                                                            } else {
                                                                                                                return next;
                                                                                                            }
                                                                                                        })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("returns the last message in the chain", 
                                                           new TypeCheckingNativeMethod.WithNoArguments("last", obj,
                                                                                                        (method, on, args, keywords, context, message) => {
                                                                                                            IokeObject current = IokeObject.As(on, context);
                                                                                                            while(GetNext(current) != null) {
                                                                                                                current = GetNext(current);
                                                                                                            }
                                                                                                            return current;
                                                                                                        })));
        
            obj.RegisterMethod(obj.runtime.NewNativeMethod("returns the previous message in the chain, or nil", 
                                                           new TypeCheckingNativeMethod.WithNoArguments("prev", obj,
                                                                                                        (method, on, args, keywords, context, message) => {
                                                                                                            IokeObject prev = ((Message)IokeObject.dataOf(on)).prev;
                                                                                                            if(prev == null) {
                                                                                                                return context.runtime.nil;
                                                                                                            } else {
                                                                                                                return prev;
                                                                                                            }
                                                                                                        })));
        
            obj.RegisterMethod(obj.runtime.NewNativeMethod("returns true when this message is a terminator, otherwise false", 
                                                           new TypeCheckingNativeMethod.WithNoArguments("terminator?", obj,
                                                                                                        (method, on, args, keywords, context, message) => {
                                                                                                            return Message.IsTerminator(on) ? context.runtime.True : context.runtime.False;
                                                                                                        })));
            obj.RegisterMethod(obj.runtime.NewNativeMethod("takes one index, and a context and returns the evaluated argument at that index.", 
                                                           new NativeMethod("evalArgAt", DefaultArgumentsDefinition.builder()
                                                                            .WithRequiredPositional("argumentIndex")
                                                                            .WithRequiredPositional("context")
                                                                            .Arguments,
                                                                            (method, on, args, keywords, context, message) => {
                                                                                int index = Number.ExtractInt(args[0], message, context);
                                                                                IokeObject newContext = IokeObject.As(args[1], context);
                                                                                IokeObject _m =  IokeObject.As(on, context);
                                                                                return ((Message)IokeObject.dataOf(_m)).GetEvaluatedArgument(_m, index, newContext);
                                                                            })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("Takes one evaluated argument and returns a message that wraps the value of that argument.", 
                                                           new NativeMethod("wrap", DefaultArgumentsDefinition.builder()
                                                                            .WithRequiredPositional("value")
                                                                            .Arguments,
                                                                            (method, on, args, keywords, context, message) => {
                                                                                return context.runtime.CreateMessage(Message.Wrap(IokeObject.As(args[0], context)));
                                                                            })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("evaluates the argument and makes it the new next pointer of the receiver. it also modifies the argument so its prev pointer points back to this message. if the argument is nil, the next pointer will be erased. it then returns the receiving message.", 
                                                           new TypeCheckingNativeMethod("->", TypeCheckingArgumentsDefinition.builder()
                                                                                        .ReceiverMustMimic(obj)
                                                                                        .WithRequiredPositional("nextMessage")
                                                                                        .Arguments,
                                                                                        (method, on, args, keywords, context, message) => {
                                                                                            object arg = args[0];
                                                                                            if(arg == context.runtime.nil) {
                                                                                                Message.SetNext(IokeObject.As(on, context), null);
                                                                                            } else {
                                                                                                arg = context.runtime.Message.ConvertToThis(arg, message, context);
                                                                                                Message.SetNext(IokeObject.As(on, context), IokeObject.As(arg, context));
                                                                                                Message.SetPrev(IokeObject.As(arg, context), IokeObject.As(on, context));
                                                                                            }
                                                                                            return arg;
                                                                                        })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("evaluates the argument and adds it to the beginning of the argument list of this message. it then returns the receiving message.", 
                                                           new NativeMethod(">>", DefaultArgumentsDefinition.builder()
                                                                            .WithRequiredPositional("newArgument")
                                                                            .Arguments,
                                                                            (method, on, args, keywords, context, message) => {
                                                                                IokeObject.As(on, context).Arguments.Insert(0, args[0]);
                                                                                return on;
                                                                            })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("evaluates the argument and adds it to the argument list of this message. it then returns the receiving message.", 
                                                           new NativeMethod("appendArgument", DefaultArgumentsDefinition.builder()
                                                                            .WithRequiredPositional("newArgument")
                                                                            .Arguments,
                                                                            (method, on, args, keywords, context, message) => {
                                                                                IokeObject.As(on, context).Arguments.Add(args[0]);
                                                                                return on;
                                                                            })));
            obj.AliasMethod("appendArgument", "<<", null, null);

            obj.RegisterMethod(obj.runtime.NewNativeMethod("returns a string that describes this message as a stack trace elemtn", 
                                                           new TypeCheckingNativeMethod.WithNoArguments("asStackTraceText", obj,
                                                                                                        (method, on, args, keywords, context, message) => {
                                                                                                            return context.runtime.NewText(Message.GetStackTraceText(on));
                                                                                                        })));
            obj.RegisterMethod(obj.runtime.NewNativeMethod("returns true if this message is a keyword parameter or not", 
                                                           new TypeCheckingNativeMethod.WithNoArguments("keyword?", obj,
                                                                                                        (method, on, args, keywords, context, message) => {
                                                                                                            return ((Message)IokeObject.dataOf(on)).IsKeyword() ? context.runtime.True : context.runtime.False;
                                                                                                        })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("returns true if this message is a symbol message or not", 
                                                           new TypeCheckingNativeMethod.WithNoArguments("symbol?", obj,
                                                                                                        (method, on, args, keywords, context, message) => {
                                                                                                            return ((Message)IokeObject.dataOf(on)).IsSymbolMessage ? context.runtime.True : context.runtime.False;
                                                                                                        })));
            
            obj.RegisterMethod(obj.runtime.NewNativeMethod("takes either one or two arguments. if one argument is given, it should be a message chain that will be sent to each message in the chain, recursively. the result will be thrown away. if two arguments are given, the first is an unevaluated name that will be set to each of the messages in the chain in succession, and then the second argument will be evaluated in a scope with that argument in it. the code will evaluate in a lexical context, and if the argument name is available outside the context, it will be shadowed. the method will return the original message.", 
                                                           new NativeMethod("walk", DefaultArgumentsDefinition.builder()
                                                                            .WithOptionalPositionalUnevaluated("argOrCode")
                                                                            .WithOptionalPositionalUnevaluated("code")
                                                                            .Arguments,
                                                                            (method, context, message, on, outer) => {
                                                                                outer.ArgumentsDefinition.CheckArgumentCount(context, message, on);

                                                                                object onAsMessage = context.runtime.Message.ConvertToThis(on, message, context);

                                                                                switch(message.Arguments.Count) {
                                                                                case 1: {
                                                                                    IokeObject code = IokeObject.As(message.Arguments[0], context);
                                                                                    WalkWithReceiver(context, onAsMessage, code);
                                                                                    break;
                                                                                }
                                                                                case 2: {
                                                                                    LexicalContext c = new LexicalContext(context.runtime, context, "Lexical activation context for Message#walk", message, context);
                                                                                    string name = IokeObject.As(message.Arguments[0], context).Name;
                                                                                    IokeObject code = IokeObject.As(message.Arguments[1], context);

                                                                                    WalkWithoutExplicitReceiver(onAsMessage, c, name, code);
                                                                                    break;
                                                                                }
                                                                                }
                                                                                return onAsMessage;

                                                                            })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("takes either one or two or three arguments. if one argument is given, it should be a message chain that will be sent to each message in the chain. the result will be thrown away. if two arguments are given, the first is an unevaluated name that will be set to each of the messages in the chain in succession, and then the second argument will be evaluated in a scope with that argument in it. if three arguments is given, the first one is an unevaluated name that will be set to the index of each message, and the other two arguments are the name of the argument for the value, and the actual code. the code will evaluate in a lexical context, and if the argument name is available outside the context, it will be shadowed. the method will return the original message.", 
                                                           new NativeMethod("each",  DefaultArgumentsDefinition.builder()
                                                                            .WithRequiredPositionalUnevaluated("indexOrArgOrCode")
                                                                            .WithOptionalPositionalUnevaluated("argOrCode")
                                                                            .WithOptionalPositionalUnevaluated("code")
                                                                            .Arguments,
                                                                            (method, context, message, on, outer) => {
                                                                                outer.ArgumentsDefinition.CheckArgumentCount(context, message, on);

                                                                                object onAsMessage = context.runtime.Message.ConvertToThis(on, message, context);
                    
                                                                                Runtime runtime = context.runtime;
                                                                                switch(message.Arguments.Count) {
                                                                                case 1: {
                                                                                    IokeObject code = IokeObject.As(message.Arguments[0], context);
                                                                                    object o = onAsMessage;
                                                                                    while(o != null) {
                                                                                        ((Message)IokeObject.dataOf(code)).EvaluateCompleteWithReceiver(code, context, context.RealContext, o);
                                                                                        o = GetNext(o);
                                                                                    }

                                                                                    break;
                                                                                }
                                                                                case 2: {
                                                                                    LexicalContext c = new LexicalContext(context.runtime, context, "Lexical activation context for List#each", message, context);
                                                                                    string name = IokeObject.As(message.Arguments[0], context).Name;
                                                                                    IokeObject code = IokeObject.As(message.Arguments[1], context);

                                                                                    object o = onAsMessage;
                                                                                    while(o != null) {
                                                                                        c.SetCell(name, o);
                                                                                        ((Message)IokeObject.dataOf(code)).EvaluateCompleteWithoutExplicitReceiver(code, c, c.RealContext);
                                                                                        o = GetNext(o);
                                                                                    }
                                                                                    break;
                                                                                }
                                                                                case 3: {
                                                                                    LexicalContext c = new LexicalContext(context.runtime, context, "Lexical activation context for List#each", message, context);
                                                                                    string iname = IokeObject.As(message.Arguments[0], context).Name;
                                                                                    string name = IokeObject.As(message.Arguments[1], context).Name;
                                                                                    IokeObject code = IokeObject.As(message.Arguments[2], context);

                                                                                    int index = 0;
                                                                                    object o = onAsMessage;
                                                                                    while(o != null) {
                                                                                        c.SetCell(name, o);
                                                                                        c.SetCell(iname, runtime.NewNumber(index++));
                                                                                        ((Message)IokeObject.dataOf(code)).EvaluateCompleteWithoutExplicitReceiver(code, c, c.RealContext);
                                                                                        o = GetNext(o);
                                                                                    }
                                                                                    break;
                                                                                }
                                                                                }
                                                                                return onAsMessage;
                                                                            })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("Takes one evaluated argument and sends this message to that argument", 
                                                           new NativeMethod("sendTo", DefaultArgumentsDefinition.builder()
                                                                            .WithRequiredPositional("newReceiver")
                                                                            .WithOptionalPositional("context", "nil")
                                                                            .Arguments,
                                                                            (method, on, args, keywords, context, message) => {
                                                                                IokeObject realReceiver = IokeObject.As(args[0], context);
                                                                                IokeObject realContext = realReceiver;
                                                                                if(args.Count > 1) {
                                                                                    realContext = IokeObject.As(args[1], context);
                                                                                }

                                                                                IokeObject msg = IokeObject.As(on, context);
                                                                                return ((Message)IokeObject.dataOf(msg)).SendTo(msg, realContext, realReceiver);
                                                                            })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("sets the arguments for this message. if given nil the arguments list will be creared, otherwise the list given as arguments will be used. it then returns the receiving message.", 
                                                           new TypeCheckingNativeMethod("arguments=", TypeCheckingArgumentsDefinition.builder()
                                                                                        .ReceiverMustMimic(obj)
                                                                                        .WithRequiredPositional("newArguments")
                                                                                        .Arguments,
                                                                                        (method, on, args, keywords, context, message) => {
                                                                                            object arg = args[0];
                                                                                            IokeObject.As(on, method).Arguments.Clear();
                                                                                            if(arg == context.runtime.nil) {
                                                                                                // no arguments for this message
                                                                                            } else if (IokeObject.dataOf(arg) is IokeList) {
                                                                                                var elements = IokeList.GetList(arg);
                                                                                                var arg1 = IokeObject.As(on, method).Arguments;
                                                                                                foreach(object o in elements) arg1.Add(o);
                                                                                            } else {
                                                                                                IokeObject.As(on, method).Arguments.Insert(0, arg);
                                                                                            }
                                                                                            return on;
                                                                                        })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("Takes one evaluated argument and returns the message resulting from parsing and operator shuffling the resulting message.", 
                                                           new TypeCheckingNativeMethod("fromText", TypeCheckingArgumentsDefinition.builder()
                                                                                        .WithRequiredPositional("code").WhichMustMimic(obj.runtime.Text)
                                                                                        .Arguments,
                                                                                        (method, on, args, keywords, context, message) => {
                                                                                            string code = Text.GetText(args[0]);
                                                                                            return Message.NewFromStream(context.runtime, new StringReader(code), message, context);
                                                                                        })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("Takes one evaluated argument and executes the contents of that text in the current context and returns the result of that.", 
                                                           new TypeCheckingNativeMethod("doText", TypeCheckingArgumentsDefinition.builder()
                                                                                        .WithRequiredPositional("code").WhichMustMimic(obj.runtime.Text)
                                                                                        .Arguments,
                                                                                        (method, on, args, keywords, context, message) => {
                                                                                            string code = Text.GetText(args[0]);
                                                                                            return context.runtime.EvaluateString(code, message, context);
                                                                                        })));
        }

        public static string GetStackTraceText(object _message) {
            IokeObject message = IokeObject.As(_message, null);
            IokeObject start = message;
        
            while(GetPrev(start) != null && GetPrev(start).Line == message.Line) {
                start = GetPrev(start);
            }

            string s1 = Code(start);

            int ix = s1.IndexOf("\n");
            if(ix > -1) {
                ix--;
            }
        
            return string.Format(" {0,-48} {1}", 
                                 (ix == -1 ? s1 : s1.Substring(0,ix)),
                                 "[" + message.File + ":" + message.Line + ":" + message.Position + "]");
        }
        
        private static void WalkWithoutExplicitReceiver(object onAsMessage, LexicalContext c, string name, IokeObject code) {
            object o = onAsMessage;
            while(o != null) {
                c.SetCell(name, o);
                ((Message)IokeObject.dataOf(code)).EvaluateCompleteWithoutExplicitReceiver(code, c, c.RealContext);
                foreach(object arg in ((IokeObject)o).Arguments) {
                    WalkWithoutExplicitReceiver(arg, c, name, code);
                }
                o = GetNext(o);
            }
        }
        
        private static void WalkWithReceiver(IokeObject context, object onAsMessage, IokeObject code) {
            object o = onAsMessage;
            while(o != null) {
                ((Message)IokeObject.dataOf(code)).EvaluateCompleteWithReceiver(code, context, context.RealContext, o);
                foreach(object arg in ((IokeObject)o).Arguments) {
                    WalkWithReceiver(context, arg, code);
                }
                o = GetNext(o);
            }
        }
    }
}
