
namespace Ioke.Lang {
    using System;
    using System.Collections;
    using System.Collections.Generic;
    using System.IO;
    using System.Threading;
    using Ioke.Math;
    using Ioke.Lang.Parser;
    using Ioke.Lang.Util;
    using NETSystem = System;

    public class Runtime : IokeData {
        private bool debug = false;

        public bool Debug {
            get { return this.debug; }
            set { this.debug = value; }
        }

        private static int nextId = 1;
        private static int getNextId() {
            lock(typeof(Runtime)) {
                int ret = nextId;
                nextId++;
                return ret;
            }
        }
        private readonly int id;

        public IOperatorShufflerFactory operatorShufflerFactory;
        public Globber globber = new Ioke.Lang.Util.DefaultGlobber();

        public TextWriter Out;
        public TextWriter Error;
        public TextReader In;

        public IokeObject Base;
        public IokeObject IokeGround;
        public IokeObject Ground;
        public IokeObject System;
        public IokeObject DefaultBehavior;
        public IokeObject Origin;
        public IokeObject Message;
        public IokeObject Text;
        public IokeObject Symbol;
        public IokeObject nil;
        public new IokeObject True;
        public new IokeObject False;
        public IokeObject List;
        public IokeObject Method;
        public IokeObject NativeMethod;
        public IokeObject Io;
        public IokeObject Condition;
        public IokeObject Number;
        public IokeObject Dict;
        public IokeObject DefaultMethod;
        public IokeObject DefaultMacro;
        public IokeObject Call;
        public IokeObject Locals;
        public IokeObject LexicalBlock;
        public LexicalContext LexicalContext;
        public IokeObject DefaultSyntax;
        public IokeObject Range;
        public IokeObject Restart;
        public IokeObject Rescue;
        public IokeObject Handler;
        public IokeObject Mixins;
        public IokeObject _Runtime;
        public IokeObject Pair;
        public IokeObject Tuple;
        public IokeObject Regexp;
        public IokeObject FileSystem;
        public IokeObject Set;
        public IokeObject Arity;
        public IokeObject LexicalMacro;
        public IokeObject DateTime;
        public IokeObject Sequence;
        public IokeObject IteratorSequence;
        public IokeObject Iterator2Sequence;
        public IokeObject KeyValueIteratorSequence;

        public IokeObject asText;
        public IokeObject asTuple;
        public IokeObject opShuffle;
        public IokeObject printlnMessage;
        public IokeObject outMessage;
        public IokeObject nilMessage;
        public IokeObject isApplicableMessage;
        public IokeObject errorMessage;
        public IokeObject mimicMessage;
        public IokeObject callMessage;
        public IokeObject handlerMessage;
        public IokeObject nameMessage;
        public IokeObject conditionsMessage;
        public IokeObject codeMessage;
        public IokeObject testMessage;
        public IokeObject printMessage;
        public IokeObject reportMessage;
        public IokeObject currentDebuggerMessage;
        public IokeObject invokeMessage;
        public IokeObject minusMessage;
        public IokeObject asRationalMessage;
        public IokeObject spaceShipMessage;
        public IokeObject succMessage;
        public IokeObject predMessage;
        public IokeObject setValueMessage;
        public IokeObject inspectMessage;
        public IokeObject noticeMessage;
        public IokeObject removeCellMessage;
        public IokeObject eachMessage;
        public IokeObject plusMessage;
        public IokeObject multMessage;
        public IokeObject divMessage;
        public IokeObject modMessage;
        public IokeObject expMessage;
        public IokeObject binAndMessage;
        public IokeObject binOrMessage;
        public IokeObject binXorMessage;
        public IokeObject lshMessage;
        public IokeObject rshMessage;
        public IokeObject eqqMessage;
        public IokeObject asDecimalMessage;
        public IokeObject ltMessage;
        public IokeObject lteMessage;
        public IokeObject gtMessage;
        public IokeObject gteMessage;
        public IokeObject eqMessage;
        public IokeObject asSymbolMessage;
        public IokeObject FileMessage;
        public IokeObject closeMessage;

        public IokeObject cellAddedMessage;
        public IokeObject cellChangedMessage;
        public IokeObject cellRemovedMessage;
        public IokeObject cellUndefinedMessage;
        public IokeObject mimicAddedMessage;
        public IokeObject mimicRemovedMessage;
        public IokeObject mimicsChangedMessage;
        public IokeObject mimickedMessage;
        public IokeObject seqMessage;
        public IokeObject hashMessage;

        public readonly NullObject nul;

        public IokeObject Integer = null;
        public IokeObject Decimal = null;
        public IokeObject Ratio = null;
        public IokeObject Infinity = null;

        public Runtime(IOperatorShufflerFactory shuffler) : this(shuffler, Console.Out, Console.In, Console.Error) {
        }

