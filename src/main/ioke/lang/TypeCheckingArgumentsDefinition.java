package ioke.lang;

import ioke.lang.exceptions.ControlFlow;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Map;

public class TypeCheckingArgumentsDefinition extends DefaultArgumentsDefinition {
    private List<Object> mustMimic = new ArrayList<Object>();
    private Object receiverMustMimic;
    private List<Argument> arguments;

    private TypeCheckingArgumentsDefinition(List<Argument> arguments,
            Collection<String> keywords, String rest, String krest, int min,
            int max, boolean restUneval, List<Object> mustMimic,
            Object receiverMustMimic) {
        super(arguments, keywords, rest, krest, min, max, restUneval);
        this.arguments = arguments;
        this.mustMimic = mustMimic;
        this.receiverMustMimic = receiverMustMimic;
    }

    private Object convertToMimic(Object mimic, Object on, IokeObject message,
            IokeObject context) throws ControlFlow {
        if (mimic == null) {
            return on;
        } else {
            return IokeObject.as(mimic).convertToThis(on, message, context);
        }

    }

    public Object getValidatedArgumentsAndReceiver(IokeObject context,
            IokeObject message, Object on,
            List<Object> argumentsWithoutKeywords,
            Map<String, Object> givenKeywords) throws ControlFlow {

        getEvaluatedArguments(context, message, on,
                argumentsWithoutKeywords, givenKeywords);

        int ix = 0;
        for (int i = 0, j = this.arguments.size(); i < j; i++) {
            Argument a = this.arguments.get(i);

            if (a instanceof KeywordArgument) {
                String name = a.getName() + ":";
                Object given = givenKeywords.get(name);
                if (given != null) {
                    givenKeywords.put(name, convertToMimic(
                            mustMimic.get(i), given, message, context));
                }
            } else {
                if(ix < argumentsWithoutKeywords.size()) {
                    argumentsWithoutKeywords.set(ix, convertToMimic(mustMimic.get(i),
                                                                    argumentsWithoutKeywords.get(ix), message,
                                                                    context));
                    ix++;
                }
            }
        }

        return convertToMimic(receiverMustMimic, on, message, context);
    }

    public static TypeCheckingArgumentsDefinition empty() {
        return emptyButReceiverMustMimic(null);
    }

    public static TypeCheckingArgumentsDefinition emptyButReceiverMustMimic(Object mimic) {
        return new TypeCheckingArgumentsDefinition(new ArrayList<Argument>(), new ArrayList<String>(), null, null, 0, 0, false, new ArrayList<Object>(), mimic);
    }
    
    public static class Builder extends DefaultArgumentsDefinition.Builder {
        private List<Object> mustMimic = new ArrayList<Object>();
        private Object receiverMustMimic;

        private boolean setMimic = true;

        private void next() {
            if (!setMimic) {
                mustMimic.add(null);
            }
            setMimic = false;
        }

        public Builder whichMustMimic(Object mimic) {
            mustMimic.add(mimic);
            setMimic = true;
            return this;
        }

        public Builder receiverMustMimic(Object mimic) {
            this.receiverMustMimic = mimic;
            return this;
        }

        @Override
        public Builder withKeyword(String name) {
            next();
            super.withKeyword(name);
            return this;
        }

        @Override
        public Builder withKeywordRest(String name) {
            next();
            super.withKeywordRest(name);
            return this;
        }

        @Override
        public Builder withOptionalPositional(String name, String defaultValue) {
            next();
            super.withOptionalPositional(name, defaultValue);
            return this;
        }

        @Override
        public Builder withOptionalPositionalUnevaluated(String name) {
            next();
            super.withOptionalPositionalUnevaluated(name);
            return this;
        }

        @Override
        public Builder withRequiredPositional(String name) {
            next();
            super.withRequiredPositional(name);
            return this;
        }

        @Override
        public Builder withRequiredPositionalUnevaluated(String name) {
            next();
            super.withRequiredPositionalUnevaluated(name);
            return this;
        }

        @Override
        public Builder withRest(String name) {
            next();
            super.withRest(name);
            return this;
        }

        @Override
        public Builder withRestUnevaluated(String name) {
            next();
            super.withRestUnevaluated(name);
            return this;
        }

        @Override
        public TypeCheckingArgumentsDefinition getArguments() {
            next(); 
            return new TypeCheckingArgumentsDefinition(arguments, keywords,
                    rest, krest, min, max, restUneval, mustMimic,
                    receiverMustMimic);
        }
    }

    public static Builder builder() {
        return new Builder();
    }
}
