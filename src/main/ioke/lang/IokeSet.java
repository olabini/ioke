/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.List;
import java.util.HashSet;
import java.util.Map;
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
        obj.mimics(IokeObject.as(runtime.mixins.getCell(null, null, "Enumerable"), null), runtime.nul, runtime.nul);

        obj.registerMethod(obj.runtime.newJavaMethod("Returns a text inspection of the object", new TypeCheckingJavaMethod.WithNoArguments("inspect", runtime.set) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    return method.runtime.newText(IokeSet.getInspect(on));
                }
            }));

        obj.registerMethod(obj.runtime.newJavaMethod("Converts this set to use identity semantics, and then returns it.", new TypeCheckingJavaMethod.WithNoArguments("withIdentitySemantics!", runtime.set) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    IokeSet set = (IokeSet)IokeObject.data(on);
                    set.set = new IdentitySet<Object>(set.set);
                    return on;
                }
            }));

        obj.registerMethod(obj.runtime.newJavaMethod("Returns a brief text inspection of the object", new TypeCheckingJavaMethod.WithNoArguments("notice", runtime.set) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    return method.runtime.newText(IokeSet.getNotice(on));
                }
            }));

        obj.registerMethod(obj.runtime.newJavaMethod("returns true if this set is empty, false otherwise", new TypeCheckingJavaMethod.WithNoArguments("empty?", runtime.set) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    return ((IokeSet)IokeObject.data(on)).getSet().isEmpty() ? context.runtime._true : context.runtime._false;
                }
            }));

        obj.registerMethod(obj.runtime.newJavaMethod("Adds the argument to this set, if it's not already in the set. Returns the set after adding the object.", new TypeCheckingJavaMethod("<<") {
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

        obj.registerMethod(obj.runtime.newJavaMethod("Removes the argument from the set, if it's in the set. Returns the set after removing the object.", new TypeCheckingJavaMethod("remove!") {
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

        obj.registerMethod(runtime.newJavaMethod("returns a new set that contains the receivers elements and the elements of the set sent in as the argument.", new TypeCheckingJavaMethod("+") {
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

        obj.registerMethod(obj.runtime.newJavaMethod("returns true if the receiver includes the evaluated argument, otherwise false", new TypeCheckingJavaMethod("include?") {
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

        obj.registerMethod(runtime.newJavaMethod("takes either one, two or three arguments. if one argument is given, it should be a message chain that will be sent to each object in the set. the result will be thrown away. if two arguments are given, the first is an unevaluated name that will be set to each of the values in the set in succession, and then the second argument will be evaluated in a scope with that argument in it. if three arguments is given, the first one is an unevaluated name that will be set to the index of each element, and the other two arguments are the name of the argument for the value, and the actual code. the code will evaluate in a lexical context, and if the argument name is available outside the context, it will be shadowed. the method will return the set. the iteration order is not defined.", new JavaMethod("each") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositionalUnevaluated("indexOrArgOrCode")
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
                    case 1: {
                        IokeObject code = IokeObject.as(message.getArguments().get(0), context);

                        for(Object o : set) {
                            code.evaluateCompleteWithReceiver(context, context.getRealContext(), o);
                        }
                        break;
                    }
                    case 2: {
                        LexicalContext c = new LexicalContext(context.runtime, context, "Lexical activation context for Set#each", message, context);
                        String name = IokeObject.as(message.getArguments().get(0), context).getName();
                        IokeObject code = IokeObject.as(message.getArguments().get(1), context);

                        for(Object o : set) {
                            c.setCell(name, o);
                            code.evaluateCompleteWithoutExplicitReceiver(c, c.getRealContext());
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
                            code.evaluateCompleteWithoutExplicitReceiver(c, c.getRealContext());
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
    public boolean isEqualTo(IokeObject self, Object other) {
        return ((other instanceof IokeObject) && 
                (IokeObject.data(other) instanceof IokeSet) 
                && this.set.equals(((IokeSet)IokeObject.data(other)).set));
    }

    @Override
    public int hashCode(IokeObject self) {
        return this.set.hashCode();
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
