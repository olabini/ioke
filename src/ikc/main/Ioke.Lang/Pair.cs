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
            obj.Mimics(IokeObject.As(runtime.Mixins.GetCell(null, null, "Enumerable"), null), runtime.nul, runtime.nul);
            obj.Mimics(IokeObject.As(runtime.Mixins.GetCell(null, null, "Comparing"), null), runtime.nul, runtime.nul);

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

        public override bool IsEqualTo(IokeObject self, object other) {
            return ((other is IokeObject) && 
                    (IokeObject.dataOf(other) is Pair) 
                    && this.first.Equals(((Pair)IokeObject.dataOf(other)).first)
                    && this.second.Equals(((Pair)IokeObject.dataOf(other)).second));
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