        public Runtime(IOperatorShufflerFactory shuffler, TextWriter Out, TextReader In, TextWriter Error) {
            this.id = getNextId();
            this.operatorShufflerFactory = shuffler;
            this.Out = Out;
            this.In = In;
            this.Error = Error;

            Base = new IokeObject(this, "Base is the top of the inheritance structure. Most of the objects in the system are derived from this instance. Base should keep its cells to the bare minimum needed for the system.");
            IokeGround = new IokeObject(this, "IokeGround is the place that mimics default behavior, and where most global objects are defined.");
            Ground = new IokeObject(this, "Ground is the default place code is evaluated in.");
            System = new IokeObject(this, "System defines things that represents the currently running system, such as the load path.", new IokeSystem());
            DefaultBehavior = new IokeObject(this, "DefaultBehavior is a mixin that provides most of the methods shared by most instances in the system.");
            Origin = new IokeObject(this, "Any object created from scratch should usually be derived from Origin.");
            Message = new IokeObject(this, "A Message is the basic code unit in Ioke.", new Message(this, ""));
            Text = new IokeObject(this, "Contains an immutable piece of text.", new Text(""));
            Symbol = new IokeObject(this, "Represents a symbol - an object that always represents itself.", new Symbol(""));
            nil = new IokeObject(this, "nil is an oddball object that always represents itself. It can not be mimicked and (alongside false) is one of the two false values.", IokeData.Nil);
            True = new IokeObject(this, "true is an oddball object that always represents itself. It can not be mimicked and represents the a true value.", IokeData.True);
            False = new IokeObject(this, "false is an oddball object that always represents itself. It can not be mimicked and (alongside nil) is one of the two false values.", IokeData.False);
            List = new IokeObject(this, "A list is a collection of objects that can change size", new IokeList());
            Method = new IokeObject(this, "Method is the origin of all methods in the system, both default and Java..", new Method((string)null));
            NativeMethod = new IokeObject(this, "NativeMethod is a derivation of Method that represents a primitive implemented in Java.", new NativeMethod.WithNoArguments((string)null, null));
            Io = new IokeObject(this, "IO is the base for all input/output in Ioke.", new IokeIO());
            Condition = new IokeObject(this, "The root mimic of all the conditions in the system.");
            Number = new IokeObject(this, "Represents an exact number", new Number(Ioke.Lang.Number.GetFrom("0")));
            Dict = new IokeObject(this, "A dictionary is a collection of mappings from one object to another object. The default Dict implementation will use hashing for this.", new Dict());
            DefaultMethod = new IokeObject(this, "DefaultMethod is the instance all methods in the system are derived from.", new DefaultMethod((string)null));
            DefaultMacro = new IokeObject(this, "DefaultMacro is the instance all non-lexical macros in the system are derived from.", new DefaultMacro((string)null));
            Call = new IokeObject(this, "A call is the runtime structure that includes the specific information for a call, that is available inside a DefaultMacro.", new Call());
            Locals = new IokeObject(this, "Contains all the locals for a specific invocation.");
            LexicalBlock = new IokeObject(this, "A lexical block allows you to delay a computation in a specific lexical context. See DefaultMethod#fn for detailed documentation.", new LexicalBlock(this.Ground));
            LexicalContext = new LexicalContext(this, this.Ground, "A lexical activation context.", null, this.Ground);
            DefaultSyntax = new IokeObject(this, "DefaultSyntax is the instance all syntactical macros in the system are derived from.", new DefaultSyntax((string)null));
            Range = new IokeObject(this, "A range is a collection of two objects of the same kind. This Range can be either inclusive or exclusive.", new Range(nil, nil, false, false));
            Restart = new IokeObject(this, "A Restart is the actual object that contains restart information.");
            Rescue = new IokeObject(this, "A Rescue contains handling information from rescuing a Condition.");
            Handler = new IokeObject(this, "A Handler contains handling information for handling a condition without unwinding the stack.");
            Mixins = new IokeObject(this, "Mixins is the name space for most mixins in the system. DefaultBehavior is the notable exception.");
            _Runtime = new IokeObject(this, "Runtime gives meta-circular access to the currently executing Ioke runtime.", this);
            Pair = new IokeObject(this, "A pair is a collection of two objects of any kind. They are used among other things to represent Dict entries.", new Pair(nil, nil));
            Tuple = new IokeObject(this, "A tuple is a collection of objects of any kind. It is immutable and supports destructuring.", new Tuple(new object[0]));
            Regexp = new IokeObject(this, "A regular expression allows you to matching text against a pattern.", Ioke.Lang.Regexp.Create("", ""));
            FileSystem = new IokeObject(this, "Gives access to things related to the file system.");
            Set = new IokeObject(this, "A set is an unordered collection of objects that contains no duplicates.", new IokeSet());
            Arity = new IokeObject(this, "Arity provides information about the arguments needed to activate a value.", new Arity((DefaultArgumentsDefinition) null));
            LexicalMacro = new IokeObject(this, "LexicalMacro is the instance all lexical macros in the system are derived from.", new LexicalMacro((string)null));
            DateTime = new IokeObject(this, "A DateTime represents the current date and time in a particular time zone.", new DateTime(0));
            Sequence = new IokeObject(this, "The root mimic of all the sequences in the system.");
            IteratorSequence = new IokeObject(this, "The root mimic of all the iterator sequences in the system.", new Sequence.IteratorSequence(null));
            Iterator2Sequence = new IokeObject(this, "The root mimic of all the iterator sequences in the system.", new Sequence.Iterator2Sequence(null));
            KeyValueIteratorSequence = new IokeObject(this, "The root mimic of all the key-value-iterator sequences in the system.", new Sequence.KeyValueIteratorSequence(null));

            asText = NewMessage("asText");
            asTuple = NewMessage("asTuple");
            opShuffle = NewMessage("shuffleOperators");
            printlnMessage = NewMessage("println");
            outMessage = NewMessage("out");
            nilMessage = NewMessage("nil");
            isApplicableMessage = NewMessage("applicable?");
            errorMessage = NewMessage("error!");
            mimicMessage = NewMessage("mimic");
            callMessage = NewMessage("call");
            handlerMessage = NewMessage("handler");
            nameMessage = NewMessage("name");
            conditionsMessage = NewMessage("conditions");
            codeMessage = NewMessage("code");
            testMessage = NewMessage("test");
            printMessage = NewMessage("print");
            reportMessage = NewMessage("report");
            currentDebuggerMessage = NewMessage("currentDebugger");
            invokeMessage = NewMessage("invoke");
            minusMessage = NewMessage("-");
            asRationalMessage = NewMessage("asRational");
            spaceShipMessage = NewMessage("<=>");
            succMessage = NewMessage("succ");
            predMessage = NewMessage("pred");
            setValueMessage = NewMessage("=");
            inspectMessage = NewMessage("inspect");
            noticeMessage = NewMessage("notice");
            removeCellMessage = NewMessage("removeCell!");
            eachMessage = NewMessage("each");
            plusMessage = NewMessage("+");
            multMessage = NewMessage("*");
            divMessage = NewMessage("/");
            modMessage = NewMessage("%");
            expMessage = NewMessage("**");
            binAndMessage = NewMessage("&");
            binOrMessage = NewMessage("|");
            binXorMessage = NewMessage("^");
            lshMessage = NewMessage("<<");
            rshMessage = NewMessage(">>");
            eqqMessage = NewMessage("===");
            asDecimalMessage = NewMessage("asDecimal");
            ltMessage = NewMessage("<");
            lteMessage = NewMessage("<=");
            gtMessage = NewMessage(">");
            gteMessage = NewMessage(">=");
            eqMessage = NewMessage("==");
            asSymbolMessage = NewMessage("asSymbol");
            FileMessage = NewMessage("File");
            closeMessage = NewMessage("close");

            cellAddedMessage = NewMessage("cellAdded");
            cellChangedMessage = NewMessage("cellChanged");
            cellRemovedMessage = NewMessage("cellRemoved");
            cellUndefinedMessage = NewMessage("cellUndefined");
            mimicAddedMessage = NewMessage("mimicAdded");
            mimicRemovedMessage = NewMessage("mimicRemoved");
            mimicsChangedMessage = NewMessage("mimicsChanged");
            mimickedMessage = NewMessage("mimicked");
            seqMessage = NewMessage("seq");
            hashMessage = NewMessage("hash");

            nul = new NullObject(this);

            symbolTable = new SaneDictionary<string, IokeObject>();
        }

