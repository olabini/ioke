/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.Arrays;
import java.util.ArrayList;
import java.util.List;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.HashSet;

import ioke.lang.exceptions.ControlFlow;
import ioke.lang.util.StringUtils;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class InternalBehavior {
    public static void init(IokeObject obj) throws ControlFlow {
        final Runtime runtime = obj.runtime;
        obj.setKind("DefaultBehavior Internal");

        obj.registerMethod(runtime.newJavaMethod("takes zero or more arguments, calls asText on non-text arguments, and then concatenates them and returns the result.", new JavaMethod("internal:concatenateText") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRest("textSegments")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());

                    StringBuilder sb = new StringBuilder();

                    if(IokeObject.data(on) instanceof Text) {
                        sb.append(Text.getText(on));
                    }

                    for(Object o : args) {
                        if(o instanceof IokeObject) {
                            if(IokeObject.data(o) instanceof Text) {
                                sb.append(Text.getText(o));
                            } else {
                                sb.append(Text.getText(context.runtime.asText.sendTo(context, o)));
                            }
                        } else {
                            sb.append(o);
                        }
                    }

                    return context.runtime.newText(sb.toString());
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("takes one or more arguments. it expects the last argument to be a regular expression, where the rest should be text. will call asText on all of them and insert that text in a regular expression. the flags for the regular expression will come from the last argument.", new JavaMethod("internal:compositeRegexp") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRest("regexpSegments")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());

                    StringBuilder sb = new StringBuilder();

                    if(IokeObject.data(on) instanceof Text) {
                        sb.append(Text.getText(on));
                    }

                    String flags = "";
                    for(Object o : args) {
                        if(IokeObject.data(o) instanceof Text) {
                            sb.append(Text.getText(o));
                        } else if(IokeObject.data(o) instanceof Regexp) {
                            sb.append(Regexp.getPattern(o));
                            flags = Regexp.getFlags(o);
                        } else {
                            sb.append(Text.getText(context.runtime.asText.sendTo(context, o)));
                        }
                    }

                    return context.runtime.newRegexp(sb.toString(), flags, context, message);
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("expects one 'strange' argument. creates a new instance of Text with the given Java String backing it.", new JavaMethod("internal:createText") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositionalUnevaluated("text")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().checkArgumentCount(context, message, on);

                    Object o = Message.getArg1(message);
                    boolean cache = true;
                    if(o instanceof IokeObject) {
                        cache = false;
                        o = Message.getEvaluatedArgument(o, context);
                    }
                    if(o instanceof String) {
                        String s = (String)o;
                        Object value = runtime.newText(new StringUtils().replaceEscapes(s));
                        if(cache) {
                            Message.cacheValue(message, value);
                        }
                        return value;
                    } else {
                        return IokeObject.convertToText(o, message, context, true);
                    }
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("expects two 'strange' arguments. creates a new mimic of Regexp with the given Java String backing it.", new JavaMethod("internal:createRegexp") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositionalUnevaluated("regexp")
                    .withRequiredPositionalUnevaluated("flags")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().checkArgumentCount(context, message, on);

                    Object o = Message.getArg1(message);
                    Object o2 = Message.getArg2(message);
                    if(o instanceof IokeObject) {
                        o = Message.getEvaluatedArgument(o, context);
                    }
                    if(o2 instanceof IokeObject) {
                        o2 = Message.getEvaluatedArgument(o2, context);
                    }
                    if(o instanceof String) {
                        String s = (String)o;
                        return runtime.newRegexp(new StringUtils().replaceRegexpEscapes(s), (String)o2, context, message);
                    } else {
                        return IokeObject.convertToRegexp(o, message, context);
                    }
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("expects one 'strange' argument. creates a new instance of Number that represents the number found in the strange argument.", new JavaMethod("internal:createNumber") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositionalUnevaluated("number")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().checkArgumentCount(context, message, on);

                    Object o = Message.getArg1(message);
                    boolean cache = true;
                    if(o instanceof IokeObject) {
                        cache = false;
                        o = Message.getEvaluatedArgument(o, context);
                    }
                    Object value = null;
                    if(o instanceof String) {
                        value = runtime.newNumber((String)o);
                    } else if(o instanceof Integer) {
                        value = runtime.newNumber((Integer)o);
                    }

                    if(cache) {
                        Message.cacheValue(message, value);
                    }
                    return value;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("expects one 'strange' argument. creates a new instance of Decimal that represents the number found in the strange argument.", new JavaMethod("internal:createDecimal") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositionalUnevaluated("decimal")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().checkArgumentCount(context, message, on);

                    Object o = Message.getArg1(message);
                    boolean cache = true;
                    if(o instanceof IokeObject) {
                        cache = false;
                        o = Message.getEvaluatedArgument(o, context);
                    }
                    Object value = runtime.newDecimal((String)o);
                    if(cache) {
                        Message.cacheValue(message, value);
                    }
                    return value;
                }
            }));
    }
}
