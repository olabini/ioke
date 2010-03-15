namespace Ioke.Math {
    using System;

    public abstract class Complex : Quantity {
        public override Complex number() { return this; }

        public double doubleRealValue() {
            return doubleValue();
        }

        public static Complex power(Complex x, Complex y) {
            if(y is IntNum) {
                return (Complex) x.power((IntNum) y);
            }

            double x_re = x.doubleRealValue();
            double y_re = y.doubleRealValue();
            return new DFloNum(Math.Pow(x_re, y_re));
        }
    }
}
