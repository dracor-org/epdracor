<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:ep="http://earlyprint.org/ns/1.0"
  xmlns:d="http://dracor.org/ns/1.0"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="ep d tei fn map"
  version="3.0">

  <xsl:output method="xml" encoding="utf-8" omit-xml-declaration="yes" indent="yes"/>

  <xsl:param name="authors" select="document('authors.xml')"/>
  <xsl:param name="index" select="document('index.xml')"/>
  <xsl:param name="spelling">w</xsl:param>
  <xsl:param name="outputdirectory">tei</xsl:param>
  <xsl:param name="speakersjson"/>

  <xsl:variable
    name="tcpid"
    select="replace(tokenize(document-uri(.), '/')[last()], '.xml', '')"/>
  <xsl:variable name="meta" select="$index//item[@sourceid eq $tcpid]"/>

  <!--
    In some documents (e.g. A16527_01.xml) only the main part of the TCP ID
    before the number suffix (_01) is used to prefix the xml:ids while in others
    (e.g. A04632_09.xml) the entire ID is used. Here we try to figure out which
    prefix is used.
  -->
  <xsl:variable name="idprefix">
    <xsl:choose>
      <xsl:when test="count(//@xml:id[starts-with(., $tcpid || '-')]) > 1">
        <xsl:value-of select="$tcpid"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="tokenize($tcpid, '_')[1]"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:function name="d:id-to-name">
    <xsl:param name="id"/>
    <xsl:sequence select="
      fn:string-join(
        tokenize(replace($id, $idprefix || '-', ''), '[-_]')
         ! concat(upper-case(substring(., 1, 1)), substring(., 2)), ' ')"
    />
  </xsl:function>

  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="$meta">
        <xsl:variable
          name="target"
          select="concat($outputdirectory, '/', $meta/@slug, '.xml')"/>
        <xsl:message select="$tcpid || ' (' || $idprefix || '): ' || $target"/>
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
    <TEI xml:id="{$meta/@id}" xml:lang="eng">
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
      </fileDesc>
      <xsl:call-template name="profileDesc"/>
      <xsl:call-template name="revisionDesc"/>
    </teiHeader>
    <standOff>
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
      <xsl:if test="$meta/@wikidata">
        <listRelation>
          <relation name="wikidata">
            <xsl:attribute name="active">
              <xsl:text>https://dracor.org/entity/</xsl:text>
              <xsl:value-of select="$meta/@id"/>
            </xsl:attribute>
            <xsl:attribute name="passive">
              <xsl:text>http://www.wikidata.org/entity/</xsl:text>
              <xsl:value-of select="$meta/@wikidata"/>
            </xsl:attribute>
          </relation>
        </listRelation>
      </xsl:if>
    </standOff>
  </xsl:template>

  <!-- strip facsimile information -->
  <xsl:template match="tei:facsimile|@facs" />

  <!-- strip @xml:id except for div, sp and stage -->
  <xsl:template match="@xml:id"/>
  <xsl:template match="(tei:div|tei:sp|tei:stage|tei:pb)/@xml:id">
    <xsl:attribute name="xml:id" select="replace(., $idprefix, $meta/@id)"/>
  </xsl:template>

  <xsl:template match="tei:sp[@xml:id]">
    <xsl:copy>
      <xsl:choose>
        <xsl:when test="$speakersjson">
          <xsl:variable name="id" select="@xml:id/string()"/>
          <xsl:variable name="speeches" as="map(*)" select="json-doc($speakersjson)?speeches"/>
          <xsl:variable name="who" select="map:get($speeches, $id)"/>
          <xsl:if test="count($who?*) > 0">
            <xsl:attribute name="who" select="$who?* ! concat('#', $meta/@id, '-', .)"/>
          </xsl:if>
          <xsl:apply-templates select="@*[local-name() != 'who']" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="@*" />
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates />
    </xsl:copy>
  </xsl:template>

  <!-- fix @who references -->
  <xsl:template match="tei:sp/@who">
    <xsl:attribute
      name="who"
      select="tokenize(., ' ') ! concat('#', replace(., $idprefix, $meta/@id))"
    />
  </xsl:template>

  <!-- strip machine generated castlist -->
  <xsl:template match="tei:div[@type='machine-generated_castlist']" />

  <!-- strip textual notes -->
  <xsl:template match="tei:div[@type='textual_notes']" />

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
    <profileDesc>
      <xsl:call-template name="particDesc"/>
      <xsl:call-template name="textClass"/>
    </profileDesc>
  </xsl:template>

  <xsl:template name="textClass">
    <xsl:variable name="subgenre" select="//tei:xenoData/ep:epHeader/ep:subgenre"/>
    <xsl:if test="$subgenre = ('comedy', 'tragedy', 'tragicomedy')">
      <textClass>
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
      </textClass>
    </xsl:if>
  </xsl:template>

  <xsl:template name="particDesc">
    <xsl:choose>
      <xsl:when test="$speakersjson">
        <xsl:call-template name="particDesc-from-json"/>
      </xsl:when>
      <xsl:when test="//tei:sp/@who">
        <xsl:call-template name="particDesc-from-who"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="particDesc-from-who">
    <particDesc>
      <listPerson>
        <xsl:for-each select="distinct-values(//tei:sp/@who/tokenize(., ' '))">
          <person xml:id="{replace(., $idprefix, $meta/@id)}">
            <persName>
              <xsl:value-of select="d:id-to-name(.)"/>
            </persName>
          </person>
        </xsl:for-each>
      </listPerson>
    </particDesc>
  </xsl:template>

  <xsl:template name="particDesc-from-json">
    <xsl:variable name="speakers" select="fn:json-doc($speakersjson)"/>
    <particDesc>
      <listPerson>
        <xsl:for-each select="$speakers?particDesc?*">
          <xsl:choose>
            <xsl:when test="?isGroup">
              <personGrp xml:id="{concat($meta/@id, '-', ?id)}">
                <xsl:if test="?sex">
                  <xsl:attribute name="sex" select="?sex"/>
                </xsl:if>
                <name>
                  <xsl:value-of select="?name"/>
                </name>
              </personGrp>
            </xsl:when>
            <xsl:otherwise>
              <person xml:id="{concat($meta/@id, '-', ?id)}">
                <xsl:if test="?sex">
                  <xsl:attribute name="sex" select="?sex"/>
                </xsl:if>
                <persName>
                  <xsl:value-of select="?name"/>
                </persName>
              </person>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </listPerson>
    </particDesc>
  </xsl:template>

  <xsl:template name="revisionDesc">
    <xsl:if test="$speakersjson">
      <xsl:variable name="speakers" select="fn:json-doc($speakersjson)"/>
      <xsl:if test="count($speakers?changes?*) > 0">
        <revisionDesc>
          <listChange>
            <xsl:for-each select="$speakers?changes?*">
              <change when="{?when}">
                <xsl:value-of select="?text"/>
              </change>
            </xsl:for-each>
          </listChange>
        </revisionDesc>
      </xsl:if>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
