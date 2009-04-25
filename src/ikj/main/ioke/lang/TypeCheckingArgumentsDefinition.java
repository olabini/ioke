package ioke.lang;

import ioke.lang.exceptions.ControlFlow;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Map;

public class TypeCheckingArgumentsDefinition extends DefaultArgumentsDefinition {
    private List<TypeChecker> mustMimic;
    private TypeChecker receiverMustMimic;
    private List<Argument> arguments;

    private TypeCheckingArgumentsDefinition(List<Argument> arguments,
            Collection<String> keywords, String rest, String krest, int min,
            int max, boolean restUneval, List<TypeChecker> mustMimic,
            TypeChecker receiverMustMimic) {
        super(arguments, keywords, rest, krest, min, max, restUneval);
        this.arguments = arguments;
        this.mustMimic = mustMimic;
        this.receiverMustMimic = receiverMustMimic;
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
                    givenKeywords.put(name, mustMimic.get(0).convertToMimic(given, message, context, true));
                }
            } else {
                if(ix < argumentsWithoutKeywords.size()) {
                    argumentsWithoutKeywords.set(ix, mustMimic.
                                                 get(i).
                                                 convertToMimic(argumentsWithoutKeywords.get(ix), 
                                                                message, context, true));
                    ix++;
                }
            }
        }

        return receiverMustMimic.convertToMimic(on, message, context, true);
    }

    public static TypeCheckingArgumentsDefinition empty() {
        return new TypeCheckingArgumentsDefinition(new ArrayList<Argument>(), new ArrayList<String>(), null, null, 0, 0, false, new ArrayList<TypeChecker>(), TypeChecker.None);
    }

    public static TypeCheckingArgumentsDefinition emptyButReceiverMustMimic(Object mimic) {
        return new TypeCheckingArgumentsDefinition(new ArrayList<Argument>(), new ArrayList<String>(), null, null, 0, 0, false, new ArrayList<TypeChecker>(), (IokeObject)mimic);
    }
    
    public static class Builder extends DefaultArgumentsDefinition.Builder {
        public static class OrNil {
            public final Object realKind;
            public OrNil(Object realKind) {
                this.realKind = realKind;
            }
        }

        private List<TypeChecker> mustMimic = new ArrayList<TypeChecker>();
        private TypeChecker receiverMustMimic = TypeChecker.None;

        private boolean setMimic = true;

        private void next() {
            if (!setMimic) {
                mustMimic.add(TypeChecker.None);
            }
            setMimic = false;
        }

        public Builder whichMustMimic(IokeObject mimic) {
            mustMimic.add(mimic);
            setMimic = true;
            return this;
        }

        public Builder or(IokeObject mimic) {
            int ix = mustMimic.size() - 1;
            mustMimic.set(ix, new TypeChecker.Or(mustMimic.get(ix), mimic));
            return this;
        }

        public Builder orBeNil() {
            int ix = mustMimic.size() - 1;
            mustMimic.set(ix, new TypeChecker.Or(mustMimic.get(ix), TypeChecker.Nil));
            return this;
        }

        public Builder receiverMustMimic(IokeObject mimic) {
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
