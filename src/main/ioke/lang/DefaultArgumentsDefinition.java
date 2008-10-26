/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.HashSet;
import java.util.Map;
import java.util.HashMap;

import ioke.lang.exceptions.ControlFlow;
import ioke.lang.exceptions.MismatchedArgumentCount;
import ioke.lang.exceptions.MismatchedKeywords;
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

    public static class KeywordArgument extends Argument {
        private IokeObject defaultValue;

        public KeywordArgument(String name, IokeObject defaultValue) {
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
    private Set<String> keywords;

    private DefaultArgumentsDefinition(List<Argument> arguments, Set<String> keywords, int min, int max) {
        this.arguments = arguments;
        this.keywords = keywords;
        this.min = min;
        this.max = max;
    }

    public void assignArgumentValues(IokeObject locals, IokeObject context, IokeObject message, Object on) throws ControlFlow {
        List<Object> arguments = message.getArguments();
        List<Object> argumentsWithoutKeywords = new ArrayList<Object>();
        int argCount = 0;
        Map<String, IokeObject> givenKeywords = new HashMap<String, IokeObject>();
        
        for(Object o : arguments) {
            if(Message.isKeyword(o)) {
                givenKeywords.put(IokeObject.as(o).getName(), ((Message)IokeObject.data(o)).next);
            } else {
                argumentsWithoutKeywords.add(o);
                argCount++;
            }
        }
        
        if(argCount < min || argCount > max) {
            throw new MismatchedArgumentCount(message, "" + min + ".." + max, argCount, on, context);
        }

        Set<String> intersection = new HashSet<String>(givenKeywords.keySet());
        intersection.removeAll(keywords);

        if(!intersection.isEmpty()) {
            throw new MismatchedKeywords(message, keywords, intersection, on, context);
        }
        
        for(int i=0, ix=0, j=this.arguments.size();i<j;i++) {
            Argument a = this.arguments.get(i);
            
            if(a instanceof KeywordArgument) {
                IokeObject given = givenKeywords.get(a.getName() + ":");
                Object result = null;
                if(given == null) {
                    result = ((KeywordArgument)a).getDefaultValue().evaluateCompleteWithoutExplicitReceiver(locals, locals.getRealContext());
                } else {
                    result = Message.getEvaluatedArgument(given, context);
                }
                locals.setCell(a.getName(), result);
            } else if((a instanceof OptionalArgument) && ix>=argCount) {
                locals.setCell(a.getName(), ((OptionalArgument)a).getDefaultValue().evaluateCompleteWithoutExplicitReceiver(locals, locals.getRealContext()));
            } else {
                locals.setCell(a.getName(), Message.getEvaluatedArgument(argumentsWithoutKeywords.get(ix++), context));
            }
        }
    }

    public static DefaultArgumentsDefinition empty() {
        return new DefaultArgumentsDefinition(new ArrayList<Argument>(), new HashSet<String>(), 0, 0);
    }

    public static DefaultArgumentsDefinition createFrom(List<Object> args, int start, int len, IokeObject message, Object on, IokeObject context) {
        List<Argument> arguments = new ArrayList<Argument>();
        Set<String> keywords = new HashSet<String>();

        int min = 0;
        int max = 0;
        boolean hadOptional = false;

        for(Object obj : args.subList(start, args.size()-1)) {
            Message m = (Message)IokeObject.data(obj);
            if(m.isKeyword()) {
                String name = m.getName(null);
                IokeObject dValue = context.runtime.nilMessage;
                if(m.next != null) {
                    dValue = m.next;
                }
                arguments.add(new KeywordArgument(name.substring(0, name.length()-1), dValue));
                keywords.add(name);
            } else if(m.next != null) {
                String name = m.getName(null);
                hadOptional = true;
                max++;
                arguments.add(new OptionalArgument(name, m.next));
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

        return new DefaultArgumentsDefinition(arguments, keywords, min, max);
    }
}// DefaultArgumentsDefinition
