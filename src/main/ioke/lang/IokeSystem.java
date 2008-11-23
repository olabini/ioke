/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.File;
import java.io.IOException;

import java.util.Arrays;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.HashSet;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class IokeSystem extends IokeData {
    private List<String> currentFile = new ArrayList<String>(Arrays.asList("<init>"));
    private String currentProgram;
    private String currentWorkingDirectory;
    private Set<String> loaded = new HashSet<String>();

    private IokeObject loadPath;

    public void pushCurrentFile(String filename) {
        currentFile.add(0, filename);
    }

    public String popCurrentFile() {
        return currentFile.remove(0);
    }

    public String currentFile() {
        return currentFile.get(0);
    }

    public String currentProgram() {
        return currentProgram;
    }

    public void setCurrentProgram(String currentProgram) {
        this.currentProgram = currentProgram;
    }

    public void setCurrentWorkingDirectory(String cwd) {
        this.currentWorkingDirectory = cwd;
    }

    public String getCurrentWorkingDirectory() {
        return this.currentWorkingDirectory;
    }

    private static final String[] SUFFIXES = {"", ".ik"};

    public boolean use(IokeObject self, IokeObject context, IokeObject message, String name) throws ControlFlow {
        final Runtime runtime = context.runtime;
        Builtin b = context.runtime.getBuiltin(name);
        if(b != null) {
            if(loaded.contains(name)) {
                return false;
            } else {
                b.load(context.runtime, context, message);
                loaded.add(name);
                return true;
            }
        }

        List<Object> paths = ((IokeList)IokeObject.data(loadPath)).getList();

        for(Object o : paths) {
            String currentS = Text.getText(o);

            for(String suffix : SUFFIXES) {
                String before = "/";
                if(name.startsWith("/")) {
                    before = "";
                }

                InputStream is = IokeSystem.class.getResourceAsStream(before + name + suffix);
                if(null != is) {
                    if(loaded.contains(name+suffix)) {
                        return false;
                    } else {
                        context.runtime.evaluateStream(name+suffix, new InputStreamReader(is));
                        loaded.add(name+suffix);
                        return true;
                    }
                }

                try {
                    File f;

                    if(currentS.startsWith("/")) {
                        f = new File(currentS, name + suffix);
                    } else {
                        f = new File(new File(currentWorkingDirectory, currentS), name + suffix);
                    }

                    if(f.exists()) {
                        if(loaded.contains(f.getCanonicalPath())) {
                            return false;
                        } else {
                            context.runtime.evaluateFile(f);
                            loaded.add(f.getCanonicalPath());
                            return true;
                        }
                    }
                } catch(IOException e) {
                    final IokeObject condition = IokeObject.as(IokeObject.getCellChain(runtime.condition, 
                                                                                       message, 
                                                                                       context, 
                                                                                       "Error", 
                                                                                       "Load")).mimic(message, context);
                    condition.setCell("message", message);
                    condition.setCell("context", context);
                    condition.setCell("receiver", self);
                    condition.setCell("moduleName", runtime.newText(name));
                    condition.setCell("exceptionMessage", runtime.newText(e.getMessage()));
                    List<Object> ob = new ArrayList<Object>();
                    for(StackTraceElement ste : e.getStackTrace()) {
                        ob.add(runtime.newText(ste.toString()));
                    }

                    condition.setCell("exceptionStackTrace", runtime.newList(ob));

                    final boolean[] continueLoadChain = new boolean[]{false};

                    runtime.withRestartReturningArguments(new RunnableWithControlFlow() {
                            public void run() throws ControlFlow {
                                runtime.errorCondition(condition);
                            }}, 
                        context,
                        new Restart.ArgumentGivingRestart("continueLoadChain") { 
                            public IokeObject invoke(IokeObject context, List<Object> arguments) throws ControlFlow {
                                continueLoadChain[0] = true;
                                return runtime.nil;
                            }
                        },
                        new Restart.ArgumentGivingRestart("ignoreLoadError") {
                            public IokeObject invoke(IokeObject context, List<Object> arguments) throws ControlFlow {
                                continueLoadChain[0] = false;
                                return runtime.nil;
                            }
                        }
                        );
                    if(!continueLoadChain[0]) {
                        return false;
                    }
                }
            }
        }
        
        final IokeObject condition = IokeObject.as(IokeObject.getCellChain(runtime.condition, 
                                                                           message, 
                                                                           context, 
                                                                           "Error", 
                                                                           "Load")).mimic(message, context);
        condition.setCell("message", message);
        condition.setCell("context", context);
        condition.setCell("receiver", self);
        condition.setCell("moduleName", runtime.newText(name));

        runtime.withReturningRestart("ignoreLoadError", context, new RunnableWithControlFlow() {
                public void run() throws ControlFlow {
                    runtime.errorCondition(condition);
                }});
        return false;
    }
    
    public IokeData cloneData(IokeObject obj, IokeObject m, IokeObject context) {
        return new IokeSystem();
    }

    public void init(IokeObject obj) throws ControlFlow {
        final Runtime runtime = obj.runtime;

        obj.setKind("System");

        try {
            currentWorkingDirectory = new File(".").getCanonicalPath();
        } catch(Exception e) {
            currentWorkingDirectory = ".";
        }

        List<Object> l = new ArrayList<Object>();
        l.add(runtime.newText("."));
        loadPath = runtime.newList(l);

        IokeObject outx = runtime.io.mimic(null, null);
        outx.data = new IokeIO(runtime.out);
        obj.registerCell("out", outx);

        IokeObject errx = runtime.io.mimic(null, null);
        errx.data = new IokeIO(runtime.err);
        obj.registerCell("err", errx);

        obj.registerCell("currentDebugger", runtime.nil);

        obj.registerMethod(runtime.newJavaMethod("returns the current file executing", new JavaMethod("currentFile") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    return runtime.newText(((IokeSystem)IokeObject.data(on)).currentFile.get(0));
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns the current load path", new JavaMethod("loadPath") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    return ((IokeSystem)IokeObject.data(on)).loadPath;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns result of evaluating first argument", new JavaMethod("ifMain") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    if(((IokeSystem)IokeObject.data(on)).currentProgram().equals(message.getFile())) {
                        return ((IokeObject)message.getArguments().get(0)).evaluateCompleteWith(context, context.getRealContext());
                    } else {
                        return runtime.nil;
                    }
                }
            }));
    }

    public String toString() {
        return "System";
    }
}// IokeSystem