        public void Init() {
            Ioke.Lang.Base.Init(this.Base);
            Ioke.Lang.DefaultBehavior.Init(DefaultBehavior);
            Ioke.Lang.Mixins.Init(this.Mixins);
            System.Init();
            Ioke.Lang.Runtime.InitRuntime(this._Runtime);
            Message.Init();
            Ioke.Lang.Ground.Init(this.IokeGround, this.Ground);
            Ioke.Lang.Origin.Init(this.Origin);
            nil.Init();
            True.Init();
            False.Init();
            Text.Init();
            Symbol.Init();
            Number.Init();
            Range.Init();
            Pair.Init();
            Tuple.Init();
            DateTime.Init();
            LexicalContext.Init();
            List.Init();
            Dict.Init();
            this.Set.Init();
            this.Call.Init();
            Ioke.Lang.Locals.Init(this.Locals);
            Ioke.Lang.Condition.Init(Condition);
            Ioke.Lang.Rescue.Init(this.Rescue);
            Ioke.Lang.Handler.Init(this.Handler);
            Io.Init();
            Ioke.Lang.FileSystem.Init(this.FileSystem);
            this.Regexp.Init();

            IokeGround.MimicsWithoutCheck(this.DefaultBehavior);
            IokeGround.MimicsWithoutCheck(this.Base);
            Ground.MimicsWithoutCheck(this.IokeGround);
            Origin.MimicsWithoutCheck(this.Ground);

            this.Mixins.MimicsWithoutCheck(this.DefaultBehavior);

            System.MimicsWithoutCheck(Ground);
            System.MimicsWithoutCheck(DefaultBehavior);
            this._Runtime.MimicsWithoutCheck(Ground);
            this._Runtime.MimicsWithoutCheck(DefaultBehavior);

            nil.MimicsWithoutCheck(Origin);
            True.MimicsWithoutCheck(Origin);
            False.MimicsWithoutCheck(Origin);
            Text.MimicsWithoutCheck(Origin);
            Symbol.MimicsWithoutCheck(Origin);
            Number.MimicsWithoutCheck(Origin);
            Range.MimicsWithoutCheck(Origin);
            Pair.MimicsWithoutCheck(Origin);
            this.DateTime.MimicsWithoutCheck(this.Origin);

            Message.MimicsWithoutCheck(Origin);
            Method.MimicsWithoutCheck(Origin);

            this.List.MimicsWithoutCheck(Origin);
            this.Dict.MimicsWithoutCheck(Origin);
            this.Set.MimicsWithoutCheck(Origin);

            Condition.MimicsWithoutCheck(Origin);
            Rescue.MimicsWithoutCheck(Origin);
            Handler.MimicsWithoutCheck(Origin);

            Io.MimicsWithoutCheck(Origin);

            this.FileSystem.MimicsWithoutCheck(this.Origin);

            this.Regexp.MimicsWithoutCheck(Origin);

            this.Method.Init();
            this.DefaultMethod.Init();
            this.NativeMethod.Init();
            this.LexicalBlock.Init();
            this.DefaultMacro.Init();
            this.LexicalMacro.Init();
            this.DefaultSyntax.Init();
            this.Arity.Init();
            this.Call.MimicsWithoutCheck(Origin);

            this.DefaultMethod.MimicsWithoutCheck(this.Method);
            this.NativeMethod.MimicsWithoutCheck(this.Method);
            this.DefaultMacro.MimicsWithoutCheck(this.Origin);
            this.LexicalMacro.MimicsWithoutCheck(this.Origin);
            this.DefaultSyntax.MimicsWithoutCheck(this.Origin);
            this.Arity.MimicsWithoutCheck(Origin);
            this.LexicalBlock.MimicsWithoutCheck(this.Origin);

            Ioke.Lang.Restart.Init(this.Restart);
            this.Restart.MimicsWithoutCheck(this.Origin);

            Reflector.Init(this);
            Hook.Init(this);

            Ioke.Lang.Sequence.Init(this.Sequence);
            this.IteratorSequence.Init();
            this.Iterator2Sequence.Init();
            this.KeyValueIteratorSequence.Init();

            AddBuiltinScript("benchmark", new Builtin.Delegate((runtime, context, message) => {
                        return Ioke.Lang.Extensions.Benchmark.Benchmark.Create(runtime);
                    }));

            AddBuiltinScript("readline", new Builtin.Delegate((runtime, context, message) => {
                        return Ioke.Lang.Extensions.Readline.Readline.Create(runtime);
                    }));

            try {
                EvaluateString("use(\"builtin/A05_conditions\")", Message, Ground);
                EvaluateString("use(\"builtin/A10_defaultBehavior\")", Message, Ground);
                EvaluateString("use(\"builtin/A15_dmacro\")", Message, Ground);
                EvaluateString("use(\"builtin/A20_comparing\")", Message, Ground);
                EvaluateString("use(\"builtin/A25_defaultBehavior_inspection\")", Message, Ground);
                EvaluateString("use(\"builtin/A30_system\")", Message, Ground);

                EvaluateString("use(\"builtin/D05_number\")", Message, Ground);
                EvaluateString("use(\"builtin/D10_call\")", Message, Ground);
                EvaluateString("use(\"builtin/D15_range\")", Message, Ground);
                EvaluateString("use(\"builtin/D20_booleans\")", Message, Ground);
                EvaluateString("use(\"builtin/D25_list\")", Message, Ground);
                EvaluateString("use(\"builtin/D30_dict\")", Message, Ground);
                EvaluateString("use(\"builtin/D35_pair\")", Message, Ground);
                EvaluateString("use(\"builtin/D37_tuple\")", Message, Ground);
                EvaluateString("use(\"builtin/D40_text\")", Message, Ground);
                EvaluateString("use(\"builtin/D43_regexp\")", Message, Ground);
                EvaluateString("use(\"builtin/D45_fileSystem\")", Message, Ground);
                EvaluateString("use(\"builtin/D50_runtime\")", Message, Ground);

                EvaluateString("use(\"builtin/F05_case\")", Message, Ground);
                EvaluateString("use(\"builtin/F10_comprehensions\")", Message, Ground);
                EvaluateString("use(\"builtin/F15_message\")", Message, Ground);
                EvaluateString("use(\"builtin/F20_set\")", Message, Ground);
                EvaluateString("use(\"builtin/F25_cond\")", Message, Ground);
                EvaluateString("use(\"builtin/F30_enumerable\")", Message, Ground);
                EvaluateString("use(\"builtin/F32_sequence\")", Message, Ground);

                EvaluateString("use(\"builtin/G05_aspects\")", Message, Ground);
                EvaluateString("use(\"builtin/G10_origin\")", Message, Ground);
                EvaluateString("use(\"builtin/G10_arity\")", Message, Ground);

                EvaluateString("use(\"builtin/G50_hook\")", Message, Ground);

                EvaluateString("use(\"builtin/H10_lexicalBlock\")", Message, Ground);
            } catch(ControlFlow cf) {
                Console.Error.WriteLine("Internal problem: " + cf);
            }
        }

