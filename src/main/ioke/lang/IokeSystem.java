/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

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

    public void init() {
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
