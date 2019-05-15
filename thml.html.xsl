<xsl:stylesheet version="1.0"
  xmlns:xsl ="http://www.w3.org/1999/XSL/Transform"
  xmlns:xi  ="http://www.w3.org/2001/XInclude"
  xmlns:lang="http://www.ccel.org/info/languageCodes.xml"
  xmlns:letter="http://www.ccel.org/alphabetLetters"
  xmlns:str="http://exslt.org/strings"
  >
<xsl:output method="html" indent="yes" encoding="UTF-8"/>

<!--
thml.html.xsl: convert a ThML document to HTML
Special processing for Text.Dictionary, Text.Daily
First version by Jimmy Osborn 2002-summer; additional work by
Wes Morgan, Jon VanHofwegen, Brian Johnson, Harry Plantinga, Matt Johnson

Parameters it understands:
  sect:    In server mode, 
  	     ID of divn to return.
             Actually, return the divn less contained divn elements.
             If id is not of a divn, returns smallest containing divn
             Special values are all, toc, about, titlepage, 
	       today (for Text.Daily docs)
             Also, if _id, it returns the element whose id is given, which
               could be more or less than a section.
	   In desktop mode, it's blank, ain't it?
  debug:   1 to turn on debugging mode
  notes:   foot, margin, or hidden
  words:   if 1, add <a id="xxx"> around words for scripting
  osisRef: handle osisRef request
  term:	   for dictionary term lookup
  start:   for dictionary, show terms starting with this
  desktop  1 for running from CCEL-Desktop  
  bver		single bible preference for the server
  ot_bib, nt_bib, ap_bib: bible preferences
-->

<!-- set up parameter defaults -->
<xsl:param name="sect">all</xsl:param>
<xsl:param name="debug"></xsl:param>
<xsl:param name="notes">foot</xsl:param>
<xsl:param name="words"></xsl:param>
<xsl:param name="bver">asv</xsl:param>
<xsl:param name="osisRef"></xsl:param>
<xsl:param name="term"></xsl:param>
<xsl:param name="start"></xsl:param>
<xsl:param name="desktop">1</xsl:param>
<xsl:param name="theText"></xsl:param>
<xsl:param name="id"></xsl:param>
<xsl:param name="word">0</xsl:param>
<xsl:param name="ot_bib"><xsl:choose>
<xsl:when test="$bver"><xsl:value-of select="$bver"/></xsl:when>
<xsl:otherwise>web</xsl:otherwise>
</xsl:choose></xsl:param>
<xsl:param name="nt_bib"><xsl:choose>
<xsl:when test="$bver"><xsl:value-of select="$bver"/></xsl:when>
<xsl:otherwise>web</xsl:otherwise>
</xsl:choose></xsl:param>
<xsl:param name="ap_bib"><xsl:choose>
<xsl:when test="$bver"><xsl:value-of select="$bver"/></xsl:when>
<xsl:otherwise>kjv</xsl:otherwise>
</xsl:choose></xsl:param>

<!-- myNotes is what we should do with notes, whether passed in by the
     notes param or default (footnotes) -->
<xsl:variable name="myNotes"><xsl:choose><xsl:when test="$notes='hidden'">hidden</xsl:when><xsl:when test="$notes='margin'">margin</xsl:when><xsl:otherwise>foot</xsl:otherwise></xsl:choose></xsl:variable>

<xsl:variable name="termTrans">ABCDEFGHIJKLMNOPQRSTUVWXYZ+,;.()[]{}=</xsl:variable>

<xsl:variable name="authorID">
  <xsl:choose>
    <xsl:when test="/processing-instruction()[name()='thml-authorID']">
      <xsl:value-of select="/processing-instruction()[name()='thml-authorID']"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="/ThML/ThML.head/electronicEdInfo/authorID"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<xsl:variable name="bookID">
  <xsl:choose>
    <xsl:when test="/processing-instruction()[name()='thml-bookID']">
      <xsl:value-of select="/processing-instruction()[name()='thml-bookID']"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="/ThML/ThML.head/electronicEdInfo/bookID"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<xsl:variable name="author">
  <xsl:choose>
    <xsl:when test="/processing-instruction()[name()='thml-author']">
      <xsl:value-of select="/processing-instruction()[name()='thml-author']"/>
    </xsl:when>
    <xsl:when test="/ThML/ThML.head/electronicEdInfo/DC/DC.Creator[@sub='Author' and @scheme='short-form']">
      <xsl:value-of select="/ThML/ThML.head/electronicEdInfo/DC/DC.Creator[@sub='Author' and @scheme='short-form']"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="/ThML/ThML.head/electronicEdInfo/DC/DC.Creator[@sub='Author'
        and not(@scheme)]"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<xsl:variable name="title">
  <xsl:choose>
    <xsl:when test="/processing-instruction()[name()='thml-title']">
      <xsl:value-of select="/processing-instruction()[name()='thml-title']"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="/ThML/ThML.head/electronicEdInfo/DC/DC.Title[not(@sub='short')]"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<xsl:variable name="authLet"
    select="substring($authorID,1,1)"/>
<xsl:variable name="baseURI">/ccel/<xsl:value-of
    select="$authorID"/>/<xsl:value-of
    select="$bookID"/></xsl:variable>
<xsl:variable name="homeURI">http://www.ccel.org<xsl:value-of
    select="$baseURI"/></xsl:variable>
<xsl:variable name="xmlfile">http://www.ccel.org/<xsl:value-of
    select="$authLet"/>/<xsl:value-of select="$authorID"/>/<xsl:value-of
    select="$bookID"/>.xml</xsl:variable>
<xsl:variable name="homedir">http://www.ccel.org/<xsl:value-of
    select="$authLet"/>/<xsl:value-of select="$authorID"/>/<xsl:value-of
    select="$bookID"/></xsl:variable>

<xsl:param name="rootPath">/ccel/<xsl:value-of select="$authLet"/>/<xsl:value-of
	select="$authorID"/>/<xsl:value-of select="$bookID"/>/cache/xml/</xsl:param>

<xsl:variable name="bookInfo" select="concat('/ccel/',$authLet,'/',
    $authorID, '/', $bookID, '/bookInfo.xml')"/>

<xsl:variable name="ccsubj"
    select="/ThML/ThML.head/electronicEdInfo/DC/DC.Subject[@scheme='ccel']"/>

<!-- headtitle is used on left side of navbar -->
<xsl:variable name="shorttitle"
    select="/ThML/ThML.head/electronicEdInfo/DC/DC.Title[@sub='short']"/>
<xsl:variable name="headtitle"><xsl:choose><xsl:when test="$shorttitle"><xsl:value-of select="$shorttitle"/></xsl:when><xsl:otherwise><xsl:value-of select="$title"/></xsl:otherwise></xsl:choose></xsl:variable>
<xsl:variable name="titlepage" select="/ThML/ThML.body/div1[1]"/>
<xsl:variable name="titlepageID" select="$titlepage/@id"/>
<xsl:param name="progress">0%</xsl:param>

<!-- this is the ID of the requested element. -->
<xsl:variable name="mySectID">
  <xsl:choose>
    <xsl:when test="$osisRef != ''">
      <xsl:value-of select="$osisRef"/>
    </xsl:when>
    <xsl:when test="$sect='titlepage'">
      <xsl:value-of select="/ThML/ThML.body/div1[1]/@id"/>
    </xsl:when>
    <xsl:when test="substring($sect,1,1)='_'">
      <xsl:value-of select="substring($sect,2)"/>
    </xsl:when>
    <xsl:when test="/processing-instruction()[name()='thml-sect']">
      <xsl:value-of select="/processing-instruction()[name()='thml-sect']"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$sect"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:variable>


<xsl:variable name="theElt" select="/ThML/ThML.body//*[@id = $mySectID]"/>

<!-- this is the ID of the sect (divn) containing the requested element -->
<xsl:variable name="theDivID">
  <xsl:choose>
    <xsl:when test="$sect='all'"></xsl:when>
    <xsl:when test="$theElt[name()='div1'] or $theElt[name()='div2'] or
	$theElt[name()='div3'] or $theElt[name()='div4'] or
	$theElt[name()='div5']">
      <xsl:value-of select="$mySectID"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$theElt/ancestor::div5/@id|$theElt/ancestor::div4/@id|$theElt/ancestor::div3/@id|$theElt/ancestor::div2/@id|$theElt/ancestor::div1/@id[last()]"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:variable>


<!-- for osisRefs
     - delete any + and rest of osisRef string
     - delete any - and rest of osisRef string
     - get the ID of <scripture osisDI="..." or <scripCom osisRef="..."
-->

<xsl:variable name="osisRefOne">
  <xsl:choose>
    <xsl:when test="contains($osisRef,'+')"><xsl:value-of
	select="substring-before($osisRef,'+')"/></xsl:when>
    <xsl:otherwise><xsl:value-of select="$osisRef"/></xsl:otherwise>
  </xsl:choose>
</xsl:variable>
<xsl:variable name="osisRefStart">
  <xsl:choose>
    <xsl:when test="contains($osisRef,'-')"><xsl:value-of
	select="substring-before($osisRef,'-')"/></xsl:when>
    <xsl:otherwise><xsl:value-of select="$osisRef"/></xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<xsl:variable name="osisRefID">
  <xsl:choose>
    <xsl:when test="$osisRefStart=''"></xsl:when>
    <xsl:otherwise>
      <xsl:value-of
      select="//scripture[@osisID=$osisRefStart]/@id|//scripCom[contains(@osisRef,$osisRefStart)]/@id"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:variable>
<xsl:variable name="osisSect">
  <xsl:value-of select="substring-before($osisRefID,'-')"/>
</xsl:variable>

<!-- 'in' means #id urls, 'ex' means bookID.id.html urls -->
<xsl:variable name="urls">
  <xsl:choose>
    <xsl:when test="$mySectID='all' and $desktop!=1 and $osisRef=''">in</xsl:when>
    <xsl:otherwise>ex</xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<xsl:variable name="urlPrefix">
	<xsl:choose>
		<xsl:when test="$urls='in'">#</xsl:when>
		<xsl:otherwise><xsl:value-of select="$bookID"/>.</xsl:otherwise>
	</xsl:choose>
