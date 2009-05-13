/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import ioke.lang.exceptions.ControlFlow;

import java.util.ArrayList;
import java.util.List;

public class Rewriter {
    private Runtime runtime;
    private IokeObject context;
    private IokeObject message;

    public Rewriter(IokeObject context, IokeObject message) {
        this.context = context;
        this.message = message;
        this.runtime = context.runtime;
    }

    public Object rewrite(Object inputMessage, List<Object> patterns) {
        return inputMessage;
    }
}
