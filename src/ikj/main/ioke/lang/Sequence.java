/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import ioke.lang.exceptions.ControlFlow;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Iterator;

public class Sequence {
    public static class IteratorSequence extends IokeData {
        private final Iterator<Object> iter;
        public IteratorSequence(Iterator<Object> iter) {
            this.iter = iter;
        }

        @Override
        public void init(final IokeObject obj) throws ControlFlow {
            obj.setKind("Sequence Iterator");
            obj.mimicsWithoutCheck(obj.runtime.sequence);

            obj.registerMethod(obj.runtime.newNativeMethod("returns the next object from this sequence if it exists. the behavior otherwise is undefined", new TypeCheckingNativeMethod.WithNoArguments("next", obj) {
                    @Override
                    public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                        return ((IteratorSequence)IokeObject.data(on)).iter.next();
                    }
                }));

            obj.registerMethod(obj.runtime.newNativeMethod("returns true if there is another object in this sequence.", new TypeCheckingNativeMethod.WithNoArguments("next?", obj) {
                    @Override
                    public Object activate(IokeObject method, Object on, List<Object> args, Map<String, Object> keywords, IokeObject context, IokeObject message) throws ControlFlow {
                        return ((IteratorSequence)IokeObject.data(on)).iter.hasNext() ? method.runtime._true : method.runtime._false;
                    }
                }));
        }
    }

    public static void init(IokeObject obj) throws ControlFlow {
        final Runtime runtime = obj.runtime;
        obj.setKind("Sequence");
        obj.mimicsWithoutCheck(runtime.origin);
    }
}
