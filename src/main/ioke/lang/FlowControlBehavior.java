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

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class FlowControlBehavior {
    public static void init(IokeObject obj) throws ControlFlow {
        final Runtime runtime = obj.runtime;
        obj.setKind("DefaultBehavior FlowControl");

        obj.registerMethod(runtime.newJavaMethod("breaks out of the enclosing context. if an argument is supplied, this will be returned as the result of the object breaking out of", new JavaMethod("break") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withOptionalPositional("value", "nil")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());

                    Object value = runtime.nil;
                    if(message.getArgumentCount() > 0) {
                        value = message.getEvaluatedArgument(0, context);
                    }
                    throw new ControlFlow.Break(value);
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns from the enclosing method/macro. if an argument is supplied, this will be returned as the result of the method/macro breaking out of.", new JavaMethod("return") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withOptionalPositional("value", "nil")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    Object value = runtime.nil;
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());
                    if(args.size() > 0) {
                        value = args.get(0);
                    }
                    IokeObject ctx = context;
                    while(ctx instanceof LexicalContext) {
                        ctx = ((LexicalContext)ctx).surroundingContext;
                    }

                    throw new ControlFlow.Return(value, ctx);
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("breaks out of the enclosing context and continues from that point again.", new JavaMethod.WithNoArguments("continue") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());

                    throw new ControlFlow.Continue();
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("until the first argument evaluates to something true, loops and evaluates the next argument", new JavaMethod("until") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withOptionalPositionalUnevaluated("condition")
                    .withRestUnevaluated("body")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().checkArgumentCount(context, message, on);

                    if(message.getArgumentCount() == 0) {
                        return runtime.nil;
                    }

                    boolean body = message.getArgumentCount() > 1;
                    Object ret = runtime.nil;
                    boolean doAgain = false;
                    do {
                        doAgain = false;
                        try {
                            while(!IokeObject.isTrue(message.getEvaluatedArgument(0, context))) {
                                if(body) {
                                    ret = message.getEvaluatedArgument(1, context);
                                }
                            }
                        } catch(ControlFlow.Break e) {
                            ret = e.getValue();
                        } catch(ControlFlow.Continue e) {
                            doAgain = true;
                        }
                    } while(doAgain);

                    return ret;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("while the first argument evaluates to something true, loops and evaluates the next argument", new JavaMethod("while") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withOptionalPositionalUnevaluated("condition")
                    .withRestUnevaluated("body")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().checkArgumentCount(context, message, on);

                    if(message.getArgumentCount() == 0) {
                        return runtime.nil;
                    }

                    boolean body = message.getArgumentCount() > 1;
                    Object ret = runtime.nil;
                    boolean doAgain = false;
                    do {
                        doAgain = false;
                        try {
                            while(IokeObject.isTrue(message.getEvaluatedArgument(0, context))) {
                                if(body) {
                                    ret = message.getEvaluatedArgument(1, context);
                                }
                            }
                        } catch(ControlFlow.Break e) {
                            ret = e.getValue();
                        } catch(ControlFlow.Continue e) {
                            doAgain = true;
                        }
                    } while(doAgain);

                    return ret;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("loops forever - executing it's argument over and over until interrupted in some way.", new JavaMethod("loop") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRestUnevaluated("body")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().checkArgumentCount(context, message, on);

                    if(message.getArgumentCount() > 0) {
                        while(true) {
                            try {
                                while(true) {
                                    message.getEvaluatedArgument(0, context);
                                }
                            } catch(ControlFlow.Break e) {
                                return e.getValue();
                            } catch(ControlFlow.Continue e) {
                            }
                        }
                    } else {
                        while(true){}
                    }
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("evaluates the first arguments, and then evaluates the second argument if the result was true, otherwise the last argument. returns the result of the call, or the result if it's not true.", new JavaMethod("if") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("condition")
                    .withOptionalPositionalUnevaluated("then")
                    .withOptionalPositionalUnevaluated("else")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().checkArgumentCount(context, message, on);

                    Object test = message.getEvaluatedArgument(0, context);

                    LexicalContext itContext = new LexicalContext(context.runtime, context.getRealContext(), "Lexical activation context", message, context);
                    itContext.setCell("it", test);

                    if(IokeObject.isTrue(test)) {
                        if(message.getArgumentCount() > 1) {
                            return message.getEvaluatedArgument(1, itContext);
                        } else {
                            return test;
                        }
                    } else {
                        if(message.getArgumentCount() > 2) {
                            return message.getEvaluatedArgument(2, itContext);
                        } else {
                            return test;
                        }
                    }
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("evaluates the first arguments, and then evaluates the second argument if the result was false, otherwise the last argument. returns the result of the call, or the result if it's true.", new JavaMethod("unless") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("condition")
                    .withOptionalPositionalUnevaluated("then")
                    .withOptionalPositionalUnevaluated("else")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().checkArgumentCount(context, message, on);

                    Object test = message.getEvaluatedArgument(0, context);

                    LexicalContext itContext = new LexicalContext(context.runtime, context.getRealContext(), "Lexical activation context", message, context);
                    itContext.setCell("it", test);

                    if(IokeObject.isTrue(test)) {
                        if(message.getArgumentCount() > 2) {
                            return message.getEvaluatedArgument(2, itContext);
                        } else {
                            return test;
                        }
                    } else {
                        if(message.getArgumentCount() > 1) {
                            return message.getEvaluatedArgument(1, itContext);
                        } else {
                            return test;
                        }
                    }
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("will execute and return the value of the first argument. after the code has run, all the remaining blocks of code are guaranteed to run in order even if a non-local flow control happens inside the main code. if any code in the ensure blocks generate a new non-local flow control, the rest of the ensure blocks in that specific ensure invocation are not guaranteed to run.", new JavaMethod("ensure") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositionalUnevaluated("code")
                    .withRestUnevaluated("ensureBlocks")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, final IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().checkArgumentCount(context, message, on);
                    
                    final Runtime runtime = context.runtime;
                    List<Object> args = message.getArguments();
                    int argCount = args.size();

                    Object result = runtime.nil;

                    try {
                        result = IokeObject.as(args.get(0)).evaluateCompleteWithoutExplicitReceiver(context, context.getRealContext());
                    } finally {
                        for(Object o : args.subList(1, argCount)) {
                            IokeObject.as(o).evaluateCompleteWithoutExplicitReceiver(context, context.getRealContext());
                        }
                    }

                    return result;
                }
            }));
    }
}
