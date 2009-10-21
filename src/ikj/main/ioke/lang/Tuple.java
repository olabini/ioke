/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.List;
import java.util.Map;
import java.util.HashMap;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Tuple extends IokeData {
    private final Object[] elements;

    public Tuple(Object[] elements) {
        this.elements = elements;
    }

    @Override
    public void init(IokeObject obj) throws ControlFlow {
        final Runtime runtime = obj.runtime;
        obj.setKind("Tuple");
        obj.mimicsWithoutCheck(runtime.origin);
        runtime.iokeGround.registerCell("Tuple", obj);
    }
}
