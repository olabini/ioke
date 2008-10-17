/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.io.File;

import java.util.Arrays;
import java.util.ArrayList;
import java.util.List;

import ioke.lang.exceptions.IokeException;
import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class IokeSystem extends IokeData {
    private List<String> currentFile = new ArrayList<String>(Arrays.asList("<init>"));
    private String currentProgram;
    private String currentWorkingDirectory;

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

    public boolean use(IokeObject context, Message message, String name) throws ControlFlow {
        Builtin b = context.runtime.getBuiltin(name);
        if(b != null) {
            b.load(context.runtime, context, message);
            return true;
        }

//         System.err.println("use(" + context + "," + message + "," + name + ")");
        for(String suffix : SUFFIXES) {
//             System.err.println("- suffix: " + suffix);
            File f = new File(currentWorkingDirectory, name + suffix);
//             System.err.println("- gah: " + f);
            if(f.exists()) {
//                 System.err.println("- IT EXISTS");
                context.runtime.evaluateFile(f);
                return true;
            }
        }
        // TODO: raise condition here...
        throw new IokeException(message, "Couldn't find module '" + name + "' to load", context, context);
    }
    
    public IokeData cloneData(IokeObject obj, Message m, IokeObject context) {
        return new IokeSystem();
    }

    public void init(IokeObject obj) {
        Runtime runtime = obj.runtime;

        obj.setKind("System");

        try {
            currentWorkingDirectory = new File(".").getCanonicalPath();
        } catch(Exception e) {
            currentWorkingDirectory = ".";
        }

        obj.registerMethod(new JavaMethod(runtime, "currentFile", "returns the current file executing") {
                public IokeObject activate(IokeObject context, Message message, IokeObject on) throws ControlFlow {
                    return new Text(runtime, ((IokeSystem)on.data).currentFile.get(0));
                }
            });

        obj.registerMethod(new JavaMethod(runtime, "ifMain", "returns result of evaluating first argument") {
                public IokeObject activate(IokeObject context, Message message, IokeObject on) throws ControlFlow {
                    if(((IokeSystem)on.data).currentProgram().equals(message.getFile())) {
                        return ((Message)message.getArguments().get(0)).evaluateCompleteWith(context, context.getRealContext());
                    } else {
                        return runtime.nil;
                    }
                }
            });
    }

    public String toString() {
        return "System";
    }
}// IokeSystem
