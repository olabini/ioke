/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang.parser;

import java.util.Arrays;
import java.util.ArrayList;
import java.util.List;
import java.util.ListIterator;
import java.util.Map;
import java.util.HashMap;
import java.util.Set;
import java.util.HashSet;

import ioke.lang.IokeObject;
import ioke.lang.Message;
import ioke.lang.Runtime;
import ioke.lang.Dict;
import ioke.lang.Number;
import ioke.lang.Symbol;
import ioke.lang.IokeSystem;
import ioke.lang.exceptions.ControlFlow;

/**
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Operators {
    public static class OpEntry {
        public final String name;
        public final int precedence;
        public OpEntry(String name, int precedence) { 
            this.name = name; 
            this.precedence = precedence;
        }
    }

    public static class OpArity {
        public final String name;
        public final int arity;
        public OpArity(String name, int arity) { 
            this.name = name; 
            this.arity = arity;
        }
    }

    public static interface OpTableCreator {
        Map<Object, Object> create(Runtime runtime);
    }

    public final static Map<String, OpEntry> DEFAULT_OPERATORS;
    public final static Map<String, OpArity> DEFAULT_ASSIGNMENT_OPERATORS;
    public final static Map<String, OpEntry> DEFAULT_INVERTED_OPERATORS;
    public final static Set<String> DEFAULT_UNARY_OPERATORS = new HashSet(Arrays.asList("-","~","$"));
    public final static Set<String> DEFAULT_ONLY_UNARY_OPERATORS = new HashSet(Arrays.asList("'","''","`",":"));


    private final static void addOpEntry(String name, int precedence, Map<String, OpEntry> current){
        current.put(name, new OpEntry(name, precedence));
    }

    private final static void addOpArity(String name, int arity, Map<String, OpArity> current){
        current.put(name, new OpArity(name, arity));
    }

    private final static Map<Object, Object> getOpTable(IokeParser parser, IokeObject opTable, String name, OpTableCreator creator) throws ControlFlow {
        IokeObject operators = IokeObject.as(opTable.findCell(parser.message, parser.context, name), null);
        if(operators != parser.runtime.nul && (IokeObject.data(operators) instanceof Dict)) {
            return Dict.getMap(operators);
        } else {
            Map<Object, Object> result = creator.create(parser.runtime);
            opTable.setCell(name, parser.runtime.newDict(result));
            return result;
        }
    }

    public final static void createOrGetOpTables(IokeParser parser) throws ControlFlow {
        final ioke.lang.Runtime runtime = parser.runtime;
        IokeObject opTable = IokeObject.as(runtime.message.findCell(parser.message, parser.context, "OperatorTable"), null);
        if(opTable == runtime.nul) {
            opTable = runtime.newFromOrigin();
            opTable.setKind("Message OperatorTable");
            runtime.message.setCell("OperatorTable", opTable);
        }

        Map<Object, Object> tmpOperatorTable = getOpTable(parser, opTable, "operators", new OpTableCreator() {
                public Map<Object, Object> create(Runtime runtime) {
                    Map<Object, Object> table = new HashMap<Object, Object>();
                    for(OpEntry ot : DEFAULT_OPERATORS.values()) {
                        table.put(runtime.getSymbol(ot.name), runtime.newNumber(ot.precedence));
                    }
                    return table;
                }
            });
        
        Map<Object, Object> tmpTrinaryOperatorTable = getOpTable(parser, opTable, "trinaryOperators", new OpTableCreator() {
                public Map<Object, Object> create(Runtime runtime) {
                    Map<Object, Object> table = new HashMap<Object, Object>();
                    for(OpArity ot : DEFAULT_ASSIGNMENT_OPERATORS.values()) {
                        table.put(runtime.getSymbol(ot.name), runtime.newNumber(ot.arity));
                    }
                    return table;
                }
            });

        Map<Object, Object> tmpInvertedOperatorTable = getOpTable(parser, opTable, "invertedOperators", new OpTableCreator() {
                public Map<Object, Object> create(Runtime runtime) {
                    Map<Object, Object> table = new HashMap<Object, Object>();
                    for(OpEntry ot : DEFAULT_INVERTED_OPERATORS.values()) {
                        table.put(runtime.getSymbol(ot.name), runtime.newNumber(ot.precedence));
                    }
                    return table;
                }
            });

        for(Map.Entry<Object, Object> entry : tmpOperatorTable.entrySet()) {
            addOpEntry(Symbol.getText(entry.getKey()), Number.intValue(entry.getValue()).intValue(), parser.operatorTable);
        }
        for(Map.Entry<Object, Object> entry : tmpTrinaryOperatorTable.entrySet()) {
            addOpArity(Symbol.getText(entry.getKey()), Number.intValue(entry.getValue()).intValue(), parser.trinaryOperatorTable);
        }
        for(Map.Entry<Object, Object> entry : tmpInvertedOperatorTable.entrySet()) {
            addOpEntry(Symbol.getText(entry.getKey()), Number.intValue(entry.getValue()).intValue(), parser.invertedOperatorTable);
        }
    }

    static {
        Map<String, OpEntry> operators = new HashMap<String, OpEntry>();

		addOpEntry("!",   0, operators);
		addOpEntry("?",   0, operators);
		addOpEntry("$",   0, operators);
		addOpEntry("~",   0, operators);
		addOpEntry("#",   0, operators);

		addOpEntry("**",  1, operators);

		addOpEntry("*",   2, operators);
		addOpEntry("/",   2, operators);
		addOpEntry("%",   2, operators);

		addOpEntry("+",   3, operators);
		addOpEntry("-",   3, operators);
        addOpEntry("\u2229", 3, operators);
        addOpEntry("\u222A", 3, operators);

		addOpEntry("<<",  4, operators);
		addOpEntry(">>",  4, operators);

		addOpEntry("<=>",  5, operators);
		addOpEntry(">",   5, operators);
		addOpEntry("<",   5, operators);
		addOpEntry("<=",  5, operators);
		addOpEntry("\u2264",  5, operators);
		addOpEntry(">=",  5, operators);
		addOpEntry("\u2265",  5, operators);
		addOpEntry("<>",  5, operators);
		addOpEntry("<>>",  5, operators);
        addOpEntry("\u2282", 5, operators);
        addOpEntry("\u2283", 5, operators);
        addOpEntry("\u2286", 5, operators);
        addOpEntry("\u2287", 5, operators);

		addOpEntry("==",  6, operators);
		addOpEntry("!=",  6, operators);
		addOpEntry("\u2260",  6, operators);
		addOpEntry("===",  6, operators);
		addOpEntry("=~",  6, operators);
		addOpEntry("!~",  6, operators);

		addOpEntry("&",   7, operators);

		addOpEntry("^",   8, operators);

		addOpEntry("|",   9, operators);

		addOpEntry("&&",  10, operators);
		addOpEntry("?&",  10, operators);

		addOpEntry("||",  11, operators);
		addOpEntry("?|",  11, operators);

		addOpEntry("..",  12, operators);
		addOpEntry("...",  12, operators);
		addOpEntry("=>",  12, operators);
		addOpEntry("<->",  12, operators);
		addOpEntry("->",  12, operators);
        addOpEntry("\u2218", 12, operators);
		addOpEntry("+>",  12, operators);
		addOpEntry("!>",  12, operators);
		addOpEntry("&>",  12, operators);
		addOpEntry("%>",  12, operators);
		addOpEntry("#>",  12, operators);
		addOpEntry("@>",  12, operators);
		addOpEntry("/>",  12, operators);
		addOpEntry("*>",  12, operators);
		addOpEntry("?>",  12, operators);
		addOpEntry("|>",  12, operators);
		addOpEntry("^>",  12, operators);
		addOpEntry("~>",  12, operators);
		addOpEntry("->>",  12, operators);
		addOpEntry("+>>",  12, operators);
		addOpEntry("!>>",  12, operators);
		addOpEntry("&>>",  12, operators);
		addOpEntry("%>>",  12, operators);
		addOpEntry("#>>",  12, operators);
		addOpEntry("@>>",  12, operators);
		addOpEntry("/>>",  12, operators);
		addOpEntry("*>>",  12, operators);
		addOpEntry("?>>",  12, operators);
		addOpEntry("|>>",  12, operators);
		addOpEntry("^>>",  12, operators);
		addOpEntry("~>>",  12, operators);
		addOpEntry("=>>",  12, operators);
		addOpEntry("**>",  12, operators);
		addOpEntry("**>>",  12, operators);
		addOpEntry("&&>",  12, operators);
		addOpEntry("&&>>",  12, operators);
		addOpEntry("||>",  12, operators);
		addOpEntry("||>>",  12, operators);
		addOpEntry("$>",  12, operators);
		addOpEntry("$>>",  12, operators);

		addOpEntry("and",  13, operators);
		addOpEntry("nand",  13, operators);
		addOpEntry("or",  13, operators);
		addOpEntry("xor",  13, operators);
		addOpEntry("nor",  13, operators);

		addOpEntry("<-",  14, operators);

		addOpEntry("return", 14, operators);
		addOpEntry("import", 14, operators);

        DEFAULT_OPERATORS = operators;


        Map<String, OpArity> aoperators = new HashMap<String, OpArity>();
        
		addOpArity("=", 2, aoperators);
		addOpArity("+=", 2, aoperators);
		addOpArity("-=", 2, aoperators);
		addOpArity("/=", 2, aoperators);
		addOpArity("*=", 2, aoperators);
		addOpArity("**=", 2, aoperators);
		addOpArity("%=", 2, aoperators);
		addOpArity("&=", 2, aoperators);
		addOpArity("&&=", 2, aoperators);
		addOpArity("|=", 2, aoperators);
		addOpArity("||=", 2, aoperators);
		addOpArity("^=", 2, aoperators);
		addOpArity("<<=", 2, aoperators);
		addOpArity(">>=", 2, aoperators);
		addOpArity("++", 1, aoperators);
        addOpArity("--", 1, aoperators);

        DEFAULT_ASSIGNMENT_OPERATORS = aoperators;


        Map<String, OpEntry> ioperators = new HashMap<String, OpEntry>();

		addOpEntry("\u2208",  12, ioperators);
		addOpEntry("\u2209",  12, ioperators);
		addOpEntry("::",      12, ioperators);
		addOpEntry(":::",     12, ioperators);

        DEFAULT_INVERTED_OPERATORS = ioperators;
    }
}// Operators
