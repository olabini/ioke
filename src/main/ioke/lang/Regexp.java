/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.Set;

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
            return new Regexp(pattern, new Pattern(pattern, flags), flags);
        } catch(Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    static Regexp create(String pattern, String flags) {
        try {
            return new Regexp(pattern, new Pattern(pattern, flags), flags);
        } catch(Exception e) {
            e.printStackTrace();
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

        final IokeObject regexpMatch  = new IokeObject(runtime, "contains behavior related to assignment", new RegexpMatch(obj, null, null));
        regexpMatch.mimicsWithoutCheck(runtime.origin);
        regexpMatch.init();
        obj.registerCell("Match", regexpMatch);

        obj.registerMethod(runtime.newJavaMethod("Returns the pattern use for this regular expression", new TypeCheckingJavaMethod.WithNoArguments("pattern", runtime.regexp) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    return context.runtime.newText(getPattern(on));
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("Takes one argument and tries to match that argument against the current pattern. Returns nil if no match can be done, or a Regexp Match object if a match succeeds", new TypeCheckingJavaMethod("match") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .receiverMustMimic(runtime.regexp)
                    .withRequiredPositional("other")
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    IokeObject target = IokeObject.as(context.runtime.asText.sendTo(context, args.get(0)), context);
                    String arg = Text.getText(target);
                    Matcher m = ((Regexp)IokeObject.data(on)).regexp.matcher(arg);
                    
                    if(m.find()) {
                        IokeObject match = regexpMatch.allocateCopy(message, context);
                        match.mimicsWithoutCheck(regexpMatch);
                        match.setData(new RegexpMatch(IokeObject.as(on, context), m, target));
                        return match;
                    } else {
                        return context.runtime.nil;
                    }
                }
            }));

        obj.aliasMethod("match", "=~", null, null);

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
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
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
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    String pattern = Text.getText(context.runtime.asText.sendTo(context, args.get(0)));
                    String flags = "";
                    if(args.size() > 1) {
                        flags = Text.getText(context.runtime.asText.sendTo(context, args.get(1)));
                    }

                    return context.runtime.newRegexp(pattern, flags, context, message);
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("Takes one argument and tries to match that argument against the current pattern. Returns a list of all the texts that were matched.", new TypeCheckingJavaMethod("allMatches") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .receiverMustMimic(runtime.regexp)
                    .withRequiredPositional("other")
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
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

        obj.registerMethod(runtime.newJavaMethod("Returns a text inspection of the object", new TypeCheckingJavaMethod.WithNoArguments("inspect", runtime.regexp) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    return method.runtime.newText(Regexp.getInspect(on));
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("Returns a brief text inspection of the object", new TypeCheckingJavaMethod.WithNoArguments("notice", runtime.regexp) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    return method.runtime.newText(Regexp.getNotice(on));
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns a list of all the named groups in this regular expression", new TypeCheckingJavaMethod.WithNoArguments("names", runtime.regexp) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    Set names = Regexp.getRegexp(on).getGroupNames();
                    List<Object> theNames = new ArrayList<Object>();
                    for(Object name : names) {
                        theNames.add(context.runtime.getSymbol(((String)name)));
                    }
                    return context.runtime.newList(theNames);
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
