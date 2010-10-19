
namespace Ioke.Lang.Parser
{
    using System.IO;
    using System.Collections;
    using System.Collections.Generic;
    using System.Text;

    using Ioke.Lang;
    using Ioke.Lang.Util;

    public class IokeParser
    {
        internal readonly Runtime runtime;
        internal readonly TextReader reader;

        internal readonly IokeObject context;
        internal readonly IokeObject message;

        internal ChainContext top = new ChainContext(null);

        internal readonly Dictionary<string, Operators.OpEntry> operatorTable = new SaneDictionary<string, Operators.OpEntry>();
        internal readonly Dictionary<string, Operators.OpArity> trinaryOperatorTable = new SaneDictionary<string, Operators.OpArity>();
        internal readonly Dictionary<string, Operators.OpEntry> invertedOperatorTable = new SaneDictionary<string, Operators.OpEntry>();
        internal readonly ICollection<string> unaryOperators = Operators.DEFAULT_UNARY_OPERATORS;
        internal readonly ICollection<string> onlyUnaryOperators = Operators.DEFAULT_ONLY_UNARY_OPERATORS;

        public IokeParser(Runtime runtime, TextReader reader, IokeObject context, IokeObject message) {
            this.runtime = runtime;
            this.reader = reader;
            this.context = context;
            this.message = message;

            Operators.CreateOrGetOpTables(this);
        }


        public IokeObject ParseFully() {
            IokeObject result = ParseMessageChain();
            return result;
        }

        private IokeObject ParseMessageChain() {
            top = new ChainContext(top);
            while(ParseMessage());
            top.PopOperatorsTo(999999);
            IokeObject ret = top.Pop();
            top = top.parent;
            return ret;
        }

        private IList ParseCommaSeparatedMessageChains() {
            ArrayList chain = new SaneArrayList();

            IokeObject curr = ParseMessageChain();
            while(curr != null) {
                chain.Add(curr);
                ReadWhiteSpace();
                int rr = Peek();
                if(rr == ',') {
                    Read();
                    curr = ParseMessageChain();
                    if(curr == null) {
                        Fail("Expected expression following comma");
                    }
                } else {
                    if(curr != null && Message.IsTerminator(curr) && Message.GetNext(curr) == null) {
                        chain.RemoveAt(chain.Count-1);
                    }
                    curr = null;
                }
            }

            return chain;
        }

        private int lineNumber = 1;
        private int currentCharacter = -1;
        private bool skipLF = false;

        private int saved2 = -2;
        private int saved = -2;

        private int Read() {
            if(saved > -2) {
                int x = saved;
                saved = saved2;
                saved2 = -2;

                if(skipLF) {
                    skipLF = false;
                    if(x == '\n') {
                        return x;
                    }
                }

                currentCharacter++;

                switch(x) {
                case '\r':
                    skipLF = true;
                    goto case '\n';
                case '\n':		/* Fall through */
                    lineNumber++;
                    currentCharacter = 0;
                    break;
                }

                return x;
            }

            int xx = reader.Read();

            if(skipLF) {
                skipLF = false;
                if(xx == '\n') {
                    return xx;
                }
            }

            currentCharacter++;

            switch(xx) {
            case '\r':
                skipLF = true;
                goto case '\n';
            case '\n':		/* Fall through */
                lineNumber++;
                currentCharacter = 0;
                break;
            }

            return xx;
        }

        private int Peek() {
            if(saved == -2) {
                if(saved2 != -2) {
                    saved = saved2;
                    saved2 = -2;
                } else {
                    saved = reader.Read();
                }
            }
            return saved;
        }

        private int Peek2() {
            if(saved == -2) {
                saved = reader.Read();
            }
            if(saved2 == -2) {
                saved2 = reader.Read();
            }
            return saved2;
        }

