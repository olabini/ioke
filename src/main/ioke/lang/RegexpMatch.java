/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.Set;

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
    public void init(final IokeObject obj) throws ControlFlow {
        final Runtime runtime = obj.runtime;
        obj.setKind("Regexp Match");

        obj.registerMethod(runtime.newJavaMethod("Returns the target that this match was created against", new TypeCheckingJavaMethod.WithNoArguments("target", obj) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    return getTarget(on);
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns a list of all the named groups in the regular expression used to create this match", new TypeCheckingJavaMethod.WithNoArguments("names", obj) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    Set names = Regexp.getRegexp(getRegexp(on)).getGroupNames();
                    List<Object> theNames = new ArrayList<Object>();
                    for(Object name : names) {
                        theNames.add(context.runtime.getSymbol(((String)name)));
                    }
                    return context.runtime.newList(theNames);
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns the part of the target before the text that matched", new TypeCheckingJavaMethod.WithNoArguments("beforeMatch", obj) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    return context.runtime.newText(getMatchResult(on).prefix());
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns the part of the target after the text that matched", new TypeCheckingJavaMethod.WithNoArguments("afterMatch", obj) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    return context.runtime.newText(getMatchResult(on).suffix());
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns the text that matched", new TypeCheckingJavaMethod.WithNoArguments("match", obj) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    return context.runtime.newText(getMatchResult(on).group(0));
                }
            }));

        obj.aliasMethod("match", "asText", null, null);

        obj.registerMethod(runtime.newJavaMethod("returns the number of groups available in this match", new TypeCheckingJavaMethod.WithNoArguments("length", obj) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    return context.runtime.newNumber(getMatchResult(on).groupCount());
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns a list of all groups captured in this match. if a group is not matched it will be nil in the list. the actual match text is not included in this list.", new TypeCheckingJavaMethod.WithNoArguments("captures", obj) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    List<Object> groups = new ArrayList<Object>();
                    MatchResult mr = getMatchResult(on);
                    int len = mr.groupCount();
                    for(int i=1;i<len;i++) {
                        if(mr.isCaptured(i)) {
                            groups.add(context.runtime.newText(mr.group(i)));
                        } else {
                            groups.add(context.runtime.nil);
                        }
                    }

                    return context.runtime.newList(groups);
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns a list of all groups captured in this match. if a group is not matched it will be nil in the list. the actual match text is the first element in the list.", new TypeCheckingJavaMethod.WithNoArguments("asList", obj) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    List<Object> groups = new ArrayList<Object>();
                    MatchResult mr = getMatchResult(on);
                    int len = mr.groupCount();
                    for(int i=0;i<len;i++) {
                        if(mr.isCaptured(i)) {
                            groups.add(context.runtime.newText(mr.group(i)));
                        } else {
                            groups.add(context.runtime.nil);
                        }
                    }

                    return context.runtime.newList(groups);
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("Takes one optional argument that should be either a number or a symbol. this should be the name or index of a group to return the start index for. if no index is supplied, 0 is the default. if the group in question wasn't matched, returns -1.", new TypeCheckingJavaMethod("start") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .receiverMustMimic(obj)
                    .withOptionalPositional("index", "0")
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    int index = 0;
                    
                    if(args.size() > 0) {
                        Object arg = args.get(0);
                        if(IokeObject.data(arg) instanceof Number) {
                            index = Number.extractInt(arg, message, context);
                        } else {
                            String namedIndex = Text.getText(context.runtime.asText.sendTo(context, arg));
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

        obj.registerMethod(runtime.newJavaMethod("Takes one optional argument that should be either a number or a symbol. this should be the name or index of a group to return the end index for. if no index is supplied, 0 is the default. if the group in question wasn't matched, returns -1.", new TypeCheckingJavaMethod("end") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .receiverMustMimic(obj)
                    .withOptionalPositional("index", "0")
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    int index = 0;
                    
                    if(args.size() > 0) {
                        Object arg = args.get(0);
                        if(IokeObject.data(arg) instanceof Number) {
                            index = Number.extractInt(arg, message, context);
                        } else {
                            String namedIndex = Text.getText(context.runtime.asText.sendTo(context, arg));
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

        obj.registerMethod(runtime.newJavaMethod("Takes one optional argument that should be either a number or a symbol. this should be the name or index of a group to return the start and end index for. if no index is supplied, 0 is the default. if the group in question wasn't matched, returns nil, otherwise a pair of the start and end indices.", new TypeCheckingJavaMethod("offset") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .receiverMustMimic(obj)
                    .withOptionalPositional("index", "0")
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    int index = 0;
                    
                    if(args.size() > 0) {
                        Object arg = args.get(0);
                        if(IokeObject.data(arg) instanceof Number) {
                            index = Number.extractInt(arg, message, context);
                        } else {
                            String namedIndex = Text.getText(context.runtime.asText.sendTo(context, arg));
                            Integer ix = Regexp.getRegexp(getRegexp(on)).groupId(namedIndex);
                            if(ix == null) {
                                return context.runtime.nil;
                            }
                            
                            index = ix;
                        }
                    }
                    MatchResult mr = getMatchResult(on);
                    if(index < mr.groupCount() && mr.isCaptured(index)) {
                        return context.runtime.newPair(context.runtime.newNumber(mr.start(index)), context.runtime.newNumber(mr.end(index)));
                    } else {
                        return context.runtime.nil;
                    }
                }
            }));


        obj.registerMethod(runtime.newJavaMethod("Takes one indexing argument that should be either a number, a range, a text or a symbol. if it's a number or a range of numbers, these will specify the index of the capture to return. 0 is the whole match. negative indices are interpreted in the usual way. if the range is out of range it will only use as many groups as there are. if it's a text or a sym it will be interpreted as a the name of a named group to return. if an index isn't correct or wasn't matched, it returns nil in those places.", new TypeCheckingJavaMethod("[]") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .receiverMustMimic(obj)
                    .withRequiredPositional("index")
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    Object arg = args.get(0);

                    MatchResult mr = getMatchResult(on);

                    if((IokeObject.data(arg) instanceof Symbol) || (IokeObject.data(arg) instanceof Text)) {
                        String namedIndex = Text.getText(context.runtime.asText.sendTo(context, arg));
                        Integer ix = Regexp.getRegexp(getRegexp(on)).groupId(namedIndex);
                        if(ix == null || !mr.isCaptured(ix)) {
                            return context.runtime.nil;
                        }
                        return context.runtime.newText(mr.group(ix));
                    } else {
                        int size = mr.groupCount();

                        if(IokeObject.data(arg) instanceof Range) {
                            int first = Number.extractInt(Range.getFrom(arg), message, context); 
                        
                            if(first < 0) {
                                return context.runtime.newList(new ArrayList<Object>());
                            }

                            int last = Number.extractInt(Range.getTo(arg), message, context);
                            boolean inclusive = Range.isInclusive(arg);


                            if(last < 0) {
                                last = size + last;
                            }

                            if(last < 0) {
                                return context.runtime.newList(new ArrayList<Object>());
                            }

                            if(last >= size) {
                                last = inclusive ? size-1 : size;
                            }

                            if(first > last || (!inclusive && first == last)) {
                                return context.runtime.newList(new ArrayList<Object>());
                            }
                        
                            if(!inclusive) {
                                last--;
                            }
                        
                            List<Object> result = new ArrayList<Object>();
                            for(int i = first; i < last+1; i++) {
                                if(!mr.isCaptured(i)) {
                                    result.add(context.runtime.nil);
                                } else {
                                    result.add(context.runtime.newText(mr.group(i)));
                                }
                            }

                            return context.runtime.newList(result);
                        }
                        
                        if(!(IokeObject.data(arg) instanceof Number)) {
                            arg = IokeObject.convertToNumber(arg, message, context);
                        }
                        int index = ((Number)IokeObject.data(arg)).asJavaInteger();
                        if(index < 0) {
                            index = size + index;
                        }

                        if(index >= 0 && index < size && mr.isCaptured(index)) {
                            return context.runtime.newText(mr.group(index));
                        } else {
                            return context.runtime.nil;
                        }
                    }
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("will get the named group corresponding to the name of the message, or nil if the named group hasn't been matched. will signal a condition if no such group is defined.", new TypeCheckingJavaMethod("pass") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .receiverMustMimic(obj)
                    .getArguments();
                
                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }
                
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    MatchResult mr = getMatchResult(on);
                    String name = Message.name(message);
                    
                    Integer ix = Regexp.getRegexp(getRegexp(on)).groupId(name);
                    if(ix == null) {
                        final IokeObject condition = IokeObject.as(IokeObject.getCellChain(message.runtime.condition, 
                                                                                           message, 
                                                                                           context, 
                                                                                           "Error", 
                                                                                           "NoSuchCell"), context).mimic(message, context);
                        condition.setCell("message", message);
                        condition.setCell("context", context);
                        condition.setCell("receiver", on);
                        condition.setCell("cellName", message.runtime.getSymbol(name));

                        message.runtime.withReturningRestart("ignore", context, new RunnableWithControlFlow() {
                                public void run() throws ControlFlow {
                                    condition.runtime.errorCondition(condition);
                                }});

                        return context.runtime.nil;
                    }

                    if(mr.isCaptured(ix)) {
                        return context.runtime.newText(mr.group(ix));
                    } else {
                        return context.runtime.nil;
                    }
                }
            }));
        
    }
}
