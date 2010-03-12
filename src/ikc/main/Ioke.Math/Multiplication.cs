
namespace Ioke.Math {
    using System;

    class Multiplication {
        private Multiplication() {}
        const int whenUseKaratsuba = 63; // an heuristic value
        public static readonly int[] tenPows = {
            1, 10, 100, 1000, 10000, 100000, 1000000, 10000000, 100000000, 1000000000
        };
        public static readonly int[] fivePows = {
            1, 5, 25, 125, 625, 3125, 15625, 78125, 390625,
            1953125, 9765625, 48828125, 244140625, 1220703125
        };

        public static readonly BigInteger[] bigTenPows = new BigInteger[32];

        public static readonly BigInteger[] bigFivePows = new BigInteger[32];
    
        static Multiplication() {
            int i;
            long fivePow = 1L;
        
            for (i = 0; i <= 18; i++) {
                bigFivePows[i] = BigInteger.valueOf(fivePow);
                bigTenPows[i] = BigInteger.valueOf(fivePow << i);
                fivePow *= 5;
            }
            for (; i < bigTenPows.Length; i++) {
                bigFivePows[i] = bigFivePows[i - 1].multiply(bigFivePows[1]);
                bigTenPows[i] = bigTenPows[i - 1].multiply(BigInteger.TEN);
            }
        }

        public static BigInteger multiply(BigInteger x, BigInteger y) {
            return karatsuba(x, y);
        }

        public static BigInteger karatsuba(BigInteger op1, BigInteger op2) {
            BigInteger temp;
            if (op2.numberLength > op1.numberLength) {
                temp = op1;
                op1 = op2;
                op2 = temp;
            }
            if (op2.numberLength < whenUseKaratsuba) {
                return multiplyPAP(op1, op2);
            }
            /*  Karatsuba:  u = u1*B + u0
             *              v = v1*B + v0
             *  u*v = (u1*v1)*B^2 + ((u1-u0)*(v0-v1) + u1*v1 + u0*v0)*B + u0*v0
             */
            // ndiv2 = (op1.numberLength / 2) * 32
            int ndiv2 = (int)(op1.numberLength & 0xFFFFFFFE) << 4;
            BigInteger upperOp1 = op1.shiftRight(ndiv2);
            BigInteger upperOp2 = op2.shiftRight(ndiv2);
            BigInteger lowerOp1 = op1.subtract(upperOp1.shiftLeft(ndiv2));
            BigInteger lowerOp2 = op2.subtract(upperOp2.shiftLeft(ndiv2));

            BigInteger upper = karatsuba(upperOp1, upperOp2);
            BigInteger lower = karatsuba(lowerOp1, lowerOp2);
            BigInteger middle = karatsuba( upperOp1.subtract(lowerOp1),
                                           lowerOp2.subtract(upperOp2));
            middle = middle.add(upper).add(lower);
            middle = middle.shiftLeft(ndiv2);
            upper = upper.shiftLeft(ndiv2 << 1);

            return upper.add(middle).add(lower);
        }

        public static BigInteger multiplyPAP(BigInteger a, BigInteger b) {
            // PRE: a >= b
            int aLen = a.numberLength;
            int bLen = b.numberLength;
            int resLength = aLen + bLen;
            int resSign = (a.sign != b.sign) ? -1 : 1;
            // A special case when both numbers don't exceed int
            if (resLength == 2) {
                long val = unsignedMultAddAdd(a.digits[0], b.digits[0], 0, 0);
                int valueLo = (int)val;
                int valueHi = (int)((long)(((ulong)val) >> 32));
                return ((valueHi == 0)
                        ? new BigInteger(resSign, valueLo)
                        : new BigInteger(resSign, 2, new int[]{valueLo, valueHi}));
            }
            int[] aDigits = a.digits;
            int[] bDigits = b.digits;
            int[] resDigits = new int[resLength];
            // Common case
            multArraysPAP(aDigits, aLen, bDigits, bLen, resDigits);
            BigInteger result = new BigInteger(resSign, resLength, resDigits);
            result.cutOffLeadingZeroes();
            return result;
        }

        public static void multArraysPAP(int[] aDigits, int aLen, int[] bDigits, int bLen, int[] resDigits) {
            if(aLen == 0 || bLen == 0) return;
            
            if(aLen == 1) {
                resDigits[bLen] = multiplyByInt(resDigits, bDigits, bLen, aDigits[0]);
            } else if(bLen == 1) {
                resDigits[aLen] = multiplyByInt(resDigits, aDigits, aLen, bDigits[0]);
            } else {
                multPAP(aDigits, bDigits, resDigits, aLen, bLen);
            }
        }

        public static void multPAP(int[] a, int[] b, int[] t, int aLen, int bLen) {
            if(a == b && aLen == bLen) {
                square(a, aLen, t);
                return;
            }
        
            for(int i = 0; i < aLen; i++){
                long carry = 0;
                int aI = a[i];
                for (int j = 0; j < bLen; j++){
                    carry = unsignedMultAddAdd(aI, b[j], t[i+j], (int)carry);
                    t[i+j] = (int) carry;
                    carry = (long)(((ulong)carry) >> 32);
                }
                t[i+bLen] = (int) carry;
            }
        }

        private static int multiplyByInt(int[] res, int[] a, int aSize, int factor) {
            long carry = 0;
            for (int i = 0; i < aSize; i++) {
                carry = unsignedMultAddAdd(a[i], factor, (int)carry, 0);
                res[i] = (int)carry;
                carry = (long)(((ulong)carry) >> 32);
            }
            return (int)carry;
        }