        private bool ParseMessage() {
            int rr;
            while(true) {
                rr = Peek();
                switch(rr) {
                case -1:
                    Read();
                    return false;
                case ',':
                    goto case '}';
                case ')':
                    goto case '}';
                case ']':
                    goto case '}';
                case '}':
                    return false;
                case '(':
                    Read();
                    ParseEmptyMessageSend();
                    return true;
                case '[':
                    Read();
                    ParseOpenCloseMessageSend(']', "[]");
                    return true;
                case '{':
                    Read();
                    ParseOpenCloseMessageSend('}', "{}");
                    return true;
                case '#':
                    Read();
                    switch(Peek()) {
                    case '{':
                        ParseSimpleOpenCloseMessageSend('}', "set");
                        return true;
                    case '/':
                        ParseRegexpLiteral('/');
                        return true;
                    case '[':
                        ParseText('[');
                        return true;
                    case 'r':
                        ParseRegexpLiteral('r');
                        return true;
                    case '!':
                        ParseComment();
                        break;
                    default:
                        ParseOperatorChars('#');
                        return true;
                    }
                    break;
                case '"':
                    Read();
                    ParseText('"');
                    return true;
                case '0':
                    goto case '9';
                case '1':
                    goto case '9';
                case '2':
                    goto case '9';
                case '3':
                    goto case '9';
                case '4':
                    goto case '9';
                case '5':
                    goto case '9';
                case '6':
                    goto case '9';
                case '7':
                    goto case '9';
                case '8':
                    goto case '9';
                case '9':
                    Read();
                    ParseNumber(rr);
                    return true;
                case '.':
                    Read();
                    if((rr = Peek()) == '.') {
                        ParseRange();
                    } else {
                        ParseTerminator('.');
                    }
                    return true;
                case ';':
                    Read();
                    ParseComment();
                    break;
                case ' ':
                    goto case '\u000c';
                case '\u0009':
                    goto case '\u000c';
                case '\u000b':
                    goto case '\u000c';
                case '\u000c':
                    Read();
                    ReadWhiteSpace();
                    break;
                case '\\':
                    Read();
                    if((rr = Peek()) == '\n') {
                        Read();
                        break;
                    } else {
                        Fail("Expected newline after free-floating escape character");
                        break;
                    }
                case '\r':
                    goto case '\n';
                case '\n':
                    Read();
                    ParseTerminator(rr);
                    return true;
                case '+':
                    goto case '/';
                case '-':
                    goto case '/';
                case '*':
                    goto case '/';
                case '%':
                    goto case '/';
                case '<':
                    goto case '/';
                case '>':
                    goto case '/';
                case '!':
                    goto case '/';
                case '?':
                    goto case '/';
                case '~':
                    goto case '/';
                case '&':
                    goto case '/';
                case '|':
                    goto case '/';
                case '^':
                    goto case '/';
                case '$':
                    goto case '/';
                case '=':
                    goto case '/';
                case '@':
                    goto case '/';
                case '\'':
                    goto case '/';
                case '`':
                    goto case '/';
                case '/':
                    Read();
                    ParseOperatorChars(rr);
                    return true;
                case ':':
                    Read();
                    if(IsLetter(rr = Peek()) || IsIDDigit(rr)) {
                        ParseRegularMessageSend(':');
                    } else {
                        ParseOperatorChars(':');
                    }
                    return true;
                default:
                    Read();
                    ParseRegularMessageSend(rr);
                    return true;
                }
            }
        }
        
        private void Fail(int l, int c, string message, string expected, string got) {
            string file = ((IokeSystem)IokeObject.dataOf(runtime.System)).CurrentFile;

            IokeObject condition = IokeObject.As(IokeObject.GetCellChain(runtime.Condition,
                                                                         this.message,
                                                                         this.context,
                                                                         "Error",
                                                                         "Parser",
                                                                         "Syntax"), this.context).Mimic(this.message, this.context);
            condition.SetCell("message", this.message);
            condition.SetCell("context", this.context);
            condition.SetCell("receiver", this.context);

            if(expected != null) {
                condition.SetCell("expected", runtime.NewText(expected));
            }

            if(got != null) {
                condition.SetCell("got", runtime.NewText(got));
            }

            condition.SetCell("file", runtime.NewText(file));
            condition.SetCell("line", runtime.NewNumber(l));
            condition.SetCell("character", runtime.NewNumber(c));
            condition.SetCell("text", runtime.NewText(file + ":" + l + ":" + c + ": " + message));
            runtime.ErrorCondition(condition);
        }

        private void Fail(string message) {
            Fail(lineNumber, currentCharacter, message, null, null);
        }

