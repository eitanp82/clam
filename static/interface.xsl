<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:import href="parameters.xsl" />

<xsl:output method="html" encoding="UTF-8" omit-xml-declaration="yes" doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd" indent="yes" cdata-section-elements="script"/>

<xsl:template match="/clam">
  <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
  <xsl:call-template name="head" />
  <body>
    <div id="container">
        <xsl:choose>
         <xsl:when test="@project">
            <div id="header"><h1><xsl:value-of select="@name"/></h1><h2><xsl:value-of select="@project"/></h2></div>
            <xsl:apply-templates select="status"/>
            <xsl:choose>
              <xsl:when test="status/@code = 0">  
                <div id="input" class="box">            
                 <xsl:apply-templates select="input"/><!-- upload form transformed from input formats -->
                 <xsl:apply-templates select="inputformats"/>             
                </div>
                <xsl:apply-templates select="parameters"/>  
              </xsl:when>
              <xsl:when test="status/@code = 2">
                <xsl:apply-templates select="output"/>
              </xsl:when>
            </xsl:choose>
         </xsl:when>
         <xsl:otherwise>
             <xsl:call-template name="clamindex" />
         </xsl:otherwise>
        </xsl:choose>    
        <xsl:call-template name="footer" />
    </div>
  </body>
  </html>
</xsl:template>


<xsl:template name="head">
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <xsl:if test="status/@code = 1">
      <meta http-equiv="refresh" content="10" />            
    </xsl:if>
    <title><xsl:value-of select="@name"/> :: <xsl:value-of select="@project"/></title>
    <link rel="stylesheet" href="/static/style.css" type="text/css" />
    <!--<link rel="stylesheet" href="/static/humanity/jquery-ui-1.8.1.custom.css" type="text/css" />-->
    <link rel="stylesheet" href="/static/table.css" type="text/css" />
    <script type="text/javascript" src="/static/jquery-1.4.2.min.js"></script>
    <!--<script type="text/javascript" src="/static/jquery-ui-1.8.1.custom.min.js"></script>-->
    <script type="text/javascript" src="/static/jquery.dataTables.min.js"></script>
    <script type="text/javascript" src="/static/ajaxupload.js"></script>
    <script type="text/javascript" src="/static/clam.js"></script>
  </head>
</xsl:template>

<xsl:template name="footer">
    <div id="footer" class="box">Powered by <strong>CLAM</strong> - Computational Linguistics Application Mediator<br />by Maarten van Gompel<br /><a href="http://ilk.uvt.nl">Induction of Linguistic Knowledge Research Group</a>, <a href="http://www.uvt.nl">Tilburg University</a></div>
</xsl:template>


<xsl:template match="/clam/status">
    <div id="status" class="box">
     <h2>Status</h2>
     <xsl:if test="@errors = 'yes'">
      <div class="error">
            <strong>Error: </strong> <xsl:value-of select="@errormsg"/>
      </div>
     </xsl:if>     
     <xsl:choose>
      <xsl:when test="@code = 0">
        <div class="ready"><xsl:value-of select="@message"/><input id="abortbutton" type="button" value="Abort and delete project" /></div>
      </xsl:when>
      <xsl:when test="@code = 1">
        <div class="running"><xsl:value-of select="@message"/><input id="abortbutton" type="button" value="Abort and delete project" /></div>
        <xsl:choose>
         <xsl:when test="@completion > 75">
           <div id="progressbar">
                <span id="progressvalue"><xsl:attribute name="style">width: <xsl:value-of select="@completion"/>%;</xsl:attribute><xsl:value-of select="@completion"/>%</span>
           </div>
         </xsl:when>
         <xsl:when test="@completion > 0">
           <div id="progressbar">
                <span id="progressvalue"><xsl:attribute name="style">width: <xsl:value-of select="@completion"/>%;</xsl:attribute></span><xsl:value-of select="@completion"/>%
           </div>
         </xsl:when>
         <xsl:otherwise>
           <img class="progress" src="/static/progress.gif" />
         </xsl:otherwise>
        </xsl:choose>
        <p>You may safely close your browser or shut down your computer during this process, the system will keep running and be available when you return another time.</p>
        <xsl:call-template name="log" />
      </xsl:when>
      <xsl:when test="@code = 2">
        <div class="done"><xsl:value-of select="@message"/><input id="abortbutton" type="button" value="Cancel and delete project" /><input id="restartbutton" type="button" value="Discard output and restart" /></div>
        <xsl:call-template name="log" />
      </xsl:when>
      <xsl:otherwise>
        <div class="other"><xsl:value-of select="@message"/></div>
      </xsl:otherwise>
     </xsl:choose>
    </div>
</xsl:template>

