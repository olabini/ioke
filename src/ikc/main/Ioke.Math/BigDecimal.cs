
namespace Ioke.Math {
    using System;
    using System.Text;

    public class BigDecimal {
        public static readonly BigDecimal ZERO = new BigDecimal(0, 0);
        public static readonly BigDecimal ONE = new BigDecimal(1, 0);
        public static readonly BigDecimal TEN = new BigDecimal(10, 0);

        public const int ROUND_UP = 0;

        public const int ROUND_DOWN = 1;

        public const int ROUND_CEILING = 2;

        public const int ROUND_FLOOR = 3;

        public const int ROUND_HALF_UP = 4;

        public const int ROUND_HALF_DOWN = 5;

        public const int ROUND_HALF_EVEN = 6;

        public const int ROUND_UNNECESSARY = 7;

        private static readonly double LOG10_2 = 0.3010299956639812;

        private String toStringImage = null;

        private int hashCode = 0;

        private static readonly BigInteger[] FIVE_POW;

        private static readonly BigInteger[] TEN_POW;

        private static readonly long[] LONG_TEN_POW = new long[]
        {   1L,
            10L,
            100L,
            1000L,
            10000L,
            100000L,
            1000000L,
            10000000L,
            100000000L,
            1000000000L,
            10000000000L,
            100000000000L,
            1000000000000L,
            10000000000000L,
            100000000000000L,
            1000000000000000L,
            10000000000000000L,
            100000000000000000L,
            1000000000000000000L, };
    
    
        private static readonly long[] LONG_FIVE_POW = new long[]
        {   1L,
            5L,
            25L,
            125L,
            625L,
            3125L,
            15625L,
            78125L,
            390625L,
            1953125L,
            9765625L,
            48828125L,
            244140625L,
            1220703125L,
            6103515625L,
            30517578125L,
            152587890625L,
            762939453125L,
            3814697265625L,
            19073486328125L,
            95367431640625L,
            476837158203125L,
            2384185791015625L,
            11920928955078125L,
            59604644775390625L,
            298023223876953125L,
            1490116119384765625L,
            7450580596923828125L, };
    
        private static readonly int[] LONG_FIVE_POW_BIT_LENGTH = new int[LONG_FIVE_POW.Length];
        private static readonly int[] LONG_TEN_POW_BIT_LENGTH = new int[LONG_TEN_POW.Length];
    
        private static readonly int BI_SCALED_BY_ZERO_LENGTH = 11;

        private static readonly BigDecimal[] BI_SCALED_BY_ZERO = new BigDecimal[BI_SCALED_BY_ZERO_LENGTH];

        private static readonly BigDecimal[] ZERO_SCALED_BY = new BigDecimal[11];

        private static readonly char[] CH_ZEROS = new char[100];

        static BigDecimal() {
            int i = 0;

            for (; i < ZERO_SCALED_BY.Length; i++) {
                BI_SCALED_BY_ZERO[i] = new BigDecimal(i, 0);
                ZERO_SCALED_BY[i] = new BigDecimal(0, i);
                CH_ZEROS[i] = '0';
            }
        
            for (; i < CH_ZEROS.Length; i++) {
                CH_ZEROS[i] = '0';
            }
            for(int j=0; j<LONG_FIVE_POW_BIT_LENGTH.Length; j++) {
                LONG_FIVE_POW_BIT_LENGTH[j] = bitLength(LONG_FIVE_POW[j]);
            }
            for(int j=0; j<LONG_TEN_POW_BIT_LENGTH.Length; j++) {
                LONG_TEN_POW_BIT_LENGTH[j] = bitLength(LONG_TEN_POW[j]);
            }
        
            // Taking the references of useful powers.
            TEN_POW = Multiplication.bigTenPows;
            FIVE_POW = Multiplication.bigFivePows;
        }

        private BigInteger intVal;
    
        private int _bitLength;
    
        private long smallValue;

        private int _scale;
        private int _precision = 0;

        private BigDecimal(long smallValue, int scale){
            this.smallValue = smallValue;
            this._scale = scale;
            this._bitLength = bitLength(smallValue);
        }
    
        private BigDecimal(int smallValue, int scale){
            this.smallValue = smallValue;
            this._scale = scale;
            this._bitLength = bitLength(smallValue);
        }

        public BigDecimal(char[] _in, int offset, int len) {
            int begin = offset; // first index to be copied
            int last = offset + (len - 1); // last index to be copied
            String scaleString = null; // buffer for scale
            StringBuilder unscaledBuffer; // buffer for unscaled value
            long newScale; // the new scale

            if (_in == null) {
                throw new NullReferenceException();
            }
            if ((last >= _in.Length) || (offset < 0) || (len <= 0) || (last < 0)) {
                throw new System.FormatException();
            }
            unscaledBuffer = new StringBuilder(len);
            int bufLength = 0;
            // To skip a possible '+' symbol
            if ((offset <= last) && (_in[offset] == '+')) {
                offset++;
                begin++;
            }
            int counter = 0;
            bool wasNonZero = false;
            // Accumulating all digits until a possible decimal point
            for (; (offset <= last) && (_in[offset] != '.')
                     && (_in[offset] != 'e') && (_in[offset] != 'E'); offset++) {
                if (!wasNonZero) {
                    if (_in[offset] == '0') {
                        counter++;
                    } else {
                        wasNonZero = true;
                    }
                }

            }
            unscaledBuffer.Append(_in, begin, offset - begin);
            bufLength += offset - begin;
            // A decimal point was found
            if ((offset <= last) && (_in[offset] == '.')) {
                offset++;
                // Accumulating all digits until a possible exponent
                begin = offset;
                for (; (offset <= last) && (_in[offset] != 'e')
                         && (_in[offset] != 'E'); offset++) {
                    if (!wasNonZero) {
                        if (_in[offset] == '0') {
                            counter++;
                        } else {
                            wasNonZero = true;
                        }
                    }
                }
                _scale = offset - begin;
                bufLength += _scale;
                unscaledBuffer.Append(_in, begin, _scale);
            } else {
                _scale = 0;
            }
            // An exponent was found
            if ((offset <= last) && ((_in[offset] == 'e') || (_in[offset] == 'E'))) {
                offset++;
                // Checking for a possible sign of scale
                begin = offset;
                if ((offset <= last) && (_in[offset] == '+')) {
                    offset++;
                    if ((offset <= last) && (_in[offset] != '-')) {
                        begin++;
                    }
                }
                // Accumulating all remaining digits
                scaleString = new String(_in, begin, last + 1 - begin);
                // Checking if the scale is defined            
                newScale = (long)_scale - Int32.Parse(scaleString);
                _scale = (int)newScale;
                if (newScale != _scale) {
                    throw new System.FormatException("Scale out of range.");
                }
            }
            // Parsing the unscaled value
            if (bufLength < 19) {
                smallValue = Int64.Parse(unscaledBuffer.ToString());
                _bitLength = bitLength(smallValue);
            } else {
                setUnscaledValue(new BigInteger(unscaledBuffer.ToString()));
            }        
            _precision = unscaledBuffer.Length - counter;
            if (unscaledBuffer[0] == '-') {
                _precision --;
            }    
        }

        public BigDecimal(char[] _in, int offset, int len, MathContext mc) : this(_in, offset, len) {
            inplaceRound(mc);
        }

        public BigDecimal(char[] _in) : this(_in, 0, _in.Length) {
        }

        public BigDecimal(char[] _in, MathContext mc) : this(_in, 0, _in.Length) {
            inplaceRound(mc);
        }

        public BigDecimal(String val) : this(val.ToCharArray(), 0, val.Length) {
        }

