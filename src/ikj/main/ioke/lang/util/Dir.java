/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang.util;

import java.io.File;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import java.util.jar.JarEntry;
import java.util.jar.JarFile;

import java.util.Enumeration;

public class Dir {
    public final static boolean DOSISH = System.getProperty("os.name").indexOf("Windows") != -1;
    public final static boolean CASEFOLD_FILESYSTEM = DOSISH;

    public final static int FNM_NOESCAPE = 0x01;
    public final static int FNM_PATHNAME = 0x02;
    public final static int FNM_DOTMATCH = 0x04;
    public final static int FNM_CASEFOLD = 0x08;

    public final static int FNM_SYSCASE = CASEFOLD_FILESYSTEM ? FNM_CASEFOLD : 0;

    public final static int FNM_NOMATCH = 1;
    public final static int FNM_ERROR   = 2;

    public final static String EMPTY = "";
    public final static String SLASH = "/";
    public final static String STAR = "*";
    public final static String DOUBLE_STAR = "**";

    private static boolean isdirsep(char c) {
        return DOSISH ? (c == '\\' || c == '/') : c == '/';
    }

    private static int rb_path_next(String _s, int s, int send) {
        while(s < send && !isdirsep(_s.charAt(s))) {
            s++;
        }
        return s;
    }

    private static int fnmatch_helper(String bytes, int pstart, int pend, String string, int sstart, int send, int flags) {
        char test;
        int s = sstart;
        int pat = pstart;
        boolean escape = (flags & FNM_NOESCAPE) == 0;
        boolean pathname = (flags & FNM_PATHNAME) != 0;
        boolean period = (flags & FNM_DOTMATCH) == 0;
        boolean nocase = (flags & FNM_CASEFOLD) != 0;

        while(pat<pend) {
            char c = bytes.charAt(pat++);
            switch(c) {
            case '?':
                if(s >= send || (pathname && isdirsep(string.charAt(s))) || 
                   (period && string.charAt(s) == '.' && (s == 0 || (pathname && isdirsep(string.charAt(s-1)))))) {
                    return FNM_NOMATCH;
                }
                s++;
                break;
            case '*':
                while(pat < pend && (c = bytes.charAt(pat++)) == '*');
                if(s < send && (period && string.charAt(s) == '.' && (s == 0 || (pathname && isdirsep(string.charAt(s-1)))))) {
                    return FNM_NOMATCH;
                }
                if(pat > pend || (pat == pend && c == '*')) {
                    if(pathname && rb_path_next(string, s, send) < send) {
                        return FNM_NOMATCH;
                    } else {
                        return 0;
                    }
                } else if((pathname && isdirsep(c))) {
                    s = rb_path_next(string, s, send);
                    if(s < send) {
                        s++;
                        break;
                    }
                    return FNM_NOMATCH;
                }
                test = escape && c == '\\' && pat < pend ? bytes.charAt(pat) : c;
                test = Character.toLowerCase(test);
                pat--;
                while(s < send) {
                    if((c == '?' || c == '[' || Character.toLowerCase(string.charAt(s)) == test) &&
                       fnmatch(bytes, pat, pend, string, s, send, flags | FNM_DOTMATCH) == 0) {
                        return 0;
                    } else if((pathname && isdirsep(string.charAt(s)))) {
                        break;
                    }
                    s++;
                }
                return FNM_NOMATCH;
            case '[':
                if(s >= send || (pathname && isdirsep(string.charAt(s)) || 
                                 (period && string.charAt(s) == '.' && (s == 0 || (pathname && isdirsep(string.charAt(s-1))))))) {
                    return FNM_NOMATCH;
                }
                pat = range(bytes, pat, pend, string.charAt(s), flags);
                if(pat == -1) {
                    return FNM_NOMATCH;
                }
                s++;
                break;
            case '\\':
                if(escape &&
                   (!DOSISH ||
                    (pat < pend && "*?[]\\".indexOf(bytes.charAt(pat)) != -1))) {
                    if(pat >= pend) {
                        c = '\\';
                    } else {
                        c = bytes.charAt(pat++);
                    }
                }
            default:
                if(s >= send) {
                    return FNM_NOMATCH;
                }
                if(DOSISH && (pathname && isdirsep(c) && isdirsep(string.charAt(s)))) {
                } else {
                    if (nocase) {
                        if(Character.toLowerCase(c) != Character.toLowerCase(string.charAt(s))) {
                            return FNM_NOMATCH;
                        }
                        
                    } else {
                        if(c != string.charAt(s)) {
                            return FNM_NOMATCH;
                        }
                    }
                    
                }
                s++;
                break;
            }
        }
        return s >= send ? 0 : FNM_NOMATCH;
    }

