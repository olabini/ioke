
namespace NRegex {
    using System;
    using System.Collections;
    using System.Collections.Generic;
    using System.Text;

    internal class Term {
        public enum TermType {
            //runtime Term types
            CHAR, BITSET, BITSET2, ANY_CHAR, ANY_CHAR_NE,
       
            REG, REG_I, FIND, FINDREG, SUCCESS,
       
            /*optimization-transparent types*/
            BOUNDARY, DIRECTION, UBOUNDARY, UDIRECTION,
       
            GROUP_IN, GROUP_OUT, VOID,
       
            START, END, END_EOL, LINE_START, LINE_END, LAST_MATCH_END,
       
            CNT_SET_0, CNT_INC, CNT_GT_EQ, READ_CNT_LT,

            // CTSTORE_CRINC: store on 'actual' search entry
            CRSTORE_CRINC, CR_SET_0, CR_LT, CR_GT_EQ,
       
            /*optimization-nontransparent types*/
            BRANCH, BRANCH_STORE_CNT, BRANCH_STORE_CNT_AUX1,
       
            // INDEPENDENT_IN: functionally the same as NLOOKAHEAD_IN
            PLOOKAHEAD_IN, PLOOKAHEAD_OUT, NLOOKAHEAD_IN, NLOOKAHEAD_OUT, PLOOKBEHIND_IN, 
            PLOOKBEHIND_OUT, NLOOKBEHIND_IN, NLOOKBEHIND_OUT, INDEPENDENT_IN, INDEPENDENT_OUT,
       
            REPEAT_0_INF, REPEAT_MIN_INF, REPEAT_MIN_MAX, REPEAT_REG_MIN_INF, REPEAT_REG_MIN_MAX,
       
            BACKTRACK_0, BACKTRACK_MIN, BACKTRACK_FIND_MIN, BACKTRACK_FINDREG_MIN, BACKTRACK_REG_MIN,
       
            MEMREG_CONDITION, LOOKAHEAD_CONDITION_IN, LOOKAHEAD_CONDITION_OUT, LOOKBEHIND_CONDITION_IN,
            LOOKBEHIND_CONDITION_OUT
        }

        internal const int VARS_LENGTH=4;

        const int MEMREG_COUNT=0;    //refers current memreg index
        const int CNTREG_COUNT=1;   //refers current counters number
        const int DEPTH=2;      //refers current depth: (((depth=3)))
        const int LOOKAHEAD_COUNT=3;    //refers current memreg index
   
        const int LIMITS_LENGTH=3;
        const int LIMITS_PARSE_RESULT_INDEX=2;
        const int LIMITS_OK=1;
        const int LIMITS_FAILURE=2;
   
        internal Term next, failNext;
   
        internal TermType type=TermType.VOID;
        internal bool inverse;
   
        internal char c;
   
        internal int distance;
        internal bool eat;
   
        internal bool[] bitset;
        internal bool[][] bitset2;
   
        internal int weight;

        internal int memreg=-1;
        internal int minCount, maxCount;
        internal Term target;
        internal int cntreg=0;
        internal int lookaheadId;

        internal Term prev, _in, _out, out1, current;
        internal Term branchOut;
   
        internal static int instances;
        internal int instanceNum;


        internal Term() {
            instanceNum=instances;
            instances++;
            _in=_out=this;
        }
   
        internal Term(TermType type) : this() {
            this.type=type;
        }
   
        internal static void MakeTree(string s, REFlags flags, Pattern re) {
            char[] data=s.ToCharArray();
            MakeTree(data,0,data.Length,flags,re);
        }
   
        internal static void MakeTree(char[] data, int offset, int end, REFlags flags, Pattern re) {
            int[] vars={1,0,0,0}; //don't use counters[0]
      
            IList<Iterator> iterators = new List<Iterator>();
            IDictionary<string, int> groupNames = new Dictionary<string, int>();
      
            Pretokenizer t = new Pretokenizer(data,offset,end);
            Term term = MakeTree(t,data,vars,flags,new Group(),iterators,groupNames);

            term._out.type = TermType.SUCCESS;

            Term first = term.next;

            Term optimized = first;
            Optimizer opt = Optimizer.Find(first);
            if(opt!=null) optimized=opt.MakeFirst(first);
      
            foreach(Iterator o in iterators) {
                o.Optimize();
            }

            re.root=optimized;
            re.root0=first;
            re.memregs=vars[MEMREG_COUNT];
            re.counters=vars[CNTREG_COUNT];
            re.lookaheads=vars[LOOKAHEAD_COUNT];
            re.namedGroupMap=groupNames;
        }

