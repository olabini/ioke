/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import gnu.math.IntNum;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Number extends IokeData {
    private final IntNum value;

    public Number(String textRepresentation) {
        value = IntNum.valueOf(textRepresentation);
    }

    public Number(int javaNumber) {
        value = IntNum.make(javaNumber);
    }

    public Number(IntNum value) {
        this.value = value;
    }
    
    public String asJavaString() {
        return value.toString();
    }

    public int asJavaInteger() {
        return value.intValue();
    }

    public long asJavaLong() {
        return value.longValue();
    }

    @Override
    public String toString() {
        return asJavaString();
    }

    @Override
    public String toString(IokeObject obj) {
        return asJavaString();
    }

    @Override
    public IokeObject convertToNumber(IokeObject self, IokeObject m, IokeObject context) {
        return self;
    }

    public static IntNum value(Object number) {
        return ((Number)IokeObject.data(number)).value;
    }

    @Override
    public void init(IokeObject obj) {
        final Runtime runtime = obj.runtime;

        obj.setKind("Number");
        obj.mimics(IokeObject.as(runtime.mixins.getCell(null, null, "Comparing")), runtime.nul, runtime.nul);
        
        obj.registerMethod(runtime.newJavaMethod("compares this number against the argument, returning -1, 0 or 1 based on which one is larger", new JavaMethod("<=>") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    Object arg = message.getEvaluatedArgument(0, context);
                    if(!(IokeObject.data(arg) instanceof Number)) {
                        arg = IokeObject.convertToNumber(arg, message, context);
                    }
                    return runtime.newNumber(IntNum.compare(Number.value(on),Number.value(arg)));
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns the difference between this number and the argument", new JavaMethod("-") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    Object arg = message.getEvaluatedArgument(0, context);
                    if(!(IokeObject.data(arg) instanceof Number)) {
                        arg = IokeObject.convertToNumber(arg, message, context);
                    }
                    return runtime.newNumber(IntNum.sub(Number.value(on),Number.value(arg)));
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns the addition of this number and the argument", new JavaMethod("+") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    Object arg = message.getEvaluatedArgument(0, context);
                    if(!(IokeObject.data(arg) instanceof Number)) {
                        arg = IokeObject.convertToNumber(arg, message, context);
                    }
                    return runtime.newNumber(IntNum.add(Number.value(on),Number.value(arg)));
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("Returns a text representation of the object", new JavaMethod("asText") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) {
                    return runtime.newText(on.toString());
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("Returns the successor of this number", new JavaMethod("succ") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) {
                    return runtime.newNumber(IntNum.add(Number.value(on),IntNum.one()));
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("Returns the predecessor of this number", new JavaMethod("pred") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) {
                    return runtime.newNumber(IntNum.sub(Number.value(on),IntNum.one()));
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("Expects one or two arguments. If one argument is given, executes it as many times as the value of the receiving number. If two arguments are given, the first will be an unevaluated name that will receive the current loop value on each repitition. the iteration length is limited to the positive maximum of a Java int", new JavaMethod("times") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    int num = Number.value(on).intValue();
                    switch(message.getArgumentCount()) {
                    case 0:
                        return runtime.nil;
                    case 1: {
                        Object result = runtime.nil;
                        while(num > 0) {
                            result = message.getEvaluatedArgument(0, context);
                            num--;
                        }
                        return result;
                    }
                    default:
                        int ix = 0;
                        String name = ((IokeObject)Message.getArg1(message)).getName();
                        Object result = runtime.nil;
                        while(ix<num) {
                            context.setCell(name, runtime.newNumber(IntNum.make(ix)));
                            result = message.getEvaluatedArgument(1, context);
                            ix++;
                        }
                        return result;
                    }
                }
            }));
    }
}// Number
