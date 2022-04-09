<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:ep="http://earlyprint.org/ns/1.0"
  xmlns:d="http://dracor.org/ns/1.0"
  exclude-result-prefixes="tei ep d"
  version="3.0">

  <xsl:output method="xml" encoding="utf-8" omit-xml-declaration="yes" indent="no"/>

  <xsl:param name="sourcedirectory" required="yes"/>
  <xsl:param name="pattern">.</xsl:param>

  <xsl:function name="d:slugify">
    <xsl:param name="text"/>
    <xsl:param name="delim"/>
    <xsl:variable name="part" select="tokenize($text, $delim)[1]"/>
    <xsl:value-of select="lower-case(
      replace(
        translate(
          translate($part, 'à&amp;ʻ'' ', 'a----'), ',;.:()', ''
        ),
        '--+', '-'
      )
    )"/>
  </xsl:function>

  <xsl:function name="d:slugify-authors">
    <xsl:param name="elems"/>
    <xsl:variable name="authors">
      <xsl:for-each select="$elems">
        <xsl:for-each select="tokenize(normalize-space(.), '; ')">
          <xsl:value-of select="d:slugify(., ', ')"/>
          <xsl:if test="position() != last()">
            <xsl:text>-</xsl:text>
          </xsl:if>
        </xsl:for-each>
        <xsl:if test="position() != last()">
          <xsl:text>-</xsl:text>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:value-of select="$authors"/>
  </xsl:function>

  <xsl:function name="d:get-slug">
    <xsl:param name="id"/>
    <xsl:variable name="source-file">
      <xsl:value-of select="$sourcedirectory"/>
      <xsl:text>/</xsl:text>
      <xsl:if test="true()">
        <xsl:value-of select="substring($id, 1, 3)"/>
        <xsl:text>/</xsl:text>
      </xsl:if>
      <xsl:value-of select="$id"/>
      <xsl:text>.xml</xsl:text>
    </xsl:variable>
    <!-- <xsl:message select="$source-file"/> -->

    <xsl:variable name="doc" select="doc($source-file)"/>

    <xsl:variable name="title" select="d:slugify($doc//ep:title, '(, or|; |: )')"/>
    <xsl:variable name="authors" select="d:slugify-authors($doc//ep:author)"/>
    <xsl:variable name="slug">
      <xsl:value-of select="$authors"/>
      <xsl:if test="$authors">
        <xsl:text>-</xsl:text>
      </xsl:if>
      <xsl:value-of select="$title"/>
    </xsl:variable>

    <xsl:value-of select="$slug"/>
  </xsl:function>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="item[not(@slug) and matches(@sourceid, $pattern)]">
    <item>
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="slug" select="d:get-slug(@sourceid)"/>
    </item>
  </xsl:template>

</xsl:stylesheet>
