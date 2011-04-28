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

import ioke.lang.parser.IokeParser;

import ioke.lang.exceptions.ControlFlow;

/**
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Interpreter {
    public Object evaluateComplete(IokeObject self) throws ControlFlow {
        IokeObject ctx = self.runtime.ground;
        Object current = ctx;
        Object tmp = null;
        Object lastReal = self.runtime.getNil();
        IokeObject m = self;
        while(m != null) {
            String name = m.getName();

            if(name.equals(".")) {
                current = ctx;
            } else if(name.length() > 0 && m.getArguments().size() == 0 && name.charAt(0) == ':') {
                current = self.runtime.getSymbol(name.substring(1));
                Message.cacheValue(m, current);
                lastReal = current;
            } else {
                tmp = sendTo(m, ctx, current);
                if(tmp != null) {
                    current = tmp;
                    lastReal = current;
                }
            }
            m = Message.next(m);
        }
        return lastReal;
    }

    public Object evaluateCompleteWith(IokeObject self, IokeObject ctx, Object ground) throws ControlFlow {
        Object current = ctx;
        Object tmp = null;
        Object lastReal = self.runtime.getNil();
        IokeObject m = self;
        while(m != null) {
            String name = m.getName();

            if(name.equals(".")) {
                current = ctx;
            } else if(name.length() > 0 && m.getArguments().size() == 0 && name.charAt(0) == ':') {
                current = self.runtime.getSymbol(name.substring(1));
                Message.cacheValue(m, current);
                lastReal = current;
            } else {
                tmp = sendTo(m, ctx, current);
                if(tmp != null) {
                    current = tmp;
                    lastReal = current;
                }
            }
            m = Message.next(m);
        }
        return lastReal;
    }

    public Object evaluateCompleteWithReceiver(IokeObject self, IokeObject ctx, Object ground, Object receiver) throws ControlFlow {
        Object current = receiver;
        Object tmp = null;
        Object lastReal = self.runtime.getNil();
        IokeObject m = self;
        while(m != null) {
            String name = m.getName();

            if(name.equals(".")) {
                current = ctx;
            } else if(name.length() > 0 && m.getArguments().size() == 0 && name.charAt(0) == ':') {
                current = self.runtime.getSymbol(name.substring(1));
                Message.cacheValue(m, current);
                lastReal = current;
            } else {
                tmp = sendTo(m, ctx, current);
                if(tmp != null) {
                    current = tmp;
                    lastReal = current;
                }
            }
            m = Message.next(m);
        }
        return lastReal;
    }

    public Object evaluateCompleteWithoutExplicitReceiver(IokeObject self, IokeObject ctx, Object ground) throws ControlFlow {
        Object current = ctx;
        Object tmp = null;
        Object lastReal = self.runtime.getNil();
        IokeObject m = self;
        while(m != null) {
            String name = m.getName();

            if(name.equals(".")) {
                current = ctx;
            } else if(name.length() > 0 && m.getArguments().size() == 0 && name.charAt(0) == ':') {
                current = self.runtime.getSymbol(name.substring(1));
                Message.cacheValue(m, current);
                lastReal = current;
            } else {
                tmp = sendTo(m, ctx, current);
                if(tmp != null) {
                    current = tmp;
                    lastReal = current;
                }
            }
            m = Message.next(m);
        }
        return lastReal;
    }

    public Object evaluateCompleteWith(IokeObject self, Object ground) throws ControlFlow {
        IokeObject ctx = IokeObject.as(ground, self);
        Object current = ctx;
        Object tmp = null;
        Object lastReal = self.runtime.getNil();
        IokeObject m = self;
        while(m != null) {
            String name = m.getName();

            if(name.equals(".")) {
                current = ctx;
            } else if(name.length() > 0 && m.getArguments().size() == 0 && name.charAt(0) == ':') {
                current = self.runtime.getSymbol(name.substring(1));
                Message.cacheValue(m, current);
                lastReal = current;
            } else {
                tmp = sendTo(m, ctx, current);
                if(tmp != null) {
                    current = tmp;
                    lastReal = current;
                }
            }
            m = Message.next(m);
        }
        return lastReal;
    }










    public Object sendTo(IokeObject self, IokeObject context, Object recv) throws ControlFlow {
        if(((Message)IokeObject.data(self)).cached != null) {
            return ((Message)IokeObject.data(self)).cached;
        }

        return IokeObject.perform(recv, context, self);
    }

    public Object sendTo(IokeObject self, IokeObject context, Object recv, Object argument) throws ControlFlow {
        if(((Message)IokeObject.data(self)).cached != null) {
            return ((Message)IokeObject.data(self)).cached;
        }

        IokeObject m = self.allocateCopy(self, context);
        m.mimicsWithoutCheck(context.runtime.message);
        m.getArguments().clear();
        m.getArguments().add(argument);
        return IokeObject.perform(recv, context, m);
    }

    public Object sendTo(IokeObject self, IokeObject context, Object recv, Object arg1, Object arg2) throws ControlFlow {
        if(((Message)IokeObject.data(self)).cached != null) {
            return ((Message)IokeObject.data(self)).cached;
        }

        IokeObject m = self.allocateCopy(self, context);
        m.getArguments().clear();
        m.getArguments().add(arg1);
        m.getArguments().add(arg2);
        return IokeObject.perform(recv, context, m);
    }

    public Object sendTo(IokeObject self, IokeObject context, Object recv, Object arg1, Object arg2, Object arg3) throws ControlFlow {
        if(((Message)IokeObject.data(self)).cached != null) {
            return ((Message)IokeObject.data(self)).cached;
        }

        IokeObject m = self.allocateCopy(self, context);
        m.getArguments().clear();
        m.getArguments().add(arg1);
        m.getArguments().add(arg2);
        m.getArguments().add(arg3);
        return IokeObject.perform(recv, context, m);
    }

    public Object sendTo(IokeObject self, IokeObject context, Object recv, List<Object> args) throws ControlFlow {
        if(((Message)IokeObject.data(self)).cached != null) {
            return ((Message)IokeObject.data(self)).cached;
        }

        IokeObject m = self.allocateCopy(self, context);
        m.getArguments().clear();
        m.getArguments().addAll(args);
        return IokeObject.perform(recv, context, m);
    }
}
