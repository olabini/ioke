/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import ioke.lang.exceptions.ControlFlow;

/**
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Regexp extends IokeData {
    private String pattern;

    public Regexp(String pattern) {
        this.pattern = pattern;
    }

    public static String getPattern(Object on) throws ControlFlow {
        return ((Regexp)IokeObject.data(on)).pattern;
    }

    @Override
    public void init(IokeObject obj) {
        final Runtime runtime = obj.runtime;
        obj.setKind("Regexp");

        obj.registerMethod(runtime.newJavaMethod("Returns the pattern use for this regular expression", new JavaMethod("pattern") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    return context.runtime.newText(getPattern(on));
                }
            }));
    }
}// Regexp
