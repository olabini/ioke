
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
        private readonly TextReader reader;

        internal readonly IokeObject context;
        internal readonly IokeObject message;

        internal readonly Dictionary<string, Operators.OpEntry> operatorTable = new SaneDictionary<string, Operators.OpEntry>();
        internal readonly Dictionary<string, Operators.OpArity> trinaryOperatorTable = new SaneDictionary<string, Operators.OpArity>();
        internal readonly Dictionary<string, Operators.OpEntry> invertedOperatorTable = new SaneDictionary<string, Operators.OpEntry>();

        public IokeParser(Runtime runtime, TextReader reader, IokeObject context, IokeObject message) {
            this.runtime = runtime;
            this.reader = reader;
            this.context = context;
            this.message = message;
        }

        public IokeObject ParseFully() {
            IokeObject result = parseExpressions();
            return result;
        }

        private IokeObject parseExpressions() {
            IokeObject c = null;
            IokeObject last = null;
            IokeObject head = null;

            while((c = parseExpression()) != null) {
                if(head == null) {
                    head = c;
                    last = c;
                } else {
                    Message.SetNext(last, c);
                    Message.SetPrev(c, last);
                    last = c;
                }
            }

            if(head != null) {
                while(Message.IsTerminator(head) && Message.GetNext(head) != null) {
                    head = Message.GetNext(head);
                    Message.SetPrev(head, null);
                }
            }

            return head;
        }

        private IList parseExpressionChain() {
            ArrayList chain = new SaneArrayList();

            IokeObject curr = parseExpressions();
            while(curr != null) {
                chain.Add(curr);
                readWhiteSpace();
                int rr = peek();
                if(rr == ',') {
                    read();
                    curr = parseExpressions();
                    if(curr == null) {
                        fail("Expected expression following comma");
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

        private int read() {
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

        private int peek() {
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

        private int peek2() {
            if(saved == -2) {
                saved = reader.Read();
            }
            if(saved2 == -2) {
                saved2 = reader.Read();
            }
            return saved2;
        }

        private IokeObject parseExpression() {
            int rr;
            while(true) {
                rr = peek();
                switch(rr) {
                case -1:
                    read();
                    return null;
                case ',':
                    goto case '}';
                case ')':
                    goto case '}';
                case ']':
                    goto case '}';
                case '}':
                    return null;
                case '(':
                    read();
                    return parseEmptyMessageSend();
                case '[':
                    read();
                    return parseSquareMessageSend();
                case '{':
                    read();
                    return parseCurlyMessageSend();
                case '#':
                    read();
                    switch(peek()) {
                    case '{':
                        return parseSetMessageSend();
                    case '/':
                        return parseRegexpLiteral('/');
                    case '[':
                        return parseText('[');
                    case 'r':
                        return parseRegexpLiteral('r');
                    case '!':
                        parseComment();
                        break;
                    default:
                        return parseOperatorChars('#');
                    }
                    break;
                case '"':
                    read();
                    return parseText('"');
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
                    read();
                    return parseNumber(rr);
                case '.':
                    read();
                    if((rr = peek()) == '.') {
                        return parseRange();
                    } else {
                        return parseTerminator('.');
                    }
                case ';':
                    read();
                    parseComment();
                    break;
                case ' ':
                    goto case '\u000c';
                case '\u0009':
                    goto case '\u000c';
                case '\u000b':
                    goto case '\u000c';
                case '\u000c':
                    read();
                    readWhiteSpace();
                    break;
                case '\\':
                    read();
                    if((rr = peek()) == '\n') {
                        read();
                        break;
                    } else {
                        fail("Expected newline after free-floating escape character");
                    }
                    break;
                case '\r':
                    goto case '\n';
                case '\n':
                    read();
                    return parseTerminator(rr);
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
                    read();
                    return parseOperatorChars(rr);
                case ':':
                    read();
                    if(isLetter(rr = peek()) || isIDDigit(rr)) {
                        return parseRegularMessageSend(':');
                    } else {
                        return parseOperatorChars(':');
                    }
                default:
                    read();
                    return parseRegularMessageSend(rr);
                }
            }
        }

        private void fail(int l, int c, string message, string expected, string got) {
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

        private void fail(string message) {
            fail(lineNumber, currentCharacter, message, null, null);
        }

        private void parseCharacter(int c) {
            int l = lineNumber;
            int cc = currentCharacter;

            readWhiteSpace();
            int rr = read();
            if(rr != c) {
                fail(l, cc, "Expected: '" + (char)c + "' got: " + charDesc(rr), "" + (char)c, charDesc(rr));
            }
        }

        private IokeObject parseEmptyMessageSend() {
            int l = lineNumber; int cc = currentCharacter-1;
            IList args = parseExpressionChain();
            parseCharacter(')');

            Message m = new Message(runtime, "");
            m.Line = l;
            m.Position = cc;

            IokeObject mx = runtime.CreateMessage(m);
            Message.SetArguments(mx, args);
            return mx;
        }

        private IokeObject parseSquareMessageSend() {
            int l = lineNumber; int cc = currentCharacter-1;

            int rr = peek();
            int r2 = peek2();

            Message m = new Message(runtime, "[]");
            m.Line = l;
            m.Position = cc;

            IokeObject mx = runtime.CreateMessage(m);
            if(rr == ']' && r2 == '(') {
                read();
                read();
                IList args = parseExpressionChain();
                parseCharacter(')');
                Message.SetArguments(mx, args);
            } else {
                IList args = parseExpressionChain();
                parseCharacter(']');
                Message.SetArguments(mx, args);
            }

            return mx;
        }

        private IokeObject parseCurlyMessageSend() {

            int l = lineNumber; int cc = currentCharacter-1;

            int rr = peek();
            int r2 = peek2();

            Message m = new Message(runtime, "{}");
            m.Line = l;
            m.Position = cc;

            IokeObject mx = runtime.CreateMessage(m);
            if(rr == '}' && r2 == '(') {
                read();
                read();
                IList args = parseExpressionChain();
                parseCharacter(')');
                Message.SetArguments(mx, args);
            } else {
                IList args = parseExpressionChain();
                parseCharacter('}');
                Message.SetArguments(mx, args);
            }

            return mx;
        }

        private IokeObject parseSetMessageSend() {
            int l = lineNumber; int cc = currentCharacter-1;

            parseCharacter('{');
            IList args = parseExpressionChain();
            parseCharacter('}');

            Message m = new Message(runtime, "set");
            m.Line = l;
            m.Position = cc;

            IokeObject mx = runtime.CreateMessage(m);
            Message.SetArguments(mx, args);
            return mx;
        }

        private void parseComment() {
            int rr;
            while((rr = peek()) != '\n' && rr != '\r' && rr != -1) {
                read();
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


        private IokeObject parseRange() {
            int l = lineNumber; int cc = currentCharacter-1;

            int count = 2;
            read();
            while(peek() == '.') {
                count++;
                read();
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
            return runtime.CreateMessage(m);
        }

        private IokeObject parseTerminator(int indicator) {
            int l = lineNumber; int cc = currentCharacter-1;

            int rr;
            int rr2;
            if(indicator == '\r') {
                rr = peek();
                if(rr == '\n') {
                    read();
                }
            }

            while(true) {
                rr = peek();
                rr2 = peek2();
                if((rr == '.' && rr2 != '.') ||
                   (rr == '\n')) {
                    read();
                } else if(rr == '\r' && rr2 == '\n') {
                    read(); read();
                } else {
                    break;
                }
            }

            Message m = new Message(runtime, ".", null, true);
            m.Line = l;
            m.Position = cc;
            return runtime.CreateMessage(m);
        }

        private void readWhiteSpace() {
            int rr;
            while((rr = peek()) == ' ' ||
                  rr == '\u0009' ||
                  rr == '\u000b' ||
                  rr == '\u000c') {
                read();
            }
        }

        private IokeObject parseRegexpLiteral(int indicator) {
            StringBuilder sb = new StringBuilder();
            bool slash = indicator == '/';

            int l = lineNumber; int cc = currentCharacter-1;

            read();

            if(!slash) {
                parseCharacter('[');
            }

            int rr;
            string name = "internal:createRegexp";
            ArrayList args = new SaneArrayList();

            while(true) {
                switch(rr = peek()) {
                case -1:
                    fail("Expected end of regular expression, found EOF");
                    break;
                case '/':
                    read();
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
                            switch(rr = peek()) {
                            case 'x':
                            case 'i':
                            case 'u':
                            case 'm':
                            case 's':
                                read();
                            sb.Append((char)rr);
                            break;
                            default:
                                args.Add(sb.ToString());
                                return mm;
                            }
                        }
                    } else {
                        sb.Append((char)rr);
                    }
                    break;
                case ']':
                    read();
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
                            switch(rr = peek()) {
                            case 'x':
                            case 'i':
                            case 'u':
                            case 'm':
                            case 's':
                                read();
                            sb.Append((char)rr);
                            break;
                            default:
                                args.Add(sb.ToString());
                                //System.err.println("-parseRegexpLiteral()");
                                return mm;
                            }
                        }
                    } else {
                        sb.Append((char)rr);
                    }
                    break;
                case '#':
                    read();
                    if((rr = peek()) == '{') {
                        read();
                        args.Add(sb.ToString());
                        sb = new StringBuilder();
                        name = "internal:compositeRegexp";
                        args.Add(parseExpressions());
                        readWhiteSpace();
                        parseCharacter('}');
                    } else {
                        sb.Append((char)'#');
                    }
                    break;
                case '\\':
                    read();
                    parseRegexpEscape(sb);
                    break;
                default:
                    read();
                    sb.Append((char)rr);
                    break;
                }
            }
        }

        private IokeObject parseText(int indicator) {
            StringBuilder sb = new StringBuilder();
            bool dquote = indicator == '"';

            int l = lineNumber; int cc = currentCharacter-1;

            if(!dquote) {
                read();
            }

            int rr;
            string name = "internal:createText";
            ArrayList args = new SaneArrayList();

            while(true) {
                switch(rr = peek()) {
                case -1:
                    fail("Expected end of text, found EOF");
                    break;
                case '"':
                    read();
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
                        return mm;
                    } else {
                        sb.Append((char)rr);
                    }
                    break;
                case ']':
                    read();
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
                        return mm;
                    } else {
                        sb.Append((char)rr);
                    }
                    break;
                case '#':
                    read();
                    if((rr = peek()) == '{') {
                        read();
                        args.Add(sb.ToString());
                        sb = new StringBuilder();
                        name = "internal:concatenateText";
                        args.Add(parseExpressions());
                        readWhiteSpace();
                        parseCharacter('}');
                    } else {
                        sb.Append((char)'#');
                    }
                    break;
                case '\\':
                    read();
                    parseDoubleQuoteEscape(sb);
                    break;
                default:
                    read();
                    sb.Append((char)rr);
                    break;
                }
            }
        }

        private void parseRegexpEscape(StringBuilder sb) {
            sb.Append('\\');
            int rr = peek();
            switch(rr) {
            case 'u':
                read();
                sb.Append((char)rr);
                for(int i = 0; i < 4; i++) {
                    rr = peek();
                    if((rr >= '0' && rr <= '9') ||
                       (rr >= 'a' && rr <= 'f') ||
                       (rr >= 'A' && rr <= 'F')) {
                        read();
                        sb.Append((char)rr);
                    } else {
                        fail("Expected four hexadecimal characters in unicode escape - got: " + charDesc(rr));
                    }
                }
                break;
            case '0':
            case '1':
            case '2':
            case '3':
            case '4':
            case '5':
            case '6':
            case '7':
                read();
            sb.Append((char)rr);
            if(rr <= '3') {
                rr = peek();
                if(rr >= '0' && rr <= '7') {
                    read();
                    sb.Append((char)rr);
                    rr = peek();
                    if(rr >= '0' && rr <= '7') {
                        read();
                        sb.Append((char)rr);
                    }
                }
            } else {
                rr = peek();
                if(rr >= '0' && rr <= '7') {
                    read();
                    sb.Append((char)rr);
                }
            }
            break;
            case 't':
            case 'n':
            case 'f':
            case 'r':
            case '/':
            case '\\':
            case '\n':
            case '#':
            case 'A':
            case 'd':
            case 'D':
            case 's':
            case 'S':
            case 'w':
            case 'W':
            case 'b':
            case 'B':
            case 'z':
            case 'Z':
            case '<':
            case '>':
            case 'G':
            case 'p':
            case 'P':
            case '{':
            case '}':
            case '[':
            case ']':
            case '*':
            case '(':
            case ')':
            case '$':
            case '^':
            case '+':
            case '?':
            case '.':
            case '|':
                read();
            sb.Append((char)rr);
            break;
            case '\r':
                read();
                sb.Append((char)rr);
                if((rr = peek()) == '\n') {
                    read();
                    sb.Append((char)rr);
                }
                break;
            default:
                fail("Undefined regular expression escape character: " + charDesc(rr));
                break;
            }
        }

        private void parseDoubleQuoteEscape(StringBuilder sb) {
            sb.Append('\\');
            int rr = peek();
            switch(rr) {
            case 'u':
                read();
                sb.Append((char)rr);
                for(int i = 0; i < 4; i++) {
                    rr = peek();
                    if((rr >= '0' && rr <= '9') ||
                       (rr >= 'a' && rr <= 'f') ||
                       (rr >= 'A' && rr <= 'F')) {
                        read();
                        sb.Append((char)rr);
                    } else {
                        fail("Expected four hexadecimal characters in unicode escape - got: " + charDesc(rr));
                    }
                }
                break;
            case '0':
            case '1':
            case '2':
            case '3':
            case '4':
            case '5':
            case '6':
            case '7':
                read();
            sb.Append((char)rr);
            if(rr <= '3') {
                rr = peek();
                if(rr >= '0' && rr <= '7') {
                    read();
                    sb.Append((char)rr);
                    rr = peek();
                    if(rr >= '0' && rr <= '7') {
                        read();
                        sb.Append((char)rr);
                    }
                }
            } else {
                rr = peek();
                if(rr >= '0' && rr <= '7') {
                    read();
                    sb.Append((char)rr);
                }
            }
            break;
            case 'b':
            case 't':
            case 'n':
            case 'f':
            case 'r':
            case '"':
            case ']':
            case '\\':
            case '\n':
            case '#':
            case 'e':
                read();
            sb.Append((char)rr);
            break;
            case '\r':
                read();
                sb.Append((char)rr);
                if((rr = peek()) == '\n') {
                    read();
                    sb.Append((char)rr);
                }
                break;
            default:
                fail("Undefined text escape character: " + charDesc(rr));
                break;
            }
        }

        private IokeObject parseOperatorChars(int indicator) {
            int l = lineNumber; int cc = currentCharacter-1;

            StringBuilder sb = new StringBuilder();
            sb.Append((char)indicator);
            int rr;
            if(indicator == '#') {
                while(true) {
                    rr = peek();
                    switch(rr) {
                    case '+':
                    case '-':
                    case '*':
                    case '%':
                    case '<':
                    case '>':
                    case '!':
                    case '?':
                    case '~':
                    case '&':
                    case '|':
                    case '^':
                    case '$':
                    case '=':
                    case '@':
                    case '\'':
                    case '`':
                    case ':':
                    case '#':
                        read();
                    sb.Append((char)rr);
                    break;
                    default:
                        Message m = new Message(runtime, sb.ToString());
                        m.Line = l;
                        m.Position = cc;
                        IokeObject mx = runtime.CreateMessage(m);
                        if(rr == '(') {
                            read();
                            IList args = parseExpressionChain();
                            parseCharacter(')');
                            Message.SetArguments(mx, args);
                        }
                        return mx;
                    }
                }
            } else {
                while(true) {
                    rr = peek();
                    switch(rr) {
                    case '+':
                    case '-':
                    case '*':
                    case '%':
                    case '<':
                    case '>':
                    case '!':
                    case '?':
                    case '~':
                    case '&':
                    case '|':
                    case '^':
                    case '$':
                    case '=':
                    case '@':
                    case '\'':
                    case '`':
                    case '/':
                    case ':':
                    case '#':
                        read();
                    sb.Append((char)rr);
                    break;
                    default:
                        Message m = new Message(runtime, sb.ToString());
                        m.Line = l;
                        m.Position = cc;
                        IokeObject mx = runtime.CreateMessage(m);

                        if(rr == '(') {
                            read();
                            IList args = parseExpressionChain();
                            parseCharacter(')');
                            Message.SetArguments(mx, args);
                        }
                        return mx;
                    }
                }
            }
        }

        private IokeObject parseNumber(int indicator) {
            int l = lineNumber; int cc = currentCharacter-1;
            bool isdecimal = false;
            StringBuilder sb = new StringBuilder();
            sb.Append((char)indicator);
            int rr = -1;
            if(indicator == '0') {
                rr = peek();
                if(rr == 'x' || rr == 'X') {
                    read();
                    sb.Append((char)rr);
                    rr = peek();
                    if((rr >= '0' && rr <= '9') ||
                       (rr >= 'a' && rr <= 'f') ||
                       (rr >= 'A' && rr <= 'F')) {
                        read();
                        sb.Append((char)rr);
                        rr = peek();
                        while((rr >= '0' && rr <= '9') ||
                              (rr >= 'a' && rr <= 'f') ||
                              (rr >= 'A' && rr <= 'F')) {
                            read();
                            sb.Append((char)rr);
                            rr = peek();
                        }
                    } else {
                        fail("Expected at least one hexadecimal characters in hexadecimal number literal - got: " + charDesc(rr));
                    }
                } else {
                    int r2 = peek2();
                    if(rr == '.' && (r2 >= '0' && r2 <= '9')) {
                        isdecimal = true;
                        sb.Append((char)rr);
                        sb.Append((char)r2);
                        read(); read();
                        while((rr = peek()) >= '0' && rr <= '9') {
                            read();
                            sb.Append((char)rr);
                        }
                        if(rr == 'e' || rr == 'E') {
                            read();
                            sb.Append((char)rr);
                            if((rr = peek()) == '-' || rr == '+') {
                                read();
                                sb.Append((char)rr);
                                rr = peek();
                            }

                            if(rr >= '0' && rr <= '9') {
                                read();
                                sb.Append((char)rr);
                                while((rr = peek()) >= '0' && rr <= '9') {
                                    read();
                                    sb.Append((char)rr);
                                }
                            } else {
                                fail("Expected at least one decimal character following exponent specifier in number literal - got: " + charDesc(rr));
                            }
                        }
                    }
                }
            } else {
                while((rr = peek()) >= '0' && rr <= '9') {
                    read();
                    sb.Append((char)rr);
                }
                int r2 = peek2();
                if(rr == '.' && r2 >= '0' && r2 <= '9') {
                    isdecimal = true;
                    sb.Append((char)rr);
                    sb.Append((char)r2);
                    read(); read();

                    while((rr = peek()) >= '0' && rr <= '9') {
                        read();
                        sb.Append((char)rr);
                    }
                    if(rr == 'e' || rr == 'E') {
                        read();
                        sb.Append((char)rr);
                        if((rr = peek()) == '-' || rr == '+') {
                            read();
                            sb.Append((char)rr);
                            rr = peek();
                        }

                        if(rr >= '0' && rr <= '9') {
                            read();
                            sb.Append((char)rr);
                            while((rr = peek()) >= '0' && rr <= '9') {
                                read();
                                sb.Append((char)rr);
                            }
                        } else {
                            fail("Expected at least one decimal character following exponent specifier in number literal - got: " + charDesc(rr));
                        }
                    }
                } else if(rr == 'e' || rr == 'E') {
                    isdecimal = true;
                    read();
                    sb.Append((char)rr);
                    if((rr = peek()) == '-' || rr == '+') {
                        read();
                        sb.Append((char)rr);
                        rr = peek();
                    }

                    if(rr >= '0' && rr <= '9') {
                        read();
                        sb.Append((char)rr);
                        while((rr = peek()) >= '0' && rr <= '9') {
                            read();
                            sb.Append((char)rr);
                        }
                    } else {
                        fail("Expected at least one decimal character following exponent specifier in number literal - got: " + charDesc(rr));
                    }
                }
            }

            // TODO: add unit specifier here

            Message m = isdecimal ? new Message(runtime, "internal:createDecimal", sb.ToString()) : new Message(runtime, "internal:createNumber", sb.ToString());
            m.Line = l;
            m.Position = cc;
            return runtime.CreateMessage(m);
        }

        private IokeObject parseRegularMessageSend(int indicator) {
            int l = lineNumber; int cc = currentCharacter-1;
            StringBuilder sb = new StringBuilder();
            sb.Append((char)indicator);
            int rr = -1;
            while(isLetter(rr = peek()) || isIDDigit(rr) || rr == ':' || rr == '!' || rr == '?' || rr == '$') {
                read();
                sb.Append((char)rr);
            }
            Message m = new Message(runtime, sb.ToString());
            m.Line = l;
            m.Position = cc;
            IokeObject mx = runtime.CreateMessage(m);

            if(rr == '(') {
                read();
                IList args = parseExpressionChain();
                parseCharacter(')');
                Message.SetArguments(mx, args);
            }

            return mx;
        }

        private bool isLetter(int c) {
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

        private bool isIDDigit(int c) {
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

        private static string charDesc(int c) {
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
