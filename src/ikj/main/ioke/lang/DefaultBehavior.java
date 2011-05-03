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
        baseBehavior.setCell("=",         runtime.base.body.get("=", 0));
        baseBehavior.setCell("==",        runtime.base.body.get("==", 0));
        baseBehavior.setCell("cell",      runtime.base.body.get("cell", 0));
        baseBehavior.setCell("cell?",     runtime.base.body.get("cell?", 0));
        baseBehavior.setCell("cell=",     runtime.base.body.get("cell=", 0));
        baseBehavior.setCell("cells",     runtime.base.body.get("cells", 0));
        baseBehavior.setCell("cellNames", runtime.base.body.get("cellNames", 0));
        baseBehavior.setCell("removeCell!", runtime.base.body.get("removeCell!", 0));
        baseBehavior.setCell("undefineCell!", runtime.base.body.get("undefineCell!", 0));
        baseBehavior.setCell("cellOwner?", runtime.base.body.get("cellOwner?", 0));
        baseBehavior.setCell("cellOwner", runtime.base.body.get("cellOwner", 0));
        baseBehavior.setCell("documentation", runtime.base.body.get("documentation", 0));
        baseBehavior.setCell("identity", runtime.base.body.get("identity", 0));
        baseBehavior.setCell("activatable", runtime.base.body.get("activatable", 0));
        baseBehavior.setCell("activatable=", runtime.base.body.get("activatable=", 0));
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
    }
}// DefaultBehavior
