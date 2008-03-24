// $ANTLR 3.0.1 ioke.g 2008-03-24 14:51:45

package org.ioke.parser;


import org.antlr.runtime.*;
import java.util.Stack;
import java.util.List;
import java.util.ArrayList;


import org.antlr.runtime.tree.*;

public class iokeParser extends Parser {
    public static final String[] tokenNames = new String[] {
        "<invalid>", "<EOR>", "<DOWN>", "<UP>", "MultiComment", "NewLine", "NewlineComment", "OpenSimple", "CloseSimple", "OpenSquare", "CloseSquare", "OpenCurly", "CloseCurly", "Comma", "Digit", "HexLetter", "HexInteger", "Digits", "Integer", "Exponent", "Real", "AssignmentOperator", "UnaryOperator", "OpChars", "BinaryOperator", "Assignment", "IdentStart", "IdentChars", "Identifier", "PossibleTerminator", "Separator", "Whitespace", "Letter", "Tokens"
    };
    public static final int Assignment=25;
    public static final int CloseCurly=12;
    public static final int Exponent=19;
    public static final int OpChars=23;
    public static final int HexLetter=15;
    public static final int IdentChars=27;
    public static final int Digit=14;
    public static final int EOF=-1;
    public static final int Tokens=33;
    public static final int OpenSimple=7;
    public static final int IdentStart=26;
    public static final int Identifier=28;
    public static final int Separator=30;
    public static final int NewLine=5;
    public static final int AssignmentOperator=21;
    public static final int OpenSquare=9;
    public static final int Digits=17;
    public static final int CloseSimple=8;
    public static final int NewlineComment=6;
    public static final int HexInteger=16;
    public static final int Real=20;
    public static final int BinaryOperator=24;
    public static final int MultiComment=4;
    public static final int UnaryOperator=22;
    public static final int Whitespace=31;
    public static final int Comma=13;
    public static final int OpenCurly=11;
    public static final int CloseSquare=10;
    public static final int Letter=32;
    public static final int Integer=18;
    public static final int PossibleTerminator=29;

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