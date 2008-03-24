package org.ioke.parser

import org.specs._
import org.specs.runner.JUnit4

import java.util.ArrayList

import org.antlr.runtime.Token
import org.antlr.runtime.CommonToken

class LexerSpecTest extends JUnit4(LexerSpec)

object LexerSpec extends Specification {
  case class Tok(tokenTope: Int, tokenValue: String)

  def ident(name: String) = Tok(iokeLexer.Identifier, name)
  def integer(value: String) = Tok(iokeLexer.Integer, value)
  def hexInteger(value: String) = Tok(iokeLexer.HexInteger, value)
  def real(value: String) = Tok(iokeLexer.Real, value)
  def string(value: String) = Tok(-2, value)
  def triString(value: String) = Tok(-3, value) 
  def regexp(value: String) = Tok(-4, value)
  def assgnOp(value: String) = Tok(iokeLexer.AssignmentOperator, value)
  def unaryOp(value: String) = Tok(iokeLexer.UnaryOperator, value)
  def binaryOp(value: String) = Tok(iokeLexer.BinaryOperator, value)
  def term() = Tok(iokeLexer.PossibleTerminator, ";")
  def assgn() = Tok(iokeLexer.Assignment, "=")

  def openSimple() = Tok(iokeLexer.OpenSimple, "(")
  def closeSimple() = Tok(iokeLexer.CloseSimple, ")")
  def openSquare() = Tok(iokeLexer.OpenSquare, "[")
  def closeSquare() = Tok(iokeLexer.CloseSquare, "]")
  def openCurly() = Tok(iokeLexer.OpenCurly, "{")
  def closeCurly() = Tok(iokeLexer.CloseCurly, "}")
  def comma() = Tok(iokeLexer.Comma, ",")

  def tokens(tokens: Tok*) : ArrayList[Tok] = {
    val list = new ArrayList[Tok]()
    for(v <- tokens) 
      list.add(v)
    list
  }

  def lex(str: String) : ArrayList[Tok] = {
    val list = new ArrayList[Tok]()
    val iterator = iokeLexer.getTokens(str).iterator()
    while(iterator.hasNext()) {
      val v = iterator.next()
      list.add(Tok(v.getType(), v.getText()))
    }
    list
  }

