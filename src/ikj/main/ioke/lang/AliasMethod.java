/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class AliasMethod extends IokeData implements Named, Inspectable, AssociatedCode {
    String name;
    IokeData realMethod;
    IokeObject realSelf;

    public AliasMethod(String name, IokeData realMethod, IokeObject realSelf) {
        super(IokeData.TYPE_ALIAS_METHOD);
        this.name = name;
        this.realMethod = realMethod;
        this.realSelf = realSelf;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String inspect(Object self) {
        return ((Inspectable)realMethod).inspect(realSelf);
    }

    public String notice(Object self) {
        return ((Inspectable)realMethod).notice(realSelf);
    }

    public IokeObject getCode() {
        return ((AssociatedCode)realMethod).getCode();
    }

    public String getCodeString() {
        if(realMethod instanceof Method) {
            return ((Method)realMethod).getCodeString();
        } else if(realMethod instanceof DefaultMacro) {
            return ((DefaultMacro)realMethod).getCodeString();
        } else {
            return ((AliasMethod)realMethod).getCodeString();
        }
    }

    public String getArgumentsCode() {
        if(realMethod instanceof AssociatedCode) {
            return ((AssociatedCode)realMethod).getArgumentsCode();
        }
        return "...";
    }

    public String getFormattedCode(Object self) throws ControlFlow {
        if(realMethod instanceof AssociatedCode) {
            return ((AssociatedCode)realMethod).getFormattedCode(self);
        }
        return "";
    }

    public static Object activateFixed(IokeObject self, IokeObject ctx, IokeObject message, Object obj) throws ControlFlow {
        AliasMethod am = (AliasMethod)self.data;
        IokeObject realSelf = am.realSelf;
        switch(am.realMethod.type) {
        case IokeData.TYPE_DEFAULT_METHOD:
            return DefaultMethod.activateFixed(realSelf, ctx, message, obj);
        case IokeData.TYPE_DEFAULT_MACRO:
            return DefaultMacro.activateFixed(realSelf, ctx, message, obj);
        case IokeData.TYPE_DEFAULT_SYNTAX:
            return DefaultSyntax.activateFixed(realSelf, ctx, message, obj);
        case IokeData.TYPE_LEXICAL_MACRO:
            return LexicalMacro.activateFixed(realSelf, ctx, message, obj);
        case IokeData.TYPE_NATIVE_METHOD:
            return NativeMethod.activateFixed(realSelf, ctx, message, obj);
        case IokeData.TYPE_JAVA_CONSTRUCTOR:
            return JavaConstructorNativeMethod.activateFixed(realSelf, ctx, message, obj);
        case IokeData.TYPE_JAVA_FIELD_GETTER:
            return JavaFieldGetterNativeMethod.activateFixed(realSelf, ctx, message, obj);
        case IokeData.TYPE_JAVA_FIELD_SETTER:
            return JavaFieldSetterNativeMethod.activateFixed(realSelf, ctx, message, obj);
        case IokeData.TYPE_JAVA_METHOD:
            return JavaMethodNativeMethod.activateFixed(realSelf, ctx, message, obj);
        case IokeData.TYPE_METHOD_PROTOTYPE:
            return Method.activateFixed(realSelf, ctx, message, obj);
        case IokeData.TYPE_LEXICAL_BLOCK:
            return LexicalBlock.activateFixed(realSelf, ctx, message, obj);
        case IokeData.TYPE_ALIAS_METHOD:
            return AliasMethod.activateFixed(realSelf, ctx, message, obj);
        case IokeData.TYPE_NONE:
        default:
            return IokeData.activateFixed(realSelf, ctx, message, obj);
        }
    }
}// AliasMethod
