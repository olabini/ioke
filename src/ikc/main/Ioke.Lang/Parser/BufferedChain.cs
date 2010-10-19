
namespace Ioke.Lang.Parser {
    using Ioke.Lang;

    public sealed class BufferedChain {
        readonly internal BufferedChain parent;
        readonly internal IokeObject last;
        readonly internal IokeObject head;

        internal BufferedChain(BufferedChain parent, IokeObject last, IokeObject head) {
            this.parent = parent;
            this.last = last;
            this.head = head;
        }
    }
}
