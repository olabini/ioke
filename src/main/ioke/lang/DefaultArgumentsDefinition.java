/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.ArrayList;
import java.util.List;

import ioke.lang.exceptions.ControlFlow;
import ioke.lang.exceptions.MismatchedArgumentCount;
import ioke.lang.exceptions.ArgumentWithoutDefaultValue;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class DefaultArgumentsDefinition {
    public static class Argument {
        private String name;
        public Argument(String name) {
            this.name = name;
        }
        public String getName() {
            return name;
        }
    }

    public static class OptionalArgument extends Argument {
        private IokeObject defaultValue;

        public OptionalArgument(String name, IokeObject defaultValue) {
            super(name);
            this.defaultValue = defaultValue;
        }

        public IokeObject getDefaultValue() {
            return defaultValue;
        }
    }

    private int min;
    private int max;
    private List<Argument> arguments;

    private DefaultArgumentsDefinition(List<Argument> arguments, int min, int max) {
        this.arguments = arguments;
        this.min = min;
        this.max = max;
    }

    public void assignArgumentValues(IokeObject locals, IokeObject context, IokeObject message, Object on) throws ControlFlow {
        int argCount = message.getArguments().size();
        if(argCount < min || argCount > max) {
            throw new MismatchedArgumentCount(message, "" + min + ".." + max, argCount, on, context);
        }
        
        for(int i=0, j=arguments.size();i<j;i++) {
            Argument a = arguments.get(i);

            if(i<argCount) {
                locals.setCell(a.getName(), message.getEvaluatedArgument(i, context));
            } else {
                locals.setCell(a.getName(), ((OptionalArgument)a).getDefaultValue().evaluateCompleteWithoutExplicitReceiver(locals, locals.getRealContext()));
            }
        }
    }

    public static DefaultArgumentsDefinition empty() {
        return new DefaultArgumentsDefinition(new ArrayList<Argument>(), 0, 0);
    }

    public static DefaultArgumentsDefinition createFrom(List<Object> args, int start, int len, IokeObject message, Object on, IokeObject context) {
        List<Argument> arguments = new ArrayList<Argument>();
        int min = 0;
        int max = 0;
        boolean hadOptional = false;

        for(Object obj : args.subList(start, args.size()-1)) {
            Message m = (Message)IokeObject.data(obj);
            if(m.next != null) {
                hadOptional = true;
                max++;
                arguments.add(new OptionalArgument(IokeObject.as(obj).getName(), m.next));
            } else {
                if(hadOptional) {
                    int index = args.indexOf(obj) + start;
                    throw new ArgumentWithoutDefaultValue(message, index, on, context);
                }

                min++;
                max++;
                arguments.add(new Argument(IokeObject.as(obj).getName()));
            }
        }

        return new DefaultArgumentsDefinition(arguments, min, max);
    }
}// DefaultArgumentsDefinition
