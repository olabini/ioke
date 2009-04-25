
namespace Ioke.Lang {
    using System.Collections;
    using System.Collections.Generic;

    using Ioke.Lang.Util;

    public class NativeMethod : Method {
        public delegate object RawActivate (IokeObject method, IokeObject context, IokeObject message, object on, NativeMethod outer);
        public delegate object ArgsActivate (IokeObject self, object on, IList args, IDictionary<string, object> keywords, IokeObject context, IokeObject message);

        protected RawActivate rawActivator;
        public ArgsActivate argsActivator = NoActivator;
        protected DefaultArgumentsDefinition arguments;

        public class WithNoArguments : NativeMethod {
            public WithNoArguments(string name, RawActivate activate) : base(name, DefaultArgumentsDefinition.Empty(), activate) {}
        }

        public NativeMethod(string name) : this(name, null, ArgumentActivator, NoActivator) {}
        public NativeMethod(string name, DefaultArgumentsDefinition arguments, RawActivate activate) : this(name, arguments, activate, NoActivator) {}
        public NativeMethod(string name, DefaultArgumentsDefinition arguments, ArgsActivate activate) : this(name, arguments, ArgumentActivator, activate) {}
        public NativeMethod(string name, DefaultArgumentsDefinition arguments, RawActivate activate, ArgsActivate argsActivate) : base(name) {
            this.arguments = arguments;
            if(activate == null) {
                this.rawActivator = ArgumentActivator;
            } else {
                this.rawActivator = activate;
            }

            if(argsActivate == null) {
                this.argsActivator = NoActivator;
            } else {
                this.argsActivator = argsActivate;
            }
        }

        public DefaultArgumentsDefinition ArgumentsDefinition {
            get { return arguments; }
        }

        public override void Init(IokeObject obj) {
            obj.Kind = "NativeMethod";
        }

        public override object Activate(IokeObject self, IokeObject context, IokeObject message, object on) {
            return rawActivator(self, context, message, on, this);
        }

        private static object ArgumentActivator(IokeObject self, IokeObject context, IokeObject message, object on, NativeMethod outer) {
            IList args = new SaneArrayList();
            IDictionary<string, object> keywords = new SaneDictionary<string, object>();
            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, args, keywords);
            return outer.argsActivator(self, on, args, keywords, context, message);
        }

        private static object NoActivator(IokeObject self, object on, IList args, IDictionary<string, object> keywords, IokeObject context, IokeObject message) {
            IokeObject condition = IokeObject.As(IokeObject.GetCellChain(context.runtime.Condition, 
                                                                         message, 
                                                                         context, 
                                                                         "Error", 
                                                                         "Invocation",
                                                                         "NotActivatable"), context).Mimic(message, context);
        
            condition.SetCell("message", message);
            condition.SetCell("context", context);
            condition.SetCell("receiver", on);
            condition.SetCell("method", self);
            condition.SetCell("report", context.runtime.NewText("You tried to activate a method without any code - did you by any chance activate the JavaMethod kind by referring to it without wrapping it inside a call to cell?"));
            context.runtime.ErrorCondition(condition);
            return self.runtime.nil;
        }
    }
}
