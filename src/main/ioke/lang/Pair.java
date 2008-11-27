/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Pair extends IokeData {
    private Object first;
    private Object second;

    public Pair(Object first, Object second) {
        this.first = first;
        this.second = second;
    }

    public static Object getFirst(Object pair) {
        return ((Pair)IokeObject.data(pair)).getFirst();
    }

    public static Object getSecond(Object pair) {
        return ((Pair)IokeObject.data(pair)).getSecond();
    }

    public Object getFirst() {
        return first;
    }

    public Object getSecond() {
        return second;
    }

    @Override
    public void init(IokeObject obj) throws ControlFlow {
        final Runtime runtime = obj.runtime;

        obj.setKind("Pair");
        obj.mimics(IokeObject.as(runtime.mixins.getCell(null, null, "Enumerable")), runtime.nul, runtime.nul);
    }

    public IokeData cloneData(IokeObject obj, IokeObject m, IokeObject context) {
        return new Pair(first, second);
    }


    @Override
    public boolean isEqualTo(IokeObject self, Object other) {
        return ((other instanceof IokeObject) && 
                (IokeObject.data(other) instanceof Pair) 
                && this.first.equals(((Pair)IokeObject.data(other)).first)
                && this.second.equals(((Pair)IokeObject.data(other)).second));
    }

    @Override
    public String toString() {
        return "" + first + " => " + second;
    }

    @Override
    public String toString(IokeObject obj) {
        return "" + first + " => " + second;
    }

//     @Override
//     public String inspect(IokeObject obj) {
//         StringBuilder sb = new StringBuilder();

//         sb.append(IokeObject.inspect(first));
//         sb.append(" => ");
//         sb.append(IokeObject.inspect(second));

//         return sb.toString();
//     }
}// Pair
