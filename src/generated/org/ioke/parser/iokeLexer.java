// $ANTLR 3.0.1 ioke.g 2008-03-22 20:08:20

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
    public static final int CloseCurly=9;
    public static final int Digit=13;
    public static final int IdentChars=14;
    public static final int Tokens=20;
    public static final int EOF=-1;
    public static final int OpenSimple=4;
    public static final int Identifier=15;
    public static final int Separator=17;
    public static final int NewLine=10;
    public static final int OpenSquare=6;
    public static final int CloseSimple=5;
    public static final int Digits=19;
    public static final int Whitespace=18;
    public static final int CloseSquare=7;
    public static final int OpenCurly=8;
    public static final int Comma=11;
    public static final int Letter=12;
    public static final int PossibleTerminator=16;

        public static iokeLexer getLexerFor(String input) throws Exception {
            return getLexerFor(new StringReader(input));
        }

        public static iokeLexer getLexerFor(Reader input) throws Exception {
            return new iokeLexer(new ANTLRReaderStream(input));
        }

        public static List<Token> getTokens(String input) throws Exception {
            return getTokens(getLexerFor(input));
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
            case Identifier: return "Identifier";
            case Whitespace: return "Whitespace";
            case PossibleTerminator: return "PossibleTerminator";
            case EOF: return "EOF";
            default: return "UNKNOWN TOKEN(" + token + ")";
            }
        }

    public iokeLexer() {;} 
    public iokeLexer(CharStream input) {
        super(input);
    }
    public String getGrammarFileName() { return "ioke.g"; }

    // $ANTLR start OpenSimple
    public final void mOpenSimple() throws RecognitionException {
        try {
            int _type = OpenSimple;
            // ioke.g:67:12: ( '(' )
            // ioke.g:67:14: '('
            {
            match('('); 

            }

            this.type = _type;
        }
        finally {
        }
    }
    // $ANTLR end OpenSimple

    // $ANTLR start CloseSimple
    public final void mCloseSimple() throws RecognitionException {
        try {
            int _type = CloseSimple;
            // ioke.g:68:13: ( ')' )
            // ioke.g:68:15: ')'
            {
            match(')'); 

            }

            this.type = _type;
        }
        finally {
        }
    }
    // $ANTLR end CloseSimple

    // $ANTLR start OpenSquare
    public final void mOpenSquare() throws RecognitionException {
        try {
            int _type = OpenSquare;
            // ioke.g:69:12: ( '[' )
            // ioke.g:69:14: '['
            {
            match('['); 

            }

            this.type = _type;
        }
        finally {
        }
    }
    // $ANTLR end OpenSquare

    // $ANTLR start CloseSquare
    public final void mCloseSquare() throws RecognitionException {
        try {
            int _type = CloseSquare;
            // ioke.g:70:13: ( ']' )
            // ioke.g:70:15: ']'
            {
            match(']'); 

            }

            this.type = _type;
        }
        finally {
        }
    }
    // $ANTLR end CloseSquare

    // $ANTLR start OpenCurly
    public final void mOpenCurly() throws RecognitionException {
        try {
            int _type = OpenCurly;
            // ioke.g:71:11: ( '{' )
            // ioke.g:71:13: '{'
            {
            match('{'); 

            }

            this.type = _type;
        }
        finally {
        }
    }
    // $ANTLR end OpenCurly

    // $ANTLR start CloseCurly
    public final void mCloseCurly() throws RecognitionException {
        try {
            int _type = CloseCurly;
            // ioke.g:72:12: ( '}' )
            // ioke.g:72:14: '}'
            {
            match('}'); 

            }

            this.type = _type;
        }
        finally {
        }
    }
    // $ANTLR end CloseCurly

    // $ANTLR start Comma
    public final void mComma() throws RecognitionException {
        try {
            int _type = Comma;
            // ioke.g:74:7: ( ( ',' ( NewLine )* ) )
            // ioke.g:74:9: ( ',' ( NewLine )* )
            {
            // ioke.g:74:9: ( ',' ( NewLine )* )
            // ioke.g:74:10: ',' ( NewLine )*
            {
            match(','); 
            // ioke.g:74:14: ( NewLine )*
            loop1:
            do {
                int alt1=2;
                int LA1_0 = input.LA(1);

                if ( (LA1_0=='\n'||LA1_0=='\r') ) {
                    alt1=1;
                }


                switch (alt1) {
            	case 1 :
            	    // ioke.g:74:14: NewLine
            	    {
            	    mNewLine(); 

            	    }
            	    break;

            	default :
            	    break loop1;
                }
            } while (true);


            }

            setText(",");

            }

            this.type = _type;
        }
        finally {
        }
    }
    // $ANTLR end Comma

    // $ANTLR start Identifier
    public final void mIdentifier() throws RecognitionException {
        try {
            int _type = Identifier;
            // ioke.g:76:12: ( ( ( Letter | Digit | IdentChars ) )* | '=' | '==' | '===' | '====' | ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<' | '>' | '<<' | '>>' | '&' | '&&' | '|' | '||' | '~' | '~~' | '!' | '!!' ) '=' )
            int alt4=6;
            switch ( input.LA(1) ) {
            case '+':
                {
                switch ( input.LA(2) ) {
                case '+':
                    {
                    int LA4_15 = input.LA(3);

                    if ( (LA4_15=='=') ) {
                        alt4=6;
                    }
                    else {
                        alt4=1;}
                    }
                    break;
                case '=':
                    {
                    alt4=6;
                    }
                    break;
                default:
                    alt4=1;}

                }
                break;
            case '=':
                {
                int LA4_3 = input.LA(2);

                if ( (LA4_3=='=') ) {
                    int LA4_17 = input.LA(3);

                    if ( (LA4_17=='=') ) {
                        int LA4_30 = input.LA(4);

                        if ( (LA4_30=='=') ) {
                            alt4=5;
                        }
                        else {
                            alt4=4;}
                    }
                    else {
                        alt4=3;}
                }
                else {
                    alt4=2;}
                }
                break;
            case '-':
                {
                switch ( input.LA(2) ) {
                case '-':
                    {
                    int LA4_19 = input.LA(3);

                    if ( (LA4_19=='=') ) {
                        alt4=6;
                    }
                    else {
                        alt4=1;}
                    }
                    break;
                case '=':
                    {
                    alt4=6;
                    }
                    break;
                default:
                    alt4=1;}

                }
                break;
            case '/':
                {
                switch ( input.LA(2) ) {
                case '/':
                    {
                    int LA4_20 = input.LA(3);

                    if ( (LA4_20=='=') ) {
                        alt4=6;
                    }
                    else {
                        alt4=1;}
                    }
                    break;
                case '=':
                    {
                    alt4=6;
                    }
                    break;
                default:
                    alt4=1;}

                }
                break;
            case '*':
                {
                switch ( input.LA(2) ) {
                case '*':
                    {
                    int LA4_21 = input.LA(3);

                    if ( (LA4_21=='=') ) {
                        alt4=6;
                    }
                    else {
                        alt4=1;}
                    }
                    break;
                case '=':
                    {
                    alt4=6;
                    }
                    break;
                default:
                    alt4=1;}

                }
                break;
            case '%':
                {
                switch ( input.LA(2) ) {
                case '%':
                    {
                    int LA4_22 = input.LA(3);

                    if ( (LA4_22=='=') ) {
                        alt4=6;
                    }
                    else {
                        alt4=1;}
                    }
                    break;
                case '=':
                    {
                    alt4=6;
                    }
                    break;
                default:
                    alt4=1;}

                }
                break;
            case '^':
                {
                switch ( input.LA(2) ) {
                case '^':
                    {
                    int LA4_23 = input.LA(3);

                    if ( (LA4_23=='=') ) {
                        alt4=6;
                    }
                    else {
                        alt4=1;}
                    }
                    break;
                case '=':
                    {
                    alt4=6;
                    }
                    break;
                default:
                    alt4=1;}

                }
                break;
            case '<':
                {
                switch ( input.LA(2) ) {
                case '<':
                    {
                    int LA4_24 = input.LA(3);

                    if ( (LA4_24=='=') ) {
                        alt4=6;
                    }
                    else {
                        alt4=1;}
                    }
                    break;
                case '=':
                    {
                    alt4=6;
                    }
                    break;
                default:
                    alt4=1;}

                }
                break;
            case '>':
                {
                switch ( input.LA(2) ) {
                case '>':
                    {
                    int LA4_25 = input.LA(3);

                    if ( (LA4_25=='=') ) {
                        alt4=6;
                    }
                    else {
                        alt4=1;}
                    }
                    break;
                case '=':
                    {
                    alt4=6;
                    }
                    break;
                default:
                    alt4=1;}

                }
                break;
            case '&':
                {
                switch ( input.LA(2) ) {
                case '&':
                    {
                    int LA4_26 = input.LA(3);

                    if ( (LA4_26=='=') ) {
                        alt4=6;
                    }
                    else {
                        alt4=1;}
                    }
                    break;
                case '=':
                    {
                    alt4=6;
                    }
                    break;
                default:
                    alt4=1;}

                }
                break;
            case '|':
                {
                switch ( input.LA(2) ) {
                case '|':
                    {
                    int LA4_27 = input.LA(3);

                    if ( (LA4_27=='=') ) {
                        alt4=6;
                    }
                    else {
                        alt4=1;}
                    }
                    break;
                case '=':
                    {
                    alt4=6;
                    }
                    break;
                default:
                    alt4=1;}

                }
                break;
            case '~':
                {
                switch ( input.LA(2) ) {
                case '~':
                    {
                    int LA4_28 = input.LA(3);

                    if ( (LA4_28=='=') ) {
                        alt4=6;
                    }
                    else {
                        alt4=1;}
                    }
                    break;
                case '=':
                    {
                    alt4=6;
                    }
                    break;
                default:
                    alt4=1;}

                }
                break;
            case '!':
                {
                switch ( input.LA(2) ) {
                case '!':
                    {
                    int LA4_29 = input.LA(3);

                    if ( (LA4_29=='=') ) {
                        alt4=6;
                    }
                    else {
                        alt4=1;}
                    }
                    break;
                case '=':
                    {
                    alt4=6;
                    }
                    break;
                default:
                    alt4=1;}

                }
                break;
            default:
                alt4=1;}

            switch (alt4) {
                case 1 :
                    // ioke.g:76:14: ( ( Letter | Digit | IdentChars ) )*
                    {
                    // ioke.g:76:14: ( ( Letter | Digit | IdentChars ) )*
                    loop2:
                    do {
                        int alt2=2;
                        int LA2_0 = input.LA(1);

                        if ( (LA2_0=='!'||(LA2_0>='%' && LA2_0<='\'')||(LA2_0>='*' && LA2_0<='+')||(LA2_0>='-' && LA2_0<=':')||LA2_0=='<'||(LA2_0>='>' && LA2_0<='Z')||LA2_0=='\\'||(LA2_0>='^' && LA2_0<='z')||LA2_0=='|'||LA2_0=='~') ) {
                            alt2=1;
                        }


                        switch (alt2) {
                    	case 1 :
                    	    // ioke.g:76:15: ( Letter | Digit | IdentChars )
                    	    {
                    	    if ( input.LA(1)=='!'||(input.LA(1)>='%' && input.LA(1)<='\'')||(input.LA(1)>='*' && input.LA(1)<='+')||(input.LA(1)>='-' && input.LA(1)<=':')||input.LA(1)=='<'||(input.LA(1)>='>' && input.LA(1)<='Z')||input.LA(1)=='\\'||(input.LA(1)>='^' && input.LA(1)<='z')||input.LA(1)=='|'||input.LA(1)=='~' ) {
                    	        input.consume();

                    	    }
                    	    else {
                    	        MismatchedSetException mse =
                    	            new MismatchedSetException(null,input);
                    	        recover(mse);    throw mse;
                    	    }


                    	    }
                    	    break;

                    	default :
                    	    break loop2;
                        }
                    } while (true);


                    }
                    break;
                case 2 :
                    // ioke.g:77:7: '='
                    {
                    match('='); 

                    }
                    break;
                case 3 :
                    // ioke.g:78:7: '=='
                    {
                    match("=="); 


                    }
                    break;
                case 4 :
                    // ioke.g:79:7: '==='
                    {
                    match("==="); 


                    }
                    break;
                case 5 :
                    // ioke.g:80:7: '===='
                    {
                    match("===="); 


                    }
                    break;
                case 6 :
                    // ioke.g:81:7: ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<' | '>' | '<<' | '>>' | '&' | '&&' | '|' | '||' | '~' | '~~' | '!' | '!!' ) '='
                    {
                    // ioke.g:81:7: ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<' | '>' | '<<' | '>>' | '&' | '&&' | '|' | '||' | '~' | '~~' | '!' | '!!' )
                    int alt3=24;
                    switch ( input.LA(1) ) {
                    case '+':
                        {
                        int LA3_1 = input.LA(2);

                        if ( (LA3_1=='+') ) {
                            alt3=2;
                        }
                        else if ( (LA3_1=='=') ) {
                            alt3=1;
                        }
                        else {
                            NoViableAltException nvae =
                                new NoViableAltException("81:7: ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<' | '>' | '<<' | '>>' | '&' | '&&' | '|' | '||' | '~' | '~~' | '!' | '!!' )", 3, 1, input);

                            throw nvae;
                        }
                        }
                        break;
                    case '-':
                        {
                        int LA3_2 = input.LA(2);

                        if ( (LA3_2=='-') ) {
                            alt3=4;
                        }
                        else if ( (LA3_2=='=') ) {
                            alt3=3;
                        }
                        else {
                            NoViableAltException nvae =
                                new NoViableAltException("81:7: ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<' | '>' | '<<' | '>>' | '&' | '&&' | '|' | '||' | '~' | '~~' | '!' | '!!' )", 3, 2, input);

                            throw nvae;
                        }
                        }
                        break;
                    case '/':
                        {
                        int LA3_3 = input.LA(2);

                        if ( (LA3_3=='/') ) {
                            alt3=6;
                        }
                        else if ( (LA3_3=='=') ) {
                            alt3=5;
                        }
                        else {
                            NoViableAltException nvae =
                                new NoViableAltException("81:7: ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<' | '>' | '<<' | '>>' | '&' | '&&' | '|' | '||' | '~' | '~~' | '!' | '!!' )", 3, 3, input);

                            throw nvae;
                        }
                        }
                        break;
                    case '*':
                        {
                        int LA3_4 = input.LA(2);

                        if ( (LA3_4=='*') ) {
                            alt3=8;
                        }
                        else if ( (LA3_4=='=') ) {
                            alt3=7;
                        }
                        else {
                            NoViableAltException nvae =
                                new NoViableAltException("81:7: ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<' | '>' | '<<' | '>>' | '&' | '&&' | '|' | '||' | '~' | '~~' | '!' | '!!' )", 3, 4, input);

                            throw nvae;
                        }
                        }
                        break;
                    case '%':
                        {
                        int LA3_5 = input.LA(2);

                        if ( (LA3_5=='%') ) {
                            alt3=10;
                        }
                        else if ( (LA3_5=='=') ) {
                            alt3=9;
                        }
                        else {
                            NoViableAltException nvae =
                                new NoViableAltException("81:7: ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<' | '>' | '<<' | '>>' | '&' | '&&' | '|' | '||' | '~' | '~~' | '!' | '!!' )", 3, 5, input);

                            throw nvae;
                        }
                        }
                        break;
                    case '^':
                        {
                        int LA3_6 = input.LA(2);

                        if ( (LA3_6=='^') ) {
                            alt3=12;
                        }
                        else if ( (LA3_6=='=') ) {
                            alt3=11;
                        }
                        else {
                            NoViableAltException nvae =
                                new NoViableAltException("81:7: ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<' | '>' | '<<' | '>>' | '&' | '&&' | '|' | '||' | '~' | '~~' | '!' | '!!' )", 3, 6, input);

                            throw nvae;
                        }
                        }
                        break;
                    case '<':
                        {
                        int LA3_7 = input.LA(2);

                        if ( (LA3_7=='<') ) {
                            alt3=15;
                        }
                        else if ( (LA3_7=='=') ) {
                            alt3=13;
                        }
                        else {
                            NoViableAltException nvae =
                                new NoViableAltException("81:7: ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<' | '>' | '<<' | '>>' | '&' | '&&' | '|' | '||' | '~' | '~~' | '!' | '!!' )", 3, 7, input);

                            throw nvae;
                        }
                        }
                        break;
                    case '>':
                        {
                        int LA3_8 = input.LA(2);

                        if ( (LA3_8=='>') ) {
                            alt3=16;
                        }
                        else if ( (LA3_8=='=') ) {
                            alt3=14;
                        }
                        else {
                            NoViableAltException nvae =
                                new NoViableAltException("81:7: ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<' | '>' | '<<' | '>>' | '&' | '&&' | '|' | '||' | '~' | '~~' | '!' | '!!' )", 3, 8, input);

                            throw nvae;
                        }
                        }
                        break;
                    case '&':
                        {
                        int LA3_9 = input.LA(2);

                        if ( (LA3_9=='&') ) {
                            alt3=18;
                        }
                        else if ( (LA3_9=='=') ) {
                            alt3=17;
                        }
                        else {
                            NoViableAltException nvae =
                                new NoViableAltException("81:7: ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<' | '>' | '<<' | '>>' | '&' | '&&' | '|' | '||' | '~' | '~~' | '!' | '!!' )", 3, 9, input);

                            throw nvae;
                        }
                        }
                        break;
                    case '|':
                        {
                        int LA3_10 = input.LA(2);

                        if ( (LA3_10=='|') ) {
                            alt3=20;
                        }
                        else if ( (LA3_10=='=') ) {
                            alt3=19;
                        }
                        else {
                            NoViableAltException nvae =
                                new NoViableAltException("81:7: ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<' | '>' | '<<' | '>>' | '&' | '&&' | '|' | '||' | '~' | '~~' | '!' | '!!' )", 3, 10, input);

                            throw nvae;
                        }
                        }
                        break;
                    case '~':
                        {
                        int LA3_11 = input.LA(2);

                        if ( (LA3_11=='~') ) {
                            alt3=22;
                        }
                        else if ( (LA3_11=='=') ) {
                            alt3=21;
                        }
                        else {
                            NoViableAltException nvae =
                                new NoViableAltException("81:7: ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<' | '>' | '<<' | '>>' | '&' | '&&' | '|' | '||' | '~' | '~~' | '!' | '!!' )", 3, 11, input);

                            throw nvae;
                        }
                        }
                        break;
                    case '!':
                        {
                        int LA3_12 = input.LA(2);

                        if ( (LA3_12=='!') ) {
                            alt3=24;
                        }
                        else if ( (LA3_12=='=') ) {
                            alt3=23;
                        }
                        else {
                            NoViableAltException nvae =
                                new NoViableAltException("81:7: ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<' | '>' | '<<' | '>>' | '&' | '&&' | '|' | '||' | '~' | '~~' | '!' | '!!' )", 3, 12, input);

                            throw nvae;
                        }
                        }
                        break;
                    default:
                        NoViableAltException nvae =
                            new NoViableAltException("81:7: ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<' | '>' | '<<' | '>>' | '&' | '&&' | '|' | '||' | '~' | '~~' | '!' | '!!' )", 3, 0, input);

                        throw nvae;
                    }

                    switch (alt3) {
                        case 1 :
                            // ioke.g:81:8: '+'
                            {
                            match('+'); 

                            }
                            break;
                        case 2 :
                            // ioke.g:81:14: '++'
                            {
                            match("++"); 


                            }
                            break;
                        case 3 :
                            // ioke.g:81:21: '-'
                            {
                            match('-'); 

                            }
                            break;
                        case 4 :
                            // ioke.g:81:27: '--'
                            {
                            match("--"); 


                            }
                            break;
                        case 5 :
                            // ioke.g:81:34: '/'
                            {
                            match('/'); 

                            }
                            break;
                        case 6 :
                            // ioke.g:81:40: '//'
                            {
                            match("//"); 


                            }
                            break;
                        case 7 :
                            // ioke.g:81:47: '*'
                            {
                            match('*'); 

                            }
                            break;
                        case 8 :
                            // ioke.g:81:53: '**'
                            {
                            match("**"); 


                            }
                            break;
                        case 9 :
                            // ioke.g:81:60: '%'
                            {
                            match('%'); 

                            }
                            break;
                        case 10 :
                            // ioke.g:81:66: '%%'
                            {
                            match("%%"); 


                            }
                            break;
                        case 11 :
                            // ioke.g:81:73: '^'
                            {
                            match('^'); 

                            }
                            break;
                        case 12 :
                            // ioke.g:81:79: '^^'
                            {
                            match("^^"); 


                            }
                            break;
                        case 13 :
                            // ioke.g:81:86: '<'
                            {
                            match('<'); 

                            }
                            break;
                        case 14 :
                            // ioke.g:81:92: '>'
                            {
                            match('>'); 

                            }
                            break;
                        case 15 :
                            // ioke.g:81:98: '<<'
                            {
                            match("<<"); 


                            }
                            break;
                        case 16 :
                            // ioke.g:81:105: '>>'
                            {
                            match(">>"); 


                            }
                            break;
                        case 17 :
                            // ioke.g:81:112: '&'
                            {
                            match('&'); 

                            }
                            break;
                        case 18 :
                            // ioke.g:81:118: '&&'
                            {
                            match("&&"); 


                            }
                            break;
                        case 19 :
                            // ioke.g:81:125: '|'
                            {
                            match('|'); 

                            }
                            break;
                        case 20 :
                            // ioke.g:81:131: '||'
                            {
                            match("||"); 


                            }
                            break;
                        case 21 :
                            // ioke.g:81:138: '~'
                            {
                            match('~'); 

                            }
                            break;
                        case 22 :
                            // ioke.g:81:144: '~~'
                            {
                            match("~~"); 


                            }
                            break;
                        case 23 :
                            // ioke.g:81:151: '!'
                            {
                            match('!'); 

                            }
                            break;
                        case 24 :
                            // ioke.g:81:157: '!!'
                            {
                            match("!!"); 


                            }
                            break;

                    }

                    match('='); 

                    }
                    break;

            }
            this.type = _type;
        }
        finally {
        }
    }
    // $ANTLR end Identifier

    // $ANTLR start PossibleTerminator
    public final void mPossibleTerminator() throws RecognitionException {
        try {
            int _type = PossibleTerminator;
            // ioke.g:82:20: ( ( ( ';' | NewLine )+ ) )
            // ioke.g:82:22: ( ( ';' | NewLine )+ )
            {
            // ioke.g:82:22: ( ( ';' | NewLine )+ )
            // ioke.g:82:23: ( ';' | NewLine )+
            {
            // ioke.g:82:23: ( ';' | NewLine )+
            int cnt5=0;
            loop5:
            do {
                int alt5=2;
                int LA5_0 = input.LA(1);

                if ( (LA5_0=='\n'||LA5_0=='\r'||LA5_0==';') ) {
                    alt5=1;
                }


                switch (alt5) {
            	case 1 :
            	    // ioke.g:
            	    {
            	    if ( input.LA(1)=='\n'||input.LA(1)=='\r'||input.LA(1)==';' ) {
            	        input.consume();

            	    }
            	    else {
            	        MismatchedSetException mse =
            	            new MismatchedSetException(null,input);
            	        recover(mse);    throw mse;
            	    }


            	    }
            	    break;

            	default :
            	    if ( cnt5 >= 1 ) break loop5;
                        EarlyExitException eee =
                            new EarlyExitException(5, input);
                        throw eee;
                }
                cnt5++;
            } while (true);


            }

            setText(";");

            }

            this.type = _type;
        }
        finally {
        }
    }
    // $ANTLR end PossibleTerminator

    // $ANTLR start Whitespace
    public final void mWhitespace() throws RecognitionException {
        try {
            int _type = Whitespace;
            // ioke.g:83:12: ( Separator )
            // ioke.g:83:14: Separator
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

    // $ANTLR start Letter
    public final void mLetter() throws RecognitionException {
        try {
            // ioke.g:86:8: ( 'a' .. 'z' | 'A' .. 'Z' )
            // ioke.g:
            {
            if ( (input.LA(1)>='A' && input.LA(1)<='Z')||(input.LA(1)>='a' && input.LA(1)<='z') ) {
                input.consume();

            }
            else {
                MismatchedSetException mse =
                    new MismatchedSetException(null,input);
                recover(mse);    throw mse;
            }


            }

        }
        finally {
        }
    }
    // $ANTLR end Letter

    // $ANTLR start Digit
    public final void mDigit() throws RecognitionException {
        try {
            // ioke.g:89:7: ( '0' .. '9' )
            // ioke.g:89:9: '0' .. '9'
            {
            matchRange('0','9'); 

            }

        }
        finally {
        }
    }
    // $ANTLR end Digit

    // $ANTLR start Digits
    public final void mDigits() throws RecognitionException {
        try {
            // ioke.g:92:8: ( ( Digit )+ )
            // ioke.g:92:10: ( Digit )+
            {
            // ioke.g:92:10: ( Digit )+
            int cnt6=0;
            loop6:
            do {
                int alt6=2;
                int LA6_0 = input.LA(1);

                if ( ((LA6_0>='0' && LA6_0<='9')) ) {
                    alt6=1;
                }


                switch (alt6) {
            	case 1 :
            	    // ioke.g:92:10: Digit
            	    {
            	    mDigit(); 

            	    }
            	    break;

            	default :
            	    if ( cnt6 >= 1 ) break loop6;
                        EarlyExitException eee =
                            new EarlyExitException(6, input);
                        throw eee;
                }
                cnt6++;
            } while (true);


            }

        }
        finally {
        }
    }
    // $ANTLR end Digits

    // $ANTLR start Separator
    public final void mSeparator() throws RecognitionException {
        try {
            // ioke.g:95:11: ( ( ' ' | '\\u000c' | '\\u0009' | '\\u000b' | '\\\\' '\\u000a' )* )
            // ioke.g:95:13: ( ' ' | '\\u000c' | '\\u0009' | '\\u000b' | '\\\\' '\\u000a' )*
            {
            // ioke.g:95:13: ( ' ' | '\\u000c' | '\\u0009' | '\\u000b' | '\\\\' '\\u000a' )*
            loop7:
            do {
                int alt7=6;
                switch ( input.LA(1) ) {
                case ' ':
                    {
                    alt7=1;
                    }
                    break;
                case '\f':
                    {
                    alt7=2;
                    }
                    break;
                case '\t':
                    {
                    alt7=3;
                    }
                    break;
                case '\u000B':
                    {
                    alt7=4;
                    }
                    break;
                case '\\':
                    {
                    alt7=5;
                    }
                    break;

                }

                switch (alt7) {
            	case 1 :
            	    // ioke.g:95:14: ' '
            	    {
            	    match(' '); 

            	    }
            	    break;
            	case 2 :
            	    // ioke.g:95:20: '\\u000c'
            	    {
            	    match('\f'); 

            	    }
            	    break;
            	case 3 :
            	    // ioke.g:95:31: '\\u0009'
            	    {
            	    match('\t'); 

            	    }
            	    break;
            	case 4 :
            	    // ioke.g:95:42: '\\u000b'
            	    {
            	    match('\u000B'); 

            	    }
            	    break;
            	case 5 :
            	    // ioke.g:95:53: '\\\\' '\\u000a'
            	    {
            	    match('\\'); 
            	    match('\n'); 

            	    }
            	    break;

            	default :
            	    break loop7;
                }
            } while (true);


            }

        }
        finally {
        }
    }
    // $ANTLR end Separator

    // $ANTLR start IdentChars
    public final void mIdentChars() throws RecognitionException {
        try {
            // ioke.g:98:12: ( ( '!' | '?' | '@' | '&' | '%' | '.' | '|' | '<' | '>' | '/' | '+' | '-' | '_' | ':' | '\\\\' | '*' | '^' | '~' | '`' | '\\'' ) )
            // ioke.g:98:14: ( '!' | '?' | '@' | '&' | '%' | '.' | '|' | '<' | '>' | '/' | '+' | '-' | '_' | ':' | '\\\\' | '*' | '^' | '~' | '`' | '\\'' )
            {
            if ( input.LA(1)=='!'||(input.LA(1)>='%' && input.LA(1)<='\'')||(input.LA(1)>='*' && input.LA(1)<='+')||(input.LA(1)>='-' && input.LA(1)<='/')||input.LA(1)==':'||input.LA(1)=='<'||(input.LA(1)>='>' && input.LA(1)<='@')||input.LA(1)=='\\'||(input.LA(1)>='^' && input.LA(1)<='`')||input.LA(1)=='|'||input.LA(1)=='~' ) {
                input.consume();

            }
            else {
                MismatchedSetException mse =
                    new MismatchedSetException(null,input);
                recover(mse);    throw mse;
            }


            }

        }
        finally {
        }
    }
    // $ANTLR end IdentChars

    // $ANTLR start NewLine
    public final void mNewLine() throws RecognitionException {
        try {
            // ioke.g:101:9: ( ( '\\u000a' | '\\u000d' ) )
            // ioke.g:101:11: ( '\\u000a' | '\\u000d' )
            {
            if ( input.LA(1)=='\n'||input.LA(1)=='\r' ) {
                input.consume();

            }
            else {
                MismatchedSetException mse =
                    new MismatchedSetException(null,input);
                recover(mse);    throw mse;
            }


            }

        }
        finally {
        }
    }
    // $ANTLR end NewLine

    public void mTokens() throws RecognitionException {
        // ioke.g:1:8: ( OpenSimple | CloseSimple | OpenSquare | CloseSquare | OpenCurly | CloseCurly | Comma | Identifier | PossibleTerminator | Whitespace )
        int alt8=10;
        switch ( input.LA(1) ) {
        case '(':
            {
            alt8=1;
            }
            break;
        case ')':
            {
            alt8=2;
            }
            break;
        case '[':
            {
            alt8=3;
            }
            break;
        case ']':
            {
            alt8=4;
            }
            break;
        case '{':
            {
            alt8=5;
            }
            break;
        case '}':
            {
            alt8=6;
            }
            break;
        case ',':
            {
            alt8=7;
            }
            break;
        case '\\':
            {
            int LA8_9 = input.LA(2);

            if ( (LA8_9=='\n') ) {
                alt8=10;
            }
            else {
                alt8=8;}
            }
            break;
        case '\n':
        case '\r':
        case ';':
            {
            alt8=9;
            }
            break;
        case '\t':
        case '\u000B':
        case '\f':
        case ' ':
            {
            alt8=10;
            }
            break;
        default:
            alt8=8;}

        switch (alt8) {
            case 1 :
                // ioke.g:1:10: OpenSimple
                {
                mOpenSimple(); 

                }
                break;
            case 2 :
                // ioke.g:1:21: CloseSimple
                {
                mCloseSimple(); 

                }
                break;
            case 3 :
                // ioke.g:1:33: OpenSquare
                {
                mOpenSquare(); 

                }
                break;
            case 4 :
                // ioke.g:1:44: CloseSquare
                {
                mCloseSquare(); 

                }
                break;
            case 5 :
                // ioke.g:1:56: OpenCurly
                {
                mOpenCurly(); 

                }
                break;
            case 6 :
                // ioke.g:1:66: CloseCurly
                {
                mCloseCurly(); 

                }
                break;
            case 7 :
                // ioke.g:1:77: Comma
                {
                mComma(); 

                }
                break;
            case 8 :
                // ioke.g:1:83: Identifier
                {
                mIdentifier(); 

                }
                break;
            case 9 :
                // ioke.g:1:94: PossibleTerminator
                {
                mPossibleTerminator(); 

                }
                break;
            case 10 :
                // ioke.g:1:113: Whitespace
                {
                mWhitespace(); 

                }
                break;

        }

    }


 

}