<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="2.0"
      xmlns:math="http://exslt.org/math"
      xmlns:pxf="project.x.functions"
      xmlns:saxon="http://saxon.sf.net/"
      xmlns:xsd="http://www.w3.org/2001/XMLSchema"
      xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
      extension-element-prefixes="math saxon">

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
         <dc:description>Generates a ramp of value triples from 0 to 10.</dc:description>
      </rdf:Description>
   </rdf:RDF>
   
   
   <!--  -->
   <xsl:template match="/">
      <xsl:apply-templates select="data"/>
   </xsl:template>
   
   
   <!--  -->
   <xsl:template match="data">
      <xsl:value-of select="pxf:sequence2Base64(pxf:rampGen(0, 10))"/>
   </xsl:template>
   
   
   <!-- Convert an UTF-8 character string to base64 encoding. -->
   <xsl:function name="pxf:sequence2Base64">
      <xsl:param name="input"/>
      
      <xsl:message>count($input) = <xsl:value-of select="count($input)"/></xsl:message>
      <xsl:message>count($input) idiv 3 = <xsl:value-of select="count($input) idiv 3"/></xsl:message>
      <xsl:message>count($input) mod 3 = <xsl:value-of select="count($input) mod 3"/></xsl:message>
      <xsl:value-of select="$input"/><xsl:text>

</xsl:text>
      <xsl:for-each select="0 to (count($input) idiv 3)">
         <xsl:message><xsl:value-of select="current() * 3"/></xsl:message>
         <xsl:variable name="length" select="3"/>
         <xsl:variable name="triple" select="subsequence($input, (current() * 3) + 1, $length)"/>
         <xsl:value-of select="$triple"/><xsl:text>
</xsl:text>
      </xsl:for-each>
   </xsl:function>
   
   
   <!-- Generate a ramp between 'start' and 'end'. -->
   <xsl:function name="pxf:rampGen">
      <xsl:param name="start"/>
      <xsl:param name="end"/>
      
      <!-- <xsl:variable name="ramp">
         <xsl:for-each select="$start to $end">
            <xsl:value-of select="string-join((current(), current(), current()), ',')"/>
         </xsl:for-each>
      </xsl:variable> -->
      
      <xsl:variable name="ramp" select="for $i in $start to $end return ($i, $i, $i)"/>
      
      <xsl:sequence select="$ramp"/>
   </xsl:function>
   
</xsl:transform>
