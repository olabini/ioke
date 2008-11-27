/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.Map;
import java.util.HashMap;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Dict extends IokeData {
    private Map<Object, Object> dict;

    public Dict() {
        this(new HashMap<Object, Object>());
    }

    public Dict(Map<Object, Object> d) {
        this.dict = d;
    }

    @Override
    public void init(IokeObject obj) throws ControlFlow {
        final Runtime runtime = obj.runtime;

        obj.setKind("Dict");
        obj.mimics(IokeObject.as(runtime.mixins.getCell(null, null, "Enumerable")), runtime.nul, runtime.nul);
    }

    public static Map<Object, Object> getMap(Object dict) {
        return ((Dict)IokeObject.data(dict)).getMap();
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
    public String toString() {
        return dict.toString();
    }

    @Override
    public String toString(IokeObject obj) {
        return dict.toString();
    }

//     @Override
//     public String inspect(IokeObject obj) {
//         StringBuilder sb = new StringBuilder();
//         sb.append("{");
//         String sep = "";
//         for(Map.Entry<Object, Object> o : dict.entrySet()) {
//             sb.append(sep).append(IokeObject.inspect(o.getKey()));
//             sb.append(" => ").append(IokeObject.inspect(o.getValue()));
//             sep = ", ";
//         }
//         sb.append("}");
//         return sb.toString();
//     }
}// Dict