        private void ParseCharacter(int c) {
            int l = lineNumber;
            int cc = currentCharacter;

            ReadWhiteSpace();
            int rr = Read();
            if(rr != c) {
                Fail(l, cc, "Expected: '" + (char)c + "' got: " + CharDesc(rr), "" + (char)c, CharDesc(rr));
            }
        }

        private bool IsUnary(string name) {
            return unaryOperators.Contains(name) && (top.head == null || Message.IsTerminator(top.last));
        }

        private static int PossibleOperatorPrecedence(string name) {
            if(name.Length > 0) {
                switch(name[0]) {
                case '|':
                    return 9;
                case '^':
                    return 8;
                case '&':
                    return 7;
                case '<':
                    return 5;
                case '>':
                    return 5;
                case '=':
                    return 6;
                case '!':
                    return 6;
                case '?':
                    return 6;
                case '~':
                    return 6;
                case '$':
                    return 6;
                case '+':
                    return 3;
                case '-':
                    return 3;
                case '*':
                    return 2;
                case '/':
                    return 2;
                case '%':
                    return 2;
                }
            }
            return -1;
        }

        private void PossibleOperator(IokeObject mx) {
            string name = Message.GetName(mx);

            if(IsUnary(name) || onlyUnaryOperators.Contains(name)) {
                top.Add(mx);
                top.Push(-1, mx, Level.Type.UNARY);
                return;
            }

            if(operatorTable.ContainsKey(name)) {
                var op = operatorTable[name];
                top.PopOperatorsTo(op.precedence);
                top.Add(mx);
                top.Push(op.precedence, mx, Level.Type.REGULAR);
            } else {
                if(trinaryOperatorTable.ContainsKey(name)) {
                    var opa = trinaryOperatorTable[name];
                    if(opa.arity == 2) {
                        IokeObject last = top.PrepareAssignmentMessage();
                        mx.Arguments.Add(last);
                        top.Add(mx);
                        top.Push(13, mx, Level.Type.ASSIGNMENT);
                    } else {
                        IokeObject last = top.PrepareAssignmentMessage();
                        mx.Arguments.Add(last);
                        top.Add(mx);
                    }
                } else {
                    if(invertedOperatorTable.ContainsKey(name)) {
                        var op = invertedOperatorTable[name];
                        top.PopOperatorsTo(op.precedence);
                        top.Add(mx);
                        top.Push(op.precedence, mx, Level.Type.INVERTED);
                    } else {
                        int possible = PossibleOperatorPrecedence(name);
                        if(possible != -1) {
                            top.PopOperatorsTo(possible);
                            top.Add(mx);
                            top.Push(possible, mx, Level.Type.REGULAR);
                        } else {
                            top.Add(mx);
                        }
                    }
                }
            }
        }

        private void ParseEmptyMessageSend() {
            int l = lineNumber; int cc = currentCharacter-1;
            IList args = ParseCommaSeparatedMessageChains();
            ParseCharacter(')');

            Message m = new Message(runtime, "");
            m.Line = l;
            m.Position = cc;

            IokeObject mx = runtime.CreateMessage(m);
            Message.SetArguments(mx, args);
            top.Add(mx);
        }

        private void ParseOpenCloseMessageSend(char end, string name) {
            int l = lineNumber; int cc = currentCharacter-1;

            int rr = Peek();
            int r2 = Peek2();

            Message m = new Message(runtime, name);
            m.Line = l;
            m.Position = cc;

            IokeObject mx = runtime.CreateMessage(m);
            if(rr == end && r2 == '(') {
                Read();
                Read();
                IList args = ParseCommaSeparatedMessageChains();
                ParseCharacter(')');
                Message.SetArguments(mx, args);
            } else {
                IList args = ParseCommaSeparatedMessageChains();
                ParseCharacter(end);
                Message.SetArguments(mx, args);
            }

            top.Add(mx);
        }

        private void ParseSimpleOpenCloseMessageSend(char end, string name) {
            int l = lineNumber; int cc = currentCharacter-1;

            Read();
            IList args = ParseCommaSeparatedMessageChains();
            ParseCharacter(end);

            Message m = new Message(runtime, name);
            m.Line = l;
            m.Position = cc;

            IokeObject mx = runtime.CreateMessage(m);
            Message.SetArguments(mx, args);

            top.Add(mx);
        }

        private void ParseComment() {
            int rr;
            while((rr = Peek()) != '\n' && rr != '\r' && rr != -1) {
                Read();
            }
        }

