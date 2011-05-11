
namespace Ioke.Lang.Parser {
    using Ioke.Lang;
    using Ioke.Lang.Util;
    using System.Collections;
    using System.Collections.Generic;

    public class Operators {
        public class OpEntry {
            public readonly string name;
            public readonly int precedence;
            public OpEntry(string name, int precedence) { 
                this.name = name; 
                this.precedence = precedence;
            }
        }

        public class OpArity {
            public readonly string name;
            public readonly int arity;
            public OpArity(string name, int arity) { 
                this.name = name; 
                this.arity = arity;
            }
        }

        public interface OpTableCreator {
            IDictionary Create(Runtime runtime);
        }

        public static readonly Dictionary<string, OpEntry>  DEFAULT_OPERATORS;
        public static readonly Dictionary<string, OpArity>  DEFAULT_ASSIGNMENT_OPERATORS;
        public static readonly Dictionary<string, OpEntry>  DEFAULT_INVERTED_OPERATORS;
        public static readonly ICollection<string> DEFAULT_UNARY_OPERATORS = new SaneHashSet<string>() {"-","~","$"};
        public static readonly ICollection<string> DEFAULT_ONLY_UNARY_OPERATORS = new SaneHashSet<string>() {"'","''","`",":"};

        private static void AddOpEntry(string name, int precedence, Dictionary<string, OpEntry> current) {
            current[name] = new OpEntry(name, precedence);
        }
    
        private static void AddOpArity(string name, int arity, Dictionary<string, OpArity> current){
            current[name] = new OpArity(name, arity);
        }

        private static IDictionary GetOpTable(IokeParser parser, IokeObject opTable, string name, OpTableCreator creator) {
            IokeObject operators = IokeObject.As(IokeObject.FindCell(opTable, name), null);
            if(operators != parser.runtime.nul && (IokeObject.dataOf(operators) is Dict)) {
                return Dict.GetMap(operators);
            } else {
                IDictionary result = creator.Create(parser.runtime);
                opTable.SetCell(name, parser.runtime.NewDict(result));
                return result;
            }
        }


        private class BinaryOpTableCreator : OpTableCreator {
            public IDictionary Create(Runtime runtime) {
                IDictionary table = new SaneHashtable();
                foreach(OpEntry ot in DEFAULT_OPERATORS.Values) {
                    table[runtime.GetSymbol(ot.name)] = runtime.NewNumber(ot.precedence);
                }
                return table;
            }
        }

        private class TrinaryOpTableCreator : OpTableCreator {
            public IDictionary Create(Runtime runtime) {
                IDictionary table = new SaneHashtable();
                foreach(OpArity ot in DEFAULT_ASSIGNMENT_OPERATORS.Values) {
                    table[runtime.GetSymbol(ot.name)] = runtime.NewNumber(ot.arity);
                }
                return table;
            }
        }

        private class InvertedOpTableCreator : OpTableCreator {
            public IDictionary Create(Runtime runtime) {
                IDictionary table = new SaneHashtable();
                foreach(OpEntry ot in DEFAULT_INVERTED_OPERATORS.Values) {
                    table[runtime.GetSymbol(ot.name)] = runtime.NewNumber(ot.precedence);
                }
                return table;
            }
        }


        public static void CreateOrGetOpTables(IokeParser parser) {
            var runtime = parser.runtime;
            IokeObject opTable = IokeObject.As(IokeObject.FindCell(runtime.Message, "OperatorTable"), null);
            if(opTable == runtime.nul) {
                opTable = runtime.NewFromOrigin();
                opTable.Kind = "Message OperatorTable";
                runtime.Message.SetCell("OperatorTable", opTable);
            }

            var tmpOperatorTable = GetOpTable(parser, opTable, "operators", new BinaryOpTableCreator());
            var tmpTrinaryOperatorTable = GetOpTable(parser, opTable, "trinaryOperators", new TrinaryOpTableCreator());
            var tmpInvertedOperatorTable = GetOpTable(parser, opTable, "invertedOperators", new InvertedOpTableCreator());

            foreach(DictionaryEntry entry in tmpOperatorTable) {
                AddOpEntry(Symbol.GetText(entry.Key), Number.IntValue(entry.Value).intValue(), parser.operatorTable);
            }

            foreach(DictionaryEntry entry in tmpTrinaryOperatorTable) {
                AddOpArity(Symbol.GetText(entry.Key), Number.IntValue(entry.Value).intValue(), parser.trinaryOperatorTable);
            }

            foreach(DictionaryEntry entry in tmpInvertedOperatorTable) {
                AddOpEntry(Symbol.GetText(entry.Key), Number.IntValue(entry.Value).intValue(), parser.invertedOperatorTable);
            }
        }

