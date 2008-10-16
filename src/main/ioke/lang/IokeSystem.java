/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.io.File;

import java.util.Arrays;
import java.util.ArrayList;
import java.util.List;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class IokeSystem extends IokeObject {
    private List<String> currentFile = new ArrayList<String>(Arrays.asList("<init>"));
    private String currentProgram;
    private String currentWorkingDirectory;


    IokeSystem(Runtime runtime, String documentation) {
        super(runtime, documentation);
    }
    
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
        Builtin b = runtime.getBuiltin(name);
        if(b != null) {
            b.load(runtime, context, message);
            return true;
        }

//         System.err.println("use(" + context + "," + message + "," + name + ")");
        for(String suffix : SUFFIXES) {
//             System.err.println("- suffix: " + suffix);
            File f = new File(currentWorkingDirectory, name + suffix);
//             System.err.println("- gah: " + f);
            if(f.exists()) {
//                 System.err.println("- IT EXISTS");
                runtime.evaluateFile(f);
                return true;
            }
        }
        // TODO: raise condition here...
        return false;
    }

    public void init() {
        try {
            currentWorkingDirectory = new File(".").getCanonicalPath();
        } catch(Exception e) {
            currentWorkingDirectory = ".";
        }

        registerMethod(new JavaMethod(runtime, "currentFile", "returns the current file executing") {
                public IokeObject activate(IokeObject context, Message message, IokeObject on) throws ControlFlow {
                    return new Text(runtime, currentFile.get(0));
                }
            });

        registerMethod(new JavaMethod(runtime, "ifMain", "returns result of evaluating first argument") {
                public IokeObject activate(IokeObject context, Message message, IokeObject on) throws ControlFlow {
                    if(currentProgram().equals(message.getFile())) {
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