        public IokeObject CreateMessage(Message m) {
            IokeObject obj = this.Message.AllocateCopy(null, null);
            obj.MimicsWithoutCheck(this.Message);
            obj.Data = m;
            return obj;
        }

        public string CurrentWorkingDirectory {
            get { return ((IokeSystem)IokeObject.dataOf(System)).CurrentWorkingDirectory; }
            set {
                ((IokeSystem)IokeObject.dataOf(System)).CurrentWorkingDirectory = value;
            }
        }

        public void AddArgument(string arg) {
            ((IokeSystem)IokeObject.dataOf(System)).AddArgument(arg);
        }

        public IokeObject NewText(string text) {
            IokeObject obj = this.Text.AllocateCopy(null, null);
            obj.MimicsWithoutCheck(this.Text);
            obj.Data = new Text(text);
            return obj;
        }

        public IokeObject NewRegexp(string pattern, string flags, IokeObject context, IokeObject message) {
            IokeObject obj = this.Regexp.AllocateCopy(null, null);
            obj.MimicsWithoutCheck(this.Regexp);
            obj.Data = Ioke.Lang.Regexp.Create(pattern, flags, context, message);
            return obj;
        }

        public IokeObject NewList(IList list) {
            IokeObject obj = this.List.AllocateCopy(null, null);
            obj.MimicsWithoutCheck(this.List);
            obj.Data = new IokeList(list);
            return obj;
        }

        public IokeObject NewList(IList list, IokeObject orig) {
            IokeObject obj = orig.AllocateCopy(null, null);
            obj.MimicsWithoutCheck(orig);
            obj.Data = new IokeList(list);
            return obj;
        }

