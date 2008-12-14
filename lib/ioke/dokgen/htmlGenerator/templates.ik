
DokGen do(
  HtmlGenerator do(
    Templates = Origin mimic
    Templates do(
      Template = Origin mimic
      Template generateIntoFile = method(file, +:krest,
        file print(self data(*krest))
      )

      Readme = Template mimic
      Readme data = method(content:, basePath: "./",

"<?xml version=\"1.0\" encoding=\"iso-8859-1\"?>
<!DOCTYPE html 
PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\"
\"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">
<html xmlns=\"http://www.w3.org/1999/xhtml\">
  <head>
    <title>File: README</title>
    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=iso-8859-1\" />
    <link rel=\"stylesheet\" href=\"#{basePath}./dokgen-style.css\" type=\"text/css\" media=\"screen\" />
  </head>
  
  <body>
    <table border='0' cellpadding='0' cellspacing='0' width=\"100%\" class='banner'>
      <tr>
        <td>
          <table width=\"100%\" border='0' cellpadding='0' cellspacing='0'>
            <tr>
              <td class=\"file-title\" colspan=\"2\">
                <span class=\"file-title-prefix\">File</span>
                <br />
                README
              </td>
              <td align=\"right\">
                <table border='0' cellspacing=\"0\" cellpadding=\"2\">
                  <tr>
                    <td>Path:</td>
                    <td>README</td>
                  </tr>
                  <tr>
                    <td>Modified:</td>
                    <td>00-00-00</td>
                  </tr>
                </table>
              </td>
            </tr>
          </table>
        </td>
      </tr>
    </table>
    <br />
    <div id=\"bodyContent\">
      <div id=\"content\">
        <div class=\"description\">
          <p>
            #{content}
          </p>
        </div>
      </div>
    </div>
  </body>
</html>")

      FileFrame = Template mimic
      FileFrame data = method(content:, basePath:,

"<?xml version=\"1.0\" encoding=\"iso-8859-1\"?>
<!DOCTYPE html 
     PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\"
     \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">
<html xmlns=\"http://www.w3.org/1999/xhtml\">
  <head>
    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=iso-8859-1\" />
    <title>Index</title>
    <style type=\"text/css\">
<!--
  body {
    background-color: #EEE;
    font-family: Arial, Verdana, Sans-Serif; 
    color: #222;
    margin: 0px;
    font-size:12px;
  }
  .banner {
    background: #303;
    color: #FFF;
    padding: 0.2em;
    font-size: small;
    font-weight: bold;
    text-align: center;
  }
  .entries {
    margin: 0.25em 1em 0 1em;
    font-size: x-small;
  }
  a {
    color: #222;
    text-decoration: none;
    font-weight: bold;
    white-space: nowrap;
  }
  a:hover {
    color: #606;
    text-decoration: underline;
  }
-->
    </style>
    <base target=\"docwin\" href=\"index.html\"/>
  </head>
  <body>
    <div class=\"banner\">Files</div>
    <div class=\"entries\">
    #{content}
    </div>
  </body>
</html>")
    )
  )
)
