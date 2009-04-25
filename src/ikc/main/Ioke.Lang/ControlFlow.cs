
namespace Ioke.Lang {
    using System.Collections;

    public class ControlFlow : System.Exception {
        public class Exit : ControlFlow {
            int exitValue = 1;
            public Exit() : base(null) {}
            public Exit(object reason) : base(reason, "OH NO, exit out of place, because of: " + reason) {}
            public Exit(int value) : base(null) {
                this.exitValue = value;
            }
            public Exit(object reason, int value) : base(reason, "OH NO, exit out of place, because of: " + reason) {
                this.exitValue = value;
            }
            public int ExitValue {
                get { return exitValue; }
            }
        }

        public class Break : ControlFlow {
            public Break(object value) : base(value) {
            }
        }

        public class Continue : ControlFlow {
            public Continue() : base(null) {
            }
        }

        public class Return : ControlFlow {
            public readonly object context;
            public Return(object value, object context) : base(value) {
                this.context = context;
            }
        }

        public class Restart : ControlFlow {
            IList arguments;
            public Restart(Runtime.RestartInfo value, IList arguments) : base(value) {
                this.arguments = arguments;
            }

            public Runtime.RestartInfo GetRestart {
                get { return (Runtime.RestartInfo)Value; }
            }

            public IList Arguments {
                get { return this.arguments; }
            }
        }

        public class Rescue : ControlFlow {
            IokeObject condition;
            public Rescue(Runtime.RescueInfo value, IokeObject condition) : base(value) {
                this.condition = condition;
            }

            public Runtime.RescueInfo GetRescue {
                get { return (Runtime.RescueInfo)Value; }
            }

            public IokeObject Condition {
                get { return this.condition; }
            }

            public override string ToString() {
                return "rescue: " + Value.ToString();
            }
        }

        private object value;

        public ControlFlow(object value) {
            this.value = value;
        }

        public ControlFlow(object value, string message) : base(message) {
            this.value = value;
        }

        public object Value {
            get { return value; }
        }
    }
}
