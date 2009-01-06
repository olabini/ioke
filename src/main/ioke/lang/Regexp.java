/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.List;
import java.util.ArrayList;
import java.util.HashMap;

import org.jregex.Matcher;
import org.jregex.Pattern;
import org.jregex.MatchIterator;

import ioke.lang.exceptions.ControlFlow;

/**
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Regexp extends IokeData {
    private String pattern;
    private Pattern regexp;
    private String flags;

    private Regexp(String pattern, Pattern regexp, String flags) {
        this.pattern = pattern;
        this.regexp = regexp;
        this.flags = flags;
    }

    public static Regexp create(String pattern, String flags, IokeObject context, IokeObject message) throws ControlFlow {
        try {
            return new Regexp(pattern, new Pattern(pattern), flags);
        } catch(Exception e) {
            return null;
        }
    }

    static Regexp create(String pattern, String flags) {
        try {
            return new Regexp(pattern, new Pattern(pattern), flags);
        } catch(Exception e) {
            return null;
        }
    }

    public static String getPattern(Object on) throws ControlFlow {
        return ((Regexp)IokeObject.data(on)).pattern;
    }

    public static Pattern getRegexp(Object on) throws ControlFlow {
        return ((Regexp)IokeObject.data(on)).regexp;
    }

    public static String getFlags(Object on) throws ControlFlow {
        return ((Regexp)IokeObject.data(on)).flags;
    }

    @Override
    public void init(IokeObject obj) throws ControlFlow {
        final Runtime runtime = obj.runtime;
        obj.setKind("Regexp");

        obj.registerMethod(runtime.newJavaMethod("Returns the pattern use for this regular expression", new JavaMethod.WithNoArguments("pattern") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());
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

        obj.registerMethod(runtime.newJavaMethod("Takes one argument that should be a text and returns a text that has all regexp meta characters quoted", new JavaMethod("quote") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("text")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());

                    return context.runtime.newText(Pattern.quote(Text.getText(context.runtime.asText.sendTo(context, args.get(0)))));
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("Takes one or two text arguments that describes the regular expression to create. the first text is the pattern and the second is the flags.", new JavaMethod("from") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("pattern")
                    .withOptionalPositional("flags", "")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());
                    String pattern = Text.getText(context.runtime.asText.sendTo(context, args.get(0)));
                    String flags = "";
                    if(args.size() > 1) {
                        flags = Text.getText(context.runtime.asText.sendTo(context, args.get(1)));
                    }

                    return context.runtime.newRegexp(pattern, flags, context, message);
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("Takes one argument and tries to match that argument against the current pattern. Returns a list of all the texts that were matched.", new JavaMethod("allMatches") {
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

                    List<Object> result = new ArrayList<Object>();
                    MatchIterator iter = m.findAll();
                    Runtime runtime = context.runtime;
                    while(iter.hasMore()) {
                        result.add(runtime.newText(iter.nextMatch().group(0)));
                    }
                    
                    return runtime.newList(result);
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("Returns a text inspection of the object", new JavaMethod.WithNoArguments("inspect") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());
                    return method.runtime.newText(Regexp.getInspect(on));
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("Returns a brief text inspection of the object", new JavaMethod.WithNoArguments("notice") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());
                    return method.runtime.newText(Regexp.getNotice(on));
                }
            }));
    }

    public static String getInspect(Object on) throws ControlFlow {
        return ((Regexp)(IokeObject.data(on))).inspect(on);
    }

    public static String getNotice(Object on) throws ControlFlow {
        return ((Regexp)(IokeObject.data(on))).notice(on);
    }

    public String inspect(Object obj) throws ControlFlow {
        return "#/" + pattern + "/" + flags;
    }

    public String notice(Object obj) throws ControlFlow {
        return "#/" + pattern + "/" + flags;
    }

    @Override
    public boolean isEqualTo(IokeObject self, Object other) {
        return ((other instanceof IokeObject) && 
                (IokeObject.data(other) instanceof Regexp) &&
                ((self == self.runtime.regexp || other == self.runtime.regexp) ? self == other :
                 (this.pattern.equals(((Regexp)IokeObject.data(other)).pattern) &&
                  this.flags.equals(((Regexp)IokeObject.data(other)).flags))));
    }

    @Override
    public int hashCode(IokeObject self) {
        return this.pattern.hashCode() + this.flags.hashCode();
    }
}// Regexp
