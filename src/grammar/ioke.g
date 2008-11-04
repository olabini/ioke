grammar ioke;

options { 
    output = AST; 
    backtrack = true;
}


tokens {
    MESSAGE_SEND;
    MESSAGE_SEND_EMPTY;
    MESSAGE_SEND_SQUARE;
    MESSAGE_SEND_CURLY;
}

@lexer::header {
package ioke.lang.parser;
}

@header {
package ioke.lang.parser;
}

@members {
  protected void mismatch(IntStream input, int ttype, BitSet follow) throws RecognitionException {
    throw new MismatchedTokenException(ttype, input);
  }

  public Object recoverFromMismatchedSet(IntStream input, RecognitionException e, BitSet follow) throws RecognitionException {
			reportError(e);
    throw e;
  }

  public Tree parseFully() throws RecognitionException {
      messageChain_return result = messageChain();
      return result == null ? (Tree)null : (Tree)(result.getTree());
  }
}

@rulecatch {
  catch(RecognitionException e) {
    throw e;
  }
}

@lexer::members {
    public Token nextToken() {
        Token t = super.nextToken();
//        System.err.println("RETURNING TOKEN: " + t);
        return t;
    }


  public void reportError(RecognitionException e) {
    displayRecognitionError(this.getTokenNames(), e);
    throw new RuntimeException(e);
  }
}

messageChain
    :
        expression+ EOF!
    ;

commatedExpression
    :
        expression+ (Comma expression+)*
    ;

twoExpressions
    :
        expression+ Comma expression+
    ;

expression
    :
        Identifier ('(' commatedExpression? ')')? -> ^(MESSAGE_SEND Identifier commatedExpression?)
    |   operator '(' commatedExpression? ')' -> ^(MESSAGE_SEND operator commatedExpression?)
    |   trinaryOperator '(' twoExpressions ')'  -> ^(MESSAGE_SEND trinaryOperator twoExpressions)
    |   '(' commatedExpression? ')'  -> ^(MESSAGE_SEND_EMPTY commatedExpression?)
    |   '[]'                            -> ^(MESSAGE_SEND_SQUARE)
    |   '[' ']'                         -> ^(MESSAGE_SEND_SQUARE)
    |   '{}'                            -> ^(MESSAGE_SEND_CURLY)
    |   '{' '}'                         -> ^(MESSAGE_SEND_CURLY)
    |   '[' commatedExpression ']'  -> ^(MESSAGE_SEND_SQUARE commatedExpression)
    |   '{' commatedExpression '}'  -> ^(MESSAGE_SEND_CURLY commatedExpression)
    |   binaryOperator
    |   unaryOperator
    |   StringLiteral
    |   NumberLiteral
    |   Terminator
    ;

operator
    :
        ComparisonOperator
    |   RegularBinaryOperator
    |   IncDec
    |   SquareBrackets
    |   CurlyBrackets
    ;

trinaryOperator
    :
        Equals
    ;

binaryOperator
    :
        ComparisonOperator
    |   RegularBinaryOperator
    |   Equals
    ;

unaryOperator
    :
        IncDec
    ;

Identifier
    :
        '@'
    |   '@@'
    |   (Letter|':') (Letter|IDDigit|StrangeChars)*
    ;

NumberLiteral
    :
		'0'	('x'|'X') HexDigit+
    |   '0' (
            {(input.LA(2)>='0')&&(input.LA(2)<='9')}?=> (FloatWithLeadingDot)
        |
        )
    |   NonZeroDecimal (
            {(input.LA(2)>='0')&&(input.LA(2)<='9')}?=> (FloatWithLeadingDot)
        | Exponent
        |
        )
    ;

StringLiteral
    :  '"' ( EscapeSequence | ~('\\'|'"') )* '"'
    ;

Terminator
    :
        (('\r'? '\n') | {(input.LA(2) != '.')}?=> '.')+
    ;

Whitespace : Separator {skip();};

LineComment
    : ';' ~('\n'|'\r')* {$channel=HIDDEN;}
    ;

ComparisonOperator
    :
        '<=>'
    |   '<='
    |   '>='
    |   '<'
    |   '>'
    |   '==='
    |   '=='
    |   '!='
    |   '=~'
    |   '!~'
    ;

