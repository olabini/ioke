
namespace Ioke.Math { 
    using System;
    public abstract class Numeric : IComparable {
        public abstract double doubleValue();
        public virtual float floatValue () { return (float) doubleValue(); }
        public virtual int intValue() { return (int) longValue(); }
        public virtual long longValue() { return (long) doubleValue(); }

        /** Return this + k * obj. */
        public abstract Numeric add (object obj, int k);

        public Numeric add (object obj) { return add (obj, 1); }
        public Numeric sub (object obj) { return add (obj, -1); }

        public abstract Numeric mul (object obj);

        public abstract Numeric div (object obj);

        public abstract Numeric abs ();

        public abstract Numeric neg ();

        public abstract string toString (int radix);

        public override string ToString () { return toString (10); }

        public abstract bool isExact ();

        public abstract bool isZero ();

        /* Rounding modes: */
        public const int FLOOR = 1;
        public const int CEILING = 2;
        public const int TRUNCATE = 3;
        public const int ROUND = 4;

        /** Return an integer for which of {# code this} or {#code obj} is larger.
         * Return 1 if {@code this>obj}; 0 if {@code this==obj};
         * -1 if {@code this<obj};
         * -2 if {@code this!=obj} otherwise (for example if either is NaN);
         * -3 if not comparable (incompatible types). */
        public virtual int CompareTo(object obj)
        {
            return -3;
        }

        public virtual int compareReversed (Numeric x)
        {
            throw new ArgumentException ();
        }

        public override int GetHashCode() {
            return intValue();
        }

        public override bool Equals (object obj)
        {
            if (obj == null || ! (obj is Numeric))
                return false;
            return CompareTo(obj) == 0;
        }

        public bool grt (object x)
        {
            return CompareTo(x) > 0;
        }

        public bool  geq (object x)
        {
            return CompareTo(x) >= 0;
        }

        /** Calculate x+k&this. */
        public virtual Numeric addReversed (Numeric x, int k)
        {
            throw new ArgumentException ();
        }

        public virtual Numeric mulReversed (Numeric x)
        {
            throw new ArgumentException ();
        }

        public virtual Numeric divReversed (Numeric x)
        {
            throw new ArgumentException ();
        }

        /** Return the multiplicative inverse. */
        public virtual Numeric div_inv ()
        {
            return IntNum.one().div(this);
        }

        /** Return the multiplicative identity. */
        public virtual Numeric mul_ident ()
        {
            return IntNum.one();
        }

        /** Return this raised to an integer power.
         * Implemented by repeated squaring and multiplication.
         * If y < 0, returns div_inv of the result. */
        public virtual Numeric power (IntNum y)
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
}
