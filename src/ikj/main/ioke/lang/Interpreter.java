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
    public Object evaluate(IokeObject self, IokeObject ctx, Object ground, Object receiver) throws ControlFlow {
        Object current = receiver;
        Object tmp = null;
        String name = null;
        Object lastReal = self.runtime.getNil();
        IokeObject m = self;
        Message msg;
        while(m != null) {
            msg = (Message)m.data;
            tmp = msg.cached;
            if(tmp != null) {
                lastReal = current = tmp;
            } else if((name = msg.name.intern()) == ".") {
                current = ctx;
            } else if(name.length() > 0 && msg.arguments.size() == 0 && name.charAt(0) == ':') {
                lastReal = msg.cached = current = self.runtime.getSymbol(name.substring(1));
            } else {
                if((current instanceof IokeObject) || IokeRegistry.isWrapped(current, ctx)) {
                    IokeObject recv = IokeObject.as(current, ctx);
                    tmp = perform(recv, recv, ctx, m, name);
                } else {
                    tmp = perform(current, IokeRegistry.wrap(current.getClass(), ctx), ctx, m, name);
                }

                if(tmp != null) {
                    current = tmp;
                    lastReal = current;
                }
            }
            m = Message.next(m);
        }
        return lastReal;
    }






    public static Object getEvaluatedArgument(Object argument, IokeObject context) throws ControlFlow {
        if(!(argument instanceof IokeObject)) {
            return argument;
        }

        IokeObject o = IokeObject.as(argument, context);
        if(!o.isMessage()) {
            return o;
        }

        return context.runtime.interpreter.evaluate(o, context, context.getRealContext(), context);
    }

    public static Object getEvaluatedArgument(IokeObject self, int index, IokeObject context) throws ControlFlow {
        return getEvaluatedArgument(self.getArguments().get(index), context);
    }

    public static List<Object> getEvaluatedArguments(IokeObject self, IokeObject context) throws ControlFlow {
        List<Object> arguments = self.getArguments();
        List<Object> args = new ArrayList<Object>(arguments.size());
        for(Object o : arguments) {
            args.add(getEvaluatedArgument(o, context));
        }
        return args;
    }









    public static Object send(IokeObject self, IokeObject context, Object recv) throws ControlFlow {
        Object result;
        if((result = ((Message)self.data).cached) != null) {
            return result;
        }

        return perform(recv, context, self);
    }

    public static Object send(IokeObject self, IokeObject context, Object recv, Object argument) throws ControlFlow {
        Object result;
        if((result = ((Message)self.data).cached) != null) {
            return result;
        }

        IokeObject m = self.allocateCopy(self, context);
        m.mimicsWithoutCheck(context.runtime.message);
        m.getArguments().clear();
        m.getArguments().add(argument);
        return perform(recv, context, m);
    }

    public static Object send(IokeObject self, IokeObject context, Object recv, Object arg1, Object arg2) throws ControlFlow {
        Object result;
        if((result = ((Message)self.data).cached) != null) {
            return result;
        }

        IokeObject m = self.allocateCopy(self, context);
        m.getArguments().clear();
        m.getArguments().add(arg1);
        m.getArguments().add(arg2);
        return perform(recv, context, m);
    }

    public static Object send(IokeObject self, IokeObject context, Object recv, Object arg1, Object arg2, Object arg3) throws ControlFlow {
        Object result;
        if((result = ((Message)self.data).cached) != null) {
            return result;
        }

        IokeObject m = self.allocateCopy(self, context);
        m.getArguments().clear();
        m.getArguments().add(arg1);
        m.getArguments().add(arg2);
        m.getArguments().add(arg3);
        return perform(recv, context, m);
    }

    public static Object send(IokeObject self, IokeObject context, Object recv, List<Object> args) throws ControlFlow {
        Object result;
        if((result = ((Message)self.data).cached) != null) {
            return result;
        }

        IokeObject m = self.allocateCopy(self, context);
        m.getArguments().clear();
        m.getArguments().addAll(args);
        return perform(recv, context, m);
    }




















    public static Object perform(Object obj, IokeObject ctx, IokeObject message) throws ControlFlow {
        if((obj instanceof IokeObject) || IokeRegistry.isWrapped(obj, ctx)) {
            IokeObject recv = IokeObject.as(obj, ctx);
            return perform(recv, recv, ctx, message, message.getName());
        } else {
            return perform(obj, IokeRegistry.wrap(obj.getClass(), ctx), ctx, message, message.getName());
        }
    }

    private static Object signalNoSuchCell(IokeObject message, IokeObject ctx, Object obj, String name, Object cell, IokeObject recv) throws ControlFlow {
        Runtime runtime = ctx.runtime;
        final IokeObject condition = IokeObject.as(IokeObject.getCellChain(runtime.condition,
                                                                           message,
                                                                           ctx,
                                                                           "Error",
                                                                           "NoSuchCell"), ctx).mimic(message, ctx);
        condition.setCell("message", message);
        condition.setCell("context", ctx);
        condition.setCell("receiver", obj);
        condition.setCell("cellName", runtime.getSymbol(name));
     
        Object[] newCell = new Object[]{cell};
        runtime.withRestartReturningArguments(new ErrorConditionRunnable(runtime, condition), ctx, new UseValueRestart(name, newCell), new StoreValueRestart(name, newCell, recv));
        return newCell[0];
    }

    public static Object perform(Object obj, IokeObject recv, IokeObject ctx, IokeObject message, String name) throws ControlFlow {
        Runtime runtime = ctx.runtime;
        Object cell = recv.findCell(message, ctx, name);
        Object passed = null;

        while(cell == runtime.nul && (((cell = passed = recv.findCell(message, ctx, "pass")) == runtime.nul) ||  !isApplicable(passed, message, ctx))) {
            cell = signalNoSuchCell(message, ctx, obj, name, cell, recv);
        }

        return getOrActivate(cell, ctx, message, obj);
    }

    private static boolean isApplicable(Object pass, IokeObject message, IokeObject ctx) throws ControlFlow {
        if(pass != null && pass != ctx.runtime.nul && IokeObject.as(pass, ctx).findCell(message, ctx, "applicable?") != ctx.runtime.nul) {
            return IokeObject.isTrue(Interpreter.send(ctx.runtime.isApplicableMessage, ctx, pass, ctx.runtime.createMessage(Message.wrap(message))));
        }
        return true;
    }

    public static Object getOrActivate(Object obj, IokeObject context, IokeObject message, Object on) throws ControlFlow {
        if(obj instanceof IokeObject) {
            IokeObject io = (IokeObject)obj;
            if(io.isActivatable() || ((io.data instanceof CanRun) && message.getArguments().size() > 0)) {
                return io.data.activate(io, context, message, on);
            } else {
                return io;
            }
        } else {
            return obj;
        }
    }

    public static Object activate(IokeObject receiver, IokeObject context, IokeObject message, Object on) throws ControlFlow {
        return receiver.data.activate(receiver, context, message, on);
    }

    public static Object activateWithData(IokeObject receiver, IokeObject context, IokeObject message, Object on, Map<String, Object> d1) throws ControlFlow {
        return receiver.data.activateWithData(receiver, context, message, on, d1);
    }

    public static Object activateWithCallAndData(IokeObject receiver, IokeObject context, IokeObject message, Object on, Object c, Map<String, Object> d1) throws ControlFlow {
        return receiver.data.activateWithCallAndData(receiver, context, message, on, c, d1);
    }
}