RegularBinaryOperator
    :
        '-'
    |   '+'
    |   '**'
    |   '*'
    |   '/'
    |   '%'
    |   '&&'
    |   '&'
    |   '||'
    |   '|'
    |   '^'
    |   '=>'
    |   '=>>'
    |   '<->'
    |   '->'
    |   '+>'
    |   '!>'
    |   '<>'
    |   '&>'
    |   '%>'
    |   '#>'
    |   '@>'
    |   '/>'
    |   '*>'
    |   '?>'
    |   '|>'
    |   '^>'
    |   '~>'
    |   '**>'
    |   '&&>'
    |   '||>'
    |   '$>'
    |   '->>'
    |   '+>>'
    |   '!>>'
    |   '<>>'
    |   '&>>'
    |   '%>>'
    |   '#>>'
    |   '@>>'
    |   '/>>'
    |   '*>>'
    |   '?>>'
    |   '|>>'
    |   '^>>'
    |   '~>>'
    |   '**>>'
    |   '&&>>'
    |   '||>>'
    |   '$>>'
    |   '...'
    |   '..'
    |   '<<'
    |   '>>'
    |   'or'
    |   'and'
    |   '!'
    |   '~'
    |   '$'
    |   '+='
    |   '-='
    |   '/='
    |   '*='
    |   '%='
    |   '&='
    |   '&&='
    |   '|='
    |   '||='
    |   '^='
    |   '<<='
    |   '>>='
    ;

Equals
    :
        '='
    ;

IncDec
    :
        '++'
    |   '--'
    ;

SquareBrackets
    : 
        '[]'
    ;

CurlyBrackets
    : 
        '{}'
    ;

Comma
    :
        ','
    ;

fragment
EscapeSequence
    :   '\\' ('b'|'t'|'n'|'f'|'r'|'\"'|'\\'|'\n')
    |   UnicodeEscape
    |   OctalEscape
    ;

fragment
OctalEscape
    :   '\\' ('0'..'3') ('0'..'7') ('0'..'7')
    |   '\\' ('0'..'7') ('0'..'7')
    |   '\\' ('0'..'7')
    ;

fragment
UnicodeEscape
    :   '\\' 'u' HexDigit HexDigit HexDigit HexDigit
    ;

fragment
FloatWithLeadingDot
        :
            '.' Digit+ (Exponent)?
        ;

fragment
Exponent
    :	
        ('e'|'E')	('+'|'-')?	('0'..'9')+
    ;

fragment
NonZeroDecimal
    :
     ('1'..'9') Digit*
    ;

fragment
Digit : '0'..'9' ;

fragment
HexDigit : ('0'..'9'|'a'..'f'|'A'..'F') ;

fragment
Separator : (' ' | '\u000c' | '\u0009' | '\u000b' | '\\' '\u000a' )+ ;

fragment
StrangeChars
    :
        '_' |
        '!' |
        '?' |
        ':'
    ;

fragment
IDDigit
    :  '\u0030'..'\u0039' |
       '\u0660'..'\u0669' |
       '\u06f0'..'\u06f9' |
       '\u0966'..'\u096f' |
       '\u09e6'..'\u09ef' |
       '\u0a66'..'\u0a6f' |
       '\u0ae6'..'\u0aef' |
       '\u0b66'..'\u0b6f' |
       '\u0be7'..'\u0bef' |
       '\u0c66'..'\u0c6f' |
       '\u0ce6'..'\u0cef' |
       '\u0d66'..'\u0d6f' |
       '\u0e50'..'\u0e59' |
       '\u0ed0'..'\u0ed9' |
       '\u1040'..'\u1049'
   ;

fragment
Letter
    :  
       '\u0041'..'\u005a' |
       '\u005f'           |
       '\u0061'..'\u007a' |
       '\u00c0'..'\u00d6' |
       '\u00d8'..'\u00f6' |
       '\u00f8'..'\u00ff' |
       '\u0100'..'\u1fff' |
       '\u3040'..'\u318f' |
       '\u3300'..'\u337f' |
       '\u3400'..'\u3d2d' |
       '\u4e00'..'\u9fff' |
       '\uf900'..'\ufaff'
    ;