        private static Term MakeTree(Pretokenizer t, char[] data, int[] vars, REFlags flags, Term term, IList<Iterator> iterators, IDictionary<string, int> groupNames) {
            if(vars.Length!=VARS_LENGTH) 
                throw new ArgumentException("vars.length should be "+VARS_LENGTH+", not "+vars.Length);
            while(true) {
                t.Next();
                term.Append(t.tOffset, t.tOutside, data, vars, flags, iterators, groupNames);
                switch(t.ttype){
                case Pretokenizer.FLAGS:
                    flags=t.Flags(flags);
                    continue;
                case Pretokenizer.CLASS_GROUP:
                    t.Next();
                    Term clg= new Term();
                    CharacterClass.ParseGroup(data, t.tOffset, t.tOutside, clg,
                                              (flags&REFlags.IGNORE_CASE)>0, (flags&REFlags.IGNORE_SPACES)>0,
                                              (flags&REFlags.UNICODE)>0, (flags&REFlags.XML_SCHEMA)>0);
                    term.Append(clg);
                    continue;
                case Pretokenizer.PLAIN_GROUP:
                    vars[DEPTH]++;
                    term.Append(MakeTree(t, data, vars, t.Flags(flags), new Group(), iterators, groupNames));
                    break;
                case Pretokenizer.NAMED_GROUP:
                    string gname = t.groupName;
                    int id;
                    if(char.IsDigit(gname[0])) {
                        id=Convert.ToInt32(gname);
                        if(groupNames.Values.Contains(id)) {
                            if(t.groupDeclared) throw new PatternSyntaxException("group redeclaration: "+gname+"; use ({=id}...) for multiple group assignments");
                        }
                        if(vars[MEMREG_COUNT]<=id) vars[MEMREG_COUNT]=id+1;
                    }
                    else {
                        if(groupNames.ContainsKey(gname)) {
                            if(t.groupDeclared) throw new PatternSyntaxException("group redeclaration "+gname+"; use ({=name}...) for group reassignments");
                            id = (int)groupNames[gname];
                        } else {
                            id = vars[MEMREG_COUNT]++;
                            groupNames[t.groupName] = id;
                        }
                    }
                    vars[DEPTH]++;
                    term.Append(MakeTree(t,data,vars,flags,new Group(id),iterators,groupNames));
                    break;
                case '(':
                    vars[DEPTH]++;
                    term.Append(MakeTree(t,data,vars,flags,new Group(vars[MEMREG_COUNT]++),iterators,groupNames));
                    break;
                case Pretokenizer.POS_LOOKAHEAD:
                    vars[DEPTH]++;
                    term.Append(MakeTree(t,data,vars,flags,new Lookahead(vars[LOOKAHEAD_COUNT]++,true),iterators,groupNames));
                    break;
                case Pretokenizer.NEG_LOOKAHEAD:
                    vars[DEPTH]++;
                    term.Append(MakeTree(t,data,vars,flags,new Lookahead(vars[LOOKAHEAD_COUNT]++,false),iterators,groupNames));
                    break;
                case Pretokenizer.POS_LOOKBEHIND:
                    vars[DEPTH]++;
                    term.Append(MakeTree(t,data,vars,flags,new Lookbehind(vars[LOOKAHEAD_COUNT]++,true),iterators,groupNames));
                    break;
                case Pretokenizer.NEG_LOOKBEHIND:
                    vars[DEPTH]++;
                    term.Append(MakeTree(t,data,vars,flags,new Lookbehind(vars[LOOKAHEAD_COUNT]++,false),iterators,groupNames));
                    break;
                case Pretokenizer.INDEPENDENT_REGEX:
                    vars[DEPTH]++;
                    term.Append(MakeTree(t,data,vars,flags,new IndependentGroup(vars[LOOKAHEAD_COUNT]++),iterators,groupNames));
                    break;
                case Pretokenizer.CONDITIONAL_GROUP:
                    vars[DEPTH]++;
                    t.Next();
                    Term fork = null;
                    bool positive = true;
                    switch(t.ttype){
                    case Pretokenizer.NEG_LOOKAHEAD:
                        positive=false;
                        vars[DEPTH]++;
                        Lookahead la1 = new Lookahead(vars[LOOKAHEAD_COUNT]++,positive);
                        MakeTree(t,data,vars,flags,la1,iterators,groupNames);
                        fork = new ConditionalExpr(la1);
                        break;
                    case Pretokenizer.POS_LOOKAHEAD:
                        vars[DEPTH]++;
                        Lookahead la2 = new Lookahead(vars[LOOKAHEAD_COUNT]++,positive);
                        MakeTree(t,data,vars,flags,la2,iterators,groupNames);
                        fork = new ConditionalExpr(la2);
                        break;
                    case Pretokenizer.NEG_LOOKBEHIND:
                        positive=false;
                        vars[DEPTH]++;
                        Lookbehind lb1 = new Lookbehind(vars[LOOKAHEAD_COUNT]++,positive);
                        MakeTree(t,data,vars,flags,lb1,iterators,groupNames);
                        fork = new ConditionalExpr(lb1);
                        break;
                    case Pretokenizer.POS_LOOKBEHIND:
                        vars[DEPTH]++;
                        Lookbehind lb2 = new Lookbehind(vars[LOOKAHEAD_COUNT]++,positive);
                        MakeTree(t,data,vars,flags,lb2,iterators,groupNames);
                        fork = new ConditionalExpr(lb2);
                        break;
                    case '(':
                        t.Next();
                        if(t.ttype!=')') throw new PatternSyntaxException("malformed condition");
                        int memregNo;
                        if(char.IsDigit(data[t.tOffset])) memregNo=MakeNumber(t.tOffset,t.tOutside,data);
                        else{
                            string gn=new string(data,t.tOffset,t.tOutside-t.tOffset);
                            if(groupNames.ContainsKey(gn)) {
                                memregNo = (int)groupNames[gn];
                            } else {
                                throw new PatternSyntaxException("unknown group name in conditional expr.: "+gn);
                            }
                        }
                        fork = new ConditionalExpr(memregNo);
                        break;
                    default:
                        throw new PatternSyntaxException("malformed conditional expression: "+t.ttype+" '"+(char)t.ttype+"'");
                    }
                    term.Append(MakeTree(t,data,vars,flags,fork,iterators,groupNames));
                    break;
                case '|':
                    term.NewBranch();
                    break;
                case Pretokenizer.END:
                    if(vars[DEPTH]>0) throw new PatternSyntaxException("unbalanced parenthesis");
                    term.Close();
                    return term;
                case ')':
                    if(vars[DEPTH]<=0) throw new PatternSyntaxException("unbalanced parenthesis");
                    term.Close();
                    vars[DEPTH]--;
                    return term;
                case Pretokenizer.COMMENT:
                    while(t.ttype!=')') t.Next();
                    continue;
                default:
                    throw new PatternSyntaxException("unknown token type: "+t.ttype);
                }
            }
        }

        internal static int MakeNumber(int off, int _out, char[] data){
            int n=0;
            for(int i=off;i<_out;i++){
                int d=data[i]-'0';
                if(d<0 || d>9) return -1;
                n*=10;
                n+=d;
            }
            return n;
        }
   
        protected void Append(int offset, int end, char[] data, int[] vars, REFlags flags, IList<Iterator> iterators, IDictionary<string, int> gmap) {
            int[] limits = new int[3];
            int i = offset;
            Term tmp, current=this.current;
            while(i<end){
                char c=data[i];
                bool greedy=true;
                switch(c){
                case '*':
                    if(current==null) throw new PatternSyntaxException("missing term before *");
                    i++;
                    if(i<end){
                        switch(data[i]) {
                        case '?':
                            greedy^=true;
                            i++;
                            break;
                        case '*':
                        case '+':
                            throw new PatternSyntaxException("nested *?+ in regexp");
                        }
                    }
                    tmp = greedy ? MakeGreedyStar(vars,current,iterators) : MakeLazyStar(vars,current);
                    current = ReplaceCurrent(tmp);
                    break;
                case '+':
                    if(current==null) throw new PatternSyntaxException("missing term before +");
                    i++;
                    if(i<end){
                        switch(data[i]) {
                        case '?':
                            greedy^=true;
                            i++;
                            break;
                        case '*':
                        case '+':
                            throw new PatternSyntaxException("nested *?+ in regexp");
                        }
                    }
                    tmp = greedy ? MakeGreedyPlus(vars,current,iterators) : MakeLazyPlus(vars,current);
                    current = ReplaceCurrent(tmp);
                    break;
                case '?':
                    if(current==null) throw new PatternSyntaxException("missing term before ?");
                    i++;
                    if(i<end){
                        switch(data[i]) {
                        case '?':
                            greedy^=true;
                            i++;
                            break;
                        case '*':
                        case '+':
                            throw new PatternSyntaxException("nested *?+ in regexp");
                        }
                    }
               
                    tmp = greedy ? MakeGreedyQMark(vars,current) : MakeLazyQMark(vars,current);
                    current = ReplaceCurrent(tmp);
                    break;
                case '{':
                    limits[0]=0;
                    limits[1]=-1;
                    int le=ParseLimits(i+1,end,data,limits);
                    if(limits[LIMITS_PARSE_RESULT_INDEX]==LIMITS_OK){ //parse ok
                        if(current==null) throw new PatternSyntaxException("missing term before {}");
                        i=le;
                        if(i<end && data[i]=='?'){
                            greedy^=true;
                            i++;
                        }
                        tmp = greedy ? MakeGreedyLimits(vars,current,limits,iterators) : MakeLazyLimits(vars,current,limits);
                        current = ReplaceCurrent(tmp);
                        break;
                    } else { //unicode class or named backreference
                        if(data[i+1]=='\\'){ //'{\name}' - backreference
                            int p=i+2;
                            if(p==end) throw new PatternSyntaxException("'group_id' expected");
                            while(char.IsWhiteSpace(data[p])){
                                p++;
                                if(p==end) throw new PatternSyntaxException("'group_id' expected");
                            }
                            BackReference br = new BackReference(-1,(flags&REFlags.IGNORE_CASE)>0);
                            i = ParseGroupId(data,p,end,br,gmap);
                            current = Append(br);
                            continue;
                        } else {
                            Term t = new Term();
                            i = CharacterClass.ParseName(data,i,end,t,false,(flags&REFlags.IGNORE_SPACES)>0);
                            current = Append(t);
                            continue;
                        }
                    }
               
                case ' ':
                case '\t':
                case '\r':
                case '\n':
                    if((flags&REFlags.IGNORE_SPACES)>0){
                        i++;
                        continue;
                    }
                    tmp = new Term();
                    i = ParseTerm(data,i,end,tmp,flags);
               
                    if(tmp.type == TermType.END && i<end){
                        if((flags&REFlags.IGNORE_SPACES)>0) {
                            i++;
                            while(i<end) {
                                c=data[i];
                                switch(c){
                                case ' ':
                                case '\t':
                                case '\r':
                                case '\n':
                                    i++;
                                    continue;
                                default:
                                    throw new PatternSyntaxException("'$' is not a last term in the group: <"+new string(data,offset,end-offset)+">");
                                }
                            }
                        } else {
                            throw new PatternSyntaxException("'$' is not a last term in the group: <"+new string(data,offset,end-offset)+">");
                        }
                    }
                    current = Append(tmp);
                    break;
                default:
                    tmp = new Term();
                    i = ParseTerm(data,i,end,tmp,flags);
               
                    if(tmp.type == TermType.END && i<end){
                        if((flags&REFlags.IGNORE_SPACES)>0) {
                            i++;
                            while(i<end) {
                                c=data[i];
                                switch(c){
                                case ' ':
                                case '\t':
                                case '\r':
                                case '\n':
                                    i++;
                                    continue;
                                default:
                                    throw new PatternSyntaxException("'$' is not a last term in the group: <"+new string(data,offset,end-offset)+">");
                                }
                            }
                        } else {
                            throw new PatternSyntaxException("'$' is not a last term in the group: <"+new string(data,offset,end-offset)+">");
                        }
                    }
                    current = Append(tmp);
                    break;
                }
            }
        }

