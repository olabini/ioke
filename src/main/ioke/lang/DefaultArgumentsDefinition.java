/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.Arrays;
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

    public static class UnevaluatedArgument extends Argument {
        private boolean required;
        public UnevaluatedArgument(String name, boolean required) {
            super(name);
            this.required = required;
        }
        public boolean isRequired() {
            return required;
        }
    }

    public static class OptionalArgument extends Argument {
        private Object defaultValue;

        public OptionalArgument(String name, Object defaultValue) {
            super(name);
            this.defaultValue = defaultValue;
        }

        public Object getDefaultValue() {
            return defaultValue;
        }
    }

    public static class KeywordArgument extends Argument {
        private Object defaultValue;

        public KeywordArgument(String name, Object defaultValue) {
            super(name);
            this.defaultValue = defaultValue;
        }

        public Object getDefaultValue() {
            return defaultValue;
        }
    }

    private final int min;
    private final int max;
    private final List<Argument> arguments;
    private final Collection<String> keywords;
    private final String rest;
    private final String krest;
    private final boolean restUneval;

    // unevaluated rest
    //  they should print themselves
    //  unevaluated: [foo]
    //  unevaluated krest: +[foo]

    private boolean hasUnevaluated = false;

    protected DefaultArgumentsDefinition(List<Argument> arguments, Collection<String> keywords, String rest, String krest, int min, int max, boolean restUneval) {
        this.arguments = arguments;
        this.keywords = keywords;
        this.rest = rest;
        this.krest = krest;
        this.min = min;
        this.max = max;
        this.restUneval = restUneval;

        hasUnevaluated = restUneval;

        for(Argument arg : arguments) {
            if(arg instanceof UnevaluatedArgument) {
                hasUnevaluated = true;
                break;
            }
        }
    }

    public Collection<String> getKeywords() {
        return keywords;
    }

    public List<Argument> getArguments() {
        return arguments;
    }

    public String getCode() {
        return getCode(true);
    }

    public String getCode(boolean lastComma) {
        boolean any = false;
        StringBuilder sb = new StringBuilder();
        for(Argument argument : arguments) {
            any = true;
            if(!(argument instanceof KeywordArgument)) {
                if(argument instanceof UnevaluatedArgument) {
                    sb.append("[").append(argument.getName()).append("]");
                    if(!((UnevaluatedArgument)argument).isRequired()) {
                        sb.append(" nil");
                    }
                } else {
                    sb.append(argument.getName());
                }
            } else {
                sb.append(argument.getName()).append(":");
            }

            if((argument instanceof OptionalArgument) && ((OptionalArgument)argument).getDefaultValue() != null) {
                sb.append(" ");
                Object defValue = ((OptionalArgument)argument).getDefaultValue();
                if(defValue instanceof String) {
                    sb.append(defValue);
                } else {
                    sb.append(Message.code(IokeObject.as(defValue, null)));
                }
            } else if((argument instanceof KeywordArgument) && ((KeywordArgument)argument).getDefaultValue() != null) {
                sb.append(" ");
                Object defValue = ((KeywordArgument)argument).getDefaultValue();
                if(defValue instanceof String) {
                    sb.append(defValue);
                } else {
                    sb.append(Message.code(IokeObject.as(defValue, null)));
                }
            }

            sb.append(", ");
        }

        if(rest != null) {
            any = true;
            if(restUneval) { 
                sb.append("+[").append(rest).append("], ");
            } else {
                sb.append("+").append(rest).append(", ");
            }
        }

        if(krest != null) {
            any = true;
            sb.append("+:").append(krest).append(", ");
        }

        if(!lastComma && any) {
            sb.delete(sb.length() - 2, sb.length());
        }

        return sb.toString();
    }

    public int checkArgumentCount(final IokeObject context, final IokeObject message, final Object on) throws ControlFlow {
        final Runtime runtime = context.runtime;
        final List<Object> arguments = message.getArguments();
        int argCount = arguments.size();

        int keySize = keywords.size();

        if(argCount < min || (max != -1 && argCount > (max+keySize))) {
            final int finalArgCount = argCount;
            if(argCount < min) {
                final IokeObject condition = IokeObject.as(IokeObject.getCellChain(runtime.condition, 
                                                                                   message, 
                                                                                   context, 
                                                                                   "Error", 
                                                                                   "Invocation", 
                                                                                   "TooFewArguments"), context).mimic(message, context);
                condition.setCell("message", message);
                condition.setCell("context", context);
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
                                                                                         "TooManyArguments"), context).mimic(message, context);
                            condition.setCell("message", message);
                            condition.setCell("context", context);
                            condition.setCell("receiver", on);
                            condition.setCell("extra", runtime.newList(arguments.subList(max, finalArgCount)));

                            runtime.errorCondition(condition);
                        }});

                argCount = max;
            }
        }
        return argCount;
    }

    public int getEvaluatedArguments(final IokeObject context, final IokeObject message, final Object on, final List<Object> argumentsWithoutKeywords, final Map<String, Object> givenKeywords) throws ControlFlow {
        final Runtime runtime = context.runtime;
        final List<Object> arguments = message.getArguments();
        int argCount = 0;

        for(Object o : arguments) {
            if(Message.isKeyword(o)) {
                givenKeywords.put(IokeObject.as(o, context).getName(), Message.getEvaluatedArgument(((Message)IokeObject.data(o)).next, context));
            } else if(Message.hasName(o, "*") && IokeObject.as(o, context).getArguments().size() == 1) { // Splat
                Object result = Message.getEvaluatedArgument(IokeObject.as(o, context).getArguments().get(0), context);
                if(IokeObject.data(result) instanceof IokeList) {
                    List<Object> elements = IokeList.getList(result);
                    argumentsWithoutKeywords.addAll(elements);
                    argCount += elements.size();
                } else if(IokeObject.data(result) instanceof Dict) {
                    Map<Object, Object> keys = Dict.getMap(result);
                    for(Map.Entry<Object, Object> me : keys.entrySet()) {
                        givenKeywords.put(Text.getText(IokeObject.convertToText(me.getKey(), message, context, true)) + ":", me.getValue());
                    }
                } else {
                    final IokeObject condition = IokeObject.as(IokeObject.getCellChain(runtime.condition, 
                                                                                       message, 
                                                                                       context, 
                                                                                       "Error", 
                                                                                       "Invocation", 
                                                                                       "NotSpreadable"), context).mimic(message, context);
                    condition.setCell("message", message);
                    condition.setCell("context", context);
                    condition.setCell("receiver", on);
                    condition.setCell("given", result);
                
                    List<Object> outp = IokeList.getList(runtime.withRestartReturningArguments(new RunnableWithControlFlow() {
                            public void run() throws ControlFlow {
                                runtime.errorCondition(condition);
                            }}, 
                            context,
                            new Restart.DefaultValuesGivingRestart("ignoreArgument", runtime.nil, 0),
                            new Restart.DefaultValuesGivingRestart("takeArgumentAsIs", IokeObject.as(result, context), 1)
                            ));

                    argumentsWithoutKeywords.addAll(outp);
                    argCount += outp.size();
                }
            } else {
                argumentsWithoutKeywords.add(Message.getEvaluatedArgument(o, context));
                argCount++;
            }
        }

        
        while(argCount < min || (max != -1 && argCount > max)) {
            final int finalArgCount = argCount;
            if(argCount < min) {
                final IokeObject condition = IokeObject.as(IokeObject.getCellChain(runtime.condition, 
                                                                             message, 
                                                                             context, 
                                                                             "Error", 
                                                                             "Invocation", 
                                                                             "TooFewArguments"), context).mimic(message, context);
                condition.setCell("message", message);
                condition.setCell("context", context);
                condition.setCell("receiver", on);
                condition.setCell("missing", runtime.newNumber(min-argCount));
                
                List<Object> newArguments = IokeList.getList(runtime.withRestartReturningArguments(new RunnableWithControlFlow() {
                        public void run() throws ControlFlow {
                            runtime.errorCondition(condition);
                        }}, 
                        context,
                        new Restart.ArgumentGivingRestart("provideExtraArguments") {
                            public List<String> getArgumentNames() {
                                return new ArrayList<String>(Arrays.asList("newArgument"));
                            }
                        },
                        new Restart.DefaultValuesGivingRestart("substituteNilArguments", runtime.nil, min-argCount) {
                            public List<String> getArgumentNames() {
                                return new ArrayList<String>();
                            }
                        }
                        ));

                argCount += newArguments.size();
                argumentsWithoutKeywords.addAll(newArguments);
             } else {
                runtime.withReturningRestart("ignoreExtraArguments", context, new RunnableWithControlFlow() {
                        public void run() throws ControlFlow {
                            IokeObject condition = IokeObject.as(IokeObject.getCellChain(runtime.condition, 
                                                                                         message, 
                                                                                         context, 
                                                                                         "Error", 
                                                                                         "Invocation", 
                                                                                         "TooManyArguments"), context).mimic(message, context);
                            condition.setCell("message", message);
                            condition.setCell("context", context);
                            condition.setCell("receiver", on);
                            condition.setCell("extra", runtime.newList(argumentsWithoutKeywords.subList(max, finalArgCount)));

                            runtime.errorCondition(condition);
                        }});
                argCount = max;
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
                                                                                     "MismatchedKeywords"), context).mimic(message, context);
                        condition.setCell("message", message);
                        condition.setCell("context", context);
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

        return argCount;
    }

    public void assignArgumentValues(final IokeObject locals, final IokeObject context, final IokeObject message, final Object on, final Call call) throws ControlFlow {
        if(call.cachedPositional != null) {
            assignArgumentValues(locals, context, message, on, call.cachedPositional, call.cachedKeywords, call.cachedArgCount);
        } else {
            final List<Object> argumentsWithoutKeywords = new ArrayList<Object>();
            final Map<String, Object> givenKeywords = new LinkedHashMap<String, Object>();
            final int argCount = getEvaluatedArguments(context, message, on, argumentsWithoutKeywords, givenKeywords);
            call.cachedPositional = argumentsWithoutKeywords;
            call.cachedKeywords = givenKeywords;
            call.cachedArgCount = argCount;
            assignArgumentValues(locals, context, message, on, argumentsWithoutKeywords, givenKeywords, argCount);
        }
    }

    public void assignArgumentValues(final IokeObject locals, final IokeObject context, final IokeObject message, final Object on) throws ControlFlow {
        final List<Object> argumentsWithoutKeywords = new ArrayList<Object>();
        final Map<String, Object> givenKeywords = new LinkedHashMap<String, Object>();
        final int argCount = getEvaluatedArguments(context, message, on, argumentsWithoutKeywords, givenKeywords);
        assignArgumentValues(locals, context, message, on, argumentsWithoutKeywords, givenKeywords, argCount);
    }

    private void assignArgumentValues(final IokeObject locals, final IokeObject context, final IokeObject message, final Object on, final List<Object> argumentsWithoutKeywords, final Map<String, Object> givenKeywords, final int argCount) throws ControlFlow {
        final Runtime runtime = context.runtime;

        final Set<String> intersection = new LinkedHashSet<String>(givenKeywords.keySet());
        intersection.removeAll(keywords);

        int ix = 0;
        for(int i=0, j=this.arguments.size();i<j;i++) {
            Argument a = this.arguments.get(i);
            
            if(a instanceof KeywordArgument) {
                Object given = givenKeywords.get(a.getName() + ":");
                Object result = null;
                if(given == null) {
                    Object defVal = ((KeywordArgument)a).getDefaultValue();
                    if(!(defVal instanceof String)) {
                        result = IokeObject.as(defVal, context).evaluateCompleteWithoutExplicitReceiver(locals, locals.getRealContext());
                        locals.setCell(a.getName(), result);
                    }
                } else {
                    result = given;
                    locals.setCell(a.getName(), result);
                }
            } else if((a instanceof OptionalArgument) && ix>=argCount) {
                Object defVal = ((OptionalArgument)a).getDefaultValue();
                if(!(defVal instanceof String)) {
                    locals.setCell(a.getName(), IokeObject.as(defVal, context).evaluateCompleteWithoutExplicitReceiver(locals, locals.getRealContext()));
                }
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
        return new DefaultArgumentsDefinition(new ArrayList<Argument>(), new ArrayList<String>(), null, null, 0, 0, false);
    }

    public static DefaultArgumentsDefinition createFrom(List<Object> args, int start, int len, final IokeObject message, final Object on, final IokeObject context) throws ControlFlow {
        final Runtime runtime = context.runtime;
        List<Argument> arguments = new ArrayList<Argument>();
        List<String> keywords = new ArrayList<String>();

        int min = 0;
        int max = 0;
        boolean hadOptional = false;
        String rest = null;
        String krest = null;

        for(Object obj : args.subList(start, args.size()-1)) {
            Message m = (Message)IokeObject.data(obj);
            String mname = m.getName(null);
            if(!"+:".equals(mname) && m.isKeyword()) {
                String name = mname;
                IokeObject dValue = context.runtime.nilMessage;
                if(m.next != null) {
                    dValue = m.next;
                }
                arguments.add(new KeywordArgument(name.substring(0, name.length()-1), dValue));
                keywords.add(name);
            } else if(mname.equals("+")) {
                String name = Message.name(m.getArguments(null).get(0));
                if(name.startsWith(":")) {
                    krest = name.substring(1);
                } else {
                    rest = name;
                    max = -1;
                }
                hadOptional = true;
            } else if(mname.equals("+:")) {
                String name = m.next != null ? Message.name(m.next) : Message.name(m.getArguments(null).get(0));
                krest = name;
                hadOptional = true;
            } else if(m.next != null) {
                String name = mname;
                hadOptional = true;
                if(max != -1) {
                    max++;
                }
                arguments.add(new OptionalArgument(name, m.next));
            } else {
                if(hadOptional) {
                    int index = args.indexOf(obj) + start;


                    final IokeObject condition = IokeObject.as(IokeObject.getCellChain(runtime.condition, 
                                                                                       message, 
                                                                                       context, 
                                                                                       "Error", 
                                                                                       "Invocation", 
                                                                                       "ArgumentWithoutDefaultValue"), context).mimic(message, context);
                    condition.setCell("message", message);
                    condition.setCell("context", context);
                    condition.setCell("receiver", on);
                    condition.setCell("argumentName", runtime.getSymbol(m.getName(null)));
                    condition.setCell("index", runtime.newNumber(index));
                
                    List<Object> newValue = IokeList.getList(runtime.withRestartReturningArguments(new RunnableWithControlFlow() {
                            public void run() throws ControlFlow {
                                runtime.errorCondition(condition);
                            }}, 
                        context,
                        // Maybe also provide an unevaluated message...
                            new Restart.ArgumentGivingRestart("provideDefaultValue") {
                                public List<String> getArgumentNames() {
                                    return new ArrayList<String>(Arrays.asList("defaultValue"));
                                }
                            },
                        new Restart.DefaultValuesGivingRestart("substituteNilDefault", runtime.nil, 1)
                            ));

                    if(max != -1) {
                        max++;
                    }

                    arguments.add(new OptionalArgument(m.getName(null), runtime.createMessage(Message.wrap(IokeObject.as(newValue.get(0), context)))));
                } else {
                    min++;
                    max++;
                    arguments.add(new Argument(IokeObject.as(obj, context).getName()));
                }
            }
        }

        return new DefaultArgumentsDefinition(arguments, keywords, rest, krest, min, max, false);
    }

    public static class Builder {
        protected int min = 0;
        protected int max = 0;
        protected List<Argument> arguments = new ArrayList<Argument>();
        protected Collection<String> keywords = new HashSet<String>();
        protected String rest = null;
        protected String krest = null;
        protected boolean restUneval = false;

        public Builder withRequiredPositionalUnevaluated(String name) {
            arguments.add(new UnevaluatedArgument(name, true));
            min++;
            if(max != -1) {
                max++;
            }

            return this;
        }

        public Builder withOptionalPositionalUnevaluated(String name) {
            arguments.add(new UnevaluatedArgument(name, false));
            if(max != -1) {
                max++;
            }

            return this;
        }

        public Builder withRestUnevaluated(String name) {
            rest = name;
            restUneval = true;
            max = -1;

            return this;
        }

        public Builder withRest(String name) {
            rest = name;
            max = -1;

            return this;
        }

        public Builder withKeywordRest(String name) {
            krest = name;

            return this;
        }

        public Builder withKeywordRestUnevaluated(String name) {
            krest = name;
            restUneval = true;

            return this;
        }

        public Builder withRequiredPositional(String name) {
            arguments.add(new Argument(name));
            min++;
            if(max != -1) {
                max++;
            }

            return this;
        }

        public Builder withKeyword(String name) {
            arguments.add(new KeywordArgument(name, "nil"));
            keywords.add(name + ":");

            return this;
        }

        public Builder withOptionalPositional(String name, String defaultValue) {
            arguments.add(new OptionalArgument(name, defaultValue));
            if(max != -1) {
                max++;
            }

            return this;
        }

        public DefaultArgumentsDefinition getArguments() {
            return new DefaultArgumentsDefinition(arguments, keywords, rest, krest, min, max, restUneval);
        }
    }

    public static Builder builder() {
        return new Builder();
    }
}// DefaultArgumentsDefinition
