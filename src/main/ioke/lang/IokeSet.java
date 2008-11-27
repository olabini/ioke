/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.HashSet;
import java.util.Set;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class IokeSet extends IokeData {
    private Set<Object> set;

    public IokeSet() {
        this(new HashSet<Object>());
    }

    public IokeSet(Set<Object> s) {
        this.set = s;
    }

    @Override
    public void init(IokeObject obj) throws ControlFlow {
        final Runtime runtime = obj.runtime;

        obj.setKind("Set");
        obj.mimics(IokeObject.as(runtime.mixins.getCell(null, null, "Enumerable")), runtime.nul, runtime.nul);
    }

    public Set<Object> getSet() {
        return set;
    }

    public IokeData cloneData(IokeObject obj, IokeObject m, IokeObject context) {
        return new IokeSet(new HashSet<Object>(set));
    }

    @Override
    public boolean isEqualTo(IokeObject self, Object other) {
        return ((other instanceof IokeObject) && 
                (IokeObject.data(other) instanceof IokeSet) 
                && this.set.equals(((IokeSet)IokeObject.data(other)).set));
    }

    @Override
    public String toString() {
        return set.toString();
    }

    @Override
    public String toString(IokeObject obj) {
        return set.toString();
    }
}// IokeSet
