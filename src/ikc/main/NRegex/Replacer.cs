
namespace NRegex {
    using System;
    using System.IO;
    using System.Text;

    public class Replacer {
        private Pattern pattern;
        private Substitution substitution;
   
        public Replacer(Pattern pattern, Substitution substitution) {
            this.pattern=pattern;
            this.substitution=substitution;
        }
   
        public Replacer(Pattern pattern, string substitution) : this(pattern,substitution,true) {}
   
        public Replacer(Pattern pattern, string substitution, bool isPerlExpr) {
            this.pattern =pattern;
            this.substitution = isPerlExpr ? (Substitution)new PerlSubstitution(substitution) : new DummySubstitution(substitution);
        }
   
        public void setSubstitution(string s, bool isPerlExpr) {
            substitution= isPerlExpr? (Substitution)new PerlSubstitution(s): 
                new DummySubstitution(s);
        }
   
        public string Replace(string text) {
            TextBuffer tb=Wrap(new StringBuilder(text.Length));
            Replace(pattern.Matcher(text),substitution,tb);
            return tb.ToString();
        }

        public string ReplaceFirst(string text) {
            TextBuffer tb=Wrap(new StringBuilder(text.Length));
            ReplaceFirst(pattern.Matcher(text),substitution,tb);
            return tb.ToString();
        }
   
        public string Replace(char[] chars,int off,int len) {
            TextBuffer tb=Wrap(new StringBuilder(len));
            Replace(pattern.Matcher(chars,off,len),substitution,tb);
            return tb.ToString();
        }

        public string ReplaceFirst(char[] chars,int off,int len) {
            TextBuffer tb=Wrap(new StringBuilder(len));
            ReplaceFirst(pattern.Matcher(chars,off,len),substitution,tb);
            return tb.ToString();
        }
   
        public string Replace(MatchResult res,int group) {
            TextBuffer tb=Wrap(new StringBuilder());
            Replace(pattern.Matcher(res,group),substitution,tb);
            return tb.ToString();
        }

        public string ReplaceFirst(MatchResult res,int group) {
            TextBuffer tb=Wrap(new StringBuilder());
            ReplaceFirst(pattern.Matcher(res,group),substitution,tb);
            return tb.ToString();
        }
   
        public string Replace(TextReader text,int length) {
            TextBuffer tb=Wrap(new StringBuilder(length>=0? length: 0));
            Replace(pattern.Matcher(text,length),substitution,tb);
            return tb.ToString();
        }

        public string ReplaceFirst(TextReader text,int length) {
            TextBuffer tb=Wrap(new StringBuilder(length>=0? length: 0));
            ReplaceFirst(pattern.Matcher(text,length),substitution,tb);
            return tb.ToString();
        }
   
        public int Replace(string text,StringBuilder sb) {
            return Replace(pattern.Matcher(text),substitution,Wrap(sb));
        }

        public int ReplaceFirst(string text,StringBuilder sb) {
            return ReplaceFirst(pattern.Matcher(text),substitution,Wrap(sb));
        }
   
        public int Replace(char[] chars,int off,int len,StringBuilder sb) {
            return Replace(chars,off,len,Wrap(sb));
        }

        public int ReplaceFirst(char[] chars,int off,int len,StringBuilder sb) {
            return ReplaceFirst(chars,off,len,Wrap(sb));
        }
   
        public int Replace(MatchResult res,int group,StringBuilder sb) {
            return Replace(res,group,Wrap(sb));
        }

        public int ReplaceFirst(MatchResult res,int group,StringBuilder sb) {
            return ReplaceFirst(res,group,Wrap(sb));
        }
   
        public int Replace(MatchResult res,string groupName,StringBuilder sb) {
            return Replace(res,groupName,Wrap(sb));
        }

        public int ReplaceFirst(MatchResult res,string groupName,StringBuilder sb) {
            return ReplaceFirst(res,groupName,Wrap(sb));
        }
   
        public int Replace(TextReader text,int length,StringBuilder sb) {
            return Replace(text,length,Wrap(sb));
        }

        public int ReplaceFirst(TextReader text,int length,StringBuilder sb) {
            return ReplaceFirst(text,length,Wrap(sb));
        }
   
        public int Replace(string text,TextBuffer dest) {
            return Replace(pattern.Matcher(text),substitution,dest);
        }

        public int ReplaceFirst(string text,TextBuffer dest) {
            return ReplaceFirst(pattern.Matcher(text),substitution,dest);
        }
   
        public int Replace(char[] chars,int off,int len,TextBuffer dest) {
            return Replace(pattern.Matcher(chars,off,len),substitution,dest);
        }

        public int ReplaceFirst(char[] chars,int off,int len,TextBuffer dest) {
            return ReplaceFirst(pattern.Matcher(chars,off,len),substitution,dest);
        }
   
        public int Replace(MatchResult res,int group,TextBuffer dest) {
            return Replace(pattern.Matcher(res,group),substitution,dest);
        }
   
        public int ReplaceFirst(MatchResult res,int group,TextBuffer dest) {
            return ReplaceFirst(pattern.Matcher(res,group),substitution,dest);
        }

        public int Replace(MatchResult res,string groupName,TextBuffer dest) {
            return Replace(pattern.Matcher(res,groupName),substitution,dest);
        }

