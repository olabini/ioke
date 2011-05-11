
namespace Ioke.Lang {
    using System;
    using System.Collections;
    using System.Collections.Generic;
    using Ioke.Math;

    using Ioke.Lang.Util;

    public class Number : IokeData {
        readonly RatNum value;
        readonly bool kind;

        public Number(RatNum value) {
            this.value = value;
            kind = false;
        }

        private Number() {
            this.value = IntNum.make(0);
            kind = true;
        }

        public static IntNum GetFrom(long nativeNumber) {
            return IntNum.make(nativeNumber);
        }

        public static IntNum GetFrom(string textRepresentation) {
            if(textRepresentation.StartsWith("0x") || textRepresentation.StartsWith("0X")) {
                return IntNum.valueOf(textRepresentation.Substring(2), 16);
            } else {
                return IntNum.valueOf(textRepresentation);
            }
        }

        public RatNum Value {
            get { return value; }
        }

        public static RatNum GetValue(object number) {
            return ((Number)IokeObject.dataOf(number)).value;
        }

        public static Number Integer(string val) {
            return new Number(GetFrom(val));
        }

        public static Number Integer(long val) {
            return new Number(GetFrom(val));
        }

        public static Number Integer(IntNum val) {
            return new Number(val);
        }

        public static Number Ratio(IntFraction val) {
            return new Number(val);
        }

        public int AsNativeInteger() {
            return value.intValue();
        }

        public string AsNativeString() {
            return value.ToString();
        }

        public long AsNativeLong() {
            return value.longValue();
        }

        public override string ToString() {
            return AsNativeString();
        }

        public override string ToString(IokeObject obj) {
            return AsNativeString();
        }

        public static IntNum IntValue(object number) {
            return (IntNum)((Number)IokeObject.dataOf(number)).value;
        }

        public static int ExtractInt(object number, IokeObject m, IokeObject context) {
            if(!(IokeObject.dataOf(number) is Number)) {
                number = IokeObject.ConvertToNumber(number, m, context);
            }

            return IntValue(number).intValue();
        }

        public override IokeObject ConvertToNumber(IokeObject self, IokeObject m, IokeObject context) {
            return self;
        }

        public override IokeObject ConvertToRational(IokeObject self, IokeObject m, IokeObject context, bool signalCondition) {
            return self;
        }

        public override IokeObject ConvertToDecimal(IokeObject self, IokeObject m, IokeObject context, bool signalCondition) {
            return context.runtime.NewDecimal(this);
        }

