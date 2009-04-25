namespace Ioke.Lang {
    using System.Collections;
    using System.Collections.Generic;

    using Ioke.Lang.Util;

    public class Restart {
        public static void Init(IokeObject obj) {
            Runtime runtime = obj.runtime;
            obj.Kind = "Restart";

            obj.RegisterCell("name", runtime.nil);
            obj.RegisterCell("report", runtime.EvaluateString("fn(r, \"restart: \" + r name)", runtime.Message, runtime.Ground));
            obj.RegisterCell("test", runtime.EvaluateString("fn(c, true)", runtime.Message, runtime.Ground));
            obj.RegisterCell("code", runtime.EvaluateString("fn()", runtime.Message, runtime.Ground));
            obj.RegisterCell("argumentNames", runtime.EvaluateString("method(self code argumentNames)", runtime.Message, runtime.Ground));
        }

        public abstract class NativeRestart { 
            protected string name;
            public string Name {
                get { return name; }
            }

            public abstract IList<string> ArgumentNames { get; }
            
            public virtual string Report() {
                return null;
            }

            public abstract IokeObject Invoke(IokeObject context, IList arguments);
        }

        public abstract class ArgumentGivingRestart : NativeRestart {
            public ArgumentGivingRestart(string name) {
                this.name = name;
            }

            public override IokeObject Invoke(IokeObject context, IList arguments) {
                return context.runtime.NewList(arguments);
            }
        }

        public class DefaultValuesGivingRestart : NativeRestart {
            IokeObject value;
            int repeat;
            public DefaultValuesGivingRestart(string name, IokeObject value, int repeat) {
                this.name = name;
                this.value = value;
                this.repeat = repeat;
            }

            public override IList<string> ArgumentNames {
                get { return new SaneList<string>(); }
            }

            public override IokeObject Invoke(IokeObject context, IList arguments) {
                IList result = new SaneArrayList();
                for(int i=0; i<repeat; i++) {
                    result.Add(value);
                }
                return context.runtime.NewList(result);
            }
        }
    }
}