        private static int ParseGroupId(char[] data, int i, int end, Term term, IDictionary<string, int> gmap) {
            int id;
            int nstart=i;
            if(char.IsDigit(data[i])){
                while(char.IsDigit(data[i])){
                    i++;
                    if(i==end) throw new PatternSyntaxException("group_id expected");
                }
                id = MakeNumber(nstart,i,data);
            } else {
                while(char.IsLetterOrDigit(data[i])){
                    i++;
                    if(i==end) throw new PatternSyntaxException("group_id expected");
                }
                string s = new string(data,nstart,i-nstart);
                if(gmap.ContainsKey(s))
                    id = gmap[s];
                else
                    throw new PatternSyntaxException("backreference to unknown group: "+s);
            }
            while(char.IsWhiteSpace(data[i])){
                i++;
                if(i==end) throw new PatternSyntaxException("'}' expected");
            }
      
            int c = data[i++];
      
            if(c!='}') throw new PatternSyntaxException("'}' expected");
      
            term.memreg = id;
            return i;
        }
   
        protected virtual Term Append(Term term) {
            Term current = this.current;
            if(current==null){
                _in.next = term;
                term.prev = _in;
                this.current = term;
                return term;
            }
            Link(current,term);
            this.current = term;
            return term;
        }
   
        protected virtual Term ReplaceCurrent(Term term) {
            Term prev = current.prev;
            if(prev!=null){
                Term _in = this._in;
                if(prev == _in){
                    _in.next = term._in;
                    term._in.prev = _in;
                }
                else Link(prev,term);
            }
            this.current = term;
            return term;
        }


        protected void NewBranch() {
            Close();
            StartNewBranch();
        }


        protected virtual void Close() {
            Term current = this.current;
            if(current != null) Linkd(current,_out);
            else _in.next = _out;
        }
   
        private static void Link(Term term, Term next) {
            Linkd(term, next._in);
            next.prev = term;
        }
   
        private static void Linkd(Term term, Term next) {
            Term prev_out = term._out;
            if(prev_out != null){
                prev_out.next = next;
            }
            Term prev_out1 = term.out1;
            if(prev_out1 != null){
                prev_out1.next = next;
            }
            Term prev_branch = term.branchOut;
            if(prev_branch != null){
                prev_branch.failNext = next;
            }
        }
   
        protected virtual void StartNewBranch() {
            Term tmp = _in.next;
            Term b = new Branch();
            _in.next = b;
            b.next = tmp;
            b._in = null;
            b._out = null;
            b.out1 = null;
            b.branchOut = b;
            current = b;
        }

        private static Term MakeGreedyStar(int[] vars, Term term, IList<Iterator> iterators) {
            switch(term.type){
            case TermType.REPEAT_0_INF:
            case TermType.REPEAT_MIN_INF:
            case TermType.REPEAT_MIN_MAX:
            case TermType.REPEAT_REG_MIN_INF:
            case TermType.REPEAT_REG_MIN_MAX:
            case TermType.INDEPENDENT_IN:
            case TermType.GROUP_IN:{
                Term b = new Branch();
                b.next = term._in;
                term._out.next = b;
            
                b._in = b;
                b._out = null;
                b.out1 = null;
                b.branchOut = b;
            
                return b;
            }
            default:{
                Iterator i = new Iterator(term,0,-1,iterators);
                return i;
            }
            }
        }

        private static Term MakeLazyStar(int[] vars, Term term){
            //vars[STACK_SIZE]++;
            switch(term.type){
            case TermType.REPEAT_0_INF:
            case TermType.REPEAT_MIN_INF:
            case TermType.REPEAT_MIN_MAX:
            case TermType.REPEAT_REG_MIN_INF:
            case TermType.REPEAT_REG_MIN_MAX:
            case TermType.GROUP_IN:{
                Term b = new Branch();
                b.failNext = term._in;
                term._out.next = b;
            
                b._in = b;
                b._out = b;
                b.out1 = null;
                b.branchOut = null;
            
                return b;
            }
            default:{
                Term b = new Branch();
                b.failNext = term;
                term.next = b;
            
                b._in = b;
                b._out = b;
                b.out1 = null;
                b.branchOut = null;
            
                return b;
            }
            }
        }

        private static Term MakeGreedyPlus(int[] vars, Term term, IList<Iterator> iterators) {
            switch(term.type){
            case TermType.REPEAT_0_INF:
            case TermType.REPEAT_MIN_INF:
            case TermType.REPEAT_MIN_MAX:
            case TermType.REPEAT_REG_MIN_INF:
            case TermType.REPEAT_REG_MIN_MAX:
            case TermType.INDEPENDENT_IN://?
            case TermType.GROUP_IN:{
                Term b = new Branch();
                b.next = term._in;
                term._out.next = b;
            
                b._in = term._in;
                b._out = null;
                b.out1 = null;
                b.branchOut = b;
            
                return b;
            }
            default:{
                return new Iterator(term,1,-1,iterators);
            }
            }
        }
   
        private static Term MakeLazyPlus(int[] vars, Term term){
            switch(term.type){
            case TermType.REPEAT_0_INF:
            case TermType.REPEAT_MIN_INF:
            case TermType.REPEAT_MIN_MAX:
            case TermType.REPEAT_REG_MIN_INF:
            case TermType.REPEAT_REG_MIN_MAX:
            case TermType.GROUP_IN:{
                Term b = new Branch();
                term._out.next = b;
                b.failNext = term._in;
            
                b._in = term._in;
                b._out = b;
                b.out1 = null;
                b.branchOut = null;
            
                return b;
            }
            case TermType.REG:
            default:{
                Term b = new Branch();
                term.next = b;
                b.failNext = term;
            
                b._in = term;
                b._out = b;
                b.out1 = null;
                b.branchOut = null;
            
                return b;
            }
            }
        }

