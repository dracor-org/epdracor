<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:ep="http://earlyprint.org/ns/1.0"
  xmlns:d="http://dracor.org/ns/1.0"
  xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="ep d tei"
  version="3.0">

  <xsl:output method="xml" encoding="utf-8" omit-xml-declaration="yes" indent="yes"/>

  <xsl:param name="authors" select="document('authors.xml')"/>
  <xsl:param name="index" select="document('index.xml')"/>
  <xsl:param name="spelling">w</xsl:param>
  <xsl:param name="outputdirectory">tei</xsl:param>

  <xsl:variable
    name="tcpid"
    select="replace(tokenize(document-uri(.), '/')[last()], '.xml', '')"/>
  <xsl:variable name="meta" select="$index//item[@sourceid eq $tcpid]"/>

  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="$meta">
        <xsl:variable
          name="target"
          select="concat($outputdirectory, '/', $meta/@slug, '.xml')"/>
        <xsl:message select="$target"/>
        <xsl:result-document href="{$target}">
          <xsl:apply-templates select="tei:TEI"/>
        </xsl:result-document>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>
          <xsl:text>Unknown document ID: </xsl:text>
          <xsl:value-of select="$tcpid"/>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:function name="ep:get-content">
    <xsl:param name="w"/>
    <xsl:choose>
      <xsl:when test="$spelling = 'orig'">
        <xsl:choose>
          <xsl:when test="$w/@orig">
            <xsl:value-of select="$w/@orig"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$w"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="$spelling = 'w'">
        <xsl:value-of select="$w"/>
      </xsl:when>
      <xsl:when test="$spelling = 'reg'">
        <xsl:choose>
          <xsl:when test="$w/@reg">
            <xsl:value-of select="$w/@reg"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$w"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="$spelling = 'lemma'">
        <xsl:choose>
          <xsl:when test="$w/@lemma">
            <xsl:value-of select="$w/@lemma"/>
          </xsl:when>
          <xsl:when test="$w/@reg">
            <xsl:value-of select="$w/@reg"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$w"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
    </xsl:choose>
  </xsl:function>

  <xsl:template match="tei:w">
    <xsl:variable name="content">
      <xsl:value-of select="ep:get-content(.)"/>
    </xsl:variable>
    <xsl:value-of select="$content"/>
    <xsl:if
      test="
        (not(@join) or (@join ne 'right')) and
        (not(following::*[1][name() = 'pc' and not(@join)])) and
        (not(following::*[1][@join = 'left']))">
      <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:pc">
    <xsl:value-of select="text()"/>
    <xsl:if
      test="
        (not(@join) or (@join ne 'right')) and
        (not(following::*[1][name() = 'pc' and not(@join)])) and
        (not(following::*[1][@join = 'left']))">
      <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template
    match="tei:*[tei:w or tei:pc]"
  >
    <xsl:copy>
      <xsl:apply-templates select="@*|*"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:TEI">
    <TEI xml:lang="eng">
      <xsl:apply-templates/>
    </TEI>
  </xsl:template>

  <xsl:template match="tei:teiHeader">
    <teiHeader>
      <fileDesc>
        <titleStmt>
          <!-- FIXME: main/sub? -->
          <xsl:apply-templates select="tei:fileDesc/tei:titleStmt/tei:title"/>
          <xsl:call-template name="authors"/>
        </titleStmt>
        <xsl:call-template name="publicationStmt"/>
        <xsl:call-template name="sourceDesc"/>
        <xsl:call-template name="profileDesc"/>
      </fileDesc>
    </teiHeader>
    <standOff>
      <xsl:if test="$meta/@wikidata">
        <link type="wikidata">
          <xsl:attribute name="target">
            <xsl:text>http://www.wikidata.org/entity/</xsl:text>
            <xsl:value-of select="$meta/@wikidata"/>
          </xsl:attribute>
        </link>
      </xsl:if>
      <xsl:if test="//tei:xenoData/ep:epHeader/ep:creationYear">
        <!--
          FIXME: is ep:creationYear reliably the year of writing and can we use
          //tei:biblFull[@n='printed source']/tei:publicationStmt/tei:date[@type='publication_date']
          as print year?
        -->
        <listEvent>
          <xsl:if test="//tei:xenoData/ep:epHeader/ep:creationYear">
            <event type="written">
              <xsl:attribute name="when" select="//tei:xenoData/ep:epHeader/ep:creationYear"/>
              <desc/>
            </event>
          </xsl:if>
        </listEvent>
      </xsl:if>
    </standOff>
  </xsl:template>

  <!-- strip facsimile information -->
  <xsl:template match="tei:facsimile|@facs" />

  <!-- strip @xml:id except for div, sp and stage -->
  <xsl:template match="@xml:id"/>
  <xsl:template match="(tei:div|tei:sp|tei:stage|tei:pb)/@xml:id">
    <xsl:attribute name="xml:id" select="replace(., $tcpid, $meta/@id)"/>
  </xsl:template>

  <xsl:template name="authors">
    <xsl:variable
      name="author-elems"
      select="$authors//author/play[. eq $tcpid]/parent::*"/>
    <xsl:choose>
      <xsl:when test="$author-elems">
        <xsl:for-each select="$author-elems">
          <xsl:copy select="./tei:author">
            <xsl:apply-templates/>
          </xsl:copy>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each select="//tei:xenoData/ep:epHeader/ep:author">
          <!-- match author name with authors.xml -->
          <xsl:variable name="name" select="ep:name"/>
          <xsl:variable
            name="match"
            select="$authors//author/match[. eq $name]/parent::*"/>
          <xsl:choose>
            <xsl:when test="$match">
              <xsl:copy select="$match/tei:author">
                <xsl:apply-templates/>
              </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
              <author>
                <xsl:comment select="normalize-space(.)"/>
                <xsl:variable
                  name="parts" select="tokenize(normalize-space(.), ', *')"/>
                <persName>
                  <forename>
                    <xsl:value-of select="$parts[2]"/>
                  </forename>
                  <surname>
                    <xsl:value-of select="$parts[1]"/>
                  </surname>
                </persName>
              </author>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="publicationStmt">
    <publicationStmt>
      <publisher xml:id="dracor">DraCor</publisher>
      <idno type="URL">https://dracor.org/</idno>
      <idno type="dracor" xml:base="https://dracor.org/id/">
        <xsl:value-of select="$meta/@id"/>
      </idno>
      <availability>
        <licence>
          <ab>CC0 1.0</ab>
          <ref target="https://creativecommons.org/publicdomain/zero/1.0/">Licence</ref>
        </licence>
      </availability>
      <idno type="wikidata" xml:base="http://www.wikidata.org/entity/"></idno>
    </publicationStmt>
  </xsl:template>

  <xsl:template name="sourceDesc">
    <sourceDesc>
      <bibl type="digitalSource">
        <name>EarlyPrint Project</name>
        <idno type="URL">
          <xsl:text>https://texts.earlyprint.org/works/</xsl:text>
          <xsl:value-of select="$tcpid"/>
          <xsl:text>.xml</xsl:text>
        </idno>
        <!-- FIXME: add source URL (Bitbucket or website?) -->
        <availability>
          <!-- FIXME? -->
          <xsl:apply-templates select="//tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:availability/*"/>
        </availability>
        <bibl type="originalSource">
          <!-- FIXME? -->
          <xsl:apply-templates select="//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblFull"/>
        </bibl>
      </bibl>
    </sourceDesc>
  </xsl:template>

  <xsl:template name="profileDesc">
    <!-- FIXME: generate particDesc -->
    <profileDesc>
      <xsl:call-template name="textClass"/>
    </profileDesc>
  </xsl:template>

  <xsl:template name="textClass">
    <textClass>
      <xsl:variable name="subgenre" select="//tei:xenoData/ep:epHeader/ep:subgenre"/>
      <xsl:if test="$subgenre = ('comedy', 'tragedy', 'tragicomedy')">
        <classCode scheme="http://www.wikidata.org/entity/">
          <xsl:choose>
            <xsl:when test="$subgenre = ('comedy')">
              <xsl:text>Q40831</xsl:text>
            </xsl:when>
            <xsl:when test="$subgenre = ('tragedy')">
              <xsl:text>Q80930</xsl:text>
            </xsl:when>
            <xsl:when test="$subgenre = ('tragicomedy')">
              <xsl:text>Q192881</xsl:text>
            </xsl:when>
          </xsl:choose>
        </classCode>
      </xsl:if>
    </textClass>
  </xsl:template>

</xsl:stylesheet>
