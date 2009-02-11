/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang.test;

/**
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class InstanceFields {
    public InstanceFields() {}

    public String publicStringField;
    public String get_publicStringField(){ return publicStringField; }
    public Object publicObjectField;
    public Object get_publicObjectField(){ return publicObjectField; }
    public int publicIntField;
    public int get_publicIntField(){ return publicIntField; }
    public short publicShortField;
    public short get_publicShortField(){ return publicShortField; }
    public long publicLongField;
    public long get_publicLongField(){ return publicLongField; }
    public char publicCharField;
    public char get_publicCharField(){ return publicCharField; }
    public float publicFloatField;
    public float get_publicFloatField(){ return publicFloatField; }
    public double publicDoubleField;
    public double get_publicDoubleField(){ return publicDoubleField; }
    public boolean publicBooleanField;
    public boolean get_publicBooleanField(){ return publicBooleanField; }

    public final String publicStringFieldFinal = "test1StringFinal";
    public final Object publicObjectFieldFinal = new java.util.ArrayList();
    public final int publicIntFieldFinal = 42;
    public final short publicShortFieldFinal = 13;
    public final long publicLongFieldFinal = 13243435;
    public final char publicCharFieldFinal = 44;
    public final float publicFloatFieldFinal = 434.2F;
    public final double publicDoubleFieldFinal = 3432435.22;
    public final boolean publicBooleanFieldFinal = true;

    protected String protectedStringField;
    public String get_protectedStringField(){ return protectedStringField; }
    protected Object protectedObjectField;
    public Object get_protectedObjectField(){ return protectedObjectField; }
    protected int protectedIntField;
    public int get_protectedIntField(){ return protectedIntField; }
    protected short protectedShortField;
    public short get_protectedShortField(){ return protectedShortField; }
    protected long protectedLongField;
    public long get_protectedLongField(){ return protectedLongField; }
    protected char protectedCharField;
    public char get_protectedCharField(){ return protectedCharField; }
    protected float protectedFloatField;
    public float get_protectedFloatField(){ return protectedFloatField; }
    protected double protectedDoubleField;
    public double get_protectedDoubleField(){ return protectedDoubleField; }
    protected boolean protectedBooleanField;
    public boolean get_protectedBooleanField(){ return protectedBooleanField; }

    protected final String protectedStringFieldFinal = "test1StringFinal";
    protected final Object protectedObjectFieldFinal = new java.util.ArrayList();
    protected final int protectedIntFieldFinal = 42;
    protected final short protectedShortFieldFinal = 13;
    protected final long protectedLongFieldFinal = 13243435;
    protected final char protectedCharFieldFinal = 44;
    protected final float protectedFloatFieldFinal = 434.2F;
    protected final double protectedDoubleFieldFinal = 3432435.22;
    protected final boolean protectedBooleanFieldFinal = true;

    String packagePrivateStringField;
    public String get_packagePrivateStringField(){ return packagePrivateStringField; }
    Object packagePrivateObjectField;
    public Object get_packagePrivateObjectField(){ return packagePrivateObjectField; }
    int packagePrivateIntField;
    public int get_packagePrivateIntField(){ return packagePrivateIntField; }
    short packagePrivateShortField;
    public short get_packagePrivateShortField(){ return packagePrivateShortField; }
    long packagePrivateLongField;
    public long get_packagePrivateLongField(){ return packagePrivateLongField; }
    char packagePrivateCharField;
    public char get_packagePrivateCharField(){ return packagePrivateCharField; }
    float packagePrivateFloatField;
    public float get_packagePrivateFloatField(){ return packagePrivateFloatField; }
    double packagePrivateDoubleField;
    public double get_packagePrivateDoubleField(){ return packagePrivateDoubleField; }
    boolean packagePrivateBooleanField;
    public boolean get_packagePrivateBooleanField(){ return packagePrivateBooleanField; }

    final String packagePrivateStringFieldFinal = "test1StringFinal";
    final Object packagePrivateObjectFieldFinal = new java.util.ArrayList();
    final int packagePrivateIntFieldFinal = 42;
    final short packagePrivateShortFieldFinal = 13;
    final long packagePrivateLongFieldFinal = 13243435;
    final char packagePrivateCharFieldFinal = 44;
    final float packagePrivateFloatFieldFinal = 434.2F;
    final double packagePrivateDoubleFieldFinal = 3432435.22;
    final boolean packagePrivateBooleanFieldFinal = true;
    
    private String privateStringField;
    public String get_privateStringField(){ return privateStringField; }
    private Object privateObjectField;
    public Object get_privateObjectField(){ return privateObjectField; }
    private int privateIntField;
    public int get_privateIntField(){ return privateIntField; }
    private short privateShortField;
    public short get_privateShortField(){ return privateShortField; }
    private long privateLongField;
    public long get_privateLongField(){ return privateLongField; }
    private char privateCharField;
    public char get_privateCharField(){ return privateCharField; }
    private float privateFloatField;
    public float get_privateFloatField(){ return privateFloatField; }
    private double privateDoubleField;
    public double get_privateDoubleField(){ return privateDoubleField; }
    private boolean privateBooleanField;
    public boolean get_privateBooleanField(){ return privateBooleanField; }

    private final String privateStringFieldFinal = "test1StringFinal";
    private final Object privateObjectFieldFinal = new java.util.ArrayList();
    private final int privateIntFieldFinal = 42;
    private final short privateShortFieldFinal = 13;
    private final long privateLongFieldFinal = 13243435;
    private final char privateCharFieldFinal = 44;
    private final float privateFloatFieldFinal = 434.2F;
    private final double privateDoubleFieldFinal = 3432435.22;
    private final boolean privateBooleanFieldFinal = true;
}