        private static Term MakeGreedyQMark(int[] vars, Term term) {
            switch(term.type){
            case TermType.REPEAT_0_INF:
            case TermType.REPEAT_MIN_INF:
            case TermType.REPEAT_MIN_MAX:
            case TermType.REPEAT_REG_MIN_INF:
            case TermType.REPEAT_REG_MIN_MAX:
            case TermType.GROUP_IN:{
                Term b = new Branch();
                b.next = term._in;
            
                b._in = b;
                b._out = term._out;
                b.out1 = null;
                b.branchOut = b;
            
                return b;
            }
            case TermType.REG:
            default:{
                Term b = new Branch();
                b.next = term;
            
                b._in = b;
                b._out = term;
                b.out1 = null;
                b.branchOut = b;
            
                return b;
            }
            }
        }
   
        private static Term MakeLazyQMark(int[] vars, Term term) {
            switch(term.type){
            case TermType.REPEAT_0_INF:
            case TermType.REPEAT_MIN_INF:
            case TermType.REPEAT_MIN_MAX:
            case TermType.REPEAT_REG_MIN_INF:
            case TermType.REPEAT_REG_MIN_MAX:
            case TermType.GROUP_IN:{
                Term b = new Branch();
                b.failNext = term._in;
            
                b._in = b;
                b._out = b;
                b.out1 = term._out;
                b.branchOut = null;
            
                return b;
            }
            case TermType.REG:
            default:{
                Term b = new Branch();
                b.failNext = term;
            
                b._in = b;
                b._out = b;
                b.out1 = term;
                b.branchOut = null;
            
                return b;
            }
            }
        }

        private static Term MakeGreedyLimits(int[] vars, Term term, int[] limits, IList<Iterator> iterators) {
            int m=limits[0];
            int n=limits[1];
            switch(term.type){
            case TermType.REPEAT_0_INF:
            case TermType.REPEAT_MIN_INF:
            case TermType.REPEAT_MIN_MAX:
            case TermType.REPEAT_REG_MIN_INF:
            case TermType.REPEAT_REG_MIN_MAX:
            case TermType.GROUP_IN:{
                int cntreg = vars[CNTREG_COUNT]++;
                Term reset = new Term(TermType.CR_SET_0);
                reset.cntreg = cntreg;
                Term b = new Term(TermType.BRANCH);
            
                Term inc = new Term(TermType.CRSTORE_CRINC);
                inc.cntreg = cntreg;
            
                reset.next = b;
            
                if(n>=0) {
                    Term lt = new Term(TermType.CR_LT);
                    lt.cntreg = cntreg;
                    lt.maxCount = n;
                    b.next = lt;
                    lt.next = term._in;
                } else {
                    b.next = term._in;
                }
                term._out.next = inc;
                inc.next = b;
            
                if(m>=0) {
                    Term gt = new Term(TermType.CR_GT_EQ);
                    gt.cntreg = cntreg;
                    gt.maxCount = m;
                    b.failNext = gt;
               
                    reset._in = reset;
                    reset._out = gt;
                    reset.out1 = null;
                    reset.branchOut = null;
                } else {
                    reset._in = reset;
                    reset._out = null;
                    reset.out1 = null;
                    reset.branchOut = b;
                }
                return reset;
            }
            default:{
                return new Iterator(term,limits[0],limits[1],iterators);
            }
            }
        }

        private static Term MakeLazyLimits(int[] vars, Term term, int[] limits) {
            int m=limits[0];
            int n=limits[1];
            switch(term.type){
            case TermType.REPEAT_0_INF:
            case TermType.REPEAT_MIN_INF:
            case TermType.REPEAT_MIN_MAX:
            case TermType.REPEAT_REG_MIN_INF:
            case TermType.REPEAT_REG_MIN_MAX:
            case TermType.GROUP_IN:{
                int cntreg = vars[CNTREG_COUNT]++;
                Term reset = new Term(TermType.CR_SET_0);
                reset.cntreg = cntreg;
                Term b = new Term(TermType.BRANCH);
                Term inc = new Term(TermType.CRSTORE_CRINC);
                inc.cntreg = cntreg;
               
                reset.next = b;
            
                if(n>=0) {
                    Term lt = new Term(TermType.CR_LT);
                    lt.cntreg = cntreg;
                    lt.maxCount = n;
                    b.failNext = lt;
                    lt.next = term._in;
                } else {
                    b.failNext = term._in;
                }
                term._out.next = inc;
                inc.next = b;
            
                if(m>=0) {
                    Term gt = new Term(TermType.CR_GT_EQ);
                    gt.cntreg = cntreg;
                    gt.maxCount = m;
                    b.next = gt;
               
                    reset._in = reset;
                    reset._out = gt;
                    reset.out1 = null;
                    reset.branchOut = null;
               
                    return reset;
                } else {
                    reset._in = reset;
                    reset._out = b;
                    reset.out1 = null;
                    reset.branchOut = null;
               
                    return reset;
                }
            }
            case TermType.REG:
            default:{
                Term reset = new Term(TermType.CNT_SET_0);
                Term b = new Branch(TermType.BRANCH_STORE_CNT);
                Term inc = new Term(TermType.CNT_INC);
            
                reset.next = b;
            
                if(n>=0) {
                    Term lt = new Term(TermType.READ_CNT_LT);
                    lt.maxCount = n;
                    b.failNext = lt;
                    lt.next = term;
                    term.next = inc;
                    inc.next = b;
                } else {
                    b.next = term;
                    term.next = inc;
                    inc.next = term;
                }
            
                if(m>=0) {
                    Term gt = new Term(TermType.CNT_GT_EQ);
                    gt.maxCount = m;
                    b.next = gt;
               
                    reset._in = reset;
                    reset._out = gt;
                    reset.out1 = null;
                    reset.branchOut = null;
               
                    return reset;
                } else {
                    reset._in = reset;
                    reset._out = b;
                    reset.out1 = null;
                    reset.branchOut = null;
               
                    return reset;
                }
            }
            }
        }
   

