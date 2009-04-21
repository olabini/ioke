
namespace NRegex {
    public interface Substitution {
        void AppendSubstitution(MatchResult match, TextBuffer dest);
    }
}