</xsl:variable>
<xsl:variable name="urlSuffix">
	<xsl:choose>
		<xsl:when test="$urls='in'"></xsl:when>
		<xsl:otherwise>.html<!--<xsl:value-of select="$params"/>--></xsl:otherwise>
	</xsl:choose>
</xsl:variable>
<xsl:variable name="tocURL">
	<xsl:value-of select="concat($urlPrefix,'toc',$urlSuffix)"/>
</xsl:variable>
<xsl:variable name="aboutURL">
	<xsl:value-of select="concat($bookID,$urlSuffix)"/>
</xsl:variable>
<xsl:variable name="titlepageURL">
	<xsl:choose>
		<xsl:when test="$mySectID='all'">#<xsl:value-of select="$titlepageID"/></xsl:when>
		<xsl:otherwise><xsl:value-of select="concat($urlPrefix,'titlepage',$urlSuffix)"/></xsl:otherwise>
	</xsl:choose>
</xsl:variable>
<xsl:variable name="cssURL">
	<xsl:choose>
		<xsl:when test="$sect='all'"><xsl:value-of select="$homeURI"/>.css</xsl:when>
		<xsl:otherwise><xsl:value-of select="$bookID"/>.css</xsl:otherwise>
	</xsl:choose>
</xsl:variable>

<!--Is this book a Text.Dictionary?-->
<xsl:variable name="isDict">
  <xsl:choose>
    <xsl:when test="/ThML/ThML.head/electronicEdInfo/DC/DC.Type='Text.Dictionary'">1</xsl:when>
    <xsl:when test="processing-instruction('thml-dctype')='Text.Dictionary'">1</xsl:when>
    <xsl:otherwise></xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<xsl:variable name="myTerm">
  <xsl:variable name="temp">
	  <xsl:call-template name="url-decode">
	  <xsl:with-param name="encoded" select="$term"/>
	  </xsl:call-template>
  </xsl:variable>
  <xsl:value-of select = "translate($temp,$termTrans,'abcdefghijklmnopqrstuvwxyz ')"/>
</xsl:variable>


<!--Is this book a Text.Daily?-->
<xsl:variable name="isDaily">
  <xsl:choose>
    <xsl:when test="/ThML/ThML.head/electronicEdInfo/DC/DC.Type='Text.Daily'">1</xsl:when>
    <xsl:when test="processing-instruction('thml-dctype')='Text.Daily'">1</xsl:when>
    <xsl:otherwise>0</xsl:otherwise>
  </xsl:choose>
</xsl:variable>


<!-- ============================================================== -->
<!-- ThML template: do outer stuff, then call appropriate templates -->
<!-- ============================================================== -->
<xsl:template match="/">
<xsl:if test="$debug">
  <xsl:message>rootPath:  <xsl:value-of select="$rootPath"/></xsl:message>
  <xsl:message>desktop:   <xsl:value-of select="$desktop"/></xsl:message>
  <xsl:message>authorID:  <xsl:value-of select="$authorID"/></xsl:message>
  <xsl:message>bookID:    <xsl:value-of select="$bookID"/></xsl:message>
  <xsl:message>title:     <xsl:value-of select="$title"/></xsl:message>
  <xsl:message>bookInfo:  <xsl:value-of select="$bookInfo"/></xsl:message>
  <xsl:message>ccsubj:    <xsl:value-of select="$ccsubj"/></xsl:message>
  <xsl:message>head:      <xsl:value-of select="$headtitle"/></xsl:message>
  <xsl:message>author:    <xsl:value-of select="$author"/></xsl:message>
  <xsl:message>notes:     <xsl:value-of select="$myNotes"/></xsl:message>
  <xsl:message>sect:      <xsl:value-of select="$sect"/></xsl:message>
  <xsl:message>mySectID:  <xsl:value-of select="$mySectID"/></xsl:message>
  <xsl:message>osisRef:   <xsl:value-of select="$osisRef"/></xsl:message>
  <xsl:message>urls:      <xsl:value-of select="$urls"/></xsl:message>
  <xsl:message>urlPrefix: <xsl:value-of select="$urlPrefix"/></xsl:message>
  <xsl:message>tocURL:    <xsl:value-of select="$tocURL"/></xsl:message>
  <xsl:message>aboutURL:  <xsl:value-of select="$aboutURL"/></xsl:message>
  <xsl:message>theElt:    <xsl:value-of select="$theElt/@id"/></xsl:message>
  <xsl:message>theDivID:  <xsl:value-of select="$theDivID"/></xsl:message>
  <xsl:message>isDict:    <xsl:value-of select="$isDict"/></xsl:message>
  <xsl:message>term:      <xsl:value-of select="$term"/></xsl:message>
  <xsl:message>myTerm:    <xsl:value-of select="$myTerm"/></xsl:message>
</xsl:if>

<html>
  <head>
    <title><xsl:value-of select="$title"/> (<xsl:value-of select="translate($mySectID,'+',' ')"/>)</title>
    <link rel="stylesheet" type="text/css" href="/ss/ThML10.css"/>
    
    <!-- stylesheet -->
    <xsl:choose>
      <xsl:when test="$sect='all' and not(/processing-instruction()[name()='thml-authorID'])">
        <style type="text/css">
          <xsl:value-of select="/ThML/ThML.head/style[@type='text/css']"/>
        </style>
      </xsl:when>
      <xsl:otherwise>
        <link rel="stylesheet" type="text/css" href="{$bookID}.css"/>
      </xsl:otherwise>
    </xsl:choose>

    <!-- add javascript for isDaily documents -->
      <xsl:if test="$isDaily=1">
	<script language="javascript" type="text/javascript">
  	  function goToday() {
	    var d = new Date();
	    var theloc = "d";
	    if (d.getMonth() &lt; 9) theloc += "0";
	    theloc += String(d.getMonth() +1);
	    if (d.getDate() &lt; 10) theloc += "0";
	    theloc += String(d.getDate());

	    <xsl:if test="$bookID='morneve'">
		if (d.getHours() &lt; 12) theloc += "am";
			else theloc += "pm";
	    </xsl:if>
	    <xsl:choose>
	      <xsl:when test="$urls='in'">
		self.location = "#" + theloc;
	      </xsl:when>
	      <xsl:otherwise>
		self.location = "<xsl:value-of select="$bookID"/>." +
		theloc + ".html";
	      </xsl:otherwise>			
	    </xsl:choose>
	    return false;
	  }

	  function goDay(month,day) {
	    var m=month.value;
	    var da = day.value;
	    var d = new Date();
	    var theloc = "d";
	    if (((m=="04" || m=="06" || m=="09" || m=="11") &amp;&amp; da=="31") || (m=="02" &amp;&amp; (da=="30" || da=="31"))) {
		alert("Invalid date!  Try again.");
		return false;
	    }
	    theloc += String(m) + String(da);
	    <xsl:if test="$bookID='morneve'">
		if (d.getHours() &lt; 12) theloc += "am";
			else theloc += "pm";
	    </xsl:if>
	    <xsl:choose>
	      <xsl:when test="$urls='in'">
		self.location = "#" + theloc;
	      </xsl:when>
	      <xsl:otherwise>
		self.location = "<xsl:value-of select="$bookID"/>." +
		theloc + ".html";
	      </xsl:otherwise>
	    </xsl:choose>
	    return false;
	  }
	</script>
    </xsl:if>
  </head>

  <body>
  <xsl:attribute name="onLoad">init.call(); highlightSearch();</xsl:attribute>
  <xsl:if test="$isDaily=1 and $sect='today'">
		<script>
			goToday();
		</script>
  </xsl:if>
  <script language="javascript" type="text/javascript" src="/ss/util-dom.js"></script>
  <script language="javascript" type="text/javascript" src="/ss/highlight.js"></script>
  <xsl:choose>
    <xsl:when test="$osisRef != ''">
      <xsl:apply-templates select="/ThML/ThML.body/div1[@id=$osisSect] |
      	/ThML/ThML.body/div1/div2[@id=$osisSect] |
      	/ThML/ThML.body/div1/div2/div3[@id=$osisSect] |
      	/ThML/ThML.body/div1/div2/div3/div4[@id=$osisSect] |
      	/ThML/ThML.body/div1/div2/div3/div4/div5[@id=$osisSect]"
	mode="includeParsing"/>
    </xsl:when>

    <!-- for a term request on server, which says section is about -->
    <!--
    <xsl:when test="$desktop!='1' and $myTerm != ''">
      <xsl:apply-templates select="/ThML/ThML.body/div1/div2[@id='a']/glossary" mode="dict"/>
    </xsl:when>
    -->

    <xsl:when test="$mySectID='about'">
      <xsl:apply-templates select="/ThML/ThML.head|ThML.head" mode="includeParsing"/>
    </xsl:when>

    <!-- here for dictBookID.html?term=myTerm -->
    <xsl:when test="$mySectID='toc' and $myTerm!=''">
      <xsl:variable name="filename">
        <xsl:if test="$desktop='1'"><xsl:text>../books/</xsl:text></xsl:if>
	<xsl:if test="$desktop='0'"><xsl:text>/ccel/</xsl:text></xsl:if>
	<xsl:value-of
        select="$authLet"/>/<xsl:value-of
        select="$authorID"/>/<xsl:value-of 
        select="$bookID"/>/xml/<xsl:value-of
        select="$bookID"/>.<xsl:value-of
	select="substring($myTerm,1,1)"/>.xml</xsl:variable>
      <xsl:apply-templates select="document($filename,$rootPath)//glossary"
      	mode="dict"/>
    </xsl:when>

    <xsl:when test="$mySectID='toc'">
      <xsl:apply-templates select="/ThML/ThML.body|ThML.body" mode="includeParsing"/>
    </xsl:when>

    <xsl:when test="substring($sect,1,1)='_'">
      <xsl:apply-templates select="$theElt" mode="includeParsing"/>
    </xsl:when>

    <xsl:when test="$theDivID != '' and $start=''">
      <xsl:apply-templates select="/ThML/ThML.body/div1[@id=$theDivID] |
      	/ThML/ThML.body/div1/div2[@id=$theDivID] |
      	/ThML/ThML.body/div1/div2/div3[@id=$theDivID] |
      	/ThML/ThML.body/div1/div2/div3/div4[@id=$theDivID] |
      	/ThML/ThML.body/div1/div2/div3/div4/div5[@id=$theDivID]"
	mode="includeParsing"/>
    </xsl:when>

    <xsl:when test="$sect='today' and $isDaily=1">
      <h1>Going to today's reading...</h1>
    </xsl:when>

    <xsl:when test="$isDict=1 and ($myTerm!='' or $start!='')">
      <xsl:if test="$myTerm!=''">
        <xsl:choose>
	  <xsl:when test="//glossary/term[translate(.,
  		$termTrans, 
		'abcdefghijklmnopqrstuvwxyz ')=$myTerm]">
            <xsl:call-template name="dictTerm" />
	  </xsl:when>
	  <xsl:otherwise>
	      <xsl:call-template name="dictTermNotFound"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:if>
      <xsl:if test="$start!=''">
        <xsl:call-template name="dictStart" />
      </xsl:if>
    </xsl:when>

    <xsl:otherwise>	<!-- $sect should be 'all' -->
      <xsl:apply-templates select="*" mode="includeParsing"/>
      <xsl:apply-templates select="/ThML/ThML.body/*" mode="includeParsing"/>
    </xsl:otherwise>

  </xsl:choose>

  <xsl:if test="substring($sect,1,1) != '_'">
    <xsl:call-template name="add-footer"/>
  </xsl:if>

  </body>
