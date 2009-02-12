/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang.extensions.benchmark;

import ioke.lang.Runtime;
import ioke.lang.IokeObject;
import ioke.lang.JavaMethod;
import ioke.lang.Message;
import ioke.lang.Number;
import ioke.lang.DefaultArgumentsDefinition;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public abstract class Benchmark {
    private Benchmark() {}

    public static IokeObject create(Runtime runtime) throws ControlFlow {
        IokeObject bm = new IokeObject(runtime, "Benchmark is a module that makes it easy to test the time code takes to run");
        Benchmark.init(bm);
        return bm;
    }

    public static void init(IokeObject bm) throws ControlFlow {
        Runtime runtime = bm.runtime;
        bm.setKind("Benchmark");
        runtime.ground.setCell("Benchmark", bm);
        bm.mimicsWithoutCheck(runtime.origin);

        bm.registerMethod(runtime.newJavaMethod("expects two optional numbers, x (default 10) and y (default 1), and a block of code to run, and will run benchmark this block x times, while looping y times in each benchmark. after each loop will print the timings for this loop", new JavaMethod("report") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withOptionalPositional("repetitions", "10")
                    .withOptionalPositional("loops", "1")
                    .withRequiredPositionalUnevaluated("code")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().checkArgumentCount(context, message, on);

                    int count = message.getArgumentCount();
                    int bmRounds = 10;
                    long iterations = 1;
                    int index = 0;
                    if(count > 1) {
                        bmRounds = ((Number)IokeObject.data(IokeObject.convertToNumber(message.getEvaluatedArgument(index, context), message, context))).asJavaInteger();
                        index++;
                        if(count > 2) {
                            iterations = ((Number)IokeObject.data(IokeObject.convertToNumber(message.getEvaluatedArgument(index, context), message, context))).asJavaLong();
                            index++;
                        }
                    }

                    for(int i=0;i<bmRounds;i++) {
                        long before = System.nanoTime();
                        for(int j=0;j<iterations;j++) {
                            message.getEvaluatedArgument(index, context);
                        }
                        long after = System.nanoTime();
                        long time = after-before;
                        long secs = time/1000000000;
                        long rest = time%1000000000;

                        String theCode = Message.thisCode(((IokeObject)message.getArguments().get(index)));

                        context.runtime.printlnMessage.sendTo(context, context.runtime.outMessage.sendTo(context, context.runtime.system), context.runtime.newText(String.format("%-32.32s %.6s.%09d", theCode, secs, rest)));
                    }

                    return context.runtime.nil;
                }
            }));
    }
}// Benchmark
