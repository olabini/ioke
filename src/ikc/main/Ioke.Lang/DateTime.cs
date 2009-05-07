
namespace Ioke.Lang {
    using Ioke.Lang.Util;

    public class DateTime : IokeData {
        System.DateTime dateTime;

        public DateTime() : this(System.DateTime.Now) {}
        public DateTime(long instant) : this(new System.DateTime(instant)) {}
        public DateTime(System.DateTime val) {
            this.dateTime = val;
        }

        public static System.DateTime GetDateTime(object on) {
            return ((DateTime)IokeObject.dataOf(on)).dateTime;
        }

        public override void Init(IokeObject obj) {
            Runtime runtime = obj.runtime;

            obj.Kind = "DateTime";
            //        obj.mimics(IokeObject.as(runtime.mixins.getCell(null, null, "Comparing")), runtime.nul, runtime.nul);

            obj.RegisterMethod(runtime.NewNativeMethod("Returns a new DateTime representing the current instant in time in the default TimeZone.", 
                                                       new TypeCheckingNativeMethod.WithNoArguments("now", obj,
                                                                                                    (method, on, args, keywords, context, message) => {
                                                                                                        return method.runtime.NewDateTime(System.DateTime.Now);
                                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("Expects to get one DateTime as argument, and returns the difference between this instant and that instant, in milliseconds.", 
                                                       new TypeCheckingNativeMethod("-", TypeCheckingArgumentsDefinition.builder()
                                                                                    .ReceiverMustMimic(obj)
                                                                                    .WithRequiredPositional("subtrahend").WhichMustMimic(obj)
                                                                                    .Arguments,
                                                                                    (method, on, args, keywords, context, message) => {
                                                                                        long diff = System.Convert.ToInt64(GetDateTime(on).Subtract(GetDateTime(args[0])).TotalMilliseconds);
                                                                                        return context.runtime.NewNumber(diff);
                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("Returns a text inspection of the object", 
                                                       new TypeCheckingNativeMethod.WithNoArguments("inspect", obj,
                                                                                                    (method, on, args, keywords, context, message) => {
                                                                                                        return method.runtime.NewText(DateTime.GetInspect(on));
                                                                                                    })));

            obj.RegisterMethod(runtime.NewNativeMethod("Returns a brief text inspection of the object", 
                                                       new TypeCheckingNativeMethod.WithNoArguments("notice", obj,
                                                                                                    (method, on, args, keywords, context, message) => {
                                                                                                        return method.runtime.NewText(DateTime.GetNotice(on));
                                                                                                    })));
        }

        public override IokeData CloneData(IokeObject obj, IokeObject m, IokeObject context) {
            return this;
        }

        public static string GetInspect(object on) {
            return ((DateTime)(IokeObject.dataOf(on))).Inspect(on);
        }

        public static string GetNotice(object on) {
            return ((DateTime)(IokeObject.dataOf(on))).Notice(on);
        }

        public override bool IsEqualTo(IokeObject self, object other) {
            return ((other is IokeObject) && 
                    (IokeObject.dataOf(other) is DateTime) 
                    && this.dateTime.Equals(((DateTime)IokeObject.dataOf(other)).dateTime));
        }



        public override string ToString() {
            return this.dateTime.ToString();
        }

        public override string ToString(IokeObject obj) {
            return this.dateTime.ToString();
        }

        public string Inspect(object obj) {
            return this.dateTime.ToString();
        }

        public string Notice(object obj) {
            return this.dateTime.ToString();
        }
    }
}
