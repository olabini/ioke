
namespace Ioke.Lang.Parser
{
    using Antlr.Runtime;
    using Antlr.Runtime.Tree;

    public abstract class Parser : Antlr.Runtime.Parser
    {
        public Parser(ITokenStream input, RecognizerSharedState state)
            : base(input, state) {}

        public override object RecoverFromMismatchedSet(IIntStream input, RecognitionException e, BitSet follow) {
            throw e;
        }

        public override void ReportError(RecognitionException e) {
            if ( state.errorRecovery ) {
                return;
            }
            state.syntaxErrors++; // don't count spurious
            state.errorRecovery = true;
            throw e;
        }
    }
}
