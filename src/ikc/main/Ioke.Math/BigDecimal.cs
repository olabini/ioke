
namespace Ioke.Math {
    using System;
    using System.Text;

    public class BigDecimal {
        public static readonly BigDecimal ZERO = new BigDecimal((long)0); // use long as we want the int constructor
        public static readonly BigDecimal ONE  = new BigDecimal((long)1); // use long as we want the int constructor
        public static readonly BigDecimal TEN  = new BigDecimal(10);

        public const int ROUND_CEILING=MathContext.ROUND_CEILING;
        public const int ROUND_DOWN=MathContext.ROUND_DOWN;
        public const int ROUND_FLOOR=MathContext.ROUND_FLOOR;
        public const int ROUND_HALF_DOWN=MathContext.ROUND_HALF_DOWN;
        public const int ROUND_HALF_EVEN=MathContext.ROUND_HALF_EVEN;
        public const int ROUND_HALF_UP=MathContext.ROUND_HALF_UP;
        public const int ROUND_UNNECESSARY=MathContext.ROUND_UNNECESSARY;
        public const int ROUND_UP=MathContext.ROUND_UP;
 
        private const sbyte ispos=1; // ind: indicates positive (must be 1)
        private const sbyte iszero=0; // ind: indicates zero     (must be 0)
        private const sbyte isneg=-1; // ind: indicates negative (must be -1)
 
        private const int MinExp=-999999999; // minimum exponent allowed
        private const int MaxExp=999999999; // maximum exponent allowed
        private const int MinArg=-999999999; // minimum argument integer
        private const int MaxArg=999999999; // maximum argument integer
 
        private static readonly MathContext plainMC = new MathContext(0,MathContext.PLAIN); // context for plain unlimited math

        private static sbyte[] bytecar=new sbyte[(90+99)+1]; // carry/borrow array
        private static sbyte[] bytedig=diginit(); // next digit array
        private sbyte ind; // assumed undefined
        private sbyte form=(sbyte)MathContext.PLAIN; // assumed PLAIN
        private sbyte[] mant; // assumed null
        private int exp;

        public BigDecimal(char[] inchars) : this(inchars,0,inchars.Length) {}

        public BigDecimal(char[] inchars,int offset,int length) {
            bool exotic;
            bool hadexp;
            int d;
            int dotoff;
            int last;
            char si=(char)0;
            bool eneg=false;
            int k=0;
            int elen=0;
            int j=0;
            char sj=(char)0;
            int dvalue=0;
            int mag=0;
            int i,ix;

            if (length<=0) 
                bad(inchars); // bad conversion (empty string)
            // [bad offset will raise array bounds exception]
  
            /* Handle and step past sign */
            ind=ispos; // assume positive
            if (inchars[offset]==('-')) 
                {
                    length--;
                    if (length==0) 
                        bad(inchars); // nothing after sign
                    ind=isneg;
                    offset++;
                }
            else 
                if (inchars[offset]==('+')) 
                    {
                        length--;
                        if (length==0) 
                            bad(inchars); // nothing after sign
                        offset++;
                    }
  
            /* We're at the start of the number */
            exotic=false; // have extra digits
            hadexp=false; // had explicit exponent
            d=0; // count of digits found
            dotoff=-1; // offset where dot was found
            last=-1; // last character of mantissa
            for(ix = length, i=offset;ix>0;ix--,i++) {
                si=inchars[i];
                if (si>='0')  // test for Arabic digit
                    if (si<='9') 
                        {
                            last=i;
                            d++; // still in mantissa
                            continue;
                        }
                if (si=='.') 
                    { // record and ignore
                        if (dotoff>=0) 
                            bad(inchars); // two dots
                        dotoff=i-offset; // offset into mantissa
                        continue;
                    }
                if (si!='e') 
                    if (si!='E') 
                        { // expect an extra digit
                            if ((!(char.IsDigit(si)))) 
                                bad(inchars); // not a number
                            // defer the base 10 check until later to avoid extra method call
                            exotic=true; // will need conversion later
                            last=i;
                            d++; // still in mantissa
                            continue;
                        }
                /* Found 'e' or 'E' -- now process explicit exponent */
                // 1998.07.11: sign no longer required
                if ((i-offset)>(length-2)) 
                    bad(inchars); // no room for even one digit
                eneg=false;
                if ((inchars[i+1])==('-')) 
                    {
                        eneg=true;
                        k=i+2;
                    }
                else 
                    if ((inchars[i+1])==('+')) 
                        k=i+2;
                    else 
                        k=i+1;
                // k is offset of first expected digit
                elen=length-((k-offset)); // possible number of digits
                if ((elen==0)|(elen>9)) 
                    bad(inchars); // 0 or more than 9 digits
                for(ix=elen,j=k;ix>0;ix--,j++){
                    sj=inchars[j];
                    if (sj<'0') 
                        bad(inchars); // always bad
                    if (sj>'9') 
                        { // maybe an exotic digit
                            if ((!(char.IsDigit(sj)))) 
                                bad(inchars); // not a number
                            dvalue=IntNum.digitForChar(sj,10); // check base
                            if (dvalue<0) 
                                bad(inchars); // not base 10
                        }
                    else 
                        dvalue=((int)(sj))-((int)('0'));
                    exp=(exp*10)+dvalue;
                }
                if (eneg) 
                    exp=(int)-exp; // was negative
                hadexp=true; // remember we had one
                break; // we are done
            }
  
            /* Here when all inspected */
            if (d==0) 
                bad(inchars); // no mantissa digits
            if (dotoff>=0) 
                exp=(exp+dotoff)-d; // adjust exponent if had dot
  
            /* strip leading zeros/dot (leave final if all 0's) */
            for(ix=last-1,i=offset;i<=ix;i++) {
                si=inchars[i];
                if (si=='0') 
                    {
                        offset++;
                        dotoff--;
                        d--;
                    }
                else 
                    if (si=='.') 
                        {
                            offset++; // step past dot
                            dotoff--;
                        }
                    else 
                        if (si<='9') 
                            break;/* non-0 */
                        else 
                            {/* exotic */
                                if ((IntNum.digitForChar(si,10))!=0) 
                                    break; // non-0 or bad
                                // is 0 .. strip like '0'
                                offset++;
                                dotoff--;
                                d--;
                            }
            }
  
            /* Create the mantissa array */
            mant=new sbyte[d]; // we know the length
            j=offset; // input offset
            if (exotic) 
                for(ix=d, i=0;ix>0;ix--,i++){
                    if (i==dotoff) 
                        j++; // at dot
                    sj=inchars[j];
                    if (sj<='9') 
                        mant[i]=(sbyte)(((int)(sj))-((int)('0')));/* easy */
                    else 
                        {
                            dvalue=IntNum.digitForChar(sj,10);
                            if (dvalue<0) 
                                bad(inchars); // not a number after all
                            mant[i]=(sbyte)dvalue;
                        }
                    j++;
                }
            else 
                for(ix=d,i=0;ix>0;ix--,i++){
                    if (i==dotoff) 
                        j++;
                    mant[i]=(sbyte)(((int)(inchars[j]))-((int)('0')));
                    j++;
                }
            if (mant[0]==0) 
                {
                    ind=iszero; // force to show zero
                    // negative exponent is significant (e.g., -3 for 0.000) if plain
                    if (exp>0) 
                        exp=0; // positive exponent can be ignored
                    if (hadexp) 
                        { // zero becomes single digit from add
                            mant=ZERO.mant;
                            exp=0;
                        }
                }
            else 
                { // non-zero
                    // [ind was set earlier]
                    // now determine form
                    if (hadexp) 
                        {
                            form=(sbyte)MathContext.SCIENTIFIC;
                            // 1999.06.29 check for overflow
                            mag=(exp+mant.Length)-1; // true exponent in scientific notation
                            if ((mag<MinExp)|(mag>MaxExp)) 
                                bad(inchars);
                        }
                }
            // say 'BD(c[]): mant[0] mantlen exp ind form:' mant[0] mant.Length exp ind form
            return;
        }

        public BigDecimal(int num){
            int mun;
            int i=0;
            // We fastpath commoners
            if (num<=9) 
                if (num>=(-9)) {
                    // very common single digit case
                    if (num==0)
                        {
                            mant=ZERO.mant;
                            ind=iszero;
                        }
                    else if (num==1)
                        {
                            mant=ONE.mant;
                            ind=ispos;
                        }
                    else if (num==(-1))
                        {
                            mant=ONE.mant;
                            ind=isneg;
                        }
                    else{
                        {
                            mant=new sbyte[1];
                            if (num>0) 
                                {
                                    mant[0]=(sbyte)num;
                                    ind=ispos;
                                }
                            else 
                                { // num<-1
                                    mant[0]=(sbyte)((int)-num);
                                    ind=isneg;
                                }
                        }
                    }
                    return;
                }
  
            /* We work on negative numbers so we handle the most negative number */
            if (num>0) 
                {
                    ind=ispos;
                    num=(int)-num;
                }
            else 
                ind=isneg;/* negative */ // [0 case already handled]
            // [it is quicker, here, to pre-calculate the length with
            // one loop, then allocate exactly the right length of sbyte array,
            // then re-fill it with another loop]
            mun=num; // working copy
            for(i=9;;i--){
                mun=mun/10;
                if (mun==0) 
                    break;
            }
            // i is the position of the leftmost digit placed
            mant=new sbyte[10-i];
            for(i=(10-i)-1;;i--){
                mant[i]=(sbyte)-(((sbyte)(num%10)));
                num=num/10;
                if (num==0) 
                    break;
            }
            return;
        }
 