</html>
</xsl:template>


<!-- ================================================================ -->
<!-- divn template: if $sect=all, process all divs, else only         -->
<!-- requested one(s). Handle navbar and notes, then apply-templates. -->
<!-- ================================================================ -->
<xsl:template match="div1|div2|div3|div4|div5|div[@type='sect']" mode="includeParsing">
  <xsl:if test="($sect='all' or @id=$theDivID or @id=$osisSect)">
    <xsl:call-template name="navbar">
      <xsl:with-param name="progress" select="@progress"/>
    </xsl:call-template>
    <a name="navtop" id="navtop"/>
    <xsl:apply-templates mode="includeParsing" />
    <xsl:if test="./p//note and $myNotes='foot'">
      <hr class="Note" id="noteBottom"/>
    </xsl:if>
    <xsl:if test=".//note and $myNotes='foot'">
      <xsl:apply-templates select="./*" mode="createNotes"/>
    </xsl:if>
    <a name="navbottom" id="navbottom"/>
    <xsl:call-template name="navbar">
      <xsl:with-param name="progress" select="@progress"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>


<!-- ============================================================ -->
<!-- Generate a spiffy Table of Contents with expandable outline. -->
<!-- ============================================================ -->
<xsl:template match="ThML.body" name="toc" mode="includeParsing">
<table id="bcbHide" bgcolor="#660000" style="margin-top:24pt; width:100%">
  <tbody>
  <tr><td><p class="whitehead" style="text-align:center"><xsl:value-of
	select="$title"/> - Table of Contents</p></td></tr>
  </tbody>
</table>
  <h1 class="title"><xsl:value-of select="$title"/></h1>
  <h3 class="subhead">by</h3>
  <h2 class="subhead"><xsl:value-of select="$author"/></h2>
  <hr width="30%"/>
  <div style="text-align:center; margin-left:0.5in; margin-right:0.5in">
    <table align="center"><tbody><tr><td>
      <h1 class="title" id="toc">Table of Contents</h1>
	  <xsl:if test="$isDaily=1">
	    <p class="TOC1" style="text-align:center">
		<form onsubmit="return goToday()">
		<input type="submit" value="Go to today"/>
		</form>
		</p>
		<p class="TOC1" style="text-align:center">
		  <form onsubmit="return goDay(month,day)">
		   <select name="month">
		     <option value="01">January</option>
		     <option value="02">February</option>
		     <option value="03">March</option>
		     <option value="04">April</option>
		     <option value="05">May</option>
		     <option value="06">June</option>
		     <option value="07">July</option>
		     <option value="08">August</option>
		     <option value="09">September</option>
		     <option value="10">October</option>
		     <option value="11">November</option>
		     <option value="12">December</option>
		   </select>
		   <select name="day">
		     <option value="01">1</option>
		     <option value="02">2</option>
		     <option value="03">3</option>
		     <option value="04">4</option>
		     <option value="05">5</option>
		     <option value="06">6</option>
		     <option value="07">7</option>
		     <option value="08">8</option>
		     <option value="09">9</option>
		     <option value="10">10</option>
		     <option value="11">11</option>
		     <option value="12">12</option>
		     <option value="13">13</option>
		     <option value="14">14</option>
		     <option value="15">15</option>
		     <option value="16">16</option>
		     <option value="17">17</option>
		     <option value="18">18</option>
		     <option value="19">19</option>
		     <option value="20">20</option>
		     <option value="21">21</option>
		     <option value="22">22</option>
		     <option value="23">23</option>
		     <option value="24">24</option>
		     <option value="25">25</option>
		     <option value="26">26</option>
		     <option value="27">27</option>
		     <option value="28">28</option>
		     <option value="29">29</option>
		     <option value="30">30</option>
		     <option value="31">31</option>
		   </select>
		   <input type="submit" value="Go to day..."/>
		</form>
		</p>
	  </xsl:if>
      <p class="TOC1" style="text-align:center">
        <a bcbTarg="true" class="TOC" href="{$aboutURL}">
          <i>About This Book</i> 
        </a>
      </p>
      <xsl:apply-templates select="div1[1]" mode="tocRequestDom1"/>
    <p id="bcbHide" style="text-indent:0in;margin-top:12pt">
	      <a href="/files/nav.htm">Navigation and searching hints</a>
    </p>
	<xsl:if test="$isDict=1">
	<p id="bcbHide" style="text-indent:0in;margin-top:12pt">
	  <form action="/termSearch">

	    Look up an entry:
		<input type="text" name="q"/>
		<input type="hidden" name="authorID" value="{$authorID}"/>
		<input type="hidden" name="bookID" value="{$bookID}"/>
		<input type="submit" value="Search"/>
	  </form>
	</p>
	<p class="nav">
	<xsl:for-each select="document('')/*/letter:alphabet/letter:letter">
	  <a class="TOC" href="/termSearch?authorID={$authorID}&amp;bookID={$bookID}&amp;q={.}"><xsl:value-of select="translate(., 'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')" /></a><xsl:text> </xsl:text>
	</xsl:for-each>
	</p></xsl:if>
    </td></tr></tbody></table>
  </div>
  <hr id="bcbHide"/>
</xsl:template>

<xsl:template match="div1|div2|div3|div4|div5" mode="tocRequestDom1">
  <xsl:variable name="unique" select="@id"/>
  <div>
    <xsl:choose>
      <xsl:when test="local-name(.) = 'div1'">
        <xsl:attribute name="style">display:block</xsl:attribute>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute name="style">display:none</xsl:attribute>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:attribute name="id">d<xsl:value-of select="$unique"/></xsl:attribute>
    <xsl:apply-templates select=".|following-sibling::div1|following-sibling::div2|following-sibling::div3|following-sibling::div4|following-sibling::div5" mode="tocFillDivDom1"/>
  </div>
</xsl:template>

<xsl:template match="div1|div2|div3|div4|div5" mode="tocFillDivDom1">
  <xsl:variable name="level">
    <xsl:value-of select="substring-after(local-name(.), 'div')"/>
  </xsl:variable>
  <p class="{concat('TOC', $level)}">
  <xsl:if test="boolean(div2|div3|div4|div5)">
    <xsl:variable name="nextUnique" select="div2/@id|div3/@id|div4/@id|div5/@id"/>
    <a>
      <xsl:attribute name="href">javascript:t(&apos;d<xsl:value-of select="$nextUnique"/>&apos;,&apos;p<xsl:value-of select="$nextUnique"/>&apos;)</xsl:attribute>
      <img alt="Click to expand or collapse this item" title="Click to expand or collapse this item" name="imEx" border="0" src="/pix/shut.gif" onmouseover="javascript:highlight(this)" onmouseout="javascript:unhighlight(this)">
        <xsl:attribute name="id">p<xsl:value-of select="$nextUnique"/></xsl:attribute>
      </img>
    </a>&#160;
  </xsl:if>
  <a bcbParam="true" class="TOC" href="{$urlPrefix}{@id}{$urlSuffix}">
    <xsl:value-of select="@title"/>
  </a>
  </p>
  <xsl:apply-templates
    select="div2[1]|div3[1]|div4[1]|div5[1]" mode="tocRequestDom1"/>
</xsl:template>


<!-- ====================================================== -->
<!-- Create a list of dictionary terms starting with $start -->
<!-- ====================================================== -->
<xsl:template name="dictStart">
  <xsl:variable name="firstletter" select="substring($start,1,1)" />
  <xsl:variable name="prev1">
    <xsl:choose>
      <xsl:when test="string-length($start) != 1">
	<xsl:value-of select="substring($start,1,1)" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="translate($start, 
              'abcdefghijklmnopqrstuvwxyz','zabcdefghijklmnopqrstuvwxy')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="next1">
    <xsl:choose>
      <xsl:when test="string-length($start) != 1">
        <xsl:value-of select="substring($start,1,1)" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="translate($start, 
              'abcdefghijklmnopqrstuvwxyz','bcdefghijklmnopqrstuvwxyza')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:call-template name="navbar">
     <xsl:with-param name="prev" select="$prev1" />
     <xsl:with-param name="prevParam">?start=<xsl:value-of
       select="$prev1" /></xsl:with-param>
     <xsl:with-param name="next" select="$next1" />
     <xsl:with-param name="nextParam">?start=<xsl:value-of
       select="$next1" /></xsl:with-param>
  </xsl:call-template>

  <h3>Terms starting with <xsl:value-of select="translate($start, 
  	'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')" /></h3>
  <ul>
    <xsl:for-each select="//glossary/term[translate(substring(.,1,
    	string-length($start)), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
	'abcdefghijklmnopqrstuvwxyz')=$start]">
      <xsl:variable name="first1" select="substring($start,1,1)"/>

      <li><a href="{$bookID}.{$first1}.html?term={translate(.,' ,;',
      	'+')}"><xsl:value-of select="."/></a></li>
     </xsl:for-each>
  </ul>
