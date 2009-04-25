// Copyright (c) 1997  Per M.A. Bothner.
// This is free software;  for terms and warranty disclaimer see ./COPYING.

package gnu.math;
import java.io.*;

/** A complex number using rectangular (Cartesian) plain double values.
 * @author Per Bothner
 * @author Some algorithms were transcribed from GNU libstdc++,
 * written by Jason Merrill.
 * Also see below for copyrights for functions taken from fdlib and f2c.
 */

public class DComplex extends Complex implements Externalizable
{ 
  double real;
  double imag;

  public DComplex ()
  {
  }

  public DComplex (double real, double imag)
  {
    this.real = real;
    this.imag = imag;
  }

  public RealNum re () { return new DFloNum (real); }
  public double doubleValue() { return real; }
  public RealNum im () { return new DFloNum (imag); }
  public double doubleImagValue () { return imag; }

  public boolean equals (Object obj)
  {
    if (obj == null || ! (obj instanceof Complex))
      return false;
    Complex y = (Complex)obj;
    return y.unit() == Unit.Empty
      && (Double.doubleToLongBits(real)
	  == Double.doubleToLongBits(y.reValue()))
      && (Double.doubleToLongBits(imag)
	  == Double.doubleToLongBits(y.imValue()));
  }

  public String toString ()
  {
    String prefix = "";

    String reString;
    if (real == 1.0/0.0)
      {
	prefix = "#i"; reString = "1/0";
      }
    else if (real == -1.0/0.0)
      {
	prefix = "#i"; reString = "-1/0";
      }
    else if (Double.isNaN (real))
      {
	prefix = "#i"; reString = "0/0";
      }
    else
      reString = Double.toString (real);

    if (Double.doubleToLongBits (imag) == 0)  // i.e. imag is 0.0 and not -0.0
      return prefix + reString;

    String imString;
    if (imag == 1.0/0.0)
      {
	prefix = "#i"; imString = "+1/0i";
      }
    else if (imag == -1.0/0.0)
      {
	prefix = "#i"; imString = "-1/0i";
      }
    else if (Double.isNaN (imag))
      {
	prefix = "#i"; imString = "+0/0i";
      }
    else
      {
	imString = Double.toString (imag) + "i";
	if (imString.charAt (0) != '-')
	  imString = "+" + imString;
      }

    return ((Double.doubleToLongBits (real) == 0 ? prefix : prefix + reString)
            + imString);
  }

  public String toString (int radix)
  {
    if (radix == 10)
      return toString ();
    return "#d" + toString ();
  }

  // All transcendental complex functions return DComplex

  public final Numeric neg () { return new DComplex (-real, -imag); }

  public Numeric add (Object y, int k)
  {
    if (y instanceof Complex)
      {
        Complex yc = (Complex)y;
	if (yc.dimensions() != Dimensions.Empty)
	  throw new ArithmeticException ("units mis-match");
	return new DComplex (real + k * yc.reValue(),
			     imag + k * yc.imValue());
      }
    return ((Numeric)y).addReversed(this, k);
  }

  public Numeric mul (Object y)
  {
    if (y instanceof Complex)
      {
        Complex yc = (Complex)y;
	if (yc.unit() == Unit.Empty)
	  {
	    double y_re = yc.reValue();
	    double y_im = yc.imValue();
	    return new DComplex (real * y_re - imag * y_im,
				 real * y_im + imag * y_re);
	  }
	return Complex.times(this, yc);
      }
    return ((Numeric)y).mulReversed(this);
  }

  public Numeric div (Object y)
  {
    if (y instanceof Complex)
      {
	Complex yc = (Complex) y;
	return div (real, imag,
		    yc.doubleValue(), yc.doubleImagValue());
      }
    return ((Numeric)y).divReversed(this);
  }

  public static DComplex power (double x_re, double x_im,
				double y_re, double y_im)
  {
    double h;
    /* #ifdef JAVA5 */
    // h = Math.hypot(x_re, x_im);
    /* #else */
    h = DComplex.hypot(x_re, x_im);
    /* #endif */
    double logr = Math.log (h);
    double t = Math.atan2 (x_im, x_re);
    double r = Math.exp (logr * y_re - y_im * t);
    t = y_im * logr + y_re * t;
    return Complex.polar (r, t);
  }

