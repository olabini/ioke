namespace Ioke.Lang {
    public class Origin {
        public static void Init(IokeObject obj) {
            Runtime runtime = obj.runtime;
            obj.Kind = "Origin";

            obj.RegisterMethod(runtime.NewNativeMethod("Prints a text representation and a newline to standard output", new NativeMethod.WithNoArguments("println", (method, context, message, on, outer) => {
                            ((Message)IokeObject.dataOf(runtime.printlnMessage)).SendTo(runtime.printlnMessage, context, ((Message)IokeObject.dataOf(runtime.outMessage)).SendTo(runtime.outMessage, context, runtime.System), on);
                            return runtime.nil;
                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("Prints a text representation to standard output", new NativeMethod.WithNoArguments("print", (method, context, message, on, outer) => {
                            ((Message)IokeObject.dataOf(runtime.printMessage)).SendTo(runtime.printMessage, context, ((Message)IokeObject.dataOf(runtime.outMessage)).SendTo(runtime.outMessage, context, runtime.System), on);
                            return runtime.nil;
                        })));
        }
    }
}
