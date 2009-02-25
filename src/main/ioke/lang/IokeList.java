/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.ListIterator;
import java.util.Map;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class IokeList extends IokeData {
    private List<Object> list;

    public IokeList() {
        this(new ArrayList<Object>());
    }

    public IokeList(List<Object> l) {
        this.list = l;
    }

    public static void add(Object list, Object obj) {
        ((IokeList)IokeObject.data(list)).list.add(obj);
    }

    @Override
    public void init(IokeObject obj) throws ControlFlow {
        final Runtime runtime = obj.runtime;

        obj.setKind("List");
        obj.mimics(IokeObject.as(runtime.mixins.getCell(null, null, "Enumerable"), null), runtime.nul, runtime.nul);

        obj.registerMethod(obj.runtime.newJavaMethod("Returns a text inspection of the object", new TypeCheckingJavaMethod.WithNoArguments("inspect", runtime.list) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                  return method.runtime.newText(IokeList.getInspect(on));
                }
            }));

        obj.registerMethod(obj.runtime.newJavaMethod("Returns a brief text inspection of the object", new TypeCheckingJavaMethod.WithNoArguments("notice", runtime.list) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    return method.runtime.newText(IokeList.getNotice(on));
                }
            }));

        obj.registerMethod(obj.runtime.newJavaMethod("Compares this object against the argument. The comparison is only based on the elements inside the lists, which are in turn compared using <=>.", new TypeCheckingJavaMethod("<=>") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .receiverMustMimic(runtime.list)
                    .withRequiredPositional("other")
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject self, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {

                    List<Object> one = IokeList.getList(on);
                    Object arg = args.get(0);
                    if(!(IokeObject.data(arg) instanceof IokeList)) {
                        return context.runtime.nil;
                    }
                    List<Object> two = IokeList.getList(arg);

                    int len = Math.min(one.size(), two.size());
                    SpaceshipComparator sc = new SpaceshipComparator(context, message);

                    for(int i = 0; i < len; i++) {
                        int v = sc.compare(one.get(i), two.get(i));
                        if(v != 0) {
                            return context.runtime.newNumber(v);
                        }
                    }

                    len = one.size() - two.size();

                    if(len == 0) return context.runtime.newNumber(0);
                    if(len > 0) return context.runtime.newNumber(1);
                    return context.runtime.newNumber(-1);
                }
            }));
            
            obj.registerMethod(runtime.newJavaMethod("takes either one or two or three arguments. if one argument is given, it should be a message chain that will be sent to each object in the list. the result will be thrown away. if two arguments are given, the first is an unevaluated name that will be set to each of the values in the list in succession, and then the second argument will be evaluated in a scope with that argument in it. if three arguments is given, the first one is an unevaluated name that will be set to the index of each element, and the other two arguments are the name of the argument for the value, and the actual code. the code will evaluate in a lexical context, and if the argument name is available outside the context, it will be shadowed. the method will return the list.", new JavaMethod("each") {
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
                    
                    Object onAsList = context.runtime.list.convertToThis(on, message, context);
                    
                    List<Object> ls = ((IokeList)IokeObject.data(onAsList)).list;
                    
                    switch(message.getArgumentCount()) {
                    case 1: {
                        IokeObject code = IokeObject.as(message.getArguments().get(0), context);

                        for(Object o : ls) {
                            code.evaluateCompleteWithReceiver(context, context.getRealContext(), o);
                        }
                        break;
                    }
                    case 2: {
                        LexicalContext c = new LexicalContext(context.runtime, context, "Lexical activation context for List#each", message, context);
                        String name = IokeObject.as(message.getArguments().get(0), context).getName();
                        IokeObject code = IokeObject.as(message.getArguments().get(1), context);

                        for(Object o : ls) {
                            c.setCell(name, o);
                            code.evaluateCompleteWithoutExplicitReceiver(c, c.getRealContext());
                        }
                        break;
                    }
                    case 3: {
                        LexicalContext c = new LexicalContext(context.runtime, context, "Lexical activation context for List#each", message, context);
                        String iname = IokeObject.as(message.getArguments().get(0), context).getName();
                        String name = IokeObject.as(message.getArguments().get(1), context).getName();
                        IokeObject code = IokeObject.as(message.getArguments().get(2), context);

                        int index = 0;
                        for(Object o : ls) {
                            c.setCell(name, o);
                            c.setCell(iname, runtime.newNumber(index++));
                            code.evaluateCompleteWithoutExplicitReceiver(c, c.getRealContext());
                        }
                        break;
                    }
                    }
                    return onAsList;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("takes one argument and adds it at the end of the list, and then returns the list", new TypeCheckingJavaMethod("<<") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .receiverMustMimic(runtime.list)
                    .withRequiredPositional("value")
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject self, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    IokeList.add(on, args.get(0));
                    return on;
                }
            }));
        
        obj.registerMethod(runtime.newJavaMethod("will remove all the entries from the list, and then returns the list", new TypeCheckingJavaMethod.WithNoArguments("clear!", runtime.list) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    ((IokeList)IokeObject.data(on)).getList().clear();
                    return on;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns true if this list is empty, false otherwise", new TypeCheckingJavaMethod.WithNoArguments("empty?", runtime.list) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    return ((IokeList)IokeObject.data(on)).getList().isEmpty() ? context.runtime._true : context.runtime._false;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns true if the receiver includes the evaluated argument, otherwise false", new TypeCheckingJavaMethod("include?") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .receiverMustMimic(runtime.list)
                    .withRequiredPositional("object")
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    return ((IokeList)IokeObject.data(on)).getList().contains(args.get(0)) ? context.runtime._true : context.runtime._false;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns a new list that contains the receivers elements and the elements of the list sent in as the argument.", new TypeCheckingJavaMethod("+") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .receiverMustMimic(runtime.list)
                    .withRequiredPositional("otherList").whichMustMimic(runtime.list)
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    List<Object> newList = new ArrayList<Object>();
                    newList.addAll(((IokeList)IokeObject.data(on)).getList());
                    newList.addAll(((IokeList)IokeObject.data(args.get(0))).getList());
                    return context.runtime.newList(newList, IokeObject.as(on, context));
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns a new list that contains all the elements from the receivers list, except for those that are in the argument list", new TypeCheckingJavaMethod("-") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .receiverMustMimic(runtime.list)
                    .withRequiredPositional("otherList").whichMustMimic(runtime.list)
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    List<Object> newList = new ArrayList<Object>();
                    newList.addAll(((IokeList)IokeObject.data(on)).getList());
                    newList.removeAll(((IokeList)IokeObject.data(args.get(0))).getList());
                    return context.runtime.newList(newList, IokeObject.as(on, context));
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns a new sorted version of this list", new TypeCheckingJavaMethod.WithNoArguments("sort", runtime.list) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    Object newList = IokeObject.mimic(on, message, context);
                    try {
                        Collections.sort(((IokeList)IokeObject.data(newList)).getList(), new SpaceshipComparator(context, message));
                    } catch(RuntimeException e) {
                        if(e.getCause() instanceof ControlFlow) {
                            throw (ControlFlow)e.getCause();
                        }
                        throw e;
                    }
                    return newList;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("sorts this list in place and then returns it", new TypeCheckingJavaMethod.WithNoArguments("sort!", runtime.list) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    try {
                        Collections.sort(((IokeList)IokeObject.data(on)).getList(), new SpaceshipComparator(context, message));
                    } catch(RuntimeException e) {
                        if(e.getCause() instanceof ControlFlow) {
                            throw (ControlFlow)e.getCause();
                        }
                        throw e;
                    }
                    return on;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns the size of this list", new TypeCheckingJavaMethod.WithNoArguments("size", runtime.list) {
                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    return context.runtime.newNumber(((IokeList)IokeObject.data(on)).getList().size());
                }
            }));
        obj.aliasMethod("size", "length", null, null);

        obj.registerMethod(runtime.newJavaMethod("takes one argument, the index of the element to be returned. can be negative, and will in that case return indexed from the back of the list. if the index is outside the bounds of the list, will return nil. the argument can also be a range, and will in that case interpret the first index as where to start, and the second the end. the end can be negative and will in that case be from the end. if the first argument is negative, or after the second, an empty list will be returned. if the end point is larger than the list, the size of the list will be used as the end point.", new TypeCheckingJavaMethod("at") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .receiverMustMimic(runtime.list)
                    .withRequiredPositional("index")
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                    Object arg = args.get(0);

                    if(IokeObject.data(arg) instanceof Range) {
                        int first = Number.extractInt(Range.getFrom(arg), message, context); 
                        
                        if(first < 0) {
                            return context.runtime.newList(new ArrayList<Object>());
                        }

                        int last = Number.extractInt(Range.getTo(arg), message, context);
                        boolean inclusive = Range.isInclusive(arg);

                        List<Object> o = ((IokeList)IokeObject.data(on)).getList();
                        int size = o.size();

                        if(last < 0) {
                            last = size + last;
                        }

                        if(last < 0) {
                            return context.runtime.newList(new ArrayList<Object>());
                        }

                        if(last >= size) {
                            
                            last = inclusive ? size-1 : size;
                        }

                        if(first > last || (!inclusive && first == last)) {
                            return context.runtime.newList(new ArrayList<Object>());
                        }
                        
                        if(!inclusive) {
                            last--;
                        }
                        
                        return context.runtime.newList(new ArrayList<Object>(o.subList(first, last+1)));
                    }

                    if(!(IokeObject.data(arg) instanceof Number)) {
                        arg = IokeObject.convertToNumber(arg, message, context);
                    }
                    int index = ((Number)IokeObject.data(arg)).asJavaInteger();
                    List<Object> o = ((IokeList)IokeObject.data(on)).getList();
                    if(index < 0) {
                        index = o.size() + index;
                    }

                    if(index >= 0 && index < o.size()) {
                        return o.get((int)index);
                    } else {
                        return context.runtime.nil;
                    }
                }
            }));

        obj.aliasMethod("at", "[]", null, null);

        obj.registerMethod(runtime.newJavaMethod("takes two arguments, the index of the element to set, and the value to set. the index can be negative and will in that case set indexed from the end of the list. if the index is larger than the current size, the list will be expanded with nils. an exception will be raised if a abs(negative index) is larger than the size.", new TypeCheckingJavaMethod("at=") {
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                    .builder()
                    .receiverMustMimic(runtime.list)
                    .withRequiredPositional("index")
                    .withRequiredPositional("value")
                    .getArguments();

                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                    return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, final IokeObject context, final IokeObject message) throws ControlFlow {
                    Object arg = args.get(0);
                    Object value = args.get(1);
                    if(!(IokeObject.data(arg) instanceof Number)) {
                        arg = IokeObject.convertToNumber(arg, message, context);
                    }
                    int index = ((Number)IokeObject.data(arg)).asJavaInteger();
                    List<Object> o = ((IokeList)IokeObject.data(on)).getList();
                    if(index < 0) {
                        index = o.size() + index;
                    }

                    while(index < 0) {
                        final IokeObject condition = IokeObject.as(IokeObject.getCellChain(context.runtime.condition, 
                                                                                           message, 
                                                                                           context, 
                                                                                           "Error", 
                                                                                           "Index"), context).mimic(message, context);
                        condition.setCell("message", message);
                        condition.setCell("context", context);
                        condition.setCell("receiver", on);
                        condition.setCell("index", context.runtime.newNumber(index));

                        final int[] newCell = new int[]{index};

                        context.runtime.withRestartReturningArguments(new RunnableWithControlFlow() {
                                public void run() throws ControlFlow {
                                    context.runtime.errorCondition(condition);
                                }}, 
                            context,
                            new Restart.ArgumentGivingRestart("useValue") { 
                                public List<String> getArgumentNames() {
                                    return new ArrayList<String>(Arrays.asList("newValue"));
                                }

                                public IokeObject invoke(IokeObject context, List<Object> arguments) throws ControlFlow {
                                    newCell[0] = Number.extractInt(arguments.get(0), message, context);
                                    return context.runtime.nil;
                                }
                            }
                            );

                        index = newCell[0];
                        if(index < 0) {
                            index = o.size() + index;
                        }
                    }

                    if(index >= o.size()) {
                        int toAdd = (index-o.size()) + 1;
                        for(int i=0;i<toAdd;i++) {
                            o.add(context.runtime.nil);
                        }
                    }

                    o.set((int)index, value);

                    return value;
                }
            }));

        obj.aliasMethod("at=", "[]=", null, null);
        
        obj.registerMethod(runtime.newJavaMethod(
                "takes as argument the index of the element to be removed and returns it. can be " +
                "negative and will in that case index from the back of the list. if the index is " +
                "outside the bounds of the list, will return nil. the argument can also be a range, " +
                "and will in that case remove the sublist beginning at the first index and extending " +
                "to the position in the list specified by the second index (inclusive or exclusive " +
                "depending on the range). the end of the range can be negative and will in that case " +
                "index from the back of the list. if the start of the range is negative, or greater " +
                "than the end, an empty list will be returned. if the end index exceeds the bounds " +
                "of the list, its size will be used instead.", 
                new TypeCheckingJavaMethod("removeAt!") {
                	
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                	.builder()
                	.receiverMustMimic(runtime.list)
                	.withRequiredPositional("indexOrRange")
                	.getArguments();
            
                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                	return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                	Object arg = args.get(0);

                	if(IokeObject.data(arg) instanceof Range) {
                    
                		int first = Number.extractInt(Range.getFrom(arg), message, context); 
                		if(first < 0) {
                			return emptyList(context);
                		}

                		int last = Number.extractInt(Range.getTo(arg), message, context);
                		List<Object> receiver = getList(on);
                		int size = receiver.size();

                		if(last < 0) {
                			last = size + last;
                		}

                		if(last < 0) {
                			return emptyList(context);
                		}

                		boolean inclusive = Range.isInclusive(arg);
                    
                		if(last >= size) {                        
                			last = inclusive ? size-1 : size;
                		}

                		if(first > last || (!inclusive && first == last)) {
                			return emptyList(context);
                		}
                    
                		if(!inclusive) {
                			last--;
                		}
                    
                		List<Object> result = new ArrayList<Object>();
                		for(int i = 0; i <= last - first; i++) {
                			result.add(receiver.remove(first));
                		}
                    
                		return copyList(context, result);
                	}

                	if(!(IokeObject.data(arg) instanceof Number)) {
                		arg = IokeObject.convertToNumber(arg, message, context);
                	}
               
                	int index = ((Number)IokeObject.data(arg)).asJavaInteger();
                	List<Object> receiver = getList(on);
                	int size = receiver.size();
                
                	if(index < 0) {
                		index = size + index;
                	}

                	if(index >= 0 && index < size) {
                		return receiver.remove((int)index);
                	} else {
                		return context.runtime.nil;
                	}
                }
            }));
        
        obj.registerMethod(runtime.newJavaMethod(
                "takes one or more arguments. removes all occurrences of the provided arguments from " +
                "the list and returns the updated list. if an argument is not contained, the list " +
                "remains unchanged. sending this method to an empty list has no effect.", 
                new TypeCheckingJavaMethod("remove!") {
                	
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                	.builder()
                	.receiverMustMimic(runtime.list)
                	.withRequiredPositional("element")
                	.withRest("elements")
                	.getArguments();
            
                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                	return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                	List<Object> receiver = getList(on);
                	if(receiver.isEmpty()) {
                		return emptyList(context);
                	}
                	receiver.removeAll(args);
                	return copyList(context, receiver);
                }
            }));
        
        obj.registerMethod(runtime.newJavaMethod(
                "takes one or more arguments. removes the first occurrence of the provided arguments " +
                "from the list and returns the updated list. if an argument is not contained, the list " +
                "remains unchanged. arguments that are provided multiple times are treated as distinct " +
                "elements. sending this message to an empty list has no effect.", 
                new TypeCheckingJavaMethod("removeFirst!") {
                	
                private final TypeCheckingArgumentsDefinition ARGUMENTS = TypeCheckingArgumentsDefinition
                	.builder()
                	.receiverMustMimic(runtime.list)
                	.withRequiredPositional("element")
                	.withRest("elements")
                	.getArguments();
            
                @Override
                public TypeCheckingArgumentsDefinition getArguments() {
                	return ARGUMENTS;
                }

                @Override
                public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                	List<Object> receiver = getList(on);
                	if(receiver.isEmpty()) {
                		return emptyList(context);
                	}
                	for(Object o : args) {
                		receiver.remove(o);
                	}
                	return copyList(context, receiver);
                }
            }));
    }

    public void add(Object obj) {
        list.add(obj);
    }

    public List<Object> getList() {
        return list;
    }

    public static List<Object> getList(Object on) {
        return ((IokeList)(IokeObject.data(on))).getList();
    }

    public static String getInspect(Object on) throws ControlFlow {
        return ((IokeList)(IokeObject.data(on))).inspect(on);
    }

    public static String getNotice(Object on) throws ControlFlow {
        return ((IokeList)(IokeObject.data(on))).notice(on);
    }
    
    public static IokeObject emptyList(IokeObject context) {
    	return context.runtime.newList(new ArrayList<Object>());
    }
    
    public static IokeObject copyList(IokeObject context, List<Object> orig) {
    	return context.runtime.newList(new ArrayList<Object>(orig));
    }

    public IokeData cloneData(IokeObject obj, IokeObject m, IokeObject context) {
        return new IokeList(new ArrayList<Object>(list));
    }

    @Override
    public boolean isEqualTo(IokeObject self, Object other) {
        return ((other instanceof IokeObject) && 
                (IokeObject.data(other) instanceof IokeList) 
                && this.list.equals(((IokeList)IokeObject.data(other)).list));
    }

    @Override
    public int hashCode(IokeObject self) {
        return this.list.hashCode();
    }

    @Override
    public String toString() {
        return list.toString();
    }

    @Override
    public String toString(IokeObject obj) {
        return list.toString();
    }

    public String inspect(Object obj) throws ControlFlow {
        StringBuilder sb = new StringBuilder();
        sb.append("[");
        String sep = "";
        for(Object o : list) {
            sb.append(sep).append(IokeObject.inspect(o));
            sep = ", ";
        }
        sb.append("]");
        return sb.toString();
    }

    public String notice(Object obj) throws ControlFlow {
        StringBuilder sb = new StringBuilder();
        sb.append("[");
        String sep = "";
        for(Object o : list) {
            sb.append(sep).append(IokeObject.notice(o));
            sep = ", ";
        }
        sb.append("]");
        return sb.toString();
    }
}// IokeList
