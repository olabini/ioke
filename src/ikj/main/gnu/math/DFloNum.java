// Copyright (c) 1997  Per M.A. Bothner.
// This is free software;  for terms and warranty disclaimer see ./COPYING.

package gnu.math;
import java.io.*;

public class DFloNum extends RealNum implements Externalizable
{
  double value;

  public DFloNum ()
  {
  }

  public DFloNum (double value)
  {
    this.value = value;
  }

  public DFloNum (String s) throws NumberFormatException
  {
    Double d = Double.valueOf (s); // wasteful ...
    value = d.doubleValue ();

    // We want "-0.0" to convert to -0.0, but the spec as of 1.1
    // requires Double.valueOf to convert it to 0.0, because the
    // method is defined to be equivalent to first computing the exact
    // rational value and then converting to floating-point, and the
    // exact rational value represented by either string "0.0" or
    // "-0.0" is 0.
    
    // This is apparently a bug in the spec, which I've reported
    // to sun.  As of 1.1, the sun implementation returns -0.0,
    // but the linux port returns 0.0.
    
    // To be safe, we check for this case.
    if (value == 0.0 && s.charAt (0) == '-')
      value = -0.0;
  }

  public static DFloNum make (double value)
  {
    return new DFloNum (value);
  }

  public final double doubleValue ()
  {
    return value;
  }

  public long longValue ()
  {
    return (long) value;
  }

  public int hashCode ()
  {
    return (int)value;
  }

  public boolean equals (Object obj)
  {
    // take from java.lang.Double.equals:
    return (obj != null)
      && (obj instanceof DFloNum) 
      && (Double.doubleToLongBits(((DFloNum)obj).value)
	  == Double.doubleToLongBits(value));
  }

  public Numeric add (Object y, int k)
  {
    if (y instanceof RealNum)
      return new DFloNum (value + k * ((RealNum)y).doubleValue ());
    if (!(y instanceof Numeric))
      throw new IllegalArgumentException ();
    return ((Numeric)y).addReversed(this, k);
  }

  public Numeric addReversed (Numeric x, int k)
  {
    if (x instanceof RealNum)
      return new DFloNum (((RealNum)x).doubleValue () + k * value);
    throw new IllegalArgumentException ();
  }

  public Numeric mul (Object y)
  {
    if (y instanceof RealNum)
      return new DFloNum (value * ((RealNum)y).doubleValue ());
    if (!(y instanceof Numeric))
      throw new IllegalArgumentException ();
    return ((Numeric)y).mulReversed(this);
  }

  public Numeric mulReversed (Numeric x)
  {
    if (x instanceof RealNum)
      return new DFloNum (((RealNum)x).doubleValue () * value);
    throw new IllegalArgumentException ();
  }

  private static final DFloNum one = new DFloNum(1.0);
  public static final DFloNum one() { return one; }

  public Numeric div (Object y)
  {
    if (y instanceof RealNum)
      return new DFloNum (value / ((RealNum)y).doubleValue ());
    if (!(y instanceof Numeric))
      throw new IllegalArgumentException ();
    return ((Numeric)y).divReversed(this);
  }

  public Numeric divReversed (Numeric x)
  {
    if (x instanceof RealNum)
      return new DFloNum (((RealNum)x).doubleValue () / value);
    throw new IllegalArgumentException ();
  }

  public Numeric power (IntNum y)
  {
    return new DFloNum (Math.pow (doubleValue(), y.doubleValue()));
  }

  public boolean isNegative ()
  {
    return value < 0;
  }

  public Numeric neg ()
  {
    return new DFloNum (-value);
  }

  public int sign ()
  {
    return value > 0.0 ? 1 : value < 0.0 ? -1 : value == 0.0 ? 0: -2;
  }

  public static int compare (double x, double y)
  {
    return x > y ? 1 : x < y ? -1 : x == y ? 0 : -2;
  }

  /** Compare (x_num/x_den) with toExact(y). */
  public static int compare(IntNum x_num, IntNum x_den, double y)
  {
    if (Double.isNaN (y))
      return -2;
    if (Double.isInfinite (y))
      {
	int result = y >= 0.0 ? -1 : 1;
	if (! x_den.isZero()) 
	  return result;  // x is finite
	if (x_num.isZero()) 
	  return -2;  // indeterminate x
	result >>= 1;
	return x_num.isNegative() ? result : ~result;
      }
    else
      {
	long bits = Double.doubleToLongBits (y);
	boolean neg = bits < 0;
	int exp = (int) (bits >> 52) & 0x7FF;
	bits &= 0xfffffffffffffL;
	if (exp == 0)
	  bits <<= 1;
	else
	  bits |= 0x10000000000000L;
	IntNum y_num = IntNum.make (neg ? -bits : bits);
	if (exp >= 1075)
	  y_num = IntNum.shift (y_num, exp - 1075);
	else
	  x_num = IntNum.shift (x_num, 1075 - exp);
	return IntNum.compare (x_num, IntNum.times (y_num, x_den));
      }
  }