        private readonly static string[] RANGES = {
            "",
            ".",
            "..",
            "...",
            "....",
            ".....",
            "......",
            ".......",
            "........",
            ".........",
            "..........",
            "...........",
            "............"
        };

        private void ParseRange() {
            int l = lineNumber; int cc = currentCharacter-1;

            int count = 2;
            Read();
            int rr;
            while((rr = Peek()) == '.') {
                count++;
                Read();
            }
            string result = null;
            if(count < 13) {
                result = RANGES[count];
            } else {
                StringBuilder sb = new StringBuilder();
                for(int i = 0; i<count; i++) {
                    sb.Append('.');
                }
                result = sb.ToString();
            }

            Message m = new Message(runtime, result);
            m.Line = l;
            m.Position = cc;
            IokeObject mx = runtime.CreateMessage(m);

            if(rr == '(') {
                Read();
                IList args = ParseCommaSeparatedMessageChains();
                ParseCharacter(')');
                Message.SetArguments(mx, args);
                top.Add(mx);
            } else {
                PossibleOperator(mx);
            }
        }

        private void ParseTerminator(int indicator) {
            int l = lineNumber; int cc = currentCharacter-1;

            int rr;
            int rr2;
            if(indicator == '\r') {
                rr = Peek();
                if(rr == '\n') {
                    Read();
                }
            }

            while(true) {
                rr = Peek();
                rr2 = Peek2();
                if((rr == '.' && rr2 != '.') ||
                   (rr == '\n')) {
                    Read();
                } else if(rr == '\r' && rr2 == '\n') {
                    Read(); Read();
                } else {
                    break;
                }
            }
        
            if(!(top.last == null && top.currentLevel.operatorMessage != null)) {
                top.PopOperatorsTo(999999);
            }

            Message m = new Message(runtime, ".", null, true);
            m.Line = l;
            m.Position = cc;
            top.Add(runtime.CreateMessage(m));
        }

        private void ReadWhiteSpace() {
            int rr;
            while((rr = Peek()) == ' ' ||
                  rr == '\u0009' ||
                  rr == '\u000b' ||
                  rr == '\u000c') {
                Read();
            }
        }

        private void ParseRegexpLiteral(int indicator) {
            StringBuilder sb = new StringBuilder();
            bool slash = indicator == '/';

            int l = lineNumber; int cc = currentCharacter-1;

            Read();

            if(!slash) {
                ParseCharacter('[');
            }

            int rr;
            string name = "internal:createRegexp";
            ArrayList args = new SaneArrayList();

            while(true) {
                switch(rr = Peek()) {
                case -1:
                    Fail("Expected end of regular expression, found EOF");
                    break;
                case '/':
                    Read();
                    if(slash) {
                        args.Add(sb.ToString());
                        Message m = new Message(runtime, "internal:createRegexp");
                        m.Line = l;
                        m.Position = cc;
                        IokeObject mm = runtime.CreateMessage(m);
                        if(!name.Equals("internal:createRegexp")) {
                            Message.SetName(mm, name);
                        }
                        Message.SetArguments(mm, args);

                        sb = new StringBuilder();
                        while(true) {
                            switch(rr = Peek()) {
                            case 'x': goto case 's';
                            case 'i': goto case 's';
                            case 'u': goto case 's';
                            case 'm': goto case 's';
                            case 's':
                                Read();
                                sb.Append((char)rr);
                                break;
                            default:
                                args.Add(sb.ToString());
                                top.Add(mm);
                                return;
                            }
                        }
                    } else {
                        sb.Append((char)rr);
                    }
                    break;
                case ']':
                    Read();
                    if(!slash) {
                        args.Add(sb.ToString());
                        Message m = new Message(runtime, "internal:createRegexp");
                        m.Line = l;
                        m.Position = cc;
                        IokeObject mm = runtime.CreateMessage(m);
                        if(!name.Equals("internal:createRegexp")) {
                            Message.SetName(mm, name);
                        }
                        Message.SetArguments(mm, args);
                        sb = new StringBuilder();
                        while(true) {
                            switch(rr = Peek()) {
                            case 'x': goto case 's';
                            case 'i': goto case 's';
                            case 'u': goto case 's';
                            case 'm': goto case 's';
                            case 's':
                                Read();
                                sb.Append((char)rr);
                                break;
                            default:
                                args.Add(sb.ToString());
                                top.Add(mm);
                                return;
                            }
                        }
                    } else {
                        sb.Append((char)rr);
                    }
                    break;
                case '#':
                    Read();
                    if((rr = Peek()) == '{') {
                        Read();
                        args.Add(sb.ToString());
                        sb = new StringBuilder();
                        name = "internal:compositeRegexp";
                        args.Add(ParseMessageChain());
                        ReadWhiteSpace();
                        ParseCharacter('}');
                    } else {
                        sb.Append((char)'#');
                    }
                    break;
                case '\\':
                    Read();
                    ParseRegexpEscape(sb);
                    break;
                default:
                    Read();
                    sb.Append((char)rr);
                    break;
                }
            }
        }