<xsl:template name="log">
     <xsl:if test="log">
        <div id="statuslog">
            <table>
                <xsl:apply-templates select="log" />
            </table>
        </div>
     </xsl:if>
</xsl:template>

<xsl:template match="/clam/status/log">
    <tr><td class="time"><xsl:value-of select="@time" /></td><td class="message"><xsl:value-of select="." /></td></tr>
</xsl:template>

<xsl:template match="/clam/inputformats">
        <div class="uploadform">
            <h3>Upload a file from disk</h3>
            <p>Use this to upload files from your computer to the system.</p>
            <!--
            <div id="simpleupload">
             <form id="uploadform" method="POST" enctype="multipart/form-data" action="upload/">
                <input type="hidden" name="uploadcount" value="1" />
                <table>
                 <tr><th><label for="upload1">Upload file:</label></th><td><input type="file" name="upload1" /></td></tr>
                 <tr><th><label for="uploadformat1">Format:</label></th><td>
                    <select name="uploadformat1">
                    <xsl:for-each select="*">
                        <option><xsl:attribute name="value"><xsl:value-of select="name(.)" /></xsl:attribute><xsl:value-of select="@name" /><xsl:if test="@encoding"> [<xsl:value-of select="@encoding" />]</xsl:if></option>
                    </xsl:for-each>
                    </select>
                 </td></tr>
                 <tr><td></td><td><input id="uploadbutton" type="submit" value="Upload input file" /></td></tr>
                </table>
             </form>
            </div>
            -->

            <div id="complexupload">
                <strong>Step 1)</strong><xsl:text> </xsl:text><em>First select the desired input format for this upload:</em><xsl:text> </xsl:text><select id="uploadformat1">
                    <xsl:for-each select="*">
                        <option><xsl:attribute name="value"><xsl:value-of select="name(.)" /></xsl:attribute><xsl:value-of select="@name" /><xsl:if test="@encoding"> [<xsl:value-of select="@encoding" />]</xsl:if></option>
                    </xsl:for-each>
                    </select><br />
                <strong>Step 2)</strong><xsl:text> </xsl:text><input id="upload1" class="uploadbutton" type="submit" value="Select and upload a file" />
            </div>
            <div id="uploadprogress">
                    <strong>Upload in progress... Please wait...</strong><br />
                    <img class="progress" src="/static/progress.gif" />
            </div>
        

        </div>
        <h3>Grab a file from the web</h3>
        <div id="urlupload">
            <p>Retrieves an input file from another location on the web.</p>
            <strong>Step 1)</strong><xsl:text> </xsl:text><em>First select the desired input format:</em><xsl:text> </xsl:text><select id="uploadformaturl">
                        <xsl:for-each select="*">
                            <option><xsl:attribute name="value"><xsl:value-of select="name(.)" /></xsl:attribute><xsl:value-of select="@name" /><xsl:if test="@encoding"> [<xsl:value-of select="@encoding" />]</xsl:if></option>
                        </xsl:for-each>
            </select><br />
            <strong>Step 2)</strong><xsl:text> </xsl:text><em>Enter the URL where to retrieve the file</em><xsl:text> </xsl:text><input id="uploadurl" value="http://" /><br />
            <strong>Step 3)</strong><xsl:text> </xsl:text><input id="uploadurlsubmit" class="uploadbutton" type="submit" value="Retrieve and add file" />
        </div>
        <div id="urluploadprogress">
                    <strong>Downloadin progress... Please wait...</strong><br />
                    <img class="progress" src="/static/progress.gif" />
        </div>    

        <h3>Add input from browser</h3>
        <p>You can create new files right from your browser: <button id="openeditor">Open Live Editor</button></p>
        <div id="mask"></div>
        <div id="editor">
            <h3>Add input from browser</h3>
            <!--<form id="editorform" method="POST" enctype="multipart/form-data" action="upload/">-->
            <!--<input type="hidden" name="uploadcount" value="1" />-->
                <table>
                 <tr><th><label for="uploadtext1">Input:</label></th><td><textarea id="uploadtext1"></textarea></td></tr>
                 <tr><th><label for="uploadfilename1">Desired filename:</label></th><td><input id="uploadfilename1" /></td></tr>
                 <tr><th><label for="uploadformat1">Format:</label></th><td>
                    <select id="editoruploadformat">
                    <xsl:for-each select="*">
                        <option><xsl:attribute name="value"><xsl:value-of select="name(.)" /></xsl:attribute><xsl:value-of select="@name" /></option>
                    </xsl:for-each>
                    </select>
                 </td></tr>
                 <tr><th></th><td class="buttons"><input id="submiteditor" class="uploadbutton" type="submit" value="Add to input files" /> <button id="canceleditor">Cancel</button></td></tr>
                </table>
            <!--</form>-->
        </div>
