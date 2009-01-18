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
                argumentsWithoutKeywords.set(ix, convertToMimic(mustMimic.get(i),
                        argumentsWithoutKeywords.get(ix), message,
                        context));
                ix++;
            }
        }

        return convertToMimic(receiverMustMimic, on, message, context);
    }

    public static class Builder extends DefaultArgumentsDefinition.Builder {
        private List<Object> mustMimic = new ArrayList<Object>();
        private Object receiverMustMimic;

        private boolean setMimic = true;

        private void next() {
            if (!setMimic)
                mustMimic.add(null);
            else
                setMimic = false;
        }

        public Builder whichMustMimic(Object mimic) {
            mustMimic.add(mimic);
            return this;
        }

        public Builder receiverMustMimic(Object mimic) {
            this.receiverMustMimic = mimic;
            return this;
        }

        @Override
        public Builder withKeyword(String name) {
            super.withKeyword(name);
            next();
            return this;
        }

        @Override
        public Builder withKeywordRest(String name) {
            super.withKeywordRest(name);
            next();
            return this;
        }

        @Override
        public Builder withOptionalPositional(String name, String defaultValue) {
            super.withOptionalPositional(name, defaultValue);
            next();
            return this;
        }

        @Override
        public Builder withOptionalPositionalUnevaluated(String name) {
            super.withOptionalPositionalUnevaluated(name);
            next();
            return this;
        }

        @Override
        public Builder withRequiredPositional(String name) {
            super.withRequiredPositional(name);
            next();
            return this;
        }

        @Override
        public Builder withRequiredPositionalUnevaluated(String name) {
            super.withRequiredPositionalUnevaluated(name);
            next();
            return this;
        }

        @Override
        public Builder withRest(String name) {
            super.withRest(name);
            next();
            return this;
        }

        @Override
        public Builder withRestUnevaluated(String name) {
            super.withRestUnevaluated(name);
            next();
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
