namespace Ioke.Math {
    using System;
    using System.Text;

    public class BigInteger {
        internal int[] digits;
        internal int numberLength;
        internal int sign;

        public static readonly BigInteger ZERO = new BigInteger(0, 0);
        public static readonly BigInteger ONE = new BigInteger(1, 1);
        public static readonly BigInteger TEN = new BigInteger(1, 10);
        internal static readonly BigInteger MINUS_ONE = new BigInteger(-1, 1);
        internal const int EQUALS = 0;
        internal const int GREATER = 1;
        internal const int LESS = -1;
        static readonly BigInteger[] SMALL_VALUES = { ZERO, ONE, new BigInteger(1, 2),
                                                   new BigInteger(1, 3), new BigInteger(1, 4), new BigInteger(1, 5),
                                                   new BigInteger(1, 6), new BigInteger(1, 7), new BigInteger(1, 8),
                                                   new BigInteger(1, 9), TEN };

        static readonly BigInteger[] TWO_POWS;

        static BigInteger() {
            TWO_POWS = new BigInteger[32];
            for(int i = 0; i < TWO_POWS.Length; i++) {
                TWO_POWS[i] = BigInteger.valueOf(1L<<i);
            }
        }

        private int firstNonzeroDigit = -2;
        private int hashCode = 0;

        public BigInteger(int numBits, Random rnd) {
            if (numBits < 0) {
                throw new ArgumentException("numBits must be non-negative");
            }
            if (numBits == 0) {
                sign = 0;
                numberLength = 1;
                digits = new int[] { 0 };
            } else {
                sign = 1;
                numberLength = (numBits + 31) >> 5;
                digits = new int[numberLength];
                for (int i = 0; i < numberLength; i++) {
                    digits[i] = rnd.Next();
                }
                // Using only the necessary bits
                digits[numberLength - 1] = (int)(((uint)digits[numberLength - 1]) >> (-numBits) & 31);
                cutOffLeadingZeroes();
            }
        }

        public BigInteger(int bitLength, int certainty, Random rnd) {
            if (bitLength < 2) {
                throw new ArithmeticException("bitLength < 2");
            }
            BigInteger me = Primality.consBigInteger(bitLength, certainty, rnd);
            sign = me.sign;
            numberLength = me.numberLength;
            digits = me.digits;
        }

        public BigInteger(String val) : this(val, 10) {
        }

        public BigInteger(String val, int radix) {
            if (val == null) {
                throw new NullReferenceException();
            }
            if ((radix < 0) || (radix > 26)) {
                throw new System.FormatException("Radix out of range");
            }
            if (val.Length == 0) {
                throw new System.FormatException("Zero length BigInteger");
            }
            setFromString(this, val, radix);
        }

        public BigInteger(int signum, byte[] magnitude) {
            if (magnitude == null) {
                throw new NullReferenceException();
            }
            if ((signum < -1) || (signum > 1)) {
                // math.13=Invalid signum value
                throw new System.FormatException("Invalid signum value");
            }
            if (signum == 0) {
                foreach (byte element in magnitude) {
                    if (element != 0) {
                        // math.14=signum-magnitude mismatch
                        throw new System.FormatException("signum-magnitude mismatch");
                    }
                }
            }
            if (magnitude.Length == 0) {
                sign = 0;
                numberLength = 1;
                digits = new int[] { 0 };
            } else {
                sign = signum;
                putBytesPositiveToIntegers(magnitude);
                cutOffLeadingZeroes();
            }
        }

        public BigInteger(byte[] val) {
            if (val.Length == 0) {
                // math.12=Zero length BigInteger
                throw new System.FormatException("Zero length BigInteger");
            }
            if (val[0] < 0) {
                sign = -1;
                putBytesNegativeToIntegers(val);
            } else {
                sign = 1;
                putBytesPositiveToIntegers(val);
            }
            cutOffLeadingZeroes();
        }

