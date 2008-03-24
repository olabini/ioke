// $ANTLR 3.0.1 ioke.g 2008-03-24 14:59:12

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
    public static final int Assignment=25;
    public static final int CloseCurly=12;
    public static final int Exponent=19;
    public static final int OpChars=23;
    public static final int HexLetter=15;
    public static final int IdentChars=27;
    public static final int Digit=14;
    public static final int Tokens=33;
    public static final int EOF=-1;
    public static final int OpenSimple=7;
    public static final int IdentStart=26;
    public static final int Identifier=28;
    public static final int Separator=30;
    public static final int NewLine=5;
    public static final int AssignmentOperator=21;
    public static final int OpenSquare=9;
    public static final int CloseSimple=8;
    public static final int Digits=17;
    public static final int NewlineComment=6;
    public static final int HexInteger=16;
    public static final int Real=20;
    public static final int BinaryOperator=24;
    public static final int MultiComment=4;
    public static final int UnaryOperator=22;
    public static final int Whitespace=31;
    public static final int CloseSquare=10;
    public static final int OpenCurly=11;
    public static final int Comma=13;
    public static final int Letter=32;
    public static final int Integer=18;
    public static final int PossibleTerminator=29;

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

    // $ANTLR start MultiComment
    public final void mMultiComment() throws RecognitionException {
        try {
            int _type = MultiComment;
            // ioke.g:67:14: ( ( '{#' ( options {greedy=false; } : ( . )* ) '#}' ) )
            // ioke.g:67:16: ( '{#' ( options {greedy=false; } : ( . )* ) '#}' )
            {
            // ioke.g:67:16: ( '{#' ( options {greedy=false; } : ( . )* ) '#}' )
            // ioke.g:67:17: '{#' ( options {greedy=false; } : ( . )* ) '#}'
            {
            match("{#"); 

            // ioke.g:67:22: ( options {greedy=false; } : ( . )* )
            // ioke.g:67:50: ( . )*
            {
            // ioke.g:67:50: ( . )*
            loop1:
            do {
                int alt1=2;
                int LA1_0 = input.LA(1);

                if ( (LA1_0=='#') ) {
                    int LA1_1 = input.LA(2);

                    if ( (LA1_1=='}') ) {
                        alt1=2;
                    }
                    else if ( ((LA1_1>='\u0000' && LA1_1<='|')||(LA1_1>='~' && LA1_1<='\uFFFE')) ) {
                        alt1=1;
                    }


                }
                else if ( ((LA1_0>='\u0000' && LA1_0<='\"')||(LA1_0>='$' && LA1_0<='\uFFFE')) ) {
                    alt1=1;
                }


                switch (alt1) {
            	case 1 :
            	    // ioke.g:67:50: .
            	    {
            	    matchAny(); 

            	    }
            	    break;

            	default :
            	    break loop1;
                }
            } while (true);


            }

            match("#}"); 


            }

            skip();

            }

            this.type = _type;
        }
        finally {
        }
    }
    // $ANTLR end MultiComment

    // $ANTLR start NewlineComment
    public final void mNewlineComment() throws RecognitionException {
        try {
            int _type = NewlineComment;
            // ioke.g:68:16: ( '#' (~ NewLine )* ( NewLine )? )
            // ioke.g:68:18: '#' (~ NewLine )* ( NewLine )?
            {
            match('#'); 
            // ioke.g:68:22: (~ NewLine )*
            loop2:
            do {
                int alt2=2;
                int LA2_0 = input.LA(1);

                if ( ((LA2_0>='\u0000' && LA2_0<='\t')||(LA2_0>='\u000B' && LA2_0<='\f')||(LA2_0>='\u000E' && LA2_0<='\uFFFE')) ) {
                    alt2=1;
                }


                switch (alt2) {
            	case 1 :
            	    // ioke.g:68:24: ~ NewLine
            	    {
            	    if ( (input.LA(1)>='\u0000' && input.LA(1)<='\u0004')||(input.LA(1)>='\u0006' && input.LA(1)<='\uFFFE') ) {
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

            // ioke.g:68:36: ( NewLine )?
            int alt3=2;
            int LA3_0 = input.LA(1);

            if ( (LA3_0=='\n'||LA3_0=='\r') ) {
                alt3=1;
            }
            switch (alt3) {
                case 1 :
                    // ioke.g:68:36: NewLine
                    {
                    mNewLine(); 

                    }
                    break;

            }

            _type=PossibleTerminator;setText(";");

            }

            this.type = _type;
        }
        finally {
        }
    }
    // $ANTLR end NewlineComment

    // $ANTLR start OpenSimple
    public final void mOpenSimple() throws RecognitionException {
        try {
            int _type = OpenSimple;
            // ioke.g:70:12: ( '(' )
            // ioke.g:70:14: '('
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
            // ioke.g:71:13: ( ')' )
            // ioke.g:71:15: ')'
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
            // ioke.g:72:12: ( '[' )
            // ioke.g:72:14: '['
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
            // ioke.g:73:13: ( ']' )
            // ioke.g:73:15: ']'
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
            // ioke.g:74:11: ( '{' )
            // ioke.g:74:13: '{'
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
            // ioke.g:75:12: ( '}' )
            // ioke.g:75:14: '}'
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
            // ioke.g:77:7: ( ( ',' ( NewLine )* ) )
            // ioke.g:77:9: ( ',' ( NewLine )* )
            {
            // ioke.g:77:9: ( ',' ( NewLine )* )
            // ioke.g:77:10: ',' ( NewLine )*
            {
            match(','); 
            // ioke.g:77:14: ( NewLine )*
            loop4:
            do {
                int alt4=2;
                int LA4_0 = input.LA(1);

                if ( (LA4_0=='\n'||LA4_0=='\r') ) {
                    alt4=1;
                }


                switch (alt4) {
            	case 1 :
            	    // ioke.g:77:14: NewLine
            	    {
            	    mNewLine(); 

            	    }
            	    break;

            	default :
            	    break loop4;
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
            // ioke.g:79:12: ( ( '+' | '-' )? '0' ( 'x' | 'X' ) ( Digit | HexLetter )+ )
            // ioke.g:79:14: ( '+' | '-' )? '0' ( 'x' | 'X' ) ( Digit | HexLetter )+
            {
            // ioke.g:79:14: ( '+' | '-' )?
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

            match('0'); 
            if ( input.LA(1)=='X'||input.LA(1)=='x' ) {
                input.consume();

            }
            else {
                MismatchedSetException mse =
                    new MismatchedSetException(null,input);
                recover(mse);    throw mse;
            }

            // ioke.g:79:41: ( Digit | HexLetter )+
            int cnt6=0;
            loop6:
            do {
                int alt6=2;
                int LA6_0 = input.LA(1);

                if ( ((LA6_0>='0' && LA6_0<='9')||(LA6_0>='A' && LA6_0<='F')||(LA6_0>='a' && LA6_0<='f')) ) {
                    alt6=1;
                }


                switch (alt6) {
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
            	    if ( cnt6 >= 1 ) break loop6;
                        EarlyExitException eee =
                            new EarlyExitException(6, input);
                        throw eee;
                }
                cnt6++;
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
            // ioke.g:81:9: ( ( '+' | '-' )? Digits )
            // ioke.g:81:11: ( '+' | '-' )? Digits
            {
            // ioke.g:81:11: ( '+' | '-' )?
            int alt7=2;
            int LA7_0 = input.LA(1);

            if ( (LA7_0=='+'||LA7_0=='-') ) {
                alt7=1;
            }
            switch (alt7) {
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
            // ioke.g:84:5: ( ( '+' | '-' )? ( Digits '.' ( Digit )* ( Exponent )? | '.' Digits ( Exponent )? | Digits Exponent ) )
            // ioke.g:84:9: ( '+' | '-' )? ( Digits '.' ( Digit )* ( Exponent )? | '.' Digits ( Exponent )? | Digits Exponent )
            {
            // ioke.g:84:9: ( '+' | '-' )?
            int alt8=2;
            int LA8_0 = input.LA(1);

            if ( (LA8_0=='+'||LA8_0=='-') ) {
                alt8=1;
            }
            switch (alt8) {
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

            // ioke.g:85:9: ( Digits '.' ( Digit )* ( Exponent )? | '.' Digits ( Exponent )? | Digits Exponent )
            int alt12=3;
            alt12 = dfa12.predict(input);
            switch (alt12) {
                case 1 :
                    // ioke.g:85:10: Digits '.' ( Digit )* ( Exponent )?
                    {
                    mDigits(); 
                    match('.'); 
                    // ioke.g:85:21: ( Digit )*
                    loop9:
                    do {
                        int alt9=2;
                        int LA9_0 = input.LA(1);

                        if ( ((LA9_0>='0' && LA9_0<='9')) ) {
                            alt9=1;
                        }


                        switch (alt9) {
                    	case 1 :
                    	    // ioke.g:85:21: Digit
                    	    {
                    	    mDigit(); 

                    	    }
                    	    break;

                    	default :
                    	    break loop9;
                        }
                    } while (true);

                    // ioke.g:85:28: ( Exponent )?
                    int alt10=2;
                    int LA10_0 = input.LA(1);

                    if ( (LA10_0=='E'||LA10_0=='e') ) {
                        alt10=1;
                    }
                    switch (alt10) {
                        case 1 :
                            // ioke.g:85:28: Exponent
                            {
                            mExponent(); 

                            }
                            break;

                    }


                    }
                    break;
                case 2 :
                    // ioke.g:86:10: '.' Digits ( Exponent )?
                    {
                    match('.'); 
                    mDigits(); 
                    // ioke.g:86:21: ( Exponent )?
                    int alt11=2;
                    int LA11_0 = input.LA(1);

                    if ( (LA11_0=='E'||LA11_0=='e') ) {
                        alt11=1;
                    }
                    switch (alt11) {
                        case 1 :
                            // ioke.g:86:21: Exponent
                            {
                            mExponent(); 

                            }
                            break;

                    }


                    }
                    break;
                case 3 :
                    // ioke.g:87:10: Digits Exponent
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
            // ioke.g:90:20: ( ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<<' | '>>' | '&' | '&&' | '|' | '||' ) '=' )
            // ioke.g:91:9: ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<<' | '>>' | '&' | '&&' | '|' | '||' ) '='
            {
            // ioke.g:91:9: ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<<' | '>>' | '&' | '&&' | '|' | '||' )
            int alt13=18;
            switch ( input.LA(1) ) {
            case '+':
                {
                int LA13_1 = input.LA(2);

                if ( (LA13_1=='+') ) {
                    alt13=2;
                }
                else if ( (LA13_1=='=') ) {
                    alt13=1;
                }
                else {
                    NoViableAltException nvae =
                        new NoViableAltException("91:9: ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<<' | '>>' | '&' | '&&' | '|' | '||' )", 13, 1, input);

                    throw nvae;
                }
                }
                break;
            case '-':
                {
                int LA13_2 = input.LA(2);

                if ( (LA13_2=='-') ) {
                    alt13=4;
                }
                else if ( (LA13_2=='=') ) {
                    alt13=3;
                }
                else {
                    NoViableAltException nvae =
                        new NoViableAltException("91:9: ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<<' | '>>' | '&' | '&&' | '|' | '||' )", 13, 2, input);

                    throw nvae;
                }
                }
                break;
            case '/':
                {
                int LA13_3 = input.LA(2);

                if ( (LA13_3=='/') ) {
                    alt13=6;
                }
                else if ( (LA13_3=='=') ) {
                    alt13=5;
                }
                else {
                    NoViableAltException nvae =
                        new NoViableAltException("91:9: ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<<' | '>>' | '&' | '&&' | '|' | '||' )", 13, 3, input);

                    throw nvae;
                }
                }
                break;
            case '*':
                {
                int LA13_4 = input.LA(2);

                if ( (LA13_4=='*') ) {
                    alt13=8;
                }
                else if ( (LA13_4=='=') ) {
                    alt13=7;
                }
                else {
                    NoViableAltException nvae =
                        new NoViableAltException("91:9: ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<<' | '>>' | '&' | '&&' | '|' | '||' )", 13, 4, input);

                    throw nvae;
                }
                }
                break;
            case '%':
                {
                int LA13_5 = input.LA(2);

                if ( (LA13_5=='%') ) {
                    alt13=10;
                }
                else if ( (LA13_5=='=') ) {
                    alt13=9;
                }
                else {
                    NoViableAltException nvae =
                        new NoViableAltException("91:9: ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<<' | '>>' | '&' | '&&' | '|' | '||' )", 13, 5, input);

                    throw nvae;
                }
                }
                break;
            case '^':
                {
                int LA13_6 = input.LA(2);

                if ( (LA13_6=='^') ) {
                    alt13=12;
                }
                else if ( (LA13_6=='=') ) {
                    alt13=11;
                }
                else {
                    NoViableAltException nvae =
                        new NoViableAltException("91:9: ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<<' | '>>' | '&' | '&&' | '|' | '||' )", 13, 6, input);

                    throw nvae;
                }
                }
                break;
            case '<':
                {
                alt13=13;
                }
                break;
            case '>':
                {
                alt13=14;
                }
                break;
            case '&':
                {
                int LA13_9 = input.LA(2);

                if ( (LA13_9=='&') ) {
                    alt13=16;
                }
                else if ( (LA13_9=='=') ) {
                    alt13=15;
                }
                else {
                    NoViableAltException nvae =
                        new NoViableAltException("91:9: ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<<' | '>>' | '&' | '&&' | '|' | '||' )", 13, 9, input);

                    throw nvae;
                }
                }
                break;
            case '|':
                {
                int LA13_10 = input.LA(2);

                if ( (LA13_10=='|') ) {
                    alt13=18;
                }
                else if ( (LA13_10=='=') ) {
                    alt13=17;
                }
                else {
                    NoViableAltException nvae =
                        new NoViableAltException("91:9: ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<<' | '>>' | '&' | '&&' | '|' | '||' )", 13, 10, input);

                    throw nvae;
                }
                }
                break;
            default:
                NoViableAltException nvae =
                    new NoViableAltException("91:9: ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<<' | '>>' | '&' | '&&' | '|' | '||' )", 13, 0, input);

                throw nvae;
            }

            switch (alt13) {
                case 1 :
                    // ioke.g:91:10: '+'
                    {
                    match('+'); 

                    }
                    break;
                case 2 :
                    // ioke.g:92:11: '++'
                    {
                    match("++"); 


                    }
                    break;
                case 3 :
                    // ioke.g:93:11: '-'
                    {
                    match('-'); 

                    }
                    break;
                case 4 :
                    // ioke.g:94:11: '--'
                    {
                    match("--"); 


                    }
                    break;
                case 5 :
                    // ioke.g:95:11: '/'
                    {
                    match('/'); 

                    }
                    break;
                case 6 :
                    // ioke.g:96:11: '//'
                    {
                    match("//"); 


                    }
                    break;
                case 7 :
                    // ioke.g:97:11: '*'
                    {
                    match('*'); 

                    }
                    break;
                case 8 :
                    // ioke.g:98:11: '**'
                    {
                    match("**"); 


                    }
                    break;
                case 9 :
                    // ioke.g:99:11: '%'
                    {
                    match('%'); 

                    }
                    break;
                case 10 :
                    // ioke.g:100:11: '%%'
                    {
                    match("%%"); 


                    }
                    break;
                case 11 :
                    // ioke.g:101:11: '^'
                    {
                    match('^'); 

                    }
                    break;
                case 12 :
                    // ioke.g:102:11: '^^'
                    {
                    match("^^"); 


                    }
                    break;
                case 13 :
                    // ioke.g:103:11: '<<'
                    {
                    match("<<"); 


                    }
                    break;
                case 14 :
                    // ioke.g:104:11: '>>'
                    {
                    match(">>"); 


                    }
                    break;
                case 15 :
                    // ioke.g:105:11: '&'
                    {
                    match('&'); 

                    }
                    break;
                case 16 :
                    // ioke.g:106:11: '&&'
                    {
                    match("&&"); 


                    }
                    break;
                case 17 :
                    // ioke.g:107:11: '|'
                    {
                    match('|'); 

                    }
                    break;
                case 18 :
                    // ioke.g:108:11: '||'
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
            // ioke.g:111:15: ( '@' | '@@' | '\\'' | '`' | '!' | ':' | 'return' )
            int alt14=7;
            switch ( input.LA(1) ) {
            case '@':
                {
                int LA14_1 = input.LA(2);

                if ( (LA14_1=='@') ) {
                    alt14=2;
                }
                else {
                    alt14=1;}
                }
                break;
            case '\'':
                {
                alt14=3;
                }
                break;
            case '`':
                {
                alt14=4;
                }
                break;
            case '!':
                {
                alt14=5;
                }
                break;
            case ':':
                {
                alt14=6;
                }
                break;
            case 'r':
                {
                alt14=7;
                }
                break;
            default:
                NoViableAltException nvae =
                    new NoViableAltException("111:1: UnaryOperator : ( '@' | '@@' | '\\'' | '`' | '!' | ':' | 'return' );", 14, 0, input);

                throw nvae;
            }

            switch (alt14) {
                case 1 :
                    // ioke.g:112:7: '@'
                    {
                    match('@'); 

                    }
                    break;
                case 2 :
                    // ioke.g:113:7: '@@'
                    {
                    match("@@"); 


                    }
                    break;
                case 3 :
                    // ioke.g:114:7: '\\''
                    {
                    match('\''); 

                    }
                    break;
                case 4 :
                    // ioke.g:115:7: '`'
                    {
                    match('`'); 

                    }
                    break;
                case 5 :
                    // ioke.g:116:7: '!'
                    {
                    match('!'); 

                    }
                    break;
                case 6 :
                    // ioke.g:117:7: ':'
                    {
                    match(':'); 

                    }
                    break;
                case 7 :
                    // ioke.g:118:7: 'return'
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
            // ioke.g:121:16: ( ( OpChars )+ | '==' | '===' | '====' | '<=' | '>=' | '~=' | '~~=' | '!=' | '!!=' | 'and' | 'or' )
            int alt16=12;
            switch ( input.LA(1) ) {
            case '<':
                {
                int LA16_1 = input.LA(2);

                if ( (LA16_1=='=') ) {
                    alt16=5;
                }
                else {
                    alt16=1;}
                }
                break;
            case '=':
                {
                int LA16_2 = input.LA(2);

                if ( (LA16_2=='=') ) {
                    int LA16_10 = input.LA(3);

                    if ( (LA16_10=='=') ) {
                        int LA16_16 = input.LA(4);

                        if ( (LA16_16=='=') ) {
                            alt16=4;
                        }
                        else {
                            alt16=3;}
                    }
                    else {
                        alt16=2;}
                }
                else {
                    NoViableAltException nvae =
                        new NoViableAltException("121:1: BinaryOperator : ( ( OpChars )+ | '==' | '===' | '====' | '<=' | '>=' | '~=' | '~~=' | '!=' | '!!=' | 'and' | 'or' );", 16, 2, input);

                    throw nvae;
                }
                }
                break;
            case '>':
                {
                int LA16_3 = input.LA(2);

                if ( (LA16_3=='=') ) {
                    alt16=6;
                }
                else {
                    alt16=1;}
                }
                break;
            case '~':
                {
                switch ( input.LA(2) ) {
                case '=':
                    {
                    alt16=7;
                    }
                    break;
                case '~':
                    {
                    int LA16_13 = input.LA(3);

                    if ( (LA16_13=='=') ) {
                        alt16=8;
                    }
                    else {
                        alt16=1;}
                    }
                    break;
                default:
                    alt16=1;}

                }
                break;
            case '!':
                {
                switch ( input.LA(2) ) {
                case '=':
                    {
                    alt16=9;
                    }
                    break;
                case '!':
                    {
                    int LA16_15 = input.LA(3);

                    if ( (LA16_15=='=') ) {
                        alt16=10;
                    }
                    else {
                        alt16=1;}
                    }
                    break;
                default:
                    alt16=1;}

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
                alt16=1;
                }
                break;
            case 'a':
                {
                alt16=11;
                }
                break;
            case 'o':
                {
                alt16=12;
                }
                break;
            default:
                NoViableAltException nvae =
                    new NoViableAltException("121:1: BinaryOperator : ( ( OpChars )+ | '==' | '===' | '====' | '<=' | '>=' | '~=' | '~~=' | '!=' | '!!=' | 'and' | 'or' );", 16, 0, input);

                throw nvae;
            }

            switch (alt16) {
                case 1 :
                    // ioke.g:122:7: ( OpChars )+
                    {
                    // ioke.g:122:7: ( OpChars )+
                    int cnt15=0;
                    loop15:
                    do {
                        int alt15=2;
                        int LA15_0 = input.LA(1);

                        if ( (LA15_0=='!'||(LA15_0>='%' && LA15_0<='\'')||(LA15_0>='*' && LA15_0<='+')||(LA15_0>='-' && LA15_0<='/')||LA15_0==':'||LA15_0=='<'||(LA15_0>='>' && LA15_0<='@')||LA15_0=='\\'||(LA15_0>='^' && LA15_0<='`')||LA15_0=='|'||LA15_0=='~') ) {
                            alt15=1;
                        }


                        switch (alt15) {
                    	case 1 :
                    	    // ioke.g:122:7: OpChars
                    	    {
                    	    mOpChars(); 

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
                    break;
                case 2 :
                    // ioke.g:123:7: '=='
                    {
                    match("=="); 


                    }
                    break;
                case 3 :
                    // ioke.g:124:7: '==='
                    {
                    match("==="); 


                    }
                    break;
                case 4 :
                    // ioke.g:125:7: '===='
                    {
                    match("===="); 


                    }
                    break;
                case 5 :
                    // ioke.g:126:7: '<='
                    {
                    match("<="); 


                    }
                    break;
                case 6 :
                    // ioke.g:127:7: '>='
                    {
                    match(">="); 


                    }
                    break;
                case 7 :
                    // ioke.g:128:7: '~='
                    {
                    match("~="); 


                    }
                    break;
                case 8 :
                    // ioke.g:129:7: '~~='
                    {
                    match("~~="); 


                    }
                    break;
                case 9 :
                    // ioke.g:130:7: '!='
                    {
                    match("!="); 


                    }
                    break;
                case 10 :
                    // ioke.g:131:7: '!!='
                    {
                    match("!!="); 


                    }
                    break;
                case 11 :
                    // ioke.g:132:7: 'and'
                    {
                    match("and"); 


                    }
                    break;
                case 12 :
                    // ioke.g:133:7: 'or'
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
            // ioke.g:136:12: ( '=' )
            // ioke.g:136:14: '='
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
            // ioke.g:138:12: ( IdentStart ( IdentChars )* )
            // ioke.g:138:14: IdentStart ( IdentChars )*
            {
            mIdentStart(); 
            // ioke.g:138:25: ( IdentChars )*
            loop17:
            do {
                int alt17=2;
                int LA17_0 = input.LA(1);

                if ( (LA17_0=='!'||(LA17_0>='%' && LA17_0<='\'')||(LA17_0>='*' && LA17_0<='+')||(LA17_0>='-' && LA17_0<=':')||LA17_0=='<'||(LA17_0>='>' && LA17_0<='Z')||LA17_0=='\\'||(LA17_0>='^' && LA17_0<='z')||LA17_0=='|'||LA17_0=='~') ) {
                    alt17=1;
                }


                switch (alt17) {
            	case 1 :
            	    // ioke.g:138:25: IdentChars
            	    {
            	    mIdentChars(); 

            	    }
            	    break;

            	default :
            	    break loop17;
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
            // ioke.g:140:20: ( ( ( ';' | NewLine )+ ) )
            // ioke.g:140:22: ( ( ';' | NewLine )+ )
            {
            // ioke.g:140:22: ( ( ';' | NewLine )+ )
            // ioke.g:140:23: ( ';' | NewLine )+
            {
            // ioke.g:140:23: ( ';' | NewLine )+
            int cnt18=0;
            loop18:
            do {
                int alt18=2;
                int LA18_0 = input.LA(1);

                if ( (LA18_0=='\n'||LA18_0=='\r'||LA18_0==';') ) {
                    alt18=1;
                }


                switch (alt18) {
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
            	    if ( cnt18 >= 1 ) break loop18;
                        EarlyExitException eee =
                            new EarlyExitException(18, input);
                        throw eee;
                }
                cnt18++;
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
            // ioke.g:142:12: ( Separator )
            // ioke.g:142:14: Separator
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
            // ioke.g:146:10: ( ( 'e' | 'E' ) ( '+' | '-' )? Digits )
            // ioke.g:146:12: ( 'e' | 'E' ) ( '+' | '-' )? Digits
            {
            if ( input.LA(1)=='E'||input.LA(1)=='e' ) {
                input.consume();

            }
            else {
                MismatchedSetException mse =
                    new MismatchedSetException(null,input);
                recover(mse);    throw mse;
            }

            // ioke.g:146:22: ( '+' | '-' )?
            int alt19=2;
            int LA19_0 = input.LA(1);

            if ( (LA19_0=='+'||LA19_0=='-') ) {
                alt19=1;
            }
            switch (alt19) {
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
            // ioke.g:149:8: ( 'a' .. 'z' | 'A' .. 'Z' )
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
            // ioke.g:152:7: ( '0' .. '9' )
            // ioke.g:152:9: '0' .. '9'
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
            // ioke.g:155:8: ( ( Digit )+ )
            // ioke.g:155:10: ( Digit )+
            {
            // ioke.g:155:10: ( Digit )+
            int cnt20=0;
            loop20:
            do {
                int alt20=2;
                int LA20_0 = input.LA(1);

                if ( ((LA20_0>='0' && LA20_0<='9')) ) {
                    alt20=1;
                }


                switch (alt20) {
            	case 1 :
            	    // ioke.g:155:10: Digit
            	    {
            	    mDigit(); 

            	    }
            	    break;

            	default :
            	    if ( cnt20 >= 1 ) break loop20;
                        EarlyExitException eee =
                            new EarlyExitException(20, input);
                        throw eee;
                }
                cnt20++;
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
            // ioke.g:158:11: ( 'a' .. 'f' | 'A' .. 'F' )
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
            // ioke.g:161:11: ( ( ' ' | '\\u000c' | '\\u0009' | '\\u000b' | '\\\\' '\\u000a' )+ )
            // ioke.g:161:13: ( ' ' | '\\u000c' | '\\u0009' | '\\u000b' | '\\\\' '\\u000a' )+
            {
            // ioke.g:161:13: ( ' ' | '\\u000c' | '\\u0009' | '\\u000b' | '\\\\' '\\u000a' )+
            int cnt21=0;
            loop21:
            do {
                int alt21=6;
                switch ( input.LA(1) ) {
                case ' ':
                    {
                    alt21=1;
                    }
                    break;
                case '\f':
                    {
                    alt21=2;
                    }
                    break;
                case '\t':
                    {
                    alt21=3;
                    }
                    break;
                case '\u000B':
                    {
                    alt21=4;
                    }
                    break;
                case '\\':
                    {
                    alt21=5;
                    }
                    break;

                }

                switch (alt21) {
            	case 1 :
            	    // ioke.g:161:14: ' '
            	    {
            	    match(' '); 

            	    }
            	    break;
            	case 2 :
            	    // ioke.g:161:20: '\\u000c'
            	    {
            	    match('\f'); 

            	    }
            	    break;
            	case 3 :
            	    // ioke.g:161:31: '\\u0009'
            	    {
            	    match('\t'); 

            	    }
            	    break;
            	case 4 :
            	    // ioke.g:161:42: '\\u000b'
            	    {
            	    match('\u000B'); 

            	    }
            	    break;
            	case 5 :
            	    // ioke.g:161:53: '\\\\' '\\u000a'
            	    {
            	    match('\\'); 
            	    match('\n'); 

            	    }
            	    break;

            	default :
            	    if ( cnt21 >= 1 ) break loop21;
                        EarlyExitException eee =
                            new EarlyExitException(21, input);
                        throw eee;
                }
                cnt21++;
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
            // ioke.g:164:9: ( ( '!' | '?' | '@' | '&' | '%' | '.' | '|' | '<' | '>' | '/' | '+' | '-' | '_' | ':' | '\\\\' | '*' | '^' | '~' | '`' | '\\'' ) )
            // ioke.g:164:11: ( '!' | '?' | '@' | '&' | '%' | '.' | '|' | '<' | '>' | '/' | '+' | '-' | '_' | ':' | '\\\\' | '*' | '^' | '~' | '`' | '\\'' )
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
            // ioke.g:167:12: ( Letter | Digit | ( '!' | '?' | '@' | '&' | '%' | '.' | '|' | '<' | '>' | '/' | '+' | '-' | '_' | ':' | '\\\\' | '*' | '^' | '~' | '`' | '\\'' ) )
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
            // ioke.g:170:12: ( Letter | Digit | ( '?' | '&' | '%' | '|' | '<' | '>' | '/' | '+' | '-' | '_' | '\\\\' | '*' | '^' | '~' ) )
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
            // ioke.g:173:9: ( ( '\\u000a' | '\\u000d' ) )
            // ioke.g:173:11: ( '\\u000a' | '\\u000d' )
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
        // ioke.g:1:8: ( MultiComment | NewlineComment | OpenSimple | CloseSimple | OpenSquare | CloseSquare | OpenCurly | CloseCurly | Comma | HexInteger | Integer | Real | AssignmentOperator | UnaryOperator | BinaryOperator | Assignment | Identifier | PossibleTerminator | Whitespace )
        int alt22=19;
        alt22 = dfa22.predict(input);
        switch (alt22) {
            case 1 :
                // ioke.g:1:10: MultiComment
                {
                mMultiComment(); 

                }
                break;
            case 2 :
                // ioke.g:1:23: NewlineComment
                {
                mNewlineComment(); 

                }
                break;
            case 3 :
                // ioke.g:1:38: OpenSimple
                {
                mOpenSimple(); 

                }
                break;
            case 4 :
                // ioke.g:1:49: CloseSimple
                {
                mCloseSimple(); 

                }
                break;
            case 5 :
                // ioke.g:1:61: OpenSquare
                {
                mOpenSquare(); 

                }
                break;
            case 6 :
                // ioke.g:1:72: CloseSquare
                {
                mCloseSquare(); 

                }
                break;
            case 7 :
                // ioke.g:1:84: OpenCurly
                {
                mOpenCurly(); 

                }
                break;
            case 8 :
                // ioke.g:1:94: CloseCurly
                {
                mCloseCurly(); 

                }
                break;
            case 9 :
                // ioke.g:1:105: Comma
                {
                mComma(); 

                }
                break;
            case 10 :
                // ioke.g:1:111: HexInteger
                {
                mHexInteger(); 

                }
                break;
            case 11 :
                // ioke.g:1:122: Integer
                {
                mInteger(); 

                }
                break;
            case 12 :
                // ioke.g:1:130: Real
                {
                mReal(); 

                }
                break;
            case 13 :
                // ioke.g:1:135: AssignmentOperator
                {
                mAssignmentOperator(); 

                }
                break;
            case 14 :
                // ioke.g:1:154: UnaryOperator
                {
                mUnaryOperator(); 

                }
                break;
            case 15 :
                // ioke.g:1:168: BinaryOperator
                {
                mBinaryOperator(); 

                }
                break;
            case 16 :
                // ioke.g:1:183: Assignment
                {
                mAssignment(); 

                }
                break;
            case 17 :
                // ioke.g:1:194: Identifier
                {
                mIdentifier(); 

                }
                break;
            case 18 :
                // ioke.g:1:205: PossibleTerminator
                {
                mPossibleTerminator(); 

                }
                break;
            case 19 :
                // ioke.g:1:224: Whitespace
                {
                mWhitespace(); 

                }
                break;

        }

    }


    protected DFA12 dfa12 = new DFA12(this);
    protected DFA22 dfa22 = new DFA22(this);
    static final String DFA12_eotS =
        "\5\uffff";
    static final String DFA12_eofS =
        "\5\uffff";
    static final String DFA12_minS =
        "\2\56\3\uffff";
    static final String DFA12_maxS =
        "\1\71\1\145\3\uffff";
    static final String DFA12_acceptS =
        "\2\uffff\1\2\1\3\1\1";
    static final String DFA12_specialS =
        "\5\uffff}>";
    static final String[] DFA12_transitionS = {
            "\1\2\1\uffff\12\1",
            "\1\4\1\uffff\12\1\13\uffff\1\3\37\uffff\1\3",
            "",
            "",
            ""
    };

    static final short[] DFA12_eot = DFA.unpackEncodedString(DFA12_eotS);
    static final short[] DFA12_eof = DFA.unpackEncodedString(DFA12_eofS);
    static final char[] DFA12_min = DFA.unpackEncodedStringToUnsignedChars(DFA12_minS);
    static final char[] DFA12_max = DFA.unpackEncodedStringToUnsignedChars(DFA12_maxS);
    static final short[] DFA12_accept = DFA.unpackEncodedString(DFA12_acceptS);
    static final short[] DFA12_special = DFA.unpackEncodedString(DFA12_specialS);
    static final short[][] DFA12_transition;

    static {
        int numStates = DFA12_transitionS.length;
        DFA12_transition = new short[numStates][];
        for (int i=0; i<numStates; i++) {
            DFA12_transition[i] = DFA.unpackEncodedString(DFA12_transitionS[i]);
        }
    }

    class DFA12 extends DFA {

        public DFA12(BaseRecognizer recognizer) {
            this.recognizer = recognizer;
            this.decisionNumber = 12;
            this.eot = DFA12_eot;
            this.eof = DFA12_eof;
            this.min = DFA12_min;
            this.max = DFA12_max;
            this.accept = DFA12_accept;
            this.special = DFA12_special;
            this.transition = DFA12_transition;
        }
        public String getDescription() {
            return "85:9: ( Digits '.' ( Digit )* ( Exponent )? | '.' Digits ( Exponent )? | Digits Exponent )";
        }
    }
    static final String DFA22_eotS =
        "\1\uffff\1\46\7\uffff\1\53\2\57\12\53\5\75\1\41\1\53\1\100\1\53"+
        "\2\41\3\uffff\1\53\2\uffff\1\53\2\57\1\53\1\uffff\1\53\1\uffff\1"+
        "\41\1\uffff\1\41\1\62\1\uffff\11\53\1\75\1\uffff\1\41\1\53\1\uffff"+
        "\1\41\1\53\1\62\1\114\1\41\2\62\2\41\1\53\1\41\1\uffff\1\41\1\62"+
        "\2\41\1\62\1\41\1\75";
    static final String DFA22_eofS =
        "\124\uffff";
    static final String DFA22_minS =
        "\1\11\1\43\7\uffff\3\41\1\60\16\41\1\145\1\41\1\75\1\12\1\156\1"+
        "\162\3\uffff\1\41\2\uffff\4\41\1\uffff\1\41\1\uffff\1\60\1\uffff"+
        "\1\53\1\41\1\uffff\12\41\1\uffff\1\164\1\41\1\uffff\1\144\3\41\1"+
        "\60\2\41\1\53\1\165\1\41\1\53\1\uffff\1\60\1\41\1\162\1\60\1\41"+
        "\1\156\1\41";
    static final String DFA22_maxS =
        "\1\176\1\43\7\uffff\3\176\1\71\16\176\1\145\1\176\1\75\1\176\1\156"+
        "\1\162\3\uffff\1\176\2\uffff\4\176\1\uffff\1\176\1\uffff\1\146\1"+
        "\uffff\1\71\1\176\1\uffff\12\176\1\uffff\1\164\1\176\1\uffff\1\144"+
        "\3\176\1\71\2\176\1\71\1\165\1\176\1\71\1\uffff\1\71\1\176\1\162"+
        "\1\71\1\176\1\156\1\176";
    static final String DFA22_acceptS =
        "\2\uffff\1\2\1\3\1\4\1\5\1\6\1\10\1\11\30\uffff\1\21\1\22\1\23\1"+
        "\uffff\1\1\1\7\4\uffff\1\17\1\uffff\1\15\1\uffff\1\13\2\uffff\1"+
        "\14\12\uffff\1\16\2\uffff\1\20\13\uffff\1\12\7\uffff";
    static final String DFA22_specialS =
        "\124\uffff}>";
    static final String[] DFA22_transitionS = {
            "\1\43\1\42\2\43\1\42\22\uffff\1\43\1\31\1\uffff\1\2\1\uffff"+
            "\1\20\1\24\1\27\1\3\1\4\1\17\1\11\1\10\1\15\1\14\1\16\1\12\11"+
            "\13\1\32\1\42\1\22\1\35\1\23\1\44\1\26\32\41\1\5\1\36\1\6\1"+
            "\21\1\44\1\30\1\37\15\41\1\40\2\41\1\33\10\41\1\1\1\25\1\7\1"+
            "\34",
            "\1\45",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "\1\54\3\uffff\3\54\2\uffff\1\54\1\47\1\uffff\1\54\1\52\1\54"+
            "\1\50\11\51\1\54\1\uffff\1\54\1\55\3\54\32\41\1\uffff\1\54\1"+
            "\uffff\3\54\32\41\1\uffff\1\54\1\uffff\1\54",
            "\1\41\3\uffff\3\41\2\uffff\2\41\1\uffff\1\41\1\61\1\41\12\51"+
            "\1\41\1\uffff\1\41\1\uffff\7\41\1\60\22\41\1\56\2\41\1\uffff"+
            "\1\41\1\uffff\7\41\1\60\22\41\1\56\2\41\1\uffff\1\41\1\uffff"+
            "\1\41",
            "\1\41\3\uffff\3\41\2\uffff\2\41\1\uffff\1\41\1\61\1\41\12\51"+
            "\1\41\1\uffff\1\41\1\uffff\7\41\1\60\25\41\1\uffff\1\41\1\uffff"+
            "\7\41\1\60\25\41\1\uffff\1\41\1\uffff\1\41",
            "\12\62",
            "\1\54\3\uffff\3\54\2\uffff\2\54\1\uffff\1\63\1\52\1\54\1\50"+
            "\11\51\1\54\1\uffff\1\54\1\55\3\54\32\41\1\uffff\1\54\1\uffff"+
            "\3\54\32\41\1\uffff\1\54\1\uffff\1\54",
            "\1\54\3\uffff\3\54\2\uffff\2\54\1\uffff\2\54\1\64\12\41\1\54"+
            "\1\uffff\1\54\1\55\3\54\32\41\1\uffff\1\54\1\uffff\3\54\32\41"+
            "\1\uffff\1\54\1\uffff\1\54",
            "\1\54\3\uffff\3\54\2\uffff\1\65\1\54\1\uffff\3\54\12\41\1\54"+
            "\1\uffff\1\54\1\55\3\54\32\41\1\uffff\1\54\1\uffff\3\54\32\41"+
            "\1\uffff\1\54\1\uffff\1\54",
            "\1\54\3\uffff\1\66\2\54\2\uffff\2\54\1\uffff\3\54\12\41\1\54"+
            "\1\uffff\1\54\1\55\3\54\32\41\1\uffff\1\54\1\uffff\3\54\32\41"+
            "\1\uffff\1\54\1\uffff\1\54",
            "\1\54\3\uffff\3\54\2\uffff\2\54\1\uffff\3\54\12\41\1\54\1\uffff"+
            "\1\54\1\55\3\54\32\41\1\uffff\1\54\1\uffff\1\67\2\54\32\41\1"+
            "\uffff\1\54\1\uffff\1\54",
            "\1\54\3\uffff\3\54\2\uffff\2\54\1\uffff\3\54\12\41\1\54\1\uffff"+
            "\1\70\1\uffff\3\54\32\41\1\uffff\1\54\1\uffff\3\54\32\41\1\uffff"+
            "\1\54\1\uffff\1\54",
            "\1\54\3\uffff\3\54\2\uffff\2\54\1\uffff\3\54\12\41\1\54\1\uffff"+
            "\1\54\1\uffff\1\71\2\54\32\41\1\uffff\1\54\1\uffff\3\54\32\41"+
            "\1\uffff\1\54\1\uffff\1\54",
            "\1\54\3\uffff\1\54\1\72\1\54\2\uffff\2\54\1\uffff\3\54\12\41"+
            "\1\54\1\uffff\1\54\1\55\3\54\32\41\1\uffff\1\54\1\uffff\3\54"+
            "\32\41\1\uffff\1\54\1\uffff\1\54",
            "\1\54\3\uffff\3\54\2\uffff\2\54\1\uffff\3\54\12\41\1\54\1\uffff"+
            "\1\54\1\55\3\54\32\41\1\uffff\1\54\1\uffff\3\54\32\41\1\uffff"+
            "\1\73\1\uffff\1\54",
            "\1\53\3\uffff\3\53\2\uffff\2\53\1\uffff\3\53\12\uffff\1\53\1"+
            "\uffff\1\53\1\uffff\2\53\1\74\33\uffff\1\53\1\uffff\3\53\33"+
            "\uffff\1\53\1\uffff\1\53",
            "\1\53\3\uffff\3\53\2\uffff\2\53\1\uffff\3\53\12\uffff\1\53\1"+
            "\uffff\1\53\1\uffff\3\53\33\uffff\1\53\1\uffff\3\53\33\uffff"+
            "\1\53\1\uffff\1\53",
            "\1\53\3\uffff\3\53\2\uffff\2\53\1\uffff\3\53\12\uffff\1\53\1"+
            "\uffff\1\53\1\uffff\3\53\33\uffff\1\53\1\uffff\3\53\33\uffff"+
            "\1\53\1\uffff\1\53",
            "\1\53\3\uffff\3\53\2\uffff\2\53\1\uffff\3\53\12\uffff\1\53\1"+
            "\uffff\5\53\33\uffff\1\53\1\uffff\3\53\33\uffff\1\53\1\uffff"+
            "\1\53",
            "\1\53\3\uffff\3\53\2\uffff\2\53\1\uffff\3\53\12\uffff\1\53\1"+
            "\uffff\1\53\1\uffff\3\53\33\uffff\1\53\1\uffff\3\53\33\uffff"+
            "\1\53\1\uffff\1\53",
            "\1\76",
            "\1\54\3\uffff\3\54\2\uffff\2\54\1\uffff\3\54\12\41\1\54\1\uffff"+
            "\1\54\1\uffff\3\54\32\41\1\uffff\1\54\1\uffff\3\54\32\41\1\uffff"+
            "\1\54\1\uffff\1\77",
            "\1\53",
            "\1\43\26\uffff\1\54\3\uffff\3\54\2\uffff\2\54\1\uffff\3\54\12"+
            "\41\1\54\1\uffff\1\54\1\uffff\3\54\32\41\1\uffff\1\54\1\uffff"+
            "\3\54\32\41\1\uffff\1\54\1\uffff\1\54",
            "\1\101",
            "\1\102",
            "",
            "",
            "",
            "\1\54\3\uffff\3\54\2\uffff\2\54\1\uffff\3\54\12\41\1\54\1\uffff"+
            "\1\54\1\uffff\3\54\32\41\1\uffff\1\54\1\uffff\3\54\32\41\1\uffff"+
            "\1\54\1\uffff\1\54",
            "",
            "",
            "\1\54\3\uffff\3\54\2\uffff\2\54\1\uffff\3\54\12\41\1\54\1\uffff"+
            "\1\54\1\55\3\54\32\41\1\uffff\1\54\1\uffff\3\54\32\41\1\uffff"+
            "\1\54\1\uffff\1\54",
            "\1\41\3\uffff\3\41\2\uffff\2\41\1\uffff\1\41\1\61\1\41\12\51"+
            "\1\41\1\uffff\1\41\1\uffff\7\41\1\60\22\41\1\56\2\41\1\uffff"+
            "\1\41\1\uffff\7\41\1\60\22\41\1\56\2\41\1\uffff\1\41\1\uffff"+
            "\1\41",
            "\1\41\3\uffff\3\41\2\uffff\2\41\1\uffff\1\41\1\61\1\41\12\51"+
            "\1\41\1\uffff\1\41\1\uffff\7\41\1\60\25\41\1\uffff\1\41\1\uffff"+
            "\7\41\1\60\25\41\1\uffff\1\41\1\uffff\1\41",
            "\1\54\3\uffff\3\54\2\uffff\2\54\1\uffff\3\54\12\103\1\54\1\uffff"+
            "\1\54\1\uffff\3\54\32\41\1\uffff\1\54\1\uffff\3\54\32\41\1\uffff"+
            "\1\54\1\uffff\1\54",
            "",
            "\1\54\3\uffff\3\54\2\uffff\2\54\1\uffff\3\54\12\41\1\54\1\uffff"+
            "\1\54\1\uffff\3\54\32\41\1\uffff\1\54\1\uffff\3\54\32\41\1\uffff"+
            "\1\54\1\uffff\1\54",
            "",
            "\12\104\7\uffff\6\104\32\uffff\6\104",
            "",
            "\1\105\1\uffff\1\105\2\uffff\12\106",
            "\1\41\3\uffff\3\41\2\uffff\2\41\1\uffff\3\41\12\107\1\41\1\uffff"+
            "\1\41\1\uffff\7\41\1\110\25\41\1\uffff\1\41\1\uffff\7\41\1\110"+
            "\25\41\1\uffff\1\41\1\uffff\1\41",
            "",
            "\1\54\3\uffff\3\54\2\uffff\2\54\1\uffff\3\54\12\41\1\54\1\uffff"+
            "\1\54\1\55\3\54\32\41\1\uffff\1\54\1\uffff\3\54\32\41\1\uffff"+
            "\1\54\1\uffff\1\54",
            "\1\54\3\uffff\3\54\2\uffff\2\54\1\uffff\3\54\12\41\1\54\1\uffff"+
            "\1\54\1\55\3\54\32\41\1\uffff\1\54\1\uffff\3\54\32\41\1\uffff"+
            "\1\54\1\uffff\1\54",
            "\1\54\3\uffff\3\54\2\uffff\2\54\1\uffff\3\54\12\41\1\54\1\uffff"+
            "\1\54\1\55\3\54\32\41\1\uffff\1\54\1\uffff\3\54\32\41\1\uffff"+
            "\1\54\1\uffff\1\54",
            "\1\54\3\uffff\3\54\2\uffff\2\54\1\uffff\3\54\12\41\1\54\1\uffff"+
            "\1\54\1\55\3\54\32\41\1\uffff\1\54\1\uffff\3\54\32\41\1\uffff"+
            "\1\54\1\uffff\1\54",
            "\1\54\3\uffff\3\54\2\uffff\2\54\1\uffff\3\54\12\41\1\54\1\uffff"+
            "\1\54\1\55\3\54\32\41\1\uffff\1\54\1\uffff\3\54\32\41\1\uffff"+
            "\1\54\1\uffff\1\54",
            "\1\54\3\uffff\3\54\2\uffff\2\54\1\uffff\3\54\12\41\1\54\1\uffff"+
            "\1\54\1\55\3\54\32\41\1\uffff\1\54\1\uffff\3\54\32\41\1\uffff"+
            "\1\54\1\uffff\1\54",
            "\1\54\3\uffff\3\54\2\uffff\2\54\1\uffff\3\54\12\41\1\54\1\uffff"+
            "\1\54\1\55\3\54\32\41\1\uffff\1\54\1\uffff\3\54\32\41\1\uffff"+
            "\1\54\1\uffff\1\54",
            "\1\54\3\uffff\3\54\2\uffff\2\54\1\uffff\3\54\12\41\1\54\1\uffff"+
            "\1\54\1\55\3\54\32\41\1\uffff\1\54\1\uffff\3\54\32\41\1\uffff"+
            "\1\54\1\uffff\1\54",
            "\1\54\3\uffff\3\54\2\uffff\2\54\1\uffff\3\54\12\41\1\54\1\uffff"+
            "\1\54\1\55\3\54\32\41\1\uffff\1\54\1\uffff\3\54\32\41\1\uffff"+
            "\1\54\1\uffff\1\54",
            "\1\53\3\uffff\3\53\2\uffff\2\53\1\uffff\3\53\12\uffff\1\53\1"+
            "\uffff\1\53\1\uffff\3\53\33\uffff\1\53\1\uffff\3\53\33\uffff"+
            "\1\53\1\uffff\1\53",
            "",
            "\1\111",
            "\1\54\3\uffff\3\54\2\uffff\2\54\1\uffff\3\54\12\41\1\54\1\uffff"+
            "\1\54\1\uffff\3\54\32\41\1\uffff\1\54\1\uffff\3\54\32\41\1\uffff"+
            "\1\54\1\uffff\1\54",
            "",
            "\1\112",
            "\1\41\3\uffff\3\41\2\uffff\2\41\1\uffff\16\41\1\uffff\1\41\1"+
            "\uffff\35\41\1\uffff\1\41\1\uffff\35\41\1\uffff\1\41\1\uffff"+
            "\1\41",
            "\1\41\3\uffff\3\41\2\uffff\2\41\1\uffff\3\41\12\103\1\41\1\uffff"+
            "\1\41\1\uffff\7\41\1\113\25\41\1\uffff\1\41\1\uffff\7\41\1\113"+
            "\25\41\1\uffff\1\41\1\uffff\1\41",
            "\1\41\3\uffff\3\41\2\uffff\2\41\1\uffff\3\41\12\104\1\41\1\uffff"+
            "\1\41\1\uffff\3\41\6\104\24\41\1\uffff\1\41\1\uffff\3\41\6\104"+
            "\24\41\1\uffff\1\41\1\uffff\1\41",
            "\12\106",
            "\1\41\3\uffff\3\41\2\uffff\2\41\1\uffff\3\41\12\106\1\41\1\uffff"+
            "\1\41\1\uffff\35\41\1\uffff\1\41\1\uffff\35\41\1\uffff\1\41"+
            "\1\uffff\1\41",
            "\1\41\3\uffff\3\41\2\uffff\2\41\1\uffff\3\41\12\107\1\41\1\uffff"+
            "\1\41\1\uffff\7\41\1\110\25\41\1\uffff\1\41\1\uffff\7\41\1\110"+
            "\25\41\1\uffff\1\41\1\uffff\1\41",
            "\1\115\1\uffff\1\115\2\uffff\12\116",
            "\1\117",
            "\1\41\3\uffff\3\41\2\uffff\2\41\1\uffff\16\41\1\uffff\1\41\1"+
            "\uffff\35\41\1\uffff\1\41\1\uffff\35\41\1\uffff\1\41\1\uffff"+
            "\1\41",
            "\1\120\1\uffff\1\120\2\uffff\12\121",
            "",
            "\12\116",
            "\1\41\3\uffff\3\41\2\uffff\2\41\1\uffff\3\41\12\116\1\41\1\uffff"+
            "\1\41\1\uffff\35\41\1\uffff\1\41\1\uffff\35\41\1\uffff\1\41"+
            "\1\uffff\1\41",
            "\1\122",
            "\12\121",
            "\1\41\3\uffff\3\41\2\uffff\2\41\1\uffff\3\41\12\121\1\41\1\uffff"+
            "\1\41\1\uffff\35\41\1\uffff\1\41\1\uffff\35\41\1\uffff\1\41"+
            "\1\uffff\1\41",
            "\1\123",
            "\1\41\3\uffff\3\41\2\uffff\2\41\1\uffff\16\41\1\uffff\1\41\1"+
            "\uffff\35\41\1\uffff\1\41\1\uffff\35\41\1\uffff\1\41\1\uffff"+
            "\1\41"
    };

    static final short[] DFA22_eot = DFA.unpackEncodedString(DFA22_eotS);
    static final short[] DFA22_eof = DFA.unpackEncodedString(DFA22_eofS);
    static final char[] DFA22_min = DFA.unpackEncodedStringToUnsignedChars(DFA22_minS);
    static final char[] DFA22_max = DFA.unpackEncodedStringToUnsignedChars(DFA22_maxS);
    static final short[] DFA22_accept = DFA.unpackEncodedString(DFA22_acceptS);
    static final short[] DFA22_special = DFA.unpackEncodedString(DFA22_specialS);
    static final short[][] DFA22_transition;

    static {
        int numStates = DFA22_transitionS.length;
        DFA22_transition = new short[numStates][];
        for (int i=0; i<numStates; i++) {
            DFA22_transition[i] = DFA.unpackEncodedString(DFA22_transitionS[i]);
        }
    }

    class DFA22 extends DFA {

        public DFA22(BaseRecognizer recognizer) {
            this.recognizer = recognizer;
            this.decisionNumber = 22;
            this.eot = DFA22_eot;
            this.eof = DFA22_eof;
            this.min = DFA22_min;
            this.max = DFA22_max;
            this.accept = DFA22_accept;
            this.special = DFA22_special;
            this.transition = DFA22_transition;
        }
        public String getDescription() {
            return "1:1: Tokens : ( MultiComment | NewlineComment | OpenSimple | CloseSimple | OpenSquare | CloseSquare | OpenCurly | CloseCurly | Comma | HexInteger | Integer | Real | AssignmentOperator | UnaryOperator | BinaryOperator | Assignment | Identifier | PossibleTerminator | Whitespace );";
        }
    }
 

}