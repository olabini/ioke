
namespace Ioke.Lang {
    using System.Collections;
    using NRegex;

    using Ioke.Lang.Util;

    public class Regexp : IokeData {
        string pattern;
        Pattern regexp;
        string flags;

        Regexp(string pattern, Pattern regexp, string flags) {
            this.pattern = pattern;
            this.regexp = regexp;
            this.flags = flags;
        }

        public static Regexp Create(string pattern, string flags, IokeObject context, IokeObject message) {
            try {
                return new Regexp(pattern, new Pattern(pattern, flags), flags);
            } catch(System.Exception e) {
                System.Console.Error.WriteLine(e.StackTrace);
                return null;
            }
        }

        internal static Regexp Create(string pattern, string flags) {
            try {
                return new Regexp(pattern, new Pattern(pattern, flags), flags);
            } catch(System.Exception e) {
                System.Console.Error.WriteLine(e.StackTrace);
                return null;
            }
        }

        public static string GetPattern(object on) {
            return ((Regexp)IokeObject.dataOf(on)).pattern;
        }

        public static Pattern GetRegexp(object on) {
            return ((Regexp)IokeObject.dataOf(on)).regexp;
        }

        public static string GetFlags(object on) {
            return ((Regexp)IokeObject.dataOf(on)).flags;
        }

