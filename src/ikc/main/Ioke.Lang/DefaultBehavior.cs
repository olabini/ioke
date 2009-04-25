namespace Ioke.Lang {
    using System.Collections;
    using System.Collections.Generic;

    using Ioke.Lang.Util;

    public class DefaultBehavior {
        public static void Init(IokeObject obj) {
            Runtime runtime = obj.runtime;
            obj.Kind = "DefaultBehavior";

            IokeObject baseBehavior = new IokeObject(runtime, "contains behavior copied from Base");
            baseBehavior.Kind = "DefaultBehavior BaseBehavior";
            baseBehavior.SetCell("=",         runtime.Base.Cells["="]);
            baseBehavior.SetCell("==",        runtime.Base.Cells["=="]);
            baseBehavior.SetCell("cell",      runtime.Base.Cells["cell"]);
            baseBehavior.SetCell("cell?",     runtime.Base.Cells["cell?"]);
            baseBehavior.SetCell("cell=",     runtime.Base.Cells["cell="]);
            baseBehavior.SetCell("cells",     runtime.Base.Cells["cells"]);
            baseBehavior.SetCell("cellNames", runtime.Base.Cells["cellNames"]);
            baseBehavior.SetCell("removeCell!", runtime.Base.Cells["removeCell!"]);
            baseBehavior.SetCell("undefineCell!", runtime.Base.Cells["undefineCell!"]);
            baseBehavior.SetCell("cellOwner?", runtime.Base.Cells["cellOwner?"]);
            baseBehavior.SetCell("cellOwner", runtime.Base.Cells["cellOwner"]);
            baseBehavior.SetCell("documentation", runtime.Base.Cells["documentation"]);
            baseBehavior.SetCell("identity", runtime.Base.Cells["identity"]);
            obj.MimicsWithoutCheck(baseBehavior);
            obj.RegisterCell("BaseBehavior", baseBehavior);

            IokeObject assignmentBehavior = new IokeObject(runtime, "contains behavior related to assignment");
            assignmentBehavior.MimicsWithoutCheck(baseBehavior);
            AssignmentBehavior.Init(assignmentBehavior);
            obj.MimicsWithoutCheck(assignmentBehavior);
            obj.RegisterCell("Assignment", assignmentBehavior);

            IokeObject internalBehavior = new IokeObject(runtime, "contains behavior related to internal functionality");
            internalBehavior.MimicsWithoutCheck(baseBehavior);
            InternalBehavior.Init(internalBehavior);
            obj.MimicsWithoutCheck(internalBehavior);
            obj.RegisterCell("Internal", internalBehavior);

            IokeObject flowControlBehavior = new IokeObject(runtime, "contains behavior related to flow control");
            flowControlBehavior.MimicsWithoutCheck(baseBehavior);
            FlowControlBehavior.Init(flowControlBehavior);
            obj.MimicsWithoutCheck(flowControlBehavior);
            obj.RegisterCell("FlowControl", flowControlBehavior);

            IokeObject definitionsBehavior = new IokeObject(runtime, "contains behavior related to the definition of different concepts");
            definitionsBehavior.MimicsWithoutCheck(baseBehavior);
            DefinitionsBehavior.Init(definitionsBehavior);
            obj.MimicsWithoutCheck(definitionsBehavior);
            obj.RegisterCell("Definitions", definitionsBehavior);

            IokeObject conditionsBehavior = new IokeObject(runtime, "contains behavior related to conditions");
            conditionsBehavior.MimicsWithoutCheck(baseBehavior);
            ConditionsBehavior.Init(conditionsBehavior);
            obj.MimicsWithoutCheck(conditionsBehavior);
            obj.RegisterCell("Conditions", conditionsBehavior);

            IokeObject literalsBehavior = new IokeObject(runtime, "contains behavior related to literals");
            literalsBehavior.MimicsWithoutCheck(baseBehavior);
            LiteralsBehavior.Init(literalsBehavior);
            obj.MimicsWithoutCheck(literalsBehavior);
            obj.RegisterCell("Literals", literalsBehavior);

            IokeObject caseBehavior = new IokeObject(runtime, "contains behavior related to the case statement");
            caseBehavior.MimicsWithoutCheck(baseBehavior);
            CaseBehavior.Init(caseBehavior);
            obj.MimicsWithoutCheck(caseBehavior);
            obj.RegisterCell("Case", caseBehavior);

            IokeObject reflectionBehavior = new IokeObject(runtime, "contains behavior related to reflection");
            reflectionBehavior.MimicsWithoutCheck(baseBehavior);
            ReflectionBehavior.Init(reflectionBehavior);
            obj.MimicsWithoutCheck(reflectionBehavior);
            obj.RegisterCell("Reflection", reflectionBehavior);

            IokeObject booleanBehavior = new IokeObject(runtime, "contains behavior related to boolean behavior");
            booleanBehavior.MimicsWithoutCheck(baseBehavior);
            booleanBehavior.Kind = "DefaultBehavior Boolean";
            obj.MimicsWithoutCheck(booleanBehavior);
            obj.RegisterCell("Boolean", booleanBehavior);

            IokeObject aspects = new IokeObject(runtime, "contains behavior related to aspects");
            aspects.MimicsWithoutCheck(baseBehavior);
            aspects.Kind = "DefaultBehavior Aspects";
            obj.MimicsWithoutCheck(aspects);
            obj.RegisterCell("Aspects", aspects);

            obj.RegisterMethod(runtime.NewNativeMethod("takes one or more evaluated string argument. will import the files corresponding to each of the strings named based on the Ioke loading behavior that can be found in the documentation for the loadBehavior cell on System.", 
                                                       new NativeMethod("use", DefaultArgumentsDefinition.builder()
                                                                        .WithOptionalPositional("module", "false")
                                                                        .Arguments,
                                                                        (method, context, message, on, outer) => {
                                                                            IList args = new SaneArrayList();
                                                                            outer.ArgumentsDefinition.GetEvaluatedArguments(context, message, on, args, new SaneDictionary<string, object>());
                                                                            if(args.Count == 0) {
                                                                                return method;
                                                                            }

                                                                            string name = Text.GetText(((Message)IokeObject.dataOf(runtime.asText)).SendTo(runtime.asText, context, args[0]));
                                                                            if(((IokeSystem)IokeObject.dataOf(runtime.System)).Use(IokeObject.As(on, context), context, message, name)) {
                                                                                return runtime.True;
                                                                            } else {
                                                                                return runtime.False;
                                                                            }
                                                                        })));
        }
    }
}
