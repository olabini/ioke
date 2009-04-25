
namespace Ioke.Lang {
    using System.Collections;
    using System.Collections.Generic;

    using Ioke.Lang.Util;

    public class TypeCheckingArgumentsDefinition : DefaultArgumentsDefinition {
        public new static  TypeCheckingArgumentsDefinition Empty() {
            return new TypeCheckingArgumentsDefinition(new SaneList<Argument>(), new SaneList<string>(), null, null, 0, 0, false, new SaneList<ITypeChecker>(), TypeChecker.None);
        }

        public static TypeCheckingArgumentsDefinition EmptyButReceiverMustMimic(object mimic) {
            return new TypeCheckingArgumentsDefinition(new SaneList<Argument>(), new SaneList<string>(), null, null, 0, 0, false, new SaneList<ITypeChecker>(), (IokeObject)mimic);
        }

        IList<ITypeChecker> mustMimic;
        ITypeChecker receiverMustMimic;
        IList<Argument> arguments;

        private TypeCheckingArgumentsDefinition(IList<Argument> arguments, ICollection<string> keywords, string rest, string krest, int min, int max, bool restUneval, IList<ITypeChecker> mustMimic, ITypeChecker receiverMustMimic) : base(arguments, keywords, rest, krest, min, max, restUneval) {
            this.arguments = arguments;
            this.mustMimic = mustMimic;
            this.receiverMustMimic = receiverMustMimic;
        }

        public object GetValidatedArgumentsAndReceiver(IokeObject context, IokeObject message, object on, IList argumentsWithoutKeywords, IDictionary<string, object> givenKeywords) {
            if(!restUneval) {
                GetEvaluatedArguments(context, message, on, argumentsWithoutKeywords, givenKeywords);
                int ix = 0;
                for (int i = 0, j = this.arguments.Count; i < j; i++) {
                    Argument a = this.arguments[i];

                    if (a is KeywordArgument) {
                        string name = a.Name + ":";
                        object given = givenKeywords[name];
                        if (given != null) {
                            givenKeywords[name] = mustMimic[0].ConvertToMimic(given, message, context, true);
                        }
                    } else {
                        if(ix < argumentsWithoutKeywords.Count) {
                            argumentsWithoutKeywords[ix] = mustMimic[i].ConvertToMimic(argumentsWithoutKeywords[ix], message, context, true);
                            ix++;
                        }
                    }
                }
            } else {
                foreach(object o in message.Arguments) argumentsWithoutKeywords.Add(o);
            }
            return receiverMustMimic.ConvertToMimic(on, message, context, true);
        }

        public new class Builder : DefaultArgumentsDefinition.Builder {
            public class OrNil {
                public readonly object realKind;
                public OrNil(object realKind) {
                    this.realKind = realKind;
                }
            }

            IList<ITypeChecker> mustMimic = new SaneList<ITypeChecker>();
            ITypeChecker receiverMustMimic = TypeChecker.None;

            bool setMimic = true;

            void Next() {
                if (!setMimic) {
                    mustMimic.Add(TypeChecker.None);
                }
                setMimic = false;
            }

            public Builder WhichMustMimic(IokeObject mimic) {
                mustMimic.Add(mimic);
                setMimic = true;
                return this;
            }

            public Builder Or(IokeObject mimic) {
                int ix = mustMimic.Count - 1;
                mustMimic[ix] = new TypeChecker.Or(mustMimic[ix], mimic);
                return this;
            }

            public Builder OrBeNil() {
                int ix = mustMimic.Count - 1;
                mustMimic[ix] = new TypeChecker.Or(mustMimic[ix], TypeChecker.Nil);
                return this;
            }

            public Builder ReceiverMustMimic(IokeObject mimic) {
                this.receiverMustMimic = mimic;
                return this;
            }

            public new Builder WithKeyword(string name) {
                Next();
                base.WithKeyword(name);
                return this;
            }

            public new Builder WithKeywordRest(string name) {
                Next();
                base.WithKeywordRest(name);
                return this;
            }

            public new Builder WithOptionalPositional(string name, string defaultValue) {
                Next();
                base.WithOptionalPositional(name, defaultValue);
                return this;
            }

            public new Builder WithOptionalPositionalUnevaluated(string name) {
                Next();
                base.WithOptionalPositionalUnevaluated(name);
                return this;
            }

            public new Builder WithRequiredPositional(string name) {
                Next();
                base.WithRequiredPositional(name);
                return this;
            }

            public new Builder WithRequiredPositionalUnevaluated(string name) {
                Next();
                base.WithRequiredPositionalUnevaluated(name);
                return this;
            }

            public new Builder WithRest(string name) {
                Next();
                base.WithRest(name);
                return this;
            }

            public new Builder WithRestUnevaluated(string name) {
                Next();
                base.WithRestUnevaluated(name);
                return this;
            }

            public new TypeCheckingArgumentsDefinition Arguments {
                get {
                    Next(); 
                    return new TypeCheckingArgumentsDefinition(arguments, keywords, rest, krest, min, max, restUneval, mustMimic, receiverMustMimic);
                }
            }
        }

        public new static Builder builder() {
            return new Builder();
        }
    }
}
