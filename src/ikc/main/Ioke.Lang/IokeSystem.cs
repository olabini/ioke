
namespace Ioke.Lang {
    using System;
    using System.Collections;
    using System.Collections.Generic;
    using System.IO;
    using System.Reflection;

    using Ioke.Lang.Util;

    public class IokeSystem : IokeData {
        public class AtExitInfo {
            public readonly IokeObject context;
            public readonly IokeObject message;
            public AtExitInfo(IokeObject context, IokeObject message) {
                this.context = context;
                this.message = message;
            }
        }

        public static readonly HashSet<string> FEATURES = new HashSet<string>() {"clr"};

        IList<string> currentFile;
        string currentProgram;
        string currentWorkingDirectory;
        IokeObject loadPath;
        IokeObject programArguments;
        ICollection<string> loaded = new SaneHashSet<string>();
        IList<AtExitInfo> atExit = new SaneList<AtExitInfo>();

        Random random = new Random();

        public IokeSystem() {
            currentFile = new SaneList<string>();
            currentFile.Add("<init>");
        }

        public static readonly string UserHome = System.Environment.GetEnvironmentVariable("HOME");

        public static string WithReplacedHomeDirectory(string input) {
            return input.Replace("~", UserHome);
        }

        public static IList<AtExitInfo> GetAtExits(object on) {
            return ((IokeSystem)IokeObject.dataOf(on)).atExit;
        }

        public string CurrentFile {
            get {
                return currentFile[0];
            }
        }

        public string CurrentWorkingDirectory {
            get {
                return currentWorkingDirectory;
            }
            set {
                currentWorkingDirectory = value;
            }
        }

        public string CurrentProgram {
            get { return currentProgram; }
            set { currentProgram = value; }
        }

        public void AddLoadPath(string newPath) {
            IokeList.GetList(loadPath).Add(loadPath.runtime.NewText(newPath));
        }

        public void AddArgument(string newArgument) {
            IokeList.GetList(programArguments).Add(programArguments.runtime.NewText(newArgument));
        }


        public void PushCurrentFile(string filename) {
            currentFile.Insert(0, filename);
        }

        public string PopCurrentFile() {
            string val = currentFile[0];
            currentFile.RemoveAt(0);
            return val;
        }

        public static bool IsAbsoluteFileName(string name) {
            return System.IO.Path.IsPathRooted(name);
        }

        public override string ToString() {
            return "System";
        }

