
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
}

Whitespace : Separator {skip();};

fragment
Separator : (' ' | '\u000c' | '\u0009' | '\u000b' | '\\' '\u000a' )* ;
