/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang.parser;

import java.io.Reader;
import java.io.BufferedReader;
import java.io.IOException;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class LineAndCharReader extends BufferedReader {
    private int lineNumber = 0;
    private int currentCharacter = -1;
    private boolean skipLF;

    public LineAndCharReader(Reader in) {
        super(in);
    }

    public LineAndCharReader(Reader in, int sz) {
        super(in, sz);
    }

    public int getLineNumber() {
        return lineNumber;
    }

    public int getCharNumber() {
        return lineNumber;
    }

    public int read() throws IOException {
        int c = super.read();
        if (skipLF) {
            if(c == '\n') {
                c = super.read();
            }
            skipLF = false;
        }
        currentCharacter++;
        switch (c) {
        case '\r':
            skipLF = true;
        case '\n':		/* Fall through */
            lineNumber++;
            currentCharacter = 0;
            return '\n';
        }
        return c;
    }

    public int read(char cbuf[], int off, int len) throws IOException {
        int n = super.read(cbuf, off, len);

        for (int i = off; i < off + n; i++) {
            int c = cbuf[i];
            if (skipLF) {
                skipLF = false;
                if (c == '\n')
                    continue;
            }
            currentCharacter++;
            switch (c) {
            case '\r':
                skipLF = true;
            case '\n':	/* Fall through */
                lineNumber++;
                currentCharacter = 0;
                break;
            }
        }

        return n;
    }
}
