/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Condition {
    public static void init(IokeObject obj) {
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
    }
}// Condition
