/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang.parser;

import java.io.Reader;
import java.io.LineNumberReader;

import ioke.lang.IokeObject;
import ioke.lang.Message;
import ioke.lang.Runtime;
import ioke.lang.Dict;
import ioke.lang.Number;
import ioke.lang.Symbol;
import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class IokeParser {
    private final Runtime runtime;
    private final LineNumberReader reader;

    public IokeParser(Runtime runtime, Reader reader) {
        this.runtime = runtime;
        this.reader = new LineNumberReader(reader);
    }

    public IokeObject parseFully() {
        IokeObject result = parseExpressionChain();
        return result;
    }

    private IokeObject parseExpressionChain() {
        IokeObject c = null;
        IokeObject last = null;
        IokeObject head = null;

        while((c = parseExpression()) != null) {
            if(head == null) {
                head = c;
                last = c;
            } else {
                attach(last, c);
                last = c;
            }
        }

        return head;
    }

    private int lastRead;

    private IokeObject parseExpression() {
        int rr;
        while(true) {
            lastRead = rr = reader.read();
            switch(rr) {
            case '(':
                break;
            case '[':
                break;
            case '{':
                break;
            case '#':
                break;
            case '"':
                break;
            case '0':
            case '1':
            case '2':
            case '3':
            case '4':
            case '5':
            case '6':
            case '7':
            case '8':
            case '9':
                break;
            case '.':
                break;
            case ';':
                break;
            case ' ':
            case '\u0009':
            case '\u000b':
            case '\u000c':
                break;
            case '\\':
                break;
            case '\n':
            case '\r':
                break;
            case '+':
            case '-':
            case '*':
            case '%':
            case '<':
            case '>':
            case '!':
            case '?':
            case '~':
            case '&':
            case '|':
            case '^':
            case '$':
            case '=':
            case '@':
            case '\'':
            case '`':
                break;
            case '/':
                break;
            case ':':
                break;
            default:
                break;
            }
        }
    }
}
