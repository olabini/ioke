/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.ArrayList;
import java.util.List;
import java.util.HashMap;
import java.util.Map;
import java.util.Iterator;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Range extends IokeData {
    private IokeObject from;
    private IokeObject to;
    private boolean inclusive;
    private boolean inverted = false;

    public Range(IokeObject from, IokeObject to, boolean inclusive, boolean inverted) {
        this.from = from;
        this.to = to;
        this.inclusive = inclusive;
        this.inverted = inverted;
    }

    public static IokeObject getFrom(Object range) {
        return ((Range)IokeObject.data(range)).getFrom();
    }

    public static IokeObject getTo(Object range) {
        return ((Range)IokeObject.data(range)).getTo();
    }

    public static boolean isInclusive(Object range) {
        return ((Range)IokeObject.data(range)).isInclusive();
    }

    public IokeObject getFrom() {
        return from;
    }

    public IokeObject getTo() {
        return to;
    }

    public boolean isInclusive() {
        return inclusive;
    }

    private static class RangeIterator implements Iterator<Object> {
        private IokeObject start;
        private IokeObject end;
        private final boolean inclusive;
        private IokeObject context;
        //        private IokeObject message;
        private IokeObject messageToSend;
        private final Runtime runtime;
        private boolean oneIteration = false;
        private boolean doLast = true;

        public RangeIterator(IokeObject start, IokeObject end, boolean inclusive, boolean inverted, IokeObject context, IokeObject message) {
            this.runtime = context.runtime;
            this.start = start;
            this.end = end;
            this.inclusive = inclusive;
            this.context = context;
            //            this.message = message;

            messageToSend = runtime.succ;
            if(inverted) {
                messageToSend = runtime.pred;
            }
        }

        public boolean hasNext() {
            try {
                boolean sameEndpoints = IokeObject.isTrue(Interpreter.send(runtime.eqMessage, context, start, end));
                boolean shouldGoOver = (doLast && inclusive);
                boolean sameStartPoint = sameEndpoints && inclusive && !oneIteration;
                return !sameEndpoints || shouldGoOver || sameStartPoint;
            } catch(ControlFlow cf) {}
            throw new RuntimeException("(TODO: fix) - got an error. =(");
        }

        public Object next() {
            IokeObject obj = start;
            try {
                if(!IokeObject.isTrue(Interpreter.send(runtime.eqMessage, context, start, end))) {
                    oneIteration = true;
                    start = (IokeObject)Interpreter.send(messageToSend, context, start);
                    doLast = true;
                    return obj;
                } else {
                    if(inclusive && doLast) {
                        doLast = false;
                        return obj;
                    }
                }
            } catch(ControlFlow cf) {}
            throw new RuntimeException("(TODO: fix) - iterating over end");
        }

        public void remove(){}
    }


    @Override
    public void init(IokeObject obj) throws ControlFlow {
        final Runtime runtime = obj.runtime;

        obj.setKind("Range");
        obj.mimics(IokeObject.as(runtime.mixins.getCell(null, null, "Sequenced"), null), runtime.nul, runtime.nul);

        obj.registerMethod(runtime.newNativeMethod("returns true if the left hand side range is equal to the right hand side range.", new TypeCheckingNativeMethod("==") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .receiverMustMimic(runtime.range)
                    .withRequiredPositional("other")
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject self, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());
                    Range d = (Range)IokeObject.data(on);
                    Object other = args.get(0);
                    return ((other instanceof IokeObject) &&
                            (IokeObject.data(other) instanceof Range)
                            && d.inclusive == ((Range)IokeObject.data(other)).inclusive
                            && d.from.equals(((Range)IokeObject.data(other)).from)
                            && d.to.equals(((Range)IokeObject.data(other)).to)) ? context.runtime._true : context.runtime._false;
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("will return a new inclusive Range based on the two arguments", new NativeMethod("inclusive") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("from")
                    .withRequiredPositional("to")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());

                    Object from = args.get(0);
                    Object to = args.get(1);

                    boolean comparing = IokeObject.isMimic(from, IokeObject.as(context.runtime.mixins.body.get("Comparing"), context), context);
                    boolean inverted = false;

                    if(comparing) {
                        Object result = Interpreter.send(context.runtime.spaceShip, context, from, to);
                        if(result != context.runtime.nil && Number.extractInt(result, message, context) == 1) {
                            inverted = true;
                        }
                    }

                    return runtime.newRange(IokeObject.as(from, context), IokeObject.as(to, context), true, inverted);
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("will return a new exclusive Range based on the two arguments", new NativeMethod("exclusive") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("from")
                    .withRequiredPositional("to")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());

                    Object from = args.get(0);
                    Object to = args.get(1);

                    boolean comparing = IokeObject.isMimic(from, IokeObject.as(context.runtime.mixins.body.get("Comparing"), context), context);
                    boolean inverted = false;
                    if(comparing) {
                        Object result = Interpreter.send(context.runtime.spaceShip, context, from, to);
                        if(result != context.runtime.nil && Number.extractInt(result, message, context) == 1) {
                            inverted = true;
                        }
                    }

                    return runtime.newRange(IokeObject.as(from, context), IokeObject.as(to, context), false, inverted);
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("returns true if the receiver is an exclusive range, false otherwise", new NativeMethod.WithNoArguments("exclusive?") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());
                    return ((Range)IokeObject.data(on)).inclusive ? context.runtime._false : context.runtime._true;
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("returns true if the receiver is an inclusive range, false otherwise", new NativeMethod.WithNoArguments("inclusive?") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());
                    return ((Range)IokeObject.data(on)).inclusive ? context.runtime._true : context.runtime._false;
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("returns the 'from' part of the range", new TypeCheckingNativeMethod.WithNoArguments("from", runtime.range) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());
                    return ((Range)IokeObject.data(on)).from;
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("returns the 'to' part of the range", new NativeMethod.WithNoArguments("to") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());
                    return ((Range)IokeObject.data(on)).to;
                }
            }));

        obj.registerMethod(obj.runtime.newNativeMethod("returns a new sequence to iterate over this range", new TypeCheckingNativeMethod.WithNoArguments("seq", runtime.range) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    IokeObject obj = method.runtime.iteratorSequence.allocateCopy(null, null);
                    obj.singleMimicsWithoutCheck(method.runtime.iteratorSequence);
                    Range r = ((Range)IokeObject.data(on));
                    RangeIterator ri = new RangeIterator(r.from, r.to, r.inclusive, r.inverted, context, message);
                    obj.setData(new Sequence.IteratorSequence(ri));
                    return obj;
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("takes either one or two or three arguments. if one argument is given, it should be a message chain that will be sent to each object in the range. the result will be thrown away. if two arguments are given, the first is an unevaluated name that will be set to each of the values in the range in succession, and then the second argument will be evaluated in a scope with that argument in it. if three arguments is given, the first one is an unevaluated name that will be set to the index of each element, and the other two arguments are the name of the argument for the value, and the actual code. the code will evaluate in a lexical context, and if the argument name is available outside the context, it will be shadowed. the method will return the range.", new NativeMethod("each") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withOptionalPositionalUnevaluated("indexOrArgOrCode")
                    .withOptionalPositionalUnevaluated("argOrCode")
                    .withOptionalPositionalUnevaluated("code")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().checkArgumentCount(context, message, on);

                    Runtime runtime = context.runtime;

                    IokeObject from = IokeObject.as(((Range)IokeObject.data(on)).from, context);
                    IokeObject to = IokeObject.as(((Range)IokeObject.data(on)).to, context);
                    boolean inclusive = ((Range)IokeObject.data(on)).inclusive;

                    IokeObject messageToSend = context.runtime.succ;
                    if(((Range)IokeObject.data(on)).inverted) {
                        messageToSend = context.runtime.pred;
                    }

                    switch(message.getArgumentCount()) {
                    case 0: {
                        return Interpreter.send(runtime.seqMessage, context, on);
                    }
                    case 1: {
                        IokeObject code = IokeObject.as(message.getArguments().get(0), context);

                        Object current = from;

                        while(!IokeObject.isTrue(Interpreter.send(context.runtime.eqMessage, context, current, to))) {
                            runtime.interpreter.evaluate(code, context, context.getRealContext(), current);
                            current = Interpreter.send(messageToSend, context, current);
                        }
                        if(inclusive) {
                            runtime.interpreter.evaluate(code, context, context.getRealContext(), current);
                        }

                        break;
                    }
                    case 2: {
                        IokeObject c = context.runtime.newLexicalContext(context, "Lexical activation context for Range#each", context);
                        String name = IokeObject.as(message.getArguments().get(0), context).getName();
                        IokeObject code = IokeObject.as(message.getArguments().get(1), context);

                        Object current = from;

                        while(!IokeObject.isTrue(Interpreter.send(context.runtime.eqMessage, context, current, to))) {
                            c.setCell(name, current);
                            runtime.interpreter.evaluate(code, c, c.getRealContext(), c);
                            current = Interpreter.send(messageToSend, context, current);
                        }
                        if(inclusive) {
                            c.setCell(name, current);
                            runtime.interpreter.evaluate(code, c, c.getRealContext(), c);
                        }

                        break;
                    }
                    case 3: {
                        IokeObject c = context.runtime.newLexicalContext(context, "Lexical activation context for Range#each", context);
                        String iname = IokeObject.as(message.getArguments().get(0), context).getName();
                        String name = IokeObject.as(message.getArguments().get(1), context).getName();
                        IokeObject code = IokeObject.as(message.getArguments().get(2), context);

                        int index = 0;

                        Object current = from;

                        while(!IokeObject.isTrue(Interpreter.send(context.runtime.eqMessage, context, current, to))) {
                            c.setCell(name, current);
                            c.setCell(iname, runtime.newNumber(index++));
                            runtime.interpreter.evaluate(code, c, c.getRealContext(), c);
                            current = Interpreter.send(messageToSend, context, current);
                        }
                        if(inclusive) {
                            c.setCell(name, current);
                            c.setCell(iname, runtime.newNumber(index++));
                            runtime.interpreter.evaluate(code, c, c.getRealContext(), c);
                        }

                        break;
                    }
                    }
                    return on;
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("returns true if the argument is within the confines of this range. how this comparison is done depends on if the object mimics Comparing. If it does, < and > will be used. If not, all the available entries in this range will be enumerated using 'succ'/'pred' until either the end or the element we're looking for is found. in that case, comparison is done with '=='", new NativeMethod("===") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("other")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());
                    Object other = args.get(0);

                    IokeObject from = IokeObject.as(((Range)IokeObject.data(on)).from, context);
                    IokeObject to = IokeObject.as(((Range)IokeObject.data(on)).to, context);
                    boolean comparing = IokeObject.isMimic(from, IokeObject.as(context.runtime.mixins.body.get("Comparing"), context));
                    boolean inclusive = ((Range)IokeObject.data(on)).inclusive;

                    if(comparing) {
                        IokeObject firstMessage = context.runtime.lteMessage;
                        IokeObject secondMessageInclusive = context.runtime.gteMessage;
                        IokeObject secondMessageExclusive = context.runtime.gtMessage;

                        if(((Range)IokeObject.data(on)).inverted) {
                            firstMessage = context.runtime.gteMessage;
                            secondMessageInclusive = context.runtime.lteMessage;
                            secondMessageExclusive = context.runtime.ltMessage;
                        }

                        if(IokeObject.isTrue(Interpreter.send(firstMessage, context, from, other)) &&
                           ((inclusive &&
                             IokeObject.isTrue(Interpreter.send(secondMessageInclusive, context, to, other))) ||
                            IokeObject.isTrue(Interpreter.send(secondMessageExclusive, context, to, other)))) {
                            return context.runtime._true;
                        } else {
                            return context.runtime._false;
                        }
                    } else {
                        IokeObject messageToSend = context.runtime.succ;
                        if(((Range)IokeObject.data(on)).inverted) {
                            messageToSend = context.runtime.pred;
                        }

                        Object current = from;

                        while(!IokeObject.isTrue(Interpreter.send(context.runtime.eqMessage, context, current, to))) {
                            if(IokeObject.isTrue(Interpreter.send(context.runtime.eqMessage, context, current, other))) {
                                return context.runtime._true;
                            }
                            current = Interpreter.send(messageToSend, context, current);
                        }

                        if(inclusive && IokeObject.isTrue(Interpreter.send(context.runtime.eqMessage, context, to, other))) {
                            return context.runtime._true;
                        }
                        return context.runtime._false;
                    }
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("Returns a text inspection of the object", new NativeMethod.WithNoArguments("inspect") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());
                    return method.runtime.newText(Range.getInspect(on));
                }
            }));

        obj.registerMethod(runtime.newNativeMethod("Returns a brief text inspection of the object", new NativeMethod.WithNoArguments("notice") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());
                    return method.runtime.newText(Range.getNotice(on));
                }
            }));
    }

    public IokeData cloneData(IokeObject obj, IokeObject m, IokeObject context) {
        return new Range(from, to, inclusive, inverted);
    }

    public static String getInspect(Object on) throws ControlFlow {
        return ((Range)(IokeObject.data(on))).inspect(on);
    }

    public static String getNotice(Object on) throws ControlFlow {
        return ((Range)(IokeObject.data(on))).notice(on);
    }

    public String inspect(Object obj) throws ControlFlow {
        StringBuilder sb = new StringBuilder();

        sb.append(IokeObject.inspect(from));
        if(inclusive) {
            sb.append("..");
        } else {
            sb.append("...");
        }
        sb.append(IokeObject.inspect(to));

        return sb.toString();
    }

    public String notice(Object obj) throws ControlFlow {
        StringBuilder sb = new StringBuilder();

        sb.append(IokeObject.notice(from));
        if(inclusive) {
            sb.append("..");
        } else {
            sb.append("...");
        }
        sb.append(IokeObject.notice(to));

        return sb.toString();
    }
}// Range
