namespace Ioke.Math {
    using System;
    using System.Text;

    public abstract class RealNum : Complex {
        public override RealNum re() { return this; }
        public override RealNum im() { return IntNum.zero(); }

        public abstract bool isNegative ();

        /** Return 1 if >0; 0 if ==0; -1 if <0; -2 if NaN. */
        public abstract int sign ();

        public RealNum max (RealNum x)
        {
            RealNum result = grt (x) ? this : x;
            return result;
        }

        public RealNum min (RealNum x)
        {
            RealNum result = grt (x) ? x : this;
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
        public override abstract Numeric add (object obj, int k);
        public override abstract Numeric mul (object obj);
        public override abstract Numeric div (object obj);

        public override Numeric abs ()
        {
            return isNegative () ? neg () : this;
        }

        public RealNum rneg() { return (RealNum) neg(); }

        public override bool isZero ()
        {
            return sign () == 0;
        }

        /** Converts a real to an integer, according to a specified rounding mode.
         * Note an inexact argument gives an inexact result, following Scheme.
         * See also RatNum.toExactInt. */
        public static double toInt (double d, int rounding_mode)
        {
            switch (rounding_mode)
                {
                case FLOOR:
                    return Math.Floor(d);
                case CEILING:
                    return Math.Ceiling(d);
                case TRUNCATE:
                    return d < 0.0 ? Math.Ceiling (d) : Math.Floor (d);
                case ROUND:
                    return Math.Round(d);
                default:  // Illegal rounding_mode
                    return d;
                }
        }

        /** Converts to an exact integer, with specified rounding mode. */
        public virtual IntNum toExactInt (int rounding_mode)
        {
            return toExactInt(doubleValue(), rounding_mode);
        }

        public abstract RealNum toInt (int rounding_mode);

        /** Converts real to an exact integer, with specified rounding mode. */
        public static IntNum toExactInt (double value, int rounding_mode)
        {
            return toExactInt(toInt(value, rounding_mode));
        }

        /** Converts an integral double (such as a toInt result) to an IntNum. */
        public static IntNum toExactInt (double value)
        {
            if (Double.IsInfinity (value) || Double.IsNaN (value))
                throw new ArithmeticException ("cannot convert "+value+" to exact integer");
            long bits =  BitConverter.DoubleToInt64Bits(value);
            bool neg = bits < 0;
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

        public static string toStringScientific (float d)
        {
            return toStringScientific(d.ToString());
        }

        public static string toStringScientific (double d)
        {
            return toStringScientific(d.ToString());
        }

        /** Convert result of Double.toString or Float.toString to
         * scientific notation.
         * Does not validate the input.
         */
        public static string toStringScientific (string dstr)
        {
            int indexE = dstr.IndexOf('E');
            if (indexE >= 0)
                return dstr;
            int len = dstr.Length;
            // Check for "Infinity" or "NaN".
            char ch = dstr[len-1];
            if (ch == 'y' || ch == 'N')
                return dstr;
            StringBuilder sbuf = new StringBuilder(len+10);
            int exp = toStringScientific(dstr, sbuf);
            sbuf.Append('E');
            sbuf.Append(exp);
            return sbuf.ToString();
        }

        public static int toStringScientific (string dstr, StringBuilder sbuf)
        {
            bool neg = dstr[0] == '-';
            if (neg)
                sbuf.Append('-');
            int pos = neg ? 1 : 0;
            int exp;
            int len = dstr.Length;
            if (dstr[pos] == '0')
                { // Value is < 1.0.
                    int start = pos;
                    for (;;)
                        {
                            if (pos == len)
                                {
                                    sbuf.Append("0");
                                    exp = 0;
                                    break;
                                }
                            char ch = dstr[pos++];
                            if (ch >= '0' && ch <= '9' && (ch != '0' || pos == len))
                                {
                                    sbuf.Append(ch);
                                    sbuf.Append('.');
                                    exp = ch == '0' ? 0 : start - pos + 2;
                                    if (pos == len)
                                        sbuf.Append('0');
                                    else
                                        {
                                            while (pos < len)
                                                sbuf.Append(dstr[pos++]);
                                        }
                                    break;
                                }
                        }
                }
            else
                {
                    // Number of significant digits in string.
                    int ndigits = len - (neg ? 2 : 1);
                    int dot = dstr.IndexOf('.');
                    // Number of fractional digits is len-dot-1.
                    // We want ndigits-1 fractional digits.  Hence we need to move the
                    // decimal point ndigits-1-(len-dot-1) == ndigits-len+dot positions
                    // to the left. This becomes the exponent we need.
                    exp = ndigits - len + dot;
                    sbuf.Append(dstr[pos++]); // Copy initial digit before point.
                    sbuf.Append('.');
                    while (pos < len)
                        {
                            char ch = dstr[pos++];
                            if (ch != '.')
                                sbuf.Append(ch);
                        }
                }
            // Remove excess zeros.
            pos = sbuf.Length;
            int slen = -1;
            for (;;)
                {
                    char ch = sbuf[--pos];
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
                sbuf.Length = slen;
            return exp;
        }

        public static string toStringDecimal (string dstr)
        {
            int indexE = dstr.IndexOf('E');
            if (indexE < 0)
                return dstr;
            int len = dstr.Length;
            // Check for "Infinity" or "NaN".
            char ch = dstr[len-1];
            if (ch == 'y' || ch == 'N')
                return dstr;
            StringBuilder sbuf = new StringBuilder(len+10);
            bool neg = dstr[0] == '-';
            if (dstr[indexE+1] != '-')
                {
                    throw new Exception("not implemented: toStringDecimal given non-negative exponent: "+dstr);
                }
            else
                {
                    int pos = indexE+2;  // skip "E-".
                    int exp = 0;
                    while (pos < len)
                        exp = 10 * exp + (dstr[pos++] - '0');
                    if (neg)
                        sbuf.Append('-');
                    sbuf.Append("0.");
                    while (--exp > 0) sbuf.Append('0');
                    for (pos = 0; (ch = dstr[pos++]) != 'E'; )
                        {
                            if (ch != '-' & ch != '.'
                                && (ch != '0' || pos < indexE))
                                sbuf.Append(ch);
                        }
                    return sbuf.ToString();
                }
        }

        public virtual decimal AsDecimal() {
            return System.Convert.ToDecimal(doubleValue());
        }

        public virtual BigDecimal AsBigDecimal() {
            return new BigDecimal(doubleValue().ToString());
        }
    }
}
