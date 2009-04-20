/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang.util;

import java.util.AbstractSet;
import java.util.Collection;
import java.util.Map;
import java.util.Iterator;
import java.util.IdentityHashMap;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class IdentitySet<T> extends AbstractSet<T> {
    private final Map<T,Object> internal = new IdentityHashMap<T,Object>();

    public IdentitySet(Collection<? extends T> initialElements) {
        for(T t : initialElements) {
            internal.put(t, null);
        }
    }

    @Override
    public int size() {
        return internal.size();
    }

    @Override
    public Iterator<T> iterator() {
        return internal.keySet().iterator();
    }

    @Override
    public boolean add(T obj) {
        if(internal.containsKey(obj)) {
            return false;
        }
        internal.put(obj, null);
        return true;
    }

    @Override
    public boolean remove(Object obj) {
        if(internal.containsKey(obj)) {
            internal.remove(obj);
            return true;
        }
        return false;
    }

    @Override
    public boolean contains(Object obj) {
        return internal.containsKey(obj);
    }
}// IdentitySet
