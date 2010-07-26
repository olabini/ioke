/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang.parser;

import ioke.lang.IokeObject;

/**
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
final class BufferedChain {
    final BufferedChain parent;
    final IokeObject last;
    final IokeObject head;

    BufferedChain(BufferedChain parent, IokeObject last, IokeObject head) {
        this.parent = parent;
        this.last = last;
        this.head = head;
    }
}// BufferedChain
