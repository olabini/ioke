
namespace Ioke.Lang.Parser {
    using Ioke.Lang;

    public class Level {
        public enum Type {REGULAR, UNARY, ASSIGNMENT, INVERTED};

        readonly internal int precedence;
        readonly internal IokeObject operatorMessage;
        readonly internal Level parent;
        readonly internal Type type;

        internal Level(int precedence, IokeObject op, Level parent, Type type) {
            this.precedence = precedence;
            this.operatorMessage = op;
            this.parent = parent;
            this.type = type;
        }

        public override string ToString() {
            return "Level<" + precedence + ", " + operatorMessage + ", " + type + ", " + parent + ">";
        }
    }
}
