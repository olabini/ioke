
namespace NRegex {
    using System;
    using System.Collections.Generic;
    using System.IO;
    using System.Text;

    public class Matcher : MatchResult {
        public const int MATCH=0;
        public const int PREFIX=-1;
        public const int SUFFIX=-2;
        public const int TARGET=-3;

        public const int ANCHOR_START = 1;
        public const int ANCHOR_LASTMATCH = 2;
        public const int ANCHOR_END = 4;
        public const int ACCEPT_INCOMPLETE = 8;
   
        static Term startAnchor = new Term(Term.TermType.START);
        static Term lastMatchAnchor = new Term(Term.TermType.LAST_MATCH_END);
   
        Pattern re;
        int[] counters;
        MemReg[] memregs;
        LAEntry[] lookaheads;
   
        char[] data;
        int offset,end,wOffset,wEnd;
        bool shared;
   
        SearchEntry top;           //stack entry
        SearchEntry first;         //object pool entry
        SearchEntry defaultEntry;  //called when moving the window
   
        bool called;
   
        int minQueueLength;
   
        string cache;
   
        int cacheOffset,cacheLength;   
   
        MemReg prefixBounds,suffixBounds,targetBounds;

        internal Matcher(Pattern regex) {
            this.re=regex;

            int memregCount, counterCount, lookaheadCount;
            if((memregCount=regex.memregs)>0) {
                MemReg[] memregs = new MemReg[memregCount];
                for(int i=0;i<memregCount;i++){
                    memregs[i]=new MemReg(-1); //unlikely to SearchEntry, in this case we know memreg indicies by definition
                }
                this.memregs=memregs;
            }
      
            if((counterCount=regex.counters)>0) counters = new int[counterCount];
      
            if((lookaheadCount=regex.lookaheads)>0) {
                LAEntry[] lookaheads=new LAEntry[lookaheadCount];
                for(int i=0;i<lookaheadCount;i++){
                    lookaheads[i] = new LAEntry();
                }
                this.lookaheads = lookaheads;
            }
      
            first = new SearchEntry();
            defaultEntry = new SearchEntry();
            minQueueLength = regex.stringRepr.Length/2;  // just evaluation!!!
        }


        public void SetTarget(Matcher m, int groupId) {
            MemReg mr=m.Bounds(groupId);
            if(mr==null) throw new ArgumentException("group #"+groupId+" is not assigned");
            data=m.data;
            offset=mr._in;
            end=mr._out;
            cache=m.cache;
            cacheLength=m.cacheLength;
            cacheOffset=m.cacheOffset;
            if(m!=this){
                shared=true;
                m.shared=true;
            }
            Init();
        }
   
        public string Target {
            get { return GetString(offset,end); }
            set { SetTarget(value,0,value.Length); }
        }

        public void SetTarget(string text, int start, int len){
            char[] mychars=data;
            if(mychars==null || shared || mychars.Length<len) {
                data=mychars=new char[(int)(1.7f*len)];
                shared=false;
            }
            text.CopyTo(start, mychars, 0, len);
            offset = 0;
            end = len;
      
            cache = text;
            cacheOffset = -start;
            cacheLength = text.Length;
      
            Init();
        }

        public void SetTarget(char[] text, int start, int len) {
            SetTarget(text,start,len,true);
        }

        public void SetTarget(char[] text, int start, int len, bool shared) {
            cache = null;
            data = text;
            offset = start;
            end = start+len;
            this.shared  =shared;
            Init();
        }
   
        public void SetTarget(TextReader _in, int len) {
            if(len<0){
                SetAll(_in);
                return;
            }
            char[] mychars = data;
            bool shared = this.shared;
            if(mychars==null || shared || mychars.Length<len){
                mychars = new char[len];
                shared = false;
            }
            int count = 0;
            int c;
            while((c=_in.Read(mychars,count,len))>=0){
                len-=c;
                count+=c;
                if(len==0) break;
            }
            SetTarget(mychars,0,count,shared);
        }

        private void SetAll(TextReader _in) {
            char[] mychars=data;
            int free;
            bool shared=this.shared;
            if(mychars==null || shared){
                mychars=new char[free=1024];
                shared=false;
            }
            else free = mychars.Length;
            int count=0;
            int c;
            while((c=_in.Read(mychars, count, free))>=0){
                free-=c;
                count+=c;
                if(free==0){
                    int newsize=count*3;
                    char[] newchars=new char[newsize];
                    Array.Copy(mychars,newchars,count);
                    mychars=newchars;
                    free=newsize-count;
                    shared=false;
                }
            }
            SetTarget(mychars, 0, count, shared);
        }
   
        private string GetString(int start, int end){
            string src=cache;
            if(src!=null){
                int co=cacheOffset;
                return src.Substring(start-co,(end-co)-(start-co));
            }
            int tOffset,tLen=(this.end)-(tOffset=this.offset);
            char[] data = this.data;
            if((end-start)>=(tLen/3)){
                cache=src=new string(data, tOffset, tLen);
                cacheOffset=tOffset;
                cacheLength=tLen;
                return src.Substring(start-tOffset,(end-tOffset)-(start-tOffset));
            }
            return new string(data, start, end-start);
        }
   
        public bool MatchesPrefix() {
            Position = 0;
            return Search(ANCHOR_START|ACCEPT_INCOMPLETE|ANCHOR_END);
        }
   
        public bool IsStart() {
            return MatchesPrefix();
        }
   
        public bool Matches(){
            if(called) Position = 0;
            return Search(ANCHOR_START|ANCHOR_END);
        }
   
        public bool Matches(string s){
            Target = s;
            return Search(ANCHOR_START|ANCHOR_END);
        }
   
        public int Position {
            set {
                wOffset=offset+value;
                wEnd=-1;
                called=false;
                Flush();
            }
        }

        public int Offset {
            set {
                this.offset = value;
                wOffset=value;
                wEnd=-1;
                called=false;
                Flush();
            }
        }
   
        public bool Find(){
            if(called) Skip();
            return Search(0);
        }
   
