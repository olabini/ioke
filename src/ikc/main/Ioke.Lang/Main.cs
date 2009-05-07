
namespace Ioke.Lang {
    using System;
    using System.Collections.Generic;
    using System.IO; 
    using Ioke.Lang.Parser;
    using Ioke.Lang.Parser.Functional;
    using Ioke.Lang.Util;

    public class IokeMain {
        private const string HELP = 
            "Usage: ioke [switches] -- [programfile] [arguments]\n" +
            " -Cdirectory     execute with directory as CWD\n" +
            " -d              debug, set debug flag\n" +
            " -e script       execute the script. if provided, no program file is necessary.\n" +
            "                 there can be many of these provided on the same command line.\n" +
            " -h, --help      help, this message\n" +
            " -Idir           add directory to 'System loadPath'. May be used more than once\n" +
            " --copyright     print the copyright\n" +
            " --version       print current version\n";

        public static void Main(string[] args) {
            string current = System.Reflection.Assembly.GetExecutingAssembly().Location;
            string iokeHome = new FileInfo(current).Directory.Parent.FullName;
            string iokeLib = Path.Combine(iokeHome, "lib");
            
            Runtime r = new Runtime(new FunctionalOperatorShufflerFactory());
            r.Init();

            IokeObject context = r.Ground;
            Message mx = new Message(r, ".", null, Message.Type.TERMINATOR);
            mx.Line = 0;
            mx.Position = 0;
            IokeObject message = r.CreateMessage(mx);

            string cwd = null;

            var scripts = new SaneList<string>();
            var loadDirs = new SaneList<string>();
            bool debug = false;

            try {
                int start = 0;
                bool done = false;
                bool readStdin = false;
                bool printedSomething = false;

                for(;!done && start<args.Length;start++) {
                    string arg = args[start];
                    if(arg.Length > 0) {
                        if(arg[0] != '-') {
                            done = true;
                            break;
                        } else {
                            if(arg.Equals("--")) {
                                done = true;
                            } else if(arg.Equals("-d")) {
                                debug = true;
                                r.Debug = true;
                            } else if(arg.StartsWith("-e")) {
                                if(arg.Length == 2) {
                                    scripts.Add(args[++start]);
                                } else {
                                    scripts.Add(arg.Substring(2));
                                }
                            } else if(arg.StartsWith("-I")) {
                                if(arg.Length == 2) {
                                    loadDirs.Add(args[++start]);
                                } else {
                                    loadDirs.Add(arg.Substring(2));
                                }
                            } else if(arg.Equals("-h") || arg.Equals("--help")) {
                                Console.Error.Write(HELP);
                                return;
                            } else if(arg.Equals("--version")) {
                                Console.Error.WriteLine(getVersion());
                                printedSomething = true;
                            } else if(arg.Equals("--copyright")) {
                                Console.Error.Write(COPYRIGHT);
                                printedSomething = true;
                            } else if(arg.Equals("-")) {
                                readStdin = true;
                            } else if(arg[1] == 'C') {
                                if(arg.Length == 2) {
                                    cwd = args[++start];
                                } else {
                                    cwd = arg.Substring(2);
                                }
                            } else {
                                IokeObject condition = IokeObject.As(IokeObject.GetCellChain(r.Condition, 
                                                                                             message, 
                                                                                             context, 
                                                                                             "Error", 
                                                                                             "CommandLine", 
                                                                                             "DontUnderstandOption"), null).Mimic(message, context);
                                condition.SetCell("message", message);
                                condition.SetCell("context", context);
                                condition.SetCell("receiver", context);
                                condition.SetCell("option", r.NewText(arg));
                                r.ErrorCondition(condition);
                            }
                        }
                    }
                }
                
                if(cwd != null) {
                    r.CurrentWorkingDirectory = cwd;
                }

                ((IokeSystem)IokeObject.dataOf(r.System)).CurrentProgram = "-e";

                string lib = Environment.GetEnvironmentVariable("ioke.lib");
                if(lib == null) {
                    lib = iokeLib;
                }
                ((IokeSystem)IokeObject.dataOf(r.System)).AddLoadPath(lib + "/ioke");
                ((IokeSystem)IokeObject.dataOf(r.System)).AddLoadPath("lib/ioke");

                foreach(string ss in loadDirs) {
                    ((IokeSystem)IokeObject.dataOf(r.System)).AddLoadPath(ss);
                }

                foreach(string script in scripts) {
                    r.EvaluateStream("-e", new StringReader(script), message, context);
                }
                
                if(readStdin) {
                    ((IokeSystem)IokeObject.dataOf(r.System)).CurrentProgram = "<stdin>";
                    r.EvaluateStream("<stdin>", Console.In, message, context);
                }

                if(args.Length > start) { 
                    if(args.Length > (start+1)) {
                        for(int i=start+1,j=args.Length; i<j; i++) {
                            r.AddArgument(args[i]);
                        }
                    }
                    string file = args[start];
                    if(file.StartsWith("\"")) {
                        file = file.Substring(1, file.Length-1);
                    }

                    if(file.Length > 1 && file[file.Length-1] == '"') {
                        file = file.Substring(0, file.Length-1);
                    }

                    ((IokeSystem)IokeObject.dataOf(r.System)).CurrentProgram = file;
                    r.EvaluateFile(file, message, context);
                } else {
                    if(!readStdin && scripts.Count == 0 && !printedSomething) {
                        r.EvaluateString("use(\"builtin/iik\"). IIk mainLoop", message, context);
                    }
                }

                r.TearDown();

            } catch(ControlFlow.Exit e) {
                int exitVal = e.ExitValue;
                try {
                    r.TearDown();
                } catch(ControlFlow.Exit e2) {
                    exitVal = e2.ExitValue;
                }
                Environment.Exit(exitVal);
            } catch(ControlFlow e) {
                string name = e.GetType().FullName;
                System.Console.Error.WriteLine("unexpected control flow: " + name.Substring(name.LastIndexOf(".") + 1).ToLower());
                if(debug) {
                    System.Console.Error.WriteLine(e);
                }
                Environment.Exit(1);
            }
        }


