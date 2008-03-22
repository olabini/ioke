// $ANTLR 3.0.1 ioke.g 2008-03-22 18:30:36

package org.ioke.parser;

import java.io.FileReader;
import java.io.BufferedReader;
import java.io.Reader;
import java.io.InputStreamReader;
import java.io.StringReader;

import java.util.List;
import java.util.ArrayList;


import org.antlr.runtime.*;
import java.util.Stack;
import java.util.List;
import java.util.ArrayList;

public class iokeLexer extends Lexer {
    public static final int Tokens=6;
    public static final int Whitespace=5;
    public static final int EOF=-1;
    public static final int Separator=4;

        public static iokeLexer getLexerFor(String input) throws Exception {
            return getLexerFor(new StringReader(input));
        }

        public static iokeLexer getLexerFor(Reader input) throws Exception {
            return new iokeLexer(new ANTLRReaderStream(input));
        }

        public static List<Token> getTokens(Reader reader) throws Exception {
            return getTokens(getLexerFor(reader));
        }

        private static List<Token> getTokens(iokeLexer lexer) throws Exception {
            List<Token> tokens = new ArrayList<Token>();
            Token t;
            while((t = lexer.nextToken()).getType() != EOF) {
                tokens.add(t);
            } 
            return tokens;
        }

        public static void main(final String[] args) throws Exception {
            Reader reader;
            if(args.length > 0) {
                reader = new BufferedReader(new FileReader(args[0]));
            } else {
                reader = new InputStreamReader(System.in);
            }
            List<Token> tokens = getTokens(reader);
            for(Token t : tokens) {
                System.out.println("{" + tokenToName(t.getType()) + "} " + t.getText());
            }
        }
        
        public final static String tokenToName(int token) {
            switch(token) {
            case EOF: return "EOF";
            default: return "UNKNOWN TOKEN(" + token + ")";
            }
        }

    public iokeLexer() {;} 
    public iokeLexer(CharStream input) {
        super(input);
    }
    public String getGrammarFileName() { return "ioke.g"; }

    // $ANTLR start Whitespace
    public final void mWhitespace() throws RecognitionException {
        try {
            int _type = Whitespace;
            // ioke.g:60:12: ( Separator )
            // ioke.g:60:14: Separator
            {
            mSeparator(); 
            skip();

            }

            this.type = _type;
        }
        finally {
        }
    }
    // $ANTLR end Whitespace

    // $ANTLR start Separator
    public final void mSeparator() throws RecognitionException {
        try {
            // ioke.g:63:11: ( ( ' ' | '\\u000c' | '\\u0009' | '\\u000b' | '\\\\' '\\u000a' )* )
            // ioke.g:63:13: ( ' ' | '\\u000c' | '\\u0009' | '\\u000b' | '\\\\' '\\u000a' )*
            {
            // ioke.g:63:13: ( ' ' | '\\u000c' | '\\u0009' | '\\u000b' | '\\\\' '\\u000a' )*
            loop1:
            do {
                int alt1=6;
                switch ( input.LA(1) ) {
                case ' ':
                    {
                    alt1=1;
                    }
                    break;
                case '\f':
                    {
                    alt1=2;
                    }
                    break;
                case '\t':
                    {
                    alt1=3;
                    }
                    break;
                case '\u000B':
                    {
                    alt1=4;
                    }
                    break;
                case '\\':
                    {
                    alt1=5;
                    }
                    break;

                }

                switch (alt1) {
            	case 1 :
            	    // ioke.g:63:14: ' '
            	    {
            	    match(' '); 

            	    }
            	    break;
            	case 2 :
            	    // ioke.g:63:20: '\\u000c'
            	    {
            	    match('\f'); 

            	    }
            	    break;
            	case 3 :
            	    // ioke.g:63:31: '\\u0009'
            	    {
            	    match('\t'); 

            	    }
            	    break;
            	case 4 :
            	    // ioke.g:63:42: '\\u000b'
            	    {
            	    match('\u000B'); 

            	    }
            	    break;
            	case 5 :
            	    // ioke.g:63:53: '\\\\' '\\u000a'
            	    {
            	    match('\\'); 
            	    match('\n'); 

            	    }
            	    break;

            	default :
            	    break loop1;
                }
            } while (true);


            }

        }
        finally {
        }
    }
    // $ANTLR end Separator

    public void mTokens() throws RecognitionException {
        // ioke.g:1:8: ( Whitespace )
        // ioke.g:1:10: Whitespace
        {
        mWhitespace(); 

        }


    }


 

}