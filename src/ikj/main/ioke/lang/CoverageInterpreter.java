/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.io.Reader;
import java.io.StringReader;

import java.util.Arrays;
import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;

import ioke.lang.parser.IokeParser;

import ioke.lang.exceptions.ControlFlow;

/**
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class CoverageInterpreter extends Interpreter {
    private static class CoveragePoint {
        String filename;
        String name;
        int line;
        int pos;
        int posEnd;
        IokeObject message;

        int count = 0;

        public String toString() {
            return "CoveragePoint<" + filename + ":" + line + ":" + pos + " - " + name + "(" + count + ")>";
        }
    }

    public final Map<String, Map<Integer, Map<Integer, CoveragePoint>>> covered = new HashMap<String, Map<Integer, Map<Integer, CoveragePoint>>>();

    private boolean covering = true;

    public void stopCovering() {
        covering = false;
    }

    public IokeObject iokefiedCoverageData(Runtime runtime) {
        try {
            IokeObject coveragePoint = runtime.newFromOrigin();
            coveragePoint.setKind("CoveragePoint");
            Map<Object, Object> d = new HashMap<Object, Object>();
            IokeObject result = runtime.newDict(d);
            for(Map.Entry<String, Map<Integer, Map<Integer, CoveragePoint>>> me : covered.entrySet()) {
                IokeObject k = runtime.newText(me.getKey());
                Object val = d.get(k);
                if(val == null) {
                    val = runtime.newDict(new HashMap<Object, Object>());
                    d.put(k, val);
                }
            
                Map<Object, Object> lineToPos = Dict.getMap(val);
            
                for(Map.Entry<Integer, Map<Integer, CoveragePoint>> me2 : me.getValue().entrySet()) {
                    IokeObject k2 = runtime.newNumber(me2.getKey());
                    Object val2 = lineToPos.get(k2);
                    if(val2 == null) {
                        val2 = runtime.newDict(new HashMap<Object, Object>());
                        lineToPos.put(k2, val2);
                    }
            
                    Map<Object, Object> posToCoveragePoint = Dict.getMap(val2);
                    for(Map.Entry<Integer, CoveragePoint> me3 : me2.getValue().entrySet()) {
                        IokeObject k3 = runtime.newNumber(me3.getKey());
                        IokeObject v3 = coveragePoint.mimic(null, null);
                        v3.setCell("filename", runtime.newText(me3.getValue().filename));
                        v3.setCell("name", runtime.newText(me3.getValue().name));
                        v3.setCell("line", runtime.newNumber(me3.getValue().line));
                        v3.setCell("pos", runtime.newNumber(me3.getValue().pos));
                        v3.setCell("posEnd", runtime.newNumber(me3.getValue().posEnd));
                        v3.setCell("message", me3.getValue().message);
                        v3.setCell("count", runtime.newNumber(me3.getValue().count));
                        posToCoveragePoint.put(k3, v3);
                    }                
                }
            }
            return result;
        } catch(ControlFlow e) {
            return null;
        }
    }

    private void cover(IokeObject message) throws ControlFlow {
        if(covering) {
            CoveragePoint cp = new CoveragePoint();
            cp.filename = Message.file(message);
            cp.name = Message.name(message);
            cp.line = Message.line(message);
            cp.pos = Message.position(message);
            cp.posEnd = Message.positionEnd(message);
            cp.message = message;

            Map<Integer, Map<Integer, CoveragePoint>> perLine = covered.get(cp.filename);
            if(perLine == null) {
                perLine = new HashMap<Integer, Map<Integer, CoveragePoint>>();
                covered.put(cp.filename, perLine);
            }

            Map<Integer, CoveragePoint> perPos = perLine.get(cp.line);
            if(perPos == null) {
                perPos = new HashMap<Integer, CoveragePoint>();
                perLine.put(cp.line, perPos);
            }

            CoveragePoint cp2 = perPos.get(cp.pos);
            if(cp2 == null) {
                cp2 = cp;
                perPos.put(cp.pos, cp2);
            }
            cp2.count++;
        }
    }

    @Override
    public Object evaluate(IokeObject self, IokeObject ctx, Object ground, Object receiver) throws ControlFlow {
        Runtime runtime = self.runtime;
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
