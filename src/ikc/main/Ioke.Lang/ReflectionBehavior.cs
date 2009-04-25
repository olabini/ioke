namespace Ioke.Lang {
    using System.Collections; 
    using System.Collections.Generic; 

    using Ioke.Lang.Util;

    public class ReflectionBehavior {
        public static void Init(IokeObject obj) {
            Runtime runtime = obj.runtime;
            obj.Kind = "DefaultBehavior Reflection";

            obj.RegisterMethod(runtime.NewNativeMethod("Takes one evaluated argument and returns either true or false if this object or one of it's mimics mimics that argument", 
                                                       new NativeMethod("mimics?", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositional("potentialMimic")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            var args = new SaneArrayList();
                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, args, new SaneDictionary<string, object>());

                                                                            IokeObject arg = IokeObject.As(args[0], context);
                                                                            if(IokeObject.IsMimic(on, arg, context)) {
                                                                                return context.runtime.True;
                                                                            } else {
                                                                                return context.runtime.False;
                                                                            }
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("modifies the receiver to be in all ways identical to the argument. if the receiver is nil, true or false, this method can't be used - but those are the only exceptions. it's generally not recommended to use it on kinds and objects that are important for the Ioke runtime, since the result might be highly unpredictable.", 
                                                       new NativeMethod("become!", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositional("objectToBecome")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            var args = new SaneArrayList();
                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, args, new SaneDictionary<string, object>());
                                                                            IokeObject me = IokeObject.As(on, context);
                                                                            IokeObject other = IokeObject.As(args[0], context);

                                                                            if(on == context.runtime.nil || on == context.runtime.True || on == context.runtime.False) {
                                                                                IokeObject condition = IokeObject.As(IokeObject.GetCellChain(context.runtime.Condition, 
                                                                                                                                             message, 
                                                                                                                                             context,
                                                                                                                                             "Error", 
                                                                                                                                             "CantMimicOddball"), context).Mimic(message, context);
                                                                                condition.SetCell("message", message);
                                                                                condition.SetCell("context", context);
                                                                                condition.SetCell("receiver", on);
                                                                                context.runtime.ErrorCondition(condition);
                                                                            }

                                                                            me.Become(other, message, context);
                    
                                                                            return on;
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("returns a text hex representation of the receiver in upper case hex literal, starting with 0x. This value is based on System.identityHashCode, and as such is not totally guaranteed to be totally unique. but almost.", 
                                                       new NativeMethod.WithNoArguments("uniqueHexId",
                                                                                        (method, context, message, on, outer) => {
                                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, new SaneArrayList(), new SaneDictionary<string, object>());
                                                                                            return context.runtime.NewText("0x" + System.Convert.ToString(System.Runtime.CompilerServices.RuntimeHelpers.GetHashCode(IokeObject.As(on, context).Cells), 16).ToUpper());
                                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("returns a textual representation of the object called on.", 
                                                       new NativeMethod.WithNoArguments("asText",
                                                                                        (method, context, message, on, outer) => {
                                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, new SaneArrayList(), new SaneDictionary<string, object>());
                                                                                            return method.runtime.NewText(on.ToString());
                                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("returns true if the evaluated argument is the same reference as the receiver, false otherwise.", 
                                                       new NativeMethod("same?", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositional("other")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            var args = new SaneArrayList();
                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, args, new SaneDictionary<string, object>());
                                                                            return IokeObject.Same(on, args[0]) ? context.runtime.True : context.runtime.False;
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("takes the name of a message to send, and the arguments to give it. send should generally behave exactly as if you had sent the message itself - except that you can give a variable containing the name.", 
                                                       new NativeMethod("send", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositional("messageName")
                                                                        .WithRestUnevaluated("arguments")
                                                                        .WithKeywordRestUnevaluated("keywordArguments")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            outer.ArgumentsDefinition.CheckArgumentCount(context, message, on);
                                                                            object _name = ((Message)IokeObject.dataOf(message)).GetEvaluatedArgument(message, 0, context);
                                                                            string name = Text.GetText(((Message)IokeObject.dataOf(runtime.asText)).SendTo(runtime.asText, context, _name));

                                                                            IokeObject newMessage = Message.DeepCopy(message);
                                                                            newMessage.Arguments.RemoveAt(0);
                                                                            Message.SetName(newMessage, name);
                                                                            return ((Message)IokeObject.dataOf(newMessage)).SendTo(newMessage, context, on);
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("returns false if the left hand side is equal to the right hand side. exactly what this means depend on the object. the default behavior of Ioke objects is to only be equal if they are the same instance.", 
                                                       new NativeMethod("!=", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositional("other")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            var args = new SaneArrayList();
                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, args, new SaneDictionary<string, object>());
                                                                            return !IokeObject.Equals(on, ((Message)IokeObject.dataOf(message)).GetEvaluatedArgument(message, 0, context)) ? context.runtime.True : context.runtime.False;
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("Takes one evaluated Text argument and returns either true or false if this object or one of it's mimics have the kind of the name specified", 
                                                       new TypeCheckingNativeMethod("kind?", TypeCheckingArgumentsDefinition.builder()
                                                                                    .WithRequiredPositional("name").WhichMustMimic(runtime.Text)
                                                                                    .Arguments,
                                                                                    (method, on, args, keywords, context, message) => {
                                                                                        string kind = Text.GetText(args[0]);
                                                                                        return IokeObject.IsKind(on, kind, context) ? context.runtime.True : context.runtime.False;
                                                                                    })));
        
            obj.RegisterMethod(runtime.NewNativeMethod("Takes one evaluated argument and returns either true or false if this object or one of it's mimics mimics that argument. exactly the same as 'mimics?'", 
                                                       new NativeMethod("is?", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositional("potentialMimic")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            var args = new SaneArrayList();
                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, args, new SaneDictionary<string, object>());
                                                                        
                                                                            IokeObject arg = IokeObject.As(args[0], context);
                                                                            return IokeObject.IsMimic(on, arg, context) ? context.runtime.True : context.runtime.False;
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("returns a list of all the mimics of the receiver. it will not be the same list as is used to back the object, so modifications to this list will not show up in the object.", 
                                                       new NativeMethod.WithNoArguments("mimics",
                                                                                        (method, context, message, on, outer) => {
                                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, new SaneArrayList(), new SaneDictionary<string, object>());
                                                                                            var l = new SaneArrayList();
                                                                                            foreach(object x in IokeObject.GetMimics(on, context)) l.Add(x);
                                                                                            return context.runtime.NewList(l);
                                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("removes all mimics on the receiver, and returns the receiver", 
                                                       new NativeMethod.WithNoArguments("removeAllMimics!",
                                                                                        (method, context, message, on, outer) => {
                                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, new SaneArrayList(), new SaneDictionary<string, object>());
                                                                                            IokeObject.RemoveAllMimics(on, message, context);
                                                                                            return on;
                                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("removes the argument mimic from the list of all mimics on the receiver. will do nothing if the receiver has no such mimic. it returns the receiver", 
                                                       new NativeMethod("removeMimic!", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositional("mimicToRemove")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            var args = new SaneArrayList();
                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, args, new SaneDictionary<string, object>());
                                                                            IokeObject.RemoveMimic(on, args[0], message, context);
                                                                            return on;
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("Takes one evaluated argument and adds it to the list of mimics for the receiver. the receiver will be returned.", 
                                                       new NativeMethod("mimic!", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositional("newMimic")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            var args = new SaneArrayList();
                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, args, new SaneDictionary<string, object>());
                                                                            IokeObject newMimic = IokeObject.As(args[0], context);
                                                                            IokeObject.As(on, context).Mimics(newMimic, message, context);
                                                                            return on;
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("Takes one evaluated argument and prepends it to the list of mimics for the receiver. the receiver will be returned.", 
                                                       new NativeMethod("prependMimic!", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositional("newMimic")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            var args = new SaneArrayList();
                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, args, new SaneDictionary<string, object>());
                                                                            IokeObject newMimic = IokeObject.As(args[0], context);
                                                                            IokeObject.As(on, context).Mimics(0, newMimic, message, context);
                                                                            return on;
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("returns true if the receiver is frozen, otherwise false", 
                                                       new NativeMethod.WithNoArguments("frozen?",
                                                                                        (method, context, message, on, outer) => {
                                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, new SaneArrayList(), new SaneDictionary<string, object>());
                                                                                            return IokeObject.IsFrozen(on) ? context.runtime.True : context.runtime.False;
                                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("ensures that the receiver is frozen", 
                                                       new NativeMethod.WithNoArguments("freeze!",
                                                                                        (method, context, message, on, outer) => {
                                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, new SaneArrayList(), new SaneDictionary<string, object>());
                                                                                            IokeObject.Freeze(on);
                                                                                            return on;
                                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("ensures that the receiver is not frozen", 
                                                       new NativeMethod.WithNoArguments("thaw!",
                                                           (method, context, message, on, outer) => {
                                                               outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, new SaneArrayList(), new SaneDictionary<string, object>());
                                                               IokeObject.Thaw(on);
                                                               return on;
                                                           })));
        }
    }
}
