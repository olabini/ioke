
namespace Ioke.Math {
    using System;
    using System.Text;
    class BitLevel {
        private BitLevel() {}

        internal static int bitLength(BigInteger val) {
            if (val.sign == 0) {
                return 0;
            }
            int bLength = (val.numberLength << 5);
            int highDigit = val.digits[val.numberLength - 1];

            if (val.sign < 0) {
                int i = val.getFirstNonzeroDigit();
                // We reduce the problem to the positive case.
                if (i == val.numberLength - 1) {
                    highDigit--;
                }
            }
            // Subtracting all sign bits
            bLength -= BigDecimal.numberOfLeadingZeros(highDigit);
            return bLength;
        }

        internal static int bitCount(BigInteger val) {
            int bCount = 0;

            if (val.sign == 0) {
                return 0;
            }
        
            int i = val.getFirstNonzeroDigit();;
            if (val.sign > 0) {
                for ( ; i < val.numberLength; i++) {
                    bCount += BigDecimal.bitCount(val.digits[i]);
                }
            } else {// (sign < 0)
                // this digit absorbs the carry
                bCount += BigDecimal.bitCount(-val.digits[i]);
                for (i++; i < val.numberLength; i++) {
                    bCount += BigDecimal.bitCount(~val.digits[i]);
                }
                // We take the complement sum:
                bCount = (val.numberLength << 5) - bCount;
            }
            return bCount;
        }

        internal static bool testBit(BigInteger val, int n) {
            // PRE: 0 <= n < val.bitLength()
            return ((val.digits[n >> 5] & (1 << (n & 31))) != 0);
        }

        internal static bool nonZeroDroppedBits(int numberOfBits, int[] digits) {
            int intCount = numberOfBits >> 5;
            int bitCount = numberOfBits & 31;
            int i;

            for (i = 0; (i < intCount) && (digits[i] == 0); i++) {
                ;
            }
            return ((i != intCount) || (digits[i] << (32 - bitCount) != 0));
        }

        internal static BigInteger shiftLeft(BigInteger source, int count) {
            int intCount = count >> 5;
            count &= 31; // %= 32
            int resLength = source.numberLength + intCount
                + ( ( count == 0 ) ? 0 : 1 );
            int[] resDigits = new int[resLength];

            shiftLeft(resDigits, source.digits, intCount, count);
            BigInteger result = new BigInteger(source.sign, resLength, resDigits);
            result.cutOffLeadingZeroes();
            return result;
        }

        internal static void inplaceShiftLeft(BigInteger val, int count) {
            int intCount = count >> 5; // count of integers
            val.numberLength += intCount
                + ( BigDecimal
                    .numberOfLeadingZeros(val.digits[val.numberLength - 1])
                    - ( count & 31 ) >= 0 ? 0 : 1 );
            shiftLeft(val.digits, val.digits, intCount, count & 31);
            val.cutOffLeadingZeroes();
            val.unCache();
        }
    
        internal static void shiftLeft(int[] result, int[] source, int intCount, int count) {
            if (count == 0) {
                Array.Copy(source, 0, result, intCount, result.Length
                                 - intCount);
            } else {
                int rightShiftCount = 32 - count;

                result[result.Length - 1] = 0;
                for (int i = result.Length - 1; i > intCount; i--) {
                    result[i] |= (int)(((uint)source[i - intCount - 1]) >> rightShiftCount);
                    result[i - 1] = source[i - intCount - 1] << count;
                }
            }
        
            for (int i = 0; i < intCount; i++) {
                result[i] = 0;
            }
        }

        internal static void shiftLeftOneBit(int[] result, int[] source, int srcLen) {
            int carry = 0;
            for (int i = 0; i < srcLen; i++) {
                int val = source[i];
                result[i] = (val << 1) | carry;
                carry = (int)(((uint)val) >> 31);
            }
            if (carry != 0) {
                result[srcLen] = carry;
            }
        }

        internal static BigInteger shiftLeftOneBit(BigInteger source) {
            int srcLen = source.numberLength;
            int resLen = srcLen + 1;
            int[] resDigits = new int[resLen];
            shiftLeftOneBit(resDigits, source.digits, srcLen);
            BigInteger result = new BigInteger(source.sign, resLen, resDigits);
            result.cutOffLeadingZeroes();
            return result;
        }