        public override void Init(IokeObject obj) {
            Runtime runtime = obj.runtime;
            IokeObject number = obj;

            obj.Kind = "Number";
            obj.Mimics(IokeObject.As(IokeObject.FindCell(runtime.Mixins, "Comparing"), obj), runtime.nul, runtime.nul);

            IokeObject real = new IokeObject(runtime, "A real number can be either a rational number or a decimal number", new Number());
            real.MimicsWithoutCheck(number);
            real.Kind = "Number Real";
            number.RegisterCell("Real", real);

            IokeObject rational = new IokeObject(runtime, "A rational number is either an integer or a ratio", new Number());
            rational.MimicsWithoutCheck(real);
            rational.Kind = "Number Rational";
            number.RegisterCell("Rational", rational);

            IokeObject integer = new IokeObject(runtime, "An integral number", new Number());
            integer.MimicsWithoutCheck(rational);
            integer.Kind = "Number Integer";
            number.RegisterCell("Integer", integer);
            runtime.Integer = integer;

            IokeObject ratio = new IokeObject(runtime, "A ratio of two integral numbers", new Number());
            ratio.MimicsWithoutCheck(rational);
            ratio.Kind = "Number Ratio";
            number.RegisterCell("Ratio", ratio);
            runtime.Ratio = ratio;

            IokeObject _decimal = new IokeObject(runtime, "An exact, unlimited representation of a decimal number", new Decimal(BigDecimal.ZERO));
            _decimal.MimicsWithoutCheck(real);
            _decimal.Init();
            number.RegisterCell("Decimal", _decimal);

            IokeObject infinity = new IokeObject(runtime, "A value representing infinity", new Number(RatNum.infinity(1)));
            infinity.MimicsWithoutCheck(ratio);
            infinity.Kind = "Number Infinity";
            number.RegisterCell("Infinity", infinity);
            runtime.Infinity = infinity;

            IokeObject infinity2 = new IokeObject(runtime, "A value representing infinity", new Number(RatNum.infinity(1)));
            infinity2.MimicsWithoutCheck(ratio);
            infinity2.Kind = "Number \u221E";
            number.RegisterCell("\u221E", infinity2);

            number.RegisterMethod(runtime.NewNativeMethod("returns a hash for the number",
                                                           new NativeMethod.WithNoArguments("hash", (method, context, message, on, outer) => {
                                                                   outer.ArgumentsDefinition.CheckArgumentCount(context, message, on);
                                                                   return context.runtime.NewNumber(Number.GetValue(on).GetHashCode());
                                                               })));

            number.RegisterMethod(runtime.NewNativeMethod("returns the square root of the receiver. this should return the same result as calling ** with 0.5",
                                                           new NativeMethod.WithNoArguments("sqrt", (method, context, message, on, outer) => {
                                                                   outer.ArgumentsDefinition.CheckArgumentCount(context, message, on);

                                                                   RatNum value = Number.GetValue(on);
                                                                   if(value is IntFraction) {
                                                                       IntNum num = value.numerator();
                                                                       IntNum den = value.denominator();
                                                                       BigDecimal nums = new BigSquareRoot().Get(num.AsBigDecimal());
                                                                       BigDecimal dens = new BigSquareRoot().Get(den.AsBigDecimal());
                                                                       try {
                                                                           num = IntNum.valueOf(nums.toBigIntegerExact().ToString());
                                                                           den = IntNum.valueOf(dens.toBigIntegerExact().ToString());
                                                                           return context.runtime.NewNumber(new IntFraction(num, den));
                                                                       } catch(ArithmeticException) {
                                                                           // Ignore and fall through
                                                                       }
                                                                   }

                                                                   if(RatNum.compare(value, IntNum.zero()) < 1) {
                                                                       IokeObject condition = IokeObject.As(IokeObject.GetCellChain(context.runtime.Condition,
                                                                                                                                          message,
                                                                                                                                          context,
                                                                                                                                          "Error",
                                                                                                                                          "Arithmetic"), context).Mimic(message, context);
                                                                       condition.SetCell("message", message);
                                                                       condition.SetCell("context", context);
                                                                       condition.SetCell("receiver", on);

                                                                       context.runtime.ErrorCondition(condition);
                                                                   }
                                                                   return context.runtime.NewDecimal(new BigSquareRoot().Get(value.AsBigDecimal()));
                                                               })));

            number.RegisterMethod(runtime.NewNativeMethod("returns true if the left hand side number is equal to the right hand side number.",
                                                       new TypeCheckingNativeMethod("==", TypeCheckingArgumentsDefinition.builder()
                                                                                    .ReceiverMustMimic(runtime.Number)
                                                                                    .WithRequiredPositional("other")
                                                                                    .Arguments,
                                                                                    (method, on, args, keywords, context, message) => {
                                                                                        Number d = (Number)IokeObject.dataOf(on);
                                                                                        object other = args[0];

                                                                                        return ((other is IokeObject) &&
                                                                                                (IokeObject.dataOf(other) is Number)
                                                                                                && (((d.kind || ((Number)IokeObject.dataOf(other)).kind) ? on == other :
                                                                                                     d.value.Equals(((Number)IokeObject.dataOf(other)).value)))) ? context.runtime.True : context.runtime.False;
                                                                                    })));


            rational.RegisterMethod(runtime.NewNativeMethod("compares this number against the argument, returning -1, 0 or 1 based on which one is larger. if the argument is a decimal, the receiver will be converted into a form suitable for comparing against a decimal, and then compared - it's not specified whether this will actually call Decimal#<=> or not. if the argument is neither a Rational nor a Decimal, it tries to call asRational, and if that doesn't work it returns nil.",
                                                            new TypeCheckingNativeMethod("<=>", TypeCheckingArgumentsDefinition.builder()
                                                                                         .ReceiverMustMimic(rational)
                                                                                         .WithRequiredPositional("other")
                                                                                         .Arguments,
                                                                                         (method, on, args, keywords, context, message) => {
                                                                                             object arg = args[0];

                                                                                             IokeData data = IokeObject.dataOf(arg);

                                                                                             if(data is Decimal) {
                                                                                                 return context.runtime.NewNumber(new BigDecimal(Number.GetValue(on).longValue()).CompareTo(Decimal.GetValue(arg)));
                                                                                             } else {
                                                                                                 if(!(data is Number)) {
                                                                                                     arg = IokeObject.ConvertToRational(arg, message, context, false);
                                                                                                     if(!(IokeObject.dataOf(arg) is Number)) {
                                                                                                         // Can't compare, so bail out
                                                                                                         return context.runtime.nil;
                                                                                                     }
                                                                                                 }

                                                                                                 if(on == rational || arg == rational || on == integer || arg == integer || on == ratio || arg == ratio) {
                                                                                                     if(arg == on) {
                                                                                                         return context.runtime.NewNumber(0);
                                                                                                     }
                                                                                                     return context.runtime.nil;
                                                                                                 }

                                                                                                 return context.runtime.NewNumber(IntNum.compare(Number.GetValue(on),Number.GetValue(arg)));
                                                                                             }
                                                                                         })));

            number.RegisterMethod(runtime.NewNativeMethod("compares this against the argument. should be overridden - in this case only used to check for equivalent number kinds",
                                                          new NativeMethod("==", DefaultArgumentsDefinition.builder()
                                                                           .WithRequiredPositional("other")
                                                                           .Arguments,
                                                                           (method, context, message, on, outer) => {
                                                                               IList args = new SaneArrayList();
                                                                               outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, args, new SaneDictionary<string, object>());
                                                                               object arg = args[0];
                                                                               if(on == arg) {
                                                                                   return context.runtime.True;
                                                                               } else {
                                                                                   return context.runtime.False;
                                                                               }
                                                                           })));


