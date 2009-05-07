
namespace Ioke.Lang {
    using System.Collections;
    using System.Collections.Generic;

    using Ioke.Lang.Util;

    public class Reflector {
        public static void Init(Runtime runtime) {
            IokeObject obj = new IokeObject(runtime, "Allows access to the internals of any object without actually using methods on that object");
            obj.Kind = "Reflector";
            obj.MimicsWithoutCheck(runtime.Origin);
            runtime.IokeGround.RegisterCell("Reflector", obj);

            obj.RegisterMethod(obj.runtime.NewNativeMethod("returns the documentation text of the object given as argument. anything can have a documentation text - this text will initially be nil.", 
                                                           new TypeCheckingNativeMethod("other:documentation", TypeCheckingArgumentsDefinition.builder()
                                                                                        .WithRequiredPositional("other")
                                                                                        .Arguments,
                                                                                        (method, on, args, keywords, context, message) => {
                                                                                            return Base.Documentation(context, message, args[0]);
                                                                                        })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("sets the documentation string for a specific object.", 
                                                           new TypeCheckingNativeMethod("other:documentation=", TypeCheckingArgumentsDefinition.builder()
                                                                                        .WithRequiredPositional("other")
                                                                                        .WithRequiredPositional("text").WhichMustMimic(obj.runtime.Text).OrBeNil()
                                                                                        .Arguments,
                                                                                        (method, on, args, keywords, context, message) => {
                                                                                            return Base.SetDocumentation(context, message, args[0], args[1]);
                                                                                        })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("will return a new derivation of the receiving object. Might throw exceptions if the object is an oddball object.", 
                                                           new TypeCheckingNativeMethod("other:mimic", TypeCheckingArgumentsDefinition.builder()
                                                                                        .WithRequiredPositional("other")
                                                                                        .Arguments,
                                                                                        (method, on, args, keywords, context, message) => {
                                                                                            return IokeObject.As(args[0], context).Mimic(message, context);
                                                                                        })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("expects one evaluated text or symbol argument that names the cell to set, sets this cell to the result of evaluating the second argument, and returns the value set.", 
                                                           new NativeMethod("other:cell=",
                                                                            DefaultArgumentsDefinition
                                                                            .builder()
                                                                            .WithRequiredPositional("other")
                                                                            .WithRequiredPositional("cellName")
                                                                            .WithRequiredPositional("value")
                                                                            .Arguments,
                                                                            (method, context, message, on, outer) => {
                                                                                var args = new SaneArrayList();
                                                                                outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, args, new SaneDictionary<string, object>());
                                                                                return Base.AssignCell(context, message, args[0], args[1], args[2]);
                                                                            })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("expects one evaluated text or symbol argument and returns the cell that matches that name, without activating even if it's activatable.", 
                                                           new NativeMethod("other:cell", DefaultArgumentsDefinition.builder()
                                                                            .WithRequiredPositional("other")
                                                                            .WithRequiredPositional("cellName")
                                                                            .Arguments,
                                                                            (method, context, message, on, outer) => {
                                                                                var args = new SaneArrayList();
                                                                                outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, args, new SaneDictionary<string, object>());
                                                                                string name = Text.GetText(((Message)IokeObject.dataOf(context.runtime.asText)).SendTo(context.runtime.asText, context, args[1]));
                                                                                return IokeObject.GetCell(args[0], message, context, name);
                                                                            })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("expects one evaluated text or symbol argument and returns a boolean indicating whether such a cell is reachable from this point.", 
                                                           new NativeMethod("other:cell?", DefaultArgumentsDefinition.builder()
                                                                            .WithRequiredPositional("other")
                                                                            .WithRequiredPositional("cellName")
                                                                            .Arguments,
                                                                            (method, context, message, on, outer) => {
                                                                                IList args = new SaneArrayList();
                                                                                outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, args, new SaneDictionary<string, object>());

                                                                                string name = Text.GetText(((Message)IokeObject.dataOf(context.runtime.asText)).SendTo(context.runtime.asText, context, args[1]));
                                                                                return IokeObject.FindCell(args[0], message, context, name) != context.runtime.nul ? context.runtime.True : context.runtime.False;
                                                                            })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("expects one evaluated text or symbol argument and returns a boolean indicating whether this cell is owned by the receiver or not. the assumption is that the cell should exist. if it doesn't exist, a NoSuchCell condition will be signalled.", 
                                                           new NativeMethod("other:cellOwner?", DefaultArgumentsDefinition.builder()
                                                                            .WithRequiredPositional("other")
                                                                            .WithRequiredPositional("cellName")
                                                                            .Arguments,
                                                                            (method, context, message, on, outer) => {
                                                                                var args = new SaneArrayList();
                                                                                outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, args, new SaneDictionary<string, object>());
                                                                                string name = Text.GetText(((Message)IokeObject.dataOf(context.runtime.asText)).SendTo(context.runtime.asText, context, args[1]));
                                                                                return (IokeObject.FindPlace(args[0], message, context, name) == args[0]) ? context.runtime.True : context.runtime.False;
                                                                            })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("expects one evaluated text or symbol argument and returns the closest object that defines such a cell. if it doesn't exist, a NoSuchCell condition will be signalled.", 
                                                           new NativeMethod("other:cellOwner", DefaultArgumentsDefinition.builder()
                                                                            .WithRequiredPositional("other")
                                                                            .WithRequiredPositional("cellName")
                                                                            .Arguments,
                                                                            (method, context, message, on, outer) => {
                                                                                var args = new SaneArrayList();
                                                                                outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, args, new SaneDictionary<string, object>());
                                                                                string name = Text.GetText(((Message)IokeObject.dataOf(context.runtime.asText)).SendTo(context.runtime.asText, context, args[1]));
                                                                                object result = IokeObject.FindPlace(args[0], message, context, name);
                                                                                if(result == context.runtime.nul) {
                                                                                    return context.runtime.nil;
                                                                                }
                                                                                return result;
                                                                            })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("expects one evaluated text or symbol argument and removes that cell from the current receiver. if the current receiver has no such object, signals a condition. note that if another cell with that name is available in the mimic chain, it will still be accessible after calling this method. the method returns the receiver.", 
                                                           new NativeMethod("other:removeCell!", DefaultArgumentsDefinition.builder()
                                                                            .WithRequiredPositional("other")
                                                                            .WithRequiredPositional("cellName")
                                                                            .Arguments,
                                                                            (method, context, message, on, outer) => {
                                                                                var args = new SaneArrayList();
                                                                                outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, args, new SaneDictionary<string, object>());
                                                                                string name = Text.GetText(((Message)IokeObject.dataOf(context.runtime.asText)).SendTo(context.runtime.asText, context, args[1]));
                                                                                IokeObject.RemoveCell(args[0], message, context, name);
                                                                                return args[0];
                                                                            })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("expects one evaluated text or symbol argument and makes that cell undefined in the current receiver. what that means is that from now on it will look like this cell doesn't exist in the receiver or any of its mimics. the cell will not show up if you call cellNames on the receiver or any of the receivers mimics. the undefined status can be removed by doing removeCell! on the correct cell name. a cell name that doesn't exist can still be undefined. the method returns the receiver.", 
                                                           new NativeMethod("other:undefineCell!", DefaultArgumentsDefinition.builder()
                                                                            .WithRequiredPositional("other")
                                                                            .WithRequiredPositional("cellName")
                                                                            .Arguments,
                                                                            (method, context, message, on, outer) => {
                                                                                var args = new SaneArrayList();
                                                                                outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, args, new SaneDictionary<string, object>());
                                                                                string name = Text.GetText(((Message)IokeObject.dataOf(context.runtime.asText)).SendTo(context.runtime.asText, context, args[1]));
                                                                                IokeObject.UndefineCell(args[0], message, context, name);
                                                                                return args[0];
                                                                            })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("takes one optional evaluated boolean argument, which defaults to false. if false, this method returns a list of the cell names of the receiver. if true, it returns the cell names of this object and all it's mimics recursively.", 
                                                           new NativeMethod("other:cellNames", DefaultArgumentsDefinition.builder()
                                                                            .WithRequiredPositional("other")
                                                                            .WithOptionalPositional("includeMimics", "false")
                                                                            .WithOptionalPositional("cutoff", "nil")
                                                                            .Arguments,
                                                                            (method, context, message, on, outer) => {
                                                                                var args = new SaneArrayList();
                                                                                outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, args, new SaneDictionary<string, object>());
                                                                                return Base.CellNames(context, message, args[0], args.Count > 1 && IokeObject.IsObjectTrue(args[1]), (args.Count > 2) ? args[2] : null);
                                                                            })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("takes one optional evaluated boolean argument, which defaults to false. if false, this method returns a dict of the cell names and values of the receiver. if true, it returns the cell names and values of this object and all it's mimics recursively.", 
                                                           new NativeMethod("other:cells", DefaultArgumentsDefinition.builder()
                                                                            .WithRequiredPositional("other")
                                                                            .WithOptionalPositional("includeMimics", "false")
                                                                            .Arguments,
                                                                            (method, context, message, on, outer) => {
                                                                                var args = new SaneArrayList();
                                                                                outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, args, new SaneDictionary<string, object>());
                                                                                return Base.Cells(context, message, args[0], args.Count > 1 && IokeObject.IsObjectTrue(args[1]));
                                                                            })));

            obj.RegisterMethod(runtime.NewNativeMethod("Takes one evaluated argument and returns either true or false if this object or one of it's mimics mimics that argument", 
                                                       new NativeMethod("other:mimics?", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositional("other")
                                                                        .WithRequiredPositional("potentialMimic")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            var args = new SaneArrayList();
                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, args, new SaneDictionary<string, object>());

                                                                            IokeObject arg = IokeObject.As(args[1], context);
                                                                            if(IokeObject.IsMimic(args[0], arg, context)) {
                                                                                return context.runtime.True;
                                                                            } else {
                                                                                return context.runtime.False;
                                                                            }
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("modifies the receiver to be in all ways identical to the argument. if the receiver is nil, true or false, this method can't be used - but those are the only exceptions. it's generally not recommended to use it on kinds and objects that are important for the Ioke runtime, since the result might be highly unpredictable.", 
                                                       new NativeMethod("other:become!", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositional("other")
                                                                        .WithRequiredPositional("objectToBecome")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            var args = new SaneArrayList();
                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, args, new SaneDictionary<string, object>());
                                                                            IokeObject me = IokeObject.As(args[0], context);
                                                                            IokeObject other = IokeObject.As(args[1], context);

                                                                            if(args[0] == context.runtime.nil || args[0] == context.runtime.True || args[0] == context.runtime.False) {
                                                                                IokeObject condition = IokeObject.As(IokeObject.GetCellChain(context.runtime.Condition, 
                                                                                                                                             message, 
                                                                                                                                             context,
                                                                                                                                             "Error", 
                                                                                                                                             "CantMimicOddball"), context).Mimic(message, context);
                                                                                condition.SetCell("message", message);
                                                                                condition.SetCell("context", context);
                                                                                condition.SetCell("receiver", args[0]);
                                                                                context.runtime.ErrorCondition(condition);
                                                                            }

                                                                            me.Become(other, message, context);
                    
                                                                            return args[0];
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("returns a text hex representation of the receiver in upper case hex literal, starting with 0x. This value is based on System.identityHashCode, and as such is not totally guaranteed to be totally unique. but almost.", 
                                                       new TypeCheckingNativeMethod("other:uniqueHexId", TypeCheckingArgumentsDefinition.builder()
                                                                                    .WithRequiredPositional("other")
                                                                                    .Arguments,
                                                                                    (method, on, args, keywords, context, message) => {
                                                                                        return context.runtime.NewText("0x" + System.Convert.ToString(System.Runtime.CompilerServices.RuntimeHelpers.GetHashCode(IokeObject.As(args[0], context).Cells), 16).ToUpper());
                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("returns true if the evaluated argument is the same reference as the receiver, false otherwise.", 
                                                       new NativeMethod("other:same?", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositional("other")
                                                                        .WithRequiredPositional("other")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            var args = new SaneArrayList();
                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, args, new SaneDictionary<string, object>());
                                                                            return IokeObject.Same(args[0], args[1]) ? context.runtime.True : context.runtime.False;
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("takes the name of a message to send, and the arguments to give it. send should generally behave exactly as if you had sent the message itself - except that you can give a variable containing the name.", 
                                                       new NativeMethod("other:send", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositional("other")
                                                                        .WithRequiredPositional("messageName")
                                                                        .WithRestUnevaluated("arguments")
                                                                        .WithKeywordRestUnevaluated("keywordArguments")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            outer.ArgumentsDefinition.CheckArgumentCount(context, message, on);
                                                                            object _recv = ((Message)IokeObject.dataOf(message)).GetEvaluatedArgument(message, 0, context);
                                                                            object _name = ((Message)IokeObject.dataOf(message)).GetEvaluatedArgument(message, 1, context);
                                                                            string name = Text.GetText(((Message)IokeObject.dataOf(runtime.asText)).SendTo(runtime.asText, context, _name));

                                                                            IokeObject newMessage = Message.DeepCopy(message);
                                                                            newMessage.Arguments.RemoveAt(0);
                                                                            newMessage.Arguments.RemoveAt(0);
                                                                            Message.SetName(newMessage, name);
                                                                            return ((Message)IokeObject.dataOf(newMessage)).SendTo(newMessage, context, _recv);
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("Takes one evaluated Text argument and returns either true or false if this object or one of it's mimics have the kind of the name specified", 
                                                       new TypeCheckingNativeMethod("other:kind?", TypeCheckingArgumentsDefinition.builder()
                                                                                    .WithRequiredPositional("other")
                                                                                    .WithRequiredPositional("name").WhichMustMimic(runtime.Text)
                                                                                    .Arguments,
                                                                                    (method, on, args, keywords, context, message) => {
                                                                                        string kind = Text.GetText(args[1]);
                                                                                        return IokeObject.IsKind(args[0], kind, context) ? context.runtime.True : context.runtime.False;
                                                                                    })));
        
            obj.RegisterMethod(runtime.NewNativeMethod("Takes one evaluated argument and returns either true or false if this object or one of it's mimics mimics that argument. exactly the same as 'mimics?'", 
                                                       new NativeMethod("other:is?", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositional("other")
                                                                        .WithRequiredPositional("potentialMimic")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            var args = new SaneArrayList();
                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, args, new SaneDictionary<string, object>());
                                                                        
                                                                            IokeObject arg = IokeObject.As(args[1], context);
                                                                            return IokeObject.IsMimic(args[0], arg, context) ? context.runtime.True : context.runtime.False;
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("returns a list of all the mimics of the receiver. it will not be the same list as is used to back the object, so modifications to this list will not show up in the object.", 
                                                       new TypeCheckingNativeMethod("other:mimics", TypeCheckingArgumentsDefinition.builder()
                                                                                    .WithRequiredPositional("other")
                                                                                    .Arguments,
                                                                                    (method, on, args, keywords, context, message) => {
                                                                                        var l = new SaneArrayList();
                                                                                        foreach(object x in IokeObject.GetMimics(args[0], context)) l.Add(x);
                                                                                        return context.runtime.NewList(l);
                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("removes all mimics on the receiver, and returns the receiver", 
                                                       new TypeCheckingNativeMethod("other:removeAllMimics!", TypeCheckingArgumentsDefinition.builder()
                                                                                    .WithRequiredPositional("other")
                                                                                    .Arguments,
                                                                                    (method, on, args, keywords, context, message) => {
                                                                                        IokeObject.RemoveAllMimics(args[0], message, context);
                                                                                        return args[0];
                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("removes the argument mimic from the list of all mimics on the receiver. will do nothing if the receiver has no such mimic. it returns the receiver", 
                                                       new NativeMethod("other:removeMimic!", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositional("other")
                                                                        .WithRequiredPositional("mimicToRemove")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            var args = new SaneArrayList();
                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, args, new SaneDictionary<string, object>());
                                                                            IokeObject.RemoveMimic(args[0], args[1], message, context);
                                                                            return args[0];
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("Takes one evaluated argument and adds it to the list of mimics for the receiver. the receiver will be returned.", 
                                                       new NativeMethod("other:mimic!", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositional("other")
                                                                        .WithRequiredPositional("newMimic")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            var args = new SaneArrayList();
                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, args, new SaneDictionary<string, object>());
                                                                            IokeObject newMimic = IokeObject.As(args[1], context);
                                                                            IokeObject.As(args[0], context).Mimics(newMimic, message, context);
                                                                            return args[0];
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("Takes one evaluated argument and prepends it to the list of mimics for the receiver. the receiver will be returned.", 
                                                       new NativeMethod("other:prependMimic!", DefaultArgumentsDefinition.builder()
                                                                        .WithRequiredPositional("other")
                                                                        .WithRequiredPositional("newMimic")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            var args = new SaneArrayList();
                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, args, new SaneDictionary<string, object>());
                                                                            IokeObject newMimic = IokeObject.As(args[1], context);
                                                                            IokeObject.As(args[0], context).Mimics(0, newMimic, message, context);
                                                                            return args[0];
                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("returns true if the receiver is frozen, otherwise false", 
                                                       new TypeCheckingNativeMethod("other:frozen?", TypeCheckingArgumentsDefinition.builder()
                                                                                    .WithRequiredPositional("other")
                                                                                    .Arguments,
                                                                                    (method, on, args, keywords, context, message) => {
                                                                                        return IokeObject.IsFrozen(args[0]) ? context.runtime.True : context.runtime.False;
                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("ensures that the receiver is frozen", 
                                                       new TypeCheckingNativeMethod("other:freeze!", TypeCheckingArgumentsDefinition.builder()
                                                                                    .WithRequiredPositional("other")
                                                                                    .Arguments,
                                                                                    (method, on, args, keywords, context, message) => {
                                                                                        IokeObject.Freeze(args[0]);
                                                                                        return args[0];
                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("ensures that the receiver is not frozen", 
                                                       new TypeCheckingNativeMethod("other:thaw!", TypeCheckingArgumentsDefinition.builder()
                                                                                    .WithRequiredPositional("other")
                                                                                    .Arguments,
                                                                                    (method, on, args, keywords, context, message) => {
                                                                                        IokeObject.Thaw(args[0]);
                                                                                        return args[0];
                                                                                    })));
        }
    }
}