        private int ParseTerm(char[] data, int i, int _out, Term term, REFlags flags) {
            char c=data[i++];
            bool inv=false;
            switch(c) {
            case '[':
                return CharacterClass.ParseClass(data, i, _out, term,(flags&REFlags.IGNORE_CASE)>0, (flags&REFlags.IGNORE_SPACES)>0, (flags&REFlags.UNICODE)>0, (flags&REFlags.XML_SCHEMA)>0);

            case '.':
                term.type = (flags&REFlags.DOTALL)>0 ? TermType.ANY_CHAR : TermType.ANY_CHAR_NE;
            break;

            case '$':
                term.type = (flags&REFlags.MULTILINE)>0 ? TermType.LINE_END : TermType.END_EOL;
            break;

            case '^':
                term.type = (flags&REFlags.MULTILINE)>0 ? TermType.LINE_START : TermType.START;
            break;

            case '\\': {
                if(i>=_out) throw new PatternSyntaxException("Escape without a character");
                c=data[i++];
                switch(c){
                case 'f':
                    c='\f'; // form feed
                    break;
                case 'n':
                    c='\n'; // new line
                    break;
                case 'r':
                    c='\r'; // carriage return
                    break;
                case 't':
                    c='\t'; // tab
                    break;
                case '\\':
                    c='\\';
                    break;
                case 'u':
                    if(i+4 >= _out) throw new PatternSyntaxException("To few characters for u-escape");
                    c=(char)((CharacterClass.ToHexDigit(data[i++])<<12)+
                             (CharacterClass.ToHexDigit(data[i++])<<8)+
                             (CharacterClass.ToHexDigit(data[i++])<<4)+
                             CharacterClass.ToHexDigit(data[i++]));
                    break;
                case 'v':
                    if(i+6 >= _out) throw new PatternSyntaxException("To few characters for u-escape");
                    c=(char)((CharacterClass.ToHexDigit(data[i++])<<24)+
                             (CharacterClass.ToHexDigit(data[i++])<<16)+
                             (CharacterClass.ToHexDigit(data[i++])<<12)+
                             (CharacterClass.ToHexDigit(data[i++])<<8)+
                             (CharacterClass.ToHexDigit(data[i++])<<4)+
                             CharacterClass.ToHexDigit(data[i++]));
                    break;
                case 'x':{   // hex 2-digit number -> char
                    if(i >= _out) throw new PatternSyntaxException("To few characters for x-escape");
                    int hex=0;
                    char d;
                    if((d=data[i++])=='{'){
                        while(i<_out && (d=data[i++])!='}'){
                            hex=(hex<<4)+CharacterClass.ToHexDigit(d);
                            if(hex>0xffff) throw new PatternSyntaxException("\\x{<out of range>}");
                        }
                    } else {
                        if(i >= _out) throw new PatternSyntaxException("To few characters for x-escape");
                        hex=(CharacterClass.ToHexDigit(d)<<4)+
                            CharacterClass.ToHexDigit(data[i++]);
                    }
                    c=(char)hex;
                    break;
                }
                case '0':
                case 'o':   // oct 2- or 3-digit number -> char
                    int oct=0;
                    for(;;){
                        char d=data[i];
                        if(d>='0' && d<='7'){
                            i++;
                            oct*=8;
                            oct+=d-'0';
                            if(oct>0xffff) break;
                            if(i>=_out) break;
                        } else break;
                    }
                    c=(char)oct;
                    break;
                case 'm':   // decimal number -> char
                    int dec=0;
                    for(;;){
                        char d=data[i++];
                        if(d>='0' && d<='9'){
                            dec*=10;
                            dec+=d-'0';
                            if(dec>0xffff) break;
                            if(i>=_out) break;
                        } else break;
                    }
                    i--;
                    c=(char)dec;
                    break;
                case 'c':   // ctrl-char
                    c=(char)(data[i++]&0x1f);
                    break;
                case 'D':   // non-digit
                    inv=true;
                    goto case 'd';
                case 'd':   // digit
                    CharacterClass.MakeDigit(term, inv, (flags&REFlags.UNICODE)>0);
                    return i;
                case 'S':   // non-space
                    inv=true;
                    goto case 's';
                case 's':   // space
                    CharacterClass.MakeSpace(term, inv, (flags&REFlags.UNICODE)>0);
                    return i;
                case 'W':   // non-letter
                    inv=true;
                    goto case 'w';
                case 'w':   // letter
                    CharacterClass.MakeWordChar(term, inv, (flags&REFlags.UNICODE)>0);
                    return i;
                case 'B':   // non-(word boundary)
                    inv=true;
                    goto case 'b';
                case 'b':   // word boundary
                    CharacterClass.MakeWordBoundary(term, inv, (flags&REFlags.UNICODE)>0);
                    return i;
                case '<':   // non-(word boundary)
                    CharacterClass.MakeWordStart(term, (flags&REFlags.UNICODE)>0);
                    return i;
                case '>':   // word boundary
                    CharacterClass.MakeWordEnd(term, (flags&REFlags.UNICODE)>0);
                    return i;
                case 'A':   // text beginning
                    term.type = TermType.START;
                    return i;
                case 'Z':   // text end
                    term.type = TermType.END_EOL;
                    return i;
                case 'z':   // text end
                    term.type = TermType.END;
                    return i;
                case 'G':   // end of last match
                    term.type = TermType.LAST_MATCH_END;
                    return i;
                case 'P':   // \\P{..}
                    inv=true;
                    goto case 'p';
                case 'p':   // \\p{..}
                    i=CharacterClass.ParseName(data, i, _out, term, inv, (flags&REFlags.IGNORE_SPACES)>0);
                    return i;
                default:
                    if(c>='1' && c<='9'){
                        int n=c-'0';
                        while((i<_out) && (c=data[i])>='0' && c<='9'){
                            n=(n*10)+c-'0';
                            i++;
                        }
                        term.type = (flags&REFlags.IGNORE_CASE)>0 ? TermType.REG_I : TermType.REG;
                        term.memreg = n;
                        return i;
                    }
                    break;
                }
                term.type = TermType.CHAR;
                term.c = c;
                break;
            }
            default: {
                if((flags&REFlags.IGNORE_CASE)==0){
                    term.type = TermType.CHAR;
                    term.c = c;
                } else {
                    CharacterClass.MakeICase(term,c);
                }
                break;
            }
            }
            return i;
        }


        // one of {n},{n,},{,n},{n1,n2}
        protected static int ParseLimits(int i, int end, char[] data, int[] limits) {
            if(limits.Length!=LIMITS_LENGTH) throw new ArgumentException("maxTimess.length="+limits.Length+", should be 2");
            limits[LIMITS_PARSE_RESULT_INDEX]=LIMITS_OK;
            int ind=0;
            int v=0;
            char c;
            while(i<end){
                c=data[i++];
                switch(c){
                case ' ':
                    continue;

                case ',':
                    if(ind>0) throw new PatternSyntaxException("illegal construction: {.. , , ..}");
                    limits[ind++]=v;
                    v=-1;
                    continue;

                case '}':
                    limits[ind]=v;
                    if(ind==0) limits[1]=v;
                    return i;

                default:
                    if(c>'9' || c<'0'){
                        limits[LIMITS_PARSE_RESULT_INDEX]=LIMITS_FAILURE;
                        return i;
                    }
                    if(v<0) v=0;
                    v= v*10 + (c-'0');
                    break;
                }
            }
            throw new PatternSyntaxException("malformed quantifier");
        }