        public IokeObject NewSet(ICollection objs) {
            IokeObject obj = this.Set.AllocateCopy(null, null);
            obj.MimicsWithoutCheck(this.Set);
            var hh = new SaneHashSet<object>();
            foreach(object o in objs) hh.Add(o);
            obj.Data = new IokeSet(hh);
            return obj;
        }

        public IokeObject NewSet(ICollection<object> objs) {
            IokeObject obj = this.Set.AllocateCopy(null, null);
            obj.MimicsWithoutCheck(this.Set);
            obj.Data = new IokeSet(new SaneHashSet<object>(objs));
            return obj;
        }

        public IokeObject NewDict(IDictionary map) {
            IokeObject obj = this.Dict.AllocateCopy(null, null);
            obj.MimicsWithoutCheck(this.Dict);
            obj.Data = new Dict(map);
            return obj;
        }

        public IokeObject NewMessage(string name) {
            return CreateMessage(new Message(this, name));
        }

        public IokeObject NewMessageFrom(IokeObject m, string name, IList args) {
            Message mess = new Message(this, name);
            mess.File = m.File;
            mess.Line = m.Line;
            mess.Position = m.Position;
            mess.SetArguments(args);
            return CreateMessage(mess);
        }

        public IokeObject NewLexicalBlock(string doc, IokeObject tp, LexicalBlock impl) {
            IokeObject obj = tp.AllocateCopy(null, null);
            obj.SetDocumentation(doc, null, null);
            obj.MimicsWithoutCheck(tp);
            obj.Data = impl;
            return obj;
        }

        public IokeObject NewCallFrom(IokeObject ctx, IokeObject message, IokeObject surroundingContext, IokeObject on) {
            IokeObject obj = this.Call.AllocateCopy(null, null);
            obj.MimicsWithoutCheck(this.Call);
            obj.Data = new Call(ctx, message, surroundingContext, on);
            return obj;
        }

        public IokeObject NewNativeMethod(String doc, NativeMethod impl) {
            return NewMethod(doc, this.NativeMethod, impl);
        }

        public IokeObject NewMethod(String doc, IokeObject tp, Method impl) {
            IokeObject obj = tp.AllocateCopy(null, null);
            obj.SetDocumentation(doc, null, null);
            obj.MimicsWithoutCheck(tp);
            obj.Data = impl;
            return obj;
        }

        public IokeObject NewMacro(string doc, IokeObject tp, IokeData impl) {
            IokeObject obj = tp.AllocateCopy(null, null);
            obj.SetDocumentation(doc, null, null);
            obj.MimicsWithoutCheck(tp);
            obj.Data = impl;
            return obj;
        }

        public IokeObject NewFromOrigin() {
            return this.Origin.Mimic(null, null);
        }

        public IokeObject NewRange(IokeObject from, IokeObject to, bool inclusive, bool inverted) {
            IokeObject obj = this.Range.AllocateCopy(null, null);
            obj.MimicsWithoutCheck(this.Range);
            obj.Data = new Range(from, to, inclusive, inverted);
            return obj;
        }

        public IokeObject NewFile(IokeObject context, FileInfo eff)  {
            IokeObject fileMimic = IokeObject.As(((Message)IokeObject.dataOf(FileMessage)).SendTo(FileMessage, context, this.FileSystem), context);
            IokeObject obj = fileMimic.AllocateCopy(null, null);
            obj.MimicsWithoutCheck(fileMimic);
            obj.Data = new FileSystem.IokeFile(eff);
            return obj;
        }

        public IokeObject NewPair(object first, object second) {
            IokeObject obj = this.Pair.AllocateCopy(null, null);
            obj.MimicsWithoutCheck(this.Pair);
            obj.Data = new Pair(first, second);
            return obj;
        }

        public IokeObject NewDateTime(System.DateTime dt) {
            IokeObject obj = this.DateTime.AllocateCopy(null, null);
            obj.MimicsWithoutCheck(this.DateTime);
            obj.Data = new DateTime(dt);
            return obj;
        }

        public IokeObject NewNumber(string number) {
            return NewNumber(Ioke.Lang.Number.GetFrom(number));
        }

        public IokeObject NewNumber(int number) {
            return NewNumber(Ioke.Lang.Number.GetFrom((long)number));
        }

        public IokeObject NewNumber(long number) {
            return NewNumber(Ioke.Lang.Number.GetFrom(number));
        }

        private IDictionary<IntNum, IokeObject> numCache = new SaneDictionary<IntNum, IokeObject>();

        public IokeObject NewNumber(IntNum number) {
            if(numCache.ContainsKey(number))
                return numCache[number];
            IokeObject obj = this.Integer.AllocateCopy(null, null);
            obj.MimicsWithoutCheck(this.Integer);
            obj.Data = Ioke.Lang.Number.Integer(number);
            numCache[number] = obj;
            return obj;
        }

        public IokeObject NewNumber(RatNum number) {
            if(number is IntNum) {
                return NewNumber((IntNum)number);
            } else {
                IokeObject obj = this.Ratio.AllocateCopy(null, null);
                obj.MimicsWithoutCheck(this.Ratio);
                obj.Data = Ioke.Lang.Number.Ratio((IntFraction)number);
                return obj;
            }
        }

        public IokeObject NewDecimal(string number) {
            IokeObject obj = this.Decimal.AllocateCopy(null, null);
            obj.MimicsWithoutCheck(this.Decimal);
            obj.Data = Ioke.Lang.Decimal.CreateDecimal(number);
            return obj;
        }

