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

    Origin origin = new Origin(this);
    System system = new System(this);
    Ground ground = new Ground(this);
    Nil nil = new Nil(this);
    Text text = new Text(this, "");

    public Message asString = new Message(this, "asString");

    public Runtime() {
        this(new PrintWriter(java.lang.System.out), new InputStreamReader(java.lang.System.in), new PrintWriter(java.lang.System.err));
    }

    public Runtime(PrintWriter out, Reader in, PrintWriter err) {
        this.out = out;
        this.in = in;
        this.err = err;
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
        origin.init();
        system.init();
        ground.init();
        nil.init();
        text.init();

        ground.mimics(origin);
        ground.mimics(system);
        nil.mimics(ground);
        text.mimics(ground);
    }

    public Ground getGround() {
        return this.ground;
    }

    public Nil getNil() {
        return this.nil;
    }

    public EvaluationResult evaluateFile(String filename) {
        try {
            iokeParser parser = new iokeParser(new CommonTokenStream(new iokeLexer(new ANTLRReaderStream(new FileReader(filename)))));

            Message message = Message.fromTree(this, (Tree)(parser.messageChain().getTree()));
            
            message.evaluateCompleteWith();

            return EvaluationResult.OK;
        } catch(Exception e) {
            throw new RuntimeException(e);
        }
    }
}// Runtime
