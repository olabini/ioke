namespace Ioke.Lang {
    using System.Text;

    public class Pair : IokeData {
        object first;
        object second;

        public Pair(object first, object second) {
            this.first = first;
            this.second = second;
        }

        public static object GetFirst(object pair) {
            return ((Pair)IokeObject.dataOf(pair)).First;
        }

        public static object GetSecond(object pair) {
            return ((Pair)IokeObject.dataOf(pair)).Second;
        }

        public object First {
            get { return first; }
        }

        public object Second {
            get { return second; }
        }

        public override void Init(IokeObject obj) {
            Runtime runtime = obj.runtime;

            obj.Kind = "Pair";
            obj.Mimics(IokeObject.As(IokeObject.FindCell(runtime.Mixins, "Enumerable"), null), runtime.nul, runtime.nul);
            obj.Mimics(IokeObject.As(IokeObject.FindCell(runtime.Mixins, "Comparing"), null), runtime.nul, runtime.nul);

            obj.RegisterMethod(obj.runtime.NewNativeMethod("returns a hash for the pair",
                                                           new NativeMethod.WithNoArguments("hash", (method, context, message, on, outer) => {
                                                                   outer.ArgumentsDefinition.CheckArgumentCount(context, message, on);
                                                                   var one = ((Pair)IokeObject.dataOf(on)).first.GetHashCode();
                                                                   var two = ((Pair)IokeObject.dataOf(on)).second.GetHashCode();
                                                                   return context.runtime.NewNumber(one + 13*two);
                                                               })));

            obj.RegisterMethod(runtime.NewNativeMethod("returns true if the left hand side pair is equal to the right hand side pair.",
                                                       new TypeCheckingNativeMethod("==", TypeCheckingArgumentsDefinition.builder()
                                                                                    .ReceiverMustMimic(runtime.Pair)
                                                                                    .WithRequiredPositional("other")
                                                                                    .Arguments,
                                                                                    (method, on, args, keywords, context, message) => {
                                                                                        Pair d = (Pair)IokeObject.dataOf(on);
                                                                                        object other = args[0];

                                                                                        return ((other is IokeObject) &&
                                                                                                (IokeObject.dataOf(other) is Pair)
                                                                                                && d.first.Equals(((Pair)IokeObject.dataOf(other)).first)
                                                                                                && d.second.Equals(((Pair)IokeObject.dataOf(other)).second)) ? context.runtime.True : context.runtime.False;
                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("Returns the first value",
                                                       new TypeCheckingNativeMethod.WithNoArguments("first", obj,
                                                                                                    (method, on, args, keywords, context, message) => {
                                                                                                        return ((Pair)IokeObject.dataOf(on)).first;
                                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("Returns the first value",
                                                       new TypeCheckingNativeMethod.WithNoArguments("key", obj,
                                                                                                    (method, on, args, keywords, context, message) => {
                                                                                                        return ((Pair)IokeObject.dataOf(on)).first;
                                                                                                    })));


            obj.RegisterMethod(runtime.NewNativeMethod("Returns the second value",
                                                       new TypeCheckingNativeMethod.WithNoArguments("second", obj,
                                                                                                    (method, on, args, keywords, context, message) => {
                                                                                                        return ((Pair)IokeObject.dataOf(on)).second;
                                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("Returns the second value",
                                                       new TypeCheckingNativeMethod.WithNoArguments("value", obj,
                                                                                                    (method, on, args, keywords, context, message) => {
                                                                                                        return ((Pair)IokeObject.dataOf(on)).second;
                                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("Returns a text inspection of the object",
                                                       new TypeCheckingNativeMethod.WithNoArguments("inspect", obj,
                                                                                                    (method, on, args, keywords, context, message) => {
                                                                                                        return method.runtime.NewText(Pair.GetInspect(on));
                                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("Returns a brief text inspection of the object",
                                                       new TypeCheckingNativeMethod.WithNoArguments("notice", obj,
                                                                                                    (method, on, args, keywords, context, message) => {
                                                                                                        return method.runtime.NewText(Pair.GetNotice(on));
                                                                                                    })));
        }

        public override IokeData CloneData(IokeObject obj, IokeObject m, IokeObject context) {
            return new Pair(first, second);
        }


        public static string GetInspect(object on) {
            return ((Pair)(IokeObject.dataOf(on))).Inspect(on);
        }

        public static string GetNotice(object on) {
            return ((Pair)(IokeObject.dataOf(on))).Notice(on);
        }

        public override string ToString() {
            return "" + first + " => " + second;
        }

        public override string ToString(IokeObject obj) {
            return "" + first + " => " + second;
        }

        public string Inspect(object obj) {
            StringBuilder sb = new StringBuilder();

            sb.Append(IokeObject.Inspect(first));
            sb.Append(" => ");
            sb.Append(IokeObject.Inspect(second));

            return sb.ToString();
        }

        public string Notice(object obj) {
            StringBuilder sb = new StringBuilder();

            sb.Append(IokeObject.Notice(first));
            sb.Append(" => ");
            sb.Append(IokeObject.Notice(second));

            return sb.ToString();
        }
    }
}