        public override void Init(IokeObject obj) {
            Runtime runtime = obj.runtime;

            obj.Kind = "System";

            if(currentWorkingDirectory == null) {
                // Use CLRs CWD
                try {
                    currentWorkingDirectory = System.IO.Directory.GetCurrentDirectory();
                } catch(System.Exception) {
                    currentWorkingDirectory = ".";
                }
            }

            var l = new SaneArrayList();
            l.Add(runtime.NewText("."));
            loadPath = runtime.NewList(l);
            programArguments = runtime.NewList(new SaneArrayList());

            IokeObject outx = runtime.Io.Mimic(null, null);
            outx.Data = new IokeIO(runtime.Out);
            obj.RegisterCell("out", outx);

            IokeObject errx = runtime.Io.Mimic(null, null);
            errx.Data = new IokeIO(runtime.Error);
            obj.RegisterCell("err", errx);

            IokeObject inx = runtime.Io.Mimic(null, null);
            inx.Data = new IokeIO(runtime.In);
            obj.RegisterCell("in", inx);

            obj.RegisterCell("currentDebugger", runtime.nil);

            obj.RegisterMethod(runtime.NewNativeMethod("takes one text or symbol argument and returns a boolean indicating whether the named feature is available on this runtime.",
                                                       new NativeMethod("feature?", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositional("feature")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            var args = new SaneArrayList();
                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, args, new SaneDictionary<string, object>());
                                                                            string name = Text.GetText(((Message)IokeObject.dataOf(runtime.asText)).SendTo(runtime.asText, context, args[0]));
                                                                            if(FEATURES.Contains(name)) {
                                                                                return runtime.True;
                                                                            } else {
                                                                                return runtime.False;
                                                                            }
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("returns the current file executing",
                                                       new NativeMethod.WithNoArguments("currentFile",
                                                                                        (method, context, message, on, outer) => {
                                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, new SaneArrayList(), new SaneDictionary<string, object>());
                                                                                            return runtime.NewText(((IokeSystem)IokeObject.dataOf(on)).currentFile[0]);
                                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("returns true if running on windows, otherwise false",
                                                       new NativeMethod.WithNoArguments("windows?",
                                                                                        (method, context, message, on, outer) => {
                                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, new SaneArrayList(), new SaneDictionary<string, object>());
                                                                                            return DOSISH ? runtime.True : runtime.False;
                                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("returns the current load path",
                                                       new NativeMethod.WithNoArguments("loadPath",
                                                                                        (method, context, message, on, outer) => {
                                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, new SaneArrayList(), new SaneDictionary<string, object>());
                                                                                            return ((IokeSystem)IokeObject.dataOf(on)).loadPath;
                                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("returns a random number",
                                                       new NativeMethod.WithNoArguments("randomNumber",
                                                                                        (method, context, message, on, outer) => {
                                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, new SaneArrayList(), new SaneDictionary<string, object>());
                                                                                            return context.runtime.NewNumber(((IokeSystem)IokeObject.dataOf(on)).random.Next());
                                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("returns the current directory that the code is executing in",
                                                       new NativeMethod.WithNoArguments("currentDirectory",
                                                                                        (method, context, message, on, outer) => {
                                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, new SaneArrayList(), new SaneDictionary<string, object>());
                                                                                            string name = Message.GetFile(message);
                                                                                            FileInfo f = null;
                                                                                            if(IsAbsoluteFileName(name)) {
                                                                                                f = new FileInfo(name);
                                                                                            } else {
                                                                                                f = new FileInfo(Path.Combine(context.runtime.CurrentWorkingDirectory, name));
                                                                                            }

                                                                                            if(f.Exists) {
                                                                                                return context.runtime.NewText(f.Directory.FullName);
                                                                                            }

                                                                                            return context.runtime.nil;
                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("forcibly exits the currently running interpreter. takes one optional argument that defaults to 1 - which is the value to return from the process, if the process is exited.",
                                                       new NativeMethod("exit", DefaultArgumentsDefinition.builder()
                                                                        .WithOptionalPositional("other", "1")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            var args = new SaneArrayList();
                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, args, new SaneDictionary<string, object>());
                                                                            int val = 1;
                                                                            if(args.Count > 0) {
                                                                                object arg = args[0];
                                                                                if(arg == context.runtime.True) {
                                                                                    val = 0;
                                                                                } else if(arg == context.runtime.False) {
                                                                                    val = 1;
                                                                                } else {
                                                                                    val = Number.ExtractInt(arg, message, context);
                                                                                }
                                                                            }
                                                                            throw new ControlFlow.Exit(val);
                                                                        })));

            obj.RegisterCell("programArguments", programArguments);

            obj.RegisterMethod(runtime.NewNativeMethod("returns result of evaluating first argument",
                                                       new NativeMethod("ifMain", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositionalUnevaluated("code")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            outer.ArgumentsDefinition.CheckArgumentCount(context, message, on);
                                                                            if(((IokeSystem)IokeObject.dataOf(on)).CurrentProgram.Equals(message.File)) {
                                                                                IokeObject msg = ((IokeObject)message.Arguments[0]);
                                                                                return ((Message)IokeObject.dataOf(msg)).EvaluateCompleteWith(msg, context, context.RealContext);
                                                                            } else {
                                                                                return runtime.nil;
                                                                            }
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("adds a new piece of code that should be executed on exit",
                                                       new NativeMethod("atExit", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositionalUnevaluated("code")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            outer.ArgumentsDefinition.CheckArgumentCount(context, message, on);
                                                                            GetAtExits(on).Add(new AtExitInfo(context, IokeObject.As(message.Arguments[0], context)));
                                                                            return context.runtime.nil;
                                                                        })));
        }

        private static readonly string[] SUFFIXES = {".ik"};
        private static readonly string[] SUFFIXES_WITH_BLANK = {"", ".ik"};

        public readonly static bool DOSISH = !(System.Environment.OSVersion.Platform == System.PlatformID.Unix ||
                                               System.Environment.OSVersion.Platform == System.PlatformID.MacOSX ||
                                               System.Environment.OSVersion.Platform == System.PlatformID.Xbox);

        private class BooleanGivingRestart : Restart.ArgumentGivingRestart {
            bool[] place;
            bool value;
            Runtime runtime;
            public BooleanGivingRestart(string name, bool[] place, bool value, Runtime runtime) : base(name) {
                this.place = place;
                this.value = value;
                this.runtime = runtime;
            }

            public override IList<string> ArgumentNames {
                get { return new SaneList<string>(); }
            }

            public override IokeObject Invoke(IokeObject context, IList arguments) {
                place[0] = value;
                return runtime.nil;
            }
        }

        public bool Use(IokeObject self, IokeObject context, IokeObject message, string name) {
            Runtime runtime = context.runtime;
            Builtin b = context.runtime.GetBuiltin(name);
            if(b != null) {
                if(loaded.Contains(name)) {
                    return false;
                } else {
                    try {
                        b.Load(context.runtime, context, message);
                        loaded.Add(name);
                        return true;
                    } catch(Exception e) {
                        IokeObject condition = IokeObject.As(IokeObject.GetCellChain(runtime.Condition,
                                                                                     message,
                                                                                     context,
                                                                                     "Error",
                                                                                     "Load"), context).Mimic(message, context);
                        condition.SetCell("message", message);
                        condition.SetCell("context", context);
                        condition.SetCell("receiver", self);
                        condition.SetCell("moduleName", runtime.NewText(name));
                        condition.SetCell("exceptionMessage", runtime.NewText(e.Message));
                        var st = new System.Diagnostics.StackTrace(e);
                        var ob = new SaneArrayList();
                        foreach(var frame in st.GetFrames()) {
                            ob.Add(runtime.NewText(frame.ToString()));
                        }
                        condition.SetCell("exceptionStackTrace", runtime.NewList(ob));

                        bool[] continueLoadChain = new bool[]{false};

                        runtime.WithRestartReturningArguments(()=>{runtime.ErrorCondition(condition);},
                                                              context,
                                                              new BooleanGivingRestart("continueLoadChain", continueLoadChain, true, runtime),
                                                              new BooleanGivingRestart("ignoreLoadError", continueLoadChain, false, runtime));
                        if(!continueLoadChain[0]) {
                            return false;
                        }
                    }
                }
            }

            var paths = ((IokeList)IokeObject.dataOf(loadPath)).List;

            string[] suffixes = (name.EndsWith(".ik")) ? SUFFIXES_WITH_BLANK : SUFFIXES;

            // Absolute path
            foreach(string suffix in suffixes) {
                string before = "/";
                if(name.StartsWith("/")) {
                    before = "";
                }


                try {
                    FileInfo f = new FileInfo(name + suffix);
                    if(f.Exists) {
                        if(loaded.Contains(f.FullName)) {
                            return false;
                        } else {
                            context.runtime.EvaluateFile(f, message, context);
                        }
                        loaded.Add(f.FullName);
                        return true;
                    }

                    string xname = (before + name + suffix).Replace("/", ".");
                    if(xname.StartsWith("."))
                        xname = xname.Substring(1);
                    Stream s = typeof(IokeSystem).Assembly.GetManifestResourceStream(xname);
                    if(s != null) {
                        if(loaded.Contains(name + suffix)) {
                            return false;
                        } else {
                            context.runtime.EvaluateStream(name+suffix, new StreamReader(s, System.Text.Encoding.UTF8), message, context);
                        }
                        loaded.Add(name + suffix);
                        return true;
                    }
                } catch(FileNotFoundException) {
                    // ignore
                } catch(Exception e) {
                    IokeObject condition = IokeObject.As(IokeObject.GetCellChain(runtime.Condition,
                                                                                 message,
                                                                                 context,
                                                                                 "Error",
                                                                                 "Load"), context).Mimic(message, context);
                    condition.SetCell("message", message);
                    condition.SetCell("context", context);
                    condition.SetCell("receiver", self);
                    condition.SetCell("moduleName", runtime.NewText(name));
                    condition.SetCell("exceptionMessage", runtime.NewText(e.Message));
                    var st = new System.Diagnostics.StackTrace(e);
                    var ob = new SaneArrayList();
                    foreach(var frame in st.GetFrames()) {
                        ob.Add(runtime.NewText(frame.ToString()));
                    }
                    condition.SetCell("exceptionStackTrace", runtime.NewList(ob));

                    bool[] continueLoadChain = new bool[]{false};

                    runtime.WithRestartReturningArguments(()=>{runtime.ErrorCondition(condition);},
                                                          context,
                                                          new BooleanGivingRestart("continueLoadChain", continueLoadChain, true, runtime),
                                                          new BooleanGivingRestart("ignoreLoadError", continueLoadChain, false, runtime));
                    if(!continueLoadChain[0]) {
                        return false;
                    }
                }
            }

            foreach(object o in paths) {
                string currentS = Text.GetText(o);

                foreach(string suffix in suffixes) {
                    string before = "/";
                    if(name.StartsWith("/")) {
                        before = "";
                    }

                    try {
                        FileInfo f;

                        if(IsAbsoluteFileName(currentS)) {
                            f = new FileInfo(Path.Combine(currentS, name + suffix));
                        } else {
                            f = new FileInfo(Path.Combine(Path.Combine(currentWorkingDirectory, currentS), name + suffix));
                        }

                        if(f.Exists) {
                            if(loaded.Contains(f.FullName)) {
                                return false;
                            } else {
                                context.runtime.EvaluateFile(f, message, context);
                                loaded.Add(f.FullName);
                                return true;
                            }
                        }

                        string yname = (before + name + suffix).Replace("/", ".");
                        if(yname.StartsWith("."))
                            yname = yname.Substring(1);

                        Stream ss = typeof(IokeSystem).Assembly.GetManifestResourceStream(yname);
                        if(ss != null) {
                            if(loaded.Contains(name + suffix)) {
                                return false;
                            } else {
                                context.runtime.EvaluateStream(name+suffix, new StreamReader(ss, System.Text.Encoding.UTF8), message, context);
                            }
                            loaded.Add(name + suffix);
                            return true;
                        }
                    } catch(FileNotFoundException) {
                        // ignore
                    } catch(Exception e) {
                        IokeObject condition = IokeObject.As(IokeObject.GetCellChain(runtime.Condition,
                                                                                     message,
                                                                                     context,
                                                                                     "Error",
                                                                                     "Load"), context).Mimic(message, context);
                        condition.SetCell("message", message);
                        condition.SetCell("context", context);
                        condition.SetCell("receiver", self);
                        condition.SetCell("moduleName", runtime.NewText(name));
                        condition.SetCell("exceptionMessage", runtime.NewText(e.Message));
                        var st = new System.Diagnostics.StackTrace(e);
                        var ob = new SaneArrayList();
                        foreach(var frame in st.GetFrames()) {
                            ob.Add(runtime.NewText(frame.ToString()));
                        }
                        condition.SetCell("exceptionStackTrace", runtime.NewList(ob));

                        bool[] continueLoadChain = new bool[]{false};

                        runtime.WithRestartReturningArguments(()=>{runtime.ErrorCondition(condition);},
                                                              context,
                                                              new BooleanGivingRestart("continueLoadChain", continueLoadChain, true, runtime),
                                                              new BooleanGivingRestart("ignoreLoadError", continueLoadChain, false, runtime));
                        if(!continueLoadChain[0]) {
                            return false;
                        }
                    }
                }
            }

            IokeObject condition2 = IokeObject.As(IokeObject.GetCellChain(runtime.Condition,
                                                                          message,
                                                                          context,
                                                                          "Error",
                                                                          "Load"), context).Mimic(message, context);
            condition2.SetCell("message", message);
            condition2.SetCell("context", context);
            condition2.SetCell("receiver", self);
            condition2.SetCell("moduleName", runtime.NewText(name));

            runtime.WithReturningRestart("ignoreLoadError", context, ()=>{runtime.ErrorCondition(condition2);});
            return false;
        }
    }
}