        public BigDecimal(long num){
            long mun;
            int i=0;
            if (num>0) 
                {
                    ind=ispos;
                    num=(long)-num;
                }
            else 
                if (num==0) 
                    ind=iszero;
                else 
                    ind=isneg;/* negative */
            mun=num;
            for(i=18;;i--){
                mun=mun/10;
                if (mun==0) 
                    break;
            }
            // i is the position of the leftmost digit placed
            mant=new sbyte[19-i];
            for(i=(19-i)-1;;i--){
                mant[i]=(sbyte)-(((sbyte)(num%10)));
                num=num/10;
                if (num==0) 
                    break;
            }
            return;
        }
 
        public BigDecimal(string str) : this(str.ToCharArray(),0,str.Length) {}
        private BigDecimal(){
            return;
        }

        public BigDecimal abs(){
            return this.abs(plainMC);
        }

        public BigDecimal abs(MathContext set){
            if (this.ind==isneg) 
                return this.negate(set);
            return this.plus(set);
        }

        public BigDecimal add(BigDecimal rhs){
            return this.add(rhs,plainMC);
        }

        public BigDecimal add(BigDecimal rhs,MathContext set){
            BigDecimal lhs;
            int reqdig;
            BigDecimal res;
            sbyte[] usel;
            int usellen;
            sbyte[] user;
            int userlen;
            int newlen=0;
            int tlen=0;
            int mult=0;
            sbyte[] t=null;
            int ia=0;
            int ib=0;
            int ea=0;
            int eb=0;
            sbyte ca=0;
            sbyte cb=0;
            /* determine requested digits and form */
            if (set.lostDigits) 
                checkdigits(rhs,set.digits);
            lhs=this; // name for clarity and proxy
  
            /* Quick exit for add floating 0 */
            // plus() will optimize to return same object if possible
            if (lhs.ind==0) 
                if (set.form!=MathContext.PLAIN) 
                    return rhs.plus(set);
            if (rhs.ind==0) 
                if (set.form!=MathContext.PLAIN) 
                    return lhs.plus(set);
  
            /* Prepare numbers (round, unless unlimited precision) */
            reqdig=set.digits; // local copy (heavily used)
            if (reqdig>0) 
                {
                    if (lhs.mant.Length>reqdig) 
                        lhs=clone(lhs).round(set);
                    if (rhs.mant.Length>reqdig) 
                        rhs=clone(rhs).round(set);
                    // [we could reuse the new LHS for result in this case]
                }
  
            res=new BigDecimal(); // build result here
  
            /* Now see how much we have to pad or truncate lhs or rhs in order
               to align the numbers.  If one number is much larger than the
               other, then the smaller cannot affect the answer [but we may
               still need to pad with up to DIGITS trailing zeros]. */
            // Note sign may be 0 if digits (reqdig) is 0
            // usel and user will be the sbyte arrays passed to the adder; we'll
            // use them on all paths except quick exits
            usel=lhs.mant;
            usellen=lhs.mant.Length;
            user=rhs.mant;
            userlen=rhs.mant.Length;
                    if (lhs.exp==rhs.exp)
                        {/* no padding needed */
                            // This is the most common, and fastest, path
                            res.exp=lhs.exp;
                        }
                    else if (lhs.exp>rhs.exp)
                        { // need to pad lhs and/or truncate rhs
                            newlen=(usellen+lhs.exp)-rhs.exp;
                            /* If, after pad, lhs would be longer than rhs by digits+1 or
                               more (and digits>0) then rhs cannot affect answer, so we only
                               need to pad up to a length of DIGITS+1. */
                            if (newlen>=((userlen+reqdig)+1)) 
                                if (reqdig>0) 
                                    {
                                        // LHS is sufficient
                                        res.mant=usel;
                                        res.exp=lhs.exp;
                                        res.ind=lhs.ind;
                                        if (usellen<reqdig) 
                                            { // need 0 padding
                                                res.mant=extend(lhs.mant,reqdig);
                                                res.exp=res.exp-((reqdig-usellen));
                                            }
                                        return res.finish(set,false);
                                    }
                            // RHS may affect result
                            res.exp=rhs.exp; // expected final exponent
                            if (newlen>(reqdig+1)) 
                                if (reqdig>0) 
                                    {
                                        // LHS will be max; RHS truncated
                                        tlen=(newlen-reqdig)-1; // truncation length
                                        userlen=userlen-tlen;
                                        res.exp=res.exp+tlen;
                                        newlen=reqdig+1;
                                    }
                            if (newlen>usellen) 
                                usellen=newlen; // need to pad LHS
                        }
                    else{ // need to pad rhs and/or truncate lhs
                        newlen=(userlen+rhs.exp)-lhs.exp;
                        if (newlen>=((usellen+reqdig)+1)) 
                            if (reqdig>0) 
                                {
                                    // RHS is sufficient
                                    res.mant=user;
                                    res.exp=rhs.exp;
                                    res.ind=rhs.ind;
                                    if (userlen<reqdig) 
                                        { // need 0 padding
                                            res.mant=extend(rhs.mant,reqdig);
                                            res.exp=res.exp-((reqdig-userlen));
                                        }
                                    return res.finish(set,false);
                                }
                        // LHS may affect result
                        res.exp=lhs.exp; // expected final exponent
                        if (newlen>(reqdig+1)) 
                            if (reqdig>0) 
                                {
                                    // RHS will be max; LHS truncated
                                    tlen=(newlen-reqdig)-1; // truncation length
                                    usellen=usellen-tlen;
                                    res.exp=res.exp+tlen;
                                    newlen=reqdig+1;
                                }
                        if (newlen>userlen) 
                            userlen=newlen; // need to pad RHS
                    }
  
            if (lhs.ind==iszero) 
                res.ind=ispos;
            else 
                res.ind=lhs.ind; // likely sign, all paths
            if (((lhs.ind==isneg)?1:0)==((rhs.ind==isneg)?1:0))  // same sign, 0 non-negative
                mult=1;
            else {
                        mult=-1; // will cause subtract
                        /* Before we can subtract we must determine which is the larger,
                           as our add/subtract routine only handles non-negative results
                           so we may need to swap the operands. */

                                if (rhs.ind==iszero){
                                    // original A bigger
                                }else if ((usellen<userlen)|(lhs.ind==iszero))
                                    { // original B bigger
                                        t=usel;
                                        usel=user;
                                        user=t; // swap
                                        tlen=usellen;
                                        usellen=userlen;
                                        userlen=tlen; // ..
                                        res.ind=(sbyte)-res.ind; // and set sign
                                    }
                                else if (usellen>userlen){
                                    // original A bigger
                                }else{
                                    {/* logical lengths the same */ // need compare
                                        /* may still need to swap: compare the strings */
                                        ia=0;
                                        ib=0;
                                        ea=usel.Length-1;
                                        eb=user.Length-1;
                                        for(;;){
                                                if (ia<=ea) 
                                                    ca=usel[ia];
                                                else 
                                                    {
                                                        if (ib>eb) 
                                                            {/* identical */
                                                                if (set.form!=MathContext.PLAIN) 
                                                                    return ZERO;
                                                                // [if PLAIN we must do the subtract, in case of 0.000 results]
                                                                break;
                                                            }
                                                        ca=(sbyte)0;
                                                    }
                                                if (ib<=eb) 
                                                    cb=user[ib];
                                                else 
                                                    cb=(sbyte)0;
                                                if (ca!=cb) 
                                                    {
                                                        if (ca<cb) 
                                                            {/* swap needed */
                                                                t=usel;
                                                                usel=user;
                                                                user=t; // swap
                                                                tlen=usellen;
                                                                usellen=userlen;
                                                                userlen=tlen; // ..
                                                                res.ind=(sbyte)-res.ind;
                                                            }
                                                        break;
                                                    }
                                                /* mantissas the same, so far */
                                                ia++;
                                                ib++;
                                            }
                                    } // lengths the same
                                }
            }  
            res.mant=byteaddsub(usel,usellen,user,userlen,mult,false);
            return res.finish(set,false);
        }

        public int CompareTo(BigDecimal rhs){
            return this.CompareTo(rhs,plainMC);
        }

