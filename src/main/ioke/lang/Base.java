/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.Arrays;
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
    public static void init(IokeObject base) {
        base.setKind("Base");
        base.registerMethod(base.runtime.newJavaMethod("returns the documentation text of the object called on. anything can have a documentation text - this text will initially be nil.", new JavaMethod("documentation") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) {
                    String docs = IokeObject.as(on).documentation;
                    if(null == docs) {
                        return context.runtime.nil;
                    }
                    return context.runtime.newText(docs);
                }
            }));

        base.registerMethod(base.runtime.newJavaMethod("sets the documentation string for a specific object.", new JavaMethod("documentation=") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    DefaultArgumentsDefinition.getEvaluatedArguments(message, context, args, new HashMap<String, Object>());
                    Object arg = args.get(0);
                    String s = Text.getText(arg);
                    IokeObject.as(on).documentation = s;
                    return arg;
                }
            }));

        base.registerMethod(base.runtime.newJavaMethod("will return a new derivation of the receiving object. Might throw exceptions if the object is an oddball object.", 
                                                       new JavaMethod("mimic") {
                                                           @Override
                                                           public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                                                               return IokeObject.as(on).mimic(message, context);
                                                           }}));

        base.registerMethod(base.runtime.newJavaMethod("expects two arguments, the first unevaluated, the second evaluated. assigns the result of evaluating the second argument in the context of the caller, and assigns this result to the name provided by the first argument. the first argument remains unevaluated. the result of the assignment is the value assigned to the name. if the second argument is a method-like object and it's name is not set, that name will be set to the name of the cell. TODO: add setf documentation here.", new JavaMethod("=") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    IokeObject m1 = IokeObject.as(Message.getArg1(message));
                    String name = m1.getName();
                    if(m1.getArguments().size() == 0) {
                        Object value = message.getEvaluatedArgument(1, context);

                        IokeObject.assign(on, name, value, context, message);

                        if((IokeObject.data(value) instanceof Named) && ((Named)IokeObject.data(value)).getName() == null) {
                            ((Named)IokeObject.data(value)).setName(name);
                        } else if(name.length() > 0 && Character.isUpperCase(name.charAt(0)) && !IokeObject.as(value).hasKind()) {
                            if(on == context.runtime.ground) {
                                IokeObject.as(value).setKind(name);
                            } else {
                                IokeObject.as(value).setKind(IokeObject.as(on).getKind() + " " + name);
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
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    String name = Text.getText(context.runtime.asText.sendTo(context, IokeObject.as(message.getArguments().get(0)).evaluateCompleteWith(context, context.getRealContext())));
                    return IokeObject.getCell(on, message, context, name);
                }
            }));

        base.registerMethod(base.runtime.newJavaMethod("expects one evaluated text or symbol argument and returns a boolean indicating whether such a cell is reachable from this point.", new JavaMethod("cell?") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    List<Object> args = new ArrayList<Object>();
                    DefaultArgumentsDefinition.getEvaluatedArguments(message, context, args, new HashMap<String, Object>());
                    String name = Text.getText(context.runtime.asText.sendTo(context, args.get(0)));

                    return IokeObject.findCell(on, message, context, name) != context.runtime.nul ? context.runtime._true : context.runtime._false;
                }
            }));

        base.registerMethod(base.runtime.newJavaMethod("takes one optional evaluated boolean argument, which defaults to false. if false, this method returns a list of the cell names of the receiver. if true, it returns the cell names of this object and all it's mimics recursively.", new JavaMethod("cellNames") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    if(message.getArgumentCount() > 0 && IokeObject.isTrue(message.getEvaluatedArgument(0, context))) {
                        IdentityHashMap<Object, Object> visited = new IdentityHashMap<Object, Object>();
                        List<Object> names = new ArrayList<Object>();
                        Set<Object> visitedNames = new HashSet<Object>();
                        Runtime runtime = context.runtime;
                        List<Object> toVisit = new ArrayList<Object>();
                        toVisit.add(on);

                        while(!toVisit.isEmpty()) {
                            IokeObject current = IokeObject.as(toVisit.remove(0));
                            if(!visited.containsKey(current)) {
                                visited.put(current, null);
                                toVisit.addAll(current.getMimics());
                                
                                Map<String, Object> mso = current.getCells();

                                for(String s : mso.keySet()) {
                                    Object x = runtime.getSymbol(s);
                                    if(!visitedNames.contains(x)) {
                                        visitedNames.add(x);
                                        names.add(x);
                                    }
                                }
                            }
                        }
                        
                        return runtime.newList(names);
                    } else {
                        Map<String, Object> mso = IokeObject.as(on).getCells();
                        List<Object> names = new ArrayList<Object>();
                        Runtime runtime = context.runtime;

                        for(String s : mso.keySet()) {
                            names.add(runtime.getSymbol(s));
                        }

                        return runtime.newList(names);
                    }
                }
            }));


        base.registerMethod(base.runtime.newJavaMethod("takes one optional evaluated boolean argument, which defaults to false. if false, this method returns a dict of the cell names and values of the receiver. if true, it returns the cell names and values of this object and all it's mimics recursively.", new JavaMethod("cells") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    Map<Object, Object> cells = new LinkedHashMap<Object, Object>();
                    Runtime runtime = context.runtime;

                    if(message.getArgumentCount() > 0 && IokeObject.isTrue(message.getEvaluatedArgument(0, context))) {
                        IdentityHashMap<Object, Object> visited = new IdentityHashMap<Object, Object>();

                        List<Object> toVisit = new ArrayList<Object>();
                        toVisit.add(on);

                        while(!toVisit.isEmpty()) {
                            IokeObject current = IokeObject.as(toVisit.remove(0));
                            if(!visited.containsKey(current)) {
                                visited.put(current, null);
                                toVisit.addAll(current.getMimics());
                                
                                Map<String, Object> mso = current.getCells();

                                for(String s : mso.keySet()) {
                                    Object x = runtime.getSymbol(s);
                                    if(!cells.containsKey(x)) {
                                        cells.put(x, mso.get(s));
                                    }
                                }
                            }
                        }
                    } else {
                        Map<String, Object> mso = IokeObject.as(on).getCells();

                        for(String s : mso.keySet()) {
                            cells.put(runtime.getSymbol(s), mso.get(s));
                        }
                    }
                    return runtime.newDict(cells);
                }
            }));


        base.registerMethod(base.runtime.newJavaMethod("expects one evaluated text or symbol argument that names the cell to set, sets this cell to the result of evaluating the second argument, and returns the value set.", new JavaMethod("cell=") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    String name = Text.getText(context.runtime.asText.sendTo(context, IokeObject.as(message.getArguments().get(0)).evaluateCompleteWith(context, context.getRealContext())));
                    Object val = message.getEvaluatedArgument(1, context);
                    return IokeObject.setCell(on, message, context, name, val);
                }
            }));

        base.registerMethod(base.runtime.newJavaMethod("returns true if the left hand side is equal to the right hand side. exactly what this means depend on the object. the default behavior of Ioke objects is to only be equal if they are the same instance.", new JavaMethod("==") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    return IokeObject.equals(on, message.getEvaluatedArgument(0, context)) ? context.runtime._true : context.runtime._false ;
                }
            }));
    }
}// Base
