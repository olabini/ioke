/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang.util;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class StringUtils {
    public StringUtils() {
    }

    public String replaceEscapes(String s) {
        if(s.indexOf('\\') == -1) {
            if(ioke.lang.IokeSystem.DOSISH) {
                return s.replaceAll("\r\n","\n");
            } else {
                return s;
            }
        }
        int len = s.length();
        StringBuilder result = new StringBuilder(s.length());
        if(ioke.lang.IokeSystem.DOSISH) {
            for(int i=0;i<len;i++) {
                char c = s.charAt(i);

                if(c == '\r'&& (i+1<len) && s.charAt(i+1) == '\n') {
                    result.append('\n');
                    i++;
                } else if(c != '\\') {
                    result.append(c);
                } else {
                    switch(s.charAt(++i)) {
                    case '\n':
                        // escaped newline means nothing.
                        break;
                    case '\r':
                        if(i+1<len && s.charAt(i+1) == '\n') {
                            i++;
                        }
                        // escaped newline means nothing.
                        break;
                    case '\\':
                        result.append(c);
                        break;
                    case 'f':
                        result.append('\f');
                        break;
                    case 'r':
                        result.append('\r');
                        break;
                    case 'n':
                        result.append('\n');
                        break;
                    case 't':
                        result.append('\t');
                        break;
                    case 'b':
                        result.append('\b');
                        break;
                    case 'e':
                        result.append((char)27);
                        break;
                    case '"':
                        result.append('"');
                        break;
                    case ']':
                        result.append(']');
                        break;
                    case '#':
                        result.append('#');
                        break;
                    case 'u':
                        result.append((char)Integer.valueOf(s.substring(i+1, i+5), 16).intValue());
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
                        char cx = ((i+1)<len) ? s.charAt(i+1) : 0;
                        if(cx >= '0' && cx <= '7') {
                            clen++;
                        }
                        cx = ((i+2)<len) ? s.charAt(i+2) : 0;
                        if(cx >= '0' && cx <= '7') {
                            clen++;
                        }
                        result.append((char)Integer.valueOf(s.substring(i, i+clen), 8).intValue());
                        i+=(clen-1);
                        break;
                    }
                    default:
                        // Shouldn't happen, but this is a reasonable default
                        result.append(s.charAt(i));
                        break;
                    }
                }
            }
        } else {
            for(int i=0;i<len;i++) {
                char c = s.charAt(i);
                if(c != '\\') {
                    result.append(c);
                } else {
                    switch(s.charAt(++i)) {
                    case '\n':
                        // escaped newline means nothing.
                        break;
                    case '\r':
                        if(i+1<len && s.charAt(i+1) == '\n') {
                            i++;
                        }
                        // escaped newline means nothing.
                        break;
                    case '\\':
                        result.append(c);
                        break;
                    case 'f':
                        result.append('\f');
                        break;
                    case 'r':
                        result.append('\r');
                        break;
                    case 'n':
                        result.append('\n');
                        break;
                    case 't':
                        result.append('\t');
                        break;
                    case 'b':
                        result.append('\b');
                        break;
                    case 'e':
                        result.append((char)27);
                        break;
                    case '"':
                        result.append('"');
                        break;
                    case ']':
                        result.append(']');
                        break;
                    case '#':
                        result.append('#');
                        break;
                    case 'u':
                        result.append((char)Integer.valueOf(s.substring(i+1, i+5), 16).intValue());
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
                        char cx = ((i+1)<len) ? s.charAt(i+1) : 0;
                        if(cx >= '0' && cx <= '7') {
                            clen++;
                        }
                        cx = ((i+2)<len) ? s.charAt(i+2) : 0;
                        if(cx >= '0' && cx <= '7') {
                            clen++;
                        }
                        result.append((char)Integer.valueOf(s.substring(i, i+clen), 8).intValue());
                        i+=(clen-1);
                        break;
                    }
                    default:
                        // Shouldn't happen, but this is a reasonable default
                        result.append(s.charAt(i));
                        break;
                    }
                }
            }
        }
        return result.toString();
    }

    public String replaceRegexpEscapes(String s) {
        if(s.indexOf('\\') == -1) {
            if(ioke.lang.IokeSystem.DOSISH) {
                return s.replaceAll("\r\n","\n");
            } else {
                return s;
            }
        }
        int len = s.length();
        StringBuilder result = new StringBuilder(s.length());
        if(ioke.lang.IokeSystem.DOSISH) {
            for(int i=0;i<len;i++) {
                char c = s.charAt(i);

                if(c == '\r'&& (i+1<len) && s.charAt(i+1) == '\n') {
                    result.append('\n');
                    i++;
                } else if(c != '\\') {
                    result.append(c);
                } else {
                    switch(s.charAt(++i)) {
                    case '\n':
                        // escaped newline means nothing.
                        break;
                    case '\r':
                        if(i+1<len && s.charAt(i+1) == '\n') {
                            i++;
                        }
                        // escaped newline means nothing.
                        break;
                    case '\\':
                        result.append(c);
                        break;
                    case 'f':
                        result.append('\f');
                        break;
                    case 'r':
                        result.append('\r');
                        break;
                    case 'n':
                        result.append('\n');
                        break;
                    case 't':
                        result.append('\t');
                        break;
                    case 'e':
                        result.append((char)27);
                        break;
                    case '"':
                        result.append('"');
                        break;
                    case ']':
                        result.append(']');
                        break;
                    case '#':
                        result.append('#');
                        break;
                    case 'u':
                        result.append((char)Integer.valueOf(s.substring(i+1, i+5), 16).intValue());
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
                        char cx = ((i+1)<len) ? s.charAt(i+1) : 0;
                        if(cx >= '0' && cx <= '7') {
                            clen++;
                        }
                        cx = ((i+2)<len) ? s.charAt(i+2) : 0;
                        if(cx >= '0' && cx <= '7') {
                            clen++;
                        }
                        result.append((char)Integer.valueOf(s.substring(i, i+clen), 8).intValue());
                        i+=(clen-1);
                        break;
                    }
                    default:
                        // Shouldn't happen, but this is a reasonable default
                        result.append('\\');
                        result.append(s.charAt(i));
                        break;
                    }
                }
            }
        } else {
            for(int i=0;i<len;i++) {
                char c = s.charAt(i);
                if(c != '\\') {
                    result.append(c);
                } else {
                    switch(s.charAt(++i)) {
                    case '\n':
                        // escaped newline means nothing.
                        break;
                    case '\r':
                        if(i+1<len && s.charAt(i+1) == '\n') {
                            i++;
                        }
                        // escaped newline means nothing.
                        break;
                    case '\\':
                        result.append(c);
                        break;
                    case 'f':
                        result.append('\f');
                        break;
                    case 'r':
                        result.append('\r');
                        break;
                    case 'n':
                        result.append('\n');
                        break;
                    case 't':
                        result.append('\t');
                        break;
                    case 'e':
                        result.append((char)27);
                        break;
                    case '"':
                        result.append('"');
                        break;
                    case ']':
                        result.append(']');
                        break;
                    case '#':
                        result.append('#');
                        break;
                    case 'u':
                        result.append((char)Integer.valueOf(s.substring(i+1, i+5), 16).intValue());
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
                        char cx = ((i+1)<len) ? s.charAt(i+1) : 0;
                        if(cx >= '0' && cx <= '7') {
                            clen++;
                        }
                        cx = ((i+2)<len) ? s.charAt(i+2) : 0;
                        if(cx >= '0' && cx <= '7') {
                            clen++;
                        }
                        result.append((char)Integer.valueOf(s.substring(i, i+clen), 8).intValue());
                        i+=(clen-1);
                        break;
                    }
                    default:
                        // Shouldn't happen, but this is a reasonable default
                        result.append('\\');
                        result.append(s.charAt(i));
                        break;
                    }
                }
            }
        }
        return result.toString();
    }
}// StringUtils
