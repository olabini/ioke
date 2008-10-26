/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang.exceptions;

import java.util.Set;

import ioke.lang.IokeObject;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class MismatchedKeywords extends IokeException {
    public MismatchedKeywords(IokeObject m, Set<String> expected, Set<String> given, Object on, IokeObject context) {
        super(m, m.getName() + " expected these keywords arguments: " + expected + " but got: " + given, on, context);
    }
}// MismatchedKeywords
