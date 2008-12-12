/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.io.PrintWriter;
import java.io.Reader;
import java.io.InputStreamReader;
import java.io.FileReader;
import java.io.File;
import java.io.StringReader;

import java.math.BigDecimal;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Collection;

import ioke.lang.parser.iokeLexer;
import ioke.lang.parser.iokeParser;

import ioke.lang.exceptions.ControlFlow;

import gnu.math.RatNum;
import gnu.math.IntNum;
import gnu.math.IntFraction;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Runtime {
    public boolean debug = false;

    PrintWriter out;
    PrintWriter err;
    Reader in;

    // Core objects and origins
    public IokeObject base = new IokeObject(this, "Base is the top of the inheritance structure. Most of the objects in the system are derived from this instance. Base should keep its cells to the bare minimum needed for the system.");
    public IokeObject ground = new IokeObject(this, "Ground is the default place code is evaluated in. This is where you can find most of the global objects defined.");
    public IokeObject system = new IokeObject(this, "System defines things that represents the currently running system, such as the load path.", new IokeSystem());
    public IokeObject runtime = new IokeObject(this, "Runtime gives meta-circular access to the currently executing Ioke runtime.");
    public IokeObject defaultBehavior = new IokeObject(this, "DefaultBehavior is a mixin that provides most of the methods shared by most instances in the system.");
    public IokeObject origin = new IokeObject(this, "Any object created from scratch should usually be derived from Origin.");
    public IokeObject nil = new IokeObject(this, "nil is an oddball object that always represents itself. It can not be mimicked and (alongside false) is one of the two false values.", IokeData.Nil);
    public IokeObject _true = new IokeObject(this, "true is an oddball object that always represents itself. It can not be mimicked and represents the a true value.", IokeData.True);
    public IokeObject _false = new IokeObject(this, "false is an oddball object that always represents itself. It can not be mimicked and (alongside nil) is one of the two false values.", IokeData.False);
    public IokeObject text = new IokeObject(this, "Contains an immutable piece of text.", new Text(""));
    public IokeObject symbol = new IokeObject(this, "Represents a symbol - an object that always represents itself.", new Symbol(""));
    public IokeObject number = new IokeObject(this, "Represents an exact number", new Number("0"));
    public IokeObject method = new IokeObject(this, "Method is the origin of all methods in the system, both default and Java..", new Method((String)null));
    public IokeObject defaultMethod = new IokeObject(this, "DefaultMethod is the instance all methods in the system are derived from.", new DefaultMethod((String)null));
    public IokeObject javaMethod = new IokeObject(this, "JavaMethod is a derivation of Method that represents a primitive implemented in Java.", new JavaMethod((String)null));
    public IokeObject lexicalBlock = new IokeObject(this, "A lexical block allows you to delay a computation in a specific lexical context. See DefaultMethod#fn for detailed documentation.", new LexicalBlock(ground));
    public IokeObject defaultMacro = new IokeObject(this, "DefaultMacro is the instance all macros in the system are derived from.", new DefaultMacro((String)null));
    public IokeObject mixins = new IokeObject(this, "Mixins is the name space for most mixins in the system. DefaultBehavior is the notable exception.");
    public IokeObject message = new IokeObject(this, "A Message is the basic code unit in Ioke.", new Message(this, "", Message.Type.EMPTY));
    public IokeObject restart = new IokeObject(this, "A Restart is the actual object that contains restart information.");
    public IokeObject list = new IokeObject(this, "A list is a collection of objects that can change size", new IokeList());
    public IokeObject dict = new IokeObject(this, "A dictionary is a collection of mappings from one object to another object. The default Dict implementation will use hashing for this.", new Dict());
    public IokeObject set = new IokeObject(this, "A set is an unordered collection of objects that contains no duplicates.", new IokeSet());
    public IokeObject range = new IokeObject(this, "A range is a collection of two objects of the same kind. This Range can be either inclusive or exclusive.", new Range(nil, nil, false));
    public IokeObject pair = new IokeObject(this, "A pair is a collection of two objects of any kind. They are used among other things to represent Dict entries.", new Pair(nil, nil));
    public IokeObject call = new IokeObject(this, "A call is the runtime structure that includes the specific information for a call, that is available inside a DefaultMacro.", new Call());
    public LexicalContext lexicalContext = new LexicalContext(this, ground, "A lexical activation context.", null, ground);
    public IokeObject dateTime = new IokeObject(this, "A DateTime represents the current date and time in a particular time zone.", new DateTime(0));

    public IokeObject locals = new IokeObject(this, "Contains all the locals for a specific invocation.");

    public IokeObject condition = new IokeObject(this, "The root mimic of all the conditions in the system.");
    public IokeObject rescue = new IokeObject(this, "A Rescue contains handling information from rescuing a Condition.");
    public IokeObject handler = new IokeObject(this, "A Handler contains handling information for handling a condition without unwinding the stack.");
    public IokeObject io = new IokeObject(this, "IO is the base for all input/output in Ioke.", new IokeIO());
    public IokeObject fileSystem = new IokeObject(this, "Gives access to things related to the file system.");

    public IokeObject regexp = new IokeObject(this, "A regular expression allows you to matching text against a pattern.", new Regexp(""));

    public IokeObject integer = null;
    public IokeObject decimal = null;
    public IokeObject ratio = null;

    // Core messages
    public IokeObject asText = newMessage("asText");
    public IokeObject asRational = newMessage("asRational");
    public IokeObject asDecimal = newMessage("asDecimal");
    public IokeObject mimic = newMessage("mimic");
    public IokeObject spaceShip = newMessage("<=>");
    public IokeObject succ = newMessage("succ");
    public IokeObject pred = newMessage("pred");
    public IokeObject setValue = newMessage("=");
    public IokeObject nilMessage = newMessage("nil");
    public IokeObject name = newMessage("name");
    public IokeObject callMessage = newMessage("call");
    public IokeObject code = newMessage("code");
    public IokeObject each = newMessage("each");
    public IokeObject opShuffle = newMessage("shuffleOperators");
    public IokeObject textMessage = newMessage("text");
    public IokeObject conditionsMessage = newMessage("conditions");
    public IokeObject handlerMessage = newMessage("handler");
    public IokeObject reportMessage = newMessage("report");
    public IokeObject printMessage = newMessage("print");
    public IokeObject printlnMessage = newMessage("println");
    public IokeObject outMessage = newMessage("out");
    public IokeObject currentDebuggerMessage = newMessage("currentDebugger");
    public IokeObject invokeMessage = newMessage("invoke");
    public IokeObject errorMessage = newMessage("error!");
    public IokeObject ErrorMessage = newMessage("Error");
    public IokeObject inspectMessage = newMessage("inspect");
    public IokeObject noticeMessage = newMessage("notice");

    public IokeObject plusMessage = newMessage("+");
    public IokeObject minusMessage = newMessage("-");
    public IokeObject multMessage = newMessage("*");
    public IokeObject divMessage = newMessage("/");
    public IokeObject modMessage = newMessage("%");
    public IokeObject expMessage = newMessage("**");
    public IokeObject binAndMessage = newMessage("&");
    public IokeObject binOrMessage = newMessage("|");
    public IokeObject binXorMessage = newMessage("^");
    public IokeObject lshMessage = newMessage("<<");
    public IokeObject rshMessage = newMessage(">>");
    public IokeObject ltMessage = newMessage("<"); 
    public IokeObject lteMessage = newMessage("<=");
    public IokeObject gtMessage = newMessage(">");
    public IokeObject gteMessage = newMessage(">=");
    public IokeObject eqMessage = newMessage("==");

    // NOT TO BE EXPOSED TO Ioke - used for internal usage only
    public final NullObject nul = new NullObject(this);

    public Runtime() {
        this(new PrintWriter(java.lang.System.out), new InputStreamReader(java.lang.System.in), new PrintWriter(java.lang.System.err));
    }

    public Runtime(PrintWriter out, Reader in, PrintWriter err) {
        this.out = out;
        this.in = in;
        this.err = err;
    }

    public static Runtime getRuntime() throws ControlFlow {
        return getRuntime(new PrintWriter(java.lang.System.out), new InputStreamReader(java.lang.System.in), new PrintWriter(java.lang.System.err));
    }

    public static Runtime getRuntime(PrintWriter out, Reader in, PrintWriter err) throws ControlFlow {
        Runtime r = new Runtime(out, in, err);
        r.init();
        return r;
    }

    public void setCurrentWorkingDirectory(String cwd) {
        ((IokeSystem)system.data).setCurrentWorkingDirectory(cwd);
    }

    public String getCurrentWorkingDirectory() {
        return ((IokeSystem)system.data).getCurrentWorkingDirectory();
    }

    public PrintWriter getOut() {
        return out;
    }

    public void addArgument(String arg) {
        ((IokeSystem)IokeObject.data(system)).addArgument(arg);
    }

    public void init() throws ControlFlow {
        Base.init(base);
        DefaultBehavior.init(defaultBehavior);
        Mixins.init(mixins);
        system.init();
        Runtime.init(runtime);
        message.init();
        Ground.init(ground);
        Origin.init(origin);
        nil.init();
        _true.init();
        _false.init();
        text.init();
        symbol.init();
        number.init(); 
        range.init();
        pair.init();
        dateTime.init();
        lexicalContext.init();
        list.init();
        dict.init();
        set.init();
        call.init();
        Locals.init(locals);
        Condition.init(condition);
        Rescue.init(rescue);
        Handler.init(handler);
        io.init();
        FileSystem.init(fileSystem);
        regexp.init();

        ground.mimicsWithoutCheck(defaultBehavior);
        ground.mimicsWithoutCheck(base);
        origin.mimicsWithoutCheck(ground);

        mixins.mimicsWithoutCheck(defaultBehavior);

        system.mimicsWithoutCheck(ground);
        system.mimicsWithoutCheck(defaultBehavior);
        runtime.mimicsWithoutCheck(ground);
        runtime.mimicsWithoutCheck(defaultBehavior);

        nil.mimicsWithoutCheck(origin);
        _true.mimicsWithoutCheck(origin);
        _false.mimicsWithoutCheck(origin);
        text.mimicsWithoutCheck(origin);
        symbol.mimicsWithoutCheck(origin);
        number.mimicsWithoutCheck(origin);
        range.mimicsWithoutCheck(origin);
        pair.mimicsWithoutCheck(origin);
        dateTime.mimicsWithoutCheck(origin);

        message.mimicsWithoutCheck(origin);
        method.mimicsWithoutCheck(origin);

        list.mimicsWithoutCheck(origin);
        dict.mimicsWithoutCheck(origin);
        set.mimicsWithoutCheck(origin);

        condition.mimicsWithoutCheck(origin);
        rescue.mimicsWithoutCheck(origin);
        handler.mimicsWithoutCheck(origin);

        io.mimicsWithoutCheck(origin);

        fileSystem.mimicsWithoutCheck(origin);

        regexp.mimicsWithoutCheck(origin);

        method.init();
        defaultMethod.init();
        javaMethod.init();
        lexicalBlock.init();
        defaultMacro.init();
        call.mimicsWithoutCheck(origin);

        method.mimicsWithoutCheck(origin);
        defaultMethod.mimicsWithoutCheck(method);
        javaMethod.mimicsWithoutCheck(method);
        defaultMacro.mimicsWithoutCheck(origin);

        lexicalBlock.mimicsWithoutCheck(origin);

        Restart.init(restart);
        restart.mimicsWithoutCheck(origin);

        addBuiltinScript("benchmark", new Builtin() {
                public IokeObject load(Runtime runtime, IokeObject context, IokeObject message) throws ControlFlow {
                    return ioke.lang.extensions.benchmark.Benchmark.create(runtime);
                }
            });

        addBuiltinScript("readline", new Builtin() {
                public IokeObject load(Runtime runtime, IokeObject context, IokeObject message) throws ControlFlow {
                    return ioke.lang.extensions.readline.Readline.create(runtime);
                }
            });
        
        try {
            evaluateString("use(\"builtin/A1_defaultBehavior\")", message, ground);
            evaluateString("use(\"builtin/A1_defaultBehavior_inspection\")", message, ground);
            evaluateString("use(\"builtin/A2_number\")", message, ground);
            evaluateString("use(\"builtin/A3_booleans\")", message, ground);
            evaluateString("use(\"builtin/A4_range\")", message, ground);
            evaluateString("use(\"builtin/A5_call\")", message, ground);
            evaluateString("use(\"builtin/A6_list\")", message, ground);
            evaluateString("use(\"builtin/A7_dict\")", message, ground);
            evaluateString("use(\"builtin/A8_pair\")", message, ground);
            evaluateString("use(\"builtin/A9_conditions\")", message, ground);
            evaluateString("use(\"builtin/A10_text\")", message, ground);

            evaluateString("use(\"builtin/M1_comparing\")", message, ground);
            evaluateString("use(\"builtin/M2_enumerable\")", message, ground);
        } catch(ControlFlow cf) {
        }
    }

    public NullObject getNul() {
        return nul;
    }

    public IokeObject getGround() {
        return this.ground;
    }

    public IokeObject getOrigin() {
        return this.origin;
    }

    public IokeObject getSystem() {
        return this.system;
    }

    public IokeObject getIokeRuntime() {
        return this.runtime;
    }

    public IokeObject getMixins() {
        return this.mixins;
    }

    public IokeObject getText() {
        return this.text;
    }

    public IokeObject getSymbol() {
        return this.symbol;
    }

    public IokeObject getNumber() {
        return this.number;
    }

    public IokeObject getBase() {
        return this.base;
    }

    public IokeObject getTrue() {
        return this._true;
    }

    public IokeObject getSet() {
        return this.set;
    }

    public IokeObject getFalse() {
        return this._false;
    }

    public IokeObject getMethod() {
        return this.method;
    }

    public IokeObject getJavaMethod() {
        return this.javaMethod;
    }

    public IokeObject getDefaultMethod() {
        return this.defaultMethod;
    }

    public IokeObject getDefaultMacro() {
        return this.defaultMacro;
    }

    public IokeObject getLexicalBlock() {
        return this.lexicalBlock;
    }

    public IokeObject getDefaultBehavior() {
        return this.defaultBehavior;
    }

    public IokeObject getRestart() {
        return this.restart;
    }
 
    public IokeObject getCondition() {
        return this.condition;
    }

    public IokeObject getRescue() {
        return this.rescue;
    }

    public IokeObject getHandler() {
        return this.handler;
    }

    public IokeObject getFileSystem() {
        return this.fileSystem;
    }

    public IokeObject getPair() {
        return this.pair;
    }

    public IokeObject getDateTime() {
        return this.dateTime;
    }

    public IokeObject getNil() {
        return this.nil;
    }

    public IokeObject getCall() {
        return this.call;
    }

    public IokeObject getIO() {
        return this.io;
    }

    private Map<String, Builtin> builtins = new HashMap<String, Builtin>();
    
    public void addBuiltinScript(String name, Builtin builtin) {
        builtins.put(name, builtin);
    }

    public Builtin getBuiltin(String name) {
        return builtins.get(name);
    }

    public IokeObject parseStream(Reader reader, IokeObject message, IokeObject context) throws ControlFlow {
        return Message.newFromStream(this, reader, message, context);
    }

    public Object evaluateStream(Reader reader, IokeObject message, IokeObject context) throws ControlFlow {
        return parseStream(reader, message, context).evaluateComplete();
    }

    public Object evaluateString(String str, IokeObject message, IokeObject context) throws ControlFlow {
        return parseStream(new StringReader(str), message, context).evaluateComplete();
    }

    // ONLY FOR USE FROM RSPEC
    public Object evaluateStream(Reader reader) throws ControlFlow {
        return evaluateStream(reader, this.message, this.ground);
    }

    // ONLY FOR USE FROM RSPEC
    public Object evaluateString(String str) throws ControlFlow {
        return evaluateString(str, this.message, this.ground);
    }

    public Object evaluateStream(String name, Reader reader, IokeObject message, IokeObject context) throws ControlFlow {
        try {
            ((IokeSystem)system.data).pushCurrentFile(name);
            return evaluateStream(reader, message, context);
        } catch(Exception e) {
            reportJavaException(e, message, context);
            return null;
        } finally {
            ((IokeSystem)system.data).popCurrentFile();
        }
    }

    public Object evaluateFile(File f, IokeObject message, IokeObject context) throws ControlFlow {
        try {
            ((IokeSystem)system.data).pushCurrentFile(f.getCanonicalPath());
            return evaluateStream(new FileReader(f), message, context);
        } catch(Exception e) {
            reportJavaException(e, message, context);
            return null;
        } finally {
            ((IokeSystem)system.data).popCurrentFile();
        }
    }

    public Object evaluateFile(String filename, IokeObject message, IokeObject context) throws ControlFlow {
        try {
            ((IokeSystem)system.data).pushCurrentFile(filename);
            if(filename.startsWith("/") || (filename.length() > 2 && filename.charAt(1) == '\\')) {
                return evaluateStream(new FileReader(new File(filename)), message, context);
            } else {
                return evaluateStream(new FileReader(new File(((IokeSystem)system.data).getCurrentWorkingDirectory(), filename)), message, context);
            }


        } catch(Exception e) {
            reportJavaException(e, message, context);
            return null;
        } finally {
            ((IokeSystem)system.data).popCurrentFile();
        }
    }

    public void reportJavaException(Exception e, IokeObject message, IokeObject context) throws ControlFlow {
        final IokeObject condition = IokeObject.as(IokeObject.getCellChain(this.condition, 
                                                                           message, 
                                                                           context, 
                                                                           "Error", 
                                                                           "JavaException")).mimic(message, context);
        condition.setCell("message", message);
        condition.setCell("context", context);
        condition.setCell("receiver", context);
        condition.setCell("exceptionType", newText(e.getClass().getName()));
        condition.setCell("exceptionMessage", newText(e.getMessage()));
        List<Object> ob = new ArrayList<Object>();
        for(StackTraceElement ste : e.getStackTrace()) {
            ob.add(newText(ste.toString()));
        }
        condition.setCell("exceptionStackTrace", newList(ob));
        this.errorCondition(condition);
    }

    public IokeObject newFromOrigin() throws ControlFlow {
        return this.origin.mimic(null, null);
    }

    public IokeObject newText(String text) {
        IokeObject obj = this.text.allocateCopy(null, null);
        obj.mimicsWithoutCheck(this.text);
        obj.data = new Text(text);
        return obj;
    }

    public IokeObject newRegexp(String pattern) {
        IokeObject obj = this.regexp.allocateCopy(null, null);
        obj.mimicsWithoutCheck(this.regexp);
        obj.data = new Regexp(pattern);
        return obj;
    }

    public IokeObject newDecimal(String number) throws ControlFlow {
        IokeObject obj = this.decimal.allocateCopy(null, null);
        obj.mimicsWithoutCheck(this.decimal);
        obj.data = Decimal.decimal(number);
        return obj;
    }

    public IokeObject newDecimal(Number number) throws ControlFlow {
        IokeObject obj = this.decimal.allocateCopy(null, null);
        obj.mimicsWithoutCheck(this.decimal);
        obj.data = Decimal.decimal(number.getValue());
        return obj;
    }

    public IokeObject newDecimal(BigDecimal number) throws ControlFlow {
        IokeObject obj = this.decimal.allocateCopy(null, null);
        obj.mimicsWithoutCheck(this.decimal);
        obj.data = Decimal.decimal(number);
        return obj;
    }

    public IokeObject newNumber(String number) throws ControlFlow {
        IokeObject obj = this.integer.allocateCopy(null, null);
        obj.mimicsWithoutCheck(this.integer);
        obj.data = Number.integer(number);
        return obj;
    }

    public IokeObject newNumber(IntNum number) {
        IokeObject obj = this.integer.allocateCopy(null, null);
        obj.mimicsWithoutCheck(this.integer);
        obj.data = Number.integer(number);
        return obj;
    }

    public IokeObject newNumber(RatNum number) {
        if(number instanceof IntNum) {
            IokeObject obj = this.integer.allocateCopy(null, null);
            obj.mimicsWithoutCheck(this.integer);
            obj.data = Number.integer((IntNum)number);
            return obj;
        } else {
            IokeObject obj = this.ratio.allocateCopy(null, null);
            obj.mimicsWithoutCheck(this.ratio);
            obj.data = Number.ratio((IntFraction)number);
            return obj;
        }
    }

    public IokeObject newNumber(long number) {
        IokeObject obj = this.integer.allocateCopy(null, null);
        obj.mimicsWithoutCheck(this.integer);
        obj.data = Number.integer(number);
        return obj;
    }

    public IokeObject newMethod(String doc, IokeObject tp, Method impl) {
        IokeObject obj = tp.allocateCopy(null, null);
        obj.documentation = doc;
        obj.mimicsWithoutCheck(tp);
        obj.data = impl;
        return obj;
    }

    public IokeObject newMacro(String doc, IokeObject tp, DefaultMacro impl) {
        IokeObject obj = tp.allocateCopy(null, null);
        obj.documentation = doc;
        obj.mimicsWithoutCheck(tp);
        obj.data = impl;
        return obj;
    }

    public IokeObject newJavaMethod(String doc, JavaMethod impl) {
        return newMethod(doc, this.javaMethod, impl);
    }

    public IokeObject newMessage(String name) {
        return createMessage(new Message(this, name));
    }

    public IokeObject createMessage(Message m) {
        IokeObject obj = this.message.allocateCopy(null, null);
        obj.mimicsWithoutCheck(this.message);
        obj.data = m;
        return obj;
    }

    public IokeObject newMessageFrom(IokeObject m, String name, List<Object> args) throws ControlFlow {
        Message mess = new Message(this, name);
        mess.setFile(m.getFile());
        mess.setLine(m.getLine());
        mess.setPosition(m.getPosition());
        mess.setArguments(args);
        return createMessage(mess);
    }

    public IokeObject newLexicalBlock(IokeObject tp, LexicalBlock impl) {
        IokeObject obj = tp.allocateCopy(null, null);
        obj.mimicsWithoutCheck(tp);
        obj.data = impl;
        return obj;
    }

    public IokeObject newDict(Map<Object, Object> map) {
        IokeObject obj = dict.allocateCopy(null, null);
        obj.mimicsWithoutCheck(dict);
        obj.data = new Dict(map);
        return obj;
    }

    public IokeObject newSet(Collection<Object> objs) {
        IokeObject obj = this.set.allocateCopy(null, null);
        obj.mimicsWithoutCheck(this.set);
        obj.data = new IokeSet(new HashSet<Object>(objs));
        return obj;
    }

    public void errorCondition(IokeObject cond) throws ControlFlow {
        errorMessage.sendTo(ground, ground, createMessage(Message.wrap(cond)));
    }

    public IokeObject newList(List<Object> list) {
        IokeObject obj = this.list.allocateCopy(null, null);
        obj.mimicsWithoutCheck(this.list);
        obj.data = new IokeList(list);
        return obj;
    }

    public IokeObject newList(List<Object> list, IokeObject orig) {
        IokeObject obj = orig.allocateCopy(null, null);
        obj.mimicsWithoutCheck(orig);
        obj.data = new IokeList(list);
        return obj;
    }

    public IokeObject newCallFrom(IokeObject ctx, IokeObject message, IokeObject surroundingContext, IokeObject on) {
        IokeObject obj = this.call.allocateCopy(null, null);
        obj.mimicsWithoutCheck(this.call);
        obj.data = new Call(ctx, message, surroundingContext, on);
        return obj;
    }

    public IokeObject newRange(IokeObject from, IokeObject to, boolean inclusive) {
        IokeObject obj = this.range.allocateCopy(null, null);
        obj.mimicsWithoutCheck(this.range);
        obj.data = new Range(from, to, inclusive);
        return obj;
    }

    public IokeObject newPair(Object first, Object second) {
        IokeObject obj = this.pair.allocateCopy(null, null);
        obj.mimicsWithoutCheck(this.pair);
        obj.data = new Pair(first, second);
        return obj;
    }

    public IokeObject newDateTime(org.joda.time.DateTime dt) {
        IokeObject obj = this.dateTime.allocateCopy(null, null);
        obj.mimicsWithoutCheck(this.dateTime);
        obj.data = new DateTime(dt);
        return obj;
    }

    private Map<String, IokeObject> symbolTable = new HashMap<String, IokeObject>();
    public IokeObject getSymbol(String name) {
        synchronized(symbolTable) {
            IokeObject obj = symbolTable.get(name);
            if(obj == null) {
                obj = new IokeObject(this, this.symbol.documentation, new Symbol(name));
                obj.mimicsWithoutCheck(this.symbol);
                symbolTable.put(name, obj);
            }
            return obj;
        }            
    }

    public Object withRestartReturningArguments(RunnableWithControlFlow code, IokeObject context, Restart.JavaRestart... restarts) throws ControlFlow {
        List<RestartInfo> rrs = new ArrayList<RestartInfo>();
        BindIndex index = getBindIndex();
        
        for(Restart.JavaRestart rjr : restarts) {
            IokeObject rr = IokeObject.as(mimic.sendTo(context, restart));
            IokeObject.setCell(rr, "name", getSymbol(rjr.getName()));

            rrs.add(0, new RestartInfo(rjr.getName(), rr, rrs, index, rjr));
            index = index.nextCol();
        }
        registerRestarts(rrs);

        try {
            code.run();
            return new ArrayList<Object>();
        } catch(ControlFlow.Restart e) {
            RestartInfo ri = null;
            if((ri = e.getRestart()).token == rrs) {
                Restart.JavaRestart currentRjr = (Restart.JavaRestart)ri.data;
                IokeObject result = currentRjr.invoke(context, e.getArguments());
                return result;
            } else {
                throw e;
            } 
        } finally {
            unregisterRestarts(rrs); 
        }
    }

    public void withReturningRestart(String name, IokeObject context, RunnableWithControlFlow code) throws ControlFlow {
        IokeObject rr = IokeObject.as(mimic.sendTo(context, restart));
        IokeObject.setCell(rr, "name", getSymbol(name));

        List<RestartInfo> rrs = new ArrayList<RestartInfo>();
        BindIndex index = getBindIndex();
        rrs.add(0, new RestartInfo(name, rr, rrs, index, null));
        index = index.nextCol();
        registerRestarts(rrs);

        try {
            code.run();
        } catch(ControlFlow.Restart e) {
            RestartInfo ri = null;
            if((ri = e.getRestart()).token == rrs) {
                return;
            } else {
                throw e;
            } 
        } finally {
            unregisterRestarts(rrs); 
        }
    }

    public static class RescueInfo {
        public final IokeObject rescue;
        public final List<Object> applicableConditions;
        public final Object token;
        public final BindIndex index;
        public RescueInfo(IokeObject rescue, List<Object> applicableConditions, Object token, BindIndex index) {
            this.rescue = rescue;
            this.applicableConditions = applicableConditions;
            this.token = token;
            this.index = index;
        }
    }

    public static class HandlerInfo {
        public final IokeObject handler;
        public final List<Object> applicableConditions;
        public final Object token;
        public final BindIndex index;
        public HandlerInfo(IokeObject handler, List<Object> applicableConditions, Object token, BindIndex index) {
            this.handler = handler;
            this.applicableConditions = applicableConditions;
            this.token = token;
            this.index = index;
        }
    }

    public static class RestartInfo {
        public final String name;
        public final IokeObject restart;
        public final Object token;
        public final BindIndex index;
        public final Object data;
        public RestartInfo(String name, IokeObject restart, Object token, BindIndex index, Object data) {
            this.name = name;
            this.restart = restart;
            this.token = token;
            this.index = index;
            this.data = data;
        }
    }

    private ThreadLocal<List<List<RestartInfo>>> restarts = new ThreadLocal<List<List<RestartInfo>>>() {
             @Override
             protected List<List<RestartInfo>> initialValue() {
                 return new ArrayList<List<RestartInfo>>();
             }};

    private ThreadLocal<List<List<RescueInfo>>> rescues = new ThreadLocal<List<List<RescueInfo>>>() {
             @Override
             protected List<List<RescueInfo>> initialValue() {
                 return new ArrayList<List<RescueInfo>>();
             }};

    private ThreadLocal<List<List<HandlerInfo>>> handlers = new ThreadLocal<List<List<HandlerInfo>>>() {
             @Override
             protected List<List<HandlerInfo>> initialValue() {
                 return new ArrayList<List<HandlerInfo>>();
             }};

    public void registerRestarts(List<RestartInfo> restarts) {
        this.restarts.get().add(0, restarts);
    }

    public void unregisterRestarts(List<RestartInfo> restarts) {
        this.restarts.get().remove(restarts);
    }

    public void registerRescues(List<RescueInfo> rescues) {
        this.rescues.get().add(0, rescues);
    }

    public void unregisterRescues(List<RescueInfo> rescues) {
        this.rescues.get().remove(rescues);
    }

    public void registerHandlers(List<HandlerInfo> handlers) {
        this.handlers.get().add(0, handlers);
    }

    public void unregisterHandlers(List<HandlerInfo> handlers) {
        this.handlers.get().remove(handlers);
    }

    public static class BindIndex {
        public final int row;
        public final int col;
        public BindIndex(int row) {
            this(row, 0);
        }
        public BindIndex(int row, int col) {
            this.row = row;
            this.col = col;
        }
        public BindIndex nextCol() {
            return new BindIndex(this.row, this.col+1);
        }
        public boolean lessThan(BindIndex other) {
            return this.row < other.row || 
                (this.row == other.row && this.col < other.col);
        }
        public boolean greaterThan(BindIndex other) {
            return this.row > other.row || 
                (this.row == other.row && this.col > other.col);
        }
    }

    public BindIndex getBindIndex() {
        return new BindIndex(rescues.get().size());
    }
    
    public List<HandlerInfo> findActiveHandlersFor(IokeObject condition, BindIndex stopIndex) {
        List<HandlerInfo> result = new ArrayList<HandlerInfo>();
        
        for(List<HandlerInfo> lrp : handlers.get()) {
            for(HandlerInfo rp : lrp) {
                if(rp.index.lessThan(stopIndex)) {
                    return result;
                }

                for(Object possibleKind : rp.applicableConditions) {
                    if(IokeObject.isMimic(condition, IokeObject.as(possibleKind))) {
                        result.add(rp);
                    }
                }
            }
        }

        return result;
    }

    public RescueInfo findActiveRescueFor(IokeObject condition) {
        for(List<RescueInfo> lrp : rescues.get()) {
            for(RescueInfo rp : lrp) {
                for(Object possibleKind : rp.applicableConditions) {
                    if(IokeObject.isMimic(condition, IokeObject.as(possibleKind))) {
                        return rp;
                    }
                }
            }
        }

        return null;
    }

    public RestartInfo findActiveRestart(String name) {
        for(List<RestartInfo> lrp : restarts.get()) {
            for(RestartInfo rp : lrp) {
                if(name.equals(rp.name)) {
                    return rp;
                }
            }
        }

        return null;
    }

    public RestartInfo findActiveRestart(IokeObject restart) {
        for(List<RestartInfo> lrp : restarts.get()) {
            for(RestartInfo rp : lrp) {
                if(rp.restart == restart) {
                    return rp;
                }
            }
        }

        return null;
    }

    public void tearDown() throws ControlFlow.Exit {
        int status = 0;
        List<IokeSystem.AtExitInfo> atExits = IokeSystem.getAtExits(system);
        while(!atExits.isEmpty()) {
            IokeSystem.AtExitInfo atExit = atExits.remove(0);
            try {
                atExit.message.evaluateCompleteWithoutExplicitReceiver(atExit.context, atExit.context.getRealContext());
            } catch(ControlFlow.Exit e) {
                status = 1;
            } catch(ControlFlow e) {
                String name = e.getClass().getName();
                System.err.println("unexpected control flow: " + name.substring(name.indexOf("$") + 1).toLowerCase());
                if(debug) {
                    e.printStackTrace(System.err);
                }
                status = 1;
            }
        }
        if(status != 0) {
            throw new ControlFlow.Exit();
        }
    }

    public static void init(IokeObject runtime) {
        runtime.setKind("Runtime");
    }
}// Runtime
