/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang.extensions.benchmark;

import ioke.lang.Runtime;
import ioke.lang.IokeObject;
import ioke.lang.JavaMethod;
import ioke.lang.Message;
import ioke.lang.Number;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Benchmark extends IokeObject {
    Benchmark(Runtime runtime, String documentation) {
        super(runtime, documentation);
    }

    @Override
    public IokeObject allocateCopy(IokeObject m, IokeObject context) {
        return new Benchmark(runtime, documentation);
    }

    public static IokeObject create(Runtime runtime) {
        Benchmark bm = new Benchmark(runtime, "Benchmark is a module that makes it easy to test the time code takes to run");
        bm.init();
        return bm;
    }

    public void init() {
        runtime.ground.setCell("Benchmark", this);
        
        registerMethod(runtime.newJavaMethod("expects two optional numbers, x (default 10) and y (default 1), and a block of code to run, and will run benchmark this block x times, while looping y times in each benchmark. after each loop will print the timings for this loop", new JavaMethod("report") {
                @Override
                public IokeObject activate(IokeObject method, IokeObject context, IokeObject message, IokeObject on) throws ControlFlow {
                    int count = message.getArgumentCount();
                    int bmRounds = 10;
                    long iterations = 1;
                    int index = 0;
                    if(count > 1) {
                        bmRounds = ((Number)message.getEvaluatedArgument(index, context).convertToNumber(message, context).data).asJavaInteger();
                        index++;
                        if(count > 2) {
                            iterations = ((Number)message.getEvaluatedArgument(index, context).convertToNumber(message, context).data).asJavaLong();
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
                        runtime.getOut().println(String.format("%-32.32s %.6s.%09d", ((Message)message.getArguments().get(index)).thisCode(), secs, rest));
                        runtime.getOut().flush();
                    }

                    return runtime.nil;
                }
            }));
    }

    public String toString() {
        return "Benchmark";
    }
}// Benchmark
