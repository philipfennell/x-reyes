<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
      xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
      xmlns:pxf="project.x.functions">

   <xsl:output method="text" indent="no" encoding="UTF-8" media-type="text/text"/>

   <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
         xmlns:dc="http://purl.org/dc/elements/1.1/"
         xmlns:dcterms="http:purl.org/dc/terms/">
      <rdf:Description rdf:about="$Source: $">
         <dc:creator>Philip A. R. Fennell</dc:creator>
         <dcterms:hasVersion>$Revision: $</dcterms:hasVersion>
         <dcterms:dateSubmitted>$Date: $</dcterms:dateSubmitted>
         <dc:rights>Copyright 2005 All Rights Reserved.</dc:rights>
         <dc:format>text/xsl</dc:format>
         <dc:description>Converts a sequence of unsigned chars (0-255) to a
            binary sequence.</dc:description>
      </rdf:Description>
   </rdf:RDF>
   
   
   <xsl:template match="/">
      <xsl:apply-templates select="data"/>
   </xsl:template>
   
   
   <!--  -->
   <xsl:template match="data">
      <xsl:variable name="input" select="tokenize(text(), ',')"/>
      <xsl:for-each select="$input">
         <xsl:value-of select="current()"/><xsl:text> = </xsl:text>
         <xsl:value-of select="pxf:uchar2Binary(number(current()))"/>
         <xsl:text>
</xsl:text>
      </xsl:for-each>
   </xsl:template>
   
   
   <!-- Convert a uchar (8 bit unsigned integer) to binary. -->
   <xsl:function name="pxf:uchar2Binary">
      <xsl:param name="uchar"/>
      <xsl:variable name="bitLUT" select="tokenize('128,64,32,16,8,4,2,1', ',')"/>
      <xsl:for-each select="$bitLUT">
         <xsl:value-of select="($uchar idiv number(current())) mod 2"/>
      </xsl:for-each>
   </xsl:function>

</xsl:stylesheet>
