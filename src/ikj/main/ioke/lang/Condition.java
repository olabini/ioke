/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Condition {
    public static void init(IokeObject obj) throws ControlFlow {
        Runtime runtime = obj.runtime;
        obj.setKind("Condition");

        IokeObject conditionDefault = obj.mimic(null, null);
        conditionDefault.setKind("Condition Default");
        obj.setCell("Default", conditionDefault);

        IokeObject conditionWarning = obj.mimic(null, null);
        conditionWarning.setKind("Condition Warning");
        obj.setCell("Warning", conditionWarning);

        IokeObject conditionWarningDefault = conditionWarning.mimic(null, null);
        conditionWarningDefault.setKind("Condition Warning Default");
        conditionWarning.setCell("Default", conditionWarningDefault);

        IokeObject conditionError = obj.mimic(null, null);
        conditionError.setKind("Condition Error");
        obj.setCell("Error", conditionError);

        IokeObject conditionErrorDefault = conditionError.mimic(null, null);
        conditionErrorDefault.setKind("Condition Error Default");
        conditionError.setCell("Default", conditionErrorDefault);
    }
}// Condition