</xsl:template>


<!-- ========================================== -->
<!-- Create a dictionary term page for $myTerm  -->
<!-- ========================================== -->
<xsl:template match="*" mode="dict">
  <xsl:choose>
    <xsl:when test="//glossary/term[translate(.,$termTrans, 
	'abcdefghijklmnopqrstuvwxyz ')=$myTerm]">
      <xsl:call-template name="dictTerm" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="dictTermNotFound"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="dictTerm">
  <xsl:variable name="termNode" select="//glossary/term[translate(.,$termTrans,
	'abcdefghijklmnopqrstuvwxyz ')=$myTerm]"/>

  <xsl:call-template name="navbar">
    <xsl:with-param name="prev"
            select="translate(substring($termNode/preceding::term[1],1,1),
            'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')" />
    <xsl:with-param name="prevParam">
    	<xsl:if test="$termNode/preceding::term[1]">?term=<xsl:call-template name="url-encode">
            <xsl:with-param name="str" select="$termNode/preceding::term[1]" /></xsl:call-template></xsl:if>
    </xsl:with-param>
    <xsl:with-param name="next"
            select="translate(substring($termNode/following::term[1],1,1),
            'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')" />
    <xsl:with-param name="nextParam">
    	<xsl:if test="$termNode/following::term[1]">?term=<xsl:call-template name="url-encode">
            <xsl:with-param name="str" select="$termNode/following::term[1]" /></xsl:call-template></xsl:if>
    </xsl:with-param>
  </xsl:call-template>
  <a name="navtop" id="navtop"/>

  <dl>
    <b><xsl:apply-templates select="$termNode" mode="includeParsing"/></b>
    <xsl:apply-templates select="$termNode/following-sibling::def[1]" 
      mode="includeParsing"/>
  </dl>

  <xsl:if test="string-length($myTerm) &gt; 2">
    <xsl:if test="count(//glossary/term[contains(translate(.,
      $termTrans,'abcdefghijklmnopqrstuvwxyz '),
      $myTerm)]) &gt; 1">
      <h5>Or did you want:</h5>
      <ul>
        <xsl:for-each select="//glossary/term[contains(translate(.,
          $termTrans,'abcdefghijklmnopqrstuvwxyz '),
          $myTerm) and not(translate(., $termTrans,
          'abcdefghijklmnopqrstuvwxyz ')=$myTerm)]">
		<xsl:variable name="tempTerm">
			<xsl:call-template name="url-encode">
			<xsl:with-param name="str" select="."/>
			</xsl:call-template>
		</xsl:variable>
          <li><a href="{$bookID}.{substring($myTerm,1,1)}.html?term={$tempTerm}"><xsl:value-of 
            select="."/></a></li>          
        </xsl:for-each>
      </ul>
    </xsl:if>
  </xsl:if>

  <h5><a href="/termSearch?q={substring($myTerm,1,2)}&amp;authorID={$authorID}&amp;bookID={$bookID}">More terms</a></h5>
<a name="navbottom" id="navbottom"/>
<xsl:call-template name="navbar">
    <xsl:with-param name="prev"
            select="translate(substring($termNode/preceding::term[1],1,1),
            'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')" />
    <xsl:with-param name="prevParam">
    	<xsl:if test="$termNode/preceding::term[1]">?term=<xsl:call-template name="url-encode">
            <xsl:with-param name="str" select="$termNode/preceding::term[1]" /></xsl:call-template></xsl:if>
    </xsl:with-param>
    <xsl:with-param name="next"
            select="translate(substring($termNode/following::term[1],1,1),
            'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')" />
    <xsl:with-param name="nextParam">
    	<xsl:if test="$termNode/following::term[1]">?term=<xsl:call-template name="url-encode">
            <xsl:with-param name="str" select="$termNode/following::term[1]" /></xsl:call-template></xsl:if>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>


<!-- ======================================================= -->
<!-- Create a dictionary term page when $myTerm isn't found  -->
<!-- ======================================================= -->
<xsl:template name="dictTermNotFound">
  <xsl:call-template name="navbar">
    <xsl:with-param name="prev" select="substring($myTerm,1,1)"/>
    <xsl:with-param name="prevParam">?start=<xsl:value-of 
    	select="substring($myTerm,1,1)"/>
    </xsl:with-param>
    <xsl:with-param name="next"
      select="translate(substring($myTerm,1,1), 
      'abcdefghijklmnopqrstuvwxyz','bcdefghijklmnopqrstuvwxyza')"/>
    <xsl:with-param name="nextParam">?start=<xsl:value-of 
      select="translate(substring($myTerm,1,1), 
      'abcdefghijklmnopqrstuvwxyz','bcdefghijklmnopqrstuvwxyza')"/>
    </xsl:with-param>
  </xsl:call-template>

  <h2 termName="{$myTerm}">Term not found.</h2>
  <xsl:choose>
    
    <!-- if myTerm is contained by an existing term... -->
    <xsl:when test="count(//glossary/term[contains(translate(.,
        $termTrans,'abcdefghijklmnopqrstuvwxyz '),
	$myTerm)]) &gt; 0">
      <h5>What about these terms?</h5>
        <ul>
          <xsl:for-each select="//glossary/term[contains(translate(.,
              $termTrans,'abcdefghijklmnopqrstuvwxyz '),
	      $myTerm)]">
            <li><a bcbParam="true">
            <xsl:attribute name="href">
            <xsl:value-of select="$bookID"/>.<xsl:value-of select="translate(substring(.,1,1),
	      'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"/>
	      <xsl:value-of select="$urlSuffix"/>?term=<xsl:call-template name="url-encode"> 
	      <xsl:with-param name="str" select="."/></xsl:call-template>
	      </xsl:attribute>
	      <xsl:value-of select="."/></a></li>
          </xsl:for-each>
        </ul>
      </xsl:when>

      <!-- if myTerm isn't contained in an existing term, return
           terms that start with the same two letters -->
      <xsl:otherwise>
        <xsl:variable name="beginTerm" select="substring($myTerm,1,2)"/>
	<xsl:if test="//glossary/term[starts-with(translate(., 
		$termTrans,'abcdefghijklmnopqrstuvwxyz '),
		$beginTerm)]">
	<h5>What about these terms?</h5>
        <ul>
        <xsl:for-each select="//glossary/term[starts-with(translate(., 
		$termTrans,'abcdefghijklmnopqrstuvwxyz '),
		$beginTerm)]">
		<xsl:variable name="tempTerm">
			<xsl:call-template name="url-encode">
			<xsl:with-param name="str" select="."/>
			</xsl:call-template>
		</xsl:variable>
          <li><a bcbParam="true" href="{$bookID}.{translate(substring(.,1,1),
	    'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
	    'abcdefghijklmnopqrstuvwxyz')}{$urlSuffix}?term={$tempTerm}"><xsl:value-of 
	  select="."/></a></li>
        </xsl:for-each>
        </ul>
	</xsl:if>
      </xsl:otherwise>
    </xsl:choose>
</xsl:template>