        public bool Find(int anchors){
            if(called) Skip();
            return Search(anchors);
        }
   
        public MatchIterator FindAll() {
            return FindAll(0);
        }
   
        private class SimpleMatchIterator : MatchIterator {
            Matcher matcher;
            int options;
            bool _checked = false;
            bool hasMore = false;
            public SimpleMatchIterator(Matcher matcher, int options) {
                this.matcher = matcher;
                this.options = options;
            }

            public bool HasMore {
                get {
                    if(!_checked) Check();
                    return hasMore;
                }
            }

            public MatchResult NextMatch {
                get {
                    if(!_checked) Check();
                    if(!hasMore) throw new InvalidOperationException();
                    _checked = false;
                    return matcher;
                }
            }

            private void Check() {
                hasMore = matcher.Find(options);
                _checked = true;
            }
        
            public int Count {
                get {
                    if(!_checked) Check();
                    if(!hasMore) return 0;
                    int c=1;
                    while(matcher.Find(options))c++;
                    _checked=false;
                    return c;
                }
            }
        }

        public MatchIterator FindAll(int options) {
            return new SimpleMatchIterator(this, options);
        }
   
        public bool Proceed() {
            return Proceed(0);
        }
   
        public bool Proceed(int options) {
            if(called){
                if(top==null){
                    wOffset++;
                }
            }
            return Search(0);
        }
   
        public void Skip() {
            int we=wEnd;
            if(wOffset==we) { //requires special handling
                if(top==null){ 
                    wOffset++;
                    Flush();
                }
                return;
            } else {
                if(we<0) wOffset=0;
                else wOffset=we;
            }
            Flush();
        }
   
        private void Init() {
            wOffset=offset;
            wEnd=-1;
            called=false;
            Flush();
        }
   
        private void Flush() {
            top=null;
            defaultEntry.Reset(0);
      
            first.Reset(minQueueLength);
            for(int i=memregs.Length-1;i>0;i--){
                MemReg mr=memregs[i];
                mr._in=mr._out=-1;
            }
            for(int i=memregs.Length-1;i>0;i--){
                MemReg mr=memregs[i];
                mr._in=mr._out=-1;
            }
            called=false;
        }
      
        public override string ToString() {
            return GetString(wOffset,wEnd);
        }
   
        public Pattern Pattern {
            get { return re; }
        }
   
        public char[] TargetChars {
            get { 
                shared=true;
                return data;
            }
        }
   
        public int TargetStart {
            get { return offset; }
        }
   
        public int TargetEnd {
            get { return end; }
        }
   
        public char CharAt(int i) {
            int _in=this.wOffset;
            int _out=this.wEnd;
            if(_in<0 || _out<_in) throw new InvalidOperationException("unassigned");
            return data[_in+i];
        }
   
        public char CharAt(int i, int groupId) {
            MemReg mr=Bounds(groupId);
            if(mr==null) throw new InvalidOperationException("group #"+groupId+" is not assigned");
            int _in=mr._in;
            if(i<0 || i>(mr._out-_in)) throw new ArgumentOutOfRangeException(""+i);
            return data[_in+i];
        }
   
        public int Length {
            get { return wEnd-wOffset; }
        }
   
        public int Start {
            get { return wOffset-offset; }
        }
   
        public int End {
            get { return wEnd-offset; }
        }
   
        public string Prefix {
            get { return GetString(offset,wOffset); }
        }

        public string Suffix {
            get { return GetString(wEnd,end); }
        }
   
        public int GroupCount {
            get { return memregs.Length; }
        }
   
        public string Group(int n) {
            MemReg mr=Bounds(n);
            if(mr==null) return null;
            return GetString(mr._in,mr._out);
        }
   
        public string Group(string name){
            return Group(re.GroupId(name));
        }
   
        public bool Group(int n, TextBuffer tb) {
            MemReg mr=Bounds(n);
            if(mr==null) return false;
            int _in;
            tb.Append(data,_in=mr._in,mr._out-_in);
            return true;
        }

        public bool Group(string name, TextBuffer tb) {
            return Group(re.GroupId(name), tb);
        }
   
        public bool Group(int n, StringBuilder sb) {
            MemReg mr=Bounds(n);
            if(mr==null) return false;
            int _in;
            sb.Append(data,_in=mr._in,mr._out-_in);
            return true;
        }
   
        public bool Group(string name, StringBuilder sb){
            return Group(re.GroupId(name), sb);
        }
   
        public string[] Groups {
            get {
                MemReg[] memregs=this.memregs;
                string[] groups=new string[memregs.Length];
                int _in,_out;
                MemReg mr;
                for(int i=0;i<memregs.Length;i++){
                    _in=(mr=memregs[i])._in;
                    _out=mr._out;
                    if((_in=mr._in)<0 || mr._out<_in) continue;
                    groups[i]=GetString(_in,_out);
                }
                return groups;
            }
        }
   
        public IList<string> Groupv {
            get {
                MemReg[] memregs=this.memregs;
                IList<string> v=new List<string>();
                MemReg mr;
                for(int i=0;i<memregs.Length;i++){
                    mr=Bounds(i);
                    if(mr==null){
                        v.Add("empty");
                        continue;
                    }
                    string s=GetString(mr._in,mr._out);
                    v.Add(s);
                }
                return v;
            }
        }
   
        private MemReg Bounds(int id) {
            MemReg mr;
            if(id>=0){
                mr=memregs[id];
            } else switch(id) {
                case PREFIX:
                    mr=prefixBounds;
                    if(mr==null) prefixBounds=mr=new MemReg(PREFIX);
                    mr._in=offset;
                    mr._out=wOffset;
                    break;
                case SUFFIX:
                    mr=suffixBounds;
                    if(mr==null) suffixBounds=mr=new MemReg(SUFFIX);
                    mr._in=wEnd;
                    mr._out=end;
                    break;
                case TARGET:
                    mr=targetBounds;
                    if(mr==null) targetBounds=mr=new MemReg(TARGET);
                    mr._in=offset;
                    mr._out=end;
                    break;
                default:
                    throw new ArgumentException("illegal group id: "+id+"; must either nonnegative int, or MatchResult.PREFIX, or MatchResult.SUFFIX");
                }
            int _in;
            if((_in=mr._in)<0 || mr._out<_in) return null;
            return mr;
        }
   
