/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.ArrayList;
import java.util.List;
import java.util.HashMap;
import java.util.Map;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Call extends IokeData {
    private IokeObject ctx;
    private IokeObject message;
    private IokeObject surroundingContext;
    private IokeObject on;
    List<Object> cachedPositional;
    Map<String, Object> cachedKeywords;
    int cachedArgCount;

    public Call() {
    }

    public Call(IokeObject ctx, IokeObject message, IokeObject surroundingContext, IokeObject on) {
        this.ctx = ctx;
        this.message = message;
        this.surroundingContext = surroundingContext;
        this.on = on;
    }

    @Override
    public void init(IokeObject obj) throws ControlFlow {
        final Runtime runtime = obj.runtime;

        obj.setKind("Call");

        obj.registerMethod(runtime.newJavaMethod("returns a list of all the unevaluated arguments", new TypeCheckingJavaMethod.WithNoArguments("arguments", runtime.call) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    return context.runtime.newList(((Call)IokeObject.data(on)).message.getArguments());
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns the ground of the place this call originated", new TypeCheckingJavaMethod.WithNoArguments("ground", runtime.call) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());

                    return ((Call)IokeObject.data(on)).surroundingContext;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns the receiver of the call", new TypeCheckingJavaMethod.WithNoArguments("receiver", runtime.call) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());

                    return ((Call)IokeObject.data(on)).on;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns the currently executing context", new TypeCheckingJavaMethod.WithNoArguments("currentContext", runtime.call) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());

                    return ((Call)IokeObject.data(on)).ctx;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns the message that started this call", new TypeCheckingJavaMethod.WithNoArguments("message", runtime.call) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());

                    return ((Call)IokeObject.data(on)).message;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns a list of the result of evaluating all the arguments to this call", new TypeCheckingJavaMethod.WithNoArguments("evaluatedArguments", runtime.call) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());

                    return context.runtime.newList(((Call)IokeObject.data(on)).message.getEvaluatedArguments(((Call)IokeObject.data(on)).surroundingContext));
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("takes one evaluated text or symbol argument and resends the current message to that method/macro on the current receiver.", new TypeCheckingJavaMethod("resendToMethod") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .receiverMustMimic(runtime.call)
                    .withRequiredPositional("cellName")
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    Call c = (Call)IokeObject.data(on);
                    String name = Text.getText(runtime.asText.sendTo(context, args.get(0)));
                    IokeObject m = Message.copy(c.message);
                    Message.setName(m, name);
                    return m.sendTo(c.surroundingContext, c.on);
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("uhm. this is a strange one. really.", new TypeCheckingJavaMethod("resendToValue") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .receiverMustMimic(runtime.call)
                    .withRequiredPositional("value")
                    .withOptionalPositional("newSelf", "nil")
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    Call c = (Call)IokeObject.data(on);
                    Object self = c.on;
                    if(args.size() > 1) {
                        self = args.get(1);
                    }

                    return IokeObject.getOrActivate(args.get(0), c.surroundingContext, c.message, self);
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("uhm. this one isn't too bad.", new TypeCheckingJavaMethod("activateValue") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .receiverMustMimic(runtime.call)
                    .withRequiredPositional("value")
                    .withOptionalPositional("newSelf", "nil")
                    .withKeywordRest("valuesToAdd")
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keys, IokeObject context, IokeObject message) throws ControlFlow {
                    Call c = (Call)IokeObject.data(on);
                    Object self = c.on;
                    if(args.size() > 1) {
                        self = args.get(1);
                    }

                    return IokeObject.as(args.get(0), context).activateWithData(c.surroundingContext, c.message, self, keys);
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("I really ought to write documentation for these methods, but I don't know how to describe what they do.", new TypeCheckingJavaMethod("activateValueWithCachedArguments") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .receiverMustMimic(runtime.call)
                    .withRequiredPositional("value")
                    .withOptionalPositional("newSelf", "nil")
                    .withKeywordRest("valuesToAdd")
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keys, IokeObject context, IokeObject message) throws ControlFlow {
                    Call c = (Call)IokeObject.data(on);
                    Object self = c.on;
                    if(args.size() > 1) {
                        self = args.get(1);
                    }

                    return IokeObject.as(args.get(0), context).activateWithCallAndData(c.surroundingContext, c.message, self, on, keys);
                }
            }));

    }

    public IokeData cloneData(IokeObject obj, IokeObject m, IokeObject context) {
        return new Call(this.ctx, this.message, this.surroundingContext, this.on);
    }
}// Call