        internal BigInteger(int sign, int value) {
            this.sign = sign;
            numberLength = 1;
            digits = new int[] { value };
        }

        internal BigInteger(int sign, int numberLength, int[] digits) {
            this.sign = sign;
            this.numberLength = numberLength;
            this.digits = digits;
        }

        internal BigInteger(int sign, long val) {
            // PRE: (val >= 0) && (sign >= -1) && (sign <= 1)
            this.sign = sign;
            if (((ulong)val & 0xFFFFFFFF00000000L) == 0) {
                // It fits in one 'int'
                numberLength = 1;
                digits = new int[] { (int) val };
            } else {
                numberLength = 2;
                digits = new int[] { (int) val, (int) (val >> 32) };
            }
        }

        internal BigInteger(int signum, int[] digits) {
            if (digits.Length == 0) {
                sign = 0;
                numberLength = 1;
                this.digits = new int[] { 0 };
            } else {
                sign = signum;
                numberLength = digits.Length;
                this.digits = digits;
                cutOffLeadingZeroes();
            }
        }

        public static BigInteger valueOf(long val) {
            if (val < 0) {
                if (val != -1) {
                    return new BigInteger(-1, -val);
                }
                return MINUS_ONE;
            } else if (val <= 10) {
                return SMALL_VALUES[(int) val];
            } else {// (val > 10)
                return new BigInteger(1, val);
            }
        }

        public byte[] toByteArray() {
            if (this.sign == 0) {
                return new byte[] { 0 };
            }
            BigInteger temp = this;
            int bitLen = bitLength();
            int iThis = getFirstNonzeroDigit();
            int bytesLen = (bitLen >> 3) + 1;
            /*
             * Puts the little-endian int array representing the magnitude of this
             * BigInteger into the big-endian byte array.
             */
            byte[] bytes = new byte[bytesLen];
            int firstByteNumber = 0;
            int highBytes;
            int digitIndex = 0;
            int bytesInInteger = 4;
            int digit;
            int hB;

            if (bytesLen - (numberLength << 2) == 1) {
                bytes[0] = (byte) ((sign < 0) ? -1 : 0);
                highBytes = 4;
                firstByteNumber++;
            } else {
                hB = bytesLen & 3;
                highBytes = (hB == 0) ? 4 : hB;
            }

            digitIndex = iThis;
            bytesLen -= iThis << 2;

            if (sign < 0) {
                digit = -temp.digits[digitIndex];
                digitIndex++;
                if (digitIndex == numberLength) {
                    bytesInInteger = highBytes;
                }
                for (int i = 0; i < bytesInInteger; i++, digit >>= 8) {
                    bytes[--bytesLen] = (byte) digit;
                }
                while (bytesLen > firstByteNumber) {
                    digit = ~temp.digits[digitIndex];
                    digitIndex++;
                    if (digitIndex == numberLength) {
                        bytesInInteger = highBytes;
                    }
                    for (int i = 0; i < bytesInInteger; i++, digit >>= 8) {
                        bytes[--bytesLen] = (byte) digit;
                    }
                }
            } else {
                while (bytesLen > firstByteNumber) {
                    digit = temp.digits[digitIndex];
                    digitIndex++;
                    if (digitIndex == numberLength) {
                        bytesInInteger = highBytes;
                    }
                    for (int i = 0; i < bytesInInteger; i++, digit >>= 8) {
                        bytes[--bytesLen] = (byte) digit;
                    }
                }
            }
            return bytes;
        }

