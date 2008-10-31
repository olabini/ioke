/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.ArrayList;
import java.util.List;

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

    @Override
    public void init(IokeObject obj) {
        final Runtime runtime = obj.runtime;

        obj.setKind("List");
        //        obj.mimics(IokeObject.as(runtime.mixins.getCell(null, null, "Enumerable")), runtime.nul, runtime.nul);
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
}// IokeList
