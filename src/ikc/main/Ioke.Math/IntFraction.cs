namespace Ioke.Math {
    using System;

    public class IntFraction : RatNum
    {
        IntNum num;
        IntNum den;

        IntFraction ()
            {
            }

        public IntFraction (IntNum num, IntNum den)
            {
                this.num = num;
                this.den = den;
            }

        public override IntNum numerator () { return num; }
        public override IntNum denominator () { return den; }

        public override bool isNegative () { return num.isNegative (); }

        public override int sign () { return num.sign (); }

        public override int CompareTo(object obj)
        {
            if (obj is RatNum)
                return RatNum.compare (this, (RatNum) obj);
            return ((RealNum)obj).compareReversed(this);
        }

        public override int compareReversed (Numeric x)
        {
            return RatNum.compare ((RatNum) x, this);
        }

        public override Numeric add (object y, int k)
        {
            if (y is RatNum)
                return RatNum.add (this, (RatNum) y, k);
            if (! (y is Numeric))
                throw new ArgumentException ();
            return ((Numeric)y).addReversed(this, k);
        }

        public override Numeric addReversed (Numeric x, int k)
        {
            if (! (x is RatNum))
                throw new ArgumentException ();
            return RatNum.add ((RatNum)x, this, k);
        }

        public override Numeric mul (object y)
        {
            if (y is RatNum)
                return RatNum.times (this, (RatNum)y);
            if (! (y is Numeric))
                throw new ArgumentException ();
            return ((Numeric)y).mulReversed(this);
        }

        public override Numeric mulReversed (Numeric x)
        {
            if (! (x is RatNum))
                throw new ArgumentException ();
            return RatNum.times ((RatNum) x, this);
        }

        public override Numeric div (object y)
        {
            if (y is RatNum)
                return RatNum.divide (this, (RatNum)y);
            if (! (y is Numeric))
                throw new ArgumentException ();
            return ((Numeric)y).divReversed(this);
        }

        public override Numeric divReversed (Numeric x)
        {
            if (! (x is RatNum))
                throw new ArgumentException ();
            return RatNum.divide ((RatNum)x, this);
        }

        public static IntFraction neg (IntFraction x)
        {
            // If x is normalized, we do not need to call RatNum.make to normalize.
            return new IntFraction (IntNum.neg (x.numerator()), x.denominator ());
        }

        public override Numeric neg ()
        {
            return IntFraction.neg (this);
        }

        public override long longValue ()
        {
            return toExactInt (ROUND).longValue ();
        }

        public override double doubleValue ()
        {
            bool neg = num.isNegative ();
            if (den.isZero())
                return (neg ? Double.NegativeInfinity
                        : num.isZero() ? Double.NaN
                        : Double.PositiveInfinity);
            IntNum n = num;
            if (neg)
                n = IntNum.neg (n);
            int num_len = n.intLength ();
            int den_len = den.intLength ();
            int exp = 0;
            if (num_len < den_len + 54)
                {
                    exp = den_len + 54 - num_len;
                    n = IntNum.shift (n, exp);
                    exp = - exp;
                }

            // Divide n (which is shifted num) by den, using truncating division,
            // and return quot and remainder.
            IntNum quot = new IntNum ();
            IntNum remainder = new IntNum ();
            IntNum.divide (n, den, quot, remainder, TRUNCATE);
            quot = quot.canonicalize ();
            remainder = remainder.canonicalize ();

            return quot.roundToDouble (exp, neg, !remainder.isZero ());
        }

        public override string toString (int radix)
        {
            return num.toString(radix) + '/' + den.toString(radix);
        }
    }
}