    public static int fnmatch(
            String bytes, int pstart, int pend,
            String string, int sstart, int send, int flags) {
        
        // This method handles '**/' patterns and delegates to
        // fnmatch_helper for the main work.

        boolean period = (flags & FNM_DOTMATCH) == 0;
        boolean pathname = (flags & FNM_PATHNAME) != 0;

        int pat_pos = pstart;
        int str_pos = sstart;
        int ptmp = -1;
        int stmp = -1;

        if (pathname) {
            while (true) {
                if (isDoubleStarAndSlash(bytes, pat_pos)) {
                    do { pat_pos += 3; } while (isDoubleStarAndSlash(bytes, pat_pos));
                    ptmp = pat_pos;
                    stmp = str_pos;
                }

                int patSlashIdx = nextSlashIndex(bytes, pat_pos, pend);
                int strSlashIdx = nextSlashIndex(string, str_pos, send);

                if (fnmatch_helper(bytes, pat_pos, patSlashIdx,
                        string, str_pos, strSlashIdx, flags) == 0) {
                    if (patSlashIdx < pend && strSlashIdx < send) {
                        pat_pos = ++patSlashIdx;
                        str_pos = ++strSlashIdx;
                        continue;
                    }
                    if (patSlashIdx == pend && strSlashIdx == send) {
                        return 0;
                    }
                }
                /* failed : try next recursion */
                if (ptmp != -1 && stmp != -1 && !(period && string.charAt(stmp) == '.')) {
                    stmp = nextSlashIndex(string, stmp, send);
                    if (stmp < send) {
                        pat_pos = ptmp;
                        stmp++;
                        str_pos = stmp;
                        continue;
                    }
                }
                return FNM_NOMATCH;
            }
        } else {
            return fnmatch_helper(bytes, pstart, pend, string, sstart, send, flags);
        }

    }

    // are we at '**/'
    private static boolean isDoubleStarAndSlash(String bytes, int pos) {
        if ((bytes.length() - pos) <= 2) {
            return false; // not enough bytes
        }

        return bytes.charAt(pos) == '*'
            && bytes.charAt(pos + 1) == '*'
            && bytes.charAt(pos + 2) == '/';
    }

    // Look for slash, starting from 'start' position, until 'end'.
    private static int nextSlashIndex(String bytes, int start, int end) {
        int idx = start;
        while (idx < end && idx < bytes.length() && bytes.charAt(idx) != '/') {
            idx++;
        }
        return idx;
    }

    public static int range(String _pat, int pat, int pend, char test, int flags) {
        boolean not;
        boolean ok = false;
        boolean nocase = (flags & FNM_CASEFOLD) != 0;
        boolean escape = (flags & FNM_NOESCAPE) == 0;

        not = _pat.charAt(pat) == '!' || _pat.charAt(pat) == '^';
        if(not) {
            pat++;
        }

        if (nocase) {
            test = Character.toLowerCase(test);
        }

        while(_pat.charAt(pat) != ']') {
            char cstart, cend;
            if(escape && _pat.charAt(pat) == '\\') {
                pat++;
            }
            if(pat >= pend) {
                return -1;
            }
            cstart = cend = _pat.charAt(pat++);
            if(_pat.charAt(pat) == '-' && _pat.charAt(pat+1) != ']') {
                pat++;
                if(escape && _pat.charAt(pat) == '\\') {
                    pat++;
                }
                if(pat >= pend) {
                    return -1;
                }

                cend = _pat.charAt(pat++);
            }

            if (nocase) {
                if (Character.toLowerCase(cstart) <= test
                        && test <= Character.toLowerCase(cend)) {
                    ok = true;
                }
            } else {
                if (cstart <= test && test <= cend) {
                    ok = true;
                }
            }
        }

        return ok == not ? -1 : pat + 1;
    }