  public static Complex log (double x_re, double x_im)
  {
    double h;
    /* #ifdef JAVA5 */
    // h = Math.hypot(x_re, x_im);
    /* #else */
    h = DComplex.hypot(x_re, x_im);
    /* #endif */
    return make(Math.log(h), Math.atan2(x_im, x_re));
  }

  // The code below is adapted from f2c's libF77, and is subject to this
  // copyright:
 
  /****************************************************************
    Copyright 1990, 1991, 1992, 1993 by AT&T Bell Laboratories and Bellcore.
 
    Permission to use, copy, modify, and distribute this software
    and its documentation for any purpose and without fee is hereby
    granted, provided that the above copyright notice appear in all
    copies and that both that the copyright notice and this
    permission notice and warranty disclaimer appear in supporting
    documentation, and that the names of AT&T Bell Laboratories or
    Bellcore or any of their entities not be used in advertising or
    publicity pertaining to distribution of the software without
    specific, written prior permission.
 
    AT&T and Bellcore disclaim all warranties with regard to this
    software, including all implied warranties of merchantability
    and fitness.  In no event shall AT&T or Bellcore be liable for
    any special, indirect or consequential damages or any damages
    whatsoever resulting from loss of use, data or profits, whether
    in an action of contract, negligence or other tortious action,
    arising out of or in connection with the use or performance of
    this software.
    ****************************************************************/

  public static DComplex div (double x_re, double x_im,
			      double y_re, double y_im)
  {
    double ar = Math.abs (y_re);
    double ai = Math.abs (y_im);
    double nr, ni;
    double t, d;
    if (ar <= ai)
      {
	t = y_re / y_im;
	d = y_im * (1 + t*t);
	nr = x_re * t + x_im;
	ni = x_im * t - x_re;
      }
    else
      {
	t = y_im / y_re;
	d = y_re * (1 + t*t);
	nr = x_re + x_im * t;
	ni = x_im - x_re * t;
      }
    return new DComplex (nr / d, ni / d);
  }
  
  public static Complex sqrt (double x_re, double x_im)
  {
    /* #ifdef JAVA5 */
    // double r = Math.hypot(x_re, x_im);
    /* #else */
    double r = DComplex.hypot(x_re, x_im);
    /* #endif */
    double nr, ni;
    if (r == 0.0)
      nr = ni = r;
    else if (x_re > 0)
      {
	nr = Math.sqrt (0.5 * (r + x_re));
	ni = x_im / nr / 2;
      }
    else
      {
	ni = Math.sqrt (0.5 * (r - x_re));
	if (x_im < 0)
	  ni = - ni;
	nr = x_im / ni / 2;
      }
    return new DComplex (nr, ni);
  }

  // Transcribed from:
  // http://netlib.bell-labs.com/netlib/fdlibm/e_hypot.c.Z
  /*
   * ====================================================
   * Copyright (C) 1993 by Sun Microsystems, Inc. All rights reserved.
   *
   * Developed at SunSoft, a Sun Microsystems, Inc. business.
   * Permission to use, copy, modify, and distribute this
   * software is freely granted, provided that this notice 
   * is preserved.
   * ====================================================
   */
  /* __ieee754_hypot(x,y)
   *
   * Method :                  
   *      If (assume round-to-nearest) z=x*x+y*y 
   *      has error less than sqrt(2)/2 ulp, than 
   *      sqrt(z) has error less than 1 ulp (exercise).
   *
   *      So, compute sqrt(x*x+y*y) with some care as 
   *      follows to get the error below 1 ulp:
   *
   *      Assume x>y>0;
   *      (if possible, set rounding to round-to-nearest)
   *      1. if x > 2y  use
   *              x1*x1+(y*y+(x2*(x+x1))) for x*x+y*y
   *      where x1 = x with lower 32 bits cleared, x2 = x-x1; else
   *      2. if x <= 2y use
   *              t1*y1+((x-y)*(x-y)+(t1*y2+t2*y))
   *      where t1 = 2x with lower 32 bits cleared, t2 = 2x-t1, 
   *      y1= y with lower 32 bits chopped, y2 = y-y1.
   *              
   *      NOTE: scaling may be necessary if some argument is too 
   *            large or too tiny
   *
   * Special cases:
   *      hypot(x,y) is INF if x or y is +INF or -INF; else
   *      hypot(x,y) is NAN if x or y is NAN.
   *
   * Accuracy:
   *      hypot(x,y) returns sqrt(x^2+y^2) with error less 
   *      than 1 ulps (units in the last place) 
   */

