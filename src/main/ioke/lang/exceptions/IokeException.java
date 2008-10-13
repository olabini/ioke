/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang.exceptions;

import java.io.PrintStream;

import java.util.ArrayList;
import java.util.List;

import ioke.lang.Message;
import ioke.lang.IokeObject;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class IokeException extends RuntimeException {
    Message message;
    IokeObject on;
    public IokeException(Message m, IokeObject on) {
        super();
        this.message = m;
        this.on = on;
    }

    public IokeException(Message m, String message, IokeObject on) {
        super(message);
        this.message = m;
        this.on = on;
    }

    public IokeException(Message m, Throwable cause, IokeObject on) {
        super(cause);
        this.message = m;
        this.on = on;
    }

    public IokeException(Message m, String message, Throwable cause, IokeObject on) {
        super(message, cause);
        this.message = m;
        this.on = on;
    }

    public StackTraceElement[] getStackTrace() {
        StackTraceElement[] trace = super.getStackTrace();
        
        List<StackTraceElement> stes = new ArrayList<StackTraceElement>();
        for(StackTraceElement ste : trace) {
            stes.add(ste);
            if(ste.getClassName().equals("ioke.lang.Runtime") && ste.getMethodName().equals("evaluateStream")) {
                break;
            }
        }
        return stes.toArray(new StackTraceElement[0]);
    }

    public void reportError(PrintStream stream) {
        Message start = message;

        while(start.prev != null && start.prev.getLine() == message.getLine()) {
            start = start.prev;
        }

//         System.err.println("for message : " + message);
//         System.err.println(" found start: " + start);

        stream.println();
        stream.println("  Exception: " + getMessage());
        stream.println("  ---------");
        stream.println("  " + start.codeSequenceTo(";"));
        stream.print("  ");

        int position = start.codePositionOf(message);

        for(int i=0,j=position;i<j;i++) {
            stream.print(" ");
        }
        for(int i=0,j=message.getName().length();i<j;i++) {
            stream.print("^");
        }
        stream.println();
        stream.println();
        stream.println(String.format("  %-48.48s %s", on.toString() + " " + message.thisCode(),"[" + message.getFile() + ":" + message.getLine() + ":" + message.getPosition() + "]"));
        stream.println();
    }

    public String toString() {
        return "[" + message.getFile() + ":" + message.getLine() + ":" + message.getPosition() + "] " + getMessage();
    }
}// IokeException