        public bool IsCaptured() {
            return wOffset>=0 && wEnd>=wOffset;
        }
   
        public bool IsCaptured(int id) {
            return Bounds(id)!=null;
        }
   
        public bool IsCaptured(string groupName){
            return IsCaptured(re.GroupId(groupName));
        }
   
        public int GetLength(int id) {
            MemReg mr=Bounds(id);
            return mr._out-mr._in;
        }
   
        public int GetStart(int id) {
            return Bounds(id)._in-offset;
        }
   
        public int GetEnd(int id) {
            return Bounds(id)._out-offset;
        }

        private bool Search(int anchors) {
            called=true;
            int end=this.end;
            int offset=this.offset;
            char[] data=this.data;
            int wOffset=this.wOffset;
            int wEnd=this.wEnd;
      
            MemReg[] memregs=this.memregs;
            int[] counters=this.counters;
            LAEntry[] lookaheads=this.lookaheads;
      
            SearchEntry defaultEntry=this.defaultEntry;
            SearchEntry first=this.first;
            SearchEntry top=this.top;
            SearchEntry actual=null;
            int cnt,regLen;
            int i;
      
            bool matchEnd=(anchors&ANCHOR_END)>0;
            bool allowIncomplete=(anchors&ACCEPT_INCOMPLETE)>0;
      
            Pattern re=this.re;
            Term root=re.root;
            Term term;
            if(top==null) {
                if((anchors&ANCHOR_START)>0) {
                    term=re.root0;  //raw root
                    root=startAnchor;
                } else if((anchors&ANCHOR_LASTMATCH)>0) {
                    term=re.root0;  //raw root
                    root=lastMatchAnchor;
                } else {
                    term=root;  //optimized root
                }
                i=wOffset;
                actual=first;
                SearchEntry.PopState(defaultEntry,memregs,counters);
            } else {
                top=(actual=top).sub;
                term=actual.term;
                i=actual.index;
                SearchEntry.PopState(actual,memregs,counters);
            }
            cnt=actual.cnt;
            regLen=actual.regLen;
      
            while(wOffset<=end){
                matchHere:
                for(;;){
                    int memreg,cntreg;
                    char c;
                    switch(term.type){
                    case Term.TermType.FIND:{
                        int jump=Find(data,i+term.distance,end,term.target); //don't eat the last match
                        if(jump<0) goto breakMain; //return false
                        i+=jump;
                        wOffset=i; //force window to move
                        if(term.eat){
                            if(i==end) break;
                            i++;
                        }
                        term=term.next;
                        goto matchHere;
                    }
                    case Term.TermType.FINDREG:{
                        MemReg mr=memregs[term.target.memreg];
                        int sampleOff=mr._in;
                        int sampleLen=mr._out-sampleOff;
                        if(sampleOff<0 || sampleLen<0) {
                            break;
                        } else if (sampleLen==0) {
                            term=term.next;
                            goto matchHere;
                        }
                        int jump=FindReg(data,i+term.distance,sampleOff,sampleLen,term.target,end); //don't eat the last match
                        if(jump<0) goto breakMain; //return false
                        i+=jump;
                        wOffset=i; //force window to move
                        if(term.eat) {
                            i+=sampleLen;
                            if(i>end) break;
                        }
                        term=term.next;
                        goto matchHere;
                    }
                    case Term.TermType.VOID:
                        term=term.next;
                        goto matchHere;
               
                    case Term.TermType.CHAR:
                        if(i>=end || data[i]!=term.c) break;
                        i++;
                        term=term.next;
                        goto matchHere;
               
                    case Term.TermType.ANY_CHAR:
                        if(i>=end) break;
                        i++;
                        term=term.next;
                        goto matchHere;
               
                    case Term.TermType.ANY_CHAR_NE:
                        if(i>=end || data[i]=='\n') break;
                        i++;
                        term=term.next;
                        goto matchHere;
               
                    case Term.TermType.END:
                        if(i>=end) {  //meets
                            term=term.next;
                            goto matchHere;
                        }
                        break; 
                  
                    case Term.TermType.END_EOL:  //perl's $
                        if(i>=end) {  //meets
                            term=term.next;
                            goto matchHere;
                        } else {
                            bool matches=
                                i>=end |
                                ((i+1)==end && data[i]=='\n');
                        
                            if(matches) {
                                term=term.next;
                                goto matchHere;
                            } else break; 
                        }
                  
                    case Term.TermType.LINE_END:
                        if(i>=end) {  //meets
                            term=term.next;
                            goto matchHere;
                        } else {
                            if(data[i]=='\n'){
                                term=term.next;
                                goto matchHere;
                            }
                        }
                        break; 
                  
                    case Term.TermType.START: //Perl's "^"
                        if(i==offset) {  //meets
                            term=term.next;
                            goto matchHere;
                        }
                        if(top!=null) break;
                        if(term!=startAnchor) break;
                        else goto breakMain;
                  
                    case Term.TermType.LAST_MATCH_END:
                        if(i==wEnd || wEnd == -1) {  //meets
                            term=term.next;
                            goto matchHere;
                        }
                        goto breakMain; //return false
                  
                    case Term.TermType.LINE_START:
                        if(i==offset) {  //meets
                            term=term.next;
                            goto matchHere;
                        } else if(i<end) {
                            if((c=data[i-1])=='\n') {
                                term=term.next;
                                goto matchHere;
                            }
                        }
                        break; 
                  
                    case Term.TermType.BITSET:{
                        if(i>=end) break;
                        c=data[i];
                        if(!(c<=255 && term.bitset[c])^term.inverse) break;
                        i++;
                        term=term.next;
                        goto matchHere;
                    }
                    case Term.TermType.BITSET2:{
                        if(i>=end) break;
                        c=data[i];
                        bool[] arr=term.bitset2[c>>8];
                        if(arr==null || !arr[c&255]^term.inverse) break;
                        i++;
                        term=term.next;
                        goto matchHere;
                    }
                    case Term.TermType.BOUNDARY:{
                        bool ch1Meets=false,ch2Meets=false;
                        bool[] bitset=term.bitset;
                        {
                            int j=i-1;
                            if(j<offset) goto test1;
                            c = data[j];
                            ch1Meets= (c<256 && bitset[c]);
                        }
                        test1:
                        {
                            if(i>=end) goto test2;
                            c = data[i];
                            ch2Meets = (c<256 && bitset[c]);
                        }
                        test2:
                        if(ch1Meets^ch2Meets^term.inverse) {  //meets
                            term=term.next;
                            goto matchHere;
                        } else break;
                    }
                    case Term.TermType.UBOUNDARY:{
                        bool ch1Meets=false,ch2Meets=false;
                        bool[][] bitset2=term.bitset2;
                        {
                            int j=i-1;
                            if(j<offset) goto test1;
                            c= data[j];
                            bool[] bits=bitset2[c>>8];
                            ch1Meets= bits!=null && bits[c&0xff];
                        }
                        test1:
                        {
                            if(i>=end) goto test2;
                            c= data[i];
                            bool[] bits=bitset2[c>>8];
                            ch2Meets= bits!=null && bits[c&0xff];
                        }
                        test2:
                        if(ch1Meets^ch2Meets^term.inverse){  //is boundary ^ inv
                            term=term.next;
                            goto matchHere;
                        }
                        else break;
                    }
                    case Term.TermType.DIRECTION:{
                        bool ch1Meets=false,ch2Meets=false;
                        bool[] bitset=term.bitset;
                        bool inv=term.inverse;
                        int j=i-1;
                        if(j>=offset){
                            c = data[j];
                            ch1Meets = c<256 && bitset[c];
                        }
                        if(ch1Meets^inv) break;
                  
                        if(i<end){
                            c = data[i];
                            ch2Meets= c<256 && bitset[c];
                        }
                        if(!ch2Meets^inv) break;
                        term=term.next;
                        goto matchHere;
                    }
                    case Term.TermType.UDIRECTION:{
                        bool ch1Meets=false,ch2Meets=false;
                        bool[][] bitset2=term.bitset2;
                        bool inv=term.inverse;
                        int j=i-1;
                  
                        if(j>=offset) {
                            c = data[j];
                            bool[] bits=bitset2[c>>8];
                            ch1Meets= bits!=null && bits[c&0xff];
                        }
                        if(ch1Meets^inv) break;
                        if(i<end) {
                            c= data[i];
                            bool[] bits=bitset2[c>>8];
                            ch2Meets= bits!=null && bits[c&0xff];
                        }
                        if(!ch2Meets^inv) break;
                  
                        term=term.next;
                        goto matchHere;
                    }
                    case Term.TermType.REG:{
                        MemReg mr=memregs[term.memreg];
                        int sampleOffset=mr._in;
                        int sampleOutside=mr._out;
                        int rLen;
                        if(sampleOffset<0 || (rLen=sampleOutside-sampleOffset)<0) {
                            break;
                        } else if(rLen==0) {
                            term=term.next;
                            goto matchHere;
                        }
                  
                        if((i+rLen)>end) break;
                  
                        if(CompareRegions(data,sampleOffset,i,rLen,end)){
                            i+=rLen;
                            term=term.next;
                            goto matchHere;
                        }
                        break;
                    }
                    case Term.TermType.REG_I:{
                        MemReg mr=memregs[term.memreg];
                        int sampleOffset=mr._in;
                        int sampleOutside=mr._out;
                        int rLen;
                        if(sampleOffset<0 || (rLen=sampleOutside-sampleOffset)<0){
                            break;
                        } else if(rLen==0) {
                            term=term.next;
                            goto matchHere;
                        }
                  
                        if((i+rLen)>end) break;
                  
                        if(CompareRegionsI(data,sampleOffset,i,rLen,end)) {
                            i+=rLen;
                            term=term.next;
                            goto matchHere;
                        }
                        break;
                    }
                    case Term.TermType.REPEAT_0_INF:{
                        if((cnt=Repeat(data,i,end,term.target))<=0){
                            term=term.next;
                            continue;
                        }
                        i+=cnt;
                  
                        actual.cnt=cnt;
                        actual.term=term.failNext;
                        actual.index=i;
                        actual=(top=actual).on;
                        if(actual==null){
                            actual=new SearchEntry();
                            top.on=actual;
                            actual.sub=top;
                        }
                        term=term.next;
                        continue;
                    }
                    case Term.TermType.REPEAT_MIN_INF:{
                        cnt=Repeat(data,i,end,term.target);
                        if(cnt<term.minCount) break;
                        i+=cnt;
                  
                        actual.cnt=cnt;
                        actual.term=term.failNext;
                        actual.index=i;
                        actual=(top=actual).on;
                        if(actual==null){
                            actual=new SearchEntry();
                            top.on=actual;
                            actual.sub=top;
                        }
                        term=term.next;
                        continue;
                    }
                    case Term.TermType.REPEAT_MIN_MAX:{
                        int out1=end;
                        int out2=i+term.maxCount;
                        cnt=Repeat(data,i,out1<out2? out1: out2,term.target);
                        if(cnt<term.minCount) break;
                        i+=cnt;
                  
                        actual.cnt=cnt;
                        actual.term=term.failNext;
                        actual.index=i;
                        actual=(top=actual).on;
                        if(actual==null) {
                            actual=new SearchEntry();
                            top.on=actual;
                            actual.sub=top;
                        }
                        term=term.next;
                        continue;
                    }
                    case Term.TermType.REPEAT_REG_MIN_INF:{
                        MemReg mr=memregs[term.memreg];
                        int sampleOffset=mr._in;
                        int sampleOutside=mr._out;
                        int bitset;
                        if(sampleOffset<0 || (bitset=sampleOutside-sampleOffset)<0) {
                            break;
                        } else if(bitset==0) {
                            term=term.next;
                            goto matchHere;
                        }
                  
                        cnt=0;
                  
                        while(CompareRegions(data,i,sampleOffset,bitset,end)){
                            cnt++;
                            i+=bitset;
                        }
                  
                        if(cnt<term.minCount) break;
                  
                        actual.cnt=cnt;
                        actual.term=term.failNext;
                        actual.index=i;
                        actual.regLen=bitset;
                        actual=(top=actual).on;
                        if(actual==null){
                            actual=new SearchEntry();
                            top.on=actual;
                            actual.sub=top;
                        }
                        term=term.next;
                        continue;
                    }
                    case Term.TermType.REPEAT_REG_MIN_MAX:{
                        MemReg mr=memregs[term.memreg];
                        int sampleOffset=mr._in;
                        int sampleOutside=mr._out;
                        int bitset;
                        if(sampleOffset<0 || (bitset=sampleOutside-sampleOffset)<0){
                            break;
                        } else if(bitset==0) {
                            term=term.next;
                            goto matchHere;
                        }
                  
                        cnt=0;
                        int countBack=term.maxCount;
                        while(countBack>0 && CompareRegions(data,i,sampleOffset,bitset,end)){
                            cnt++;
                            i+=bitset;
                            countBack--;
                        }
                  
                        if(cnt<term.minCount) break;
                  
                        actual.cnt=cnt;
                        actual.term=term.failNext;
                        actual.index=i;
                        actual.regLen=bitset;
                        actual=(top=actual).on;
                        if(actual==null) {
                            actual=new SearchEntry();
                            top.on=actual;
                            actual.sub=top;
                        }
                        term=term.next;
                        continue;
                    }
                    case Term.TermType.BACKTRACK_0:
                        cnt=actual.cnt;
                        if(cnt>0){
                            cnt--;
                            i--;
                            actual.cnt=cnt;
                            actual.index=i;
                            actual.term=term;
                            actual=(top=actual).on;
                            if(actual==null) {
                                actual=new SearchEntry();
                                top.on=actual;
                                actual.sub=top;
                            }
                            term=term.next;
                            continue;
                        }
                        else break;
               
                    case Term.TermType.BACKTRACK_MIN:
                        cnt=actual.cnt;
                        if(cnt>term.minCount) {
                            cnt--;
                            i--;
                            actual.cnt=cnt;
                            actual.index=i;
                            actual.term=term;
                            actual=(top=actual).on;
                            if(actual==null){
                                actual=new SearchEntry();
                                top.on=actual;
                                actual.sub=top;
                            }
                            term=term.next;
                            continue;
                        }
                        else break;
               
                    case Term.TermType.BACKTRACK_FIND_MIN:{
                        cnt=actual.cnt;
                        int minCnt;
                        if(cnt>(minCnt=term.minCount)) {
                            int start=i+term.distance;
                            if(start>end){
                                int exceed=start-end;
                                cnt-=exceed;
                                if(cnt<=minCnt) break;
                                i-=exceed;
                                start=end;
                            }
                            int back=FindBack(data,i+term.distance,cnt-minCnt,term.target);
                            if(back<0) break;
                     
                            if((cnt-=back)<=minCnt) {
                                i-=back;
                                if(term.eat)i++;
                                term=term.next;
                                continue;
                            }
                            i-=back;
                     
                            actual.cnt=cnt;
                            actual.index=i;
                     
                            if(term.eat)i++;
                     
                            actual.term=term;
                            actual=(top=actual).on;
                            if(actual==null) {
                                actual=new SearchEntry();
                                top.on=actual;
                                actual.sub=top;
                            }
                            term=term.next;
                            continue;
                        }
                        else break;
                    }
               
                    case Term.TermType.BACKTRACK_FINDREG_MIN:{
                        cnt=actual.cnt;
                        int minCnt;
                        if(cnt>(minCnt=term.minCount)){
                            int start=i+term.distance;
                            if(start>end) {
                                int exceed=start-end;
                                cnt-=exceed;
                                if(cnt<=minCnt) break;
                                i-=exceed;
                                start=end;
                            }
                            MemReg mr=memregs[term.target.memreg];
                            int sampleOff=mr._in;
                            int sampleLen=mr._out-sampleOff;
                            int back;
                            if(sampleOff<0 || sampleLen<0) { 
                                cnt--;
                                i--;
                                actual.cnt=cnt;
                                actual.index=i;
                                actual.term=term;
                                actual=(top=actual).on;
                                if(actual==null) {
                                    actual=new SearchEntry();
                                    top.on=actual;
                                    actual.sub=top;
                                }
                                term=term.next;
                                continue;
                            } else if(sampleLen==0) {
                                back=1;
                            } else {
                                back=FindBackReg(data,i+term.distance,sampleOff,sampleLen,cnt-minCnt,term.target,end);
                                if(back<0) break;
                            }
                            cnt-=back;
                            i-=back;
                            actual.cnt=cnt;
                            actual.index=i;
                     
                            if(term.eat)i+=sampleLen;
                     
                            actual.term=term;
                            actual=(top=actual).on;
                            if(actual==null){
                                actual=new SearchEntry();
                                top.on=actual;
                                actual.sub=top;
                            }
                            term=term.next;
                            continue;
                        }
                        else break;
                    }
               
                    case Term.TermType.BACKTRACK_REG_MIN:
                        cnt=actual.cnt;
                        if(cnt>term.minCount) {
                            regLen=actual.regLen;
                            cnt--;
                            i-=regLen;
                            actual.cnt=cnt;
                            actual.index=i;
                            actual.term=term;
                            actual=(top=actual).on;
                            if(actual==null){
                                actual=new SearchEntry();
                                top.on=actual;
                                actual.sub=top;
                            }
                            term=term.next;
                            continue;
                        }
                        else break;
               
                    case Term.TermType.GROUP_IN:{
                        memreg=term.memreg;
                        if(memreg>0) {
                            memregs[memreg].tmp=i; //assume
                        }
                        term=term.next;
                        continue;
                    }
                    case Term.TermType.GROUP_OUT:
                        memreg=term.memreg;
                        if(memreg>0){
                            MemReg mr=memregs[memreg];
                            SearchEntry.SaveMemregState((top!=null)? top: defaultEntry,memreg,mr);
                            mr._in=mr.tmp; //commit
                            mr._out=i;
                        }
                        term=term.next;
                        continue;
               
                    case Term.TermType.PLOOKBEHIND_IN:{
                        int tmp=i-term.distance;
                        if(tmp<offset) break;
                        LAEntry le=lookaheads[term.lookaheadId];
                        le.index=i;
                        i=tmp;
                        le.actual=actual;
                        le.top=top;
                        term=term.next;
                        continue;
                    }
                    case Term.TermType.INDEPENDENT_IN:
                    case Term.TermType.PLOOKAHEAD_IN:{
                        LAEntry le=lookaheads[term.lookaheadId];
                        le.index=i;
                        le.actual=actual;
                        le.top=top;
                        term=term.next;
                        continue;
                    }
                    case Term.TermType.LOOKBEHIND_CONDITION_OUT:
                    case Term.TermType.LOOKAHEAD_CONDITION_OUT:
                    case Term.TermType.PLOOKAHEAD_OUT:
                    case Term.TermType.PLOOKBEHIND_OUT:{
                        LAEntry le=lookaheads[term.lookaheadId];
                        i=le.index;
                        actual=le.actual;
                        top=le.top;
                        term=term.next;
                        continue;
                    }
                    case Term.TermType.INDEPENDENT_OUT:{
                        LAEntry le=lookaheads[term.lookaheadId];
                        actual=le.actual;
                        top=le.top;
                        term=term.next;
                        continue;
                    }
                    case Term.TermType.NLOOKBEHIND_IN:{
                        int tmp=i-term.distance;
                        if(tmp<offset) {
                            term=term.failNext;
                            continue;
                        }
                        LAEntry le=lookaheads[term.lookaheadId];
                        le.actual=actual;
                        le.top=top;
                  
                        actual.term=term.failNext;
                        actual.index=i;
                        i=tmp;
                        actual=(top=actual).on;
                        if(actual==null){
                            actual=new SearchEntry();
                            top.on=actual;
                            actual.sub=top;
                        }
                        term=term.next;
                        continue;
                    }
                    case Term.TermType.NLOOKAHEAD_IN:{
                        LAEntry le=lookaheads[term.lookaheadId];
                        le.actual=actual;
                        le.top=top;
                  
                        actual.term=term.failNext;
                        actual.index=i;
                        actual=(top=actual).on;
                        if(actual==null) {
                            actual=new SearchEntry();
                            top.on=actual;
                            actual.sub=top;
                        }
                  
                        term=term.next;
                        continue;
                    }
                    case Term.TermType.NLOOKBEHIND_OUT:
                    case Term.TermType.NLOOKAHEAD_OUT:{
                        LAEntry le=lookaheads[term.lookaheadId];
                        actual=le.actual;
                        top=le.top;
                        break;
                    }
                    case Term.TermType.LOOKBEHIND_CONDITION_IN:{
                        int tmp=i-term.distance;
                        if(tmp<offset){
                            term=term.failNext;
                            continue;
                        }
                        LAEntry le=lookaheads[term.lookaheadId];
                        le.index=i;
                        le.actual=actual;
                        le.top=top;
                  
                        actual.term=term.failNext;
                        actual.index=i;
                        actual=(top=actual).on;
                        if(actual==null) {
                            actual=new SearchEntry();
                            top.on=actual;
                            actual.sub=top;
                        }
                  
                        i=tmp;
                  
                        term=term.next;
                        continue;
                    }
                    case Term.TermType.LOOKAHEAD_CONDITION_IN:{
                        LAEntry le=lookaheads[term.lookaheadId];
                        le.index=i;
                        le.actual=actual;
                        le.top=top;
                  
                        actual.term=term.failNext;
                        actual.index=i;
                        actual=(top=actual).on;
                        if(actual==null) {
                            actual=new SearchEntry();
                            top.on=actual;
                            actual.sub=top;
                        }
                  
                        term=term.next;
                        continue;
                    }
                    case Term.TermType.MEMREG_CONDITION:{
                        MemReg mr=memregs[term.memreg];
                        int sampleOffset=mr._in;
                        int sampleOutside=mr._out;
                        if(sampleOffset>=0 && sampleOutside>=0 && sampleOutside>=sampleOffset){
                            term=term.next;
                        } else {
                            term=term.failNext;
                        }
                        continue;
                    }
                    case Term.TermType.BRANCH_STORE_CNT_AUX1:
                        actual.regLen=regLen;
                        goto case Term.TermType.BRANCH_STORE_CNT;
                    case Term.TermType.BRANCH_STORE_CNT:
                        actual.cnt=cnt;
                        goto case Term.TermType.BRANCH;
                    case Term.TermType.BRANCH:
                        actual.term=term.failNext;
                        actual.index=i;
                        actual=(top=actual).on;
                        if(actual==null) {
                            actual=new SearchEntry();
                            top.on=actual;
                            actual.sub=top;
                        }
                        term=term.next;
                        continue;

                    case Term.TermType.SUCCESS:
                        if(!matchEnd || i==end) {
                            this.wOffset=memregs[0]._in=wOffset;
                            this.wEnd=memregs[0]._out=i;
                            this.top=top;
                            return true;
                        } else break;

                    case Term.TermType.CNT_SET_0:
                        cnt=0;
                        term=term.next;
                        continue;

                    case Term.TermType.CNT_INC:
                        cnt++;
                        term=term.next;
                        continue;
               
                    case Term.TermType.CNT_GT_EQ:
                        if(cnt>=term.maxCount) {
                            term=term.next;
                            continue;
                        }
                        else break;
               
                    case Term.TermType.READ_CNT_LT:
                        cnt=actual.cnt;
                        if(cnt<term.maxCount) {
                            term=term.next;
                            continue;
                        }
                        else break;
               
                    case Term.TermType.CRSTORE_CRINC:{
                        int cntvalue=counters[cntreg=term.cntreg];
                        SearchEntry.SaveCntState((top!=null)? top: defaultEntry,cntreg,cntvalue);
                        counters[cntreg]=++cntvalue;
                        term=term.next;
                        continue;
                    }
                    case Term.TermType.CR_SET_0:
                        counters[term.cntreg]=0;

                        term=term.next;
                        continue;

                    case Term.TermType.CR_LT:
                        if(counters[term.cntreg]<term.maxCount) {
                            term=term.next;
                            continue;
                        } else break;

                    case Term.TermType.CR_GT_EQ:
                        if(counters[term.cntreg]>=term.maxCount) {
                            term=term.next;
                            continue;
                        } else break;
                               
                    default:
                        throw new System.Exception("unknown term type: "+term.type);
                    }
            
                    if(allowIncomplete && i==end) {
                        return true;
                    }
                    if(top==null) {
                        goto breakMatchHere;
                    }
            
                    top=(actual=top).sub;
                    term=actual.term;
                    i=actual.index;
                    if(actual.isState) {
                        SearchEntry.PopState(actual,memregs,counters);
                    }
                }
                breakMatchHere:
                if(defaultEntry.isState) SearchEntry.PopState(defaultEntry,memregs,counters);
         
                term=root;
                i=++wOffset;
            }
            breakMain:
            this.wOffset=wOffset;
            this.top=top;
      
            return false;
        }

