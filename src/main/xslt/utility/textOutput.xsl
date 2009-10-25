<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="2.0"
      xmlns:pxf="project.x.functions"
      xmlns:txt="project.x.text"
      xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

   <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
         xmlns:dc="http://purl.org/dc/elements/1.1/"
         xmlns:dcterms="http:purl.org/dc/terms/">
      <rdf:Description rdf:about="$Source: $">
         <dc:creator>Philip A. R. Fennell</dc:creator>
         <dcterms:hasVersion>$Revision: $</dcterms:hasVersion>
         <dcterms:dateSubmitted>$Date: $</dcterms:dateSubmitted>
         <dc:rights>Copyright 2005 All Rights Reserved.</dc:rights>
         <dc:format>text/xsl</dc:format>
         <dc:description>Text output utility functions.</dc:description>
      </rdf:Description>
   </rdf:RDF>
   
   
   <!-- Insert a newline character. 10 = Line Feed (LF). -->
   <xsl:function name="txt:newline">
     <xsl:value-of select="codepoints-to-string(10)"/>
   </xsl:function>
   
   
</xsl:transform>
