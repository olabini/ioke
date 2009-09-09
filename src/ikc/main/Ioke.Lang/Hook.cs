namespace Ioke.Lang {
    public class Hook {
        public static void Init(Runtime runtime) {
            IokeObject obj = new IokeObject(runtime, "A hook allow you to observe what happens to a specific object. All hooks have Hook in their mimic chain.");
            obj.Kind = "Hook";
            obj.MimicsWithoutCheck(runtime.Origin);
            runtime.IokeGround.RegisterCell("Hook", obj);
        }
    }
}
