// Copyright (c) 1997, 2004, 2006  Per M.A. Bothner.
// This is free software;  for terms and warranty disclaimer see ./COPYING.

package gnu.math;
import java.math.BigDecimal;

public abstract class RealNum extends Complex
  /* #ifdef JAVA2 */
  implements Comparable
  /* #endif */
{
  public final RealNum re() { return this; }
  public final RealNum im() { return IntNum.zero(); }

  public abstract boolean isNegative ();

  /** Return 1 if >0; 0 if ==0; -1 if <0; -2 if NaN. */
  public abstract int sign ();

  public RealNum max (RealNum x)
  {
    boolean exact = isExact () && x.isExact ();
    RealNum result = grt (x) ? this : x;
    if (!exact && result.isExact ())
      result = new DFloNum (result.doubleValue ());
    return result;
  }

  public RealNum min (RealNum x)
  {
    boolean exact = isExact () && x.isExact ();
    RealNum result = grt (x) ? x : this;
    if (!exact && result.isExact ())
      result = new DFloNum (result.doubleValue ());
    return result;
  }

  public static RealNum add (RealNum x, RealNum y, int k)
  {
    return (RealNum)(x.add(y, k));
  }

  public static RealNum times(RealNum x, RealNum y)
  {
    return (RealNum)(x.mul(y));
  }

  public static RealNum divide (RealNum x, RealNum y)
  {
    return (RealNum)(x.div(y));
  }

  /* These are defined in Complex, but have to be overridden. */
  public abstract Numeric add (Object obj, int k);
  public abstract Numeric mul (Object obj);
  public abstract Numeric div (Object obj);

  public Numeric abs ()
  {
    return isNegative () ? neg () : this;
  }

  public final RealNum rneg() { return (RealNum) neg(); }

  public boolean isZero ()
  {
    return sign () == 0;
  }

  /** Convert to an exact number.
   * Implements the Scheme inexact->exact (for real numbers).
   */
  public RatNum toExact ()
  {
    return DFloNum.toExact (doubleValue ());
  }

  /** Converts a real to an integer, according to a specified rounding mode.
   * Note an inexact argument gives an inexact result, following Scheme.
   * See also RatNum.toExactInt. */
  public static double toInt (double d, int rounding_mode)
  {
    switch (rounding_mode)
      {
      case FLOOR:
	return Math.floor(d);
      case CEILING:
	return Math.ceil(d);
      case TRUNCATE:
	return d < 0.0 ? Math.ceil (d) : Math.floor (d);
      case ROUND:
	return Math.rint(d);
      default:  // Illegal rounding_mode
	return d;
      }
  }

  /** Converts a real to an integer, according to a specified rounding mode.
   * Note an inexact argument gives an inexact result, following Scheme.
   * See also toExactInt. */
  public RealNum toInt (int rounding_mode)
  {
    return new DFloNum(toInt(doubleValue(), rounding_mode));
  }

  /** Converts to an exact integer, with specified rounding mode. */
  public IntNum toExactInt (int rounding_mode)
  {
    return toExactInt(doubleValue(), rounding_mode);
  }

  /** Converts real to an exact integer, with specified rounding mode. */
  public static IntNum toExactInt (double value, int rounding_mode)
  {
    return toExactInt(toInt(value, rounding_mode));
  }

  /** Converts an integral double (such as a toInt result) to an IntNum. */
  public static IntNum toExactInt (double value)
  {
    if (Double.isInfinite (value) || Double.isNaN (value))
      throw new ArithmeticException ("cannot convert "+value+" to exact integer");
    long bits = Double.doubleToLongBits (value);
    boolean neg = bits < 0;
    int exp = (int) (bits >> 52) & 0x7FF;
    bits &= 0xfffffffffffffL;
    if (exp == 0)
      bits <<= 1;
    else
      bits |= 0x10000000000000L;
    if (exp <= 1075)
      {
	int rshift = 1075 - exp;
	if (rshift > 53)
	  return IntNum.zero();
	bits >>= rshift;
	return IntNum.make (neg ? -bits : bits);
      }
    return IntNum.shift (IntNum.make (neg ? -bits : bits), exp - 1075);
  }

  public Complex exp ()
  {
    return new DFloNum(Math.exp(doubleValue()));
  }

  public Complex log ()
  {
    double x = doubleValue();
    if (x < 0)
      return DComplex.log(x, 0.0);
    return new DFloNum(Math.log(x));
  }

  public final Complex sin() { return new DFloNum(Math.sin(doubleValue())); }

  public final Complex sqrt ()
  {
    double d = doubleValue();
    if (d >= 0)
      return new DFloNum(Math.sqrt(d));
    else
      return DComplex.sqrt(d, 0);
  }

  /** Convert double to (rounded) integer, after multiplying by 10**k. */
  public static IntNum toScaledInt (double f, int k)
  {
    return toScaledInt(DFloNum.toExact(f), k);
  }

  /** Convert rational to (rounded) integer, after multiplying by 10**k. */
  public static IntNum toScaledInt (RatNum r, int k)
  {
    if (k != 0)
      {
	IntNum power = IntNum.power(IntNum.ten(), k < 0 ? -k : k);
	IntNum num = r.numerator();
	IntNum den = r.denominator();
	if (k >= 0)
	  num = IntNum.times(num, power);
	else
	  den = IntNum.times(den, power);
	r = RatNum.make(num, den);
      }
    return r.toExactInt(ROUND);
  }

  /** Convert this to (rounded) integer, after multiplying by 10**k. */
  public IntNum toScaledInt (int k)
  {
    return toScaledInt(toExact(), k);
  }

  /*
  public static String toScaledIntString (double f, int k)
  {
    switch (k)
      {
      case 0:  break;
      case 1:  f = f * 10;  break;
      case 2:  f = f * 100;  break;
      case 3:  f = f * 1000;  break;
      default: return toScaledInt(f, k).toString();
      }
    return Long.toString((long) f);
  }
  */

  /** Implements the Comparable interface.
   * This ordering isn't fully consistent with equals, since say
   * it returns 0 when comparing 1.5 and 3/2, though they are not equals.
   */
  public int compareTo(Object o)
  {
    return compare(o);
  }

  public java.math.BigDecimal asBigDecimal ()
  {
    return new BigDecimal(doubleValue());
  }

  public static String toStringScientific (float d)
  {
    return toStringScientific(Float.toString(d));
  }

  public static String toStringScientific (double d)
  {
    return toStringScientific(Double.toString(d));
  }

  /** Convert result of Double.toString or Float.toString to
   * scientific notation.
   * Does not validate the input.
   */
  public static String toStringScientific (String dstr)
  {
    int indexE = dstr.indexOf('E');
    if (indexE >= 0)
      return dstr;
    int len = dstr.length();
    // Check for "Infinity" or "NaN".
    char ch = dstr.charAt(len-1);
    if (ch == 'y' || ch == 'N')
      return dstr;
    StringBuffer sbuf = new StringBuffer(len+10);
    int exp = toStringScientific(dstr, sbuf);
    sbuf.append('E');
    sbuf.append(exp);
    return sbuf.toString();
  }

  public static int toStringScientific (String dstr, StringBuffer sbuf)
  {
    boolean neg = dstr.charAt(0) == '-';
    if (neg)
      sbuf.append('-');
    int pos = neg ? 1 : 0;
    int exp;
    int len = dstr.length();
    if (dstr.charAt(pos) == '0')
      { // Value is < 1.0.
        int start = pos;
        for (;;)
          {
            if (pos == len)
              {
                sbuf.append("0");
                exp = 0;
                break;
              }
            char ch = dstr.charAt(pos++);
            if (ch >= '0' && ch <= '9' && (ch != '0' || pos == len))
              {
                sbuf.append(ch);
                sbuf.append('.');
                exp = ch == '0' ? 0 : start - pos + 2;
                if (pos == len)
                  sbuf.append('0');
                else
                  {
                    while (pos < len)
                      sbuf.append(dstr.charAt(pos++));
                  }
                break;
              }
          }
      }
    else
      {
        // Number of significant digits in string.
        int ndigits = len - (neg ? 2 : 1);
        int dot = dstr.indexOf('.');
        // Number of fractional digits is len-dot-1.
        // We want ndigits-1 fractional digits.  Hence we need to move the
        // decimal point ndigits-1-(len-dot-1) == ndigits-len+dot positions
        // to the left. This becomes the exponent we need.
        exp = ndigits - len + dot;
        sbuf.append(dstr.charAt(pos++)); // Copy initial digit before point.
        sbuf.append('.');
        while (pos < len)
          {
            char ch = dstr.charAt(pos++);
            if (ch != '.')
              sbuf.append(ch);
          }
      }
    // Remove excess zeros.
    pos = sbuf.length();
    int slen = -1;
    for (;;)
      {
        char ch = sbuf.charAt(--pos);
        if (ch == '0')
          slen = pos;
        else
          {
            if (ch == '.')
              slen = pos + 2;
            break;
          }
      }
    if (slen >= 0)
      sbuf.setLength(slen);
    return exp;
  }

  public static String toStringDecimal (String dstr)
  {
    int indexE = dstr.indexOf('E');
    if (indexE < 0)
      return dstr;
    int len = dstr.length();
    // Check for "Infinity" or "NaN".
    char ch = dstr.charAt(len-1);
    if (ch == 'y' || ch == 'N')
      return dstr;
    StringBuffer sbuf = new StringBuffer(len+10);
    boolean neg = dstr.charAt(0) == '-';
    if (dstr.charAt(indexE+1) != '-')
      {
        throw new Error("not implemented: toStringDecimal given non-negative exponent: "+dstr);
      }
    else
      {
        int pos = indexE+2;  // skip "E-".
        int exp = 0;
        while (pos < len)
          exp = 10 * exp + (dstr.charAt(pos++) - '0');
        if (neg)
          sbuf.append('-');
        sbuf.append("0.");
        while (--exp > 0) sbuf.append('0');
        for (pos = 0; (ch = dstr.charAt(pos++)) != 'E'; )
          {
            if (ch != '-' & ch != '.'
                && (ch != '0' || pos < indexE))
              sbuf.append(ch);
          }
        return sbuf.toString();
      }
  }
}
