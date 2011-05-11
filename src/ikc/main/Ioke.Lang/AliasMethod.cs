namespace Ioke.Lang {
    public class AliasMethod : IokeData, Named, Inspectable, AssociatedCode  {
        string name;
        IokeData realMethod;
        IokeObject realSelf;

        public AliasMethod(string name, IokeData realMethod, IokeObject realSelf) : base(IokeData.TYPE_ALIAS_METHOD) {
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

        public new static object ActivateFixed(IokeObject self, IokeObject ctx, IokeObject message, object obj) {
            AliasMethod am = (AliasMethod)self.data;
            IokeObject realSelf = am.realSelf;
            switch(am.realMethod.type) {
            case IokeData.TYPE_DEFAULT_METHOD:
                return DefaultMethod.ActivateFixed(realSelf, ctx, message, obj);
            case IokeData.TYPE_DEFAULT_MACRO:
                return DefaultMacro.ActivateFixed(realSelf, ctx, message, obj);
            case IokeData.TYPE_DEFAULT_SYNTAX:
                return DefaultSyntax.ActivateFixed(realSelf, ctx, message, obj);
            case IokeData.TYPE_LEXICAL_MACRO:
                return LexicalMacro.ActivateFixed(realSelf, ctx, message, obj);
            case IokeData.TYPE_NATIVE_METHOD:
                return NativeMethod.ActivateFixed(realSelf, ctx, message, obj);
            case IokeData.TYPE_METHOD_PROTOTYPE:
                return Method.ActivateFixed(realSelf, ctx, message, obj);
            case IokeData.TYPE_LEXICAL_BLOCK:
                return LexicalBlock.ActivateFixed(realSelf, ctx, message, obj);
            case IokeData.TYPE_ALIAS_METHOD:
                return AliasMethod.ActivateFixed(realSelf, ctx, message, obj);
            case IokeData.TYPE_NONE:
            default:
                return IokeData.ActivateFixed(realSelf, ctx, message, obj);
            }
        }
    }
}
