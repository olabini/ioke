
namespace Ioke.Math {
    using System;

    public class BigSquareRoot {
        private static readonly BigDecimal ZERO = BigDecimal.ZERO;
        private static readonly BigDecimal ONE = BigDecimal.ONE;
        private static readonly BigDecimal TWO = new BigDecimal ("2");
        public const int DEFAULT_MAX_ITERATIONS = 50;
        public const int DEFAULT_SCALE = 10;

        private BigDecimal error;
        private readonly int scale;
        private readonly int maxIterations;
    
        public BigSquareRoot() : this(DEFAULT_MAX_ITERATIONS, DEFAULT_SCALE) {}
    
        public BigSquareRoot(int maxIterations, int scale) {
            this.maxIterations = maxIterations;
            this.scale = scale;
        }

        public BigDecimal Get(BigDecimal n) {
            if(n.CompareTo(ZERO) <= 0) {
                throw new System.ArgumentException();
            }

            BigDecimal initialGuess = GetInitialApproximation(n);
            BigDecimal lastGuess = ZERO;
            BigDecimal guess = new BigDecimal(initialGuess.ToString());

            int iterations = 0;
            bool more = true;
            while(more) {
                lastGuess = guess;
                guess = n.divide(guess, scale, BigDecimal.ROUND_HALF_UP);
                guess = guess.add(lastGuess);
                guess = guess.divide(TWO, scale, BigDecimal.ROUND_HALF_UP);
                error = n.subtract(guess.multiply(guess));
                if(++iterations >= maxIterations) {
                    more = false;
                } else if(lastGuess.Equals(guess)) {
                    more = error.abs().CompareTo(ONE) >= 0;
                }
            }
            return guess;
        }

        private static BigDecimal GetInitialApproximation(BigDecimal n) {
            BigInteger integerPart = n.toBigInteger();
            int length = integerPart.ToString().Length;
            if((length % 2) == 0) {
                length--;
            }
            length /= 2;
            BigDecimal guess = ONE.movePointRight(length);
            return guess;
        }
    }
}
