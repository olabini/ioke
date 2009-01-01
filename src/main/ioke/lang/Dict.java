/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.Set;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Dict extends IokeData {
    private Map<Object, Object> dict;
    private IokeObject defaultValue;

    public Dict() {
        this(new HashMap<Object, Object>());
    }

    public Dict(Map<Object, Object> d) {
        this.dict = d;
    }

    public static IokeObject getDefaultValue(Object on, IokeObject context, IokeObject message) throws ControlFlow {
        Dict dict = (Dict)IokeObject.data(on);
        if(dict.defaultValue == null) {
            return context.runtime.nil;
        } else {
            return dict.defaultValue;
        }
    }

    public static void setDefaultValue(Object on, IokeObject defaultValue) throws ControlFlow {
        Dict dict = (Dict)IokeObject.data(on);
        dict.defaultValue = defaultValue;
    }

    @Override
    public void init(IokeObject obj) throws ControlFlow {
        final Runtime runtime = obj.runtime;

        obj.setKind("Dict");
        obj.mimics(IokeObject.as(runtime.mixins.getCell(null, null, "Enumerable")), runtime.nul, runtime.nul);
        obj.registerMethod(runtime.newJavaMethod("takes one argument, that should be a default value, and returns a new mimic of the receiver, with the default value for that new dict set to the argument", new JavaMethod("withDefault") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("defaultValue")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> positionalArgs = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, positionalArgs, new HashMap<String, Object>());

                    Object newDict = IokeObject.mimic(on, message, context);
                    setDefaultValue(newDict, IokeObject.as(positionalArgs.get(0)));
                    return newDict;
                }}));

        obj.registerMethod(runtime.newJavaMethod("takes one argument, the key of the element to return. if the key doesn't map to anything in the dict, returns the default value", new JavaMethod("at") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("key")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> positionalArgs = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, positionalArgs, new HashMap<String, Object>());

                    Object result = Dict.getMap(on).get(positionalArgs.get(0));
                    if(result == null) {
                        return getDefaultValue(on, context, message);
                    } else {
                        return result;
                    }
                }}));

        obj.registerMethod(runtime.newJavaMethod("takes two arguments, the key of the element to set and the value to set it too. returns the value set", new JavaMethod("[]=") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("key")
                    .withRequiredPositional("value")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> positionalArgs = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, positionalArgs, new HashMap<String, Object>());

                    Dict.getMap(on).put(positionalArgs.get(0), positionalArgs.get(1));
                    return positionalArgs.get(1);
                }}));

        obj.registerMethod(runtime.newJavaMethod("Returns a text inspection of the object", new JavaMethod.WithNoArguments("inspect") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());
                    return method.runtime.newText(Dict.getInspect(on));
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("Returns a brief text inspection of the object", new JavaMethod.WithNoArguments("notice") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());
                    return method.runtime.newText(Dict.getNotice(on));
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("Returns all the keys of this dict", new JavaMethod.WithNoArguments("keys") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());
                    return method.runtime.newSet(Dict.getKeys(on));
                }
            }));
        obj.registerMethod(runtime.newJavaMethod("takes either one or two or three arguments. if one argument is given, it should be a message chain that will be sent to each object in the dict. the result will be thrown away. if two arguments are given, the first is an unevaluated name that will be set to each of the entries in the dict in succession, and then the second argument will be evaluated in a scope with that argument in it. if three arguments is given, the first one is an unevaluated name that will be set to the index of each element, and the other two arguments are the name of the argument for the value, and the actual code. the code will evaluate in a lexical context, and if the argument name is available outside the context, it will be shadowed. the method will return the dict. the entries yielded will be mimics of Pair.", new JavaMethod("each") {

                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositionalUnevaluated("indexOrArgOrCode")
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
                    Map<Object, Object> ls = Dict.getMap(on);
                    switch(message.getArgumentCount()) {
                    case 1: {
                        IokeObject code = IokeObject.as(message.getArguments().get(0));

                        for(Map.Entry<Object, Object> o : ls.entrySet()) {
                            code.evaluateCompleteWithReceiver(context, context.getRealContext(), runtime.newPair(o.getKey(), o.getValue()));
                        }
                        break;
                    }
                    case 2: {
                        LexicalContext c = new LexicalContext(context.runtime, context, "Lexical activation context for List#each", message, context);
                        String name = IokeObject.as(message.getArguments().get(0)).getName();
                        IokeObject code = IokeObject.as(message.getArguments().get(1));

                        for(Map.Entry<Object, Object> o : ls.entrySet()) {
                            c.setCell(name, runtime.newPair(o.getKey(), o.getValue()));
                            code.evaluateCompleteWithoutExplicitReceiver(c, c.getRealContext());
                        }
                        break;
                    }
                    case 3: {
                        LexicalContext c = new LexicalContext(context.runtime, context, "Lexical activation context for List#each", message, context);
                        String iname = IokeObject.as(message.getArguments().get(0)).getName();
                        String name = IokeObject.as(message.getArguments().get(1)).getName();
                        IokeObject code = IokeObject.as(message.getArguments().get(2));

                        int index = 0;
                        for(Map.Entry<Object, Object> o : ls.entrySet()) {
                            c.setCell(name, runtime.newPair(o.getKey(), o.getValue()));
                            c.setCell(iname, runtime.newNumber(index++));
                            code.evaluateCompleteWithoutExplicitReceiver(c, c.getRealContext());
                        }
                        break;
                    }
                    }
                    return on;
                }
            }));
    }

    public static Map<Object, Object> getMap(Object dict) {
        return ((Dict)IokeObject.data(dict)).getMap();
    }

    public static Set<Object> getKeys(Object dict) {
        return ((Dict)IokeObject.data(dict)).getMap().keySet();
    }

    public Map<Object, Object> getMap() {
        return dict;
    }

    public IokeData cloneData(IokeObject obj, IokeObject m, IokeObject context) {
        return new Dict(new HashMap<Object, Object>(dict));
    }

    @Override
    public boolean isEqualTo(IokeObject self, Object other) {
        return ((other instanceof IokeObject) && 
                (IokeObject.data(other) instanceof Dict) 
                && this.dict.equals(((Dict)IokeObject.data(other)).dict));
    }

    @Override
    public int hashCode(IokeObject self) {
        return this.dict.hashCode();
    }

    @Override
    public String toString() {
        return dict.toString();
    }

    @Override
    public String toString(IokeObject obj) {
        return dict.toString();
    }

    public static String getInspect(Object on) throws ControlFlow {
        return ((Dict)(IokeObject.data(on))).inspect(on);
    }

    public static String getNotice(Object on) throws ControlFlow {
        return ((Dict)(IokeObject.data(on))).notice(on);
    }

    public String inspect(Object obj) throws ControlFlow {
        StringBuilder sb = new StringBuilder();
        sb.append("{");
        String sep = "";

        for(Map.Entry<Object, Object> o : dict.entrySet()) {
            sb.append(sep);
            Object key = o.getKey();

            if((IokeObject.data(key) instanceof Symbol) && Symbol.onlyGoodChars(key)) {
                sb.append(Symbol.getText(key)).append(": ");
            } else {
                sb.append(IokeObject.inspect(key)).append(" => ");
            }

            sb.append(IokeObject.inspect(o.getValue()));
            sep = ", ";
        }

        sb.append("}");
        return sb.toString();
    }

    public String notice(Object obj) throws ControlFlow {
        StringBuilder sb = new StringBuilder();
        sb.append("{");
        String sep = "";

        for(Map.Entry<Object, Object> o : dict.entrySet()) {
            sb.append(sep);
            Object key = o.getKey();

            if((IokeObject.data(key) instanceof Symbol) && Symbol.onlyGoodChars(key)) {
                sb.append(Symbol.getText(key)).append(": ");
            } else {
                sb.append(IokeObject.notice(key)).append(" => ");
            }

            sb.append(IokeObject.notice(o.getValue()));
            sep = ", ";
        }

        sb.append("}");
        return sb.toString();
    }
}// Dict