        public int CompareTo(BigDecimal rhs,MathContext set){
            int thislength=0;
            int i=0;
            int ix=0;
            BigDecimal newrhs;
            // rhs=null will raise NullPointerException, as per Comparable interface
            if (set.lostDigits) 
                checkdigits(rhs,set.digits);
            // [add will recheck in slowpath cases .. but would report -rhs]
            if ((this.ind==rhs.ind)&(this.exp==rhs.exp)) 
                {
                    /* sign & exponent the same [very common] */
                    thislength=this.mant.Length;
                    if (thislength<rhs.mant.Length) 
                        return (sbyte)-this.ind;
                    if (thislength>rhs.mant.Length) 
                        return this.ind;
                    /* lengths are the same; we can do a straight mantissa compare
                       unless maybe rounding [rounding is very unusual] */
                    if ((thislength<=set.digits)|(set.digits==0)) 
                        {
                            for(ix=thislength,i=0;ix>0;ix--,i++){
                                    if (this.mant[i]<rhs.mant[i]) 
                                        return (sbyte)-this.ind;
                                    if (this.mant[i]>rhs.mant[i]) 
                                        return this.ind;
                                }
                            return 0; // identical
                        }
                    /* drop through for full comparison */
                }
            else 
                {
                    /* More fastpaths possible */
                    if (this.ind<rhs.ind) 
                        return -1;
                    if (this.ind>rhs.ind) 
                        return 1;
                }
            /* carry out a subtract to make the comparison */
            newrhs=clone(rhs); // safe copy
            newrhs.ind=(sbyte)-newrhs.ind; // prepare to subtract
            return this.add(newrhs,set).ind; // add, and return sign of result
        }

        public BigDecimal divide(BigDecimal rhs){
            return this.dodivide('D',rhs,plainMC,-1);
        }

        public BigDecimal divide(BigDecimal rhs,int round){
            MathContext set;
            set=new MathContext(0,MathContext.PLAIN,false,round); // [checks round, too]
            return this.dodivide('D',rhs,set,-1); // take scale from LHS
        }

        public BigDecimal divide(BigDecimal rhs,int scale,int round){
            MathContext set;
            if (scale<0) 
                throw new System.ArithmeticException("Negative scale:"+" "+scale);
            set=new MathContext(0,MathContext.PLAIN,false,round); // [checks round]
            return this.dodivide('D',rhs,set,scale);
        }

        public BigDecimal divide(BigDecimal rhs,MathContext set){
            return this.dodivide('D',rhs,set,-1);
        }

        public BigDecimal divideInteger(BigDecimal rhs){
            // scale 0 to drop .000 when plain
            return this.dodivide('I',rhs,plainMC,0);
        }

        public BigDecimal divideInteger(BigDecimal rhs,MathContext set){
            // scale 0 to drop .000 when plain
            return this.dodivide('I',rhs,set,0);
        }

        public BigDecimal max(BigDecimal rhs){
            return this.max(rhs,plainMC);
        }

        public BigDecimal max(BigDecimal rhs,MathContext set){
            if ((this.CompareTo(rhs,set))>=0) 
                return this.plus(set);
            else 
                return rhs.plus(set);
        }

        public BigDecimal min(BigDecimal rhs){
            return this.min(rhs,plainMC);
        }

        public BigDecimal min(BigDecimal rhs,MathContext set){
            if ((this.CompareTo(rhs,set))<=0) 
                return this.plus(set);
            else 
                return rhs.plus(set);
        }

        public BigDecimal multiply(BigDecimal rhs){
            return this.multiply(rhs,plainMC);
        }

        public BigDecimal multiply(BigDecimal rhs,MathContext set){
            BigDecimal lhs;
            int padding;
            int reqdig;
            sbyte[] multer=null;
            sbyte[] multand=null;
            int multandlen;
            int acclen=0;
            BigDecimal res;
            sbyte[] acc;
            int n=0;
            int ix;
            sbyte mult=0;
            if (set.lostDigits) 
                checkdigits(rhs,set.digits);
            lhs=this; // name for clarity and proxy
  
            /* Prepare numbers (truncate, unless unlimited precision) */
            padding=0; // trailing 0's to add
            reqdig=set.digits; // local copy
            if (reqdig>0) 
                {
                    if (lhs.mant.Length>reqdig) 
                        lhs=clone(lhs).round(set);
                    if (rhs.mant.Length>reqdig) 
                        rhs=clone(rhs).round(set);
                    // [we could reuse the new LHS for result in this case]
                }
            else 
                {/* unlimited */
                    // fixed point arithmetic will want every trailing 0; we add these
                    // after the calculation rather than before, for speed.
                    if (lhs.exp>0) 
                        padding=padding+lhs.exp;
                    if (rhs.exp>0) 
                        padding=padding+rhs.exp;
                }
  
            // For best speed, as in DMSRCN, we use the shorter number as the
            // multiplier and the longer as the multiplicand.
            // 1999.12.22: We used to special case when the result would fit in
            //             a long, but with Java 1.3 this gave no advantage.
            if (lhs.mant.Length<rhs.mant.Length) 
                {
                    multer=lhs.mant;
                    multand=rhs.mant;
                }
            else 
                {
                    multer=rhs.mant;
                    multand=lhs.mant;
                }
  
            /* Calculate how long result sbyte array will be */
            multandlen=(multer.Length+multand.Length)-1; // effective length
            // optimize for 75% of the cases where a carry is expected...
            if ((multer[0]*multand[0])>9) 
                acclen=multandlen+1;
            else 
                acclen=multandlen;
  
            /* Now the main long multiplication loop */
            res=new BigDecimal(); // where we'll build result
            acc=new sbyte[acclen]; // accumulator, all zeros
            for(ix=multer.Length,n=0;ix>0;ix--,n++){
                    mult=multer[n];
                    if (mult!=0) 
                        { // [optimization]
                            // accumulate [accumulator is reusable array]
                            acc=byteaddsub(acc,acc.Length,multand,multandlen,mult,true);
                        }
                    // divide multiplicand by 10 for next digit to right
                    multandlen--; // 'virtual length'
                }
  
            res.ind=(sbyte)(lhs.ind*rhs.ind); // final sign
            res.exp=(lhs.exp+rhs.exp)-padding; // final exponent
            // [overflow is checked by finish]
  
            /* add trailing zeros to the result, if necessary */
            if (padding==0) 
                res.mant=acc;
            else 
                res.mant=extend(acc,acc.Length+padding); // add trailing 0s
            return res.finish(set,false);
        }

        public BigDecimal negate(){
            return this.negate(plainMC);
        }

        public BigDecimal negate(MathContext set){
            BigDecimal res;
            if (set.lostDigits) 
                checkdigits((BigDecimal)null,set.digits);
            res=clone(this); // safe copy
            res.ind=(sbyte)-res.ind;
            return res.finish(set,false);
        }
 
        public BigDecimal plus(){
            return this.plus(plainMC);
        }
 
        public BigDecimal plus(MathContext set){
            // This clones and forces the result to the new settings
            // May return same object
            if (set.lostDigits) 
                checkdigits((BigDecimal)null,set.digits);
            // Optimization: returns same object for some common cases
            if (set.form==MathContext.PLAIN) 
                if (this.form==MathContext.PLAIN) 
                    {
                        if (this.mant.Length<=set.digits) 
                            return this;
                        if (set.digits==0) 
                            return this;
                    }
            return clone(this).finish(set,false);
        }

        public BigDecimal pow(BigDecimal rhs){
            return this.pow(rhs,plainMC);
        }
 
        public BigDecimal pow(BigDecimal rhs,MathContext set){
            int n;
            BigDecimal lhs;
            int reqdig;
            int workdigits=0;
            int L=0;
            MathContext workset;
            BigDecimal res;
            bool seenbit;
            int i=0;
            if (set.lostDigits) 
                checkdigits(rhs,set.digits);
            n=rhs.intcheck(MinArg,MaxArg); // check RHS by the rules
            lhs=this; // clarified name
  
            reqdig=set.digits; // local copy (heavily used)
            if (reqdig==0) 
                {
                    if (rhs.ind==isneg) 
                        throw new System.ArithmeticException("Negative power:"+" "+rhs.ToString());
                    workdigits=0;
                }
            else 
                {/* non-0 digits */
                    if ((rhs.mant.Length+rhs.exp)>reqdig) 
                        throw new System.ArithmeticException("Too many digits:"+" "+rhs.ToString());
    
                    /* Round the lhs to DIGITS if need be */
                    if (lhs.mant.Length>reqdig) 
                        lhs=clone(lhs).round(set);
    
                    /* L for precision calculation [see ANSI X3.274-1996] */
                    L=rhs.mant.Length+rhs.exp; // length without decimal zeros/exp
                    workdigits=(reqdig+L)+1; // calculate the working DIGITS
                }
  
            workset=new MathContext(workdigits,set.form,false,set.roundingMode);
  
            res=ONE; // accumulator
            if (n==0) 
                return res; // x**0 == 1
            if (n<0) 
                n=(int)-n; // [rhs.ind records the sign]
            seenbit=false; // set once we've seen a 1-bit
            for(i=1;;i++){ // for each bit [top bit ignored]
                    n=n+n; // shift left 1 bit
                    if (n<0) 
                        { // top bit is set
                            seenbit=true; // OK, we're off
                            res=res.multiply(lhs,workset); // acc=acc*x
                        }
                    if (i==31) 
                        break; // that was the last bit
                    if ((!seenbit)) 
                        continue; // we don't have to square 1
                    res=res.multiply(res,workset); // acc=acc*acc [square]
                }
            if (rhs.ind<0)  // was a **-n [hence digits>0]
                res=ONE.divide(res,workset); // .. so acc=1/acc
            return res.finish(set,true); // round and strip [original digits]
        }

