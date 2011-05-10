/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang.coverage;

import gnu.math.*;

import java.io.*;
import java.util.*;

import ioke.lang.*;
import ioke.lang.coverage.CoverageInterpreter.CoveragePoint;

/**
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Coverage {
    public static void processCoverage(ioke.lang.Runtime runtime, CoverageInterpreter citer) throws Throwable {
        List<String> files = new ArrayList(citer.covered.keySet());

        String directory = "coverage-report";

        File configFile = new File("ikover_config.ik");
        if(configFile.exists()) {
            IokeObject config = (IokeObject)runtime.evaluateStream(new FileReader(configFile));
            IokeObject dir = (IokeObject)IokeObject.findCell(config, "directory");
            if(dir != runtime.nul && dir != runtime.nil) {
                directory = Text.getText(Interpreter.send(runtime.asText, runtime.ground, dir));
            }
            IokeObject fileFilter = (IokeObject)IokeObject.findCell(config, "files");
            if(fileFilter != runtime.nul && fileFilter != runtime.nil) {
                for(Iterator<String> iter = files.iterator(); iter.hasNext();) {
                    if(!IokeObject.isTrue(Interpreter.send(runtime.callMessage, runtime.ground, fileFilter, runtime.newText(iter.next())))) {
                        iter.remove();
                    }
                }
            }
        }

        Collections.sort(files);

        File dir = new File(directory);
        dir.mkdirs();

        PrintWriter summaryX = new PrintWriter(new FileWriter(new File(dir, "frame-summary.html")));
        StringWriter summaryS = new StringWriter();
        PrintWriter summary = new PrintWriter(summaryS);
        PrintWriter filesh = new PrintWriter(new FileWriter(new File(dir, "frame-files.html")));
        
        filesh.println("<html>");
        filesh.println("  <head>");
        filesh.println("    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\"/>"); 
        filesh.println("    <title>Coverage Report Files</title>");
        filesh.println("    <link title=\"Style\" type=\"text/css\" rel=\"stylesheet\" href=\"main.css\"/>");
        filesh.println("  </head>");
        filesh.println("  <body>");
        filesh.println("    <h5>All Files</h5>");
        filesh.println("    <div class=\"separator\">&nbsp;</div>");
        filesh.println("    <h5>Classes</h5>");
        filesh.println("    <table width=\"100%\">");
        filesh.println("      <tbody>");

        summaryX.println("<html>");
        summaryX.println("  <head>");
        summaryX.println("    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\"/>"); 
        summaryX.println("    <title>Coverage Report</title>");
        summaryX.println("    <link title=\"Style\" type=\"text/css\" rel=\"stylesheet\" href=\"main.css\"/>");
        summaryX.println("  </head>");
        summaryX.println("  <body>");
        summaryX.println("    <h5>Coverage Report - All Files</h5>");
        summaryX.println("    <div class=\"separator\">&nbsp;</div>");

        summaryX.println("    <table class=\"report\" id=\"packageResults\">");
        summaryX.println("      <thead>");
        summaryX.println("        <tr>");
        summaryX.println("          <td class=\"heading\">File</td>");
        summaryX.println("          <td class=\"heading\">");
        summaryX.println("            Complete Line Coverage");
        summaryX.println("          </td>");
        summaryX.println("          <td class=\"heading\">");
        summaryX.println("            Partial Line Coverage");
        summaryX.println("          </td>");
        summaryX.println("          <td class=\"heading\">");
        summaryX.println("            Message Coverage");
        summaryX.println("          </td>");
        summaryX.println("        </tr>");
        summaryX.println("      </thead>"); 
        summaryX.println("      <tbody> ");


        int linesWithContent = 0;
        int linesPartiallyCovered = 0;
        int linesCompletelyCovered = 0;
        int messages = 0;
        int numberOfUncovered = 0;
        int numberOfCovered = 0;
        
        for(String filename : files) {
            String cwd = runtime.getCurrentWorkingDirectory();
            String filename2 = filename;
            if(filename2.startsWith(cwd)) {
                filename2 = filename2.substring(cwd.length());
                if(filename2.startsWith("/")) {
                    filename2 = filename2.substring(1);
                }

            }

            String filenameInFilesystem = filename2.replaceAll("/", "_");

            Map<String, Map<String, CoveragePoint>> cdata = citer.covered;
            String realFile = filename2;
            if(!new File(realFile).exists()) {
                realFile = "src/" + filename2;
                if(!new File(realFile).exists()) {
                    realFile = "src/ikj/" + filename2;
                }
            }
            
            if(new File(realFile).exists()) {
                FileWriter fw = new FileWriter(new File(dir, filenameInFilesystem + ".html"));
                CoverageParser unparser = new CoverageParser(runtime, 
                                                             new InputStreamReader(new FileInputStream(realFile), "UTF-8"), 
                                                             runtime.ground, 
                                                             runtime.message, 
                                                             filename,
                                                             cdata.get(filename),
                                                             fw);
            
                unparser.unparse();
                fw.close();

                filesh.println("        <tr>");
                filesh.println("          <td nowrap=\"nowrap\"><a target=\"summary\" href=\"" + filenameInFilesystem + ".html\">" + filename2 + "</a> <i>(" + (unparser.numberOfCovered*100/unparser.messages) + "%)</i></td>");
                filesh.println("        </tr>");

                summary.println("      <tr>");
                summary.println("        <td>");
                summary.println("          <a href=\"" + filenameInFilesystem + ".html\" onclick='parent.sourceFileList.location.href=\"" + filenameInFilesystem + ".html\"'>" + filename2 + "</a>");
                summary.println("        </td>");
                summary.println("        <td>");
                summary.println("          <table cellpadding=\"0px\" cellspacing=\"0px\" class=\"percentgraph\">");
                summary.println("            <tr class=\"percentgraph\">");
                summary.println("              <td align=\"right\" class=\"percentgraph\" width=\"40\">" + unparser.percentageComplete + "%</td>");
                summary.println("              <td class=\"percentgraph\">");
                summary.println("                <div class=\"percentgraph\">");
                summary.println("                  <div class=\"greenbar\" style=\"width:" + unparser.percentageComplete + "px\">");
                summary.println("                    <span class=\"text\">" + unparser.ratioComplete + "</span>");
                summary.println("                  </div>");
                summary.println("                </div>");
                summary.println("              </td>");
                summary.println("            </tr>");
                summary.println("          </table>");
                summary.println("        </td>");
                summary.println("        <td>");
                summary.println("          <table cellpadding=\"0px\" cellspacing=\"0px\" class=\"percentgraph\">");
                summary.println("            <tr class=\"percentgraph\">");
                summary.println("              <td align=\"right\" class=\"percentgraph\" width=\"40\">" + unparser.percentagePartial + "%</td>");
                summary.println("              <td class=\"percentgraph\">");
                summary.println("                <div class=\"percentgraph\">");
                summary.println("                  <div class=\"greenbar\" style=\"width:" + unparser.percentagePartial + "px\">");
                summary.println("                    <span class=\"text\">" + unparser.ratioPartial + "</span>");
                summary.println("                  </div>");
                summary.println("                </div>");
                summary.println("              </td>");
                summary.println("            </tr>");
                summary.println("          </table>");
                summary.println("        </td>");
                summary.println("        <td>");
                summary.println("          <table cellpadding=\"0px\" cellspacing=\"0px\" class=\"percentgraph\">");
                summary.println("            <tr class=\"percentgraph\">");
                summary.println("              <td align=\"right\" class=\"percentgraph\" width=\"40\">" + unparser.percentageMessages + "%</td>");
                summary.println("              <td class=\"percentgraph\">");
                summary.println("                <div class=\"percentgraph\">");
                summary.println("                  <div class=\"greenbar\" style=\"width:" + unparser.percentageMessages + "px\">");
                summary.println("                    <span class=\"text\">" + unparser.ratioMessages + "</span>");
                summary.println("                  </div>");
                summary.println("                </div>");
                summary.println("              </td>");
                summary.println("            </tr>");
                summary.println("          </table>");
                summary.println("        </td>");
                summary.println("      </tr> ");

                linesWithContent += unparser.linesWithContent;
                linesPartiallyCovered += unparser.linesPartiallyCovered;
                linesCompletelyCovered += unparser.linesCompletelyCovered;
                messages += unparser.messages;
                numberOfUncovered += unparser.numberOfUncovered;
                numberOfCovered += unparser.numberOfCovered;
            }
        }

        filesh.println("      </tbody>");
        filesh.println("    </table>");
        filesh.println("  </body>");
        filesh.println("</html>");

        summary.close();
        filesh.close();

        summary.println("      </tbody>");
        summary.println("    </table>");
        summary.println("  </body>");
        summary.println("</html>");


        int percentageComplete = linesCompletelyCovered * 100 / linesWithContent;
        int percentagePartial = linesPartiallyCovered * 100 / linesWithContent;
        int percentageMessages = numberOfCovered * 100 / messages;
        
        IokeObject ratioComplete = runtime.newNumber(RatNum.make(IntNum.make(linesCompletelyCovered), IntNum.make(linesWithContent)));
        IokeObject ratioPartial = runtime.newNumber(RatNum.make(IntNum.make(linesPartiallyCovered), IntNum.make(linesWithContent)));
        IokeObject ratioMessages = runtime.newNumber(RatNum.make(IntNum.make(numberOfCovered), IntNum.make(messages)));

        summaryX.println("      <tr>");
        summaryX.println("        <td>");
        summaryX.println("          <b>All Files</b>");
        summaryX.println("        </td>");
        summaryX.println("        <td>");
        summaryX.println("          <table cellpadding=\"0px\" cellspacing=\"0px\" class=\"percentgraph\">");
        summaryX.println("            <tr class=\"percentgraph\">");
        summaryX.println("              <td align=\"right\" class=\"percentgraph\" width=\"40\">" + percentageComplete + "%</td>");
        summaryX.println("              <td class=\"percentgraph\">");
        summaryX.println("                <div class=\"percentgraph\">");
        summaryX.println("                  <div class=\"greenbar\" style=\"width:" + percentageComplete + "px\">");
        summaryX.println("                    <span class=\"text\">" + ratioComplete + "</span>");
        summaryX.println("                  </div>");
        summaryX.println("                </div>");
        summaryX.println("              </td>");
        summaryX.println("            </tr>");
        summaryX.println("          </table>");
        summaryX.println("        </td>");
        summaryX.println("        <td>");
        summaryX.println("          <table cellpadding=\"0px\" cellspacing=\"0px\" class=\"percentgraph\">");
        summaryX.println("            <tr class=\"percentgraph\">");
        summaryX.println("              <td align=\"right\" class=\"percentgraph\" width=\"40\">" + percentagePartial + "%</td>");
        summaryX.println("              <td class=\"percentgraph\">");
        summaryX.println("                <div class=\"percentgraph\">");
        summaryX.println("                  <div class=\"greenbar\" style=\"width:" + percentagePartial + "px\">");
        summaryX.println("                    <span class=\"text\">" + ratioPartial + "</span>");
        summaryX.println("                  </div>");
        summaryX.println("                </div>");
        summaryX.println("              </td>");
        summaryX.println("            </tr>");
        summaryX.println("          </table>");
        summaryX.println("        </td>");
        summaryX.println("        <td>");
        summaryX.println("          <table cellpadding=\"0px\" cellspacing=\"0px\" class=\"percentgraph\">");
        summaryX.println("            <tr class=\"percentgraph\">");
        summaryX.println("              <td align=\"right\" class=\"percentgraph\" width=\"40\">" + percentageMessages + "%</td>");
        summaryX.println("              <td class=\"percentgraph\">");
        summaryX.println("                <div class=\"percentgraph\">");
        summaryX.println("                  <div class=\"greenbar\" style=\"width:" + percentageMessages + "px\">");
        summaryX.println("                    <span class=\"text\">" + ratioMessages + "</span>");
        summaryX.println("                  </div>");
        summaryX.println("                </div>");
        summaryX.println("              </td>");
        summaryX.println("            </tr>");
        summaryX.println("          </table>");
        summaryX.println("        </td>");
        summaryX.println("      </tr>");

        summaryX.write(summaryS.toString());
        summaryX.close();

        byte[] buffer = new byte[1024];
        int read = 0;
        FileOutputStream index = new FileOutputStream(new File(dir, "index.html"));
        InputStream fileis = Main.class.getResourceAsStream("/ioke/lang/coverage/index.html");
        while((read = fileis.read(buffer)) != -1) {
            index.write(buffer, 0, read);
        }
        fileis.close();
        index.close();

        FileOutputStream css = new FileOutputStream(new File(dir, "main.css"));
        InputStream maincss = Main.class.getResourceAsStream("/ioke/lang/coverage/main.css");
        while((read = maincss.read(buffer)) != -1) {
            css.write(buffer, 0, read);
        }
        maincss.close();
        css.close();

    }
}// Coverage
