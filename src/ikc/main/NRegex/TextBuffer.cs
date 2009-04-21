
namespace NRegex {
    public interface TextBuffer {
        void Append(char c);
        void Append(char[] chars, int start, int len);
        void Append(string s);
    }
}