            rational.RegisterMethod(runtime.NewNativeMethod("compares this number against the argument, true if this number is the same, otherwise false",
                                                            new TypeCheckingNativeMethod("==", TypeCheckingArgumentsDefinition.builder()
                                                                                         .ReceiverMustMimic(number)
                                                                                         .WithRequiredPositional("other")
                                                                                         .Arguments,
                                                                                         (method, on, args, keywords, context, message) => {
                                                                                             object arg = args[0];
                                                                                             if(on == rational || arg == rational || on == integer || arg == integer || on == ratio || arg == ratio || on == infinity || arg == infinity || on == infinity2 || arg == infinity2) {
                                                                                                 if(arg == on) {
                                                                                                     return context.runtime.True;
                                                                                                 }
                                                                                                 return context.runtime.False;
                                                                                             }
                                                                                             if(IokeObject.dataOf(arg) is Decimal) {
                                                                                                 return (new BigDecimal(Number.GetValue(on).longValue()).CompareTo(Decimal.GetValue(arg)) == 0) ? context.runtime.True : context.runtime.False;
                                                                                             } else if(IokeObject.dataOf(arg) is Number) {
                                                                                                 return IntNum.compare(Number.GetValue(on),Number.GetValue(arg)) == 0 ? context.runtime.True : context.runtime.False;
                                                                                             } else {
                                                                                                 return context.runtime.False;
                                                                                             }
                                                                                         })));

            rational.RegisterMethod(runtime.NewNativeMethod("returns the difference between this number and the argument. if the argument is a decimal, the receiver will be converted into a form suitable for subtracting against a decimal, and then subtracted. if the argument is neither a Rational nor a Decimal, it tries to call asRational, and if that fails it signals a condition.",
                                                            new TypeCheckingNativeMethod("-", TypeCheckingArgumentsDefinition.builder()
                                                                                         .ReceiverMustMimic(number)
                                                                                         .WithRequiredPositional("subtrahend")
                                                                                         .Arguments,
                                                                                         (method, on, args, keywords, context, message) => {
                                                                                             object arg = args[0];
                                                                                             IokeData data = IokeObject.dataOf(arg);

                                                                                             if(data is Decimal) {
                                                                                                 return Interpreter.Send(context.runtime.minusMessage, context, context.runtime.NewDecimal(((Number)IokeObject.dataOf(on))), arg);
                                                                                             } else {
                                                                                                 if(!(data is Number)) {
                                                                                                     arg = IokeObject.ConvertToRational(arg, message, context, true);
                                                                                                 }

                                                                                                 return context.runtime.NewNumber((RatNum)Number.GetValue(on).sub(Number.GetValue(arg)));
                                                                                             }
                                                                                         })));
            integer.RegisterMethod(runtime.NewNativeMethod("Returns the successor of this number", new TypeCheckingNativeMethod.WithNoArguments("succ", integer,
                                                                                                                                                (method, on, args, keywords, context, message) => {
                                                                                                                                                    return runtime.NewNumber(IntNum.add(Number.IntValue(on),IntNum.one()));
                                                                                                                                                })));

