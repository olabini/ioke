/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Reflector {
    public static void init(final Runtime runtime) throws ControlFlow {
        IokeObject obj = new IokeObject(runtime, "Allows access to the internals of any object without actually using methods on that object");
        obj.setKind("Reflector");
        obj.mimicsWithoutCheck(runtime.origin);
        runtime.iokeGround.registerCell("Reflector", obj);

        obj.registerMethod(runtime.newNativeMethod("returns the documentation text of the object given as argument. anything can have a documentation text - this text will initially be nil.", new TypeCheckingNativeMethod("other:documentation") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .withRequiredPositional("other")
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    return Base.documentation(context, message, args.get(0));
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("sets the documentation string for a specific object.", new TypeCheckingNativeMethod("other:documentation=") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .withRequiredPositional("other")
                    .withRequiredPositional("text").whichMustMimic(runtime.text).orBeNil()
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    return Base.setDocumentation(context, message, args.get(0), args.get(1));
                }
            }));


        obj.registerMethod(runtime.newNativeMethod("Takes one evaluated Text argument and returns either true or false if this object or one of it's mimics have the kind of the name specified", new TypeCheckingNativeMethod("other:kind?") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .withRequiredPositional("other")
                    .withRequiredPositional("name").whichMustMimic(runtime.text)
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    String kind = Text.getText(args.get(1));
                    return IokeObject.isKind(args.get(0), kind, context) ? context.runtime._true : context.runtime._false;
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("Takes one evaluated argument and returns either true or false if this object or one of it's mimics mimics that argument", new NativeMethod("other:mimics?") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("other")
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
                    return IokeObject.isMimic(args.get(0), IokeObject.as(args.get(1), context), context) ? context.runtime._true : context.runtime._false;
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("Takes one evaluated argument and returns either true or false if this object or one of it's mimics mimics that argument. exactly the same as 'other:mimics?'", new NativeMethod("other:is?") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("other")
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

                    IokeObject arg = IokeObject.as(args.get(1), context);
                    return IokeObject.isMimic(args.get(0), arg, context) ? context.runtime._true : context.runtime._false;
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("returns a list of all the mimics of the receiver. it will not be the same list as is used to back the object, so modifications to this list will not show up in the object.", new TypeCheckingNativeMethod("other:mimics") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .withRequiredPositional("other")
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    return context.runtime.newList(new ArrayList<Object>(IokeObject.getMimics(args.get(0), context)));
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("removes all mimics on the receiver, and returns the receiver", new TypeCheckingNativeMethod("other:removeAllMimics!") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .withRequiredPositional("other")
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    IokeObject.removeAllMimics(args.get(0), message, context);
                    return args.get(0);
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("removes the argument mimic from the list of all mimics on the receiver. will do nothing if the receiver has no such mimic. it returns the receiver", new NativeMethod("other:removeMimic!") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("other")
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

                    IokeObject.removeMimic(args.get(0), args.get(1), message, context);
                    return args.get(0);
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("Takes one evaluated argument and adds it to the list of mimics for the receiver. the receiver will be returned.", new NativeMethod("other:mimic!") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("other")
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

                    IokeObject newMimic = IokeObject.as(args.get(1), context);
                    IokeObject.as(args.get(0), context).mimics(newMimic, message, context);
                    return args.get(0);
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("Takes one evaluated argument and prepends it to the list of mimics for the receiver. the receiver will be returned.", new NativeMethod("other:prependMimic!") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("other")
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

                    IokeObject newMimic = IokeObject.as(args.get(1), context);
                    IokeObject.as(args.get(0), context).mimics(0, newMimic, message, context);
                    return args.get(0);
                }
            }));


        obj.registerMethod(runtime.newNativeMethod("expects one evaluated text or symbol argument and returns the cell that matches that name, without activating even if it's activatable.", new NativeMethod("other:cell") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("other")
                    .withRequiredPositional("cellName")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());

                    String name = Text.getText(((Message)IokeObject.data(context.runtime.asText)).sendTo(context.runtime.asText, context, args.get(1)));
                    return IokeObject.getCell(args.get(0), message, context, name);
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("expects one evaluated text or symbol argument and returns a boolean indicating whether such a cell is reachable from this point.", new NativeMethod("other:cell?") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("other")
                    .withRequiredPositional("cellName")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());

                    String name = Text.getText(((Message)IokeObject.data(context.runtime.asText)).sendTo(context.runtime.asText, context, args.get(1)));
                    return IokeObject.findCell(args.get(0), message, context, name) != context.runtime.nul ? context.runtime._true : context.runtime._false;
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("expects one evaluated text or symbol argument and returns a boolean indicating whether this cell is owned by the receiver or not. the assumption is that the cell should exist. if it doesn't exist, a NoSuchCell condition will be signalled.", new NativeMethod("other:cellOwner?") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("other")
                    .withRequiredPositional("cellName")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());

                    String name = Text.getText(((Message)IokeObject.data(context.runtime.asText)).sendTo(context.runtime.asText, context, args.get(1)));
                    return (IokeObject.findPlace(args.get(0), message, context, name) == args.get(0)) ? context.runtime._true : context.runtime._false;
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("expects one evaluated text or symbol argument and returns the closest object that defines such a cell. if it doesn't exist, a NoSuchCell condition will be signalled.", new NativeMethod("other:cellOwner") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("other")
                    .withRequiredPositional("cellName")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());

                    String name = Text.getText(((Message)IokeObject.data(context.runtime.asText)).sendTo(context.runtime.asText, context, args.get(1)));
                    Object result = IokeObject.findPlace(args.get(0), message, context, name);
                    if(result == context.runtime.nul) {
                        return context.runtime.nil;
                    }
                    return result;
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("expects one evaluated text or symbol argument and removes that cell from the current receiver. if the current receiver has no such object, signals a condition. note that if another cell with that name is available in the mimic chain, it will still be accessible after calling this method. the method returns the receiver.", new NativeMethod("other:removeCell!") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("other")
                    .withRequiredPositional("cellName")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());

                    String name = Text.getText(((Message)IokeObject.data(context.runtime.asText)).sendTo(context.runtime.asText, context, args.get(1)));
                    IokeObject.removeCell(args.get(0), message, context, name);
                    return args.get(0);
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("expects one evaluated text or symbol argument and makes that cell undefined in the current receiver. what that means is that from now on it will look like this cell doesn't exist in the receiver or any of its mimics. the cell will not show up if you call cellNames on the receiver or any of the receivers mimics. the undefined status can be removed by doing removeCell! on the correct cell name. a cell name that doesn't exist can still be undefined. the method returns the receiver.", new NativeMethod("other:undefineCell!") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("other")
                    .withRequiredPositional("cellName")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());

                    String name = Text.getText(((Message)IokeObject.data(context.runtime.asText)).sendTo(context.runtime.asText, context, args.get(1)));
                    IokeObject.undefineCell(args.get(0), message, context, name);
                    return args.get(0);
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("takes one optional evaluated boolean argument, which defaults to false. if false, this method returns a list of the cell names of the receiver. if true, it returns the cell names of this object and all it's mimics recursively.", new NativeMethod("other:cellNames") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("other")
                    .withOptionalPositional("includeMimics", "false")
                    .withOptionalPositional("cutoff", "nil")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());

                    return Base.cellNames(context, message, args.get(0), args.size() > 1 && IokeObject.isTrue(args.get(1)), (args.size() > 2) ? args.get(2) : null);
                }
            }));


        obj.registerMethod(runtime.newNativeMethod("takes one optional evaluated boolean argument, which defaults to false. if false, this method returns a dict of the cell names and values of the receiver. if true, it returns the cell names and values of this object and all it's mimics recursively.", new NativeMethod("other:cells") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("other")
                    .withOptionalPositional("includeMimics", "false")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());
                    return Base.cells(context, message, args.get(0), args.size() > 1 && IokeObject.isTrue(args.get(1)));
                }
            }));


        obj.registerMethod(runtime.newNativeMethod("expects one evaluated text or symbol argument that names the cell to set, sets this cell to the result of evaluating the second argument, and returns the value set.", new NativeMethod("other:cell=") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("other")
                    .withRequiredPositional("cellName")
                    .withRequiredPositional("value")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());
                    return Base.assignCell(context, message, args.get(0), args.get(1), args.get(2));
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("will return a new derivation of the receiving object. Might throw exceptions if the object is an oddball object.", new TypeCheckingNativeMethod("other:mimic") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .withRequiredPositional("other")
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    return IokeObject.as(args.get(0), context).mimic(message, context);
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("modifies the receiver to be in all ways identical to the argument. if the receiver is nil, true or false, this method can't be used - but those are the only exceptions. it's generally not recommended to use it on kinds and objects that are important for the Ioke runtime, since the result might be highly unpredictable.", new NativeMethod("other:become!") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("other")
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
                    IokeObject me = IokeObject.as(args.get(0), context);
                    IokeObject other = IokeObject.as(args.get(1), context);

                    if(args.get(0) == context.runtime.nil || args.get(0) == context.runtime._true || args.get(0) == context.runtime._false) {
                        final IokeObject condition = IokeObject.as(IokeObject.getCellChain(context.runtime.condition, 
                                                                                           message, 
                                                                                           context,
                                                                                           "Error", 
                                                                                           "CantMimicOddball"), context).mimic(message, context);
                        condition.setCell("message", message);
                        condition.setCell("context", context);
                        condition.setCell("receiver", args.get(0));
                        context.runtime.errorCondition(condition);
                    }

                    me.become(other, message, context);
                    
                    return args.get(0);
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("returns true if the receiver is frozen, otherwise false", new TypeCheckingNativeMethod("other:frozen?") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .withRequiredPositional("other")
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    return IokeObject.isFrozen(args.get(0)) ? context.runtime._true : context.runtime._false;
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("ensures that the receiver is frozen", new TypeCheckingNativeMethod("other:freeze!") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .withRequiredPositional("other")
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    IokeObject.freeze(args.get(0));
                    return args.get(0);
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("ensures that the receiver is not frozen", new TypeCheckingNativeMethod("other:thaw!") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .withRequiredPositional("other")
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    IokeObject.thaw(args.get(0));
                    return args.get(0);
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("returns a text hex representation of the receiver in upper case hex literal, starting with 0x. This value is based on System.identityHashCode, and as such is not totally guaranteed to be totally unique. but almost.", new TypeCheckingNativeMethod("other:uniqueHexId") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .withRequiredPositional("other")
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    return context.runtime.newText("0x" + Integer.toHexString(System.identityHashCode(IokeObject.getCells(args.get(0), context))).toUpperCase());
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("returns true if the evaluated argument is the same reference as the receiver, false otherwise.", new NativeMethod("other:same?") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("this")
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
                    return IokeObject.same(args.get(0), args.get(1)) ? context.runtime._true : context.runtime._false;
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("takes the name of a message to send, and the arguments to give it. send should generally behave exactly as if you had sent the message itself - except that you can give a variable containing the name.", new NativeMethod("other:send") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("other")
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
                    Object recv = ((Message)IokeObject.data(message)).getEvaluatedArgument(message, 0, context);
                    Object _name = ((Message)IokeObject.data(message)).getEvaluatedArgument(message, 1, context);
                    String name = Text.getText(((Message)IokeObject.data(runtime.asText)).sendTo(runtime.asText, context, _name));

                    IokeObject newMessage = Message.deepCopy(message);
                    newMessage.getArguments().remove(0);
                    newMessage.getArguments().remove(0);
                    Message.setName(newMessage, name);
                    return ((Message)IokeObject.data(newMessage)).sendTo(newMessage, context, recv);
                }
            }));
    }
}