        private static bool CompareRegions(char[] arr, int off1, int off2, int len,int _out) {
            int p1=off1+len-1;
            int p2=off2+len-1;
            if(p1>=_out || p2>=_out){
                return false;
            }
            for(int c=len;c>0;c--,p1--,p2--){
                if(arr[p1]!=arr[p2]){
                    return false;
                }
            }
            return true;
        }
   
        private static bool CompareRegionsI(char[] arr, int off1, int off2, int len,int _out){
            int p1=off1+len-1;
            int p2=off2+len-1;
            if(p1>=_out || p2>=_out){
                return false;
            }
            char c1,c2;
            for(int c=len;c>0;c--,p1--,p2--){
                if((c1=arr[p1])!=char.ToLower(c2=arr[p2]) &&
                   c1!=char.ToUpper(c2)) return false;
            }
            return true;
        }
   
        private static int Repeat(char[] data,int off,int _out,Term term){
            switch(term.type){
            case Term.TermType.CHAR:{
                char c=term.c;
                int i=off;
                while(i<_out) {
                    if(data[i]!=c) break;
                    i++;
                }
                return i-off;
            }
            case Term.TermType.ANY_CHAR:{
                return _out-off;
            }
            case Term.TermType.ANY_CHAR_NE:{
                int i=off;
                while(i<_out) {
                    if(data[i]=='\n') break;
                    i++;
                }
                return i-off;
            }
            case Term.TermType.BITSET:{
                bool[] arr=term.bitset;
                int i=off;
                char c;
                if(term.inverse) while(i<_out) {
                        if((c=data[i])<=255 && arr[c]) break;
                        else i++;
                    }
                else while(i<_out){
                        if((c=data[i])<=255 && arr[c]) i++;
                        else break;
                    }
                return i-off;
            }
            case Term.TermType.BITSET2:{
                int i=off;
                bool[][] bitset2=term.bitset2;
                char c;
                if(term.inverse) while(i<_out){
                        bool[] arr=bitset2[(c=data[i])>>8];
                        if(arr!=null && arr[c&0xff]) break;
                        else i++;
                    }
                else while(i<_out){
                        bool[] arr=bitset2[(c=data[i])>>8];
                        if(arr!=null && arr[c&0xff]) i++;
                        else break;
                    }
                return i-off;
            }
            }
            throw new System.Exception("this kind of term can't be quantified:"+term.type);
        }
   
