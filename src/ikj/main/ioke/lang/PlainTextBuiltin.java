/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.io.StringReader;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class PlainTextBuiltin extends Builtin {
    private String text;
    private String name;
    public PlainTextBuiltin(String name, String text) {
        this.text = text;
        this.name = name;
    }

    @Override
    public Object load(Runtime runtime, IokeObject context, IokeObject message) throws ControlFlow {
        return runtime.evaluateStream("<builtin:"+name+">", new StringReader(text), message, context);
    }
}// PlainTextBuiltin