  "lexer" should {
    "handle lexings of identifiers correctly" in {
      lex("") must be_==(tokens(
      ))
 
      lex("foo") must be_==(tokens(
        ident("foo")
      ))

      lex("foo; bar") must be_==(tokens(
        ident("foo"), 
        term,
        ident("bar")
      ))

      lex("foo bar") must be_==(tokens(
        ident("foo"), 
        ident("bar")
      ))

      lex("fo0o ba1r") must be_==(tokens(
        ident("fo0o"), 
        ident("ba1r")
      ))

      lex("foo:: f::oo") must be_==(tokens(
        ident("foo::"), 
        ident("f::oo")
      ))

      lex("&f:?!%o.._!</@|>*o-+---^~-`'-") must be_==(tokens(
        ident("&f:?!%o.._!</@|>*o-+---^~-`'-")
      ))

      lex("foo=") must be_==(tokens(
        ident("foo"), 
        assgn
      ))

      lex("foo=bar") must be_==(tokens(
        ident("foo"), 
        assgn,
        ident("bar")
      ))
    }

    "handle lexings of symbol identifiers" in {
      lex("=") must be_==(tokens(
        assgn 
      ))

      lex("=;=") must be_==(tokens(
        assgn,
        term,
        assgn
      ))

      lex("==") must be_==(tokens(
        binaryOp("==") 
      ))

      lex("===") must be_==(tokens(
        binaryOp("===") 
      ))

      lex("====") must be_==(tokens(
        binaryOp("====") 
      ))

      lex("=====") must be_==(tokens(
        binaryOp("===="),
        assgn
      ))

      lex("+=") must be_==(tokens(
        assgnOp("+=") 
      ))

      lex("-=") must be_==(tokens(
        assgnOp("-=") 
      ))

      lex("/=") must be_==(tokens(
        assgnOp("/=") 
      ))

      lex("*=") must be_==(tokens(
        assgnOp("*=") 
      ))

      lex("++=") must be_==(tokens(
        assgnOp("++=") 
      ))

      lex("--=") must be_==(tokens(
        assgnOp("--=") 
      ))

      lex("//=") must be_==(tokens(
        assgnOp("//=") 
      ))

      lex("**=") must be_==(tokens(
        assgnOp("**=") 
      ))

      lex("~=") must be_==(tokens(
        binaryOp("~=") 
      ))

      lex("~~=") must be_==(tokens(
        binaryOp("~~=") 
      ))

      lex("<=") must be_==(tokens(
        binaryOp("<=") 
      ))

      lex(">=") must be_==(tokens(
        binaryOp(">=") 
      ))

      lex("<<=") must be_==(tokens(
        assgnOp("<<=") 
      ))

      lex(">>=") must be_==(tokens(
        assgnOp(">>=") 
      ))

      lex("&=") must be_==(tokens(
        assgnOp("&=") 
      ))

      lex("&&=") must be_==(tokens(
        assgnOp("&&=") 
      ))

      lex("|=") must be_==(tokens(
        assgnOp("|=") 
      ))

      lex("||=") must be_==(tokens(
        assgnOp("||=") 
      ))

      lex("%=") must be_==(tokens(
        assgnOp("%=") 
      ))

      lex("%%=") must be_==(tokens(
        assgnOp("%%=") 
      ))

      lex("^=") must be_==(tokens(
        assgnOp("^=") 
      ))

      lex("^^=") must be_==(tokens(
        assgnOp("^^=") 
      ))

      lex("!=") must be_==(tokens(
        binaryOp("!=") 
      ))

      lex("!!=") must be_==(tokens(
        binaryOp("!!=") 
      ))

      lex("@foo") must be_==(tokens(
        unaryOp("@"),
        ident("foo")
      ))

      lex("@@foo") must be_==(tokens(
        unaryOp("@@"),
        ident("foo")
      ))

      lex("!foo") must be_==(tokens(
        unaryOp("!"),
        ident("foo")
      ))

      lex("'foo") must be_==(tokens(
        unaryOp("'"),
        ident("foo")
      ))

      lex(":foo") must be_==(tokens(
        unaryOp(":"),
        ident("foo")
      ))

      lex("`foo") must be_==(tokens(
        unaryOp("`"),
        ident("foo")
      ))

      lex("return foo") must be_==(tokens(
        unaryOp("return"),
        ident("foo")
      ))
    }

    "handle lexings of argument lists" in {
      lex("foo()") must be_==(tokens(
        ident("foo"),
        openSimple,
        closeSimple
      ))

      lex("foo[]") must be_==(tokens(
        ident("foo"),
        openSquare,
        closeSquare
      ))

      lex("foo{}") must be_==(tokens(
        ident("foo"),
        openCurly,
        closeCurly
      ))

      lex("foo(abc)") must be_==(tokens(
        ident("foo"),
        openSimple,
        ident("abc"),
        closeSimple
      ))

      lex("foo(abc hah)") must be_==(tokens(
        ident("foo"),
        openSimple,
        ident("abc"),
        ident("hah"),
        closeSimple
      ))

      lex("foo(qux,bar)") must be_==(tokens(
        ident("foo"),
        openSimple,
        ident("qux"),
        comma,
        ident("bar"),
        closeSimple
      ))

    }

    "handle lexings of numbers" in {
      lex("0") must be_==(tokens(
        integer("0")
      ))

      lex("-1") must be_==(tokens(
        integer("-1")
      ))

      lex("+1") must be_==(tokens(
        integer("+1")
      ))

      lex("1234567890") must be_==(tokens(
        integer("1234567890")
      ))

      lex("1\n1") must be_==(tokens(
        integer("1"),
        term,
        integer("1")
      ))
    }

    "handle lexings of hex numbers" in {
      lex("0x0") must be_==(tokens(
        hexInteger("0x0")
      ))

      lex("-0x1") must be_==(tokens(
        hexInteger("-0x1")
      ))

      lex("+0x1") must be_==(tokens(
        hexInteger("+0x1")
      ))

      lex("0X1") must be_==(tokens(
        hexInteger("0X1")
      ))

      lex("0x1234567890ABCDEFabcdef") must be_==(tokens(
        hexInteger("0x1234567890ABCDEFabcdef")
      ))
    }

    "handle lexings of real numbers" in {
      lex("0.0") must be_==(tokens(
        real("0.0")
      ))

      lex("-0.0") must be_==(tokens(
        real("-0.0")
      ))

      lex("+0.0") must be_==(tokens(
        real("+0.0")
      ))

      lex("0.") must be_==(tokens(
        real("0.")
      ))

      lex("-0.") must be_==(tokens(
        real("-0.")
      ))

      lex("+0.") must be_==(tokens(
        real("+0.")
      ))

      lex(".0") must be_==(tokens(
        real(".0")
      ))

      lex("-.0") must be_==(tokens(
        real("-.0")
      ))

      lex("+.0") must be_==(tokens(
        real("+.0")
      ))

      lex("1.0e1234") must be_==(tokens(
        real("1.0e1234")
      ))

      lex("1.0E1234") must be_==(tokens(
        real("1.0E1234")
      ))

      lex("1.0e+1234") must be_==(tokens(
        real("1.0e+1234")
      ))

      lex("1.0E+1234") must be_==(tokens(
        real("1.0E+1234")
      ))

      lex("1.0e-1234") must be_==(tokens(
        real("1.0e-1234")
      ))

      lex("1.0E-1234") must be_==(tokens(
        real("1.0E-1234")
      ))

      lex("+1.0e1234") must be_==(tokens(
        real("+1.0e1234")
      ))

      lex("+1.0E1234") must be_==(tokens(
        real("+1.0E1234")
      ))

      lex("+1.0e+1234") must be_==(tokens(
        real("+1.0e+1234")
      ))

      lex("+1.0E+1234") must be_==(tokens(
        real("+1.0E+1234")
      ))

      lex("+1.0e-1234") must be_==(tokens(
        real("+1.0e-1234")
      ))

      lex("+1.0E-1234") must be_==(tokens(
        real("+1.0E-1234")
      ))

      lex("-1.0e1234") must be_==(tokens(
        real("-1.0e1234")
      ))

      lex("-1.0E1234") must be_==(tokens(
        real("-1.0E1234")
      ))

      lex("-1.0e+1234") must be_==(tokens(
        real("-1.0e+1234")
      ))

      lex("-1.0E+1234") must be_==(tokens(
        real("-1.0E+1234")
      ))

      lex("-1.0e-1234") must be_==(tokens(
        real("-1.0e-1234")
      ))

      lex("-1.0E-1234") must be_==(tokens(
        real("-1.0E-1234")
      ))

      lex("7.e12") must be_==(tokens(
        real("7.e12")
      ))

      lex("7.E12") must be_==(tokens(
        real("7.E12")
      ))

      lex("7.e+12") must be_==(tokens(
        real("7.e+12")
      ))

      lex("7.E+12") must be_==(tokens(
        real("7.E+12")
      ))

      lex("7.e-12") must be_==(tokens(
        real("7.e-12")
      ))

      lex("7.E-12") must be_==(tokens(
        real("7.E-12")
      ))

      lex("+7.e12") must be_==(tokens(
        real("+7.e12")
      ))

      lex("+7.E12") must be_==(tokens(
        real("+7.E12")
      ))

      lex("+7.e+12") must be_==(tokens(
        real("+7.e+12")
      ))

      lex("+7.E+12") must be_==(tokens(
        real("+7.E+12")
      ))

      lex("+7.e-12") must be_==(tokens(
        real("+7.e-12")
      ))

      lex("+7.E-12") must be_==(tokens(
        real("+7.E-12")
      ))

      lex("-7.e12") must be_==(tokens(
        real("-7.e12")
      ))

      lex("-7.E12") must be_==(tokens(
        real("-7.E12")
      ))

      lex("-7.e+12") must be_==(tokens(
        real("-7.e+12")
      ))

      lex("-7.E+12") must be_==(tokens(
        real("-7.E+12")
      ))

      lex("-7.e-12") must be_==(tokens(
        real("-7.e-12")
      ))

      lex("-7.E-12") must be_==(tokens(
        real("-7.E-12")
      ))

      lex(".7e3") must be_==(tokens(
        real(".7e3")
      ))

      lex(".7E3") must be_==(tokens(
        real(".7E3")
      ))

      lex(".7e-3") must be_==(tokens(
        real(".7e-3")
      ))

      lex(".7E-3") must be_==(tokens(
        real(".7E-3")
      ))

      lex(".7e+3") must be_==(tokens(
        real(".7e+3")
      ))

      lex(".7E+3") must be_==(tokens(
        real(".7E+3")
      ))


      lex("+.7e3") must be_==(tokens(
        real("+.7e3")
      ))

      lex("+.7E3") must be_==(tokens(
        real("+.7E3")
      ))

      lex("+.7e-3") must be_==(tokens(
        real("+.7e-3")
      ))

      lex("+.7E-3") must be_==(tokens(
        real("+.7E-3")
      ))

      lex("+.7e+3") must be_==(tokens(
        real("+.7e+3")
      ))

      lex("+.7E+3") must be_==(tokens(
        real("+.7E+3")
      ))

      lex("-.71e3") must be_==(tokens(
        real("-.71e3")
      ))

      lex("-.7E3") must be_==(tokens(
        real("-.7E3")
      ))

      lex("-.73e-3") must be_==(tokens(
        real("-.73e-3")
      ))

      lex("-.7E-3") must be_==(tokens(
        real("-.7E-3")
      ))

      lex("-.7e+3") must be_==(tokens(
        real("-.7e+3")
      ))

      lex("-.75555555E+3") must be_==(tokens(
        real("-.75555555E+3")
      ))

      lex("123e2") must be_==(tokens(
        real("123e2")
      ))

      lex("123E2") must be_==(tokens(
        real("123E2")
      ))

      lex("123e+2") must be_==(tokens(
        real("123e+2")
      ))

      lex("123E+2") must be_==(tokens(
        real("123E+2")
      ))

      lex("123e-2") must be_==(tokens(
        real("123e-2")
      ))

      lex("123E-2") must be_==(tokens(
        real("123E-2")
      ))


      lex("-123e2") must be_==(tokens(
        real("-123e2")
      ))

      lex("-123E2") must be_==(tokens(
        real("-123E2")
      ))

      lex("-123e+2") must be_==(tokens(
        real("-123e+2")
      ))

      lex("-123E+2") must be_==(tokens(
        real("-123E+2")
      ))

      lex("-123e-2") must be_==(tokens(
        real("-123e-2")
      ))

      lex("-123E-2") must be_==(tokens(
        real("-123E-2")
      ))


      lex("+123e2") must be_==(tokens(
        real("+123e2")
      ))

      lex("+123E2") must be_==(tokens(
        real("+123E2")
      ))

      lex("+123e+2") must be_==(tokens(
        real("+123e+2")
      ))

      lex("+123E+2") must be_==(tokens(
        real("+123E+2")
      ))

      lex("+123e-2") must be_==(tokens(
        real("+123e-2")
      ))

      lex("+123E-2") must be_==(tokens(
        real("+123E-2")
      ))

      lex("123E-") must be_==(tokens(
        ident("123E-")
      ))
    }

//     "handle lexings of strings" in {
//       lex("\"\"") must be_==(tokens(
//         string("\"\"")
//       ))

//       lex("\"a\"") must be_==(tokens(
//         string("\"a\"")
//       ))

//       // TODO: more tests
//     }

    "handle lexings of comments" in {
      lex("a{# another \ncom#ment #}b") must be_==(tokens(
        ident("a"),
        ident("b")
      ))

      lex("a # one more comment\nb") must be_==(tokens(
        ident("a"),
        term,
        ident("b")
      ))
    }

//     "handle lexings of tri-strings" in {
//       lex("\"\"\"\"\"\"") must be_==(tokens(
//         triString("\"\"\"\"\"\"")
//       ))

//       lex("\"\"\"a\"\"\"") must be_==(tokens(
//         triString("\"\"\"a\"\"\"")
//       ))

//       // TODO: more tests
//     }

//     "handle lexings of regexp" in {
//       lex("//") must be_==(tokens(
//         regexp("//")
//       ))

//       lex("/a/") must be_==(tokens(
//         regexp("/a/")
//       ))

//       lex("/a/i") must be_==(tokens(
//         regexp("/a/i")
//       ))
//       // TODO: more tests
//     }

    "handle terminations correctly" in {
      lex("foo\nbar") must be_==(tokens(
        ident("foo"),
        term,
        ident("bar")
      ))

      lex("foo,\nbar") must be_==(tokens(
        ident("foo"),
        comma,
        ident("bar")
      ))
    }
  }
}
