/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang.parser;

import org.antlr.runtime.*;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public abstract class Lexer extends org.antlr.runtime.Lexer {
    public Lexer() {
        super();
    }

    public Lexer(CharStream input, RecognizerSharedState state) {
        super(input,state);
    }

    @Override
    public void reportError(RecognitionException e) {
        //    displayRecognitionError(this.getTokenNames(), e);
        throw new RuntimeException(e);
    }

    private final static Object IPOL_STRING = new Object();
    private final static Object IPOL_ALT_STRING = new Object();
    private final static Object IPOL_REGEXP = new Object();
    private final static Object IPOL_ALT_REGEXP = new Object();
    private java.util.List<Object> interpolation = new java.util.LinkedList<Object>();

    public void startInterpolation() {
        interpolation.add(0, IPOL_STRING);
    }

    public void startAltInterpolation() {
        interpolation.add(0, IPOL_ALT_STRING);
    }

    public void startRegexpInterpolation() {
        interpolation.add(0, IPOL_REGEXP);
    }

    public void startAltRegexpInterpolation() {
        interpolation.add(0, IPOL_REGEXP);
    }

    public void endInterpolation() {
        interpolation.remove(0);
    }

    public void endAltInterpolation() {
        interpolation.remove(0);
    }

    public void endRegexpInterpolation() {
        interpolation.remove(0);
    }

    public void endAltRegexpInterpolation() {
        interpolation.remove(0);
    }

    public boolean isInterpolating() {
        return interpolation.size() > 0 && interpolation.get(0) == IPOL_STRING;
    }

    public boolean isAltInterpolating() {
        return interpolation.size() > 0 && interpolation.get(0) == IPOL_ALT_STRING;
    }

    public boolean isRegexpInterpolating() {
        return interpolation.size() > 0 && interpolation.get(0) == IPOL_REGEXP;
    }

    public boolean isAltRegexpInterpolating() {
        return interpolation.size() > 0 && interpolation.get(0) == IPOL_ALT_REGEXP;
    }

    public boolean isNum(int c) {
        return c>='0' && c<='9';
    }

    public int unitType(int type) {
        if(type == iokeLexer.DecimalLiteral) {
            return iokeLexer.UnitDecimalLiteral;
        } else {
            return iokeLexer.UnitLiteral;
        }
    }

    public boolean lookingAtInterpolation() {
        return input.LA(1) == '#' && input.LA(2) == '{';
    }
}// Lexer