        public override string ToString(){
            StringBuilder b = new StringBuilder(100);
            b.Append(instanceNum);
            b.Append(": ");
            if(inverse) b.Append('^');
            switch(type){
            case TermType.VOID:
                b.Append("[]");
                b.Append(" , ");
                break;
            case TermType.CHAR:
                b.Append(CharacterClass.StringValue(c));
                b.Append(" , ");
                break;
            case TermType.ANY_CHAR:
                b.Append("dotall, ");
                break;
            case TermType.ANY_CHAR_NE:
                b.Append("dot-eols, ");
                break;
            case TermType.BITSET:
                b.Append('[');
                b.Append(CharacterClass.StringValue0(bitset));
                b.Append(']');
                b.Append(" , weight=");
                b.Append(weight);
                b.Append(" , ");
                break;
            case TermType.BITSET2:
                b.Append('[');
                b.Append(CharacterClass.StringValue2(bitset2));
                b.Append(']');
                b.Append(" , weight=");
                b.Append(weight);
                b.Append(" , ");
                break;
            case TermType.START:
                b.Append("abs.start");
                break;            
            case TermType.END:
                b.Append("abs.end");
                break;            
            case TermType.END_EOL:
                b.Append("abs.end-eol");
                break;            
            case TermType.LINE_START:
                b.Append("line start");
                break;            
            case TermType.LINE_END:
                b.Append("line end");
                break;            
            case TermType.LAST_MATCH_END:
                if(inverse)b.Append("non-");
                b.Append("BOUNDARY");
                break;            
            case TermType.BOUNDARY:
                if(inverse)b.Append("non-");
                b.Append("BOUNDARY");
                break;            
            case TermType.UBOUNDARY:
                if(inverse)b.Append("non-");
                b.Append("UBOUNDARY");
                break;            
            case TermType.DIRECTION:
                b.Append("DIRECTION");
                break;            
            case TermType.UDIRECTION:
                b.Append("UDIRECTION");
                break;            
            case TermType.FIND:
                b.Append(">>>{");
                b.Append(target);
                b.Append("}, <<");
                b.Append(distance);
                if(eat){
                    b.Append(",eat");
                }
                b.Append(", ");
                break;            
            case TermType.REPEAT_0_INF:
                b.Append("rpt{");
                b.Append(target);
                b.Append(",0,inf}");
                if(failNext!=null){
                    b.Append(", =>");
                    b.Append(failNext.instanceNum);
                    b.Append(", ");
                }
                break;            
            case TermType.REPEAT_MIN_INF:
                b.Append("rpt{");
                b.Append(target);
                b.Append(",");
                b.Append(minCount);
                b.Append(",inf}");
                if(failNext!=null){
                    b.Append(", =>");
                    b.Append(failNext.instanceNum);
                    b.Append(", ");
                }
                break;            
            case TermType.REPEAT_MIN_MAX:
                b.Append("rpt{");
                b.Append(target);
                b.Append(",");
                b.Append(minCount);
                b.Append(",");
                b.Append(maxCount);
                b.Append("}");
                if(failNext!=null){
                    b.Append(", =>");
                    b.Append(failNext.instanceNum);
                    b.Append(", ");
                }
                break;            
            case TermType.REPEAT_REG_MIN_INF:
                b.Append("rpt{$");
                b.Append(memreg);
                b.Append(',');
                b.Append(minCount);
                b.Append(",inf}");
                if(failNext!=null){
                    b.Append(", =>");
                    b.Append(failNext.instanceNum);
                    b.Append(", ");
                }
                break;            
            case TermType.REPEAT_REG_MIN_MAX:
                b.Append("rpt{$");
                b.Append(memreg);
                b.Append(',');
                b.Append(minCount);
                b.Append(',');
                b.Append(maxCount);
                b.Append("}");
                if(failNext!=null){
                    b.Append(", =>");
                    b.Append(failNext.instanceNum);
                    b.Append(", ");
                }
                break;            
            case TermType.BACKTRACK_0:
                b.Append("back(0)");
                break;            
            case TermType.BACKTRACK_MIN:
                b.Append("back(");
                b.Append(minCount);
                b.Append(")");
                break;            
            case TermType.BACKTRACK_REG_MIN:
                b.Append("back");
                b.Append("_$");
                b.Append(memreg);
                b.Append("(");
                b.Append(minCount);
                b.Append(")");
                break;            
            case TermType.GROUP_IN:
                b.Append('(');
                if(memreg>0)b.Append(memreg);
                b.Append('-');
                b.Append(" , ");
                break;
            case TermType.GROUP_OUT:
                b.Append('-');
                if(memreg>0)b.Append(memreg);
                b.Append(')');
                b.Append(" , ");
                break;
            case TermType.PLOOKAHEAD_IN:
                b.Append('(');
                b.Append("=");
                b.Append(lookaheadId);
                b.Append(" , ");
                break;
            case TermType.PLOOKAHEAD_OUT:
                b.Append('=');
                b.Append(lookaheadId);
                b.Append(')');
                b.Append(" , ");
                break;
            case TermType.NLOOKAHEAD_IN:
                b.Append("(!");
                b.Append(lookaheadId);
                b.Append(" , ");
                if(failNext!=null){
                    b.Append(", =>");
                    b.Append(failNext.instanceNum);
                    b.Append(", ");
                }
                break;
            case TermType.NLOOKAHEAD_OUT:
                b.Append('!');
                b.Append(lookaheadId);
                b.Append(')');
                b.Append(" , ");
                break;
            case TermType.PLOOKBEHIND_IN:
                b.Append('(');
                b.Append("<=");
                b.Append(lookaheadId);
                b.Append(" , dist=");
                b.Append(distance);
                b.Append(" , ");
                break;
            case TermType.PLOOKBEHIND_OUT:
                b.Append("<=");
                b.Append(lookaheadId);
                b.Append(')');
                b.Append(" , ");
                break;
            case TermType.NLOOKBEHIND_IN:
                b.Append("(<!");
                b.Append(lookaheadId);
                b.Append(" , dist=");
                b.Append(distance);
                b.Append(" , ");
                if(failNext!=null){
                    b.Append(", =>");
                    b.Append(failNext.instanceNum);
                    b.Append(", ");
                }
                break;
            case TermType.NLOOKBEHIND_OUT:
                b.Append("<!");
                b.Append(lookaheadId);
                b.Append(')');
                b.Append(" , ");
                break;
            case TermType.MEMREG_CONDITION:
                b.Append("(reg");
                b.Append(memreg);
                b.Append("?)");
                if(failNext!=null){
                    b.Append(", =>");
                    b.Append(failNext.instanceNum);
                    b.Append(", ");
                }
                break;
            case TermType.LOOKAHEAD_CONDITION_IN:
                b.Append("(cond");
                b.Append(lookaheadId);
                b.Append(((Lookahead)this).isPositive ? '=' : '!');
                b.Append(" , ");
                if(failNext!=null){
                    b.Append(", =>");
                    b.Append(failNext.instanceNum);
                    b.Append(", ");
                }
                break;
            case TermType.LOOKAHEAD_CONDITION_OUT:
                b.Append("cond");
                b.Append(lookaheadId);
                b.Append(")");
                if(failNext!=null){
                    b.Append(", =>");
                    b.Append(failNext.instanceNum);
                    b.Append(", ");
                }
                break;
            case TermType.REG:
                b.Append("$");
                b.Append(memreg);
                b.Append(", ");
                break;
            case TermType.SUCCESS:
                b.Append("END");
                break;
            case TermType.BRANCH_STORE_CNT_AUX1:
                b.Append("(aux1)");
                b.Append("(cnt)");
                b.Append("=>");
                if(failNext!=null) b.Append(failNext.instanceNum);
                else b.Append("null");
                b.Append(" , ");
                break;
            case TermType.BRANCH_STORE_CNT:
                b.Append("(cnt)");
                b.Append("=>");
                if(failNext!=null) b.Append(failNext.instanceNum);
                else b.Append("null");
                b.Append(" , ");
                break;
            case TermType.BRANCH:
                b.Append("=>");
                if(failNext!=null) b.Append(failNext.instanceNum);
                else b.Append("null");
                b.Append(" , ");
                break;
            default:
                b.Append('[');
                switch(type){
                case TermType.CNT_SET_0:
                    b.Append("cnt=0");
                    break;
                case TermType.CNT_INC:
                    b.Append("cnt++");
                    break;
                case TermType.CNT_GT_EQ:
                    b.Append("cnt>="+maxCount);
                    break;
                case TermType.READ_CNT_LT:
                    b.Append("->cnt<"+maxCount);
                    break;
                case TermType.CRSTORE_CRINC:
                    b.Append("M("+memreg+")->,Cr("+cntreg+")->,Cr("+cntreg+")++");
                    break;
                case TermType.CR_SET_0:
                    b.Append("Cr("+cntreg+")=0");
                    break;
                case TermType.CR_LT:
                    b.Append("Cr("+cntreg+")<"+maxCount);
                    break;
                case TermType.CR_GT_EQ:
                    b.Append("Cr("+cntreg+")>="+maxCount);
                    break;
                default:
                    b.Append("unknown type: "+type);
                    break;
                }
                b.Append("] , ");
                break;
            }
            if(next!=null){
                b.Append("->");
                b.Append(next.instanceNum);
                b.Append(", ");
            }
            //b.Append("\r\n");
            return b.ToString();
        }
   
        public string ToStringAll(){
            return ToStringAll(new List<int>());
        }
   