        public BigDecimal remainder(BigDecimal rhs){
            return this.dodivide('R',rhs,plainMC,-1);
        }

        public BigDecimal remainder(BigDecimal rhs,MathContext set){
            return this.dodivide('R',rhs,set,-1);
        }

        public BigDecimal subtract(BigDecimal rhs){
            return this.subtract(rhs,plainMC);
        }
 
        public BigDecimal subtract(BigDecimal rhs,MathContext set){
            BigDecimal newrhs;
            if (set.lostDigits) 
                checkdigits(rhs,set.digits);
            // [add will recheck .. but would report -rhs]
            /* carry out the subtraction */
            // we could fastpath -0, but it is too rare.
            newrhs=clone(rhs); // safe copy
            newrhs.ind=(sbyte)-newrhs.ind; // prepare to subtract
            return this.add(newrhs,set); // arithmetic
        }
 
        public sbyte byteValueExact(){
            int num;
            num=this.intValueExact(); // will check decimal part too
            if ((num>127)|(num<(-128))) 
                throw new System.ArithmeticException("Conversion overflow:"+" "+this.ToString());
            return (sbyte)num;
        }
 
        public int CompareTo(object rhsobj){
            return CompareTo((BigDecimal)rhsobj,plainMC);
        }

        public double doubleValue(){
            return double.Parse(this.ToString());
        }

        public override bool Equals(object obj){
            BigDecimal rhs;
            int i=0;
            int ix=0;
            char[] lca=null;
            char[] rca=null;
            // We are equal iff ToString of both are exactly the same
            if (obj==null) 
                return false; // not equal
            if ((!(((obj is BigDecimal))))) 
                return false; // not a decimal
            rhs=(BigDecimal)obj; // cast; we know it will work
            if (this.ind!=rhs.ind) 
                return false; // different signs never match
            if (((this.mant.Length==rhs.mant.Length)&(this.exp==rhs.exp))&(this.form==rhs.form)) 
   
                { // mantissas say all
                    // here with equal-length sbyte arrays to compare
                    for(ix=this.mant.Length,i=0;ix>0;ix--,i++){
                            if (this.mant[i]!=rhs.mant[i]) 
                                return false;
                        }
                }
            else 
                { // need proper layout
                    lca=this.layout(); // layout to character array
                    rca=rhs.layout();
                    if (lca.Length!=rca.Length) 
                        return false; // mismatch
                    // here with equal-length character arrays to compare
                    for(ix=lca.Length,i=0;ix>0;ix--,i++){
                            if (lca[i]!=rca[i]) 
                                return false;
                        }
                }
            return true; // arrays have identical content
        }
 
        public float floatValue(){
            return float.Parse(this.ToString());
        }

        public string format(int before,int after){
            return format(before,after,-1,-1,MathContext.SCIENTIFIC,ROUND_HALF_UP);
        }

        public string format(int before,int after,int explaces,int exdigits,int exformint,int exround){
            BigDecimal num;
            int mag=0;
            int thisafter=0;
            int lead=0;
            sbyte[] newmant=null;
            int chop=0;
            int need=0;
            int oldexp=0;
            char[] a;
            int p=0;
            char[] newa=null;
            int i=0;
            int ix=0;
            int places=0;
  
  
            /* Check arguments */
            if ((before<(-1))|(before==0)) 
                badarg("format",1,System.Convert.ToString(before));
            if (after<(-1)) 
                badarg("format",2,System.Convert.ToString(after));
            if ((explaces<(-1))|(explaces==0)) 
                badarg("format",3,System.Convert.ToString(explaces));
            if (exdigits<(-1)) 
                badarg("format",4,System.Convert.ToString(explaces));
            {/*select*/
                if (exformint==MathContext.SCIENTIFIC){
                }else if (exformint==MathContext.ENGINEERING){
                }else if (exformint==(-1))
                    exformint=MathContext.SCIENTIFIC;
                // note PLAIN isn't allowed
                else{
                    badarg("format",5,System.Convert.ToString(exformint));
                }
            }
            // checking the rounding mode is done by trying to construct a
            // MathContext object with that mode; it will fail if bad
            if (exround!=ROUND_HALF_UP) 
                try{ // if non-default...
                        if (exround==(-1)) 
                            exround=ROUND_HALF_UP;
                        else 
                            new MathContext(9,MathContext.SCIENTIFIC,false,exround);
                    } catch(System.ArgumentException){
                        badarg("format",6,System.Convert.ToString(exround));
                    }
  
            num=clone(this); // make private copy
  
            /* determine form */
            {do{/*select*/
                    if (exdigits==(-1))
                        num.form=(sbyte)MathContext.PLAIN;
                    else if (num.ind==iszero)
                        num.form=(sbyte)MathContext.PLAIN;
                    else{
                        // determine whether triggers
                        mag=num.exp+num.mant.Length;
                        if (mag>exdigits) 
                            num.form=(sbyte)exformint;
                        else 
                            if (mag<(-5)) 
                                num.form=(sbyte)exformint;
                            else 
                                num.form=(sbyte)MathContext.PLAIN;
                    }
                }while(false);}/*setform*/
  
            /* If 'after' was specified then we may need to adjust the
               mantissa.  This is a little tricky, as we must conform to the
               rules of exponential layout if necessary (e.g., we cannot end up
               with 10.0 if scientific). */
            if (after>=0) 
                for(;;){
                        // calculate the current after-length
                        {/*select*/
                            if (num.form==MathContext.PLAIN)
                                thisafter=(int)-num.exp; // has decimal part
                            else if (num.form==MathContext.SCIENTIFIC)
                                thisafter=num.mant.Length-1;
                            else{ // engineering
                                lead=(((num.exp+num.mant.Length)-1))%3; // exponent to use
                                if (lead<0) 
                                    lead=3+lead; // negative exponent case
                                lead++; // number of leading digits
                                if (lead>=num.mant.Length) 
                                    thisafter=0;
                                else 
                                    thisafter=num.mant.Length-lead;
                            }
                        }
                        if (thisafter==after) 
                            break; // we're in luck
                        if (thisafter<after) 
                            { // need added trailing zeros
                                // [thisafter can be negative]
                                newmant=extend(num.mant,(num.mant.Length+after)-thisafter);
                                num.mant=newmant;
                                num.exp=num.exp-((after-thisafter)); // adjust exponent
                                if (num.exp<MinExp) 
                                    throw new System.ArithmeticException("Exponent Overflow:"+" "+num.exp);
                                break;
                            }
                        // We have too many digits after the decimal point; this could
                        // cause a carry, which could change the mantissa...
                        // Watch out for implied leading zeros in PLAIN case
                        chop=thisafter-after; // digits to lop [is >0]
                        if (chop>num.mant.Length) 
                            { // all digits go, no chance of carry
                                // carry on with zero
                                num.mant=ZERO.mant;
                                num.ind=iszero;
                                num.exp=0;
                                continue; // recheck: we may need trailing zeros
                            }
                        // we have a digit to inspect from existing mantissa
                        // round the number as required
                        need=num.mant.Length-chop; // digits to end up with [may be 0]
                        oldexp=num.exp; // save old exponent
                        num.round(need,exround);
                        // if the exponent grew by more than the digits we chopped, then
                        // we must have had a carry, so will need to recheck the layout
                        if ((num.exp-oldexp)==chop) 
                            break; // number did not have carry
                        // mantissa got extended .. so go around and check again
                    }
  
            a=num.layout(); // lay out, with exponent if required, etc.
  
            /* Here we have laid-out number in 'a' */
            // now apply 'before' and 'explaces' as needed
            if (before>0) 
                {
                    // look for '.' or 'E'
                    for(ix=a.Length,p=0;ix>0;ix--,p++){
                            if (a[p]=='.') 
                                break;
                            if (a[p]=='E') 
                                break;
                        }
                    // p is now offset of '.', 'E', or character after end of array
                    // that is, the current length of before part
                    if (p>before) 
                        badarg("format",1,System.Convert.ToString(before)); // won't fit
                    if (p<before) 
                        { // need leading blanks
                            newa=new char[(a.Length+before)-p];
                            for(ix=before-p,i=0;ix>0;ix--,i++){
                                    newa[i]=' ';
                                }
                            System.Array.Copy(a,0,newa,i,a.Length);
                            a=newa;
                        }
                    // [if p=before then it's just the right length]
                }
  
            if (explaces>0) 
                {
                    // look for 'E' [cannot be at offset 0]
                    for(ix=a.Length-1,p=ix;ix>0;ix--,p--){
                            if (a[p]=='E') 
                                break;
                        }
                    // p is now offset of 'E', or 0
                    if (p==0) 
                        { // no E part; add trailing blanks
                            newa=new char[(a.Length+explaces)+2];
                            System.Array.Copy(a,0,newa,0,a.Length);
                            for(ix=explaces+2,i=a.Length;ix>0;ix--,i++){
                                    newa[i]=' ';
                                }
                            a=newa;
                        }
                    else 
                        {/* found E */ // may need to insert zeros
                            places=(a.Length-p)-2; // number so far
                            if (places>explaces) 
                                badarg("format",3,System.Convert.ToString(explaces));
                            if (places<explaces) 
                                { // need to insert zeros
                                    newa=new char[(a.Length+explaces)-places];
                                    System.Array.Copy(a,0,newa,0,p+2);
                                    for(ix=explaces-places,i=p+2;ix>0;ix--,i++){
                                            newa[i]='0';
                                        }
                                    System.Array.Copy(a,p+2,newa,i,places);
                                    a=newa;
                                }
                            // [if places=explaces then it's just the right length]
                        }
                }
            return new string(a);
        }

