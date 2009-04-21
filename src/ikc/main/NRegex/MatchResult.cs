
namespace NRegex {
    using System.Text;

    public interface MatchResult {
        Pattern Pattern { get; }

        int GroupCount { get; }

        bool IsCaptured();
        bool IsCaptured(int groupId);
        bool IsCaptured(string groupName);

        string Group(int n);
        bool Group(int n, StringBuilder sb);
        bool Group(int n, TextBuffer tb);

        string Prefix { get; }
        string Suffix { get; }
        string Target { get; }

        int TargetStart { get; }
        int TargetEnd { get; }
        char[] TargetChars { get; }

        int Start { get; }
        int End { get; }
        int Length { get; }

        int GetStart(int n);
        int GetEnd(int n);
        int GetLength(int n);
   
        char CharAt(int i);
        char CharAt(int i, int groupNo);
    }
}
