// $ANTLR 3.0.1 ioke.g 2008-04-09 11:22:43

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
    public static final int Assignment=27;
    public static final int CloseCurly=14;
    public static final int Exponent=21;
    public static final int OpChars=25;
    public static final int HexLetter=17;
    public static final int IdentChars=29;
    public static final int Digit=16;
    public static final int Tokens=35;
    public static final int EOF=-1;
    public static final int OpenSimple=9;
    public static final int IdentStart=28;
    public static final int Identifier=30;
    public static final int Separator=32;
    public static final int NewLine=7;
    public static final int AssignmentOperator=23;
    public static final int SimpleString=5;
    public static final int OpenSquare=11;
    public static final int Digits=20;
    public static final int CloseSimple=10;
    public static final int NewlineComment=8;
    public static final int HexInteger=18;
    public static final int Real=22;
    public static final int BinaryOperator=26;
    public static final int MultiComment=6;
    public static final int UnaryOperator=24;
    public static final int Whitespace=33;
    public static final int CloseSquare=12;
    public static final int OpenCurly=13;
    public static final int Comma=15;
    public static final int Letter=34;
    public static final int Integer=19;
    public static final int PossibleTerminator=31;

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
            case MultiString: return "MultiString";
            case SimpleString: return "SimpleString";
            case OpenSimple: return "OpenSimple";
            case CloseSimple: return "CloseSimple";
            case OpenSquare: return "OpenSquare";
            case CloseSquare: return "CloseSquare";
            case OpenCurly: return "OpenCurly";
            case CloseCurly: return "CloseCurly";
            case Comma: return "Comma";
            case Identifier: return "Identifier";
            case HexInteger: return "HexInteger";
            case Integer: return "Integer";
            case Real: return "Real";
            case Assignment: return "Assignment";
            case AssignmentOperator: return "AssignmentOperator";
            case UnaryOperator: return "UnaryOperator";
            case BinaryOperator: return "BinaryOperator";
            case PossibleTerminator: return "PossibleTerminator";
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
            // ioke.g:82:5: ( ( '%{' ( options {greedy=false; } : ( . )* ) '}' ) | ( '%[' ( options {greedy=false; } : ( . )* ) ']' ) )
            int alt3=2;
            int LA3_0 = input.LA(1);

            if ( (LA3_0=='%') ) {
                int LA3_1 = input.LA(2);

                if ( (LA3_1=='{') ) {
                    alt3=1;
                }
                else if ( (LA3_1=='[') ) {
                    alt3=2;
                }
                else {
                    NoViableAltException nvae =
                        new NoViableAltException("81:1: MultiString : ( ( '%{' ( options {greedy=false; } : ( . )* ) '}' ) | ( '%[' ( options {greedy=false; } : ( . )* ) ']' ) );", 3, 1, input);

                    throw nvae;
                }
            }
            else {
                NoViableAltException nvae =
                    new NoViableAltException("81:1: MultiString : ( ( '%{' ( options {greedy=false; } : ( . )* ) '}' ) | ( '%[' ( options {greedy=false; } : ( . )* ) ']' ) );", 3, 0, input);

                throw nvae;
            }
            switch (alt3) {
                case 1 :
                    // ioke.g:82:7: ( '%{' ( options {greedy=false; } : ( . )* ) '}' )
                    {
                    // ioke.g:82:7: ( '%{' ( options {greedy=false; } : ( . )* ) '}' )
                    // ioke.g:82:8: '%{' ( options {greedy=false; } : ( . )* ) '}'
                    {
                    match("%{"); 

                    // ioke.g:82:13: ( options {greedy=false; } : ( . )* )
                    // ioke.g:82:41: ( . )*
                    {
                    // ioke.g:82:41: ( . )*
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
                    	    // ioke.g:82:41: .
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
                    // ioke.g:83:7: ( '%[' ( options {greedy=false; } : ( . )* ) ']' )
                    {
                    // ioke.g:83:7: ( '%[' ( options {greedy=false; } : ( . )* ) ']' )
                    // ioke.g:83:8: '%[' ( options {greedy=false; } : ( . )* ) ']'
                    {
                    match("%["); 

                    // ioke.g:83:13: ( options {greedy=false; } : ( . )* )
                    // ioke.g:83:41: ( . )*
                    {
                    // ioke.g:83:41: ( . )*
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
                    	    // ioke.g:83:41: .
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
            // ioke.g:85:14: ( ( '\"' ( ( '\\\\' ( '\"' | '\\\\' ) ) | ( '\\\\' )? ~ ( '\"' | '\\\\' ) )* '\"' ) )
            // ioke.g:85:16: ( '\"' ( ( '\\\\' ( '\"' | '\\\\' ) ) | ( '\\\\' )? ~ ( '\"' | '\\\\' ) )* '\"' )
            {
            // ioke.g:85:16: ( '\"' ( ( '\\\\' ( '\"' | '\\\\' ) ) | ( '\\\\' )? ~ ( '\"' | '\\\\' ) )* '\"' )
            // ioke.g:85:17: '\"' ( ( '\\\\' ( '\"' | '\\\\' ) ) | ( '\\\\' )? ~ ( '\"' | '\\\\' ) )* '\"'
            {
            match('\"'); 
            // ioke.g:85:21: ( ( '\\\\' ( '\"' | '\\\\' ) ) | ( '\\\\' )? ~ ( '\"' | '\\\\' ) )*
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
            	    // ioke.g:85:23: ( '\\\\' ( '\"' | '\\\\' ) )
            	    {
            	    // ioke.g:85:23: ( '\\\\' ( '\"' | '\\\\' ) )
            	    // ioke.g:85:24: '\\\\' ( '\"' | '\\\\' )
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
            	    // ioke.g:85:43: ( '\\\\' )? ~ ( '\"' | '\\\\' )
            	    {
            	    // ioke.g:85:43: ( '\\\\' )?
            	    int alt4=2;
            	    int LA4_0 = input.LA(1);

            	    if ( (LA4_0=='\\') ) {
            	        alt4=1;
            	    }
            	    switch (alt4) {
            	        case 1 :
            	            // ioke.g:85:43: '\\\\'
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

    // $ANTLR start MultiComment
    public final void mMultiComment() throws RecognitionException {
        try {
            int _type = MultiComment;
            // ioke.g:87:14: ( ( '{#' ( options {greedy=false; } : ( . )* ) '#}' ) )
            // ioke.g:87:16: ( '{#' ( options {greedy=false; } : ( . )* ) '#}' )
            {
            // ioke.g:87:16: ( '{#' ( options {greedy=false; } : ( . )* ) '#}' )
            // ioke.g:87:17: '{#' ( options {greedy=false; } : ( . )* ) '#}'
            {
            match("{#"); 

            // ioke.g:87:22: ( options {greedy=false; } : ( . )* )
            // ioke.g:87:50: ( . )*
            {
            // ioke.g:87:50: ( . )*
            loop6:
            do {
                int alt6=2;
                int LA6_0 = input.LA(1);

                if ( (LA6_0=='#') ) {
                    int LA6_1 = input.LA(2);

                    if ( (LA6_1=='}') ) {
                        alt6=2;
                    }
                    else if ( ((LA6_1>='\u0000' && LA6_1<='|')||(LA6_1>='~' && LA6_1<='\uFFFE')) ) {
                        alt6=1;
                    }


                }
                else if ( ((LA6_0>='\u0000' && LA6_0<='\"')||(LA6_0>='$' && LA6_0<='\uFFFE')) ) {
                    alt6=1;
                }


                switch (alt6) {
            	case 1 :
            	    // ioke.g:87:50: .
            	    {
            	    matchAny(); 

            	    }
            	    break;

            	default :
            	    break loop6;
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
            // ioke.g:88:16: ( '#' (~ NewLine )* ( NewLine )? )
            // ioke.g:88:18: '#' (~ NewLine )* ( NewLine )?
            {
            match('#'); 
            // ioke.g:88:22: (~ NewLine )*
            loop7:
            do {
                int alt7=2;
                int LA7_0 = input.LA(1);

                if ( ((LA7_0>='\u0000' && LA7_0<='\t')||(LA7_0>='\u000B' && LA7_0<='\f')||(LA7_0>='\u000E' && LA7_0<='\uFFFE')) ) {
                    alt7=1;
                }


                switch (alt7) {
            	case 1 :
            	    // ioke.g:88:24: ~ NewLine
            	    {
            	    if ( (input.LA(1)>='\u0000' && input.LA(1)<='\u0006')||(input.LA(1)>='\b' && input.LA(1)<='\uFFFE') ) {
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

            // ioke.g:88:36: ( NewLine )?
            int alt8=2;
            int LA8_0 = input.LA(1);

            if ( (LA8_0=='\n'||LA8_0=='\r') ) {
                alt8=1;
            }
            switch (alt8) {
                case 1 :
                    // ioke.g:88:36: NewLine
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
            // ioke.g:90:12: ( '(' )
            // ioke.g:90:14: '('
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
            // ioke.g:91:13: ( ')' )
            // ioke.g:91:15: ')'
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
            // ioke.g:92:12: ( '[' )
            // ioke.g:92:14: '['
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
            // ioke.g:93:13: ( ']' )
            // ioke.g:93:15: ']'
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
            // ioke.g:94:11: ( '{' )
            // ioke.g:94:13: '{'
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
            // ioke.g:95:12: ( '}' )
            // ioke.g:95:14: '}'
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
            // ioke.g:97:7: ( ( ',' ( NewLine )* ) )
            // ioke.g:97:9: ( ',' ( NewLine )* )
            {
            // ioke.g:97:9: ( ',' ( NewLine )* )
            // ioke.g:97:10: ',' ( NewLine )*
            {
            match(','); 
            // ioke.g:97:14: ( NewLine )*
            loop9:
            do {
                int alt9=2;
                int LA9_0 = input.LA(1);

                if ( (LA9_0=='\n'||LA9_0=='\r') ) {
                    alt9=1;
                }


                switch (alt9) {
            	case 1 :
            	    // ioke.g:97:14: NewLine
            	    {
            	    mNewLine(); 

            	    }
            	    break;

            	default :
            	    break loop9;
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
            // ioke.g:99:12: ( ( '+' | '-' )? '0' ( 'x' | 'X' ) ( Digit | HexLetter | '_' )+ )
            // ioke.g:99:14: ( '+' | '-' )? '0' ( 'x' | 'X' ) ( Digit | HexLetter | '_' )+
            {
            // ioke.g:99:14: ( '+' | '-' )?
            int alt10=2;
            int LA10_0 = input.LA(1);

            if ( (LA10_0=='+'||LA10_0=='-') ) {
                alt10=1;
            }
            switch (alt10) {
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

            // ioke.g:99:41: ( Digit | HexLetter | '_' )+
            int cnt11=0;
            loop11:
            do {
                int alt11=2;
                int LA11_0 = input.LA(1);

                if ( ((LA11_0>='0' && LA11_0<='9')||(LA11_0>='A' && LA11_0<='F')||LA11_0=='_'||(LA11_0>='a' && LA11_0<='f')) ) {
                    alt11=1;
                }


                switch (alt11) {
            	case 1 :
            	    // ioke.g:
            	    {
            	    if ( (input.LA(1)>='0' && input.LA(1)<='9')||(input.LA(1)>='A' && input.LA(1)<='F')||input.LA(1)=='_'||(input.LA(1)>='a' && input.LA(1)<='f') ) {
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
            	    if ( cnt11 >= 1 ) break loop11;
                        EarlyExitException eee =
                            new EarlyExitException(11, input);
                        throw eee;
                }
                cnt11++;
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
            // ioke.g:101:9: ( ( '+' | '-' )? Digit ( Digit | '_' )* )
            // ioke.g:101:11: ( '+' | '-' )? Digit ( Digit | '_' )*
            {
            // ioke.g:101:11: ( '+' | '-' )?
            int alt12=2;
            int LA12_0 = input.LA(1);

            if ( (LA12_0=='+'||LA12_0=='-') ) {
                alt12=1;
            }
            switch (alt12) {
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

            mDigit(); 
            // ioke.g:101:28: ( Digit | '_' )*
            loop13:
            do {
                int alt13=2;
                int LA13_0 = input.LA(1);

                if ( ((LA13_0>='0' && LA13_0<='9')||LA13_0=='_') ) {
                    alt13=1;
                }


                switch (alt13) {
            	case 1 :
            	    // ioke.g:
            	    {
            	    if ( (input.LA(1)>='0' && input.LA(1)<='9')||input.LA(1)=='_' ) {
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
            	    break loop13;
                }
            } while (true);


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
            // ioke.g:104:5: ( ( '+' | '-' )? ( Digits '.' ( Digit )* ( Exponent )? | '.' Digits ( Exponent )? | Digits Exponent ) )
            // ioke.g:104:9: ( '+' | '-' )? ( Digits '.' ( Digit )* ( Exponent )? | '.' Digits ( Exponent )? | Digits Exponent )
            {
            // ioke.g:104:9: ( '+' | '-' )?
            int alt14=2;
            int LA14_0 = input.LA(1);

            if ( (LA14_0=='+'||LA14_0=='-') ) {
                alt14=1;
            }
            switch (alt14) {
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

            // ioke.g:105:9: ( Digits '.' ( Digit )* ( Exponent )? | '.' Digits ( Exponent )? | Digits Exponent )
            int alt18=3;
            alt18 = dfa18.predict(input);
            switch (alt18) {
                case 1 :
                    // ioke.g:105:10: Digits '.' ( Digit )* ( Exponent )?
                    {
                    mDigits(); 
                    match('.'); 
                    // ioke.g:105:21: ( Digit )*
                    loop15:
                    do {
                        int alt15=2;
                        int LA15_0 = input.LA(1);

                        if ( ((LA15_0>='0' && LA15_0<='9')) ) {
                            alt15=1;
                        }


                        switch (alt15) {
                    	case 1 :
                    	    // ioke.g:105:21: Digit
                    	    {
                    	    mDigit(); 

                    	    }
                    	    break;

                    	default :
                    	    break loop15;
                        }
                    } while (true);

                    // ioke.g:105:28: ( Exponent )?
                    int alt16=2;
                    int LA16_0 = input.LA(1);

                    if ( (LA16_0=='E'||LA16_0=='e') ) {
                        alt16=1;
                    }
                    switch (alt16) {
                        case 1 :
                            // ioke.g:105:28: Exponent
                            {
                            mExponent(); 

                            }
                            break;

                    }


                    }
                    break;
                case 2 :
                    // ioke.g:106:10: '.' Digits ( Exponent )?
                    {
                    match('.'); 
                    mDigits(); 
                    // ioke.g:106:21: ( Exponent )?
                    int alt17=2;
                    int LA17_0 = input.LA(1);

                    if ( (LA17_0=='E'||LA17_0=='e') ) {
                        alt17=1;
                    }
                    switch (alt17) {
                        case 1 :
                            // ioke.g:106:21: Exponent
                            {
                            mExponent(); 

                            }
                            break;

                    }


                    }
                    break;
                case 3 :
                    // ioke.g:107:10: Digits Exponent
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
            // ioke.g:110:20: ( ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<<' | '>>' | '&' | '&&' | '|' | '||' ) '=' )
            // ioke.g:111:9: ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<<' | '>>' | '&' | '&&' | '|' | '||' ) '='
            {
            // ioke.g:111:9: ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<<' | '>>' | '&' | '&&' | '|' | '||' )
            int alt19=18;
            switch ( input.LA(1) ) {
            case '+':
                {
                int LA19_1 = input.LA(2);

                if ( (LA19_1=='+') ) {
                    alt19=2;
                }
                else if ( (LA19_1=='=') ) {
                    alt19=1;
                }
                else {
                    NoViableAltException nvae =
                        new NoViableAltException("111:9: ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<<' | '>>' | '&' | '&&' | '|' | '||' )", 19, 1, input);

                    throw nvae;
                }
                }
                break;
            case '-':
                {
                int LA19_2 = input.LA(2);

                if ( (LA19_2=='-') ) {
                    alt19=4;
                }
                else if ( (LA19_2=='=') ) {
                    alt19=3;
                }
                else {
                    NoViableAltException nvae =
                        new NoViableAltException("111:9: ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<<' | '>>' | '&' | '&&' | '|' | '||' )", 19, 2, input);

                    throw nvae;
                }
                }
                break;
            case '/':
                {
                int LA19_3 = input.LA(2);

                if ( (LA19_3=='/') ) {
                    alt19=6;
                }
                else if ( (LA19_3=='=') ) {
                    alt19=5;
                }
                else {
                    NoViableAltException nvae =
                        new NoViableAltException("111:9: ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<<' | '>>' | '&' | '&&' | '|' | '||' )", 19, 3, input);

                    throw nvae;
                }
                }
                break;
            case '*':
                {
                int LA19_4 = input.LA(2);

                if ( (LA19_4=='*') ) {
                    alt19=8;
                }
                else if ( (LA19_4=='=') ) {
                    alt19=7;
                }
                else {
                    NoViableAltException nvae =
                        new NoViableAltException("111:9: ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<<' | '>>' | '&' | '&&' | '|' | '||' )", 19, 4, input);

                    throw nvae;
                }
                }
                break;
            case '%':
                {
                int LA19_5 = input.LA(2);

                if ( (LA19_5=='%') ) {
                    alt19=10;
                }
                else if ( (LA19_5=='=') ) {
                    alt19=9;
                }
                else {
                    NoViableAltException nvae =
                        new NoViableAltException("111:9: ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<<' | '>>' | '&' | '&&' | '|' | '||' )", 19, 5, input);

                    throw nvae;
                }
                }
                break;
            case '^':
                {
                int LA19_6 = input.LA(2);

                if ( (LA19_6=='^') ) {
                    alt19=12;
                }
                else if ( (LA19_6=='=') ) {
                    alt19=11;
                }
                else {
                    NoViableAltException nvae =
                        new NoViableAltException("111:9: ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<<' | '>>' | '&' | '&&' | '|' | '||' )", 19, 6, input);

                    throw nvae;
                }
                }
                break;
            case '<':
                {
                alt19=13;
                }
                break;
            case '>':
                {
                alt19=14;
                }
                break;
            case '&':
                {
                int LA19_9 = input.LA(2);

                if ( (LA19_9=='&') ) {
                    alt19=16;
                }
                else if ( (LA19_9=='=') ) {
                    alt19=15;
                }
                else {
                    NoViableAltException nvae =
                        new NoViableAltException("111:9: ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<<' | '>>' | '&' | '&&' | '|' | '||' )", 19, 9, input);

                    throw nvae;
                }
                }
                break;
            case '|':
                {
                int LA19_10 = input.LA(2);

                if ( (LA19_10=='|') ) {
                    alt19=18;
                }
                else if ( (LA19_10=='=') ) {
                    alt19=17;
                }
                else {
                    NoViableAltException nvae =
                        new NoViableAltException("111:9: ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<<' | '>>' | '&' | '&&' | '|' | '||' )", 19, 10, input);

                    throw nvae;
                }
                }
                break;
            default:
                NoViableAltException nvae =
                    new NoViableAltException("111:9: ( '+' | '++' | '-' | '--' | '/' | '//' | '*' | '**' | '%' | '%%' | '^' | '^^' | '<<' | '>>' | '&' | '&&' | '|' | '||' )", 19, 0, input);

                throw nvae;
            }

            switch (alt19) {
                case 1 :
                    // ioke.g:111:10: '+'
                    {
                    match('+'); 

                    }
                    break;
                case 2 :
                    // ioke.g:112:11: '++'
                    {
                    match("++"); 


                    }
                    break;
                case 3 :
                    // ioke.g:113:11: '-'
                    {
                    match('-'); 

                    }
                    break;
                case 4 :
                    // ioke.g:114:11: '--'
                    {
                    match("--"); 


                    }
                    break;
                case 5 :
                    // ioke.g:115:11: '/'
                    {
                    match('/'); 

                    }
                    break;
                case 6 :
                    // ioke.g:116:11: '//'
                    {
                    match("//"); 


                    }
                    break;
                case 7 :
                    // ioke.g:117:11: '*'
                    {
                    match('*'); 

                    }
                    break;
                case 8 :
                    // ioke.g:118:11: '**'
                    {
                    match("**"); 


                    }
                    break;
                case 9 :
                    // ioke.g:119:11: '%'
                    {
                    match('%'); 

                    }
                    break;
                case 10 :
                    // ioke.g:120:11: '%%'
                    {
                    match("%%"); 


                    }
                    break;
                case 11 :
                    // ioke.g:121:11: '^'
                    {
                    match('^'); 

                    }
                    break;
                case 12 :
                    // ioke.g:122:11: '^^'
                    {
                    match("^^"); 


                    }
                    break;
                case 13 :
                    // ioke.g:123:11: '<<'
                    {
                    match("<<"); 


                    }
                    break;
                case 14 :
                    // ioke.g:124:11: '>>'
                    {
                    match(">>"); 


                    }
                    break;
                case 15 :
                    // ioke.g:125:11: '&'
                    {
                    match('&'); 

                    }
                    break;
                case 16 :
                    // ioke.g:126:11: '&&'
                    {
                    match("&&"); 


                    }
                    break;
                case 17 :
                    // ioke.g:127:11: '|'
                    {
                    match('|'); 

                    }
                    break;
                case 18 :
                    // ioke.g:128:11: '||'
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
            // ioke.g:131:15: ( '@' | '@@' | '\\'' | '`' | '!' | ':' | 'return' )
            int alt20=7;
            switch ( input.LA(1) ) {
            case '@':
                {
                int LA20_1 = input.LA(2);

                if ( (LA20_1=='@') ) {
                    alt20=2;
                }
                else {
                    alt20=1;}
                }
                break;
            case '\'':
                {
                alt20=3;
                }
                break;
            case '`':
                {
                alt20=4;
                }
                break;
            case '!':
                {
                alt20=5;
                }
                break;
            case ':':
                {
                alt20=6;
                }
                break;
            case 'r':
                {
                alt20=7;
                }
                break;
            default:
                NoViableAltException nvae =
                    new NoViableAltException("131:1: UnaryOperator : ( '@' | '@@' | '\\'' | '`' | '!' | ':' | 'return' );", 20, 0, input);

                throw nvae;
            }

            switch (alt20) {
                case 1 :
                    // ioke.g:132:7: '@'
                    {
                    match('@'); 

                    }
                    break;
                case 2 :
                    // ioke.g:133:7: '@@'
                    {
                    match("@@"); 


                    }
                    break;
                case 3 :
                    // ioke.g:134:7: '\\''
                    {
                    match('\''); 

                    }
                    break;
                case 4 :
                    // ioke.g:135:7: '`'
                    {
                    match('`'); 

                    }
                    break;
                case 5 :
                    // ioke.g:136:7: '!'
                    {
                    match('!'); 

                    }
                    break;
                case 6 :
                    // ioke.g:137:7: ':'
                    {
                    match(':'); 

                    }
                    break;
                case 7 :
                    // ioke.g:138:7: 'return'
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
            // ioke.g:141:16: ( ( OpChars )+ | '==' | '===' | '====' | '<=' | '>=' | '~=' | '~~=' | '!=' | '!!=' | 'and' | 'or' )
            int alt22=12;
            switch ( input.LA(1) ) {
            case '<':
                {
                int LA22_1 = input.LA(2);

                if ( (LA22_1=='=') ) {
                    alt22=5;
                }
                else {
                    alt22=1;}
                }
                break;
            case '=':
                {
                int LA22_2 = input.LA(2);

                if ( (LA22_2=='=') ) {
                    int LA22_10 = input.LA(3);

                    if ( (LA22_10=='=') ) {
                        int LA22_16 = input.LA(4);

                        if ( (LA22_16=='=') ) {
                            alt22=4;
                        }
                        else {
                            alt22=3;}
                    }
                    else {
                        alt22=2;}
                }
                else {
                    NoViableAltException nvae =
                        new NoViableAltException("141:1: BinaryOperator : ( ( OpChars )+ | '==' | '===' | '====' | '<=' | '>=' | '~=' | '~~=' | '!=' | '!!=' | 'and' | 'or' );", 22, 2, input);

                    throw nvae;
                }
                }
                break;
            case '>':
                {
                int LA22_3 = input.LA(2);

                if ( (LA22_3=='=') ) {
                    alt22=6;
                }
                else {
                    alt22=1;}
                }
                break;
            case '~':
                {
                switch ( input.LA(2) ) {
                case '~':
                    {
                    int LA22_12 = input.LA(3);

                    if ( (LA22_12=='=') ) {
                        alt22=8;
                    }
                    else {
                        alt22=1;}
                    }
                    break;
                case '=':
                    {
                    alt22=7;
                    }
                    break;
                default:
                    alt22=1;}

                }
                break;
            case '!':
                {
                switch ( input.LA(2) ) {
                case '=':
                    {
                    alt22=9;
                    }
                    break;
                case '!':
                    {
                    int LA22_15 = input.LA(3);

                    if ( (LA22_15=='=') ) {
                        alt22=10;
                    }
                    else {
                        alt22=1;}
                    }
                    break;
                default:
                    alt22=1;}

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
                alt22=1;
                }
                break;
            case 'a':
                {
                alt22=11;
                }
                break;
            case 'o':
                {
                alt22=12;
                }
                break;
            default:
                NoViableAltException nvae =
                    new NoViableAltException("141:1: BinaryOperator : ( ( OpChars )+ | '==' | '===' | '====' | '<=' | '>=' | '~=' | '~~=' | '!=' | '!!=' | 'and' | 'or' );", 22, 0, input);

                throw nvae;
            }

            switch (alt22) {
                case 1 :
                    // ioke.g:142:7: ( OpChars )+
                    {
                    // ioke.g:142:7: ( OpChars )+
                    int cnt21=0;
                    loop21:
                    do {
                        int alt21=2;
                        int LA21_0 = input.LA(1);

                        if ( (LA21_0=='!'||(LA21_0>='%' && LA21_0<='\'')||(LA21_0>='*' && LA21_0<='+')||(LA21_0>='-' && LA21_0<='/')||LA21_0==':'||LA21_0=='<'||(LA21_0>='>' && LA21_0<='@')||LA21_0=='\\'||(LA21_0>='^' && LA21_0<='`')||LA21_0=='|'||LA21_0=='~') ) {
                            alt21=1;
                        }


                        switch (alt21) {
                    	case 1 :
                    	    // ioke.g:142:7: OpChars
                    	    {
                    	    mOpChars(); 

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
                    break;
                case 2 :
                    // ioke.g:143:7: '=='
                    {
                    match("=="); 


                    }
                    break;
                case 3 :
                    // ioke.g:144:7: '==='
                    {
                    match("==="); 


                    }
                    break;
                case 4 :
                    // ioke.g:145:7: '===='
                    {
                    match("===="); 


                    }
                    break;
                case 5 :
                    // ioke.g:146:7: '<='
                    {
                    match("<="); 


                    }
                    break;
                case 6 :
                    // ioke.g:147:7: '>='
                    {
                    match(">="); 


                    }
                    break;
                case 7 :
                    // ioke.g:148:7: '~='
                    {
                    match("~="); 


                    }
                    break;
                case 8 :
                    // ioke.g:149:7: '~~='
                    {
                    match("~~="); 


                    }
                    break;
                case 9 :
                    // ioke.g:150:7: '!='
                    {
                    match("!="); 


                    }
                    break;
                case 10 :
                    // ioke.g:151:7: '!!='
                    {
                    match("!!="); 


                    }
                    break;
                case 11 :
                    // ioke.g:152:7: 'and'
                    {
                    match("and"); 


                    }
                    break;
                case 12 :
                    // ioke.g:153:7: 'or'
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
            // ioke.g:156:12: ( '=' )
            // ioke.g:156:14: '='
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
            // ioke.g:158:12: ( IdentStart ( IdentChars )* )
            // ioke.g:158:14: IdentStart ( IdentChars )*
            {
            mIdentStart(); 
            // ioke.g:158:25: ( IdentChars )*
            loop23:
            do {
                int alt23=2;
                int LA23_0 = input.LA(1);

                if ( (LA23_0=='!'||(LA23_0>='%' && LA23_0<='\'')||(LA23_0>='*' && LA23_0<='+')||(LA23_0>='-' && LA23_0<=':')||LA23_0=='<'||(LA23_0>='>' && LA23_0<='Z')||LA23_0=='\\'||(LA23_0>='^' && LA23_0<='z')||LA23_0=='|'||LA23_0=='~') ) {
                    alt23=1;
                }


                switch (alt23) {
            	case 1 :
            	    // ioke.g:158:25: IdentChars
            	    {
            	    mIdentChars(); 

            	    }
            	    break;

            	default :
            	    break loop23;
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
            // ioke.g:160:20: ( ( ( ';' | NewLine )+ ) )
            // ioke.g:160:22: ( ( ';' | NewLine )+ )
            {
            // ioke.g:160:22: ( ( ';' | NewLine )+ )
            // ioke.g:160:23: ( ';' | NewLine )+
            {
            // ioke.g:160:23: ( ';' | NewLine )+
            int cnt24=0;
            loop24:
            do {
                int alt24=2;
                int LA24_0 = input.LA(1);

                if ( (LA24_0=='\n'||LA24_0=='\r'||LA24_0==';') ) {
                    alt24=1;
                }


                switch (alt24) {
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
            	    if ( cnt24 >= 1 ) break loop24;
                        EarlyExitException eee =
                            new EarlyExitException(24, input);
                        throw eee;
                }
                cnt24++;
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
            // ioke.g:162:12: ( Separator )
            // ioke.g:162:14: Separator
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
            // ioke.g:166:10: ( ( 'e' | 'E' ) ( '+' | '-' )? Digits )
            // ioke.g:166:12: ( 'e' | 'E' ) ( '+' | '-' )? Digits
            {
            if ( input.LA(1)=='E'||input.LA(1)=='e' ) {
                input.consume();

            }
            else {
                MismatchedSetException mse =
                    new MismatchedSetException(null,input);
                recover(mse);    throw mse;
            }

            // ioke.g:166:22: ( '+' | '-' )?
            int alt25=2;
            int LA25_0 = input.LA(1);

            if ( (LA25_0=='+'||LA25_0=='-') ) {
                alt25=1;
            }
            switch (alt25) {
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
            // ioke.g:169:8: ( 'a' .. 'z' | 'A' .. 'Z' )
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
            // ioke.g:172:7: ( '0' .. '9' )
            // ioke.g:172:9: '0' .. '9'
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
            // ioke.g:175:8: ( ( Digit )+ )
            // ioke.g:175:10: ( Digit )+
            {
            // ioke.g:175:10: ( Digit )+
            int cnt26=0;
            loop26:
            do {
                int alt26=2;
                int LA26_0 = input.LA(1);

                if ( ((LA26_0>='0' && LA26_0<='9')) ) {
                    alt26=1;
                }


                switch (alt26) {
            	case 1 :
            	    // ioke.g:175:10: Digit
            	    {
            	    mDigit(); 

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

        }
        finally {
        }
    }
    // $ANTLR end Digits

    // $ANTLR start HexLetter
    public final void mHexLetter() throws RecognitionException {
        try {
            // ioke.g:178:11: ( 'a' .. 'f' | 'A' .. 'F' )
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
            // ioke.g:181:11: ( ( ' ' | '\\u000c' | '\\u0009' | '\\u000b' | '\\\\' '\\u000a' )+ )
            // ioke.g:181:13: ( ' ' | '\\u000c' | '\\u0009' | '\\u000b' | '\\\\' '\\u000a' )+
            {
            // ioke.g:181:13: ( ' ' | '\\u000c' | '\\u0009' | '\\u000b' | '\\\\' '\\u000a' )+
            int cnt27=0;
            loop27:
            do {
                int alt27=6;
                switch ( input.LA(1) ) {
                case ' ':
                    {
                    alt27=1;
                    }
                    break;
                case '\f':
                    {
                    alt27=2;
                    }
                    break;
                case '\t':
                    {
                    alt27=3;
                    }
                    break;
                case '\u000B':
                    {
                    alt27=4;
                    }
                    break;
                case '\\':
                    {
                    alt27=5;
                    }
                    break;

                }

                switch (alt27) {
            	case 1 :
            	    // ioke.g:181:14: ' '
            	    {
            	    match(' '); 

            	    }
            	    break;
            	case 2 :
            	    // ioke.g:181:20: '\\u000c'
            	    {
            	    match('\f'); 

            	    }
            	    break;
            	case 3 :
            	    // ioke.g:181:31: '\\u0009'
            	    {
            	    match('\t'); 

            	    }
            	    break;
            	case 4 :
            	    // ioke.g:181:42: '\\u000b'
            	    {
            	    match('\u000B'); 

            	    }
            	    break;
            	case 5 :
            	    // ioke.g:181:53: '\\\\' '\\u000a'
            	    {
            	    match('\\'); 
            	    match('\n'); 

            	    }
            	    break;

            	default :
            	    if ( cnt27 >= 1 ) break loop27;
                        EarlyExitException eee =
                            new EarlyExitException(27, input);
                        throw eee;
                }
                cnt27++;
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
            // ioke.g:184:9: ( ( '!' | '?' | '@' | '&' | '%' | '.' | '|' | '<' | '>' | '/' | '+' | '-' | '_' | ':' | '\\\\' | '*' | '^' | '~' | '`' | '\\'' ) )
            // ioke.g:184:11: ( '!' | '?' | '@' | '&' | '%' | '.' | '|' | '<' | '>' | '/' | '+' | '-' | '_' | ':' | '\\\\' | '*' | '^' | '~' | '`' | '\\'' )
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
            // ioke.g:187:12: ( Letter | Digit | ( '!' | '?' | '@' | '&' | '%' | '.' | '|' | '<' | '>' | '/' | '+' | '-' | '_' | ':' | '\\\\' | '*' | '^' | '~' | '`' | '\\'' ) )
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
            // ioke.g:190:12: ( Letter | Digit | ( '?' | '&' | '%' | '|' | '<' | '>' | '/' | '+' | '-' | '_' | '\\\\' | '*' | '^' | '~' ) )
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
            // ioke.g:193:9: ( ( '\\u000a' | '\\u000d' ) )
            // ioke.g:193:11: ( '\\u000a' | '\\u000d' )
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
        // ioke.g:1:8: ( MultiString | SimpleString | MultiComment | NewlineComment | OpenSimple | CloseSimple | OpenSquare | CloseSquare | OpenCurly | CloseCurly | Comma | HexInteger | Integer | Real | AssignmentOperator | UnaryOperator | BinaryOperator | Assignment | Identifier | PossibleTerminator | Whitespace )
        int alt28=21;
        alt28 = dfa28.predict(input);
        switch (alt28) {
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
                // ioke.g:1:35: MultiComment
                {
                mMultiComment(); 

                }
                break;
            case 4 :
                // ioke.g:1:48: NewlineComment
                {
                mNewlineComment(); 

                }
                break;
            case 5 :
                // ioke.g:1:63: OpenSimple
                {
                mOpenSimple(); 

                }
                break;
            case 6 :
                // ioke.g:1:74: CloseSimple
                {
                mCloseSimple(); 

                }
                break;
            case 7 :
                // ioke.g:1:86: OpenSquare
                {
                mOpenSquare(); 

                }
                break;
            case 8 :
                // ioke.g:1:97: CloseSquare
                {
                mCloseSquare(); 

                }
                break;
            case 9 :
                // ioke.g:1:109: OpenCurly
                {
                mOpenCurly(); 

                }
                break;
            case 10 :
                // ioke.g:1:119: CloseCurly
                {
                mCloseCurly(); 

                }
                break;
            case 11 :
                // ioke.g:1:130: Comma
                {
                mComma(); 

                }
                break;
            case 12 :
                // ioke.g:1:136: HexInteger
                {
                mHexInteger(); 

                }
                break;
            case 13 :
                // ioke.g:1:147: Integer
                {
                mInteger(); 

                }
                break;
            case 14 :
                // ioke.g:1:155: Real
                {
                mReal(); 

                }
                break;
            case 15 :
                // ioke.g:1:160: AssignmentOperator
                {
                mAssignmentOperator(); 

                }
                break;
            case 16 :
                // ioke.g:1:179: UnaryOperator
                {
                mUnaryOperator(); 

                }
                break;
            case 17 :
                // ioke.g:1:193: BinaryOperator
                {
                mBinaryOperator(); 

                }
                break;
            case 18 :
                // ioke.g:1:208: Assignment
                {
                mAssignment(); 

                }
                break;
            case 19 :
                // ioke.g:1:219: Identifier
                {
                mIdentifier(); 

                }
                break;
            case 20 :
                // ioke.g:1:230: PossibleTerminator
                {
                mPossibleTerminator(); 

                }
                break;
            case 21 :
                // ioke.g:1:249: Whitespace
                {
                mWhitespace(); 

                }
                break;

        }

    }


    protected DFA18 dfa18 = new DFA18(this);
    protected DFA28 dfa28 = new DFA28(this);
    static final String DFA18_eotS =
        "\5\uffff";
    static final String DFA18_eofS =
        "\5\uffff";
    static final String DFA18_minS =
        "\2\56\3\uffff";
    static final String DFA18_maxS =
        "\1\71\1\145\3\uffff";
    static final String DFA18_acceptS =
        "\2\uffff\1\2\1\3\1\1";
    static final String DFA18_specialS =
        "\5\uffff}>";
    static final String[] DFA18_transitionS = {
            "\1\2\1\uffff\12\1",
            "\1\4\1\uffff\12\1\13\uffff\1\3\37\uffff\1\3",
            "",
            "",
            ""
    };

    static final short[] DFA18_eot = DFA.unpackEncodedString(DFA18_eotS);
    static final short[] DFA18_eof = DFA.unpackEncodedString(DFA18_eofS);
    static final char[] DFA18_min = DFA.unpackEncodedStringToUnsignedChars(DFA18_minS);
    static final char[] DFA18_max = DFA.unpackEncodedStringToUnsignedChars(DFA18_maxS);
    static final short[] DFA18_accept = DFA.unpackEncodedString(DFA18_acceptS);
    static final short[] DFA18_special = DFA.unpackEncodedString(DFA18_specialS);
    static final short[][] DFA18_transition;

    static {
        int numStates = DFA18_transitionS.length;
        DFA18_transition = new short[numStates][];
        for (int i=0; i<numStates; i++) {
            DFA18_transition[i] = DFA.unpackEncodedString(DFA18_transitionS[i]);
        }
    }

    class DFA18 extends DFA {

        public DFA18(BaseRecognizer recognizer) {
            this.recognizer = recognizer;
            this.decisionNumber = 18;
            this.eot = DFA18_eot;
            this.eof = DFA18_eof;
            this.min = DFA18_min;
            this.max = DFA18_max;
            this.accept = DFA18_accept;
            this.special = DFA18_special;
            this.transition = DFA18_transition;
        }
        public String getDescription() {
            return "105:9: ( Digits '.' ( Digit )* ( Exponent )? | '.' Digits ( Exponent )? | Digits Exponent )";
        }
    }
    static final String DFA28_eotS =
        "\1\uffff\1\50\1\uffff\1\54\7\uffff\1\50\2\62\11\50\5\101\1\42\1"+
        "\50\1\104\1\50\2\42\3\uffff\1\50\1\uffff\1\50\1\uffff\1\50\3\uffff"+
        "\1\50\1\62\1\50\1\62\1\42\1\uffff\1\67\2\62\1\42\1\uffff\10\50\1"+
        "\101\1\uffff\1\42\1\50\1\uffff\1\42\1\50\1\67\1\120\1\67\2\42\1"+
        "\67\1\42\1\50\1\42\1\uffff\1\42\1\67\2\42\1\67\1\42\1\101";
    static final String DFA28_eofS =
        "\130\uffff";
    static final String DFA28_minS =
        "\1\11\1\41\1\uffff\1\43\7\uffff\3\41\1\60\15\41\1\145\1\41\1\75"+
        "\1\12\1\156\1\162\3\uffff\1\41\1\uffff\1\41\1\uffff\1\41\3\uffff"+
        "\4\41\1\60\1\uffff\3\41\1\53\1\uffff\11\41\1\uffff\1\164\1\41\1"+
        "\uffff\1\144\4\41\1\53\1\60\1\41\1\165\1\41\1\53\1\uffff\1\60\1"+
        "\41\1\162\1\60\1\41\1\156\1\41";
    static final String DFA28_maxS =
        "\2\176\1\uffff\1\43\7\uffff\3\176\1\71\15\176\1\145\1\176\1\75\1"+
        "\176\1\156\1\162\3\uffff\1\176\1\uffff\1\176\1\uffff\1\176\3\uffff"+
        "\4\176\1\146\1\uffff\3\176\1\71\1\uffff\11\176\1\uffff\1\164\1\176"+
        "\1\uffff\1\144\4\176\2\71\1\176\1\165\1\176\1\71\1\uffff\1\71\1"+
        "\176\1\162\1\71\1\176\1\156\1\176";
    static final String DFA28_acceptS =
        "\2\uffff\1\2\1\uffff\1\4\1\5\1\6\1\7\1\10\1\12\1\13\27\uffff\1\23"+
        "\1\24\1\25\1\uffff\1\1\1\uffff\1\21\1\uffff\1\17\1\3\1\11\5\uffff"+
        "\1\15\4\uffff\1\16\11\uffff\1\20\2\uffff\1\22\13\uffff\1\14\7\uffff";
    static final String DFA28_specialS =
        "\130\uffff}>";
    static final String[] DFA28_transitionS = {
            "\1\44\1\43\2\44\1\43\22\uffff\1\44\1\32\1\2\1\4\1\uffff\1\1"+
            "\1\25\1\30\1\5\1\6\1\21\1\13\1\12\1\17\1\16\1\20\1\14\11\15"+
            "\1\33\1\43\1\23\1\36\1\24\1\45\1\27\32\42\1\7\1\37\1\10\1\22"+
            "\1\45\1\31\1\40\15\42\1\41\2\42\1\34\10\42\1\3\1\26\1\11\1\35",
            "\1\51\3\uffff\1\47\2\51\2\uffff\2\51\1\uffff\3\51\12\42\1\51"+
            "\1\uffff\1\51\1\52\3\51\32\42\1\46\1\51\1\uffff\3\51\32\42\1"+
            "\46\1\51\1\uffff\1\51",
            "",
            "\1\53",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "\1\51\3\uffff\3\51\2\uffff\1\51\1\55\1\uffff\1\51\1\57\1\51"+
            "\1\56\11\60\1\51\1\uffff\1\51\1\52\3\51\32\42\1\uffff\1\51\1"+
            "\uffff\3\51\32\42\1\uffff\1\51\1\uffff\1\51",
            "\1\42\3\uffff\3\42\2\uffff\2\42\1\uffff\1\42\1\63\1\42\12\64"+
            "\1\42\1\uffff\1\42\1\uffff\7\42\1\66\22\42\1\61\2\42\1\uffff"+
            "\1\42\1\uffff\1\42\1\65\5\42\1\66\22\42\1\61\2\42\1\uffff\1"+
            "\42\1\uffff\1\42",
            "\1\42\3\uffff\3\42\2\uffff\2\42\1\uffff\1\42\1\63\1\42\12\64"+
            "\1\42\1\uffff\1\42\1\uffff\7\42\1\66\25\42\1\uffff\1\42\1\uffff"+
            "\1\42\1\65\5\42\1\66\25\42\1\uffff\1\42\1\uffff\1\42",
            "\12\67",
            "\1\51\3\uffff\3\51\2\uffff\2\51\1\uffff\1\70\1\57\1\51\1\56"+
            "\11\60\1\51\1\uffff\1\51\1\52\3\51\32\42\1\uffff\1\51\1\uffff"+
            "\3\51\32\42\1\uffff\1\51\1\uffff\1\51",
            "\1\51\3\uffff\3\51\2\uffff\2\51\1\uffff\2\51\1\71\12\42\1\51"+
            "\1\uffff\1\51\1\52\3\51\32\42\1\uffff\1\51\1\uffff\3\51\32\42"+
            "\1\uffff\1\51\1\uffff\1\51",
            "\1\51\3\uffff\3\51\2\uffff\1\72\1\51\1\uffff\3\51\12\42\1\51"+
            "\1\uffff\1\51\1\52\3\51\32\42\1\uffff\1\51\1\uffff\3\51\32\42"+
            "\1\uffff\1\51\1\uffff\1\51",
            "\1\51\3\uffff\3\51\2\uffff\2\51\1\uffff\3\51\12\42\1\51\1\uffff"+
            "\1\51\1\52\3\51\32\42\1\uffff\1\51\1\uffff\1\73\2\51\32\42\1"+
            "\uffff\1\51\1\uffff\1\51",
            "\1\51\3\uffff\3\51\2\uffff\2\51\1\uffff\3\51\12\42\1\51\1\uffff"+
            "\1\74\1\uffff\3\51\32\42\1\uffff\1\51\1\uffff\3\51\32\42\1\uffff"+
            "\1\51\1\uffff\1\51",
            "\1\51\3\uffff\3\51\2\uffff\2\51\1\uffff\3\51\12\42\1\51\1\uffff"+
            "\1\51\1\uffff\1\75\2\51\32\42\1\uffff\1\51\1\uffff\3\51\32\42"+
            "\1\uffff\1\51\1\uffff\1\51",
            "\1\51\3\uffff\1\51\1\76\1\51\2\uffff\2\51\1\uffff\3\51\12\42"+
            "\1\51\1\uffff\1\51\1\52\3\51\32\42\1\uffff\1\51\1\uffff\3\51"+
            "\32\42\1\uffff\1\51\1\uffff\1\51",
            "\1\51\3\uffff\3\51\2\uffff\2\51\1\uffff\3\51\12\42\1\51\1\uffff"+
            "\1\51\1\52\3\51\32\42\1\uffff\1\51\1\uffff\3\51\32\42\1\uffff"+
            "\1\77\1\uffff\1\51",
            "\1\50\3\uffff\3\50\2\uffff\2\50\1\uffff\3\50\12\uffff\1\50\1"+
            "\uffff\1\50\1\uffff\2\50\1\100\33\uffff\1\50\1\uffff\3\50\33"+
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
            "\1\102",
            "\1\51\3\uffff\3\51\2\uffff\2\51\1\uffff\3\51\12\42\1\51\1\uffff"+
            "\1\51\1\uffff\3\51\32\42\1\uffff\1\51\1\uffff\3\51\32\42\1\uffff"+
            "\1\51\1\uffff\1\103",
            "\1\50",
            "\1\44\26\uffff\1\51\3\uffff\3\51\2\uffff\2\51\1\uffff\3\51\12"+
            "\42\1\51\1\uffff\1\51\1\uffff\3\51\32\42\1\uffff\1\51\1\uffff"+
            "\3\51\32\42\1\uffff\1\51\1\uffff\1\51",
            "\1\105",
            "\1\106",
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
            "",
            "",
            "\1\51\3\uffff\3\51\2\uffff\2\51\1\uffff\3\51\12\42\1\51\1\uffff"+
            "\1\51\1\52\3\51\32\42\1\uffff\1\51\1\uffff\3\51\32\42\1\uffff"+
            "\1\51\1\uffff\1\51",
            "\1\42\3\uffff\3\42\2\uffff\2\42\1\uffff\1\42\1\63\1\42\12\64"+
            "\1\42\1\uffff\1\42\1\uffff\7\42\1\66\22\42\1\61\2\42\1\uffff"+
            "\1\42\1\uffff\1\42\1\65\5\42\1\66\22\42\1\61\2\42\1\uffff\1"+
            "\42\1\uffff\1\42",
            "\1\51\3\uffff\3\51\2\uffff\2\51\1\uffff\3\51\12\107\1\51\1\uffff"+
            "\1\51\1\uffff\3\51\32\42\1\uffff\1\51\1\uffff\3\51\32\42\1\uffff"+
            "\1\51\1\uffff\1\51",
            "\1\42\3\uffff\3\42\2\uffff\2\42\1\uffff\1\42\1\63\1\42\12\64"+
            "\1\42\1\uffff\1\42\1\uffff\7\42\1\66\25\42\1\uffff\1\42\1\uffff"+
            "\1\42\1\65\5\42\1\66\25\42\1\uffff\1\42\1\uffff\1\42",
            "\12\110\7\uffff\6\110\30\uffff\1\110\1\uffff\6\110",
            "",
            "\1\42\3\uffff\3\42\2\uffff\2\42\1\uffff\3\42\12\111\1\42\1\uffff"+
            "\1\42\1\uffff\7\42\1\112\25\42\1\uffff\1\42\1\uffff\7\42\1\112"+
            "\25\42\1\uffff\1\42\1\uffff\1\42",
            "\1\42\3\uffff\3\42\2\uffff\2\42\1\uffff\1\42\1\63\1\42\12\64"+
            "\1\42\1\uffff\1\42\1\uffff\7\42\1\66\25\42\1\uffff\1\42\1\uffff"+
            "\1\42\1\65\5\42\1\66\25\42\1\uffff\1\42\1\uffff\1\42",
            "\1\42\3\uffff\3\42\2\uffff\2\42\1\uffff\3\42\12\65\1\42\1\uffff"+
            "\1\42\1\uffff\35\42\1\uffff\1\42\1\uffff\1\42\1\65\33\42\1\uffff"+
            "\1\42\1\uffff\1\42",
            "\1\113\1\uffff\1\113\2\uffff\12\114",
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
            "\1\51\3\uffff\3\51\2\uffff\2\51\1\uffff\3\51\12\42\1\51\1\uffff"+
            "\1\51\1\52\3\51\32\42\1\uffff\1\51\1\uffff\3\51\32\42\1\uffff"+
            "\1\51\1\uffff\1\51",
            "\1\50\3\uffff\3\50\2\uffff\2\50\1\uffff\3\50\12\uffff\1\50\1"+
            "\uffff\1\50\1\uffff\3\50\33\uffff\1\50\1\uffff\3\50\33\uffff"+
            "\1\50\1\uffff\1\50",
            "",
            "\1\115",
            "\1\51\3\uffff\3\51\2\uffff\2\51\1\uffff\3\51\12\42\1\51\1\uffff"+
            "\1\51\1\uffff\3\51\32\42\1\uffff\1\51\1\uffff\3\51\32\42\1\uffff"+
            "\1\51\1\uffff\1\51",
            "",
            "\1\116",
            "\1\42\3\uffff\3\42\2\uffff\2\42\1\uffff\16\42\1\uffff\1\42\1"+
            "\uffff\35\42\1\uffff\1\42\1\uffff\35\42\1\uffff\1\42\1\uffff"+
            "\1\42",
            "\1\42\3\uffff\3\42\2\uffff\2\42\1\uffff\3\42\12\107\1\42\1\uffff"+
            "\1\42\1\uffff\7\42\1\117\25\42\1\uffff\1\42\1\uffff\7\42\1\117"+
            "\25\42\1\uffff\1\42\1\uffff\1\42",
            "\1\42\3\uffff\3\42\2\uffff\2\42\1\uffff\3\42\12\110\1\42\1\uffff"+
            "\1\42\1\uffff\3\42\6\110\24\42\1\uffff\1\42\1\uffff\1\42\1\110"+
            "\1\42\6\110\24\42\1\uffff\1\42\1\uffff\1\42",
            "\1\42\3\uffff\3\42\2\uffff\2\42\1\uffff\3\42\12\111\1\42\1\uffff"+
            "\1\42\1\uffff\7\42\1\112\25\42\1\uffff\1\42\1\uffff\7\42\1\112"+
            "\25\42\1\uffff\1\42\1\uffff\1\42",
            "\1\121\1\uffff\1\121\2\uffff\12\122",
            "\12\114",
            "\1\42\3\uffff\3\42\2\uffff\2\42\1\uffff\3\42\12\114\1\42\1\uffff"+
            "\1\42\1\uffff\35\42\1\uffff\1\42\1\uffff\35\42\1\uffff\1\42"+
            "\1\uffff\1\42",
            "\1\123",
            "\1\42\3\uffff\3\42\2\uffff\2\42\1\uffff\16\42\1\uffff\1\42\1"+
            "\uffff\35\42\1\uffff\1\42\1\uffff\35\42\1\uffff\1\42\1\uffff"+
            "\1\42",
            "\1\124\1\uffff\1\124\2\uffff\12\125",
            "",
            "\12\122",
            "\1\42\3\uffff\3\42\2\uffff\2\42\1\uffff\3\42\12\122\1\42\1\uffff"+
            "\1\42\1\uffff\35\42\1\uffff\1\42\1\uffff\35\42\1\uffff\1\42"+
            "\1\uffff\1\42",
            "\1\126",
            "\12\125",
            "\1\42\3\uffff\3\42\2\uffff\2\42\1\uffff\3\42\12\125\1\42\1\uffff"+
            "\1\42\1\uffff\35\42\1\uffff\1\42\1\uffff\35\42\1\uffff\1\42"+
            "\1\uffff\1\42",
            "\1\127",
            "\1\42\3\uffff\3\42\2\uffff\2\42\1\uffff\16\42\1\uffff\1\42\1"+
            "\uffff\35\42\1\uffff\1\42\1\uffff\35\42\1\uffff\1\42\1\uffff"+
            "\1\42"
    };

    static final short[] DFA28_eot = DFA.unpackEncodedString(DFA28_eotS);
    static final short[] DFA28_eof = DFA.unpackEncodedString(DFA28_eofS);
    static final char[] DFA28_min = DFA.unpackEncodedStringToUnsignedChars(DFA28_minS);
    static final char[] DFA28_max = DFA.unpackEncodedStringToUnsignedChars(DFA28_maxS);
    static final short[] DFA28_accept = DFA.unpackEncodedString(DFA28_acceptS);
    static final short[] DFA28_special = DFA.unpackEncodedString(DFA28_specialS);
    static final short[][] DFA28_transition;

    static {
        int numStates = DFA28_transitionS.length;
        DFA28_transition = new short[numStates][];
        for (int i=0; i<numStates; i++) {
            DFA28_transition[i] = DFA.unpackEncodedString(DFA28_transitionS[i]);
        }
    }

    class DFA28 extends DFA {

        public DFA28(BaseRecognizer recognizer) {
            this.recognizer = recognizer;
            this.decisionNumber = 28;
            this.eot = DFA28_eot;
            this.eof = DFA28_eof;
            this.min = DFA28_min;
            this.max = DFA28_max;
            this.accept = DFA28_accept;
            this.special = DFA28_special;
            this.transition = DFA28_transition;
        }
        public String getDescription() {
            return "1:1: Tokens : ( MultiString | SimpleString | MultiComment | NewlineComment | OpenSimple | CloseSimple | OpenSquare | CloseSquare | OpenCurly | CloseCurly | Comma | HexInteger | Integer | Real | AssignmentOperator | UnaryOperator | BinaryOperator | Assignment | Identifier | PossibleTerminator | Whitespace );";
        }
    }
 

}