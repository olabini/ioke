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

    public RegexpMatch(IokeObject regexp, MatchResult mr) {
        this.regexp = regexp;
        this.mr = mr;
    }

    @Override
    public void init(IokeObject obj) throws ControlFlow {
        final Runtime runtime = obj.runtime;
        obj.setKind("Regexp Match");
    }
}
