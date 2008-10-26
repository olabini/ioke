/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.io.InputStream;
import java.io.InputStreamReader;
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

    public boolean use(IokeObject context, IokeObject message, String name) throws ControlFlow {
        Builtin b = context.runtime.getBuiltin(name);
        if(b != null) {
            b.load(context.runtime, context, message);
            return true;
        }

        for(String suffix : SUFFIXES) {
            String before = "/";
            if(name.startsWith("/")) {
                before = "";
            }

            InputStream is = IokeSystem.class.getResourceAsStream(before + name + suffix);
            if(null != is) {
                context.runtime.evaluateStream(name+suffix, new InputStreamReader(is));
                return true;
            }

            File f = new File(currentWorkingDirectory, name + suffix);
            if(f.exists()) {
                context.runtime.evaluateFile(f);
                return true;
            }
        }
        // TODO: raise condition here...
        throw new IokeException(message, "Couldn't find module '" + name + "' to load", context, context);
    }
    
    public IokeData cloneData(IokeObject obj, IokeObject m, IokeObject context) {
        return new IokeSystem();
    }

    public void init(IokeObject obj) {
        final Runtime runtime = obj.runtime;

        obj.setKind("System");

        try {
            currentWorkingDirectory = new File(".").getCanonicalPath();
        } catch(Exception e) {
            currentWorkingDirectory = ".";
        }

        obj.registerMethod(runtime.newJavaMethod("returns the current file executing", new JavaMethod("currentFile") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    return runtime.newText(((IokeSystem)IokeObject.data(on)).currentFile.get(0));
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
