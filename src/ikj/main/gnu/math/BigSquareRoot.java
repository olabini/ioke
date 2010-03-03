package gnu.math;

import java.math.*;

/**
 * Taken from public domain implementation found at http://www.merriampark.com/bigsqrt.htm
 */
public class BigSquareRoot {
    private static BigDecimal ZERO = new BigDecimal ("0");
    private static BigDecimal ONE = new BigDecimal ("1");
    private static BigDecimal TWO = new BigDecimal ("2");
    public static final int DEFAULT_MAX_ITERATIONS = 50;
    public static final int DEFAULT_SCALE = 10;

    private BigDecimal error;
    private final int scale;
    private final int maxIterations;
    
    public BigSquareRoot() {
        this(DEFAULT_MAX_ITERATIONS, DEFAULT_SCALE);
    }
    
    public BigSquareRoot(int maxIterations, int scale) {
        this.maxIterations = maxIterations;
        this.scale = scale;
    }

    public BigDecimal get(BigInteger n) {
        return get(new BigDecimal(n));
    }

    public BigDecimal get(BigDecimal n) {
        if (n.compareTo(ZERO) <= 0) {
            throw new IllegalArgumentException ();
        }

        BigDecimal initialGuess = getInitialApproximation(n);
        BigDecimal lastGuess = ZERO;
        BigDecimal guess = new BigDecimal(initialGuess.toString());

        int iterations = 0;
        boolean more = true;
        while(more) {
            lastGuess = guess;
            guess = n.divide(guess, scale, BigDecimal.ROUND_HALF_UP);
            guess = guess.add(lastGuess);
            guess = guess.divide(TWO, scale, BigDecimal.ROUND_HALF_UP);
            error = n.subtract(guess.multiply(guess));
            if(++iterations >= maxIterations) {
                more = false;
            } else if(lastGuess.equals(guess)) {
                more = error.abs().compareTo(ONE) >= 0;
            }
        }
        return guess;
    }

    private static BigDecimal getInitialApproximation(BigDecimal n) {
        BigInteger integerPart = n.toBigInteger();
        int length = integerPart.toString().length();
        if((length % 2) == 0) {
            length--;
        }
        length /= 2;
        BigDecimal guess = ONE.movePointRight(length);
        return guess;
    }

    private static BigInteger getRandomBigInteger(int nDigits) {
        StringBuilder sb = new StringBuilder();
        java.util.Random r = new java.util.Random();
        for (int i = 0; i < nDigits; i++) {
            sb.append(r.nextInt(10));
        }
        return new BigInteger(sb.toString());
    }
}