<!-- ============================================== -->
<!-- Gnarly template to generate the about page     -->
<!-- ============================================== -->
<xsl:template match="ThML.head" name="about" mode="includeParsing">
  
  <p><a name="about">&#160;</a></p>
  <center>
  <table border="2" bordercolor="#660000" style="margin-top:12pt; width: 440pt" >
    <tbody>
    <tr>
      <td bgcolor="#660000" width="100%" colspan="3"><p class="whitehead" style="text-align:center; font-size:14pt">About  
        <i><xsl:value-of select="$title"/></i> by <xsl:value-of select="$author"/></p>
      </td>
    </tr>
    <tr><td colspan="3">
      <center>
      <p style="text-align:center; margin-top:12pt">
      <form method="get" action="http://www.ccel.org/search">
	<span style="font-weight:bold; font-size:14pt"><a bcbParam="true" class="TOC" href="{$titlepageURL}">Title Page</a></span>
	&#160; &#160; &#160;
	<span style="font-weight:bold; font-size:14pt"><a bcbParam="true" class="TOC" href="{$tocURL}">Table of Contents</a></span>
	&#160; &#160; &#160;
	<xsl:if test="$isDaily=1">
	  <span style="font-weight:bold; font-size:14pt"><a class="TOC" 
		href="javascript:goToday()">Today's Reading</a></span>
	</xsl:if>
	&#160; &#160; &#160;

	<input type="hidden" name="a" value="advanced_search" />
	<input type="hidden" name="authorID" value="{$authorID}" />
	<input type="hidden" name="bookID" value="{$bookID}" />
	<span style="font-weight:bold; font-size:16pt">Search:</span>&#160;
	<input type="text" size="12" name="q" value="" />
 	<input type="Submit" value="Go" />
      </form>
      </p>
      </center>
    </td></tr>
    <tr><td ><table>
      <tbody>
      <tr>	
        <td style="width:110pt; text-align:right;">
	  <p style="margin-top:12pt"><b>Title:</b></p></td>
        <td style="width:5pt"></td>
        <td width="*">
	  <p style="margin-top:12pt">
          <a class="TOC" bcbParam="true" href="{$titlepageURL}">
          <xsl:value-of select="$title"/></a></p></td>
      </tr>

      <tr>	
        <td align="right" valign="top"><b>Creator(s):</b></td>
        <td></td>
        <td><a class="TOC">
          <xsl:attribute name="href">
            <xsl:choose>
              <xsl:when test="$desktop=1">/ccel/<xsl:value-of
	        select="$authorID"/>.html</xsl:when> 
	      <xsl:otherwise>/<xsl:value-of select="$authLet"/>/<xsl:value-of 
	        select="$authorID"/></xsl:otherwise>
	    </xsl:choose>
          </xsl:attribute>
          <xsl:value-of select="electronicEdInfo/DC/DC.Creator[@sub='Author' and @scheme='file-as']"/></a>
          <xsl:for-each select="electronicEdInfo/DC/DC.Creator[@sub!='Author' and @scheme='file-as']">
            <br/><xsl:value-of select="."/><xsl:if test="@sub != ''">  (<xsl:value-of select="@sub"/>)</xsl:if>
          </xsl:for-each>
        </td>
      </tr>

    <xsl:if test="electronicEdInfo/DC/DC.Publisher!=''">
      <tr><td align="right" valign="top"><b>Publisher:</b></td><td></td><td><xsl:value-of 
      	select="electronicEdInfo/DC/DC.Publisher"/></td></tr>
    </xsl:if>

    <xsl:if test="generalInfo/description != ''">
      <tr><td align="right" valign="top"><b>Description:</b></td><td></td><td><xsl:apply-templates 
      	select="generalInfo/description" mode="includeParsing"/></td></tr>
    </xsl:if>

    <xsl:if test="generalInfo/firstPublished != ''">
      <tr><td align="right" valign="top"><b>First Published:</b></td><td></td><td><xsl:apply-templates 
      	select="generalInfo/firstPublished" mode="includeParsing"/></td></tr>
    </xsl:if>

    <xsl:if test="generalInfo/pubHistory != ''">
      <tr><td align="right" valign="top"><b>Publication History:</b></td><td></td><td><xsl:apply-templates 
      	select="generalInfo/pubHistory" mode="includeParsing"/></td></tr>
    </xsl:if>

    <xsl:if test="printSourceInfo/published != ''">
      <tr><td align="right" valign="top"><b>Print Basis:</b></td><td></td><td><xsl:apply-templates 
      	select="printSourceInfo/published" mode="includeParsing"/></td></tr>
    </xsl:if>

    <xsl:if test="electronicEdInfo/DC/DC.Source[not(@scheme)] != ''">
      <tr><td align="right" valign="top"><b>Source:</b></td><td></td><td>
        <xsl:choose>
	  <xsl:when test="electronicEdInfo/DC/DC.Source[@scheme = 'URL'] != ''">
	    <a class="TOC" href="{electronicEdInfo/DC/DC.Source[@scheme = 'URL']}"><xsl:value-of 
	    	select="electronicEdInfo/DC/DC.Source[not(@scheme)]"/></a>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:value-of select="electronicEdInfo/DC/DC.Source[not(@scheme)]"/>
	  </xsl:otherwise>
	</xsl:choose>
      </td></tr>
    </xsl:if>

    <xsl:variable name="lang" select="electronicEdInfo/DC/DC.Language"/>
    <xsl:if test="$lang != '' and not(starts-with($lang, 'en'))">
      <tr><td align="right" valign="top"><b>Language:</b></td><td></td><td>
      <xsl:value-of select="document('')/*/lang:name[@code=$lang]"/></td></tr>
    </xsl:if>

    <xsl:if test="electronicEdInfo/series != ''">
      <tr>
        <td align="right" valign="top"><b>Series:</b></td><td></td>
        <td><xsl:value-of select="electronicEdInfo/series"/>
      </td></tr>
    </xsl:if>

    <xsl:if test="electronicEdInfo/DC/DC.Rights != ''">
      <tr><td align="right" valign="top"><b>Rights:</b></td><td></td><td><xsl:value-of 
      	select="electronicEdInfo/DC/DC.Rights"/></td></tr>
    </xsl:if>

    <xsl:if test="electronicEdInfo/DC/DC.Date[@sub = 'Created'] != ''">
      <tr><td align="right" valign="top"><b>Date Created:</b></td><td></td><td><xsl:value-of 
      	select="electronicEdInfo/DC/DC.Date[@sub = 'Created']"/></td></tr>
    </xsl:if>

    <xsl:if test="electronicEdInfo/status != ''">
      <tr><td align="right" valign="top"><b>Status:</b></td><td></td><td><xsl:apply-templates 
      	select="electronicEdInfo/status" mode="includeParsing"/></td></tr>
    </xsl:if>

    <xsl:if test="generalInfo/comments != ''">
      <tr><td align="right" valign="top"><b>Comments:</b></td><td></td><td><xsl:apply-templates 
      	select="generalInfo/comments" mode="includeParsing"/></td></tr>
    </xsl:if>

    <xsl:if test="electronicEdInfo/editorialComments != ''">
      <tr><td align="right" valign="top"><b>Editorial Comments:</b></td><td></td><td><xsl:apply-templates 
      	select="electronicEdInfo/editorialComments" mode="includeParsing"/></td></tr>
    </xsl:if>

    <xsl:if test="electronicEdInfo/DC/DC.Contributor != ''">
      <tr><td align="right" valign="top"><b>Contributor(s):</b></td><td></td><td>
        <xsl:for-each select="electronicEdInfo/DC/DC.Contributor">
          <xsl:if test=". != ''">
            <xsl:value-of select="."/> (<xsl:value-of select="@sub"/>)<br/>
          </xsl:if>
        </xsl:for-each></td>
      </tr>
    </xsl:if>

    <xsl:if test="electronicEdInfo/DC/DC.Subject[@scheme = 'ccel'] != ''">
      <tr><td align="right" valign="top"><b>CCEL Subjects:</b></td><td></td><td><xsl:value-of 
      	select="electronicEdInfo/DC/DC.Subject[@scheme = 'ccel']"/></td>
      </tr>
    </xsl:if>

    <xsl:if test="electronicEdInfo/DC/DC.Subject[@scheme = 'LCCN'] != ''">
      <tr><td align="right" valign="top"><b>LC Call no:</b></td><td></td><td><xsl:variable name="lccn" 
      	select="electronicEdInfo/DC/DC.Subject[@scheme = 'LCCN']"/><xsl:value-of 
	select="electronicEdInfo/DC/DC.Subject[@scheme='LCCN']"/></td>
      </tr>
    </xsl:if>

    <xsl:if test="electronicEdInfo/DC/DC.Subject[starts-with(@scheme, 'lcsh')] != ''">
      <tr><td align="right" valign="top"><b>LC Subjects:</b></td><td></td><td>
        <xsl:for-each select="electronicEdInfo/DC/DC.Subject[starts-with(@scheme, 'lcsh')]">
          <xsl:variable name="class" select="concat('t', substring-after(@scheme, 'lcsh'))"/>
          <p class="{$class}"><xsl:value-of select="."/></p>
        </xsl:for-each></td>
      </tr>
    </xsl:if>

    <xsl:if test="contains($ccsubj,'Shell')=false">
    <tr><td align="right" valign="top">
        <p style="margin-bottom:12pt"><b><a class="TOC"
    	href="http://www.ccel.org/help/formats.html">Other Formats:</a></b></p></td>
      <td></td><td>
      <p style="margin-bottom:12pt">
      <a class="TOC" href="/{$authLet}/{$authorID}/{$bookID}.xml">ThML</a>
      - <a class="TOC" href="/ccel/{$authorID}/{$bookID}.pdf">pdf</a>
      - <a class="TOC" href="/ccel/{$authorID}/{$bookID}.pdb">pdb</a>
      - <a class="TOC" href="/ccel/{$authorID}/{$bookID}.htm">htm</a>
      - <a class="TOC" href="/ccel/{$authorID}/{$bookID}.txt">txt</a>
      - <a class="TOC" href="/ccel/{$authorID}/{$bookID}.fo">fo</a>
      <xsl:if test="not($desktop=1)">

        <xsl:for-each select="document($bookInfo)/bookInfo/format">
          <xsl:text> - </xsl:text><a class="TOC" href="{.}"><xsl:value-of 
		  select="@type"/></a>
        </xsl:for-each>
      </xsl:if>
      </p>
      </td>
    </tr>
    </xsl:if>
  </tbody>
    </table>
     <table style="width:100%">
       <tbody>
       <tr><td bgcolor="#660000" width="100%" colspan="3">
         <p class="whitehead" style="text-align:center;font-size:14pt">
           Other ways to get <i><xsl:value-of select="$title"/></i></p></td></tr>
       <tr><td colspan="3">
       <xsl:copy-of select="document($bookInfo)/bookInfo/offer/*"/>

       <p style="margin-top:12pt; margin-left:10%">
         <a href="http://www.christianbook.com/Christian/Books/easy_find?event=AFF&amp;p=1026055&amp;Ns=product.number_sold&amp;Nso=1&amp;Ntk=typeset.typeset&amp;Ntt={$authorID}%20{$bookID}&amp;Nu=product.endeca_rollup">
	 Search for this book at ChristianBooks.com</a>
       </p>

      </td></tr>
       </tbody>
   </table>
   </td></tr>
 </tbody>
</table>
</center>
</xsl:template>