            integer.RegisterMethod(runtime.NewNativeMethod("Returns the predecessor of this number", new TypeCheckingNativeMethod.WithNoArguments("pred", integer,
                                                                                                                                                (method, on, args, keywords, context, message) => {
                                                                                                                                                    return runtime.NewNumber(IntNum.sub(Number.IntValue(on),IntNum.one()));
                                                                                                                                                })));

            infinity.RegisterMethod(runtime.NewNativeMethod("Returns a text inspection of the object",
                                                            new TypeCheckingNativeMethod.WithNoArguments("inspect", infinity,
                                                                                                         (method, on, args, keywords, context, message) => {
                                                                                                             return runtime.NewText("Infinity");
                                                                                                         })));

            infinity.RegisterMethod(runtime.NewNativeMethod("Returns a brief text inspection of the object",
                                                            new TypeCheckingNativeMethod.WithNoArguments("notice", infinity,
                                                                                                         (method, on, args, keywords, context, message) => {
                                                                                                             return runtime.NewText("Infinity");
                                                                                                         })));

            infinity2.RegisterMethod(runtime.NewNativeMethod("Returns a text inspection of the object",
                                                            new TypeCheckingNativeMethod.WithNoArguments("inspect", infinity2,
                                                                                                         (method, on, args, keywords, context, message) => {
                                                                                                             return runtime.NewText("\u221E");
                                                                                                         })));

            infinity2.RegisterMethod(runtime.NewNativeMethod("Returns a brief text inspection of the object",
                                                            new TypeCheckingNativeMethod.WithNoArguments("notice", infinity2,
                                                                                                         (method, on, args, keywords, context, message) => {
                                                                                                             return runtime.NewText("\u221E");
                                                                                                         })));

            rational.RegisterMethod(runtime.NewNativeMethod("returns the addition of this number and the argument. if the argument is a decimal, the receiver will be converted into a form suitable for addition against a decimal, and then added. if the argument is neither a Rational nor a Decimal, it tries to call asRational, and if that fails it signals a condition.",
                                                            new TypeCheckingNativeMethod("+", TypeCheckingArgumentsDefinition.builder()
                                                                                         .ReceiverMustMimic(number)
                                                                                         .WithRequiredPositional("addend")
                                                                                         .Arguments,
                                                                                         (method, on, args, keywords, context, message) => {
                                                                                             object arg = args[0];
                                                                                             IokeData data = IokeObject.dataOf(arg);

                                                                                             if(data is Decimal) {
                                                                                                 return Interpreter.Send(context.runtime.plusMessage, context, context.runtime.NewDecimal(((Number)IokeObject.dataOf(on))), arg);
                                                                                             } else {
                                                                                                 if(!(data is Number)) {
                                                                                                     arg = IokeObject.ConvertToRational(arg, message, context, true);
                                                                                                 }

                                                                                                 return context.runtime.NewNumber(RatNum.add(Number.GetValue(on),Number.GetValue(arg),1));
                                                                                             }
                                                                                         })));

            rational.RegisterMethod(runtime.NewNativeMethod("returns the product of this number and the argument. if the argument is a decimal, the receiver will be converted into a form suitable for multiplying against a decimal, and then multiplied. if the argument is neither a Rational nor a Decimal, it tries to call asRational, and if that fails it signals a condition.",
                                                            new TypeCheckingNativeMethod("*", TypeCheckingArgumentsDefinition.builder()
                                                                                         .ReceiverMustMimic(number)
                                                                                         .WithRequiredPositional("multiplier")
                                                                                         .Arguments,
                                                                                         (method, on, args, keywords, context, message) => {
                                                                                             object arg = args[0];
                                                                                             IokeData data = IokeObject.dataOf(arg);

                                                                                             if(data is Decimal) {
                                                                                                 return Interpreter.Send(context.runtime.multMessage, context, context.runtime.NewDecimal(((Number)IokeObject.dataOf(on))), arg);
                                                                                             } else {
                                                                                                 if(!(data is Number)) {
                                                                                                     arg = IokeObject.ConvertToRational(arg, message, context, true);
                                                                                                 }

                                                                                                 return context.runtime.NewNumber(RatNum.times(Number.GetValue(on),Number.GetValue(arg)));
                                                                                             }
                                                                                         })));

