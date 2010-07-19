/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang.performance;

import java.io.*;

import ioke.lang.*;
import ioke.lang.parser.*;

/**
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Parsing {
    public static void main(String[] args) throws Exception, ioke.lang.exceptions.ControlFlow {
        String filename = args[0];
        System.out.println("Reading of file: \"" + filename + "\"");

        File f = new File(filename);
        InputStream reader = new FileInputStream(f);
        byte[] result = new byte[(int)f.length()];

        int offset = 0;
        int numRead = 0;
        while(offset < result.length && (numRead = reader.read(result, offset, result.length-offset)) >= 0) {
            offset += numRead;
        }
        reader.close();

        long before, after, time;
        double timeS;

        ioke.lang.Runtime runtime = new ioke.lang.Runtime();
        runtime.init();
        for(int j=0;j<10;j++) {
            before = System.currentTimeMillis();
            for(int i=0;i<100;i++) {
                IokeParser parser = new IokeParser(runtime, new InputStreamReader(new ByteArrayInputStream(result)), null, null);
                IokeObject m = parser.parseFully();
                ((Message)IokeObject.data(m.runtime.opShuffle)).sendTo(m.runtime.opShuffle, m.runtime.ground, m);
            }
            after = System.currentTimeMillis();
            time = after-before;
            timeS = (after-before)/1000.0;
            System.out.printf(" %-10d %-10f\n", time, timeS); 
        }
    }
}// Parsing