        private void ParseText(int indicator) {
            StringBuilder sb = new StringBuilder();
            bool dquote = indicator == '"';

            int l = lineNumber; int cc = currentCharacter-1;

            if(!dquote) {
                Read();
            }

            int rr;
            string name = "internal:createText";
            ArrayList args = new SaneArrayList();

            while(true) {
                switch(rr = Peek()) {
                case -1:
                    Fail("Expected end of text, found EOF");
                    break;
                case '"':
                    Read();
                    if(dquote) {
                        args.Add(sb.ToString());
                        Message m = new Message(runtime, "internal:createText");
                        m.Line = l;
                        m.Position = cc;
                        IokeObject mm = runtime.CreateMessage(m);
                        if(!name.Equals("internal:createText")) {
                            for(int i = 0; i<args.Count; i++) {
                                object o = args[i];
                                if(o is string) {
                                    Message mx = new Message(runtime, "internal:createText", o);
                                    mx.Line = l;
                                    mx.Position = cc;
                                    IokeObject mmx = runtime.CreateMessage(mx);
                                    args[i] = mmx;
                                }
                            }
                            Message.SetName(mm, name);
                        }
                        Message.SetArguments(mm, args);
                        top.Add(mm);
                        return;
                    } else {
                        sb.Append((char)rr);
                    }
                    break;
                case ']':
                    Read();
                    if(!dquote) {
                        args.Add(sb.ToString());
                        Message m = new Message(runtime, "internal:createText");
                        m.Line = l;
                        m.Position = cc;
                        IokeObject mm = runtime.CreateMessage(m);
                        if(!name.Equals("internal:createText")) {
                            for(int i = 0; i<args.Count; i++) {
                                object o = args[i];
                                if(o is string) {
                                    Message mx = new Message(runtime, "internal:createText", o);
                                    mx.Line = l;
                                    mx.Position = cc;
                                    IokeObject mmx = runtime.CreateMessage(mx);
                                    args[i] = mmx;
                                }
                            }
                            Message.SetName(mm, name);
                        }
                        Message.SetArguments(mm, args);
                        top.Add(mm);
                        return;
                    } else {
                        sb.Append((char)rr);
                    }
                    break;
                case '#':
                    Read();
                    if((rr = Peek()) == '{') {
                        Read();
                        args.Add(sb.ToString());
                        sb = new StringBuilder();
                        name = "internal:concatenateText";
                        args.Add(ParseMessageChain());
                        ReadWhiteSpace();
                        ParseCharacter('}');
                    } else {
                        sb.Append((char)'#');
                    }
                    break;
                case '\\':
                    Read();
                    ParseDoubleQuoteEscape(sb);
                    break;
                default:
                    Read();
                    sb.Append((char)rr);
                    break;
                }
            }
        }

