/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public interface AssociatedCode {
    public IokeObject getCode();
    public String getArgumentsCode();
    public String getFormattedCode(Object self) throws ControlFlow;
}// AssociatedCode