<!-- =========================================== -->
<!-- standard navbar, with doc and section title -->
<!-- =========================================== -->
<xsl:template name="navbar">
<xsl:param name="prev"/>
<xsl:param name="next"/>
<xsl:param name="prevParam"></xsl:param>
<xsl:param name="nextParam"></xsl:param>
<!-- prev and next should be attributes with the ID of the previous and next
     section. If they aren't there we can compute them, but that takes time. -->
  <xsl:variable name="myPrev">
    <xsl:value-of select="$urlPrefix"/>
    <xsl:choose>
      <xsl:when test="@prev"><xsl:value-of select="@prev"/></xsl:when>
	  <xsl:when test="$prev=''">toc</xsl:when>
	  <xsl:when test="$prev"><xsl:value-of select="translate($prev,' ;,','+')"/></xsl:when>
      <xsl:otherwise><xsl:value-of select="preceding-sibling::div1[1]/div2[last()]/div3[last()]/div4[last()]/@id|preceding-sibling::div1[1]/div2[last()]/div3[last()]/@id|preceding-sibling::div2[1]/div3[last()]/div4[last()]/@id|preceding-sibling::div3[1]/div4[last()]/div5[last()]/@id|preceding-sibling::div1[1]/div2[last()]/@id|preceding-sibling::div2[1]/div3[last()]/@id|preceding-sibling::div3[1]/div4[last()]/@id|preceding-sibling::div4[1]/div5[last()]/@id|preceding-sibling::div1[1]/@id|preceding-sibling::div2[1]/@id|preceding-sibling::div3[1]/@id|preceding-sibling::div4[1]/@id|preceding-sibling::div5[1]/@id|ancestor::*/@id"/></xsl:otherwise>
    </xsl:choose>
     <xsl:value-of select="$urlSuffix"/>
     <!--<xsl:value-of select="translate($prevParam,'?','&amp;')"/>-->
     <xsl:value-of select="$prevParam"/>
  </xsl:variable>
  <xsl:variable name="myNext">
  	<xsl:value-of select="$urlPrefix"/>
    <xsl:choose>
      <xsl:when test="@next"><xsl:value-of select="@next"/></xsl:when>
      <xsl:when test="$next=''">toc</xsl:when>
	  <xsl:when test="$next"><xsl:value-of select="translate($next,' ;,','+')"/></xsl:when>
      <xsl:otherwise><xsl:value-of select="div1/@id|div2/@id|div3/@id|div4/@id|div5/@id|following-sibling::*/@id|../following-sibling::*/@id|../../following-sibling::*/@id|../../../following-sibling::*/@id|../../../../following-sibling::*/@id"/></xsl:otherwise>
    </xsl:choose>
    <xsl:value-of select="$urlSuffix"/>
     <!--<xsl:value-of select="translate($nextParam,'?','&amp;')"/>-->
     <xsl:value-of select="$nextParam"/>
  </xsl:variable>

<xsl:if test="$debug">
  <xsl:message>myPrev:  <xsl:value-of select="$myPrev"/></xsl:message>
  <xsl:message>myNext:  <xsl:value-of select="$myNext"/></xsl:message>
</xsl:if>

  <p id="bcbHide"><a><xsl:attribute name="name"><xsl:value-of select="@id"/></xsl:attribute>&#160;</a></p>
  <table id="bcbHide" width="100%" bgcolor="#660000">
    <tbody>
    <tr>
      <td valign="top" class="whitehead" style="text-align:left;
      font-size:77%; width:37%"><div style="height:12pt; overflow:hidden">
	<a style="color:#FFFFFF; text-decoration:none" href="{$urlPrefix}html">
          <xsl:value-of select="$headtitle"/></a></div></td>
      <td valign="top" class="whitehead" style="text-align:center">
        <a bcbParam="true" href="{$myPrev}">
        <!--<img onmouseover="this.style.borderColor='#CC6666'" onmouseout="this.style.borderColor='#660000'" src="/pix/mroonppv.gif" alt="Previous" title="Previous" style="border-color:#660000" border="2"/>-->
          <img border="0" src="/pix/mroonppv.gif" alt="Previous"/>
        </a>
	<a bcbParam="true" href="{$tocURL}">
		<!--<img onmouseover="this.style.borderColor='#CC6666'" onmouseout="this.style.borderColor='#660000'" src="/pix/mroontoc.gif" alt="Table of Contents" title="Contents" style="border-color:#660000" border="2"/>-->
          <img border="0" src="/pix/mroontoc.gif" alt="Contents"/>
        </a>
        <a bcbParam="true" href="{$myNext}">
			<!--<img onmouseover="this.style.borderColor='#CC6666'" onmouseout="this.style.borderColor='#660000'" src="/pix/mroonpnx.gif" alt="Next" title="Next" style="border-color:#660000" border="2"/>-->
          <img border="0" src="/pix/mroonpnx.gif" alt="Next"/>
        </a>
      </td>
      <td valign="top" class="whitehead" style="text-align:right;
      font-size:77%; width:37%"><div style="height:12pt; overflow:hidden">
        <xsl:value-of select="@title"/>
      </div></td>
    </tr>
    <tr><td colspan="3">
      <img src="/pix/yellowdot.gif" height="1" >
        <xsl:attribute name="width"><xsl:value-of select="@progress"/></xsl:attribute>
      </img>
    </td></tr>
    </tbody>
  </table>
  <p id="bcbHide">&#160;</p>

<a bcbParam="true" name="prevNav" href="{$myPrev}"/>
<a bcbParam="true" name="nextNav" href="{$myNext}"/>
</xsl:template>


<!-- =============================================== -->
<!-- add the standard CCEL footer (for dynamic docs) -->
<!-- =============================================== -->
<xsl:template name="add-footer">
<table id="bcbHide" align="center" style="clear:right; margin-top:0in">
  <tbody>
  <tr>
    <td>
      <a href="http://www.ccel.org">
        <img src="/pix/gem-icon2.gif" border="0" alt="CCEL home page"/>
      </a>
    </td>
    <td align="center"><span style="font-size:9pt; font-style:italic">
      <xsl:choose>

	<!-- running on CCEL desktop -->
	<xsl:when test="$desktop=1">
          This <a class="TOC" href="http://www.ccel.org/ThML">ThML</a> 
	  document is from the 
	  <a class="TOC" href="http://www.ccel.org">Christian 
	  Classics Ethereal Library</a> at <a class="TOC"
	  href="http://www.calvin.edu">Calvin College</a>.<br/>

          <a class="TOC" href="/index.jsp">Home</a> | 
          <a class="TOC" href="/jsp/prefs.jsp">Preferences</a>
	 <!--<xsl:if test="$cd!=1">-->
           | Search this book: <form style="margin-top:0in"
	    action="/search" method="get">
	    <input type="hidden" name="authorID" value="{$authorID}" />
	    <input type="hidden" name="bookID" value="{$bookID}" />
	    <input type="hidden" name="a" value="search" />
            <input type="text" name="q" size="12"
	    style="font-size:8pt"/> 
	    <input type="submit" value="Go" size="7"/>
	    </form>
	    <!--</xsl:if>-->
        </xsl:when>

	<!-- create HTML files on server -->
        <xsl:otherwise>
          This document is from the <a class="TOC"
	  href="http://www.ccel.org">Christian Classics
          Ethereal Library</a> at <a class="TOC"
	  href="http://www.calvin.edu">Calvin College</a>,<br/>
          generated on demand from
          <a class="TOC" href="http://www.ccel.org/ThML">ThML </a>
          <a class="TOC"
	  href="http://www.ccel.org/ccel/{$authorID}/{$bookID}.xml">source</a>
	  at <script type="text/javascript">document.write(
	  document.lastModified);</script>. <br/>
 	    <xsl:variable name="hitfile" select="concat('/ccel/',$authLet,'/',
	      $authorID, '/', $bookID, '/hits.xml')"/>
	    This book has been accessed more than 
	    <xsl:value-of select="document($hitfile)/stats/hits"/> times 
	    since
	    <xsl:value-of select="document($hitfile)/stats/date"/>.
        </xsl:otherwise>
      </xsl:choose>
      </span></td>

    <td>
      <a class="TOC" href="http://www.calvin.edu">
        <img src="/pix/seal.gif" border="0" alt="Calvin seal: My heart I offer you O Lord, promptly and sincerely"/>
      </a>
    </td>
  </tr>
  </tbody>
  </table>
</xsl:template>


<!-- ========================== -->
<!-- process ThML body elements -->
<!-- ========================== -->

<!-- include included stuff -->
  <xsl:template match="xi:include" mode="includeParsing">
    <xsl:if test="$debug">
      <xsl:message>xi:include: loading <xsl:value-of select="@href"/></xsl:message>
    </xsl:if>

    <xsl:apply-templates select="document(@href,$rootPath)" mode="includeParsing"/>
  </xsl:template>

  <xsl:template match="scripCom" mode="includeParsing">
    <a name="{@id}" />
  </xsl:template>

<!-- just drop the tags -->
  <xsl:template match="scripContext|insertIndex|added" mode="includeParsing">
    <a id="{@id}" />
    <xsl:apply-templates mode="includeParsing"/>
  </xsl:template>

<!-- convert <elt class="xxx"> to <span class="elt"><span class="xxx"> -->
  <xsl:template match="date|foreign|index|name|unclear"
	mode="includeParsing">
    <span class="{local-name()}">
      <xsl:copy-of select="@*[name() != 'class']"/>
      <xsl:choose>
        <xsl:when test="@class != ''">
          <span class="{@class}">
	    <xsl:apply-templates mode="includeParsing"/>
	  </span>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates mode="includeParsing"/>
        </xsl:otherwise>
      </xsl:choose>
    </span>
  </xsl:template>

  <xsl:template match="scripture"
	mode="includeParsing">
    <span class="{local-name()}">
	<xsl:choose>
		<xsl:when test="@*[name() = 'id']">
			<xsl:copy-of select="@*[name() != 'class']"/>
		</xsl:when>
		<xsl:when test="@*[name() = 'osisRef']">
			<xsl:attribute name="id">
				<xsl:variable name="bk1"><xsl:value-of select="substring-after(@*[name() = 'osisRef'],':')"/></xsl:variable>
				<xsl:choose>
					<xsl:when test="starts-with($bk1,'1')"><xsl:value-of select="concat('i',substring-after($bk1,'1'))"/></xsl:when>
					<xsl:when test="starts-with($bk1,'2')"><xsl:value-of select="concat('ii',substring-after($bk1,'2'))"/></xsl:when>
					<xsl:when test="starts-with($bk1,'3')"><xsl:value-of select="concat('iii',substring-after($bk1,'3'))"/></xsl:when>
					<xsl:otherwise><xsl:value-of select="$bk1"/></xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:copy-of select="@*[name() != 'class']"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:message>Warning: no scripture id found (nor equivalent osisRef) - verse won't be highlighted</xsl:message>
			<xsl:copy-of select="@*[name() != 'class']"/>
		</xsl:otherwise>
	</xsl:choose>
      <xsl:choose>
        <xsl:when test="@class != ''">
          <span class="{@class}">
	    <xsl:apply-templates mode="includeParsing"/>
	  </span>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates mode="includeParsing"/>
        </xsl:otherwise>

      </xsl:choose>
    </span>
  </xsl:template>