        public int ReplaceFirst(MatchResult res,string groupName,TextBuffer dest) {
            return ReplaceFirst(pattern.Matcher(res,groupName),substitution,dest);
        }
   
        public int Replace(TextReader text,int length,TextBuffer dest) {
            return Replace(pattern.Matcher(text,length),substitution,dest);
        }

        public int ReplaceFirst(TextReader text,int length,TextBuffer dest) {
            return ReplaceFirst(pattern.Matcher(text,length),substitution,dest);
        }
   
        public static int Replace(Matcher m,Substitution substitution,TextBuffer dest) {
            bool firstPass=true;
            int c=0;
            while(m.Find()) {
                if(m.End==0 && !firstPass) continue;  //allow to Replace at "^"
                if(m.Start>0) m.Group(Matcher.PREFIX,dest);
                substitution.AppendSubstitution(m,dest);
                c++;
                m.SetTarget(m,Matcher.SUFFIX);
                firstPass=false;
            }
            m.Group(Matcher.TARGET,dest);
            return c;
        }

        public static int ReplaceFirst(Matcher m,Substitution substitution,TextBuffer dest) {
            int c=0;
            if(m.Find()) {
                if(m.Start>0) m.Group(Matcher.PREFIX,dest);
                substitution.AppendSubstitution(m,dest);
                c++;
                m.SetTarget(m,Matcher.SUFFIX);
            }
            m.Group(Matcher.TARGET,dest);
            return c;
        }
   
        public static int Replace(Matcher m,Substitution substitution,TextWriter _out) {
            try {
                return Replace(m,substitution,Wrap(_out));
            } catch(WriteException e) {
                throw e.reason;
            }
        }

        public static int ReplaceFirst(Matcher m,Substitution substitution,TextWriter _out) {
            try {
                return ReplaceFirst(m,substitution,Wrap(_out));
            } catch(WriteException e) {
                throw e.reason;
            }
        }
   
        public void Replace(string text, TextWriter _out) {
            Replace(pattern.Matcher(text),substitution,_out);
        }

        public void ReplaceFirst(string text, TextWriter _out) {
            ReplaceFirst(pattern.Matcher(text),substitution,_out);
        }

        public void Replace(char[] chars,int off,int len, TextWriter _out) {
            Replace(pattern.Matcher(chars,off,len),substitution,_out);
        }
   
        public void ReplaceFirst(char[] chars,int off,int len, TextWriter _out) {
            ReplaceFirst(pattern.Matcher(chars,off,len),substitution,_out);
        }

        public void Replace(MatchResult res,int group, TextWriter _out) {
            Replace(pattern.Matcher(res,group),substitution,_out);
        }
   
        public void ReplaceFirst(MatchResult res,int group, TextWriter _out) {
            ReplaceFirst(pattern.Matcher(res,group),substitution,_out);
        }

        public void Replace(MatchResult res,string groupName, TextWriter _out) {
            Replace(pattern.Matcher(res,groupName),substitution,_out);
        }
   
        public void ReplaceFirst(MatchResult res,string groupName, TextWriter _out) {
            ReplaceFirst(pattern.Matcher(res,groupName),substitution,_out);
        }

        public void Replace(TextReader _in, int length, TextWriter _out) {
            Replace(pattern.Matcher(_in,length),substitution,_out);
        }
   
        public void ReplaceFirst(TextReader _in,int length,TextWriter _out) {
            ReplaceFirst(pattern.Matcher(_in,length),substitution,_out);
        }
   
        private class DummySubstitution : Substitution {
            internal string str;
            internal DummySubstitution(string s) {
                str = s;
            }

            public void AppendSubstitution(MatchResult match, TextBuffer res) {
                if(str!=null) res.Append(str);
            }
        }
   
        private class StringBuilderTextBuffer : TextBuffer {
            StringBuilder sb;
            public StringBuilderTextBuffer(StringBuilder sb) {
                this.sb = sb;
            }
            public void Append(char c) {
                sb.Append(c);
            }
            public void Append(char[] chars,int start,int len) {
                sb.Append(chars,start,len);
            }
            public void Append(string s) {
                sb.Append(s);
            }
            public override string ToString() {
                return sb.ToString();
            }
        }

        public static TextBuffer Wrap(StringBuilder sb) {
            return new StringBuilderTextBuffer(sb);
        }

        private class TextWriterTextBuffer : TextBuffer {
            TextWriter writer;
            public TextWriterTextBuffer(TextWriter writer) {
                this.writer = writer;
            }

            public void Append(char c) {
                try {
                    writer.Write(c);
                } catch(IOException e) {
                    throw new WriteException(e);
                }
            }
            public void Append(char[] chars,int off,int len) {
                try {
                    writer.Write(chars,off,len);
                } catch(IOException e) {
                    throw new WriteException(e);
                }
            }
            public void Append(string s) {
                try {
                    writer.Write(s);
                } catch(IOException e) {
                    throw new WriteException(e);
                }
            }
        }   

        public static TextBuffer Wrap(TextWriter writer) {
            return new TextWriterTextBuffer(writer);
        }
   
        private class WriteException : System.ApplicationException {
            internal IOException reason;
            internal WriteException(IOException io) {
                reason = io;
            }
        }
    }
}
