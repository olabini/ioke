namespace Ioke.Math {
    using System;
    using System.Text;

    class Elementary {
        private Elementary() {
        }

        internal static int compareArrays(int[] a, int[] b, int size) {
            int i;
            for (i = size - 1; (i >= 0) && (a[i] == b[i]); i--) {
                ;
            }
            return ((i < 0) ? BigInteger.EQUALS
                    : (a[i] & 0xFFFFFFFFL) < (b[i] & 0xFFFFFFFFL) ? BigInteger.LESS
                    : BigInteger.GREATER);
        }

        internal static BigInteger add(BigInteger op1, BigInteger op2) {
            int[] resDigits;
            int resSign;
            int op1Sign = op1.sign;
            int op2Sign = op2.sign;

            if (op1Sign == 0) {
                return op2;
            }
            if (op2Sign == 0) {
                return op1;
            }
            int op1Len = op1.numberLength;
            int op2Len = op2.numberLength;

            if (op1Len + op2Len == 2) {
                long a = (op1.digits[0] & 0xFFFFFFFFL);
                long b = (op2.digits[0] & 0xFFFFFFFFL);
                long ress;
                int valueLo;
                int valueHi;

                if (op1Sign == op2Sign) {
                    ress = a + b;
                    valueLo = (int) ress;
                    valueHi = (int) ((long)(((ulong)ress) >> 32));
                    return ((valueHi == 0) ? new BigInteger(op1Sign, valueLo)
                            : new BigInteger(op1Sign, 2, new int[] { valueLo,
                                                                     valueHi }));
                }
                return BigInteger.valueOf((op1Sign < 0) ? (b - a) : (a - b));
            } else if (op1Sign == op2Sign) {
                resSign = op1Sign;
                // an augend should not be shorter than addend
                resDigits = (op1Len >= op2Len) ? add(op1.digits, op1Len,
                                                     op2.digits, op2Len) : add(op2.digits, op2Len, op1.digits,
                                                                               op1Len);
            } else { // signs are different
                int cmp = ((op1Len != op2Len) ? ((op1Len > op2Len) ? 1 : -1)
                           : compareArrays(op1.digits, op2.digits, op1Len));

                if (cmp == BigInteger.EQUALS) {
                    return BigInteger.ZERO;
                }
                // a minuend should not be shorter than subtrahend
                if (cmp == BigInteger.GREATER) {
                    resSign = op1Sign;
                    resDigits = subtract(op1.digits, op1Len, op2.digits, op2Len);
                } else {
                    resSign = op2Sign;
                    resDigits = subtract(op2.digits, op2Len, op1.digits, op1Len);
                }
            }
            BigInteger res = new BigInteger(resSign, resDigits.Length, resDigits);
            res.cutOffLeadingZeroes();
            return res;
        }

        private static void add(int[] res, int[] a, int aSize, int[] b, int bSize) {
            int i;
            long carry = ( a[0] & 0xFFFFFFFFL ) + ( b[0] & 0xFFFFFFFFL );

            res[0] = (int) carry;
            carry >>= 32;

            if (aSize >= bSize) {
                for (i = 1; i < bSize; i++) {
                    carry += ( a[i] & 0xFFFFFFFFL ) + ( b[i] & 0xFFFFFFFFL );
                    res[i] = (int) carry;
                    carry >>= 32;
                }
                for (; i < aSize; i++) {
                    carry += a[i] & 0xFFFFFFFFL;
                    res[i] = (int) carry;
                    carry >>= 32;
                }
            } else {
                for (i = 1; i < aSize; i++) {
                    carry += ( a[i] & 0xFFFFFFFFL ) + ( b[i] & 0xFFFFFFFFL );
                    res[i] = (int) carry;
                    carry >>= 32;
                }
                for (; i < bSize; i++) {
                    carry += b[i] & 0xFFFFFFFFL;
                    res[i] = (int) carry;
                    carry >>= 32;
                }
            }
            if (carry != 0) {
                res[i] = (int) carry;
            }
        }

        internal static BigInteger subtract(BigInteger op1, BigInteger op2) {
            int resSign;
            int[] resDigits;
            int op1Sign = op1.sign;
            int op2Sign = op2.sign;

            if (op2Sign == 0) {
                return op1;
            }
            if (op1Sign == 0) {
                return op2.negate ();
            }
            int op1Len = op1.numberLength;
            int op2Len = op2.numberLength;
            if (op1Len + op2Len == 2) {
                long a = ( op1.digits[0] & 0xFFFFFFFFL );
                long b = ( op2.digits[0] & 0xFFFFFFFFL );
                if (op1Sign < 0) {
                    a = -a;
                }
                if (op2Sign < 0) {
                    b = -b;
                }
                return BigInteger.valueOf (a - b);
            }
            int cmp = ( ( op1Len != op2Len ) ? ( ( op1Len > op2Len ) ? 1 : -1 )
                        : Elementary.compareArrays (op1.digits, op2.digits, op1Len) );

            if (cmp == BigInteger.LESS) {
                resSign = -op2Sign;
                resDigits = ( op1Sign == op2Sign ) ? subtract (op2.digits, op2Len,
                                                               op1.digits, op1Len) : add (op2.digits, op2Len, op1.digits,
                                                                                          op1Len);
            } else {
                resSign = op1Sign;
                if (op1Sign == op2Sign) {
                    if (cmp == BigInteger.EQUALS) {
                        return BigInteger.ZERO;
                    }
                    resDigits = subtract (op1.digits, op1Len, op2.digits, op2Len);
                } else {
                    resDigits = add (op1.digits, op1Len, op2.digits, op2Len);
                }
            }
            BigInteger res = new BigInteger (resSign, resDigits.Length, resDigits);
            res.cutOffLeadingZeroes();
            return res;
        }

        private static void subtract(int[] res, int[] a, int aSize, int[] b,
                                     int bSize) {
            // PRE: a[] >= b[]
            int i;
            long borrow = 0;

            for (i = 0; i < bSize; i++) {
                borrow += ( a[i] & 0xFFFFFFFFL ) - ( b[i] & 0xFFFFFFFFL );
                res[i] = (int) borrow;
                borrow >>= 32; // -1 or 0
            }
            for (; i < aSize; i++) {
                borrow += a[i] & 0xFFFFFFFFL;
                res[i] = (int) borrow;
                borrow >>= 32; // -1 or 0
            }
        }

        private static int[] add(int[] a, int aSize, int[] b, int bSize) {
            int[] res = new int[aSize + 1];
            add(res, a, aSize, b, bSize);
            return res;
        }

        internal static void inplaceAdd(BigInteger op1, BigInteger op2) {
            // PRE: op1 >= op2 > 0
            add (op1.digits, op1.digits, op1.numberLength, op2.digits,
                 op2.numberLength);
            op1.numberLength = Math.Min(Math.Max(op1.numberLength,
                                                 op2.numberLength) + 1, op1.digits.Length);
            op1.cutOffLeadingZeroes ();
            op1.unCache();
        }

        internal static int inplaceAdd(int[] a, int aSize, int addend) {
            long carry = addend & 0xFFFFFFFFL;

            for (int i = 0; (carry != 0) && (i < aSize); i++) {
                carry += a[i] & 0xFFFFFFFFL;
                a[i] = (int) carry;
                carry >>= 32;
            }
            return (int) carry;
        }

        internal static void inplaceAdd(BigInteger op1, int addend) {
            int carry = inplaceAdd(op1.digits, op1.numberLength, addend);
            if (carry == 1) {
                op1.digits[op1.numberLength] = 1;
                op1.numberLength++;
            }
            op1.unCache();
        }

        internal static void inplaceSubtract(BigInteger op1, BigInteger op2) {
            subtract (op1.digits, op1.digits, op1.numberLength, op2.digits,
                      op2.numberLength);
            op1.cutOffLeadingZeroes ();
            op1.unCache();
        }

        private static void inverseSubtract(int[] res, int[] a, int aSize, int[] b,
                                            int bSize) {
            int i;
            long borrow = 0;
            if (aSize < bSize) {
                for (i = 0; i < aSize; i++) {
                    borrow += ( b[i] & 0xFFFFFFFFL ) - ( a[i] & 0xFFFFFFFFL );
                    res[i] = (int) borrow;
                    borrow >>= 32; // -1 or 0
                }
                for (; i < bSize; i++) {
                    borrow += b[i] & 0xFFFFFFFFL;
                    res[i] = (int) borrow;
                    borrow >>= 32; // -1 or 0
                }
            } else {
                for (i = 0; i < bSize; i++) {
                    borrow += ( b[i] & 0xFFFFFFFFL ) - ( a[i] & 0xFFFFFFFFL );
                    res[i] = (int) borrow;
                    borrow >>= 32; // -1 or 0
                }
                for (; i < aSize; i++) {
                    borrow -= a[i] & 0xFFFFFFFFL;
                    res[i] = (int) borrow;
                    borrow >>= 32; // -1 or 0
                }
            }

        }

        private static int[] subtract(int[] a, int aSize, int[] b, int bSize) {
            int[] res = new int[aSize];
            subtract(res, a, aSize, b, bSize);
            return res;
        }

        internal static void completeInPlaceSubtract(BigInteger op1, BigInteger op2) {
            int resultSign = op1.compareTo (op2);
            if (op1.sign == 0) {
                Array.Copy(op2.digits, op1.digits, op2.numberLength);
                op1.sign = -op2.sign;
            } else if (op1.sign != op2.sign) {
                add (op1.digits, op1.digits, op1.numberLength, op2.digits,
                     op2.numberLength);
                op1.sign = resultSign;
            } else {
                int sign = unsignedArraysCompare (op1.digits,
                                                  op2.digits, op1.numberLength, op2.numberLength);
                if (sign > 0) {
                    subtract (op1.digits, op1.digits, op1.numberLength, op2.digits,
                              op2.numberLength);	// op1 = op1 - op2
                    // op1.sign remains equal
                } else {
                    inverseSubtract (op1.digits, op1.digits, op1.numberLength,
                                     op2.digits, op2.numberLength);	// op1 = op2 - op1
                    op1.sign = -op1.sign;
                }
            }
            op1.numberLength = Math.Max(op1.numberLength, op2.numberLength) + 1;
            op1.cutOffLeadingZeroes ();
            op1.unCache();
        }

        internal static void completeInPlaceAdd(BigInteger op1, BigInteger op2) {
            if (op1.sign == 0)
                Array.Copy(op2.digits, op1.digits, op2.numberLength);
            else if (op2.sign == 0)
                return;
            else if (op1.sign == op2.sign)
                add (op1.digits, op1.digits, op1.numberLength, op2.digits,
                     op2.numberLength);
            else {
                int sign = unsignedArraysCompare(op1.digits,
                                                 op2.digits, op1.numberLength, op2.numberLength);
                if (sign > 0)
                    subtract (op1.digits, op1.digits, op1.numberLength, op2.digits,
                              op2.numberLength);
                else {
                    inverseSubtract (op1.digits, op1.digits, op1.numberLength,
                                     op2.digits, op2.numberLength);
                    op1.sign = -op1.sign;
                }
            }
            op1.numberLength = Math.Max(op1.numberLength, op2.numberLength) + 1;
            op1.cutOffLeadingZeroes ();
            op1.unCache();
        }

        private static int unsignedArraysCompare(int[] a, int[] b, int aSize, int bSize){
            if (aSize > bSize)
                return 1;
            else if (aSize < bSize)
                return -1;
		
            else {
                int i;
                for (i = aSize - 1; i >= 0 && a[i] == b[i]; i-- )
                    ;
                return i < 0 ? BigInteger.EQUALS : (( a[i] & 0xFFFFFFFFL ) < (b[i] & 0xFFFFFFFFL ) ? BigInteger.LESS
                                                    : BigInteger.GREATER) ;
            }
        }
    }
}
