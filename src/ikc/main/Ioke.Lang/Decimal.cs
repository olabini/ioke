
namespace Ioke.Lang {
    using System;
    using System.Globalization;
    using Ioke.Math;

    public class Decimal : IokeData {
        private readonly BigDecimal value;

        public static BigDecimal GetValue(object number) {
            return ((Decimal)IokeObject.dataOf(number)).value;
        }

        public Decimal(string textRepresentation) {
            this.value = new BigDecimal(textRepresentation);
        }

        public Decimal(BigDecimal value) {
            this.value = value;
        }

        public static Decimal CreateDecimal(string val) {
            return new Decimal(val);
        }

        public static Decimal CreateDecimal(RatNum val) {
            return new Decimal(new BigDecimal(val.longValue()));
        }

        public static Decimal CreateDecimal(BigDecimal val) {
            return new Decimal(val);
        }

        public string AsNativeString() {
            string s = value.ToString(MathContext.PLAIN);
            if(s[s.Length-1] == '0' && s.IndexOf('.') != -1 && s.IndexOf('e') == -1 && s.IndexOf('E') == -1) {
                int end = s.Length-1;
                while(s[end] == '0' && s[end-1] != '.') end--;
                if(s[end-1] == '.') end++;
                return s.Substring(0, end);
            }
            return s;
        }

        public override string ToString() {
            return AsNativeString();
        }

        public override string ToString(IokeObject obj) {
            return AsNativeString();
        }

        public override IokeObject ConvertToRational(IokeObject self, IokeObject m, IokeObject context, bool signalCondition) {
            System.Console.Error.WriteLine("convertorational should be implemented");
            throw new Exception("TODO: implement");
        }

        public override IokeObject ConvertToDecimal(IokeObject self, IokeObject m, IokeObject context, bool signalCondition) {
            return self;
        }

        public static string GetInspect(object on) {
            return ((Decimal)(IokeObject.dataOf(on))).Inspect(on);
        }

        public string Inspect(object obj) {
            return AsNativeString();
        }

