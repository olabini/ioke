/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.ArrayList;
import java.util.List;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.IdentityHashMap;
import java.util.Map;
import java.util.HashSet;
import java.util.Set;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Base {
    public static void init(final IokeObject base) throws ControlFlow {
        base.setKind("Base");
        base.registerMethod(base.runtime.newJavaMethod("returns the documentation text of the object called on. anything can have a documentation text - this text will initially be nil.", new JavaMethod.WithNoArguments("documentation") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());

                    String docs = IokeObject.as(on, context).getDocumentation();
                    if(null == docs) {
                        return context.runtime.nil;
                    }
                    return context.runtime.newText(docs);
                }
            }));

        base.registerMethod(base.runtime.newJavaMethod("returns this object", new JavaMethod.WithNoArguments("identity") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());
                    return on;
                }
            }));

        base.registerMethod(base.runtime.newJavaMethod("sets the documentation string for a specific object.", new TypeCheckingJavaMethod("documentation=") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .withRequiredPositional("text").whichMustMimic(base.runtime.text).orBeNil()
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    Object arg = args.get(0);
                    if(arg == context.runtime.nil) {
                        IokeObject.as(on, context).setDocumentation(null, message, context);
                    } else {
                        String s = Text.getText(arg);
                        IokeObject.as(on, context).setDocumentation(s, message, context);
                    }
                    return arg;
                }
            }));

        base.registerMethod(base.runtime.newJavaMethod("will return a new derivation of the receiving object. Might throw exceptions if the object is an oddball object.", 
                                                       new JavaMethod.WithNoArguments("mimic") {
                                                           @Override
                                                           public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                                                               getArguments().checkArgumentCount(context, message, on);
                                                               return IokeObject.as(on, context).mimic(message, context);
                                                           }}));

        base.registerMethod(base.runtime.newJavaMethod("expects two arguments, the first unevaluated, the second evaluated. assigns the result of evaluating the second argument in the context of the caller, and assigns this result to the name provided by the first argument. the first argument remains unevaluated. the result of the assignment is the value assigned to the name. if the second argument is a method-like object and it's name is not set, that name will be set to the name of the cell. TODO: add setf documentation here.", new JavaMethod("=") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositionalUnevaluated("place")
                    .withRequiredPositional("value")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().checkArgumentCount(context, message, on);

                    IokeObject m1 = IokeObject.as(Message.getArg1(message), context);
                    String name = m1.getName();
                    if(m1.getArguments().size() == 0) {
                        Object value = message.getEvaluatedArgument(1, context);

                        IokeObject.assign(on, name, value, context, message);

                        if(value instanceof IokeObject) {
                            if((IokeObject.data(value) instanceof Named) && ((Named)IokeObject.data(value)).getName() == null) {
                                ((Named)IokeObject.data(value)).setName(name);
                            } else if(name.length() > 0 && Character.isUpperCase(name.charAt(0)) && !IokeObject.as(value, context).hasKind()) {
                                if(on == context.runtime.ground) {
                                    IokeObject.as(value, context).setKind(name);
                                } else {
                                    IokeObject.as(value, context).setKind(IokeObject.as(on, context).getKind(message, context) + " " + name);
                                }
                            }
                        }

                    
                        return value;
                    } else {
                        String newName = name + "=";
                        List<Object> arguments = new ArrayList<Object>(m1.getArguments());
                        arguments.add(Message.getArg2(message));
                        return context.runtime.newMessageFrom(message, newName, arguments).sendTo(context, on);
                    }
                }
            }));

        base.registerMethod(base.runtime.newJavaMethod("expects one evaluated text or symbol argument and returns the cell that matches that name, without activating even if it's activatable.", new JavaMethod("cell") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("cellName")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());

                    String name = Text.getText(context.runtime.asText.sendTo(context, args.get(0)));
                    return IokeObject.getCell(on, message, context, name);
                }
            }));

        base.registerMethod(base.runtime.newJavaMethod("expects one evaluated text or symbol argument and returns a boolean indicating whether such a cell is reachable from this point.", new JavaMethod("cell?") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("cellName")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());

                    String name = Text.getText(context.runtime.asText.sendTo(context, args.get(0)));
                    return IokeObject.findCell(on, message, context, name) != context.runtime.nul ? context.runtime._true : context.runtime._false;
                }
            }));

        base.registerMethod(base.runtime.newJavaMethod("expects one evaluated text or symbol argument and returns a boolean indicating whether this cell is owned by the receiver or not. the assumption is that the cell should exist. if it doesn't exist, a NoSuchCell condition will be signalled.", new JavaMethod("cellOwner?") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("cellName")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());

                    String name = Text.getText(context.runtime.asText.sendTo(context, args.get(0)));
                    return (IokeObject.findPlace(on, message, context, name) == on) ? context.runtime._true : context.runtime._false;
                }
            }));

        base.registerMethod(base.runtime.newJavaMethod("expects one evaluated text or symbol argument and returns the closest object that defines such a cell. if it doesn't exist, a NoSuchCell condition will be signalled.", new JavaMethod("cellOwner") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("cellName")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());

                    String name = Text.getText(context.runtime.asText.sendTo(context, args.get(0)));
                    Object result = IokeObject.findPlace(on, message, context, name);
                    if(result == context.runtime.nul) {
                        return context.runtime.nil;
                    }
                    return result;
                }
            }));

        base.registerMethod(base.runtime.newJavaMethod("expects one evaluated text or symbol argument and removes that cell from the current receiver. if the current receiver has no such object, signals a condition. note that if another cell with that name is available in the mimic chain, it will still be accessible after calling this method. the method returns the receiver.", new JavaMethod("removeCell!") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("cellName")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());

                    String name = Text.getText(context.runtime.asText.sendTo(context, args.get(0)));
                    IokeObject.removeCell(on, message, context, name);
                    return on;
                }
            }));

        base.registerMethod(base.runtime.newJavaMethod("expects one evaluated text or symbol argument and makes that cell undefined in the current receiver. what that means is that from now on it will look like this cell doesn't exist in the receiver or any of its mimics. the cell will not show up if you call cellNames on the receiver or any of the receivers mimics. the undefined status can be removed by doing removeCell! on the correct cell name. a cell name that doesn't exist can still be undefined. the method returns the receiver.", new JavaMethod("undefineCell!") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("cellName")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());

                    String name = Text.getText(context.runtime.asText.sendTo(context, args.get(0)));
                    IokeObject.undefineCell(on, message, context, name);
                    return on;
                }
            }));

        base.registerMethod(base.runtime.newJavaMethod("takes one optional evaluated boolean argument, which defaults to false. if false, this method returns a list of the cell names of the receiver. if true, it returns the cell names of this object and all it's mimics recursively.", new JavaMethod("cellNames") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withOptionalPositional("includeMimics", "false")
                    .withOptionalPositional("cutoff", "nil")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());

                    if(args.size() > 0 && IokeObject.isTrue(args.get(0))) {
                        Object cutoff = null;
                        if(args.size() > 1) {
                            cutoff = args.get(1);
                        }

                        IdentityHashMap<Object, Object> visited = new IdentityHashMap<Object, Object>();
                        List<Object> names = new ArrayList<Object>();
                        Set<Object> visitedNames = new HashSet<Object>();
                        Set<String> undefined = new HashSet<String>();
                        Runtime runtime = context.runtime;
                        List<Object> toVisit = new ArrayList<Object>();
                        toVisit.add(on);

                        while(!toVisit.isEmpty()) {
                            IokeObject current = IokeObject.as(toVisit.remove(0), context);
                            if(!visited.containsKey(current)) {
                                visited.put(current, null);
                                if(cutoff != current) {
                                    toVisit.addAll(current.getMimics());
                                }
                                
                                Map<String, Object> mso = current.getCells();

                                for(String s : mso.keySet()) {
                                    if(!undefined.contains(s)) {
                                        if(mso.get(s) == runtime.nul) {
                                            undefined.add(s);
                                        } else {
                                            Object x = runtime.getSymbol(s);
                                            if(!visitedNames.contains(x)) {
                                                visitedNames.add(x);
                                                names.add(x);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        return runtime.newList(names);
                    } else {
                        Map<String, Object> mso = IokeObject.as(on, context).getCells();
                        List<Object> names = new ArrayList<Object>();
                        Runtime runtime = context.runtime;

                        for(String s : mso.keySet()) {
                            if(mso.get(s) != runtime.nul) {
                                names.add(runtime.getSymbol(s));
                            }
                        }

                        return runtime.newList(names);
                    }
                }
            }));


        base.registerMethod(base.runtime.newJavaMethod("takes one optional evaluated boolean argument, which defaults to false. if false, this method returns a dict of the cell names and values of the receiver. if true, it returns the cell names and values of this object and all it's mimics recursively.", new JavaMethod("cells") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withOptionalPositional("includeMimics", "false")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    Map<Object, Object> cells = new LinkedHashMap<Object, Object>();
                    Runtime runtime = context.runtime;

                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());

                    if(args.size() > 0 && IokeObject.isTrue(args.get(0))) {
                        IdentityHashMap<Object, Object> visited = new IdentityHashMap<Object, Object>();
                        Set<String> undefined = new HashSet<String>();

                        List<Object> toVisit = new ArrayList<Object>();
                        toVisit.add(on);

                        while(!toVisit.isEmpty()) {
                            IokeObject current = IokeObject.as(toVisit.remove(0), context);
                            if(!visited.containsKey(current)) {
                                visited.put(current, null);
                                toVisit.addAll(current.getMimics());
                                
                                Map<String, Object> mso = current.getCells();

                                for(String s : mso.keySet()) {
                                    if(!undefined.contains(s)) {
                                        Object val = mso.get(s);
                                        if(val == runtime.nul) {
                                            undefined.add(s);
                                        } else {
                                            Object x = runtime.getSymbol(s);
                                            if(!cells.containsKey(x)) {
                                                cells.put(x, val);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        Map<String, Object> mso = IokeObject.as(on, context).getCells();

                        for(String s : mso.keySet()) {
                            Object val = mso.get(s);
                            if(val != runtime.nul) {
                                cells.put(runtime.getSymbol(s), val);
                            }
                        }
                    }
                    return runtime.newDict(cells);
                }
            }));


        base.registerMethod(base.runtime.newJavaMethod("expects one evaluated text or symbol argument that names the cell to set, sets this cell to the result of evaluating the second argument, and returns the value set.", new JavaMethod("cell=") {
                private final DefaultArgumentsDefinition ARGUMENTS = DefaultArgumentsDefinition
                    .builder()
                    .withRequiredPositional("cellName")
                    .withRequiredPositional("value")
                    .getArguments();

                @Override
                public DefaultArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    getArguments().getEvaluatedArguments(context, message, on, args, new HashMap<String, Object>());

                    String name = Text.getText(context.runtime.asText.sendTo(context, args.get(0)));
                    Object val = args.get(1);

                    if(val instanceof IokeObject) {
                    if((IokeObject.data(val) instanceof Named) && ((Named)IokeObject.data(val)).getName() == null) {
                        ((Named)IokeObject.data(val)).setName(name);
                    } else if(name.length() > 0 && Character.isUpperCase(name.charAt(0)) && !IokeObject.as(val, context).hasKind()) {
                        if(on == context.runtime.ground) {
                            IokeObject.as(val, context).setKind(name);
                        } else {
                            IokeObject.as(val, context).setKind(IokeObject.as(on, context).getKind(message, context) + " " + name);
                        }
                    }
                    }

                    return IokeObject.setCell(on, message, context, name, val);
                }
            }));

        base.registerMethod(base.runtime.newJavaMethod("returns true if the left hand side is equal to the right hand side. exactly what this means depend on the object. the default behavior of Ioke objects is to only be equal if they are the same instance.", new JavaMethod("==") {
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

                    return IokeObject.equals(on, args.get(0)) ? context.runtime._true : context.runtime._false;
                }
            }));
    }
}// Base