        private void ParseRegexpEscape(StringBuilder sb) {
            sb.Append('\\');
            int rr = Peek();
            switch(rr) {
            case 'u':
                Read();
                sb.Append((char)rr);
                for(int i = 0; i < 4; i++) {
                    rr = Peek();
                    if((rr >= '0' && rr <= '9') ||
                       (rr >= 'a' && rr <= 'f') ||
                       (rr >= 'A' && rr <= 'F')) {
                        Read();
                        sb.Append((char)rr);
                    } else {
                        Fail("Expected four hexadecimal characters in unicode escape - got: " + CharDesc(rr));
                    }
                }
                break;
            case '0': goto case '7';
            case '1': goto case '7';
            case '2': goto case '7';
            case '3': goto case '7';
            case '4': goto case '7';
            case '5': goto case '7';
            case '6': goto case '7';
            case '7':
                Read();
                sb.Append((char)rr);
                if(rr <= '3') {
                    rr = Peek();
                    if(rr >= '0' && rr <= '7') {
                        Read();
                        sb.Append((char)rr);
                        rr = Peek();
                        if(rr >= '0' && rr <= '7') {
                            Read();
                            sb.Append((char)rr);
                        }
                    }
                } else {
                    rr = Peek();
                    if(rr >= '0' && rr <= '7') {
                        Read();
                        sb.Append((char)rr);
                    }
                }
                break;
            case 't': goto case '|';
            case 'n': goto case '|';
            case 'f': goto case '|';
            case 'r': goto case '|';
            case '/': goto case '|';
            case '\\': goto case '|';
            case '\n': goto case '|';
            case '#': goto case '|';
            case 'A': goto case '|';
            case 'd': goto case '|';
            case 'D': goto case '|';
            case 's': goto case '|';
            case 'S': goto case '|';
            case 'w': goto case '|';
            case 'W': goto case '|';
            case 'b': goto case '|';
            case 'B': goto case '|';
            case 'z': goto case '|';
            case 'Z': goto case '|';
            case '<': goto case '|';
            case '>': goto case '|';
            case 'G': goto case '|';
            case 'p': goto case '|';
            case 'P': goto case '|';
            case '{': goto case '|';
            case '}': goto case '|';
            case '[': goto case '|';
            case ']': goto case '|';
            case '*': goto case '|';
            case '(': goto case '|';
            case ')': goto case '|';
            case '$': goto case '|';
            case '^': goto case '|';
            case '+': goto case '|';
            case '?': goto case '|';
            case '.': goto case '|';
            case '|':
                Read();
                sb.Append((char)rr);
                break;
            case '\r':
                Read();
                sb.Append((char)rr);
                if((rr = Peek()) == '\n') {
                    Read();
                    sb.Append((char)rr);
                }
                break;
            default:
                Fail("Undefined regular expression escape character: " + CharDesc(rr));
                break;
            }
        }

        private void ParseDoubleQuoteEscape(StringBuilder sb) {
            sb.Append('\\');
            int rr = Peek();
            switch(rr) {
            case 'u':
                Read();
                sb.Append((char)rr);
                for(int i = 0; i < 4; i++) {
                    rr = Peek();
                    if((rr >= '0' && rr <= '9') ||
                       (rr >= 'a' && rr <= 'f') ||
                       (rr >= 'A' && rr <= 'F')) {
                        Read();
                        sb.Append((char)rr);
                    } else {
                        Fail("Expected four hexadecimal characters in unicode escape - got: " + CharDesc(rr));
                    }
                }
                break;
            case '0': goto case '7';
            case '1': goto case '7';
            case '2': goto case '7';
            case '3': goto case '7';
            case '4': goto case '7';
            case '5': goto case '7';
            case '6': goto case '7';
            case '7':
                Read();
                sb.Append((char)rr);
                if(rr <= '3') {
                    rr = Peek();
                    if(rr >= '0' && rr <= '7') {
                        Read();
                        sb.Append((char)rr);
                        rr = Peek();
                        if(rr >= '0' && rr <= '7') {
                            Read();
                            sb.Append((char)rr);
                        }
                    }
                } else {
                    rr = Peek();
                    if(rr >= '0' && rr <= '7') {
                        Read();
                        sb.Append((char)rr);
                    }
                }
                break;
            case 'b': goto case 'e';
            case 't': goto case 'e';
            case 'n': goto case 'e';
            case 'f': goto case 'e';
            case 'r': goto case 'e';
            case '"': goto case 'e';
            case ']': goto case 'e';
            case '\\': goto case 'e';
            case '\n': goto case 'e';
            case '#': goto case 'e';
            case 'e':
                Read();
                sb.Append((char)rr);
                break;
            case '\r':
                Read();
                sb.Append((char)rr);
                if((rr = Peek()) == '\n') {
                    Read();
                    sb.Append((char)rr);
                }
                break;
            default:
                Fail("Undefined text escape character: " + CharDesc(rr));
                break;
            }
        }

