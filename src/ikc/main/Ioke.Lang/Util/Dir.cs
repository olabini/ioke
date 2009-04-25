
namespace Ioke.Lang.Util {
    using System;
    using System.Collections.Generic;
    using System.IO;
    using System.Text;

    public class DefaultGlobber : Ioke.Lang.Globber {
        public readonly static bool DOSISH = !(Environment.OSVersion.Platform == PlatformID.Unix || Environment.OSVersion.Platform == PlatformID.MacOSX || Environment.OSVersion.Platform == PlatformID.Xbox);
        public readonly static bool CASEFOLD_FILESYSTEM = DOSISH;

        public const int FNM_NOESCAPE = 0x01;
        public const int FNM_PATHNAME = 0x02;
        public const int FNM_DOTMATCH = 0x04;
        public const int FNM_CASEFOLD = 0x08;

        public readonly static int FNM_SYSCASE = CASEFOLD_FILESYSTEM ? FNM_CASEFOLD : 0;

        public const int FNM_NOMATCH = 1;
        public const int FNM_ERROR   = 2;

        public readonly static string EMPTY = "";
        public readonly static string SLASH = "/";
        public readonly static string STAR = "*";
        public readonly static string DOUBLE_STAR = "**";

        private static bool IsDirSep(char c) {
            return DOSISH ? (c == '\\' || c == '/') : c == '/';
        }

        private static int PathNext(string str, int s, int send) {
            while(s < send && !IsDirSep(str[s])) {
                s++;
            }
            return s;
        }

