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
    public IokeObject convertToNumber(IokeObject self, Message m, IokeObject context) {
        return self;
    }

    @Override
    public void init(IokeObject obj) {
        final Runtime runtime = obj.runtime;

        obj.setKind("Number");
        obj.mimics(runtime.mixins.getCell(null, null, "Comparing"));
        
        obj.registerMethod(runtime.newJavaMethod("compares this number against the argument, returning -1, 0 or 1 based on which one is larger", new JavaMethod("<=>") {
                @Override
                public IokeObject activate(IokeObject method, IokeObject context, Message message, IokeObject on) throws ControlFlow {
                    IokeObject arg = ((Message)message).getEvaluatedArgument(0, context);
                    if(!(arg.data instanceof Number)) {
                        arg = arg.convertToNumber(message, context);
                    }
                    return runtime.newNumber(IntNum.compare(((Number)on.data).value,((Number)arg.data).value));
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns the difference between this number and the argument", new JavaMethod("-") {
                @Override
                public IokeObject activate(IokeObject method, IokeObject context, Message message, IokeObject on) throws ControlFlow {
                    IokeObject arg = ((Message)message).getEvaluatedArgument(0, context);
                    if(!(arg.data instanceof Number)) {
                        arg = arg.convertToNumber(message, context);
                    }
                    return runtime.newNumber(IntNum.sub(((Number)on.data).value,((Number)arg.data).value));
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns the addition of this number and the argument", new JavaMethod("+") {
                @Override
                public IokeObject activate(IokeObject method, IokeObject context, Message message, IokeObject on) throws ControlFlow {
                    IokeObject arg = ((Message)message).getEvaluatedArgument(0, context);
                    if(!(arg.data instanceof Number)) {
                        arg = arg.convertToNumber(message, context);
                    }
                    return runtime.newNumber(IntNum.add(((Number)on.data).value,((Number)arg.data).value));
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("Returns a text representation of the object", new JavaMethod("asText") {
                @Override
                public IokeObject activate(IokeObject method, IokeObject context, Message message, IokeObject on) {
                    return runtime.newText(on.toString());
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("Returns the successor of this number", new JavaMethod("succ") {
                @Override
                public IokeObject activate(IokeObject method, IokeObject context, Message message, IokeObject on) {
                    return runtime.newNumber(IntNum.add(((Number)on.data).value,IntNum.one()));
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("Expects one or two arguments. If one argument is given, executes it as many times as the value of the receiving number. If two arguments are given, the first will be an unevaluated name that will receive the current loop value on each repitition. the iteration length is limited to the positive maximum of a Java int", new JavaMethod("times") {
                @Override
                public IokeObject activate(IokeObject method, IokeObject context, Message message, IokeObject on) throws ControlFlow {
                    int num = ((Number)on.data).value.intValue();
                    switch(message.getArgumentCount()) {
                    case 0:
                        return runtime.nil;
                    case 1: {
                        IokeObject result = runtime.nil;
                        while(num > 0) {
                            result = message.getEvaluatedArgument(0, context);
                            num--;
                        }
                        return result;
                    }
                    default:
                        int ix = 0;
                        String name = ((Message)(message.getArg1())).getName();
                        IokeObject result = runtime.nil;
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
