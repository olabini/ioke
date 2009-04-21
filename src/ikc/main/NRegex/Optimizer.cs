namespace NRegex {
    public class Optimizer {
        public const int THRESHOLD=20;
   
        internal static Optimizer Find(Term entry){
            return Find(entry,0);
        }
   
        private static Optimizer Find(Term term, int dist) {
            if(term==null) return null;
            Term next=term.next;
            Term.TermType type=term.type;
            switch(type){
            case Term.TermType.CHAR:
            case Term.TermType.REG:
            case Term.TermType.REG_I:
                return new Optimizer(term,dist);
            case Term.TermType.BITSET:
            case Term.TermType.BITSET2:
                if(term.weight<=THRESHOLD) return new Optimizer(term,dist);
                else return Find(term.next,dist+1);
            case Term.TermType.ANY_CHAR:
            case Term.TermType.ANY_CHAR_NE:
                return Find(next,dist+1);
            case Term.TermType.REPEAT_MIN_INF:
            case Term.TermType.REPEAT_MIN_MAX:
                if(term.minCount>0){
                    return Find(term.target,dist);
                }
                else return null;
            case Term.TermType.BOUNDARY: case Term.TermType.DIRECTION: case Term.TermType.UBOUNDARY: case Term.TermType.UDIRECTION:
            case Term.TermType.GROUP_IN: case Term.TermType.GROUP_OUT: case Term.TermType.VOID: case Term.TermType.START: case Term.TermType.END:
            case Term.TermType.END_EOL: case Term.TermType.LINE_START: case Term.TermType.LINE_END: case Term.TermType.LAST_MATCH_END:
            case Term.TermType.CNT_SET_0: case Term.TermType.CNT_INC: case Term.TermType.CNT_GT_EQ: case Term.TermType.READ_CNT_LT:
            case Term.TermType.CRSTORE_CRINC: case Term.TermType.CR_SET_0: case Term.TermType.CR_LT: case Term.TermType.CR_GT_EQ:
                return Find(next,dist);
            }
            return null;
        }
   
        private Term atom;
        private int distance;
   
        private Optimizer(Term atom, int distance) {
            this.atom=atom;
            this.distance=distance;
        }
   
        internal Term MakeFirst(Term theFirst){
            return new Find(atom,distance,theFirst);
        }
   
        internal Term MakeBacktrack(Term back){
            int min=back.minCount;
            switch(back.type){
            case Term.TermType.BACKTRACK_0:
                min=0;
                return new FindBack(atom,distance,min,back);
            case Term.TermType.BACKTRACK_MIN:
                return new FindBack(atom,distance,min,back);
         
            case Term.TermType.BACKTRACK_REG_MIN:
                return back;
         
            default:
                throw new System.Exception("unexpected iterator's backtracker:"+ back);
            }
        }
    }

    internal class Find : Term {
        internal Find(Term target, int distance, Term theFirst) {
            switch(target.type){
            case TermType.CHAR:
            case TermType.BITSET:
            case TermType.BITSET2:
                type=TermType.FIND;
                break;
            case TermType.REG:
            case TermType.REG_I:
                type=TermType.FINDREG;
                break;
            default:
                throw new System.ArgumentException("wrong target type: "+target.type);
            }
            this.target=target;
            this.distance=distance;
            if(target==theFirst) {
                next=target.next;
                eat=true; //eat the next
            } else {
                next=theFirst;
                eat=false;
            }
        }
    }

    internal class FindBack : Term {
        internal FindBack(Term target, int distance, int minCount, Term backtrack) {
            this.minCount=minCount;
            switch(target.type){
            case TermType.CHAR:
            case TermType.BITSET:
            case TermType.BITSET2:
                type=TermType.BACKTRACK_FIND_MIN;
                break;
            case TermType.REG:
            case TermType.REG_I:
                type=TermType.BACKTRACK_FINDREG_MIN;
                break;
            default:
                throw new System.ArgumentException("wrong target type: "+target.type);
            }
      
            this.target=target;
            this.distance=distance;
            Term next=backtrack.next;
            if(target==next){
                this.next=next.next;
                this.eat=true;
            } else {
                this.next=next;
                this.eat=false;
            }
        }
    }
}
