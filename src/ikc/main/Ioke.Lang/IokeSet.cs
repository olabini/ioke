
namespace Ioke.Lang {
    using System.Collections.Generic;
    using System.Text;

    using Ioke.Lang.Util;

    public class IokeSet : IokeData {
        private HashSet<object> _set;

        public IokeSet() : this(new SaneHashSet<object>()) {}
        public IokeSet(HashSet<object> s) {
            this._set = s;
        }

        public override void Init(IokeObject obj) {
            Runtime runtime = obj.runtime;

            obj.Kind = "Set";
            obj.Mimics(IokeObject.As(runtime.Mixins.GetCell(null, null, "Enumerable"), null), runtime.nul, runtime.nul);

            obj.RegisterMethod(runtime.NewNativeMethod("Returns a text inspection of the object", 
                                                       new TypeCheckingNativeMethod.WithNoArguments("inspect", obj,
                                                                                                    (method, on, args, keywords, context, message) => {
                                                                                                        return method.runtime.NewText(IokeSet.GetInspect(on));
                                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("Converts this set to use identity semantics, and then returns it.", 
                                                       new TypeCheckingNativeMethod.WithNoArguments("withIdentitySemantics!", obj,
                                                                                                    (method, on, args, keywords, context, message) => {
                                                                                                        IokeSet ss = (IokeSet)IokeObject.dataOf(on);
                                                                                                        ss._set = new SaneHashSet<object>(ss._set, new IdentityHashTable.IdentityEqualityComparer());
                                                                                                        return on;
                                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("Returns a brief text inspection of the object", 
                                                       new TypeCheckingNativeMethod.WithNoArguments("notice", obj,
                                                                                                    (method, on, args, keywords, context, message) => {
                                                                                                        return method.runtime.NewText(IokeSet.GetNotice(on));
                                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("returns true if this set is empty, false otherwise", 
                                                       new TypeCheckingNativeMethod.WithNoArguments("empty?", obj,
                                                                                                    (method, on, args, keywords, context, message) => {
                                                                                                        return ((IokeSet)IokeObject.dataOf(on)).Set.Count == 0 ? context.runtime.True : context.runtime.False;
                                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("Adds the argument to this set, if it's not already in the set. Returns the set after adding the object.", 
                                                       new TypeCheckingNativeMethod("<<", TypeCheckingArgumentsDefinition.builder()
                                                                                    .ReceiverMustMimic(obj)
                                                                                    .WithRequiredPositional("value")
                                                                                    .Arguments,
                                                                                    (method, on, args, keywords, context, message) => {
                                                                                        ((IokeSet)IokeObject.dataOf(on))._set.Add(args[0]);
                                                                                        return on;
                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("Removes the argument from the set, if it's in the set. Returns the set after removing the object.", 
                                                       new TypeCheckingNativeMethod("remove!", TypeCheckingArgumentsDefinition.builder()
                                                                                    .ReceiverMustMimic(obj)
                                                                                    .WithRequiredPositional("value")
                                                                                    .Arguments,
                                                                                    (method, on, args, keywords, context, message) => {
                                                                                        ((IokeSet)IokeObject.dataOf(on))._set.Remove(args[0]);
                                                                                        return on;
                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("returns a new set that contains the receivers elements and the elements of the set sent in as the argument.", 
                                                       new TypeCheckingNativeMethod("+", TypeCheckingArgumentsDefinition.builder()
                                                                                    .ReceiverMustMimic(obj)
                                                                                    .WithRequiredPositional("otherSet").WhichMustMimic(obj)
                                                                                    .Arguments,
                                                                                    (method, on, args, keywords, context, message) => {
                                                                                        var newSet = new SaneHashSet<object>();
                                                                                        newSet.UnionWith(((IokeSet)IokeObject.dataOf(on)).Set);
                                                                                        newSet.UnionWith(((IokeSet)IokeObject.dataOf(args[0])).Set);
                                                                                        return context.runtime.NewSet(newSet);
                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("returns true if the receiver includes the evaluated argument, otherwise false", 
                                                       new TypeCheckingNativeMethod("include?", TypeCheckingArgumentsDefinition.builder()
                                                                                    .ReceiverMustMimic(obj)
                                                                                    .WithRequiredPositional("object")
                                                                                    .Arguments,
                                                                                    (method, on, args, keywords, context, message) => {
                                                                                        return ((IokeSet)IokeObject.dataOf(on)).Set.Contains(args[0]) ? context.runtime.True : context.runtime.False;
                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("takes either one, two or three arguments. if one argument is given, it should be a message chain that will be sent to each object in the set. the result will be thrown away. if two arguments are given, the first is an unevaluated name that will be set to each of the values in the set in succession, and then the second argument will be evaluated in a scope with that argument in it. if three arguments is given, the first one is an unevaluated name that will be set to the index of each element, and the other two arguments are the name of the argument for the value, and the actual code. the code will evaluate in a lexical context, and if the argument name is available outside the context, it will be shadowed. the method will return the set. the iteration order is not defined.", 
                                                       new NativeMethod("each", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositionalUnevaluated("indexOrArgOrCode")
                                                                        .WithOptionalPositionalUnevaluated("argOrCode")
                                                                        .WithOptionalPositionalUnevaluated("code")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            outer.ArgumentsDefinition.CheckArgumentCount(context, message, on);

                                                                            object onAsSet = context.runtime.Set.ConvertToThis(on, message, context);
                                                                            var _set = ((IokeSet)IokeObject.dataOf(onAsSet))._set;

                                                                            switch(message.Arguments.Count) {
                                                                            case 1: {
                                                                                IokeObject code = IokeObject.As(message.Arguments[0], context);

                                                                                foreach(object o in _set) {
                                                                                    ((Message)IokeObject.dataOf(code)).EvaluateCompleteWithReceiver(code, context, context.RealContext, o);
                                                                                }
                                                                                break;
                                                                            }
                                                                            case 2: {
                                                                                LexicalContext c = new LexicalContext(context.runtime, context, "Lexical activation context for Set#each", message, context);
                                                                                string name = IokeObject.As(message.Arguments[0], context).Name;
                                                                                IokeObject code = IokeObject.As(message.Arguments[1], context);

                                                                                foreach(object o in _set) {
                                                                                    c.SetCell(name, o);
                                                                                    ((Message)IokeObject.dataOf(code)).EvaluateCompleteWithoutExplicitReceiver(code, c, c.RealContext);
                                                                                }
                                                                                break;
                                                                            }
                                                                            case 3: {
                                                                                LexicalContext c = new LexicalContext(context.runtime, context, "Lexical activation context for Set#each", message, context);
                                                                                string iname = IokeObject.As(message.Arguments[0], context).Name;
                                                                                string name = IokeObject.As(message.Arguments[1], context).Name;
                                                                                IokeObject code = IokeObject.As(message.Arguments[2], context);

                                                                                int index = 0;
                                                                                foreach(object o in _set) {
                                                                                    c.SetCell(name, o);
                                                                                    c.SetCell(iname, runtime.NewNumber(index++));
                                                                                    ((Message)IokeObject.dataOf(code)).EvaluateCompleteWithoutExplicitReceiver(code, c, c.RealContext);
                                                                                }
                                                                                break;
                                                                            }
                                                                            }

                                                                            return onAsSet;
                                                                        })));
        }

        public HashSet<object> Set {
            get { return _set; }
        }

        public override IokeData CloneData(IokeObject obj, IokeObject m, IokeObject context) {
            return new IokeSet(new SaneHashSet<object>(_set));
        }

        public override bool IsEqualTo(IokeObject self, object other) {
            return ((other is IokeObject) && 
                    (IokeObject.dataOf(other) is IokeSet) 
                    && this._set.Equals(((IokeSet)IokeObject.dataOf(other))._set));
        }

        public override int HashCode(IokeObject self) {
            return this._set.GetHashCode();
        }

        public override string ToString() {
            return _set.ToString();
        }

        public override string ToString(IokeObject obj) {
            return _set.ToString();
        }
        
        public static string GetInspect(object on) {
            return ((IokeSet)(IokeObject.dataOf(on))).Inspect(on);
        }

        public static string GetNotice(object on) {
            return ((IokeSet)(IokeObject.dataOf(on))).Notice(on);
        }

        public string Inspect(object obj) {
            StringBuilder sb = new StringBuilder();
            sb.Append("set(");
            string sep = "";
            foreach(object o in _set) {
                sb.Append(sep).Append(IokeObject.Inspect(o));
                sep = ", ";
            }
            sb.Append(")");
            return sb.ToString();
        }

        public string Notice(object obj) {
            StringBuilder sb = new StringBuilder();
            sb.Append("set(");
            string sep = "";
            foreach(object o in _set) {
                sb.Append(sep).Append(IokeObject.Notice(o));
                sep = ", ";
            }
            sb.Append(")");
            return sb.ToString();
        }
    }
}