        private static void setFromString(BigInteger bi, String val, int radix) {
            int sign;
            int[] digits;
            int numberLength;
            int stringLength = val.Length;
            int startChar;
            int endChar = stringLength;

            if (val[0] == '-') {
                sign = -1;
                startChar = 1;
                stringLength--;
            } else {
                sign = 1;
                startChar = 0;
            }
            /*
             * We use the following algorithm: split a string into portions of n
             * characters and convert each portion to an integer according to the
             * radix. Then convert an exp(radix, n) based number to binary using the
             * multiplication method. See D. Knuth, The Art of Computer Programming,
             * vol. 2.
             */

            int charsPerInt = Conversion.digitFitInInt[radix];
            int bigRadixDigitsLength = stringLength / charsPerInt;
            int topChars = stringLength % charsPerInt;

            if (topChars != 0) {
                bigRadixDigitsLength++;
            }
            digits = new int[bigRadixDigitsLength];
            // Get the maximal power of radix that fits in int
            int bigRadix = Conversion.bigRadices[radix - 2];
            // Parse an input string and accumulate the BigInteger's magnitude
            int digitIndex = 0; // index of digits array
            int substrEnd = startChar + ((topChars == 0) ? charsPerInt : topChars);
            int newDigit;

            for (int substrStart = startChar; substrStart < endChar; substrStart = substrEnd, substrEnd = substrStart
                     + charsPerInt) {
                int bigRadixDigit = Convert.ToInt32(val.Substring(substrStart,
                                                                  substrEnd - substrStart), radix);
                newDigit = Multiplication.multiplyByInt(digits, digitIndex,
                                                        bigRadix);
                newDigit += Elementary
                    .inplaceAdd(digits, digitIndex, bigRadixDigit);
                digits[digitIndex++] = newDigit;
            }
            numberLength = digitIndex;
            bi.sign = sign;
            bi.numberLength = numberLength;
            bi.digits = digits;
            bi.cutOffLeadingZeroes();
        }

        public BigInteger abs() {
            return ((sign < 0) ? new BigInteger(1, numberLength, digits) : this);
        }

        public BigInteger negate() {
            return ((sign == 0) ? this
                    : new BigInteger(-sign, numberLength, digits));
        }

        public BigInteger add(BigInteger val) {
            return Elementary.add(this, val);
        }

        public BigInteger subtract(BigInteger val) {
            return Elementary.subtract(this, val);
        }

        public int signum() {
            return sign;
        }

        public BigInteger shiftRight(int n) {
            if ((n == 0) || (sign == 0)) {
                return this;
            }
            return ((n > 0) ? BitLevel.shiftRight(this, n) : BitLevel.shiftLeft(
                        this, -n));
        }

        public BigInteger shiftLeft(int n) {
            if ((n == 0) || (sign == 0)) {
                return this;
            }
            return ((n > 0) ? BitLevel.shiftLeft(this, n) : BitLevel.shiftRight(
                        this, -n));
        }

        internal BigInteger shiftLeftOneBit() {
            return (sign == 0) ? this : BitLevel.shiftLeftOneBit(this);
        }

        public int bitLength() {
            return BitLevel.bitLength(this);
        }

        public bool testBit(int n) {
            if (n == 0) {
                return ((digits[0] & 1) != 0);
            }
            if (n < 0) {
                throw new ArithmeticException("Negative bit address");
            }
            int intCount = n >> 5;
            if (intCount >= numberLength) {
                return (sign < 0);
            }
            int digit = digits[intCount];
            n = (1 << (n & 31)); // int with 1 set to the needed position
            if (sign < 0) {
                int firstNonZeroDigit = getFirstNonzeroDigit();
                if (intCount < firstNonZeroDigit) {
                    return false;
                } else if (firstNonZeroDigit == intCount) {
                    digit = -digit;
                } else {
                    digit = ~digit;
                }
            }
            return ((digit & n) != 0);
        }

        public BigInteger setBit(int n) {
            if (!testBit(n)) {
                return BitLevel.flipBit(this, n);
            }
            return this;
        }

        public BigInteger clearBit(int n) {
            if (testBit(n)) {
                return BitLevel.flipBit(this, n);
            }
            return this;
        }

