namespace Ioke.Lang {
    public interface AssociatedCode : CanRun {
        IokeObject Code { get; }
        string ArgumentsCode { get; }
        string FormattedCode(object self);
    }
}
