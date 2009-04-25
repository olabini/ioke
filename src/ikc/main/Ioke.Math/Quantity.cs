namespace Ioke.Math {
    using System;

    public abstract class Quantity : Numeric {
        public abstract Complex number ();

        /** The value of the real component, as a RealNum.
         * The unit() is not factored in, so you actually need to multiply
         * by unit() to get the true real component.
         */
        public virtual RealNum re () { return number().re(); }

        /** The value of the imaginary component, as a RealNum.
         * The unit() is not factored in, so you actually need to multiply
         * by unit() to get the true imaginary component.
         */
        public virtual RealNum im () { return number().im(); }

        /** The value of the real component, as a double.
         * This is relative to the unit().dims - i.e. unit().doubleValue()
         * is factored in.
         * A final alias for the virtual doubleValue. */
        public virtual double reValue() { return doubleValue(); }

        /** The value of the imaginary component, as a double.
         * This is relative to the unit().dims - i.e. unit().doubleValue()
         * is factored in.
         * A final alias for the virtual doubleImagValue. */
        public virtual double imValue() { return doubleImagValue(); }

        /** The value of the real component, as a double.
         * This is relative to the unit().dims - i.e. unit()/doubleValue()
         * is factored in. */
        public override double doubleValue ()
        { return re().doubleValue (); }

        /** The value of the imaginary component, as a double.
         * This is relative to the unit().dims - i.e. unit()/doubleValue()
         * is factored in. */
        public virtual double doubleImagValue() {return im().doubleValue ();}

        public virtual string ToString (int radix)
        {
            string str = number ().ToString (radix);
            return str;
        }
    }
}