        public BigDecimal(String val, MathContext mc) : this(val.ToCharArray(), 0, val.Length) {
            inplaceRound(mc);
        }

        public BigDecimal(double val) : this(System.Convert.ToString(val)) {
        }

        public BigDecimal(double val, MathContext mc) : this(val) {
            inplaceRound(mc);
        }

        public BigDecimal(BigInteger val) : this(val, 0) {
        }

        public BigDecimal(BigInteger val, MathContext mc) : this(val) {
            inplaceRound(mc);
        }

        public BigDecimal(BigInteger unscaledVal, int scale) {
            if (unscaledVal == null) {
                throw new NullReferenceException();
            }
            this._scale = scale;
            setUnscaledValue(unscaledVal);
        }

        public BigDecimal(BigInteger unscaledVal, int scale, MathContext mc) : this(unscaledVal, scale) {
            inplaceRound(mc);
        }

        public BigDecimal(int val) : this(val,0) {
        }

        public BigDecimal(int val, MathContext mc) : this(val,0) {
            inplaceRound(mc);
        }

        public BigDecimal(long val) : this(val,0) {
        }

        public BigDecimal(long val, MathContext mc) : this(val) {
            inplaceRound(mc);
        }

        public static BigDecimal valueOf(long unscaledVal, int scale) {
            if (scale == 0) {
                return valueOf(unscaledVal);
            }
            if ((unscaledVal == 0) && (scale >= 0)
                && (scale < ZERO_SCALED_BY.Length)) {
                return ZERO_SCALED_BY[scale];
            }
            return new BigDecimal(unscaledVal, scale);
        }

        public static BigDecimal valueOf(long unscaledVal) {
            if ((unscaledVal >= 0) && (unscaledVal < BI_SCALED_BY_ZERO_LENGTH)) {
                return BI_SCALED_BY_ZERO[(int)unscaledVal];
            }
            return new BigDecimal(unscaledVal,0);
        }

        public static BigDecimal valueOf(double val) {
            if (Double.IsInfinity(val) || Double.IsNaN(val)) {
                // math.03=Infinity or NaN
                throw new System.FormatException("Infinity or NaN");
            }
            return new BigDecimal(val.ToString());
        }

        public BigDecimal add(BigDecimal augend) {
            int diffScale = this._scale - augend._scale;
            // Fast return when some operand is zero
            if (this.isZero()) {
                if (diffScale <= 0) {
                    return augend;
                }
                if (augend.isZero()) {
                    return this;
                }
            } else if (augend.isZero()) {
                if (diffScale >= 0) {
                    return this;
                }
            }
            // Let be:  this = [u1,s1]  and  augend = [u2,s2]
            if (diffScale == 0) {
                // case s1 == s2: [u1 + u2 , s1]
                if (Math.Max(this._bitLength, augend._bitLength) + 1 < 64) {
                    return valueOf(this.smallValue + augend.smallValue, this._scale);
                }
                return new BigDecimal(this.getUnscaledValue().add(augend.getUnscaledValue()), this._scale);
            } else if (diffScale > 0) {
                // case s1 > s2 : [(u1 + u2) * 10 ^ (s1 - s2) , s1]
                return addAndMult10(this, augend, diffScale);
            } else {// case s2 > s1 : [(u2 + u1) * 10 ^ (s2 - s1) , s2]
                return addAndMult10(augend, this, -diffScale);
            }
        }

        private static BigDecimal addAndMult10(BigDecimal thisValue,BigDecimal augend, int diffScale) {
            if(diffScale < LONG_TEN_POW.Length &&
               Math.Max(thisValue._bitLength,augend._bitLength+LONG_TEN_POW_BIT_LENGTH[diffScale])+1<64) {
                return valueOf(thisValue.smallValue+augend.smallValue*LONG_TEN_POW[diffScale],thisValue._scale);
            }
            return new BigDecimal(thisValue.getUnscaledValue().add(
                                      Multiplication.multiplyByTenPow(augend.getUnscaledValue(),diffScale)), thisValue._scale);
        }
    
        public BigDecimal add(BigDecimal augend, MathContext mc) {
            BigDecimal larger; // operand with the largest unscaled value
            BigDecimal smaller; // operand with the smallest unscaled value
            BigInteger tempBI;
            long diffScale = (long)this._scale - augend._scale;
            int largerSignum;
            // Some operand is zero or the precision is infinity  
            if ((augend.isZero()) || (this.isZero())
                || (mc.getPrecision() == 0)) {
                return add(augend).round(mc);
            }
            // Cases where there is room for optimizations
            if (this.aproxPrecision() < diffScale - 1) {
                larger = augend;
                smaller = this;
            } else if (augend.aproxPrecision() < -diffScale - 1) {
                larger = this;
                smaller = augend;
            } else {// No optimization is done 
                return add(augend).round(mc);
            }
            if (mc.getPrecision() >= larger.aproxPrecision()) {
                // No optimization is done
                return add(augend).round(mc);
            }
            // Cases where it's unnecessary to add two numbers with very different scales 
            largerSignum = larger.signum();
            if (largerSignum == smaller.signum()) {
                tempBI = Multiplication.multiplyByPositiveInt(larger.getUnscaledValue(),10)
                    .add(BigInteger.valueOf(largerSignum));
            } else {
                tempBI = larger.getUnscaledValue().subtract(
                    BigInteger.valueOf(largerSignum));
                tempBI = Multiplication.multiplyByPositiveInt(tempBI,10)
                    .add(BigInteger.valueOf(largerSignum * 9));
            }
            // Rounding the improved adding 
            larger = new BigDecimal(tempBI, larger._scale + 1);
            return larger.round(mc);
        }

        public BigDecimal subtract(BigDecimal subtrahend) {
            int diffScale = this._scale - subtrahend._scale;
            // Fast return when some operand is zero
            if (this.isZero()) {
                if (diffScale <= 0) {
                    return subtrahend.negate();
                }
                if (subtrahend.isZero()) {
                    return this;
                }
            } else if (subtrahend.isZero()) {
                if (diffScale >= 0) {
                    return this;
                }
            }
            // Let be: this = [u1,s1] and subtrahend = [u2,s2] so:
            if (diffScale == 0) {
                // case s1 = s2 : [u1 - u2 , s1]
                if (Math.Max(this._bitLength, subtrahend._bitLength) + 1 < 64) {
                    return valueOf(this.smallValue - subtrahend.smallValue,this._scale);
                }
                return new BigDecimal(this.getUnscaledValue().subtract(subtrahend.getUnscaledValue()), this._scale);
            } else if (diffScale > 0) {
                // case s1 > s2 : [ u1 - u2 * 10 ^ (s1 - s2) , s1 ]
                if(diffScale < LONG_TEN_POW.Length &&
                   Math.Max(this._bitLength,subtrahend._bitLength+LONG_TEN_POW_BIT_LENGTH[diffScale])+1<64) {
                    return valueOf(this.smallValue-subtrahend.smallValue*LONG_TEN_POW[diffScale],this._scale);
                }
                return new BigDecimal(this.getUnscaledValue().subtract(
                                          Multiplication.multiplyByTenPow(subtrahend.getUnscaledValue(),diffScale)), this._scale);
            } else {// case s2 > s1 : [ u1 * 10 ^ (s2 - s1) - u2 , s2 ]
                diffScale = -diffScale;
                if(diffScale < LONG_TEN_POW.Length &&
                   Math.Max(this._bitLength+LONG_TEN_POW_BIT_LENGTH[diffScale],subtrahend._bitLength)+1<64) {
                    return valueOf(this.smallValue*LONG_TEN_POW[diffScale]-subtrahend.smallValue,subtrahend._scale);
                }
                return new BigDecimal(Multiplication.multiplyByTenPow(this.getUnscaledValue(),diffScale)
                                      .subtract(subtrahend.getUnscaledValue()), subtrahend._scale);
            }
        }

