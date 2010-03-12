
namespace Ioke.Math {
    using System;
    using System.Text;

    public sealed class MathContext {
        public static readonly MathContext DECIMAL128 = new MathContext(34, RoundingMode.HALF_EVEN);
        public static readonly MathContext DECIMAL32 = new MathContext(7, RoundingMode.HALF_EVEN);
        public static readonly MathContext DECIMAL64 = new MathContext(16, RoundingMode.HALF_EVEN);
        public static readonly MathContext UNLIMITED = new MathContext(0, RoundingMode.HALF_UP);

        private int precision;
        private RoundingMode roundingMode;

        private readonly static char[] chPrecision = { 'p', 'r', 'e', 'c', 'i', 's', 'i', 'o', 'n', '=' };
        private readonly static char[] chRoundingMode = { 'r', 'o', 'u', 'n', 'd', 'i', 'n', 'g', 'M', 'o', 'd', 'e', '=' };

        public MathContext(int precision) : this(precision, RoundingMode.HALF_UP) {
        }

        public MathContext(int precision, RoundingMode roundingMode) {
            if(precision < 0) {
                throw new System.ArgumentException("Digits < 0");
            }
            this.precision = precision;
            this.roundingMode = roundingMode;
        }

        // public MathContext(String val) {
        //     char[] charVal = val.ToCharArray();
        //     int i; // Index of charVal
        //     int j; // Index of chRoundingMode
        //     int digit; // It will contain the digit parsed

        //     if ((charVal.Length < 27) || (charVal.Length > 45)) {
        //         throw new System.ArgumentException("bad string format");
        //     }
        //     // Parsing "precision=" String
        //     for (i = 0; (i < chPrecision.Length) && (charVal[i] == chPrecision[i]); i++) {
        //         ;
        //     }

        //     if (i < chPrecision.Length) {
        //         throw new System.ArgumentException("bad string format");
        //     }
        //     // Parsing the value for "precision="...
        //     if(!Char.IsDigit(charVal[i])) {
        //         throw new System.ArgumentException("bad string format");
        //     }
        //     digit = charVal[i] - '0';
        //     this.precision = this.precision * 10 + digit;
        //     i++;

        //     do {
        //         if(!Char.IsDigit(charVal[i])) {
        //             if (charVal[i] == ' ') {
        //                 // It parsed all the digits
        //                 i++;
        //                 break;
        //             }
        //             // It isn't  a valid digit, and isn't a white space
        //             throw new System.ArgumentException("bad string format");
        //         }
        //         digit = charVal[i] - '0';
        //         // Accumulating the value parsed
        //         this.precision = this.precision * 10 + digit;
        //         if (this.precision < 0) {
        //             throw new System.ArgumentException("bad string format");
        //         }
        //         i++;
        //     } while (true);
        //     // Parsing "roundingMode="
        //     for (j = 0; (j < chRoundingMode.Length)
        //              && (charVal[i] == chRoundingMode[j]); i++, j++) {
        //         ;
        //     }

        //     if (j < chRoundingMode.Length) {
        //         throw new System.ArgumentException("bad string format");
        //     }
        //     // Parsing the value for "roundingMode"...
        //     this.roundingMode = RoundingModeS.valueOf(new String(charVal, i,
        //                                                         charVal.Length - i));
        // }

        public int getPrecision() {
            return precision;
        }

        public RoundingMode getRoundingMode() {
            return roundingMode;
        }

        public override bool Equals(object x) {
            return ((x is MathContext)
                    && (((MathContext) x).getPrecision() == precision) && (((MathContext) x)
                                                                           .getRoundingMode() == roundingMode));
        }

        public override int GetHashCode() {
            // Make place for the necessary bits to represent 8 rounding modes
            return ((precision << 3) | RoundingModeS.ordinal(roundingMode));
        }

        public override string ToString() {
            StringBuilder sb = new StringBuilder(45);

            sb.Append(chPrecision);
            sb.Append(precision);
            sb.Append(' ');
            sb.Append(chRoundingMode);
            sb.Append(roundingMode);
            return sb.ToString();
        }
    }
}
