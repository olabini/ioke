namespace Ioke.Lang {
    using System.Collections;
    using System.Collections.Generic;

    public class Call : IokeData {
        IokeObject ctx;
        IokeObject message;
        IokeObject surroundingContext;
        IokeObject on;

        public IList cachedPositional;
        public IDictionary<string, object> cachedKeywords;
        public int cachedArgCount;

        public Call() {}

        public Call(IokeObject ctx, IokeObject message, IokeObject surroundingContext, IokeObject on) {
            this.ctx = ctx;
            this.message = message;
            this.surroundingContext = surroundingContext;
            this.on = on;
        }

        public override void Init(IokeObject obj) {
            Runtime runtime = obj.runtime;
            obj.Kind = "Call";

            obj.RegisterMethod(runtime.NewNativeMethod("takes one evaluated text or symbol argument and resends the current message to that method/macro on the current receiver.", 
                                                       new TypeCheckingNativeMethod("resendToMethod", TypeCheckingArgumentsDefinition.builder()
                                                                                    .ReceiverMustMimic(runtime.Call)
                                                                                    .WithRequiredPositional("cellName")
                                                                                    .Arguments,
                                                                                    (self, _on, args, keywords, context, _message) => {
                                                                                        Call c = (Call)IokeObject.dataOf(_on);
                                                                                        string name = Text.GetText(((Message)IokeObject.dataOf(runtime.asText)).SendTo(runtime.asText, context, args[0]));
                                                                                        IokeObject m = Message.Copy(c.message);
                                                                                        Message.SetName(m, name);
                                                                                        return ((Message)IokeObject.dataOf(m)).SendTo(m, c.surroundingContext, c.on);
                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("returns a list of all the unevaluated arguments", 
                                                       new TypeCheckingNativeMethod.WithNoArguments("arguments", 
                                                                                                    runtime.Call,
                                                                                                    (method, _on, args, keywords, context, _message) => {
                                                                                                        return context.runtime.NewList(((Call)IokeObject.dataOf(_on)).message.Arguments);
                                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("returns the ground of the place this call originated", 
                                                       new TypeCheckingNativeMethod.WithNoArguments("ground", 
                                                                                                    runtime.Call,
                                                                                                    (method, _on, args, keywords, context, _message) => {
                                                                                                        return ((Call)IokeObject.dataOf(_on)).surroundingContext;
                                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("returns the receiver of the call", 
                                                       new TypeCheckingNativeMethod.WithNoArguments("receiver", 
                                                                                                    runtime.Call,
                                                                                                    (method, _on, args, keywords, context, _message) => {
                                                                                                        return ((Call)IokeObject.dataOf(_on)).on;
                                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("returns the currently executing context", 
                                                       new TypeCheckingNativeMethod.WithNoArguments("currentContext", 
                                                                                                    runtime.Call,
                                                                                                    (method, _on, args, keywords, context, _message) => {
                                                                                                        return ((Call)IokeObject.dataOf(_on)).ctx;
                                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("returns the message that started this call", 
                                                       new TypeCheckingNativeMethod.WithNoArguments("message", 
                                                                                                    runtime.Call,
                                                                                                    (method, _on, args, keywords, context, _message) => {
                                                                                                        return ((Call)IokeObject.dataOf(_on)).message;
                                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("returns a list of the result of evaluating all the arguments to this call", 
                                                       new TypeCheckingNativeMethod.WithNoArguments("evaluatedArguments", 
                                                                                                    runtime.Call,
                                                                                                    (method, _on, args, keywords, context, _message) => {
                                                                                                        IokeObject msg = ((Call)IokeObject.dataOf(_on)).message;
                                                                                                        return context.runtime.NewList(((Message)IokeObject.dataOf(msg)).GetEvaluatedArguments(msg, ((Call)IokeObject.dataOf(_on)).surroundingContext));
                                                                                                    })));


            obj.RegisterMethod(runtime.NewNativeMethod("uhm. this is a strange one. really.", 
                                                       new TypeCheckingNativeMethod("resendToValue", TypeCheckingArgumentsDefinition.builder()
                                                                                    .ReceiverMustMimic(runtime.Call)
                                                                                    .WithRequiredPositional("value")
                                                                                    .WithOptionalPositional("newSelf", "nil")
                                                                                    .Arguments,
                                                                                    (method, _on, args, keywords, context, _message) => {
                                                                                        Call c = (Call)IokeObject.dataOf(_on);
                                                                                        object self = c.on;
                                                                                        if(args.Count > 1) {
                                                                                            self = args[1];
                                                                                        }

                                                                                        return IokeObject.GetOrActivate(args[0], c.surroundingContext, c.message, self);
                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("uhm. this one isn't too bad.", 
                                                       new TypeCheckingNativeMethod("activateValue", TypeCheckingArgumentsDefinition.builder()
                                                                                    .ReceiverMustMimic(runtime.Call)
                                                                                    .WithRequiredPositional("value")
                                                                                    .WithOptionalPositional("newSelf", "nil")
                                                                                    .WithKeywordRest("valuesToAdd")
                                                                                    .Arguments,
                                                                                    (method, _on, args, keys, context, _message) => {
                                                                                        Call c = (Call)IokeObject.dataOf(_on);
                                                                                        object self = c.on;
                                                                                        if(args.Count > 1) {
                                                                                            self = args[1];
                                                                                        }

                                                                                        return IokeObject.As(args[0], context).ActivateWithData(c.surroundingContext, c.message, self, keys);
                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("I really ought to write documentation for these methods, but I don't know how to describe what they do.", 
                                                       new TypeCheckingNativeMethod("activateValueWithCachedArguments", TypeCheckingArgumentsDefinition.builder()
                                                                                    .ReceiverMustMimic(runtime.Call)
                                                                                    .WithRequiredPositional("value")
                                                                                    .WithOptionalPositional("newSelf", "nil")
                                                                                    .WithKeywordRest("valuesToAdd")
                                                                                    .Arguments,
                                                                                    (method, _on, args, keys, context, _message) => {
                                                                                        Call c = (Call)IokeObject.dataOf(_on);
                                                                                        object self = c.on;
                                                                                        if(args.Count > 1) {
                                                                                            self = args[1];
                                                                                        }

                                                                                        return IokeObject.As(args[0], context).ActivateWithCallAndData(c.surroundingContext, c.message, self, _on, keys);
                                                                                    })));
        }

        public override IokeData CloneData(IokeObject obj, IokeObject m, IokeObject context) {
            return new Call(this.ctx, this.message, this.surroundingContext, this.on);
        }
    }
}
