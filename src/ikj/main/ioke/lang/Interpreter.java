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
            msg = (Message)IokeObject.data(m);
            tmp = msg.cached;
            if(tmp != null) {
                lastReal = current = tmp;
            } else if((name = msg.name.intern()) == ".") {
                current = ctx;
            } else if(name.length() > 0 && msg.arguments.size() == 0 && name.charAt(0) == ':') {
                lastReal = msg.cached = current = self.runtime.getSymbol(name.substring(1));
            } else {
                if((current instanceof IokeObject) || IokeRegistry.isWrapped(current, ctx)) {
                    tmp = perform(IokeObject.as(current, ctx), ctx, m, name);
                } else {
                    tmp = performJava(current, ctx, m);
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
        if((result = ((Message)IokeObject.data(self)).cached) != null) {
            return result;
        }

        return perform(recv, context, self);
    }

    public static Object send(IokeObject self, IokeObject context, Object recv, Object argument) throws ControlFlow {
        Object result;
        if((result = ((Message)IokeObject.data(self)).cached) != null) {
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
        if((result = ((Message)IokeObject.data(self)).cached) != null) {
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
        if((result = ((Message)IokeObject.data(self)).cached) != null) {
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
        if((result = ((Message)IokeObject.data(self)).cached) != null) {
            return result;
        }

        IokeObject m = self.allocateCopy(self, context);
        m.getArguments().clear();
        m.getArguments().addAll(args);
        return perform(recv, context, m);
    }




















    public static Object perform(Object obj, IokeObject ctx, IokeObject message) throws ControlFlow {
        if((obj instanceof IokeObject) || IokeRegistry.isWrapped(obj, ctx)) {
            return perform(IokeObject.as(obj, ctx), ctx, message, message.getName());
        } else {
            return performJava(obj, ctx, message);
        }
    }

    public static Object perform(IokeObject obj, IokeObject ctx, IokeObject message) throws ControlFlow {
        return perform(obj, ctx, message, message.getName());
    }

    private static Object performJava(Object obj, IokeObject ctx, IokeObject message) throws ControlFlow {
        final IokeObject clz = IokeRegistry.wrap(obj.getClass(), ctx);
        final Runtime runtime = ctx.runtime;
        final String name = message.getName();
        final String outerName = name;
        Object cell = clz.findCell(message, ctx, name);
        Object passed = null;

        while(cell == runtime.nul && (((cell = passed = clz.findCell(message, ctx, "pass")) == runtime.nul) ||  !isApplicable(passed, message, ctx))) {
            final IokeObject condition = IokeObject.as(IokeObject.getCellChain(runtime.condition,
                                                                               message,
                                                                               ctx,
                                                                               "Error",
                                                                               "NoSuchCell"), ctx).mimic(message, ctx);
            condition.setCell("message", message);
            condition.setCell("context", ctx);
            condition.setCell("receiver", obj);
            condition.setCell("cellName", runtime.getSymbol(name));

            final Object[] newCell = new Object[]{cell};

            runtime.withRestartReturningArguments(new RunnableWithControlFlow() {
                    public void run() throws ControlFlow {
                        runtime.errorCondition(condition);
                    }},
                ctx,
                new Restart.ArgumentGivingRestart("useValue") {
                    public String report() {
                        return "Use value for: " + outerName;
                    }

                    public List<String> getArgumentNames() {
                        return new ArrayList<String>(Arrays.asList("newValue"));
                    }

                    public IokeObject invoke(IokeObject context, List<Object> arguments) throws ControlFlow {
                        newCell[0] = arguments.get(0);
                        return context.runtime.nil;
                    }
                },
                new Restart.ArgumentGivingRestart("storeValue") {
                    public String report() {
                        return "Store value for: " + outerName;
                    }

                    public List<String> getArgumentNames() {
                        return new ArrayList<String>(Arrays.asList("newValue"));
                    }

                    public IokeObject invoke(IokeObject context, List<Object> arguments) throws ControlFlow {
                        newCell[0] = arguments.get(0);
                        clz.setCell(outerName, newCell[0]);
                        return context.runtime.nil;
                    }
                }
                );

            cell = newCell[0];
        }

        return getOrActivate(cell, ctx, message, obj);
    }

    private static boolean isApplicable(Object pass, IokeObject message, IokeObject ctx) throws ControlFlow {
        if(pass != null && pass != ctx.runtime.nul && IokeObject.as(pass, ctx).findCell(message, ctx, "applicable?") != ctx.runtime.nul) {
            return IokeObject.isTrue(Interpreter.send(ctx.runtime.isApplicableMessage, ctx, pass, ctx.runtime.createMessage(Message.wrap(message))));
        }
        return true;
    }

    public static Object perform(final IokeObject recv, IokeObject ctx, IokeObject message, final String name) throws ControlFlow {
        final String outerName = name;
        final Runtime runtime = recv.runtime;
        Object cell = recv.findCell(message, ctx, name);
        Object passed = null;

        while(cell == runtime.nul && (((cell = passed = recv.findCell(message, ctx, "pass")) == runtime.nul) || !isApplicable(passed, message, ctx))) {
            final IokeObject condition = IokeObject.as(IokeObject.getCellChain(runtime.condition,
                                                                               message,
                                                                               ctx,
                                                                               "Error",
                                                                               "NoSuchCell"), ctx).mimic(message, ctx);
            condition.setCell("message", message);
            condition.setCell("context", ctx);
            condition.setCell("receiver", recv);
            condition.setCell("cellName", runtime.getSymbol(name));

            final Object[] newCell = new Object[]{cell};

            runtime.withRestartReturningArguments(new RunnableWithControlFlow() {
                    public void run() throws ControlFlow {
                        runtime.errorCondition(condition);
                    }},
                ctx,
                new Restart.ArgumentGivingRestart("useValue") {
                    public String report() {
                        return "Use value for: " + outerName;
                    }

                    public List<String> getArgumentNames() {
                        return new ArrayList<String>(Arrays.asList("newValue"));
                    }

                    public IokeObject invoke(IokeObject context, List<Object> arguments) throws ControlFlow {
                        newCell[0] = arguments.get(0);
                        return context.runtime.nil;
                    }
                },
                new Restart.ArgumentGivingRestart("storeValue") {
                    public String report() {
                        return "Store value for: " + outerName;
                    }

                    public List<String> getArgumentNames() {
                        return new ArrayList<String>(Arrays.asList("newValue"));
                    }

                    public IokeObject invoke(IokeObject context, List<Object> arguments) throws ControlFlow {
                        newCell[0] = arguments.get(0);
                        recv.setCell(outerName, newCell[0]);
                        return context.runtime.nil;
                    }
                }
                );

            cell = newCell[0];
        }

        return getOrActivate(cell, ctx, message, recv);
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
