/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.Arrays;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.HashSet;
import java.util.Map;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.Collection;

import ioke.lang.exceptions.ControlFlow;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class DefaultArgumentsDefinitionArgs0 implements ArgumentsDefinition {
    public void assignArgumentValues(final IokeObject locals, final IokeObject context, final IokeObject message, final Object on, final Call call) throws ControlFlow {
        if(call.cachedPositional == null) {
            call.cachedArgCount = 0;
            call.cachedPositional = DefaultArgumentsDefinitionArgs1.assign(context, message, on, 0);
        }
    }

    public void assignArgumentValues(final IokeObject locals, final IokeObject context, final IokeObject message, final Object on) throws ControlFlow {
        DefaultArgumentsDefinitionArgs1.assign(context, message, on, 0);
    }

    public String getCode() {
        return getCode(true);
    }

    public String getCode(boolean lastComma) {
        return "";
    }

    public Collection<String> getKeywords() {
        return new ArrayList<String>();
    }

    public List<DefaultArgumentsDefinition.Argument> getArguments() {
        return new ArrayList<DefaultArgumentsDefinition.Argument>();
    }

    public boolean isEmpty() {
        return true;
    }

    public String getRestName() {
        return null;
    }

    public String getKrestName() {
        return null;
    }
}
