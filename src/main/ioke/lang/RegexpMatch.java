/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.List;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Set;

import org.jregex.Matcher;
import org.jregex.Pattern;
import org.jregex.MatchIterator;
import org.jregex.MatchResult;

import ioke.lang.exceptions.ControlFlow;

/**
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class RegexpMatch extends IokeData {
    private IokeObject regexp;
    private MatchResult mr;
    private IokeObject target;

    public RegexpMatch(IokeObject regexp, MatchResult mr, IokeObject target) {
        this.regexp = regexp;
        this.mr = mr;
        this.target = target;
    }
    
    public static Object getTarget(Object on) throws ControlFlow {
        return ((RegexpMatch)IokeObject.data(on)).target;
    }

    public static Object getRegexp(Object on) throws ControlFlow {
        return ((RegexpMatch)IokeObject.data(on)).regexp;
    }

    public static MatchResult getMatchResult(Object on) throws ControlFlow {
        return ((RegexpMatch)IokeObject.data(on)).mr;
    }

    @Override
    public void init(IokeObject obj) throws ControlFlow {
        final Runtime runtime = obj.runtime;
        obj.setKind("Regexp Match");

        obj.registerMethod(runtime.newJavaMethod("Returns the target that this match was created against", new JavaMethod.WithNoArguments("target") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());
                    return getTarget(on);
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns a list of all the named groups in the regular expression used to create this match", new JavaMethod.WithNoArguments("names") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());

                    Set names = Regexp.getRegexp(getRegexp(on)).getGroupNames();
                    List<Object> theNames = new ArrayList<Object>();
                    for(Object name : names) {
                        theNames.add(context.runtime.getSymbol(((String)name)));
                    }
                    return context.runtime.newList(theNames);
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("Takes one optional argument that should be either a number or a symbol. this should be the name or index of a group to return the start index for. if no index is supplied, 0 is the default. if the group in question wasn't matched, returns -1.", new JavaMethod("start") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withOptionalPositional("index", "0")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());
                    int index = 0;
                    
                    if(args.size() > 0) {
                        Object arg = args.get(0);
                        if(IokeObject.data(arg) instanceof Number) {
                            index = Number.extractInt(arg, message, context);
                        } else {
                            String namedIndex = Symbol.getText(arg);
                            Integer ix = Regexp.getRegexp(getRegexp(on)).groupId(namedIndex);
                            if(ix == null) {
                                return context.runtime.newNumber(-1);
                            }
                            
                            index = ix;
                        }
                    }
                    MatchResult mr = getMatchResult(on);
                    if(index < mr.groupCount() && mr.isCaptured(index)) {
                        return context.runtime.newNumber(mr.start(index));
                    } else {
                        return context.runtime.newNumber(-1);
                    }
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("Takes one optional argument that should be either a number or a symbol. this should be the name or index of a group to return the end index for. if no index is supplied, 0 is the default. if the group in question wasn't matched, returns -1.", new JavaMethod("end") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withOptionalPositional("index", "0")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());
                    int index = 0;
                    
                    if(args.size() > 0) {
                        Object arg = args.get(0);
                        if(IokeObject.data(arg) instanceof Number) {
                            index = Number.extractInt(arg, message, context);
                        } else {
                            String namedIndex = Symbol.getText(arg);
                            Integer ix = Regexp.getRegexp(getRegexp(on)).groupId(namedIndex);
                            if(ix == null) {
                                return context.runtime.newNumber(-1);
                            }
                            
                            index = ix;
                        }
                    }
                    MatchResult mr = getMatchResult(on);
                    if(index < mr.groupCount() && mr.isCaptured(index)) {
                        return context.runtime.newNumber(mr.end(index));
                    } else {
                        return context.runtime.newNumber(-1);
                    }
                }
            }));
    }
}