        public static int multiplyByInt(int[] a, int aSize, int factor) {
            return multiplyByInt(a, a, aSize, factor);
        }
    
        public static BigInteger multiplyByPositiveInt(BigInteger val, int factor) {
            int resSign = val.sign;
            if (resSign == 0) {
                return BigInteger.ZERO;
            }
            int aNumberLength = val.numberLength;
            int[] aDigits = val.digits;
        
            if (aNumberLength == 1) {
                long res = unsignedMultAddAdd(aDigits[0], factor, 0, 0);
                int resLo = (int)res;
                
                int resHi = (int)((long)(((ulong)res) >> 32));
                return ((resHi == 0)
                        ? new BigInteger(resSign, resLo)
                        : new BigInteger(resSign, 2, new int[]{resLo, resHi}));
            }
            // Common case
            int resLength = aNumberLength + 1;
            int[] resDigits = new int[resLength];
        
            resDigits[aNumberLength] = multiplyByInt(resDigits, aDigits, aNumberLength, factor);
            BigInteger result = new BigInteger(resSign, resLength, resDigits);
            result.cutOffLeadingZeroes();
            return result;
        }

        public static BigInteger pow(BigInteger _base, int exponent) {
            // PRE: exp > 0
            BigInteger res = BigInteger.ONE;
            BigInteger acc = _base;

            for (; exponent > 1; exponent >>= 1) {
                if ((exponent & 1) != 0) {
                    // if odd, multiply one more time by acc
                    res = res.multiply(acc);
                }
                // acc = base^(2^i)
                //a limit where karatsuba performs a faster square than the square algorithm
                if ( acc.numberLength == 1 ){
                    acc = acc.multiply(acc); // square
                }
                else{
                    acc = new BigInteger(1, square(acc.digits, acc.numberLength, new int [acc.numberLength<<1]));
                }
            }
            // exponent == 1, multiply one more time
            res = res.multiply(acc);
            return res;
        }

        public static int[] square(int[] a, int aLen, int[] res) {
            long carry;
        
            for(int i = 0; i < aLen; i++){
                carry = 0;            
                for (int j = i+1; j < aLen; j++){
                    carry = unsignedMultAddAdd(a[i], a[j], res[i+j], (int)carry);
                    res[i+j] = (int) carry;
                    carry = (long)(((ulong)carry) >> 32);
                }
                res[i+aLen] = (int) carry;
            }
        
            BitLevel.shiftLeftOneBit(res, res, aLen << 1);
        
            carry = 0;
            for(int i = 0, index = 0; i < aLen; i++, index++){            
                carry = unsignedMultAddAdd(a[i], a[i], res[index],(int)carry);
                res[index] = (int) carry;
                carry = (long)(((ulong)carry) >> 32);
                index++;
                carry += res[index] & 0xFFFFFFFFL;
                res[index] = (int)carry;
                carry = (long)(((ulong)carry) >> 32);
            }
            return res;
        }

        public static BigInteger multiplyByTenPow(BigInteger val, long exp) {
            // PRE: exp >= 0
            return ((exp < tenPows.Length)
                    ? multiplyByPositiveInt(val, tenPows[(int)exp])
                    : val.multiply(powerOf10(exp)));
        }
    
        public static BigInteger powerOf10(long exp) {
            // PRE: exp >= 0
            int intExp = (int)exp;
            // "SMALL POWERS"
            if (exp < bigTenPows.Length) {
                // The largest power that fit in 'long' type
                return bigTenPows[intExp];
            } else if (exp <= 50) {
                // To calculate:    10^exp
                return BigInteger.TEN.pow(intExp);
            } else if (exp <= 1000) {
                // To calculate:    5^exp * 2^exp
                return bigFivePows[1].pow(intExp).shiftLeft(intExp);
            }
        
            if (exp <= Int32.MaxValue) {
                // To calculate:    5^exp * 2^exp
                return bigFivePows[1].pow(intExp).shiftLeft(intExp);
            }
            /*
             * "HUGE POWERS"
             * 
             * This branch probably won't be executed since the power of ten is too
             * big.
             */
            // To calculate:    5^exp
            BigInteger powerOfFive = bigFivePows[1].pow(Int32.MaxValue);
            BigInteger res = powerOfFive;
            long longExp = exp - Int32.MaxValue;
        
            intExp = (int)(exp % Int32.MaxValue);
            while (longExp > Int32.MaxValue) {
                res = res.multiply(powerOfFive);
                longExp -= Int32.MaxValue;
            }
            res = res.multiply(bigFivePows[1].pow(intExp));
            // To calculate:    5^exp << exp
            res = res.shiftLeft(Int32.MaxValue);
            longExp = exp - Int32.MaxValue;
            while (longExp > Int32.MaxValue) {
                res = res.shiftLeft(Int32.MaxValue);
                longExp -= Int32.MaxValue;
            }
            res = res.shiftLeft(intExp);
            return res;
        }
    
        public static BigInteger multiplyByFivePow(BigInteger val, int exp) {
            // PRE: exp >= 0
            if (exp < fivePows.Length) {
                return multiplyByPositiveInt(val, fivePows[exp]);
            } else if (exp < bigFivePows.Length) {
                return val.multiply(bigFivePows[exp]);
            } else {// Large powers of five
                return val.multiply(bigFivePows[1].pow(exp));
            }
        }

        public static long unsignedMultAddAdd(int a, int b, int c, int d) {
            return (a & 0xFFFFFFFFL) * (b & 0xFFFFFFFFL) + (c & 0xFFFFFFFFL) + (d & 0xFFFFFFFFL);
        }
    }
}
