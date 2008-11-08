/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang.exceptions;

import java.util.Set;
import java.util.Collection;

import ioke.lang.IokeObject;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class MismatchedKeywords extends IokeException {
    public MismatchedKeywords(IokeObject m, Collection<String> expected, Collection<String> given, Object on, IokeObject context) {
        super(m, m.getName() + " expected these keywords arguments: " + expected + " but got: " + given, on, context);
    }
}// MismatchedKeywords
