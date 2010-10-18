/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang.parser;

import ioke.lang.IokeObject;

/**
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
final class Level {
    public static enum Type {
        REGULAR, UNARY, ASSIGNMENT, INVERTED
    }

    final int precedence;
    final IokeObject operatorMessage;
    final Level parent;
    final Type type;

    Level(int precedence, IokeObject op, Level parent, Type type) {
        this.precedence = precedence;
        this.operatorMessage = op;
        this.parent = parent;
        this.type = type;
    }

    public String toString() {
        return "Level<" + precedence + ", " + operatorMessage + ", " + type + ", " + parent + ">";
    }
}// Level
