
namespace Ioke.Lang {
    public class NullObject : IokeObject {
        public NullObject(Runtime runtime) : base(runtime, "Null object - only to be used internally by the implementation") {
        }

        public override bool IsActivatable {
            get { return false; }
        }

        public override bool IsTrue {
            get { return false; }
        }
    }
}
