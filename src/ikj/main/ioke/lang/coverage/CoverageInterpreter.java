/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang.coverage;

import java.io.Reader;
import java.io.StringReader;

import java.util.Arrays;
import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;

import ioke.lang.*;

import ioke.lang.parser.IokeParser;

import ioke.lang.exceptions.ControlFlow;

/**
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class CoverageInterpreter extends Interpreter {
    public static class CoveragePoint {
        String filename;
        String name;
        int line;
        int pos;
        IokeObject message;

        public int count = 0;

        public String toString() {
            return "CoveragePoint<" + filename + ":" + line + ":" + pos + " - " + name + "(" + count + ")>";
        }
    }

    public final Map<String, Map<String, CoveragePoint>> covered = new HashMap<String, Map<String, CoveragePoint>>();

    private boolean covering = true;

    public void stopCovering() {
        covering = false;
    }

    private void cover(IokeObject message) throws ControlFlow {
        if(covering) {
            CoveragePoint cp = new CoveragePoint();
            cp.filename = Message.file(message);
            cp.name = Message.name(message);
            cp.line = Message.line(message);
            cp.pos = Message.position(message);
            cp.message = message;

            Map<String, CoveragePoint> perLinePos = covered.get(cp.filename);
            if(perLinePos == null) {
                perLinePos = new HashMap<String, CoveragePoint>();
                covered.put(cp.filename, perLinePos);
            }

            CoveragePoint cp2 = perLinePos.get("" + cp.line + ":" + cp.pos);
            if(cp2 == null) {
                cp2 = cp;
                perLinePos.put("" + cp.line + ":" + cp.pos, cp2);
            }
            cp2.count++;
        }
    }

    @Override
    public Object evaluate(IokeObject self, IokeObject ctx, Object ground, Object receiver) throws ControlFlow {
        ioke.lang.Runtime runtime = self.runtime;
        Object current = receiver;
        Object tmp = null;
        String name = null;
        Object lastReal = runtime.getNil();
        IokeObject m = self;
        Message msg;
        while(m != null) {
            msg = (Message)m.data;
            tmp = msg.cached;
            cover(m);
            if(tmp != null) {
                lastReal = current = tmp;
            } else if((name = msg.name.intern()) == ".") {
                current = ctx;
            } else if(name.length() > 0 && msg.arguments.size() == 0 && name.charAt(0) == ':') {
                lastReal = msg.cached = current = runtime.getSymbol(name.substring(1));
            } else {
                if((current instanceof IokeObject) || IokeRegistry.isWrapped(current, ctx)) {
                    IokeObject recv = IokeObject.as(current, ctx);
                    tmp = perform(recv, recv, ctx, m, name);
                } else {
                    tmp = perform(current, IokeRegistry.wrap(current.getClass(), ctx), ctx, m, name);
                }

                lastReal = current = tmp;
            }
            m = Message.next(m);
        }
        return lastReal;
    }
}// CoverageInterpreter