<!-- convert <elt class="xxx"> to <div class="elt"><p class="xxx"> -->
  <xsl:template match="argument|attr|author|composer|incipit|l|meter|music|tune" mode="includeParsing">
    <xsl:choose>
      <xsl:when test="@class != ''">
        <div class="{local-name()}">
          <p class="{@class}">
	    <xsl:apply-templates mode="includeParsing"/>
	  </p>
        </div>
      </xsl:when>
      <xsl:otherwise>
        <p class="{local-name()}">
          <xsl:apply-templates mode="includeParsing"/>
	</p>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

<!-- hymn: do non-verse stuff, then put <verse>s in a centered td -->
  <xsl:template match="hymn" mode="includeParsing">
    <div class="hymn" id="{@id}">
      <xsl:apply-templates mode="includeParsing" select="*[name()!='verse']"/>
      <div class="Center">
        <table><tbody><tr><td>
        <xsl:apply-templates mode="includeParsing" select="verse"/>
        </td></tr></tbody></table>
      </div>
    </div>
  </xsl:template>

<!-- glossary, term, def -->
  <xsl:template match="glossary" mode="includeParsing">
    <dl>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="includeParsing"/>
    </dl>
  </xsl:template>

  <xsl:template match="term" mode="includeParsing">
    <dt>
	    <xsl:copy-of select="@*"/>
    	<xsl:choose>
    	<xsl:when test="following-sibling::def[@source]">
    		<a href="{following-sibling::def/@target}">
    			<xsl:apply-templates mode="includeParsing"/>
    		</a>
    		<!--<xsl:text>  - from </xsl:text>
    		<a href="{following-sibling::def/@surl}">
				<xsl:value-of select="following-sibling::def/@source"/>
			</a>-->
    	</xsl:when>
    	<xsl:otherwise>
	      <xsl:apply-templates mode="includeParsing"/>
    	</xsl:otherwise>
    	</xsl:choose>
    </dt>
  </xsl:template>

  <xsl:template match="def" mode="includeParsing">
	<xsl:if test="not(@source)">
	    <dd>
	      <xsl:copy-of select="@*"/>
	      <xsl:apply-templates mode="includeParsing"/>
	    </dd>
    </xsl:if>
  </xsl:template>

<!-- sync -->
  <xsl:template match="sync" mode="includeParsing">
    <a>
      <xsl:attribute name="name"><xsl:value-of select="@type"/>_<xsl:value-of select="@value"/></xsl:attribute>
    </a>
  </xsl:template>

<!-- <pb> -->
  <xsl:template match="pb" mode="includeParsing">
    <span>
    	<xsl:attribute name="class">pb</xsl:attribute>
      <xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
	  <xsl:choose>
            <xsl:when test="@href">
	      <a class="page">
                <xsl:attribute name="href">
		<xsl:value-of select="@href"/>
                </xsl:attribute>
	        <xsl:value-of select="@n"/>
	      </a>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="@n"/>
            </xsl:otherwise>
          </xsl:choose>
	</span>
  </xsl:template>


<!-- delete deleted stuff -->
  <xsl:template match="deleted" mode="includeParsing">
  </xsl:template>


<!-- verse: put in a centered table -->
  <xsl:template match="verse" mode="includeParsing">
    <div class="verse2">
      <table><tbody><tr><td>
        <xsl:apply-templates mode="includeParsing"/>
      </td></tr></tbody></table>
    </div>
  </xsl:template>


<!-- scripref: link to /ccel/bible reference -->
  <xsl:template match="scripRef" mode="includeParsing">

    <!-- parse osisRef to get bk, ch -->
    <xsl:variable name="psg"><xsl:value-of
      select="substring-before(concat(
        substring-after(@osisRef,':'),'-'),'-')"/></xsl:variable>
    <xsl:variable name="bk1"><xsl:value-of
      select="substring-before($psg,'.')"/></xsl:variable>
    <xsl:variable name="bk">
      <xsl:choose>
        <xsl:when test="starts-with($bk1,'1')"><xsl:value-of select="concat('i',substring-after($bk1,'1'))"/></xsl:when>
        <xsl:when test="starts-with($bk1,'2')"><xsl:value-of select="concat('ii',substring-after($bk1,'2'))"/></xsl:when>
        <xsl:when test="starts-with($bk1,'3')"><xsl:value-of select="concat('iii',substring-after($bk1,'3'))"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="$bk1"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="ch"><xsl:if 
      test="substring-before(substring-after($psg,'.'),'.') != ''"><xsl:value-of
        select="substring-before(substring-after($psg,'.'),'.')"/></xsl:if><xsl:if
      test="substring-before(substring-after($psg,'.'),'.') = ''"><xsl:value-of
        select="substring-after($psg,'.')"/></xsl:if></xsl:variable>
    <xsl:variable name="v"><xsl:value-of
      select="substring-after($psg,concat($bk1,'.',$ch,'.'))"/></xsl:variable>
    <xsl:variable name="vdot"><xsl:if test="$v != ''">.<xsl:value-of
      select="$v"/></xsl:if></xsl:variable>

	<xsl:variable name="pref">
		<xsl:value-of select="document('bible.xml')/books/grouping[book[osisID[text()=$bk1]]]/@pref"/>
	</xsl:variable>
	<xsl:variable name="bibleID">
    <xsl:choose>
			<xsl:when test="$pref = 'ot_bib'"><xsl:value-of select="$ot_bib"/></xsl:when>
			<xsl:when test="$pref = 'nt_bib'"><xsl:value-of select="$nt_bib"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="$ap_bib"/></xsl:otherwise>
    </xsl:choose>
	</xsl:variable>
    <a><xsl:attribute name="class">scripRef</xsl:attribute>
	<xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
     <!-- if bcb, link to new window -->
     <xsl:attribute name="bcbTarg">true</xsl:attribute>
    <xsl:attribute name="href">/ccel/bible/<xsl:value-of 
       select="$bibleID"/>.<xsl:value-of select="$bk"/>.<xsl:value-of 
       select="$ch"/>.html#<xsl:value-of select="$bk"/>.<xsl:value-of
       select="$ch"/><xsl:value-of select="$vdot"/></xsl:attribute>
    <xsl:attribute name="name"><xsl:value-of select="translate(@parsed,'|','_')"/></xsl:attribute>

<xsl:value-of select="."/>
</a>
  </xsl:template>


<!-- a href: change "#sect-id" urls to "bookID.sect.html#id" if urls='ex' -->
  <xsl:template match="a" mode="includeParsing">
    <a>
      <xsl:copy-of select="@*[name() != 'href']"/>
      <xsl:if test="@href">

	<!-- href with http://domain_name/ part stripped off -->
        <xsl:variable name="temphref">
	  <xsl:choose>
	    <xsl:when test="starts-with(@href,'http:')">/<xsl:value-of 
	    	select="substring-after(substring-after(@href,'.'),'/')"/>
	    </xsl:when>
	    <xsl:otherwise><xsl:value-of select="@href"/></xsl:otherwise>
	  </xsl:choose>
	</xsl:variable>

	<!-- authorID of /ccel hrefs -->
	<xsl:variable name="linkauthorID">
	  <xsl:choose>
	    <xsl:when test="starts-with($temphref,'/ccel/')"><xsl:value-of 
	    	select="substring-before(substring-after($temphref,
			'/ccel/'),'/')"/>
	    </xsl:when>
	    <xsl:when test="starts-with($temphref,'/')"><xsl:value-of 
	    	select="substring-before(substring($temphref,4),'/')"/>
	    </xsl:when>
	  </xsl:choose>
	</xsl:variable>

	<!-- authLet of /ccel hrefs -->
	<xsl:variable name="linkauthLet" select="substring($linkauthorID,1,1)"/>

        <!-- bookID of /ccel href -->
        <xsl:variable name="linkbookID">
          <xsl:choose>
            <xsl:when test="starts-with($temphref,'/ccel/')"><xsl:value-of 
	      	select="substring-before(substring-after(substring-after(
		$temphref,'/ccel/'),'/'),'.')"/></xsl:when>
            <xsl:when test="starts-with($temphref,'/')"><xsl:value-of 
	      	select="substring-before(substring-after(substring($temphref,
		4),'/'),'/')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
	
	<!-- the filename extension of the link -->
	<xsl:variable name="linktype">
	  <xsl:call-template name="getlinktype">
	    <xsl:with-param name="theText" 
	    	select="substring-after($temphref,$linkbookID)"/>
          </xsl:call-template>
	</xsl:variable>

	<xsl:attribute name="href">
          <xsl:choose>

	    <!-- with a non-#id URL, and one big file -->
            <xsl:when test="(substring(@href,1,1)!='#' and substring(@href,1,1)!='?') or $urls='in'">
	      <xsl:value-of select="@href"/>
	    </xsl:when>

        <!-- a #xxx-yyy URI -->
        <xsl:otherwise>
        <xsl:variable name="hrefSect">
        	<xsl:choose>
		        <xsl:when test="contains(@href,'-')">
		        	<xsl:value-of select="substring-after(substring-before(@href,'-'),'#')"/>
			    </xsl:when>
			    <xsl:otherwise>
			    	<xsl:value-of select="substring-after(@href,'#')"/>
			    </xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		 <xsl:variable name="hrefHash">
        	<xsl:choose>
		        <xsl:when test="contains(@href,'-')">
		        	<xsl:value-of select="@href"/>
			    </xsl:when>
			    <xsl:when test="contains(@href,'?')">
		        	<xsl:value-of select="substring-before(@href,'#')"/>
			    </xsl:when>
			    <xsl:otherwise>
			    </xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
      <xsl:value-of select="$bookID"/>.<xsl:value-of
	    select="$hrefSect"/><xsl:text>.html</xsl:text>
	    <xsl:value-of select="$hrefHash"/>
	
	</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates mode="includeParsing"/>
    </a>
  </xsl:template>

  <!-- get extension of link -->
  <xsl:template name="getlinktype">
    <xsl:param name="theText"/>
    <xsl:choose>
      <xsl:when test="contains($theText,'.')">
	<xsl:call-template name="getlinktype">
          <xsl:with-param name="theText" select="substring-after($theText,'.')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="contains($theText,'?')">
	<xsl:call-template name="getlinktype">
          <xsl:with-param name="theText" select="substring-before($theText,'?')"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:when test="contains($theText,'#')">
	<xsl:call-template name="getlinktype">
	  <xsl:with-param name="theText" select="substring-before($theText,'#')"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:otherwise><xsl:value-of select="$theText"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

