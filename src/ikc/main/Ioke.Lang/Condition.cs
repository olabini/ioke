namespace Ioke.Lang {
    public class Condition {
        public static void Init(IokeObject obj) {
            obj.Kind = "Condition";

            IokeObject conditionDefault = obj.Mimic(null, null);
            conditionDefault.Kind = "Condition Default";
            obj.SetCell("Default", conditionDefault);

            IokeObject conditionWarning = obj.Mimic(null, null);
            conditionWarning.Kind = "Condition Warning";
            obj.SetCell("Warning", conditionWarning);

            IokeObject conditionWarningDefault = conditionWarning.Mimic(null, null);
            conditionWarningDefault.Kind = "Condition Warning Default";
            conditionWarning.SetCell("Default", conditionWarningDefault);

            IokeObject conditionError = obj.Mimic(null, null);
            conditionError.Kind = "Condition Error";
            obj.SetCell("Error", conditionError);

            IokeObject conditionErrorDefault = conditionError.Mimic(null, null);
            conditionErrorDefault.Kind = "Condition Error Default";
            conditionError.SetCell("Default", conditionErrorDefault);
        }
    }
}
