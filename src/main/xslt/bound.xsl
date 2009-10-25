<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="2.0"
    xmlns:math="http://exslt.org/math"
    xmlns:pxf="project.x.functions"
    xmlns:tiff="graphics.2d.tiff6"
    xmlns:txt="project.x.text"
    xmlns:svg="http://www.w3.org/2000/svg"
    xmlns:saxon="http://saxon.sf.net/"
    xmlns:xr="project.x-reyes"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    extension-element-prefixes="math saxon"
    exclude-result-prefixes="pxf txt">

  <xsl:output method="xml" indent="yes" encoding="UTF-8" media-type="image/svg+xml"/>
   
  <xsl:strip-space elements="*"/>

  <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
      xmlns:dc="http://purl.org/dc/elements/1.1/"
      xmlns:dcterms="http:purl.org/dc/terms/">
    <rdf:Description rdf:about="$Source: $">
      <dc:creator>Philip A. R. Fennell</dc:creator>
      <dcterms:hasVersion>$Revision: $</dcterms:hasVersion>
      <dcterms:dateSubmitted>$Date: $</dcterms:dateSubmitted>
      <dc:rights>Copyright 2005 All Rights Reserved.</dc:rights>
      <dc:format>text/xsl</dc:format>
      <dc:description>Bound primitives.</dc:description>
    </rdf:Description>
  </rdf:RDF>

  <xsl:include href="formats/input/svg.xsl"/>
  <xsl:include href="utility/textOutput.xsl"/>
   
   
  <!--  -->
  <xsl:variable name="metadata" as="item()*">
    <xsl:apply-templates select="/" mode="metadata"/>
  </xsl:variable>
  
  
  <!--  -->
  <xsl:template match="/" mode="bound">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  
</xsl:transform>
