/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang.test;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class StaticFields {
    public static String publicStringField;
    public static String get_publicStringField(){ return publicStringField; }
    public static Object publicObjectField;
    public static Object get_publicObjectField(){ return publicObjectField; }
    public static int publicIntField;
    public static int get_publicIntField(){ return publicIntField; }
    public static short publicShortField;
    public static short get_publicShortField(){ return publicShortField; }
    public static long publicLongField;
    public static long get_publicLongField(){ return publicLongField; }
    public static char publicCharField;
    public static char get_publicCharField(){ return publicCharField; }
    public static float publicFloatField;
    public static float get_publicFloatField(){ return publicFloatField; }
    public static double publicDoubleField;
    public static double get_publicDoubleField(){ return publicDoubleField; }
    public static boolean publicBooleanField;
    public static boolean get_publicBooleanField(){ return publicBooleanField; }

    public static final String publicStringFieldFinal = "test1StringFinal";
    public static final Object publicObjectFieldFinal = new java.util.ArrayList();
    public static final int publicIntFieldFinal = 42;
    public static final short publicShortFieldFinal = 13;
    public static final long publicLongFieldFinal = 13243435;
    public static final char publicCharFieldFinal = 44;
    public static final float publicFloatFieldFinal = 434.2F;
    public static final double publicDoubleFieldFinal = 3432435.22;
    public static final boolean publicBooleanFieldFinal = true;

    protected static String protectedStringField;
    public static String get_protectedStringField(){ return protectedStringField; }
    protected static Object protectedObjectField;
    public static Object get_protectedObjectField(){ return protectedObjectField; }
    protected static int protectedIntField;
    public static int get_protectedIntField(){ return protectedIntField; }
    protected static short protectedShortField;
    public static short get_protectedShortField(){ return protectedShortField; }
    protected static long protectedLongField;
    public static long get_protectedLongField(){ return protectedLongField; }
    protected static char protectedCharField;
    public static char get_protectedCharField(){ return protectedCharField; }
    protected static float protectedFloatField;
    public static float get_protectedFloatField(){ return protectedFloatField; }
    protected static double protectedDoubleField;
    public static double get_protectedDoubleField(){ return protectedDoubleField; }
    protected static boolean protectedBooleanField;
    public static boolean get_protectedBooleanField(){ return protectedBooleanField; }

    protected static final String protectedStringFieldFinal = "test1StringFinal";
    protected static final Object protectedObjectFieldFinal = new java.util.ArrayList();
    protected static final int protectedIntFieldFinal = 42;
    protected static final short protectedShortFieldFinal = 13;
    protected static final long protectedLongFieldFinal = 13243435;
    protected static final char protectedCharFieldFinal = 44;
    protected static final float protectedFloatFieldFinal = 434.2F;
    protected static final double protectedDoubleFieldFinal = 3432435.22;
    protected static final boolean protectedBooleanFieldFinal = true;

    static String packagePrivateStringField;
    public static String get_packagePrivateStringField(){ return packagePrivateStringField; }
    static Object packagePrivateObjectField;
    public static Object get_packagePrivateObjectField(){ return packagePrivateObjectField; }
    static int packagePrivateIntField;
    public static int get_packagePrivateIntField(){ return packagePrivateIntField; }
    static short packagePrivateShortField;
    public static short get_packagePrivateShortField(){ return packagePrivateShortField; }
    static long packagePrivateLongField;
    public static long get_packagePrivateLongField(){ return packagePrivateLongField; }
    static char packagePrivateCharField;
    public static char get_packagePrivateCharField(){ return packagePrivateCharField; }
    static float packagePrivateFloatField;
    public static float get_packagePrivateFloatField(){ return packagePrivateFloatField; }
    static double packagePrivateDoubleField;
    public static double get_packagePrivateDoubleField(){ return packagePrivateDoubleField; }
    static boolean packagePrivateBooleanField;
    public static boolean get_packagePrivateBooleanField(){ return packagePrivateBooleanField; }

    static final String packagePrivateStringFieldFinal = "test1StringFinal";
    static final Object packagePrivateObjectFieldFinal = new java.util.ArrayList();
    static final int packagePrivateIntFieldFinal = 42;
    static final short packagePrivateShortFieldFinal = 13;
    static final long packagePrivateLongFieldFinal = 13243435;
    static final char packagePrivateCharFieldFinal = 44;
    static final float packagePrivateFloatFieldFinal = 434.2F;
    static final double packagePrivateDoubleFieldFinal = 3432435.22;
    static final boolean packagePrivateBooleanFieldFinal = true;
    
    private static String privateStringField;
    public static String get_privateStringField(){ return privateStringField; }
    private static Object privateObjectField;
    public static Object get_privateObjectField(){ return privateObjectField; }
    private static int privateIntField;
    public static int get_privateIntField(){ return privateIntField; }
    private static short privateShortField;
    public static short get_privateShortField(){ return privateShortField; }
    private static long privateLongField;
    public static long get_privateLongField(){ return privateLongField; }
    private static char privateCharField;
    public static char get_privateCharField(){ return privateCharField; }
    private static float privateFloatField;
    public static float get_privateFloatField(){ return privateFloatField; }
    private static double privateDoubleField;
    public static double get_privateDoubleField(){ return privateDoubleField; }
    private static boolean privateBooleanField;
    public static boolean get_privateBooleanField(){ return privateBooleanField; }

    private static final String privateStringFieldFinal = "test1StringFinal";
    private static final Object privateObjectFieldFinal = new java.util.ArrayList();
    private static final int privateIntFieldFinal = 42;
    private static final short privateShortFieldFinal = 13;
    private static final long privateLongFieldFinal = 13243435;
    private static final char privateCharFieldFinal = 44;
    private static final float privateFloatFieldFinal = 434.2F;
    private static final double privateDoubleFieldFinal = 3432435.22;
    private static final boolean privateBooleanFieldFinal = true;
}// StaticFields