        public BigDecimal subtract(BigDecimal subtrahend, MathContext mc) {
            long diffScale = subtrahend._scale - (long)this._scale;
            int thisSignum;
            BigDecimal leftOperand; // it will be only the left operand (this) 
            BigInteger tempBI;
            // Some operand is zero or the precision is infinity  
            if ((subtrahend.isZero()) || (this.isZero())
                || (mc.getPrecision() == 0)) {
                return subtract(subtrahend).round(mc);
            }
            // Now:   this != 0   and   subtrahend != 0
            if (subtrahend.aproxPrecision() < diffScale - 1) {
                // Cases where it is unnecessary to subtract two numbers with very different scales
                if (mc.getPrecision() < this.aproxPrecision()) {
                    thisSignum = this.signum();
                    if (thisSignum != subtrahend.signum()) {
                        tempBI = Multiplication.multiplyByPositiveInt(this.getUnscaledValue(), 10)
                            .add(BigInteger.valueOf(thisSignum));
                    } else {
                        tempBI = this.getUnscaledValue().subtract(BigInteger.valueOf(thisSignum));
                        tempBI = Multiplication.multiplyByPositiveInt(tempBI, 10)
                            .add(BigInteger.valueOf(thisSignum * 9));
                    }
                    // Rounding the improved subtracting
                    leftOperand = new BigDecimal(tempBI, this._scale + 1);
                    return leftOperand.round(mc);
                }
            }
            // No optimization is done
            return subtract(subtrahend).round(mc);
        }

        public BigDecimal multiply(BigDecimal multiplicand) {
            long newScale = (long)this._scale + multiplicand._scale;

            if ((this.isZero()) || (multiplicand.isZero())) {
                return zeroScaledBy(newScale);
            }
            /* Let be: this = [u1,s1] and multiplicand = [u2,s2] so:
             * this x multiplicand = [ s1 * s2 , s1 + s2 ] */
            if(this._bitLength + multiplicand._bitLength < 64) {
                return valueOf(this.smallValue*multiplicand.smallValue,toIntScale(newScale));
            }
            return new BigDecimal(this.getUnscaledValue().multiply(
                                      multiplicand.getUnscaledValue()), toIntScale(newScale));
        }

        public BigDecimal multiply(BigDecimal multiplicand, MathContext mc) {
            BigDecimal result = multiply(multiplicand);

            result.inplaceRound(mc);
            return result;
        }

        public BigDecimal divide(BigDecimal divisor, int scale, int roundingMode) {
            return divide(divisor, scale, RoundingModeS.valueOf(roundingMode));
        }

        public BigDecimal divide(BigDecimal divisor, int scale, RoundingMode roundingMode) {
            // Let be: this = [u1,s1]  and  divisor = [u2,s2]
            if (divisor.isZero()) {
                throw new ArithmeticException("Division by zero");
            }
        
            long diffScale = ((long)this._scale - divisor._scale) - scale;
            if(this._bitLength < 64 && divisor._bitLength < 64 ) {
                if(diffScale == 0) {
                    return dividePrimitiveLongs(this.smallValue,
                                                divisor.smallValue,
                                                scale,
                                                roundingMode );
                } else if(diffScale > 0) {
                    if(diffScale < LONG_TEN_POW.Length &&
                       divisor._bitLength + LONG_TEN_POW_BIT_LENGTH[(int)diffScale] < 64) {
                        return dividePrimitiveLongs(this.smallValue,
                                                    divisor.smallValue*LONG_TEN_POW[(int)diffScale],
                                                    _scale,
                                                    roundingMode);
                    }
                } else { // diffScale < 0
                    if(-diffScale < LONG_TEN_POW.Length &&
                       this._bitLength + LONG_TEN_POW_BIT_LENGTH[(int)-diffScale] < 64) {
                        return dividePrimitiveLongs(this.smallValue*LONG_TEN_POW[(int)-diffScale],
                                                    divisor.smallValue,
                                                    scale,
                                                    roundingMode);
                    }
                
                }
            }
            BigInteger scaledDividend = this.getUnscaledValue();
            BigInteger scaledDivisor = divisor.getUnscaledValue(); // for scaling of 'u2'
        
            if (diffScale > 0) {
                // Multiply 'u2'  by:  10^((s1 - s2) - scale)
                scaledDivisor = Multiplication.multiplyByTenPow(scaledDivisor, (int)diffScale);
            } else if (diffScale < 0) {
                // Multiply 'u1'  by:  10^(scale - (s1 - s2))
                scaledDividend  = Multiplication.multiplyByTenPow(scaledDividend, (int)-diffScale);
            }
            return divideBigIntegers(scaledDividend, scaledDivisor, scale, roundingMode);
        }
    
        private static BigDecimal divideBigIntegers(BigInteger scaledDividend, BigInteger scaledDivisor, int scale, RoundingMode roundingMode) {
            BigInteger[] quotAndRem = scaledDividend.divideAndRemainder(scaledDivisor);  // quotient and remainder

            // If after division there is a remainder...
            BigInteger quotient = quotAndRem[0];
            BigInteger remainder = quotAndRem[1];
            if (remainder.signum() == 0) {
                return new BigDecimal(quotient, scale);
            }
            int sign = scaledDividend.signum() * scaledDivisor.signum();
            int compRem;                                      // 'compare to remainder'
            if(scaledDivisor.bitLength() < 63) { // 63 in order to avoid out of long after <<1
                long rem = remainder.longValue();
                long divisor = scaledDivisor.longValue();
                compRem = longCompareTo(Math.Abs(rem) << 1,Math.Abs(divisor));
                // To look if there is a carry
                compRem = roundingBehavior(quotient.testBit(0) ? 1 : 0,
                                           sign * (5 + compRem), roundingMode);
            
            } else {
                // Checking if:  remainder * 2 >= scaledDivisor 
                compRem = remainder.abs().shiftLeftOneBit().compareTo(scaledDivisor.abs());
                compRem = roundingBehavior(quotient.testBit(0) ? 1 : 0,
                                           sign * (5 + compRem), roundingMode);
            }
            if (compRem != 0) {
                if(quotient.bitLength() < 63) {
                    return valueOf(quotient.longValue() + compRem,scale);
                }
                quotient = quotient.add(BigInteger.valueOf(compRem));
                return new BigDecimal(quotient, scale);
            }
            // Constructing the result with the appropriate unscaled value
            return new BigDecimal(quotient, scale);
        }
    
        private static BigDecimal dividePrimitiveLongs(long scaledDividend, long scaledDivisor, int scale, RoundingMode roundingMode) {
            long quotient = scaledDividend / scaledDivisor;
            long remainder = scaledDividend % scaledDivisor;
            int sign = Math.Sign( scaledDividend ) * Math.Sign( scaledDivisor );
            if (remainder != 0) {
                // Checking if:  remainder * 2 >= scaledDivisor
                int compRem;                                      // 'compare to remainder'
                compRem = longCompareTo(Math.Abs(remainder) << 1,Math.Abs(scaledDivisor));
                // To look if there is a carry
                quotient += roundingBehavior(((int)quotient) & 1,
                                             sign * (5 + compRem),
                                             roundingMode);
            }
            // Constructing the result with the appropriate unscaled value
            return valueOf(quotient, scale);
        }

        public BigDecimal divide(BigDecimal divisor, int roundingMode) {
            return divide(divisor, _scale, RoundingModeS.valueOf(roundingMode));
        }

        public BigDecimal divide(BigDecimal divisor, RoundingMode roundingMode) {
            return divide(divisor, _scale, roundingMode);
        }

