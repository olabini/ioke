
namespace Ioke.Math {
    public sealed class MathContext {
        public const int PLAIN=0; // [no exponent]
        public const int SCIENTIFIC=1; // 1 digit before .
        public const int ENGINEERING=2; // 1-3 digits before .
        public const int ROUND_CEILING=2;
        public const int ROUND_DOWN=1;
        public const int ROUND_FLOOR=3;
        public const int ROUND_HALF_DOWN=5;
        public const int ROUND_HALF_EVEN=6;
        public const int ROUND_HALF_UP=4;
        public const int ROUND_UNNECESSARY=7;
        public const int ROUND_UP=0;
        internal int digits;
        internal int form; // values for this must fit in a byte
        internal bool lostDigits;
        internal int roundingMode;
 
        private const int DEFAULT_FORM=SCIENTIFIC;
        private const int DEFAULT_DIGITS=9;
        private const bool DEFAULT_LOSTDIGITS=false;
        private const int DEFAULT_ROUNDINGMODE=ROUND_HALF_UP;
 
        private const int MIN_DIGITS=0;
        private const int MAX_DIGITS=999999999;
        private static readonly int[] ROUNDS=new int[]{ROUND_HALF_UP,ROUND_UNNECESSARY,ROUND_CEILING,ROUND_DOWN,ROUND_FLOOR,ROUND_HALF_DOWN,ROUND_HALF_EVEN,ROUND_UP};

        private static readonly string[] ROUNDWORDS = new string[] {"ROUND_HALF_UP","ROUND_UNNECESSARY","ROUND_CEILING","ROUND_DOWN","ROUND_FLOOR","ROUND_HALF_DOWN","ROUND_HALF_EVEN","ROUND_UP"};
        public static readonly MathContext DEFAULT = new MathContext(DEFAULT_DIGITS,DEFAULT_FORM,DEFAULT_LOSTDIGITS,DEFAULT_ROUNDINGMODE);
        public static readonly MathContext DECIMAL128 = new MathContext(34, DEFAULT_FORM, DEFAULT_LOSTDIGITS, ROUND_HALF_EVEN);

        public MathContext(int setdigits) : this(setdigits,DEFAULT_FORM,DEFAULT_LOSTDIGITS,DEFAULT_ROUNDINGMODE) {}
        public MathContext(int setdigits, int setform) : this(setdigits,setform,DEFAULT_LOSTDIGITS,DEFAULT_ROUNDINGMODE) {}
        public MathContext(int setdigits, int setform, bool setlostdigits) : this(setdigits,setform,setlostdigits,DEFAULT_ROUNDINGMODE) {}
        public MathContext(int setdigits, int setform, bool setlostdigits, int setroundingmode) {
            if (setdigits!=DEFAULT_DIGITS) 
                {
                    if (setdigits<MIN_DIGITS) 
                        throw new System.ArgumentException("Digits too small:"+" "+setdigits);
                    if (setdigits>MAX_DIGITS) 
                        throw new System.ArgumentException("Digits too large:"+" "+setdigits);
                }
            {
                if (setform==SCIENTIFIC){
                    // [most common]
                }else if (setform==ENGINEERING){
                }else if (setform==PLAIN){
                }else{
                    throw new System.ArgumentException("Bad form value:"+" "+setform);
                }
            }
            if ((!(isValidRound(setroundingmode)))) 
                throw new System.ArgumentException("Bad roundingMode value:"+" "+setroundingmode);
            digits=setdigits;
            form=setform;
            lostDigits=setlostdigits; // [no bad value possible]
            roundingMode=setroundingmode;
        }

        public int getDigits(){
            return digits;
        }
 
        public int getForm(){
            return form;
        }

        public bool getLostDigits(){
            return lostDigits;
        }
 
        public int getRoundingMode(){
            return roundingMode;
        }

        public override string ToString() {
            string formstr=null;
            int r=0;
            string roundword=null;
            {/*select*/
                if (form==SCIENTIFIC)
                    formstr="SCIENTIFIC";
                else if (form==ENGINEERING)
                    formstr="ENGINEERING";
                else{
                    formstr="PLAIN";/* form=PLAIN */
                }
            }
            for(int i = ROUNDS.Length; i>0; i--, r++) {
                if(roundingMode == ROUNDS[r]) {
                    roundword = ROUNDWORDS[r];
                    break;
                }
            }
            return "digits="+digits+" "+"form="+formstr+" "+"lostDigits="+(lostDigits?"1":"0")+" "+"roundingMode="+roundword;
        }
 
        private static bool isValidRound(int testround){
            for(int i = ROUNDS.Length, r=0; i>0; i--, r++) {
                if(testround == ROUNDS[r]) {
                    return true;
                }
            }
            return false;
        }
    }
}
