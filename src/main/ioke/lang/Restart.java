/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Restart {
    public static void init(IokeObject restart) throws ControlFlow {
        Runtime runtime = restart.runtime;
        restart.setKind("Restart");

        restart.registerCell("name", runtime.nil);
        restart.registerCell("report", runtime.evaluateString("fn(r, \"restart: \" + r name)"));
        restart.registerCell("test", runtime.evaluateString("fn(c, true)"));
        restart.registerCell("code", runtime.evaluateString("fn()"));
    }
}// Restart
