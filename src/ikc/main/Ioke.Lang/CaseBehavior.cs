
namespace Ioke.Lang {
    public class CaseBehavior {

        public static IokeObject TransformWhenStatement(object when, IokeObject context, IokeObject message, IokeObject caseMimic) {
            string outerName = Message.GetName(when);

            if(caseMimic.body.Has("case:" + outerName)) {
                IokeObject cp = Message.DeepCopy(when);
                ReplaceAllCaseNames(cp, context, message, caseMimic);
                return cp;
            }

            return IokeObject.As(when, context);
        }

        private static void ReplaceAllCaseNames(IokeObject when, IokeObject context, IokeObject message, IokeObject caseMimic) {
            string theName = "case:" + Message.GetName(when);
            if(caseMimic.body.Has(theName)) {
                Message.SetName(when, theName);

                foreach(object arg in when.Arguments) {
                    ReplaceAllCaseNames(IokeObject.As(arg, context), context, message, caseMimic);
                }
            }
        }

        public static void Init(IokeObject obj) {
            obj.Kind = "DefaultBehavior Case";

            obj.RegisterMethod(obj.runtime.NewNativeMethod("takes one argument that should evaluate to a value, zero or more whenAndThen pairs and one optional else clause. will first evaluate the initial value, then check each whenAndThen pair against this value. if the when part of a pair returns true, then return the result of evaluating the then part. if no pair matches and no else clause is present, returns nil. if an else clause is there, it should be the last one. each whenAndThen pair is comprised of two arguments, where the first is the when argument and the second is the then argument. the when part will be evaluated and the result of this evaluation will be sent a === message with the value as argument.",
                                                           new NativeMethod("case", DefaultArgumentsDefinition.builder()
                                                                            .WithRequiredPositional("value")
                                                                            .WithRestUnevaluated("whensAndThens")
                                                                            .WithOptionalPositionalUnevaluated("elseCode")
                                                                            .Arguments,
                                                                            (method, context, message, on, outer) => {
                                                                                outer.ArgumentsDefinition.CheckArgumentCount(context, message, on);
                                                                                Runtime runtime = context.runtime;

                                                                                var args = message.Arguments;
                                                                                int argCount = args.Count;
                                                                                int index = 0;
                                                                                IokeObject msg = IokeObject.As(args[index++], context);
                                                                                object value = runtime.interpreter.Evaluate(msg, context, context.RealContext, context);
                                                                                argCount--;

                                                                                while(argCount > 1) {
                                                                                    msg = TransformWhenStatement(args[index++], context, message, obj);
                                                                                    object when = runtime.interpreter.Evaluate(msg, context, context.RealContext, context);
                                                                                    if(IokeObject.IsObjectTrue(Interpreter.Send(runtime.eqqMessage, context, when, value))) {
                                                                                        msg = IokeObject.As(args[index++], context);
                                                                                        return runtime.interpreter.Evaluate(msg, context, context.RealContext, context);
                                                                                    } else {
                                                                                        index++;
                                                                                    }
                                                                                    argCount -= 2;
                                                                                }

                                                                                if(argCount == 1) {
                                                                                    msg = IokeObject.As(args[index++], context);
                                                                                    return runtime.interpreter.Evaluate(msg, context, context.RealContext, context);
                                                                                }

                                                                                return runtime.nil;
                                                                            })));
        }
    }
}
