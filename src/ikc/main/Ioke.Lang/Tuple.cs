namespace Ioke.Lang {
    using System;
    using System.Collections;
    using System.Text;

    using Ioke.Lang.Util;

    public class Tuple : IokeData {
        object[] elements;

        public Tuple(object[] elements) {
            this.elements = elements;
        }

        public override void Init(IokeObject obj) {
            Runtime runtime = obj.runtime;
            obj.Kind = "Tuple";
            obj.MimicsWithoutCheck(runtime.Origin);
            runtime.IokeGround.RegisterCell("Tuple", obj);


            obj.RegisterMethod(runtime.NewNativeMethod("will modify the tuple, initializing it to contain the specified arguments",
                                                       new TypeCheckingNativeMethod("private:initializeWith", TypeCheckingArgumentsDefinition.builder()
                                                                                    .ReceiverMustMimic(runtime.Tuple)
                                                                                    .WithRest("values")
                                                                                    .Arguments,
                                                                                    (method, on, args, keywords, context, message) => {
                                                                                        IokeObject.As(on, context).Data = new Tuple(((ArrayList)args).ToArray());
                                                                                        return on;
                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("returns a new method that can be used to access an element of a tuple based on the index",
                                                       new TypeCheckingNativeMethod("private:accessor", TypeCheckingArgumentsDefinition.builder()
                                                                                    .ReceiverMustMimic(runtime.Tuple)
                                                                                    .WithRequiredPositional("index")
                                                                                    .Arguments,
                                                                                    (method, on, args, keywords, context, message) => {
                                                                                        int index = Number.ExtractInt(args[0], message, context);
                                                                                        return runtime.NewNativeMethod("Returns the object at index " + index + " in the receiving tuple",
                                                                                                                       new TypeCheckingNativeMethod.WithNoArguments("_" + index, runtime.Tuple,
                                                                                                                                                                    (method2, on2, args2, keywords2, context2, message2) => {
                                                                                                                                                                        return ((Tuple)IokeObject.dataOf(on2)).elements[index];
                                                                                                                                                                    }));
                                                                                    })));


            obj.RegisterMethod(runtime.NewNativeMethod("Compares this object against the argument. The comparison is only based on the elements inside the tuple, which are in turn compared using <=>.",
                                                       new TypeCheckingNativeMethod("<=>", TypeCheckingArgumentsDefinition.builder()
                                                                                    .ReceiverMustMimic(obj)
                                                                                    .WithRequiredPositional("other")
                                                                                    .Arguments,
                                                                                    (method, on, args, keywords, context, message) => {
                                                                                        object arg = args[0];
                                                                                        var one = ((Tuple)IokeObject.dataOf(on)).elements;
                                                                                        var two = ((Tuple)IokeObject.dataOf(arg)).elements;

                                                                                        int len = System.Math.Min(one.Length, two.Length);
                                                                                        SpaceshipComparator sc = new SpaceshipComparator(context, message);

                                                                                        for(int i = 0; i < len; i++) {
                                                                                            int v = sc.Compare(one[i], two[i]);
                                                                                            if(v != 0) {
                                                                                                return context.runtime.NewNumber(v);
                                                                                            }
                                                                                        }

                                                                                        len = one.Length - two.Length;

                                                                                        if(len == 0) return context.runtime.NewNumber(0);
                                                                                        if(len > 0) return context.runtime.NewNumber(1);
                                                                                        return context.runtime.NewNumber(-1);
                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("Returns the arity of this tuple",
                                                       new TypeCheckingNativeMethod.WithNoArguments("arity", runtime.Tuple,
                                                                                                    (method, on, args, keywords, context, message) => {
                                                                                                        return context.runtime.NewNumber(((Tuple)IokeObject.dataOf(on)).elements.Length);
                                                                                                    })));
            obj.RegisterMethod(runtime.NewNativeMethod("Returns a text inspection of the object",
                                                       new TypeCheckingNativeMethod.WithNoArguments("inspect", obj,
                                                                                                    (method, on, args, keywords, context, message) => {
                                                                                                        return method.runtime.NewText(Tuple.GetInspect(on));
                                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("Returns a brief text inspection of the object",
                                                       new TypeCheckingNativeMethod.WithNoArguments("notice", obj,
                                                                                                    (method, on, args, keywords, context, message) => {
                                                                                                        return method.runtime.NewText(Tuple.GetNotice(on));
                                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("Returns a list representation of this tuple",
                                                       new TypeCheckingNativeMethod.WithNoArguments("asList", obj,
                                                                                                    (method, on, args, keywords, context, message) => {
                                                                                                        return method.runtime.NewList(new SaneArrayList(((Tuple)IokeObject.dataOf(on)).elements));
                                                                                                    })));
        }

        public static string GetInspect(object on) {
            return ((Tuple)(IokeObject.dataOf(on))).Inspect(on);
        }

        public static string GetNotice(object on) {
            return ((Tuple)(IokeObject.dataOf(on))).Notice(on);
        }

        public string Inspect(object obj) {
            StringBuilder sb = new StringBuilder();
            sb.Append("(");
            string sep = "";
            foreach(object o in elements) {
                sb.Append(sep).Append(IokeObject.Inspect(o));
                sep = ", ";
            }
            sb.Append(")");
            return sb.ToString();
        }

        public string Notice(object obj) {
            StringBuilder sb = new StringBuilder();
            sb.Append("(");
            string sep = "";
            foreach(object o in elements) {
                sb.Append(sep).Append(IokeObject.Notice(o));
                sep = ", ";
            }
            sb.Append(")");
            return sb.ToString();
        }
    }
}