  public int compare (Object obj)
  {
    if (obj instanceof RatNum)
      {
	RatNum y_rat = (RatNum) obj;
	int i = compare(y_rat.numerator(), y_rat.denominator(), value);
	return i < -1 ? i : -i;
      }
    return compare (value, ((RealNum)obj).doubleValue ());
  }

  public int compareReversed (Numeric x)
  {
    if (x instanceof RatNum)
      {
	RatNum x_rat = (RatNum) x;
	return compare(x_rat.numerator(), x_rat.denominator(), value);
      }
    return compare (((RealNum)x).doubleValue (), value);
  }

  public boolean isExact ()
  {
    return false;
  }

  public boolean isZero ()
  {
    return value == 0.0;
  }

  /** Converts to the closest exact rational value. */
  public static RatNum toExact (double value)
  {
    if (Double.isInfinite (value))
      return RatNum.infinity(value >= 0.0 ? 1 : -1);
    if (Double.isNaN (value))
      throw new ArithmeticException ("cannot convert NaN to exact rational");
    long bits = Double.doubleToLongBits (value);
    boolean neg = bits < 0;
    int exp = (int) (bits >> 52) & 0x7FF;
    bits &= 0xfffffffffffffL;
    if (exp == 0)
      bits <<= 1;
    else
      bits |= 0x10000000000000L;
    IntNum mant = IntNum.make (neg ? -bits : bits);
    if (exp >= 1075)
      return IntNum.shift (mant, exp - 1075);
    else
      return RatNum.make (mant, IntNum.shift (IntNum.one(), 1075 - exp));
  }

   public String toString ()
   {
    return (value == 1.0/0.0 ? "#i1/0"
	    : value == -1.0/0.0 ? "#i-1/0"
	    : Double.isNaN (value) ? "#i0/0"
	    : Double.toString (value));
   }

   public String toString (int radix)
   {
    if (radix == 10)
      return toString ();
    return "#d" + toString ();
   }

  /**
   * @serialData Writes the number as a double (using writeDouble).
   */
  public void writeExternal(ObjectOutput out) throws IOException
  {
    out.writeDouble(value);
  }

  public void readExternal(ObjectInput in)
    throws IOException, ClassNotFoundException
  {
    value = in.readDouble();
  }

  /*
  static final int mine_e = -1024;
  static final long bp_1 = 1L << 52;

  static ?? flonum_digits (foubel v, long f, int e)
  {
    boolean round_p = (f & 1) == 0;
    if (e >= 0)
      {
	IntNum be = 1L << e;   // ???
	if (f != bp_1)
	  return scale (f * be * 2 (?), 2, be, be, 0, round_p, round_p, v);
	else
	  return scale (f * be * 4 (?), 4, 2 * be, b2, 0, round_p, round_p, v);
      }
    else
      {
	if (e == min_e || f != bp_1)
	  return scale (f * 2 (?), 2 ** (1 - 3), 1, 1, 0, round_p, round_p, v);
	else
	  return scale (f * 4 (?), 2 ** (2 - e), 2, 1, 0, round_p, round_p, v);
      }
  }

  static ?? scale (IntNum r, IntNum s, IntNum m_plus, IntNum m_minus,
		   int k, boolean low_ok?, boolean high_ok, double v)
  {
    int est = (int) Math.ceil(log10(v) - 1e-10);
    if (est >= 0)
      return fixup(r, s * expt10(est), m_plus, m_minus, est, low_ok, high_ok);
    else
      {
	IntNum scale = expt10(-ext);
	return fixup(r * scale, s, scale * m_plus, scale * m_minus,
		     est, low_ok, high_ok);
      }
  }

  static ?? fixup (IntNum r, IntNum s, IntNum m_plus, IntNum m_minus,
		   int k, boolean low_ok, boolean high_ok)
  {
    ...;
  }

  static ?? generate (IntNum r, IntNum s, IntNum m_plus, IntNum m_minus,
		      boolean low_ok, boolean high_ok)
  {
    IntNum d = new IntNum(), r = new IntNum();
    IntNum.divide (r, s, d, r, mode?);
    d = d.canonicalize();
    r = r.canonicalize();
    boolean tc1 = ?;
    boolean tc2 = ?;
  }

  static IntNum expt10 = null;

  static IntNum expt10 (int k)
  {
    if (expt10 == null)
      {
	expt10 = new IntNum[326];
	int i = 0;
	IntNum v = IntNum.one();
	for (; ; i++)
	  {
	    expt10[i] = v;
	    if (i == 325)
	      break;
	    v = IntNum.times(v, 10);
	  }
      }
    return expt10[k];
  }

  static double InvLog10 = 1.0 / Math.log(10);
  
  static double log10 (double x) { return Math.log(x) * InvLog10; }
  */
}
