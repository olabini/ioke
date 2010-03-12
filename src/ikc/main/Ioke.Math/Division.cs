namespace Ioke.Math {
    using System;

    class Division {
        internal static int[] divide(int[] quot, int quotLength, int[] a, int aLength, int[] b, int bLength) {
            int[] normA = new int[aLength + 1]; // the normalized dividend
            // an extra byte is needed for correct shift
            int[] normB = new int[bLength + 1]; // the normalized divisor;
            int normBLength = bLength;
            /*
             * Step D1: normalize a and b and put the results to a1 and b1 the
             * normalized divisor's first digit must be >= 2^31
             */
            int divisorShift = BigDecimal.numberOfLeadingZeros(b[bLength - 1]);
            if (divisorShift != 0) {
                BitLevel.shiftLeft(normB, b, 0, divisorShift);
                BitLevel.shiftLeft(normA, a, 0, divisorShift);
            } else {
                Array.Copy(a, normA, aLength);
                Array.Copy(b, normB, bLength);
            }
            int firstDivisorDigit = normB[normBLength - 1];
            // Step D2: set the quotient index
            int i = quotLength - 1;
            int j = aLength;

            while (i >= 0) {
                // Step D3: calculate a guess digit guessDigit
                int guessDigit = 0;
                if (normA[j] == firstDivisorDigit) {
                    // set guessDigit to the largest unsigned int value
                    guessDigit = -1;
                } else {
                    long product = (((normA[j] & 0xffffffffL) << 32) + (normA[j - 1] & 0xffffffffL));
                    long res = Division.divideLongByInt(product, firstDivisorDigit);
                    guessDigit = (int) res; // the quotient of divideLongByInt
                    int rem = (int) (res >> 32); // the remainder of
                    // divideLongByInt
                    // decrease guessDigit by 1 while leftHand > rightHand
                    if (guessDigit != 0) {
                        long leftHand = 0;
                        long rightHand = 0;
                        bool rOverflowed = false;
                        guessDigit++; // to have the proper value in the loop
                        // below
                        do {
                            guessDigit--;
                            if (rOverflowed) {
                                break;
                            }
                            // leftHand always fits in an unsigned long
                            leftHand = (guessDigit & 0xffffffffL)
                                * (normB[normBLength - 2] & 0xffffffffL);
                            /*
                             * rightHand can overflow; in this case the loop
                             * condition will be true in the next step of the loop
                             */
                            rightHand = ((long) rem << 32)
                                + (normA[j - 2] & 0xffffffffL);
                            long longR = (rem & 0xffffffffL)
                                + (firstDivisorDigit & 0xffffffffL);
                            /*
                             * checks that longR does not fit in an unsigned int;
                             * this ensures that rightHand will overflow unsigned
                             * long in the next step
                             */
                            if (BigDecimal.numberOfLeadingZeros((int) ((long)(((ulong)longR) >> 32))) < 32) {
                                rOverflowed = true;
                            } else {
                                rem = (int) longR;
                            }
                        } while (((long)((ulong)leftHand ^ 0x8000000000000000L) > (long)((ulong)rightHand ^ 0x8000000000000000L)));
                    }
                }
                // Step D4: multiply normB by guessDigit and subtract the production
                // from normA.
                if (guessDigit != 0) {
                    int borrow = Division.multiplyAndSubtract(normA, j
                                                              - normBLength, normB, normBLength,
                                                              guessDigit);
                    // Step D5: check the borrow
                    if (borrow != 0) {
                        // Step D6: compensating addition
                        guessDigit--;
                        long carry = 0;
                        for (int k = 0; k < normBLength; k++) {
                            carry += (normA[j - normBLength + k] & 0xffffffffL)
                                + (normB[k] & 0xffffffffL);
                            normA[j - normBLength + k] = (int) carry;
                            carry = (long)(((ulong)carry) >> 32);
                        }
                    }
                }
                if (quot != null) {
                    quot[i] = guessDigit;
                }
                // Step D7
                j--;
                i--;
            }
            /*
             * Step D8: we got the remainder in normA. Denormalize it id needed
             */
            if (divisorShift != 0) {
                // reuse normB
                BitLevel.shiftRight(normB, normBLength, normA, 0, divisorShift);
                return normB;
            }
            Array.Copy(normA, normB, bLength);
            return normA;
        }

        internal static int divideArrayByInt(int[] dest, int[] src, int srcLength, int divisor) {
            long rem = 0;
            long bLong = divisor & 0xffffffffL;

            for (int i = srcLength - 1; i >= 0; i--) {
                long temp = (rem << 32) | (src[i] & 0xffffffffL);
                long quot;
                if (temp >= 0) {
                    quot = (temp / bLong);
                    rem = (temp % bLong);
                } else {
                    /*
                     * make the dividend positive shifting it right by 1 bit then
                     * get the quotient an remainder and correct them properly
                     */
                    long aPos = (long)(((ulong)temp) >> 1);
                    long bPos = (int)(((uint)divisor) >> 1);
                    quot = aPos / bPos;
                    rem = aPos % bPos;
                    // double the remainder and add 1 if a is odd
                    rem = (rem << 1) + (temp & 1);
                    if ((divisor & 1) != 0) {
                        // the divisor is odd
                        if (quot <= rem) {
                            rem -= quot;
                        } else {
                            if (quot - rem <= bLong) {
                                rem += bLong - quot;
                                quot -= 1;
                            } else {
                                rem += (bLong << 1) - quot;
                                quot -= 2;
                            }
                        }
                    }
                }
                dest[i] = (int) (quot & 0xffffffffL);
            }
            return (int) rem;
        }

        internal static int remainderArrayByInt(int[] src, int srcLength,
                                       int divisor) {

            long result = 0;

            for (int i = srcLength - 1; i >= 0; i--) {
                long temp = (result << 32) + (src[i] & 0xffffffffL);
                long res = divideLongByInt(temp, divisor);
                result = (int) (res >> 32);
            }
            return (int) result;
        }

        internal static int remainder(BigInteger dividend, int divisor) {
            return remainderArrayByInt(dividend.digits, dividend.numberLength,
                                       divisor);
        }

        internal static long divideLongByInt(long a, int b) {
            long quot;
            long rem;
            long bLong = b & 0xffffffffL;

            if (a >= 0) {
                quot = (a / bLong);
                rem = (a % bLong);
            } else {
                /*
                 * Make the dividend positive shifting it right by 1 bit then get
                 * the quotient an remainder and correct them properly
                 */
                long aPos = (long)(((ulong)a) >> 1);
                long bPos = (int)(((uint)b) >> 1);
                quot = aPos / bPos;
                rem = aPos % bPos;
                // double the remainder and add 1 if a is odd
                rem = (rem << 1) + (a & 1);
                if ((b & 1) != 0) { // the divisor is odd
                    if (quot <= rem) {
                        rem -= quot;
                    } else {
                        if (quot - rem <= bLong) {
                            rem += bLong - quot;
                            quot -= 1;
                        } else {
                            rem += (bLong << 1) - quot;
                            quot -= 2;
                        }
                    }
                }
            }
            return (rem << 32) | (quot & 0xffffffffL);
        }

        internal static BigInteger[] divideAndRemainderByInteger(BigInteger val,
                                                        int divisor, int divisorSign) {
            // res[0] is a quotient and res[1] is a remainder:
            int[] valDigits = val.digits;
            int valLen = val.numberLength;
            int valSign = val.sign;
            if (valLen == 1) {
                long a = (valDigits[0] & 0xffffffffL);
                long b = (divisor & 0xffffffffL);
                long quo = a / b;
                long rem = a % b;
                if (valSign != divisorSign) {
                    quo = -quo;
                }
                if (valSign < 0) {
                    rem = -rem;
                }
                return new BigInteger[] { BigInteger.valueOf(quo),
                                          BigInteger.valueOf(rem) };
            }
            int quotientLength = valLen;
            int quotientSign = ((valSign == divisorSign) ? 1 : -1);
            int[] quotientDigits = new int[quotientLength];
            int[] remainderDigits;
            remainderDigits = new int[] { Division.divideArrayByInt(
                    quotientDigits, valDigits, valLen, divisor) };
            BigInteger result0 = new BigInteger(quotientSign, quotientLength,
                                                quotientDigits);
            BigInteger result1 = new BigInteger(valSign, 1, remainderDigits);
            result0.cutOffLeadingZeroes();
            result1.cutOffLeadingZeroes();
            return new BigInteger[] { result0, result1 };
        }

        internal static int multiplyAndSubtract(int[] a, int start, int[] b, int bLen, int c) {
            long carry0 = 0;
            long carry1 = 0;
        
            for (int i = 0; i < bLen; i++) {
                carry0 = Multiplication.unsignedMultAddAdd(b[i], c, (int)carry0, 0);
                carry1 = (a[start+i] & 0xffffffffL) - (carry0 & 0xffffffffL) + carry1;
                a[start+i] = (int)carry1;
                carry1 >>=  32; // -1 or 0
                carry0 = (long)(((ulong)carry0) >> 32);
            }
        
            carry1 = (a[start + bLen] & 0xffffffffL) - carry0 + carry1;
            a[start + bLen] = (int)carry1;
            return (int)(carry1 >> 32); // -1 or 0
        }

        internal static BigInteger gcdBinary(BigInteger op1, BigInteger op2) {
            // PRE: (op1 > 0) and (op2 > 0)
        
            /*
             * Divide both number the maximal possible times by 2 without rounding
             * gcd(2*a, 2*b) = 2 * gcd(a,b)
             */
            int lsb1 = op1.getLowestSetBit();
            int lsb2 = op2.getLowestSetBit();
            int pow2Count = Math.Min(lsb1, lsb2);

            BitLevel.inplaceShiftRight(op1, lsb1);
            BitLevel.inplaceShiftRight(op2, lsb2);
        
            BigInteger swap;
            // I want op2 > op1
            if (op1.compareTo(op2) == BigInteger.GREATER) {
                swap = op1;
                op1 = op2;
                op2 = swap;
            } 
        
            do { // INV: op2 >= op1 && both are odd unless op1 = 0
            
                // Optimization for small operands
                // (op2.bitLength() < 64) implies by INV (op1.bitLength() < 64)
                if (( op2.numberLength == 1 )
                    || ( ( op2.numberLength == 2 ) && ( op2.digits[1] > 0 ) )) {
                    op2 = BigInteger.valueOf(Division.gcdBinary(op1.longValue(),
                                                                op2.longValue()));
                    break;
                }
            
                // Implements one step of the Euclidean algorithm
                // To reduce one operand if it's much smaller than the other one
                if (op2.numberLength > op1.numberLength * 1.2) {
                    op2 = op2.remainder(op1);
                    if (op2.signum() != 0) {
                        BitLevel.inplaceShiftRight(op2, op2.getLowestSetBit());
                    }
                } else {
                
                    // Use Knuth's algorithm of successive subtract and shifting
                    do {
                        Elementary.inplaceSubtract(op2, op1); // both are odd
                        BitLevel.inplaceShiftRight(op2, op2.getLowestSetBit()); // op2 is even
                    } while (op2.compareTo(op1) >= BigInteger.EQUALS);
                }
                // now op1 >= op2
                swap = op2;
                op2 = op1;
                op1 = swap;
            } while (op1.sign != 0);
            return op2.shiftLeft(pow2Count);
        }

        internal static long gcdBinary(long op1, long op2) {
            // PRE: (op1 > 0) and (op2 > 0)
            int lsb1 = BigDecimal.numberOfTrailingZeros(op1);
            int lsb2 = BigDecimal.numberOfTrailingZeros(op2);
            int pow2Count = Math.Min(lsb1, lsb2);

            if (lsb1 != 0) {
                op1 = (long)(((ulong)op1) >> lsb1);
            }
            if (lsb2 != 0) {
                op2 = (long)(((ulong)op2) >> lsb2);
            }
            do {
                if (op1 >= op2) {
                    op1 -= op2;
                    op1 = (long)(((ulong)op1) >> BigDecimal.numberOfTrailingZeros(op1));
                } else {
                    op2 -= op1;
                    op2 = (long)(((ulong)op2) >> BigDecimal.numberOfTrailingZeros(op2));
                }
            } while (op1 != 0);
            return ( op2 << pow2Count );
        }

        internal static BigInteger modInverseMontgomery(BigInteger a, BigInteger p) {

            if (a.sign == 0){
                // ZERO hasn't inverse
                throw new ArithmeticException("BigInteger not invertible");
            }
        
        
            if (!p.testBit(0)){
                // montgomery inverse require even modulo
                return modInverseLorencz(a, p);
            }
        
            int m = p.numberLength * 32;
            // PRE: a \in [1, p - 1]
            BigInteger u, v, r, s;
            u = p.copy();  // make copy to use inplace method
            v = a.copy();
            int max = Math.Max(v.numberLength, u.numberLength);
            r = new BigInteger(1, 1, new int[max + 1]);
            s = new BigInteger(1, 1, new int[max + 1]);
            s.digits[0] = 1;
            // s == 1 && v == 0
        
            int k = 0;
        
            int lsbu = u.getLowestSetBit();
            int lsbv = v.getLowestSetBit();
            int toShift;
        
            if (lsbu > lsbv) {
                BitLevel.inplaceShiftRight(u, lsbu);
                BitLevel.inplaceShiftRight(v, lsbv);
                BitLevel.inplaceShiftLeft(r, lsbv);
                k += lsbu - lsbv;
            } else {
                BitLevel.inplaceShiftRight(u, lsbu);
                BitLevel.inplaceShiftRight(v, lsbv);
                BitLevel.inplaceShiftLeft(s, lsbu);
                k += lsbv - lsbu;
            }
        
            r.sign = 1;
            while (v.signum() > 0) {
                // INV v >= 0, u >= 0, v odd, u odd (except last iteration when v is even (0))
    
                while (u.compareTo(v) > BigInteger.EQUALS) {
                    Elementary.inplaceSubtract(u, v);
                    toShift = u.getLowestSetBit();
                    BitLevel.inplaceShiftRight(u, toShift);
                    Elementary.inplaceAdd(r, s);
                    BitLevel.inplaceShiftLeft(s, toShift);
                    k += toShift;                
                }
            
                while (u.compareTo(v) <= BigInteger.EQUALS) {
                    Elementary.inplaceSubtract(v, u);
                    if (v.signum() == 0)
                        break;
                    toShift = v.getLowestSetBit();
                    BitLevel.inplaceShiftRight(v, toShift);
                    Elementary.inplaceAdd(s, r);
                    BitLevel.inplaceShiftLeft(r, toShift);
                    k += toShift;
                }
            }
            if (!u.isOne()){
                // in u is stored the gcd
                throw new ArithmeticException("BigInteger not invertible.");
            }
            if (r.compareTo(p) >= BigInteger.EQUALS) {
                Elementary.inplaceSubtract(r, p);
            }
        
            r = p.subtract(r);

            // Have pair: ((BigInteger)r, (Integer)k) where r == a^(-1) * 2^k mod (module)		
            int n1 = calcN(p);
            if (k > m) {
                r = monPro(r, BigInteger.ONE, p, n1);
                k = k - m;
            }
        
            r = monPro(r, BigInteger.getPowerOfTwo(m - k), p, n1);
            return r;
        }
    
        private static int calcN(BigInteger a) {
            long m0 = a.digits[0] & 0xFFFFFFFFL;
            long n2 = 1L; // this is a'[0]
            long powerOfTwo = 2L;
            do {
                if (((m0 * n2) & powerOfTwo) != 0) {
                    n2 |= powerOfTwo;
                }
                powerOfTwo <<= 1;
            } while (powerOfTwo < 0x100000000L);
            n2 = -n2;
            return (int)(n2 & 0xFFFFFFFFL);
        }

        private static bool isPowerOfTwo(BigInteger bi, int exp) {
            bool result = false;
            result = ( exp >> 5 == bi.numberLength - 1 )
                && ( bi.digits[bi.numberLength - 1] == 1 << ( exp & 31 ) );
            if (result) {
                for (int i = 0; result && i < bi.numberLength - 1; i++) {
                    result = bi.digits[i] == 0;
                }
            }
            return result;
        }
    
        private static int howManyIterations(BigInteger bi, int n) {
            int i = n - 1;
            if (bi.sign > 0) {
                while (!bi.testBit(i))
                    i--;
                return n - 1 - i;
            } else {
                while (bi.testBit(i))
                    i--;
                return n - 1 - Math.Max(i, bi.getLowestSetBit());
            }
        
        }
    
        internal static BigInteger modInverseLorencz(BigInteger a, BigInteger modulo) {
            int max = Math.Max(a.numberLength, modulo.numberLength);
            int[] uDigits = new int[max + 1]; // enough place to make all the inplace operation
            int[] vDigits = new int[max + 1];
            Array.Copy(modulo.digits, uDigits, modulo.numberLength);
            Array.Copy(a.digits, vDigits, a.numberLength);
            BigInteger u = new BigInteger(modulo.sign, modulo.numberLength,
                                          uDigits);
            BigInteger v = new BigInteger(a.sign, a.numberLength, vDigits);
        
            BigInteger r = new BigInteger(0, 1, new int[max + 1]); // BigInteger.ZERO;
            BigInteger s = new BigInteger(1, 1, new int[max + 1]);
            s.digits[0] = 1;
            // r == 0 && s == 1, but with enough place
        
            int coefU = 0, coefV = 0;
            int n = modulo.bitLength();
            int k;
            while (!isPowerOfTwo(u, coefU) && !isPowerOfTwo(v, coefV)) {
            
                // modification of original algorithm: I calculate how many times the algorithm will enter in the same branch of if
                k = howManyIterations(u, n);
            
                if (k != 0) {
                    BitLevel.inplaceShiftLeft(u, k);
                    if (coefU >= coefV) {
                        BitLevel.inplaceShiftLeft(r, k);
                    } else {
                        BitLevel.inplaceShiftRight(s, Math.Min(coefV - coefU, k));
                        if (k - ( coefV - coefU ) > 0) {
                            BitLevel.inplaceShiftLeft(r, k - coefV + coefU);
                        }
                    }
                    coefU += k;
                }
            
                k = howManyIterations(v, n);
                if (k != 0) {
                    BitLevel.inplaceShiftLeft(v, k);
                    if (coefV >= coefU) {
                        BitLevel.inplaceShiftLeft(s, k);
                    } else {
                        BitLevel.inplaceShiftRight(r, Math.Min(coefU - coefV, k));
                        if (k - ( coefU - coefV ) > 0) {
                            BitLevel.inplaceShiftLeft(s, k - coefU + coefV);
                        }
                    }
                    coefV += k;
                
                }
            
                if (u.signum() == v.signum()) {
                    if (coefU <= coefV) {
                        Elementary.completeInPlaceSubtract(u, v);
                        Elementary.completeInPlaceSubtract(r, s);
                    } else {
                        Elementary.completeInPlaceSubtract(v, u);
                        Elementary.completeInPlaceSubtract(s, r);
                    }
                } else {
                    if (coefU <= coefV) {
                        Elementary.completeInPlaceAdd(u, v);
                        Elementary.completeInPlaceAdd(r, s);
                    } else {
                        Elementary.completeInPlaceAdd(v, u);
                        Elementary.completeInPlaceAdd(s, r);
                    }
                }
                if (v.signum() == 0 || u.signum() == 0){
                    throw new ArithmeticException("BigInteger not invertible");
                }
            }
        
            if (isPowerOfTwo(v, coefV)) {
                r = s;
                if (v.signum() != u.signum())
                    u = u.negate();
            }
            if (u.testBit(n)) {
                if (r.signum() < 0) {
                    r = r.negate();
                } else {
                    r = modulo.subtract(r);
                }
            }
            if (r.signum() < 0) {
                r = r.add(modulo);
            }
        
            return r;
        }
    
        internal static BigInteger squareAndMultiply(BigInteger x2, BigInteger a2, BigInteger exponent,BigInteger modulus, int n2  ){
            BigInteger res = x2;
            for (int i = exponent.bitLength() - 1; i >= 0; i--) {
                res = monPro(res,res,modulus, n2);
                if (BitLevel.testBit(exponent, i)) {
                    res = monPro(res, a2, modulus, n2);
                }
            }
            return res;
        }

        internal static BigInteger slidingWindow(BigInteger x2, BigInteger a2, BigInteger exponent,BigInteger modulus, int n2){
            // fill odd low pows of a2
            BigInteger[] pows = new BigInteger[8];
            BigInteger res = x2;
            int lowexp;
            BigInteger x3;
            int acc3;
            pows[0] = a2;
        
            x3 = monPro(a2,a2,modulus,n2);
            for (int i = 1; i <= 7; i++){
                pows[i] = monPro(pows[i-1],x3,modulus,n2) ;
            }
        
            for (int i = exponent.bitLength()-1; i>=0;i--){
                if( BitLevel.testBit(exponent,i) ) {
                    lowexp = 1;
                    acc3 = i;
                
                    for(int j = Math.Max(i-3,0);j <= i-1 ;j++) {
                        if (BitLevel.testBit(exponent,j)) {
                            if (j<acc3) {
                                acc3 = j;
                                lowexp = (lowexp << (i-j))^1;
                            } else {
                                lowexp = lowexp^(1<<(j-acc3));
                            }
                        }
                    }
                
                    for(int j = acc3; j <= i; j++) {
                        res = monPro(res,res,modulus,n2);
                    }
                    res = monPro(pows[(lowexp-1)>>1], res, modulus,n2);
                    i = acc3 ;
                }else{
                    res = monPro(res, res, modulus, n2) ;
                }
            }
            return res;
        }
    
        internal static BigInteger oddModPow(BigInteger _base, BigInteger exponent,
                                    BigInteger modulus) {
            // PRE: (base > 0), (exponent > 0), (modulus > 0) and (odd modulus)
            int k = (modulus.numberLength << 5); // r = 2^k
            // n-residue of base [base * r (mod modulus)]
            BigInteger a2 = _base.shiftLeft(k).mod(modulus);
            // n-residue of base [1 * r (mod modulus)]
            BigInteger x2 = BigInteger.getPowerOfTwo(k).mod(modulus);
            BigInteger res;
            // Compute (modulus[0]^(-1)) (mod 2^32) for odd modulus
        
            int n2 = calcN(modulus);
            if( modulus.numberLength == 1 ){
                res = squareAndMultiply(x2,a2, exponent, modulus,n2);
            } else {
                res = slidingWindow(x2, a2, exponent, modulus, n2);
            }
        
            return monPro(res, BigInteger.ONE, modulus, n2);
        }

        internal static BigInteger evenModPow(BigInteger _base, BigInteger exponent,
                                     BigInteger modulus) {
            // PRE: (base > 0), (exponent > 0), (modulus > 0) and (modulus even)
            // STEP 1: Obtain the factorization 'modulus'= q * 2^j.
            int j = modulus.getLowestSetBit();
            BigInteger q = modulus.shiftRight(j);

            // STEP 2: Compute x1 := base^exponent (mod q).
            BigInteger x1 = oddModPow(_base, exponent, q);

            // STEP 3: Compute x2 := base^exponent (mod 2^j).
            BigInteger x2 = pow2ModPow(_base, exponent, j);

            // STEP 4: Compute q^(-1) (mod 2^j) and y := (x2-x1) * q^(-1) (mod 2^j)
            BigInteger qInv = modPow2Inverse(q, j);
            BigInteger y = (x2.subtract(x1)).multiply(qInv);
            inplaceModPow2(y, j);
            if (y.sign < 0) {
                y = y.add(BigInteger.getPowerOfTwo(j));
            }
            // STEP 5: Compute and return: x1 + q * y
            return x1.add(q.multiply(y));
        }

        internal static BigInteger pow2ModPow(BigInteger _base, BigInteger exponent, int j) {
            // PRE: (base > 0), (exponent > 0) and (j > 0)
            BigInteger res = BigInteger.ONE;
            BigInteger e = exponent.copy();
            BigInteger baseMod2toN = _base.copy();
            BigInteger res2;
            /*
             * If 'base' is odd then it's coprime with 2^j and phi(2^j) = 2^(j-1);
             * so we can reduce reduce the exponent (mod 2^(j-1)).
             */
            if (_base.testBit(0)) {
                inplaceModPow2(e, j - 1);
            }
            inplaceModPow2(baseMod2toN, j);

            for (int i = e.bitLength() - 1; i >= 0; i--) {
                res2 = res.copy();
                inplaceModPow2(res2, j);
                res = res.multiply(res2);
                if (BitLevel.testBit(e, i)) {
                    res = res.multiply(baseMod2toN);
                    inplaceModPow2(res, j);
                }
            }
            inplaceModPow2(res, j);
            return res;
        }

        private static void monReduction(int[] res, BigInteger modulus, int n2) {

            /* res + m*modulus_digits */
            int[] modulus_digits = modulus.digits;
            int modulusLen = modulus.numberLength;
            long outerCarry = 0;
        
            for (int i = 0; i < modulusLen; i++){
                long innerCarry = 0;
                int m = (int) Multiplication.unsignedMultAddAdd(res[i],n2,0,0);
                for(int j = 0; j < modulusLen; j++){
                    innerCarry =  Multiplication.unsignedMultAddAdd(m, modulus_digits[j], res[i+j], (int)innerCarry);
                    res[i+j] = (int) innerCarry;
                    innerCarry = (long)(((ulong)innerCarry) >> 32);
                }

                outerCarry += (res[i+modulusLen] & 0xFFFFFFFFL) + innerCarry;
                res[i+modulusLen] = (int) outerCarry;
                outerCarry = (long)(((ulong)outerCarry) >> 32);
            }
        
            res[modulusLen << 1] = (int) outerCarry;
        
            /* res / r  */        
            for(int j = 0; j < modulusLen+1; j++){
                res[j] = res[j+modulusLen];
            }
        }
    
        internal static BigInteger monPro(BigInteger a, BigInteger b, BigInteger modulus, int n2) {
            int modulusLen = modulus.numberLength;
            int[] res = new int[(modulusLen << 1) + 1];
            Multiplication.multArraysPAP(a.digits, Math.Min(modulusLen, a.numberLength),
                                         b.digits, Math.Min(modulusLen, b.numberLength), res);
            monReduction(res,modulus,n2);
            return finalSubtraction(res, modulus);
        
        }
    
        internal static BigInteger finalSubtraction(int[] res, BigInteger modulus){
        
            // skipping leading zeros
            int modulusLen = modulus.numberLength;
            bool doSub = res[modulusLen]!=0;
            if(!doSub) {
                int[] modulusDigits = modulus.digits;
                doSub = true;
                for(int i = modulusLen - 1; i >= 0; i--) {
                    if(res[i] != modulusDigits[i]) {
                        doSub = (res[i] != 0) && ((res[i] & 0xFFFFFFFFL) > (modulusDigits[i] & 0xFFFFFFFFL));
                        break;
                    }
                }
            }
        
            BigInteger result = new BigInteger(1, modulusLen+1, res);
        
            // if (res >= modulusDigits) compute (res - modulusDigits)
            if (doSub) {
                Elementary.inplaceSubtract(result, modulus);
            }
        
            result.cutOffLeadingZeroes();
            return result;
        }

        internal static BigInteger modPow2Inverse(BigInteger x, int n) {
            // PRE: (x > 0), (x is odd), and (n > 0)
            BigInteger y = new BigInteger(1, new int[1 << n]);
            y.numberLength = 1;
            y.digits[0] = 1;
            y.sign = 1;

            for (int i = 1; i < n; i++) {
                if (BitLevel.testBit(x.multiply(y), i)) {
                    // Adding 2^i to y (setting the i-th bit)
                    y.digits[i >> 5] |= (1 << (i & 31));
                }
            }
            return y;
        }

        internal static void inplaceModPow2(BigInteger x, int n) {
            // PRE: (x > 0) and (n >= 0)
            int fd = n >> 5;
            int leadingZeros;

            if ((x.numberLength < fd) || (x.bitLength() <= n)) {
                return;
            }
            leadingZeros = 32 - (n & 31);
            x.numberLength = fd + 1;
            unchecked {
                x.digits[fd] &= (leadingZeros < 32) ? ((int)(((uint)-1) >> leadingZeros)) : 0;
            }
            x.cutOffLeadingZeroes();
        }

    }
}
