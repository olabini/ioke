/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang.parser;

import java.io.Reader;
import java.io.LineNumberReader;
import java.io.IOException;

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

    public IokeObject parseFully() throws IOException {
        IokeObject result = parseExpressionChain();
        return result;
    }

    private IokeObject parseExpressionChain() throws IOException {
        IokeObject c = null;
        IokeObject last = null;
        IokeObject head = null;

        while((c = parseExpression()) != null) {
            if(head == null) {
                head = c;
                last = c;
            } else {
                Message.setNext(last, c);
                Message.setPrev(c, last);
                last = c;
            }
        }

        return head;
    }


    private int saved = -2;
    private int read() throws IOException {
        if(saved > -2) {
            int x = saved;
            saved = -2;
            return saved;
        }
        return reader.read();
    }

    private int peek() throws IOException {
        if(saved == -2) {
            saved = reader.read();
        }
        return saved;
    }

    private IokeObject parseExpression() throws IOException {
        int rr;
        while(true) {
            rr = read();
            switch(rr) {
            case '(':
                return parseEmptyMessageSend();
            case '[':
                return parseSquareMessageSend();
            case '{':
                return parseCurlyMessageSend();
            case '#':
                switch(peek()) {
                case '{':
                    return parseSetMessageSend();
                case '/':
                    return parseRegexpLiteral('/');
                case '[':
                    return parseText('[');
                case 'r':
                    return parseRegexpLiteral('r');
                case '!':
                    parseComment();
                    break;
                default:
                    return parseOperatorChars('#');
                }
                break;
            case '"':
                return parseText('"');
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
                return parseNumber(rr);
            case '.':
                if((rr = peek()) == '.') {
                    return parseRange();
                } else if(rr >= '0' && rr <= '9') {
                    return parseNumber('.');
                } else {
                    return parseTerminator('.');
                }
            case ';':
                parseComment();
                break;
            case ' ':
            case '\u0009':
            case '\u000b':
            case '\u000c':
                break;
            case '\\':
                if((rr = peek()) == '\n') {
                    break;
                } else {
                    fail();
                }
            case '\r':
            case '\n':
                return parseTerminator(rr);
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
            case '/':
                return parseOperatorChars(rr);
            case ':':
                if(isLetter(rr = peek()) || isIDDigit(rr)) {
                    return parseIdentifier(':');
                } else {
                    return parseOperatorChars(':');
                }
            default:
                return parseIdentifier(rr);
            }
        }
    }

    private void fail() {
        throw new RuntimeException();
    }

    private IokeObject parseEmptyMessageSend() {
        // TODO: implement
        return null;
    }

    private IokeObject parseSquareMessageSend() {
        // TODO: implement
        return null;
    }

    private IokeObject parseCurlyMessageSend() {
        // TODO: implement
        return null;
    }

    private IokeObject parseSetMessageSend() {
        // TODO: implement
        return null;
    }

    private IokeObject parseComment() {
        // TODO: implement
        return null;
    }

    private IokeObject parseRange() {
        // TODO: implement
        return null;
    }

    private IokeObject parseTerminator(int indicator) {
        // TODO: implement
        return null;
    }

    private IokeObject parseRegexpLiteral(int indicator) {
        // TODO: implement
        return null;
    }

    private IokeObject parseText(int indicator) {
        // TODO: implement
        return null;
    }

    private IokeObject parseOperatorChars(int indicator) {
        // TODO: implement
        return null;
    }

    private IokeObject parseNumber(int indicator) {
        // TODO: implement
        return null;
    }

    private IokeObject parseIdentifier(int indicator) {
        // TODO: implement
        return null;
    }

    private boolean isLetter(int c) {
        // TODO: implement
        return false;
    }


    private boolean isIDDigit(int c) {
        // TODO: implement
        return false;
    }
}
