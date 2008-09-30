parser grammar ioke;

options {
    output=AST;
    ASTLabelType=CommonTree;
    tokenVocab=ioke;
}

@header {
package org.ioke.parser;
}

ioke_program : ;
