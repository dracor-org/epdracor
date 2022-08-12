<!-- Transform data derived from OpenRefine (play-author-items.xml) into authors.xml -->
<xsl:stylesheet version="1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="tei">

  <xsl:output method="xml" encoding="utf-8" omit-xml-declaration="no" indent="yes"/>

  <xsl:variable name="authors">
    <xsl:apply-templates select="/" mode="aggregate"/>
  </xsl:variable>

  <xsl:template match="/">
    <authors>
      <author>
        <match>Anon.</match>
        <match>Anon. ('Ariadne')</match>
        <match>Anon. ('Ariadne'?)</match>
        <match>Anon. (Behn?)</match>
        <match>Anon. (Settle, Elkanah?)</match>
        <match>Anon. (produced by Duffett, Thomas?)</match>
        <match>Anon. (produced by Horden, Hildebrand)</match>
        <match>Anon. (produced by Powell, George; Verbruggen, John)</match>
        <match>Anon. (produced by Powell, George?)</match>
        <author xmlns="http://www.tei-c.org/ns/1.0">
          <persName>Anon.</persName>
          <idno type="wikidata" xml:base="http://www.wikidata.org/entity/">Q4233718</idno>
        </author>
      </author>
      <xsl:for-each select="$authors/authors/author">
        <xsl:sort select="tei:author/tei:persName/tei:surname"/>
        <xsl:sort select="tei:author/tei:persName/tei:forname"/>
        <xsl:copy-of select="."/>
      </xsl:for-each>
    </authors>
  </xsl:template>

  <xsl:template match="/" mode="aggregate">
    <xsl:variable name="items" select="/items"/>

    <authors>
      <xsl:for-each select="distinct-values(//play[not(starts-with(@slug, 'anon-'))]//persName/normalize-space())">
        <xsl:variable name="name" select="."/>
        <xsl:variable name="plays" select="$items/play[author/persName/normalize-space() eq $name]"/>
        <author>
          <!-- <xsl:copy-of select="$plays[1]/author"/> -->
          <xsl:call-template name="author">
            <xsl:with-param name="author" select="$plays[1]/author"/>
          </xsl:call-template>
          <xsl:for-each select="$plays">
            <xsl:variable name="author" select="./author[persName/normalize-space() eq $name]"/>
            <play position="{$author/@position}">
              <xsl:value-of select="./@id"/>
            </play>
          </xsl:for-each>
        </author>
      </xsl:for-each>
    </authors>
  </xsl:template>

  <xsl:template name="author">
    <xsl:param name="author"/>
    <author xmlns="http://www.tei-c.org/ns/1.0">
      <persName>
        <forename>
          <xsl:value-of select="$author/persName/forename"/>
        </forename>
        <surname>
          <xsl:value-of select="$author/persName/surname"/>
        </surname>
      </persName>
      <xsl:if test="$author/idno/text()">
        <idno type="wikidata" xml:base="http://www.wikidata.org/entity/">
          <xsl:value-of select="tokenize($author/idno, '/')[last()]"/>
        </idno>
      </xsl:if>
    </author>
  </xsl:template>

</xsl:stylesheet>
