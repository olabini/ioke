
namespace Ioke.Lang {
    public class Mixins {
        public class Comparing {
            public static void Init(IokeObject obj) {
                obj.Kind = "Mixins Comparing";
            }
        }

        public class Enumerable {
            public static void Init(IokeObject obj) {
                obj.Kind = "Mixins Enumerable";
            }
        }

        public class Sequenced {
            public static void Init(IokeObject obj) {
                obj.Kind = "Mixins Sequenced";
            }
        }

        public static void Init(IokeObject obj) {
            Runtime runtime = obj.runtime;
            obj.Kind = "Mixins";

            obj.SetCell("=",         runtime.Base.body.Get("="));
            obj.SetCell("==",        runtime.Base.body.Get("=="));
            obj.SetCell("cell",      runtime.Base.body.Get("cell"));
            obj.SetCell("cell=",     runtime.Base.body.Get("cell="));
            obj.SetCell("cell?",     runtime.Base.body.Get("cell?"));
            obj.SetCell("cells",     runtime.Base.body.Get("cells"));
            obj.SetCell("cellNames", runtime.Base.body.Get("cellNames"));
            obj.SetCell("mimic",     runtime.Base.body.Get("mimic"));

            IokeObject comparing = new IokeObject(obj.runtime, "allows different objects to be compared, based on the spaceship operator being available");
            comparing.MimicsWithoutCheck(obj);
            Comparing.Init(comparing);
            obj.RegisterCell("Comparing", comparing);

            IokeObject enumerable = new IokeObject(obj.runtime, "adds lots of helpful methods that can be done on enumerable methods. based on the 'each' method being available on the self.");
            enumerable.MimicsWithoutCheck(obj);
            Enumerable.Init(enumerable);
            obj.RegisterCell("Enumerable", enumerable);

            IokeObject sequenced = new IokeObject(obj.runtime, "something that is sequenced can return a Sequence over itself. it also allows several other methods to be defined in terms of that sequence. A Sequenced object is Enumerable, since all Enumerable operations can be defined in terms of sequencing.");
            sequenced.MimicsWithoutCheck(obj);
            sequenced.MimicsWithoutCheck(enumerable);
            Sequenced.Init(sequenced);
            obj.RegisterCell("Sequenced", sequenced);
        }
    }
}
