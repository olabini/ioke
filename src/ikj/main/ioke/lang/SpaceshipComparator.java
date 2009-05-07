/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.Comparator;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class SpaceshipComparator implements Comparator<Object> {
    private IokeObject context;
    private IokeObject message;

    public SpaceshipComparator(IokeObject context, IokeObject message) {
        this.context = context;
        this.message = message;
    }

    public int compare(Object one, Object two) {
        Runtime runtime = context.runtime;
        try {
            return Number.extractInt(((Message)IokeObject.data(runtime.spaceShip)).sendTo(runtime.spaceShip, context, one, two), message, context);
        } catch(ControlFlow e) {
            throw new RuntimeException(e);
        }
    }
}// SpaceshipComparator