        public IokeObject NewDecimal(Number number) {
            IokeObject obj = this.Decimal.AllocateCopy(null, null);
            obj.MimicsWithoutCheck(this.Decimal);
            obj.Data = Ioke.Lang.Decimal.CreateDecimal(number.Value);
            return obj;
        }

        public IokeObject NewDecimal(BigDecimal number) {
            IokeObject obj = this.Decimal.AllocateCopy(null, null);
            obj.MimicsWithoutCheck(this.Decimal);
            obj.Data = Ioke.Lang.Decimal.CreateDecimal(number);
            return obj;
        }

        private IDictionary<string, Builtin> builtins = new SaneDictionary<string, Builtin>();

        public void AddBuiltinScript(string name, Builtin builtin) {
            builtins[name] = builtin;
        }

        public Builtin GetBuiltin(string name) {
            if(builtins.ContainsKey(name)) {
                return builtins[name];
            } else {
                return null;
            }
        }

        public IokeObject ParseStream(TextReader reader, IokeObject message, IokeObject context) {
            return Ioke.Lang.Message.NewFromStream(this, reader, message, context);
        }

        public object EvaluateString(string str, IokeObject message, IokeObject context) {
            IokeObject msg = ParseStream(new StringReader(str), message, context);
            if(msg != null) {
                return ((Message)IokeObject.dataOf(msg)).EvaluateComplete(msg);
            } else {
                return nil;
            }
        }

        public object EvaluateStream(TextReader reader, IokeObject message, IokeObject context) {
            IokeObject msg = ParseStream(reader, message, context);
            if(msg != null) {
                return ((Message)IokeObject.dataOf(msg)).EvaluateComplete(msg);
            } else {
                return nil;
            }
        }

        public object EvaluateStream(string name, TextReader reader, IokeObject message, IokeObject context) {
            try {
                ((IokeSystem)IokeObject.dataOf(System)).PushCurrentFile(name);
                return EvaluateStream(reader, message, context);
            } catch(ControlFlow) {
                throw;
            } catch(Exception e) {
                ReportNativeException(e, message, context);
                return null;
            } finally {
                ((IokeSystem)IokeObject.dataOf(System)).PopCurrentFile();
            }
        }

        public object EvaluateFile(string filename, IokeObject message, IokeObject context) {
            try {
                ((IokeSystem)IokeObject.dataOf(System)).PushCurrentFile(filename);
                if(IokeSystem.IsAbsoluteFileName(filename)) {
                    return EvaluateStream(new StreamReader(File.OpenRead(filename), NETSystem.Text.Encoding.UTF8), message, context);
                } else {
                    return EvaluateStream(new StreamReader(File.OpenRead(Path.Combine(((IokeSystem)IokeObject.dataOf(System)).CurrentWorkingDirectory, filename)), NETSystem.Text.Encoding.UTF8), message, context);
                }
            } catch(ControlFlow) {
                throw;
            } catch(Exception e) {
                ReportNativeException(e, message, context);
                return null;
            } finally {
                ((IokeSystem)IokeObject.dataOf(System)).PopCurrentFile();
            }
        }

        public object EvaluateFile(FileInfo filename, IokeObject message, IokeObject context) {
            try {
                ((IokeSystem)IokeObject.dataOf(System)).PushCurrentFile(filename.FullName);
                return EvaluateStream(new StreamReader(filename.OpenRead(), NETSystem.Text.Encoding.UTF8), message, context);
            } catch(ControlFlow) {
                throw;
            } catch(Exception e) {
                ReportNativeException(e, message, context);
                return null;
            } finally {
                ((IokeSystem)IokeObject.dataOf(System)).PopCurrentFile();
            }
        }

        public void ReportNativeException(Exception e, IokeObject message, IokeObject context) {
            IokeObject condition = IokeObject.As(IokeObject.GetCellChain(this.Condition,
                                                                         message,
                                                                         context,
                                                                         "Error",
                                                                         "NativeException"), context).Mimic(message, context);
            condition.SetCell("message", message);
            condition.SetCell("context", context);
            condition.SetCell("receiver", context);
            condition.SetCell("exceptionType", NewText(e.GetType().FullName));

            if(e.Message != null) {
                condition.SetCell("exceptionMessage", NewText(e.Message));
            } else {
                condition.SetCell("exceptionMessage", nil);
            }

            var st = new System.Diagnostics.StackTrace(e);
            var ob = new SaneArrayList();
            foreach(var frame in st.GetFrames()) {
                ob.Add(NewText(frame.ToString()));
            }
            condition.SetCell("exceptionStackTrace", NewList(ob));

            this.ErrorCondition(condition);
        }

        private IDictionary<string, IokeObject> symbolTable;
        public IokeObject GetSymbol(string name) {
            lock(symbolTable) {
                if(symbolTable.ContainsKey(name))
                    return symbolTable[name];

                IokeObject obj = new IokeObject(this, null, new Symbol(name));
                obj.MimicsWithoutCheck(this.Symbol);
                symbolTable[name] = obj;
                return obj;
            }
        }

        public void TearDown() {
            int status = 0;
            IList<IokeSystem.AtExitInfo> atExits = IokeSystem.GetAtExits(System);
            while(atExits.Count > 0) {
                IokeSystem.AtExitInfo atExit = atExits[0];
                atExits.RemoveAt(0);
                try {
                    ((Message)IokeObject.dataOf(atExit.message)).EvaluateCompleteWithoutExplicitReceiver(atExit.message, atExit.context, atExit.context.RealContext);
                } catch(ControlFlow.Exit) {
                    status = 1;
                } catch(ControlFlow e) {
                    string name = e.GetType().FullName;
                    Console.Error.WriteLine("unexpected control flow: " + name.Substring(name.LastIndexOf(".") + 1).ToLower());
                    if(debug) {
                        Console.Error.WriteLine(e);
                    }
                    status = 1;
                }
            }
            if(status != 0) {
                throw new ControlFlow.Exit();
            }
        }