    public static List<String> push_glob(String cwd, String globString, int flags) {
        List<String> result = new ArrayList<String>();
        if(globString.length() > 0) {
            push_braces(cwd, result, new GlobPattern(globString, flags));
        }

        return result;
    }
    
    private static class GlobPattern {
        final String string;        
        final int begin;
        final int end;
        
        int flags;
        int index;

        public GlobPattern(String string, int flags) {
            this(string, 0, string.length(), flags);
        }
        
        public GlobPattern(String string, int index, int end, int flags) {
            this.string = string;
            this.index = index;
            this.begin = index;
            this.end = end;
            this.flags = flags;
        }
        
        public int findClosingIndexOf(int leftTokenIndex) {
            if (leftTokenIndex == -1 || leftTokenIndex > end) return -1;
            
            char leftToken = string.charAt(leftTokenIndex);
            char rightToken;
            
            switch (leftToken) {
            case '{': rightToken = '}'; break;
            case '[': rightToken = ']'; break;
            default: return -1;
            }
            
            int nest = 1; // leftToken made us start as nest 1
            index = leftTokenIndex + 1;
            while (hasNext()) {
                char c = next();
                
                if (c == leftToken) {
                    nest++;
                } else if (c == rightToken && --nest == 0) {
                    return index();
                }
            }
            
            return -1;
        }
        
        public boolean hasNext() {
            return index < end;
        }
        
        public void reset() {
            index = begin;
        }
        
        public void setIndex(int value) {
            index = value;
        }
        
        // Get index of last read byte
        public int index() {
            return index - 1;
        }
        
        public int indexOf(char c) {
            while (hasNext()) if (next() == c) return index();
            
            return -1;
        }
        
        public char next() {
            return string.charAt(index++);
        }

    }

    private static interface GlobFunc {
        int call(String ptr, int p, int len, Object ary);
    }

    private static class GlobArgs {
        GlobFunc func;
        int c = -1;
        List<String> v;
        
        public GlobArgs(GlobFunc func, List<String> arg) {
            this.func = func;
            this.v = arg;
        }
    }

    public final static GlobFunc push_pattern = new GlobFunc() {
            @SuppressWarnings("unchecked")
            public int call(String ptr, int p, int len, Object ary) {
                ((List) ary).add(ptr.substring(p, p+len));
                return 0;
            }
        };
    public final static GlobFunc glob_caller = new GlobFunc() {
        public int call(String ptr, int p, int len, Object ary) {
            GlobArgs args = (GlobArgs)ary;
            args.c = p;
            return args.func.call(ptr, args.c, len, args.v);
        }
    };

    private static int push_braces(String cwd, List<String> result, GlobPattern pattern) {
        pattern.reset();
        int lbrace = pattern.indexOf('{'); // index of left-most brace
        int rbrace = pattern.findClosingIndexOf(lbrace);// index of right-most brace

        // No or mismatched braces..Move along..nothing to see here
        if (lbrace == -1 || rbrace == -1) return push_globs(cwd, result, pattern); 

        // Peel onion...make subpatterns out of outer layer of glob and recall with each subpattern 
        // Example: foo{a{c},b}bar -> fooa{c}bar, foobbar
        String buf = "";
        int middleRegionIndex;
        int i = lbrace;
        while (pattern.string.charAt(i) != '}') {
            middleRegionIndex = i + 1;
            for(i = middleRegionIndex; i < pattern.end && pattern.string.charAt(i) != '}' && pattern.string.charAt(i) != ','; i++) {
                if (pattern.string.charAt(i) == '{') pattern.findClosingIndexOf(i); // skip inner braces
            }

            buf = "";
            buf += pattern.string.substring(pattern.begin, lbrace);
            buf += pattern.string.substring(middleRegionIndex, i);
            buf += pattern.string.substring(rbrace+1, pattern.end);
            int status = push_braces(cwd, result, new GlobPattern(buf, 0, buf.length(), pattern.flags));
            if(status != 0) return status;
        }
        
        return 0; // All braces pushed..
    }

