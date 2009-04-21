namespace Ioke.Lang {
    public abstract class Builtin {
        public class Delegate : Builtin {
            public delegate object LoadDelegate (Runtime runtime, IokeObject context, IokeObject message);
            
            LoadDelegate ld;
            public Delegate(LoadDelegate ld) {
                this.ld = ld;
            }

            public override object Load(Runtime runtime, IokeObject context, IokeObject message) {
                return ld(runtime, context, message);
            }
        }

        public abstract object Load(Runtime runtime, IokeObject context, IokeObject message);
    }
}