        private static int Find(char[] data,int off,int _out,Term term) {
            if(off>=_out) return -1;
            switch(term.type){
            case Term.TermType.CHAR:{
                char c=term.c;
                int i=off;
                while(i<_out) {
                    if(data[i]==c) break;
                    i++;
                }
                return i-off;
            }
            case Term.TermType.BITSET:{
                bool[] arr=term.bitset;
                int i=off;
                char c;
                if(!term.inverse) while(i<_out) {
                        if((c=data[i])<=255 && arr[c]) break;
                        else i++;
                    } else while(i<_out) {
                        if((c=data[i])<=255 && arr[c]) i++;
                        else break;
                    }
                return i-off;
            }
            case Term.TermType.BITSET2:{
                int i=off;
                bool[][] bitset2=term.bitset2;
                char c;
                if(!term.inverse) while(i<_out) {
                        bool[] arr=bitset2[(c=data[i])>>8];
                        if(arr!=null && arr[c&0xff]) break;
                        else i++;
                    } else while(i<_out) {
                        bool[] arr=bitset2[(c=data[i])>>8];
                        if(arr!=null && arr[c&0xff]) i++;
                        else break;
                    }
                return i-off;
            }
            }
            throw new ArgumentException("can't seek this kind of term:"+term.type);
        }
   
   
        private static int FindReg(char[] data,int off,int regOff,int regLen,Term term,int _out) {
            if(off>=_out) return -1;
            int i=off;
            if(term.type==Term.TermType.REG) {
                while(i<_out) {
                    if(CompareRegions(data,i,regOff,regLen,_out)) break;
                    i++;
                }
            } else if(term.type==Term.TermType.REG_I) {
                while(i<_out) {
                    if(CompareRegionsI(data,i,regOff,regLen,_out)) break;
                    i++;
                }
            } else throw new ArgumentException("wrong findReg() target:"+term.type);
            return off-i;
        }
   
