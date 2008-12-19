/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.List;
import java.util.ArrayList;
import java.util.HashMap;

import org.jregex.Matcher;
import org.jregex.Pattern;

import ioke.lang.exceptions.ControlFlow;

/**
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Regexp extends IokeData {
    private String pattern;
    private Pattern regexp;

    private Regexp(String pattern, Pattern regexp) {
        this.pattern = pattern;
        this.regexp = regexp;
    }

    public static Regexp create(String pattern, IokeObject context, IokeObject message) throws ControlFlow {
        try {
            return new Regexp(pattern, new Pattern(pattern));
        } catch(Exception e) {
            return null;
        }
    }

    static Regexp create(String pattern) {
        try {
            return new Regexp(pattern, new Pattern(pattern));
        } catch(Exception e) {
            return null;
        }
    }

    public static String getPattern(Object on) throws ControlFlow {
        return ((Regexp)IokeObject.data(on)).pattern;
    }

    @Override
    public void init(IokeObject obj) {
        final Runtime runtime = obj.runtime;
        obj.setKind("Regexp");

        obj.registerMethod(runtime.newJavaMethod("Returns the pattern use for this regular expression", new JavaMethod.WithNoArguments("pattern") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().checkArgumentCount(context, message, on);
                    return context.runtime.newText(getPattern(on));
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("Takes one argument and tries to match that argument against the current pattern. Returns nil if no match can be done, or a Regexp Match object if a match succeeds", new JavaMethod("=~") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("other")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());

                    String arg = Text.getText(context.runtime.asText.sendTo(context, args.get(0)));
                    Matcher m = ((Regexp)IokeObject.data(on)).regexp.matcher(arg);
                    return m.find() ? context.runtime._true : context.runtime.nil;
                }
            }));
    }
}// Regexp
