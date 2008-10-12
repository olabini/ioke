/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang.exceptions;

import java.util.ArrayList;
import java.util.List;

import ioke.lang.Message;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class IokeException extends RuntimeException {
    Message message;
    public IokeException(Message m) {
        super();
        this.message = m;
    }

    public IokeException(Message m, String message) {
        super(message);
        this.message = m;
    }

    public IokeException(Message m, Throwable cause) {
        super(cause);
        this.message = m;
    }

    public IokeException(Message m, String message, Throwable cause) {
        super(message, cause);
        this.message = m;
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

    public String toString() {
        return "[" + message.getFile() + ":" + message.getLine() + ":" + message.getPosition() + "] " + getMessage();
    }
}// IokeException
