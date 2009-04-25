
namespace Ioke.Lang {
    public interface ITypeChecker {
        object ConvertToMimic(object on, IokeObject message, IokeObject context, bool signal);
    }

    public sealed class TypeChecker {
        private class NoneClass : ITypeChecker {
            public object ConvertToMimic(object on, IokeObject message, IokeObject context, bool signal) {
                return on;
            }
        }
        private class NilClass : ITypeChecker {
            public object ConvertToMimic(object on, IokeObject message, IokeObject context, bool signal) {
                if(on == context.runtime.nil) {
                    return on;
                } else if(signal) {
                    return context.runtime.nil.ConvertToThis(on, message, context);
                } else {
                    return context.runtime.nul;
                }
            }
        }

        public static readonly ITypeChecker None = new NoneClass();
        public static readonly ITypeChecker Nil = new NilClass();

        public class Or : ITypeChecker {
            public readonly ITypeChecker first;
            public readonly ITypeChecker second;
            public Or(ITypeChecker first, ITypeChecker second) {
                this.first = first;
                this.second = second;
            }

            public object ConvertToMimic(object on, IokeObject message, IokeObject context, bool signal) {
                object firstResult = first.ConvertToMimic(on, message, context, false);
                if(firstResult == context.runtime.nul) {
                    return second.ConvertToMimic(on, message, context, signal);
                } else {
                    return firstResult;
                }
            }
        }
    }
}
