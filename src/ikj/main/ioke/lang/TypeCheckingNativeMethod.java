package ioke.lang;

import ioke.lang.exceptions.ControlFlow;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public abstract class TypeCheckingNativeMethod extends NativeMethod {
    public static class WithNoArguments extends TypeCheckingNativeMethod {
        private TypeCheckingArgumentsDefinition ARGUMENTS;

        public WithNoArguments(String name) {
            super(name);
            ARGUMENTS = TypeCheckingArgumentsDefinition.empty();
        }

        public WithNoArguments(String name, Object mimic) {
            super(name);
            ARGUMENTS = TypeCheckingArgumentsDefinition.emptyButReceiverMustMimic(mimic);
        }

        @Override
        public TypeCheckingArgumentsDefinition getArguments() {
            return ARGUMENTS;
        }
    }
   
    public TypeCheckingNativeMethod(String name) {
        super(name);
    }

    @Override
    public abstract TypeCheckingArgumentsDefinition getArguments();

    public Object activate(IokeObject self, Object on, List<Object> args,
            Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
        return super.activate(self, context, message, on);
    }

    @Override
    public Object activate(IokeObject self, IokeObject context,
            IokeObject message, Object on) throws ControlFlow {
        List<Object> args = new ArrayList<Object>();
        Map<String, Object> keywords = new HashMap<String, Object>();
        Object receiver = getArguments().getValidatedArgumentsAndReceiver(
                context, message, on, args, keywords);

        return activate(self, receiver, args, keywords, context, message);
    }
}