        public override int GetHashCode() {
            return this.ToString().GetHashCode();
        }

        public int intValue(){
            return intValueExact();
        }

        public int intValueExact(){
            int lodigit;
            int useexp=0;
            int result;
            int i=0;
            int ix=0;
            int topdig=0;
            // This does not use longValueExact() as the latter can be much
            // slower.
            // intcheck (from pow) relies on this to check decimal part
            if (ind==iszero) 
                return 0; // easy, and quite common
            /* test and drop any trailing decimal part */
            lodigit=mant.Length-1;
            if (exp<0) 
                {
                    lodigit=lodigit+exp; // reduces by -(-exp)
                    /* all decimal places must be 0 */
                    if ((!(allzero(mant,lodigit+1)))) 
                        throw new System.ArithmeticException("Decimal part non-zero:"+" "+this.ToString());
                    if (lodigit<0) 
                        return 0; // -1<this<1
                    useexp=0;
                }
            else 
                {/* >=0 */
                    if ((exp+lodigit)>9)  // early exit
                        throw new System.ArithmeticException("Conversion overflow:"+" "+this.ToString());
                    useexp=exp;
                }
            /* convert the mantissa to binary, inline for speed */
            result=0;
            for(ix=lodigit+useexp,i=0;i<=ix;i++){
                    result=result*10;
                    if (i<=lodigit) 
                        result=result+mant[i];
                }
  
            /* Now, if the risky length, check for overflow */
            if ((lodigit+useexp)==9) 
                {
                    // note we cannot just test for -ve result, as overflow can move a
                    // zero into the top bit [consider 5555555555]
                    topdig=result/1000000000; // get top digit, preserving sign
                    if (topdig!=mant[0]) 
                        { // digit must match and be positive
                            // except in the special case ...
                            if (result==int.MinValue)  // looks like the special
                                if (ind==isneg)  // really was negative
                                    if (mant[0]==2) 
                                        return result; // really had top digit 2
                            throw new System.ArithmeticException("Conversion overflow:"+" "+this.ToString());
                        }
                }
  
            /* Looks good */
            if (ind==ispos) 
                return result;
            return (int)-result;
        }

        public long longValue(){
            return longValueExact();
        }

        public long longValueExact(){
            int lodigit;
            int cstart=0;
            int useexp=0;
            long result;
            int i=0;
            int ix=0;
            long topdig=0;
            // Identical to intValueExact except for result=long, and exp>=20 test
            if (ind==0) 
                return 0; // easy, and quite common
            lodigit=mant.Length-1; // last included digit
            if (exp<0) 
                {
                    lodigit=lodigit+exp; // -(-exp)
                    /* all decimal places must be 0 */
                    if (lodigit<0) 
                        cstart=0;
                    else 
                        cstart=lodigit+1;
                    if ((!(allzero(mant,cstart)))) 
                        throw new System.ArithmeticException("Decimal part non-zero:"+" "+this.ToString());
                    if (lodigit<0) 
                        return 0; // -1<this<1
                    useexp=0;
                }
            else 
                {/* >=0 */
                    if ((exp+mant.Length)>18)  // early exit
                        throw new System.ArithmeticException("Conversion overflow:"+" "+this.ToString());
                    useexp=exp;
                }
  
            /* convert the mantissa to binary, inline for speed */
            // note that we could safely use the 'test for wrap to negative'
            // algorithm here, but instead we parallel the intValueExact
            // algorithm for ease of checking and maintenance.
            result=(long)0;
            for(ix=lodigit+useexp,i=0;i<=ix;i++){
                    result=result*10;
                    if (i<=lodigit) 
                        result=result+mant[i];
                }
  
            /* Now, if the risky length, check for overflow */
            if ((lodigit+useexp)==18) 
                {
                    topdig=result/1000000000000000000L; // get top digit, preserving sign
                    if (topdig!=mant[0]) 
                        { // digit must match and be positive
                            // except in the special case ...
                            if (result==long.MinValue)  // looks like the special
                                if (ind==isneg)  // really was negative
                                    if (mant[0]==9) 
                                        return result; // really had top digit 9
                            throw new System.ArithmeticException("Conversion overflow:"+" "+this.ToString());
                        }
                }
  
            /* Looks good */
            if (ind==ispos) 
                return result;
            return (long)-result;
        }

        public BigDecimal movePointLeft(int n){
            BigDecimal res;
            // very little point in optimizing for shift of 0
            res=clone(this);
            res.exp=res.exp-n;
            return res.finish(plainMC,false); // finish sets form and checks exponent
        }

        public BigDecimal movePointRight(int n){
            BigDecimal res;
            res=clone(this);
            res.exp=res.exp+n;
            return res.finish(plainMC,false);
        }

        public int scale(){
            if (exp>=0) 
                return 0; // scale can never be negative
            return (int)-exp;
        }

        public BigDecimal setScale(int scale){
            return setScale(scale,ROUND_UNNECESSARY);
        }

        public BigDecimal setScale(int scale,int round){
            int ourscale;
            BigDecimal res;
            int padding=0;
            int newlen=0;
            // at present this naughtily only checks the round value if it is
            // needed (used), for speed
            ourscale=this.scale();
            if (ourscale==scale)  // already correct scale
                if (this.form==MathContext.PLAIN)  // .. and form
                    return this;
            res=clone(this); // need copy
            if (ourscale<=scale) 
                { // simply zero-padding/changing form
                    // if ourscale is 0 we may have lots of 0s to add
                    if (ourscale==0) 
                        padding=res.exp+scale;
                    else 
                        padding=scale-ourscale;
                    res.mant=extend(res.mant,res.mant.Length+padding);
                    res.exp=(int)-scale; // as requested
                }
            else 
                {/* ourscale>scale: shortening, probably */
                    if (scale<0) 
                        throw new System.ArithmeticException("Negative scale:"+" "+scale);
                    // [round() will raise exception if invalid round]
                    newlen=res.mant.Length-((ourscale-scale)); // [<=0 is OK]
                    res=res.round(newlen,round); // round to required length
                    // This could have shifted left if round (say) 0.9->1[.0]
                    // Repair if so by adding a zero and reducing exponent
                    if (res.exp!=((int)-scale)) 
                        {
                            res.mant=extend(res.mant,res.mant.Length+1);
                            res.exp=res.exp-1;
                        }
                }
            res.form=(sbyte)MathContext.PLAIN; // by definition
            return res;
        }

        public short shortValueExact(){
            int num;
            num=this.intValueExact(); // will check decimal part too
            if ((num>32767)|(num<(-32768))) 
                throw new System.ArithmeticException("Conversion overflow:"+" "+this.ToString());
            return (short)num;
        }
 
        public int signum(){
            return (int)this.ind; // [note this assumes values for ind.]
        }
 
        public char[] toCharArray(){
            return layout();
        }
 
        public override string ToString(){
            return new string(layout());
        }

        public string ToString(int form){
            return new string(layout(form));
        }

        public static BigDecimal valueOf(double dub){
            return new BigDecimal(System.Convert.ToString(dub));
        }

        public static BigDecimal valueOf(long lint){
            return valueOf(lint,0);
        }

        public static BigDecimal valueOf(long lint,int scale){
            BigDecimal res=null;
            {/*select*/
                if (lint==0)
                    res=ZERO;
                else if (lint==1)
                    res=ONE;
                else if (lint==10)
                    res=TEN;
                else{
                    res=new BigDecimal(lint);
                }
            }
            if (scale==0) 
                return res;
            if (scale<0) 
                throw new System.FormatException("Negative scale:"+" "+scale);
            res=clone(res); // safe copy [do not mutate]
            res.exp=(int)-scale; // exponent is -scale
            return res;
        }

        private char[] layout(){
            return this.layout(this.form);
        }

