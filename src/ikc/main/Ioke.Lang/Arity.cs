
namespace Ioke.Lang {
    using System.Collections;
    using Ioke.Lang.Util;

    public class Arity : IokeData {
        private enum Taking { Unset, Nothing, Everything }

        private static IokeObject GetArity(IokeObject self, Taking thing) {
            IokeObject obj = self.runtime.Arity.AllocateCopy(null, null);
            obj.MimicsWithoutCheck(self.runtime.Arity);
            obj.Data = new Arity(thing);
            return obj;
        }

        public static IokeObject GetArity(IokeObject self, DefaultArgumentsDefinition def) {
            if(def == null || def.IsEmpty) {
                return IokeObject.As(TakingNothing(self), self.runtime.Arity);
            }
            IokeObject obj = self.runtime.Arity.AllocateCopy(null, null);
            obj.MimicsWithoutCheck(self.runtime.Arity);
            obj.Data = new Arity(def);
            return obj;
        }

        private DefaultArgumentsDefinition argumentsDefinition;
        private Taking taking = Taking.Unset;

        private Arity(Taking taking) {
            this.taking = taking;
        }

        public Arity(DefaultArgumentsDefinition argumentsDefinition) {
            if(argumentsDefinition == null || argumentsDefinition.IsEmpty) {
                this.taking = Taking.Nothing;
            } else {
                this.argumentsDefinition = argumentsDefinition;
            }
        }

        public static object TakingNothing(IokeObject self) {
            return self.runtime.Arity.GetCell(null, null, "taking:nothing");
        }

        public static object TakingEverything(IokeObject self) {
            return self.runtime.Arity.GetCell(null, null, "taking:everything");
        }

        public override void Init(IokeObject obj) {
            obj.Kind = "Arity";
        
            obj.SetCell("taking:nothing", GetArity(obj, Taking.Nothing));
            obj.SetCell("taking:everything", GetArity(obj, Taking.Everything));
        
            obj.RegisterMethod(obj.runtime.NewNativeMethod("Create an Arity object from the given messages. The list of unevaluated messages given to this method will be used as if they were the arguments part of a DefaultMethod definition.", 
                                                           new TypeCheckingNativeMethod("from", TypeCheckingArgumentsDefinition.builder()
                                                                                        .ReceiverMustMimic(obj)
                                                                                        .WithRestUnevaluated("arguments")
                                                                                        .Arguments,
                                                                                        (self, on, args, keywords, context, message) => {
                                                                                            if (message.Arguments.Count == 0) { 
                                                                                                return TakingNothing(self);
                                                                                            }
                                                                                            DefaultArgumentsDefinition def = DefaultArgumentsDefinition.CreateFrom(message.Arguments, 0, message.Arguments.Count, message, on, context);
                                                                                            return GetArity(self, def);
                                                                                        })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("returns the names for positional arguments", 
                                                           new TypeCheckingNativeMethod("positionals", TypeCheckingArgumentsDefinition.builder()
                                                                                        .WithOptionalPositional("includeOptionals", "true")
                                                                                        .Arguments,
                                                                                        (method, on, args, keywords, context, message) => {
                                                                                            Arity a = (Arity)IokeObject.dataOf(on);
                                                                                            var names = new SaneArrayList();
                                                                                            bool includeOptional = args.Count == 0 ? true : IokeObject.IsObjectTrue(args[0]);
                                                                                            if(a.argumentsDefinition != null) {
                                                                                                foreach(DefaultArgumentsDefinition.Argument argument in a.argumentsDefinition.Arguments) {
                                                                                                    if(argument is DefaultArgumentsDefinition.KeywordArgument) { continue; }
                                                                                                    if(argument is DefaultArgumentsDefinition.OptionalArgument) {
                                                                                                        if(includeOptional) {
                                                                                                            names.Add(method.runtime.GetSymbol(argument.Name));
                                                                                                        }
                                                                                                    } else {
                                                                                                        names.Add(method.runtime.GetSymbol(argument.Name));
                                                                                                    }
                                                                                                }
                                                                                            }
                                                                                            return method.runtime.NewList(names);
                                                                                        })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("returns the names for keyword arguments", 
                                                           new TypeCheckingNativeMethod.WithNoArguments("keywords", obj,
                                                                                                        (method, on, args, keywords, context, message) => {
                                                                                                            Arity a = (Arity)IokeObject.dataOf(on);
                                                                                                            var names = new SaneArrayList();
                                                                                                            if(a.argumentsDefinition != null) {
                                                                                                                foreach(string name in a.argumentsDefinition.Keywords) {
                                                                                                                    names.Add(method.runtime.GetSymbol(name.Substring(0, name.Length - 1)));
                                                                                                                }
                                                                                                            }
                                                                                                            return method.runtime.NewList(names);
                                                                                                        })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("returns the symbol name for the krest argument.", 
                                                           new TypeCheckingNativeMethod.WithNoArguments("krest", obj, 
                                                                                                        (method, on, args, keywords, context, message) => {
                                                                                                            Arity a = (Arity)IokeObject.dataOf(on);
                                                                                                            if(a.argumentsDefinition != null) {
                                                                                                                string name = a.argumentsDefinition.KrestName;
                                                                                                                if(name == null) { 
                                                                                                                    return method.runtime.nil;
                                                                                                                } else {
                                                                                                                    return method.runtime.GetSymbol(name);
                                                                                                                }
                                                                                                            } else {
                                                                                                                return method.runtime.nil;
                                                                                                            }
                                                                                                        })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("returns the symbol name for the rest argument.", 
                                                           new TypeCheckingNativeMethod.WithNoArguments("rest", obj,
                                                                                                        (method, on, args, keywords, context, message) => {
                                                                                                            Arity a = (Arity)IokeObject.dataOf(on);
                                                                                                            if(a.argumentsDefinition != null) {
                                                                                                                string name = a.argumentsDefinition.RestName;
                                                                                                                if(name == null) {
                                                                                                                    return method.runtime.nil;
                                                                                                                } else {
                                                                                                                    return method.runtime.GetSymbol(name);
                                                                                                                }
                                                                                                            } else {
                                                                                                                return method.runtime.nil;
                                                                                                            }
                                                                                                        })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("returns the text representation of this arity", 
                                                           new TypeCheckingNativeMethod.WithNoArguments("asText", obj,
                                                                                                        (method, on, args, keywords, context, message) => {
                                                                                                            Arity a = (Arity) IokeObject.dataOf(on);
                                                                                                            if (a.taking == Taking.Everything) {
                                                                                                                return method.runtime.NewText("...");
                                                                                                            } else if (a.taking == Taking.Nothing) {
                                                                                                                return method.runtime.NewText("");
                                                                                                            }
                                                                                                            return method.runtime.NewText(a.argumentsDefinition.GetCode(false));
                                                                                                        })));
        }
    }
}