        private void ParseOperatorChars(int indicator) {
            int l = lineNumber; int cc = currentCharacter-1;

            StringBuilder sb = new StringBuilder();
            sb.Append((char)indicator);
            int rr;
            while(true) {
                rr = Peek();
                switch(rr) {
                case '+': goto case '#';
                case '-': goto case '#';
                case '*': goto case '#';
                case '%': goto case '#';
                case '<': goto case '#';
                case '>': goto case '#';
                case '!': goto case '#';
                case '?': goto case '#';
                case '~': goto case '#';
                case '&': goto case '#';
                case '|': goto case '#';
                case '^': goto case '#';
                case '$': goto case '#';
                case '=': goto case '#';
                case '@': goto case '#';
                case '\'': goto case '#';
                case '`': goto case '#';
                case ':': goto case '#';
                case '#':
                    Read();
                    sb.Append((char)rr);
                    break;
                case '/':
                    if(indicator != '#') {
                        Read();
                        sb.Append((char)rr);
                        break;
                    }
                    goto default;
                default:
                    Message m = new Message(runtime, sb.ToString());
                    m.Line = l;
                    m.Position = cc;
                    IokeObject mx = runtime.CreateMessage(m);

                    if(rr == '(') {
                        Read();
                        IList args = ParseCommaSeparatedMessageChains();
                        ParseCharacter(')');
                        Message.SetArguments(mx, args);
                        top.Add(mx);
                    } else {
                        PossibleOperator(mx);
                    }
                    return;
                }
            }
        }

        private void ParseNumber(int indicator) {
            int l = lineNumber; int cc = currentCharacter-1;
            bool dcimal = false;
            StringBuilder sb = new StringBuilder();
            sb.Append((char)indicator);
            int rr = -1;
            if(indicator == '0') {
                rr = Peek();
                if(rr == 'x' || rr == 'X') {
                    Read();
                    sb.Append((char)rr);
                    rr = Peek();
                    if((rr >= '0' && rr <= '9') ||
                       (rr >= 'a' && rr <= 'f') ||
                       (rr >= 'A' && rr <= 'F')) {
                        Read();
                        sb.Append((char)rr);
                        rr = Peek();
                        while((rr >= '0' && rr <= '9') ||
                              (rr >= 'a' && rr <= 'f') ||
                              (rr >= 'A' && rr <= 'F')) {
                            Read();
                            sb.Append((char)rr);
                            rr = Peek();
                        }
                    } else {
                        Fail("Expected at least one hexadecimal characters in hexadcimal number literal - got: " + CharDesc(rr));
                    }
                } else {
                    int r2 = Peek2();
                    if(rr == '.' && (r2 >= '0' && r2 <= '9')) {
                        dcimal = true;
                        sb.Append((char)rr);
                        sb.Append((char)r2);
                        Read(); Read();
                        while((rr = Peek()) >= '0' && rr <= '9') {
                            Read();
                            sb.Append((char)rr);
                        }
                        if(rr == 'e' || rr == 'E') {
                            Read();
                            sb.Append((char)rr);
                            if((rr = Peek()) == '-' || rr == '+') {
                                Read();
                                sb.Append((char)rr);
                                rr = Peek();
                            }

                            if(rr >= '0' && rr <= '9') {
                                Read();
                                sb.Append((char)rr);
                                while((rr = Peek()) >= '0' && rr <= '9') {
                                    Read();
                                    sb.Append((char)rr);
                                }
                            } else {
                                Fail("Expected at least one decimal character following exponent specifier in number literal - got: " + CharDesc(rr));
                            }
                        }
                    }
                }
            } else {
                while((rr = Peek()) >= '0' && rr <= '9') {
                    Read();
                    sb.Append((char)rr);
                }
                int r2 = Peek2();
                if(rr == '.' && r2 >= '0' && r2 <= '9') {
                    dcimal = true;
                    sb.Append((char)rr);
                    sb.Append((char)r2);
                    Read(); Read();

                    while((rr = Peek()) >= '0' && rr <= '9') {
                        Read();
                        sb.Append((char)rr);
                    }
                    if(rr == 'e' || rr == 'E') {
                        Read();
                        sb.Append((char)rr);
                        if((rr = Peek()) == '-' || rr == '+') {
                            Read();
                            sb.Append((char)rr);
                            rr = Peek();
                        }

                        if(rr >= '0' && rr <= '9') {
                            Read();
                            sb.Append((char)rr);
                            while((rr = Peek()) >= '0' && rr <= '9') {
                                Read();
                                sb.Append((char)rr);
                            }
                        } else {
                            Fail("Expected at least one decimal character following exponent specifier in number literal - got: " + CharDesc(rr));
                        }
                    }
                } else if(rr == 'e' || rr == 'E') {
                    dcimal = true;
                    Read();
                    sb.Append((char)rr);
                    if((rr = Peek()) == '-' || rr == '+') {
                        Read();
                        sb.Append((char)rr);
                        rr = Peek();
                    }

                    if(rr >= '0' && rr <= '9') {
                        Read();
                        sb.Append((char)rr);
                        while((rr = Peek()) >= '0' && rr <= '9') {
                            Read();
                            sb.Append((char)rr);
                        }
                    } else {
                        Fail("Expected at least one decimal character following exponent specifier in number literal - got: " + CharDesc(rr));
                    }
                }
            }

            // TODO: add unit specifier here

            Message m = dcimal ? new Message(runtime, "internal:createDecimal", sb.ToString()) : new Message(runtime, "internal:createNumber", sb.ToString());
            m.Line = l;
            m.Position = cc;
            top.Add(runtime.CreateMessage(m));
        }