        public BigInteger flipBit(int n) {
            if (n < 0) {
                throw new ArithmeticException("Negative bit address");
            }
            return BitLevel.flipBit(this, n);
        }

        public int getLowestSetBit() {
            if (sign == 0) {
                return -1;
            }
            // (sign != 0) implies that exists some non zero digit
            int i = getFirstNonzeroDigit();
            return ((i << 5) + BigDecimal.numberOfTrailingZeros(digits[i]));
        }

        public int bitCount() {
            return BitLevel.bitCount(this);
        }

        public BigInteger not() {
            return Logical.not(this);
        }

        public BigInteger and(BigInteger val) {
            return Logical.and(this, val);
        }

        public BigInteger or(BigInteger val) {
            return Logical.or(this, val);
        }

        public BigInteger xor(BigInteger val) {
            return Logical.xor(this, val);
        }

        public BigInteger andNot(BigInteger val) {
            return Logical.andNot(this, val);
        }

        public int intValue() {
            return (sign * digits[0]);
        }

        public long longValue() {
            long value = (numberLength > 1) ? (((long) digits[1]) << 32)
                | (digits[0] & 0xFFFFFFFFL) : (digits[0] & 0xFFFFFFFFL);
            return (sign * value);
        }

        public float floatValue() {
            return (float) doubleValue();
        }

        public double doubleValue() {
            return Conversion.bigInteger2Double(this);
        }

        public int compareTo(BigInteger val) {
            if (sign > val.sign) {
                return GREATER;
            }
            if (sign < val.sign) {
                return LESS;
            }
            if (numberLength > val.numberLength) {
                return sign;
            }
            if (numberLength < val.numberLength) {
                return -val.sign;
            }
            // Equal sign and equal numberLength
            return (sign * Elementary.compareArrays(digits, val.digits,
                                                    numberLength));
        }

        public BigInteger min(BigInteger val) {
            return ((this.compareTo(val) == LESS) ? this : val);
        }

        public BigInteger max(BigInteger val) {
            return ((this.compareTo(val) == GREATER) ? this : val);
        }

        public override int GetHashCode() {
            if (hashCode != 0) {
                return hashCode;
            }
            for (int i = 0; i < digits.Length; i++) {
                hashCode = (hashCode * 33 + (int)(digits[i] & 0xffffffff));
            }
            hashCode = hashCode * sign;
            return hashCode;
        }

        public override bool Equals(object x) {
            if (this == x) {
                return true;
            }
            if (x is BigInteger) {
                BigInteger x1 = (BigInteger) x;
                return sign == x1.sign && numberLength == x1.numberLength
                    && equalsArrays(x1.digits);
            }
            return false;
        }

        bool equalsArrays(int[] b) {
            int i;
            for (i = numberLength - 1; (i >= 0) && (digits[i] == b[i]); i--) {
                // Empty
            }
            return i < 0;
        }

        public override string ToString(){
            return Conversion.toDecimalScaledString(this, 0);
        }

        public String toString(int radix) {
            return Conversion.bigInteger2String(this, radix);
        }

        public BigInteger gcd(BigInteger val) {
            BigInteger val1 = this.abs();
            BigInteger val2 = val.abs();
            // To avoid a possible division by zero
            if (val1.signum() == 0) {
                return val2;
            } else if (val2.signum() == 0) {
                return val1;
            }

            // Optimization for small operands
            // (op2.bitLength() < 64) and (op1.bitLength() < 64)
            if (((val1.numberLength == 1) || ((val1.numberLength == 2) && (val1.digits[1] > 0)))
                && (val2.numberLength == 1 || (val2.numberLength == 2 && val2.digits[1] > 0))) {
                return BigInteger.valueOf(Division.gcdBinary(val1.longValue(), val2
                                                             .longValue()));
            }

            return Division.gcdBinary(val1.copy(), val2.copy());

        }

