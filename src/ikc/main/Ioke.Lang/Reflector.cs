
namespace Ioke.Lang {
    using System.Collections;
    using System.Collections.Generic;

    public class Reflector {
        public static void Init(Runtime runtime) {
            IokeObject obj = new IokeObject(runtime, "Allows access to the internals of any object without actually using methods on that object");
            obj.Kind = "Reflector";
            obj.MimicsWithoutCheck(runtime.Origin);
            runtime.IokeGround.RegisterCell("Reflector", obj);

            obj.RegisterMethod(obj.runtime.NewNativeMethod("returns the documentation text of the object given as argument. anything can have a documentation text - this text will initially be nil.", 
                                                       new TypeCheckingNativeMethod("other:documentation", TypeCheckingArgumentsDefinition.builder()
                                                                                    .WithRequiredPositional("other")
                                                                                    .Arguments,
                                                                                    (method, on, args, keywords, context, message) => {
                                                                                        return Base.Documentation(context, message, args[0]);
                                                                                    })));

            obj.RegisterMethod(obj.runtime.NewNativeMethod("sets the documentation string for a specific object.", 
                                                       new TypeCheckingNativeMethod("other:documentation=", TypeCheckingArgumentsDefinition.builder()
                                                                                    .WithRequiredPositional("other")
                                                                                    .WithRequiredPositional("text").WhichMustMimic(obj.runtime.Text).OrBeNil()
                                                                                    .Arguments,
                                                                                    (method, on, args, keywords, context, message) => {
                                                                                        return Base.SetDocumentation(context, message, args[0], args[1]);
                                                                                    })));
        }
    }
}
