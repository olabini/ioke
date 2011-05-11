
namespace Ioke.Lang {
    using System.Collections;
    using System.Collections.Generic;

    public abstract class IokeData {
        public readonly int type;

        public const int TYPE_NONE = 0;
        public const int TYPE_DEFAULT_METHOD = 1;
        public const int TYPE_DEFAULT_MACRO = 2;
        public const int TYPE_DEFAULT_SYNTAX = 3;
        public const int TYPE_LEXICAL_MACRO = 4;
        public const int TYPE_ALIAS_METHOD = 5;
        public const int TYPE_NATIVE_METHOD = 6;
        public const int TYPE_METHOD_PROTOTYPE = 11;
        public const int TYPE_LEXICAL_BLOCK = 12;

        public IokeData() : this(TYPE_NONE) {
        }

        public IokeData(int type) {
            this.type = type;
        }

        private class NoneIokeData : IokeData {}

        private class NilIokeData : IokeData {
            public override void Init(IokeObject obj) {
                obj.Kind = "nil";
                obj.body.flags |= IokeObject.NIL_F | IokeObject.FALSY_F;
            }

            public override void CheckMimic(IokeObject obj, IokeObject m, IokeObject context) {
                IokeObject condition = IokeObject.As(IokeObject.GetCellChain(context.runtime.Condition,
                                                                             m,
                                                                             context,
                                                                             "Error",
                                                                             "CantMimicOddball"), context).Mimic(m, context);
                condition.SetCell("message", m);
                condition.SetCell("context", context);
                condition.SetCell("receiver", obj);
                context.runtime.ErrorCondition(condition);
            }

            public override string ToString(IokeObject self) {
                return "nil";
            }
        }

        private class FalseIokeData : IokeData {
            public override void Init(IokeObject obj) {
                obj.Kind = "false";
                obj.body.flags |= IokeObject.FALSY_F;
            }

            public override void CheckMimic(IokeObject obj, IokeObject m, IokeObject context) {
                IokeObject condition = IokeObject.As(IokeObject.GetCellChain(context.runtime.Condition,
                                                                             m,
                                                                             context,
                                                                             "Error",
                                                                             "CantMimicOddball"), context).Mimic(m, context);
                condition.SetCell("message", m);
                condition.SetCell("context", context);
                condition.SetCell("receiver", obj);
                context.runtime.ErrorCondition(condition);
            }

            public override string ToString(IokeObject self) {
                return "false";
            }
        }

        private class TrueIokeData : IokeData {
            public override void Init(IokeObject obj) {
                obj.Kind = "true";
            }

            public override void CheckMimic(IokeObject obj, IokeObject m, IokeObject context) {
                IokeObject condition = IokeObject.As(IokeObject.GetCellChain(context.runtime.Condition,
                                                                             m,
                                                                             context,
                                                                             "Error",
                                                                             "CantMimicOddball"), context).Mimic(m, context);
                condition.SetCell("message", m);
                condition.SetCell("context", context);
                condition.SetCell("receiver", obj);
                context.runtime.ErrorCondition(condition);
            }

            public override string ToString(IokeObject self) {
                return "true";
            }
        }

        public static readonly IokeData None = new NoneIokeData();
        public static readonly IokeData Nil = new NilIokeData();
        public static readonly IokeData False = new FalseIokeData();
        public static readonly IokeData True = new TrueIokeData();

        public virtual IokeData CloneData(IokeObject obj, IokeObject m, IokeObject context) {
            return this;
        }

        public virtual bool IsMessage {get{return false;}}
        public virtual bool IsSymbol {get{return false;}}
        public virtual void CheckMimic(IokeObject obj, IokeObject m, IokeObject context) {}

        private static void report(object self, IokeObject context, IokeObject message, string name) {
            IokeObject condition = IokeObject.As(IokeObject.GetCellChain(context.runtime.Condition,
                                                                         message,
                                                                         context,
                                                                         "Error",
                                                                         "Invocation",
                                                                         "NotActivatable"), context).Mimic(message, context);
            condition.SetCell("message", message);
            condition.SetCell("context", context);
            condition.SetCell("receiver", self);
            condition.SetCell("methodName", context.runtime.GetSymbol(name));
            context.runtime.ErrorCondition(condition);
        }

        public virtual void Init(IokeObject obj) {}

        public virtual IList Arguments(IokeObject self) {
            report(self, self, self, "getArguments");
            return null;
        }



        public static object ActivateFixed(IokeObject self, IokeObject context, IokeObject message, object on) {
            object cell = IokeObject.FindCell(self, "activate");
            if(cell == context.runtime.nul) {
                report(self, context, message, "activate");
                return context.runtime.nil;
            } else {
                IokeObject newMessage = Message.DeepCopy(message);
                newMessage.Arguments.Clear();
                newMessage.Arguments.Add(context.runtime.CreateMessage(Message.Wrap(context)));
                newMessage.Arguments.Add(context.runtime.CreateMessage(Message.Wrap(message)));
                newMessage.Arguments.Add(context.runtime.CreateMessage(Message.Wrap(IokeObject.As(on, context))));
                return Interpreter.GetOrActivate(cell, context, newMessage, self);
            }
        }

