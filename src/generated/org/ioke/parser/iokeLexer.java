// $ANTLR 3.0.1 ioke.g 2008-03-24 15:25:45

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
    public static final int MultiString=4;
    public static final int Assignment=28;
    public static final int CloseCurly=15;
    public static final int Exponent=22;
    public static final int OpChars=26;
    public static final int HexLetter=18;
    public static final int IdentChars=30;
    public static final int Digit=17;
    public static final int Tokens=36;
    public static final int EOF=-1;
    public static final int OpenSimple=10;
    public static final int IdentStart=29;
    public static final int Identifier=31;
    public static final int Separator=33;
    public static final int Regexp=6;
    public static final int NewLine=8;
    public static final int AssignmentOperator=24;
    public static final int SimpleString=5;
    public static final int OpenSquare=12;
    public static final int Digits=20;
    public static final int CloseSimple=11;
    public static final int NewlineComment=9;
    public static final int HexInteger=19;
    public static final int Real=23;
    public static final int BinaryOperator=27;
    public static final int MultiComment=7;
    public static final int UnaryOperator=25;
    public static final int Whitespace=34;
    public static final int CloseSquare=13;
    public static final int OpenCurly=14;
    public static final int Comma=16;
    public static final int Letter=35;
    public static final int Integer=21;
    public static final int PossibleTerminator=32;

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

    // $ANTLR start MultiString
    public final void mMultiString() throws RecognitionException {
        try {
            int _type = MultiString;
            // ioke.g:68:5: ( ( '%{' ( options {greedy=false; } : ( . )* ) '}' ) | ( '%[' ( options {greedy=false; } : ( . )* ) ']' ) )
            int alt3=2;
            int LA3_0 = input.LA(1);

            if ( (LA3_0=='%') ) {
                int LA3_1 = input.LA(2);

                if ( (LA3_1=='[') ) {
                    alt3=2;
                }
                else if ( (LA3_1=='{') ) {
                    alt3=1;
                }
                else {
                    NoViableAltException nvae =
                        new NoViableAltException("67:1: MultiString : ( ( '%{' ( options {greedy=false; } : ( . )* ) '}' ) | ( '%[' ( options {greedy=false; } : ( . )* ) ']' ) );", 3, 1, input);

                    throw nvae;
                }
            }
            else {
                NoViableAltException nvae =
                    new NoViableAltException("67:1: MultiString : ( ( '%{' ( options {greedy=false; } : ( . )* ) '}' ) | ( '%[' ( options {greedy=false; } : ( . )* ) ']' ) );", 3, 0, input);

                throw nvae;
            }
            switch (alt3) {
                case 1 :
                    // ioke.g:68:7: ( '%{' ( options {greedy=false; } : ( . )* ) '}' )
                    {
                    // ioke.g:68:7: ( '%{' ( options {greedy=false; } : ( . )* ) '}' )
                    // ioke.g:68:8: '%{' ( options {greedy=false; } : ( . )* ) '}'
                    {
                    match("%{"); 

                    // ioke.g:68:13: ( options {greedy=false; } : ( . )* )
                    // ioke.g:68:41: ( . )*
                    {
                    // ioke.g:68:41: ( . )*
                    loop1:
                    do {
                        int alt1=2;
                        int LA1_0 = input.LA(1);

                        if ( (LA1_0=='}') ) {
                            alt1=2;
                        }
                        else if ( ((LA1_0>='\u0000' && LA1_0<='|')||(LA1_0>='~' && LA1_0<='\uFFFE')) ) {
                            alt1=1;
                        }


                        switch (alt1) {
                    	case 1 :
                    	    // ioke.g:68:41: .
                    	    {
                    	    matchAny(); 

                    	    }
                    	    break;

                    	default :
                    	    break loop1;
                        }
                    } while (true);


                    }

                    match('}'); 

                    }


                    }
                    break;
                case 2 :
                    // ioke.g:69:7: ( '%[' ( options {greedy=false; } : ( . )* ) ']' )
                    {
                    // ioke.g:69:7: ( '%[' ( options {greedy=false; } : ( . )* ) ']' )
                    // ioke.g:69:8: '%[' ( options {greedy=false; } : ( . )* ) ']'
                    {
                    match("%["); 

                    // ioke.g:69:13: ( options {greedy=false; } : ( . )* )
                    // ioke.g:69:41: ( . )*
                    {
                    // ioke.g:69:41: ( . )*
                    loop2:
                    do {
                        int alt2=2;
                        int LA2_0 = input.LA(1);

                        if ( (LA2_0==']') ) {
                            alt2=2;
                        }
                        else if ( ((LA2_0>='\u0000' && LA2_0<='\\')||(LA2_0>='^' && LA2_0<='\uFFFE')) ) {
                            alt2=1;
                        }


                        switch (alt2) {
                    	case 1 :
                    	    // ioke.g:69:41: .
                    	    {
                    	    matchAny(); 

                    	    }
                    	    break;

                    	default :
                    	    break loop2;
                        }
                    } while (true);


                    }

                    match(']'); 

                    }


                    }
                    break;

            }
            this.type = _type;
        }
        finally {
        }
    }
    // $ANTLR end MultiString

    // $ANTLR start SimpleString
    public final void mSimpleString() throws RecognitionException {
        try {
            int _type = SimpleString;
            // ioke.g:71:14: ( ( '\"' ( ( '\\\\' ( '\"' | '\\\\' ) ) | ( '\\\\' )? ~ ( '\"' | '\\\\' ) )* '\"' ) )
            // ioke.g:71:16: ( '\"' ( ( '\\\\' ( '\"' | '\\\\' ) ) | ( '\\\\' )? ~ ( '\"' | '\\\\' ) )* '\"' )
            {
            // ioke.g:71:16: ( '\"' ( ( '\\\\' ( '\"' | '\\\\' ) ) | ( '\\\\' )? ~ ( '\"' | '\\\\' ) )* '\"' )
            // ioke.g:71:17: '\"' ( ( '\\\\' ( '\"' | '\\\\' ) ) | ( '\\\\' )? ~ ( '\"' | '\\\\' ) )* '\"'
            {
            match('\"'); 
            // ioke.g:71:21: ( ( '\\\\' ( '\"' | '\\\\' ) ) | ( '\\\\' )? ~ ( '\"' | '\\\\' ) )*
            loop5:
            do {
                int alt5=3;
                int LA5_0 = input.LA(1);

                if ( (LA5_0=='\\') ) {
                    int LA5_2 = input.LA(2);

                    if ( (LA5_2=='\"'||LA5_2=='\\') ) {
                        alt5=1;
                    }
                    else if ( ((LA5_2>='\u0000' && LA5_2<='!')||(LA5_2>='#' && LA5_2<='[')||(LA5_2>=']' && LA5_2<='\uFFFE')) ) {
                        alt5=2;
                    }


                }
                else if ( ((LA5_0>='\u0000' && LA5_0<='!')||(LA5_0>='#' && LA5_0<='[')||(LA5_0>=']' && LA5_0<='\uFFFE')) ) {
                    alt5=2;
                }


                switch (alt5) {
            	case 1 :
            	    // ioke.g:71:23: ( '\\\\' ( '\"' | '\\\\' ) )
            	    {
            	    // ioke.g:71:23: ( '\\\\' ( '\"' | '\\\\' ) )
            	    // ioke.g:71:24: '\\\\' ( '\"' | '\\\\' )
            	    {
            	    match('\\'); 
            	    if ( input.LA(1)=='\"'||input.LA(1)=='\\' ) {
            	        input.consume();

            	    }
            	    else {
            	        MismatchedSetException mse =
            	            new MismatchedSetException(null,input);
            	        recover(mse);    throw mse;
            	    }


            	    }


            	    }
            	    break;
            	case 2 :
            	    // ioke.g:71:43: ( '\\\\' )? ~ ( '\"' | '\\\\' )
            	    {
            	    // ioke.g:71:43: ( '\\\\' )?
            	    int alt4=2;
            	    int LA4_0 = input.LA(1);

            	    if ( (LA4_0=='\\') ) {
            	        alt4=1;
            	    }
            	    switch (alt4) {
            	        case 1 :
            	            // ioke.g:71:43: '\\\\'
            	            {
            	            match('\\'); 

            	            }
            	            break;

            	    }

            	    if ( (input.LA(1)>='\u0000' && input.LA(1)<='!')||(input.LA(1)>='#' && input.LA(1)<='[')||(input.LA(1)>=']' && input.LA(1)<='\uFFFE') ) {
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
            	    break loop5;
                }
            } while (true);

            match('\"'); 

            }


            }

            this.type = _type;
        }
        finally {
        }
    }
    // $ANTLR end SimpleString

    // $ANTLR start Regexp
    public final void mRegexp() throws RecognitionException {
        try {
            int _type = Regexp;
            // ioke.g:74:5: ( ( '/' ( ( '\\\\' ( '/' | '\\\\' ) ) | ( '\\\\' )? ~ ( '/' | '\\\\' ) )* '/' ) ( 'i' | 'x' | 'm' )* )
            // ioke.g:74:7: ( '/' ( ( '\\\\' ( '/' | '\\\\' ) ) | ( '\\\\' )? ~ ( '/' | '\\\\' ) )* '/' ) ( 'i' | 'x' | 'm' )*
            {
            // ioke.g:74:7: ( '/' ( ( '\\\\' ( '/' | '\\\\' ) ) | ( '\\\\' )? ~ ( '/' | '\\\\' ) )* '/' )
            // ioke.g:74:8: '/' ( ( '\\\\' ( '/' | '\\\\' ) ) | ( '\\\\' )? ~ ( '/' | '\\\\' ) )* '/'
            {
            match('/'); 
            // ioke.g:74:12: ( ( '\\\\' ( '/' | '\\\\' ) ) | ( '\\\\' )? ~ ( '/' | '\\\\' ) )*
            loop7:
            do {
                int alt7=3;
                int LA7_0 = input.LA(1);

                if ( (LA7_0=='\\') ) {
                    int LA7_2 = input.LA(2);

                    if ( (LA7_2=='/'||LA7_2=='\\') ) {
                        alt7=1;
                    }
                    else if ( ((LA7_2>='\u0000' && LA7_2<='.')||(LA7_2>='0' && LA7_2<='[')||(LA7_2>=']' && LA7_2<='\uFFFE')) ) {
                        alt7=2;
                    }


                }
                else if ( ((LA7_0>='\u0000' && LA7_0<='.')||(LA7_0>='0' && LA7_0<='[')||(LA7_0>=']' && LA7_0<='\uFFFE')) ) {
                    alt7=2;
                }


                switch (alt7) {
            	case 1 :
            	    // ioke.g:74:14: ( '\\\\' ( '/' | '\\\\' ) )
            	    {
            	    // ioke.g:74:14: ( '\\\\' ( '/' | '\\\\' ) )
            	    // ioke.g:74:15: '\\\\' ( '/' | '\\\\' )
            	    {
            	    match('\\'); 
            	    if ( input.LA(1)=='/'||input.LA(1)=='\\' ) {
            	        input.consume();

            	    }
            	    else {
            	        MismatchedSetException mse =
            	            new MismatchedSetException(null,input);
            	        recover(mse);    throw mse;
            	    }


            	    }


            	    }
            	    break;
            	case 2 :
            	    // ioke.g:74:34: ( '\\\\' )? ~ ( '/' | '\\\\' )
            	    {
            	    // ioke.g:74:34: ( '\\\\' )?
            	    int alt6=2;
            	    int LA6_0 = input.LA(1);

            	    if ( (LA6_0=='\\') ) {
            	        alt6=1;
            	    }
            	    switch (alt6) {
            	        case 1 :
            	            // ioke.g:74:34: '\\\\'
            	            {
            	            match('\\'); 

            	            }
            	            break;

            	    }

            	    if ( (input.LA(1)>='\u0000' && input.LA(1)<='.')||(input.LA(1)>='0' && input.LA(1)<='[')||(input.LA(1)>=']' && input.LA(1)<='\uFFFE') ) {
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
            	    break loop7;
                }
            } while (true);

            match('/'); 

            }

            // ioke.g:74:59: ( 'i' | 'x' | 'm' )*
            loop8:
            do {
                int alt8=2;
                int LA8_0 = input.LA(1);

                if ( (LA8_0=='i'||LA8_0=='m'||LA8_0=='x') ) {
                    alt8=1;
                }


                switch (alt8) {
            	case 1 :
            	    // ioke.g:
            	    {
            	    if ( input.LA(1)=='i'||input.LA(1)=='m'||input.LA(1)=='x' ) {
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
            	    break loop8;
                }
            } while (true);


            }

            this.type = _type;
        }
        finally {
        }
    }
    // $ANTLR end Regexp

    // $ANTLR start MultiComment
    public final void mMultiComment() throws RecognitionException {
        try {
            int _type = MultiComment;
            // ioke.g:76:14: ( ( '{#' ( options {greedy=false; } : ( . )* ) '#}' ) )
            // ioke.g:76:16: ( '{#' ( options {greedy=false; } : ( . )* ) '#}' )
            {
            // ioke.g:76:16: ( '{#' ( options {greedy=false; } : ( . )* ) '#}' )
            // ioke.g:76:17: '{#' ( options {greedy=false; } : ( . )* ) '#}'
            {
            match("{#"); 

            // ioke.g:76:22: ( options {greedy=false; } : ( . )* )
            // ioke.g:76:50: ( . )*
            {
            // ioke.g:76:50: ( . )*
            loop9:
            do {
                int alt9=2;
                int LA9_0 = input.LA(1);

                if ( (LA9_0=='#') ) {
                    int LA9_1 = input.LA(2);

                    if ( (LA9_1=='}') ) {
                        alt9=2;
                    }
                    else if ( ((LA9_1>='\u0000' && LA9_1<='|')||(LA9_1>='~' && LA9_1<='\uFFFE')) ) {
                        alt9=1;
                    }


                }
                else if ( ((LA9_0>='\u0000' && LA9_0<='\"')||(LA9_0>='$' && LA9_0<='\uFFFE')) ) {
                    alt9=1;
                }


                switch (alt9) {
            	case 1 :
            	    // ioke.g:76:50: .
            	    {
            	    matchAny(); 

            	    }
            	    break;

            	default :
            	    break loop9;
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
            // ioke.g:77:16: ( '#' (~ NewLine )* ( NewLine )? )
            // ioke.g:77:18: '#' (~ NewLine )* ( NewLine )?
            {
            match('#'); 
            // ioke.g:77:22: (~ NewLine )*
            loop10:
            do {
                int alt10=2;
                int LA10_0 = input.LA(1);

                if ( ((LA10_0>='\u0000' && LA10_0<='\t')||(LA10_0>='\u000B' && LA10_0<='\f')||(LA10_0>='\u000E' && LA10_0<='\uFFFE')) ) {
                    alt10=1;
                }


                switch (alt10) {
            	case 1 :
            	    // ioke.g:77:24: ~ NewLine
            	    {
            	    if ( (input.LA(1)>='\u0000' && input.LA(1)<='\u0007')||(input.LA(1)>='\t' && input.LA(1)<='\uFFFE') ) {
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
            	    break loop10;
                }
            } while (true);

            // ioke.g:77:36: ( NewLine )?
            int alt11=2;
            int LA11_0 = input.LA(1);

            if ( (LA11_0=='\n'||LA11_0=='\r') ) {
                alt11=1;
            }
            switch (alt11) {
                case 1 :
                    // ioke.g:77:36: NewLine
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
            // ioke.g:79:12: ( '(' )
            // ioke.g:79:14: '('
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
            // ioke.g:80:13: ( ')' )
            // ioke.g:80:15: ')'
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
            // ioke.g:81:12: ( '[' )
            // ioke.g:81:14: '['
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
            // ioke.g:82:13: ( ']' )
            // ioke.g:82:15: ']'
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
            // ioke.g:83:11: ( '{' )
            // ioke.g:83:13: '{'
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
            // ioke.g:84:12: ( '}' )
            // ioke.g:84:14: '}'
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
            // ioke.g:86:7: ( ( ',' ( NewLine )* ) )
            // ioke.g:86:9: ( ',' ( NewLine )* )
            {
            // ioke.g:86:9: ( ',' ( NewLine )* )
            // ioke.g:86:10: ',' ( NewLine )*
            {
            match(','); 
            // ioke.g:86:14: ( NewLine )*
            loop12:
            do {
                int alt12=2;
                int LA12_0 = input.LA(1);

                if ( (LA12_0=='\n'||LA12_0=='\r') ) {
                    alt12=1;
                }


                switch (alt12) {
            	case 1 :
            	    // ioke.g:86:14: NewLine
            	    {
            	    mNewLine(); 

            	    }
            	    break;

            	default :
            	    break loop12;
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
            // ioke.g:88:12: ( ( '+' | '-' )? '0' ( 'x' | 'X' ) ( Digit | HexLetter )+ )
            // ioke.g:88:14: ( '+' | '-' )? '0' ( 'x' | 'X' ) ( Digit | HexLetter )+
            {
            // ioke.g:88:14: ( '+' | '-' )?
            int alt13=2;
            int LA13_0 = input.LA(1);

            if ( (LA13_0=='+'||LA13_0=='-') ) {
                alt13=1;
            }
            switch (alt13) {
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

            // ioke.g:88:41: ( Digit | HexLetter )+
            int cnt14=0;
            loop14:
            do {
                int alt14=2;
                int LA14_0 = input.LA(1);

                if ( ((LA14_0>='0' && LA14_0<='9')||(LA14_0>='A' && LA14_0<='F')||(LA14_0>='a' && LA14_0<='f')) ) {
                    alt14=1;
                }


                switch (alt14) {
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
            	    if ( cnt14 >= 1 ) break loop14;
                        EarlyExitException eee =
                            new EarlyExitException(14, input);
                        throw eee;
                }
                cnt14++;
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
            // ioke.g:90:9: ( ( '+' | '-' )? Digits )
            // ioke.g:90:11: ( '+' | '-' )? Digits
            {
            // ioke.g:90:11: ( '+' | '-' )?
            int alt15=2;
            int LA15_0 = input.LA(1);

            if ( (LA15_0=='+'||LA15_0=='-') ) {
                alt15=1;
            }
            switch (alt15) {
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
            // ioke.g:93:5: ( ( '+' | '-' )? ( Digits '.' ( Digit )* ( Exponent )? | '.' Digits ( Exponent )? | Digits Exponent ) )
            // ioke.g:93:9: ( '+' | '-' )? ( Digits '.' ( Digit )* ( Exponent )? | '.' Digits ( Exponent )? | Digits Exponent )
            {
            // ioke.g:93:9: ( '+' | '-' )?
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

            // ioke.g:94:9: ( Digits '.' ( Digit )* ( Exponent )? | '.' Digits ( Exponent )? | Digits Exponent )
            int alt20=3;
            alt20 = dfa20.predict(input);
            switch (alt20) {
                case 1 :
                    // ioke.g:94:10: Digits '.' ( Digit )* ( Exponent )?
                    {
                    mDigits(); 
                    match('.'); 
                    // ioke.g:94:21: ( Digit )*
                    loop17:
                    do {
                        int alt17=2;
                        int LA17_0 = input.LA(1);

                        if ( ((LA17_0>='0' && LA17_0<='9')) ) {
                            alt17=1;
                        }


                        switch (alt17) {
                    	case 1 :
                    	    // ioke.g:94:21: Digit
                    	    {
                    	    mDigit(); 

                    	    }
                    	    break;

                    	default :
                    	    break loop17;
                        }
                    } while (true);

                    // ioke.g:94:28: ( Exponent )?
                    int alt18=2;
                    int LA18_0 = input.LA(1);

                    if ( (LA18_0=='E'||LA18_0=='e') ) {
                        alt18=1;
                    }
                    switch (alt18) {
                        case 1 :
                            // ioke.g:94:28: Exponent
                            {
                            mExponent(); 

                            }
                            break;

                    }


                    }
                    break;
                case 2 :
                    // ioke.g:95:10: '.' Digits ( Exponent )?
                    {
                    match('.'); 
                    mDigits(); 
                    // ioke.g:95:21: ( Exponent )?
                    int alt19=2;
                    int LA19_0 = input.LA(1);

                    if ( (LA19_0=='E'||LA19_0=='e') ) {
                        alt19=1;
                    }
                    switch (alt19) {
                        case 1 :
                            // ioke.g:95:21: Exponent
                            {
                            mExponent(); 

                            }
                            break;

                    }


                    }
                    break;
                case 3 :
                    // ioke.g:96:10: Digits Exponent
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
            // ioke.g:99:20: ( ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<<' | '>>' | '&' | '&&' | '|' | '||' ) '=' )
            // ioke.g:100:9: ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<<' | '>>' | '&' | '&&' | '|' | '||' ) '='
            {
            // ioke.g:100:9: ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<<' | '>>' | '&' | '&&' | '|' | '||' )
            int alt21=18;
            switch ( input.LA(1) ) {
            case '+':
                {
                int LA21_1 = input.LA(2);

                if ( (LA21_1=='+') ) {
                    alt21=2;
                }
                else if ( (LA21_1=='=') ) {
                    alt21=1;
                }
                else {
                    NoViableAltException nvae =
                        new NoViableAltException("100:9: ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<<' | '>>' | '&' | '&&' | '|' | '||' )", 21, 1, input);

                    throw nvae;
                }
                }
                break;
            case '-':
                {
                int LA21_2 = input.LA(2);

                if ( (LA21_2=='-') ) {
                    alt21=4;
                }
                else if ( (LA21_2=='=') ) {
                    alt21=3;
                }
                else {
                    NoViableAltException nvae =
                        new NoViableAltException("100:9: ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<<' | '>>' | '&' | '&&' | '|' | '||' )", 21, 2, input);

                    throw nvae;
                }
                }
                break;
            case '/':
                {
                int LA21_3 = input.LA(2);

                if ( (LA21_3=='/') ) {
                    alt21=6;
                }
                else if ( (LA21_3=='=') ) {
                    alt21=5;
                }
                else {
                    NoViableAltException nvae =
                        new NoViableAltException("100:9: ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<<' | '>>' | '&' | '&&' | '|' | '||' )", 21, 3, input);

                    throw nvae;
                }
                }
                break;
            case '*':
                {
                int LA21_4 = input.LA(2);

                if ( (LA21_4=='*') ) {
                    alt21=8;
                }
                else if ( (LA21_4=='=') ) {
                    alt21=7;
                }
                else {
                    NoViableAltException nvae =
                        new NoViableAltException("100:9: ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<<' | '>>' | '&' | '&&' | '|' | '||' )", 21, 4, input);

                    throw nvae;
                }
                }
                break;
            case '%':
                {
                int LA21_5 = input.LA(2);

                if ( (LA21_5=='%') ) {
                    alt21=10;
                }
                else if ( (LA21_5=='=') ) {
                    alt21=9;
                }
                else {
                    NoViableAltException nvae =
                        new NoViableAltException("100:9: ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<<' | '>>' | '&' | '&&' | '|' | '||' )", 21, 5, input);

                    throw nvae;
                }
                }
                break;
            case '^':
                {
                int LA21_6 = input.LA(2);

                if ( (LA21_6=='^') ) {
                    alt21=12;
                }
                else if ( (LA21_6=='=') ) {
                    alt21=11;
                }
                else {
                    NoViableAltException nvae =
                        new NoViableAltException("100:9: ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<<' | '>>' | '&' | '&&' | '|' | '||' )", 21, 6, input);

                    throw nvae;
                }
                }
                break;
            case '<':
                {
                alt21=13;
                }
                break;
            case '>':
                {
                alt21=14;
                }
                break;
            case '&':
                {
                int LA21_9 = input.LA(2);

                if ( (LA21_9=='&') ) {
                    alt21=16;
                }
                else if ( (LA21_9=='=') ) {
                    alt21=15;
                }
                else {
                    NoViableAltException nvae =
                        new NoViableAltException("100:9: ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<<' | '>>' | '&' | '&&' | '|' | '||' )", 21, 9, input);

                    throw nvae;
                }
                }
                break;
            case '|':
                {
                int LA21_10 = input.LA(2);

                if ( (LA21_10=='|') ) {
                    alt21=18;
                }
                else if ( (LA21_10=='=') ) {
                    alt21=17;
                }
                else {
                    NoViableAltException nvae =
                        new NoViableAltException("100:9: ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<<' | '>>' | '&' | '&&' | '|' | '||' )", 21, 10, input);

                    throw nvae;
                }
                }
                break;
            default:
                NoViableAltException nvae =
                    new NoViableAltException("100:9: ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<<' | '>>' | '&' | '&&' | '|' | '||' )", 21, 0, input);

                throw nvae;
            }

            switch (alt21) {
                case 1 :
                    // ioke.g:100:10: '+'
                    {
                    match('+'); 

                    }
                    break;
                case 2 :
                    // ioke.g:101:11: '++'
                    {
                    match("++"); 


                    }
                    break;
                case 3 :
                    // ioke.g:102:11: '-'
                    {
                    match('-'); 

                    }
                    break;
                case 4 :
                    // ioke.g:103:11: '--'
                    {
                    match("--"); 


                    }
                    break;
                case 5 :
                    // ioke.g:104:11: '/'
                    {
                    match('/'); 

                    }
                    break;
                case 6 :
                    // ioke.g:105:11: '//'
                    {
                    match("//"); 


                    }
                    break;
                case 7 :
                    // ioke.g:106:11: '*'
                    {
                    match('*'); 

                    }
                    break;
                case 8 :
                    // ioke.g:107:11: '**'
                    {
                    match("**"); 


                    }
                    break;
                case 9 :
                    // ioke.g:108:11: '%'
                    {
                    match('%'); 

                    }
                    break;
                case 10 :
                    // ioke.g:109:11: '%%'
                    {
                    match("%%"); 


                    }
                    break;
                case 11 :
                    // ioke.g:110:11: '^'
                    {
                    match('^'); 

                    }
                    break;
                case 12 :
                    // ioke.g:111:11: '^^'
                    {
                    match("^^"); 


                    }
                    break;
                case 13 :
                    // ioke.g:112:11: '<<'
                    {
                    match("<<"); 


                    }
                    break;
                case 14 :
                    // ioke.g:113:11: '>>'
                    {
                    match(">>"); 


                    }
                    break;
                case 15 :
                    // ioke.g:114:11: '&'
                    {
                    match('&'); 

                    }
                    break;
                case 16 :
                    // ioke.g:115:11: '&&'
                    {
                    match("&&"); 


                    }
                    break;
                case 17 :
                    // ioke.g:116:11: '|'
                    {
                    match('|'); 

                    }
                    break;
                case 18 :
                    // ioke.g:117:11: '||'
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
            // ioke.g:120:15: ( '@' | '@@' | '\\'' | '`' | '!' | ':' | 'return' )
            int alt22=7;
            switch ( input.LA(1) ) {
            case '@':
                {
                int LA22_1 = input.LA(2);

                if ( (LA22_1=='@') ) {
                    alt22=2;
                }
                else {
                    alt22=1;}
                }
                break;
            case '\'':
                {
                alt22=3;
                }
                break;
            case '`':
                {
                alt22=4;
                }
                break;
            case '!':
                {
                alt22=5;
                }
                break;
            case ':':
                {
                alt22=6;
                }
                break;
            case 'r':
                {
                alt22=7;
                }
                break;
            default:
                NoViableAltException nvae =
                    new NoViableAltException("120:1: UnaryOperator : ( '@' | '@@' | '\\'' | '`' | '!' | ':' | 'return' );", 22, 0, input);

                throw nvae;
            }

            switch (alt22) {
                case 1 :
                    // ioke.g:121:7: '@'
                    {
                    match('@'); 

                    }
                    break;
                case 2 :
                    // ioke.g:122:7: '@@'
                    {
                    match("@@"); 


                    }
                    break;
                case 3 :
                    // ioke.g:123:7: '\\''
                    {
                    match('\''); 

                    }
                    break;
                case 4 :
                    // ioke.g:124:7: '`'
                    {
                    match('`'); 

                    }
                    break;
                case 5 :
                    // ioke.g:125:7: '!'
                    {
                    match('!'); 

                    }
                    break;
                case 6 :
                    // ioke.g:126:7: ':'
                    {
                    match(':'); 

                    }
                    break;
                case 7 :
                    // ioke.g:127:7: 'return'
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
            // ioke.g:130:16: ( ( OpChars )+ | '==' | '===' | '====' | '<=' | '>=' | '~=' | '~~=' | '!=' | '!!=' | 'and' | 'or' )
            int alt24=12;
            switch ( input.LA(1) ) {
            case '<':
                {
                int LA24_1 = input.LA(2);

                if ( (LA24_1=='=') ) {
                    alt24=5;
                }
                else {
                    alt24=1;}
                }
                break;
            case '=':
                {
                int LA24_2 = input.LA(2);

                if ( (LA24_2=='=') ) {
                    int LA24_10 = input.LA(3);

                    if ( (LA24_10=='=') ) {
                        int LA24_16 = input.LA(4);

                        if ( (LA24_16=='=') ) {
                            alt24=4;
                        }
                        else {
                            alt24=3;}
                    }
                    else {
                        alt24=2;}
                }
                else {
                    NoViableAltException nvae =
                        new NoViableAltException("130:1: BinaryOperator : ( ( OpChars )+ | '==' | '===' | '====' | '<=' | '>=' | '~=' | '~~=' | '!=' | '!!=' | 'and' | 'or' );", 24, 2, input);

                    throw nvae;
                }
                }
                break;
            case '>':
                {
                int LA24_3 = input.LA(2);

                if ( (LA24_3=='=') ) {
                    alt24=6;
                }
                else {
                    alt24=1;}
                }
                break;
            case '~':
                {
                switch ( input.LA(2) ) {
                case '~':
                    {
                    int LA24_12 = input.LA(3);

                    if ( (LA24_12=='=') ) {
                        alt24=8;
                    }
                    else {
                        alt24=1;}
                    }
                    break;
                case '=':
                    {
                    alt24=7;
                    }
                    break;
                default:
                    alt24=1;}

                }
                break;
            case '!':
                {
                switch ( input.LA(2) ) {
                case '=':
                    {
                    alt24=9;
                    }
                    break;
                case '!':
                    {
                    int LA24_15 = input.LA(3);

                    if ( (LA24_15=='=') ) {
                        alt24=10;
                    }
                    else {
                        alt24=1;}
                    }
                    break;
                default:
                    alt24=1;}

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
                alt24=1;
                }
                break;
            case 'a':
                {
                alt24=11;
                }
                break;
            case 'o':
                {
                alt24=12;
                }
                break;
            default:
                NoViableAltException nvae =
                    new NoViableAltException("130:1: BinaryOperator : ( ( OpChars )+ | '==' | '===' | '====' | '<=' | '>=' | '~=' | '~~=' | '!=' | '!!=' | 'and' | 'or' );", 24, 0, input);

                throw nvae;
            }

            switch (alt24) {
                case 1 :
                    // ioke.g:131:7: ( OpChars )+
                    {
                    // ioke.g:131:7: ( OpChars )+
                    int cnt23=0;
                    loop23:
                    do {
                        int alt23=2;
                        int LA23_0 = input.LA(1);

                        if ( (LA23_0=='!'||(LA23_0>='%' && LA23_0<='\'')||(LA23_0>='*' && LA23_0<='+')||(LA23_0>='-' && LA23_0<='/')||LA23_0==':'||LA23_0=='<'||(LA23_0>='>' && LA23_0<='@')||LA23_0=='\\'||(LA23_0>='^' && LA23_0<='`')||LA23_0=='|'||LA23_0=='~') ) {
                            alt23=1;
                        }


                        switch (alt23) {
                    	case 1 :
                    	    // ioke.g:131:7: OpChars
                    	    {
                    	    mOpChars(); 

                    	    }
                    	    break;

                    	default :
                    	    if ( cnt23 >= 1 ) break loop23;
                                EarlyExitException eee =
                                    new EarlyExitException(23, input);
                                throw eee;
                        }
                        cnt23++;
                    } while (true);


                    }
                    break;
                case 2 :
                    // ioke.g:132:7: '=='
                    {
                    match("=="); 


                    }
                    break;
                case 3 :
                    // ioke.g:133:7: '==='
                    {
                    match("==="); 


                    }
                    break;
                case 4 :
                    // ioke.g:134:7: '===='
                    {
                    match("===="); 


                    }
                    break;
                case 5 :
                    // ioke.g:135:7: '<='
                    {
                    match("<="); 


                    }
                    break;
                case 6 :
                    // ioke.g:136:7: '>='
                    {
                    match(">="); 


                    }
                    break;
                case 7 :
                    // ioke.g:137:7: '~='
                    {
                    match("~="); 


                    }
                    break;
                case 8 :
                    // ioke.g:138:7: '~~='
                    {
                    match("~~="); 


                    }
                    break;
                case 9 :
                    // ioke.g:139:7: '!='
                    {
                    match("!="); 


                    }
                    break;
                case 10 :
                    // ioke.g:140:7: '!!='
                    {
                    match("!!="); 


                    }
                    break;
                case 11 :
                    // ioke.g:141:7: 'and'
                    {
                    match("and"); 


                    }
                    break;
                case 12 :
                    // ioke.g:142:7: 'or'
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
            // ioke.g:145:12: ( '=' )
            // ioke.g:145:14: '='
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
            // ioke.g:147:12: ( IdentStart ( IdentChars )* )
            // ioke.g:147:14: IdentStart ( IdentChars )*
            {
            mIdentStart(); 
            // ioke.g:147:25: ( IdentChars )*
            loop25:
            do {
                int alt25=2;
                int LA25_0 = input.LA(1);

                if ( (LA25_0=='!'||(LA25_0>='%' && LA25_0<='\'')||(LA25_0>='*' && LA25_0<='+')||(LA25_0>='-' && LA25_0<=':')||LA25_0=='<'||(LA25_0>='>' && LA25_0<='Z')||LA25_0=='\\'||(LA25_0>='^' && LA25_0<='z')||LA25_0=='|'||LA25_0=='~') ) {
                    alt25=1;
                }


                switch (alt25) {
            	case 1 :
            	    // ioke.g:147:25: IdentChars
            	    {
            	    mIdentChars(); 

            	    }
            	    break;

            	default :
            	    break loop25;
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
            // ioke.g:149:20: ( ( ( ';' | NewLine )+ ) )
            // ioke.g:149:22: ( ( ';' | NewLine )+ )
            {
            // ioke.g:149:22: ( ( ';' | NewLine )+ )
            // ioke.g:149:23: ( ';' | NewLine )+
            {
            // ioke.g:149:23: ( ';' | NewLine )+
            int cnt26=0;
            loop26:
            do {
                int alt26=2;
                int LA26_0 = input.LA(1);

                if ( (LA26_0=='\n'||LA26_0=='\r'||LA26_0==';') ) {
                    alt26=1;
                }


                switch (alt26) {
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
            	    if ( cnt26 >= 1 ) break loop26;
                        EarlyExitException eee =
                            new EarlyExitException(26, input);
                        throw eee;
                }
                cnt26++;
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
            // ioke.g:151:12: ( Separator )
            // ioke.g:151:14: Separator
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
            // ioke.g:155:10: ( ( 'e' | 'E' ) ( '+' | '-' )? Digits )
            // ioke.g:155:12: ( 'e' | 'E' ) ( '+' | '-' )? Digits
            {
            if ( input.LA(1)=='E'||input.LA(1)=='e' ) {
                input.consume();

            }
            else {
                MismatchedSetException mse =
                    new MismatchedSetException(null,input);
                recover(mse);    throw mse;
            }

            // ioke.g:155:22: ( '+' | '-' )?
            int alt27=2;
            int LA27_0 = input.LA(1);

            if ( (LA27_0=='+'||LA27_0=='-') ) {
                alt27=1;
            }
            switch (alt27) {
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
            // ioke.g:158:8: ( 'a' .. 'z' | 'A' .. 'Z' )
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
            // ioke.g:161:7: ( '0' .. '9' )
            // ioke.g:161:9: '0' .. '9'
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
            // ioke.g:164:8: ( ( Digit )+ )
            // ioke.g:164:10: ( Digit )+
            {
            // ioke.g:164:10: ( Digit )+
            int cnt28=0;
            loop28:
            do {
                int alt28=2;
                int LA28_0 = input.LA(1);

                if ( ((LA28_0>='0' && LA28_0<='9')) ) {
                    alt28=1;
                }


                switch (alt28) {
            	case 1 :
            	    // ioke.g:164:10: Digit
            	    {
            	    mDigit(); 

            	    }
            	    break;

            	default :
            	    if ( cnt28 >= 1 ) break loop28;
                        EarlyExitException eee =
                            new EarlyExitException(28, input);
                        throw eee;
                }
                cnt28++;
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
            // ioke.g:167:11: ( 'a' .. 'f' | 'A' .. 'F' )
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
            // ioke.g:170:11: ( ( ' ' | '\\u000c' | '\\u0009' | '\\u000b' | '\\\\' '\\u000a' )+ )
            // ioke.g:170:13: ( ' ' | '\\u000c' | '\\u0009' | '\\u000b' | '\\\\' '\\u000a' )+
            {
            // ioke.g:170:13: ( ' ' | '\\u000c' | '\\u0009' | '\\u000b' | '\\\\' '\\u000a' )+
            int cnt29=0;
            loop29:
            do {
                int alt29=6;
                switch ( input.LA(1) ) {
                case ' ':
                    {
                    alt29=1;
                    }
                    break;
                case '\f':
                    {
                    alt29=2;
                    }
                    break;
                case '\t':
                    {
                    alt29=3;
                    }
                    break;
                case '\u000B':
                    {
                    alt29=4;
                    }
                    break;
                case '\\':
                    {
                    alt29=5;
                    }
                    break;

                }

                switch (alt29) {
            	case 1 :
            	    // ioke.g:170:14: ' '
            	    {
            	    match(' '); 

            	    }
            	    break;
            	case 2 :
            	    // ioke.g:170:20: '\\u000c'
            	    {
            	    match('\f'); 

            	    }
            	    break;
            	case 3 :
            	    // ioke.g:170:31: '\\u0009'
            	    {
            	    match('\t'); 

            	    }
            	    break;
            	case 4 :
            	    // ioke.g:170:42: '\\u000b'
            	    {
            	    match('\u000B'); 

            	    }
            	    break;
            	case 5 :
            	    // ioke.g:170:53: '\\\\' '\\u000a'
            	    {
            	    match('\\'); 
            	    match('\n'); 

            	    }
            	    break;

            	default :
            	    if ( cnt29 >= 1 ) break loop29;
                        EarlyExitException eee =
                            new EarlyExitException(29, input);
                        throw eee;
                }
                cnt29++;
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
            // ioke.g:173:9: ( ( '!' | '?' | '@' | '&' | '%' | '.' | '|' | '<' | '>' | '/' | '+' | '-' | '_' | ':' | '\\\\' | '*' | '^' | '~' | '`' | '\\'' ) )
            // ioke.g:173:11: ( '!' | '?' | '@' | '&' | '%' | '.' | '|' | '<' | '>' | '/' | '+' | '-' | '_' | ':' | '\\\\' | '*' | '^' | '~' | '`' | '\\'' )
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
            // ioke.g:176:12: ( Letter | Digit | ( '!' | '?' | '@' | '&' | '%' | '.' | '|' | '<' | '>' | '/' | '+' | '-' | '_' | ':' | '\\\\' | '*' | '^' | '~' | '`' | '\\'' ) )
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
            // ioke.g:179:12: ( Letter | Digit | ( '?' | '&' | '%' | '|' | '<' | '>' | '/' | '+' | '-' | '_' | '\\\\' | '*' | '^' | '~' ) )
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
            // ioke.g:182:9: ( ( '\\u000a' | '\\u000d' ) )
            // ioke.g:182:11: ( '\\u000a' | '\\u000d' )
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
        // ioke.g:1:8: ( MultiString | SimpleString | Regexp | MultiComment | NewlineComment | OpenSimple | CloseSimple | OpenSquare | CloseSquare | OpenCurly | CloseCurly | Comma | HexInteger | Integer | Real | AssignmentOperator | UnaryOperator | BinaryOperator | Assignment | Identifier | PossibleTerminator | Whitespace )
        int alt30=22;
        alt30 = dfa30.predict(input);
        switch (alt30) {
            case 1 :
                // ioke.g:1:10: MultiString
                {
                mMultiString(); 

                }
                break;
            case 2 :
                // ioke.g:1:22: SimpleString
                {
                mSimpleString(); 

                }
                break;
            case 3 :
                // ioke.g:1:35: Regexp
                {
                mRegexp(); 

                }
                break;
            case 4 :
                // ioke.g:1:42: MultiComment
                {
                mMultiComment(); 

                }
                break;
            case 5 :
                // ioke.g:1:55: NewlineComment
                {
                mNewlineComment(); 

                }
                break;
            case 6 :
                // ioke.g:1:70: OpenSimple
                {
                mOpenSimple(); 

                }
                break;
            case 7 :
                // ioke.g:1:81: CloseSimple
                {
                mCloseSimple(); 

                }
                break;
            case 8 :
                // ioke.g:1:93: OpenSquare
                {
                mOpenSquare(); 

                }
                break;
            case 9 :
                // ioke.g:1:104: CloseSquare
                {
                mCloseSquare(); 

                }
                break;
            case 10 :
                // ioke.g:1:116: OpenCurly
                {
                mOpenCurly(); 

                }
                break;
            case 11 :
                // ioke.g:1:126: CloseCurly
                {
                mCloseCurly(); 

                }
                break;
            case 12 :
                // ioke.g:1:137: Comma
                {
                mComma(); 

                }
                break;
            case 13 :
                // ioke.g:1:143: HexInteger
                {
                mHexInteger(); 

                }
                break;
            case 14 :
                // ioke.g:1:154: Integer
                {
                mInteger(); 

                }
                break;
            case 15 :
                // ioke.g:1:162: Real
                {
                mReal(); 

                }
                break;
            case 16 :
                // ioke.g:1:167: AssignmentOperator
                {
                mAssignmentOperator(); 

                }
                break;
            case 17 :
                // ioke.g:1:186: UnaryOperator
                {
                mUnaryOperator(); 

                }
                break;
            case 18 :
                // ioke.g:1:200: BinaryOperator
                {
                mBinaryOperator(); 

                }
                break;
            case 19 :
                // ioke.g:1:215: Assignment
                {
                mAssignment(); 

                }
                break;
            case 20 :
                // ioke.g:1:226: Identifier
                {
                mIdentifier(); 

                }
                break;
            case 21 :
                // ioke.g:1:237: PossibleTerminator
                {
                mPossibleTerminator(); 

                }
                break;
            case 22 :
                // ioke.g:1:256: Whitespace
                {
                mWhitespace(); 

                }
                break;

        }

    }


    protected DFA20 dfa20 = new DFA20(this);
    protected DFA30 dfa30 = new DFA30(this);
    static final String DFA20_eotS =
        "\5\uffff";
    static final String DFA20_eofS =
        "\5\uffff";
    static final String DFA20_minS =
        "\2\56\3\uffff";
    static final String DFA20_maxS =
        "\1\71\1\145\3\uffff";
    static final String DFA20_acceptS =
        "\2\uffff\1\2\1\1\1\3";
    static final String DFA20_specialS =
        "\5\uffff}>";
    static final String[] DFA20_transitionS = {
            "\1\2\1\uffff\12\1",
            "\1\3\1\uffff\12\1\13\uffff\1\4\37\uffff\1\4",
            "",
            "",
            ""
    };

    static final short[] DFA20_eot = DFA.unpackEncodedString(DFA20_eotS);
    static final short[] DFA20_eof = DFA.unpackEncodedString(DFA20_eofS);
    static final char[] DFA20_min = DFA.unpackEncodedStringToUnsignedChars(DFA20_minS);
    static final char[] DFA20_max = DFA.unpackEncodedStringToUnsignedChars(DFA20_maxS);
    static final short[] DFA20_accept = DFA.unpackEncodedString(DFA20_acceptS);
    static final short[] DFA20_special = DFA.unpackEncodedString(DFA20_specialS);
    static final short[][] DFA20_transition;

    static {
        int numStates = DFA20_transitionS.length;
        DFA20_transition = new short[numStates][];
        for (int i=0; i<numStates; i++) {
            DFA20_transition[i] = DFA.unpackEncodedString(DFA20_transitionS[i]);
        }
    }

    class DFA20 extends DFA {

        public DFA20(BaseRecognizer recognizer) {
            this.recognizer = recognizer;
            this.decisionNumber = 20;
            this.eot = DFA20_eot;
            this.eof = DFA20_eof;
            this.min = DFA20_min;
            this.max = DFA20_max;
            this.accept = DFA20_accept;
            this.special = DFA20_special;
            this.transition = DFA20_transition;
        }
        public String getDescription() {
            return "94:9: ( Digits '.' ( Digit )* ( Exponent )? | '.' Digits ( Exponent )? | Digits Exponent )";
        }
    }
    static final String DFA30_eotS =
        "\1\uffff\1\50\1\uffff\1\50\1\62\7\uffff\1\50\2\70\10\50\5\104\1"+
        "\42\1\50\1\107\1\50\2\42\3\uffff\1\50\1\uffff\1\50\1\uffff\1\50"+
        "\1\uffff\1\60\1\50\1\42\1\52\1\50\3\uffff\1\50\2\70\1\50\1\42\1"+
        "\uffff\1\42\1\73\1\uffff\7\50\1\104\1\uffff\1\42\1\50\1\uffff\1"+
        "\42\1\50\1\60\1\50\1\60\1\42\1\60\1\73\1\131\1\42\2\73\2\42\1\50"+
        "\2\42\1\uffff\1\42\1\73\2\42\1\73\1\42\1\104";
    static final String DFA30_eofS =
        "\141\uffff";
    static final String DFA30_minS =
        "\1\11\1\41\1\uffff\1\0\1\43\7\uffff\3\41\1\60\14\41\1\145\1\41\1"+
        "\75\1\12\1\156\1\162\3\uffff\1\41\1\uffff\1\41\1\uffff\1\41\1\uffff"+
        "\1\41\4\0\3\uffff\4\41\1\60\1\uffff\1\53\1\41\1\uffff\10\41\1\uffff"+
        "\1\164\1\41\1\uffff\1\144\2\41\1\0\1\41\1\0\3\41\1\60\2\41\1\53"+
        "\1\165\1\41\1\0\1\53\1\uffff\1\60\1\41\1\162\1\60\1\41\1\156\1\41";
    static final String DFA30_maxS =
        "\2\176\1\uffff\1\ufffe\1\43\7\uffff\3\176\1\71\14\176\1\145\1\176"+
        "\1\75\1\176\1\156\1\162\3\uffff\1\176\1\uffff\1\176\1\uffff\1\176"+
        "\1\uffff\1\176\4\ufffe\3\uffff\4\176\1\146\1\uffff\1\71\1\176\1"+
        "\uffff\10\176\1\uffff\1\164\1\176\1\uffff\1\144\2\176\1\ufffe\1"+
        "\176\1\ufffe\3\176\1\71\2\176\1\71\1\165\1\176\1\ufffe\1\71\1\uffff"+
        "\1\71\1\176\1\162\1\71\1\176\1\156\1\176";
    static final String DFA30_acceptS =
        "\2\uffff\1\2\2\uffff\1\5\1\6\1\7\1\10\1\11\1\13\1\14\26\uffff\1"+
        "\24\1\25\1\26\1\uffff\1\1\1\uffff\1\22\1\uffff\1\20\5\uffff\1\3"+
        "\1\4\1\12\5\uffff\1\16\2\uffff\1\17\10\uffff\1\21\2\uffff\1\23\21"+
        "\uffff\1\15\7\uffff";
    static final String DFA30_specialS =
        "\141\uffff}>";
    static final String[] DFA30_transitionS = {
            "\1\44\1\43\2\44\1\43\22\uffff\1\44\1\32\1\2\1\5\1\uffff\1\1"+
            "\1\25\1\30\1\6\1\7\1\21\1\14\1\13\1\20\1\17\1\3\1\15\11\16\1"+
            "\33\1\43\1\23\1\36\1\24\1\45\1\27\32\42\1\10\1\37\1\11\1\22"+
            "\1\45\1\31\1\40\15\42\1\41\2\42\1\34\10\42\1\4\1\26\1\12\1\35",
            "\1\51\3\uffff\1\47\2\51\2\uffff\2\51\1\uffff\3\51\12\42\1\51"+
            "\1\uffff\1\51\1\52\3\51\32\42\1\46\1\51\1\uffff\3\51\32\42\1"+
            "\46\1\51\1\uffff\1\51",
            "",
            "\41\60\1\57\3\60\3\57\2\60\2\57\1\60\2\57\1\53\12\55\1\57\1"+
            "\60\1\57\1\56\3\57\32\55\1\60\1\54\1\60\3\57\32\55\1\60\1\57"+
            "\1\60\1\57\uff80\60",
            "\1\61",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "\1\51\3\uffff\3\51\2\uffff\1\51\1\63\1\uffff\1\51\1\66\1\51"+
            "\1\64\11\65\1\51\1\uffff\1\51\1\52\3\51\32\42\1\uffff\1\51\1"+
            "\uffff\3\51\32\42\1\uffff\1\51\1\uffff\1\51",
            "\1\42\3\uffff\3\42\2\uffff\2\42\1\uffff\1\42\1\72\1\42\12\65"+
            "\1\42\1\uffff\1\42\1\uffff\7\42\1\71\22\42\1\67\2\42\1\uffff"+
            "\1\42\1\uffff\7\42\1\71\22\42\1\67\2\42\1\uffff\1\42\1\uffff"+
            "\1\42",
            "\1\42\3\uffff\3\42\2\uffff\2\42\1\uffff\1\42\1\72\1\42\12\65"+
            "\1\42\1\uffff\1\42\1\uffff\7\42\1\71\25\42\1\uffff\1\42\1\uffff"+
            "\7\42\1\71\25\42\1\uffff\1\42\1\uffff\1\42",
            "\12\73",
            "\1\51\3\uffff\3\51\2\uffff\2\51\1\uffff\1\74\1\66\1\51\1\64"+
            "\11\65\1\51\1\uffff\1\51\1\52\3\51\32\42\1\uffff\1\51\1\uffff"+
            "\3\51\32\42\1\uffff\1\51\1\uffff\1\51",
            "\1\51\3\uffff\3\51\2\uffff\1\75\1\51\1\uffff\3\51\12\42\1\51"+
            "\1\uffff\1\51\1\52\3\51\32\42\1\uffff\1\51\1\uffff\3\51\32\42"+
            "\1\uffff\1\51\1\uffff\1\51",
            "\1\51\3\uffff\3\51\2\uffff\2\51\1\uffff\3\51\12\42\1\51\1\uffff"+
            "\1\51\1\52\3\51\32\42\1\uffff\1\51\1\uffff\1\76\2\51\32\42\1"+
            "\uffff\1\51\1\uffff\1\51",
            "\1\51\3\uffff\3\51\2\uffff\2\51\1\uffff\3\51\12\42\1\51\1\uffff"+
            "\1\77\1\uffff\3\51\32\42\1\uffff\1\51\1\uffff\3\51\32\42\1\uffff"+
            "\1\51\1\uffff\1\51",
            "\1\51\3\uffff\3\51\2\uffff\2\51\1\uffff\3\51\12\42\1\51\1\uffff"+
            "\1\51\1\uffff\1\100\2\51\32\42\1\uffff\1\51\1\uffff\3\51\32"+
            "\42\1\uffff\1\51\1\uffff\1\51",
            "\1\51\3\uffff\1\51\1\101\1\51\2\uffff\2\51\1\uffff\3\51\12\42"+
            "\1\51\1\uffff\1\51\1\52\3\51\32\42\1\uffff\1\51\1\uffff\3\51"+
            "\32\42\1\uffff\1\51\1\uffff\1\51",
            "\1\51\3\uffff\3\51\2\uffff\2\51\1\uffff\3\51\12\42\1\51\1\uffff"+
            "\1\51\1\52\3\51\32\42\1\uffff\1\51\1\uffff\3\51\32\42\1\uffff"+
            "\1\102\1\uffff\1\51",
            "\1\50\3\uffff\3\50\2\uffff\2\50\1\uffff\3\50\12\uffff\1\50\1"+
            "\uffff\1\50\1\uffff\2\50\1\103\33\uffff\1\50\1\uffff\3\50\33"+
            "\uffff\1\50\1\uffff\1\50",
            "\1\50\3\uffff\3\50\2\uffff\2\50\1\uffff\3\50\12\uffff\1\50\1"+
            "\uffff\1\50\1\uffff\3\50\33\uffff\1\50\1\uffff\3\50\33\uffff"+
            "\1\50\1\uffff\1\50",
            "\1\50\3\uffff\3\50\2\uffff\2\50\1\uffff\3\50\12\uffff\1\50\1"+
            "\uffff\1\50\1\uffff\3\50\33\uffff\1\50\1\uffff\3\50\33\uffff"+
            "\1\50\1\uffff\1\50",
            "\1\50\3\uffff\3\50\2\uffff\2\50\1\uffff\3\50\12\uffff\1\50\1"+
            "\uffff\5\50\33\uffff\1\50\1\uffff\3\50\33\uffff\1\50\1\uffff"+
            "\1\50",
            "\1\50\3\uffff\3\50\2\uffff\2\50\1\uffff\3\50\12\uffff\1\50\1"+
            "\uffff\1\50\1\uffff\3\50\33\uffff\1\50\1\uffff\3\50\33\uffff"+
            "\1\50\1\uffff\1\50",
            "\1\105",
            "\1\51\3\uffff\3\51\2\uffff\2\51\1\uffff\3\51\12\42\1\51\1\uffff"+
            "\1\51\1\uffff\3\51\32\42\1\uffff\1\51\1\uffff\3\51\32\42\1\uffff"+
            "\1\51\1\uffff\1\106",
            "\1\50",
            "\1\44\26\uffff\1\51\3\uffff\3\51\2\uffff\2\51\1\uffff\3\51\12"+
            "\42\1\51\1\uffff\1\51\1\uffff\3\51\32\42\1\uffff\1\51\1\uffff"+
            "\3\51\32\42\1\uffff\1\51\1\uffff\1\51",
            "\1\110",
            "\1\111",
            "",
            "",
            "",
            "\1\51\3\uffff\3\51\2\uffff\2\51\1\uffff\3\51\12\42\1\51\1\uffff"+
            "\1\51\1\uffff\3\51\32\42\1\uffff\1\51\1\uffff\3\51\32\42\1\uffff"+
            "\1\51\1\uffff\1\51",
            "",
            "\1\51\3\uffff\3\51\2\uffff\2\51\1\uffff\3\51\12\42\1\51\1\uffff"+
            "\1\51\1\52\3\51\32\42\1\uffff\1\51\1\uffff\3\51\32\42\1\uffff"+
            "\1\51\1\uffff\1\51",
            "",
            "\1\51\3\uffff\3\51\2\uffff\2\51\1\uffff\3\51\12\42\1\51\1\uffff"+
            "\1\51\1\uffff\3\51\32\42\1\uffff\1\51\1\uffff\3\51\32\42\1\uffff"+
            "\1\51\1\uffff\1\51",
            "",
            "\1\51\3\uffff\3\51\2\uffff\2\51\1\uffff\3\51\12\42\1\51\1\uffff"+
            "\1\51\1\52\3\51\32\42\1\uffff\1\51\1\uffff\3\51\10\42\1\112"+
            "\3\42\1\112\12\42\1\112\2\42\1\uffff\1\51\1\uffff\1\51",
            "\41\60\1\57\3\60\3\57\2\60\2\57\1\60\2\57\1\113\12\55\1\57\1"+
            "\60\1\57\1\60\3\57\32\55\1\60\1\113\1\60\3\57\32\55\1\60\1\57"+
            "\1\60\1\57\uff80\60",
            "\41\60\1\55\3\60\3\55\2\60\2\55\1\60\2\55\1\114\13\55\1\60\1"+
            "\55\1\60\35\55\1\60\1\115\1\60\35\55\1\60\1\55\1\60\1\55\uff80"+
            "\60",
            "\uffff\60",
            "\41\60\1\57\3\60\3\57\2\60\2\57\1\60\2\57\1\116\12\55\1\57\1"+
            "\60\1\57\1\60\3\57\32\55\1\60\1\54\1\60\3\57\32\55\1\60\1\57"+
            "\1\60\1\57\uff80\60",
            "",
            "",
            "",
            "\1\51\3\uffff\3\51\2\uffff\2\51\1\uffff\3\51\12\42\1\51\1\uffff"+
            "\1\51\1\52\3\51\32\42\1\uffff\1\51\1\uffff\3\51\32\42\1\uffff"+
            "\1\51\1\uffff\1\51",
            "\1\42\3\uffff\3\42\2\uffff\2\42\1\uffff\1\42\1\72\1\42\12\65"+
            "\1\42\1\uffff\1\42\1\uffff\7\42\1\71\22\42\1\67\2\42\1\uffff"+
            "\1\42\1\uffff\7\42\1\71\22\42\1\67\2\42\1\uffff\1\42\1\uffff"+
            "\1\42",
            "\1\42\3\uffff\3\42\2\uffff\2\42\1\uffff\1\42\1\72\1\42\12\65"+
            "\1\42\1\uffff\1\42\1\uffff\7\42\1\71\25\42\1\uffff\1\42\1\uffff"+
            "\7\42\1\71\25\42\1\uffff\1\42\1\uffff\1\42",
            "\1\51\3\uffff\3\51\2\uffff\2\51\1\uffff\3\51\12\117\1\51\1\uffff"+
            "\1\51\1\uffff\3\51\32\42\1\uffff\1\51\1\uffff\3\51\32\42\1\uffff"+
            "\1\51\1\uffff\1\51",
            "\12\120\7\uffff\6\120\32\uffff\6\120",
            "",
            "\1\121\1\uffff\1\121\2\uffff\12\122",
            "\1\42\3\uffff\3\42\2\uffff\2\42\1\uffff\3\42\12\123\1\42\1\uffff"+
            "\1\42\1\uffff\7\42\1\124\25\42\1\uffff\1\42\1\uffff\7\42\1\124"+
            "\25\42\1\uffff\1\42\1\uffff\1\42",
            "",
            "\1\51\3\uffff\3\51\2\uffff\2\51\1\uffff\3\51\12\42\1\51\1\uffff"+
            "\1\51\1\52\3\51\32\42\1\uffff\1\51\1\uffff\3\51\32\42\1\uffff"+
            "\1\51\1\uffff\1\51",
            "\1\51\3\uffff\3\51\2\uffff\2\51\1\uffff\3\51\12\42\1\51\1\uffff"+
            "\1\51\1\52\3\51\32\42\1\uffff\1\51\1\uffff\3\51\32\42\1\uffff"+
            "\1\51\1\uffff\1\51",
            "\1\51\3\uffff\3\51\2\uffff\2\51\1\uffff\3\51\12\42\1\51\1\uffff"+
            "\1\51\1\52\3\51\32\42\1\uffff\1\51\1\uffff\3\51\32\42\1\uffff"+
            "\1\51\1\uffff\1\51",
            "\1\51\3\uffff\3\51\2\uffff\2\51\1\uffff\3\51\12\42\1\51\1\uffff"+
            "\1\51\1\52\3\51\32\42\1\uffff\1\51\1\uffff\3\51\32\42\1\uffff"+
            "\1\51\1\uffff\1\51",
            "\1\51\3\uffff\3\51\2\uffff\2\51\1\uffff\3\51\12\42\1\51\1\uffff"+
            "\1\51\1\52\3\51\32\42\1\uffff\1\51\1\uffff\3\51\32\42\1\uffff"+
            "\1\51\1\uffff\1\51",
            "\1\51\3\uffff\3\51\2\uffff\2\51\1\uffff\3\51\12\42\1\51\1\uffff"+
            "\1\51\1\52\3\51\32\42\1\uffff\1\51\1\uffff\3\51\32\42\1\uffff"+
            "\1\51\1\uffff\1\51",
            "\1\51\3\uffff\3\51\2\uffff\2\51\1\uffff\3\51\12\42\1\51\1\uffff"+
            "\1\51\1\52\3\51\32\42\1\uffff\1\51\1\uffff\3\51\32\42\1\uffff"+
            "\1\51\1\uffff\1\51",
            "\1\50\3\uffff\3\50\2\uffff\2\50\1\uffff\3\50\12\uffff\1\50\1"+
            "\uffff\1\50\1\uffff\3\50\33\uffff\1\50\1\uffff\3\50\33\uffff"+
            "\1\50\1\uffff\1\50",
            "",
            "\1\125",
            "\1\51\3\uffff\3\51\2\uffff\2\51\1\uffff\3\51\12\42\1\51\1\uffff"+
            "\1\51\1\uffff\3\51\32\42\1\uffff\1\51\1\uffff\3\51\32\42\1\uffff"+
            "\1\51\1\uffff\1\51",
            "",
            "\1\126",
            "\1\42\3\uffff\3\42\2\uffff\2\42\1\uffff\16\42\1\uffff\1\42\1"+
            "\uffff\35\42\1\uffff\1\42\1\uffff\35\42\1\uffff\1\42\1\uffff"+
            "\1\42",
            "\1\42\3\uffff\3\42\2\uffff\2\42\1\uffff\16\42\1\uffff\1\42\1"+
            "\uffff\35\42\1\uffff\1\42\1\uffff\13\42\1\112\3\42\1\112\12"+
            "\42\1\112\2\42\1\uffff\1\42\1\uffff\1\42",
            "\41\60\1\57\3\60\3\57\2\60\2\57\1\60\2\57\1\116\12\55\1\57\1"+
            "\60\1\57\1\60\3\57\32\55\1\60\1\54\1\60\3\57\32\55\1\60\1\57"+
            "\1\60\1\57\uff80\60",
            "\1\42\3\uffff\3\42\2\uffff\2\42\1\uffff\16\42\1\uffff\1\42\1"+
            "\uffff\35\42\1\uffff\1\42\1\uffff\13\42\1\112\3\42\1\112\12"+
            "\42\1\112\2\42\1\uffff\1\42\1\uffff\1\42",
            "\41\60\1\55\3\60\3\55\2\60\2\55\1\60\2\55\1\127\13\55\1\60\1"+
            "\55\1\60\35\55\1\60\1\127\1\60\35\55\1\60\1\55\1\60\1\55\uff80"+
            "\60",
            "\1\51\3\uffff\3\51\2\uffff\2\51\1\uffff\3\51\12\42\1\51\1\uffff"+
            "\1\51\1\uffff\3\51\32\42\1\uffff\1\51\1\uffff\3\51\10\42\1\112"+
            "\3\42\1\112\12\42\1\112\2\42\1\uffff\1\51\1\uffff\1\51",
            "\1\42\3\uffff\3\42\2\uffff\2\42\1\uffff\3\42\12\117\1\42\1\uffff"+
            "\1\42\1\uffff\7\42\1\130\25\42\1\uffff\1\42\1\uffff\7\42\1\130"+
            "\25\42\1\uffff\1\42\1\uffff\1\42",
            "\1\42\3\uffff\3\42\2\uffff\2\42\1\uffff\3\42\12\120\1\42\1\uffff"+
            "\1\42\1\uffff\3\42\6\120\24\42\1\uffff\1\42\1\uffff\3\42\6\120"+
            "\24\42\1\uffff\1\42\1\uffff\1\42",
            "\12\122",
            "\1\42\3\uffff\3\42\2\uffff\2\42\1\uffff\3\42\12\122\1\42\1\uffff"+
            "\1\42\1\uffff\35\42\1\uffff\1\42\1\uffff\35\42\1\uffff\1\42"+
            "\1\uffff\1\42",
            "\1\42\3\uffff\3\42\2\uffff\2\42\1\uffff\3\42\12\123\1\42\1\uffff"+
            "\1\42\1\uffff\7\42\1\124\25\42\1\uffff\1\42\1\uffff\7\42\1\124"+
            "\25\42\1\uffff\1\42\1\uffff\1\42",
            "\1\132\1\uffff\1\132\2\uffff\12\133",
            "\1\134",
            "\1\42\3\uffff\3\42\2\uffff\2\42\1\uffff\16\42\1\uffff\1\42\1"+
            "\uffff\35\42\1\uffff\1\42\1\uffff\35\42\1\uffff\1\42\1\uffff"+
            "\1\42",
            "\41\60\1\55\3\60\3\55\2\60\2\55\1\60\2\55\1\114\13\55\1\60\1"+
            "\55\1\60\35\55\1\60\1\115\1\60\35\55\1\60\1\55\1\60\1\55\uff80"+
            "\60",
            "\1\135\1\uffff\1\135\2\uffff\12\136",
            "",
            "\12\133",
            "\1\42\3\uffff\3\42\2\uffff\2\42\1\uffff\3\42\12\133\1\42\1\uffff"+
            "\1\42\1\uffff\35\42\1\uffff\1\42\1\uffff\35\42\1\uffff\1\42"+
            "\1\uffff\1\42",
            "\1\137",
            "\12\136",
            "\1\42\3\uffff\3\42\2\uffff\2\42\1\uffff\3\42\12\136\1\42\1\uffff"+
            "\1\42\1\uffff\35\42\1\uffff\1\42\1\uffff\35\42\1\uffff\1\42"+
            "\1\uffff\1\42",
            "\1\140",
            "\1\42\3\uffff\3\42\2\uffff\2\42\1\uffff\16\42\1\uffff\1\42\1"+
            "\uffff\35\42\1\uffff\1\42\1\uffff\35\42\1\uffff\1\42\1\uffff"+
            "\1\42"
    };

    static final short[] DFA30_eot = DFA.unpackEncodedString(DFA30_eotS);
    static final short[] DFA30_eof = DFA.unpackEncodedString(DFA30_eofS);
    static final char[] DFA30_min = DFA.unpackEncodedStringToUnsignedChars(DFA30_minS);
    static final char[] DFA30_max = DFA.unpackEncodedStringToUnsignedChars(DFA30_maxS);
    static final short[] DFA30_accept = DFA.unpackEncodedString(DFA30_acceptS);
    static final short[] DFA30_special = DFA.unpackEncodedString(DFA30_specialS);
    static final short[][] DFA30_transition;

    static {
        int numStates = DFA30_transitionS.length;
        DFA30_transition = new short[numStates][];
        for (int i=0; i<numStates; i++) {
            DFA30_transition[i] = DFA.unpackEncodedString(DFA30_transitionS[i]);
        }
    }

    class DFA30 extends DFA {

        public DFA30(BaseRecognizer recognizer) {
            this.recognizer = recognizer;
            this.decisionNumber = 30;
            this.eot = DFA30_eot;
            this.eof = DFA30_eof;
            this.min = DFA30_min;
            this.max = DFA30_max;
            this.accept = DFA30_accept;
            this.special = DFA30_special;
            this.transition = DFA30_transition;
        }
        public String getDescription() {
            return "1:1: Tokens : ( MultiString | SimpleString | Regexp | MultiComment | NewlineComment | OpenSimple | CloseSimple | OpenSquare | CloseSquare | OpenCurly | CloseCurly | Comma | HexInteger | Integer | Real | AssignmentOperator | UnaryOperator | BinaryOperator | Assignment | Identifier | PossibleTerminator | Whitespace );";
        }
    }
 

}