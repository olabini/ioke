grammar ioke;

options { 
    language = CSharp2;
    output = AST; 
}

tokens {
    MESSAGE;
}

@parser::namespace { Ioke.Lang.Parser } 
@lexer::namespace { Ioke.Lang.Parser }

@parser::members {
  public ITree parseFully() {
    iokeParser.fullProgram_return result = fullProgram();
    return result == null ? null : (ITree)(result.Tree);
  }
}

@rulecatch {
  catch(RecognitionException e) {
    throw e;
  }
}

fullProgram
    :
        expressionChain? EOF!
    ;

commatedExpression
    :
        expressionChain (Comma expressionChain)*
    ;

expressionChain
    :
        expression+
    ;

expression
    :
        {!"(".Equals(input.LT(2).Text)}?=> 
        v=Identifier                               -> ^(MESSAGE[$v] Identifier)
    |   v=Identifier '(' commatedExpression? ')'   -> ^(MESSAGE[$v] Identifier        '('  commatedExpression?)
    |   v='('  commatedExpression? ')'             -> ^(MESSAGE[$v] Identifier[""]    '('  commatedExpression?)
    |   v='['  commatedExpression? ']'             -> ^(MESSAGE[$v] Identifier["[]"]  '['  commatedExpression?)
    |   v='{'  commatedExpression? '}'             -> ^(MESSAGE[$v] Identifier["{}"]  '{'  commatedExpression?)
    |   v='#{' commatedExpression? '}'             -> ^(MESSAGE[$v] Identifier["set"] '{'  commatedExpression?)
    |   literals
    |   Terminator
    ;

literals
    :
        StringLiteral
    |   RegexpLiteral
    |   NumberLiteral
    |   DecimalLiteral
    |   UnitLiteral
    ;

fragment
OperatorChar
    : 
        '+' 
    |   '-' 
    |   '*'
    |   '%' 
    |   '<'  
    |   '>' 
    |   '!' 
    |   '?' 
    |   '~' 
    |   '&'  
    |   '|' 
    |   '^' 
    |   '$'
    |   '=' 
    |   '@'
    |   '\'' 
    |   '`'
    |   ':'
    ;

Identifier
    :
        '[]'
    |   '{}'
    |   (OperatorChar | '/') (OperatorChar | '#' | '/')*
    |   '#' (OperatorChar | '#')+
    |   '.' '.'+
    |   Letter (Letter|IDDigit|':'|'!'|'?'|'$')*
    |   ':' (Letter|IDDigit) (Letter|IDDigit|':'|'!'|'?'|'$')*
    ;

fragment
DecimalLiteral
    :
    ;

fragment
UnitLiteral
    :
    ;

fragment
UnitDecimalLiteral
    :
    ;

NumberLiteral
    :
		'0'	('x'|'X') HexDigit+
    |   '0' (
            {isNum(input.LA(2))}?=> (FloatWithLeadingDot) {$type=DecimalLiteral;}
        |
        ) (
            UnitSpecifier {$type = unitType($type);}
        |
        )
    |   NonZeroDecimal (
            {isNum(input.LA(2))}?=> (FloatWithLeadingDot) {$type=DecimalLiteral;}
        | Exponent {$type=DecimalLiteral;}
        |
        ) (
            UnitSpecifier {$type = unitType($type);}
        |
        )
    ;

StringLiteral
    :  ('"' 
        ( ({!lookingAtInterpolation()}?=> (EscapeSequence | ~('\\'|'"')))* ) 
        (
            '#{' {startInterpolation(); }
        |   '"'))
    |  ('#[' 
        ( ({!lookingAtInterpolation()}?=> (EscapeSequence | ~('\\'|']')))* ) 
        (
            '#{' {startAltInterpolation(); }
        |   ']'))
    | {isInterpolating()}?=> ('}' ( ({!lookingAtInterpolation()}?=> (EscapeSequence | ~('\\'|'"')))* ) 
        (
            '#{' {startInterpolation(); }
        |   '"'  {endInterpolation(); }))
    | {isAltInterpolating()}?=> ('}' ( ({!lookingAtInterpolation()}?=> (EscapeSequence | ~('\\'|']')))* ) 
        (
            '#{' {startAltInterpolation(); }
        |   ']'  {endAltInterpolation(); }))
    ;

RegexpLiteral
    :  ('#/'
            ( ({!lookingAtInterpolation()}?=> ( EscapeSequenceRegexpB | ~('\\'|'/')))* )
            (
                '#{' {startRegexpInterpolation(); }
            |   '/' RegexpModifier))
    |  ('#r[' 
        ( ({!lookingAtInterpolation()}?=> (EscapeSequenceRegexpA | ~('\\'|']')))* ) 
        (
            '#{' {startAltRegexpInterpolation(); }
        |   ']' RegexpModifier))
    | {isRegexpInterpolating()}?=> ('}' (({!lookingAtInterpolation()}?=> (EscapeSequenceRegexpB | ~('\\'|'/')))* ) 
        (
            '#{' {startRegexpInterpolation(); }

        |   '/' RegexpModifier  {endRegexpInterpolation(); }))
    | {isAltRegexpInterpolating()}?=> ('}' ( ({!lookingAtInterpolation()}?=> (EscapeSequenceRegexpA | ~('\\'|']')))* ) 
        (
            '#{' {startAltRegexpInterpolation(); }
        |   '/' RegexpModifier {endAltRegexpInterpolation(); }))
    ;

fragment
EscapeSequence
    :   '\\' ('b'|'t'|'n'|'f'|'r'|'\"'|']'|'\\'|'\n'|'#'|'e'|'\r' '\n')
    |   UnicodeEscape
    |   OctalEscape
    ;

fragment
EscapeSequenceRegexpA
    :   '\\' ('t'|'n'|'f'|'r'|'/'|'\\'|'\n'|'#'|'A'|'d'|'D'|'s'|'S'|'w'|'W'|'b'|'B'|'z'|'Z'|'<'|'>'|'G'|'p'|'P'|'{'|'}'|'['|'*'|'('|')'|'$'|'^'|'+'|'?'|'.'|'|'|'\r' '\n')
    |   UnicodeEscape
    |   OctalEscape
    ;

fragment
EscapeSequenceRegexpB
    :   '\\' ('t'|'n'|'f'|'r'|'/'|'\\'|'\n'|'#'|'A'|'d'|'D'|'s'|'S'|'w'|'W'|'b'|'B'|'z'|'Z'|'<'|'>'|'G'|'p'|'P'|'{'|'}'|'['|'*'|'('|')'|'$'|'^'|'+'|'?'|'.'|'|'|'\r' '\n')
    |   UnicodeEscape
    |   OctalEscape
    ;

fragment
RegexpModifier
		:	('x'|'i'|'u'|'m'|'s')*
		;

Terminator
    :
        (('\r'? '\n') | {(input.LA(2) != '.')}?=> '.')+
    ;

Whitespace : Separator {Skip();};

LineComment
    : ';' ~('\n'|'\r')* {$channel=HIDDEN;}
    | '#!' ~('\n'|'\r')* {$channel=HIDDEN;}
    ;

Comma
    :
        ','
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
UnitSpecifier
    :
        ('a'..'w'|'A'..'W'|'y'|'Y'|'z'|'Z'|'_') ('a'..'z'|'A'..'Z'|'_')*
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
       '\uf900'..'\ufaff' |
       '\u2200'..'\u22FF' |
       '\u27C0'..'\u27EF' |
       '\u2980'..'\u29FF' |
       '\u2A00'..'\u2AFF'
    ;
