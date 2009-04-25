namespace Ioke.Lang {
    using System.Collections;
    using System.Collections.Generic;
    using System.Collections.Specialized;
    using System.Text;

    using Ioke.Lang.Util;

    public class DefaultArgumentsDefinition {
        public class Argument {
            string name;
            public Argument(string name) {
                this.name = name;
            }
            public string Name {
                get { return name; }
            }
        }

        public class UnevaluatedArgument : Argument {
            bool required;
            public UnevaluatedArgument(string name, bool required) : base(name) {
                this.required = required;
            }
            public bool Required {
                get { return required; }
            }
        }

        public class OptionalArgument : Argument {
            object defaultValue;
            public OptionalArgument(string name, object defaultValue) : base(name) {
                this.defaultValue = defaultValue;
            }
            public object DefaultValue {
                get { return defaultValue; }
            }
        }

        public class KeywordArgument : Argument {
            object defaultValue;
            public KeywordArgument(string name, object defaultValue) : base(name) {
                this.defaultValue = defaultValue;
            }
            public object DefaultValue {
                get { return defaultValue; }
            }
        }

        public static DefaultArgumentsDefinition Empty() {
            return new DefaultArgumentsDefinition(new SaneList<Argument>(), new SaneList<string>(), null, null, 0, 0, false);
        }

        private readonly int min;
        private readonly int max;
        private readonly IList<Argument> arguments;
        private readonly ICollection<string> keywords;
        private readonly string rest;
        private readonly string krest;
        internal readonly bool restUneval;

        protected DefaultArgumentsDefinition(IList<Argument> arguments, ICollection<string> keywords, string rest, string krest, int min, int max, bool restUneval) {
            this.arguments = arguments;
            this.keywords = keywords;
            this.rest = rest;
            this.krest = krest;
            this.min = min;
            this.max = max;
            this.restUneval = restUneval;
        }

        public ICollection<string> Keywords {
            get { return keywords; }
        }

        public IList<Argument> Arguments {
            get { return arguments; }
        }

        public int Max {
            get { return max; }
        }

        public int Min {
            get { return min; }
        }

        public string RestName {
            get { return rest; }
        }

        public string KrestName {
            get { return krest; }
        }

        public bool IsEmpty {
            get { return min == 0 && max == 0 && arguments.Count == 0 && keywords.Count == 0 && rest == null && krest == null; }
        }

        public string GetCode() {
            return GetCode(true);
        }

        public string GetCode(bool lastComma) {
            bool any = false;
            StringBuilder sb = new StringBuilder();
            foreach(Argument argument in arguments) {
                any = true;
                if(!(argument is KeywordArgument)) {
                    if(argument is UnevaluatedArgument) {
                        sb.Append("[").Append(argument.Name).Append("]");
                        if(!((UnevaluatedArgument)argument).Required) {
                            sb.Append(" nil");
                        }
                    } else {
                        sb.Append(argument.Name);
                    }
                } else {
                    sb.Append(argument.Name).Append(":");
                }

                if((argument is OptionalArgument) && ((OptionalArgument)argument).DefaultValue != null) {
                    sb.Append(" ");
                    object defValue = ((OptionalArgument)argument).DefaultValue;
                    if(defValue is string) {
                        sb.Append(defValue);
                    } else {
                        sb.Append(Message.Code(IokeObject.As(defValue, null)));
                    }
                } else if((argument is KeywordArgument) && ((KeywordArgument)argument).DefaultValue != null) {
                    sb.Append(" ");
                    object defValue = ((KeywordArgument)argument).DefaultValue;
                    if(defValue is string) {
                        sb.Append(defValue);
                    } else {
                        sb.Append(Message.Code(IokeObject.As(defValue, null)));
                    }
                }

                sb.Append(", ");
            }

            if(rest != null) {
                any = true;
                if(restUneval) { 
                    sb.Append("+[").Append(rest).Append("], ");
                } else {
                    sb.Append("+").Append(rest).Append(", ");
                }
            }

            if(krest != null) {
                any = true;
                sb.Append("+:").Append(krest).Append(", ");
            }

            if(!lastComma && any) {
                sb.Remove(sb.Length - 2, 2);
            }

            return sb.ToString();
        }

        public int CheckArgumentCount(IokeObject context, IokeObject message, object on) {
            Runtime runtime = context.runtime;
            IList arguments = message.Arguments;
            int argCount = arguments.Count;
            int keySize = keywords.Count;

            if(argCount < min || (max != -1 && argCount > (max+keySize))) {
                int finalArgCount = argCount;
                if(argCount < min) {
                    IokeObject condition = IokeObject.As(IokeObject.GetCellChain(runtime.Condition, 
                                                                                 message, 
                                                                                 context, 
                                                                                 "Error", 
                                                                                 "Invocation", 
                                                                                 "TooFewArguments"), context).Mimic(message, context);
                    condition.SetCell("message", message);
                    condition.SetCell("context", context);
                    condition.SetCell("receiver", on);
                    condition.SetCell("missing", runtime.NewNumber(min-argCount));

                    runtime.ErrorCondition(condition);
                } else {
                    IokeObject condition = IokeObject.As(IokeObject.GetCellChain(runtime.Condition, 
                                                                                 message, 
                                                                                 context, 
                                                                                 "Error", 
                                                                                 "Invocation", 
                                                                                 "TooManyArguments"), context).Mimic(message, context);
                    condition.SetCell("message", message);
                    condition.SetCell("context", context);
                    condition.SetCell("receiver", on);
                    condition.SetCell("extra", runtime.NewList(ArrayList.Adapter(arguments).GetRange(max, finalArgCount-max)));

                    runtime.WithReturningRestart("ignoreExtraArguments", context, () => {runtime.ErrorCondition(condition);});
                    argCount = max;
                }
            }
            return argCount;
        }

        private class NewArgumentGivingRestart : Restart.ArgumentGivingRestart {
            string argname;
            public NewArgumentGivingRestart(string name) : this(name, "newArguments") {}
            public NewArgumentGivingRestart(string name, string argname) : base(name) {
                this.argname = argname;
            }
            public override IList<string> ArgumentNames {
                get { return new SaneList<string>() {argname}; }
            }
        }

        public int GetEvaluatedArguments(IokeObject context, IokeObject message, object on, IList argumentsWithoutKeywords, IDictionary<string, object> givenKeywords) {
            Runtime runtime = context.runtime;
            IList arguments = message.Arguments;
            int argCount = 0;

            foreach(object o in arguments) {
                if(Message.IsKeyword(o)) {
                    givenKeywords[IokeObject.As(o, context).Name] = Message.GetEvaluatedArgument(((Message)IokeObject.dataOf(o)).next, context);
                } else if(Message.HasName(o, "*") && IokeObject.As(o, context).Arguments.Count == 1) { // Splat
                    object result = Message.GetEvaluatedArgument(IokeObject.As(o, context).Arguments[0], context);
                    if(IokeObject.dataOf(result) is IokeList) {
                        IList elements = IokeList.GetList(result);
                        foreach(object ox in elements) argumentsWithoutKeywords.Add(ox);
                        argCount += elements.Count;
                    } else if(IokeObject.dataOf(result) is Dict) {
                        IDictionary keys = Dict.GetMap(result);
                        foreach(DictionaryEntry me in keys) {
                            givenKeywords[Text.GetText(IokeObject.ConvertToText(me.Key, message, context, true)) + ":"] = me.Value;
                        }
                    } else {
                        IokeObject condition = IokeObject.As(IokeObject.GetCellChain(runtime.Condition, 
                                                                                     message, 
                                                                                     context, 
                                                                                     "Error", 
                                                                                     "Invocation", 
                                                                                     "NotSpreadable"), context).Mimic(message, context);
                        condition.SetCell("message", message);
                        condition.SetCell("context", context);
                        condition.SetCell("receiver", on);
                        condition.SetCell("given", result);
                
                        IList outp = IokeList.GetList(runtime.WithRestartReturningArguments(()=>{runtime.ErrorCondition(condition);},
                                                                                            context,
                                                                                            new Restart.DefaultValuesGivingRestart("ignoreArgument", runtime.nil, 0),
                                                                                            new Restart.DefaultValuesGivingRestart("takeArgumentAsIs", IokeObject.As(result, context), 1)
                                                                                            ));

                        foreach(object ox in outp) argumentsWithoutKeywords.Add(ox);
                        argCount += outp.Count;
                    }
                } else {
                    argumentsWithoutKeywords.Add(Message.GetEvaluatedArgument(o, context));
                    argCount++;
                }
            }

            while(argCount < min || (max != -1 && argCount > max)) {
                int finalArgCount = argCount;
                if(argCount < min) {
                    IokeObject condition = IokeObject.As(IokeObject.GetCellChain(runtime.Condition, 
                                                                                 message, 
                                                                                 context, 
                                                                                 "Error", 
                                                                                 "Invocation", 
                                                                                 "TooFewArguments"), context).Mimic(message, context);
                    condition.SetCell("message", message);
                    condition.SetCell("context", context);
                    condition.SetCell("receiver", on);
                    condition.SetCell("missing", runtime.NewNumber(min-argCount));
                
                    IList newArguments = IokeList.GetList(runtime.WithRestartReturningArguments(()=>{runtime.ErrorCondition(condition);},
                                                                                                context,
                                                                                                new NewArgumentGivingRestart("provideExtraArguments"),
                                                                                                new Restart.DefaultValuesGivingRestart("substituteNilArguments", runtime.nil, min-argCount)));

                    foreach(object ox in newArguments) argumentsWithoutKeywords.Add(ox);
                    argCount += newArguments.Count;
                } else {
                    IokeObject condition = IokeObject.As(IokeObject.GetCellChain(runtime.Condition, 
                                                                                 message, 
                                                                                 context, 
                                                                                 "Error", 
                                                                                 "Invocation", 
                                                                                 "TooManyArguments"), context).Mimic(message, context);
                    condition.SetCell("message", message);
                    condition.SetCell("context", context);
                    condition.SetCell("receiver", on);
                    condition.SetCell("extra", runtime.NewList(ArrayList.Adapter(argumentsWithoutKeywords).GetRange(max, finalArgCount-max)));

                    runtime.WithReturningRestart("ignoreExtraArguments", context, ()=>{runtime.ErrorCondition(condition);});
                    argCount = max;
                }
            }

            var intersection = new SaneHashSet<string>(givenKeywords.Keys);
            foreach(string k in keywords) intersection.Remove(k);

            if(krest == null && intersection.Count > 0) {
                IokeObject condition = IokeObject.As(IokeObject.GetCellChain(runtime.Condition, 
                                                                             message, 
                                                                             context, 
                                                                             "Error", 
                                                                             "Invocation", 
                                                                             "MismatchedKeywords"), context).Mimic(message, context);
                condition.SetCell("message", message);
                condition.SetCell("context", context);
                condition.SetCell("receiver", on);

                IList expected = new SaneArrayList();
                foreach(string s in keywords) {
                    expected.Add(runtime.NewText(s));
                }

                condition.SetCell("expected", runtime.NewList(expected));

                IList extra = new SaneArrayList();
                foreach(string s in intersection) {
                    extra.Add(runtime.NewText(s));
                }
                condition.SetCell("extra", runtime.NewList(extra));
                runtime.WithReturningRestart("ignoreExtraKeywords", context, ()=>{runtime.ErrorCondition(condition);});
            }

            return argCount;
        }

        public void AssignArgumentValues(IokeObject locals, IokeObject context, IokeObject message, object on, Call call) {
            if(call.cachedPositional != null) {
                AssignArgumentValues(locals, context, message, on, call.cachedPositional, call.cachedKeywords, call.cachedArgCount);
            } else {
                IList argumentsWithoutKeywords = new SaneArrayList();
                IDictionary<string, object> givenKeywords = new SaneDictionary<string, object>();
                int argCount = GetEvaluatedArguments(context, message, on, argumentsWithoutKeywords, givenKeywords);
                call.cachedPositional = argumentsWithoutKeywords;
                call.cachedKeywords = givenKeywords;
                call.cachedArgCount = argCount;
                AssignArgumentValues(locals, context, message, on, argumentsWithoutKeywords, givenKeywords, argCount);
            }
        }

        public void AssignArgumentValues(IokeObject locals, IokeObject context, IokeObject message, object on) {
            IList argumentsWithoutKeywords = new SaneArrayList();
            IDictionary<string, object> givenKeywords = new SaneDictionary<string, object>();
            int argCount = GetEvaluatedArguments(context, message, on, argumentsWithoutKeywords, givenKeywords);
            AssignArgumentValues(locals, context, message, on, argumentsWithoutKeywords, givenKeywords, argCount);
        }

        private void AssignArgumentValues(IokeObject locals, IokeObject context, IokeObject message, object on, IList argumentsWithoutKeywords, IDictionary<string, object> givenKeywords, int argCount) {
            Runtime runtime = context.runtime;

            var intersection = new SaneHashSet<string>(givenKeywords.Keys);
            foreach(string k in keywords) intersection.Remove(k);

            int ix = 0;
            for(int i=0, j=this.arguments.Count;i<j;i++) {
                Argument a = this.arguments[i];
            
                if(a is KeywordArgument) {
                    string nm = a.Name + ":";
                    object result = null;
                    if(givenKeywords.ContainsKey(nm)) {
                        object given = givenKeywords[nm];
                        result = given;
                        locals.SetCell(a.Name, result);
                    } else {
                        object defVal = ((KeywordArgument)a).DefaultValue;
                        if(!(defVal is string)) {
                            IokeObject m1 = IokeObject.As(defVal, context);
                            result = ((Message)IokeObject.dataOf(m1)).EvaluateCompleteWithoutExplicitReceiver(m1, locals, locals.RealContext);
                            locals.SetCell(a.Name, result);
                        }
                    }
                } else if((a is OptionalArgument) && ix>=argCount) {
                    object defVal = ((OptionalArgument)a).DefaultValue;
                    if(!(defVal is string)) {
                        IokeObject m2 = IokeObject.As(defVal, context);
                        locals.SetCell(a.Name, ((Message)IokeObject.dataOf(m2)).EvaluateCompleteWithoutExplicitReceiver(m2, locals, locals.RealContext));
                    }
                } else {
                    locals.SetCell(a.Name, argumentsWithoutKeywords[ix++]);
                }
            }

            if(krest != null) {
                var krests = new SaneHashtable();
                foreach(string s in intersection) {
                    object given = givenKeywords[s];
                    object result = given;
                    krests[runtime.GetSymbol(s.Substring(0, s.Length-1))] = result;
                }
            
                locals.SetCell(krest, runtime.NewDict(krests));
            }

            if(rest != null) {
                IList rests = new SaneArrayList();
                for(int j=argumentsWithoutKeywords.Count;ix<j;ix++) {
                    rests.Add(argumentsWithoutKeywords[ix]);
                }

                locals.SetCell(rest, runtime.NewList(rests));
            }
        }


        public static DefaultArgumentsDefinition CreateFrom(IList args, int start, int end, IokeObject message, object on, IokeObject context) {
            Runtime runtime = context.runtime;
            IList<Argument> arguments = new SaneList<Argument>();
            IList<string> keywords = new SaneList<string>();

            int min = 0;
            int max = 0;
            bool hadOptional = false;
            string rest = null;
            string krest = null;

            foreach(object obj in ArrayList.Adapter(args).GetRange(start, end-start)) {
                Message m = (Message)IokeObject.dataOf(obj);
                string mname = m.Name;
                if(!"+:".Equals(mname) && m.IsKeyword()) {
                    string name = mname;
                    IokeObject dValue = context.runtime.nilMessage;
                    if(m.next != null) {
                        dValue = m.next;
                    }
                    arguments.Add(new KeywordArgument(name.Substring(0, name.Length-1), dValue));
                    keywords.Add(name);
                } else if(mname.Equals("+")) {
                    string name = Message.GetName(m.Arguments(null)[0]);
                    if(name.StartsWith(":")) {
                        krest = name.Substring(1);
                    } else {
                        rest = name;
                        max = -1;
                    }
                    hadOptional = true;
                } else if(mname.Equals("+:")) {
                    string name = m.next != null ? Message.GetName(m.next) : Message.GetName(m.Arguments(null)[0]);
                    krest = name;
                    hadOptional = true;
                } else if(m.next != null) {
                    string name = mname;
                    hadOptional = true;
                    if(max != -1) {
                        max++;
                    }
                    arguments.Add(new OptionalArgument(name, m.next));
                } else {
                    if(hadOptional) {
                        int index = args.IndexOf(obj) + start;

                        IokeObject condition = IokeObject.As(IokeObject.GetCellChain(runtime.Condition, 
                                                                                     message, 
                                                                                     context, 
                                                                                     "Error", 
                                                                                     "Invocation", 
                                                                                     "ArgumentWithoutDefaultValue"), context).Mimic(message, context);
                        condition.SetCell("message", message);
                        condition.SetCell("context", context);
                        condition.SetCell("receiver", on);
                        condition.SetCell("argumentName", runtime.GetSymbol(m.Name));
                        condition.SetCell("index", runtime.NewNumber(index));
                
                        IList newValue = IokeList.GetList(runtime.WithRestartReturningArguments(()=>{runtime.ErrorCondition(condition);},
                                                                                                context,
                                                                                                new NewArgumentGivingRestart("provideDefaultValue", "defaultValue"),
                                                                                                new Restart.DefaultValuesGivingRestart("substituteNilDefault", runtime.nil, 1)));
                        if(max != -1) {
                            max++;
                        }

                        arguments.Add(new OptionalArgument(m.Name, runtime.CreateMessage(Message.Wrap(IokeObject.As(newValue[0], context)))));
                    } else {
                        min++;
                        max++;
                        arguments.Add(new Argument(IokeObject.As(obj, context).Name));
                    }
                }
            }

            return new DefaultArgumentsDefinition(arguments, keywords, rest, krest, min, max, false);
        }

        public class Builder {
            protected int min = 0;
            protected int max = 0;
            protected IList<Argument> arguments = new SaneList<Argument>();
            protected ICollection<string> keywords = new SaneHashSet<string>();
            protected string rest = null;
            protected string krest = null;
            protected bool restUneval = false;

            public virtual Builder WithRequiredPositionalUnevaluated(string name) {
                arguments.Add(new UnevaluatedArgument(name, true));
                min++;
                if(max != -1) {
                    max++;
                }

                return this;
            }

            public virtual Builder WithOptionalPositionalUnevaluated(string name) {
                arguments.Add(new UnevaluatedArgument(name, false));
                if(max != -1) {
                    max++;
                }

                return this;
            }

            public virtual Builder WithRestUnevaluated(string name) {
                rest = name;
                restUneval = true;
                max = -1;

                return this;
            }

            public virtual Builder WithRest(string name) {
                rest = name;
                max = -1;

                return this;
            }

            public virtual Builder WithKeywordRest(string name) {
                krest = name;

                return this;
            }

            public virtual Builder WithKeywordRestUnevaluated(string name) {
                krest = name;
                restUneval = true;

                return this;
            }

            public virtual Builder WithRequiredPositional(string name) {
                arguments.Add(new Argument(name));
                min++;
                if(max != -1) {
                    max++;
                }

                return this;
            }

            public virtual Builder WithKeyword(string name) {
                arguments.Add(new KeywordArgument(name, "nil"));
                keywords.Add(name + ":");

                return this;
            }

            public virtual Builder WithOptionalPositional(string name, string defaultValue) {
                arguments.Add(new OptionalArgument(name, defaultValue));
                if(max != -1) {
                    max++;
                }

                return this;
            }

            public virtual DefaultArgumentsDefinition Arguments {
                get { return new DefaultArgumentsDefinition(arguments, keywords, rest, krest, min, max, restUneval); }
            }
        }

        public static Builder builder() {
            return new Builder();
        }

    }
}