        public BigDecimal divide(BigDecimal divisor) {
            BigInteger p = this.getUnscaledValue();
            BigInteger q = divisor.getUnscaledValue();
            BigInteger gcd; // greatest common divisor between 'p' and 'q'
            BigInteger[] quotAndRem;
            long diffScale = (long)_scale - divisor._scale;
            int newScale; // the new scale for final quotient
            int k; // number of factors "2" in 'q'
            int l = 0; // number of factors "5" in 'q'
            int i = 1;
            int lastPow = FIVE_POW.Length - 1;

            if (divisor.isZero()) {
                throw new ArithmeticException("Division by zero");
            }
            if (p.signum() == 0) {
                return zeroScaledBy(diffScale);
            }
            // To divide both by the GCD
            gcd = p.gcd(q);
            p = p.divide(gcd);
            q = q.divide(gcd);
            // To simplify all "2" factors of q, dividing by 2^k
            k = q.getLowestSetBit();
            q = q.shiftRight(k);
            // To simplify all "5" factors of q, dividing by 5^l
            do {
                quotAndRem = q.divideAndRemainder(FIVE_POW[i]);
                if (quotAndRem[1].signum() == 0) {
                    l += i;
                    if (i < lastPow) {
                        i++;
                    }
                    q = quotAndRem[0];
                } else {
                    if (i == 1) {
                        break;
                    }
                    i = 1;
                }
            } while (true);
            // If  abs(q) != 1  then the quotient is periodic
            if (!q.abs().Equals(BigInteger.ONE)) {
                throw new ArithmeticException("Non-terminating decimal expansion; no exact representable decimal result.");
            }
            // The sign of the is fixed and the quotient will be saved in 'p'
            if (q.signum() < 0) {
                p = p.negate();
            }
            // Checking if the new scale is out of range
            newScale = toIntScale(diffScale + Math.Max(k, l));
            // k >= 0  and  l >= 0  implies that  k - l  is in the 32-bit range
            i = k - l;
        
            p = (i > 0) ? Multiplication.multiplyByFivePow(p, i)
                : p.shiftLeft(-i);
            return new BigDecimal(p, newScale);
        }

        public BigDecimal divide(BigDecimal divisor, MathContext mc) {
            /* Calculating how many zeros must be append to 'dividend'
             * to obtain a  quotient with at least 'mc.precision()' digits */
            long traillingZeros = mc.getPrecision() + 2L
                + divisor.aproxPrecision() - aproxPrecision();
            long diffScale = (long)_scale - divisor._scale;
            long newScale = diffScale; // scale of the final quotient
            int compRem; // to compare the remainder
            int i = 1; // index   
            int lastPow = TEN_POW.Length - 1; // last power of ten
            BigInteger integerQuot; // for temporal results
            BigInteger[] quotAndRem = {getUnscaledValue()};
            // In special cases it reduces the problem to call the dual method
            if ((mc.getPrecision() == 0) || (this.isZero())
                || (divisor.isZero())) {
                return this.divide(divisor);
            }
            if (traillingZeros > 0) {
                // To append trailing zeros at end of dividend
                quotAndRem[0] = getUnscaledValue().multiply( Multiplication.powerOf10(traillingZeros) );
                newScale += traillingZeros;
            }
            quotAndRem = quotAndRem[0].divideAndRemainder( divisor.getUnscaledValue() );
            integerQuot = quotAndRem[0];
            // Calculating the exact quotient with at least 'mc.precision()' digits
            if (quotAndRem[1].signum() != 0) {
                // Checking if:   2 * remainder >= divisor ?
                compRem = quotAndRem[1].shiftLeftOneBit().compareTo( divisor.getUnscaledValue() );
                // quot := quot * 10 + r;     with 'r' in {-6,-5,-4, 0,+4,+5,+6}
                integerQuot = integerQuot.multiply(BigInteger.TEN)
                    .add(BigInteger.valueOf(quotAndRem[0].signum() * (5 + compRem)));
                newScale++;
            } else {
                // To strip trailing zeros until the preferred scale is reached
                while (!integerQuot.testBit(0)) {
                    quotAndRem = integerQuot.divideAndRemainder(TEN_POW[i]);
                    if ((quotAndRem[1].signum() == 0)
                        && (newScale - i >= diffScale)) {
                        newScale -= i;
                        if (i < lastPow) {
                            i++;
                        }
                        integerQuot = quotAndRem[0];
                    } else {
                        if (i == 1) {
                            break;
                        }
                        i = 1;
                    }
                }
            }
            // To perform rounding
            return new BigDecimal(integerQuot, toIntScale(newScale), mc);
        }

        public BigDecimal divideToIntegralValue(BigDecimal divisor) {
            BigInteger integralValue; // the integer of result
            BigInteger powerOfTen; // some power of ten
            BigInteger[] quotAndRem = {getUnscaledValue()};
            long newScale = (long)this._scale - divisor._scale;
            long tempScale = 0;
            int i = 1;
            int lastPow = TEN_POW.Length - 1;

            if (divisor.isZero()) {
                throw new ArithmeticException("Division by zero");
            }
            if ((divisor.aproxPrecision() + newScale > this.aproxPrecision() + 1L)
                || (this.isZero())) {
                /* If the divisor's integer part is greater than this's integer part,
                 * the result must be zero with the appropriate scale */
                integralValue = BigInteger.ZERO;
            } else if (newScale == 0) {
                integralValue = getUnscaledValue().divide( divisor.getUnscaledValue() );
            } else if (newScale > 0) {
                powerOfTen = Multiplication.powerOf10(newScale);
                integralValue = getUnscaledValue().divide( divisor.getUnscaledValue().multiply(powerOfTen) );
                integralValue = integralValue.multiply(powerOfTen);
            } else {// (newScale < 0)
                powerOfTen = Multiplication.powerOf10(-newScale);
                integralValue = getUnscaledValue().multiply(powerOfTen).divide( divisor.getUnscaledValue() );
                // To strip trailing zeros approximating to the preferred scale
                while (!integralValue.testBit(0)) {
                    quotAndRem = integralValue.divideAndRemainder(TEN_POW[i]);
                    if ((quotAndRem[1].signum() == 0)
                        && (tempScale - i >= newScale)) {
                        tempScale -= i;
                        if (i < lastPow) {
                            i++;
                        }
                        integralValue = quotAndRem[0];
                    } else {
                        if (i == 1) {
                            break;
                        }
                        i = 1;
                    }
                }
                newScale = tempScale;
            }
            return ((integralValue.signum() == 0)
                    ? zeroScaledBy(newScale)
                    : new BigDecimal(integralValue, toIntScale(newScale)));
        }