        private char[] layout(int form){
            char[] cmant;
            int i=0;
            int ix=0;
            StringBuilder sb=null;
            int euse=0;
            int sig=0;
            char csign=(char)0;
            char[] rec=null;
            int needsign;
            int mag;
            int len=0;
            cmant=new char[mant.Length]; // copy sbyte[] to a char[]
            for(ix=mant.Length,i=0;ix>0;ix--,i++){
                    cmant[i]=(char)(mant[i]+((int)('0')));
                }
  
            if (form!=MathContext.PLAIN) 
                {/* exponential notation needed */
                    sb=new StringBuilder(cmant.Length+15); // -x.xxxE+999999999
                    if (ind==isneg) 
                        sb.Append('-');
                    euse=(exp+cmant.Length)-1; // exponent to use
                    /* setup sig=significant digits and copy to result */
                    if (form==MathContext.SCIENTIFIC) 
                        { // [default]
                            sb.Append(cmant[0]); // significant character
                            if (cmant.Length>1)  // have decimal part
                                sb.Append('.').Append(cmant,1,cmant.Length-1);
                        }
                    else 
                        {do{
                                sig=euse%3; // common
                                if (sig<0) 
                                    sig=3+sig; // negative exponent
                                euse=euse-sig;
                                sig++;
                                if (sig>=cmant.Length) 
                                    { // zero padding may be needed
                                        sb.Append(cmant,0,cmant.Length);
                                        for(ix=sig-cmant.Length;ix>0;ix--){
                                                sb.Append('0');
                                            }
                                    }
                                else 
                                    { // decimal point needed
                                        sb.Append(cmant,0,sig).Append('.').Append(cmant,sig,cmant.Length-sig);
                                    }
                            }while(false);}/*engineering*/
                    if (euse!=0) 
                        {
                            if (euse<0) 
                                {
                                    csign='-';
                                    euse=(int)-euse;
                                }
                            else 
                                csign='+';
                            sb.Append('E').Append(csign).Append(euse);
                        }
                    rec=new char[sb.Length];
                    sb.CopyTo(0, rec, 0, sb.Length);
                    return rec;
                }
  
            /* Here for non-exponential (plain) notation */
            if (exp==0) 
                {/* easy */
                    if (ind>=0) 
                        return cmant; // non-negative integer
                    rec=new char[cmant.Length+1];
                    rec[0]='-';
                    
                    System.Array.Copy(cmant,0,rec,1,cmant.Length);
                    return rec;
                }
  
            /* Need a '.' and/or some zeros */
            needsign=(int)((ind==isneg)?1:0); // space for sign?  0 or 1
  
            /* MAG is the position of the point in the mantissa (index of the
               character it follows) */
            mag=exp+cmant.Length;
  
            if (mag<1) 
                {/* 0.00xxxx form */
                    len=(needsign+2)-exp; // needsign+2+(-mag)+cmant.Length
                    rec=new char[len];
                    if (needsign!=0) 
                        rec[0]='-';
                    rec[needsign]='0';
                    rec[needsign+1]='.';
                    for(ix=(int)-mag,i=needsign+2;ix>0;ix--,i++){ // maybe none
                            rec[i]='0';
                        }
                    System.Array.Copy(cmant,0,rec,(needsign+2)-mag,cmant.Length);
                    return rec;
                }
  
            if (mag>cmant.Length) 
                {/* xxxx0000 form */
                    len=needsign+mag+2;
                    rec=new char[len];
                    if (needsign!=0) 
                        rec[0]='-';
                    rec[needsign+mag] = '.';
                    rec[needsign+mag+1] = '0';
                    System.Array.Copy(cmant,0,rec,needsign,cmant.Length);
                    for(ix=mag-cmant.Length,i=needsign+cmant.Length;ix>0;ix--,i++){ // never 0
                            rec[i]='0';
                        }
                    return rec;
                }
  
            /* decimal point is in the middle of the mantissa */
            len=(needsign+1)+cmant.Length;
            rec=new char[len];
            if (needsign!=0) 
                rec[0]='-';
            System.Array.Copy(cmant,0,rec,needsign,mag);
            rec[needsign+mag]='.';
            System.Array.Copy(cmant,mag,rec,(needsign+mag)+1,cmant.Length-mag);
            return rec;
        }

        private int intcheck(int min,int max){
            int i;
            i=this.intValueExact(); // [checks for non-0 decimal part]
            // Use same message as though intValueExact failed due to size
            if ((i<min)|(i>max)) 
                throw new System.ArithmeticException("Conversion overflow:"+" "+i);
            return i;
        }
 