        private static int FilenameMatchHelper(string pattern, int pstart, int pend, string path, int sstart, int send, int flags) {
            char test;
            int s = sstart;
            int pat = pstart;
            bool escape = (flags & FNM_NOESCAPE) == 0;
            bool pathname = (flags & FNM_PATHNAME) != 0;
            bool period = (flags & FNM_DOTMATCH) == 0;
            bool nocase = (flags & FNM_CASEFOLD) != 0;

            while(pat<pend) {
                char c = pattern[pat++];
                switch(c) {
                case '?':
                    if(s >= send || (pathname && IsDirSep(path[s])) || 
                       (period && path[s] == '.' && (s == 0 || (pathname && IsDirSep(path[s-1]))))) {
                        return FNM_NOMATCH;
                    }
                    s++;
                    break;
                case '*':
                    while(pat < pend && (c = pattern[pat++]) == '*');
                    if(s < send && (period && path[s] == '.' && (s == 0 || (pathname && IsDirSep(path[s-1]))))) {
                        return FNM_NOMATCH;
                    }
                    if(pat > pend || (pat == pend && c == '*')) {
                        if(pathname && PathNext(path, s, send) < send) {
                            return FNM_NOMATCH;
                        } else {
                            return 0;
                        }
                    } else if((pathname && IsDirSep(c))) {
                        s = PathNext(path, s, send);
                        if(s < send) {
                            s++;
                            break;
                        }
                        return FNM_NOMATCH;
                    }
                    test = escape && c == '\\' && pat < pend ? pattern[pat] : c;
                    test = char.ToLower(test);
                    pat--;
                    while(s < send) {
                        if((c == '?' || c == '[' || char.ToLower(path[s]) == test) &&
                           FilenameMatch(pattern, pat, pend, path, s, send, flags | FNM_DOTMATCH) == 0) {
                            return 0;
                        } else if((pathname && IsDirSep(path[s]))) {
                            break;
                        }
                        s++;
                    }
                    return FNM_NOMATCH;
                case '[':
                    if(s >= send || (pathname && IsDirSep(path[s]) || (period && path[s] == '.' && (s == 0 || (pathname && IsDirSep(path[s-1])))))) {
                        return FNM_NOMATCH;
                    }
                    pat = Range(pattern, pat, pend, path[s], flags);
                    if(pat == -1) {
                        return FNM_NOMATCH;
                    }
                    s++;
                    break;
                case '\\':
                    if(escape &&
                       (!DOSISH ||
                        (pat < pend && "*?[]\\".IndexOf(pattern[pat]) != -1))) {
                        if(pat >= pend) {
                            c = '\\';
                        } else {
                            c = pattern[pat++];
                        }
                    }
                    goto default;
                default:
                    if(s >= send) {
                        return FNM_NOMATCH;
                    }
                    if(DOSISH && (pathname && IsDirSep(c) && IsDirSep(path[s]))) {
                    } else {
                        if (nocase) {
                            if(char.ToLower(c) != char.ToLower(path[s])) {
                                return FNM_NOMATCH;
                            }
                        } else {
                            if(c != path[s]) {
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

        public static int FilenameMatch(String pattern, int pstart, int pend, String path, int sstart, int send, int flags) {
            // This method handles '**/' patterns and delegates to
            // fnmatch_helper for the main work.

            bool period = (flags & FNM_DOTMATCH) == 0;
            bool pathname = (flags & FNM_PATHNAME) != 0;

            int pat_pos = pstart;
            int str_pos = sstart;
            int ptmp = -1;
            int stmp = -1;

            if(pathname) {
                while(true) {
                    if (IsDoubleStarAndSlash(pattern, pat_pos)) {
                        do { pat_pos += 3; } while (IsDoubleStarAndSlash(pattern, pat_pos));
                        ptmp = pat_pos;
                        stmp = str_pos;
                    }

                    int patSlashIdx = NextSlashIndex(pattern, pat_pos, pend);
                    int strSlashIdx = NextSlashIndex(path, str_pos, send);

                    if(FilenameMatchHelper(pattern, pat_pos, patSlashIdx, path, str_pos, strSlashIdx, flags) == 0) {
                        if(patSlashIdx < pend && strSlashIdx < send) {
                            pat_pos = ++patSlashIdx;
                            str_pos = ++strSlashIdx;
                            continue;
                        }
                        if(patSlashIdx == pend && strSlashIdx == send) {
                            return 0;
                        }
                    }
                    /* failed : try next recursion */
                    if (ptmp != -1 && stmp != -1 && !(period && path[stmp] == '.')) {
                        stmp = NextSlashIndex(path, stmp, send);
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
                return FilenameMatchHelper(pattern, pstart, pend, path, sstart, send, flags);
            }
        }

        // are we at '**/'
        private static bool IsDoubleStarAndSlash(string pattern, int pos) {
            if ((pattern.Length - pos) <= 2) {
                return false; // not enough bytes
            }

            return pattern[pos] == '*'
                && pattern[pos + 1] == '*'
                && pattern[pos + 2] == '/';
        }

        // Look for slash, starting from 'start' position, until 'end'.
        private static int NextSlashIndex(string pattern, int start, int end) {
            int idx = start;
            while(idx < end && idx < pattern.Length && pattern[idx] != '/') {
                idx++;
            }
            return idx;
        }

        public static int Range(string _pat, int pat, int pend, char test, int flags) {
            bool not;
            bool ok = false;
            bool nocase = (flags & FNM_CASEFOLD) != 0;
            bool escape = (flags & FNM_NOESCAPE) == 0;

            not = _pat[pat] == '!' || _pat[pat] == '^';
            if(not) {
                pat++;
            }

            if(nocase) {
                test = char.ToLower(test);
            }

            while(_pat[pat] != ']') {
                char cstart, cend;
                if(escape && _pat[pat] == '\\') {
                    pat++;
                }
                if(pat >= pend) {
                    return -1;
                }
                cstart = cend = _pat[pat++];
                if(_pat[pat] == '-' && _pat[pat+1] != ']') {
                    pat++;
                    if(escape && _pat[pat] == '\\') {
                        pat++;
                    }
                    if(pat >= pend) {
                        return -1;
                    }

                    cend = _pat[pat++];
                }

                if(nocase) {
                    if(char.ToLower(cstart) <= test
                        && test <= char.ToLower(cend)) {
                        ok = true;
                    }
                } else {
                    if(cstart <= test && test <= cend) {
                        ok = true;
                    }
                }
            }

            return ok == not ? -1 : pat + 1;
        }

        public IList<string> PushGlob(string cwd, string globstring, int flags) {
            var result = new List<string>();
            if(globstring.Length > 0) {
                PushBraces(cwd, result, new GlobPattern(globstring, flags));
            }

            return result;
        }

        private class GlobPattern {
            internal readonly string path;        
            internal readonly int begin;
            internal readonly int end;
        
            internal int flags;
            internal int index;

            public GlobPattern(string path, int flags) : this(path, 0, path.Length, flags) {}
            public GlobPattern(string path, int index, int end, int flags) {
                this.path = path;
                this.index = index;
                this.begin = index;
                this.end = end;
                this.flags = flags;
            }
        
            public int FindClosingIndexOf(int leftTokenIndex) {
                if(leftTokenIndex == -1 || leftTokenIndex > end) return -1;
            
                char leftToken = path[leftTokenIndex];
                char rightToken;
            
                switch (leftToken) {
                case '{': rightToken = '}'; break;
                case '[': rightToken = ']'; break;
                default: return -1;
                }
            
                int nest = 1; // leftToken made us start as nest 1
                index = leftTokenIndex + 1;
                while(HasNext()) {
                    char c = Next();
                
                    if(c == leftToken) {
                        nest++;
                    } else if(c == rightToken && --nest == 0) {
                        return Index;
                    }
                }
            
                return -1;
            }
        
            public bool HasNext() {
                return index < end;
            }
        
            public void Reset() {
                index = begin;
            }

            public int Index {
                get { return index - 1; }
                set { this.index = value; }
            }
            
            public int IndexOf(char c) {
                while (HasNext()) if (Next() == c) return Index;
                return -1;
            }
        
            public char Next() {
                return path[index++];
            }
        }

        public delegate int GlobFunc (string ptr, int p, int len, object ary);

        private class GlobArgs {
            internal GlobFunc func;
            internal int c = -1;
            internal IList<string> v;
        
            public GlobArgs(GlobFunc func, IList<string> arg) {
                this.func = func;
                this.v = arg;
            }
        }

        public static GlobFunc push_pattern = (ptr, p, len, ary) => {
            ((IList<string>) ary).Add(ptr.Substring(p, len));
            return 0;
        };

        public static GlobFunc glob_caller = (ptr, p, len, ary) => {
            GlobArgs args = (GlobArgs)ary;
            args.c = p;
            return args.func(ptr, args.c, len, args.v);
        };

        private static int PushBraces(string cwd, IList<string> result, GlobPattern pattern) {
            pattern.Reset();
            int lbrace = pattern.IndexOf('{'); // index of left-most brace
            int rbrace = pattern.FindClosingIndexOf(lbrace);// index of right-most brace

            // No or mismatched braces..Move along..nothing to see here
            if(lbrace == -1 || rbrace == -1) return PushGlobs(cwd, result, pattern); 

            // Peel onion...make subpatterns out of outer layer of glob and recall with each subpattern 
            // Example: foo{a{c},b}bar -> fooa{c}bar, foobbar
            string buf = "";
            int middleRegionIndex;
            int i = lbrace;
            while(pattern.path[i] != '}') {
                middleRegionIndex = i + 1;
                for(i = middleRegionIndex; i < pattern.end && pattern.path[i] != '}' && pattern.path[i] != ','; i++) {
                    if (pattern.path[i] == '{') pattern.FindClosingIndexOf(i); // skip inner braces
                }

                buf = "";
                buf += pattern.path.Substring(pattern.begin, lbrace - pattern.begin);
                buf += pattern.path.Substring(middleRegionIndex, i - middleRegionIndex);
                buf += pattern.path.Substring(rbrace+1, pattern.end - (rbrace+1));
                int status = PushBraces(cwd, result, new GlobPattern(buf, 0, buf.Length, pattern.flags));
                if(status != 0) return status;
            }
        
            return 0; // All braces pushed..
        }

        private static int PushGlobs(string cwd, IList<string> ary, GlobPattern pattern) {
            pattern.flags |= FNM_SYSCASE;
            return GlobHelper(cwd, pattern.path, pattern.begin, pattern.end, -1, pattern.flags, glob_caller, new GlobArgs(push_pattern, ary));
        }

        private static bool HasMagic(string pattern, int begin, int end, int flags) {
            bool escape = (flags & FNM_NOESCAPE) == 0;
            bool nocase = (flags & FNM_CASEFOLD) != 0;
            int open = 0;

            for(int i = begin; i < end; i++) {
                switch(pattern[i]) {
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
                    if (FNM_SYSCASE == 0 && nocase && char.IsLetter(pattern[i])) return true;
                    break;
                }
            }

            return false;
        }

        private static int RemoveBackslashes(StringBuilder pattern, int index, int len) {
            int t = index;
        
            for (; index < len; index++, t++) {
                if (pattern[index] == '\\' && ++index == len) break;
            
                string ss = pattern.ToString().Substring(index, 1);
                pattern.Remove(t, 1);
                pattern.Insert(t, ss);
            }
        
            return t;
        }

        private static int strchr(string pattern, int begin, int end, char ch) {
            for (int i = begin; i < end; i++) {
                if (pattern[i] == ch) return i;
            }
        
            return -1;
        }

        private static string ExtractPath(string pattern, int begin, int end) {
            int len = end - begin;
        
            if (len > 1 && pattern[end-1] == '/' && (!DOSISH || (len < 2 || pattern[end-2] != ':'))) len--;

            return pattern.Substring(begin, len);
        }

        private static string ExtractElem(string pattern, int begin, int end) {
            int elementEnd = strchr(pattern, begin, end, '/');
            if (elementEnd == -1) elementEnd = end;
        
            return ExtractPath(pattern, begin, elementEnd);
        }

        private static bool BASE(string _base) {
            return DOSISH ? 
                (_base.Length > 0 && !((IsDirSep(_base[0]) && _base.Length < 2) || (_base.Length > 2 && _base[1] == ':' && IsDirSep(_base[2]) && _base.Length < 4)))
                :
                (_base.Length > 0 && !(IsDirSep(_base[0]) && _base.Length < 2));
        }
    
        private static string[] Files(DirectoryInfo directory) {
            FileSystemInfo[] files = directory.GetFileSystemInfos();
        
            string[] filesPlusDotFiles = new string[files.Length + 2];
            filesPlusDotFiles[0] = ".";
            filesPlusDotFiles[1] = "..";
            for(int i=0, j=files.Length; i<j; i++)
                filesPlusDotFiles[i+2] = files[i].Name;
            
            return filesPlusDotFiles;
        }

        private static int GlobHelper(string cwd, string pattern, int begin, int end, int sub, int flags, GlobFunc func, GlobArgs arg) {
            int p,m;
            int status = 0;
            StringBuilder newpath = null;
            FileSystemInfo st;
            p = sub != -1 ? sub : begin;
            if (!HasMagic(pattern, p, end, flags)) {
                if (DOSISH || (flags & FNM_NOESCAPE) == 0) {
                    newpath = new StringBuilder();
                    newpath.Append(pattern, 0, end);
                    if (sub != -1) {
                        p = (sub - begin);
                        end = RemoveBackslashes(newpath, p, end);
                        sub = p;
                    } else {
                        end = RemoveBackslashes(newpath, 0, end);
                        pattern = newpath.ToString();
                    }
                }

                if(pattern[begin] == '/' || (DOSISH && begin+2<end && pattern[begin+1] == ':' && IsDirSep(pattern[begin+2]))) {
                    string ss = pattern.Substring(begin, end-begin);
                    if(new FileInfo(ss).Exists || new DirectoryInfo(ss).Exists) {
                        status = func(pattern, begin, end, arg);
                    }
                } else if((end - begin) > 0) { // Length check is a hack.  We should not be reeiving "" as a filename ever. 
                    string ss2 = pattern.Substring(begin, end-begin);
                    if(new FileInfo(ss2).Exists || new DirectoryInfo(ss2).Exists) {
                        status = func(pattern, begin, end - begin, arg);
                    }
                }

                return status;
            }

            string bytes2 = pattern;
            string buf = "";
            var link = new List<string>();
            while(p != -1 && status == 0) {
                if(bytes2[p] == '/') p++;

                m = strchr(bytes2, p, end, '/');
                if(HasMagic(bytes2, p, m == -1 ? end : m, flags)) {
                    do {
                        string _base = ExtractPath(bytes2, begin, p);
                        string dir = begin == p ? "." : _base; 
                        string magic = ExtractElem(bytes2,p,end);
                        bool recursive = false;

                        if(dir[0] == '/'  || (DOSISH && 2<dir.Length && dir[1] == ':' && IsDirSep(dir[2]))) {
                            st = new DirectoryInfo(dir);
                        } else {
                            st = new DirectoryInfo(Path.Combine(cwd, dir));
                        }

                        if(st.Exists) {
                            if(m != -1 && magic.Equals(DOUBLE_STAR)) {
                                int n = _base.Length;
                                recursive = true;
                                buf = _base + bytes2.Substring((_base.Length > 0 ? m : m + 1), end - (_base.Length > 0 ? m : m + 1));
                                status = GlobHelper(cwd, buf, 0, buf.Length, n, flags, func, arg);
                                if(status != 0) {
                                    goto finalize;
                                }
                            }
                        } else {
                            return status;
                        }

                        string[] dirp = Files((DirectoryInfo)st);

                        for(int i=0;i<dirp.Length;i++) {
                            if(recursive) {
                                string bs = dirp[i];
                                if(FilenameMatch(STAR,0,1,bs,0,bs.Length,flags) != 0) {
                                    continue;
                                }
                                buf = _base + (BASE(_base) ? SLASH : EMPTY);
                                buf += dirp[i];
                                if(buf[0] == '/' || (DOSISH && 2<buf.Length && buf[1] == ':' && IsDirSep(buf[2]))) {
                                    st = new DirectoryInfo(buf);
                                } else {
                                    st = new DirectoryInfo(Path.Combine(cwd, buf));
                                }
                                if(st.Exists && !".".Equals(dirp[i]) && !"..".Equals(dirp[i])) {
                                    int t = buf.Length;
                                    buf += SLASH + DOUBLE_STAR;
                                    buf += bytes2.Substring(m, end-m);
                                    status = GlobHelper(cwd, buf, 0, buf.Length, t, flags, func, arg);
                                    if(status != 0) {
                                        break;
                                    }
                                }
                                continue;
                            }
                            string bsx = dirp[i];
                            if(FilenameMatch(magic,0,magic.Length,bsx,0, bsx.Length,flags) == 0) {
                                buf = _base + (BASE(_base) ? SLASH : EMPTY) + dirp[i];
                                if(m == -1) {
                                    status = func(buf,0,buf.Length,arg);
                                    if(status != 0) {
                                        break;
                                    }
                                    continue;
                                }
                                link.Add(buf);
                                buf = "";
                            }
                        }
                    } while(false);
                    finalize:

                    if(link.Count > 0) {
                        foreach(string b in link) {
                            if(status == 0) {
                                if(b[0] == '/'  || (DOSISH && 2<b.Length && b[1] == ':' && IsDirSep(b[2]))) {
                                    st = new DirectoryInfo(b);
                                } else {
                                    st = new DirectoryInfo(Path.Combine(cwd, b));
                                }

                                if(st.Exists) {
                                    int len = b.Length;
                                    buf = b + bytes2.Substring(m, end - m);
                                    status = GlobHelper(cwd,buf,0,buf.Length,len,flags,func,arg);
                                }
                            }
                        }
                        return status;
                    }
                }
                p = m;
            }

            return status;
        }
    }
}
