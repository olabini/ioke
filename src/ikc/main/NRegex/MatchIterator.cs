namespace NRegex {
    public interface MatchIterator {
        bool HasMore {
            get;
        }
        MatchResult NextMatch {
            get;
        }
        int Count {
            get;
        }
    }
}