        public BigDecimal divideToIntegralValue(BigDecimal divisor, MathContext mc) {
            int mcPrecision = mc.getPrecision();
            int diffPrecision = this.precision() - divisor.precision();
            int lastPow = TEN_POW.Length - 1;
            long diffScale = (long)this._scale - divisor._scale;
            long newScale = diffScale;
            long quotPrecision = diffPrecision - diffScale + 1;
            BigInteger[] quotAndRem = new BigInteger[2];
            // In special cases it call the dual method
            if ((mcPrecision == 0) || (this.isZero()) || (divisor.isZero())) {
                return this.divideToIntegralValue(divisor);
            }
            // Let be:   this = [u1,s1]   and   divisor = [u2,s2]
            if (quotPrecision <= 0) {
                quotAndRem[0] = BigInteger.ZERO;
            } else if (diffScale == 0) {
                // CASE s1 == s2:  to calculate   u1 / u2 
                quotAndRem[0] = this.getUnscaledValue().divide( divisor.getUnscaledValue() );
            } else if (diffScale > 0) {
                // CASE s1 >= s2:  to calculate   u1 / (u2 * 10^(s1-s2)  
                quotAndRem[0] = this.getUnscaledValue().divide(
                    divisor.getUnscaledValue().multiply(Multiplication.powerOf10(diffScale)) );
                // To chose  10^newScale  to get a quotient with at least 'mc.precision()' digits
                newScale = Math.Min(diffScale, Math.Max(mcPrecision - quotPrecision + 1, 0));
                // To calculate: (u1 / (u2 * 10^(s1-s2)) * 10^newScale
                quotAndRem[0] = quotAndRem[0].multiply(Multiplication.powerOf10(newScale));
            } else {// CASE s2 > s1:   
                /* To calculate the minimum power of ten, such that the quotient 
                 *   (u1 * 10^exp) / u2   has at least 'mc.precision()' digits. */
                long exp = Math.Min(-diffScale, Math.Max((long)mcPrecision - diffPrecision, 0));
                long compRemDiv;
                // Let be:   (u1 * 10^exp) / u2 = [q,r]  
                quotAndRem = this.getUnscaledValue().multiply(Multiplication.powerOf10(exp)).
                    divideAndRemainder(divisor.getUnscaledValue());
                newScale += exp; // To fix the scale
                exp = -newScale; // The remaining power of ten
                // If after division there is a remainder...
                if ((quotAndRem[1].signum() != 0) && (exp > 0)) {
                    // Log10(r) + ((s2 - s1) - exp) > mc.precision ?
                    compRemDiv = (new BigDecimal(quotAndRem[1])).precision()
                        + exp - divisor.precision();
                    if (compRemDiv == 0) {
                        // To calculate:  (r * 10^exp2) / u2
                        quotAndRem[1] = quotAndRem[1].multiply(Multiplication.powerOf10(exp)).
                            divide(divisor.getUnscaledValue());
                        compRemDiv = Math.Abs(quotAndRem[1].signum());
                    }
                    if (compRemDiv > 0) {
                        // The quotient won't fit in 'mc.precision()' digits
                        throw new ArithmeticException("Division impossible");
                    }
                }
            }
            // Fast return if the quotient is zero
            if (quotAndRem[0].signum() == 0) {
                return zeroScaledBy(diffScale);
            }
            BigInteger strippedBI = quotAndRem[0];
            BigDecimal integralValue = new BigDecimal(quotAndRem[0]);
            long resultPrecision = integralValue.precision();
            int i = 1;
            // To strip trailing zeros until the specified precision is reached
            while (!strippedBI.testBit(0)) {
                quotAndRem = strippedBI.divideAndRemainder(TEN_POW[i]);
                if ((quotAndRem[1].signum() == 0) &&
                    ((resultPrecision - i >= mcPrecision)
                     || (newScale - i >= diffScale)) ) {
                    resultPrecision -= i;
                    newScale -= i;
                    if (i < lastPow) {
                        i++;
                    }
                    strippedBI = quotAndRem[0];
                } else {
                    if (i == 1) {
                        break;
                    }
                    i = 1;
                }
            }
            // To check if the result fit in 'mc.precision()' digits
            if (resultPrecision > mcPrecision) {
                throw new ArithmeticException("Division impossible");
            }
            integralValue._scale = toIntScale(newScale);
            integralValue.setUnscaledValue(strippedBI);
            return integralValue;
        }

        public BigDecimal remainder(BigDecimal divisor) {
            return divideAndRemainder(divisor)[1];
        }

        public BigDecimal remainder(BigDecimal divisor, MathContext mc) {
            return divideAndRemainder(divisor, mc)[1];
        }

        public BigDecimal[] divideAndRemainder(BigDecimal divisor) {
            BigDecimal[] quotAndRem = new BigDecimal[2];

            quotAndRem[0] = this.divideToIntegralValue(divisor);
            quotAndRem[1] = this.subtract( quotAndRem[0].multiply(divisor) );
            return quotAndRem;
        }

        public BigDecimal[] divideAndRemainder(BigDecimal divisor, MathContext mc) {
            BigDecimal[] quotAndRem = new BigDecimal[2];

            quotAndRem[0] = this.divideToIntegralValue(divisor, mc);
            quotAndRem[1] = this.subtract( quotAndRem[0].multiply(divisor) );
            return quotAndRem;
        }

        public BigDecimal pow(int n) {
            if (n == 0) {
                return ONE;
            }
            if ((n < 0) || (n > 999999999)) {
                // math.07=Invalid Operation
                throw new ArithmeticException("Invalid Operation");
            }
            long newScale = _scale * (long)n;
            // Let be: this = [u,s]   so:  this^n = [u^n, s*n]
            return ((isZero())
                    ? zeroScaledBy(newScale)
                    : new BigDecimal(getUnscaledValue().pow(n), toIntScale(newScale)));
        }


        internal static int numberOfTrailingZeros(long lng) {
            return bitCount((lng & -lng) - 1);
        }

        internal static int numberOfTrailingZeros(int i) {
            return bitCount((i & -i) - 1);
        }

        internal static int numberOfLeadingZeros(long lng) {
            lng |= lng >> 1;
            lng |= lng >> 2;
            lng |= lng >> 4;
            lng |= lng >> 8;
            lng |= lng >> 16;
            lng |= lng >> 32;
            return bitCount(~lng);
        }

        internal static int bitCount(long lng) {
            lng = (lng & 0x5555555555555555L) + ((lng >> 1) & 0x5555555555555555L);
            lng = (lng & 0x3333333333333333L) + ((lng >> 2) & 0x3333333333333333L);
            // adjust for 64-bit integer
            int i = (int) ((lng >> 32) + lng);
            i = (i & 0x0F0F0F0F) + ((i >> 4) & 0x0F0F0F0F);
            i = (i & 0x00FF00FF) + ((i >> 8) & 0x00FF00FF);
            i = (i & 0x0000FFFF) + ((i >> 16) & 0x0000FFFF);
            return i;
        }

        internal static int numberOfLeadingZeros(int i) {
            i |= i >> 1;
            i |= i >> 2;
            i |= i >> 4;
            i |= i >> 8;
            i |= i >> 16;
            return bitCount(~i);
        }

        internal static int bitCount(int i) {
            i -= ((i >> 1) & 0x55555555);
            i = (i & 0x33333333) + ((i >> 2) & 0x33333333);
            i = (((i >> 4) + i) & 0x0F0F0F0F);
            i += (i >> 8);
            i += (i >> 16);
            return (i & 0x0000003F);
        }

        private static int highestOneBit(int i) {
            i |= (i >> 1);
            i |= (i >> 2);
            i |= (i >> 4);
            i |= (i >> 8);
            i |= (i >> 16);
            return (i & ~(i >> 1));
        }

        public BigDecimal pow(int n, MathContext mc) {
            // The ANSI standard X3.274-1996 algorithm
            int m = Math.Abs(n);
            int mcPrecision = mc.getPrecision();
            int elength = (int)Math.Log10(m) + 1;   // decimal digits in 'n'
            int oneBitMask; // mask of bits
            BigDecimal accum; // the single accumulator
            MathContext newPrecision = mc; // MathContext by default

            // In particular cases, it reduces the problem to call the other 'pow()'
            if ((n == 0) || ((isZero()) && (n > 0))) {
                return pow(n);
            }
            if ((m > 999999999) || ((mcPrecision == 0) && (n < 0))
                || ((mcPrecision > 0) && (elength > mcPrecision))) {
                // math.07=Invalid Operation
                throw new ArithmeticException("Invalid Operation");
            }
            if (mcPrecision > 0) {
                newPrecision = new MathContext( mcPrecision + elength + 1,
                                                mc.getRoundingMode());
            }
            // The result is calculated as if 'n' were positive        
            accum = round(newPrecision);
            oneBitMask = highestOneBit(m) >> 1;

            while (oneBitMask > 0) {
                accum = accum.multiply(accum, newPrecision);
                if ((m & oneBitMask) == oneBitMask) {
                    accum = accum.multiply(this, newPrecision);
                }
                oneBitMask >>= 1;
            }
            // If 'n' is negative, the value is divided into 'ONE'
            if (n < 0) {
                accum = ONE.divide(accum, newPrecision);
            }
            // The final value is rounded to the destination precision
            accum.inplaceRound(mc);
            return accum;
        }

