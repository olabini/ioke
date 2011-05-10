/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang.coverage;

import gnu.math.*;

import java.io.Reader;
import java.io.Writer;
import java.io.PrintWriter;
import java.io.StringReader;
import java.io.StringWriter;
import java.io.IOException;

import java.util.Arrays;
import java.util.ArrayList;
import java.util.List;
import java.util.ListIterator;
import java.util.LinkedList;
import java.util.Map;
import java.util.HashMap;
import java.util.Set;
import java.util.HashSet;

import ioke.lang.*;
import ioke.lang.exceptions.ControlFlow;

import ioke.lang.parser.*;
import static ioke.lang.parser.Operators.OpEntry;
import static ioke.lang.parser.Operators.OpArity;
import static ioke.lang.parser.Operators.DEFAULT_UNARY_OPERATORS;
import static ioke.lang.parser.Operators.DEFAULT_ONLY_UNARY_OPERATORS;

import static ioke.lang.coverage.CoverageInterpreter.CoveragePoint;

/**
 * Parser and unparser.
 *
 * Right now this tightly couples and hard codes the HTML output, but that won't happen in the future
 * This should really be in Ioke, but since it's basically a copy-paste of the existing parser, that is in Java,
 * I couldn't be bothered.
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class CoverageParser extends IokeParser {
    private final Map<String, CoveragePoint> coverageInfo;
    private final PrintWriter realOutput;
    private final StringWriter soutput;
    private final PrintWriter output;
    private final String filename;

    public CoverageParser(ioke.lang.Runtime runtime, Reader reader, IokeObject context, IokeObject message, String filename, Map<String, CoveragePoint> coverageInfo, Writer output) throws ControlFlow {
        super(runtime, reader, context, message);
        this.coverageInfo = coverageInfo;
        this.realOutput = new PrintWriter(output);
        this.filename = filename;
        this.soutput = new StringWriter();
        this.output = new PrintWriter(soutput);
    }

    public int percentageComplete;
    public int percentagePartial;
    public int percentageMessages;
    
    public IokeObject ratioComplete;
    public IokeObject ratioPartial;
    public IokeObject ratioMessages;

    public void unparse() {
        try {
            parseFully();
            endLine();

            realOutput.println("<html>");
            realOutput.println("  <head>");
            realOutput.println("    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\"/>"); 
            realOutput.println("    <title>Coverage Report</title>");
            realOutput.println("    <link title=\"Style\" type=\"text/css\" rel=\"stylesheet\" href=\"main.css\"/>");
            realOutput.println("  </head>");
            realOutput.println("  <body>");
            realOutput.println("    <h5>Coverage Report - " + filename + "</h5>");
            realOutput.println("    <div class=\"separator\">&nbsp;</div>");
            realOutput.println("    <table class=\"report\">");
            realOutput.println("      <thead>");
            realOutput.println("        <tr>");
            realOutput.println("          <td class=\"heading\">");
            realOutput.println("            Complete Line Coverage");
            realOutput.println("          </td>");
            realOutput.println("          <td class=\"heading\">");
            realOutput.println("            Partial Line Coverage");
            realOutput.println("          </td>");
            realOutput.println("          <td class=\"heading\">");
            realOutput.println("            Message Coverage");
            realOutput.println("          </td>");
            realOutput.println("        </tr>");
            realOutput.println("      </thead>");
            realOutput.println("      <tr>");

            percentageComplete = linesCompletelyCovered * 100 / linesWithContent;
            percentagePartial = linesPartiallyCovered * 100 / linesWithContent;
            percentageMessages = numberOfCovered * 100 / messages;

            ratioComplete = runtime.newNumber(RatNum.make(IntNum.make(linesCompletelyCovered), IntNum.make(linesWithContent)));
            ratioPartial = runtime.newNumber(RatNum.make(IntNum.make(linesPartiallyCovered), IntNum.make(linesWithContent)));
            ratioMessages = runtime.newNumber(RatNum.make(IntNum.make(numberOfCovered), IntNum.make(messages)));

            realOutput.println("        <td>");
            realOutput.println("          <table cellpadding=\"0px\" cellspacing=\"0px\" class=\"percentgraph\">");
            realOutput.println("            <tr class=\"percentgraph\">");
            realOutput.println("              <td align=\"right\" class=\"percentgraph\" width=\"40\">" + percentageComplete + "%</td>");
            realOutput.println("              <td class=\"percentgraph\">");
            realOutput.println("                <div class=\"percentgraph\">");
            realOutput.println("                  <div class=\"greenbar\" style=\"width:" + percentageComplete + " px\">");
            realOutput.println("                    <span class=\"text\">" + ratioComplete + "</span>");
            realOutput.println("                  </div>");
            realOutput.println("                </div>");
            realOutput.println("              </td>");
            realOutput.println("            </tr>");
            realOutput.println("          </table>");
            realOutput.println("        </td>");
            realOutput.println("        <td>");
            realOutput.println("          <table cellpadding=\"0px\" cellspacing=\"0px\" class=\"percentgraph\">");
            realOutput.println("            <tr class=\"percentgraph\">");
            realOutput.println("              <td align=\"right\" class=\"percentgraph\" width=\"40\">" + percentagePartial + "%</td>");
            realOutput.println("              <td class=\"percentgraph\">");
            realOutput.println("                <div class=\"percentgraph\">");
            realOutput.println("                  <div class=\"greenbar\" style=\"width:" + percentagePartial + "px\">");
            realOutput.println("                    <span class=\"text\">" + ratioPartial + "</span>");
            realOutput.println("                  </div>");
            realOutput.println("                </div>");
            realOutput.println("              </td>");
            realOutput.println("            </tr>");
            realOutput.println("          </table>");
            realOutput.println("        </td>");
            realOutput.println("        <td>");
            realOutput.println("          <table cellpadding=\"0px\" cellspacing=\"0px\" class=\"percentgraph\">");
            realOutput.println("            <tr class=\"percentgraph\">");
            realOutput.println("              <td align=\"right\" class=\"percentgraph\" width=\"40\">" + percentageMessages + "%</td>");
            realOutput.println("              <td class=\"percentgraph\">");
            realOutput.println("                <div class=\"percentgraph\">");
            realOutput.println("                  <div class=\"greenbar\" style=\"width:" + percentageMessages + "px\">");
            realOutput.println("                    <span class=\"text\">" + ratioMessages + "</span>");
            realOutput.println("                  </div>");
            realOutput.println("                </div>");
            realOutput.println("              </td>");
            realOutput.println("            </tr>");
            realOutput.println("          </table>");
            realOutput.println("        </td>");
            realOutput.println("      </tr>");
            realOutput.println("    </table>");
            realOutput.println("    <div class=\"separator\">&nbsp;</div>");
            realOutput.println("    <table cellpadding='0' cellspacing='0' class='src'>");

            realOutput.write(soutput.toString());

            realOutput.println("    </table>");
            realOutput.println("  </body>");
            realOutput.println("</html>");
            realOutput.flush();
        } catch(Throwable e) {
            System.err.println(e);
            e.printStackTrace();
        }
    }

    public int messages = 0;
    public int numberOfUncovered = 0;
    public int numberOfCovered = 0;

    public static class CoverageOutput {
        public String css;
        public int coverageCount;
        public String name;

        public CoverageOutput(String css, int coverageCount, String name) {
            this.css = css;
            this.coverageCount = coverageCount;
            this.name = name;
        }
    }

    public List<CoverageOutput> currentLine = new LinkedList<CoverageOutput>();
    public CoverageOutput last = null;
    public CoverageOutput lastMessage = null;

    public int registerMessage(int line, int pos) {
        CoveragePoint cp = coverageInfo.get("" + line + ":" + pos);
        messages++;
        if(cp == null || cp.count == 0) {
            numberOfUncovered++;
            return 0;
        } else {
            numberOfCovered++;
            return cp.count;
        }
    }

    public String messageSendClass(int coverage) {
        if(coverage == 0) {
            return "srcUncovered";
        } else {
            return "green";
        }
    }

    private String nothingClass(char cc) {
        switch(cc) {
        case ',':
        case ')':
        case '(':
        case ']':
        case '}':
            return "nothing";
        }
        return null;
    }

    private static final Set<String> KEYWORDS = new HashSet<String>(Arrays.asList("if", "true", "false", "nil", "method", "unless", "use", "macro", "fn", "fnx"));

    public int linesWithContent = 0;
    public int linesPartiallyCovered = 0;
    public int linesCompletelyCovered = 0;

    private void endLine() {
        int maxCountForLine = 0;
        boolean someGood = false;
        boolean someBad = false;
        boolean someCover = false;
        for(CoverageOutput co : currentLine) {
            if(co.css != null && co.coverageCount > -1) {
                if(co.coverageCount > maxCountForLine) {
                    maxCountForLine = co.coverageCount;
                }
                if(co.coverageCount > 0) {
                    someGood = true;
                } else {
                    someBad = true;
                }
                someCover = true;
            }
        }

        if(someCover) {
            linesWithContent++;

            if(someGood && !someBad) {
                linesCompletelyCovered++;
                linesPartiallyCovered++;
            } else if(someGood && someBad) {
                linesPartiallyCovered++;
            }
        }

        String clzz1 = someCover ? "numLineCover" : "numLine";
        String clzz2 = someGood ? (someBad ? "nbHits" : "nbHitsCovered") : "nbHitsUncovered";
        String maxCount = "" + maxCountForLine;
        if(!someCover) {
            clzz2 = "nbHits";
            maxCount = "";
        }
        output.print("<tr><td class=\"" + clzz1 + "\">&nbsp;" + (lineNumber-1) + "</td><td class=\"" + clzz2 + "\">&nbsp;" + maxCount + "</td><td class=\"src\"><pre class=\"src\">&nbsp;");

        CoverageOutput last = null;
        boolean lastBad = false;

        for(CoverageOutput co : currentLine) {
            if(lastBad && co.coverageCount > 0) {
                output.print("</span>");
                lastBad = false;
            }

            if(!lastBad && (co.css != null && !co.css.equals("comment") && co.coverageCount == 0)) {
                output.print("<span class=\"srcUncovered\">");
                lastBad = true;
            }

            if(co.css == null) {
                output.print(co.name);
            } else {
                output.print("<span");
                if(co.coverageCount > -1) {
                    output.print(" data-coverage-count=\"" + co.coverageCount + "\"");
                } 
                if(KEYWORDS.contains(co.name)) {
                    output.print(" class=\"keyword\"");
                }
                output.print(" class=\"");
                output.print(co.css);
                output.print("\">");


                output.print(co.name);
                output.print("</span>");
            }
        }
        if(lastBad) {
            output.print("</span>");
        }
        currentLine = new LinkedList<CoverageOutput>();
        last = null;
        lastMessage = null;
        output.print("</pre></td></tr>\n"); 
    }

    private void addOutput(String css, int coverage, String output) {
        CoverageOutput co = new CoverageOutput(css, coverage, output);
        currentLine.add(co);
        last = co;
        if(css != null && !css.equals("comment")) {
            lastMessage = co;
        }
    }

    private void addOutput(String name, int coverage, char output) {
        addOutput(name, coverage, "" + output);
    }

    private void addOutput(String name, char output) {
        addOutput(name, -1, "" + output);
    }

    private void addOutput(String output) {
        if(last != null && (last.css == null || last.css.equals("comment"))) {
            last.name += output;
        } else {
            CoverageOutput co = new CoverageOutput(null, -1, output);
            currentLine.add(co);
            last = co;
        }
    }

    private void addOutput(char output) {
        addOutput("" + output);
    }

    @Override
    protected List<Object> parseCommaSeparatedMessageChains() throws IOException, ControlFlow {
        ArrayList<Object> chain = new ArrayList<Object>();

        IokeObject curr = parseMessageChain();
        while(curr != null) {
            chain.add(curr);
            readWhiteSpace();
            int rr = peek();
            if(rr == ',') {
                read();
                addOutput(nothingClass((char)rr), ',');
                curr = parseMessageChain();
                if(curr == null) {
                    fail("Expected expression following comma");
                }
            } else {
                if(curr != null && Message.isTerminator(curr) && Message.next(curr) == null) {
                    chain.remove(chain.size()-1);
                }
                curr = null;
            }
        }

        return chain;
    }

    @Override
    protected boolean parseMessage() throws IOException, ControlFlow {
        int rr;
        while(true) {
            rr = peek();
            switch(rr) {
            case -1:
                read();
                return false;
            case ',':
            case ')':
            case ']':
            case '}':
                return false;
            case '(':
                read();
                parseEmptyMessageSend();
                return true;
            case '[':
                read();
                parseOpenCloseMessageSend(']', "[]", '[');
                return true;
            case '{':
                read();
                parseOpenCloseMessageSend('}', "{}", '{');
                return true;
            case '#':
                read();
                switch(peek()) {
                case '{':
                    parseSimpleOpenCloseMessageSend('}', "set");
                    return true;
                case '/':
                    parseRegexpLiteral('/');
                    return true;
                case '[':
                    parseText('[');
                    return true;
                case 'r':
                    parseRegexpLiteral('r');
                    return true;
                case '!':
                    addOutput("comment", -1, "#!");
                    parseComment();
                    break;
                default:
                    parseOperatorChars('#');
                    return true;
                }
                break;
            case '"':
                read();
                parseText('"');
                return true;
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
                read();
                parseNumber(rr);
                return true;
            case '.':
                read();
                if((rr = peek()) == '.') {
                    parseRange();
                } else {
                    parseTerminator('.');
                }
                return true;
            case ';':
                read();
                addOutput("comment", -1, ";");
                parseComment();
                break;
            case ' ':
            case '\u0009':
            case '\u000b':
            case '\u000c':
                addOutput((char)rr);
                read();
                readWhiteSpace();
                break;
            case '\\':
                read();
                if((rr = peek()) == '\n') {
                    read();
                    break;
                } else {
                    fail("Expected newline after free-floating escape character");
                }
            case '\r':
            case '\n':
                read();
                endLine();
                parseTerminator(rr);
                return true;
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
                read();
                parseOperatorChars(rr);
                return true;
            case ':':
                read();
                if(isLetter(rr = peek()) || isIDDigit(rr)) {
                    parseRegularMessageSend(':');
                } else {
                    parseOperatorChars(':');
                }
                return true;
            default:
                read();
                parseRegularMessageSend(rr);
                return true;
            }
        }
    }

    protected void possibleOperator(IokeObject mx, int coverage) throws ControlFlow {
        String name = Message.name(mx);

        if(isUnary(name) || onlyUnaryOperators.contains(name)) {
            top.add(mx);
            top.push(-1, mx, Level.Type.UNARY);
            return;
        }

        OpEntry op = operatorTable.get(name);
        if(op != null) {
            top.popOperatorsTo(op.precedence);
            top.add(mx);
            top.push(op.precedence, mx, Level.Type.REGULAR);
        } else {
            OpArity opa = trinaryOperatorTable.get(name);
            if(opa != null) {
                if(lastMessage != null) {
                    lastMessage.css = messageSendClass(coverage);
                    lastMessage.coverageCount = coverage;
                }

                if(opa.arity == 2) {
                    IokeObject last = top.prepareAssignmentMessage();
                    mx.getArguments().add(last);
                    top.add(mx);
                    top.push(13, mx, Level.Type.ASSIGNMENT);
                } else {
                    IokeObject last = top.prepareAssignmentMessage();
                    mx.getArguments().add(last);
                    top.add(mx);
                }
            } else {
                op = invertedOperatorTable.get(name);
                if(op != null) {
                    top.popOperatorsTo(op.precedence);
                    top.add(mx);
                    top.push(op.precedence, mx, Level.Type.INVERTED);
                } else {
                    int possible = possibleOperatorPrecedence(name);
                    if(possible != -1) {
                        top.popOperatorsTo(possible);
                        top.add(mx);
                        top.push(possible, mx, Level.Type.REGULAR);
                    } else {
                        top.add(mx);
                    }
                }
            }
        }
    }

    @Override
    protected void parseEmptyMessageSend() throws IOException, ControlFlow {
        int l = lineNumber; int cc = currentCharacter-1;
        addOutput(nothingClass('('), '(');
        List<Object> args = parseCommaSeparatedMessageChains();
        parseCharacter(')');
        addOutput(nothingClass(')'), ')');

        Message m = new Message(runtime, "");
        m.setLine(l);
        m.setPosition(cc);

        registerMessage(l, cc);

        IokeObject mx = runtime.createMessage(m);
        Message.setArguments(mx, args);
        top.add(mx);
    }

    protected void parseOpenCloseMessageSend(char end, String name, char start) throws IOException, ControlFlow {
        int l = lineNumber; int cc = currentCharacter-1;

        int rr = peek();
        int r2 = peek2();

        Message m = new Message(runtime, name);
        m.setLine(l);
        m.setPosition(cc);

        int coverage = registerMessage(l, cc);

        IokeObject mx = runtime.createMessage(m);
        if(rr == end && r2 == '(') {
            addOutput(messageSendClass(coverage), coverage, "" + start + end);
            addOutput(nothingClass((char)r2), (char)r2);
            read();
            read();
            List<Object> args = parseCommaSeparatedMessageChains();
            parseCharacter(')');
            addOutput(nothingClass(')'), ')');
            Message.setArguments(mx, args);
        } else {
            addOutput(messageSendClass(coverage), coverage, start);
            List<Object> args = parseCommaSeparatedMessageChains();
            parseCharacter(end);
            addOutput(messageSendClass(coverage), coverage, end);
            Message.setArguments(mx, args);
        }

        top.add(mx);
    }

    @Override
    protected void parseSimpleOpenCloseMessageSend(char end, String name) throws IOException, ControlFlow {
        int l = lineNumber; int cc = currentCharacter-1;

        int coverage = registerMessage(l, cc);

        addOutput(messageSendClass(coverage), coverage, (char)read());

        List<Object> args = parseCommaSeparatedMessageChains();
        parseCharacter(end);

        addOutput(messageSendClass(coverage), coverage, end);

        Message m = new Message(runtime, name);
        m.setLine(l);
        m.setPosition(cc);


        IokeObject mx = runtime.createMessage(m);
        Message.setArguments(mx, args);

        top.add(mx);
    }

    @Override
    protected void parseComment() throws IOException {
        int rr;
        while((rr = peek()) != '\n' && rr != '\r' && rr != -1) {
            addOutput((char)rr);
            read();
        }
    }

    @Override
    protected void parseRange() throws IOException, ControlFlow {
        int l = lineNumber; int cc = currentCharacter-1;

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
        m.setLine(l);
        m.setPosition(cc);
        IokeObject mx = runtime.createMessage(m);
        int coverage = registerMessage(l, cc);

        if(rr == '(') {
            addOutput(messageSendClass(coverage), coverage, result);
            read();
            addOutput(nothingClass((char)rr), (char)rr);
            List<Object> args = parseCommaSeparatedMessageChains();
            parseCharacter(')');
            addOutput(nothingClass(')'), ')');
            Message.setArguments(mx, args);
            top.add(mx);
        } else {
            possibleOperator(mx, coverage);
            addOutput(messageSendClass(coverage), coverage, result);
        }
    }

    @Override
    protected void parseTerminator(int indicator) throws IOException, ControlFlow  {
        int l = lineNumber; int cc = currentCharacter-1;

        int rr;
        int rr2;
        if(indicator == '\r') {
            rr = peek();
            if(rr == '\n') {
                endLine();
                read();
            }
        }

        while(true) {
            rr = peek();
            rr2 = peek2();
            if((rr == '.' && rr2 != '.') ||
               (rr == '\n')) {
                if(rr == '\n') {
                    endLine();
                } else {
                    addOutput(nothingClass((char)rr), (char)rr);
                }

                read();
            } else if(rr == '\r' && rr2 == '\n') {
                endLine();
                read(); read();
            } else {
                break;
            }
        }
        
        if(!(top.last == null && top.currentLevel.operatorMessage != null)) {
            top.popOperatorsTo(999999);
        }

        Message m = new Message(runtime, ".", null, true);
        m.setLine(l);
        m.setPosition(cc);
        top.add(runtime.createMessage(m));
    }

    @Override
    protected void readWhiteSpace() throws IOException {
        int rr;
        while((rr = peek()) == ' ' ||
              rr == '\u0009' ||
              rr == '\u000b' ||
              rr == '\u000c') {
            addOutput((char)rr);
            read();
        }
    }

    @Override
    protected void parseRegexpLiteral(int indicator) throws IOException, ControlFlow {
        StringBuilder sb = new StringBuilder();
        boolean slash = indicator == '/';

        int l = lineNumber; int cc = currentCharacter-1;
        int coverage = registerMessage(l, cc);

        read();

        if(!slash) {
            parseCharacter('[');
            addOutput(messageSendClass(coverage), coverage, "#r[");
        } else {
            addOutput(messageSendClass(coverage), coverage, "#/");
        }

        int rr;
        String name = "internal:createRegexp";
        List<Object> args = new ArrayList<Object>();

        while(true) {
            switch(rr = peek()) {
            case -1:
                fail("Expected end of regular expression, found EOF");
                break;
            case '/':
                read();
                if(slash) {
                    args.add(sb.toString());
                    addOutput(messageSendClass(coverage), coverage, sb + "/");
                    Message m = new Message(runtime, "internal:createRegexp");
                    m.setLine(l);
                    m.setPosition(cc);
                    IokeObject mm = runtime.createMessage(m);
                    if(!name.equals("internal:createRegexp")) {
                        Message.setName(mm, name);
                    }
                    Message.setArguments(mm, args);

                    sb = new StringBuilder();
                    while(true) {
                        switch(rr = peek()) {
                        case 'x':
                        case 'i':
                        case 'u':
                        case 'm':
                        case 's':
                            read();
                            sb.append((char)rr);
                            break;
                        default:
                            args.add(sb.toString());
                            top.add(mm);
                            addOutput(messageSendClass(coverage), coverage, sb.toString());
                            return;
                        }
                    }
                } else {
                    sb.append((char)rr);
                }
                break;
            case ']':
                read();
                if(!slash) {
                    args.add(sb.toString());
                    addOutput(messageSendClass(coverage), coverage, sb + "]");
                    Message m = new Message(runtime, "internal:createRegexp");
                    m.setLine(l);
                    m.setPosition(cc);
                    IokeObject mm = runtime.createMessage(m);
                    if(!name.equals("internal:createRegexp")) {
                        Message.setName(mm, name);
                    }
                    Message.setArguments(mm, args);
                    sb = new StringBuilder();
                    while(true) {
                        switch(rr = peek()) {
                        case 'x':
                        case 'i':
                        case 'u':
                        case 'm':
                        case 's':
                            read();
                            sb.append((char)rr);
                            break;
                        default:
                            args.add(sb.toString());
                            top.add(mm);
                            addOutput(messageSendClass(coverage), coverage, sb.toString());
                            return;
                        }
                    }
                } else {
                    sb.append((char)rr);
                }
                break;
            case '#':
                read();
                if((rr = peek()) == '{') {
                    read();
                    String contentSoFar = sb.toString();
                    args.add(contentSoFar);
                    addOutput(messageSendClass(coverage), coverage, contentSoFar + "#{");
                    sb = new StringBuilder();
                    name = "internal:compositeRegexp";
                    args.add(parseMessageChain());
                    readWhiteSpace();
                    parseCharacter('}');
                    addOutput(messageSendClass(coverage), coverage, "}");
                } else {
                    sb.append((char)'#');
                }
                break;
            case '\\':
                read();
                parseRegexpEscape(sb);
                break;
            default:
                read();
                sb.append((char)rr);
                break;
            }
        }
    }

    @Override
    protected void parseText(int indicator) throws IOException, ControlFlow {
        StringBuilder sb = new StringBuilder();
        boolean dquote = indicator == '"';

        int l = lineNumber; int cc = currentCharacter-1;
        int coverage = registerMessage(l, cc);

        if(!dquote) {
            read();
            addOutput(messageSendClass(coverage), coverage, "#[");
        } else {
            addOutput(messageSendClass(coverage), coverage, "\"");
        }


        int rr;
        String name = "internal:createText";
        List<Object> args = new ArrayList<Object>();
        List<Integer> lines = new ArrayList<Integer>();
        List<Integer> cols = new ArrayList<Integer>();
        lines.add(l); cols.add(cc);

        while(true) {
            switch(rr = peek()) {
            case -1:
                fail("Expected end of text, found EOF");
                break;
            case '"':
                read();
                if(dquote) {
                    args.add(sb.toString());
                    Message m = new Message(runtime, "internal:createText");
                    m.setLine(l);
                    m.setPosition(cc);
                    IokeObject mm = runtime.createMessage(m);
                    if(!name.equals("internal:createText")) {
                        for(int i = 0; i<args.size(); i++) {
                            Object o = args.get(i);
                            if(o instanceof String) {
                                Message mx = new Message(runtime, "internal:createText", o);
                                mx.setLine(lines.get(i));
                                mx.setPosition(cols.get(i));
                                IokeObject mmx = runtime.createMessage(mx);
                                args.set(i, mmx);
                            }
                        }
                        Message.setName(mm, name);
                    }
                    Message.setArguments(mm, args);
                    top.add(mm);
                    addOutput(messageSendClass(coverage), coverage, sb + "\"");
                    return;
                } else {
                    sb.append((char)rr);
                }
                break;
            case ']':
                read();
                if(!dquote) {
                    args.add(sb.toString());
                    Message m = new Message(runtime, "internal:createText");
                    m.setLine(l);
                    m.setPosition(cc);
                    IokeObject mm = runtime.createMessage(m);
                    if(!name.equals("internal:createText")) {
                        for(int i = 0; i<args.size(); i++) {
                            Object o = args.get(i);
                            if(o instanceof String) {
                                Message mx = new Message(runtime, "internal:createText", o);
                                mx.setLine(lines.get(i));
                                mx.setPosition(cols.get(i));
                                IokeObject mmx = runtime.createMessage(mx);
                                args.set(i, mmx);
                            }
                        }
                        Message.setName(mm, name);
                    }
                    Message.setArguments(mm, args);
                    top.add(mm);
                    addOutput(messageSendClass(coverage), coverage, sb + "]");
                    return;
                } else {
                    sb.append((char)rr);
                }
                break;
            case '#':
                read();
                if((rr = peek()) == '{') {
                    read();
                    String contentSoFar = sb.toString();
                    args.add(contentSoFar);
                    sb = new StringBuilder();
                    lines.add(l);
                    cols.add(cc);
                    lines.add(lineNumber);
                    cols.add(currentCharacter);
                    name = "internal:concatenateText";
                    addOutput(messageSendClass(coverage), coverage, contentSoFar + "#{");
                    args.add(parseMessageChain());
                    readWhiteSpace();
                    l = lineNumber; cc = currentCharacter;
                    parseCharacter('}');
                    addOutput(messageSendClass(coverage), coverage, "}");
                } else {
                    sb.append((char)'#');
                }
                break;
            case '\\':
                read();
                parseDoubleQuoteEscape(sb);
                break;
            default:
                read();
                sb.append((char)rr);
                break;
            }
        }
    }

    @Override
    protected void parseRegexpEscape(StringBuilder sb) throws IOException, ControlFlow {
        sb.append('\\');
        int rr = peek();
        switch(rr) {
        case 'u':
            read();
            sb.append((char)rr);
            for(int i = 0; i < 4; i++) {
                rr = peek();
                if((rr >= '0' && rr <= '9') ||
                   (rr >= 'a' && rr <= 'f') ||
                   (rr >= 'A' && rr <= 'F')) {
                    read();
                    sb.append((char)rr);
                } else {
                    fail("Expected four hexadecimal characters in unicode escape - got: " + charDesc(rr));
                }
            }
            break;
        case '0':
        case '1':
        case '2':
        case '3':
        case '4':
        case '5':
        case '6':
        case '7':
            read();
            sb.append((char)rr);
            if(rr <= '3') {
                rr = peek();
                if(rr >= '0' && rr <= '7') {
                    read();
                    sb.append((char)rr);
                    rr = peek();
                    if(rr >= '0' && rr <= '7') {
                        read();
                        sb.append((char)rr);
                    }
                }
            } else {
                rr = peek();
                if(rr >= '0' && rr <= '7') {
                    read();
                    sb.append((char)rr);
                }
            }
            break;
        case 't':
        case 'n':
        case 'f':
        case 'r':
        case '/':
        case '\\':
        case '\n':
        case '#':
        case 'A':
        case 'd':
        case 'D':
        case 's':
        case 'S':
        case 'w':
        case 'W':
        case 'b':
        case 'B':
        case 'z':
        case 'Z':
        case '<':
        case '>':
        case 'G':
        case 'p':
        case 'P':
        case '{':
        case '}':
        case '[':
        case ']':
        case '*':
        case '(':
        case ')':
        case '$':
        case '^':
        case '+':
        case '?':
        case '.':
        case '|':
            read();
            sb.append((char)rr);
            break;
        case '\r':
            read();
            sb.append((char)rr);
            if((rr = peek()) == '\n') {
                read();
                sb.append((char)rr);
            }
            break;
        default:
            fail("Undefined regular expression escape character: " + charDesc(rr));
            break;
        }
    }

    @Override
    protected void parseDoubleQuoteEscape(StringBuilder sb) throws IOException, ControlFlow {
        sb.append('\\');
        int rr = peek();
        switch(rr) {
        case 'u':
            read();
            sb.append((char)rr);
            for(int i = 0; i < 4; i++) {
                rr = peek();
                if((rr >= '0' && rr <= '9') ||
                   (rr >= 'a' && rr <= 'f') ||
                   (rr >= 'A' && rr <= 'F')) {
                    read();
                    sb.append((char)rr);
                } else {
                    fail("Expected four hexadecimal characters in unicode escape - got: " + charDesc(rr));
                }
            }
            break;
        case '0':
        case '1':
        case '2':
        case '3':
        case '4':
        case '5':
        case '6':
        case '7':
            read();
            sb.append((char)rr);
            if(rr <= '3') {
                rr = peek();
                if(rr >= '0' && rr <= '7') {
                    read();
                    sb.append((char)rr);
                    rr = peek();
                    if(rr >= '0' && rr <= '7') {
                        read();
                        sb.append((char)rr);
                    }
                }
            } else {
                rr = peek();
                if(rr >= '0' && rr <= '7') {
                    read();
                    sb.append((char)rr);
                }
            }
            break;
        case 'b':
        case 't':
        case 'n':
        case 'f':
        case 'r':
        case '"':
        case ']':
        case '\\':
        case '\n':
        case '#':
        case 'e':
            read();
            sb.append((char)rr);
            break;
        case '\r':
            read();
            sb.append((char)rr);
            if((rr = peek()) == '\n') {
                read();
                sb.append((char)rr);
            }
            break;
        default:
            fail("Undefined text escape character: " + charDesc(rr));
            break;
        }
    }

    @Override
    protected void parseOperatorChars(int indicator) throws IOException, ControlFlow {
        int l = lineNumber; int cc = currentCharacter-1;

        int coverage = registerMessage(l, cc);

        StringBuilder sb = new StringBuilder();
        sb.append((char)indicator);
        int rr;
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
            case '/':
                if(indicator != '#') {
                    read();
                    sb.append((char)rr);
                    break;
                }
                // FALL THROUGH
            default:
                Message m = new Message(runtime, sb.toString());
                m.setLine(l);
                m.setPosition(cc);
                IokeObject mx = runtime.createMessage(m);


                if(rr == '(') {
                    addOutput(messageSendClass(coverage), coverage, sb.toString());
                    read();
                    addOutput(nothingClass((char)rr), (char)rr);
                    List<Object> args = parseCommaSeparatedMessageChains();
                    parseCharacter(')');
                    addOutput(nothingClass(')'), ')');
                    Message.setArguments(mx, args);
                    top.add(mx);
                } else {
                    possibleOperator(mx, coverage);
                    addOutput(messageSendClass(coverage), coverage, sb.toString());
                }
                return;
            }
        }
    }

    @Override
    protected void parseNumber(int indicator) throws IOException, ControlFlow {
        int l = lineNumber; int cc = currentCharacter-1;
        boolean decimal = false;
        StringBuilder sb = new StringBuilder();
        sb.append((char)indicator);
        int rr = -1;
        if(indicator == '0') {
            rr = peek();
            if(rr == 'x' || rr == 'X') {
                read();
                sb.append((char)rr);
                rr = peek();
                if((rr >= '0' && rr <= '9') ||
                   (rr >= 'a' && rr <= 'f') ||
                   (rr >= 'A' && rr <= 'F')) {
                    read();
                    sb.append((char)rr);
                    rr = peek();
                    while((rr >= '0' && rr <= '9') ||
                          (rr >= 'a' && rr <= 'f') ||
                          (rr >= 'A' && rr <= 'F')) {
                        read();
                        sb.append((char)rr);
                        rr = peek();
                    }
                } else {
                    fail("Expected at least one hexadecimal characters in hexadecimal number literal - got: " + charDesc(rr));
                }
            } else {
                int r2 = peek2();
                if(rr == '.' && (r2 >= '0' && r2 <= '9')) {
                    decimal = true;
                    sb.append((char)rr);
                    sb.append((char)r2);
                    read(); read();
                    while((rr = peek()) >= '0' && rr <= '9') {
                        read();
                        sb.append((char)rr);
                    }
                    if(rr == 'e' || rr == 'E') {
                        read();
                        sb.append((char)rr);
                        if((rr = peek()) == '-' || rr == '+') {
                            read();
                            sb.append((char)rr);
                            rr = peek();
                        }

                        if(rr >= '0' && rr <= '9') {
                            read();
                            sb.append((char)rr);
                            while((rr = peek()) >= '0' && rr <= '9') {
                                read();
                                sb.append((char)rr);
                            }
                        } else {
                            fail("Expected at least one decimal character following exponent specifier in number literal - got: " + charDesc(rr));
                        }
                    }
                }
            }
        } else {
            while((rr = peek()) >= '0' && rr <= '9') {
                read();
                sb.append((char)rr);
            }
            int r2 = peek2();
            if(rr == '.' && r2 >= '0' && r2 <= '9') {
                decimal = true;
                sb.append((char)rr);
                sb.append((char)r2);
                read(); read();

                while((rr = peek()) >= '0' && rr <= '9') {
                    read();
                    sb.append((char)rr);
                }
                if(rr == 'e' || rr == 'E') {
                    read();
                    sb.append((char)rr);
                    if((rr = peek()) == '-' || rr == '+') {
                        read();
                        sb.append((char)rr);
                        rr = peek();
                    }

                    if(rr >= '0' && rr <= '9') {
                        read();
                        sb.append((char)rr);
                        while((rr = peek()) >= '0' && rr <= '9') {
                            read();
                            sb.append((char)rr);
                        }
                    } else {
                        fail("Expected at least one decimal character following exponent specifier in number literal - got: " + charDesc(rr));
                    }
                }
            } else if(rr == 'e' || rr == 'E') {
                decimal = true;
                read();
                sb.append((char)rr);
                if((rr = peek()) == '-' || rr == '+') {
                    read();
                    sb.append((char)rr);
                    rr = peek();
                }

                if(rr >= '0' && rr <= '9') {
                    read();
                    sb.append((char)rr);
                    while((rr = peek()) >= '0' && rr <= '9') {
                        read();
                        sb.append((char)rr);
                    }
                } else {
                    fail("Expected at least one decimal character following exponent specifier in number literal - got: " + charDesc(rr));
                }
            }
        }

        // TODO: add unit specifier here

        int coverage = registerMessage(l, cc);

        addOutput(messageSendClass(coverage), coverage, sb.toString());
        Message m = decimal ? new Message(runtime, "internal:createDecimal", sb.toString()) : new Message(runtime, "internal:createNumber", sb.toString());
        m.setLine(l);
        m.setPosition(cc);
        top.add(runtime.createMessage(m));
    }

    @Override
    protected void parseRegularMessageSend(int indicator) throws IOException, ControlFlow {
        int l = lineNumber; int cc = currentCharacter-1;

        int coverage = registerMessage(l, cc);

        StringBuilder sb = new StringBuilder();
        sb.append((char)indicator);
        int rr = -1;
        while(isLetter(rr = peek()) || isIDDigit(rr) || rr == ':' || rr == '!' || rr == '?' || rr == '$') {
            read();
            sb.append((char)rr);
        }
        Message m = new Message(runtime, sb.toString());
        m.setLine(l);
        m.setPosition(cc);
        IokeObject mx = runtime.createMessage(m);


        if(rr == '(') {
            addOutput(messageSendClass(coverage), coverage, sb.toString());
            read();
            addOutput(nothingClass((char)rr), (char)rr);
            List<Object> args = parseCommaSeparatedMessageChains();
            parseCharacter(')');
            addOutput(nothingClass(')'), ')');
            Message.setArguments(mx, args);
            top.add(mx);
        } else {
            possibleOperator(mx, coverage);
            addOutput(messageSendClass(coverage), coverage, sb.toString());
        }
    }
}// CoverageParser

