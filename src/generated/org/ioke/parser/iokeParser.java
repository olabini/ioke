// $ANTLR 3.0.1 ioke.g 2008-03-23 23:48:29

package org.ioke.parser;


import org.antlr.runtime.*;
import java.util.Stack;
import java.util.List;
import java.util.ArrayList;


import org.antlr.runtime.tree.*;

public class iokeParser extends Parser {
    public static final String[] tokenNames = new String[] {
        "<invalid>", "<EOR>", "<DOWN>", "<UP>", "OpenSimple", "CloseSimple", "OpenSquare", "CloseSquare", "OpenCurly", "CloseCurly", "NewLine", "Comma", "HexInteger", "Integer", "Letter", "Digit", "IdentChars", "Identifier", "PossibleTerminator", "Separator", "Whitespace", "Digits", "Tokens"
    };
    public static final int CloseCurly=9;
    public static final int IdentChars=16;
    public static final int Digit=15;
    public static final int Tokens=22;
    public static final int EOF=-1;
    public static final int OpenSimple=4;
    public static final int Identifier=17;
    public static final int Separator=19;
    public static final int NewLine=10;
    public static final int OpenSquare=6;
    public static final int Digits=21;
    public static final int CloseSimple=5;
    public static final int HexInteger=12;
    public static final int Whitespace=20;
    public static final int CloseSquare=7;
    public static final int OpenCurly=8;
    public static final int Comma=11;
    public static final int Letter=14;
    public static final int Integer=13;
    public static final int PossibleTerminator=18;

        public iokeParser(TokenStream input) {
            super(input);
        }
        
    protected TreeAdaptor adaptor = new CommonTreeAdaptor();

    public void setTreeAdaptor(TreeAdaptor adaptor) {
        this.adaptor = adaptor;
    }
    public TreeAdaptor getTreeAdaptor() {
        return adaptor;
    }

    public String[] getTokenNames() { return tokenNames; }
    public String getGrammarFileName() { return "ioke.g"; }


    public static class ioke_program_return extends ParserRuleReturnScope {
        CommonTree tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start ioke_program
    // ioke.g:13:1: ioke_program : ;
    public final ioke_program_return ioke_program() throws RecognitionException {
        ioke_program_return retval = new ioke_program_return();
        retval.start = input.LT(1);

        CommonTree root_0 = null;

        try {
            // ioke.g:13:14: ()
            // ioke.g:13:16: 
            {
            root_0 = (CommonTree)adaptor.nil();

            }

            retval.stop = input.LT(-1);

                retval.tree = (CommonTree)adaptor.rulePostProcessing(root_0);
                adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end ioke_program


 

}