        internal static BigInteger shiftRight(BigInteger source, int count) {
            int intCount = count >> 5; // count of integers
            count &= 31; // count of remaining bits
            if (intCount >= source.numberLength) {
                return ((source.sign < 0) ? BigInteger.MINUS_ONE : BigInteger.ZERO);
            }
            int i;
            int resLength = source.numberLength - intCount;
            int[] resDigits = new int[resLength + 1];

            shiftRight(resDigits, resLength, source.digits, intCount, count);
            if (source.sign < 0) {
                // Checking if the dropped bits are zeros (the remainder equals to
                // 0)
                for (i = 0; (i < intCount) && (source.digits[i] == 0); i++) {
                    ;
                }
                // If the remainder is not zero, add 1 to the result
                if ((i < intCount)
                    || ((count > 0) && ((source.digits[i] << (32 - count)) != 0))) {
                    for (i = 0; (i < resLength) && (resDigits[i] == -1); i++) {
                        resDigits[i] = 0;
                    }
                    if (i == resLength) {
                        resLength++;
                    }
                    resDigits[i]++;
                }
            }
            BigInteger result = new BigInteger(source.sign, resLength, resDigits);
            result.cutOffLeadingZeroes();
            return result;
        }

        internal static void inplaceShiftRight(BigInteger val, int count) {
            int sign = val.signum();
            if (count == 0 || val.signum() == 0)
                return;
            int intCount = count >> 5; // count of integers
            val.numberLength -= intCount;
            if (!shiftRight(val.digits, val.numberLength, val.digits, intCount,
                            count & 31)
                && sign < 0) {
                // remainder not zero: add one to the result
                int i;
                for (i = 0; ( i < val.numberLength ) && ( val.digits[i] == -1 ); i++) {
                    val.digits[i] = 0;
                }
                if (i == val.numberLength) {
                    val.numberLength++;
                }
                val.digits[i]++;
            }
            val.cutOffLeadingZeroes();
            val.unCache();
        }

        internal static bool shiftRight(int[] result, int resultLen, int[] source,
                                  int intCount, int count) {
            int i;
            bool allZero = true;
            for (i = 0; i < intCount; i++)
                allZero &= source[i] == 0;
            if (count == 0) {
                Array.Copy(source, intCount, result, 0, resultLen);
                i = resultLen;
            } else {
                int leftShiftCount = 32 - count;

                allZero &= ( source[i] << leftShiftCount ) == 0;
                for (i = 0; i < resultLen - 1; i++) {
                    result[i] = ( (int)(((uint)source[i + intCount]) >> count) )
                        | ( source[i + intCount + 1] << leftShiftCount );
                }
                result[i] = (int)(((uint)( source[i + intCount]) >> count) );
                i++;
            }
        
            return allZero;
        }

        internal static BigInteger flipBit(BigInteger val, int n){
            int resSign = (val.sign == 0) ? 1 : val.sign;
            int intCount = n >> 5;
            int bitN = n & 31;
            int resLength = Math.Max(intCount + 1, val.numberLength) + 1;
            int[] resDigits = new int[resLength];
            int i;
        
            int bitNumber = 1 << bitN;
            Array.Copy(val.digits, 0, resDigits, 0, val.numberLength);
        
            if (val.sign < 0) {
                if (intCount >= val.numberLength) {
                    resDigits[intCount] = bitNumber;
                } else {
                    //val.sign<0 y intCount < val.numberLength
                    int firstNonZeroDigit = val.getFirstNonzeroDigit();
                    if (intCount > firstNonZeroDigit) {
                        resDigits[intCount] ^= bitNumber;
                    } else if (intCount < firstNonZeroDigit) {
                        resDigits[intCount] = -bitNumber;
                        for (i=intCount + 1; i < firstNonZeroDigit; i++) {
                            resDigits[i]=-1;
                        }
                        resDigits[i] = resDigits[i]--;
                    } else {
                        i = intCount;
                        resDigits[i] = -((-resDigits[intCount]) ^ bitNumber);
                        if (resDigits[i] == 0) {
                            for (i++; resDigits[i] == -1 ; i++) {
                                resDigits[i] = 0;
                            }
                            resDigits[i]++;
                        }
                    }
                }
            } else {//case where val is positive
                resDigits[intCount] ^= bitNumber;
            }
            BigInteger result = new BigInteger(resSign, resLength, resDigits);
            result.cutOffLeadingZeroes();
            return result;
        }
    }
}
