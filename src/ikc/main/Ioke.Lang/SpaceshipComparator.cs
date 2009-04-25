
namespace Ioke.Lang {
    using System.Collections;
    using System.Collections.Generic;

    public class SpaceshipComparator : IComparer, IComparer<object> {
        IokeObject context;
        IokeObject message;

        public SpaceshipComparator(IokeObject context, IokeObject message) {
            this.context = context;
            this.message = message;
        }

        public int Compare(object one, object two) {
            Runtime runtime = context.runtime;
            return Number.ExtractInt(((Message)IokeObject.dataOf(runtime.spaceShipMessage)).SendTo(runtime.spaceShipMessage, context, one, two), message, context);
        }
    }
}