        public BigInteger multiply(BigInteger val) {
            // This let us to throw NullReferenceException when val == null
            if (val.sign == 0) {
                return ZERO;
            }
            if (sign == 0) {
                return ZERO;
            }
            return Multiplication.multiply(this, val);
        }

        public BigInteger pow(int exp) {
            if (exp < 0) {
                // math.16=Negative exponent
                throw new ArithmeticException("Negative exponent");
            }
            if (exp == 0) {
                return ONE;
            } else if (exp == 1 || Equals(ONE) || Equals(ZERO)) {
                return this;
            }

            // if even take out 2^x factor which we can
            // calculate by shifting.
            if (!testBit(0)) {
                int x = 1;
                while (!testBit(x)) {
                    x++;
                }
                return getPowerOfTwo(x*exp).multiply(this.shiftRight(x).pow(exp));
            }
            return Multiplication.pow(this, exp);
        }

        public BigInteger[] divideAndRemainder(BigInteger divisor) {
            int divisorSign = divisor.sign;
            if (divisorSign == 0) {
                throw new ArithmeticException("BigInteger divide by zero");
            }
            int divisorLen = divisor.numberLength;
            int[] divisorDigits = divisor.digits;
            if (divisorLen == 1) {
                return Division.divideAndRemainderByInteger(this, divisorDigits[0],
                                                            divisorSign);
            }


            // res[0] is a quotient and res[1] is a remainder:
            int[] thisDigits = digits;
            int thisLen = numberLength;
            int cmp = (thisLen != divisorLen) ? ((thisLen > divisorLen) ? 1 : -1)
                : Elementary.compareArrays(thisDigits, divisorDigits, thisLen);
            if (cmp < 0) {
                return new BigInteger[] { ZERO, this };
            }
            int thisSign = sign;
            int quotientLength = thisLen - divisorLen + 1;
            int remainderLength = divisorLen;
            int quotientSign = ((thisSign == divisorSign) ? 1 : -1);
            int[] quotientDigits = new int[quotientLength];
            int[] remainderDigits = Division.divide(quotientDigits, quotientLength,
                                                    thisDigits, thisLen, divisorDigits, divisorLen);
            BigInteger result0 = new BigInteger(quotientSign, quotientLength,
                                                quotientDigits);
            BigInteger result1 = new BigInteger(thisSign, remainderLength,
                                                remainderDigits);
            result0.cutOffLeadingZeroes();
            result1.cutOffLeadingZeroes();
            return new BigInteger[] { result0, result1 };
        }

        public BigInteger divide(BigInteger divisor) {
            if (divisor.sign == 0) {
                throw new ArithmeticException("BigInteger divide by zero");
            }
            int divisorSign = divisor.sign;
            if (divisor.isOne()) {
                return ((divisor.sign > 0) ? this : this.negate());
            }
            int thisSign = sign;
            int thisLen = numberLength;
            int divisorLen = divisor.numberLength;
            if (thisLen + divisorLen == 2) {
                long val = (digits[0] & 0xFFFFFFFFL)
                    / (divisor.digits[0] & 0xFFFFFFFFL);
                if (thisSign != divisorSign) {
                    val = -val;
                }
                return valueOf(val);
            }
            int cmp = ((thisLen != divisorLen) ? ((thisLen > divisorLen) ? 1 : -1)
                       : Elementary.compareArrays(digits, divisor.digits, thisLen));
            if (cmp == EQUALS) {
                return ((thisSign == divisorSign) ? ONE : MINUS_ONE);
            }
            if (cmp == LESS) {
                return ZERO;
            }
            int resLength = thisLen - divisorLen + 1;
            int[] resDigits = new int[resLength];
            int resSign = ((thisSign == divisorSign) ? 1 : -1);
            if (divisorLen == 1) {
                Division.divideArrayByInt(resDigits, digits, thisLen,
                                          divisor.digits[0]);
            } else {
                Division.divide(resDigits, resLength, digits, thisLen,
                                divisor.digits, divisorLen);
            }
            BigInteger result = new BigInteger(resSign, resLength, resDigits);
            result.cutOffLeadingZeroes();
            return result;
        }

