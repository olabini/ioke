namespace Ioke.Lang {
    using Ioke.Lang.Util;

    using System.Text;

    public class Locals {
        public static void Init(IokeObject obj) {
            obj.Kind = "Locals";
            obj.GetMimics().Clear();

            obj.SetCell("=",         obj.runtime.Base.Cells["="]);
            var assgn = IokeObject.As(obj.runtime.DefaultBehavior.Cells["Assignment"], null).Cells;
            obj.SetCell("++",        assgn["++"]);
            obj.SetCell("--",        assgn["--"]);
            obj.SetCell("+=",        assgn["+="]);
            obj.SetCell("-=",        assgn["-="]);
            obj.SetCell("/=",        assgn["/="]);
            obj.SetCell("*=",        assgn["*="]);
            obj.SetCell("%=",        assgn["%="]);
            obj.SetCell("**=",       assgn["**="]);
            obj.SetCell("&=",        assgn["&="]);
            obj.SetCell("|=",        assgn["|="]);
            obj.SetCell("^=",        assgn["^="]);
            obj.SetCell("<<=",       assgn["<<="]);
            obj.SetCell(">>=",       assgn[">>="]);
            obj.SetCell("&&=",       assgn["&&="]);
            obj.SetCell("||=",       assgn["||="]);
            obj.SetCell("cell",         obj.runtime.Base.Cells["cell"]);
            obj.SetCell("cell=",         obj.runtime.Base.Cells["cell="]);
            obj.SetCell("cells",         obj.runtime.Base.Cells["cells"]);
            obj.SetCell("cellNames",         obj.runtime.Base.Cells["cellNames"]);
            obj.SetCell("removeCell!",         obj.runtime.Base.Cells["removeCell!"]);
            obj.SetCell("undefineCell!",         obj.runtime.Base.Cells["undefineCell!"]);
            obj.SetCell("cellOwner?",         obj.runtime.Base.Cells["cellOwner?"]);
            obj.SetCell("cellOwner",         obj.runtime.Base.Cells["cellOwner"]);
            obj.SetCell("identity",         obj.runtime.Base.Cells["identity"]);

            obj.RegisterMethod(obj.runtime.NewNativeMethod("will pass along the call to the real self object of this context.",
                                                           new NativeMethod("pass", DefaultArgumentsDefinition.builder()
                                                                            .WithRestUnevaluated("arguments")
                                                                            .Arguments,
                                                                            (method, context, message, on, outer) => {
                                                                                object selfDelegate = IokeObject.As(on, context).Self;
                                                                                if(selfDelegate != null && selfDelegate != on) {
                                                                                    return IokeObject.Perform(selfDelegate, context, message);
                                                                                }
                                                                                return context.runtime.nil;
                                                                            })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("will return a text representation of the current stack trace",
                                                           new NativeMethod.WithNoArguments("stackTraceAsText",
                                                                                            (method, context, m, on, outer) => {
                                                                                                outer.ArgumentsDefinition.CheckArgumentCount(context, m, on);
                                                                                                Runtime runtime = context.runtime;
                                                                                                StringBuilder sb = new StringBuilder();

                                                                                                IokeObject current = IokeObject.As(on, context);
                                                                                                while("Locals".Equals(current.GetKind(m, context))) {
                                                                                                    IokeObject message = IokeObject.As(IokeObject.GetCell(current, m, context, "currentMessage"), context);
                                                                                                    IokeObject start = message;

                                                                                                    while(Message.GetPrev(start) != null && Message.GetPrev(start).Line == message.Line) {
                                                                                                        start = Message.GetPrev(start);
                                                                                                    }

                                                                                                    string s1 = Message.Code(start);

                                                                                                    int ix = s1.IndexOf("\n");
                                                                                                    if(ix > -1) {
                                                                                                        ix--;
                                                                                                    }

                                                                                                    sb.Append(string.Format(" {0,-48} {1}\n",
                                                                                                                            (ix == -1 ? s1 : s1.Substring(0,ix)),
                                                                                                                            "[" + message.File + ":" + message.Line + ":" + message.Position + GetContextMessageName(IokeObject.As(current.Cells["surroundingContext"], context)) + "]"));


                                                                                                    current = IokeObject.As(IokeObject.FindCell(current, m, context, "surroundingContext"), context);
                                                                                                }

                                                                                                return runtime.NewText(sb.ToString());
                                                                                            })));
        }

        public static string GetContextMessageName(IokeObject ctx) {
            if("Locals".Equals(ctx.GetKind())) {
                return ":in `" + IokeObject.As(ctx.Cells["currentMessage"], ctx).Name + "'";
            } else {
                return "";
            }
        }
    }
}
