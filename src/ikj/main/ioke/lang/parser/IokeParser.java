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
    // TODO: line numbers yay!
    // TODO: good failures yay!

    private final Runtime runtime;
    private final LineNumberReader reader;

    public IokeParser(Runtime runtime, Reader reader) {
        this.runtime = runtime;
        this.reader = new LineNumberReader(reader);
    }

    public IokeObject parseFully() throws IOException {
        IokeObject result = parseExpressions();
        return result;
    }

    private IokeObject parseExpressions() throws IOException {
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

    private void parseCharacter(int c) {
        readWhiteSpace();
        int rr = read();
        if(rr != c) {
            fail();
        }
    }

    private IokeObject parseEmptyMessageSend() {
        List<Object> args = parseExpressionChain();
        parseCharacter(')');
        IokeObject mx = runtime.createMessage(new Message(runtime, ""));
        Message.setArguments(mx, args);
        return mx;
    }

    private IokeObject parseSquareMessageSend() {
        List<Object> args = parseExpressionChain();
        parseCharacter(']');
        IokeObject mx = runtime.createMessage(new Message(runtime, "[]"));
        Message.setArguments(mx, args);
        return mx;
    }

    private IokeObject parseCurlyMessageSend() {
        List<Object> args = parseExpressionChain();
        parseCharacter('}');
        IokeObject mx = runtime.createMessage(new Message(runtime, "{}"));
        Message.setArguments(mx, args);
        return mx;
    }

    private IokeObject parseSetMessageSend() {
        parseCharacter('{');
        List<Object> args = parseExpressionChain();
        parseCharacter('}');
        IokeObject mx = runtime.createMessage(new Message(runtime, "set"));
        Message.setArguments(mx, args);
        return mx;
    }

    private void parseComment() {
        int rr;
        while((rr = peek()) != '\n' && rr != '\r') {
            read();
        }
    }

    private final static String[] RANGES = {
        "",
        ".",
        "..",
        "...",
        "....",
        ".....",
        "......",
        ".......",
        "........",
        ".........",
        "..........",
        "...........",
        "............"
    };


    private IokeObject parseRange() {
        int count = 2;
        read();
        int rr;
        while((rr = peek()) == '.') {
            count++;
            read();
        }
        String result = null;
        if(count < 13) {
            result = RANGES[count];
        } else {
            StringBuilder sb = new StringBuilder();
            for(int i = 0; i<count; i++) {
                sb.append('.');
            }
            result = sb.toString();
        }

        Message m = new Message(runtime, result);
        return runtime.createMessage(m);
    }

    private IokeObject parseTerminator(int indicator) {
        int rr;
        if(indicator == '\r') {
            rr = peek();
            if(rr == '\n') {
                read();
            }
        }

        // TODO: should parse more than one terminator into one

        Message m = new Message(runtime, ".", null, Type.TERMINATOR);
        return runtime.createMessage(m);
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
        StringBuilder sb = new StringBuilder();
        sb.append((char)indicator);
        int rr;
        if(indicator == '#') {
            while(true) {
                rr = peek();
                switch(rr) {
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
                case ':':
                case '#':
                    read();
                sb.append((char)rr);
                break;
                default:
                    Message m = new Message(runtime, sb.toString());
                    return runtime.createMessage(m);
                }
            }
        } else {
            while(true) {
                rr = peek();
                switch(rr) {
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
                case ':':
                case '#':
                    read();
                sb.append((char)rr);
                break;
                default:
                    Message m = new Message(runtime, sb.toString());
                    return runtime.createMessage(m);
                }
            }
        }
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
        return ((c>='A' && c<='Z') ||
                c=='_' ||
                (c>='a' && c<='z') ||
                (c>='\u00C0' && c<='\u00D6') ||
                (c>='\u00D8' && c<='\u00F6') ||
                (c>='\u00F8' && c<='\u1FFF') ||
                (c>='\u2200' && c<='\u22FF') ||
                (c>='\u27C0' && c<='\u27EF') ||
                (c>='\u2980' && c<='\u2AFF') ||
                (c>='\u3040' && c<='\u318F') ||
                (c>='\u3300' && c<='\u337F') ||
                (c>='\u3400' && c<='\u3D2D') ||
                (c>='\u4E00' && c<='\u9FFF') ||
                (c>='\uF900' && c<='\uFAFF'));
    }

    private boolean isIDDigit(int c) {
        return ((c>='0' && c<='9') ||
                (c>='\u0660' && c<='\u0669') ||
                (c>='\u06F0' && c<='\u06F9') ||
                (c>='\u0966' && c<='\u096F') ||
                (c>='\u09E6' && c<='\u09EF') ||
                (c>='\u0A66' && c<='\u0A6F') ||
                (c>='\u0AE6' && c<='\u0AEF') ||
                (c>='\u0B66' && c<='\u0B6F') ||
                (c>='\u0BE7' && c<='\u0BEF') ||
                (c>='\u0C66' && c<='\u0C6F') ||
                (c>='\u0CE6' && c<='\u0CEF') ||
                (c>='\u0D66' && c<='\u0D6F') ||
                (c>='\u0E50' && c<='\u0E59') ||
                (c>='\u0ED0' && c<='\u0ED9') ||
                (c>='\u1040' && c<='\u1049'));
    }
}
