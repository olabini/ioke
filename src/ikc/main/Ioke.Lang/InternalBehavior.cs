namespace Ioke.Lang {
    using Ioke.Lang.Util;
    using System.Collections;
    using System.Collections.Generic;
    using System.Text;

    public class InternalBehavior {
        public static void Init(IokeObject obj) {
            Runtime runtime = obj.runtime;
            obj.Kind = "DefaultBehavior Internal";

            obj.RegisterMethod(runtime.NewNativeMethod("expects one 'strange' argument. creates a new instance of Text with the given Java String backing it.", 
                                                       new NativeMethod("internal:createText", 
                                                                        DefaultArgumentsDefinition
                                                                        .builder()
                                                                        .WithRequiredPositionalUnevaluated("text")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            outer.ArgumentsDefinition.CheckArgumentCount(context, message, on);
                                                                            object o = Message.GetArguments(message)[0];
                                                                            bool cache = true;
                                                                            if(o is IokeObject) {
                                                                                cache = false;
                                                                                o = Message.GetEvaluatedArgument(o, context);
                                                                            }
                                                                            if(o is string) {
                                                                                string s = (string)o;
                                                                                object value = runtime.NewText(new StringUtils().ReplaceEscapes(s));
                                                                                if(cache) {
                                                                                    Message.CacheValue(message, value);
                                                                                }
                                                                                return value;
                                                                            } else {
                                                                                return IokeObject.ConvertToText(o, message, context, true);
                                                                            }
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("expects one 'strange' argument. creates a new instance of Number that represents the number found in the strange argument.", 
                                                       new NativeMethod("internal:createNumber", 
                                                                        DefaultArgumentsDefinition
                                                                        .builder()
                                                                        .WithRequiredPositionalUnevaluated("number")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            outer.ArgumentsDefinition.CheckArgumentCount(context, message, on);
                                                                            object o = Message.GetArguments(message)[0];
                                                                            bool cache = true;

                                                                            if(o is IokeObject) {
                                                                                cache = false;
                                                                                o = Message.GetEvaluatedArgument(o, context);
                                                                            }
                                                                            object value = null;
                                                                            if(o is string) {
                                                                                value = runtime.NewNumber((string)o);
                                                                            } else if(o is int) {
                                                                                value = runtime.NewNumber((int)o);
                                                                            }
                                                                            
                                                                            if(cache) {
                                                                                Message.CacheValue(message, value);
                                                                            }
                                                                            return value;
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("takes zero or more arguments, calls asText on non-text arguments, and then concatenates them and returns the result.", 
                                                       new NativeMethod("internal:concatenateText", DefaultArgumentsDefinition.builder()
                                                                        .WithRest("textSegments")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            var args = new SaneArrayList();
                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, args, new SaneDictionary<string, object>());
                                                                        
                                                                            StringBuilder sb = new StringBuilder();

                                                                            foreach(object o in args) {
                                                                                if(o is IokeObject) {
                                                                                    if(IokeObject.dataOf(o) is Text) {
                                                                                        sb.Append(Text.GetText(o));
                                                                                    } else {
                                                                                        sb.Append(Text.GetText(((Message)IokeObject.dataOf(context.runtime.asText)).SendTo(context.runtime.asText, context, o)));
                                                                                    }
                                                                                } else {
                                                                                    sb.Append(o);
                                                                                }
                                                                            }

                                                                            return context.runtime.NewText(sb.ToString());
                                                                        })));
        
            obj.RegisterMethod(runtime.NewNativeMethod("takes one or more arguments. it expects the last argument to be a text of flags, while the rest of the arguments are either texts or regexps or nil. if text, it will be inserted verbatim into the result regexp. if regexp it will be inserted into a group that make sure the flags of the regexp is preserved. if nil, nothing will be inserted.", 
                                                       new NativeMethod("internal:compositeRegexp", DefaultArgumentsDefinition.builder()
                                                                        .WithRest("regexpSegments")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            var args = new SaneArrayList();
                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, args, new SaneDictionary<string, object>());

                                                                            StringBuilder sb = new StringBuilder();
                                                                            if((IokeObject.dataOf(on) is Text) || (IokeObject.dataOf(on) is Regexp)) {
                                                                                AddObject(on, sb, context);
                                                                            }
                    
                                                                            int size = args.Count;

                                                                            foreach(object o in ArrayList.Adapter(args).GetRange(0, size-1)) {
                                                                                AddObject(o, sb, context);
                                                                            }

                                                                            object f = args[size-1];
                                                                            string flags = null;
                                                                            if(f is string) {
                                                                                flags = (string)f;
                                                                            } else if(IokeObject.dataOf(f) is Text) {
                                                                                flags = Text.GetText(f);
                                                                            } else if(IokeObject.dataOf(f) is Regexp) {
                                                                                sb.Append(Regexp.GetPattern(f));
                                                                                flags = Regexp.GetFlags(f);
                                                                            }

                                                                            return context.runtime.NewRegexp(sb.ToString(), flags, context, message);
                                                                        })));
        
            obj.RegisterMethod(runtime.NewNativeMethod("expects two 'strange' arguments. creates a new mimic of Regexp with the given Java String backing it.", 
                                                       new NativeMethod("internal:createRegexp", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositionalUnevaluated("regexp")
                                                                        .WithRequiredPositionalUnevaluated("flags")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            outer.ArgumentsDefinition.CheckArgumentCount(context, message, on);
                                                                            object o = Message.GetArguments(message)[0];
                                                                            object o2 = Message.GetArguments(message)[1];
                                                                            if(o is IokeObject) {
                                                                                o = Message.GetEvaluatedArgument(o, context);
                                                                            }
                                                                            if(o2 is IokeObject) {
                                                                                o2 = Message.GetEvaluatedArgument(o2, context);
                                                                            }
                                                                            if(o is string) {
                                                                                string s = (string)o;
                                                                                return runtime.NewRegexp(new StringUtils().ReplaceRegexpEscapes(s), (string)o2, context, message);
                                                                            } else {
                                                                                return IokeObject.ConvertToRegexp(o, message, context);
                                                                            }
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("expects one 'strange' argument. creates a new instance of Decimal that represents the number found in the strange argument.", 
                                                     new NativeMethod("internal:createDecimal", DefaultArgumentsDefinition.builder()
                                                                    .WithRequiredPositionalUnevaluated("decimal")
                                                                    .Arguments,
                                                                    (method, context, message, on, outer) => {
                                                                        outer.ArgumentsDefinition.CheckArgumentCount(context, message, on);
                                                                        object o = Message.GetArguments(message)[0];
                                                                        bool cache = true;
                                                                        if(o is IokeObject) {
                                                                            cache = false;
                                                                            o = Message.GetEvaluatedArgument(o, context);
                                                                        }
                                                                        object value = runtime.NewDecimal((string)o);
                                                                        if(cache) {
                                                                            Message.CacheValue(message, value);
                                                                        }
                                                                        return value;
                                                                    })));
        }

        private static void AddRegexp(object o, StringBuilder sb) {
            string f = Regexp.GetFlags(o);
            string nflags = "";
            if(f.IndexOf("i") == -1) {
                nflags += "i";
            }
            if(f.IndexOf("x") == -1) {
                nflags += "x";
            }
            if(f.IndexOf("m") == -1) {
                nflags += "m";
            }
            if(f.IndexOf("u") == -1) {
                nflags += "u";
            }
            if(f.IndexOf("s") == -1) {
                nflags += "s";
            }
            if(nflags.Length > 0) {
                nflags = "-" + nflags;
            }
            sb.Append("(?").Append(f).Append(nflags).Append(":").Append(Regexp.GetPattern(o)).Append(")");
        }

        private static void AddText(object o, StringBuilder sb) {
            sb.Append(Text.GetText(o));
        }

        public static void AddObject(object o, StringBuilder sb, IokeObject context) {
            if(o != null) {
                if(o is string) {
                    sb.Append(o);
                } else if(IokeObject.dataOf(o) is Text) {
                    AddText(o, sb);
                } else if(IokeObject.dataOf(o) is Regexp) {
                    AddRegexp(o, sb);
                } else {
                    AddText(((Message)IokeObject.dataOf(context.runtime.asText)).SendTo(context.runtime.asText, context, o), sb);
                }
            }
        }
    }
}
