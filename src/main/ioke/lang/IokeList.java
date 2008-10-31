/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.ArrayList;
import java.util.List;

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
    public void init(IokeObject obj) {
        final Runtime runtime = obj.runtime;

        obj.setKind("List");
        obj.mimics(IokeObject.as(runtime.mixins.getCell(null, null, "Enumerable")), runtime.nul, runtime.nul);
        
        obj.registerMethod(runtime.newJavaMethod("takes one argument and adds it at the end of the list, and then returns the list", new JavaMethod("<<") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    Object arg = message.getEvaluatedArgument(0, context);
                    IokeList.add(on, arg);
                    return on;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("will remove all the entries from the list, and then returns the list", new JavaMethod("clear!") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    ((IokeList)IokeObject.data(on)).getList().clear();
                    return on;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns true if this list is empty, false otherwise", new JavaMethod("empty?") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    return ((IokeList)IokeObject.data(on)).getList().isEmpty() ? context.runtime._true : context.runtime._false;
                }
            }));

        obj.registerMethod(runtime.newJavaMethod("returns the size of this list", new JavaMethod("size") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    return context.runtime.newNumber(((IokeList)IokeObject.data(on)).getList().size());
                }
            }));
        obj.aliasMethod("size", "length");

        obj.registerMethod(runtime.newJavaMethod("takes one argument, the index of the element to be returned. can be negative, and will in that case return indexed from the back of the list. if the index is outside the bounds of the list, will return nil. ", new JavaMethod("at") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    Object arg = message.getEvaluatedArgument(0, context);
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

        obj.aliasMethod("at", "[]");

        obj.registerMethod(runtime.newJavaMethod("takes two arguments, the index of the element to set, and the value to set. the index can be negative and will in that case set indexed from the end of the list. if the index is larger than the current size, the list will be expanded with nils. an exception will be raised if a abs(negative index) is larger than the size.", new JavaMethod("at=") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    Object arg = message.getEvaluatedArgument(0, context);
                    Object value = message.getEvaluatedArgument(1, context);
                    if(!(IokeObject.data(arg) instanceof Number)) {
                        arg = IokeObject.convertToNumber(arg, message, context);
                    }
                    int index = ((Number)IokeObject.data(arg)).asJavaInteger();
                    List<Object> o = ((IokeList)IokeObject.data(on)).getList();
                    if(index < 0) {
                        index = o.size() + index;
                    }

                    if(index < 0) {
                        throw new RuntimeException("index " + arg + " out of bounds on " + on);
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

        obj.aliasMethod("at=", "[]=");
    }

    public void add(Object obj) {
        list.add(obj);
    }

    public List<Object> getList() {
        return list;
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
    public String toString() {
        return list.toString();
    }

    @Override
    public String toString(IokeObject obj) {
        return list.toString();
    }

    @Override
    public String representation(IokeObject obj) {
        StringBuilder sb = new StringBuilder();
        sb.append("[");
        String sep = "";
        for(Object o : list) {
            sb.append(sep).append(IokeObject.representation(o));
            sep = ", ";
        }
        sb.append("]");
        return sb.toString();
    }
}// IokeList
