/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang.parser;

import ioke.lang.IokeObject;

/**
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
final class Level {
    final int precedence;
    final IokeObject operatorMessage;
    final Level parent;
    final boolean unary;
    final boolean assignment;
    final boolean inverted;

    Level(int precedence, IokeObject op, Level parent, boolean unary, boolean assignment, boolean inverted) {
        this.precedence = precedence;
        this.operatorMessage = op;
        this.parent = parent;
        this.unary = unary;
        this.assignment = assignment;
        this.inverted = inverted;
    }
}// Level