    private static int push_globs(String cwd, List<String> ary, GlobPattern pattern) {
        pattern.flags |= FNM_SYSCASE;
        return glob_helper(cwd, pattern.string, pattern.begin, pattern.end, -1, pattern.flags, glob_caller, new GlobArgs(push_pattern, ary));
    }

    private static boolean has_magic(String bytes, int begin, int end, int flags) {
        boolean escape = (flags & FNM_NOESCAPE) == 0;
        boolean nocase = (flags & FNM_CASEFOLD) != 0;
        int open = 0;

        for (int i = begin; i < end; i++) {
            switch(bytes.charAt(i)) {
            case '?':
            case '*':
                return true;
            case '[':	/* Only accept an open brace if there is a close */
                open++;	/* brace to match it.  Bracket expressions must be */
                continue;	/* complete, according to Posix.2 */
            case ']':
                if (open > 0) return true;

                continue;
            case '\\':
                if (escape && i == end) return false;

                break;
            default:
                if (FNM_SYSCASE == 0 && nocase && Character.isLetter(bytes.charAt(i))) return true;
            }
        }

        return false;
    }

    private static int remove_backslashes(StringBuilder bytes, int index, int len) {
        int t = index;
        
        for (; index < len; index++, t++) {
            if (bytes.charAt(index) == '\\' && ++index == len) break;
            
            bytes.replace(t, t+1, bytes.substring(index, index+1));
        }
        
        return t;
    }

    private static int strchr(String bytes, int begin, int end, char ch) {
        for (int i = begin; i < end; i++) {
            if (bytes.charAt(i) == ch) return i;
        }
        
        return -1;
    }

    private static String extract_path(String bytes, int begin, int end) {
        int len = end - begin;
        
        if (len > 1 && bytes.charAt(end-1) == '/' && (!DOSISH || (len < 2 || bytes.charAt(end-2) != ':'))) len--;

        return bytes.substring(begin, begin+len);
    }

    private static String extract_elem(String bytes, int begin, int end) {
        int elementEnd = strchr(bytes, begin, end, '/');
        if (elementEnd == -1) elementEnd = end;
        
        return extract_path(bytes, begin, elementEnd);
    }

    private static boolean BASE(String base) {
        return DOSISH ? 
            (base.length() > 0 && !((isdirsep(base.charAt(0)) && base.length() < 2) || (base.length() > 2 && base.charAt(1) == ':' && isdirsep(base.charAt(2)) && base.length() < 4)))
            :
            (base.length() > 0 && !(isdirsep(base.charAt(0)) && base.length() < 2));
    }
    
    private static boolean isJarFilePath(String bytes, int begin, int end) {
        return end > 6 && bytes.substring(begin, begin+5).equals("file:");
    }

    private static String[] files(File directory) {
        String[] files = directory.list();
        
        if (files != null) {
            String[] filesPlusDotFiles = new String[files.length + 2];
            System.arraycopy(files, 0, filesPlusDotFiles, 2, files.length);
            filesPlusDotFiles[0] = ".";
            filesPlusDotFiles[1] = "..";

            return filesPlusDotFiles;
        } else {
            return new String[0];
        }
    }