        public virtual string ToString(IokeObject self) {
            int h = HashCode(self);
            string hash = System.Convert.ToString(h, 16).ToUpper();
            if(self == self.runtime.nul) {
                return "#<nul:" + hash + ">";
            }

            object obj = Interpreter.Send(self.runtime.kindMessage, self.runtime.Ground, self);
            string kind = ((Text)IokeObject.dataOf(obj)).GetText();
            return "#<" + kind + ":" + hash + ">";
        }

        public virtual string GetName(IokeObject self) {
            report(self, self, self, "getName");
            return null;
        }

        public virtual string GetFile(IokeObject self) {
            report(self, self, self, "getFile");
            return null;
        }

        public virtual int GetLine(IokeObject self) {
            report(self, self, self, "getLine");
            return -1;
        }

        public virtual int GetPosition(IokeObject self) {
            report(self, self, self, "getPosition");
            return -1;
        }

        public virtual IokeObject TryConvertToText(IokeObject self, IokeObject m, IokeObject context) {
            return null;
        }

        public virtual IokeObject ConvertToText(IokeObject self, IokeObject m, IokeObject context, bool signalCondition) {
            if(signalCondition) {
                IokeObject condition = IokeObject.As(IokeObject.GetCellChain(context.runtime.Condition,
                                                                                   m,
                                                                                   context,
                                                                                   "Error",
                                                                                   "Type",
                                                                                   "IncorrectType"), context).Mimic(m, context);
                condition.SetCell("message", m);
                condition.SetCell("context", context);
                condition.SetCell("receiver", self);
                condition.SetCell("expectedType", context.runtime.GetSymbol("Text"));

                object[] newCell = new object[]{self};

                context.runtime.WithRestartReturningArguments(()=>{context.runtime.ErrorCondition(condition);},
                                                              context,
                                                              new IokeObject.UseValue("text", newCell));
                return IokeObject.ConvertToText(newCell[0], m, context, signalCondition);
            }
            return null;
        }

        public virtual IokeObject ConvertToSymbol(IokeObject self, IokeObject m, IokeObject context, bool signalCondition) {
            if(signalCondition) {
                IokeObject condition = IokeObject.As(IokeObject.GetCellChain(context.runtime.Condition,
                                                                             m,
                                                                             context,
                                                                             "Error",
                                                                             "Type",
                                                                             "IncorrectType"), context).Mimic(m, context);
                condition.SetCell("message", m);
                condition.SetCell("context", context);
                condition.SetCell("receiver", self);
                condition.SetCell("expectedType", context.runtime.GetSymbol("Symbol"));

                object[] newCell = new object[]{self};

                context.runtime.WithRestartReturningArguments(() => {context.runtime.ErrorCondition(condition);},
                                                              context,
                                                              new IokeObject.UseValue("symbol", newCell));
                return IokeObject.ConvertToSymbol(newCell[0], m, context, signalCondition);
            }
            return null;
        }

        public virtual IokeObject ConvertToRegexp(IokeObject self, IokeObject m, IokeObject context) {
            IokeObject condition = IokeObject.As(IokeObject.GetCellChain(context.runtime.Condition,
                                                                         m,
                                                                         context,
                                                                         "Error",
                                                                         "Type",
                                                                         "IncorrectType"), context).Mimic(m, context);
            condition.SetCell("message", m);
            condition.SetCell("context", context);
            condition.SetCell("receiver", self);
            condition.SetCell("expectedType", context.runtime.GetSymbol("Regexp"));

            object[] newCell = new object[]{self};

            context.runtime.WithRestartReturningArguments(()=>{context.runtime.ErrorCondition(condition);},
                                                          context,
                                                          new IokeObject.UseValue("regexp", newCell));
            return IokeObject.ConvertToRegexp(newCell[0], m, context);
        }

        public virtual IokeObject ConvertToNumber(IokeObject self, IokeObject m, IokeObject context) {
            IokeObject condition = IokeObject.As(IokeObject.GetCellChain(context.runtime.Condition,
                                                                         m,
                                                                         context,
                                                                         "Error",
                                                                         "Type",
                                                                         "IncorrectType"), context).Mimic(m, context);
            condition.SetCell("message", m);
            condition.SetCell("context", context);
            condition.SetCell("receiver", self);
            condition.SetCell("expectedType", context.runtime.GetSymbol("Number"));

            object[] newCell = new object[]{self};

            context.runtime.WithRestartReturningArguments(()=>{context.runtime.ErrorCondition(condition);},
                                                          context,
                                                          new IokeObject.UseValue("number", newCell));

            return IokeObject.ConvertToNumber(newCell[0], m, context);
        }

