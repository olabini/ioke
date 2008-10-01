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
    Base base = new Base(this);
    Ground ground = new Ground(this);
    DefaultBehavior defaultBehavior = new DefaultBehavior(this);
    Origin origin = new Origin(this);
    Nil nil = new Nil(this);
    Text text = new Text(this, "");
    Method method = new Method(this);
    JavaMethod javaMethod = new JavaMethod(this);

    // Core messages
    public Message asString = new Message(this, "asString");
    public Message mimic = new Message(this, "mimic");


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
        ground.init();
        origin.init();
        nil.init();
        text.init();

        ground.mimics(base);
        ground.mimics(defaultBehavior);
        origin.mimics(ground);

        nil.mimics(origin);
        text.mimics(origin);

        method.init();
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

    public Base getBase() {
        return this.base;
    }

    public DefaultBehavior getDefaultBehavior() {
        return this.defaultBehavior;
    }

    public Nil getNil() {
        return this.nil;
    }

    public IokeObject evaluateStream(Reader reader) {
        try {
            iokeParser parser = new iokeParser(new CommonTokenStream(new iokeLexer(new ANTLRReaderStream(reader))));
            return Message.fromTree(this, (Tree)(parser.messageChain().getTree())).evaluateComplete();
        } catch(RuntimeException e) {
            throw e;
        } catch(Exception e) {
            throw new RuntimeException(e);
        }
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
}// Runtime
