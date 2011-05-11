
namespace Ioke.Lang {
    using System;
    using System.Collections;
    using System.Collections.Generic;
    using System.IO;
    using System.Text;
    using Ioke.Lang.Parser;
    using Ioke.Lang.Util;

    public class Interpreter {
        public object Evaluate(IokeObject self, IokeObject ctx, object ground, object receiver) {
            Runtime runtime = self.runtime;
            object current = receiver;
            object tmp = null;
            string name = null;
            object lastReal = runtime.nil;
            IokeObject m = self;
            Message msg;
            while(m != null) {
                msg = (Message)m.data;
                tmp = msg.cached;
                if(tmp != null) {
                    lastReal = current = tmp;
                } else if((name = msg.name).Equals(".")) {
                    current = ctx;
                } else if(name.Length > 0 && msg.arguments.Count == 0 && name[0] == ':') {
                    lastReal = msg.cached = current = runtime.GetSymbol(name.Substring(1));
                } else {
                    IokeObject recv = IokeObject.As(current, ctx);
                    lastReal = current = tmp = Perform(recv, recv, ctx, m, name);
                }
                
                m = Message.GetNext(m);
            }
            return lastReal;
        }






        public static object GetEvaluatedArgument(object argument, IokeObject context) {
            if(!(argument is IokeObject)) {
                return argument;
            }

            IokeObject o = IokeObject.As(argument, context);
            if(!o.IsMessage) {
                return o;
            }

            var xx = context.runtime.interpreter.Evaluate(o, context, context.RealContext, context);
            return xx;
        }

        public static object GetEvaluatedArgument(IokeObject self, int index, IokeObject context) {
            return GetEvaluatedArgument(self.Arguments[index], context);
        }

        public static IList GetEvaluatedArguments(IokeObject self, IokeObject context) {
            IList arguments = self.Arguments;
            IList args = new SaneArrayList(arguments.Count);
            foreach(object o in arguments) {
                args.Add(GetEvaluatedArgument(o, context));
            }
            return args;
        }









        public static object Send(IokeObject self, IokeObject context, Object recv) {
            object result;
            if((result = ((Message)self.data).cached) != null) {
                return result;
            }

            return Perform(recv, context, self);
        }

        public static object Send(IokeObject self, IokeObject context, object recv, object argument) {
            object result;
            if((result = ((Message)self.data).cached) != null) {
                return result;
            }

            IokeObject m = self.AllocateCopy(self, context);
            m.SingleMimicsWithoutCheck(context.runtime.Message);
            m.Arguments.Clear();
            m.Arguments.Add(argument);
            return Perform(recv, context, m);
        }

        public static object Send(IokeObject self, IokeObject context, object recv, object arg1, object arg2) {
            object result;
            if((result = ((Message)self.data).cached) != null) {
                return result;
            }

            IokeObject m = self.AllocateCopy(self, context);
            m.Arguments.Clear();
            m.Arguments.Add(arg1);
            m.Arguments.Add(arg2);
            return Perform(recv, context, m);
        }

        public static object Send(IokeObject self, IokeObject context, object recv, object arg1, object arg2, object arg3) {
            object result;
            if((result = ((Message)self.data).cached) != null) {
                return result;
            }

            IokeObject m = self.AllocateCopy(self, context);
            m.Arguments.Clear();
            m.Arguments.Add(arg1);
            m.Arguments.Add(arg2);
            m.Arguments.Add(arg3);
            return Perform(recv, context, m);
        }

        public static object Send(IokeObject self, IokeObject context, object recv, IList args) {
            object result;
            if((result = ((Message)self.data).cached) != null) {
                return result;
            }

            IokeObject m = self.AllocateCopy(self, context);
            m.Arguments.Clear();
            foreach(object o in args) m.Arguments.Add(o);
            return Perform(recv, context, m);
        }




















        public static object Perform(object obj, IokeObject ctx, IokeObject message) {
            IokeObject recv = IokeObject.As(obj, ctx);
            return Perform(recv, recv, ctx, message, message.Name);
        }

        public static object SignalNoSuchCell(IokeObject message, IokeObject ctx, object obj, string name, object cell, IokeObject recv) {
            Runtime runtime = ctx.runtime;
            IokeObject condition = IokeObject.As(IokeObject.GetCellChain(runtime.Condition,
                                                                         message,
                                                                         ctx,
                                                                         "Error",
                                                                         "NoSuchCell"), ctx).Mimic(message, ctx);
        
            condition.SetCell("message", message);
            condition.SetCell("context", ctx);
            condition.SetCell("receiver", obj);
            condition.SetCell("cellName", runtime.GetSymbol(name));
     
            object[] newCell = new object[]{cell};
            runtime.WithRestartReturningArguments(()=>{runtime.ErrorCondition(condition);}, ctx,
                                                  new IokeObject.UseValue(name, newCell),
                                                  new IokeObject.StoreValue(name, newCell, recv));
            return newCell[0];
        }

        private static bool ShouldActivate(IokeObject io, IokeObject message) {
            return io.IsActivatable || ((io.data is CanRun) && message.Arguments.Count > 0);
        }

        private static object FindCell(IokeObject message, IokeObject ctx, object obj, string name, IokeObject recv) {
            Runtime runtime = ctx.runtime;
            object cell = IokeObject.FindCell(recv, name);
            object passed = null;
            while(cell == runtime.nul) {
                if(((cell = passed = IokeObject.FindCell(recv, "pass")) != runtime.nul) && IsApplicable(passed, message, ctx)) {
                    return cell;
                }
                cell = SignalNoSuchCell(message, ctx, obj, name, cell, recv);
            }
            return cell;
        }