        public override void Init(IokeObject obj) {
            Runtime runtime = obj.runtime;

            obj.Kind = "Number Decimal";
            runtime.Decimal = obj;

            obj.RegisterMethod(runtime.NewNativeMethod("Returns a text representation of the object", 
                                                       new TypeCheckingNativeMethod.WithNoArguments("asText", obj,
                                                                                                    (method, on, args, keywords, context, message) => {
                                                                                                        return runtime.NewText(on.ToString());
                                                                                                    })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("Returns a text inspection of the object", 
                                                           new TypeCheckingNativeMethod.WithNoArguments("inspect", obj,
                                                                                                        (method, on, args, keywords, context, message) => {
                                                                                                            return method.runtime.NewText(Decimal.GetInspect(on));
                                                                                                        })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("Returns a brief text inspection of the object", 
                                                           new TypeCheckingNativeMethod.WithNoArguments("notice", obj, 
                                                                                                        (method, on, args, keywords, context, message) => {
                                                                                                            return method.runtime.NewText(Decimal.GetInspect(on));
                                                                                                        })));

            obj.RegisterMethod(runtime.NewNativeMethod("compares this number against the argument, true if this number is the same, otherwise false", 
                                                       new TypeCheckingNativeMethod("==", TypeCheckingArgumentsDefinition.builder()
                                                                                    .ReceiverMustMimic(obj)
                                                                                    .WithRequiredPositional("other")
                                                                                    .Arguments,
                                                                                    (method, on, args, keywords, context, message) => {
                                                                                        object arg = args[0];
                                                                                        if(IokeObject.dataOf(arg) is Number) {
                                                                                            return (Decimal.GetValue(on).CompareTo(Number.GetValue(arg).AsBigDecimal()) == 0) ? context.runtime.True : context.runtime.False;
                                                                                        } else if(IokeObject.dataOf(arg) is Decimal) {
                                                                                            return (Decimal.GetValue(on).CompareTo(Decimal.GetValue(arg)) == 0) ? context.runtime.True : context.runtime.False;
                                                                                        } else {
                                                                                            return context.runtime.False;
                                                                                        }
                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("compares this number against the argument, returning -1, 0 or 1 based on which one is larger. if the argument is a rational, it will be converted into a form suitable for comparing against a decimal, and then compared. if the argument is neither a Rational nor a Decimal, it tries to call asDecimal, and if that doesn't work it returns nil.", 
                                                       new TypeCheckingNativeMethod("<=>", TypeCheckingArgumentsDefinition.builder()
                                                                                    .ReceiverMustMimic(obj)
                                                                                    .WithRequiredPositional("other")
                                                                                    .Arguments,
                                                                                    (method, on, args, keywords, context, message) => {
                                                                                        object arg = args[0];
                                                                                        IokeData data = IokeObject.dataOf(arg);
                    
                                                                                        if(data is Number) {
                                                                                            return context.runtime.NewNumber(Decimal.GetValue(on).CompareTo(Number.GetValue(arg).AsBigDecimal()));
                                                                                        } else {
                                                                                            if(!(data is Decimal)) {
                                                                                                arg = IokeObject.ConvertToDecimal(arg, message, context, false);
                                                                                                if(!(IokeObject.dataOf(arg) is Decimal)) {
                                                                                                    // Can't compare, so bail out
                                                                                                    return context.runtime.nil;
                                                                                                }
                                                                                            }

                                                                                            if(on == context.runtime.Decimal || arg == context.runtime.Decimal) {
                                                                                                if(arg == on) {
                                                                                                    return context.runtime.NewNumber(0);
                                                                                                }
                                                                                                return context.runtime.nil;
                                                                                            }

                                                                                            return context.runtime.NewNumber(Decimal.GetValue(on).CompareTo(Decimal.GetValue(arg)));
                                                                                        }
                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("returns the difference between this number and the argument. if the argument is a rational, it will be converted into a form suitable for subtracting against a decimal, and then subtracted. if the argument is neither a Rational nor a Decimal, it tries to call asDecimal, and if that fails it signals a condition.", 
                                                       new TypeCheckingNativeMethod("-", TypeCheckingArgumentsDefinition.builder()
                                                                                    .ReceiverMustMimic(obj)
                                                                                    .WithRequiredPositional("subtrahend")
                                                                                    .Arguments,
                                                                                    (method, on, args, keywords, context, message) => {
                                                                                        object arg = args[0];

                                                                                        IokeData data = IokeObject.dataOf(arg);
                    
                                                                                        if(data is Number) {
                                                                                            return context.runtime.NewDecimal(Decimal.GetValue(on).subtract(Number.GetValue(arg).AsBigDecimal()));
                                                                                        } else {
                                                                                            if(!(data is Decimal)) {
                                                                                                arg = IokeObject.ConvertToDecimal(arg, message, context, true);
                                                                                            }

                                                                                            return context.runtime.NewDecimal(Decimal.GetValue(on).subtract(Decimal.GetValue(arg)));
                                                                                        }
                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("returns the sum of this number and the argument. if the argument is a rational, it will be converted into a form suitable for addition against a decimal, and then added. if the argument is neither a Rational nor a Decimal, it tries to call asDecimal, and if that fails it signals a condition.", 
                                                       new TypeCheckingNativeMethod("+", TypeCheckingArgumentsDefinition.builder()
                                                                                    .ReceiverMustMimic(obj)
                                                                                    .WithRequiredPositional("addend")
                                                                                    .Arguments,
                                                                                    (method, on, args, keywords, context, message) => {
                                                                                        object arg = args[0];
                                                                                        IokeData data = IokeObject.dataOf(arg);
                    
                                                                                        if(data is Number) {
                                                                                            return context.runtime.NewDecimal(Decimal.GetValue(on).add(Number.GetValue(arg).AsBigDecimal()));
                                                                                        } else {
                                                                                            if(!(data is Decimal)) {
                                                                                                arg = IokeObject.ConvertToDecimal(arg, message, context, true);
                                                                                            }

                                                                                            return context.runtime.NewDecimal(Decimal.GetValue(on).add(Decimal.GetValue(arg)));
                                                                                        }
                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("returns the product of this number and the argument. if the argument is a rational, the receiver will be converted into a form suitable for multiplying against a decimal, and then multiplied. if the argument is neither a Rational nor a Decimal, it tries to call asDecimal, and if that fails it signals a condition.", 
                                                       new TypeCheckingNativeMethod("*", TypeCheckingArgumentsDefinition.builder()
                                                                                    .ReceiverMustMimic(obj)
                                                                                    .WithRequiredPositional("multiplier")
                                                                                    .Arguments,
                                                                                    (method, on, args, keywords, context, message) => {
                                                                                        object arg = args[0];
                                                                                        
                                                                                        IokeData data = IokeObject.dataOf(arg);
                    
                                                                                        if(data is Number) {
                                                                                            return context.runtime.NewDecimal(Decimal.GetValue(on).multiply(Number.GetValue(arg).AsBigDecimal()));
                                                                                        } else {
                                                                                            if(!(data is Decimal)) {
                                                                                                arg = IokeObject.ConvertToDecimal(arg, message, context, true);
                                                                                            }

                                                                                            return context.runtime.NewDecimal(Decimal.GetValue(on).multiply(Decimal.GetValue(arg)));
                                                                                        }
                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("returns the quotient of this number and the argument.", 
                                                       new TypeCheckingNativeMethod("/", TypeCheckingArgumentsDefinition.builder()
                                                                                    .ReceiverMustMimic(obj)
                                                                                    .WithRequiredPositional("divisor")
                                                                                    .Arguments,
                                                                                    (method, on, args, keywords, context, message) => {
                                                                                        object arg = args[0];
                                                                                        IokeData data = IokeObject.dataOf(arg);
                    
                                                                                        if(data is Number) {
                                                                                            return context.runtime.NewDecimal(Decimal.GetValue(on).divide(Number.GetValue(arg).AsBigDecimal()));
                                                                                        } else {
                                                                                            if(!(data is Decimal)) {
                                                                                                arg = IokeObject.ConvertToDecimal(arg, message, context, true);
                                                                                            }

                                                                                            while(Decimal.GetValue(arg).CompareTo(BigDecimal.ZERO) == 0) {
                                                                                                IokeObject condition = IokeObject.As(IokeObject.GetCellChain(context.runtime.Condition, 
                                                                                                                                                             message, 
                                                                                                                                                             context, 
                                                                                                                                                             "Error", 
                                                                                                                                                             "Arithmetic",
                                                                                                                                                             "DivisionByZero"), context).Mimic(message, context);
                                                                                                condition.SetCell("message", message);
                                                                                                condition.SetCell("context", context);
                                                                                                condition.SetCell("receiver", on);

                                                                                                object[] newCell = new object[]{arg};

                                                                                                context.runtime.WithRestartReturningArguments(()=>{context.runtime.ErrorCondition(condition);},
                                                                                                                                              context,
                                                                                                                                              new IokeObject.UseValue("newValue", newCell));
                                                                                                arg = newCell[0];
                                                                                            }

                                                                                            BigDecimal result = null;
                                                                                            try {
                                                                                                result = Decimal.GetValue(on).divide(Decimal.GetValue(arg), BigDecimal.ROUND_UNNECESSARY);
                                                                                            } catch(System.ArithmeticException) {
                                                                                                result = Decimal.GetValue(on).divide(Decimal.GetValue(arg), MathContext.DECIMAL128);
                                                                                            }
                                                                                            return context.runtime.NewDecimal(result);
                                                                                        }
                                                                                    })));
        }

        public override bool IsEqualTo(IokeObject self, object other) {
            return ((other is IokeObject) && 
                    (IokeObject.dataOf(other) is Decimal) 
                    && ((self == self.runtime.Decimal && other == self) ||
                        this.value.Equals(((Decimal)IokeObject.dataOf(other)).value)));
        }

        public override int HashCode(IokeObject self) {
            return this.value.GetHashCode();
        }
    }
}