        private static int FindBack(char[] data,int off,int maxCount,Term term) {
            switch(term.type){
            case Term.TermType.CHAR:{
                char c=term.c;
                int i=off;
                int iMin=off-maxCount;
                for(;;){
                    if(data[--i]==c) break;
                    if(i<=iMin) return -1; 
                }
                return off-i;
            }
            case Term.TermType.BITSET:{
                bool[] arr=term.bitset;
                int i=off;
                char c;
                int iMin=off-maxCount;
                if(!term.inverse) for(;;) {
                        if((c=data[--i])<=255 && arr[c]) break;
                        if(i<=iMin) return -1;
                    } else for(;;) {
                        if((c=data[--i])>255 || !arr[c]) break;
                        if(i<=iMin) return -1;
                    }
                return off-i;
            }
            case Term.TermType.BITSET2:{
                bool[][] bitset2=term.bitset2;
                int i=off;
                char c;
                int iMin=off-maxCount;
                if(!term.inverse) for(;;) {
                        bool[] arr=bitset2[(c=data[--i])>>8];
                        if(arr!=null && arr[c&0xff]) break;
                        if(i<=iMin) return -1;
                    } else for(;;) {
                        bool[] arr=bitset2[(c=data[--i])>>8];
                        if(arr==null || arr[c&0xff]) break;
                        if(i<=iMin) return -1;
                    }
                return off-i;
            }
            }
            throw new ArgumentException("can't find this kind of term:"+term.type);
        }
   
