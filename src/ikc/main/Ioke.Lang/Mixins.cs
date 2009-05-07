
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

        public static void Init(IokeObject obj) {
            Runtime runtime = obj.runtime;
            obj.Kind = "Mixins";

            obj.SetCell("=",         runtime.Base.Cells["="]);
            obj.SetCell("==",        runtime.Base.Cells["=="]);
            obj.SetCell("cell",      runtime.Base.Cells["cell"]);
            obj.SetCell("cell=",     runtime.Base.Cells["cell="]);
            obj.SetCell("cell?",     runtime.Base.Cells["cell?"]);
            obj.SetCell("cells",     runtime.Base.Cells["cells"]);
            obj.SetCell("cellNames", runtime.Base.Cells["cellNames"]);
            obj.SetCell("mimic",     runtime.Base.Cells["mimic"]);

            IokeObject comparing = new IokeObject(obj.runtime, "allows different objects to be compared, based on the spaceship operator being available");
            comparing.MimicsWithoutCheck(obj);
            Comparing.Init(comparing);
            obj.RegisterCell("Comparing", comparing);

            IokeObject enumerable = new IokeObject(obj.runtime, "adds lots of helpful methods that can be done on enumerable methods. based on the 'each' method being available on the self.");
            enumerable.MimicsWithoutCheck(obj);
            Enumerable.Init(enumerable);
            obj.RegisterCell("Enumerable", enumerable);
        }
    }
}