        public BigDecimal abs() {
            return ((signum() < 0) ? negate() : this);
        }

        public BigDecimal abs(MathContext mc) {
            return round(mc).abs();
        }

        public BigDecimal negate() {
            if(_bitLength < 63 || (_bitLength == 63 && smallValue!=Int64.MinValue)) {
                return valueOf(-smallValue,_scale);
            }
            return new BigDecimal(getUnscaledValue().negate(), _scale);
        }

        public BigDecimal negate(MathContext mc) {
            return round(mc).negate();
        }

        public BigDecimal plus() {
            return this;
        }

        public BigDecimal plus(MathContext mc) {
            return round(mc);
        }

        public int signum() {
            if(_bitLength < 64) {
                return Math.Sign( this.smallValue );
            }
            return getUnscaledValue().signum();
        }
    
        private bool isZero() {
            //Watch out: -1 has a bitLength=0
            return _bitLength == 0 && this.smallValue != -1;
        }

        public int scale() {
            return _scale;
        }

        public int precision() {
            // Checking if the precision already was calculated
            if (_precision > 0) {
                return _precision;
            }
            int bitLength = this._bitLength;
            int decimalDigits = 1; // the precision to be calculated
            double doubleUnsc = 1;  // intVal in 'double'

            if (bitLength < 1024) {
                // To calculate the precision for small numbers
                if (bitLength >= 64) {
                    doubleUnsc = getUnscaledValue().doubleValue();
                } else if (bitLength >= 1) {
                    doubleUnsc = smallValue;
                }
                decimalDigits += (int)Math.Log10(Math.Abs(doubleUnsc));
            } else {// (bitLength >= 1024)
                /* To calculate the precision for large numbers
                 * Note that: 2 ^(bitlength() - 1) <= intVal < 10 ^(precision()) */
                decimalDigits += (int)((bitLength - 1) * LOG10_2);
                // If after division the number isn't zero, exists an aditional digit
                if (getUnscaledValue().divide(Multiplication.powerOf10(decimalDigits)).signum() != 0) {
                    decimalDigits++;
                }
            }
            _precision = decimalDigits;
            return _precision;
        }

        public BigInteger unscaledValue() {
            return getUnscaledValue();
        }

        public BigDecimal round(MathContext mc) {
            BigDecimal thisBD = new BigDecimal(getUnscaledValue(), _scale);

            thisBD.inplaceRound(mc);
            return thisBD;
        }

        public BigDecimal setScale(int newScale, RoundingMode roundingMode) {
            long diffScale = newScale - (long)_scale;
            // Let be:  'this' = [u,s]        
            if(diffScale == 0) {
                return this;
            }
            if(diffScale > 0) {
                // return  [u * 10^(s2 - s), newScale]
                if(diffScale < LONG_TEN_POW.Length &&
                   (this._bitLength + LONG_TEN_POW_BIT_LENGTH[(int)diffScale]) < 64 ) {
                    return valueOf(this.smallValue*LONG_TEN_POW[(int)diffScale],newScale);
                }
                return new BigDecimal(Multiplication.multiplyByTenPow(getUnscaledValue(),(int)diffScale), newScale);
            }
            // diffScale < 0
            // return  [u,s] / [1,newScale]  with the appropriate scale and rounding
            if(this._bitLength < 64 && -diffScale < LONG_TEN_POW.Length) {
                return dividePrimitiveLongs(this.smallValue, LONG_TEN_POW[(int)-diffScale], newScale,roundingMode);
            }
            return divideBigIntegers(this.getUnscaledValue(),Multiplication.powerOf10(-diffScale),newScale,roundingMode);
        }

        public BigDecimal setScale(int newScale, int roundingMode) {
            return setScale(newScale, RoundingModeS.valueOf(roundingMode));
        }

        public BigDecimal setScale(int newScale) {
            return setScale(newScale, RoundingMode.UNNECESSARY);
        }

        public BigDecimal movePointLeft(int n) {
            return movePoint(_scale + (long)n);
        }

        private BigDecimal movePoint(long newScale) {
            if (isZero()) {
                return zeroScaledBy(Math.Max(newScale, 0));
            }
            /* When:  'n'== Integer.MIN_VALUE  isn't possible to call to movePointRight(-n)  
             * since  -Integer.MIN_VALUE == Integer.MIN_VALUE */
            if(newScale >= 0) {
                if(_bitLength < 64) {
                    return valueOf(smallValue,toIntScale(newScale));
                }
                return new BigDecimal(getUnscaledValue(), toIntScale(newScale));
            }
            if(-newScale < LONG_TEN_POW.Length &&
               _bitLength + LONG_TEN_POW_BIT_LENGTH[(int)-newScale] < 64 ) {
                return valueOf(smallValue*LONG_TEN_POW[(int)-newScale],0);
            }
            return new BigDecimal(Multiplication.multiplyByTenPow(getUnscaledValue(),(int)-newScale), 0);
        }

        public BigDecimal movePointRight(int n) {
            return movePoint(_scale - (long)n);
        }

        public BigDecimal scaleByPowerOfTen(int n) {
            long newScale = _scale - (long)n;
            if(_bitLength < 64) {
                //Taking care when a 0 is to be scaled
                if( smallValue==0  ){
                    return zeroScaledBy( newScale );
                }
                return valueOf(smallValue,toIntScale(newScale));
            }
            return new BigDecimal(getUnscaledValue(), toIntScale(newScale));
        }

        public BigDecimal stripTrailingZeros() {
            int i = 1; // 1 <= i <= 18
            int lastPow = TEN_POW.Length - 1;
            long newScale = _scale;

            if (isZero()) {
                return new BigDecimal("0");
            }
            BigInteger strippedBI = getUnscaledValue();
            BigInteger[] quotAndRem;
        
            // while the number is even...
            while (!strippedBI.testBit(0)) {
                // To divide by 10^i
                quotAndRem = strippedBI.divideAndRemainder(TEN_POW[i]);
                // To look the remainder
                if (quotAndRem[1].signum() == 0) {
                    // To adjust the scale
                    newScale -= i;
                    if (i < lastPow) {
                        // To set to the next power
                        i++;
                    }
                    strippedBI = quotAndRem[0];
                } else {
                    if (i == 1) {
                        // 'this' has no more trailing zeros
                        break;
                    }
                    // To set to the smallest power of ten
                    i = 1;
                }
            }
            return new BigDecimal(strippedBI, toIntScale(newScale));
        }

        public int CompareTo(BigDecimal rhs){
            return this.compareTo(rhs);
        }