        private static int FindBackReg(char[] data,int off,int regOff,int regLen,int maxCount,Term term,int _out) {
            int i=off;
            int iMin=off-maxCount;
            if(term.type==Term.TermType.REG) {
                char first=data[regOff];
                regOff++;
                regLen--;
                for(;;){
                    i--;
                    if(data[i]==first && CompareRegions(data,i+1,regOff,regLen,_out)) break;
                    if(i<=iMin) return -1;
                }
            } else if(term.type==Term.TermType.REG_I) {
                char c=data[regOff];
                char firstLower=char.ToLower(c);
                char firstUpper=char.ToUpper(c);
                regOff++;
                regLen--;
                for(;;){
                    i--;
                    if(((c=data[i])==firstLower || c==firstUpper) && CompareRegionsI(data,i+1,regOff,regLen,_out)) break;
                    if(i<=iMin) return -1;
                }
                return off-i;
            } else throw new ArgumentException("wrong findBackReg() target type :"+term.type);
            return off-i;
        }

        public string ToString_d() {
            StringBuilder s=new StringBuilder();
            s.Append("counters: ");
            s.Append(counters==null? 0: counters.Length);

            s.Append("\r\nmemregs: ");
            s.Append(memregs.Length);
            for(int i=0;i<memregs.Length;i++) s.Append("\r\n #"+i+": ["+memregs[i]._in+","+memregs[i]._out+"](\""+GetString(memregs[i]._in,memregs[i]._out)+"\")");
   
            s.Append("\r\ndata: ");
            if(data!=null)s.Append(data.Length);
            else s.Append("[none]");
      
            s.Append("\r\noffset: ");
            s.Append(offset);
   
            s.Append("\r\nend: ");
            s.Append(end);
   
            s.Append("\r\nwOffset: ");
            s.Append(wOffset);
   
            s.Append("\r\nwEnd: ");
            s.Append(wEnd);
   
            s.Append("\r\nregex: ");
            s.Append(re);
            return s.ToString();
        }
    }

