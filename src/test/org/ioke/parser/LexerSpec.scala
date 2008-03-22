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
  def term() = Tok(iokeLexer.PossibleTerminator, ";")

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

      lex("foo:: ::foo") must be_==(tokens(
        ident("foo::"), 
        ident("::foo")
      ))

      lex("&f:?!%o.._!</@|>*o-+---^~-`'-") must be_==(tokens(
        ident("&f:?!%o.._!</@|>*o-+---^~-`'-")
      ))

      lex("foo=") must be_==(tokens(
        ident("foo"), 
        ident("=")
      ))

      lex("foo=bar") must be_==(tokens(
        ident("foo"), 
        ident("="),
        ident("bar")
      ))
    }
    "handle lexings of symbol identifiers" in {}
    "handle lexings of argument lists" in {}
    "handle lexings of brackets" in {}
    "handle lexings of numbers" in {}
    "handle lexings of hex numbers" in {}
    "handle lexings of floats" in {}
    "handle lexings of strings" in {}
    "handle lexings of comments" in {}
    "handle lexings of tri-strings" in {}
  }
}
