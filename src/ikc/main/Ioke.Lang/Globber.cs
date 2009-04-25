
namespace Ioke.Lang {
    using System.Collections.Generic;

    public interface Globber {
        IList<string> PushGlob(string cwd, string globstring, int flags);
    }
}
