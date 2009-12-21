#!/usr/bin/ioke

Ioke = LanguageExperiment with(
  goal: :expressiveness,
  data: as(code),
  code: as(data),
  features: [
    :dynamic,
    :object_oriented,
    :prototype_based,
    :homoiconic,
    :macros
  ],
  runtimes:(JVM, CLR),
  inspirations: set(Io, Smalltalk, Ruby, Lisp)
)

hello = method("Every example needs a hello world!",
  name,
  "hello, #{name}!" println)

Ioke inspirations select(
  features include?(:object_oriented)
) each(x, hello(x name))

;standard comment "shouldn't #{do anything} weird #/at all/

;numbers
1
-1
123123213218736128983274923874
-123123213218736128983274923874
1.2349327
-1.2349327
2319
-2319
0xFFFFF
-0xFFFFF
1E6
-1E6
1E-32
-1E-32
23.4445e10
-23.4445e10

;keywords
break cond continue do ensure for for:dict for:set if let loop return
until while with

;ground
stackTraceAsText

;literals
dict list message set

;case
case case:and case:else case:nand case:nor case:not case:otherwise
case:xor

;reflection
asText become! derive freeze! frozen? in? is? kind? mimic! mimics
mimics? prependMimic! removeAllMimics! removeMimic! same? send thaw!
uniqueHexId

;aspects
after around before

;default behaviour
destructuring kind cellDescriptionDict cellSummary genSym inspect
notice
use

;basebehaviour
cell? cellOwner? cellOwner cellNames cells cell documentation identity
removeCell! undefineCell

;internal
internal:compositeRegexp internal:concatenateText
internal:createDecimal internal:createNumber internal:createRegexp
internal:createText

;conditions
availableRestarts bind error! findRestart handle invokeRestart rescue
restart signal! warn!

;constants
nil false true

;names
Kinds Arity Arguments Base Call Condition Default Error Arithmetic
DivisionByZero NotParseable CantMimicOddball CommandLine
DontUnderstandOption Default IO Index Invocation
ArgumentWithoutDefaultValue MismatchedKeywords NoMatch NotActivatable
NotSpreadable TooFewArguments TooManyArguments Load ModifyOnFrozen
NativeException NoSuchAdvice NoSuchCell Parser pShuffle
RestartNotActive Type IncorrectType Warning Default DateTime
DefaultBehavior Aspects Pointcut Assignment BaseBehavior Boolean Case
AndCombiner Else NAndCombiner NOrCombiner NotCombiner OrCombiner
XOrCombiner Conditions Definitions FlowControl Internal Literals
Reflection DefaultMacro DefaultMethod DefaultSyntax Dict FileSystem
File Ground Handler IO IokeGround LexicalBlock LexicalMacro List
Message OperatorTable Method Mixins Comparing Enumerable NativeMethod
Number Decimal Integer Ratio Rational Real Origin Pair Range
Regexp Match Rescue Restart Runtime Set Symbol System Text

;function defs
generateMatchMethod aliasMethod λ ʎ fnx fn method dmacro dlecro syntax
macro dlecrox lecrox lecro syntax

;symbols
:foo
:flaxBarFoo
:""
:"mux mex mox \n ::::::::"

;keywords
foo:
fooBarBaz:
Buz:

;text
"\b \e \t \n \f \r \" \\ \# \uABCD \377 \0"
"foo ; bar ; baz" println
"foo #{"sam" + "aaron #{1}"}"
"foo \" bar"
"this text
spans multiple lines"

;regexps
#//
#r[]

#/foo/
#r[foo]

#/f\/o+/x
#r[fo+]x

#/bla #{"}"} bar/
#r[bla #{"foo"} bar]

;cellnames
samandsooze
return!fire
or!nor
sam1234
sam123.123
"" cell?
"" cell?bar
internal:compositeRegexp("foo bar")
"" documentation
"" removeCell!(:foobar)
"" undefineCell

;operators
 !
 ?
$
~
#
**
*
/
 %
+
-
<<
>>
<=>
>
<
<=
>=
<>
<>>
==
 !=
===
=~
 !~
&
^
|
&&
 ?&
||
 ?|
..
...
=>
<->
->
+>
 !>
&>
 %>
#>
@>
/>
*>
 ?>
|>
^>
~>
->>
+>>
 !>>
&>>
 %>>
#>>
@>>
/>>
*>>
 ?>>
|>>
^>>
~>>
=>>
**>
**>>
&&>
&&>>
||>
||>>
$>
$>>
+=
-=
**=
*=
/=
 %=
and
nand
&=
&&=
^=
or
xor
nor
|=
||=
<<=
>>=
<-

;kinds
Sam
Ola
Carlos

;assignment
team_s = [:sam, :sooze, :beans]
fooBar = "Baz"
sam = "sam"
sam? = true
sam!aaron? = true

;mimics
sam = Person mimic

;documentation
sam = method("this is documentation", x, y, x + y)

sam = method("this is documentation
that spans multiple lines for fun",
     x, y, x + y
)

sam = method(
    "this is documentation",
    x,y,
    x + y)

;lists
[1,2,3,4,5]

;dicts
{a: "a", b: 2, c: [1,2,3, {:four => 4}, {five: 5}]}

;sets
#(1,2,3,4,5, "six", :seven)
