/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.Arrays;
import java.util.ArrayList;
import java.util.List;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.HashSet;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class DefaultBehavior {
    public static void init(IokeObject obj) throws ControlFlow {
        final Runtime runtime = obj.runtime;
        obj.setKind("DefaultBehavior");

        IokeObject baseBehavior = new IokeObject(runtime, "contains behavior copied from Base");
        baseBehavior.setKind("DefaultBehavior BaseBehavior");
        baseBehavior.setCell("=",         runtime.base.getCells().get("="));
        baseBehavior.setCell("==",        runtime.base.getCells().get("=="));
        baseBehavior.setCell("cell",      runtime.base.getCells().get("cell"));
        baseBehavior.setCell("cell?",     runtime.base.getCells().get("cell?"));
        baseBehavior.setCell("cell=",     runtime.base.getCells().get("cell="));
        baseBehavior.setCell("cells",     runtime.base.getCells().get("cells"));
        baseBehavior.setCell("cellNames", runtime.base.getCells().get("cellNames"));
        baseBehavior.setCell("removeCell!", runtime.base.getCells().get("removeCell!"));
        baseBehavior.setCell("undefineCell!", runtime.base.getCells().get("undefineCell!"));
        baseBehavior.setCell("cellOwner?", runtime.base.getCells().get("cellOwner?"));
        baseBehavior.setCell("cellOwner", runtime.base.getCells().get("cellOwner"));
        baseBehavior.setCell("documentation", runtime.base.getCells().get("documentation"));
        baseBehavior.setCell("identity", runtime.base.getCells().get("identity"));
        obj.mimicsWithoutCheck(baseBehavior);
        obj.registerCell("BaseBehavior", baseBehavior);

        IokeObject assignmentBehavior = new IokeObject(runtime, "contains behavior related to assignment");
        assignmentBehavior.mimicsWithoutCheck(baseBehavior);
        AssignmentBehavior.init(assignmentBehavior);
        obj.mimicsWithoutCheck(assignmentBehavior);
        obj.registerCell("Assignment", assignmentBehavior);

        IokeObject internalBehavior = new IokeObject(runtime, "contains behavior related to internal functionality");
        internalBehavior.mimicsWithoutCheck(baseBehavior);
        InternalBehavior.init(internalBehavior);
        obj.mimicsWithoutCheck(internalBehavior);
        obj.registerCell("Internal", internalBehavior);

        IokeObject flowControlBehavior = new IokeObject(runtime, "contains behavior related to flow control");
        flowControlBehavior.mimicsWithoutCheck(baseBehavior);
        FlowControlBehavior.init(flowControlBehavior);
        obj.mimicsWithoutCheck(flowControlBehavior);
        obj.registerCell("FlowControl", flowControlBehavior);

        IokeObject definitionsBehavior = new IokeObject(runtime, "contains behavior related to the definition of different concepts");
        definitionsBehavior.mimicsWithoutCheck(baseBehavior);
        DefinitionsBehavior.init(definitionsBehavior);
        obj.mimicsWithoutCheck(definitionsBehavior);
        obj.registerCell("Definitions", definitionsBehavior);

        IokeObject conditionsBehavior = new IokeObject(runtime, "contains behavior related to conditions");
        conditionsBehavior.mimicsWithoutCheck(baseBehavior);
        ConditionsBehavior.init(conditionsBehavior);
        obj.mimicsWithoutCheck(conditionsBehavior);
        obj.registerCell("Conditions", conditionsBehavior);

        IokeObject literalsBehavior = new IokeObject(runtime, "contains behavior related to literals");
        literalsBehavior.mimicsWithoutCheck(baseBehavior);
        LiteralsBehavior.init(literalsBehavior);
        obj.mimicsWithoutCheck(literalsBehavior);
        obj.registerCell("Literals", literalsBehavior);

        IokeObject caseBehavior = new IokeObject(runtime, "contains behavior related to the case statement");
        caseBehavior.mimicsWithoutCheck(baseBehavior);
        CaseBehavior.init(caseBehavior);
        obj.mimicsWithoutCheck(caseBehavior);
        obj.registerCell("Case", caseBehavior);

        IokeObject reflectionBehavior = new IokeObject(runtime, "contains behavior related to reflection");
        reflectionBehavior.mimicsWithoutCheck(baseBehavior);
        ReflectionBehavior.init(reflectionBehavior);
        obj.mimicsWithoutCheck(reflectionBehavior);
        obj.registerCell("Reflection", reflectionBehavior);

        IokeObject booleanBehavior = new IokeObject(runtime, "contains behavior related to boolean behavior");
        booleanBehavior.mimicsWithoutCheck(baseBehavior);
        booleanBehavior.setKind("DefaultBehavior Boolean");
        obj.mimicsWithoutCheck(booleanBehavior);
        obj.registerCell("Boolean", booleanBehavior);

        IokeObject aspects = new IokeObject(runtime, "contains behavior related to aspects");
        aspects.mimicsWithoutCheck(baseBehavior);
        aspects.setKind("DefaultBehavior Aspects");
        obj.mimicsWithoutCheck(aspects);
        obj.registerCell("Aspects", aspects);
        
        obj.registerMethod(runtime.newJavaMethod("takes one or more evaluated string argument. will import the files corresponding to each of the strings named based on the Ioke loading behavior that can be found in the documentation for the loadBehavior cell on System.", new JavaMethod("use") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("module")
                    //                    .withRest("modules")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());
                    
                    String name = Text.getText(runtime.asText.sendTo(context, args.get(0)));
                    if(((IokeSystem)IokeObject.data(runtime.system)).use(IokeObject.as(on, context), context, message, name)) {
                        return runtime._true;
                    } else {
                        return runtime._false;
                    }
                }
            }));
    }
}// DefaultBehavior
