namespace NRegex { 
    using System.Globalization;

    internal class UnicodeConstants {
        internal const int CATEGORY_COUNT=32;
        internal const int Cc=(int)UnicodeCategory.Control;
        internal const int Cf=(int)UnicodeCategory.Format;
        internal const int Co=(int)UnicodeCategory.PrivateUse;
        internal const int Cn=(int)UnicodeCategory.OtherNotAssigned;
        internal const int Lu=(int)UnicodeCategory.UppercaseLetter;
        internal const int Ll=(int)UnicodeCategory.LowercaseLetter;
        internal const int Lt=(int)UnicodeCategory.TitlecaseLetter;
        internal const int Lm=(int)UnicodeCategory.ModifierLetter;
        internal const int Lo=(int)UnicodeCategory.OtherLetter;
        internal const int Mn=(int)UnicodeCategory.NonSpacingMark;
        internal const int Me=(int)UnicodeCategory.EnclosingMark;
        internal const int Mc=(int)UnicodeCategory.SpacingCombiningMark;
        internal const int Nd=(int)UnicodeCategory.DecimalDigitNumber;
        internal const int Nl=(int)UnicodeCategory.LetterNumber;
        internal const int No=(int)UnicodeCategory.OtherNumber;
        internal const int Zs=(int)UnicodeCategory.SpaceSeparator;
        internal const int Zl=(int)UnicodeCategory.LineSeparator;
        internal const int Zp=(int)UnicodeCategory.ParagraphSeparator;
        internal const int Cs=(int)UnicodeCategory.Surrogate;
        internal const int Pd=(int)UnicodeCategory.DashPunctuation;
        internal const int Ps=(int)UnicodeCategory.OpenPunctuation;
        internal const int Pi=(int)UnicodeCategory.InitialQuotePunctuation;
        internal const int Pe=(int)UnicodeCategory.ClosePunctuation;
        internal const int Pf=(int)UnicodeCategory.FinalQuotePunctuation;
        internal const int Pc=(int)UnicodeCategory.ConnectorPunctuation;
        internal const int Po=(int)UnicodeCategory.OtherPunctuation;
        internal const int Sm=(int)UnicodeCategory.MathSymbol;
        internal const int Sc=(int)UnicodeCategory.CurrencySymbol;
        internal const int Sk=(int)UnicodeCategory.ModifierSymbol;
        internal const int So=(int)UnicodeCategory.OtherSymbol;
   
        internal const int BLOCK_COUNT=256;
        internal const int BLOCK_SIZE=256;
   
        internal const int MAX_WEIGHT=char.MaxValue+1;
        internal static int[] CATEGORY_WEIGHTS=new int[CATEGORY_COUNT];
    }
}