        public override void Init(IokeObject obj) {
            Runtime runtime = obj.runtime;
            obj.Kind = "Regexp";

            IokeObject regexpMatch  = new IokeObject(runtime, "contains behavior related to assignment", new RegexpMatch(obj, null, null));
            regexpMatch.MimicsWithoutCheck(runtime.Origin);
            regexpMatch.Init();
            obj.RegisterCell("Match", regexpMatch);

            obj.RegisterMethod(runtime.NewNativeMethod("Returns the pattern use for this regular expression", 
                                                       new TypeCheckingNativeMethod.WithNoArguments("pattern", obj,
                                                                                                    (method, on, args, keywords, context, message) => {
                                                                                                        return context.runtime.NewText(GetPattern(on));
                                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("Takes one argument and tries to match that argument against the current pattern. Returns nil if no match can be done, or a Regexp Match object if a match succeeds", 
                                                       new TypeCheckingNativeMethod("match", TypeCheckingArgumentsDefinition.builder()
                                                                                    .ReceiverMustMimic(obj)
                                                                                    .WithRequiredPositional("other")
                                                                                    .Arguments,
                                                                                    (method, on, args, keywords, context, message) => {
                                                                                        IokeObject target = IokeObject.As(((Message)IokeObject.dataOf(context.runtime.asText)).SendTo(context.runtime.asText, context, args[0]), context);
                                                                                        string arg = Text.GetText(target);
                                                                                        Matcher m = ((Regexp)IokeObject.dataOf(on)).regexp.Matcher(arg);
                    
                                                                                        if(m.Find()) {
                                                                                            IokeObject match = regexpMatch.AllocateCopy(message, context);
                                                                                            match.MimicsWithoutCheck(regexpMatch);
                                                                                            match.Data = new RegexpMatch(IokeObject.As(on, context), m, target);
                                                                                            return match;
                                                                                        } else {
                                                                                            return context.runtime.nil;
                                                                                        }
                                                                                    })));

            obj.AliasMethod("match", "=~", null, null);

            obj.RegisterMethod(runtime.NewNativeMethod("Takes one argument that should be a text and returns a text that has all regexp meta characters quoted", 
                                                       new NativeMethod("quote", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositional("text")
                                                                        .Arguments,
                                                                        (method, on, args, keywords, context, message) => {
                                                                            return context.runtime.NewText(Pattern.Quote(Text.GetText(((Message)IokeObject.dataOf(context.runtime.asText)).SendTo(context.runtime.asText, context, args[0]))));
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("Takes one or two text arguments that describes the regular expression to create. the first text is the pattern and the second is the flags.", 
                                                       new NativeMethod("from", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositional("pattern")
                                                                        .WithOptionalPositional("flags", "")
                                                                        .Arguments,
                                                                        (method, on, args, keywords, context, message) => {
                                                                            string pattern = Text.GetText(((Message)IokeObject.dataOf(context.runtime.asText)).SendTo(context.runtime.asText, context, args[0]));
                                                                            string flags = "";
                                                                            if(args.Count > 1) {
                                                                                flags = Text.GetText(((Message)IokeObject.dataOf(context.runtime.asText)).SendTo(context.runtime.asText, context, args[1]));
                                                                            }

                                                                            return context.runtime.NewRegexp(pattern, flags, context, message);
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("Takes one argument and tries to match that argument against the current pattern. Returns a list of all the texts that were matched.", 
                                                       new TypeCheckingNativeMethod("allMatches", TypeCheckingArgumentsDefinition.builder()
                                                                                    .ReceiverMustMimic(obj)
                                                                                    .WithRequiredPositional("other")
                                                                                    .Arguments,
                                                                                    (method, on, args, keywords, context, message) => {
                                                                                        string arg = Text.GetText(((Message)IokeObject.dataOf(context.runtime.asText)).SendTo(context.runtime.asText, context, args[0]));
                                                                                        Matcher m = ((Regexp)IokeObject.dataOf(on)).regexp.Matcher(arg);

                                                                                        var result = new SaneArrayList();
                                                                                        MatchIterator iter = m.FindAll();
                                                                                        while(iter.HasMore) {
                                                                                            result.Add(runtime.NewText(iter.NextMatch.Group(0)));
                                                                                        }
                    
                                                                                        return runtime.NewList(result);
                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("Returns a text inspection of the object", 
                                                       new TypeCheckingNativeMethod.WithNoArguments("inspect", obj,
                                                                                                    (method, on, args, keywords, context, message) => {
                                                                                                        return method.runtime.NewText(Regexp.GetInspect(on));
                                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("Returns a brief text inspection of the object", 
                                                       new TypeCheckingNativeMethod.WithNoArguments("notice", obj,
                                                                                                    (method, on, args, keywords, context, message) => {
                                                                                                        return method.runtime.NewText(Regexp.GetNotice(on));
                                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("returns a list of all the named groups in this regular expression", 
                                                       new TypeCheckingNativeMethod.WithNoArguments("names", obj,
                                                                                                    (method, on, args, keywords, context, message) => {
                                                                                                        var names = Regexp.GetRegexp(on).GroupNames;
                                                                                                        var theNames = new SaneArrayList();
                                                                                                        foreach(object name in names) {
                                                                                                            theNames.Add(context.runtime.GetSymbol(((string)name)));
                                                                                                        }
                                                                                                        return context.runtime.NewList(theNames);
                                                                                                    })));
        }

        public static string GetInspect(object on) {
            return ((Regexp)(IokeObject.dataOf(on))).Inspect(on);
        }
        
        public static string GetNotice(object on) {
            return ((Regexp)(IokeObject.dataOf(on))).Notice(on);
        }

        public string Inspect(object obj) {
            return "#/" + pattern + "/" + flags;
        }

        public string Notice(object obj) {
            return "#/" + pattern + "/" + flags;
        }

        public override IokeObject ConvertToRegexp(IokeObject self, IokeObject m, IokeObject context) {
            return self;
        }

        public override bool IsEqualTo(IokeObject self, object other) {
            return ((other is IokeObject) && 
                    (IokeObject.dataOf(other) is Regexp) &&
                    ((self == self.runtime.Regexp || other == self.runtime.Regexp) ? self == other :
                     (this.pattern.Equals(((Regexp)IokeObject.dataOf(other)).pattern) &&
                      this.flags.Equals(((Regexp)IokeObject.dataOf(other)).flags))));
        }

        public override int HashCode(IokeObject self) {
            return this.pattern.GetHashCode() + this.flags.GetHashCode();
        }
    }
}
