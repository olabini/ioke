
namespace Ioke.Lang {
    using System.Collections;
    using System.Collections.Generic;
    using System.IO;

    using Ioke.Lang.Util;

    public class FileSystem {
        public static IList<string> Glob(Runtime runtime, string text) {
            return runtime.globber.PushGlob(runtime.CurrentWorkingDirectory, text, 0);
        }

        public class IokeFile : IokeIO {
            //            private FileInfo file;

            public IokeFile(FileInfo file) : base(null, null) {
                //                this.file = file;

                try {
                    if(file != null) {
                        this.writer = new StreamWriter(file.OpenWrite());
                    }
                } catch(IOException) {
                }
            }

            public override void Init(IokeObject obj) {
                Runtime runtime = obj.runtime;

                obj.Kind = "FileSystem File";

                obj.RegisterMethod(runtime.NewNativeMethod("Closes any open stream to this file",
                                                           new TypeCheckingNativeMethod.WithNoArguments("close", obj,
                                                                                                        (method, on, args, keywords, context, message) => {
                                                                                                            try {
                                                                                                                TextWriter writer = IokeIO.GetWriter(on);
                                                                                                                if(writer != null) {
                                                                                                                    writer.Close();
                                                                                                                }
                                                                                                            } catch(IOException) {
                                                                                                            }
                                                                                                            return context.runtime.nil;
                                                                                                        })));
            }
        }

