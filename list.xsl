<!-- stylesheet to generate lists from index.xml -->
<xsl:stylesheet version="1.0"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="text" encoding="UTF-8"/>

  <xsl:param name="type">csv</xsl:param>

  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="$type = 'csv'">
        <xsl:text>DraCor_ID,TCP_ID,ZIP_URL&#10;</xsl:text>
      </xsl:when>
    </xsl:choose>
    <xsl:apply-templates select="//item"/>
  </xsl:template>

  <xsl:template match="item[@id]">
    <xsl:choose>
      <xsl:when test="$type = 'csv'">
        <xsl:value-of select="@id"/>
        <xsl:text>,</xsl:text>
        <xsl:value-of select="@sourceid"/>
        <xsl:text>,</xsl:text>
        <xsl:text>https://texts.earlyprint.org/downloads/</xsl:text>
        <xsl:value-of select="substring(@sourceid, 1, 3)"/>
        <xsl:text>/</xsl:text>
        <xsl:value-of select="@sourceid"/>
        <xsl:text>.xml.zip</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="@*[local-name()=$type]"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>
</xsl:stylesheet>
