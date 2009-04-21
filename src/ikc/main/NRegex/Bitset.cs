namespace NRegex {
    using System;
    using System.Text;

    internal class Bitset : UnicodeConstants {
        private static readonly Block[][] categoryBits = new Block[CATEGORY_COUNT][];
        static Bitset() {
            for(int i = 0; i < categoryBits.Length; i++) categoryBits[i] = new Block[BLOCK_COUNT];
            for(int i=char.MinValue;i<=char.MaxValue;i++){
                int cat=(int)char.GetUnicodeCategory((char)i);
                int blockNo=(i>>8)&0xff;
                Block b=categoryBits[cat][blockNo];
                if(b==null) categoryBits[cat][blockNo] = b = new Block();
                b.Set(i&0xff);
            }
        }
   
        private bool positive=true;
        private bool isLarge=false;
   
        internal bool[] block0;  //1-byte bit set
        private static readonly bool[] emptyBlock0 = new bool[BLOCK_SIZE];
   
        internal Block[] blocks;  //2-byte bit set
   
        private int weight;
   
        internal void Reset(){
            positive=true;
            block0=null;
            blocks=null;
            isLarge=false;
            weight=0;
        }
   
        internal static void Unify(Bitset bs, Term term){
            if(bs.isLarge){
                term.type = Term.TermType.BITSET2;
                term.bitset2 = Block.ToBitset2(bs.blocks);
            }
            else{
                term.type = Term.TermType.BITSET;
                term.bitset = bs.block0 == null ? emptyBlock0 : bs.block0;
            }
            term.inverse = !bs.positive;
            term.weight = bs.positive ? bs.weight : MAX_WEIGHT-bs.weight;
        }

        internal void SetPositive(bool b){
            positive=b;
        }
   
        internal bool IsPositive(){
            return positive;
        }
   
        internal bool IsLarge(){
            return isLarge;
        }
   
        private void EnableLargeMode(){
            if(isLarge) return;
            Block[] blocks = new Block[BLOCK_COUNT];
            this.blocks = blocks;
            if(block0 != null) {
                blocks[0] = new Block(block0);
            }
            isLarge = true;
        }
   
        internal int GetWeight(){
            return positive ? weight : MAX_WEIGHT-weight;
        }
   
        internal void SetWordChar(bool unicode){
            if(unicode){
                SetCategory(Lu);
                SetCategory(Ll);
                SetCategory(Lt);
                SetCategory(Lo);
                SetCategory(Nd);
                SetChar('_');
            } else {
                SetRange('a','z');
                SetRange('A','Z');
                SetRange('0','9');
                SetChar('_');
            }
        }
   
        internal void SetDigit(bool unicode){
            if(unicode) {
                SetCategory(Nd);
            } else {
                SetRange('0','9');
            }
        }
   
        internal void SetSpace(bool unicode){
            if(unicode){
                SetCategory(Zs);
                SetCategory(Zp);
                SetCategory(Zl);
            } else {
                SetChar(' ');
                SetChar('\r');
                SetChar('\n');
                SetChar('\t');
                SetChar('\f');
            }
        }
   
        internal void SetCategory(int c){
            if(!isLarge) EnableLargeMode();
            Block[] catBits = categoryBits[c];
            weight += Block.Add(this.blocks,catBits,0,BLOCK_COUNT-1,false);
        }
   
        internal void SetChars(string chars){
            for(int i=chars.Length-1;i>=0;i--) SetChar(chars[i]);
        }
   
        internal void SetChar(char c){
            SetRange(c,c);
        }
   
        internal void SetRange(char c1, char c2){
            if(c2>=256 || isLarge){
                int s=0;
                if(!isLarge){
                    EnableLargeMode();
                }
                Block[] blocks = this.blocks;
                for(int c=c1;c<=c2;c++){
                    int i2=(c>>8)&0xff;
                    int i=c&0xff;
                    Block block = blocks[i2];
                    if(block == null){
                        blocks[i2] = block =new Block();
                    }
                    if(block.Set(i)) s++;
                }
                weight+=s;
            } else {
                bool[] block0 = this.block0;
                if(block0 == null){
                    this.block0 = block0 = new bool[BLOCK_SIZE];
                }
                weight += Set(block0,true,c1,c2);
            }
        }
   
        internal void Add(Bitset bs){
            Add(bs,false);
        }
   
        internal void Add(Bitset bs, bool inverse){
            weight += AddImpl(this,bs,!bs.positive^inverse);
        }
   
        private static int AddImpl(Bitset bs1, Bitset bs2, bool inv){
            int s=0;
            if(!bs1.isLarge && !bs2.isLarge && !inv){
                if(bs2.block0!=null){
                    bool[] bits = bs1.block0;
                    if(bits==null) bs1.block0 = bits = new bool[BLOCK_SIZE];
                    s += Add(bits,bs2.block0,0,BLOCK_SIZE-1,false);
                }
            }
            else {
                if(!bs1.isLarge) bs1.EnableLargeMode();
                if(!bs2.isLarge) bs2.EnableLargeMode();
                s+=Block.Add(bs1.blocks,bs2.blocks,0,BLOCK_COUNT-1,inv);
            }
            return s;
        }
   
        internal void Subtract(Bitset bs){
            Subtract(bs,false);
        }
   
        internal void Subtract(Bitset bs, bool inverse){
            weight += SubtractImpl(this, bs, !bs.positive^inverse);
        }
   
        private static int SubtractImpl(Bitset bs1, Bitset bs2, bool inv){
            int s=0;
            if(!bs1.isLarge && !bs2.isLarge && !inv){
                bool[] bits1,bits2;
                if((bits2=bs2.block0)!=null){
                    bits1=bs1.block0;
                    if(bits1==null) return 0;
                    s += Subtract(bits1,bits2,0,BLOCK_SIZE-1,false);
                }
            }
            else {
                if(!bs1.isLarge) bs1.EnableLargeMode();
                if(!bs2.isLarge) bs2.EnableLargeMode();
                s += Block.Subtract(bs1.blocks,bs2.blocks,0,BLOCK_COUNT-1,inv);
            }
            return s;
        }
   
        internal void Intersect(Bitset bs){
            Intersect(bs,false);
        }
   
        internal void Intersect(Bitset bs, bool inverse){
            Subtract(bs,!inverse);
        }
   
        internal static int Add(bool[] bs1, bool[] bs2, int from, int to, bool inv){
            int s=0;
            for(int i=from;i<=to;i++){
                if(bs1[i]) continue;
                if(!(bs2[i]^inv)) continue;
                s++;
                bs1[i]=true;
            }
            return s;
        }
   
        static internal int Subtract(bool[] bs1, bool[] bs2, int from, int to, bool inv){
            int s=0;
            for(int i=from;i<=to;i++){
                if(!bs1[i]) continue;
                if(!(bs2[i]^inv)) continue;
                s--;
                bs1[i]=false;
            }
            return s;
        }
   
        internal static int Set(bool[] arr, bool value, int from, int to){
            int s=0;
            for(int i=from;i<=to;i++){
                if(arr[i]==value) continue;
                if(value) s++; else s--;
                arr[i]=value;
            }
            return s;
        }
   
        public override string ToString() {
            StringBuilder sb=new StringBuilder();
            if(!positive) sb.Append('^');
      
            if(isLarge) sb.Append(CharacterClass.StringValue2(Block.ToBitset2(blocks)));
            else if(block0!=null) sb.Append(CharacterClass.StringValue0(block0));
      
            sb.Append('(');
            sb.Append(GetWeight());
            sb.Append(')');
            return sb.ToString();
        }
    }

    internal class Block : UnicodeConstants {
        private bool isFull;
        internal bool[] bits;
        private bool shared=false;
   
        internal Block(){}
   
        internal Block(bool[] bits){
            this.bits=bits;
            shared=true;
        }
   
        internal bool Set(int c){
            if(isFull) return false;
            bool[] bits=this.bits;
            if(bits==null){
                this.bits=bits=new bool[BLOCK_SIZE];
                shared=false;
                bits[c]=true;
                return true;
            }
      
            if(bits[c]) return false;
      
            if(shared) bits=CopyBits(this);
      
            bits[c]=true;
            return true;
        }
   
        internal bool Get(int c){
            if(isFull) return true;
            bool[] bits=this.bits;
            if(bits==null){
                return false;
            }
            return bits[c];
        }
   
        internal static int Add(Block[] targets, Block[] addends, int from, int to, bool inv){
            int s=0;
            for(int i=from;i<=to;i++){
                Block addend=addends[i];
                if(addend==null){ 
                    if(!inv) continue;
                }
                else if(addend.isFull && inv) continue;
         
                Block target=targets[i];
                if(target==null) targets[i]=target=new Block();
                else if(target.isFull) continue;
         
                s+=Add(target,addend,inv);
            }
            return s;
        }
   
        private static int Add(Block target, Block addend, bool inv){
            bool[] targetbits,addbits;
            if(addend==null){
                if(!inv) return 0;
                int s=BLOCK_SIZE;
                if((targetbits=target.bits)!=null){
                    s -= Count(targetbits,0,BLOCK_SIZE-1);
                }
                target.isFull=true;
                target.bits=null;
                target.shared=false;
                return s;
            }
            else if(addend.isFull){
                if(inv) return 0;
                int s=BLOCK_SIZE;
                if((targetbits=target.bits)!=null){
                    s -= Count(targetbits,0,BLOCK_SIZE-1);
                }
                target.isFull=true;
                target.bits=null;
                target.shared=false;
                return s;
            }
            else if((addbits=addend.bits)==null){
                if(!inv) return 0;
                int s=BLOCK_SIZE;
                if((targetbits=target.bits)!=null){
                    s -= Count(targetbits,0,BLOCK_SIZE-1);
                }
                target.isFull=true;
                target.bits=null;
                target.shared=false;
                return s;
            }
            else{
                if((targetbits=target.bits)==null){
                    if(!inv){
                        target.bits=addbits;
                        target.shared=true;
                        return Count(addbits,0,BLOCK_SIZE-1);
                    }
                    else{
                        target.bits=targetbits=EmptyBits(null);
                        target.shared=false;
                        return Bitset.Add(targetbits,addbits,0,BLOCK_SIZE-1,inv);
                    }
                }
                else{
                    if(target.shared) targetbits=CopyBits(target);
                    return Bitset.Add(targetbits,addbits,0,BLOCK_SIZE-1,inv);
                }
            }
        }
   
        internal static int Subtract(Block[] targets,Block[] subtrahends,int from,int to,bool inv){
            int s=0;
            for(int i=from;i<=to;i++){
                Block target=targets[i];
                if(target==null || (!target.isFull && target.bits==null)) continue;
                Block subtrahend=subtrahends[i];
                if(subtrahend==null){
                    if(!inv) continue;
                    else{
                        if(target.isFull){
                            s-=BLOCK_SIZE;
                        }
                        else{
                            s-=Count(target.bits,0,BLOCK_SIZE-1);
                        }
                        target.isFull=false;
                        target.bits=null;
                        target.shared=false;
                    }
                }
                else{
                    s+=Subtract(target,subtrahend,inv);
                }
            }
            return s;
        }
   
        private static int Subtract(Block target, Block subtrahend, bool inv){
            bool[] targetbits,subbits;
            if(subtrahend.isFull){
                if(inv) return 0;
                int s=0;
                if(target.isFull){
                    s=BLOCK_SIZE;
                }
                else{
                    s=Count(target.bits,0,BLOCK_SIZE-1);
                }
                target.isFull=false;
                target.bits=null;
                target.shared=false;
                return s;
            }
            else if((subbits=subtrahend.bits)==null){
                if(!inv) return 0;
                int s=0;
                if(target.isFull){
                    s=BLOCK_SIZE;
                }
                else{
                    s=Count(target.bits,0,BLOCK_SIZE-1);
                }
                target.isFull=false;
                target.bits=null;
                target.shared=false;
                return s;
            }
            else{
                if(target.isFull){
                    bool[] bits=FullBits(target.bits);
                    int s=Bitset.Subtract(bits,subbits,0,BLOCK_SIZE-1,inv);
                    target.isFull=false;
                    target.shared=false;
                    target.bits=bits;
                    return s;
                }
                else{
                    if(target.shared) targetbits=CopyBits(target);
                    else targetbits=target.bits;
                    return Bitset.Subtract(targetbits,subbits,0,BLOCK_SIZE-1,inv);
                }
            }
        }
   
        private static bool[] CopyBits(Block block){
            bool[] bits = new bool[BLOCK_SIZE];
            Array.Copy(block.bits,bits,BLOCK_SIZE);
            block.bits=bits;
            block.shared=false;
            return bits;
        }
   
        private static bool[] FullBits(bool[] bits){
            if(bits==null) bits=new bool[BLOCK_SIZE];
            Array.Copy(FULL_BITS,bits,BLOCK_SIZE);
            return bits;
        }
   
        private static bool[] EmptyBits(bool[] bits){
            if(bits==null) bits=new bool[BLOCK_SIZE];
            else Array.Copy(EMPTY_BITS,bits,BLOCK_SIZE);
            return bits;
        }
   
        internal static int Count(bool[] arr, int from, int to){
            int s=0;
            for(int i=from;i<=to;i++){
                if(arr[i]) s++;
            }
            return s;
        }
   
        internal static bool[][] ToBitset2(Block[] blocks){
            int len=blocks.Length;
            bool[][] result=new bool[len][];
            for(int i=0;i<len;i++){
                Block block=blocks[i];
                if(block==null) continue;
                if(block.isFull){
                    result[i]=FULL_BITS;
                }
                else result[i]=block.bits;
            }
            return result;
        }
   
        private readonly static bool[] EMPTY_BITS=new bool[BLOCK_SIZE];
        private readonly static bool[] FULL_BITS=new bool[BLOCK_SIZE];
        static Block() {
            for(int i=0;i<BLOCK_SIZE;i++) FULL_BITS[i]=true;
        }
    }
}