        public int compareTo(BigDecimal val) {
            int thisSign = signum();
            int valueSign = val.signum();

            if( thisSign == valueSign) {
                if(this._scale == val._scale && this._bitLength<64 && val._bitLength<64 ) {
                    return (smallValue < val.smallValue) ? -1 : (smallValue > val.smallValue) ? 1 : 0;
                }
                long diffScale = (long)this._scale - val._scale;
                int diffPrecision = this.aproxPrecision() - val.aproxPrecision();
                if (diffPrecision > diffScale + 1) {
                    return thisSign;
                } else if (diffPrecision < diffScale - 1) {
                    return -thisSign;
                } else {// thisSign == val.signum()  and  diffPrecision is aprox. diffScale
                    BigInteger thisUnscaled = this.getUnscaledValue();
                    BigInteger valUnscaled = val.getUnscaledValue();
                    // If any of both precision is bigger, append zeros to the shorter one
                    if (diffScale < 0) {
                        thisUnscaled = thisUnscaled.multiply(Multiplication.powerOf10(-diffScale));
                    } else if (diffScale > 0) {
                        valUnscaled = valUnscaled.multiply(Multiplication.powerOf10(diffScale));
                    }
                    return thisUnscaled.compareTo(valUnscaled);
                }
            } else if (thisSign < valueSign) {
                return -1;
            } else  {
                return 1;
            }
        }

        public override bool Equals(object x) {
            if (this == x) {
                return true;
            }
            if (x is BigDecimal) {
                BigDecimal x1 = (BigDecimal) x;
                return x1._scale == _scale
                    && (_bitLength < 64 ? (x1.smallValue == smallValue)
                        : intVal.Equals(x1.intVal));


            }
            return false;
        }   

        public BigDecimal min(BigDecimal val) {
            return ((compareTo(val) <= 0) ? this : val);
        }

        public BigDecimal max(BigDecimal val) {
            return ((compareTo(val) >= 0) ? this : val);
        }

        public override int GetHashCode() {
            if (hashCode != 0) {
                return hashCode;
            }
            if (_bitLength < 64) {
                hashCode = (int)(smallValue & 0xffffffff);
                hashCode = 33 * hashCode +  (int)((smallValue >> 32) & 0xffffffff);
                hashCode = 17 * hashCode + _scale;
                return hashCode;
            }
            hashCode = 17 * intVal.GetHashCode() + _scale;
            return hashCode;
        }

        public override string ToString(){
            if (toStringImage != null) {
                return toStringImage;
            }
            if(_bitLength < 32) {
                toStringImage = Conversion.toDecimalScaledString(smallValue,_scale);
                return toStringImage;
            }
            String intString = getUnscaledValue().ToString();
            if (_scale == 0) {
                return intString;
            }
            int begin = (getUnscaledValue().signum() < 0) ? 2 : 1;
            int end = intString.Length;
            long exponent = -(long)_scale + end - begin;
            StringBuilder result = new StringBuilder();

            result.Append(intString);
            if ((_scale > 0) && (exponent >= -6)) {
                if (exponent >= 0) {
                    result.Insert(end - _scale, '.');
                } else {
                    result.Insert(begin - 1, "0."); //$NON-NLS-1$
                    result.Insert(begin + 1, CH_ZEROS, 0, -(int)exponent - 1);
                }
            } else {
                if (end - begin >= 1) {
                    result.Insert(begin, '.');
                    end++;
                }
                result.Insert(end, 'E');
                if (exponent > 0) {
                    result.Insert(++end, '+');
                }
                result.Insert(++end, exponent.ToString());
            }
            toStringImage = result.ToString();
            return toStringImage;
        }

        public String toEngineeringString() {
            String intString = getUnscaledValue().ToString();
            if (_scale == 0) {
                return intString;
            }
            int begin = (getUnscaledValue().signum() < 0) ? 2 : 1;
            int end = intString.Length;
            long exponent = -(long)_scale + end - begin;
            StringBuilder result = new StringBuilder(intString);

            if ((_scale > 0) && (exponent >= -6)) {
                if (exponent >= 0) {
                    result.Insert(end - _scale, '.');
                } else {
                    result.Insert(begin - 1, "0.");
                    result.Insert(begin + 1, CH_ZEROS, 0, -(int)exponent - 1);
                }
            } else {
                int delta = end - begin;
                int rem = (int)(exponent % 3);

                if (rem != 0) {
                    // adjust exponent so it is a multiple of three
                    if (getUnscaledValue().signum() == 0) {
                        // zero value
                        rem = (rem < 0) ? -rem : 3 - rem;
                        exponent += rem;
                    } else {
                        // nonzero value
                        rem = (rem < 0) ? rem + 3 : rem;
                        exponent -= rem;
                        begin += rem;
                    }
                    if (delta < 3) {
                        for (int i = rem - delta; i > 0; i--) {
                            result.Insert(end++, '0');
                        }
                    }
                }
                if (end - begin >= 1) {
                    result.Insert(begin, '.');
                    end++;
                }
                if (exponent != 0) {
                    result.Insert(end, 'E');
                    if (exponent > 0) {
                        result.Insert(++end, '+');
                    }
                    result.Insert(++end, exponent.ToString());
                }
            }
            return result.ToString();
        }

        public String toPlainString() {
            String intStr = getUnscaledValue().ToString();
            if ((_scale == 0) || ((isZero()) && (_scale < 0))) {
                return intStr;
            }
            int begin = (signum() < 0) ? 1 : 0;
            int delta = _scale;
            // We take space for all digits, plus a possible decimal point, plus 'scale'
            StringBuilder result = new StringBuilder(intStr.Length + 1 + Math.Abs(_scale));

            if (begin == 1) {
                // If the number is negative, we insert a '-' character at front 
                result.Append('-');
            }
            if (_scale > 0) {
                delta -= (intStr.Length - begin);
                if (delta >= 0) {
                    result.Append("0."); //$NON-NLS-1$
                    // To append zeros after the decimal point
                    for (; delta > CH_ZEROS.Length; delta -= CH_ZEROS.Length) {
                        result.Append(CH_ZEROS);
                    }
                    result.Append(CH_ZEROS, 0, delta);
                    result.Append(intStr.Substring(begin));
                } else {
                    delta = begin - delta;
                    result.Append(intStr.Substring(begin, delta - begin));
                    result.Append('.');
                    result.Append(intStr.Substring(delta));
                }
            } else {// (scale <= 0)
                result.Append(intStr.Substring(begin));
                // To append trailing zeros
                for (; delta < -CH_ZEROS.Length; delta += CH_ZEROS.Length) {
                    result.Append(CH_ZEROS);
                }
                result.Append(CH_ZEROS, 0, -delta);
            }
            return result.ToString();
        }

        public BigInteger toBigInteger() {
            if ((_scale == 0) || (isZero())) {
                return getUnscaledValue();
            } else if (_scale < 0) {
                return getUnscaledValue().multiply(Multiplication.powerOf10(-(long)_scale));
            } else {// (scale > 0)
                return getUnscaledValue().divide(Multiplication.powerOf10(_scale));
            }
        }

        public BigInteger toBigIntegerExact() {
            if ((_scale == 0) || (isZero())) {
                return getUnscaledValue();
            } else if (_scale < 0) {
                return getUnscaledValue().multiply(Multiplication.powerOf10(-(long)_scale));
            } else {// (scale > 0)
                BigInteger[] integerAndFraction;
                // An optimization before do a heavy division
                if ((_scale > aproxPrecision()) || (_scale > getUnscaledValue().getLowestSetBit())) {
                    throw new ArithmeticException("Rounding necessary");
                }
                integerAndFraction = getUnscaledValue().divideAndRemainder(Multiplication.powerOf10(_scale));
                if (integerAndFraction[1].signum() != 0) {
                    // It exists a non-zero fractional part 
                    throw new ArithmeticException("Rounding necessary");
                }
                return integerAndFraction[0];
            }
        }

        public long longValue() {
            /* If scale <= -64 there are at least 64 trailing bits zero in 10^(-scale).
             * If the scale is positive and very large the long value could be zero. */
            return ((_scale <= -64) || (_scale > aproxPrecision())
                    ? 0L
                    : toBigInteger().longValue());
        }

