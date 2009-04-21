
namespace NRegex {
    using System;
    using System.Collections;
    using System.Collections.Generic;
    using System.IO;

    [Flags]
    public enum REFlags {DEFAULT=0, IGNORE_CASE=1, MULTILINE=2, DOTALL=4, IGNORE_SPACES=8, UNICODE=16, XML_SCHEMA=32};

    /* This is a port of the JRegex library - since Microsoft has decided to not use compatible syntax
     * in their core Regexp support.
     */
    public class Pattern {
        internal string stringRepr;
   
        // tree entry
        internal Term root,root0;
   
        // required number of memory slots
        internal int memregs;
   
        // required number of iteration counters
        internal int counters;
   
        // number of lookahead groups
        internal int lookaheads;
   
        internal IDictionary<string, int> namedGroupMap;
   
        protected Pattern() {}
        public Pattern(string regex) : this(regex, REFlags.DEFAULT) {}

        public ICollection<string> GroupNames {
            get { return namedGroupMap.Keys; }
        }
      
        public Pattern(string regex, string flags) {
            stringRepr=regex;
            Compile(regex, ParseFlags(flags));
        }

        public Pattern(string regex, REFlags flags) {
            Compile(regex,flags);
        }

        protected void Compile(string regex, REFlags flags) {
            stringRepr=regex;
            Term.MakeTree(regex,flags,this);
        }

        public int GroupCount {
            get { return memregs; }
        }
   
        public int GroupId(string name) {
            return namedGroupMap[name];
        }
   
        public bool Matches(string s) {
            return Matcher(s).Matches();
        }
   
        public bool StartsWith(string s) {
            return Matcher(s).MatchesPrefix();
        }
   
        public Matcher Matcher() {
            return new Matcher(this);
        }
   
        public Matcher Matcher(string s) {
            Matcher m = new Matcher(this);
            m.Target = s;
            return m;
        }
      
        public Matcher Matcher(char[] data, int start, int end) {
            Matcher m = new Matcher(this);
            m.SetTarget(data, start, end);
            return m;
        }
      
        public Matcher Matcher(MatchResult res, int groupId) {
            Matcher m = new Matcher(this);
            if(res is Matcher){
                m.SetTarget((Matcher)res, groupId);
            } else{
                m.SetTarget(res.TargetChars, res.GetStart(groupId)+res.TargetStart, res.GetLength(groupId));
            }
            return m;
        }
      
        public Matcher Matcher(MatchResult res, string groupName){
            int id = res.Pattern.GroupId(groupName);
            return Matcher(res, id);
        }
      
        public Matcher Matcher(TextReader text, int length) {
            Matcher m = new Matcher(this);
            m.SetTarget(text, length);
            return m;
        }
   
        public Replacer Replacer(string expr){
            return new Replacer(this, expr);
        }
   
        public Replacer Replacer(Substitution model){
            return new Replacer(this, model);
        }
   
        public RETokenizer Tokenizer(string text){
            return new RETokenizer(this, text);
        }
   
        public RETokenizer Tokenizer(char[] data, int off, int len){
            return new RETokenizer(this, data, off, len);
        }
   
        public RETokenizer Tokenizer(TextReader input, int length) {
            return new RETokenizer(this, input, length);
        }
   
        public override string ToString() {
            return stringRepr;
        }
   
        public string ToString_d() {
            return root.ToStringAll();
        }
   
        internal static REFlags ParseFlags(string flags) {
            bool enable = true;
            int len = flags.Length;
            REFlags result = REFlags.DEFAULT;
            for(int i=0;i<len;i++){
                char c = flags[i];
                switch(c) {
                case '+':
                    enable=true;
                    break;
                case '-':
                    enable=false;
                    break;
                default:
                    REFlags flag=GetFlag(c);
                    if(enable) result |= flag;
                    else result &= (~flag);
                    break;
                }
            }
            return result;
        }
   
        internal static REFlags ParseFlags(char[] data, int start, int len) {
            bool enable = true;
            REFlags result = REFlags.DEFAULT;
            for(int i=0;i<len;i++){
                char c = data[start+i];
                switch(c){
                case '+':
                    enable=true;
                    break;
                case '-':
                    enable=false;
                    break;
                default:
                    REFlags flag = GetFlag(c);
                    if(enable) result|=flag;
                    else result&=(~flag);
                    break;
                }
            }
            return result;
        }
   
        private static REFlags GetFlag(char c) {
            switch(c){
            case 'i':
                return REFlags.IGNORE_CASE;
            case 'm':
                return REFlags.MULTILINE|REFlags.DOTALL;
            case 's':
                return REFlags.DOTALL;
            case 'x':
                return REFlags.IGNORE_SPACES;
            case 'u':
                return REFlags.UNICODE;
                //         case 'X':
                //            return XML_SCHEMA;
            }
            throw new PatternSyntaxException("unknown flag: "+c);
        }

        public static string Quote(string input) {
            int p = 0;
            char[] entries = input.ToCharArray();
            int end = entries.Length;
            bool found = false;

            for(; !found && p < end; p++) {
                char c = entries[p];
                switch (c) {
                case '[': 
                case '{': 
                case '}':
                case '(': 
                case ')': 
                case '|':
                case '*': 
                case '.': 
                case '\\':
                case '?': 
                case '+': 
                case '^': 
                case '$':
                case ' ':
                case '\t': 
                case '\f': 
                case '\n': 
                case '\r':
                    found = true; break;
                }
                if(found) break;
            }

            if(!found) return input;

            System.Text.StringBuilder result = new System.Text.StringBuilder();
            result.Append(entries, 0, p);

            for(; p < end; p++) {
                char c = entries[p];
                switch (c) {
                case '[':
                case '{':
                case '}':
                case '(':
                case ')':
                case '|':
                case '*':
                case '.':
                case '\\':
                case '?':
                case '+':
                case '^':
                case '$':result.Append('\\'); break;
                case ' ': result.Append("\\ "); continue;
                case '\t':result.Append("\\t"); continue;
                case '\n':result.Append("\\n"); continue;
                case '\r':result.Append("\\r"); continue;
                case '\f':result.Append("\\f"); continue;
                }
                result.Append(c);
            }

            return result.ToString();
        }
    }
}
