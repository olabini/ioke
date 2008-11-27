/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.HashSet;
import java.util.Set;

import ioke.lang.exceptions.ControlFlow;

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
        obj.mimics(IokeObject.as(runtime.mixins.getCell(null, null, "Enumerable")), runtime.nul, runtime.nul);

        obj.registerMethod(runtime.newJavaMethod("takes either one, two or three arguments. if one argument is given, it should be a message chain that will be sent to each object in the set. the result will be thrown away. if two arguments are given, the first is an unevaluated name that will be set to each of the values in the set in succession, and then the second argument will be evaluated in a scope with that argument in it. if three arguments is given, the first one is an unevaluated name that will be set to the index of each element, and the other two arguments are the name of the argument for the value, and the actual code. the code will evaluate in a lexical context, and if the argument name is available outside the context, it will be shadowed. the method will return the set. the iteration order is not defined.", new JavaMethod("each") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    Set<Object> set = ((IokeSet)IokeObject.data(on)).set;
                    switch(message.getArgumentCount()) {
                    case 1: {
                        IokeObject code = IokeObject.as(message.getArguments().get(0));

                        for(Object o : set) {
                            code.evaluateCompleteWithReceiver(context, context.getRealContext(), o);
                        }
                        break;
                    }
                    case 2: {
                        LexicalContext c = new LexicalContext(context.runtime, context, "Lexical activation context for Set#each", message, context);
                        String name = IokeObject.as(message.getArguments().get(0)).getName();
                        IokeObject code = IokeObject.as(message.getArguments().get(1));

                        for(Object o : set) {
                            c.setCell(name, o);
                            code.evaluateCompleteWithoutExplicitReceiver(c, c.getRealContext());
                        }
                        break;
                    }
                    case 3: {
                        LexicalContext c = new LexicalContext(context.runtime, context, "Lexical activation context for Set#each", message, context);
                        String iname = IokeObject.as(message.getArguments().get(0)).getName();
                        String name = IokeObject.as(message.getArguments().get(1)).getName();
                        IokeObject code = IokeObject.as(message.getArguments().get(2));

                        int index = 0;
                        for(Object o : set) {
                            c.setCell(name, o);
                            c.setCell(iname, runtime.newNumber(index++));
                            code.evaluateCompleteWithoutExplicitReceiver(c, c.getRealContext());
                        }
                        break;
                    }
                    }

                    return on;
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
    public String toString() {
        return set.toString();
    }

    @Override
    public String toString(IokeObject obj) {
        return set.toString();
    }
}// IokeSet
