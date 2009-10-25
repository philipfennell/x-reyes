<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="2.0"
    xmlns:math="http://exslt.org/math"
    xmlns:pxf="project.x.functions"
    xmlns:tiff="graphics.2d.tiff6"
    xmlns:svg="http://www.w3.org/2000/svg"
    xmlns:saxon="http://saxon.sf.net/"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    extension-element-prefixes="math saxon"
    exclude-result-prefixes="pxf">

  <xsl:output method="text" indent="no" encoding="UTF-8" media-type="application/base64"/>
    
  <xsl:output name="structure" method="xml" indent="yes" encoding="UTF-8" media-type="text/xml"/>
   
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
      <dc:description>Render.</dc:description>
    </rdf:Description>
  </rdf:RDF>

  <xsl:include href="encoders/base64Optimized.xsl"/>
  <xsl:include href="formats/output/tiff.xsl"/>
  <xsl:include href="formats/input/svg.xsl"/>
   
   
   <!--  -->
  <xsl:variable name="metadata" as="item()*">
    <xsl:apply-templates select="/" mode="metadata"/>
  </xsl:variable>
   
   
   <!--  -->
  <xsl:variable name="image" as="xsd:integer*">
    <xsl:apply-templates mode="render"/>
  </xsl:variable>
  
  
  <!--  -->
  <xsl:template match="/">
    <xsl:apply-templates mode="tiff"/>
  </xsl:template>
  
   
   <!--  -->
  <xsl:template match="/" mode="tiff">
    <xsl:variable name="formatedImageStream">
      <xsl:value-of select="tiff:render()"/>
    </xsl:variable>
    <xsl:message>stream count = <xsl:value-of select="count(tokenize($formatedImageStream, ' '))"/></xsl:message>
    
    <xsl:result-document href="structure.xml" format="structure">
      <xsl:copy-of select="$structure"/>
    </xsl:result-document>
    
    <!-- <xsl:value-of select="$formatedImageStream"/> -->
    <xsl:value-of select="pxf:sequence2Base64(tokenize($formatedImageStream, ' '))"/>
  </xsl:template>
   
  
  <!--  -->
  <xsl:template match="/" mode="bound">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  
</xsl:transform>
