namespace Ioke.Math {
    using System;

    public class DFloNum : RealNum {
        double value;
        
        public DFloNum() {}

        public DFloNum(double value) {
            this.value = value;
        }

        public DFloNum(string s) {
            value = double.Parse(s, System.Globalization.CultureInfo.InvariantCulture);
        }

        public override double doubleValue() {
            return value;
        }

        public override long longValue() {
            return (long) value;
        }

        public override int GetHashCode() {
            return (int)value;
        }

        public override bool isNegative() {
            return value < 0;
        }

        public override Numeric neg() {
            return new DFloNum (-value);
        }

        public override int sign() {
            return value > 0.0 ? 1 : value < 0.0 ? -1 : value == 0.0 ? 0: -2;
        }

        public override Numeric add(Object y, int k) {
            return null;
        }

        public override Numeric addReversed(Numeric x, int k) {
            return null;
        }

        public override Numeric mul(Object y) {
            return null;
        }

        public override Numeric mulReversed(Numeric x) {
            return null;
        }

        public override Numeric div(Object y) {
            return null;
        }

        public override bool isExact() {
            return false;
        }

        public override string toString(int radix) {
            return null;
        }
    }
}