        private BigDecimal dodivide(char code,BigDecimal rhs,MathContext set,int scale){
            BigDecimal lhs;
            int reqdig;
            int newexp;
            BigDecimal res;
            int newlen;
            sbyte[] var1;
            int var1len;
            sbyte[] var2;
            int var2len;
            int b2b;
            int have;
            int thisdigit=0;
            int i=0;
            int ix=0;
            sbyte v2=0;
            int ba=0;
            int mult=0;
            int start=0;
            int padding=0;
            int d=0;
            sbyte[] newvar1=null;
            sbyte lasthave=0;
            int actdig=0;
            sbyte[] newmant=null;
  
            if (set.lostDigits) 
                checkdigits(rhs,set.digits);
            lhs=this; // name for clarity
  
            // [note we must have checked lostDigits before the following checks]
            if (rhs.ind==0) 
                throw new System.ArithmeticException("Divide by 0"); // includes 0/0
            if (lhs.ind==0) 
                { // 0/x => 0 [possibly with .0s]
                    if (set.form!=MathContext.PLAIN) 
                        return ZERO;
                    if (scale==(-1)) 
                        return lhs;
                    return lhs.setScale(scale);
                }
  
            /* Prepare numbers according to BigDecimal rules */
            reqdig=set.digits; // local copy (heavily used)
            if (reqdig>0) 
                {
                    if (lhs.mant.Length>reqdig) 
                        lhs=clone(lhs).round(set);
                    if (rhs.mant.Length>reqdig) 
                        rhs=clone(rhs).round(set);
                }
            else 
                {/* scaled divide */
                    if (scale==(-1)) 
                        scale=lhs.scale();
                    // set reqdig to be at least large enough for the computation
                    reqdig=lhs.mant.Length; // base length
                    // next line handles both positive lhs.exp and also scale mismatch
                    if (scale!=((int)-lhs.exp)) 
                        reqdig=(reqdig+scale)+lhs.exp;
                    reqdig=(reqdig-((rhs.mant.Length-1)))-rhs.exp; // reduce by RHS effect
                    if (reqdig<lhs.mant.Length) 
                        reqdig=lhs.mant.Length; // clamp
                    if (reqdig<rhs.mant.Length) 
                        reqdig=rhs.mant.Length; // ..
                }
  
            /* precalculate exponent */
            newexp=((lhs.exp-rhs.exp)+lhs.mant.Length)-rhs.mant.Length;
            /* If new exponent -ve, then some quick exits are possible */
            if (newexp<0) 
                if (code!='D') 
                    {
                        if (code=='I') 
                            return ZERO; // easy - no integer part
                        /* Must be 'R'; remainder is [finished clone of] input value */
                        return clone(lhs).finish(set,false);
                    }
  
            /* We need slow division */
            res=new BigDecimal(); // where we'll build result
            res.ind=(sbyte)(lhs.ind*rhs.ind); // final sign (for D/I)
            res.exp=newexp; // initial exponent (for D/I)
            res.mant=new sbyte[reqdig+1]; // where build the result
  
            /* Now [virtually pad the mantissae with trailing zeros */
            // Also copy the LHS, which will be our working array
            newlen=(reqdig+reqdig)+1;
            var1=extend(lhs.mant,newlen); // always makes longer, so new safe array
            var1len=newlen; // [remaining digits are 0]
  
            var2=rhs.mant;
            var2len=newlen;
  
            /* Calculate first two digits of rhs (var2), +1 for later estimations */
            b2b=(var2[0]*10)+1;
            if (var2.Length>1) 
                b2b=b2b+var2[1];
  
            /* start the long-division loops */
            have=0;
            {for(;;){
                    thisdigit=0;
                    /* find the next digit */
                    {inner:for(;;){
                            if (var1len<var2len) 
                                break; // V1 too low
                            if (var1len==var2len) 
                                { // compare needed
                                            for(ix=var1len,i=0;ix>0;ix--,i++){
                                                    // var1len is always <= var1.Length
                                                    if (i<var2.Length) 
                                                        v2=var2[i];
                                                    else 
                                                        v2=(sbyte)0;
                                                    if (var1[i]<v2) 
                                                        goto breakInner; // V1 too low
                                                    if (var1[i]>v2) 
                                                        goto breakCompare; // OK to subtract
                                                }
                                            /* reach here if lhs and rhs are identical; subtraction will
                                               increase digit by one, and the residue will be 0 so we
                                               are done; leave the loop with residue set to 0 (in case
                                               code is 'R' or ROUND_UNNECESSARY or a ROUND_HALF_xxxx is
                                               being checked) */
                                            thisdigit++;
                                            res.mant[have]=(sbyte)thisdigit;
                                            have++;
                                            var1[0]=(sbyte)0; // residue to 0 [this is all we'll test]
                                            // var1len=1      -- [optimized out]
                                            goto breakOuter;
                                    breakCompare:
                                    /* prepare for subtraction.  Estimate BA (lengths the same) */
                                    ba=(int)var1[0]; // use only first digit
                                } // lengths the same
                            else 
                                {/* lhs longer than rhs */
                                    /* use first two digits for estimate */
                                    ba=var1[0]*10;
                                    if (var1len>1) 
                                        ba=ba+var1[1];
                                }
                            /* subtraction needed; V1>=V2 */
                            mult=(ba*10)/b2b;
                            if (mult==0) 
                                mult=1;
                            thisdigit=thisdigit+mult;
                            // subtract; var1 reusable
                            var1=byteaddsub(var1,var1len,var2,var2len,(int)-mult,true);
                            if (var1[0]!=0) 
                                goto inner; // maybe another subtract needed
                            /* V1 now probably has leading zeros, remove leading 0's and try
                               again. (It could be longer than V2) */
                            for(ix=var1len-2,start=0;start<=ix;start++){
                                    if (var1[start]!=0) 
                                        break;
                                    var1len--;
                                }
                            if (start==0) 
                                goto inner;
                            // shift left
                            System.Array.Copy(var1,start,var1,0,var1len);
                        }
                    }/*inner*/
                    breakInner:
   
                    /* We have the next digit */
                    if ((have!=0)|(thisdigit!=0)) 
                        { // put the digit we got
                            res.mant[have]=(sbyte)thisdigit;
                            have++;
                            if (have==(reqdig+1)) 
                                goto breakOuter; // we have all we need
                            if (var1[0]==0) 
                                goto breakOuter; // residue now 0
                        }
                    /* can leave now if a scaled divide and exponent is small enough */
                    if (scale>=0) 
                        if (((int)-res.exp)>scale) 
                            goto breakOuter;
                    /* can leave now if not Divide and no integer part left  */
                    if (code!='D') 
                        if (res.exp<=0) 
                            goto breakOuter;
                    res.exp=res.exp-1; // reduce the exponent
                    /* to get here, V1 is less than V2, so divide V2 by 10 and go for
                       the next digit */
                    var2len--;
                }
            }/*outer*/
            breakOuter:
  
            /* here when we have finished dividing, for some reason */
            // have is the number of digits we collected in res.mant
            if (have==0) 
                have=1; // res.mant[0] is 0; we always want a digit
  
            if ((code=='I')|(code=='R')) 
                {/* check for integer overflow needed */
                    if ((have+res.exp)>reqdig) 
                        throw new System.ArithmeticException("Integer overflow");
    
                    if (code=='R') {
                                /* We were doing Remainder -- return the residue */
                                if (res.mant[0]==0)  // no integer part was found
                                    return clone(lhs).finish(set,false); // .. so return lhs, canonical
                                if (var1[0]==0) 
                                    return ZERO; // simple 0 residue
                                res.ind=lhs.ind; // sign is always as LHS
                                /* Calculate the exponent by subtracting the number of padding zeros
                                   we added and adding the original exponent */
                                padding=((reqdig+reqdig)+1)-lhs.mant.Length;
                                res.exp=(res.exp-padding)+lhs.exp;
      
                                /* strip insignificant padding zeros from residue, and create/copy
                                   the resulting mantissa if need be */
                                d=var1len;
                                for(i=d-1;i>=1;i--){if(!((res.exp<lhs.exp)&(res.exp<rhs.exp)))break;
                                        if (var1[i]!=0) 
                                            break;
                                        d--;
                                        res.exp=res.exp+1;
                                    }
                                if (d<var1.Length) 
                                    {/* need to reduce */
                                        newvar1=new sbyte[d];
                                        System.Array.Copy(var1,0,newvar1,0,d); // shorten
                                        var1=newvar1;
                                    }
                                res.mant=var1;
                                return res.finish(set,false);
                    }
                }
   
            else 
                {/* 'D' -- no overflow check needed */
                    // If there was a residue then bump the final digit (iff 0 or 5)
                    // so that the residue is visible for ROUND_UP, ROUND_HALF_xxx and
                    // ROUND_UNNECESSARY checks (etc.) later.
                    // [if we finished early, the residue will be 0]
                    if (var1[0]!=0) 
                        { // residue not 0
                            lasthave=res.mant[have-1];
                            if (((lasthave%5))==0) 
                                res.mant[have-1]=(sbyte)(lasthave+1);
                        }
                }
  
            /* Here for Divide or Integer Divide */
            // handle scaled results first ['I' always scale 0, optional for 'D']
            if (scale>=0) {
                        // say 'scale have res.exp len' scale have res.exp res.mant.Length
                        if (have!=res.mant.Length) 
                            // already padded with 0's, so just adjust exponent
                            res.exp=res.exp-((res.mant.Length-have));
                        // calculate number of digits we really want [may be 0]
                        actdig=res.mant.Length-((((int)-res.exp)-scale));
                        res.round(actdig,set.roundingMode); // round to desired length
                        // This could have shifted left if round (say) 0.9->1[.0]
                        // Repair if so by adding a zero and reducing exponent
                        if (res.exp!=((int)-scale)) 
                            {
                                res.mant=extend(res.mant,res.mant.Length+1);
                                res.exp=res.exp-1;
                            }
                        return res.finish(set,true); // [strip if not PLAIN]
            }
            // reach here only if a non-scaled
            if (have==res.mant.Length) 
                { // got digits+1 digits
                    res.round(set);
                    have=reqdig;
                }
            else 
                {/* have<=reqdig */
                    if (res.mant[0]==0) 
                        return ZERO; // fastpath
                    // make the mantissa truly just 'have' long
                    // [we could let finish do this, during strip, if we adjusted
                    // the exponent; however, truncation avoids the strip loop]
                    newmant=new sbyte[have]; // shorten
                    System.Array.Copy(res.mant,0,newmant,0,have);
                    res.mant=newmant;
                }
            return res.finish(set,true);
        }

        private void bad(char[] s){
            throw new System.FormatException("Not a number:"+" "+Convert.ToString(s));
        }

        private void badarg(string name,int pos,string value){
            throw new System.ArgumentException("Bad argument"+" "+pos+" "+"to"+" "+name+":"+" "+value);
        }
 
        private static sbyte[] extend(sbyte[] inarr,int newlen){
            sbyte[] newarr;
            if (inarr.Length==newlen) 
                return inarr;
            newarr=new sbyte[newlen];
            System.Array.Copy(inarr,0,newarr,0,inarr.Length);
            // 0 padding is carried out by the JVM on allocation initialization
            return newarr;
        }

        private static sbyte[] byteaddsub(sbyte[] a,int avlen,sbyte[] b,int bvlen,int m,bool reuse){            
            int alength;
            int blength;
            int ap;
            int bp;
            int maxarr;
            sbyte[] reb;
            bool quickm;
            int digit;
            int op=0;
            int dp90=0;
            sbyte[] newarr;
            int i=0;
            int ix=0;
  
  
  
            // We'll usually be right if we assume no carry
            alength=a.Length; // physical lengths
            blength=b.Length; // ..
            ap=avlen-1; // -> final (rightmost) digit
            bp=bvlen-1; // ..
            maxarr=bp;
            if (maxarr<ap) 
                maxarr=ap;
            reb=(sbyte[])null; // result sbyte array
            if (reuse) 
                if ((maxarr+1)==alength) 
                    reb=a; // OK to reuse A
            if (reb==null) 
                reb=new sbyte[maxarr+1]; // need new array
  
            quickm=false; // 1 if no multiply needed
            if (m==1) 
                quickm=true; // most common
            else 
                if (m==(-1)) 
                    quickm=true; // also common
  
            digit=0; // digit, with carry or borrow
            {op=maxarr;op:for(;op>=0;op--){
                    if (ap>=0) 
                        {
                            if (ap<alength) 
                                digit=digit+a[ap]; // within A
                            ap--;
                        }
                    if (bp>=0) 
                        {
                            if (bp<blength) 
                                { // within B
                                    if (quickm) 
                                        {
                                            if (m>0) 
                                                digit=digit+b[bp]; // most common
                                            else 
                                                digit=digit-b[bp]; // also common
                                        }
                                    else 
                                        digit=digit+(b[bp]*m);
                                }
                            bp--;
                        }
                    /* result so far (digit) could be -90 through 99 */
                    if (digit<10) 
                        if (digit>=0) {
                                    reb[op]=(sbyte)digit;
                                    digit=0; // no carry
                                    op--;
                                    goto op;
                        }
                    dp90=digit+90;
                    reb[op]=bytedig[dp90]; // this digit
                    digit=bytecar[dp90]; // carry or borrow
                }
            }/*op*/
  
            if (digit==0) 
                return reb; // no carry
            // following line will become an Assert, later
            // if digit<0 then signal ArithmeticException("internal.error ["digit"]")
  
            /* We have carry -- need to make space for the extra digit */
            newarr=(sbyte[])null;
            if (reuse) 
                if ((maxarr+2)==a.Length) 
                    newarr=a; // OK to reuse A
            if (newarr==null) 
                newarr=new sbyte[maxarr+2];
            newarr[0]=(sbyte)digit; // the carried digit ..
            // .. and all the rest [use local loop for short numbers]
            if (maxarr<10) 
                for(ix=maxarr+1,i=0;ix>0;ix--,i++){
                        newarr[i+1]=reb[i];
                    }
            else 
                System.Array.Copy(reb,0,newarr,1,maxarr+1);
            return newarr;
        }
 
