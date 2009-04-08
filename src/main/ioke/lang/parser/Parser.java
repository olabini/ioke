/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang.parser;

import org.antlr.runtime.*;
import org.antlr.runtime.tree.*;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public abstract class Parser extends org.antlr.runtime.Parser {
    public Parser(TokenStream input, RecognizerSharedState state) {
        super(input, state);
    }             

    protected void mismatch(IntStream input, int ttype, BitSet follow) throws RecognitionException {
        throw new MismatchedTokenException(ttype, input);
    }

    public Object recoverFromMismatchedSet(IntStream input, RecognitionException e, BitSet follow) throws RecognitionException {
        //			reportError(e);
        throw e;
    }

    public Tree parseFully() throws RecognitionException {
        iokeParser.fullProgram_return result = fullProgram();
        return result == null ? (Tree)null : (Tree)(result.getTree());
    }

    public abstract iokeParser.fullProgram_return fullProgram() throws RecognitionException;

    public boolean print(String s) {
        System.err.println(s);
        return true;
    }

    @Override
    public void reportError(RecognitionException e) {
        //    displayRecognitionError(this.getTokenNames(), e);
        if ( state.errorRecovery ) {
            return;
        }
        state.syntaxErrors++; // don't count spurious
        state.errorRecovery = true;
        throw new RuntimeException(e);
    }
}// Parser