            rational.RegisterMethod(runtime.NewNativeMethod("returns the quotient of this number and the argument. if the division is not exact, it will return a Ratio.",
                                                            new TypeCheckingNativeMethod("/", TypeCheckingArgumentsDefinition.builder()
                                                                                         .ReceiverMustMimic(number)
                                                                                         .WithRequiredPositional("dividend")
                                                                                         .Arguments,
                                                                                         (method, on, args, keywords, context, message) => {
                                                                                             object arg = args[0];
                                                                                             IokeData data = IokeObject.dataOf(arg);

                                                                                             if(data is Decimal) {
                                                                                                 return Interpreter.Send(context.runtime.divMessage, context, context.runtime.NewDecimal(((Number)IokeObject.dataOf(on))), arg);
                                                                                             } else {
                                                                                                 if(!(data is Number)) {
                                                                                                     arg = IokeObject.ConvertToRational(arg, message, context, true);
                                                                                                 }

                                                                                                 while(Number.GetValue(arg).isZero()) {
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
                                                                                                                                                   new IokeObject.UseValue("dividend", newCell));
                                                                                                     arg = newCell[0];
                                                                                                 }

                                                                                                 return context.runtime.NewNumber(RatNum.divide(Number.GetValue(on),Number.GetValue(arg)));
                                                                                             }
                                                                                         })));

            integer.RegisterMethod(runtime.NewNativeMethod("returns the modulo of this number and the argument",
                                                           new TypeCheckingNativeMethod("%", TypeCheckingArgumentsDefinition.builder()
                                                                                        .ReceiverMustMimic(integer)
                                                                                        .WithRequiredPositional("dividend")
                                                                                        .Arguments,
                                                                                         (method, on, args, keywords, context, message) => {
                                                                                             object arg = args[0];
                                                                                             IokeData data = IokeObject.dataOf(arg);
                                                                                             if(!(data is Number)) {
                                                                                                 arg = IokeObject.ConvertToRational(arg, message, context, true);
                                                                                             }

                                                                                             return context.runtime.NewNumber(IntNum.modulo(Number.IntValue(on),Number.IntValue(arg)));
                                                                                        })));