        public static string getVersion() {
            try {
                using(Stream s = typeof(IokeSystem).Assembly.GetManifestResourceStream("Ioke.Lang.version.properties")) {
                    using(StreamReader sr = new StreamReader(s, System.Text.Encoding.UTF8)) {
                        var result = new Dictionary<string, string>();
                        while(!sr.EndOfStream) {
                            string ss = sr.ReadLine();
                            if(ss.IndexOf('=') != -1) {
                                string[] parts = ss.Split('=');
                                result[parts[0].Trim()] = parts[1].Trim();
                            }
                        }

                        string version = result["ioke.build.versionString"];
                        string date = result["ioke.build.date"];
                        string commit = result["ioke.build.commit"];

                        return version + " [" + date + " -- " + commit + "]";
                    }
                }
            } catch(System.Exception) {
            }

            return "";
        }

        private const string COPYRIGHT = 
            "Copyright (c) 2009 Ola Bini, ola.bini@gmail.com\n"+
            "\n"+
            "Permission is hereby granted, free of charge, to any person obtaining a copy\n"+
            "of this software and associated documentation files (the \"Software\"), to deal\n"+
            "in the Software without restriction, including without limitation the rights\n"+
            "to use, copy, modify, merge, publish, distribute, sublicense, and/or sell\n"+
            "copies of the Software, and to permit persons to whom the Software is\n"+
            "furnished to do so, subject to the following conditions:\n"+
            "\n"+
            "The above copyright notice and this permission notice shall be included in\n"+
            "all copies or substantial portions of the Software.\n"+
            "\n"+
            "THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR\n"+
            "IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,\n"+
            "FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE\n"+
            "AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER\n"+
            "LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,\n"+
            "OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN\n"+
            "THE SOFTWARE.\n";
    }
}
