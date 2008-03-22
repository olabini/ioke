// $ANTLR 3.0.1 ioke.g 2008-03-22 18:46:31

package org.ioke.parser;


import org.antlr.runtime.*;
import java.util.Stack;
import java.util.List;
import java.util.ArrayList;


import org.antlr.runtime.tree.*;

public class iokeParser extends Parser {
    public static final String[] tokenNames = new String[] {
        "<invalid>", "<EOR>", "<DOWN>", "<UP>", "Separator", "Whitespace", "Tokens"
    };
    public static final int Whitespace=5;
    public static final int Tokens=6;
    public static final int EOF=-1;
    public static final int Separator=4;

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