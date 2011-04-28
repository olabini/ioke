/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.ArrayList;
import java.util.List;
import java.util.HashSet;
import java.util.Map;
import java.util.HashMap;
import java.util.Set;

import ioke.lang.exceptions.ControlFlow;
import ioke.lang.util.IdentitySet;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class IokeSet extends IokeData {
    private Set<Object> set;

    public IokeSet() {
        this(new HashSet<Object>());
    }

    public IokeSet(Set<Object> s) {
        this.set = s;
    }

    @Override
    public void init(IokeObject obj) throws ControlFlow {
        final Runtime runtime = obj.runtime;

        obj.setKind("Set");
        obj.mimics(IokeObject.as(runtime.mixins.getCell(null, null, "Sequenced"), null), runtime.nul, runtime.nul);

        obj.registerMethod(runtime.newNativeMethod("returns a hash for the set", new NativeMethod.WithNoArguments("hash") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());
                    return context.runtime.newNumber(((IokeSet)IokeObject.data(on)).set.hashCode());
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("returns true if the left hand side set is equal to the right hand side set.", new TypeCheckingNativeMethod("==") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .receiverMustMimic(runtime.set)
                    .withRequiredPositional("other")
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject self, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());
                    Object other = args.get(0);
                    return ((other instanceof IokeObject) &&
                            (IokeObject.data(other) instanceof IokeSet) &&
                            ((IokeSet)IokeObject.data(on)).set.equals(((IokeSet)IokeObject.data(other)).set)) ? context.runtime._true : context.runtime._false;
                }
            }));


        obj.registerMethod(obj.runtime.newNativeMethod("Returns a text inspection of the object", new TypeCheckingNativeMethod.WithNoArguments("inspect", runtime.set) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    return method.runtime.newText(IokeSet.getInspect(on));
                }
            }));

        obj.registerMethod(obj.runtime.newNativeMethod("Converts this set to use identity semantics, and then returns it.", new TypeCheckingNativeMethod.WithNoArguments("withIdentitySemantics!", runtime.set) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    IokeSet set = (IokeSet)IokeObject.data(on);
                    set.set = new IdentitySet<Object>(set.set);
                    return on;
                }
            }));

        obj.registerMethod(obj.runtime.newNativeMethod("Returns a brief text inspection of the object", new TypeCheckingNativeMethod.WithNoArguments("notice", runtime.set) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    return method.runtime.newText(IokeSet.getNotice(on));
                }
            }));

        obj.registerMethod(obj.runtime.newNativeMethod("returns true if this set is empty, false otherwise", new TypeCheckingNativeMethod.WithNoArguments("empty?", runtime.set) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    return ((IokeSet)IokeObject.data(on)).getSet().isEmpty() ? context.runtime._true : context.runtime._false;
                }
            }));

        obj.registerMethod(obj.runtime.newNativeMethod("Adds the argument to this set, if it's not already in the set. Returns the set after adding the object.", new TypeCheckingNativeMethod("<<") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .receiverMustMimic(runtime.set)
                    .withRequiredPositional("value")
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    ((IokeSet)IokeObject.data(on)).set.add(args.get(0));
                    return on;
                }
            }));

        obj.registerMethod(obj.runtime.newNativeMethod("Removes the argument from the set, if it's in the set. Returns the set after removing the object.", new TypeCheckingNativeMethod("remove!") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .receiverMustMimic(runtime.set)
                    .withRequiredPositional("value")
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    ((IokeSet)IokeObject.data(on)).set.remove(args.get(0));
                    return on;
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("returns a new set that contains the receivers elements and the elements of the set sent in as the argument.", new TypeCheckingNativeMethod("+") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .receiverMustMimic(runtime.set)
                    .withRequiredPositional("otherSet").whichMustMimic(runtime.set)
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    Set<Object> newSet = new HashSet<Object>();
                    newSet.addAll(((IokeSet)IokeObject.data(on)).getSet());
                    newSet.addAll(((IokeSet)IokeObject.data(args.get(0))).getSet());
                    return context.runtime.newSet(newSet);
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("returns a new set that is the intersection of the receiver and the argument.", new TypeCheckingNativeMethod("\u2229") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .receiverMustMimic(runtime.set)
                    .withRequiredPositional("otherSet").whichMustMimic(runtime.set)
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    Set<Object> newSet = new HashSet<Object>();
                    newSet.addAll(((IokeSet)IokeObject.data(on)).getSet());
                    newSet.retainAll(((IokeSet)IokeObject.data(args.get(0))).getSet());
                    return context.runtime.newSet(newSet);
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("returns true if this set is a subset of the argument set", new TypeCheckingNativeMethod("\u2286") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .receiverMustMimic(runtime.set)
                    .withRequiredPositional("otherSet").whichMustMimic(runtime.set)
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    boolean result = ((IokeSet)IokeObject.data(args.get(0))).getSet().containsAll(((IokeSet)IokeObject.data(on)).getSet());
                    return result ? context.runtime._true : context.runtime._false;
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("returns true if this set is a proper subset of the argument set", new TypeCheckingNativeMethod("\u2282") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .receiverMustMimic(runtime.set)
                    .withRequiredPositional("otherSet").whichMustMimic(runtime.set)
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    Set<Object> one = ((IokeSet)IokeObject.data(args.get(0))).getSet();
                    Set<Object> two = ((IokeSet)IokeObject.data(on)).getSet();
                    boolean result = one.containsAll(two);
                    return (result && two.size() < one.size()) ? context.runtime._true : context.runtime._false;
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("returns true if this set is a superset of the argument set", new TypeCheckingNativeMethod("\u2287") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .receiverMustMimic(runtime.set)
                    .withRequiredPositional("otherSet").whichMustMimic(runtime.set)
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    boolean result = ((IokeSet)IokeObject.data(on)).getSet().containsAll(((IokeSet)IokeObject.data(args.get(0))).getSet());
                    return result ? context.runtime._true : context.runtime._false;
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("returns true if this set is a proper superset of the argument set", new TypeCheckingNativeMethod("\u2283") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .receiverMustMimic(runtime.set)
                    .withRequiredPositional("otherSet").whichMustMimic(runtime.set)
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    Set<Object> one = ((IokeSet)IokeObject.data(args.get(0))).getSet();
                    Set<Object> two = ((IokeSet)IokeObject.data(on)).getSet();
                    boolean result = two.containsAll(one);
                    return (result && two.size() > one.size()) ? context.runtime._true : context.runtime._false;
                }
            }));

        obj.registerMethod(obj.runtime.newNativeMethod("returns true if the receiver includes the evaluated argument, otherwise false", new TypeCheckingNativeMethod("include?") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .receiverMustMimic(runtime.set)
                    .withRequiredPositional("object")
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    return ((IokeSet)IokeObject.data(on)).getSet().contains(args.get(0)) ? context.runtime._true : context.runtime._false;
                }
            }));

        obj.registerMethod(obj.runtime.newNativeMethod("returns a new sequence to iterate over this set", new TypeCheckingNativeMethod.WithNoArguments("seq", runtime.set) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    IokeObject obj = method.runtime.iteratorSequence.allocateCopy(null, null);
                    obj.mimicsWithoutCheck(method.runtime.iteratorSequence);
                    obj.setData(new Sequence.IteratorSequence(((IokeSet)IokeObject.data(on)).set.iterator()));
                    return obj;
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("takes either one, two or three arguments. if one argument is given, it should be a message chain that will be sent to each object in the set. the result will be thrown away. if two arguments are given, the first is an unevaluated name that will be set to each of the values in the set in succession, and then the second argument will be evaluated in a scope with that argument in it. if three arguments is given, the first one is an unevaluated name that will be set to the index of each element, and the other two arguments are the name of the argument for the value, and the actual code. the code will evaluate in a lexical context, and if the argument name is available outside the context, it will be shadowed. the method will return the set. the iteration order is not defined.", new NativeMethod("each") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withOptionalPositionalUnevaluated("indexOrArgOrCode")
                    .withOptionalPositionalUnevaluated("argOrCode")
                    .withOptionalPositionalUnevaluated("code")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().checkArgumentCount(context, message, on);

                    Object onAsSet = context.runtime.set.convertToThis(on, message, context);
                    Set<Object> set = ((IokeSet)IokeObject.data(onAsSet)).set;

                    switch(message.getArgumentCount()) {
                    case 0: {
                        return runtime.interpreter.sendTo(runtime.seqMessage, context, on);
                    }
                    case 1: {
                        IokeObject code = IokeObject.as(message.getArguments().get(0), context);

                        for(Object o : set) {
                            context.runtime.interpreter.evaluateCompleteWithReceiver(code, context, context.getRealContext(), o);
                        }
                        break;
                    }
                    case 2: {
                        LexicalContext c = new LexicalContext(context.runtime, context, "Lexical activation context for Set#each", message, context);
                        String name = IokeObject.as(message.getArguments().get(0), context).getName();
                        IokeObject code = IokeObject.as(message.getArguments().get(1), context);

                        for(Object o : set) {
                            c.setCell(name, o);
                            context.runtime.interpreter.evaluateCompleteWithoutExplicitReceiver(code, c, c.getRealContext());
                        }
                        break;
                    }
                    case 3: {
                        LexicalContext c = new LexicalContext(context.runtime, context, "Lexical activation context for Set#each", message, context);
                        String iname = IokeObject.as(message.getArguments().get(0), context).getName();
                        String name = IokeObject.as(message.getArguments().get(1), context).getName();
                        IokeObject code = IokeObject.as(message.getArguments().get(2), context);

                        int index = 0;
                        for(Object o : set) {
                            c.setCell(name, o);
                            c.setCell(iname, runtime.newNumber(index++));
                            context.runtime.interpreter.evaluateCompleteWithoutExplicitReceiver(code, c, c.getRealContext());
                        }
                        break;
                    }
                    }

                    return onAsSet;
                }
            }));
    }

    public Set<Object> getSet() {
        return set;
    }

    public IokeData cloneData(IokeObject obj, IokeObject m, IokeObject context) {
        return new IokeSet(new HashSet<Object>(set));
    }

    @Override
    public String toString() {
        return set.toString();
    }

    @Override
    public String toString(IokeObject obj) {
        return set.toString();
    }

    public static String getInspect(Object on) throws ControlFlow {
        return ((IokeSet)(IokeObject.data(on))).inspect(on);
    }

    public static String getNotice(Object on) throws ControlFlow {
        return ((IokeSet)(IokeObject.data(on))).notice(on);
    }

    public String inspect(Object obj) throws ControlFlow {
        StringBuilder sb = new StringBuilder();
        sb.append("set(");
        String sep = "";
        for(Object o : set) {
            sb.append(sep).append(IokeObject.inspect(o));
            sep = ", ";
        }
        sb.append(")");
        return sb.toString();
    }

    public String notice(Object obj) throws ControlFlow {
        StringBuilder sb = new StringBuilder();
        sb.append("set(");
        String sep = "";
        for(Object o : set) {
            sb.append(sep).append(IokeObject.notice(o));
            sep = ", ";
        }
        sb.append(")");
        return sb.toString();
    }
}// IokeSet
