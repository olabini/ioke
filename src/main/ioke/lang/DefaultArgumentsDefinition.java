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
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.Collection;

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
    private Collection<String> keywords;
    private String rest = null;
    private String krest = null;

    private DefaultArgumentsDefinition(List<Argument> arguments, Collection<String> keywords, String rest, String krest, int min, int max) {
        this.arguments = arguments;
        this.keywords = keywords;
        this.rest = rest;
        this.krest = krest;
        this.min = min;
        this.max = max;
    }

    public Collection<String> getKeywords() {
        return keywords;
    }

    public String getCode() {
        StringBuilder sb = new StringBuilder();
        for(Argument argument : arguments) {
            if(!(argument instanceof KeywordArgument)) {
                sb.append(argument.getName());
            } else {
                sb.append(argument.getName()).append(":");
            }

            if((argument instanceof OptionalArgument) && ((OptionalArgument)argument).getDefaultValue() != null) {
                sb.append(" ");
                sb.append(Message.code(((OptionalArgument)argument).getDefaultValue()));
            } else if((argument instanceof KeywordArgument) && ((KeywordArgument)argument).getDefaultValue() != null) {
                sb.append(" ");
                sb.append(Message.code(((KeywordArgument)argument).getDefaultValue()));
            }

            sb.append(", ");
        }

        if(rest != null) {
            sb.append("+").append(rest).append(", ");
        }

        if(krest != null) {
            sb.append("+:").append(krest).append(", ");
        }

        return sb.toString();
    }

    public static void getEvaluatedArguments(IokeObject message, IokeObject context, List<Object> posArgs, Map<String, Object> keyArgs) throws ControlFlow {
        List<Object> arguments = message.getArguments();

        for(Object o : arguments) {
            if(Message.isKeyword(o)) {
                String name = IokeObject.as(o).getName();

                keyArgs.put(name.substring(0, name.length()-1), Message.getEvaluatedArgument(((Message)IokeObject.data(o)).next, context));
            } else if(Message.hasName(o, "*") && IokeObject.as(o).getArguments().size() == 1) { // Splat
                Object result = Message.getEvaluatedArgument(IokeObject.as(o).getArguments().get(0), context);
                if(IokeObject.data(result) instanceof IokeList) {
                    List<Object> elements = IokeList.getList(result);
                    posArgs.addAll(elements);
                } else if(IokeObject.data(result) instanceof Dict) {
                    Map<Object, Object> keys = Dict.getMap(result);
                    for(Map.Entry<Object, Object> me : keys.entrySet()) {
                        String name = Text.getText(IokeObject.convertToText(me.getKey(), message, context));
                        keyArgs.put(name, me.getValue());
                    }
                } else {
                    throw new RuntimeException("Asked to splat " + result + " which is nether a List nor a Dict. Buhu on you!");
                }
            } else {
                posArgs.add(Message.getEvaluatedArgument(o, context));
            }
        }
    }

    public void assignArgumentValues(final IokeObject locals, final IokeObject context, final IokeObject message, final Object on) throws ControlFlow {
        final Runtime runtime = context.runtime;
        List<Object> arguments = message.getArguments();
        final List<Object> argumentsWithoutKeywords = new ArrayList<Object>();
        int argCount = 0;
        Map<String, Object> givenKeywords = new LinkedHashMap<String, Object>();
        
        for(Object o : arguments) {
            if(Message.isKeyword(o)) {
                givenKeywords.put(IokeObject.as(o).getName(), Message.getEvaluatedArgument(((Message)IokeObject.data(o)).next, context));
            } else if(Message.hasName(o, "*") && IokeObject.as(o).getArguments().size() == 1) { // Splat
                Object result = Message.getEvaluatedArgument(IokeObject.as(o).getArguments().get(0), context);
                if(IokeObject.data(result) instanceof IokeList) {
                    List<Object> elements = IokeList.getList(result);
                    argumentsWithoutKeywords.addAll(elements);
                    argCount += elements.size();
                } else if(IokeObject.data(result) instanceof Dict) {
                    Map<Object, Object> keys = Dict.getMap(result);
                    for(Map.Entry<Object, Object> me : keys.entrySet()) {
                        givenKeywords.put(Text.getText(IokeObject.convertToText(me.getKey(), message, context)) + ":", me.getValue());
                    }
                } else {
                    throw new RuntimeException("Asked to splat " + result + " which is nether a List nor a Dict. Buhu on you!");
                }
            } else {
                argumentsWithoutKeywords.add(Message.getEvaluatedArgument(o, context));
                argCount++;
            }
        }

        final int finalArgCount = argCount;
        
        if(argCount < min || (max != -1 && argCount > max)) {
            if(argCount < min) {
                // TODO Make it possible to add new arguments at a reader
                IokeObject condition = IokeObject.as(IokeObject.getCellChain(runtime.condition, 
                                                                             message, 
                                                                             context, 
                                                                             "Error", 
                                                                             "Invocation", 
                                                                             "TooFewArguments")).mimic(message, context);
                condition.setCell("message", message);
                condition.setCell("context", locals);
                condition.setCell("receiver", on);
                condition.setCell("missing", runtime.newNumber(min-argCount));

                runtime.errorCondition(condition);
            } else {
                runtime.withReturningRestart("ignoreExtraArguments", context, new RunnableWithControlFlow() {
                        public void run() throws ControlFlow {
                            IokeObject condition = IokeObject.as(IokeObject.getCellChain(runtime.condition, 
                                                                                         message, 
                                                                                         context, 
                                                                                         "Error", 
                                                                                         "Invocation", 
                                                                                         "TooManyArguments")).mimic(message, context);
                            condition.setCell("message", message);
                            condition.setCell("context", locals);
                            condition.setCell("receiver", on);
                            condition.setCell("extra", runtime.newList(argumentsWithoutKeywords.subList(max, finalArgCount)));

                            runtime.errorCondition(condition);
                        }});
            }
        }

        final Set<String> intersection = new LinkedHashSet<String>(givenKeywords.keySet());
        intersection.removeAll(keywords);

        if(krest == null && !intersection.isEmpty()) {
            runtime.withReturningRestart("ignoreExtraKeywords", context, new RunnableWithControlFlow() {
                    public void run() throws ControlFlow {
                        IokeObject condition = IokeObject.as(IokeObject.getCellChain(runtime.condition, 
                                                                                     message, 
                                                                                     context, 
                                                                                     "Error", 
                                                                                     "Invocation", 
                                                                                     "MismatchedKeywords")).mimic(message, context);
                        condition.setCell("message", message);
                        condition.setCell("context", locals);
                        condition.setCell("receiver", on);

                        List<Object> expected = new ArrayList<Object>();
                        for(String s : keywords) {
                            expected.add(runtime.newText(s));
                        }

                        condition.setCell("expected", runtime.newList(expected));

                        List<Object> extra = new ArrayList<Object>();
                        for(String s : intersection) {
                            extra.add(runtime.newText(s));
                        }
                        condition.setCell("extra", runtime.newList(extra));

                        runtime.errorCondition(condition);
                    }});
        }

        int ix = 0;
        for(int i=0, j=this.arguments.size();i<j;i++) {
            Argument a = this.arguments.get(i);
            
            if(a instanceof KeywordArgument) {
                Object given = givenKeywords.get(a.getName() + ":");
                Object result = null;
                if(given == null) {
                    result = ((KeywordArgument)a).getDefaultValue().evaluateCompleteWithoutExplicitReceiver(locals, locals.getRealContext());
                } else {
                    result = given;
                }
                locals.setCell(a.getName(), result);
            } else if((a instanceof OptionalArgument) && ix>=argCount) {
                locals.setCell(a.getName(), ((OptionalArgument)a).getDefaultValue().evaluateCompleteWithoutExplicitReceiver(locals, locals.getRealContext()));
            } else {
                locals.setCell(a.getName(), argumentsWithoutKeywords.get(ix++));
            }
        }

        if(krest != null) {
            Map<Object, Object> krests = new LinkedHashMap<Object, Object>();
            for(String s : intersection) {
                Object given = givenKeywords.get(s);
                Object result = given;
                krests.put(runtime.getSymbol(s.substring(0, s.length()-1)), result);
            }
            
            locals.setCell(krest, runtime.newDict(krests));
        }

        if(rest != null) {
            List<Object> rests = new ArrayList<Object>();
            for(int j=argumentsWithoutKeywords.size();ix<j;ix++) {
                rests.add(argumentsWithoutKeywords.get(ix));
            }

            locals.setCell(rest, runtime.newList(rests));
        }
    }

    public static DefaultArgumentsDefinition empty() {
        return new DefaultArgumentsDefinition(new ArrayList<Argument>(), new ArrayList<String>(), null, null, 0, 0);
    }

    public static DefaultArgumentsDefinition createFrom(List<Object> args, int start, int len, IokeObject message, Object on, IokeObject context) {
        List<Argument> arguments = new ArrayList<Argument>();
        List<String> keywords = new ArrayList<String>();

        int min = 0;
        int max = 0;
        boolean hadOptional = false;
        String rest = null;
        String krest = null;

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
            } else if(m.getName(null).equals("+")) {
                String name = Message.name(m.getArguments(null).get(0));
                if(name.startsWith(":")) {
                    krest = name.substring(1);
                } else {
                    rest = name;
                    max = -1;
                }
                hadOptional = true;
            } else if(m.next != null) {
                String name = m.getName(null);
                hadOptional = true;
                if(max != -1) {
                    max++;
                }
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

        return new DefaultArgumentsDefinition(arguments, keywords, rest, krest, min, max);
    }
}// DefaultArgumentsDefinition
