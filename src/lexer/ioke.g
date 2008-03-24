
lexer grammar ioke;

@header {
package org.ioke.parser;

import java.io.FileReader;
import java.io.BufferedReader;
import java.io.Reader;
import java.io.InputStreamReader;
import java.io.StringReader;

import java.util.List;
import java.util.ArrayList;
}

@members {
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
}

MultiComment : ('{#' ( options {greedy=false;} : .* ) '#}') {skip();};
NewlineComment : '#' ( ~NewLine )* NewLine? {$type=PossibleTerminator;setText(";");} ;

OpenSimple : '(' ;
CloseSimple : ')' ;
OpenSquare : '[' ;
CloseSquare : ']' ;
OpenCurly : '{' ;
CloseCurly : '}' ;

Comma : (',' NewLine*) {setText(",");};

HexInteger : ('+'|'-')? '0' ('x' | 'X') (Digit | HexLetter)+;

Integer : ('+'|'-')? Digits ;

Real
    :   ('+'|'-')? 
        (Digits '.' Digit* Exponent?
    |    '.' Digits Exponent? 
    |    Digits Exponent)
    ;

AssignmentOperator :
        ('+' 
        | '++' 
        | '-' 
        | '--' 
        | '/' 
        | '//' 
        | '*' 
        | '**' 
        | '%' 
        | '%%' 
        | '^' 
        | '^^' 
        | '<<' 
        | '>>' 
        | '&' 
        | '&&' 
        | '|' 
        | '||') '='
    ;

UnaryOperator : 
      '@'
    | '@@'
    | '\''
    | '`'
    | '!'
    | ':'
    | 'return'
    ;

BinaryOperator : 
      OpChars+
    | '=='
    | '==='
    | '===='
    | '<='
    | '>='
    | '~='
    | '~~='
    | '!='
    | '!!='
    | 'and'
    | 'or'
    ;

Assignment : '=' ;

Identifier : IdentStart IdentChars* ;

PossibleTerminator : ((';' | NewLine)+) {setText(";");};

Whitespace : Separator {skip();};


fragment
Exponent : ('e'|'E') ('+'|'-')? Digits ;

fragment
Letter : 'a' .. 'z' | 'A' .. 'Z' ;

fragment
Digit : '0'..'9' ;

fragment
Digits : Digit+ ;

fragment
HexLetter : 'a' .. 'f' | 'A' .. 'F' ;

fragment
Separator : (' ' | '\u000c' | '\u0009' | '\u000b' | '\\' '\u000a' )+ ;

fragment
OpChars : ('!' | '?' | '@' | '&' | '%' | '.' | '|' | '<' | '>' | '/' | '+' | '-' | '_' | ':' | '\\' | '*' | '^' | '~' | '`' | '\'') ;

fragment
IdentChars : Letter | Digit | ('!' | '?' | '@' | '&' | '%' | '.' | '|' | '<' | '>' | '/' | '+' | '-' | '_' | ':' | '\\' | '*' | '^' | '~' | '`' | '\'') ;

fragment
IdentStart : Letter | Digit | ('?' | '&' | '%' | '|' | '<' | '>' | '/' | '+' | '-' | '_' | '\\' | '*' | '^' | '~') ;

fragment
NewLine : ('\u000a' | '\u000d') ;
