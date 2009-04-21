
namespace Ioke.Lang {
    using System;
    using System.Collections;
    using System.Collections.Generic;
    using NRegex;

    using Ioke.Lang.Util;

    public class RegexpMatch : IokeData {
        IokeObject regexp;
        MatchResult mr;
        IokeObject target;

        public RegexpMatch(IokeObject regexp, MatchResult mr, IokeObject target) {
            this.regexp = regexp;
            this.mr = mr;
            this.target = target;
        }
    
        public static object GetTarget(object on) {
            return ((RegexpMatch)IokeObject.dataOf(on)).target;
        }

        public static object GetRegexp(object on) {
            return ((RegexpMatch)IokeObject.dataOf(on)).regexp;
        }

        public static MatchResult GetMatchResult(object on) {
            return ((RegexpMatch)IokeObject.dataOf(on)).mr;
        }

        public override void Init(IokeObject obj) {
            Runtime runtime = obj.runtime;
            obj.Kind = "Regexp Match";

            obj.RegisterMethod(runtime.NewNativeMethod("Returns the target that this match was created against", 
                                                       new TypeCheckingNativeMethod.WithNoArguments("target", obj,
                                                                                                    (method, on, args, keywords, context, message) => {
                                                                                                        return GetTarget(on);
                                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("returns a list of all the named groups in the regular expression used to create this match", 
                                                       new TypeCheckingNativeMethod.WithNoArguments("names", obj,
                                                                                                    (method, on, args, keywords, context, message) => {
                                                                                                        var names = Regexp.GetRegexp(GetRegexp(on)).GroupNames;
                                                                                                        var theNames = new SaneArrayList();
                                                                                                        foreach(object name in names) {
                                                                                                            theNames.Add(context.runtime.GetSymbol(((string)name)));
                                                                                                        }
                                                                                                        return context.runtime.NewList(theNames);
                                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("returns the part of the target before the text that matched", 
                                                       new TypeCheckingNativeMethod.WithNoArguments("beforeMatch", obj,
                                                                                                    (method, on, args, keywords, context, message) => {
                                                                                                        return context.runtime.NewText(GetMatchResult(on).Prefix);
                                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("returns the part of the target after the text that matched", 
                                                       new TypeCheckingNativeMethod.WithNoArguments("afterMatch", obj,
                                                                                                    (method, on, args, keywords, context, message) => {
                                                                                                        return context.runtime.NewText(GetMatchResult(on).Suffix);
                                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("returns the text that matched", 
                                                       new TypeCheckingNativeMethod.WithNoArguments("match", obj,
                                                                                                    (method, on, args, keywords, context, message) => {
                                                                                                        return context.runtime.NewText(GetMatchResult(on).Group(0));
                                                                                                    })));

            obj.AliasMethod("match", "asText", null, null);

            obj.RegisterMethod(runtime.NewNativeMethod("returns the number of groups available in this match", 
                                                       new TypeCheckingNativeMethod.WithNoArguments("length", obj,
                                                                                                    (method, on, args, keywords, context, message) => {
                                                                                                        return context.runtime.NewNumber(GetMatchResult(on).GroupCount);
                                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("returns a list of all groups captured in this match. if a group is not matched it will be nil in the list. the actual match text is not included in this list.", 
                                                       new TypeCheckingNativeMethod.WithNoArguments("captures", obj,
                                                                                                    (method, on, args, keywords, context, message) => {
                                                                                                        var groups = new SaneArrayList();
                                                                                                        MatchResult mr = GetMatchResult(on);
                                                                                                        int len = mr.GroupCount;
                                                                                                        for(int i=1;i<len;i++) {
                                                                                                            if(mr.IsCaptured(i)) {
                                                                                                                groups.Add(context.runtime.NewText(mr.Group(i)));
                                                                                                            } else {
                                                                                                                groups.Add(context.runtime.nil);
                                                                                                            }
                                                                                                        }

                                                                                                        return context.runtime.NewList(groups);
                                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("returns a list of all groups captured in this match. if a group is not matched it will be nil in the list. the actual match text is the first element in the list.", 
                                                       new TypeCheckingNativeMethod.WithNoArguments("asList", obj,
                                                                                                    (method, on, args, keywords, context, message) => {
                                                                                                        var groups = new SaneArrayList();
                                                                                                        MatchResult mr = GetMatchResult(on);
                                                                                                        int len = mr.GroupCount;
                                                                                                        for(int i=0;i<len;i++) {
                                                                                                            if(mr.IsCaptured(i)) {
                                                                                                                groups.Add(context.runtime.NewText(mr.Group(i)));
                                                                                                            } else {
                                                                                                                groups.Add(context.runtime.nil);
                                                                                                            }
                                                                                                        }

                                                                                                        return context.runtime.NewList(groups);
                                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("Takes one optional argument that should be either a number or a symbol. this should be the name or index of a group to return the start index for. if no index is supplied, 0 is the default. if the group in question wasn't matched, returns -1.", 
                                                       new TypeCheckingNativeMethod("start", TypeCheckingArgumentsDefinition.builder()
                                                                                    .ReceiverMustMimic(obj)
                                                                                    .WithOptionalPositional("index", "0")
                                                                                    .Arguments,
                                                                                    (method, on, args, keywords, context, message) => {
                                                                                        int index = 0;
                    
                                                                                        if(args.Count > 0) {
                                                                                            object arg = args[0];
                                                                                            if(IokeObject.dataOf(arg) is Number) {
                                                                                                index = Number.ExtractInt(arg, message, context);
                                                                                            } else {
                                                                                                string namedIndex = Text.GetText(((Message)IokeObject.dataOf(context.runtime.asText)).SendTo(context.runtime.asText, context, arg));
                                                                                                int ix = -1;
                                                                                                try {
                                                                                                    ix = Regexp.GetRegexp(GetRegexp(on)).GroupId(namedIndex);
                                                                                                } catch(Exception) {
                                                                                                    return context.runtime.NewNumber(-1);
                                                                                                }
                                                                                                index = ix;
                                                                                            }
                                                                                        }
                                                                                        MatchResult mr = GetMatchResult(on);
                                                                                        if(index < mr.GroupCount && mr.IsCaptured(index)) {
                                                                                            return context.runtime.NewNumber(mr.GetStart(index));
                                                                                        } else {
                                                                                            return context.runtime.NewNumber(-1);
                                                                                        }
                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("Takes one optional argument that should be either a number or a symbol. this should be the name or index of a group to return the end index for. if no index is supplied, 0 is the default. if the group in question wasn't matched, returns -1.", 
                                                       new TypeCheckingNativeMethod("end", TypeCheckingArgumentsDefinition.builder()
                                                                                    .ReceiverMustMimic(obj)
                                                                                    .WithOptionalPositional("index", "0")
                                                                                    .Arguments,
                                                                                    (method, on, args, keywords, context, message) => {
                                                                                        int index = 0;
                    
                                                                                        if(args.Count > 0) {
                                                                                            object arg = args[0];
                                                                                            if(IokeObject.dataOf(arg) is Number) {
                                                                                                index = Number.ExtractInt(arg, message, context);
                                                                                            } else {
                                                                                                string namedIndex = Text.GetText(((Message)IokeObject.dataOf(context.runtime.asText)).SendTo(context.runtime.asText, context, arg));
                                                                                                int ix = -1;
                                                                                                try {
                                                                                                    ix = Regexp.GetRegexp(GetRegexp(on)).GroupId(namedIndex);
                                                                                                } catch(Exception) {
                                                                                                    return context.runtime.NewNumber(-1);
                                                                                                }
                                                                                                index = ix;
                                                                                            }
                                                                                        }
                                                                                        MatchResult mr = GetMatchResult(on);
                                                                                        if(index < mr.GroupCount && mr.IsCaptured(index)) {
                                                                                            return context.runtime.NewNumber(mr.GetEnd(index));
                                                                                        } else {
                                                                                            return context.runtime.NewNumber(-1);
                                                                                        }
                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("Takes one optional argument that should be either a number or a symbol. this should be the name or index of a group to return the start and end index for. if no index is supplied, 0 is the default. if the group in question wasn't matched, returns nil, otherwise a pair of the start and end indices.", 
                                                       new TypeCheckingNativeMethod("offset", TypeCheckingArgumentsDefinition.builder()
                                                                                    .ReceiverMustMimic(obj)
                                                                                    .WithOptionalPositional("index", "0")
                                                                                    .Arguments,
                                                                                    (method, on, args, keywords, context, message) => {
                                                                                        int index = 0;
                    
                                                                                        if(args.Count > 0) {
                                                                                            object arg = args[0];
                                                                                            if(IokeObject.dataOf(arg) is Number) {
                                                                                                index = Number.ExtractInt(arg, message, context);
                                                                                            } else {
                                                                                                string namedIndex = Text.GetText(((Message)IokeObject.dataOf(context.runtime.asText)).SendTo(context.runtime.asText, context, arg));
                                                                                                int ix = -1;
                                                                                                try {
                                                                                                    ix = Regexp.GetRegexp(GetRegexp(on)).GroupId(namedIndex);
                                                                                                } catch(Exception) {
                                                                                                    return context.runtime.nil;
                                                                                                }
                                                                                                index = ix;
                                                                                            }
                                                                                        }
                                                                                        MatchResult mr = GetMatchResult(on);
                                                                                        if(index < mr.GroupCount && mr.IsCaptured(index)) {
                                                                                            return context.runtime.NewPair(context.runtime.NewNumber(mr.GetStart(index)), context.runtime.NewNumber(mr.GetEnd(index)));
                                                                                        } else {
                                                                                            return context.runtime.nil;
                                                                                        }
                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("Takes one indexing argument that should be either a number, a range, a text or a symbol. if it's a number or a range of numbers, these will specify the index of the capture to return. 0 is the whole match. negative indices are interpreted in the usual way. if the range is out of range it will only use as many groups as there are. if it's a text or a sym it will be interpreted as a the name of a named group to return. if an index isn't correct or wasn't matched, it returns nil in those places.", 
                                                       new TypeCheckingNativeMethod("[]", TypeCheckingArgumentsDefinition.builder()
                                                                                    .ReceiverMustMimic(obj)
                                                                                    .WithRequiredPositional("index")
                                                                                    .Arguments,
                                                                                    (method, on, args, keywords, context, message) => {
                                                                                        object arg = args[0];

                                                                                        MatchResult mr = GetMatchResult(on);

                                                                                        if((IokeObject.dataOf(arg) is Symbol) || (IokeObject.dataOf(arg) is Text)) {
                                                                                            string namedIndex = Text.GetText(((Message)IokeObject.dataOf(context.runtime.asText)).SendTo(context.runtime.asText, context, arg));
                                                                                            int ix = -1;
                                                                                            try {
                                                                                                ix = Regexp.GetRegexp(GetRegexp(on)).GroupId(namedIndex);
                                                                                            } catch(Exception) {
                                                                                                return context.runtime.nil;
                                                                                            }
                                                                                            if(!mr.IsCaptured(ix)) {
                                                                                                return context.runtime.nil;
                                                                                            }
                                                                                            return context.runtime.NewText(mr.Group(ix));
                                                                                        } else {
                                                                                            int size = mr.GroupCount;

                                                                                            if(IokeObject.dataOf(arg) is Range) {
                                                                                                int first = Number.ExtractInt(Range.GetFrom(arg), message, context); 
                        
                                                                                                if(first < 0) {
                                                                                                    return context.runtime.NewList(new SaneArrayList());
                                                                                                }

                                                                                                int last = Number.ExtractInt(Range.GetTo(arg), message, context);
                                                                                                bool inclusive = Range.IsInclusive(arg);


                                                                                                if(last < 0) {
                                                                                                    last = size + last;
                                                                                                }

                                                                                                if(last < 0) {
                                                                                                    return context.runtime.NewList(new SaneArrayList());
                                                                                                }

                                                                                                if(last >= size) {
                                                                                                    last = inclusive ? size-1 : size;
                                                                                                }

                                                                                                if(first > last || (!inclusive && first == last)) {
                                                                                                    return context.runtime.NewList(new SaneArrayList());
                                                                                                }
                        
                                                                                                if(!inclusive) {
                                                                                                    last--;
                                                                                                }
                        
                                                                                                var result = new SaneArrayList();
                                                                                                for(int i = first; i < last+1; i++) {
                                                                                                    if(!mr.IsCaptured(i)) {
                                                                                                        result.Add(context.runtime.nil);
                                                                                                    } else {
                                                                                                        result.Add(context.runtime.NewText(mr.Group(i)));
                                                                                                    }
                                                                                                }

                                                                                                return context.runtime.NewList(result);
                                                                                            }
                        
                                                                                            if(!(IokeObject.dataOf(arg) is Number)) {
                                                                                                arg = IokeObject.ConvertToNumber(arg, message, context);
                                                                                            }
                                                                                            int index = ((Number)IokeObject.dataOf(arg)).AsNativeInteger();
                                                                                            if(index < 0) {
                                                                                                index = size + index;
                                                                                            }

                                                                                            if(index >= 0 && index < size && mr.IsCaptured(index)) {
                                                                                                return context.runtime.NewText(mr.Group(index));
                                                                                            } else {
                                                                                                return context.runtime.nil;
                                                                                            }
                                                                                        }
                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("will get the named group corresponding to the name of the message, or nil if the named group hasn't been matched. will signal a condition if no such group is defined.", 
                                                       new TypeCheckingNativeMethod("pass", TypeCheckingArgumentsDefinition.builder()
                                                                                    .ReceiverMustMimic(obj)
                                                                                    .Arguments,
                                                                                    (method, on, args, keywords, context, message) => {
                                                                                        MatchResult mr = GetMatchResult(on);
                                                                                        string name = Message.GetName(message);
                    
                                                                                        int ix = -1;
                                                                                        try {
                                                                                            ix = Regexp.GetRegexp(GetRegexp(on)).GroupId(name);
                                                                                        } catch(Exception) {
                                                                                            IokeObject condition = IokeObject.As(IokeObject.GetCellChain(message.runtime.Condition, 
                                                                                                                                                         message, 
                                                                                                                                                         context, 
                                                                                                                                                         "Error", 
                                                                                                                                                         "NoSuchCell"), context).Mimic(message, context);
                                                                                            condition.SetCell("message", message);
                                                                                            condition.SetCell("context", context);
                                                                                            condition.SetCell("receiver", on);
                                                                                            condition.SetCell("cellName", message.runtime.GetSymbol(name));

                                                                                            message.runtime.WithReturningRestart("ignore", context, ()=>{condition.runtime.ErrorCondition(condition);});
                                                                                            return context.runtime.nil;
                                                                                        }

                                                                                        if(mr.IsCaptured(ix)) {
                                                                                            return context.runtime.NewText(mr.Group(ix));
                                                                                        } else {
                                                                                            return context.runtime.nil;
                                                                                        }
                                                                                    })));
        }
    }
}