        public delegate void RunnableWithControlFlow ();
        public delegate object RunnableWithReturnAndControlFlow ();

        public object WithRestartReturningArguments(RunnableWithControlFlow code, IokeObject context, params Restart.NativeRestart[] restarts) {
            IList<RestartInfo> rrs = new SaneList<RestartInfo>();
            BindIndex index = GetBindIndex();

            foreach(Restart.NativeRestart rjr in restarts) {
                IokeObject rr = IokeObject.As(((Message)IokeObject.dataOf(this.mimicMessage)).SendTo(this.mimicMessage, context, this.Restart), context);
                IokeObject.SetCell(rr, "name", GetSymbol(rjr.Name), context);

                IList args = new SaneArrayList();
                foreach(string argName in rjr.ArgumentNames) {
                    args.Add(GetSymbol(argName));
                }

                IokeObject.SetCell(rr, "name", GetSymbol(rjr.Name), context);
                IokeObject.SetCell(rr, "argumentNames", NewList(args), context);

                string report = rjr.Report();
                if(report != null) {
                    IokeObject.SetCell(rr, "report", EvaluateString("fn(r, \"" + report + "\")", this.Message, this.Ground), context);
                }

                rrs.Insert(0, new RestartInfo(rjr.Name, rr, rrs, index, rjr));
                index = index.NextCol();
            }
            RegisterRestarts(rrs);

            try {
                code();
                return new SaneArrayList();
            } catch(ControlFlow.Restart e) {
                RestartInfo ri = null;
                if((ri = e.GetRestart).token == rrs) {
                    Restart.NativeRestart currentRjr = (Restart.NativeRestart)ri.data;
                    IokeObject result = currentRjr.Invoke(context, e.Arguments);
                    return result;
                } else {
                    throw e;
                }
            } finally {
                UnregisterRestarts(rrs);
            }
        }

        public void WithReturningRestart(string name, IokeObject context, RunnableWithControlFlow code) {
            IokeObject rr = IokeObject.As(((Message)IokeObject.dataOf(this.mimicMessage)).SendTo(this.mimicMessage, context, this.Restart), context);
            IokeObject.SetCell(rr, "name", GetSymbol(name), context);
            IokeObject.SetCell(rr, "argumentNames", NewList(new SaneArrayList()), context);

            IList<RestartInfo> rrs = new SaneList<RestartInfo>();
            BindIndex index = GetBindIndex();
            rrs.Insert(0, new RestartInfo(name, rr, rrs, index, null));
            index = index.NextCol();
            RegisterRestarts(rrs);

            try {
                code();
            } catch(ControlFlow.Restart e) {
                if(e.GetRestart.token == rrs) {
                    return;
                } else {
                    throw e;
                }
            } finally {
                UnregisterRestarts(rrs);
            }
        }

        public object WithReturningRescue(IokeObject context, object toReturn, RunnableWithReturnAndControlFlow nativeRescue) {
            IList<RescueInfo> rescues = new SaneList<RescueInfo>();
            IokeObject rr = IokeObject.As(((Message)IokeObject.dataOf(this.mimicMessage)).SendTo(this.mimicMessage, context, this.Rescue), context);
            IList conds = new SaneArrayList();
            conds.Add(this.Condition);
            rescues.Add(new RescueInfo(rr, conds, rescues, GetBindIndex()));
            RegisterRescues(rescues);
            try {
                return nativeRescue();
            } catch(ControlFlow.Rescue e) {
                if(e.GetRescue.token == rescues) {
                    return toReturn;
                } else {
                    throw e;
                }
            } finally {
                UnregisterRescues(rescues);
            }
        }

        public class RescueInfo {
            public readonly IokeObject rescue;
            public readonly IList applicableConditions;
            public readonly object token;
            public readonly BindIndex index;
            public RescueInfo(IokeObject rescue, IList applicableConditions, object token, BindIndex index) {
                this.rescue = rescue;
                this.applicableConditions = applicableConditions;
                this.token = token;
                this.index = index;
            }

            public override string ToString() {
                return "rescueInfo(" + index + ")";
            }
        }

        public class HandlerInfo {
            public readonly IokeObject handler;
            public readonly IList applicableConditions;
            public readonly object token;
            public readonly BindIndex index;
            public HandlerInfo(IokeObject handler, IList applicableConditions, object token, BindIndex index) {
                this.handler = handler;
                this.applicableConditions = applicableConditions;
                this.token = token;
                this.index = index;
            }
        }

        public class RestartInfo {
            public readonly string name;
            public readonly IokeObject restart;
            public readonly object token;
            public readonly BindIndex index;
            public readonly object data;
            public RestartInfo(string name, IokeObject restart, object token, BindIndex index, object data) {
                this.name = name;
                this.restart = restart;
                this.token = token;
                this.index = index;
                this.data = data;
            }
        }

        private LocalDataStoreSlot restarts = Thread.GetNamedDataSlot("ioke.restarts");
        private LocalDataStoreSlot rescues = Thread.GetNamedDataSlot("ioke.rescues");
        private LocalDataStoreSlot handlers = Thread.GetNamedDataSlot("ioke.handlers");