        private void ParseRegularMessageSend(int indicator) {
            int l = lineNumber; int cc = currentCharacter-1;
            StringBuilder sb = new StringBuilder();
            sb.Append((char)indicator);
            int rr = -1;
            while(IsLetter(rr = Peek()) || IsIDDigit(rr) || rr == ':' || rr == '!' || rr == '?' || rr == '$') {
                Read();
                sb.Append((char)rr);
            }
            Message m = new Message(runtime, sb.ToString());
            m.Line = l;
            m.Position = cc;
            IokeObject mx = runtime.CreateMessage(m);

            if(rr == '(') {
                Read();
                IList args = ParseCommaSeparatedMessageChains();
                ParseCharacter(')');
                Message.SetArguments(mx, args);
                top.Add(mx);
            } else {
                PossibleOperator(mx);
            }
        }

        private bool IsLetter(int c) {
            return ((c>='A' && c<='Z') ||
                    c=='_' ||
                    (c>='a' && c<='z') ||
                    (c>='\u00C0' && c<='\u00D6') ||
                    (c>='\u00D8' && c<='\u00F6') ||
                    (c>='\u00F8' && c<='\u1FFF') ||
                    (c>='\u2200' && c<='\u22FF') ||
                    (c>='\u27C0' && c<='\u27EF') ||
                    (c>='\u2980' && c<='\u2AFF') ||
                    (c>='\u3040' && c<='\u318F') ||
                    (c>='\u3300' && c<='\u337F') ||
                    (c>='\u3400' && c<='\u3D2D') ||
                    (c>='\u4E00' && c<='\u9FFF') ||
                    (c>='\uF900' && c<='\uFAFF'));
        }

        private bool IsIDDigit(int c) {
            return ((c>='0' && c<='9') ||
                    (c>='\u0660' && c<='\u0669') ||
                    (c>='\u06F0' && c<='\u06F9') ||
                    (c>='\u0966' && c<='\u096F') ||
                    (c>='\u09E6' && c<='\u09EF') ||
                    (c>='\u0A66' && c<='\u0A6F') ||
                    (c>='\u0AE6' && c<='\u0AEF') ||
                    (c>='\u0B66' && c<='\u0B6F') ||
                    (c>='\u0BE7' && c<='\u0BEF') ||
                    (c>='\u0C66' && c<='\u0C6F') ||
                    (c>='\u0CE6' && c<='\u0CEF') ||
                    (c>='\u0D66' && c<='\u0D6F') ||
                    (c>='\u0E50' && c<='\u0E59') ||
                    (c>='\u0ED0' && c<='\u0ED9') ||
                    (c>='\u1040' && c<='\u1049'));
        }

        private static string CharDesc(int c) {
            if(c == -1) {
                return "EOF";
            } else if(c == 9) {
                return "TAB";
            } else if(c == 10 || c == 13) {
                return "EOL";
            } else {
                return "'" + (char)c + "'";
            }
        }
    }
}
