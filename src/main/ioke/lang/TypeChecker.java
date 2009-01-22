/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public interface TypeChecker {
    public Object convertToMimic(Object on, IokeObject message, IokeObject context, boolean signal) throws ControlFlow;

    public static final TypeChecker None = new TypeChecker() {
            public Object convertToMimic(Object on, IokeObject message, IokeObject context, boolean signal) {
                return on;
            }
        };

    public static final TypeChecker Nil = new TypeChecker() {
            public Object convertToMimic(Object on, IokeObject message, IokeObject context, boolean signal) throws ControlFlow {
                if(on == context.runtime.nil) {
                    return on;
                } else if(signal) {
                    return context.runtime.nil.convertToThis(on, message, context);
                } else {
                    return context.runtime.nul;
                }
            }
        };

    public static class Or implements TypeChecker {
        public final TypeChecker first;
        public final TypeChecker second;
        public Or(TypeChecker first, TypeChecker second) {
            this.first = first;
            this.second = second;
        }

        public Object convertToMimic(Object on, IokeObject message, IokeObject context, boolean signal) throws ControlFlow {
            Object firstResult = first.convertToMimic(on, message, context, false);
            if(firstResult == context.runtime.nul) {
                return second.convertToMimic(on, message, context, signal);
            } else {
                return firstResult;
            }
        }
    }
}// TypeChecker
