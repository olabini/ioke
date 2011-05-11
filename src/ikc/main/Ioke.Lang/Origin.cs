namespace Ioke.Lang {
    public class Origin {
        public static void Init(IokeObject obj) {
            Runtime runtime = obj.runtime;
            obj.Kind = "Origin";

            obj.RegisterMethod(runtime.NewNativeMethod("Prints a text representation and a newline to standard output", new NativeMethod.WithNoArguments("println", (method, context, message, on, outer) => {
                            Interpreter.Send(runtime.printlnMessage, context, Interpreter.Send(runtime.outMessage, context, runtime.System), on);
                            return runtime.nil;
                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("Prints a text representation to standard output", new NativeMethod.WithNoArguments("print", (method, context, message, on, outer) => {
                            Interpreter.Send(runtime.printMessage, context, Interpreter.Send(runtime.outMessage, context, runtime.System), on);
                            return runtime.nil;
                        })));
        }
    }
}
