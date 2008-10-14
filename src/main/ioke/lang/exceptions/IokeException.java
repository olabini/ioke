/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang.exceptions;

import java.io.PrintStream;

import java.util.ArrayList;
import java.util.List;

import ioke.lang.Context;
import ioke.lang.Message;
import ioke.lang.IokeObject;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class IokeException extends RuntimeException {
    Message message;
    IokeObject on;
    IokeObject context;
    public IokeException(Message m, IokeObject on, IokeObject context) {
        super();
        this.message = m;
        this.on = on;
        this.context = context;
    }

    public IokeException(Message m, String message, IokeObject on, IokeObject context) {
        super(message);
        this.message = m;
        this.on = on;
        this.context = context;
    }

    public IokeException(Message m, Throwable cause, IokeObject on, IokeObject context) {
        super(cause);
        this.message = m;
        this.on = on;
        this.context = context;
    }

    public IokeException(Message m, String message, Throwable cause, IokeObject on, IokeObject context) {
        super(message, cause);
        this.message = m;
        this.on = on;
        this.context = context;
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
        String s1 = start.codeSequenceTo(";");
        int ix = s1.indexOf("\n");
        stream.println("  " + (ix == -1 ? s1 : s1.substring(0,ix)));
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

        s1 = message.thisCode();
        ix = s1.indexOf("\n");

        stream.println(String.format("  %-48.48s %s", on.toString() + " " + (ix == -1 ? s1 : s1.substring(0,ix)),"[" + message.getFile() + ":" + message.getLine() + ":" + message.getPosition() + getContextMessageName(context) + "]"));

        IokeObject ctx = context;
        while(ctx instanceof Context) {
            s1 = ((Context)ctx).message.thisCode();
            ix = s1.indexOf("\n");
            stream.println(String.format("  %-48.48s %s", ((Context)ctx).getRealContext().toString() + " " +  (ix == -1 ? s1 : s1.substring(0,ix)),"[" + ((Context)ctx).message.getFile() + ":" + ((Context)ctx).message.getLine() + ":" + ((Context)ctx).message.getPosition()  + getContextMessageName(((Context)ctx).surroundingContext) + "]"));
            ctx = ((Context)ctx).surroundingContext;
        }
        stream.println();
    }

    private String getContextMessageName(IokeObject ctx) {
        if(ctx instanceof Context) {
            return ":in `" + ((Context)ctx).message.getName() + "'";
        } else {
            return "";
        }
    }

    public String toString() {
        return "[" + message.getFile() + ":" + message.getLine() + ":" + message.getPosition() + "] " + getMessage();
    }
}// IokeException
