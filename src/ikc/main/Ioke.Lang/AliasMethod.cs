namespace Ioke.Lang {
    public class AliasMethod : IokeData, Named, Inspectable, AssociatedCode  {
        string name;
        IokeData realMethod;
        IokeObject realSelf;

        public AliasMethod(string name, IokeData realMethod, IokeObject realSelf) {
            this.name = name;
            this.realMethod = realMethod;
            this.realSelf = realSelf;
        }

        public string Name {
            get { return name; }
            set { this.name = value; }
        }

        public string Inspect(object self) {
            return ((Inspectable)realMethod).Inspect(realSelf);
        }

        public string Notice(object self) {
            return ((Inspectable)realMethod).Notice(realSelf);
        }

        public IokeObject Code {
            get { return ((AssociatedCode)realMethod).Code; }
        }

        public string CodeString {
            get {
                if(realMethod is Method) {
                    return ((Method)realMethod).CodeString;
                } else if(realMethod is DefaultMacro) {
                    return ((DefaultMacro)realMethod).CodeString;
                } else {
                    return ((AliasMethod)realMethod).CodeString;
                }
            }
        }
    
        public string ArgumentsCode {
            get {
                if(realMethod is AssociatedCode) {
                    return ((AssociatedCode)realMethod).ArgumentsCode;
                }
                return "...";
            }
        }

        public string FormattedCode(object self) {
            if(realMethod is AssociatedCode) {
                return ((AssociatedCode)realMethod).FormattedCode(self);
            }
            return "";
        }

        public override object Activate(IokeObject self, IokeObject context, IokeObject message, object on) {
            return realMethod.Activate(realSelf, context, message, on);
        }
    }
}
