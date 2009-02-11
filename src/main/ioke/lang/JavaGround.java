/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.math.BigDecimal;

import java.util.List;
import java.util.Map;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class JavaGround {
    public static void init(IokeObject obj) throws ControlFlow {
        final Runtime runtime = obj.runtime;
        obj.setKind("JavaGround");
        obj.mimicsWithoutCheck(IokeObject.as(runtime.defaultBehavior.getCells().get("BaseBehavior"), null));


        obj.registerMethod(runtime.newJavaMethod("takes an internal name for a Java type and returns that object.", new TypeCheckingJavaMethod("primitiveJavaClass!") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .withRequiredPositional("name").whichMustMimic(runtime.text)
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    Object arg = args.get(0);
                    String name = Text.getText(arg);
                    Class<?> c = null;
                    try {
                        c = Class.forName(name);
                    } catch(Exception e) {
                        runtime.reportJavaException(e, message, context);
                    }
                    return runtime.registry.wrap(c);
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("expects to be invoked on a Java String, either wrapped or unwrapped.", new JavaMethod.WithNoArguments("primitiveMagic: String->Text") {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    if(on instanceof String) {
                        return runtime.newText((String)on);
                    } else {
                        return runtime.newText((String)JavaWrapper.getObject(on));
                    }
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("expects to be invoked on a Java Integer, either wrapped or unwrapped.", new JavaMethod.WithNoArguments("primitiveMagic: Integer->Rational") {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    if(on instanceof Integer) {
                        return runtime.newNumber(((Integer)on).longValue());
                    } else {
                        return runtime.newNumber(((Integer)JavaWrapper.getObject(on)).longValue());
                    }
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("expects to be invoked on a Java Short, either wrapped or unwrapped.", new JavaMethod.WithNoArguments("primitiveMagic: Short->Rational") {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    if(on instanceof Short) {
                        return runtime.newNumber(((Short)on).longValue());
                    } else {
                        return runtime.newNumber(((Short)JavaWrapper.getObject(on)).longValue());
                    }
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("expects to be invoked on a Java Long, either wrapped or unwrapped.", new JavaMethod.WithNoArguments("primitiveMagic: Long->Rational") {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    if(on instanceof Long) {
                        return runtime.newNumber(((Long)on).longValue());
                    } else {
                        return runtime.newNumber(((Long)JavaWrapper.getObject(on)).longValue());
                    }
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("expects to be invoked on a Java Character, either wrapped or unwrapped.", new JavaMethod.WithNoArguments("primitiveMagic: Character->Rational") {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    if(on instanceof Character) {
                        return runtime.newNumber(((Character)on).charValue());
                    } else {
                        return runtime.newNumber(((Character)JavaWrapper.getObject(on)).charValue());
                    }
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("expects to be invoked on a Java Float, either wrapped or unwrapped.", new JavaMethod.WithNoArguments("primitiveMagic: Float->Decimal") {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    if(on instanceof Float) {
                        return runtime.newDecimal(BigDecimal.valueOf(((Float)on).doubleValue()));
                    } else {
                        return runtime.newDecimal(BigDecimal.valueOf(((Float)JavaWrapper.getObject(on)).doubleValue()));
                    }
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("expects to be invoked on a Java Double, either wrapped or unwrapped.", new JavaMethod.WithNoArguments("primitiveMagic: Double->Decimal") {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    if(on instanceof Double) {
                        return runtime.newDecimal(BigDecimal.valueOf(((Double)on).doubleValue()));
                    } else {
                        return runtime.newDecimal(BigDecimal.valueOf(((Double)JavaWrapper.getObject(on)).doubleValue()));
                    }
                }
            }));
    }
}
