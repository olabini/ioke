// Copyright (c) 1999  Per M.A. Bothner.
// This is free software;  for terms and warranty disclaimer see ./COPYING.

package gnu.math;
import java.text.FieldPosition;

/** Format a real number using a floating-point format.
 * However, if `general' is true, and the number "fits",
 * use a fixed-point format (like printf %g).
 * Used for Common Lisp specs ~E and ~G;  also C-style %e and %g.
 */

public class ExponentialFormat extends java.text.Format
{
  /** Number of fractional digits to show.
   *  This is `d' in the CommonLisp spec. */
  public int fracDigits = -1;

  /** Number of digits to show in the integer part of the result.
   * If positive, The number of digits before the decimal point.
   * If negative, the -intDigits zeros are emitted after the decimal point.
  *  This is `k' in the CommonLisp spec. */
  public int intDigits;

  /** Number of digits to show in the exponent.
   * Zero means unspecified - show as many as needed. */
  public int expDigits;

  public char overflowChar;
  public char padChar;
  public char exponentChar = 'E';
  /** Display sign of exponent even when it is non-negative. */
  public boolean exponentShowSign;

  /** True if '+' should be printed for non-negative number. */
  public boolean showPlus;

  public int width;
  public boolean general;

  static final double LOG10 = Math.log(10);

  /** Add 1 to the integer in sbuf from digStart to digEnd.
   * @return if we overflowed. */
  static boolean addOne(StringBuffer sbuf, int digStart, int digEnd)
  {
    for (int j = digEnd ;  ; )
      {
	if (j == digStart)
	  {
	    sbuf.insert(j, '1');
	    return true;
	  }
	char ch = sbuf.charAt(--j);
	if (ch != '9')
	  {
	    sbuf.setCharAt(j, (char)((int) ch+1));
	    return false;
	  }
	sbuf.setCharAt(j, '0');
      }
  }

  public StringBuffer format(float value,
			     StringBuffer sbuf, FieldPosition fpos)
  {
    return format(value, fracDigits < 0 ? Float.toString(value) : null,
                  sbuf, fpos);
  }

  public StringBuffer format(double value,
			     StringBuffer sbuf, FieldPosition fpos)
  {
    return format(value, fracDigits < 0 ? Double.toString(value) : null,
                  sbuf, fpos);
  }