        public long longValueExact() {
            return valueExact(64);
        }

        public int intValue() {
            /* If scale <= -32 there are at least 32 trailing bits zero in 10^(-scale).
             * If the scale is positive and very large the long value could be zero. */
            return ((_scale <= -32) || (_scale > aproxPrecision())
                    ? 0
                    : toBigInteger().intValue());
        }

        public int intValueExact() {
            return (int)valueExact(32);
        }

        public short shortValueExact() {
            return (short)valueExact(16);
        }

        public byte byteValueExact() {
            return (byte)valueExact(8);
        }

        public float floatValue() {
            /* A similar code like in doubleValue() could be repeated here,
             * but this simple implementation is quite efficient. */
            float floatResult = signum();
            long powerOfTwo = this._bitLength - (long)(_scale / LOG10_2);
            if ((powerOfTwo < -149) || (floatResult == 0.0f)) {
                // Cases which 'this' is very small
                floatResult *= 0.0f;
            } else if (powerOfTwo > 129) {
                // Cases which 'this' is very large
                floatResult *= float.PositiveInfinity;
            } else {
                floatResult = (float)doubleValue();
            }
            return floatResult;
        }

        public double doubleValue() {
            return double.Parse(this.ToString());
        }

        public BigDecimal ulp() {
            return valueOf(1, _scale);
        }

        private void inplaceRound(MathContext mc) {
            int mcPrecision = mc.getPrecision();
            if (aproxPrecision() - mcPrecision <= 0 || mcPrecision == 0) {
                return;
            }
            int discardedPrecision = precision() - mcPrecision;
            // If no rounding is necessary it returns immediately
            if ((discardedPrecision <= 0)) {
                return;
            }
            // When the number is small perform an efficient rounding
            if (this._bitLength < 64) {
                smallRound(mc, discardedPrecision);
                return;
            }
            // Getting the integer part and the discarded fraction
            BigInteger sizeOfFraction = Multiplication.powerOf10(discardedPrecision);
            BigInteger[] integerAndFraction = getUnscaledValue().divideAndRemainder(sizeOfFraction);
            long newScale = (long)_scale - discardedPrecision;
            int compRem;
            BigDecimal tempBD;
            // If the discarded fraction is non-zero, perform rounding
            if (integerAndFraction[1].signum() != 0) {
                // To check if the discarded fraction >= 0.5
                compRem = (integerAndFraction[1].abs().shiftLeftOneBit().compareTo(sizeOfFraction));
                // To look if there is a carry
                compRem =  roundingBehavior( integerAndFraction[0].testBit(0) ? 1 : 0,
                                             integerAndFraction[1].signum() * (5 + compRem),
                                             mc.getRoundingMode());
                if (compRem != 0) {
                    integerAndFraction[0] = integerAndFraction[0].add(BigInteger.valueOf(compRem));
                }
                tempBD = new BigDecimal(integerAndFraction[0]);
                // If after to add the increment the precision changed, we normalize the size
                if (tempBD.precision() > mcPrecision) {
                    integerAndFraction[0] = integerAndFraction[0].divide(BigInteger.TEN);
                    newScale--;
                }
            }
            // To update all internal fields
            _scale = toIntScale(newScale);
            _precision = mcPrecision;
            setUnscaledValue(integerAndFraction[0]);
        }

        private static int longCompareTo(long value1, long value2) {
            return value1 > value2 ? 1 : (value1 < value2 ? -1 : 0);
        }

        private void smallRound(MathContext mc, int discardedPrecision) {
            long sizeOfFraction = LONG_TEN_POW[discardedPrecision];
            long newScale = (long)_scale - discardedPrecision;
            long unscaledVal = smallValue;
            // Getting the integer part and the discarded fraction
            long integer = unscaledVal / sizeOfFraction;
            long fraction = unscaledVal % sizeOfFraction;
            int compRem;
            // If the discarded fraction is non-zero perform rounding
            if (fraction != 0) {
                // To check if the discarded fraction >= 0.5
                compRem = longCompareTo(Math.Abs(fraction) << 1,sizeOfFraction);
                // To look if there is a carry
                integer += roundingBehavior( ((int)integer) & 1,
                                             Math.Sign(fraction) * (5 + compRem),
                                             mc.getRoundingMode());
                // If after to add the increment the precision changed, we normalize the size
                if (Math.Log10(Math.Abs(integer)) >= mc.getPrecision()) {
                    integer /= 10;
                    newScale--;
                }
            }
            // To update all internal fields
            _scale = toIntScale(newScale);
            _precision = mc.getPrecision();
            smallValue = integer;
            _bitLength = bitLength(integer);
            intVal = null;
        }

        private static int roundingBehavior(int parityBit, int fraction, RoundingMode roundingMode) {
            int increment = 0; // the carry after rounding

            switch (roundingMode) {
            case RoundingMode.UNNECESSARY:
                if (fraction != 0) {
                    throw new ArithmeticException("Rounding necessary");
                }
                break;
            case RoundingMode.UP:
                increment = Math.Sign(fraction);
                break;
            case RoundingMode.DOWN:
                break;
            case RoundingMode.CEILING:
                increment = Math.Max(Math.Sign(fraction), 0);
                break;
            case RoundingMode.FLOOR:
                increment = Math.Min(Math.Sign(fraction), 0);
                break;
            case RoundingMode.HALF_UP:
                if (Math.Abs(fraction) >= 5) {
                    increment = Math.Sign(fraction);
                }
                break;
            case RoundingMode.HALF_DOWN:
                if (Math.Abs(fraction) > 5) {
                    increment = Math.Sign(fraction);
                }
                break;
            case RoundingMode.HALF_EVEN:
                if (Math.Abs(fraction) + parityBit > 5) {
                    increment = Math.Sign(fraction);
                }
                break;
            }
            return increment;
        }

        private long valueExact(int bitLengthOfType) {
            BigInteger bigInteger = toBigIntegerExact();

            if (bigInteger.bitLength() < bitLengthOfType) {
                // It fits in the primitive type
                return bigInteger.longValue();
            }
            throw new ArithmeticException("Rounding necessary");
        }

        private int aproxPrecision() {
            return ((_precision > 0)
                    ? _precision
                    : (int)((this._bitLength - 1) * LOG10_2)) + 1;
        }

        private static int toIntScale(long longScale) {
            if (longScale < Int32.MinValue) {
                throw new ArithmeticException("Overflow");
            } else if (longScale > Int32.MaxValue) {
                throw new ArithmeticException("Underflow");
            } else {
                return (int)longScale;
            }
        }

        private static BigDecimal zeroScaledBy(long longScale) {
            if (longScale == (int) longScale) {
                return valueOf(0,(int)longScale);
            }
            if (longScale >= 0) {
                return new BigDecimal( 0, Int32.MaxValue);
            }
            return new BigDecimal( 0, Int32.MinValue);
        }

        private BigInteger getUnscaledValue() {
            if(intVal == null) {
                intVal = BigInteger.valueOf(smallValue);
            }
            return intVal;
        }
    
        private void setUnscaledValue(BigInteger unscaledValue) {
            this.intVal = unscaledValue;
            this._bitLength = unscaledValue.bitLength();
            if(this._bitLength < 64) {
                this.smallValue = unscaledValue.longValue();
            }
        }
    
        private static int bitLength(long smallValue) {
            if(smallValue < 0) {
                smallValue = ~smallValue;
            }
            return 64 - numberOfLeadingZeros(smallValue);
        }
    
        private static int bitLength(int smallValue) {
            if(smallValue < 0) {
                smallValue = ~smallValue;
            }
            return 32 - numberOfLeadingZeros(smallValue);
        }
    }
}
