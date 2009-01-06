/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang;

import java.util.List;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Set;

import org.jregex.Matcher;
import org.jregex.Pattern;
import org.jregex.MatchIterator;
import org.jregex.MatchResult;

import ioke.lang.exceptions.ControlFlow;

/**
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class RegexpMatch extends IokeData {
    private IokeObject regexp;
    private MatchResult mr;
    private IokeObject target;

    public RegexpMatch(IokeObject regexp, MatchResult mr, IokeObject target) {
        this.regexp = regexp;
        this.mr = mr;
        this.target = target;
    }
    
    public static Object getTarget(Object on) throws ControlFlow {
        return ((RegexpMatch)IokeObject.data(on)).target;
    }

    @Override
    public void init(IokeObject obj) throws ControlFlow {
        final Runtime runtime = obj.runtime;
        obj.setKind("Regexp Match");

        obj.registerMethod(runtime.newJavaMethod("Returns the target that this match was created against", new JavaMethod.WithNoArguments("target") {
                @Override
                public Object activate(IokeObject method, IokeObject context, IokeObject message, Object on) throws ControlFlow {
                    getArguments().getEvaluatedArguments(context, message, on, new ArrayList<Object>(), new HashMap<String, Object>());
                    return getTarget(on);
                }
            }));
    }
}
