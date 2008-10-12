// Copyright (c) 1999  Per M.A. Bothner.
// This is free software;  for terms and warranty disclaimer see ./COPYING.

package gnu.math;
import java.text.FieldPosition;

// Can't user NumberFormat, because it's format(Object, StringBuffer,
// FieldPosition) method is final - and does the wrong thing.
// (It ends up converting gnu.math number types to long!)

/** Format a real number using a fixed-point format.
 * Used for Common Lisp specs ~F and ~$;  also C-style %f.
 */

public class FixedRealFormat extends java.text.Format
{
  private int i, d;
  public int getMaximumFractionDigits() { return d; }
  public int getMinimumIntegerDigits() { return i; }
  public void setMaximumFractionDigits(int d) { this.d = d; }
  public void setMinimumIntegerDigits(int i) { this.i = i; }

  // These should not be public.  FIXME. 
  public int width;
  public int scale;
  public char padChar;
  public boolean showPlus;
  public boolean internalPad;
  public char overflowChar;

  public void format(RatNum number, boolean negative,
		     StringBuffer sbuf, FieldPosition fpos)
  {
    int decimals = getMaximumFractionDigits();
    int digits;
    int oldSize = sbuf.length();
    int signLen = 1;
    if (negative)
      sbuf.append('-');
    else if (showPlus)
      sbuf.append('+');
    else
      signLen = 0;
    String string;
    int length;
    if (decimals < 0)
      {
	double val = number.doubleValue();
	int log = (int) (Math.log(val) / ExponentialFormat.LOG10);
	int cur_scale = log == 0x80000000 ? 0 : 17 - log;
	string = RealNum.toScaledInt(val, cur_scale).toString();
	int i = string.length();
	digits = i - cur_scale + scale;
	if (width > 0)
	  decimals = width - signLen - 1 - digits;
	else
	  decimals = (i > 16 ? 16 : i) - digits;
	if (decimals < 0)
	  decimals = 0;
	sbuf.append(string);
	int digStart = oldSize + signLen;
	int digEnd = digStart + digits + decimals;
	i = sbuf.length();
	char nextDigit;
	if (digEnd >= i)
	  {
	    digEnd = i;
	    nextDigit = '0';
	  }
	else
	  nextDigit =  sbuf.charAt(digEnd);
	boolean addOne = nextDigit >= '5';
	char skip = addOne ? '9' : '0';
	while (digEnd > digStart + digits && sbuf.charAt(digEnd - 1) == skip)
	  digEnd--;
	length = digEnd - digStart;
	decimals = length - digits;
	if (addOne)
	  {
	    if (ExponentialFormat.addOne(sbuf, digStart, digEnd))
	      {
		digits++;
		decimals = 0;
		length = digits;
	      }
	  }
	if (decimals == 0 && (width <= 0
			      || signLen + digits + 1 < width))
	  {
	    decimals = 1;
	    length++;
	    // This is only needed if number==0.0:
	    sbuf.insert(digStart+digits, '0');
	  }
	sbuf.setLength(digStart + length);
      }
    else
      {
	string = RealNum.toScaledInt(number, decimals+scale).toString();
	sbuf.append(string);
	length = string.length();
	digits = length - decimals;
      }

    int total_digits = digits + decimals;
    // Number of initial zeros to add.
    int zero_digits = getMinimumIntegerDigits();
    if (digits >= 0 && digits > zero_digits)
      zero_digits = 0;
    else
      zero_digits -= digits;
    // If there are no integer digits, add an initial '0', if there is room.
    if (digits + zero_digits <= 0
	&& (width <= 0 || width > decimals + 1 + signLen))
      zero_digits++;
    int needed = signLen + length + zero_digits + 1;  /* Add 1 for '.'. */
    int padding = width - needed;
    for (int i = zero_digits;  --i >= 0; )
      sbuf.insert(oldSize + signLen, '0');
    if (padding >= 0)
      {
	int i = oldSize;
	if (internalPad && signLen > 0)
	  i++;
	while (--padding >= 0)
	  sbuf.insert(i, padChar);
      }
    else if (overflowChar != '\0')
      {
	sbuf.setLength(oldSize);
	for (i = width;  --i >= 0; )
	  sbuf.append(overflowChar);
	return;
     }
    int newSize = sbuf.length();
    sbuf.insert(newSize - decimals, '.');
    /* Requires JDK1.2 FieldPosition extensions:
    if (fpos == null)
      {
	newSize++;
	if (fpos.getField() == FRACTION_FIELD)
	  {
	    fpos.setBeginIndex(newSize-decimals);
	    fpos.setEndIndex(newSize);
	  }
	else if (fpos.getField() == INTEGER_FIELD)
	  {
	    fpos.setBeginIndex(newSize-decimals);
	    fpos.setEndIndex(newSize-length-zero_digits-1);
	  }
      }
    */
  }

  public void format(RatNum number, StringBuffer sbuf, FieldPosition fpos)
  {
    boolean negative = number.isNegative();
    if (negative)
      number = (RatNum) number.rneg();
    format(number, negative, sbuf, fpos);
  }

  public void format(RealNum number, StringBuffer sbuf, FieldPosition fpos)
  {
    if (number instanceof RatNum)
      format((RatNum) number, sbuf, fpos);
    else
      format(number.doubleValue(), sbuf, fpos);
  }

  public StringBuffer format(long num, StringBuffer sbuf, FieldPosition fpos)
  {
    format(IntNum.make(num), sbuf, fpos);
    return sbuf;
  }

  public StringBuffer format(double num, StringBuffer sbuf, FieldPosition fpos)
  {
    boolean negative;
    if (num < 0)
      {
	negative = true;
	num = -num;
      }
    else
      negative = false;
    format(DFloNum.toExact(num), negative, sbuf, fpos);
    return sbuf;
  }

  public StringBuffer format(Object num, StringBuffer sbuf, FieldPosition fpos)
  {
    // Common Lisp says if value is non-real, print as if with ~wD.  FIXME.
    return format(((RealNum) num).doubleValue(), sbuf, fpos);
  }

  public java.lang.Number parse(String text, java.text.ParsePosition status)
  {
    throw new Error("RealFixedFormat.parse - not implemented");
  }
  public Object parseObject(String text, java.text.ParsePosition status)
  {
    throw new Error("RealFixedFormat.parseObject - not implemented");
  }

}
