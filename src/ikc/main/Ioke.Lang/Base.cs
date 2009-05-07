namespace Ioke.Lang {
    using Ioke.Lang.Util;
    using System.Collections;
    using System.Collections.Generic;
    using System.Collections.Specialized;

    public class Base {
        public static object CellNames(IokeObject context, IokeObject message, object on, bool includeMimics, object cutoff) {
            if(includeMimics) {
                var visited = IdentityHashTable.Create();
                var names = new SaneArrayList();
                var visitedNames = new SaneHashSet<object>();
                var undefined = new SaneHashSet<string>();
                Runtime runtime = context.runtime;
                var toVisit = new SaneArrayList();
                toVisit.Add(on);

                while(toVisit.Count > 0) {
                    IokeObject current = IokeObject.As(toVisit[0], context);
                    toVisit.RemoveAt(0);
                    if(!visited.Contains(current)) {
                        visited[current] = null;
                        if(cutoff != current) {
                            foreach(IokeObject o in current.GetMimics()) toVisit.Add(o);
                        }
                                
                        var mso = current.Cells;

                        foreach(string s in mso.Keys) {
                            if(!undefined.Contains(s)) {
                                if(mso[s] == runtime.nul) {
                                    undefined.Add(s);
                                } else {
                                    object x = runtime.GetSymbol(s);
                                    if(!visitedNames.Contains(x)) {
                                        visitedNames.Add(x);
                                        names.Add(x);
                                    }
                                }
                            }
                        }
                    }
                }
                        
                return runtime.NewList(names);
            } else {
                var mso = IokeObject.As(on, context).Cells;
                var names = new SaneArrayList();
                Runtime runtime = context.runtime;

                foreach(string s in mso.Keys) {
                    if(mso[s] != runtime.nul) {
                        names.Add(runtime.GetSymbol(s));
                    }
                }

                return runtime.NewList(names);
            }
        }

        public static object Cells(IokeObject context, IokeObject message, object on, bool includeMimics) {
            var cells = new SaneOrderedDictionary();
            Runtime runtime = context.runtime;

            if(includeMimics) {
                var visited = IdentityHashTable.Create();
                var undefined = new SaneHashSet<string>();
                var toVisit = new SaneArrayList();
                toVisit.Add(on);

                while(toVisit.Count > 0) {
                    IokeObject current = IokeObject.As(toVisit[0], context);
                    toVisit.RemoveAt(0);
                    if(!visited.Contains(current)) {
                        visited[current] = null;
                        foreach(IokeObject o in current.GetMimics()) toVisit.Add(o);
                        var mso = current.Cells;

                        foreach(string s in mso.Keys) {
                            if(!undefined.Contains(s)) {
                                object val = mso[s];
                                if(val == runtime.nul) {
                                    undefined.Add(s);
                                } else {
                                    object x = runtime.GetSymbol(s);
                                    if(!cells.Contains(x)) {
                                        cells[x] = val;
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                var mso = IokeObject.As(on, context).Cells;

                foreach(string s in mso.Keys) {
                    object val = mso[s];
                    if(val != runtime.nul) {
                        cells[runtime.GetSymbol(s)] = val;
                    }
                }
            }
            return runtime.NewDict(cells);
        }

        public static object AssignCell(IokeObject context, IokeObject message, object on, object first, object val) {
            string name = Text.GetText(((Message)IokeObject.dataOf(context.runtime.asText)).SendTo(context.runtime.asText, context, first));
            
            if(val is IokeObject) {
                if((IokeObject.dataOf(val) is Named) && ((Named)IokeObject.dataOf(val)).Name == null) {
                    ((Named)IokeObject.dataOf(val)).Name = name;
                } else if(name.Length > 0 && char.IsUpper(name[0]) && !IokeObject.As(val, context).HasKind) {
                    if(on == context.runtime.Ground) {
                        IokeObject.As(val, context).Kind = name;
                    } else {
                        IokeObject.As(val, context).Kind = IokeObject.As(on, context).GetKind(message, context) + " " + name;
                    }
                }
            }

            return IokeObject.SetCell(on, message, context, name, val);
        }

        public static object Documentation(IokeObject context, IokeObject message, object on) {
            string docs = IokeObject.As(on, context).Documentation;
            if(null == docs) {
                return context.runtime.nil;
            }
            return context.runtime.NewText(docs);
        }

        public static object SetDocumentation(IokeObject context, IokeObject message, object on, object arg) {
            if(arg == context.runtime.nil) {
                IokeObject.As(on, context).SetDocumentation(null, message, context);
            } else {
                string s = Text.GetText(arg);
                IokeObject.As(on, context).SetDocumentation(s, message, context);
            }
            return arg;
        }

        public static void Init(IokeObject obj) {
            obj.Kind = "Base";

            obj.RegisterMethod(obj.runtime.NewNativeMethod("expects two arguments, the first unevaluated, the second evaluated. assigns the result of evaluating the second argument in the context of the caller, and assigns this result to the name provided by the first argument. the first argument remains unevaluated. the result of the assignment is the value assigned to the name. if the second argument is a method-like object and it's name is not set, that name will be set to the name of the cell. TODO: add setf documentation here.", 
                                                           new NativeMethod("=", DefaultArgumentsDefinition.builder()
                                                                            .WithRequiredPositionalUnevaluated("place")
                                                                            .WithRequiredPositional("value")
                                                                            .Arguments,
                                                                            (method, context, message, on, outer) => {
                                                                                outer.ArgumentsDefinition.CheckArgumentCount(context, message, on);
                                                                                IokeObject m1 = IokeObject.As(Message.GetArguments(message)[0], context);
                                                                                string name = m1.Name;
                                                                                if(m1.Arguments.Count == 0) {
                                                                                    object value = ((Message)IokeObject.dataOf(message)).GetEvaluatedArgument(message, 1, context);
                                                                                    IokeObject.Assign(on, name, value, context, message);

                                                                                    if(value is IokeObject) {
                                                                                        if((IokeObject.dataOf(value) is Named) && ((Named)IokeObject.dataOf(value)).Name == null) {
                                                                                            ((Named)IokeObject.dataOf(value)).Name = name;
                                                                                        } else if(name.Length > 0 && char.IsUpper(name[0]) && !(IokeObject.As(value, context).HasKind)) {
                                                                                            if(on == context.runtime.Ground || on == context.runtime.IokeGround) {
                                                                                                IokeObject.As(value, context).Kind = name;
                                                                                            } else {
                                                                                                IokeObject.As(value, context).Kind = IokeObject.As(on, context).GetKind(message, context) + " " + name;
                                                                                            }
                                                                                        }
                                                                                    }
                    
                                                                                    return value;
                                                                                } else {
                                                                                    string newName = name + "=";
                                                                                    IList arguments = new SaneArrayList(m1.Arguments);
                                                                                    arguments.Add(Message.GetArguments(message)[1]);
                                                                                    IokeObject msg = context.runtime.NewMessageFrom(message, newName, arguments);
                                                                                    return ((Message)IokeObject.dataOf(msg)).SendTo(msg, context, on);
                                                                                }
                                                                            })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("will return a new derivation of the receiving object. Might throw exceptions if the object is an oddball object.", 
                                                           new NativeMethod.WithNoArguments("mimic", (method, context, message, on, outer) => {
                                                                   outer.ArgumentsDefinition.CheckArgumentCount(context, message, on);
                                                                   return IokeObject.As(on, context).Mimic(message, context);
                                                               })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("expects one evaluated text or symbol argument that names the cell to set, sets this cell to the result of evaluating the second argument, and returns the value set.", 
                                                           new NativeMethod("cell=",
                                                                            DefaultArgumentsDefinition
                                                                            .builder()
                                                                            .WithRequiredPositional("cellName")
                                                                            .WithRequiredPositional("value")
                                                                            .Arguments,
                                                                            (method, context, message, on, outer) => {
                                                                                var args = new SaneArrayList();
                                                                                outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, args, new SaneDictionary<string, object>());
                                                                                return AssignCell(context, message, on, args[0], args[1]);
                                                                            })));
        obj.RegisterMethod(obj.runtime.NewNativeMethod("expects one evaluated text or symbol argument and returns the cell that matches that name, without activating even if it's activatable.", 
                                                       new NativeMethod("cell", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositional("cellName")
                                                                        .Arguments,
                                                                            (method, context, message, on, outer) => {
                                                                                var args = new SaneArrayList();
                                                                                outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, args, new SaneDictionary<string, object>());
                                                                                string name = Text.GetText(((Message)IokeObject.dataOf(context.runtime.asText)).SendTo(context.runtime.asText, context, args[0]));
                                                                                return IokeObject.GetCell(on, message, context, name);
                                                                        })));
        
        obj.RegisterMethod(obj.runtime.NewNativeMethod("returns true if the left hand side is equal to the right hand side. exactly what this means depend on the object. the default behavior of Ioke objects is to only be equal if they are the same instance.", 
                                                       new NativeMethod("==", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositional("other")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            IList args = new SaneArrayList();
                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, args, new SaneDictionary<string, object>());
                                                                            return IokeObject.Equals(on, args[0]) ? context.runtime.True : context.runtime.False;
                                                                        })));
        obj.RegisterMethod(obj.runtime.NewNativeMethod("expects one evaluated text or symbol argument and returns a boolean indicating whether such a cell is reachable from this point.", 
                                                       new NativeMethod("cell?", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositional("cellName")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            IList args = new SaneArrayList();
                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, args, new SaneDictionary<string, object>());

                                                                            string name = Text.GetText(((Message)IokeObject.dataOf(context.runtime.asText)).SendTo(context.runtime.asText, context, args[0]));
                                                                            return IokeObject.FindCell(on, message, context, name) != context.runtime.nul ? context.runtime.True : context.runtime.False;
                                                                        })));

        obj.RegisterMethod(obj.runtime.NewNativeMethod("returns the documentation text of the object called on. anything can have a documentation text - this text will initially be nil.", 
                                                       new NativeMethod.WithNoArguments("documentation",
                                                                                        (method, context, message, on, outer) => {
                                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, new SaneArrayList(), new SaneDictionary<string, object>());
                                                                                            return Documentation(context, message, on);
                                                                                        })));

        obj.RegisterMethod(obj.runtime.NewNativeMethod("returns this object", 
                                                       new NativeMethod.WithNoArguments("identity",
                                                                                        (method, context, message, on, outer) => {
                                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, new SaneArrayList(), new SaneDictionary<string, object>());
                                                                                            return on;
                                                                                        })));

        obj.RegisterMethod(obj.runtime.NewNativeMethod("sets the documentation string for a specific object.", 
                                                       new TypeCheckingNativeMethod("documentation=", TypeCheckingArgumentsDefinition.builder()
                                                                                    .WithRequiredPositional("text").WhichMustMimic(obj.runtime.Text).OrBeNil()
                                                                                    .Arguments,
                                                                                    (method, on, args, keywords, context, message) => {
                                                                                        return SetDocumentation(context, message, on, args[0]);
                                                                                    })));

        obj.RegisterMethod(obj.runtime.NewNativeMethod("expects one evaluated text or symbol argument and returns a boolean indicating whether this cell is owned by the receiver or not. the assumption is that the cell should exist. if it doesn't exist, a NoSuchCell condition will be signalled.", 
                                                       new NativeMethod("cellOwner?", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositional("cellName")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            var args = new SaneArrayList();
                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, args, new SaneDictionary<string, object>());
                                                                            string name = Text.GetText(((Message)IokeObject.dataOf(context.runtime.asText)).SendTo(context.runtime.asText, context, args[0]));
                                                                            return (IokeObject.FindPlace(on, message, context, name) == on) ? context.runtime.True : context.runtime.False;
                                                                        })));

        obj.RegisterMethod(obj.runtime.NewNativeMethod("expects one evaluated text or symbol argument and returns the closest object that defines such a cell. if it doesn't exist, a NoSuchCell condition will be signalled.", 
                                                       new NativeMethod("cellOwner", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositional("cellName")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            var args = new SaneArrayList();
                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, args, new SaneDictionary<string, object>());
                                                                            string name = Text.GetText(((Message)IokeObject.dataOf(context.runtime.asText)).SendTo(context.runtime.asText, context, args[0]));
                                                                            object result = IokeObject.FindPlace(on, message, context, name);
                                                                            if(result == context.runtime.nul) {
                                                                                return context.runtime.nil;
                                                                            }
                                                                            return result;
                                                                        })));

        obj.RegisterMethod(obj.runtime.NewNativeMethod("expects one evaluated text or symbol argument and removes that cell from the current receiver. if the current receiver has no such object, signals a condition. note that if another cell with that name is available in the mimic chain, it will still be accessible after calling this method. the method returns the receiver.", 
                                                       new NativeMethod("removeCell!", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositional("cellName")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            var args = new SaneArrayList();
                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, args, new SaneDictionary<string, object>());
                                                                            string name = Text.GetText(((Message)IokeObject.dataOf(context.runtime.asText)).SendTo(context.runtime.asText, context, args[0]));
                                                                            IokeObject.RemoveCell(on, message, context, name);
                                                                            return on;
                                                                        })));

        obj.RegisterMethod(obj.runtime.NewNativeMethod("expects one evaluated text or symbol argument and makes that cell undefined in the current receiver. what that means is that from now on it will look like this cell doesn't exist in the receiver or any of its mimics. the cell will not show up if you call cellNames on the receiver or any of the receivers mimics. the undefined status can be removed by doing removeCell! on the correct cell name. a cell name that doesn't exist can still be undefined. the method returns the receiver.", 
                                                       new NativeMethod("undefineCell!", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositional("cellName")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            var args = new SaneArrayList();
                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, args, new SaneDictionary<string, object>());
                                                                            string name = Text.GetText(((Message)IokeObject.dataOf(context.runtime.asText)).SendTo(context.runtime.asText, context, args[0]));
                                                                            IokeObject.UndefineCell(on, message, context, name);
                                                                            return on;
                                                                        })));

        obj.RegisterMethod(obj.runtime.NewNativeMethod("takes one optional evaluated boolean argument, which defaults to false. if false, this method returns a list of the cell names of the receiver. if true, it returns the cell names of this object and all it's mimics recursively.", 
                                                       new NativeMethod("cellNames", DefaultArgumentsDefinition.builder()
                                                                        .WithOptionalPositional("includeMimics", "false")
                                                                        .WithOptionalPositional("cutoff", "nil")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            var args = new SaneArrayList();
                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, args, new SaneDictionary<string, object>());
                                                                            return CellNames(context, message, on, args.Count > 0 && IokeObject.IsObjectTrue(args[0]), (args.Count > 1) ? args[1] : null);
                                                                        })));

        obj.RegisterMethod(obj.runtime.NewNativeMethod("takes one optional evaluated boolean argument, which defaults to false. if false, this method returns a dict of the cell names and values of the receiver. if true, it returns the cell names and values of this object and all it's mimics recursively.", 
                                                       new NativeMethod("cells", DefaultArgumentsDefinition.builder()
                                                                        .WithOptionalPositional("includeMimics", "false")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            var args = new SaneArrayList();
                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, args, new SaneDictionary<string, object>());
                                                                            return Cells(context, message, on, args.Count > 0 && IokeObject.IsObjectTrue(args[0]));
                                                                        })));
        }
    }
}