        public BigInteger remainder(BigInteger divisor) {
            if (divisor.sign == 0) {
                throw new ArithmeticException("BigInteger divide by zero");
            }
            int thisLen = numberLength;
            int divisorLen = divisor.numberLength;
            if (((thisLen != divisorLen) ? ((thisLen > divisorLen) ? 1 : -1)
                 : Elementary.compareArrays(digits, divisor.digits, thisLen)) == LESS) {
                return this;
            }
            int resLength = divisorLen;
            int[] resDigits = new int[resLength];
            if (resLength == 1) {
                resDigits[0] = Division.remainderArrayByInt(digits, thisLen,
                                                            divisor.digits[0]);
            } else {
                int qLen = thisLen - divisorLen + 1;
                resDigits = Division.divide(null, qLen, digits, thisLen,
                                            divisor.digits, divisorLen);
            }
            BigInteger result = new BigInteger(sign, resLength, resDigits);
            result.cutOffLeadingZeroes();
            return result;
        }

        public BigInteger modInverse(BigInteger m) {
            if (m.sign <= 0) {
                throw new ArithmeticException("BigInteger: modulus not positive");
            }
            // If both are even, no inverse exists
            if (!(testBit(0) || m.testBit(0))) {
                throw new ArithmeticException("BigInteger not invertible.");
            }
            if (m.isOne()) {
                return ZERO;
            }

            // From now on: (m > 1)
            BigInteger res = Division.modInverseMontgomery(abs().mod(m), m);
            if (res.sign == 0) {
                throw new ArithmeticException("BigInteger not invertible.");
            }

            res = ((sign < 0) ? m.subtract(res) : res);
            return res;

        }

        public BigInteger modPow(BigInteger exponent, BigInteger m) {
            if (m.sign <= 0) {
                throw new ArithmeticException("BigInteger: modulus not positive");
            }
            BigInteger _base = this;

            if (m.isOne() | (exponent.sign > 0 & _base.sign == 0)) {
                return BigInteger.ZERO;
            }
            if (_base.sign == 0 && exponent.sign == 0) {
                return BigInteger.ONE;
            }
            if (exponent.sign < 0) {
                _base = modInverse(m);
                exponent = exponent.negate();
            }
            // From now on: (m > 0) and (exponent >= 0)
            BigInteger res = (m.testBit(0)) ? Division.oddModPow(_base.abs(),
                                                                 exponent, m) : Division.evenModPow(_base.abs(), exponent, m);
            if ((_base.sign < 0) && exponent.testBit(0)) {
                // -b^e mod m == ((-1 mod m) * (b^e mod m)) mod m
                res = m.subtract(BigInteger.ONE).multiply(res).mod(m);
            }
            // else exponent is even, so base^exp is positive
            return res;
        }

        public BigInteger mod(BigInteger m) {
            if (m.sign <= 0) {
                throw new ArithmeticException("BigInteger: modulus not positive");
            }
            BigInteger rem = remainder(m);
            return ((rem.sign < 0) ? rem.add(m) : rem);
        }

        public bool isProbablePrime(int certainty) {
            return Primality.isProbablePrime(abs(), certainty);
        }

        public BigInteger nextProbablePrime() {
            if (sign < 0) {
                throw new ArithmeticException("start < 0: " + this);
            }
            return Primality.nextProbablePrime(this);
        }

        public static BigInteger probablePrime(int bitLength, Random rnd) {
            return new BigInteger(bitLength, 100, rnd);
        }

        internal void cutOffLeadingZeroes() {
            while ((numberLength > 0) && (digits[--numberLength] == 0)) {
                // Empty
            }
            if (digits[numberLength++] == 0) {
                sign = 0;
            }
        }

        internal bool isOne() {
            return ((numberLength == 1) && (digits[0] == 1));
        }

