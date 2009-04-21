namespace Ioke.Lang.Util {
    using System;
    using System.Text;
    
    public class StringUtils {
        public string ReplaceEscapes(string s) {
            if(s.IndexOf('\\') == -1) {
                if(Ioke.Lang.IokeSystem.DOSISH) {
                    return s.Replace("\r\n","\n");
                } else {
                    return s;
                }
            }
            int len = s.Length;
            StringBuilder result = new StringBuilder();
            if(Ioke.Lang.IokeSystem.DOSISH) {
                for(int i=0;i<len;i++) {
                    char c = s[i];

                    if(c == '\r'&& (i+1<len) && s[i+1] == '\n') {
                        result.Append('\n');
                        i++;
                    } else if(c != '\\') {
                        result.Append(c);
                    } else {
                        switch(s[++i]) {
                        case '\n':
                            // escaped newline means nothing.
                            break;
                        case '\r':
                            if(i+1<len && s[i+1] == '\n') {
                                i++;
                            }
                            // escaped newline means nothing.
                            break;
                        case '\\':
                            result.Append(c);
                            break;
                        case 'f':
                            result.Append('\f');
                            break;
                        case 'r':
                            result.Append('\r');
                            break;
                        case 'n':
                            result.Append('\n');
                            break;
                        case 't':
                            result.Append('\t');
                            break;
                        case 'b':
                            result.Append('\u0008');
                            break;
                        case 'e':
                            result.Append((char)27);
                            break;
                        case '"':
                            result.Append('"');
                            break;
                        case ']':
                            result.Append(']');
                            break;
                        case '#':
                            result.Append('#');
                            break;
                        case 'u':
                            result.Append((char)int.Parse(s.Substring(i+1, 4), System.Globalization.NumberStyles.AllowHexSpecifier));
                            i+=4;
                            break;
                        case '0':
                        case '1':
                        case '2':
                        case '3':
                        case '4':
                        case '5':
                        case '6':
                        case '7': {
                            int clen = 1;
                            char cx = ((i+1)<len) ? s[i+1] : (char)0;
                            if(cx >= '0' && cx <= '7') {
                                clen++;
                            }
                            cx = ((i+2)<len) ? s[i+2] : (char)0;
                            if(cx >= '0' && cx <= '7') {
                                clen++;
                            }
                            result.Append(OctalToChar(s.Substring(i, clen)));
                            i+=(clen-1);
                            break;
                        }
                        default:
                            // Shouldn't happen, but this is a reasonable default
                            result.Append(s[i]);
                            break;
                        }
                    }
                }
            } else {
                for(int i=0;i<len;i++) {
                    char c = s[i];
                    if(c != '\\') {
                        result.Append(c);
                    } else {
                        switch(s[++i]) {
                        case '\n':
                            // escaped newline means nothing.
                            break;
                        case '\r':
                            if(i+1<len && s[i+1] == '\n') {
                                i++;
                            }
                            // escaped newline means nothing.
                            break;
                        case '\\':
                            result.Append(c);
                            break;
                        case 'f':
                            result.Append('\f');
                            break;
                        case 'r':
                            result.Append('\r');
                            break;
                        case 'n':
                            result.Append('\n');
                            break;
                        case 't':
                            result.Append('\t');
                            break;
                        case 'b':
                            result.Append('\u0008');
                            break;
                        case 'e':
                            result.Append((char)27);
                            break;
                        case '"':
                            result.Append('"');
                            break;
                        case ']':
                            result.Append(']');
                            break;
                        case '#':
                            result.Append('#');
                            break;
                        case 'u':
                            result.Append((char)int.Parse(s.Substring(i+1, 4), System.Globalization.NumberStyles.AllowHexSpecifier));
                            i+=4;
                            break;
                        case '0':
                        case '1':
                        case '2':
                        case '3':
                        case '4':
                        case '5':
                        case '6':
                        case '7': {
                            int clen = 1;
                            char cx = ((i+1)<len) ? s[i+1] : (char)0;
                            if(cx >= '0' && cx <= '7') {
                                clen++;
                            }
                            cx = ((i+2)<len) ? s[i+2] : (char)0;
                            if(cx >= '0' && cx <= '7') {
                                clen++;
                            }
                            result.Append((char)Convert.ToInt32(s.Substring(i, clen), 8));
                            i+=(clen-1);
                            break;
                        }
                        default:
                            // Shouldn't happen, but this is a reasonable default
                            result.Append(s[i]);
                            break;
                        }
                    }
                }
            }

            return result.ToString();
        }

        private static char OctalToChar(string spec) {
            return (char)Convert.ToInt32(spec, 8);
        }

        public string ReplaceRegexpEscapes(string s) {
            if(s.IndexOf('\\') == -1) {
                if(Ioke.Lang.IokeSystem.DOSISH) {
                    return s.Replace("\r\n","\n");
                } else {
                    return s;
                }
            }
            int len = s.Length;
            StringBuilder result = new StringBuilder(s.Length);
            if(Ioke.Lang.IokeSystem.DOSISH) {
                for(int i=0;i<len;i++) {
                    char c = s[i];

                    if(c == '\r'&& (i+1<len) && s[i+1] == '\n') {
                        result.Append('\n');
                        i++;
                    } else if(c != '\\') {
                        result.Append(c);
                    } else {
                        switch(s[++i]) {
                        case '\n':
                            // escaped newline means nothing.
                            break;
                        case '\r':
                            if(i+1<len && s[i+1] == '\n') {
                                i++;
                            }
                            // escaped newline means nothing.
                            break;
                        case 'f':
                            result.Append('\f');
                            break;
                        case 'r':
                            result.Append('\r');
                            break;
                        case 'n':
                            result.Append('\n');
                            break;
                        case 't':
                            result.Append('\t');
                            break;
                        case 'e':
                            result.Append((char)27);
                            break;
                        case '"':
                            result.Append('"');
                            break;
                        case ']':
                            result.Append(']');
                            break;
                        case '#':
                            result.Append('#');
                            break;
                        case 'u':
                            result.Append((char)Convert.ToInt32(s.Substring(i+1, 4), 16));
                            i+=4;
                            break;
                        case '0':
                        case '1':
                        case '2':
                        case '3':
                        case '4':
                        case '5':
                        case '6':
                        case '7': {
                            int clen = 1;
                            char cx = (char)(((i+1)<len) ? s[i+1] : 0);
                            if(cx >= '0' && cx <= '7') {
                                clen++;
                            }
                            cx = (char)(((i+2)<len) ? s[i+2] : 0);
                            if(cx >= '0' && cx <= '7') {
                                clen++;
                            }
                            result.Append((char)Convert.ToInt32(s.Substring(i, clen), 8));
                            i+=(clen-1);
                            break;
                        }
                        default:
                            // Shouldn't happen, but this is a reasonable default
                            result.Append('\\');
                            result.Append(s[i]);
                            break;
                        }
                    }
                }
            } else {
                for(int i=0;i<len;i++) {
                    char c = s[i];
                    if(c != '\\') {
                        result.Append(c);
                    } else {
                        switch(s[++i]) {
                        case '\n':
                            // escaped newline means nothing.
                            break;
                        case '\r':
                            if(i+1<len && s[i+1] == '\n') {
                                i++;
                            }
                            // escaped newline means nothing.
                            break;
                        case 'f':
                            result.Append('\f');
                            break;
                        case 'r':
                            result.Append('\r');
                            break;
                        case 'n':
                            result.Append('\n');
                            break;
                        case 't':
                            result.Append('\t');
                            break;
                        case 'e':
                            result.Append((char)27);
                            break;
                        case '"':
                            result.Append('"');
                            break;
                        case ']':
                            result.Append(']');
                            break;
                        case '#':
                            result.Append('#');
                            break;
                        case 'u':
                            result.Append((char)Convert.ToInt32(s.Substring(i+1, 4), 16));
                            i+=4;
                            break;
                        case '0':
                        case '1':
                        case '2':
                        case '3':
                        case '4':
                        case '5':
                        case '6':
                        case '7': {
                            int clen = 1;
                            char cx = (char)(((i+1)<len) ? s[i+1] : 0);
                            if(cx >= '0' && cx <= '7') {
                                clen++;
                            }
                            cx = (char)(((i+2)<len) ? s[i+2] : 0);
                            if(cx >= '0' && cx <= '7') {
                                clen++;
                            }
                            result.Append((char)Convert.ToInt32(s.Substring(i, clen), 8));
                            i+=(clen-1);
                            break;
                        }
                        default:
                            // Shouldn't happen, but this is a reasonable default
                            result.Append('\\');
                            result.Append(s[i]);
                            break;
                        }
                    }
                }
            }
            return result.ToString();
        }

        public string Escape(string s) {
            int len = s.Length;
            StringBuilder result = new StringBuilder(s.Length);
            for(int i=0;i<len;i++) {
                char c = s[i];
                switch(c) {
                case '\\':
                    result.Append(c).Append(c);
                    break;
                case '"':
                    result.Append('\\').Append(c);
                    break;
                case '#':
                    if((i+1 < len) && s[i+1] == '{') {
                        result.Append('\\').Append(c);
                    } else {
                        result.Append(c);
                    }
                    break;
                case '\u0008':
                    result.Append('\\').Append('b');
                    break;
                case '\f':
                    result.Append('\\').Append('f');
                    break;
                case '\r':
                    result.Append('\\').Append('r');
                    break;
                case '\t':
                    result.Append('\\').Append('t');
                    break;
                case '\n':
                    result.Append('\\').Append('n');
                    break;
                case (char)27:
                    result.Append('\\').Append('e');
                    break;
                default:
                    if(c < 32) {
                        string ss = Convert.ToString((int)c, 8);
                        switch(ss.Length) {
                        case 0:
                            ss = "000";
                            break;
                        case 1:
                            ss = "00" + ss;
                            break;
                        case 2:
                            ss = "0" + ss;
                            break;
                        default:
                            break;
                        }
                        result.Append("\\").Append(ss);
                    } else if(c > 126) {
                        if(c > 255) {
                            result.AppendFormat("\\u{0:X4}", (int)c);
                        } else {
                            string s2 = Convert.ToString((int)c, 8);
                            switch(s2.Length) {
                            case 0:
                                s2 = "000";
                                break;
                            case 1:
                                s2 = "00" + s2;
                                break;
                            case 2:
                                s2 = "0" + s2;
                                break;
                            default:
                                break;
                            }
                            result.Append("\\").Append(s2);
                        }
                    } else {
                        result.Append(c);
                    }
                    break;
                }
            }

            return result.ToString();
        }
    }
}