  StringBuffer format(double value, String dstr,
                      StringBuffer sbuf, FieldPosition fpos)
  {
    int k = intDigits;
    int d = fracDigits;
    boolean negative = value < 0;
    if (negative)
      value = -value;
    int oldLen = sbuf.length();
    int signLen = 1;
    if (negative)
      {
        if (d >= 0)
          sbuf.append('-');
        // Otherwise emitted by RealNum.toStringScientific.
      }
    else if (showPlus)
      sbuf.append('+');
    else
      signLen = 0;
    // Number of significant digits.
    int digits, scale;
    int digStart = sbuf.length();
    int exponent;
    boolean nonFinite = Double.isNaN(value) || Double.isInfinite(value);
    if (d < 0 || nonFinite)
      {
	if (dstr == null)
	  dstr = Double.toString(value); // Needed if nonFinite && d >= 0.
	int indexE = dstr.indexOf('E');
        if (indexE >= 0)
          {
            sbuf.append(dstr);
            indexE += digStart;
            boolean negexp = dstr.charAt(indexE+1) == '-';
            exponent = 0;
            for (int i = indexE + (negexp ? 2 : 1);  i < sbuf.length();  i++)
              exponent = 10 * exponent + (sbuf.charAt(i) - '0');
            if (negexp)
              exponent = -exponent;
            sbuf.setLength(indexE);
          }
        else
          exponent = RealNum.toStringScientific(dstr, sbuf);
        if (negative)
          digStart++;
        int dot = digStart + 1;
        /* #ifdef JAVA2 */
        sbuf.deleteCharAt(dot);
        /* #else */
        // String afterDot = sbuf.toString().substring(dot+1);
        // sbuf.setLength(dot);
        // sbuf.append(afterDot);
        /* #endif */
        digits = sbuf.length() - digStart;
        // Remove trailing '0' added by RealNum.toStringScientific.
        if (digits > 1 && sbuf.charAt(digStart+digits-1) == '0')
          sbuf.setLength(digStart + --digits);
        scale = digits - exponent - 1;
      }
    else
      {
        digits = d + (k > 0 ? 1 : k);
        int log = (int) (Math.log(value) / LOG10 + 1000.0); // floor
        if (log == 0x80000000) // value is zero
          log = 0;
        else
          log = log - 1000;
        scale = digits - log - 1;
        RealNum.toScaledInt(value, scale).format(10, sbuf);
        exponent = digits - 1 - scale;
      }

    exponent -= k - 1;
    int exponentAbs = exponent < 0 ? -exponent : exponent;
    int exponentLen = exponentAbs >= 1000 ? 4 : exponentAbs >= 100 ? 3
      : exponentAbs >= 10 ? 2 : 1;
    if (expDigits > exponentLen)
      exponentLen = expDigits;
    boolean showExponent = true;
    int ee = !general ? 0 : expDigits > 0 ? expDigits + 2 : 4;
    boolean fracUnspecified = d < 0;
    if (general || fracUnspecified)
      {
	int n = digits - scale;
	if (fracUnspecified)
	  {
	    d = n < 7 ? n : 7;
	    if (digits > d)
	      d = digits;
	  }
	int dd = d - n;
	if (general && (n >= 0 && dd >= 0))
	  {
	    // "arg is printed as if by the format directives 
	    //    ~ww,dd,0,overflowchar,padcharF~ee@T "
	    digits = d;
	    k = n;
	    showExponent = false; 
	  }
	else if (fracUnspecified)
	  {
	    if (width <= 0)
	      digits = d;
	    else
	      {
                int avail = width - signLen - exponentLen - 3;
		digits = avail;
		if (k < 0)
		  digits -= k;
		if (digits > d)
		  digits = d;
	      }
	    if (digits <= 0)
	      digits = 1;
	  }
      }

    int digEnd = digStart + digits;
    while (sbuf.length() < digEnd)
      sbuf.append('0');

    // Now round to specified digits.
    char nextDigit = digEnd == sbuf.length() ? '0' : sbuf.charAt(digEnd);
    boolean addOne = nextDigit >= '5';
    //      || (nextDigit == '5'
    //	  && (Character.digit(sbuf.charAt(digEnd-1), 10) & 1) == 0);
    if (addOne && addOne(sbuf, digStart, digEnd))
      scale++;
    // Truncate excess digits, after adjusting scale accordingly.
    scale -= sbuf.length() - digEnd;
    sbuf.setLength(digEnd);

    int dot = digStart;
    if (k < 0)
      {
	// Insert extra zeros after '.'.
	for (int j = k;  ++j <= 0; )
	  sbuf.insert(digStart, '0');
      }
    else
      {
	// Insert extra zeros before '.', if needed.
	for (;  digStart+k > digEnd;  digEnd++)
	  sbuf.append('0');
        dot += k;
      }
    if (nonFinite)
      showExponent = false;
    else
      sbuf.insert(dot, '.');

    int newLen, i;
    if (showExponent)
      {
	// Append the exponent.
	sbuf.append(exponentChar);
        if (exponentShowSign || exponent < 0)
          sbuf.append(exponent >= 0 ? '+' : '-');
	i = sbuf.length();
	sbuf.append(exponentAbs);
	newLen = sbuf.length();
	int j = expDigits - (newLen - i);
	if (j > 0)
	  { // Insert extra exponent digits.
	    newLen += j;
	    while (--j >= 0)
	      sbuf.insert(i, '0');
	  }
      }
    else
      {
        exponentLen = 0;
      }
    newLen = sbuf.length();
    int used = newLen - oldLen;
    i = width - used;

    // Insert '0' after '.' if needed and there is space.
    if (fracUnspecified
        && (dot + 1 == sbuf.length() || sbuf.charAt(dot+1) == exponentChar)
        && (width <= 0 || i > 0))
      {
        i--;
        sbuf.insert(dot+1, '0');
      }

    if ((i >= 0 || width <= 0)
	&& ! (showExponent && exponentLen > expDigits
	      && expDigits > 0 && overflowChar != '\0'))
      {
	// Insert optional '0' before '.' if there is space.
	if (k <= 0 && (i > 0 || width <= 0))
	  {
	    sbuf.insert(digStart, '0');
	    --i;
	  }
        if (! showExponent
            // The CommonLisp spec requires adding spaces on the right
            // when a ~g format ends up using fixed-point format, corresponding
            // to the space otherwise used for the exponent.  However, it seems
            // wrong to do so when using a variable-width format.
            && width > 0)
          {
            for (; --ee >= 0; --i) //  && sbuf.length() < oldLen + width; --i)
              sbuf.append(' ');
          }
	// Insert padding:
	while (--i >= 0)
	  sbuf.insert(oldLen, padChar);
      }
    else if (overflowChar != '\0')
      {
	sbuf.setLength(oldLen);
	for (i = width;  --i >= 0; )
	  sbuf.append(overflowChar);
     }
    return sbuf;
  }

  public StringBuffer format(long num, StringBuffer sbuf, FieldPosition fpos)
  {
    return format((double) num, sbuf, fpos);
  }

  public StringBuffer format(Object num, StringBuffer sbuf, FieldPosition fpos)
  {
    // Common Lisp says if value is non-real, print as if with ~wD.  FIXME.
    return format(((RealNum) num).doubleValue(), sbuf, fpos);
  }

  public java.lang.Number parse(String text, java.text.ParsePosition status)
  {
    throw new Error("ExponentialFormat.parse - not implemented");
  }
  public Object parseObject(String text, java.text.ParsePosition status)
  {
    throw new Error("ExponentialFormat.parseObject - not implemented");
  }

}