        private void putBytesPositiveToIntegers(byte[] byteValues) {
            int bytesLen = byteValues.Length;
            int highBytes = bytesLen & 3;
            numberLength = (bytesLen >> 2) + ((highBytes == 0) ? 0 : 1);
            digits = new int[numberLength];
            int i = 0;
            // Put bytes to the int array starting from the end of the byte array
            while (bytesLen > highBytes) {
                digits[i++] = (byteValues[--bytesLen] & 0xFF)
                    | (byteValues[--bytesLen] & 0xFF) << 8
                    | (byteValues[--bytesLen] & 0xFF) << 16
                    | (byteValues[--bytesLen] & 0xFF) << 24;
            }
            // Put the first bytes in the highest element of the int array
            for (int j = 0; j < bytesLen; j++) {
                digits[i] = (digits[i] << 8) | (byteValues[j] & 0xFF);
            }
        }

        private void putBytesNegativeToIntegers(byte[] byteValues) {
            int bytesLen = byteValues.Length;
            int highBytes = bytesLen & 3;
            numberLength = (bytesLen >> 2) + ((highBytes == 0) ? 0 : 1);
            digits = new int[numberLength];
            int i = 0;
            // Setting the sign
            digits[numberLength - 1] = -1;
            // Put bytes to the int array starting from the end of the byte array
            while (bytesLen > highBytes) {
                digits[i] = (byteValues[--bytesLen] & 0xFF)
                    | (byteValues[--bytesLen] & 0xFF) << 8
                    | (byteValues[--bytesLen] & 0xFF) << 16
                    | (byteValues[--bytesLen] & 0xFF) << 24;
                if (digits[i] != 0) {
                    digits[i] = -digits[i];
                    firstNonzeroDigit = i;
                    i++;
                    while (bytesLen > highBytes) {
                        digits[i] = (byteValues[--bytesLen] & 0xFF)
                            | (byteValues[--bytesLen] & 0xFF) << 8
                            | (byteValues[--bytesLen] & 0xFF) << 16
                            | (byteValues[--bytesLen] & 0xFF) << 24;
                        digits[i] = ~digits[i];
                        i++;
                    }
                    break;
                }
                i++;
            }
            if (highBytes != 0) {
                // Put the first bytes in the highest element of the int array
                if (firstNonzeroDigit != -2) {
                    for (int j = 0; j < bytesLen; j++) {
                        digits[i] = (digits[i] << 8) | (byteValues[j] & 0xFF);
                    }
                    digits[i] = ~digits[i];
                } else {
                    for (int j = 0; j < bytesLen; j++) {
                        digits[i] = (digits[i] << 8) | (byteValues[j] & 0xFF);
                    }
                    digits[i] = -digits[i];
                }
            }
        }

        internal int getFirstNonzeroDigit() {
            if (firstNonzeroDigit == -2) {
                int i;
                if (this.sign == 0) {
                    i = -1;
                } else {
                    for (i = 0; digits[i] == 0; i++) {
                        // Empty
                    }
                }
                firstNonzeroDigit = i;
            }
            return firstNonzeroDigit;
        }

        /*
         * Returns a copy of the current instance to achieve immutability
         */
        internal BigInteger copy() {
            int[] copyDigits = new int[numberLength];
            Array.Copy(digits, copyDigits, numberLength);
            return new BigInteger(sign, numberLength, copyDigits);
        }

        internal void unCache() {
            firstNonzeroDigit = -2;
        }

        internal static BigInteger getPowerOfTwo(int exp) {
            if(exp < TWO_POWS.Length) {
                return TWO_POWS[exp];
            }
            int intCount = exp >> 5;
            int bitN = exp & 31;
            int[] resDigits = new int[intCount+1];
            resDigits[intCount] = 1 << bitN;
            return new BigInteger(1, intCount+1, resDigits);
        }
    }
}
