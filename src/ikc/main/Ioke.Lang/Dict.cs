
namespace Ioke.Lang {
    using System.Collections;
    using System.Text;

    using Ioke.Lang.Util;

    public class Dict : IokeData {
        IDictionary dict;
        IokeObject defaultValue;

        public Dict() : this(new SaneHashtable()) {}

        public Dict(IDictionary d) {
            this.dict = d;
        }

        public static IDictionary GetMap(object dict) {
            return ((Dict)IokeObject.dataOf(dict)).Map;
        }
        
        public IDictionary Map {
            get { return this.dict; }
        }

        public static IokeObject GetDefaultValue(object on, IokeObject context, IokeObject message) {
            Dict dict = (Dict)IokeObject.dataOf(on);
            if(dict.defaultValue == null) {
                return context.runtime.nil;
            } else {
                return dict.defaultValue;
            }
        }

        public static void SetDefaultValue(object on, IokeObject defaultValue) {
            Dict dict = (Dict)IokeObject.dataOf(on);
            dict.defaultValue = defaultValue;
        }

        public override void Init(IokeObject obj) {
            Runtime runtime = obj.runtime;

            obj.Kind = "Dict";
            obj.Mimics(IokeObject.As(runtime.Mixins.GetCell(null, null, "Enumerable"), null), runtime.nul, runtime.nul);
            obj.RegisterMethod(runtime.NewNativeMethod("takes one argument, that should be a default value, and returns a new mimic of the receiver, with the default value for that new dict set to the argument", 
                                                       new TypeCheckingNativeMethod("withDefault", TypeCheckingArgumentsDefinition.builder()
                                                                                    .ReceiverMustMimic(obj)
                                                                                    .WithRequiredPositional("defaultValue")
                                                                                    .Arguments,
                                                                                    (method, on, args, keywords, context, message) => {
                                                                                        object newDict = IokeObject.Mimic(on, message, context);
                                                                                        SetDefaultValue(newDict, IokeObject.As(args[0], context));
                                                                                        return newDict;
                                                                                    })));
            
            obj.RegisterMethod(runtime.NewNativeMethod("creates a new Dict from the arguments provided, combined with the values in the receiver. the arguments provided will override those in the receiver. the rules for arguments are the same as for dict, except that dicts can also be provided. all positional arguments will be added before the keyword arguments.", 
                                                       new TypeCheckingNativeMethod("merge", TypeCheckingArgumentsDefinition.builder()
                                                                                    .ReceiverMustMimic(obj)
                                                                                    .WithRest("pairsAndDicts")
                                                                                    .WithKeywordRest("keywordPairs")
                                                                                    .Arguments,
                                                                                    (method, on, args, keywords, context, message) => {
                                                                                        var newMap = new SaneHashtable();
                                                                                        foreach(DictionaryEntry de in GetMap(on)) newMap[de.Key] = de.Value;

                                                                                        foreach(object o in args) {
                                                                                            if(IokeObject.dataOf(o) is Dict) {
                                                                                                foreach(DictionaryEntry de in GetMap(o)) newMap[de.Key] = de.Value;
                                                                                            } else if(IokeObject.dataOf(o) is Pair) {
                                                                                                newMap[Pair.GetFirst(o)] = Pair.GetSecond(o);
                                                                                            } else {
                                                                                                newMap[o] = context.runtime.nil;
                                                                                            }
                                                                                        }
                                                                                        foreach(var entry in keywords) {
                                                                                            string s = entry.Key;
                                                                                            object key = context.runtime.GetSymbol(s.Substring(0, s.Length-1));
                                                                                            object value = entry.Value;
                                                                                            if(value == null) {
                                                                                                value = context.runtime.nil;
                                                                                            }
                                                                                            newMap[key] = value;
                                                                                        }

                                                                                        return context.runtime.NewDict(newMap);
                                                                                    })));

            obj.AliasMethod("merge", "+", null, null);

            obj.RegisterMethod(runtime.NewNativeMethod("takes one argument, the key of the element to return. if the key doesn't map to anything in the dict, returns the default value", 
                                                       new TypeCheckingNativeMethod("at", TypeCheckingArgumentsDefinition.builder()
                                                                                    .ReceiverMustMimic(obj)
                                                                                    .WithRequiredPositional("key")
                                                                                    .Arguments,
                                                                                    (method, on, args, keywords, context, message) => {
                                                                                        object result = Dict.GetMap(on)[args[0]];
                                                                                        if(result == null) {
                                                                                            return GetDefaultValue(on, context, message);
                                                                                        } else {
                                                                                            return result;
                                                                                        }
                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("returns true if this dict is empty, false otherwise", 
                                                       new TypeCheckingNativeMethod.WithNoArguments("empty?", obj, 
                                                                                                    (method, on, args, keywords, context, message) => {
                                                                                                        return Dict.GetMap(on).Count == 0 ? context.runtime.True : context.runtime.False;
                                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("takes one argument, the key to check if it is in the dict.", 
                                                       new TypeCheckingNativeMethod("key?", TypeCheckingArgumentsDefinition.builder()
                                                                                    .ReceiverMustMimic(obj)
                                                                                    .WithRequiredPositional("key")
                                                                                    .Arguments,
                                                                                    (method, on, args, keywords, context, message) => {
                                                                                        return (Dict.GetMap(on).Contains(args[0])) ? context.runtime.True : context.runtime.False;
                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("takes two arguments, the key of the element to set and the value to set it too. returns the value set", 
                                                       new TypeCheckingNativeMethod("[]=", TypeCheckingArgumentsDefinition.builder()
                                                                                    .ReceiverMustMimic(obj)
                                                                                    .WithRequiredPositional("key")
                                                                                    .WithRequiredPositional("value")
                                                                                    .Arguments,
                                                                                    (method, on, args, keywords, context, message) => {
                                                                                        Dict.GetMap(on)[args[0]] = args[1];
                                                                                        return args[1];
                                                                                    })));


            obj.RegisterMethod(runtime.NewNativeMethod("Returns the number of pairs contained in this dict.", 
                                                       new TypeCheckingNativeMethod.WithNoArguments("size", obj,
                                                                                                    (method, on, args, keywords, context, message) => {
                                                                                                        return runtime.NewNumber(Dict.GetMap(on).Count);
                                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("Returns a text inspection of the object", 
                                                       new TypeCheckingNativeMethod.WithNoArguments("inspect", obj,
                                                                                                    (method, on, args, keywords, context, message) => {
                                                                                                        return method.runtime.NewText(Dict.GetInspect(on));
                                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("Returns a brief text inspection of the object", 
                                                       new TypeCheckingNativeMethod.WithNoArguments("notice", obj,
                                                                                                    (method, on, args, keywords, context, message) => {
                                                                                                        return method.runtime.NewText(Dict.GetNotice(on));
                                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("Returns all the keys of this dict", 
                                                       new TypeCheckingNativeMethod.WithNoArguments("keys", obj,
                                                                                                    (method, on, args, keywords, context, message) => {
                                                                                                        return method.runtime.NewSet(Dict.GetKeys(on));
                                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("takes either one or two or three arguments. if one argument is given, it should be a message chain that will be sent to each object in the dict. the result will be thrown away. if two arguments are given, the first is an unevaluated name that will be set to each of the entries in the dict in succession, and then the second argument will be evaluated in a scope with that argument in it. if three arguments is given, the first one is an unevaluated name that will be set to the index of each element, and the other two arguments are the name of the argument for the value, and the actual code. the code will evaluate in a lexical context, and if the argument name is available outside the context, it will be shadowed. the method will return the dict. the entries yielded will be mimics of Pair.", 
                                                       new NativeMethod("each", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositionalUnevaluated("indexOrArgOrCode")
                                                                        .WithOptionalPositionalUnevaluated("argOrCode")
                                                                        .WithOptionalPositionalUnevaluated("code")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            outer.ArgumentsDefinition.CheckArgumentCount(context, message, on);
                                                                            on = runtime.Dict.ConvertToThis(on, message, context);
                    
                                                                            var ls = Dict.GetMap(on);
                                                                            switch(message.Arguments.Count) {
                                                                            case 1: {
                                                                                IokeObject code = IokeObject.As(message.Arguments[0], context);

                                                                                foreach(DictionaryEntry o in ls) {
                                                                                    ((Message)IokeObject.dataOf(code)).EvaluateCompleteWithReceiver(code, context, context.RealContext, runtime.NewPair(o.Key, o.Value));
                                                                                }
                                                                                break;
                                                                            }
                                                                            case 2: {
                                                                                LexicalContext c = new LexicalContext(context.runtime, context, "Lexical activation context for List#each", message, context);
                                                                                string name = IokeObject.As(message.Arguments[0], context).Name;
                                                                                IokeObject code = IokeObject.As(message.Arguments[1], context);

                                                                                foreach(DictionaryEntry o in ls) {
                                                                                    c.SetCell(name, runtime.NewPair(o.Key, o.Value));
                                                                                    ((Message)IokeObject.dataOf(code)).EvaluateCompleteWithoutExplicitReceiver(code, c, c.RealContext);
                                                                                }
                                                                                break;
                                                                            }
                                                                            case 3: {
                                                                                LexicalContext c = new LexicalContext(context.runtime, context, "Lexical activation context for List#each", message, context);
                                                                                string iname = IokeObject.As(message.Arguments[0], context).Name;
                                                                                string name = IokeObject.As(message.Arguments[1], context).Name;
                                                                                IokeObject code = IokeObject.As(message.Arguments[2], context);

                                                                                int index = 0;
                                                                                foreach(DictionaryEntry o in ls) {
                                                                                    c.SetCell(name, runtime.NewPair(o.Key, o.Value));
                                                                                    c.SetCell(iname, runtime.NewNumber(index++));
                                                                                    ((Message)IokeObject.dataOf(code)).EvaluateCompleteWithoutExplicitReceiver(code, c, c.RealContext);
                                                                                }
                                                                                break;
                                                                            }
                                                                            }
                                                                            return on;
                                                                        })));
        }

        public static ICollection GetKeys(object dict) {
            return ((Dict)IokeObject.dataOf(dict)).Map.Keys;
        }

        public override IokeData CloneData(IokeObject obj, IokeObject m, IokeObject context) {
            return new Dict(new SaneHashtable(dict));
        }

        public override bool IsEqualTo(IokeObject self, object other) {
            return ((other is IokeObject) && 
                    (IokeObject.dataOf(other) is Dict) 
                    && this.dict.Equals(((Dict)IokeObject.dataOf(other)).dict));
        }

        public override int HashCode(IokeObject self) {
            return this.dict.GetHashCode();
        }

        public override string ToString() {
            return dict.ToString();
        }

        public override string ToString(IokeObject obj) {
            return dict.ToString();
        }

        public static string GetInspect(object on) {
            return ((Dict)(IokeObject.dataOf(on))).Inspect(on);
        }

        public static string GetNotice(object on) {
            return ((Dict)(IokeObject.dataOf(on))).Notice(on);
        }

        public string Inspect(object obj) {
            StringBuilder sb = new StringBuilder();
            sb.Append("{");
            string sep = "";

            foreach(DictionaryEntry o in dict) {
                sb.Append(sep);
                object key = o.Key;

                if((IokeObject.dataOf(key) is Symbol) && Symbol.OnlyGoodChars(key)) {
                    sb.Append(Symbol.GetText(key)).Append(": ");
                } else {
                    sb.Append(IokeObject.Inspect(key)).Append(" => ");
                }

                sb.Append(IokeObject.Inspect(o.Value));
                sep = ", ";
            }

            sb.Append("}");
            return sb.ToString();
        }

        public string Notice(object obj) {
            StringBuilder sb = new StringBuilder();
            sb.Append("{");
            string sep = "";

            foreach(DictionaryEntry o in dict) {
                sb.Append(sep);
                object key = o.Key;

                if((IokeObject.dataOf(key) is Symbol) && Symbol.OnlyGoodChars(key)) {
                    sb.Append(Symbol.GetText(key)).Append(": ");
                } else {
                    sb.Append(IokeObject.Notice(key)).Append(" => ");
                }

                sb.Append(IokeObject.Notice(o.Value));
                sep = ", ";
            }

            sb.Append("}");
            return sb.ToString();
        }
    }
}
