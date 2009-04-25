
namespace Ioke.Lang.Extensions.Readline {
    using Mono.Terminal;
    using System.Collections;
    using System.Collections.Generic;
    using System.IO;

    using Ioke.Lang.Util;

    public abstract class Readline {
        public class ConsoleHolder {
            public LineEditor readline;
            public History history;
        }

        protected static void InitReadline(Runtime runtime, ConsoleHolder holder) {
            holder.readline = new LineEditor("ioke");
            holder.readline.History = holder.history;
            holder.readline.UseHistory = false;
        }

        private Readline() {}

        public static IokeObject Create(Runtime runtime) {
            IokeObject rl = new IokeObject(runtime, "Readline is a module allows access to the readline native functionality");
            Readline.Init(rl);
            return rl;
        }

        public static void Init(IokeObject rl) {
            Runtime runtime = rl.runtime;
            rl.Kind = "Readline";
            rl.MimicsWithoutCheck(runtime.Origin);
            runtime.Ground.SetCell("Readline", rl);
            rl.SetCell("VERSION", runtime.NewText("Mono.Terminal.LineEditor wrapper"));

            ConsoleHolder holder = new ConsoleHolder();
            holder.history = new History("ioke", 10);

            IokeObject history = runtime.NewFromOrigin();
            rl.SetCell("HISTORY", history);
        
            rl.RegisterMethod(runtime.NewNativeMethod("will print a prompt to standard out and then try to read a line with working readline functionality. takes two arguments, the first is the string to prompt, the second is a boolean that says whether we should add the read string to history or not", 
                                                      new NativeMethod("readline", DefaultArgumentsDefinition.builder()
                                                                       .WithRequiredPositional("prompt")
                                                                       .WithRequiredPositional("addToHistory?")
                                                                       .Arguments,
                                                                       (method, context, message, on, outer) => {
                                                                           var args = new SaneArrayList();
                                                                           outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, args, new SaneDictionary<string, object>());
                                                                           object line = method.runtime.nil;
                                                                           try {
                                                                               if(holder.readline == null) {
                                                                                   InitReadline(method.runtime, holder);
                                                                               }
                                                                               string v = holder.readline.Edit(Text.GetText(args[0]), "");
                                                                               if(null != v) {
                                                                                   if(IokeObject.IsObjectTrue(args[1])) {
                                                                                       holder.history.Append(v);
                                                                                   }

                                                                                   line = method.runtime.NewText(v);
                                                                               }
                                                                           } catch(IOException e) {
                                                                               IokeObject condition = IokeObject.As(IokeObject.GetCellChain(runtime.Condition, 
                                                                                                                                            message, 
                                                                                                                                            context, 
                                                                                                                                            "Error", 
                                                                                                                                            "IO"), context).Mimic(message, context);
                                                                               condition.SetCell("message", message);
                                                                               condition.SetCell("context", context);
                                                                               condition.SetCell("receiver", on);
                                                                               condition.SetCell("exceptionMessage", runtime.NewText(e.Message));
                                                                               var st = new System.Diagnostics.StackTrace(e);
                                                                               var ob = new SaneArrayList();
                                                                               foreach(var frame in st.GetFrames()) {
                                                                                   ob.Add(runtime.NewText(frame.ToString()));
                                                                               }
                                                                               condition.SetCell("exceptionStackTrace", runtime.NewList(ob));

                                                                               runtime.WithReturningRestart("ignore", context, ()=>{runtime.ErrorCondition(condition);});
                                                                           }
                                                                           return line;
                                                                       })));

            history.RegisterMethod(runtime.NewNativeMethod("will add a new line to the history", 
                                                           new NativeMethod("<<", DefaultArgumentsDefinition.builder()
                                                                            .WithRequiredPositional("line")
                                                                            .Arguments,
                                                                            (method, context, message, on, outer) => {
                                                                                var args = new SaneArrayList();
                                                                                outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, args, new SaneDictionary<string, object>());
                                                                                foreach(object o in args) {
                                                                                    holder.history.Append(Text.GetText(o));
                                                                                }
                                                                                return context.runtime.nil;
                                                                            })));
        }
    }
}