        public string ToStringAll(IList<int> v){
            v.Add(instanceNum);
            string s = ToString();
            if(next!=null){
                if(!v.Contains(next.instanceNum)) {
                    s += "\r\n";
                    s += next.ToStringAll(v);
                }
            }
            if(failNext!=null){
                if(!v.Contains(failNext.instanceNum)){
                    s += "\r\n";
                    s += failNext.ToStringAll(v);
                }
            }
            return s;
        }
    }

    internal class Pretokenizer {
        const int START = 1;
        internal const int END = 2;
        internal const int PLAIN_GROUP = 3;
        internal const int POS_LOOKAHEAD = 4;
        internal const int NEG_LOOKAHEAD = 5;
        internal const int POS_LOOKBEHIND = 6;
        internal const int NEG_LOOKBEHIND = 7;
        internal const int INDEPENDENT_REGEX = 8;
        internal const int COMMENT = 9;
        internal const int CONDITIONAL_GROUP = 10;
        internal const int FLAGS = 11;
        internal const int CLASS_GROUP = 12;
        internal const int NAMED_GROUP = 13;
   
        internal int tOffset,tOutside,skip;
        internal int offset,end;
   
        internal int ttype=START;
   
        internal char[] data;
   
        //results
        internal REFlags flags;
        internal bool flagsChanged;
   
        internal string groupName;
        internal bool groupDeclared;
   
        internal Pretokenizer(char[] data, int offset, int end) {
            if(offset<0 || end>data.Length) throw new IndexOutOfRangeException("offset="+offset+", end="+end+", length="+data.Length);
            this.offset=offset;
            this.end=end;

            this.tOffset=offset;
            this.tOutside=offset;

            this.data=data;
        }
   
        internal REFlags Flags(REFlags def) {
            return flagsChanged ? flags : def;
        }
   
        internal void Next() {
            int tOffset=this.tOutside;
            int skip=this.skip;
      
            tOffset+=skip;
            flagsChanged=false;
      
            int end=this.end; 
            char[] data=this.data; 
            bool esc=false;
            for(int i=tOffset;i<end;i++){
                if(esc){
                    esc=false;
                    continue;
                }
                char c=data[i];
                switch(c){
                case '\\':
                    esc=true;
                    continue;
                case '|':
                case ')':
                    ttype=c;
                    this.tOffset=tOffset;
                    this.tOutside=i;
                    this.skip=1;
                    return;
                case '(':
                    if(((i+2)<end) && (data[i+1]=='?')){
                        char c1=data[i+2];
                        switch(c1){
                        case ':':
                            ttype=PLAIN_GROUP;
                            skip=3; // "(?:" - skip 3 chars
                            break;
                        case '=':
                            ttype=POS_LOOKAHEAD;
                            skip=3;  // "(?="
                            break;
                        case '!':
                            ttype=NEG_LOOKAHEAD;
                            skip=3;  // "(?!"
                            break;
                        case '<':
                            switch(c1=data[i+3]){
                            case '=':
                                ttype=POS_LOOKBEHIND;
                                skip=4; // "(?<="
                                break;
                            case '!':
                                ttype=NEG_LOOKBEHIND;
                                skip=4; // "(?<!"
                                break;
                            default:
                                throw new PatternSyntaxException("invalid character after '(?<' : "+c1);
                            }
                            break;
                        case '>':
                            ttype=INDEPENDENT_REGEX;
                            skip=3;  // "(?>"
                            break;
                        case '#':
                            ttype=COMMENT;
                            skip=3; // ="(?#".length, the makeTree() skips the rest by itself
                            break;
                        case '(':
                            ttype=CONDITIONAL_GROUP;
                            skip=2; //"(?"+"(..." - skip "(?" (2 chars) and parse condition as a group
                            break;
                        case '[':
                            ttype=CLASS_GROUP;
                            skip=2; // "(?"+"[..]+...-...&...)" - skip 2 chars and parse a class group
                            break;
                        default:
                            int mOff,mLen;
                            bool breakmloop = false;
                            for(int p=i+2;!breakmloop && p<end;p++){
                                char c2=data[p];
                                switch(c2){
                                case '-':
                                case 'i':
                                case 'm':
                                case 's':
                                case 'x':
                                case 'u':
                                case 'X':
                                    continue; // mloop
                                case ':':
                                    mOff=i+2;
                                    mLen=p-mOff;
                                    if(mLen>0){
                                        flags=Pattern.ParseFlags(data,mOff,mLen);
                                        flagsChanged=true;
                                    }
                                    ttype=PLAIN_GROUP;
                                    skip=mLen+3; // "(?imsx:" mLen=4; skip= "(?".len + ":".len + mLen = 2+1+4=7
                                    breakmloop = true;
                                    break;
                                case ')':
                                    flags=Pattern.ParseFlags(data,mOff=(i+2),mLen=(p-mOff));
                                    flagsChanged=true;
                                    ttype=FLAGS;
                                    skip=mLen+3; // "(?imsx)" mLen=4, skip="(?".len+")".len+mLen=2+1+4=7
                                    breakmloop = true;
                                    break;
                                default:
                                    throw new PatternSyntaxException("wrong char after \"(?\": "+c2);
                                }
                            }
                            break;
                        }
                    }
                    else if(((i+2)<end) && (data[i+1]=='{')){ //parse named group: ({name}....),({=name}....)
                        int p=i+2;
                        skip=3; //'({' + '}'
                        int nstart,nend;
                        bool isDecl;
                        c=data[p];
                        while(char.IsWhiteSpace(c)){
                            c=data[++p];
                            skip++;
                            if(p==end) throw new PatternSyntaxException("malformed named group");
                        }
                 
                        if(c=='='){
                            isDecl=false;
                            c=data[++p];
                            skip++;
                            if(p==end) throw new PatternSyntaxException("malformed named group");
                        } else isDecl=true;
                 
                        nstart=p;
                        while(char.IsLetterOrDigit(c)){
                            c=data[++p];
                            skip++;
                            if(p==end) throw new PatternSyntaxException("malformed named group");
                        }
                        nend=p;
                        while(char.IsWhiteSpace(c)){
                            c=data[++p];
                            skip++;
                            if(p==end) throw new PatternSyntaxException("malformed named group");
                        }
                        if(c!='}') throw new PatternSyntaxException("'}' expected at "+(p-i)+" in " + new string(data,i,end-i));
                 
                        this.groupName = new string(data,nstart,nend-nstart);
                        this.groupDeclared = isDecl;
                        ttype = NAMED_GROUP;
                    } else {
                        ttype='(';
                        skip=1;
                    }
                    this.tOffset=tOffset;
                    this.tOutside=i;
                    this.skip=skip;
                    return;
                case '[':
                    bool continueLoop = true;
                    for(;continueLoop;i++){
                        if(i==end) throw new PatternSyntaxException("malformed character class");
                        char c1=data[i];
                        switch(c1){
                        case '\\':
                            i++;
                            continue;
                        case ']':
                            continueLoop = false;
                            break;
                        }
                    }
                    break;
                }
            }
            ttype=END;
            this.tOffset=tOffset;
            this.tOutside=end;
        }
    }


    internal class Branch : Term {
        internal Branch() {
            type = TermType.BRANCH;
        }

        internal Branch(TermType type) {
            switch(type){
            case TermType.BRANCH:
            case TermType.BRANCH_STORE_CNT:
            case TermType.BRANCH_STORE_CNT_AUX1:
                this.type=type;
                break;
            default:
                throw new ArgumentException("not a branch type: "+type);
            }
        }
    }

    internal class BackReference : Term {
        internal BackReference(int no, bool icase) : base(icase ? TermType.REG_I : TermType.REG) {
            memreg=no;
        }
    }

