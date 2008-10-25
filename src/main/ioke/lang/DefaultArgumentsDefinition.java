/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.ArrayList;
import java.util.List;

import ioke.lang.exceptions.ControlFlow;
import ioke.lang.exceptions.MismatchedArgumentCount;

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

    private List<Argument> arguments;
    private DefaultArgumentsDefinition(List<Argument> arguments) {
        this.arguments = arguments;
    }

    public void assignArgumentValues(IokeObject locals, IokeObject context, IokeObject message, Object on) throws ControlFlow {
        int argCount = message.getArguments().size();
        if(argCount != arguments.size()) {
            throw new MismatchedArgumentCount(message, arguments.size(), argCount, on, context);
        }
        
        for(int i=0;i<argCount;i++) {
            locals.setCell(arguments.get(i).getName(), message.getEvaluatedArgument(i, context));
        }
    }

    public static DefaultArgumentsDefinition empty() {
        return new DefaultArgumentsDefinition(new ArrayList<Argument>());
    }

    public static DefaultArgumentsDefinition createFrom(List<Object> args, int start, int len) {
        List<Argument> arguments = new ArrayList<Argument>();

        for(Object obj : args.subList(start, args.size()-1)) {
            arguments.add(new Argument(((IokeObject)obj).getName()));
        }

        return new DefaultArgumentsDefinition(arguments);
    }
}// DefaultArgumentsDefinition
