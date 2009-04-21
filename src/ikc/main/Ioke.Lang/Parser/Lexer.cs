
namespace Ioke.Lang.Parser {
    using System;
    using System.Collections;
    using Antlr.Runtime;

    public abstract class Lexer : Antlr.Runtime.Lexer {
        public Lexer() : base() {}

        public Lexer(ICharStream input, RecognizerSharedState state)
            : base(input, state) {}

        public override void ReportError(RecognitionException e) {
            throw e;
        }

        private static readonly Object IPOL_STRING = new Object();
        private static readonly Object IPOL_ALT_STRING = new Object();
        private static readonly Object IPOL_REGEXP = new Object();
        private static readonly Object IPOL_ALT_REGEXP = new Object();
        private IList interpolation = new ArrayList();

        public void startInterpolation() {
            interpolation.Insert(0, IPOL_STRING);
        }

        public void startAltInterpolation() {
            interpolation.Insert(0, IPOL_ALT_STRING);
        }

        public void startRegexpInterpolation() {
            interpolation.Insert(0, IPOL_REGEXP);
        }

        public void startAltRegexpInterpolation() {
            interpolation.Insert(0, IPOL_REGEXP);
        }

        public void endInterpolation() {
            interpolation.RemoveAt(0);
        }

        public void endAltInterpolation() {
            interpolation.RemoveAt(0);
        }

        public void endRegexpInterpolation() {
            interpolation.RemoveAt(0);
        }

        public void endAltRegexpInterpolation() {
            interpolation.RemoveAt(0);
        }

        public bool isInterpolating() {
            return interpolation.Count > 0 && interpolation[0] == IPOL_STRING;
        }

        public bool isAltInterpolating() {
            return interpolation.Count > 0 && interpolation[0] == IPOL_ALT_STRING;
        }

        public bool isRegexpInterpolating() {
            return interpolation.Count > 0 && interpolation[0] == IPOL_REGEXP;
        }

        public bool isAltRegexpInterpolating() {
            return interpolation.Count > 0 && interpolation[0] == IPOL_ALT_REGEXP;
        }

        public bool isNum(int c) {
            return c>='0' && c<='9';
        }

        public int unitType(int type) {
            if(type == iokeLexer.DecimalLiteral) {
                return iokeLexer.UnitDecimalLiteral;
            } else {
                return iokeLexer.UnitLiteral;
            }
        }

        public bool lookingAtInterpolation() {
            return input.LA(1) == '#' && input.LA(2) == '{';
        }
    }
}