    private static int glob_helper(String cwd, String _bytes, int begin, int end, int sub, int flags, GlobFunc func, GlobArgs arg) {
        CharSequence bytes = _bytes;
        int p,m;
        int status = 0;
        StringBuilder newpath = null;
        File st;
        p = sub != -1 ? sub : begin;
        if (!has_magic(_bytes, p, end, flags)) {
            if (DOSISH || (flags & FNM_NOESCAPE) == 0) {
                newpath = new StringBuilder();
                newpath.append(bytes, 0, end);
                if (sub != -1) {
                    p = (sub - begin);
                    end = remove_backslashes(newpath, p, end);
                    sub = p;
                } else {
                    end = remove_backslashes(newpath, 0, end);
                    bytes = newpath;
                }
            }

            if (bytes.charAt(begin) == '/' || (DOSISH && begin+2<end && bytes.charAt(begin+1) == ':' && isdirsep(bytes.charAt(begin+2)))) {
                if (new File(bytes.subSequence(begin, end).toString()).exists()) {
                    status = func.call(bytes.toString(), begin, end, arg);
                }
            } else if (isJarFilePath(bytes.toString(), begin, end)) {
                int ix = end;
                for(int i = 0;i<end;i++) {
                    if(bytes.charAt(begin+i) == '!') {
                        ix = i;
                        break;
                    }
                }

                st = new File(bytes.subSequence(begin+5, ix).toString());
                String jar = bytes.subSequence(begin+ix+1, end).toString();
                try {
                    JarFile jf = new JarFile(st);
                    
                    if (jar.startsWith("/")) jar = jar.substring(1);
                    if (jf.getEntry(jar + "/") != null) jar = jar + "/";
                    if (jf.getEntry(jar) != null) {
                        status = func.call(bytes.toString(), begin, end, arg);
                    }
                } catch(Exception e) {}
            } else if ((end - begin) > 0) { // Length check is a hack.  We should not be reeiving "" as a filename ever. 
                if (new File(cwd, bytes.subSequence(begin, end).toString()).exists()) {
                    status = func.call(bytes.toString(), begin, end - begin, arg);
                }
            }

            return status;
        }

        String bytes2 = bytes.toString();
        String buf = "";
        List<String> link = new ArrayList<String>();
        mainLoop: while(p != -1 && status == 0) {
            if (bytes2.charAt(p) == '/') p++;

            m = strchr(bytes2, p, end, '/');
            if(has_magic(bytes2, p, m == -1 ? end : m, flags)) {
                finalize: do {
                    String base = extract_path(bytes2, begin, p);
                    String dir = begin == p ? "." : base; 
                    String magic = extract_elem(bytes2,p,end);
                    boolean recursive = false;
                    String jar = null;
                    JarFile jf = null;

                    if(dir.charAt(0) == '/'  || (DOSISH && 2<dir.length() && dir.charAt(1) == ':' && isdirsep(dir.charAt(2)))) {
                        st = new File(dir);
                    } else if(isJarFilePath(dir, 0, dir.length())) {
                        int ix = dir.length();
                        for(int i = 0;i<dir.length();i++) {
                            if(dir.charAt(i) == '!') {
                                ix = i;
                                break;
                            }
                        }

                        st = new File(dir.substring(5, ix));
                        jar = dir.substring(ix+1, dir.length());
                        try {
                            jf = new JarFile(st);

                            if (jar.startsWith("/")) jar = jar.substring(1);
                            if (jf.getEntry(jar + "/") != null) jar = jar + "/";
                        } catch(Exception e) {
                            jar = null;
                            jf = null;
                        }
                    } else {
                        st = new File(cwd, dir);
                    }

                    if((jf != null && ("".equals(jar) || (jf.getJarEntry(jar) != null && jf.getJarEntry(jar).isDirectory()))) || st.isDirectory()) {
                        if(m != -1 && magic.equals(DOUBLE_STAR)) {
                            int n = base.length();
                            recursive = true;
                            buf = base + bytes2.substring((base.length() > 0 ? m : m + 1), end);
                            status = glob_helper(cwd, buf, 0, buf.length(), n, flags, func, arg);
                            if(status != 0) {
                                break finalize;
                            }
                        }
                    } else {
                        break mainLoop;
                    }

                    if(jar == null) {
                        String[] dirp = files(st);

                        for(int i=0;i<dirp.length;i++) {
                            if(recursive) {
                                String bs = dirp[i];
                                if (fnmatch(STAR,0,1,bs,0,bs.length(),flags) != 0) {
                                    continue;
                                }
                                buf = base + (BASE(base) ? SLASH : EMPTY);
                                buf += dirp[i];
                                if (buf.charAt(0) == '/' || (DOSISH && 2<buf.length() && buf.charAt(1) == ':' && isdirsep(buf.charAt(2)))) {
                                    st = new File(buf);
                                } else {
                                    st = new File(cwd, buf);
                                }
                                if(st.isDirectory() && !".".equals(dirp[i]) && !"..".equals(dirp[i])) {
                                    int t = buf.length();
                                    buf += SLASH + DOUBLE_STAR;
                                    buf += bytes2.substring(m, end);
                                    status = glob_helper(cwd, buf, 0, buf.length(), t, flags, func, arg);
                                    if(status != 0) {
                                        break;
                                    }
                                }
                                continue;
                            }
                            String bs = dirp[i];
                            if(fnmatch(magic,0,magic.length(),bs,0, bs.length(),flags) == 0) {
                                buf = base + (BASE(base) ? SLASH : EMPTY) + dirp[i];
                                if(m == -1) {
                                    status = func.call(buf,0,buf.length(),arg);
                                    if(status != 0) {
                                        break;
                                    }
                                    continue;
                                }
                                link.add(buf);
                                buf = "";
                            }
                        }
                    } else {
                        try {
                            List<JarEntry> dirp = new ArrayList<JarEntry>();
                            for(Enumeration<JarEntry> eje = jf.entries(); eje.hasMoreElements(); ) {
                                JarEntry je = eje.nextElement();
                                String name = je.getName();
                                int ix = name.indexOf('/', jar.length());
                                if (ix == -1 || ix == name.length()-1) {
                                    if("/".equals(jar) || (name.startsWith(jar) && name.length()>jar.length())) {
                                        dirp.add(je);
                                    }
                                }
                            }
                            for(JarEntry je : dirp) {
                                String bs = je.getName();
                                int len = bs.length();

                                if(je.isDirectory()) {
                                    len--;
                                }

                                if(recursive) {
                                    if(fnmatch(STAR,0,1,bs,0,len,flags) != 0) {
                                        continue;
                                    }
                                    buf = base.substring(0, base.length() - jar.length());
                                    buf += (BASE(base) ? SLASH : EMPTY);
                                    buf += bs.substring(0, len);

                                    if(je.isDirectory()) {
                                        int t = buf.length();
                                        buf += (SLASH + DOUBLE_STAR + bytes2.substring(m, end));
                                        status = glob_helper(cwd, buf, 0, buf.length(), t, flags, func, arg);
                                        if(status != 0) {
                                            break;
                                        }
                                    }
                                    continue;
                                }

                                if(fnmatch(magic,0,magic.length(),bs,0,len,flags) == 0) {
                                    buf = base.substring(0, base.length() - jar.length());
                                    buf += (BASE(base) ? SLASH : EMPTY);
                                    buf += bs.substring(0, len);
                                    if(m == -1) {
                                        status = func.call(buf,0,buf.length(),arg);
                                        if(status != 0) {
                                            break;
                                        }
                                        continue;
                                    }
                                    link.add(buf);
                                    buf = "";
                                }
                            }
                        } catch(Exception e) {}
                    }
                } while(false);

                if (link.size() > 0) {
                    for (String b : link) {
                        if (status == 0) {
                            if(b.charAt(0) == '/'  || (DOSISH && 2<b.length() && b.charAt(1) == ':' && isdirsep(b.charAt(2)))) {
                                st = new File(b);
                            } else {
                                st = new File(cwd, b);
                            }

                            if(st.isDirectory()) {
                                int len = b.length();
                                buf = b + bytes2.substring(m, end);
                                status = glob_helper(cwd,buf,0,buf.length(),len,flags,func,arg);
                            }
                        }
                    }
                    break mainLoop;
                }
            }
            p = m;
        }
        return status;
    }
}