        public static void Init(IokeObject obj) {
            Runtime runtime = obj.runtime;
            obj.Kind = "FileSystem";

            IokeObject file = new IokeObject(runtime, "represents a file in the file system", new IokeFile(null));
            file.MimicsWithoutCheck(runtime.Io);
            file.Init();
            obj.RegisterCell("File", file);

            obj.RegisterMethod(runtime.NewNativeMethod("Tries to interpret the given arguments as strings describing file globs, and returns an array containing the result of applying these globs.",
                                                       new NativeMethod("[]", DefaultArgumentsDefinition.builder()
                                                                        .WithRest("globTexts")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            var args = new SaneArrayList();
                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, args, new SaneDictionary<string, object>());

                                                                            var dirs = FileSystem.Glob(context.runtime, IokeSystem.WithReplacedHomeDirectory(Text.GetText(args[0])));
                                                                            var result = new SaneArrayList();
                                                                            foreach(string s in dirs) {
                                                                                result.Add(context.runtime.NewText(s));
                                                                            }
                                                                            return context.runtime.NewList(result);
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("Takes one string argument and returns true if it's the relative or absolute name of a directory, and false otherwise.",
                                                       new NativeMethod("directory?", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositional("directoryName")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            var args = new SaneArrayList();
                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, args, new SaneDictionary<string, object>());

                                                                            string name = IokeSystem.WithReplacedHomeDirectory(Text.GetText(args[0]));
                                                                            DirectoryInfo f = null;
                                                                            if(IokeSystem.IsAbsoluteFileName(name)) {
                                                                                f = new DirectoryInfo(name);
                                                                            } else {
                                                                                f = new DirectoryInfo(Path.Combine(context.runtime.CurrentWorkingDirectory, name));
                                                                            }

                                                                            return f.Exists ? context.runtime.True : context.runtime.False;
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("Takes one string argument that should be a file name, and returns a text of the contents of this file.",
                                                       new NativeMethod("readFully", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositional("fileName")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            var args = new SaneArrayList();
                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, args, new SaneDictionary<string, object>());

                                                                            string name = IokeSystem.WithReplacedHomeDirectory(Text.GetText(args[0]));
                                                                            FileInfo f = null;
                                                                            if(IokeSystem.IsAbsoluteFileName(name)) {
                                                                                f = new FileInfo(name);
                                                                            } else {
                                                                                f = new FileInfo(Path.Combine(context.runtime.CurrentWorkingDirectory, name));
                                                                            }

                                                                            return context.runtime.NewText(File.ReadAllText(f.FullName));
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("Takes one string argument and returns true if it's the relative or absolute name of a file, and false otherwise.",
                                                       new NativeMethod("file?", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositional("fileName")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            var args = new SaneArrayList();
                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, args, new SaneDictionary<string, object>());

                                                                            string name = IokeSystem.WithReplacedHomeDirectory(Text.GetText(args[0]));
                                                                            FileInfo f = null;
                                                                            if(IokeSystem.IsAbsoluteFileName(name)) {
                                                                                f = new FileInfo(name);
                                                                            } else {
                                                                                f = new FileInfo(Path.Combine(context.runtime.CurrentWorkingDirectory, name));
                                                                            }

                                                                            return f.Exists ? context.runtime.True : context.runtime.False;
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("Takes one string argument and returns true if it's the relative or absolute name of something that exists.",
                                                       new NativeMethod("exists?", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositional("entryName")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            var args = new SaneArrayList();
                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, args, new SaneDictionary<string, object>());

                                                                            string name = IokeSystem.WithReplacedHomeDirectory(Text.GetText(args[0]));
                                                                            string nx = null;
                                                                            if(IokeSystem.IsAbsoluteFileName(name)) {
                                                                                nx = name;
                                                                            } else {
                                                                                nx = Path.Combine(context.runtime.CurrentWorkingDirectory, name);
                                                                            }

                                                                            return (new FileInfo(nx).Exists || new DirectoryInfo(nx).Exists) ? context.runtime.True : context.runtime.False;
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("Takes one string argument that should be the path of a file or directory, and returns the parent of it - or nil if there is no parent.",
                                                       new NativeMethod("parentOf", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositional("entryName")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            var args = new SaneArrayList();
                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, args, new SaneDictionary<string, object>());

                                                                            string name = Text.GetText(args[0]);
                                                                            string nx;
                                                                            if(IokeSystem.IsAbsoluteFileName(name)) {
                                                                                nx = name;
                                                                            } else {
                                                                                nx = Path.Combine(context.runtime.CurrentWorkingDirectory, name);
                                                                            }

                                                                            string parent = Path.GetDirectoryName(nx);
                                                                            if(parent == null) {
                                                                                return context.runtime.nil;
                                                                            }

                                                                            string cwd = context.runtime.CurrentWorkingDirectory;

                                                                            if(!IokeSystem.IsAbsoluteFileName(name) && parent.Equals(cwd)) {
                                                                                return context.runtime.nil;
                                                                            }

                                                                            if(parent.StartsWith(cwd)) {
                                                                                parent = parent.Substring(cwd.Length+1);
                                                                            }

                                                                            return context.runtime.NewText(parent);
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("Takes a file name and a lexical block - opens the file, ensures that it exists and then yields the file to the block. Finally it closes the file after the block has finished executing, and then returns the result of the block.",
                                                       new NativeMethod("withOpenFile", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositional("fileName")
                                                                        .WithRequiredPositional("code")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            var args = new SaneArrayList();
                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, args, new SaneDictionary<string, object>());

                                                                            string name = IokeSystem.WithReplacedHomeDirectory(Text.GetText(args[0]));
                                                                            FileInfo f = null;
                                                                            if(IokeSystem.IsAbsoluteFileName(name)) {
                                                                                f = new FileInfo(name);
                                                                            } else {
                                                                                f = new FileInfo(Path.Combine(context.runtime.CurrentWorkingDirectory, name));
                                                                            }

                                                                            try {
                                                                                if(!f.Exists) {
                                                                                    using(FileStream fs = File.Create(f.FullName)) {
                                                                                    }
                                                                                }
                                                                            } catch(IOException) {
                                                                            }

                                                                            IokeObject ff = context.runtime.NewFile(context, f);
                                                                            object result = context.runtime.nil;

                                                                            try {
                                                                                result = ((Message)IokeObject.dataOf(context.runtime.callMessage)).SendTo(context.runtime.callMessage, context, args[1], ff);
                                                                            } finally {
                                                                                ((Message)IokeObject.dataOf(context.runtime.closeMessage)).SendTo(context.runtime.closeMessage, context, ff);
                                                                            }

                                                                            return result;
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("Copies a file. Takes two text arguments, where the first is the name of the file to copy and the second is the name of the destination. If the destination is a directory, the file will be copied with the same name, and if it's a filename, the file will get a new name",
                                                       new NativeMethod("copyFile", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositional("fileName")
                                                                        .WithRequiredPositional("destination")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            var args = new SaneArrayList();
                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, args, new SaneDictionary<string, object>());

                                                                            string name = Text.GetText(args[0]);
                                                                            FileInfo f = null;
                                                                            if(IokeSystem.IsAbsoluteFileName(name)) {
                                                                                f = new FileInfo(name);
                                                                            } else {
                                                                                f = new FileInfo(Path.Combine(context.runtime.CurrentWorkingDirectory, name));
                                                                            }

                                                                            string name2 = Text.GetText(args[1]);
                                                                            string nx = null;
                                                                            if(IokeSystem.IsAbsoluteFileName(name2)) {
                                                                                nx = name2;
                                                                            } else {
                                                                                nx = Path.Combine(context.runtime.CurrentWorkingDirectory, name2);
                                                                            }

                                                                            if(new DirectoryInfo(nx).Exists) {
                                                                                nx = Path.Combine(nx, f.Name);
                                                                            }


                                                                            try {
                                                                                File.Copy(f.FullName, nx, true);
                                                                            } catch (IOException) {
                                                                            }

                                                                            return context.runtime.nil;
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("Takes one string argument and creates a directory with that name. It also takes an optional second argument. If it's true, will try to create all necessary directories inbetween. Default is false. Will signal a condition if the directory already exists, or if there's a file with that name.",
                                                       new NativeMethod("createDirectory!", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositional("directoryName")
                                                                        .WithOptionalPositional("createPath", "false")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            var args = new SaneArrayList();
                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, args, new SaneDictionary<string, object>());

                                                                            string name = IokeSystem.WithReplacedHomeDirectory(Text.GetText(args[0]));
                                                                            DirectoryInfo f = null;
                                                                            if(IokeSystem.IsAbsoluteFileName(name)) {
                                                                                f = new DirectoryInfo(name);
                                                                            } else {
                                                                                f = new DirectoryInfo(Path.Combine(context.runtime.CurrentWorkingDirectory, name));
                                                                            }

                                                                            if(f.Exists || new FileInfo(f.FullName).Exists) {
                                                                                string msg = null;
                                                                                if(f.Exists) {
                                                                                    msg = "Can't create directory '" + name + "' since there already exists a directory with that name";
                                                                                } else {
                                                                                    msg = "Can't create directory '" + name + "' since there already exists a file with that name";
                                                                                }

                                                                                IokeObject condition = IokeObject.As(IokeObject.GetCellChain(runtime.Condition,
                                                                                                                                             message,
                                                                                                                                             context,
                                                                                                                                             "Error",
                                                                                                                                             "IO"), context).Mimic(message, context);
                                                                                condition.SetCell("message", message);
                                                                                condition.SetCell("context", context);
                                                                                condition.SetCell("receiver", on);
                                                                                condition.SetCell("text", runtime.NewText(msg));

                                                                                runtime.WithReturningRestart("ignore", context, ()=>{runtime.ErrorCondition(condition);});
                                                                            }

                                                                            Directory.CreateDirectory(f.FullName);
                                                                            return context.runtime.nil;
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("Takes one string argument and removes a directory with that name. Will signal a condition if the directory doesn't exist, or if there's a file with that name.",
                                                       new NativeMethod("removeDirectory!", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositional("directoryName")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            var args = new SaneArrayList();
                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, args, new SaneDictionary<string, object>());

                                                                            string name = IokeSystem.WithReplacedHomeDirectory(Text.GetText(args[0]));
                                                                            string nf = null;
                                                                            if(IokeSystem.IsAbsoluteFileName(name)) {
                                                                                nf = name;
                                                                            } else {
                                                                                nf = Path.Combine(context.runtime.CurrentWorkingDirectory, name);
                                                                            }

                                                                            if(!(new DirectoryInfo(nf).Exists) || new FileInfo(nf).Exists) {
                                                                                string msg = null;
                                                                                if(!(new DirectoryInfo(nf).Exists)) {
                                                                                    msg = "Can't remove directory '" + name + "' since it doesn't exist";
                                                                                } else {
                                                                                    msg = "Can't remove directory '" + name + "' since it is a file";
                                                                                }

                                                                                IokeObject condition = IokeObject.As(IokeObject.GetCellChain(runtime.Condition,
                                                                                                                                             message,
                                                                                                                                             context,
                                                                                                                                             "Error",
                                                                                                                                             "IO"), context).Mimic(message, context);
                                                                                condition.SetCell("message", message);
                                                                                condition.SetCell("context", context);
                                                                                condition.SetCell("receiver", on);
                                                                                condition.SetCell("text", runtime.NewText(msg));

                                                                                runtime.WithReturningRestart("ignore", context, ()=>{runtime.ErrorCondition(condition);});
                                                                            }

                                                                            Directory.Delete(nf);
                                                                            return context.runtime.nil;
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("Takes one string argument and removes a file with that name. Will signal a condition if the file doesn't exist, or if there's a directory with that name.",
                                                       new NativeMethod("removeFile!", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositional("fileName")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            var args = new SaneArrayList();
                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, args, new SaneDictionary<string, object>());

                                                                            string name = IokeSystem.WithReplacedHomeDirectory(Text.GetText(args[0]));
                                                                            string nf = null;
                                                                            if(IokeSystem.IsAbsoluteFileName(name)) {
                                                                                nf = name;
                                                                            } else {
                                                                                nf = Path.Combine(context.runtime.CurrentWorkingDirectory, name);
                                                                            }

                                                                            if(!(new FileInfo(nf).Exists) || new DirectoryInfo(nf).Exists) {
                                                                                string msg = null;
                                                                                if(!(new FileInfo(nf).Exists)) {
                                                                                    msg = "Can't remove file '" + name + "' since it doesn't exist";
                                                                                } else {
                                                                                    msg = "Can't remove file '" + name + "' since it is a directory";
                                                                                }

                                                                                IokeObject condition = IokeObject.As(IokeObject.GetCellChain(runtime.Condition,
                                                                                                                                             message,
                                                                                                                                             context,
                                                                                                                                             "Error",
                                                                                                                                             "IO"), context).Mimic(message, context);
                                                                                condition.SetCell("message", message);
                                                                                condition.SetCell("context", context);
                                                                                condition.SetCell("receiver", on);
                                                                                condition.SetCell("text", runtime.NewText(msg));

                                                                                runtime.WithReturningRestart("ignore", context, ()=>{runtime.ErrorCondition(condition);});
                                                                            }

                                                                            File.Delete(nf);

                                                                            return context.runtime.nil;
                                                                        })));
        }
    }
}