        static Operators() {
            var operators = new SaneDictionary<string, OpEntry>();

            AddOpEntry("!",   0, operators);
            AddOpEntry("?",   0, operators);
            AddOpEntry("$",   0, operators);
            AddOpEntry("~",   0, operators);
            AddOpEntry("#",   0, operators);

            AddOpEntry("**",  1, operators);

            AddOpEntry("*",   2, operators);
            AddOpEntry("/",   2, operators);
            AddOpEntry("%",   2, operators);

            AddOpEntry("+",   3, operators);
            AddOpEntry("-",   3, operators);
            AddOpEntry("\u2229", 3, operators);
            AddOpEntry("\u222A", 3, operators);

            AddOpEntry("<<",  4, operators);
            AddOpEntry(">>",  4, operators);

            AddOpEntry("<=>",  5, operators);
            AddOpEntry(">",   5, operators);
            AddOpEntry("<",   5, operators);
            AddOpEntry("<=",  5, operators);
            AddOpEntry("\u2264",  5, operators);
            AddOpEntry(">=",  5, operators);
            AddOpEntry("\u2265",  5, operators);
            AddOpEntry("<>",  5, operators);
            AddOpEntry("<>>",  5, operators);
            AddOpEntry("\u2282", 5, operators);
            AddOpEntry("\u2283", 5, operators);
            AddOpEntry("\u2286", 5, operators);
            AddOpEntry("\u2287", 5, operators);

            AddOpEntry("==",  6, operators);
            AddOpEntry("!=",  6, operators);
            AddOpEntry("\u2260",  6, operators);
            AddOpEntry("===",  6, operators);
            AddOpEntry("=~",  6, operators);
            AddOpEntry("!~",  6, operators);

            AddOpEntry("&",   7, operators);

            AddOpEntry("^",   8, operators);

            AddOpEntry("|",   9, operators);

            AddOpEntry("&&",  10, operators);
            AddOpEntry("?&",  10, operators);

            AddOpEntry("||",  11, operators);
            AddOpEntry("?|",  11, operators);

            AddOpEntry("..",  12, operators);
            AddOpEntry("...",  12, operators);
            AddOpEntry("=>",  12, operators);
            AddOpEntry("<->",  12, operators);
            AddOpEntry("->",  12, operators);
            AddOpEntry("\u2218", 12, operators);
            AddOpEntry("+>",  12, operators);
            AddOpEntry("!>",  12, operators);
            AddOpEntry("&>",  12, operators);
            AddOpEntry("%>",  12, operators);
            AddOpEntry("#>",  12, operators);
            AddOpEntry("@>",  12, operators);
            AddOpEntry("/>",  12, operators);
            AddOpEntry("*>",  12, operators);
            AddOpEntry("?>",  12, operators);
            AddOpEntry("|>",  12, operators);
            AddOpEntry("^>",  12, operators);
            AddOpEntry("~>",  12, operators);
            AddOpEntry("->>",  12, operators);
            AddOpEntry("+>>",  12, operators);
            AddOpEntry("!>>",  12, operators);
            AddOpEntry("&>>",  12, operators);
            AddOpEntry("%>>",  12, operators);
            AddOpEntry("#>>",  12, operators);
            AddOpEntry("@>>",  12, operators);
            AddOpEntry("/>>",  12, operators);
            AddOpEntry("*>>",  12, operators);
            AddOpEntry("?>>",  12, operators);
            AddOpEntry("|>>",  12, operators);
            AddOpEntry("^>>",  12, operators);
            AddOpEntry("~>>",  12, operators);
            AddOpEntry("=>>",  12, operators);
            AddOpEntry("**>",  12, operators);
            AddOpEntry("**>>",  12, operators);
            AddOpEntry("&&>",  12, operators);
            AddOpEntry("&&>>",  12, operators);
            AddOpEntry("||>",  12, operators);
            AddOpEntry("||>>",  12, operators);
            AddOpEntry("$>",  12, operators);
            AddOpEntry("$>>",  12, operators);

            AddOpEntry("and",  13, operators);
            AddOpEntry("nand",  13, operators);
            AddOpEntry("or",  13, operators);
            AddOpEntry("xor",  13, operators);
            AddOpEntry("nor",  13, operators);

            AddOpEntry("<-",  14, operators);

            AddOpEntry("return", 14, operators);
            AddOpEntry("import", 14, operators);

            DEFAULT_OPERATORS = operators;


            var aoperators = new SaneDictionary<string, OpArity>();
        
            AddOpArity("=", 2, aoperators);
            AddOpArity("+=", 2, aoperators);
            AddOpArity("-=", 2, aoperators);
            AddOpArity("/=", 2, aoperators);
            AddOpArity("*=", 2, aoperators);
            AddOpArity("**=", 2, aoperators);
            AddOpArity("%=", 2, aoperators);
            AddOpArity("&=", 2, aoperators);
            AddOpArity("&&=", 2, aoperators);
            AddOpArity("|=", 2, aoperators);
            AddOpArity("||=", 2, aoperators);
            AddOpArity("^=", 2, aoperators);
            AddOpArity("<<=", 2, aoperators);
            AddOpArity(">>=", 2, aoperators);
            AddOpArity("++", 1, aoperators);
            AddOpArity("--", 1, aoperators);

            DEFAULT_ASSIGNMENT_OPERATORS = aoperators;


            var ioperators = new SaneDictionary<string, OpEntry>();

            AddOpEntry("\u2208",  12, ioperators);
            AddOpEntry("\u2209",  12, ioperators);
            AddOpEntry("::",      12, ioperators);
            AddOpEntry(":::",     12, ioperators);

            DEFAULT_INVERTED_OPERATORS = ioperators;
        }
    }// Operators
}
