/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.io.PrintWriter;
import java.io.Reader;
import java.io.InputStreamReader;
import java.io.FileReader;
import java.io.File;

import java.util.List;
import java.util.Map;
import java.util.HashMap;

import ioke.lang.parser.iokeLexer;
import ioke.lang.parser.iokeParser;

import ioke.lang.exceptions.ControlFlow;

import org.antlr.runtime.ANTLRReaderStream;
import org.antlr.runtime.CommonTokenStream;
import org.antlr.runtime.Token;
import org.antlr.runtime.tree.Tree;

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
    public Ground ground = new Ground(this, "Ground is the default place code is evaluated in. This is where you can find most of the global objects defined.");
    IokeSystem system = new IokeSystem(this, "System defines things that represents the currently running system, such as load path.");
    Proxy runtime = new Proxy(this, "Runtime gives meta-circular access to the currently executing Ioke runtime.");
    DefaultBehavior defaultBehavior = new DefaultBehavior(this, "DefaultBehavior is a mixin that provides most of the methods shared by most instances in the system.");
    Origin origin = new Origin(this, "Any object created from scratch should usually be derived from Origin.");
    public IokeObject nil = new IokeObject(this, "nil is an oddball object that always represents itself. It can not be mimicked and is one of the two false values.", IokeData.Nil);
    public IokeObject _true = new IokeObject(this, "true is an oddball object that always represents itself. It can not be mimicked and represents the a true value.", IokeData.True);
    public IokeObject _false = new IokeObject(this, "false is an oddball object that always represents itself. It can not be mimicked and is one of the two false values.", IokeData.False);
    Text text = new Text(this, "", "Contains an immutable text.");
    Number number = new Number(this, "0", "Represents an exact number");
    Method method = new Method(this, null, "Method is the origin of all methods in the system, both default and Java..");
    DefaultMethod defaultMethod = new DefaultMethod(this, null, "DefaultMethod is the instance all methods in the system is derived from.");
    JavaMethod javaMethod = new JavaMethod(this, null, "JavaMethod is a derivation of Method that represents a primitive implemented in Java.");
    Mixins mixins = new Mixins(this, "Mixins is the name space for most mixins in the system. DefaultBehavior is the notable exception.");
    Message message = new Message(this, null, Message.Type.EMPTY, "A message is the basic code unit in Ioke.");
    Context context = new Context(this, ground, "An activation context.", null, ground);

    // Core messages
    public Message asText = new Message(this, "asText");
    public Message mimic = new Message(this, "mimic");
    public Message spaceShip = new Message(this, "<=>");
    public Message succ = new Message(this, "succ");
    public Message setValue = new Message(this, "=");

    // NOT TO BE EXPOSED TO Ioke - used for internal usage only
    NullObject nul = new NullObject(this);

    public Runtime() {
        this(new PrintWriter(java.lang.System.out), new InputStreamReader(java.lang.System.in), new PrintWriter(java.lang.System.err));
    }

    public Runtime(PrintWriter out, Reader in, PrintWriter err) {
        this.out = out;
        this.in = in;
        this.err = err;
    }

    public static Runtime getRuntime() {
        return getRuntime(new PrintWriter(java.lang.System.out), new InputStreamReader(java.lang.System.in), new PrintWriter(java.lang.System.err));
    }

    public static Runtime getRuntime(PrintWriter out, Reader in, PrintWriter err) {
        Runtime r = new Runtime(out, in, err);
        r.init();
        return r;
    }

    public void setCurrentWorkingDirectory(String cwd) {
        system.setCurrentWorkingDirectory(cwd);
    }

    public String getCurrentWorkingDirectory() {
        return system.getCurrentWorkingDirectory();
    }

    public PrintWriter getOut() {
        return out;
    }

    public void init() {
        Base.init(base);
        defaultBehavior.init();
        mixins.init();
        system.init();
        runtime.init();
        message.init();
        ground.init();
        origin.init();
        nil.init();
        _true.init();
        _false.init();
        text.init();
        number.init();
        context.init();

        ground.mimics(base);
        ground.mimics(defaultBehavior);
        origin.mimics(ground);

        system.mimics(defaultBehavior);
        runtime.mimics(defaultBehavior);

        nil.mimics(origin);
        _true.mimics(origin);
        _false.mimics(origin);
        text.mimics(origin);
        number.mimics(origin);

        message.mimics(origin);
        method.mimics(origin);
        
        method.init();
        defaultMethod.init();
        javaMethod.init();

        method.mimics(origin);
        defaultMethod.mimics(method);
        javaMethod.mimics(method);


        addBuiltinScript("benchmark", new Builtin() {
                public IokeObject load(Runtime runtime, IokeObject context, Message message) throws ControlFlow {
                    return ioke.lang.extensions.benchmark.Benchmark.create(runtime);
                }
            });
    }

    public NullObject getNul() {
        return nul;
    }

    public Ground getGround() {
        return this.ground;
    }

    public Origin getOrigin() {
        return this.origin;
    }

    public Text getText() {
        return this.text;
    }

    public Number getNumber() {
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

    public DefaultBehavior getDefaultBehavior() {
        return this.defaultBehavior;
    }

    public IokeObject getNil() {
        return this.nil;
    }

    private Map<String, Builtin> builtins = new HashMap<String, Builtin>();
    
    public void addBuiltinScript(String name, Builtin builtin) {
        builtins.put(name, builtin);
    }

    public Builtin getBuiltin(String name) {
        return builtins.get(name);
    }

    public Message parseStream(Reader reader) {
        try {
            iokeParser parser = new iokeParser(new CommonTokenStream(new iokeLexer(new ANTLRReaderStream(reader))));
            Tree t = parser.parseFully();
//             System.err.println("t: " + t.toStringTree());
            Message m = Message.fromTree(this, t);
//             System.err.println("m: " + m);
            return m;
        } catch(RuntimeException e) {
            throw e;
        } catch(Exception e) {
            throw new RuntimeException(e);
        }
    }

    public IokeObject evaluateStream(Reader reader) throws ControlFlow {
        return parseStream(reader).evaluateComplete();
    }

    public IokeObject evaluateStream(String name, Reader reader) throws ControlFlow {
        try {
            system.pushCurrentFile(name);
            return evaluateStream(reader);
        } catch(RuntimeException e) {
            throw e;
        } catch(Exception e) {
            throw new RuntimeException(e);
        } finally {
            system.popCurrentFile();
        }
    }

    public IokeObject evaluateFile(File f) throws ControlFlow {
        try {
            system.pushCurrentFile(f.getCanonicalPath());
            return evaluateStream(new FileReader(f));
        } catch(RuntimeException e) {
            throw e;
        } catch(Exception e) {
            throw new RuntimeException(e);
        } finally {
            system.popCurrentFile();
        }
    }

    public IokeObject evaluateFile(String filename) throws ControlFlow {
        try {
            system.pushCurrentFile(filename);
            return evaluateStream(new FileReader(new File(system.getCurrentWorkingDirectory(), filename)));
        } catch(RuntimeException e) {
            throw e;
        } catch(Exception e) {
            throw new RuntimeException(e);
        } finally {
            system.popCurrentFile();
        }
    }

    public IokeObject newText(String text) {
        return new Text(this, text);
    }

    public static class Proxy extends IokeObject {
        Proxy(Runtime runtime, String documentation) {
            super(runtime, documentation);
        }

        public void init() {
        }

        public String toString() {
            return "Runtime";
        }
    }
}// Runtime