            integer.RegisterMethod(runtime.NewNativeMethod("returns how many times the first number can be divided by the second one",
                                                           new TypeCheckingNativeMethod("div", TypeCheckingArgumentsDefinition.builder()
                                                                                        .ReceiverMustMimic(integer)
                                                                                        .WithRequiredPositional("dividend")
                                                                                        .Arguments,
                                                                                         (method, on, args, keywords, context, message) => {
                                                                                             object arg = args[0];
                                                                                             while(Number.GetValue(arg).isZero()) {
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
                                                                                                                                               new IokeObject.UseValue("dividend", newCell));
                                                                                                 arg = newCell[0];
                                                                                             }
                                                                                             return context.runtime.NewNumber(IntNum.quotient(Number.IntValue(on),Number.IntValue(arg), IntNum.TRUNCATE));
                                                                                        })));

            integer.RegisterMethod(runtime.NewNativeMethod("returns a tuple of how many times the first number can be divided by the second one, and the remainder",
                                                           new TypeCheckingNativeMethod("divmod", TypeCheckingArgumentsDefinition.builder()
                                                                                        .ReceiverMustMimic(integer)
                                                                                        .WithRequiredPositional("dividend")
                                                                                        .Arguments,
                                                                                         (method, on, args, keywords, context, message) => {
                                                                                             object arg = args[0];
                                                                                             while(Number.GetValue(arg).isZero()) {
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
                                                                                                                                               new IokeObject.UseValue("dividend", newCell));
                                                                                                 arg = newCell[0];
                                                                                             }
                                                                                             IntNum q = new IntNum();
                                                                                             IntNum r = new IntNum();
                                                                                             IntNum.divide(Number.IntValue(on),Number.IntValue(arg), q, r, IntNum.TRUNCATE);
                                                                                             return context.runtime.NewTuple(context.runtime.NewNumber(q.canonicalize()), context.runtime.NewNumber(r.canonicalize()));
                                                                                        })));

            rational.RegisterMethod(runtime.NewNativeMethod("returns this number to the power of the argument",
                                                            new TypeCheckingNativeMethod("**", TypeCheckingArgumentsDefinition.builder()
                                                                                         .ReceiverMustMimic(rational)
                                                                                         .WithRequiredPositional("exponent")
                                                                                         .Arguments,
                                                                                         (method, on, args, keywords, context, message) => {
                                                                                             object arg = args[0];
                                                                                             IokeData data = IokeObject.dataOf(arg);

                                                                                             if(!(data is Number)) {
                                                                                                 if(data is Decimal) {
                                                                                                     return context.runtime.NewDecimal(((RealNum)(Complex.power(Number.GetValue(on), new DFloNum(Decimal.GetValue(arg).ToString())))).AsBigDecimal());
                                                                                                 } else {
                                                                                                     arg = IokeObject.ConvertToRational(arg, message, context, true);
                                                                                                 }
                                                                                             }

                                                                                             return context.runtime.NewNumber((RatNum)Number.GetValue(on).power(Number.IntValue(arg)));
                                                                                         })));

            integer.RegisterMethod(runtime.NewNativeMethod("returns this number bitwise and the argument",
                                                           new TypeCheckingNativeMethod("&", TypeCheckingArgumentsDefinition.builder()
                                                                                        .ReceiverMustMimic(integer)
                                                                                        .WithRequiredPositional("other")
                                                                                        .Arguments,
                                                                                         (method, on, args, keywords, context, message) => {
                                                                                             object arg = args[0];
                                                                                             IokeData data = IokeObject.dataOf(arg);

                                                                                             if(!(data is Number)) {
                                                                                                 arg = IokeObject.ConvertToRational(arg, message, context, true);
                                                                                             }

                                                                                             return context.runtime.NewNumber(BitOps.and(Number.IntValue(on), Number.IntValue(arg)));
                                                                                        })));

            integer.RegisterMethod(runtime.NewNativeMethod("returns this number bitwise or the argument",
                                                           new TypeCheckingNativeMethod("|", TypeCheckingArgumentsDefinition.builder()
                                                                                        .ReceiverMustMimic(integer)
                                                                                        .WithRequiredPositional("other")
                                                                                        .Arguments,
                                                                                         (method, on, args, keywords, context, message) => {
                                                                                             object arg = args[0];
                                                                                             IokeData data = IokeObject.dataOf(arg);

                                                                                             if(!(data is Number)) {
                                                                                                 arg = IokeObject.ConvertToRational(arg, message, context, true);
                                                                                             }

                                                                                             return context.runtime.NewNumber(BitOps.ior(Number.IntValue(on), Number.IntValue(arg)));
                                                                                        })));

            integer.RegisterMethod(runtime.NewNativeMethod("returns this number bitwise xor the argument",
                                                           new TypeCheckingNativeMethod("^", TypeCheckingArgumentsDefinition.builder()
                                                                                        .ReceiverMustMimic(integer)
                                                                                        .WithRequiredPositional("other")
                                                                                        .Arguments,
                                                                                         (method, on, args, keywords, context, message) => {
                                                                                             object arg = args[0];
                                                                                             IokeData data = IokeObject.dataOf(arg);

                                                                                             if(!(data is Number)) {
                                                                                                 arg = IokeObject.ConvertToRational(arg, message, context, true);
                                                                                             }

                                                                                             return context.runtime.NewNumber(BitOps.xor(Number.IntValue(on), Number.IntValue(arg)));
                                                                                        })));

            integer.RegisterMethod(runtime.NewNativeMethod("returns this number left shifted by the argument",
                                                           new TypeCheckingNativeMethod("<<", TypeCheckingArgumentsDefinition.builder()
                                                                                        .ReceiverMustMimic(integer)
                                                                                        .WithRequiredPositional("other")
                                                                                        .Arguments,
                                                                                         (method, on, args, keywords, context, message) => {
                                                                                             object arg = args[0];
                                                                                             IokeData data = IokeObject.dataOf(arg);

                                                                                             if(!(data is Number)) {
                                                                                                 arg = IokeObject.ConvertToRational(arg, message, context, true);
                                                                                             }

                                                                                             return context.runtime.NewNumber(IntNum.shift(Number.IntValue(on), Number.IntValue(arg).intValue()));
                                                                                        })));

            integer.RegisterMethod(runtime.NewNativeMethod("returns this number right shifted by the argument",
                                                           new TypeCheckingNativeMethod(">>", TypeCheckingArgumentsDefinition.builder()
                                                                                        .ReceiverMustMimic(integer)
                                                                                        .WithRequiredPositional("other")
                                                                                        .Arguments,
                                                                                         (method, on, args, keywords, context, message) => {
                                                                                             object arg = args[0];
                                                                                             IokeData data = IokeObject.dataOf(arg);

                                                                                             if(!(data is Number)) {
                                                                                                 arg = IokeObject.ConvertToRational(arg, message, context, true);
                                                                                             }

                                                                                             return context.runtime.NewNumber(IntNum.shift(Number.IntValue(on), -Number.IntValue(arg).intValue()));
                                                                                        })));

            rational.RegisterMethod(runtime.NewNativeMethod("Returns a text representation of the object",
                                                            new TypeCheckingNativeMethod.WithNoArguments("asText", number,
                                                                                             (method, on, args, keywords, context, message) => {
                                                                                                 return runtime.NewText(on.ToString());
                                                                                             })));

            rational.RegisterMethod(obj.runtime.NewNativeMethod("Returns a text inspection of the object",
                                                                new TypeCheckingNativeMethod.WithNoArguments("inspect", number,
                                                                                                             (method, on, args, keywords, context, message) => {
                                                                                                                 return method.runtime.NewText(Number.GetInspect(on));
                                                                                                             })));

            rational.RegisterMethod(obj.runtime.NewNativeMethod("Returns a brief text inspection of the object",
                                                                new TypeCheckingNativeMethod.WithNoArguments("notice", number,
                                                                                                             (method, on, args, keywords, context, message) => {
                                                                                                                 return method.runtime.NewText(Number.GetInspect(on));
                                                                                                             })));

            integer.RegisterMethod(runtime.NewNativeMethod("Expects one or two arguments. If one argument is given, executes it as many times as the value of the receiving number. If two arguments are given, the first will be an unevaluated name that will receive the current loop value on each repitition. the iteration length is limited to the positive maximum of a Java int",
                                                           new NativeMethod("times", DefaultArgumentsDefinition.builder()
                                                                            .WithRequiredPositionalUnevaluated("argumentNameOrCode")
                                                                            .WithOptionalPositionalUnevaluated("code")
                                                                            .Arguments,
                                                                            (method, context, message, on, outer) => {
                                                                                outer.ArgumentsDefinition.CheckArgumentCount(context, message, on);

                                                                                int num = Number.GetValue(context.runtime.Integer.ConvertToThis(on, message, context)).intValue();
                                                                                if(message.Arguments.Count == 0) {
                                                                                    return runtime.nil;
                                                                                } else if(message.Arguments.Count == 1) {
                                                                                    object result = runtime.nil;
                                                                                    while(num > 0) {
                                                                                        result = Interpreter.GetEvaluatedArgument(message, 0, context);
                                                                                        num--;
                                                                                    }
                                                                                    return result;
                                                                                } else {
                                                                                    int ix = 0;
                                                                                    string name = ((IokeObject)Message.GetArguments(message)[0]).Name;
                                                                                    object result = runtime.nil;
                                                                                    while(ix<num) {
                                                                                        context.SetCell(name, runtime.NewNumber(IntNum.make(ix)));
                                                                                        result = Interpreter.GetEvaluatedArgument(message, 1, context);
                                                                                        ix++;
                                                                                    }
                                                                                    return result;
                                                                                }
                                                                            })));

            integer.RegisterMethod(runtime.NewNativeMethod("Returns a Text that represents the character with the same character code of this number", 
                                                           new TypeCheckingNativeMethod.WithNoArguments("char", integer,
                                                                                                        (method, on, args, keywords, context, message) => {
                                                                                                            return runtime.NewText(Convert.ToString((char)Number.IntValue(on).intValue()));
                                                                                                        })));
        }

        public static string GetInspect(object on) {
            return ((Number)(IokeObject.dataOf(on))).Inspect(on);
        }

        public string Inspect(object obj) {
            return AsNativeString();
        }
    }
}
