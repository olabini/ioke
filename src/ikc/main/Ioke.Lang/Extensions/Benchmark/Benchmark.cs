
namespace Ioke.Lang.Extensions.Benchmark {
    using Ioke.Lang;

    public abstract class Benchmark {
        public static IokeObject Create(Runtime runtime) {
            IokeObject bm = new IokeObject(runtime, "Benchmark is a module that makes it easy to test the time code takes to run");
            Init(bm);
            return bm;
        }

        public static void Init(IokeObject bm) {
            Runtime runtime = bm.runtime;
            bm.Kind = "Benchmark";
            runtime.Ground.SetCell("Benchmark", bm);
            bm.MimicsWithoutCheck(runtime.Origin);

            bm.RegisterMethod(runtime.NewNativeMethod("expects two optional numbers, x (default 10) and y (default 1), and a block of code to run, and will run benchmark this block x times, while looping y times in each benchmark. after each loop will print the timings for this loop", 
                                                      new NativeMethod("report", DefaultArgumentsDefinition.builder()
                                                                       .WithOptionalPositional("repetitions", "10")
                                                                       .WithOptionalPositional("loops", "1")
                                                                       .WithRequiredPositionalUnevaluated("code")
                                                                       .Arguments,
                                                                       (method, context, message, on, outer) => {
                                                                           outer.ArgumentsDefinition.CheckArgumentCount(context, message, on);
                                                                           int count = message.Arguments.Count;
                                                                           int bmRounds = 10;
                                                                           long iterations = 1;
                                                                           int index = 0;
                                                                           if(count > 1) {
                                                                               bmRounds = ((Number)IokeObject.dataOf(IokeObject.ConvertToNumber(((Message)IokeObject.dataOf(message)).GetEvaluatedArgument(message, index, context), message, context))).AsNativeInteger();
                                                                               index++;
                                                                               if(count > 2) {
                                                                                   iterations = ((Number)IokeObject.dataOf(IokeObject.ConvertToNumber(((Message)IokeObject.dataOf(message)).GetEvaluatedArgument(message, index, context), message, context))).AsNativeLong();
                                                                                   index++;
                                                                               }
                                                                           }

                                                                           for(int i=0;i<bmRounds;i++) {
                                                                               long before = System.DateTime.Now.Ticks;
                                                                               for(int j=0;j<iterations;j++) {
                                                                                   ((Message)IokeObject.dataOf(message)).GetEvaluatedArgument(message, index, context);
                                                                               }
                                                                               long after = System.DateTime.Now.Ticks;
                                                                               long time = after-before;
                                                                               long secs = time/10000000;
                                                                               long rest = time%10000000;

                                                                               string theCode = Message.ThisCode(((IokeObject)message.Arguments[index]));

                                                                               ((Message)IokeObject.dataOf(context.runtime.printlnMessage)).SendTo(context.runtime.printlnMessage, context, ((Message)IokeObject.dataOf(context.runtime.outMessage)).SendTo(context.runtime.outMessage, context, context.runtime.System), context.runtime.NewText(string.Format("{0,-32} {1:d6}.{2:d9}", theCode, secs, rest)));
                                                                           }

                                                                           return context.runtime.nil;
                                                                       })));
        }
    }
}
