
namespace Ioke.Lang {
    public class CaseBehavior {

        public static IokeObject TransformWhenStatement(object when, IokeObject context, IokeObject message, IokeObject caseMimic) {
            string outerName = Message.GetName(when);

            if(caseMimic.Cells.ContainsKey("case:" + outerName)) {
                IokeObject cp = Message.DeepCopy(when);
                ReplaceAllCaseNames(cp, context, message, caseMimic);
                return cp;
            } 

            return IokeObject.As(when, context);
        }

        private static void ReplaceAllCaseNames(IokeObject when, IokeObject context, IokeObject message, IokeObject caseMimic) {
            string theName = "case:" + Message.GetName(when);
            if(caseMimic.Cells.ContainsKey(theName)) {
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
                                                                                object value = ((Message)IokeObject.dataOf(msg)).EvaluateCompleteWithoutExplicitReceiver(msg, context, context.RealContext);
                                                                                argCount--;

                                                                                while(argCount > 1) {
                                                                                    msg = TransformWhenStatement(args[index++], context, message, obj);
                                                                                    object when = ((Message)IokeObject.dataOf(msg)).EvaluateCompleteWithoutExplicitReceiver(msg, context, context.RealContext);
                                                                                    if(IokeObject.IsObjectTrue(((Message)IokeObject.dataOf(runtime.eqqMessage)).SendTo(runtime.eqqMessage, context, when, value))) {
                                                                                        msg = IokeObject.As(args[index++], context);
                                                                                        return ((Message)IokeObject.dataOf(msg)).EvaluateCompleteWithoutExplicitReceiver(msg, context, context.RealContext);
                                                                                    } else {
                                                                                        index++;
                                                                                    }
                                                                                    argCount -= 2;
                                                                                }

                                                                                if(argCount == 1) {
                                                                                    msg = IokeObject.As(args[index++], context);
                                                                                    return ((Message)IokeObject.dataOf(msg)).EvaluateCompleteWithoutExplicitReceiver(msg, context, context.RealContext);
                                                                                }

                                                                                return runtime.nil;
                                                                            })));
        }
    }
}