    internal class SearchEntry {
        internal Term term;
        internal int index;
        internal int cnt;
        internal int regLen;
   
        internal bool isState;
   
        internal SearchEntry sub,on;
   
        private class MState {
            internal int index,_in,_out;
            internal MState next,prev;
        }
   
        private class CState {
            internal int index,value;
            internal CState next,prev;
        }
   
        MState mHead,mCurrent;
        CState cHead,cCurrent;
   
        internal static void SaveMemregState(SearchEntry entry, int memreg, MemReg mr) {
            entry.isState=true;
            MState current=entry.mCurrent;
            if(current==null) {
                MState head=entry.mHead;
                if(head==null) entry.mHead=entry.mCurrent=current=new MState();
                else current=head;
            } else {
                MState next=current.next;
                if(next==null){
                    current.next=next=new MState();
                    next.prev=current;
                }
                current=next;
            }
            current.index=memreg;
            current._in=mr._in;
            current._out=mr._out;
            entry.mCurrent=current;
        }
   
        internal static void SaveCntState(SearchEntry entry, int cntreg, int value) {
            entry.isState=true;
            CState current=entry.cCurrent;
            if(current==null) {
                CState head=entry.cHead;
                if(head==null) entry.cHead=entry.cCurrent=current=new CState();
                else current=head;
            } else {
                CState next=current.next;
                if(next==null) {
                    current.next=next=new CState();
                    next.prev=current;
                }
                current=next;
            }
            current.index=cntreg;
            current.value=value;
            entry.cCurrent=current;
        }
   
        internal static void PopState(SearchEntry entry, MemReg[] memregs, int[] counters) {
            MState ms=entry.mCurrent;
            while(ms!=null){
                MemReg mr=memregs[ms.index];
                mr._in=ms._in;
                mr._out=ms._out;
                ms=ms.prev;
            }
            CState cs=entry.cCurrent;
            while(cs!=null) {
                counters[cs.index]=cs.value;
                cs=cs.prev;
            }
            entry.mCurrent=null;
            entry.cCurrent=null;
            entry.isState=false;
        }
   
        internal void Reset(int restQueue) {
            term=null;
            index=cnt=regLen=0;
      
            mCurrent=null;
            cCurrent=null;
            isState=false;
      
            SearchEntry on=this.on;
            if(on!=null) {
                if(restQueue>0) on.Reset(restQueue-1);
                else {
                    this.on=null;
                    on.sub=null;
                }
            }
        }
    }

    internal class MemReg{
        internal int index;
   
        internal int _in=-1, _out=-1;
        internal int tmp=-1;
   
        internal MemReg(int index) {
            this.index=index;
        }
   
        internal void Reset() {
            _in=_out=-1;
        }
    }

    internal class LAEntry {
        internal int index;
        internal SearchEntry top, actual;
    }
}