        private static sbyte[] diginit(){
            sbyte[] work;
            int op=0;
            int digit=0;
            work=new sbyte[(90+99)+1];
            for(op=0;op<=(90+99);op++){
                    digit=op-90;
                    if (digit>=0) 
                        {
                            work[op]=(sbyte)(digit%10);
                            bytecar[op]=(sbyte)(digit/10); // calculate carry
                            continue;
                        }
                    // borrowing...
                    digit=digit+100; // yes, this is right [consider -50]
                    work[op]=(sbyte)(digit%10);
                    bytecar[op]=(sbyte)((digit/10)-10); // calculate borrow [NB: - after %]
                }
            return work;
        }
 
        private static BigDecimal clone(BigDecimal dec){
            BigDecimal copy;
            copy=new BigDecimal();
            copy.ind=dec.ind;
            copy.exp=dec.exp;
            copy.form=dec.form;
            copy.mant=dec.mant;
            return copy;
        }
 
        private void checkdigits(BigDecimal rhs,int dig){
            if (dig==0) 
                return; // don't check if digits=0
            // first check lhs...
            if (this.mant.Length>dig) 
                if ((!(allzero(this.mant,dig)))) 
                    throw new System.ArithmeticException("Too many digits:"+" "+this.ToString());
            if (rhs==null) 
                return; // monadic
            if (rhs.mant.Length>dig) 
                if ((!(allzero(rhs.mant,dig)))) 
                    throw new System.ArithmeticException("Too many digits:"+" "+rhs.ToString());
        }
 
        private BigDecimal round(MathContext set){
            return round(set.digits,set.roundingMode);
        }
 
        private BigDecimal round(int len,int mode){
            int adjust;
            int sign;
            sbyte[] oldmant;
            bool reuse=false;
            sbyte first=0;
            int increment;
            sbyte[] newmant=null;
            adjust=mant.Length-len;
            if (adjust<=0) 
                return this; // nowt to do
  
            exp=exp+adjust; // exponent of result
            sign=(int)ind; // save [assumes -1, 0, 1]
            oldmant=mant; // save
            if (len>0) 
                {
                    // remove the unwanted digits
                    mant=new sbyte[len];
                    System.Array.Copy(oldmant,0,mant,0,len);
                    reuse=true; // can reuse mantissa
                    first=oldmant[len]; // first of discarded digits
                }
            else 
                {/* len<=0 */
                    mant=ZERO.mant;
                    ind=iszero;
                    reuse=false; // cannot reuse mantissa
                    if (len==0) 
                        first=oldmant[0];
                    else 
                        first=(sbyte)0; // [virtual digit]
                }
  
            // decide rounding adjustment depending on mode, sign, and discarded digits
            increment=0; // bumper
            {do{/*select*/
                    if (mode==ROUND_HALF_UP)
                        { // default first [most common]
                            if (first>=5) 
                                increment=sign;
                        }
                    else if (mode==ROUND_UNNECESSARY)
                        { // default for setScale()
                            // discarding any non-zero digits is an error
                            if ((!(allzero(oldmant,len)))) 
                                throw new System.ArithmeticException("Rounding necessary");
                        }
                    else if (mode==ROUND_HALF_DOWN)
                        { // 0.5000 goes down
                            if (first>5) 
                                increment=sign;
                            else 
                                if (first==5) 
                                    if ((!(allzero(oldmant,len+1)))) 
                                        increment=sign;
                        }
                    else if (mode==ROUND_HALF_EVEN)
                        { // 0.5000 goes down if left digit even
                            if (first>5) 
                                increment=sign;
                            else 
                                if (first==5) 
                                    {
                                        if ((!(allzero(oldmant,len+1)))) 
                                            increment=sign;
                                        else /* 0.5000 */
                                            if ((((mant[mant.Length-1])%2))==1) 
                                                increment=sign;
                                    }
                        }
                    else if (mode==ROUND_DOWN){
                        // never increment
                    }else if (mode==ROUND_UP)
                        { // increment if discarded non-zero
                            if ((!(allzero(oldmant,len)))) 
                                increment=sign;
                        }
                    else if (mode==ROUND_CEILING)
                        { // more positive
                            if (sign>0) 
                                if ((!(allzero(oldmant,len)))) 
                                    increment=sign;
                        }
                    else if (mode==ROUND_FLOOR)
                        { // more negative
                            if (sign<0) 
                                if ((!(allzero(oldmant,len)))) 
                                    increment=sign;
                        }
                    else{
                        throw new System.ArgumentException("Bad round value:"+" "+mode);
                    }
                }while(false);}/*modes*/
  
            if (increment!=0) 
                {do{
                        if (ind==iszero) 
                            {
                                // we must not subtract from 0, but result is trivial anyway
                                mant=ONE.mant;
                                ind=(sbyte)increment;
                            }
                        else 
                            {
                                // mantissa is non-0; we can safely add or subtract 1
                                if (ind==isneg) 
                                    increment=(int)-increment;
                                newmant=byteaddsub(mant,mant.Length,ONE.mant,1,increment,reuse);
                                if (newmant.Length>mant.Length) 
                                    { // had a carry
                                        // drop rightmost digit and raise exponent
                                        exp++;
                                        // mant is already the correct length
                                        System.Array.Copy(newmant,0,mant,0,mant.Length);
                                    }
                                else 
                                    mant=newmant;
                            }
                    }while(false);}/*bump*/
            // rounding can increase exponent significantly
            if (exp>MaxExp) 
                throw new System.ArithmeticException("Exponent Overflow:"+" "+exp);
            return this;
        }

        private static bool allzero(sbyte[] array,int start){
            if (start<0) 
                start=0;
            for(int ix=array.Length-1,i=start;i<=ix;i++){
                    if (array[i]!=0) 
                        return false;
                }
            return true;
        }
 
        private BigDecimal finish(MathContext set, bool strip){
            int d=0;
            int i=0;
            int ix=0;
            sbyte[] newmant=null;
            int mag=0;
            int sig=0;
            /* Round if mantissa too long and digits requested */
            if (set.digits!=0) 
                if (this.mant.Length>set.digits) 
                    this.round(set);
  
            /* If strip requested (and standard formatting), remove
               insignificant trailing zeros. */
            if (strip) 
                if (set.form!=MathContext.PLAIN) 
                    {
                        d=this.mant.Length;
                        /* see if we need to drop any trailing zeros */
                        for(i=d-1;i>=1;i--){
                                if (this.mant[i]!=0) 
                                    break;
                                d--;
                                exp++;
                        }
                        if (d<this.mant.Length) 
                            {/* need to reduce */
                                newmant=new sbyte[d];
                                System.Array.Copy(this.mant,0,newmant,0,d);
                                this.mant=newmant;
                            }
                    }
  
            form=(sbyte)MathContext.PLAIN; // preset
  
            /* Now check for leading- and all- zeros in mantissa */
            for(ix=this.mant.Length,i=0;ix>0;ix--,i++){
                    if (this.mant[i]!=0) 
                        {
                            // non-0 result; ind will be correct
                            // remove leading zeros [e.g., after subtract]
                            if (i>0) 
                                {do{
                                        newmant=new sbyte[this.mant.Length-i];
                                        System.Array.Copy(this.mant,i,newmant,0,this.mant.Length-i);
                                        this.mant=newmant;
                                    }while(false);}/*delead*/
                            // now determine form if not PLAIN
                            mag=exp+mant.Length;
                            if (mag>0) 
                                { // most common path
                                    if (mag>set.digits) 
                                        if (set.digits!=0) 
                                            form=(sbyte)set.form;
                                    if ((mag-1)<=MaxExp) 
                                        return this; // no overflow; quick return
                                }
                            else 
                                if (mag<(-5)) 
                                    form=(sbyte)set.form;
                            /* check for overflow */
                            mag--;
                            if ((mag<MinExp)|(mag>MaxExp)) {
                                        // possible reprieve if form is engineering
                                        if (form==MathContext.ENGINEERING) 
                                            {
                                                sig=mag%3; // leftover
                                                if (sig<0) 
                                                    sig=3+sig; // negative exponent
                                                mag=mag-sig; // exponent to use
                                                // 1999.06.29: second test here must be MaxExp
                                                if (mag>=MinExp) 
                                                    if (mag<=MaxExp) 
                                                        return this;
                                            }
                                        throw new System.ArithmeticException("Exponent Overflow:"+" "+mag);
                            }
                            return this;
                        }
                }
  
            // Drop through to here only if mantissa is all zeros
            ind=iszero;
            {/*select*/
                if (set.form!=MathContext.PLAIN)
                    exp=0; // standard result; go to '0'
                else if (exp>0)
                    exp=0; // +ve exponent also goes to '0'
                else{
                    // a plain number with -ve exponent; preserve and check exponent
                    if (exp<MinExp) 
                        throw new System.ArithmeticException("Exponent Overflow:"+" "+exp);
                }
            }
            mant=ZERO.mant; // canonical mantissa
            return this;
        }
    }
}
