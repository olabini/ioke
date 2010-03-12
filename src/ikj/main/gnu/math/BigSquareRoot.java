package gnu.math;

import java.math.*;

/**
 * Taken from public domain implementation found at http://www.merriampark.com/bigsqrt.htm
 */
public class BigSquareRoot {
    private static java.math.BigDecimal ZERO = new java.math.BigDecimal ("0");
    private static java.math.BigDecimal ONE = new java.math.BigDecimal ("1");
    private static java.math.BigDecimal TWO = new java.math.BigDecimal ("2");
    public static final int DEFAULT_MAX_ITERATIONS = 50;
    public static final int DEFAULT_SCALE = 10;

    private java.math.BigDecimal error;
    private final int scale;
    private final int maxIterations;
    
    public BigSquareRoot() {
        this(DEFAULT_MAX_ITERATIONS, DEFAULT_SCALE);
    }
    
    public BigSquareRoot(int maxIterations, int scale) {
        this.maxIterations = maxIterations;
        this.scale = scale;
    }

    public java.math.BigDecimal get(java.math.BigInteger n) {
        return get(new java.math.BigDecimal(n));
    }

    public java.math.BigDecimal get(java.math.BigDecimal n) {
        if (n.compareTo(ZERO) <= 0) {
            throw new IllegalArgumentException ();
        }

        java.math.BigDecimal initialGuess = getInitialApproximation(n);
        java.math.BigDecimal lastGuess = ZERO;
        java.math.BigDecimal guess = new java.math.BigDecimal(initialGuess.toString());

        int iterations = 0;
        boolean more = true;
        while(more) {
            lastGuess = guess;
            guess = n.divide(guess, scale, java.math.BigDecimal.ROUND_HALF_UP);
            guess = guess.add(lastGuess);
            guess = guess.divide(TWO, scale, java.math.BigDecimal.ROUND_HALF_UP);
            error = n.subtract(guess.multiply(guess));
            if(++iterations >= maxIterations) {
                more = false;
            } else if(lastGuess.equals(guess)) {
                more = error.abs().compareTo(ONE) >= 0;
            }
        }
        return guess;
    }

    private static java.math.BigDecimal getInitialApproximation(java.math.BigDecimal n) {
        java.math.BigInteger integerPart = n.toBigInteger();
        int length = integerPart.toString().length();
        if((length % 2) == 0) {
            length--;
        }
        length /= 2;
        java.math.BigDecimal guess = ONE.movePointRight(length);
        return guess;
    }
}
