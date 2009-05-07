
namespace Ioke.Lang {
    using System.IO;
    using System.Collections;

    using Ioke.Lang.Util;

    public class IokeIO : IokeData {
        protected TextWriter writer;
        protected TextReader reader;

        public IokeIO() : this(null, null){
        }

        public IokeIO(TextWriter writer) : this(null, writer) {
        }

        public IokeIO(TextReader reader) : this(reader, null) {
        }

        public IokeIO(TextReader reader, TextWriter writer) {
            this.reader = reader;
            this.writer = writer;
        }

        public static TextWriter GetWriter(object arg) {
            return ((IokeIO)IokeObject.dataOf(arg)).writer;
        }

        public static TextReader GetReader(object arg) {
            return ((IokeIO)IokeObject.dataOf(arg)).reader;
        }

        public override void Init(IokeObject obj) {
            Runtime runtime = obj.runtime;
            obj.Kind = "IO";

            obj.RegisterMethod(runtime.NewNativeMethod("Prints a text representation of the argument and a newline to the current IO object", 
                                                       new TypeCheckingNativeMethod("println", 
                                                                                    TypeCheckingArgumentsDefinition.builder()
                                                                                    .ReceiverMustMimic(runtime.Io)
                                                                                    .WithOptionalPositional("object", "nil")
                                                                                    .Arguments,
                                                                                    (self, on, args, keywords, context, message) => {
                                                                                        try {
                                                                                            if(args.Count > 0) {
                                                                                                IokeIO.GetWriter(on).Write(((Message)IokeObject.dataOf(context.runtime.asText)).SendTo(context.runtime.asText, context, args[0]).ToString());
                                                                                            }
                                                                                            
                                                                                            IokeIO.GetWriter(on).Write("\n");
                                                                                            IokeIO.GetWriter(on).Flush();
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

                                                                                        return context.runtime.nil;
                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("Prints a text representation of the argument to the current IO object", 
                                                       new TypeCheckingNativeMethod("print", 
                                                                                    TypeCheckingArgumentsDefinition.builder()
                                                                                    .ReceiverMustMimic(runtime.Io)
                                                                                    .WithRequiredPositional("object")
                                                                                    .Arguments,
                                                                                    (self, on, args, keywords, context, message) => {
                                                                                        try {
                                                                                            IokeIO.GetWriter(on).Write(((Message)IokeObject.dataOf(context.runtime.asText)).SendTo(context.runtime.asText, context, args[0]).ToString());
                                                                                            IokeIO.GetWriter(on).Flush();
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

                                                                                        return context.runtime.nil;
                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("tries to read as much as possible and return a message chain representing what's been read", 
                                                       new TypeCheckingNativeMethod.WithNoArguments("read", obj,
                                                                                                    (self, on, args, keywords, context, message) => {
                                                                                                        try {
                                                                                                            string line = IokeIO.GetReader(on).ReadLine();
                                                                                                            return Message.NewFromStream(context.runtime, new StringReader(line), message, context);
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

                                                                                                        return context.runtime.nil;
                                                                                                    })));
        }
    }
}