        private IList<IList<RestartInfo>> Restarts {
            get {
                object r = Thread.GetData(restarts);
                if(r == null) {
                    r = new SaneList<IList<RestartInfo>>();
                    Thread.SetData(restarts, r);
                }
                return (IList<IList<RestartInfo>>)r;
            }
        }

        private IList<IList<RescueInfo>> Rescues {
            get {
                object r = Thread.GetData(rescues);
                if(r == null) {
                    r = new SaneList<IList<RescueInfo>>();
                    Thread.SetData(rescues, r);
                }
                return (IList<IList<RescueInfo>>)r;
            }
        }

        private IList<IList<HandlerInfo>> Handlers {
            get {
                object r = Thread.GetData(handlers);
                if(r == null) {
                    r = new SaneList<IList<HandlerInfo>>();
                    Thread.SetData(handlers, r);
                }
                return (IList<IList<HandlerInfo>>)r;
            }
        }

        public void RegisterRestarts(IList<RestartInfo> restarts) {
            Restarts.Insert(0, restarts);
        }

        public void UnregisterRestarts(IList<RestartInfo> restarts) {
            Restarts.Remove(restarts);
        }

        public void RegisterRescues(IList<RescueInfo> rescues) {
            Rescues.Insert(0, rescues);
        }

        public void UnregisterRescues(IList<RescueInfo> rescues) {
            Rescues.Remove(rescues);
        }

        public void RegisterHandlers(IList<HandlerInfo> handlers) {
            Handlers.Insert(0, handlers);
        }

        public void UnregisterHandlers(IList<HandlerInfo> handlers) {
            Handlers.Remove(handlers);
        }

        public class BindIndex {
            public readonly int row;
            public readonly int col;
            public BindIndex(int row) : this(row, 0) {}
            public BindIndex(int row, int col) {
                this.row = row;
                this.col = col;
            }
            public BindIndex NextCol() {
                return new BindIndex(this.row, this.col+1);
            }
            public bool LessThan(BindIndex other) {
                return this.row < other.row ||
                    (this.row == other.row && this.col < other.col);
            }
            public bool GreaterThan(BindIndex other) {
                return this.row > other.row ||
                    (this.row == other.row && this.col > other.col);
            }

            public override string ToString() {
                return "ix[" + row + "," + col + "]";
            }
        }

        public BindIndex GetBindIndex() {
            return new BindIndex(Rescues.Count);
        }

        public IList<HandlerInfo> FindActiveHandlersFor(IokeObject condition, BindIndex stopIndex) {
            var result = new SaneList<HandlerInfo>();

            foreach(IList<HandlerInfo> lrp in Handlers) {
                foreach(HandlerInfo rp in lrp) {
                    if(rp.index.LessThan(stopIndex)) {
                        return result;
                    }

                    foreach(object possibleKind in rp.applicableConditions) {
                        if(IokeObject.IsMimic(condition, IokeObject.As(possibleKind, condition))) {
                            result.Add(rp);
                        }
                    }
                }
            }

            return result;
        }

        public RescueInfo FindActiveRescueFor(IokeObject condition) {
            foreach(IList<RescueInfo> lrp in Rescues) {
                foreach(RescueInfo rp in lrp) {
                    foreach(object possibleKind in rp.applicableConditions) {
                        if(IokeObject.IsMimic(condition, IokeObject.As(possibleKind, condition))) {
                            return rp;
                        }
                    }
                }
            }

            return null;
        }

        public IList<IList<RestartInfo>> ActiveRestarts {
            get { return Restarts; }
        }

        public RestartInfo FindActiveRestart(string name) {
            foreach(IList<RestartInfo> lrp in Restarts) {
                foreach(RestartInfo rp in lrp) {
                    if(name.Equals(rp.name)) {
                        return rp;
                    }
                }
            }

            return null;
        }

        public RestartInfo FindActiveRestart(IokeObject restart) {
            foreach(IList<RestartInfo> lrp in Restarts) {
                foreach(RestartInfo rp in lrp) {
                    if(rp.restart == restart) {
                        return rp;
                    }
                }
            }

            return null;
        }

        public void ErrorCondition(IokeObject cond) {
            ((Message)IokeObject.dataOf(errorMessage)).SendTo(errorMessage, this.Ground, this.Ground, CreateMessage(Ioke.Lang.Message.Wrap(cond)));
        }

        public static void InitRuntime(IokeObject obj) {
            obj.Kind = "Runtime";

            obj.RegisterMethod(obj.runtime.NewNativeMethod("returns the node id for the runtime it's called on",
                                                           new TypeCheckingNativeMethod.WithNoArguments("nodeId", obj,
                                                                                                        (method, on, args, keywords, context, message) => {
                                                                                                            Runtime r = (Runtime)IokeObject.dataOf(on);
                                                                                                            return method.runtime.NewNumber(r.id);
                                                                                                        })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("creates a new runtime and returns that. be careful using this since it will result in some fairly strange behavior if used incorrectly. it will not copy the state of this runtime, but just create a new one from scratch.",
                                                           new TypeCheckingNativeMethod.WithNoArguments("create", obj,
                                                                                                        (method, on, args, keywords, context, message) => {
                                                                                                            Runtime r = new Runtime(method.runtime.operatorShufflerFactory, method.runtime.Out, method.runtime.In, method.runtime.Error);
                                                                                                            r.Init();
                                                                                                            IokeObject o = method.runtime._Runtime.AllocateCopy(null, null);
                                                                                                            o.MimicsWithoutCheck(method.runtime._Runtime);
                                                                                                            o.Data = r;
                                                                                                            return o;
                                                                                                        })));
        }
    }
}
