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
public class Number extends IokeObject {
    private final IntNum value;

    public Number(Runtime runtime, String textRepresentation) {
        super(runtime, runtime.number.documentation);
        this.mimics(runtime.number);
        value = IntNum.valueOf(textRepresentation);
    }

    public Number(Runtime runtime, String textRepresentation, String description) {
        super(runtime, description);
        if(runtime.number != null) {
            this.mimics(runtime.number);
        }
        value = IntNum.valueOf(textRepresentation);
    }

    public Number(Runtime runtime, int javaNumber) {
        super(runtime, runtime.number.documentation);
        this.mimics(runtime.number);
        value = IntNum.make(javaNumber);
    }

    public Number(Runtime runtime, IntNum value) {
        super(runtime, runtime.number.documentation);
        this.mimics(runtime.number);
        this.value = value;
    }
    
    @Override
    IokeObject allocateCopy(Message m, IokeObject context) {
        return new Number(runtime, value);
    }

    public String asJavaString() {
        return value.toString();
    }

    public int asJavaInteger() {
        return value.intValue();
    }

    public String toString() {
        return asJavaString();
    }

    public Number convertToNumber(Message m, IokeObject context) {
        return this;
    }

    public void init() {
        this.mimics(runtime.mixins.comparing);

        registerMethod(new JavaMethod(runtime, "<=>", "compares this number against the argument, returning -1, 0 or 1 based on which one is larger") {
                public IokeObject activate(IokeObject context, Message message, IokeObject on) throws ControlFlow {
                    IokeObject arg = ((Message)message).getEvaluatedArgument(0, context);
                    if(!(arg instanceof Number)) {
                        arg = arg.convertToNumber(message, context);
                    }
                    return new Number(runtime, IntNum.compare(((Number)on).value,((Number)arg).value));
                }
            });

        registerMethod(new JavaMethod(runtime, "-", "returns the difference between this number and the argument") {
                public IokeObject activate(IokeObject context, Message message, IokeObject on) throws ControlFlow {
                    IokeObject arg = ((Message)message).getEvaluatedArgument(0, context);
                    if(!(arg instanceof Number)) {
                        arg = arg.convertToNumber(message, context);
                    }
                    return new Number(runtime, IntNum.sub(((Number)on).value,((Number)arg).value));
                }
            });

        registerMethod(new JavaMethod(runtime, "+", "returns the addition of this number and the argument") {
                public IokeObject activate(IokeObject context, Message message, IokeObject on) throws ControlFlow {
                    IokeObject arg = ((Message)message).getEvaluatedArgument(0, context);
                    if(!(arg instanceof Number)) {
                        arg = arg.convertToNumber(message, context);
                    }
                    return new Number(runtime, IntNum.add(((Number)on).value,((Number)arg).value));
                }
            });

        registerMethod(new JavaMethod(runtime, "asText", "Returns a text representation of the object") {
                public IokeObject activate(IokeObject context, Message message, IokeObject on) {
                    return new Text(runtime, ((Number)on).toString());
                }
            });
    }
}// Number