  /* #ifndef JAVA5 */
  static double hypot (double x, double y)
  {
    double a=x,b=y,t1,t2,w;
    int j,ha,hb;
    long la = (Double.doubleToLongBits(x) << 1) >>> 1;
    long lb = (Double.doubleToLongBits(y) << 1) >>> 1;

    ha = (int)(la >>> 32);        // high word of  x
    hb = (int)(lb >>> 32);        // high word of  y
    if (hb > ha)
      {
        j=ha; ha=hb; hb=j;
        long l=la; la=lb; lb=l;
      }
    a = Double.longBitsToDouble(la);   // a <- |a|
    b = Double.longBitsToDouble(lb);   // b <- |b|
    /* Now a is max (abs(x), abs(y)) and b is min(abs(x), abs(y));
       la and lb are the long bits of a and b;
       and ha and hb are the high order bits of la and lb. */
    if ((ha-hb) > 0x3c00000) // x/y > 2**60
      return a+b;
    int k=0;
    j = 0;  // scale as high-order of double
    if (ha > 0x5f300000)
      {   // a>2**500
        if (ha >= 0x7ff00000)
          {       // Inf or NaN
            w = a+b;                 // for sNaN
            if ((la & 0xfffffffffffffL) == 0)
              w = a;
            if ((lb^0x7ff0000000000000L) == 0)
              w = b;
            return w;
          }
        /* scale a and b by 2**-600 */
        j = -0x25800000;  k += 600;
      }
    if (hb < 0x20b00000)
      {   // b < 2**-500
        if (hb <= 0x000fffff)
          {      // subnormal b or 0  
            if (lb == 0)
              return a;
            t1 = Double.longBitsToDouble(0x7fd0000000000000L); // t1=2^1022
            b *= t1;
            a *= t1;
            k -= 1022;
          }
        else
          {            // scale a and b by 2^600
            k -= 600;
            j = 0x25800000;
          }
      }
    if (j != 0)
      {
        ha += j; hb += j;
        la += (j << 32);  lb += (j << 32);
        a = Double.longBitsToDouble(la);
        b = Double.longBitsToDouble(lb);
      }

    /* medium size a and b */
    w = a-b;
    if (w>b)
      {
        t1 = Double.longBitsToDouble ((long) ha << 32);
        t2 = a-t1;
        w  = t1*t1-(b*(-b)-t2*(a+t1)); 
      }
    else
      {
        a = a+a;
        double y1 = Double.longBitsToDouble ((long) hb << 32);
        double y2 = b - y1;
        t1 = Double.longBitsToDouble (((long) (ha+0x00100000)) << 32);
        t2 = a - t1;
        w  = t1*y1-(w*(-w)-(t1*y2+t2*b));
      }
    w = Math.sqrt(w);
    if(k!=0)
      { // t1 = 2^k
        t1 = Double.longBitsToDouble (0x3ff0000000000000L + ((long)k << 52));
        w *= t1;
      }
    return w;
  }
  /* #endif */

  /**
   * @serialData Writes the real part, followed by the imaginary part.
   *   Both are written as doubles (using writeDouble).
   */
  public void writeExternal(ObjectOutput out) throws IOException
  {
    out.writeDouble(real);
    out.writeDouble(imag);
  }

  public void readExternal(ObjectInput in)
    throws IOException, ClassNotFoundException
  {
    real = in.readDouble();
    imag = in.readDouble();
  }
}
