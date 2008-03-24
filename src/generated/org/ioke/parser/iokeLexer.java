// $ANTLR 3.0.1 ioke.g 2008-03-24 14:43:15

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
    public static final int Assignment=23;
    public static final int CloseCurly=9;
    public static final int Exponent=17;
    public static final int OpChars=21;
    public static final int HexLetter=13;
    public static final int IdentChars=25;
    public static final int Digit=12;
    public static final int Tokens=31;
    public static final int EOF=-1;
    public static final int OpenSimple=4;
    public static final int IdentStart=24;
    public static final int Identifier=26;
    public static final int Separator=28;
    public static final int NewLine=10;
    public static final int AssignmentOperator=19;
    public static final int OpenSquare=6;
    public static final int CloseSimple=5;
    public static final int Digits=15;
    public static final int HexInteger=14;
    public static final int Real=18;
    public static final int BinaryOperator=22;
    public static final int UnaryOperator=20;
    public static final int Whitespace=29;
    public static final int CloseSquare=7;
    public static final int OpenCurly=8;
    public static final int Comma=11;
    public static final int Letter=30;
    public static final int Integer=16;
    public static final int PossibleTerminator=27;

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

    // $ANTLR start HexInteger
    public final void mHexInteger() throws RecognitionException {
        try {
            int _type = HexInteger;
            // ioke.g:76:12: ( ( '+' | '-' )? '0' ( 'x' | 'X' ) ( Digit | HexLetter )+ )
            // ioke.g:76:14: ( '+' | '-' )? '0' ( 'x' | 'X' ) ( Digit | HexLetter )+
            {
            // ioke.g:76:14: ( '+' | '-' )?
            int alt2=2;
            int LA2_0 = input.LA(1);

            if ( (LA2_0=='+'||LA2_0=='-') ) {
                alt2=1;
            }
            switch (alt2) {
                case 1 :
                    // ioke.g:
                    {
                    if ( input.LA(1)=='+'||input.LA(1)=='-' ) {
                        input.consume();

                    }
                    else {
                        MismatchedSetException mse =
                            new MismatchedSetException(null,input);
                        recover(mse);    throw mse;
                    }


                    }
                    break;

            }

            match('0'); 
            if ( input.LA(1)=='X'||input.LA(1)=='x' ) {
                input.consume();

            }
            else {
                MismatchedSetException mse =
                    new MismatchedSetException(null,input);
                recover(mse);    throw mse;
            }

            // ioke.g:76:41: ( Digit | HexLetter )+
            int cnt3=0;
            loop3:
            do {
                int alt3=2;
                int LA3_0 = input.LA(1);

                if ( ((LA3_0>='0' && LA3_0<='9')||(LA3_0>='A' && LA3_0<='F')||(LA3_0>='a' && LA3_0<='f')) ) {
                    alt3=1;
                }


                switch (alt3) {
            	case 1 :
            	    // ioke.g:
            	    {
            	    if ( (input.LA(1)>='0' && input.LA(1)<='9')||(input.LA(1)>='A' && input.LA(1)<='F')||(input.LA(1)>='a' && input.LA(1)<='f') ) {
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
            	    if ( cnt3 >= 1 ) break loop3;
                        EarlyExitException eee =
                            new EarlyExitException(3, input);
                        throw eee;
                }
                cnt3++;
            } while (true);


            }

            this.type = _type;
        }
        finally {
        }
    }
    // $ANTLR end HexInteger

    // $ANTLR start Integer
    public final void mInteger() throws RecognitionException {
        try {
            int _type = Integer;
            // ioke.g:78:9: ( ( '+' | '-' )? Digits )
            // ioke.g:78:11: ( '+' | '-' )? Digits
            {
            // ioke.g:78:11: ( '+' | '-' )?
            int alt4=2;
            int LA4_0 = input.LA(1);

            if ( (LA4_0=='+'||LA4_0=='-') ) {
                alt4=1;
            }
            switch (alt4) {
                case 1 :
                    // ioke.g:
                    {
                    if ( input.LA(1)=='+'||input.LA(1)=='-' ) {
                        input.consume();

                    }
                    else {
                        MismatchedSetException mse =
                            new MismatchedSetException(null,input);
                        recover(mse);    throw mse;
                    }


                    }
                    break;

            }

            mDigits(); 

            }

            this.type = _type;
        }
        finally {
        }
    }
    // $ANTLR end Integer

    // $ANTLR start Real
    public final void mReal() throws RecognitionException {
        try {
            int _type = Real;
            // ioke.g:81:5: ( ( '+' | '-' )? ( Digits '.' ( Digit )* ( Exponent )? | '.' Digits ( Exponent )? | Digits Exponent ) )
            // ioke.g:81:9: ( '+' | '-' )? ( Digits '.' ( Digit )* ( Exponent )? | '.' Digits ( Exponent )? | Digits Exponent )
            {
            // ioke.g:81:9: ( '+' | '-' )?
            int alt5=2;
            int LA5_0 = input.LA(1);

            if ( (LA5_0=='+'||LA5_0=='-') ) {
                alt5=1;
            }
            switch (alt5) {
                case 1 :
                    // ioke.g:
                    {
                    if ( input.LA(1)=='+'||input.LA(1)=='-' ) {
                        input.consume();

                    }
                    else {
                        MismatchedSetException mse =
                            new MismatchedSetException(null,input);
                        recover(mse);    throw mse;
                    }


                    }
                    break;

            }

            // ioke.g:82:9: ( Digits '.' ( Digit )* ( Exponent )? | '.' Digits ( Exponent )? | Digits Exponent )
            int alt9=3;
            alt9 = dfa9.predict(input);
            switch (alt9) {
                case 1 :
                    // ioke.g:82:10: Digits '.' ( Digit )* ( Exponent )?
                    {
                    mDigits(); 
                    match('.'); 
                    // ioke.g:82:21: ( Digit )*
                    loop6:
                    do {
                        int alt6=2;
                        int LA6_0 = input.LA(1);

                        if ( ((LA6_0>='0' && LA6_0<='9')) ) {
                            alt6=1;
                        }


                        switch (alt6) {
                    	case 1 :
                    	    // ioke.g:82:21: Digit
                    	    {
                    	    mDigit(); 

                    	    }
                    	    break;

                    	default :
                    	    break loop6;
                        }
                    } while (true);

                    // ioke.g:82:28: ( Exponent )?
                    int alt7=2;
                    int LA7_0 = input.LA(1);

                    if ( (LA7_0=='E'||LA7_0=='e') ) {
                        alt7=1;
                    }
                    switch (alt7) {
                        case 1 :
                            // ioke.g:82:28: Exponent
                            {
                            mExponent(); 

                            }
                            break;

                    }


                    }
                    break;
                case 2 :
                    // ioke.g:83:10: '.' Digits ( Exponent )?
                    {
                    match('.'); 
                    mDigits(); 
                    // ioke.g:83:21: ( Exponent )?
                    int alt8=2;
                    int LA8_0 = input.LA(1);

                    if ( (LA8_0=='E'||LA8_0=='e') ) {
                        alt8=1;
                    }
                    switch (alt8) {
                        case 1 :
                            // ioke.g:83:21: Exponent
                            {
                            mExponent(); 

                            }
                            break;

                    }


                    }
                    break;
                case 3 :
                    // ioke.g:84:10: Digits Exponent
                    {
                    mDigits(); 
                    mExponent(); 

                    }
                    break;

            }


            }

            this.type = _type;
        }
        finally {
        }
    }
    // $ANTLR end Real

    // $ANTLR start AssignmentOperator
    public final void mAssignmentOperator() throws RecognitionException {
        try {
            int _type = AssignmentOperator;
            // ioke.g:87:20: ( ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<<' | '>>' | '&' | '&&' | '|' | '||' ) '=' )
            // ioke.g:88:9: ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<<' | '>>' | '&' | '&&' | '|' | '||' ) '='
            {
            // ioke.g:88:9: ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<<' | '>>' | '&' | '&&' | '|' | '||' )
            int alt10=18;
            switch ( input.LA(1) ) {
            case '+':
                {
                int LA10_1 = input.LA(2);

                if ( (LA10_1=='+') ) {
                    alt10=2;
                }
                else if ( (LA10_1=='=') ) {
                    alt10=1;
                }
                else {
                    NoViableAltException nvae =
                        new NoViableAltException("88:9: ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<<' | '>>' | '&' | '&&' | '|' | '||' )", 10, 1, input);

                    throw nvae;
                }
                }
                break;
            case '-':
                {
                int LA10_2 = input.LA(2);

                if ( (LA10_2=='-') ) {
                    alt10=4;
                }
                else if ( (LA10_2=='=') ) {
                    alt10=3;
                }
                else {
                    NoViableAltException nvae =
                        new NoViableAltException("88:9: ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<<' | '>>' | '&' | '&&' | '|' | '||' )", 10, 2, input);

                    throw nvae;
                }
                }
                break;
            case '/':
                {
                int LA10_3 = input.LA(2);

                if ( (LA10_3=='/') ) {
                    alt10=6;
                }
                else if ( (LA10_3=='=') ) {
                    alt10=5;
                }
                else {
                    NoViableAltException nvae =
                        new NoViableAltException("88:9: ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<<' | '>>' | '&' | '&&' | '|' | '||' )", 10, 3, input);

                    throw nvae;
                }
                }
                break;
            case '*':
                {
                int LA10_4 = input.LA(2);

                if ( (LA10_4=='*') ) {
                    alt10=8;
                }
                else if ( (LA10_4=='=') ) {
                    alt10=7;
                }
                else {
                    NoViableAltException nvae =
                        new NoViableAltException("88:9: ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<<' | '>>' | '&' | '&&' | '|' | '||' )", 10, 4, input);

                    throw nvae;
                }
                }
                break;
            case '%':
                {
                int LA10_5 = input.LA(2);

                if ( (LA10_5=='%') ) {
                    alt10=10;
                }
                else if ( (LA10_5=='=') ) {
                    alt10=9;
                }
                else {
                    NoViableAltException nvae =
                        new NoViableAltException("88:9: ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<<' | '>>' | '&' | '&&' | '|' | '||' )", 10, 5, input);

                    throw nvae;
                }
                }
                break;
            case '^':
                {
                int LA10_6 = input.LA(2);

                if ( (LA10_6=='^') ) {
                    alt10=12;
                }
                else if ( (LA10_6=='=') ) {
                    alt10=11;
                }
                else {
                    NoViableAltException nvae =
                        new NoViableAltException("88:9: ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<<' | '>>' | '&' | '&&' | '|' | '||' )", 10, 6, input);

                    throw nvae;
                }
                }
                break;
            case '<':
                {
                alt10=13;
                }
                break;
            case '>':
                {
                alt10=14;
                }
                break;
            case '&':
                {
                int LA10_9 = input.LA(2);

                if ( (LA10_9=='&') ) {
                    alt10=16;
                }
                else if ( (LA10_9=='=') ) {
                    alt10=15;
                }
                else {
                    NoViableAltException nvae =
                        new NoViableAltException("88:9: ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<<' | '>>' | '&' | '&&' | '|' | '||' )", 10, 9, input);

                    throw nvae;
                }
                }
                break;
            case '|':
                {
                int LA10_10 = input.LA(2);

                if ( (LA10_10=='|') ) {
                    alt10=18;
                }
                else if ( (LA10_10=='=') ) {
                    alt10=17;
                }
                else {
                    NoViableAltException nvae =
                        new NoViableAltException("88:9: ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<<' | '>>' | '&' | '&&' | '|' | '||' )", 10, 10, input);

                    throw nvae;
                }
                }
                break;
            default:
                NoViableAltException nvae =
                    new NoViableAltException("88:9: ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<<' | '>>' | '&' | '&&' | '|' | '||' )", 10, 0, input);

                throw nvae;
            }

            switch (alt10) {
                case 1 :
                    // ioke.g:88:10: '+'
                    {
                    match('+'); 

                    }
                    break;
                case 2 :
                    // ioke.g:89:11: '++'
                    {
                    match("++"); 


                    }
                    break;
                case 3 :
                    // ioke.g:90:11: '-'
                    {
                    match('-'); 

                    }
                    break;
                case 4 :
                    // ioke.g:91:11: '--'
                    {
                    match("--"); 


                    }
                    break;
                case 5 :
                    // ioke.g:92:11: '/'
                    {
                    match('/'); 

                    }
                    break;
                case 6 :
                    // ioke.g:93:11: '//'
                    {
                    match("//"); 


                    }
                    break;
                case 7 :
                    // ioke.g:94:11: '*'
                    {
                    match('*'); 

                    }
                    break;
                case 8 :
                    // ioke.g:95:11: '**'
                    {
                    match("**"); 


                    }
                    break;
                case 9 :
                    // ioke.g:96:11: '%'
                    {
                    match('%'); 

                    }
                    break;
                case 10 :
                    // ioke.g:97:11: '%%'
                    {
                    match("%%"); 


                    }
                    break;
                case 11 :
                    // ioke.g:98:11: '^'
                    {
                    match('^'); 

                    }
                    break;
                case 12 :
                    // ioke.g:99:11: '^^'
                    {
                    match("^^"); 


                    }
                    break;
                case 13 :
                    // ioke.g:100:11: '<<'
                    {
                    match("<<"); 


                    }
                    break;
                case 14 :
                    // ioke.g:101:11: '>>'
                    {
                    match(">>"); 


                    }
                    break;
                case 15 :
                    // ioke.g:102:11: '&'
                    {
                    match('&'); 

                    }
                    break;
                case 16 :
                    // ioke.g:103:11: '&&'
                    {
                    match("&&"); 


                    }
                    break;
                case 17 :
                    // ioke.g:104:11: '|'
                    {
                    match('|'); 

                    }
                    break;
                case 18 :
                    // ioke.g:105:11: '||'
                    {
                    match("||"); 


                    }
                    break;

            }

            match('='); 

            }

            this.type = _type;
        }
        finally {
        }
    }
    // $ANTLR end AssignmentOperator

    // $ANTLR start UnaryOperator
    public final void mUnaryOperator() throws RecognitionException {
        try {
            int _type = UnaryOperator;
            // ioke.g:108:15: ( '@' | '@@' | '\\'' | '`' | '!' | ':' | 'return' )
            int alt11=7;
            switch ( input.LA(1) ) {
            case '@':
                {
                int LA11_1 = input.LA(2);

                if ( (LA11_1=='@') ) {
                    alt11=2;
                }
                else {
                    alt11=1;}
                }
                break;
            case '\'':
                {
                alt11=3;
                }
                break;
            case '`':
                {
                alt11=4;
                }
                break;
            case '!':
                {
                alt11=5;
                }
                break;
            case ':':
                {
                alt11=6;
                }
                break;
            case 'r':
                {
                alt11=7;
                }
                break;
            default:
                NoViableAltException nvae =
                    new NoViableAltException("108:1: UnaryOperator : ( '@' | '@@' | '\\'' | '`' | '!' | ':' | 'return' );", 11, 0, input);

                throw nvae;
            }

            switch (alt11) {
                case 1 :
                    // ioke.g:109:7: '@'
                    {
                    match('@'); 

                    }
                    break;
                case 2 :
                    // ioke.g:110:7: '@@'
                    {
                    match("@@"); 


                    }
                    break;
                case 3 :
                    // ioke.g:111:7: '\\''
                    {
                    match('\''); 

                    }
                    break;
                case 4 :
                    // ioke.g:112:7: '`'
                    {
                    match('`'); 

                    }
                    break;
                case 5 :
                    // ioke.g:113:7: '!'
                    {
                    match('!'); 

                    }
                    break;
                case 6 :
                    // ioke.g:114:7: ':'
                    {
                    match(':'); 

                    }
                    break;
                case 7 :
                    // ioke.g:115:7: 'return'
                    {
                    match("return"); 


                    }
                    break;

            }
            this.type = _type;
        }
        finally {
        }
    }
    // $ANTLR end UnaryOperator

    // $ANTLR start BinaryOperator
    public final void mBinaryOperator() throws RecognitionException {
        try {
            int _type = BinaryOperator;
            // ioke.g:118:16: ( ( OpChars )+ | '==' | '===' | '====' | '<=' | '>=' | '~=' | '~~=' | '!=' | '!!=' | 'and' | 'or' )
            int alt13=12;
            switch ( input.LA(1) ) {
            case '<':
                {
                int LA13_1 = input.LA(2);

                if ( (LA13_1=='=') ) {
                    alt13=5;
                }
                else {
                    alt13=1;}
                }
                break;
            case '=':
                {
                int LA13_2 = input.LA(2);

                if ( (LA13_2=='=') ) {
                    int LA13_10 = input.LA(3);

                    if ( (LA13_10=='=') ) {
                        int LA13_16 = input.LA(4);

                        if ( (LA13_16=='=') ) {
                            alt13=4;
                        }
                        else {
                            alt13=3;}
                    }
                    else {
                        alt13=2;}
                }
                else {
                    NoViableAltException nvae =
                        new NoViableAltException("118:1: BinaryOperator : ( ( OpChars )+ | '==' | '===' | '====' | '<=' | '>=' | '~=' | '~~=' | '!=' | '!!=' | 'and' | 'or' );", 13, 2, input);

                    throw nvae;
                }
                }
                break;
            case '>':
                {
                int LA13_3 = input.LA(2);

                if ( (LA13_3=='=') ) {
                    alt13=6;
                }
                else {
                    alt13=1;}
                }
                break;
            case '~':
                {
                switch ( input.LA(2) ) {
                case '~':
                    {
                    int LA13_12 = input.LA(3);

                    if ( (LA13_12=='=') ) {
                        alt13=8;
                    }
                    else {
                        alt13=1;}
                    }
                    break;
                case '=':
                    {
                    alt13=7;
                    }
                    break;
                default:
                    alt13=1;}

                }
                break;
            case '!':
                {
                switch ( input.LA(2) ) {
                case '=':
                    {
                    alt13=9;
                    }
                    break;
                case '!':
                    {
                    int LA13_15 = input.LA(3);

                    if ( (LA13_15=='=') ) {
                        alt13=10;
                    }
                    else {
                        alt13=1;}
                    }
                    break;
                default:
                    alt13=1;}

                }
                break;
            case '%':
            case '&':
            case '\'':
            case '*':
            case '+':
            case '-':
            case '.':
            case '/':
            case ':':
            case '?':
            case '@':
            case '\\':
            case '^':
            case '_':
            case '`':
            case '|':
                {
                alt13=1;
                }
                break;
            case 'a':
                {
                alt13=11;
                }
                break;
            case 'o':
                {
                alt13=12;
                }
                break;
            default:
                NoViableAltException nvae =
                    new NoViableAltException("118:1: BinaryOperator : ( ( OpChars )+ | '==' | '===' | '====' | '<=' | '>=' | '~=' | '~~=' | '!=' | '!!=' | 'and' | 'or' );", 13, 0, input);

                throw nvae;
            }

            switch (alt13) {
                case 1 :
                    // ioke.g:119:7: ( OpChars )+
                    {
                    // ioke.g:119:7: ( OpChars )+
                    int cnt12=0;
                    loop12:
                    do {
                        int alt12=2;
                        int LA12_0 = input.LA(1);

                        if ( (LA12_0=='!'||(LA12_0>='%' && LA12_0<='\'')||(LA12_0>='*' && LA12_0<='+')||(LA12_0>='-' && LA12_0<='/')||LA12_0==':'||LA12_0=='<'||(LA12_0>='>' && LA12_0<='@')||LA12_0=='\\'||(LA12_0>='^' && LA12_0<='`')||LA12_0=='|'||LA12_0=='~') ) {
                            alt12=1;
                        }


                        switch (alt12) {
                    	case 1 :
                    	    // ioke.g:119:7: OpChars
                    	    {
                    	    mOpChars(); 

                    	    }
                    	    break;

                    	default :
                    	    if ( cnt12 >= 1 ) break loop12;
                                EarlyExitException eee =
                                    new EarlyExitException(12, input);
                                throw eee;
                        }
                        cnt12++;
                    } while (true);


                    }
                    break;
                case 2 :
                    // ioke.g:120:7: '=='
                    {
                    match("=="); 


                    }
                    break;
                case 3 :
                    // ioke.g:121:7: '==='
                    {
                    match("==="); 


                    }
                    break;
                case 4 :
                    // ioke.g:122:7: '===='
                    {
                    match("===="); 


                    }
                    break;
                case 5 :
                    // ioke.g:123:7: '<='
                    {
                    match("<="); 


                    }
                    break;
                case 6 :
                    // ioke.g:124:7: '>='
                    {
                    match(">="); 


                    }
                    break;
                case 7 :
                    // ioke.g:125:7: '~='
                    {
                    match("~="); 


                    }
                    break;
                case 8 :
                    // ioke.g:126:7: '~~='
                    {
                    match("~~="); 


                    }
                    break;
                case 9 :
                    // ioke.g:127:7: '!='
                    {
                    match("!="); 


                    }
                    break;
                case 10 :
                    // ioke.g:128:7: '!!='
                    {
                    match("!!="); 


                    }
                    break;
                case 11 :
                    // ioke.g:129:7: 'and'
                    {
                    match("and"); 


                    }
                    break;
                case 12 :
                    // ioke.g:130:7: 'or'
                    {
                    match("or"); 


                    }
                    break;

            }
            this.type = _type;
        }
        finally {
        }
    }
    // $ANTLR end BinaryOperator

    // $ANTLR start Assignment
    public final void mAssignment() throws RecognitionException {
        try {
            int _type = Assignment;
            // ioke.g:133:12: ( '=' )
            // ioke.g:133:14: '='
            {
            match('='); 

            }

            this.type = _type;
        }
        finally {
        }
    }
    // $ANTLR end Assignment

    // $ANTLR start Identifier
    public final void mIdentifier() throws RecognitionException {
        try {
            int _type = Identifier;
            // ioke.g:135:12: ( IdentStart ( IdentChars )* )
            // ioke.g:135:14: IdentStart ( IdentChars )*
            {
            mIdentStart(); 
            // ioke.g:135:25: ( IdentChars )*
            loop14:
            do {
                int alt14=2;
                int LA14_0 = input.LA(1);

                if ( (LA14_0=='!'||(LA14_0>='%' && LA14_0<='\'')||(LA14_0>='*' && LA14_0<='+')||(LA14_0>='-' && LA14_0<=':')||LA14_0=='<'||(LA14_0>='>' && LA14_0<='Z')||LA14_0=='\\'||(LA14_0>='^' && LA14_0<='z')||LA14_0=='|'||LA14_0=='~') ) {
                    alt14=1;
                }


                switch (alt14) {
            	case 1 :
            	    // ioke.g:135:25: IdentChars
            	    {
            	    mIdentChars(); 

            	    }
            	    break;

            	default :
            	    break loop14;
                }
            } while (true);


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
            // ioke.g:137:20: ( ( ( ';' | NewLine )+ ) )
            // ioke.g:137:22: ( ( ';' | NewLine )+ )
            {
            // ioke.g:137:22: ( ( ';' | NewLine )+ )
            // ioke.g:137:23: ( ';' | NewLine )+
            {
            // ioke.g:137:23: ( ';' | NewLine )+
            int cnt15=0;
            loop15:
            do {
                int alt15=2;
                int LA15_0 = input.LA(1);

                if ( (LA15_0=='\n'||LA15_0=='\r'||LA15_0==';') ) {
                    alt15=1;
                }


                switch (alt15) {
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
            	    if ( cnt15 >= 1 ) break loop15;
                        EarlyExitException eee =
                            new EarlyExitException(15, input);
                        throw eee;
                }
                cnt15++;
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
            // ioke.g:139:12: ( Separator )
            // ioke.g:139:14: Separator
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

    // $ANTLR start Exponent
    public final void mExponent() throws RecognitionException {
        try {
            // ioke.g:144:10: ( ( 'e' | 'E' ) ( '+' | '-' )? Digits )
            // ioke.g:144:12: ( 'e' | 'E' ) ( '+' | '-' )? Digits
            {
            if ( input.LA(1)=='E'||input.LA(1)=='e' ) {
                input.consume();

            }
            else {
                MismatchedSetException mse =
                    new MismatchedSetException(null,input);
                recover(mse);    throw mse;
            }

            // ioke.g:144:22: ( '+' | '-' )?
            int alt16=2;
            int LA16_0 = input.LA(1);

            if ( (LA16_0=='+'||LA16_0=='-') ) {
                alt16=1;
            }
            switch (alt16) {
                case 1 :
                    // ioke.g:
                    {
                    if ( input.LA(1)=='+'||input.LA(1)=='-' ) {
                        input.consume();

                    }
                    else {
                        MismatchedSetException mse =
                            new MismatchedSetException(null,input);
                        recover(mse);    throw mse;
                    }


                    }
                    break;

            }

            mDigits(); 

            }

        }
        finally {
        }
    }
    // $ANTLR end Exponent

    // $ANTLR start Letter
    public final void mLetter() throws RecognitionException {
        try {
            // ioke.g:147:8: ( 'a' .. 'z' | 'A' .. 'Z' )
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
            // ioke.g:150:7: ( '0' .. '9' )
            // ioke.g:150:9: '0' .. '9'
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
            // ioke.g:153:8: ( ( Digit )+ )
            // ioke.g:153:10: ( Digit )+
            {
            // ioke.g:153:10: ( Digit )+
            int cnt17=0;
            loop17:
            do {
                int alt17=2;
                int LA17_0 = input.LA(1);

                if ( ((LA17_0>='0' && LA17_0<='9')) ) {
                    alt17=1;
                }


                switch (alt17) {
            	case 1 :
            	    // ioke.g:153:10: Digit
            	    {
            	    mDigit(); 

            	    }
            	    break;

            	default :
            	    if ( cnt17 >= 1 ) break loop17;
                        EarlyExitException eee =
                            new EarlyExitException(17, input);
                        throw eee;
                }
                cnt17++;
            } while (true);


            }

        }
        finally {
        }
    }
    // $ANTLR end Digits

    // $ANTLR start HexLetter
    public final void mHexLetter() throws RecognitionException {
        try {
            // ioke.g:156:11: ( 'a' .. 'f' | 'A' .. 'F' )
            // ioke.g:
            {
            if ( (input.LA(1)>='A' && input.LA(1)<='F')||(input.LA(1)>='a' && input.LA(1)<='f') ) {
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
    // $ANTLR end HexLetter

    // $ANTLR start Separator
    public final void mSeparator() throws RecognitionException {
        try {
            // ioke.g:159:11: ( ( ' ' | '\\u000c' | '\\u0009' | '\\u000b' | '\\\\' '\\u000a' )+ )
            // ioke.g:159:13: ( ' ' | '\\u000c' | '\\u0009' | '\\u000b' | '\\\\' '\\u000a' )+
            {
            // ioke.g:159:13: ( ' ' | '\\u000c' | '\\u0009' | '\\u000b' | '\\\\' '\\u000a' )+
            int cnt18=0;
            loop18:
            do {
                int alt18=6;
                switch ( input.LA(1) ) {
                case ' ':
                    {
                    alt18=1;
                    }
                    break;
                case '\f':
                    {
                    alt18=2;
                    }
                    break;
                case '\t':
                    {
                    alt18=3;
                    }
                    break;
                case '\u000B':
                    {
                    alt18=4;
                    }
                    break;
                case '\\':
                    {
                    alt18=5;
                    }
                    break;

                }

                switch (alt18) {
            	case 1 :
            	    // ioke.g:159:14: ' '
            	    {
            	    match(' '); 

            	    }
            	    break;
            	case 2 :
            	    // ioke.g:159:20: '\\u000c'
            	    {
            	    match('\f'); 

            	    }
            	    break;
            	case 3 :
            	    // ioke.g:159:31: '\\u0009'
            	    {
            	    match('\t'); 

            	    }
            	    break;
            	case 4 :
            	    // ioke.g:159:42: '\\u000b'
            	    {
            	    match('\u000B'); 

            	    }
            	    break;
            	case 5 :
            	    // ioke.g:159:53: '\\\\' '\\u000a'
            	    {
            	    match('\\'); 
            	    match('\n'); 

            	    }
            	    break;

            	default :
            	    if ( cnt18 >= 1 ) break loop18;
                        EarlyExitException eee =
                            new EarlyExitException(18, input);
                        throw eee;
                }
                cnt18++;
            } while (true);


            }

        }
        finally {
        }
    }
    // $ANTLR end Separator

    // $ANTLR start OpChars
    public final void mOpChars() throws RecognitionException {
        try {
            // ioke.g:162:9: ( ( '!' | '?' | '@' | '&' | '%' | '.' | '|' | '<' | '>' | '/' | '+' | '-' | '_' | ':' | '\\\\' | '*' | '^' | '~' | '`' | '\\'' ) )
            // ioke.g:162:11: ( '!' | '?' | '@' | '&' | '%' | '.' | '|' | '<' | '>' | '/' | '+' | '-' | '_' | ':' | '\\\\' | '*' | '^' | '~' | '`' | '\\'' )
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
    // $ANTLR end OpChars

    // $ANTLR start IdentChars
    public final void mIdentChars() throws RecognitionException {
        try {
            // ioke.g:165:12: ( Letter | Digit | ( '!' | '?' | '@' | '&' | '%' | '.' | '|' | '<' | '>' | '/' | '+' | '-' | '_' | ':' | '\\\\' | '*' | '^' | '~' | '`' | '\\'' ) )
            // ioke.g:
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

        }
        finally {
        }
    }
    // $ANTLR end IdentChars

    // $ANTLR start IdentStart
    public final void mIdentStart() throws RecognitionException {
        try {
            // ioke.g:168:12: ( Letter | Digit | ( '?' | '&' | '%' | '|' | '<' | '>' | '/' | '+' | '-' | '_' | '\\\\' | '*' | '^' | '~' ) )
            // ioke.g:
            {
            if ( (input.LA(1)>='%' && input.LA(1)<='&')||(input.LA(1)>='*' && input.LA(1)<='+')||input.LA(1)=='-'||(input.LA(1)>='/' && input.LA(1)<='9')||input.LA(1)=='<'||(input.LA(1)>='>' && input.LA(1)<='?')||(input.LA(1)>='A' && input.LA(1)<='Z')||input.LA(1)=='\\'||(input.LA(1)>='^' && input.LA(1)<='_')||(input.LA(1)>='a' && input.LA(1)<='z')||input.LA(1)=='|'||input.LA(1)=='~' ) {
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
    // $ANTLR end IdentStart

    // $ANTLR start NewLine
    public final void mNewLine() throws RecognitionException {
        try {
            // ioke.g:171:9: ( ( '\\u000a' | '\\u000d' ) )
            // ioke.g:171:11: ( '\\u000a' | '\\u000d' )
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
        // ioke.g:1:8: ( OpenSimple | CloseSimple | OpenSquare | CloseSquare | OpenCurly | CloseCurly | Comma | HexInteger | Integer | Real | AssignmentOperator | UnaryOperator | BinaryOperator | Assignment | Identifier | PossibleTerminator | Whitespace )
        int alt19=17;
        alt19 = dfa19.predict(input);
        switch (alt19) {
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
                // ioke.g:1:83: HexInteger
                {
                mHexInteger(); 

                }
                break;
            case 9 :
                // ioke.g:1:94: Integer
                {
                mInteger(); 

                }
                break;
            case 10 :
                // ioke.g:1:102: Real
                {
                mReal(); 

                }
                break;
            case 11 :
                // ioke.g:1:107: AssignmentOperator
                {
                mAssignmentOperator(); 

                }
                break;
            case 12 :
                // ioke.g:1:126: UnaryOperator
                {
                mUnaryOperator(); 

                }
                break;
            case 13 :
                // ioke.g:1:140: BinaryOperator
                {
                mBinaryOperator(); 

                }
                break;
            case 14 :
                // ioke.g:1:155: Assignment
                {
                mAssignment(); 

                }
                break;
            case 15 :
                // ioke.g:1:166: Identifier
                {
                mIdentifier(); 

                }
                break;
            case 16 :
                // ioke.g:1:177: PossibleTerminator
                {
                mPossibleTerminator(); 

                }
                break;
            case 17 :
                // ioke.g:1:196: Whitespace
                {
                mWhitespace(); 

                }
                break;

        }

    }


    protected DFA9 dfa9 = new DFA9(this);
    protected DFA19 dfa19 = new DFA19(this);
    static final String DFA9_eotS =
        "\5\uffff";
    static final String DFA9_eofS =
        "\5\uffff";
    static final String DFA9_minS =
        "\2\56\3\uffff";
    static final String DFA9_maxS =
        "\1\71\1\145\3\uffff";
    static final String DFA9_acceptS =
        "\2\uffff\1\2\1\1\1\3";
    static final String DFA9_specialS =
        "\5\uffff}>";
    static final String[] DFA9_transitionS = {
            "\1\2\1\uffff\12\1",
            "\1\3\1\uffff\12\1\13\uffff\1\4\37\uffff\1\4",
            "",
            "",
            ""
    };

    static final short[] DFA9_eot = DFA.unpackEncodedString(DFA9_eotS);
    static final short[] DFA9_eof = DFA.unpackEncodedString(DFA9_eofS);
    static final char[] DFA9_min = DFA.unpackEncodedStringToUnsignedChars(DFA9_minS);
    static final char[] DFA9_max = DFA.unpackEncodedStringToUnsignedChars(DFA9_maxS);
    static final short[] DFA9_accept = DFA.unpackEncodedString(DFA9_acceptS);
    static final short[] DFA9_special = DFA.unpackEncodedString(DFA9_specialS);
    static final short[][] DFA9_transition;

    static {
        int numStates = DFA9_transitionS.length;
        DFA9_transition = new short[numStates][];
        for (int i=0; i<numStates; i++) {
            DFA9_transition[i] = DFA.unpackEncodedString(DFA9_transitionS[i]);
        }
    }

    class DFA9 extends DFA {

        public DFA9(BaseRecognizer recognizer) {
            this.recognizer = recognizer;
            this.decisionNumber = 9;
            this.eot = DFA9_eot;
            this.eof = DFA9_eof;
            this.min = DFA9_min;
            this.max = DFA9_max;
            this.accept = DFA9_accept;
            this.special = DFA9_special;
            this.transition = DFA9_transition;
        }
        public String getDescription() {
            return "82:9: ( Digits '.' ( Digit )* ( Exponent )? | '.' Digits ( Exponent )? | Digits Exponent )";
        }
    }
    static final String DFA19_eotS =
        "\10\uffff\1\51\2\54\12\51\5\72\1\40\1\51\1\75\1\51\2\40\3\uffff"+
        "\2\51\1\54\1\uffff\1\54\1\51\1\uffff\1\51\1\40\1\uffff\1\40\1\57"+
        "\1\uffff\11\51\1\72\1\uffff\1\40\1\51\1\uffff\1\40\1\51\1\57\1\111"+
        "\1\40\2\57\2\40\1\51\1\40\1\uffff\1\40\1\57\2\40\1\57\1\40\1\72";
    static final String DFA19_eofS =
        "\121\uffff";
    static final String DFA19_minS =
        "\1\11\7\uffff\3\41\1\60\16\41\1\145\1\41\1\75\1\12\1\156\1\162\3"+
        "\uffff\3\41\1\uffff\2\41\1\uffff\1\41\1\60\1\uffff\1\53\1\41\1\uffff"+
        "\12\41\1\uffff\1\164\1\41\1\uffff\1\144\3\41\1\60\2\41\1\53\1\165"+
        "\1\41\1\53\1\uffff\1\60\1\41\1\162\1\60\1\41\1\156\1\41";
    static final String DFA19_maxS =
        "\1\176\7\uffff\3\176\1\71\16\176\1\145\1\176\1\75\1\176\1\156\1"+
        "\162\3\uffff\3\176\1\uffff\2\176\1\uffff\1\176\1\146\1\uffff\1\71"+
        "\1\176\1\uffff\12\176\1\uffff\1\164\1\176\1\uffff\1\144\3\176\1"+
        "\71\2\176\1\71\1\165\1\176\1\71\1\uffff\1\71\1\176\1\162\1\71\1"+
        "\176\1\156\1\176";
    static final String DFA19_acceptS =
        "\1\uffff\1\1\1\2\1\3\1\4\1\5\1\6\1\7\30\uffff\1\17\1\20\1\21\3\uffff"+
        "\1\13\2\uffff\1\15\2\uffff\1\11\2\uffff\1\12\12\uffff\1\14\2\uffff"+
        "\1\16\13\uffff\1\10\7\uffff";
    static final String DFA19_specialS =
        "\121\uffff}>";
    static final String[] DFA19_transitionS = {
            "\1\42\1\41\2\42\1\41\22\uffff\1\42\1\30\3\uffff\1\17\1\23\1"+
            "\26\1\1\1\2\1\16\1\10\1\7\1\14\1\13\1\15\1\11\11\12\1\31\1\41"+
            "\1\21\1\34\1\22\1\43\1\25\32\40\1\3\1\35\1\4\1\20\1\43\1\27"+
            "\1\36\15\40\1\37\2\40\1\32\10\40\1\5\1\24\1\6\1\33",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "\1\52\3\uffff\3\52\2\uffff\1\52\1\44\1\uffff\1\52\1\50\1\52"+
            "\1\45\11\47\1\52\1\uffff\1\52\1\46\3\52\32\40\1\uffff\1\52\1"+
            "\uffff\3\52\32\40\1\uffff\1\52\1\uffff\1\52",
            "\1\40\3\uffff\3\40\2\uffff\2\40\1\uffff\1\40\1\56\1\40\12\47"+
            "\1\40\1\uffff\1\40\1\uffff\7\40\1\55\22\40\1\53\2\40\1\uffff"+
            "\1\40\1\uffff\7\40\1\55\22\40\1\53\2\40\1\uffff\1\40\1\uffff"+
            "\1\40",
            "\1\40\3\uffff\3\40\2\uffff\2\40\1\uffff\1\40\1\56\1\40\12\47"+
            "\1\40\1\uffff\1\40\1\uffff\7\40\1\55\25\40\1\uffff\1\40\1\uffff"+
            "\7\40\1\55\25\40\1\uffff\1\40\1\uffff\1\40",
            "\12\57",
            "\1\52\3\uffff\3\52\2\uffff\2\52\1\uffff\1\60\1\50\1\52\1\45"+
            "\11\47\1\52\1\uffff\1\52\1\46\3\52\32\40\1\uffff\1\52\1\uffff"+
            "\3\52\32\40\1\uffff\1\52\1\uffff\1\52",
            "\1\52\3\uffff\3\52\2\uffff\2\52\1\uffff\2\52\1\61\12\40\1\52"+
            "\1\uffff\1\52\1\46\3\52\32\40\1\uffff\1\52\1\uffff\3\52\32\40"+
            "\1\uffff\1\52\1\uffff\1\52",
            "\1\52\3\uffff\3\52\2\uffff\1\62\1\52\1\uffff\3\52\12\40\1\52"+
            "\1\uffff\1\52\1\46\3\52\32\40\1\uffff\1\52\1\uffff\3\52\32\40"+
            "\1\uffff\1\52\1\uffff\1\52",
            "\1\52\3\uffff\1\63\2\52\2\uffff\2\52\1\uffff\3\52\12\40\1\52"+
            "\1\uffff\1\52\1\46\3\52\32\40\1\uffff\1\52\1\uffff\3\52\32\40"+
            "\1\uffff\1\52\1\uffff\1\52",
            "\1\52\3\uffff\3\52\2\uffff\2\52\1\uffff\3\52\12\40\1\52\1\uffff"+
            "\1\52\1\46\3\52\32\40\1\uffff\1\52\1\uffff\1\64\2\52\32\40\1"+
            "\uffff\1\52\1\uffff\1\52",
            "\1\52\3\uffff\3\52\2\uffff\2\52\1\uffff\3\52\12\40\1\52\1\uffff"+
            "\1\65\1\uffff\3\52\32\40\1\uffff\1\52\1\uffff\3\52\32\40\1\uffff"+
            "\1\52\1\uffff\1\52",
            "\1\52\3\uffff\3\52\2\uffff\2\52\1\uffff\3\52\12\40\1\52\1\uffff"+
            "\1\52\1\uffff\1\66\2\52\32\40\1\uffff\1\52\1\uffff\3\52\32\40"+
            "\1\uffff\1\52\1\uffff\1\52",
            "\1\52\3\uffff\1\52\1\67\1\52\2\uffff\2\52\1\uffff\3\52\12\40"+
            "\1\52\1\uffff\1\52\1\46\3\52\32\40\1\uffff\1\52\1\uffff\3\52"+
            "\32\40\1\uffff\1\52\1\uffff\1\52",
            "\1\52\3\uffff\3\52\2\uffff\2\52\1\uffff\3\52\12\40\1\52\1\uffff"+
            "\1\52\1\46\3\52\32\40\1\uffff\1\52\1\uffff\3\52\32\40\1\uffff"+
            "\1\70\1\uffff\1\52",
            "\1\51\3\uffff\3\51\2\uffff\2\51\1\uffff\3\51\12\uffff\1\51\1"+
            "\uffff\1\51\1\uffff\2\51\1\71\33\uffff\1\51\1\uffff\3\51\33"+
            "\uffff\1\51\1\uffff\1\51",
            "\1\51\3\uffff\3\51\2\uffff\2\51\1\uffff\3\51\12\uffff\1\51\1"+
            "\uffff\1\51\1\uffff\3\51\33\uffff\1\51\1\uffff\3\51\33\uffff"+
            "\1\51\1\uffff\1\51",
            "\1\51\3\uffff\3\51\2\uffff\2\51\1\uffff\3\51\12\uffff\1\51\1"+
            "\uffff\1\51\1\uffff\3\51\33\uffff\1\51\1\uffff\3\51\33\uffff"+
            "\1\51\1\uffff\1\51",
            "\1\51\3\uffff\3\51\2\uffff\2\51\1\uffff\3\51\12\uffff\1\51\1"+
            "\uffff\5\51\33\uffff\1\51\1\uffff\3\51\33\uffff\1\51\1\uffff"+
            "\1\51",
            "\1\51\3\uffff\3\51\2\uffff\2\51\1\uffff\3\51\12\uffff\1\51\1"+
            "\uffff\1\51\1\uffff\3\51\33\uffff\1\51\1\uffff\3\51\33\uffff"+
            "\1\51\1\uffff\1\51",
            "\1\73",
            "\1\52\3\uffff\3\52\2\uffff\2\52\1\uffff\3\52\12\40\1\52\1\uffff"+
            "\1\52\1\uffff\3\52\32\40\1\uffff\1\52\1\uffff\3\52\32\40\1\uffff"+
            "\1\52\1\uffff\1\74",
            "\1\51",
            "\1\42\26\uffff\1\52\3\uffff\3\52\2\uffff\2\52\1\uffff\3\52\12"+
            "\40\1\52\1\uffff\1\52\1\uffff\3\52\32\40\1\uffff\1\52\1\uffff"+
            "\3\52\32\40\1\uffff\1\52\1\uffff\1\52",
            "\1\76",
            "\1\77",
            "",
            "",
            "",
            "\1\52\3\uffff\3\52\2\uffff\2\52\1\uffff\3\52\12\40\1\52\1\uffff"+
            "\1\52\1\uffff\3\52\32\40\1\uffff\1\52\1\uffff\3\52\32\40\1\uffff"+
            "\1\52\1\uffff\1\52",
            "\1\52\3\uffff\3\52\2\uffff\2\52\1\uffff\3\52\12\40\1\52\1\uffff"+
            "\1\52\1\46\3\52\32\40\1\uffff\1\52\1\uffff\3\52\32\40\1\uffff"+
            "\1\52\1\uffff\1\52",
            "\1\40\3\uffff\3\40\2\uffff\2\40\1\uffff\1\40\1\56\1\40\12\47"+
            "\1\40\1\uffff\1\40\1\uffff\7\40\1\55\22\40\1\53\2\40\1\uffff"+
            "\1\40\1\uffff\7\40\1\55\22\40\1\53\2\40\1\uffff\1\40\1\uffff"+
            "\1\40",
            "",
            "\1\40\3\uffff\3\40\2\uffff\2\40\1\uffff\1\40\1\56\1\40\12\47"+
            "\1\40\1\uffff\1\40\1\uffff\7\40\1\55\25\40\1\uffff\1\40\1\uffff"+
            "\7\40\1\55\25\40\1\uffff\1\40\1\uffff\1\40",
            "\1\52\3\uffff\3\52\2\uffff\2\52\1\uffff\3\52\12\100\1\52\1\uffff"+
            "\1\52\1\uffff\3\52\32\40\1\uffff\1\52\1\uffff\3\52\32\40\1\uffff"+
            "\1\52\1\uffff\1\52",
            "",
            "\1\52\3\uffff\3\52\2\uffff\2\52\1\uffff\3\52\12\40\1\52\1\uffff"+
            "\1\52\1\uffff\3\52\32\40\1\uffff\1\52\1\uffff\3\52\32\40\1\uffff"+
            "\1\52\1\uffff\1\52",
            "\12\101\7\uffff\6\101\32\uffff\6\101",
            "",
            "\1\102\1\uffff\1\102\2\uffff\12\103",
            "\1\40\3\uffff\3\40\2\uffff\2\40\1\uffff\3\40\12\104\1\40\1\uffff"+
            "\1\40\1\uffff\7\40\1\105\25\40\1\uffff\1\40\1\uffff\7\40\1\105"+
            "\25\40\1\uffff\1\40\1\uffff\1\40",
            "",
            "\1\52\3\uffff\3\52\2\uffff\2\52\1\uffff\3\52\12\40\1\52\1\uffff"+
            "\1\52\1\46\3\52\32\40\1\uffff\1\52\1\uffff\3\52\32\40\1\uffff"+
            "\1\52\1\uffff\1\52",
            "\1\52\3\uffff\3\52\2\uffff\2\52\1\uffff\3\52\12\40\1\52\1\uffff"+
            "\1\52\1\46\3\52\32\40\1\uffff\1\52\1\uffff\3\52\32\40\1\uffff"+
            "\1\52\1\uffff\1\52",
            "\1\52\3\uffff\3\52\2\uffff\2\52\1\uffff\3\52\12\40\1\52\1\uffff"+
            "\1\52\1\46\3\52\32\40\1\uffff\1\52\1\uffff\3\52\32\40\1\uffff"+
            "\1\52\1\uffff\1\52",
            "\1\52\3\uffff\3\52\2\uffff\2\52\1\uffff\3\52\12\40\1\52\1\uffff"+
            "\1\52\1\46\3\52\32\40\1\uffff\1\52\1\uffff\3\52\32\40\1\uffff"+
            "\1\52\1\uffff\1\52",
            "\1\52\3\uffff\3\52\2\uffff\2\52\1\uffff\3\52\12\40\1\52\1\uffff"+
            "\1\52\1\46\3\52\32\40\1\uffff\1\52\1\uffff\3\52\32\40\1\uffff"+
            "\1\52\1\uffff\1\52",
            "\1\52\3\uffff\3\52\2\uffff\2\52\1\uffff\3\52\12\40\1\52\1\uffff"+
            "\1\52\1\46\3\52\32\40\1\uffff\1\52\1\uffff\3\52\32\40\1\uffff"+
            "\1\52\1\uffff\1\52",
            "\1\52\3\uffff\3\52\2\uffff\2\52\1\uffff\3\52\12\40\1\52\1\uffff"+
            "\1\52\1\46\3\52\32\40\1\uffff\1\52\1\uffff\3\52\32\40\1\uffff"+
            "\1\52\1\uffff\1\52",
            "\1\52\3\uffff\3\52\2\uffff\2\52\1\uffff\3\52\12\40\1\52\1\uffff"+
            "\1\52\1\46\3\52\32\40\1\uffff\1\52\1\uffff\3\52\32\40\1\uffff"+
            "\1\52\1\uffff\1\52",
            "\1\52\3\uffff\3\52\2\uffff\2\52\1\uffff\3\52\12\40\1\52\1\uffff"+
            "\1\52\1\46\3\52\32\40\1\uffff\1\52\1\uffff\3\52\32\40\1\uffff"+
            "\1\52\1\uffff\1\52",
            "\1\51\3\uffff\3\51\2\uffff\2\51\1\uffff\3\51\12\uffff\1\51\1"+
            "\uffff\1\51\1\uffff\3\51\33\uffff\1\51\1\uffff\3\51\33\uffff"+
            "\1\51\1\uffff\1\51",
            "",
            "\1\106",
            "\1\52\3\uffff\3\52\2\uffff\2\52\1\uffff\3\52\12\40\1\52\1\uffff"+
            "\1\52\1\uffff\3\52\32\40\1\uffff\1\52\1\uffff\3\52\32\40\1\uffff"+
            "\1\52\1\uffff\1\52",
            "",
            "\1\107",
            "\1\40\3\uffff\3\40\2\uffff\2\40\1\uffff\16\40\1\uffff\1\40\1"+
            "\uffff\35\40\1\uffff\1\40\1\uffff\35\40\1\uffff\1\40\1\uffff"+
            "\1\40",
            "\1\40\3\uffff\3\40\2\uffff\2\40\1\uffff\3\40\12\100\1\40\1\uffff"+
            "\1\40\1\uffff\7\40\1\110\25\40\1\uffff\1\40\1\uffff\7\40\1\110"+
            "\25\40\1\uffff\1\40\1\uffff\1\40",
            "\1\40\3\uffff\3\40\2\uffff\2\40\1\uffff\3\40\12\101\1\40\1\uffff"+
            "\1\40\1\uffff\3\40\6\101\24\40\1\uffff\1\40\1\uffff\3\40\6\101"+
            "\24\40\1\uffff\1\40\1\uffff\1\40",
            "\12\103",
            "\1\40\3\uffff\3\40\2\uffff\2\40\1\uffff\3\40\12\103\1\40\1\uffff"+
            "\1\40\1\uffff\35\40\1\uffff\1\40\1\uffff\35\40\1\uffff\1\40"+
            "\1\uffff\1\40",
            "\1\40\3\uffff\3\40\2\uffff\2\40\1\uffff\3\40\12\104\1\40\1\uffff"+
            "\1\40\1\uffff\7\40\1\105\25\40\1\uffff\1\40\1\uffff\7\40\1\105"+
            "\25\40\1\uffff\1\40\1\uffff\1\40",
            "\1\112\1\uffff\1\112\2\uffff\12\113",
            "\1\114",
            "\1\40\3\uffff\3\40\2\uffff\2\40\1\uffff\16\40\1\uffff\1\40\1"+
            "\uffff\35\40\1\uffff\1\40\1\uffff\35\40\1\uffff\1\40\1\uffff"+
            "\1\40",
            "\1\115\1\uffff\1\115\2\uffff\12\116",
            "",
            "\12\113",
            "\1\40\3\uffff\3\40\2\uffff\2\40\1\uffff\3\40\12\113\1\40\1\uffff"+
            "\1\40\1\uffff\35\40\1\uffff\1\40\1\uffff\35\40\1\uffff\1\40"+
            "\1\uffff\1\40",
            "\1\117",
            "\12\116",
            "\1\40\3\uffff\3\40\2\uffff\2\40\1\uffff\3\40\12\116\1\40\1\uffff"+
            "\1\40\1\uffff\35\40\1\uffff\1\40\1\uffff\35\40\1\uffff\1\40"+
            "\1\uffff\1\40",
            "\1\120",
            "\1\40\3\uffff\3\40\2\uffff\2\40\1\uffff\16\40\1\uffff\1\40\1"+
            "\uffff\35\40\1\uffff\1\40\1\uffff\35\40\1\uffff\1\40\1\uffff"+
            "\1\40"
    };

    static final short[] DFA19_eot = DFA.unpackEncodedString(DFA19_eotS);
    static final short[] DFA19_eof = DFA.unpackEncodedString(DFA19_eofS);
    static final char[] DFA19_min = DFA.unpackEncodedStringToUnsignedChars(DFA19_minS);
    static final char[] DFA19_max = DFA.unpackEncodedStringToUnsignedChars(DFA19_maxS);
    static final short[] DFA19_accept = DFA.unpackEncodedString(DFA19_acceptS);
    static final short[] DFA19_special = DFA.unpackEncodedString(DFA19_specialS);
    static final short[][] DFA19_transition;

    static {
        int numStates = DFA19_transitionS.length;
        DFA19_transition = new short[numStates][];
        for (int i=0; i<numStates; i++) {
            DFA19_transition[i] = DFA.unpackEncodedString(DFA19_transitionS[i]);
        }
    }

    class DFA19 extends DFA {

        public DFA19(BaseRecognizer recognizer) {
            this.recognizer = recognizer;
            this.decisionNumber = 19;
            this.eot = DFA19_eot;
            this.eof = DFA19_eof;
            this.min = DFA19_min;
            this.max = DFA19_max;
            this.accept = DFA19_accept;
            this.special = DFA19_special;
            this.transition = DFA19_transition;
        }
        public String getDescription() {
            return "1:1: Tokens : ( OpenSimple | CloseSimple | OpenSquare | CloseSquare | OpenCurly | CloseCurly | Comma | HexInteger | Integer | Real | AssignmentOperator | UnaryOperator | BinaryOperator | Assignment | Identifier | PossibleTerminator | Whitespace );";
        }
    }
 

}