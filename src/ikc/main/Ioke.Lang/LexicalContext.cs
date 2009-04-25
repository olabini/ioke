
namespace Ioke.Lang {
    using System.Collections;

    public class LexicalContext : IokeObject {
        object ground;

        public IokeObject message;
        public IokeObject surroundingContext;

        public LexicalContext(Runtime runtime, object ground, string documentation, IokeObject message, IokeObject surroundingContext) : base(runtime, documentation) {
            this.ground = IokeObject.GetRealContext(ground);
            this.message = message;
            this.surroundingContext = surroundingContext;

            Kind = "LexicalContext";
        }
    
        public override void Init() {
        }

        public override object RealContext {
            get { return ground; }
        }

        public override object Self {
            get { return surroundingContext.Self; }
        }

        public override void Assign(string name, object value, IokeObject context, IokeObject message) {
            object place = FindPlace(name);
            if(place == runtime.nul) {
                place = this;
            }
            IokeObject.SetCell(place, name, value, context);
        }

        protected override object FindPlace(string name, IDictionary visited) {
            object nn = base.FindPlace(name, visited);
            if(nn == runtime.nul) {
                return IokeObject.FindPlace(surroundingContext, name, visited);
            } else {
                return nn;
            }
        }

        public override object FindSuperCell(IokeObject early, IokeObject message, IokeObject context, string name, bool[] found, IDictionary visited) {
            object nn = base.FindSuperCell(early, message, context, name, found, visited);
            if(nn == runtime.nul) {
                return IokeObject.FindSuperCellOn(surroundingContext, early, message, context, name);
            } else {
                return nn;
            }
        }

        public override object FindCell(IokeObject m, IokeObject context, string name, IDictionary visited) {
            object nn = base.FindCell(m, context, name, visited);
        
            if(nn == runtime.nul) {
                return IokeObject.FindCell(surroundingContext, m, context, name, visited);
            } else {
                return nn;
            }
        }

        public override string ToString() {
            return "LexicalContext:" + System.Runtime.CompilerServices.RuntimeHelpers.GetHashCode(this);
        }
    }
}
