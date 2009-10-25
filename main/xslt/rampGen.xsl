<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="2.0"
      xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
      xmlns:xsd="http://www.w3.org/2001/XMLSchema"
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
         <dc:description>Generates a sequence of unsignedBytes increasing 
            monatomically from 0 to 255.</dc:description>
      </rdf:Description>
   </rdf:RDF>
   
   
   <!--  -->
   <xsl:template match="/">
      <xsl:apply-templates select="data"/>
   </xsl:template>
   
   
   <!--  -->
   <xsl:template match="data">
      <xsl:variable name="sequence" select="for $i in 32 to 255 return $i"/>
      
      <xsl:value-of select="codepoints-to-string($sequence)"/>
   </xsl:template>
   
</xsl:transform>
