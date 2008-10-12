/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.io.PrintWriter;
import java.io.Reader;
import java.io.InputStreamReader;
import java.io.FileReader;

import java.util.List;

import ioke.lang.parser.iokeLexer;
import ioke.lang.parser.iokeParser;

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
    Base base = new Base(this, "Base is the top of the inheritance structure. Most of the objects in the system is derived from this instance. Base should keep it's cells to the bare minimum needed for the system");
    Ground ground = new Ground(this, "Ground is the default place code is evaluated in. This is where you can find most of the global objects defined.");
    IokeSystem system = new IokeSystem(this, "System defines things that represents the currently running system, such as load path.");
    Proxy runtime = new Proxy(this, "Runtime gives meta-circular access to the currently executing Ioke runtime.");
    DefaultBehavior defaultBehavior = new DefaultBehavior(this, "DefaultBehavior is a mixin that provides most of the methods shared by most instances in the system.");
    Origin origin = new Origin(this, "Any object created from scratch should usually be derived from Origin.");
    Nil nil = new Nil(this, "nil is an oddball object that always represents itself. It can not be mimicked and is one of the two false values.");
    True _true = new True(this, "true is an oddball object that always represents itself. It can not be mimicked and represents the a true value.");
    False _false = new False(this, "false is an oddball object that always represents itself. It can not be mimicked and is one of the two false values.");
    Text text = new Text(this, "", "Contains an immutable text.");
    Number number = new Number(this, "0", "Represents an exact number");
    Method method = new Method(this, null, "Method is the origin of all methods in the system, both default and Java..");
    DefaultMethod defaultMethod = new DefaultMethod(this, null, "DefaultMethod is the instance all methods in the system is derived from.");
    JavaMethod javaMethod = new JavaMethod(this, null, "JavaMethod is a derivation of Method that represents a primitive implemented in Java.");
    Mixins mixins = new Mixins(this, "Mixins is the name space for most mixins in the system. DefaultBehavior is the notable exception.");

    // Core messages
    public Message asText = new Message(this, "asText");
    public Message mimic = new Message(this, "mimic");
    public Message spaceShip = new Message(this, "<=>");

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

    public PrintWriter getOut() {
        return out;
    }

    public void init() {
        base.init();
        defaultBehavior.init();
        mixins.init();
        system.init();
        runtime.init();
        ground.init();
        origin.init();
        nil.init();
        _true.init();
        _false.init();
        text.init();
        number.init();

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

        method.init();
        defaultMethod.init();
        javaMethod.init();

        method.mimics(origin);
        javaMethod.mimics(method);
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

    public Base getBase() {
        return this.base;
    }

    public DefaultBehavior getDefaultBehavior() {
        return this.defaultBehavior;
    }

    public Nil getNil() {
        return this.nil;
    }

    public Message parseStream(Reader reader) {
        try {
            iokeParser parser = new iokeParser(new CommonTokenStream(new iokeLexer(new ANTLRReaderStream(reader))));
            Message m = Message.fromTree(this, (Tree)(parser.messageChain().getTree()));
//             System.err.println(m);
            return m;
        } catch(RuntimeException e) {
            throw e;
        } catch(Exception e) {
            throw new RuntimeException(e);
        }
    }

    public IokeObject evaluateStream(Reader reader) {
        return parseStream(reader).evaluateComplete();
    }

    public IokeObject evaluateFile(String filename) {
        try {
            return evaluateStream(new FileReader(filename));
        } catch(RuntimeException e) {
            throw e;
        } catch(Exception e) {
            throw new RuntimeException(e);
        }
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