    internal class Group : Term {
        internal Group() : this(0) {}
   
        internal Group(int memreg) {
            type = TermType.GROUP_IN;
            this.memreg = memreg;
      
            current = null;
            _in = this;
            prev = null;
      
            _out = new Term();
            _out.type = TermType.GROUP_OUT;
            _out.memreg = memreg;
        }
    }

    internal class ConditionalExpr : Group {
        protected Term node;
        protected bool newBranchStarted = false;
        protected bool linkAsBranch = true;
   
        internal ConditionalExpr(Lookahead la) : base(0) {
            la._in.type = TermType.LOOKAHEAD_CONDITION_IN;
            la._out.type = TermType.LOOKAHEAD_CONDITION_OUT;
            if(la.isPositive) {
                node = la._in;
                linkAsBranch = true;
                node.failNext = _out;
            } else {
                node = la._out;
                linkAsBranch = false;
                node.next = _out;
            }

            la.prev = _in;
            _in.next = la;
      
            current=la;
        }
   
        internal ConditionalExpr(Lookbehind lb) : base(0) {
            lb._in.type = TermType.LOOKBEHIND_CONDITION_IN;
            lb._out.type = TermType.LOOKBEHIND_CONDITION_OUT;
            if(lb.isPositive) {
                node = lb._in;
                linkAsBranch = true;
         
                node.failNext = _out;
            } else {
                node = lb._out;
                linkAsBranch = false;
         
                node.next = _out;
            }
      
            lb.prev = _in;
            _in.next = lb;
      
            current = lb;
        }
   
        internal ConditionalExpr(int memreg) : base(0) {
            Term condition = new Term(TermType.MEMREG_CONDITION);
            condition.memreg = memreg;
            condition._out = condition;
            condition.out1 = null;
            condition.branchOut = null;
      
            //default branch
            condition.failNext = _out;
      
            node = current = condition;
            linkAsBranch = true;
      
            condition.prev = _in;
            _in.next = condition;
      
            current = condition;
        }
   
        protected override void StartNewBranch() {
            if(newBranchStarted) throw new PatternSyntaxException("attempt to set a 3'd choice in a conditional expr.");
            Term node = this.node;
            node.out1 = null;
            if(linkAsBranch){
                node._out = null;
                node.branchOut = node;
            } else {
                node._out = node;
                node.branchOut = null;
            }
            newBranchStarted = true;
            current = node;
        }
    }

    internal class IndependentGroup : Term {
        internal IndependentGroup(int id) : base(TermType.CHAR) {
            _in = this;
            _out = new Term();
            type = TermType.INDEPENDENT_IN;
            _out.type = TermType.INDEPENDENT_OUT;
            lookaheadId = _out.lookaheadId=id;
        }
    }

    internal class Lookahead : Term {
        internal readonly bool isPositive;
   
        internal Lookahead(int id, bool isPositive) {
            this.isPositive = isPositive;
            _in = this;
            _out = new Term();
            if(isPositive) {
                type = TermType.PLOOKAHEAD_IN;
                _out.type = TermType.PLOOKAHEAD_OUT;
            } else {
                type = TermType.NLOOKAHEAD_IN;
                _out.type = TermType.NLOOKAHEAD_OUT;
                branchOut = this; 
            }
            lookaheadId = id;
            _out.lookaheadId = id;
        }
    }

    internal class Lookbehind : Term {
        internal readonly bool isPositive;
        int prevDistance = -1;
   
        internal Lookbehind(int id, bool isPositive){
            distance = 0;
            this.isPositive = isPositive;
            _in = this;
            _out = new Term();
            if(isPositive) {
                type = TermType.PLOOKBEHIND_IN;
                _out.type = TermType.PLOOKBEHIND_OUT;
            } else {
                type = TermType.NLOOKBEHIND_IN;
                _out.type = TermType.NLOOKBEHIND_OUT;
                branchOut = this; 
            }
            lookaheadId = id;
            _out.lookaheadId = id;
        }
   
        protected override Term Append(Term t) {
            distance += Length(t);
            return base.Append(t);
        }
   
        protected override Term ReplaceCurrent(Term t) {
            distance += (Length(t) - Length(current));
            return base.ReplaceCurrent(t);
        }
   
        private static int Length(Term t) {
            TermType type = t.type;
            switch(type) {
            case TermType.CHAR:
            case TermType.BITSET:
            case TermType.BITSET2:
            case TermType.ANY_CHAR:
            case TermType.ANY_CHAR_NE:
                return 1;
            case TermType.BOUNDARY: case TermType.DIRECTION: case TermType.UBOUNDARY: case TermType.UDIRECTION:
            case TermType.GROUP_IN: case TermType.GROUP_OUT: case TermType.VOID: case TermType.START: case TermType.END:
            case TermType.END_EOL: case TermType.LINE_START: case TermType.LINE_END: case TermType.LAST_MATCH_END:
            case TermType.CNT_SET_0: case TermType.CNT_INC: case TermType.CNT_GT_EQ: case TermType.READ_CNT_LT:
            case TermType.CRSTORE_CRINC: case TermType.CR_SET_0: case TermType.CR_LT: case TermType.CR_GT_EQ:
                return 0;
            default:
                throw new PatternSyntaxException("variable length element within a lookbehind assertion");
            }
        }
   
        protected override void StartNewBranch() {
            prevDistance = distance;
            distance = 0;
            base.StartNewBranch();
        }
   
        protected override void Close() {
            int pd = prevDistance;
            if(pd>=0) {
                if(distance!=pd) throw new PatternSyntaxException("non-equal branch lengths within a lookbehind assertion");
            }
            base.Close();
        }
    }

    internal class Iterator : Term {
        internal Iterator(Term term, int min, int max, IList<Iterator> collection) {
            collection.Add(this);
            switch(term.type){
            case TermType.CHAR:
            case TermType.ANY_CHAR:
            case TermType.ANY_CHAR_NE:
            case TermType.BITSET:
            case TermType.BITSET2:{
                target = term;
                Term back = new Term();
                if(min<=0 && max<0) {
                    type = TermType.REPEAT_0_INF;
                    back.type = TermType.BACKTRACK_0;
                } else if(min>0 && max<0) {
                    type = TermType.REPEAT_MIN_INF;
                    back.type = TermType.BACKTRACK_MIN;
                    minCount = back.minCount = min;
                } else {
                    type = TermType.REPEAT_MIN_MAX;
                    back.type = TermType.BACKTRACK_MIN;
                    minCount = back.minCount = min;
                    maxCount = max;
                }
            
                failNext = back;
            
                _in = this;
                _out = this;
                out1 = back;
                branchOut = null;   
                return;
            }
            case TermType.REG:{
                target = term;
                memreg = term.memreg;
                Term back = new Term();
                if(max<0) {
                    type = TermType.REPEAT_REG_MIN_INF;
                    back.type = TermType.BACKTRACK_REG_MIN;
                    minCount = back.minCount = min;
                } else {
                    type = TermType.REPEAT_REG_MIN_MAX;
                    back.type = TermType.BACKTRACK_REG_MIN;
                    minCount = back.minCount = min;
                    maxCount = max;
                }
            
                failNext = back;
            
                _in = this;
                _out = this;
                out1 = back;
                branchOut = null;   
                return; 
            }
            default:
                throw new PatternSyntaxException("can't iterate this type: "+term.type);
            }
        }
   
        internal void Optimize() {
            Term back = failNext;
            Optimizer opt = Optimizer.Find(back.next);
            if(opt==null) return;
            failNext = opt.MakeBacktrack(back);
        }
    }
}