</xsl:template>

<xsl:template match="/clam/input">
        <h2>Input files</h2>
        <table id="inputfiles" class="files">
            <thead>
                <tr>
                    <th>Input File</th>
                    <th>Format</th>
                    <th>Encoding</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <xsl:apply-templates select="path" /> 
            </tbody>
        </table>
</xsl:template>

<xsl:template match="/clam/output">
    <div id="output" class="box">
        <h2>Output files</h2>
        <p>(Download all as archive: <a href="output/?format=zip">zip</a> | <a href="output/?format=tar.gz">tar.gz</a> | <a href="output/?format=tar.bz2">tar.bz2</a>)</p>
        <table id="outputfiles" class="files">
            <thead>
                <tr>
                    <th>Input File</th>
                    <th>Format</th>
                    <th>Encoding</th>
                </tr>
            </thead>
            <tbody>
                <xsl:apply-templates select="path" />
            </tbody>
        </table>
    </div>
</xsl:template>

<xsl:template match="/clam/input/path">
    <tr>
        <td class="file"><a><xsl:attribute name="href">input/<xsl:value-of select="."/></xsl:attribute><xsl:value-of select="."/></a></td>
        <td><xsl:value-of select="@label"/></td>
        <td><xsl:value-of select="@encoding" /></td>
        <td class="actions"><img src="/static/delete.png" title="Delete this file">
            <xsl:attribute name="onclick">deleteinputfile('<xsl:value-of select="."/>');</xsl:attribute>
        </img></td>
    </tr>
</xsl:template>


<xsl:template match="/clam/output/path">
    <tr>
        <td class="file"><a><xsl:attribute name="href">output/<xsl:value-of select="."/></xsl:attribute><xsl:value-of select="."/></a></td>  
        <td><xsl:value-of select="@label"/></td>
        <td><xsl:value-of select="@encoding"/></td>
    </tr>
</xsl:template>

<xsl:template match="/clam/parameters">
    <form method="POST" enctype="multipart/form-data" action="">
    <div id="parameters" class="box">
        <h2>Parameter Selection</h2>

        <xsl:for-each select="parametergroup">
         <h3><xsl:value-of select="@name" /></h3>
         <table>
          <xsl:apply-templates />
         </table>
        </xsl:for-each>

        <div id="corpusselection">
        <label for="usecorpus">Input source:</label>
        <select name="usecorpus">
            <option value="" selected="selected">Use uploaded files</option>
            <xsl:for-each select="../corpora/corpus">
                <option><xsl:attribute name="value"><xsl:value-of select="." /></xsl:attribute><xsl:value-of select="." /></option>
            </xsl:for-each>
        </select>
        </div>
        <div id="startbutton">
            <input type="submit" class="start" value="Start" />
        </div>
    </div>
    </form>
</xsl:template>


<xsl:template match="/clamupload">
  <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
  <xsl:call-template name="head" />
  <body>
    <div id="header"><h1><xsl:value-of select="@name"/></h1><h2><xsl:value-of select="@project"/></h2></div>
    <xsl:for-each select="upload">
        <div id="upload" class="box">
            <a href="../">Return to the project view</a>
            <ul>
              <xsl:apply-templates select="file"/>  
            </ul>
        </div>
    </xsl:for-each>
    <xsl:call-template name="footer" />
  </body>
  </html>
</xsl:template>

<xsl:template match="file">
    <xsl:choose>
    <xsl:when test="@validated = 'yes'">
        <li class="ok"><tt><xsl:value-of select="@name" /></tt>: OK</li>    
    </xsl:when>
    <xsl:otherwise>
        <li class="failed"><tt><xsl:value-of select="@name" /></tt>: Failed</li>    
    </xsl:otherwise>
    </xsl:choose>
</xsl:template>


<xsl:template name="clamindex">
        <div id="header"><h1><xsl:value-of select="@name"/></h1><h2><xsl:value-of select="@project"/></h2></div>
        <div id="description" class="box">
              <xsl:value-of select="description" />   
        </div>
        <div id="startproject" class="box">
            <h3>Start a new Project</h3>    
                Project ID: <input id="projectname" type="projectname" value="" />
                <input id="startprojectbutton" type="button" value="Start project" />
        </div>
        <div id="index" class="box">
        <h2>Projects</h2>
        <table id="projects">
          <thead>
            <tr><th>Project ID</th></tr>
          </thead>
          <tbody>
           <xsl:for-each select="projects/project">
            <tr><td><a><xsl:attribute name="href"><xsl:value-of select="." />/</xsl:attribute><xsl:value-of select="." /></a></td></tr>
           </xsl:for-each>
          </tbody>
        </table>
        </div>
</xsl:template>

</xsl:stylesheet>