        public object ConvertTo(IokeObject self, string kind, bool signalCondition, string conversionMethod, IokeObject message, IokeObject context) {
            if(IokeObject.IsKind(self, kind, context)) {
                return self;
            }
            if(signalCondition) {
                IokeObject condition = IokeObject.As(IokeObject.GetCellChain(context.runtime.Condition,
                                                                                   message,
                                                                                   context,
                                                                                   "Error",
                                                                                   "Type",
                                                                                   "IncorrectType"), context).Mimic(message, context);
                condition.SetCell("message", message);
                condition.SetCell("context", context);
                condition.SetCell("receiver", self);
                condition.SetCell("expectedType", context.runtime.GetSymbol(kind));

                object[] newCell = new object[]{self};

                context.runtime.WithRestartReturningArguments(()=>{context.runtime.ErrorCondition(condition);},
                                                              context,
                                                              new IokeObject.UseValue(kind, newCell));

                return IokeObject.ConvertTo(newCell[0], kind, signalCondition, conversionMethod, message, context);
            }
            return null;
        }

        public object ConvertTo(IokeObject self, object mimic, bool signalCondition, string conversionMethod, IokeObject message, IokeObject context) {
            if(IokeObject.IsMimic(self, IokeObject.As(mimic, context), context)) {
                return self;
            }
            if(signalCondition) {
                IokeObject condition = IokeObject.As(IokeObject.GetCellChain(context.runtime.Condition,
                                                                                   message,
                                                                                   context,
                                                                                   "Error",
                                                                                   "Type",
                                                                                   "IncorrectType"), context).Mimic(message, context);
                condition.SetCell("message", message);
                condition.SetCell("context", context);
                condition.SetCell("receiver", self);
                condition.SetCell("expectedType", mimic);

                object[] newCell = new object[]{self};

                context.runtime.WithRestartReturningArguments(()=>{context.runtime.ErrorCondition(condition);},
                                                              context,
                                                              new IokeObject.UseValue("object", newCell));

                return IokeObject.ConvertTo(mimic, newCell[0], signalCondition, conversionMethod, message, context);
            }
            return null;
        }

        public virtual IokeObject ConvertToRational(IokeObject self, IokeObject m, IokeObject context, bool signalCondition) {
            if(signalCondition) {
                IokeObject condition = IokeObject.As(IokeObject.GetCellChain(context.runtime.Condition,
                                                                                   m,
                                                                                   context,
                                                                                   "Error",
                                                                                   "Type",
                                                                                   "IncorrectType"), context).Mimic(m, context);
                condition.SetCell("message", m);
                condition.SetCell("context", context);
                condition.SetCell("receiver", self);
                condition.SetCell("expectedType", context.runtime.GetSymbol("Rational"));

                object[] newCell = new object[]{self};

                context.runtime.WithRestartReturningArguments(()=>{context.runtime.ErrorCondition(condition);},
                                                              context,
                                                              new IokeObject.UseValue("rational", newCell));

                return IokeObject.ConvertToRational(newCell[0], m, context, signalCondition);
            }
            return null;
        }

        public virtual IokeObject ConvertToDecimal(IokeObject self, IokeObject m, IokeObject context, bool signalCondition) {
            if(signalCondition) {
                IokeObject condition = IokeObject.As(IokeObject.GetCellChain(context.runtime.Condition,
                                                                             m,
                                                                             context,
                                                                             "Error",
                                                                             "Type",
                                                                             "IncorrectType"), context).Mimic(m, context);
                condition.SetCell("message", m);
                condition.SetCell("context", context);
                condition.SetCell("receiver", self);
                condition.SetCell("expectedType", context.runtime.GetSymbol("Decimal"));

                object[] newCell = new object[]{self};

                context.runtime.WithRestartReturningArguments(()=>{context.runtime.ErrorCondition(condition);},
                                                              context,
                                                              new IokeObject.UseValue("decimal", newCell));

                return IokeObject.ConvertToDecimal(newCell[0], m, context, signalCondition);
            }
            return null;
        }

        public virtual string ConvertMethod {
            get { return null; }
        }

        public virtual bool IsEqualTo(IokeObject self, object other) {
            object cell = IokeObject.FindCell(self, "==");
            if(cell == self.runtime.nul) {
                bool result = (other is IokeObject) && (object.ReferenceEquals(self.body, IokeObject.As(other, self).body));
                return result;
            } else {
                bool result = IokeObject.IsObjectTrue(Interpreter.Send(self.runtime.eqMessage, self.runtime.Ground, self, self.runtime.CreateMessage(Message.Wrap(IokeObject.As(other, self)))));
                return result;
            }
        }

        public int HashCode(IokeObject self) {
            object cell = IokeObject.FindCell(self, "hash");
            if(cell == self.runtime.nul) {
                return System.Runtime.CompilerServices.RuntimeHelpers.GetHashCode(self.body);
            } else {
                return Number.ExtractInt(Interpreter.Send(self.runtime.hashMessage, self.runtime.Ground, self), self.runtime.hashMessage, self.runtime.Ground);
            }
        }
    }
}
