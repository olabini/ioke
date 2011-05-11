
namespace Ioke.Lang {
    using System.Collections;

    public class LexicalContext : IokeData {
        public object ground;

        public IokeObject surroundingContext;

        public LexicalContext(object ground, IokeObject surroundingContext){
            this.ground = IokeObject.GetRealContext(ground);
            this.surroundingContext = surroundingContext;
        }

        public override string ToString(IokeObject self) {
            return "LexicalContext:" + System.Runtime.CompilerServices.RuntimeHelpers.GetHashCode(self);
        }
    }
}
