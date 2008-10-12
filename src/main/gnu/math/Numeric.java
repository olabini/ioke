// Copyright (c) 1997  Per M.A. Bothner.
// This is free software;  for terms and warranty disclaimer see ./COPYING.

package gnu.math;

public abstract class Numeric extends java.lang.Number
{
  public float floatValue () { return (float) doubleValue(); }
  public int intValue() { return (int) longValue(); }
  public long longValue() { return (long) doubleValue(); }

  /** Return this + k * obj. */
  public abstract Numeric add (Object obj, int k);

  public final Numeric add (Object obj) { return add (obj, 1); }
  public final Numeric sub (Object obj) { return add (obj, -1); }

  public abstract Numeric mul (Object obj);

  public abstract Numeric div (Object obj);

  public abstract Numeric abs ();

  public abstract Numeric neg ();

  public abstract String toString (int radix);

  public String toString () { return toString (10); }

  public abstract boolean isExact ();

  public abstract boolean isZero ();

  /* Rounding modes: */
  public static final int FLOOR = 1;
  public static final int CEILING = 2;
  public static final int TRUNCATE = 3;
  public static final int ROUND = 4;

  /** Return an integer for which of {# code this} or {#code obj} is larger.
   * Return 1 if {@code this>obj}; 0 if {@code this==obj};
   * -1 if {@code this<obj};
   * -2 if {@code this!=obj} otherwise (for example if either is NaN);
   * -3 if not comparable (incompatible types). */
  public int compare (Object obj)
  {
    return -3;
  }

  public int compareReversed (Numeric x)
  {
    throw new IllegalArgumentException ();
  }

  public boolean equals (Object obj)
  {
    if (obj == null || ! (obj instanceof Numeric))
      return false;
    return compare (obj) == 0;
  }

  public boolean grt (Object x)
  {
    return compare (x) > 0;
  }

  public boolean geq (Object x)
  {
    return compare (x) >= 0;
  }

  /** Calculate x+k&this. */
  public Numeric addReversed (Numeric x, int k)
  {
    throw new IllegalArgumentException ();
  }

  public Numeric mulReversed (Numeric x)
  {
    throw new IllegalArgumentException ();
  }

  public Numeric divReversed (Numeric x)
  {
    throw new IllegalArgumentException ();
  }

  /** Return the multiplicative inverse. */
  public Numeric div_inv ()
  {
    return IntNum.one().div(this);
  }

  /** Return the multiplicative identity. */
  public Numeric mul_ident ()
  {
    return IntNum.one();
  }

  /** Return this raised to an integer power.
   * Implemented by repeated squaring and multiplication.
   * If y < 0, returns div_inv of the result. */
  public Numeric power (IntNum y)
  {
    if (y.isNegative ())
      return power(IntNum.neg(y)).div_inv();
    Numeric pow2 = this;
    Numeric r = null;
    for (;;)  // for (i = 0;  ; i++)
      {
	// pow2 == x**(2**i)
	// prod = x**(sum(j=0..i-1, (y>>j)&1))
	if (y.isOdd())
	  r = r == null ? pow2 : r.mul (pow2);  // r *= pow2
	y = IntNum.shift (y, -1);
	if (y.isZero())
	  break;
	// pow2 *= pow2;
	pow2 = pow2.mul (pow2);
      }
    return r == null ? mul_ident() : r;
  }

}
