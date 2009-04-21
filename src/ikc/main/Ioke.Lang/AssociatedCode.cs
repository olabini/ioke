namespace Ioke.Lang {
    public interface AssociatedCode {
        IokeObject Code { get; }
        string ArgumentsCode { get; }
        string FormattedCode(object self);
    }
}
