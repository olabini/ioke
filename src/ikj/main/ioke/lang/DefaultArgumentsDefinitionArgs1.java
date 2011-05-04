/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.Arrays;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.HashSet;
import java.util.Map;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.Collection;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class DefaultArgumentsDefinitionArgs1 implements ArgumentsDefinition {
    private final String name0;

    public DefaultArgumentsDefinitionArgs1(String name0) {
        this.name0 = name0;
    }

    public void assignArgumentValues(final IokeObject locals, final IokeObject context, final IokeObject message, final Object on, final Call call) throws ControlFlow {
        final Runtime runtime = context.runtime;
        if(call.cachedPositional == null) {
            call.cachedArgCount = 1;
            call.cachedPositional = assign(context, message, on, 1);;
            locals.setCell(name0, call.cachedPositional.get(0));
        } else {
            locals.setCell(name0, call.cachedPositional.get(0));
        }
    }

    public static List<Object> assign(final IokeObject context, final IokeObject message, final Object on, final int expected) throws ControlFlow {
        final Runtime runtime = context.runtime;

        final List<Object> arguments = message.getArguments();
        int argCount = 0;
        
        final List<Object> argumentsWithoutKeywords = new ArrayList<Object>();
        final Map<String, Object> givenKeywords = new HashMap<String, Object>();

        for(Object o : arguments) {
            if(Message.isKeyword(o)) {
                givenKeywords.put(IokeObject.as(o, context).getName(), Interpreter.getEvaluatedArgument(((Message)IokeObject.data(o)).next, context));
            } else if(Message.hasName(o, "*") && IokeObject.as(o, context).getArguments().size() == 1) { // Splat
                Object result = Interpreter.getEvaluatedArgument(IokeObject.as(o, context).getArguments().get(0), context);
                if(IokeObject.data(result) instanceof IokeList) {
                    List<Object> elements = IokeList.getList(result);
                    argumentsWithoutKeywords.addAll(elements);
                    argCount += elements.size();
                } else if(IokeObject.data(result) instanceof Dict) {
                    Map<Object, Object> keys = Dict.getMap(result);
                    for(Map.Entry<Object, Object> me : keys.entrySet()) {
                        givenKeywords.put(Text.getText(IokeObject.convertToText(me.getKey(), message, context, true)) + ":", me.getValue());
                    }
                } else if(IokeObject.findCell(IokeObject.as(result, context), "asTuple") != runtime.nul) {
                    Object tupledValue = Interpreter.send(runtime.asTuple, context, result);
                    Object[] values = Tuple.getElements(tupledValue);
                    argumentsWithoutKeywords.addAll(Arrays.asList(values));
                    argCount += values.length;
                } else {
                    final IokeObject condition = IokeObject.as(IokeObject.getCellChain(runtime.condition,
                                                                                       message,
                                                                                       context,
                                                                                       "Error",
                                                                                       "Invocation",
                                                                                       "NotSpreadable"), context).mimic(message, context);
                    condition.setCell("message", message);
                    condition.setCell("context", context);
                    condition.setCell("receiver", on);
                    condition.setCell("given", result);

                    List<Object> outp = IokeList.getList(runtime.withRestartReturningArguments(new RunnableWithControlFlow() {
                            public void run() throws ControlFlow {
                                runtime.errorCondition(condition);
                            }},
                            context,
                            new Restart.DefaultValuesGivingRestart("ignoreArgument", runtime.nil, 0),
                            new Restart.DefaultValuesGivingRestart("takeArgumentAsIs", IokeObject.as(result, context), 1)
                            ));

                    argumentsWithoutKeywords.addAll(outp);
                    argCount += outp.size();
                }
            } else {
                argumentsWithoutKeywords.add(Interpreter.getEvaluatedArgument(o, context));
                argCount++;
            }
        }

        while(argCount != expected) {
            final int finalArgCount = argCount;
            if(argCount < expected) {
                final IokeObject condition = IokeObject.as(IokeObject.getCellChain(runtime.condition,
                                                                             message,
                                                                             context,
                                                                             "Error",
                                                                             "Invocation",
                                                                             "TooFewArguments"), context).mimic(message, context);
                condition.setCell("message", message);
                condition.setCell("context", context);
                condition.setCell("receiver", on);
                condition.setCell("missing", runtime.newNumber(expected-argCount));

                List<Object> newArguments = IokeList.getList(runtime.withRestartReturningArguments(new RunnableWithControlFlow() {
                        public void run() throws ControlFlow {
                            runtime.errorCondition(condition);
                        }},
                        context,
                        new Restart.ArgumentGivingRestart("provideExtraArguments") {
                            public List<String> getArgumentNames() {
                                return new ArrayList<String>(Arrays.asList("newArgument"));
                            }
                        },
                        new Restart.DefaultValuesGivingRestart("substituteNilArguments", runtime.nil, expected-argCount) {
                            public List<String> getArgumentNames() {
                                return new ArrayList<String>();
                            }
                        }
                        ));

                argCount += newArguments.size();
                argumentsWithoutKeywords.addAll(newArguments);
             } else {
                runtime.withReturningRestart("ignoreExtraArguments", context, new RunnableWithControlFlow() {
                        public void run() throws ControlFlow {
                            IokeObject condition = IokeObject.as(IokeObject.getCellChain(runtime.condition,
                                                                                         message,
                                                                                         context,
                                                                                         "Error",
                                                                                         "Invocation",
                                                                                         "TooManyArguments"), context).mimic(message, context);
                            condition.setCell("message", message);
                            condition.setCell("context", context);
                            condition.setCell("receiver", on);
                            condition.setCell("extra", runtime.newList(argumentsWithoutKeywords.subList(expected, finalArgCount)));

                            runtime.errorCondition(condition);
                        }});
                argCount = expected;
            }
        }

        if(!givenKeywords.isEmpty()) {
            runtime.withReturningRestart("ignoreExtraKeywords", context, new RunnableWithControlFlow() {
                    public void run() throws ControlFlow {
                        IokeObject condition = IokeObject.as(IokeObject.getCellChain(runtime.condition,
                                                                                     message,
                                                                                     context,
                                                                                     "Error",
                                                                                     "Invocation",
                                                                                     "MismatchedKeywords"), context).mimic(message, context);
                        condition.setCell("message", message);
                        condition.setCell("context", context);
                        condition.setCell("receiver", on);

                        List<Object> expected = new ArrayList<Object>();
                        condition.setCell("expected", runtime.newList(expected));

                        List<Object> extra = new ArrayList<Object>();
                        for(String s : givenKeywords.keySet()) {
                            extra.add(runtime.newText(s));
                        }
                        condition.setCell("extra", runtime.newList(extra));

                        runtime.errorCondition(condition);
                    }});
        }

        return argumentsWithoutKeywords;
    }

    public void assignArgumentValues(final IokeObject locals, final IokeObject context, final IokeObject message, final Object on) throws ControlFlow {
        List<Object> result = assign(context, message, on, 1);
        locals.setCell(name0, result.get(0));
    }

    public String getCode() {
        return getCode(true);
    }

    public String getCode(boolean lastComma) {
        if(lastComma) {
            return name0 + ", ";
        } else {
            return name0;
        }
    }

    public Collection<String> getKeywords() {
        return new ArrayList<String>();
    }

    public List<DefaultArgumentsDefinition.Argument> getArguments() {
        return Arrays.asList(new DefaultArgumentsDefinition.Argument(name0));
    }

    public boolean isEmpty() {
        return false;
    }

    public String getRestName() {
        return null;
    }

    public String getKrestName() {
        return null;
    }
}
