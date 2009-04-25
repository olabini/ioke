namespace Ioke.Lang {
    using System.Collections;
    using System.Collections.Generic;

    using Ioke.Lang.Util;

    public class Ground {
        public static void Init(IokeObject iokeGround, IokeObject ground) {
            Runtime runtime = ground.runtime;
            iokeGround.Kind = "IokeGround";
            ground.Kind = "Ground";
            iokeGround.RegisterCell("Base", runtime.Base);
            iokeGround.RegisterCell("DefaultBehavior", runtime.DefaultBehavior);
            iokeGround.RegisterCell("IokeGround", runtime.IokeGround);
            iokeGround.RegisterCell("Ground", runtime.Ground);
            iokeGround.RegisterCell("Origin", runtime.Origin);
            iokeGround.RegisterCell("System", runtime.System);
            iokeGround.RegisterCell("Runtime", runtime._Runtime);
            iokeGround.RegisterCell("Text", runtime.Text);
            iokeGround.RegisterCell("Symbol", runtime.Symbol);
            iokeGround.RegisterCell("Number", runtime.Number);
            iokeGround.RegisterCell("nil", runtime.nil);
            iokeGround.RegisterCell("true", runtime.True);
            iokeGround.RegisterCell("false", runtime.False);
            iokeGround.RegisterCell("Arity", runtime.Arity);
            iokeGround.RegisterCell("Method", runtime.Method);
            iokeGround.RegisterCell("DefaultMethod", runtime.DefaultMethod);
            iokeGround.RegisterCell("NativeMethod", runtime.NativeMethod);
            iokeGround.RegisterCell("LexicalBlock", runtime.LexicalBlock);
            iokeGround.RegisterCell("DefaultMacro", runtime.DefaultMacro);
            iokeGround.RegisterCell("LexicalMacro", runtime.LexicalMacro);
            iokeGround.RegisterCell("DefaultSyntax", runtime.DefaultSyntax);
            iokeGround.RegisterCell("Mixins", runtime.Mixins);
            iokeGround.RegisterCell("Restart", runtime.Restart);
            iokeGround.RegisterCell("List", runtime.List);
            iokeGround.RegisterCell("Dict", runtime.Dict);
            iokeGround.RegisterCell("Set", runtime.Set);
            iokeGround.RegisterCell("Range", runtime.Range);
            iokeGround.RegisterCell("Pair", runtime.Pair);
            iokeGround.RegisterCell("DateTime", runtime.DateTime);
            iokeGround.RegisterCell("Message", runtime.Message);
            iokeGround.RegisterCell("Call", runtime.Call);
            iokeGround.RegisterCell("Condition", runtime.Condition);
            iokeGround.RegisterCell("Rescue", runtime.Rescue);
            iokeGround.RegisterCell("Handler", runtime.Handler);
            iokeGround.RegisterCell("IO", runtime.Io);
            iokeGround.RegisterCell("FileSystem", runtime.FileSystem);
            iokeGround.RegisterCell("Regexp", runtime.Regexp);

            iokeGround.RegisterMethod(runtime.NewNativeMethod("will return a text representation of the current stack trace", 
                                                              new NativeMethod.WithNoArguments("stackTraceAsText",
                                                                                               (method, context, message, on, outer) => {
                                                                                                   outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, new SaneArrayList(), new SaneDictionary<string, object>());
                                                                                                   return context.runtime.NewText("");
                                                                                               })));
        }
    }
}