        public static object Perform(object obj, IokeObject recv, IokeObject ctx, IokeObject message, string name) {
            object cell = FindCell(message, ctx, obj, name, recv);
            return GetOrActivate(cell, ctx, message, obj);
        }

        private static bool IsApplicable(object pass, IokeObject message, IokeObject ctx) {
            if(pass != null && pass != ctx.runtime.nul && IokeObject.FindCell(IokeObject.As(pass, ctx), "applicable?") != ctx.runtime.nul) {
                return IokeObject.IsObjectTrue(Send(ctx.runtime.isApplicableMessage, ctx, pass, ctx.runtime.CreateMessage(Message.Wrap(message))));
            }
            return true;
        }

        public static object GetOrActivate(object obj, IokeObject context, IokeObject message, object on) {
            if((obj is IokeObject) && ShouldActivate((IokeObject)obj, message)) {
                return Activate((IokeObject)obj, context, message, on);
            } else {
                return obj;
            }
        }

        public static object Activate(IokeObject receiver, IokeObject context, IokeObject message, object obj) {
            switch(receiver.data.type) {
            case IokeData.TYPE_DEFAULT_METHOD:
                return DefaultMethod.ActivateFixed(receiver, context, message, obj);
            case IokeData.TYPE_DEFAULT_MACRO:
                return DefaultMacro.ActivateFixed(receiver, context, message, obj);
            case IokeData.TYPE_DEFAULT_SYNTAX:
                return DefaultSyntax.ActivateFixed(receiver, context, message, obj);
            case IokeData.TYPE_LEXICAL_MACRO:
                return LexicalMacro.ActivateFixed(receiver, context, message, obj);
            case IokeData.TYPE_NATIVE_METHOD:
                return NativeMethod.ActivateFixed(receiver, context, message, obj);
            case IokeData.TYPE_METHOD_PROTOTYPE:
                return Method.ActivateFixed(receiver, context, message, obj);
            case IokeData.TYPE_LEXICAL_BLOCK:
                return LexicalBlock.ActivateFixed(receiver, context, message, obj);
            case IokeData.TYPE_ALIAS_METHOD:
                return AliasMethod.ActivateFixed(receiver, context, message, obj);
            case IokeData.TYPE_NONE:
            default:
                return IokeData.ActivateFixed(receiver, context, message, obj);
            }
        }

        public static object ActivateWithData(IokeObject receiver, IokeObject context, IokeObject message, object obj, IDictionary<string, object> d1) {
            switch(receiver.data.type) {
            case IokeData.TYPE_DEFAULT_METHOD:
                return DefaultMethod.ActivateWithDataFixed(receiver, context, message, obj, d1);
            case IokeData.TYPE_DEFAULT_MACRO:
                return DefaultMacro.ActivateWithDataFixed(receiver, context, message, obj, d1);
            case IokeData.TYPE_DEFAULT_SYNTAX:
                return DefaultSyntax.ActivateWithDataFixed(receiver, context, message, obj, d1);
            case IokeData.TYPE_LEXICAL_MACRO:
                return LexicalMacro.ActivateWithDataFixed(receiver, context, message, obj, d1);
            case IokeData.TYPE_NATIVE_METHOD:
                return NativeMethod.ActivateFixed(receiver, context, message, obj);
            case IokeData.TYPE_METHOD_PROTOTYPE:
                return Method.ActivateFixed(receiver, context, message, obj);
            case IokeData.TYPE_LEXICAL_BLOCK:
                return LexicalBlock.ActivateWithDataFixed(receiver, context, message, obj, d1);
            case IokeData.TYPE_ALIAS_METHOD:
                return AliasMethod.ActivateFixed(receiver, context, message, obj);
            case IokeData.TYPE_NONE:
            default:
                return IokeData.ActivateFixed(receiver, context, message, obj);
            }
        }

        public static object ActivateWithCallAndData(IokeObject receiver, IokeObject context, IokeObject message, object obj, object c, IDictionary<string, object> d1) {
            switch(receiver.data.type) {
            case IokeData.TYPE_DEFAULT_METHOD:
                return DefaultMethod.ActivateWithCallAndDataFixed(receiver, context, message, obj, c, d1);
            case IokeData.TYPE_DEFAULT_MACRO:
                return DefaultMacro.ActivateWithCallAndDataFixed(receiver, context, message, obj, c, d1);
            case IokeData.TYPE_DEFAULT_SYNTAX:
                return DefaultSyntax.ActivateWithCallAndDataFixed(receiver, context, message, obj, c, d1);
            case IokeData.TYPE_LEXICAL_MACRO:
                return LexicalMacro.ActivateWithCallAndDataFixed(receiver, context, message, obj, c, d1);
            case IokeData.TYPE_NATIVE_METHOD:
                return NativeMethod.ActivateFixed(receiver, context, message, obj);
            case IokeData.TYPE_METHOD_PROTOTYPE:
                return Method.ActivateFixed(receiver, context, message, obj);
            case IokeData.TYPE_LEXICAL_BLOCK:
                return LexicalBlock.ActivateWithCallAndDataFixed(receiver, context, message, obj, c, d1);
            case IokeData.TYPE_ALIAS_METHOD:
                return AliasMethod.ActivateFixed(receiver, context, message, obj);
            case IokeData.TYPE_NONE:
            default:
                return IokeData.ActivateFixed(receiver, context, message, obj);
            }
        }
    }
}
