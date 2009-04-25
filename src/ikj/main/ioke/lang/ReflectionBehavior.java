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
public class ReflectionBehavior {
    public static void init(IokeObject obj) throws ControlFlow {
        final Runtime runtime = obj.runtime;
        obj.setKind("DefaultBehavior Reflection");

        obj.registerMethod(runtime.newNativeMethod("returns a text hex representation of the receiver in upper case hex literal, starting with 0x. This value is based on System.identityHashCode, and as such is not totally guaranteed to be totally unique. but almost.", new NativeMethod.WithNoArguments("uniqueHexId") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());

                    return context.runtime.newText("0x" + Integer.toHexString(System.identityHashCode(IokeObject.getCells(on, context))).toUpperCase());
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("returns true if the evaluated argument is the same reference as the receiver, false otherwise.", new NativeMethod("same?") {
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
                    return IokeObject.same(on, args.get(0)) ? context.runtime._true : context.runtime._false;
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("takes the name of a message to send, and the arguments to give it. send should generally behave exactly as if you had sent the message itself - except that you can give a variable containing the name.", new NativeMethod("send") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("messageName")
                    .withRestUnevaluated("arguments")
                    .withKeywordRestUnevaluated("keywordArguments")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().checkArgumentCount(context, message, on);
                    final Runtime runtime = context.runtime;
                    Object _name = ((Message)IokeObject.data(message)).getEvaluatedArgument(message, 0, context);
                    String name = Text.getText(((Message)IokeObject.data(runtime.asText)).sendTo(runtime.asText, context, _name));

                    IokeObject newMessage = Message.deepCopy(message);
                    newMessage.getArguments().remove(0);
                    Message.setName(newMessage, name);
                    return ((Message)IokeObject.data(newMessage)).sendTo(newMessage, context, on);
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("returns false if the left hand side is equal to the right hand side. exactly what this means depend on the object. the default behavior of Ioke objects is to only be equal if they are the same instance.", new NativeMethod("!=") {
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
                    return !IokeObject.equals(on, ((Message)IokeObject.data(message)).getEvaluatedArgument(message, 0, context)) ? context.runtime._true : context.runtime._false ;
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("returns a textual representation of the object called on.", new NativeMethod.WithNoArguments("asText") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());

                    return runtime.newText(on.toString());
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("Takes one evaluated Text argument and returns either true or false if this object or one of it's mimics have the kind of the name specified", new TypeCheckingNativeMethod("kind?") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .withRequiredPositional("name").whichMustMimic(runtime.text)
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    String kind = Text.getText(args.get(0));
                    return IokeObject.isKind(on, kind, context) ? context.runtime._true : context.runtime._false;
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("Takes one evaluated argument and returns either true or false if this object or one of it's mimics mimics that argument", new NativeMethod("mimics?") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("potentialMimic")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());

                    IokeObject arg = IokeObject.as(args.get(0), context);
                    return IokeObject.isMimic(on, arg, context) ? context.runtime._true : context.runtime._false;
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("Takes one evaluated argument and returns either true or false if this object or one of it's mimics mimics that argument. exactly the same as 'mimics?'", new NativeMethod("is?") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("potentialMimic")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());

                    IokeObject arg = IokeObject.as(args.get(0), context);
                    return IokeObject.isMimic(on, arg, context) ? context.runtime._true : context.runtime._false;
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("returns a list of all the mimics of the receiver. it will not be the same list as is used to back the object, so modifications to this list will not show up in the object.", new NativeMethod.WithNoArguments("mimics") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());

                    return context.runtime.newList(new ArrayList<Object>(IokeObject.getMimics(on, context)));
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("removes all mimics on the receiver, and returns the receiver", new NativeMethod.WithNoArguments("removeAllMimics!") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());

                    IokeObject.removeAllMimics(on, message, context);
                    return on;
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("removes the argument mimic from the list of all mimics on the receiver. will do nothing if the receiver has no such mimic. it returns the receiver", new NativeMethod("removeMimic!") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("mimicToRemove")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());

                    IokeObject.removeMimic(on, args.get(0), message, context);
                    return on;
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("Takes one evaluated argument and adds it to the list of mimics for the receiver. the receiver will be returned.", new NativeMethod("mimic!") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("newMimic")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());

                    IokeObject newMimic = IokeObject.as(args.get(0), context);
                    IokeObject.as(on, context).mimics(newMimic, message, context);
                    return on;
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("Takes one evaluated argument and prepends it to the list of mimics for the receiver. the receiver will be returned.", new NativeMethod("prependMimic!") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("newMimic")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());

                    IokeObject newMimic = IokeObject.as(args.get(0), context);
                    IokeObject.as(on, context).mimics(0, newMimic, message, context);
                    return on;
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("modifies the receiver to be in all ways identical to the argument. if the receiver is nil, true or false, this method can't be used - but those are the only exceptions. it's generally not recommended to use it on kinds and objects that are important for the Ioke runtime, since the result might be highly unpredictable.", new NativeMethod("become!") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("objectToBecome")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());
                    IokeObject me = IokeObject.as(on, context);
                    IokeObject other = IokeObject.as(args.get(0), context);

                    if(on == context.runtime.nil || on == context.runtime._true || on == context.runtime._false) {
                        final IokeObject condition = IokeObject.as(IokeObject.getCellChain(context.runtime.condition, 
                                                                                           message, 
                                                                                           context,
                                                                                           "Error", 
                                                                                           "CantMimicOddball"), context).mimic(message, context);
                        condition.setCell("message", message);
                        condition.setCell("context", context);
                        condition.setCell("receiver", on);
                        context.runtime.errorCondition(condition);
                    }

                    me.become(other, message, context);
                    
                    return on;
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("returns true if the receiver is frozen, otherwise false", new NativeMethod.WithNoArguments("frozen?") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());
                    return IokeObject.isFrozen(on) ? context.runtime._true : context.runtime._false;
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("ensures that the receiver is frozen", new NativeMethod.WithNoArguments("freeze!") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());

                    IokeObject.freeze(on);
                    return on;
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("ensures that the receiver is not frozen", new NativeMethod.WithNoArguments("thaw!") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());

                    IokeObject.thaw(on);
                    return on;
                }
            }));
    }
}
