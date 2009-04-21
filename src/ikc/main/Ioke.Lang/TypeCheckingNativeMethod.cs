
namespace Ioke.Lang {
    using System.Collections;
    using System.Collections.Generic;

    using Ioke.Lang.Util;

    public class TypeCheckingNativeMethod : NativeMethod {
        public new class WithNoArguments : TypeCheckingNativeMethod {
            public WithNoArguments(string name, RawActivate activate) : base(name, TypeCheckingArgumentsDefinition.Empty(), activate) {}
            public WithNoArguments(string name, object mimic, RawActivate activate) : base(name, TypeCheckingArgumentsDefinition.EmptyButReceiverMustMimic(mimic), activate) {}
            public WithNoArguments(string name, object mimic, ArgsActivate activate) : base(name, TypeCheckingArgumentsDefinition.EmptyButReceiverMustMimic(mimic), activate) {}
        }
   
        public TypeCheckingNativeMethod(string name, TypeCheckingArgumentsDefinition arguments, ArgsActivate activate) : base(name, arguments, TypeCheckingRawActivate, activate) {}
        TypeCheckingNativeMethod(string name, TypeCheckingArgumentsDefinition arguments, RawActivate activate) : base(name, arguments, activate, null) {}

        private static object TypeCheckingRawActivate(IokeObject self, IokeObject context, IokeObject message, object on, NativeMethod outer) {
            IList args = new SaneArrayList();
            IDictionary<string, object> keywords = new SaneDictionary<string, object>();
            object receiver = ((TypeCheckingArgumentsDefinition)outer.ArgumentsDefinition).GetValidatedArgumentsAndReceiver(context, message, on, args, keywords);
            return outer.argsActivator(self, receiver, args, keywords, context, message);
        }
    }
}