<!-- pass through most HTML-compatible tags unchanged -->
  <xsl:template match="abbr|acronym|address|area|applet|b|bdo|big|blockquote|br|button|caption|center|cite|code|col|colgroup|dfn|del|dd|div|dl|dt|em|fieldset|font|form|frame|frameset|h1|h2|h3|h4|h5|h6|hr|i|iframe|img|input|ins|kbd|label|legend|li|map|noframes|object|ol|option|optgroup|p|param|pre|q|s|samp|script|select|small|strong|sub|sup|table|tbody|td|textarea|tfoot|th|thead|tr|tt|u|ul|var" mode="includeParsing">
    <xsl:element name="{local-name()}">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="includeParsing"/>
    </xsl:element>
  </xsl:template>


<xsl:template match="span" mode="includeParsing">
  <span>
    <xsl:copy-of select="@*"/>
    <xsl:if test="@lang='HE' and not(@class)">
      <xsl:attribute name="class">Hebrew</xsl:attribute>
    </xsl:if>
    <xsl:if test="@lang='EL' and not(@class)">
      <xsl:attribute name="class">Greek</xsl:attribute>
    </xsl:if>
    <xsl:apply-templates mode="includeParsing"/>
  </span>
</xsl:template>


<!-- process footnotes -->
  <xsl:template match="note" mode="includeParsing">
    <xsl:variable name="fref">fnf_<xsl:value-of select="@id"/></xsl:variable>
    <xsl:variable name="bref">fnb_<xsl:value-of select="@id"/></xsl:variable>
    <xsl:variable name="noteRef"><xsl:choose><xsl:when test="@n"><xsl:value-of select="@n"/></xsl:when><xsl:otherwise><xsl:value-of select="count(preceding::note | ancestor::note | preceding-sibling::note) + 1"/></xsl:otherwise></xsl:choose></xsl:variable>

    <!-- notes processing, footnote mode -->
    <xsl:if test="$myNotes='foot'">
      <a class="Note">
        <xsl:attribute name="name"><xsl:value-of select="$bref"/></xsl:attribute>
        <xsl:attribute name="href">#<xsl:value-of select="$fref"/></xsl:attribute>
        <sup class="Note"><xsl:value-of select="$noteRef"/></sup>
      </a>
    </xsl:if>

    <!-- notes processing, marginal notes mode -->
    <xsl:if test="$myNotes='margin' or $myNotes='hidden'">
      <a class="Note">
        <xsl:attribute name="href">javascript:toggle('<xsl:value-of select="$fref"/>');</xsl:attribute>
        <sup class="Note"><xsl:value-of select="$noteRef"/></sup>
      </a>
      <span class="mnote">
	  <xsl:if test="$myNotes='hidden'"><xsl:attribute name="style">display: none</xsl:attribute></xsl:if>
        <xsl:attribute name="id"><xsl:value-of select="$fref"/></xsl:attribute><xsl:text> </xsl:text>
	<a class="Note">
	  <xsl:attribute name="name">#<xsl:value-of select="$fref"/></xsl:attribute>
	  <sup class="NoteRef">
	    <xsl:value-of select="$noteRef"/>
	  </sup>
	</a>
	<xsl:apply-templates mode="createNotesContent"/>
      </span>

    </xsl:if>

  </xsl:template>

  <xsl:template match="div1|div2|div3|div4|div5" mode="createNotes">
    <!-- do nothing -->
  </xsl:template>

  <xsl:template match="note" mode="createNotes">
    <xsl:variable name="fref">fnf_<xsl:value-of select="@id"/></xsl:variable>
    <xsl:variable name="bref">fnb_<xsl:value-of select="@id"/></xsl:variable>
    <xsl:variable name="noteRef"><xsl:choose><xsl:when test="@n"><xsl:value-of select="@n"/></xsl:when><xsl:otherwise><xsl:value-of select="count(preceding::note | ancestor::note | preceding-sibling::note) + 1"/></xsl:otherwise></xsl:choose></xsl:variable>

    <p class="noteMark">
     <a class="Note">
      <xsl:attribute name="name"><xsl:value-of select="$fref"/></xsl:attribute>
      <xsl:attribute name="href">#<xsl:value-of select="$bref"/></xsl:attribute>
      <sup class="NoteRef"><xsl:value-of select="$noteRef"/></sup>
     </a>
    </p>
    <div class="Note">
      <xsl:attribute name="id"><xsl:value-of select="$fref"/></xsl:attribute>
      <xsl:apply-templates mode="includeParsing"/>
    </div>
  </xsl:template>

<xsl:template match="text()" mode="createNotes">
</xsl:template>

<xsl:template match="text()" mode="includeParsing">
  <xsl:choose>
    <xsl:when test="$words != '1'">
      <xsl:value-of select="."/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="linkWords">
        <xsl:with-param name="theText" select="normalize-space()"/>
        <xsl:with-param name="id">
          <xsl:value-of select="../@id"/><xsl:text>.</xsl:text>
          <xsl:value-of select="position()"/>
        </xsl:with-param>
        <xsl:with-param name="word" select="0"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- linkWords: put <a> around each word, so you can process it with
     javascript, e.g. right-click to look it up in a dictionary -->
<xsl:template name="linkWords">
  <xsl:choose>
    <xsl:when test="$theText=''"></xsl:when>
    <xsl:when test="$theText=' '"><xsl:text> </xsl:text></xsl:when>
    <xsl:when test="substring-before($theText,' ')=''">
      <a id="{$id}.w{$word}"><xsl:value-of select="$theText"/></a><xsl:text>
</xsl:text>
    </xsl:when>
    <xsl:otherwise>
      <a id="{$id}.w{$word}">
        <xsl:value-of select="substring-before($theText,' ')"/>
      </a><xsl:text>
</xsl:text>
      <xsl:call-template name="linkWords">
        <xsl:with-param name="theText" select="substring-after($theText,' ')"/>
        <xsl:with-param name="word" select="$word + 1"/>
        <xsl:with-param name="id" select="$id"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>

</xsl:template>

<!-- look-up table mapping language codes to names -->
  <lang:name code="en">English</lang:name>
  <lang:name code="zh">Chinese</lang:name>
  <lang:name code="cn">Chinese</lang:name>
  <lang:name code="nl">Dutch</lang:name>
  <lang:name code="fr">French</lang:name>
  <lang:name code="fy">Frisian</lang:name>
  <lang:name code="de">German</lang:name>
  <lang:name code="el">Greek</lang:name>
  <lang:name code="he">Hebrew</lang:name>
  <lang:name code="it">Italian</lang:name>
  <lang:name code="la">Latin</lang:name>
  <lang:name code="pt">Portuguese</lang:name>
  <lang:name code="ru">Russian</lang:name>
  <lang:name code="es">Spanish</lang:name>

  <!--This list is used to generate the contents for a dictionary-->
  <letter:alphabet>
	<letter:letter>a</letter:letter>
	<letter:letter>b</letter:letter>
	<letter:letter>c</letter:letter>
	<letter:letter>d</letter:letter>
	<letter:letter>e</letter:letter>
	<letter:letter>f</letter:letter>
	<letter:letter>g</letter:letter>
	<letter:letter>h</letter:letter>
	<letter:letter>i</letter:letter>
	<letter:letter>j</letter:letter>
	<letter:letter>k</letter:letter>
	<letter:letter>l</letter:letter>
	<letter:letter>m</letter:letter>
	<letter:letter>n</letter:letter>
	<letter:letter>o</letter:letter>
	<letter:letter>p</letter:letter>
	<letter:letter>q</letter:letter>
	<letter:letter>r</letter:letter>
	<letter:letter>s</letter:letter>
	<letter:letter>t</letter:letter>
	<letter:letter>u</letter:letter>
	<letter:letter>v</letter:letter>
	<letter:letter>w</letter:letter>
	<letter:letter>x</letter:letter>
	<letter:letter>y</letter:letter>
	<letter:letter>z</letter:letter>
  </letter:alphabet>
  
	<xsl:template name="url-encode">
		<xsl:param name="str"/>
		<xsl:param name="isRec"/>
		<xsl:if test="$str">
			<xsl:variable name = "trans">
				<xsl:value-of select="translate($str,$termTrans,'abcdefghijklmnopqrstuvwxyz+')"/>
			</xsl:variable>
			<xsl:choose>
				<xsl:when test="$desktop=0">
					<xsl:value-of select="str:encode-uri($trans,true())"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="translate($trans,' ','+')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="url-decode">
		<xsl:param name="encoded"/>
		<xsl:if test="$encoded">
			<xsl:choose>
				<xsl:when test="$desktop=0">
					<xsl:value-of select="str:decode-uri($encoded)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$encoded"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
