/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang.extensions.readline;

import java.io.IOException;

import java.util.HashMap;
import java.util.ArrayList;
import java.util.List;

import ioke.lang.DefaultArgumentsDefinition;
import ioke.lang.Runtime;
import ioke.lang.RunnableWithControlFlow;
import ioke.lang.IokeObject;
import ioke.lang.JavaMethod;
import ioke.lang.Message;
import ioke.lang.Number;
import ioke.lang.Text;

import ioke.lang.exceptions.ControlFlow;

import jline.ConsoleReader;
import jline.Completor;
import jline.FileNameCompletor;
import jline.CandidateListCompletionHandler;
import jline.History;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public abstract class Readline {
    public static class ConsoleHolder {
        public ConsoleReader readline;
        public Completor currentCompletor;
        public History history;
    }

    protected static void initReadline(Runtime runtime, ConsoleHolder holder) throws IOException {
        holder.readline = new ConsoleReader();
        holder.readline.setUseHistory(false);
        holder.readline.setUsePagination(true);
        holder.readline.setBellEnabled(false);
        ((CandidateListCompletionHandler) holder.readline.getCompletionHandler()).setAlwaysIncludeNewline(false);
        holder.readline.setHistory(holder.history);
    }

    private Readline() {}

    public static IokeObject create(Runtime runtime) throws ControlFlow {
        IokeObject rl = new IokeObject(runtime, "Readline is a module allows access to the readline native functionality");
        Readline.init(rl);
        return rl;
    }

    public static void init(final IokeObject rl) throws ControlFlow {
        Runtime runtime = rl.runtime;
        rl.setKind("Readline");
        rl.mimicsWithoutCheck(runtime.origin);
        runtime.ground.setCell("Readline", rl);
        rl.setCell("VERSION", runtime.newText("JLine wrapper"));

        final ConsoleHolder holder = new ConsoleHolder();
        holder.history = new History();
        holder.currentCompletor = null;

        IokeObject history = runtime.newFromOrigin();
        rl.setCell("HISTORY", history);
        
        rl.registerMethod(runtime.newJavaMethod("will print a prompt to standard out and then try to read a line with working readline functionality. takes two arguments, the first is the string to prompt, the second is a boolean that says whether we should add the read string to history or not", new JavaMethod("readline") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("prompt")
                    .withRequiredPositional("addToHistory?")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());
                    
                    Object line = method.runtime.nil;
                    try {
                        if(holder.readline == null) {
                            initReadline(method.runtime, holder);
                        }
                        holder.readline.getTerminal().disableEcho();
                        String v = holder.readline.readLine(Text.getText(args.get(0)));
                        holder.readline.getTerminal().enableEcho();
                        if(null != v) {
                            if(IokeObject.isTrue(args.get(1))) {
                                holder.readline.getHistory().addToHistory(v);
                            }

                            line = method.runtime.newText(v);
                        }
                    } catch(IOException e) {
                        final Runtime runtime = context.runtime;
                        final IokeObject condition = IokeObject.as(IokeObject.getCellChain(runtime.condition, 
                                                                                           message, 
                                                                                           context, 
                                                                                           "Error", 
                                                                                           "IO"), context).mimic(message, context);
                        condition.setCell("message", message);
                        condition.setCell("context", context);
                        condition.setCell("receiver", on);
                        condition.setCell("exceptionMessage", runtime.newText(e.getMessage()));
                        List<Object> ob = new ArrayList<Object>();
                        for(StackTraceElement ste : e.getStackTrace()) {
                            ob.add(runtime.newText(ste.toString()));
                        }

                        condition.setCell("exceptionStackTrace", runtime.newList(ob));

                        runtime.withReturningRestart("ignore", context, new RunnableWithControlFlow() {
                                public void run() throws ControlFlow {
                                    runtime.errorCondition(condition);
                                }});
                    }
                    return line;
                }
            }));

        history.registerMethod(runtime.newJavaMethod("will add a new line to the history", new JavaMethod("<<") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("line")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());
                    
                    for(Object o : args) {
                        holder.history.addToHistory(Text.getText(o));
                    }
                    return context.runtime.nil;
                }
            }));
    }
}// Readline
