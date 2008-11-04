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

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

import ioke.lang.parser.iokeLexer;
import ioke.lang.parser.iokeParser;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Runtime {
    private PrintWriter out;
    private PrintWriter err;
    private Reader in;

    // Core objects and origins
    public IokeObject base = new IokeObject(this, "Base is the top of the inheritance structure. Most of the objects in the system is derived from this instance. Base should keep it's cells to the bare minimum needed for the system");
    public IokeObject ground = new IokeObject(this, "Ground is the default place code is evaluated in. This is where you can find most of the global objects defined.");
    public IokeObject system = new IokeObject(this, "System defines things that represents the currently running system, such as load path.", new IokeSystem());
    public IokeObject runtime = new IokeObject(this, "Runtime gives meta-circular access to the currently executing Ioke runtime.");
    public IokeObject defaultBehavior = new IokeObject(this, "DefaultBehavior is a mixin that provides most of the methods shared by most instances in the system.");
    public IokeObject origin = new IokeObject(this, "Any object created from scratch should usually be derived from Origin.");
    public IokeObject nil = new IokeObject(this, "nil is an oddball object that always represents itself. It can not be mimicked and is one of the two false values.", IokeData.Nil);
    public IokeObject _true = new IokeObject(this, "true is an oddball object that always represents itself. It can not be mimicked and represents the a true value.", IokeData.True);
    public IokeObject _false = new IokeObject(this, "false is an oddball object that always represents itself. It can not be mimicked and is one of the two false values.", IokeData.False);
    public IokeObject text = new IokeObject(this, "Contains an immutable text.", new Text(""));
    public IokeObject symbol = new IokeObject(this, "Represents a symbol - an object that always represents itself.", new Symbol(""));
    public IokeObject number = new IokeObject(this, "Represents an exact number", new Number("0"));
    public IokeObject method = new IokeObject(this, "Method is the origin of all methods in the system, both default and Java..", new Method((String)null));
    public IokeObject defaultMethod = new IokeObject(this, "DefaultMethod is the instance all methods in the system is derived from.", new DefaultMethod((String)null));
    public IokeObject javaMethod = new IokeObject(this, "JavaMethod is a derivation of Method that represents a primitive implemented in Java.", new JavaMethod((String)null));
    public IokeObject lexicalBlock = new IokeObject(this, "A lexical block allows you to delay a computation in a specific lexical context. See DefaultMethod#fn for detailed documentation.", new LexicalBlock(ground));
    public IokeObject defaultMacro = new IokeObject(this, "DefaultMacro is the instance all macros in the system is derived from.", new DefaultMacro((String)null));
    public IokeObject mixins = new IokeObject(this, "Mixins is the name space for most mixins in the system. DefaultBehavior is the notable exception.");
    public IokeObject message = new IokeObject(this, "A message is the basic code unit in Ioke.", new Message(this, null, Message.Type.EMPTY));
    public IokeObject restart = new IokeObject(this, "A Restart is the actual object that contains restart information");
    public IokeObject list = new IokeObject(this, "A list is a collection of objects that can change size", new IokeList());
    public IokeObject dict = new IokeObject(this, "A dictionary is a collection of mappings from one object to another object. The default Dict implementation will use hashing for this.", new Dict());
    public IokeObject call = new IokeObject(this, "A call is the runtime structure that includes the specific information for a call, that is available inside a DefaultMacro.", new Call());
    public Context context = new Context(this, ground, "An activation context.", null, ground);
    public MacroContext macroContext = new MacroContext(this, ground, "A macro activation context.", null, ground);
    public LexicalContext lexicalContext = new LexicalContext(this, ground, "A lexical activation context.", null, ground);

    // Core messages
    public IokeObject asText = newMessage("asText");
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
        context.init();
        lexicalContext.init();
        macroContext.init();
        list.init();
        dict.init();
        call.init();

        ground.mimicsWithoutCheck(base);
        ground.mimicsWithoutCheck(defaultBehavior);
        origin.mimicsWithoutCheck(ground);

        system.mimicsWithoutCheck(base);
        system.mimicsWithoutCheck(defaultBehavior);
        runtime.mimicsWithoutCheck(defaultBehavior);

        nil.mimicsWithoutCheck(origin);
        _true.mimicsWithoutCheck(origin);
        _false.mimicsWithoutCheck(origin);
        text.mimicsWithoutCheck(origin);
        symbol.mimicsWithoutCheck(origin);
        number.mimicsWithoutCheck(origin);

        message.mimicsWithoutCheck(origin);
        method.mimicsWithoutCheck(origin);

        list.mimicsWithoutCheck(origin);
        dict.mimicsWithoutCheck(origin);
        
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
        
        try {
            evaluateString("use(\"builtin/A1_defaultBehavior\")");
            evaluateString("use(\"builtin/A2_number\")");
            evaluateString("use(\"builtin/A3_booleans\")");

            evaluateString("use(\"builtin/M1_comparing\")");
            evaluateString("use(\"builtin/M2_enumerable\")");

            evaluateString("use(\"builtin/restarts\")");
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

    public IokeObject getMacroContext() {
        return this.macroContext;
    }

    public IokeObject getNil() {
        return this.nil;
    }

    public IokeObject getCall() {
        return this.call;
    }

    private Map<String, Builtin> builtins = new HashMap<String, Builtin>();
    
    public void addBuiltinScript(String name, Builtin builtin) {
        builtins.put(name, builtin);
    }

    public Builtin getBuiltin(String name) {
        return builtins.get(name);
    }

    public IokeObject parseStream(Reader reader) throws ControlFlow {
        return Message.newFromStream(this, reader);
    }

    public Object evaluateStream(Reader reader) throws ControlFlow {
        return parseStream(reader).evaluateComplete();
    }

    public Object evaluateString(String str) throws ControlFlow {
        return parseStream(new StringReader(str)).evaluateComplete();
    }

    public Object evaluateStream(String name, Reader reader) throws ControlFlow {
        try {
            ((IokeSystem)system.data).pushCurrentFile(name);
            return evaluateStream(reader);
        } catch(RuntimeException e) {
            throw e;
        } catch(Exception e) {
            throw new RuntimeException(e);
        } finally {
            ((IokeSystem)system.data).popCurrentFile();
        }
    }

    public Object evaluateFile(File f) throws ControlFlow {
        try {
            ((IokeSystem)system.data).pushCurrentFile(f.getCanonicalPath());
            return evaluateStream(new FileReader(f));
        } catch(RuntimeException e) {
            throw e;
        } catch(Exception e) {
            throw new RuntimeException(e);
        } finally {
            ((IokeSystem)system.data).popCurrentFile();
        }
    }

    public Object evaluateFile(String filename) throws ControlFlow {
        try {
            ((IokeSystem)system.data).pushCurrentFile(filename);
            return evaluateStream(new FileReader(new File(((IokeSystem)system.data).getCurrentWorkingDirectory(), filename)));
        } catch(RuntimeException e) {
            throw e;
        } catch(Exception e) {
            throw new RuntimeException(e);
        } finally {
            ((IokeSystem)system.data).popCurrentFile();
        }
    }

    public IokeObject newFromOrigin() {
        return this.origin.mimic(null, null);
    }

    public IokeObject newText(String text) {
        IokeObject obj = this.text.allocateCopy(null, null);
        obj.mimicsWithoutCheck(this.text);
        obj.data = new Text(text);
        return obj;
    }

    public IokeObject newNumber(String number) {
        if(number.indexOf('.') != -1) {
            throw new RuntimeException("Can't handle decimal numbers yet. Sorry.");
        }

        IokeObject obj = this.number.allocateCopy(null, null);
        obj.mimicsWithoutCheck(this.number);
        obj.data = new Number(number);
        return obj;
    }

    public IokeObject newNumber(gnu.math.IntNum number) {
        IokeObject obj = this.number.allocateCopy(null, null);
        obj.mimicsWithoutCheck(this.number);
        obj.data = new Number(number);
        return obj;
    }

    public IokeObject newNumber(int number) {
        IokeObject obj = this.number.allocateCopy(null, null);
        obj.mimicsWithoutCheck(this.number);
        obj.data = new Number(number);
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

    public IokeObject newMessageFrom(IokeObject m, String name, List<Object> args) {
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

    public IokeObject newList(List<Object> list) {
        IokeObject obj = this.list.allocateCopy(null, null);
        obj.mimicsWithoutCheck(this.list);
        obj.data = new IokeList(list);
        return obj;
    }

    public IokeObject newCallFrom(MacroContext ctx, IokeObject message, IokeObject surroundingContext, IokeObject on) {
        IokeObject obj = this.call.allocateCopy(null, null);
        obj.mimicsWithoutCheck(this.call);
        obj.data = new Call(ctx, message, surroundingContext, on);
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

    public static class RestartInfo {
        public final String name;
        public final IokeObject restart;
        public final Object token;
        public RestartInfo(String name, IokeObject restart, Object token) {
            this.name = name;
            this.restart = restart;
            this.token = token;
        }
    }

    private ThreadLocal<List<List<RestartInfo>>> restarts = new ThreadLocal<List<List<RestartInfo>>>() {
             @Override
             protected List<List<RestartInfo>> initialValue() {
                 return new ArrayList<List<RestartInfo>>();
             }};

    public void registerRestarts(List<RestartInfo> restarts) {
        this.restarts.get().add(0, restarts);
    }

    public void unregisterRestarts(List<RestartInfo> restarts) {
        this.restarts.get().remove(restarts);
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

    public static void init(IokeObject runtime) {
        runtime.setKind("Runtime");
    }
}// Runtime
