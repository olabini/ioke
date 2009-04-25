
namespace Ioke.Lang.Parser {
    using Ioke.Lang;
    using System.Collections.Generic;

    public interface IOperatorShufflerFactory {
        IOperatorShuffler Create(IokeObject msg, IokeObject context, IokeObject message);
    }
    
    public interface IOperatorShuffler {
        void Attach(IokeObject msg, IList<IokeObject> expressions);
        void NextMessage(IList<IokeObject> expressions);
    }
}
