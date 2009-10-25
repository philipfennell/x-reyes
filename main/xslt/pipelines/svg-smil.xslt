<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="2.0"
    xmlns:a3="http://ns.adobe.com/AdobeSVGViewerExtensions/3.0/"
    xmlns:fn="http://www.w3.org/2005/02/xpath-functions"
    xmlns:math="http://exslt.org/math"
    xmlns:pxf="project.x.functions"
    xmlns:saxon="http://saxon.sf.net/"
    xmlns:svg="http://www.w3.org/2000/svg"
    xmlns:xdt="http://www.w3.org/2005/xpath-datatypes"
    xmlns:xr="project.x-reyes"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    extension-element-prefixes="math saxon"
    exclude-result-prefixes="fn pxf svg xdt xr xs">

  
  <!-- Input processing templates -->
  <xsl:import href="../formats/input/svg.xsl"/>
  <xsl:include href="../interpreters/smil.xslt"/>
  
  <!-- Core pipeline processing templates. -->
  <xsl:include href="core-pipeline.xslt"/>

  
  <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
      xmlns:dc="http://purl.org/dc/elements/1.1/"
      xmlns:dcterms="http:purl.org/dc/terms/">
    <rdf:Description rdf:about="$Source: $">
      <dc:creator>Philip A. R. Fennell</dc:creator>
      <dcterms:hasVersion>$Revision: $</dcterms:hasVersion>
      <dcterms:dateSubmitted>$Date: $</dcterms:dateSubmitted>
      <dc:rights>Copyright 2006 All Rights Reserved.</dc:rights>
      <dc:format>text/xsl</dc:format>
      <dc:description>SVG - SMIL Animation pipeline processing templates.</dc:description>
    </rdf:Description>
  </rdf:RDF>
  
  
  
  <xsl:output method="xml" indent="yes" encoding="UTF-8" media-type="image/svg+xml"/>
    
  <xsl:output name="debug" method="xml" indent="yes" encoding="UTF-8" media-type="text/xml"/>

  <xsl:strip-space elements="*"/>
  
  
  
  <!-- URL pointing to an options file to be used for the context transformation. -->
  <xsl:param name="localOptions" select="''"/>
  
  
  
  <!-- The file defining the steps in the processing pipeline. -->
  <xsl:variable name="pipeline" select="document('../../pipelines/svg-smil.xml')"/>
  
  <!-- Pipeline processing options, independent of the model being transformed. -->
  <xsl:variable name="options">
    <!-- If local options have not been identified then use the 'default' options
        identified in the context pipeline. -->
    <xsl:choose>
      <xsl:when test="$localOptions = ''">
        <xsl:message>Default options: <xsl:value-of select="$pipeline/pipeline/options/@href"/>
        </xsl:message>
        <xsl:copy-of select="document($pipeline/pipeline/options/@href)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>Local options: <xsl:value-of select="$localOptions"/>
        </xsl:message>
        <xsl:copy-of select="document($localOptions)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <!-- The model's source tree. -->
  <xsl:variable name="model" select="/"/>
  
  <!-- The model's metadata. -->
  <xsl:variable name="metadata" as="element()">
    <xsl:apply-templates select="$model" mode="svg:metadata"/>
  </xsl:variable>
  
  
  
  <!--  -->
  <xsl:template match="/" mode="debug">
    <xsl:result-document href="output/smil-debug.xml" format="debug">
      <debug date="{current-dateTime()}">
        <xsl:apply-templates select="$pipeline" mode="pipeline"/>
      </debug>
    </xsl:result-document>
    <xsl:text>Pipeline is running in debug mode. See 'output/smil-debug.xml' for results.</xsl:text>
  </xsl:template>
  
  
  <!--  -->
  <xsl:template match="/" mode="smil">
    <xsl:apply-templates select="$pipeline" mode="pipeline"/>
  </xsl:template>
  
  
  <!-- Read the source model. -->
  <xsl:template match="svg:read" mode="step">
    <xsl:param name="source"/>
    <xr:job-bag xmlns:svg="http://www.w3.org/2000/svg" steps="{name()}">
      <xsl:namespace name="svg" select="'http://www.w3.org/2000/svg'"/>
      <xsl:sequence select="$source/xr:job-bag/xr:*"/>
      <xsl:apply-templates select="$source/svg:svg" mode="svg:read"/>
    </xr:job-bag>
  </xsl:template>
  
  
  <!-- Place animated primitives into individual layers. -->
  <xsl:template match="svg:layer" mode="step">
    <xsl:param name="source"/>
    <xr:job-bag xmlns:svg="http://www.w3.org/2000/svg" steps="{name()}">
      <xsl:namespace name="svg" select="'http://www.w3.org/2000/svg'"/>
      <xsl:sequence select="$source/xr:job-bag/xr:*"/>
      <xsl:apply-templates select="$source/xr:job-bag/svg:svg" mode="svg:layer"/>
    </xr:job-bag>
  </xsl:template>
  
  
  <!-- For each animated primitive create a sequence of primitives spanning
       the range of values between begin and end. -->
  <xsl:template match="svg:animate" mode="step">
    <xsl:param name="source"/>
    <xr:job-bag xmlns:svg="http://www.w3.org/2000/svg" steps="{name()}">
      <xsl:namespace name="svg" select="'http://www.w3.org/2000/svg'"/>
      <xsl:sequence select="$source/xr:job-bag/xr:*"/>
      <xsl:apply-templates select="$source/xr:job-bag/svg:svg" mode="svg:animate"/>
    </xr:job-bag>
  </xsl:template>
  
  
  <!-- Generate a timeline for marshalling playback. -->
  <xsl:template match="svg:timeline" mode="step">
    <xsl:param name="source"/>
    <xr:job-bag xmlns:svg="http://www.w3.org/2000/svg" steps="{name()}">
      <xsl:namespace name="svg" select="'http://www.w3.org/2000/svg'"/>
      <xsl:sequence select="$source/xr:job-bag/xr:*"/>
      <xsl:apply-templates select="$source/xr:job-bag/svg:svg" mode="svg:timeline"/>
    </xr:job-bag>
  </xsl:template>
  
  
  <!-- Wrap the animated model into an application framework. -->
  <xsl:template match="svg:app-wrap" mode="step">
    <xsl:param name="source"/>
    <xr:job-bag xmlns:svg="http://www.w3.org/2000/svg" steps="{name()}">
      <xsl:namespace name="svg" select="'http://www.w3.org/2000/svg'"/>
      <!-- <xsl:sequence select="$source/xr:job-bag/xr:*"/> -->
      <xsl:apply-templates select="$source/xr:job-bag/svg:svg" mode="svg:app-wrap"/>
    </xr:job-bag>
  </xsl:template>
  
  
  <!-- Write the result model(s). -->
  <xsl:template match="svg:write" mode="step">
    <xsl:param name="source"/>
    <xsl:sequence select="$source/xr:job-bag/processing-instruction()"/><xsl:text>
</xsl:text>
    <xsl:sequence select="$source/xr:job-bag/svg:svg"/>
  </xsl:template>
  
  
  <xsl:template match="svg:*" mode="step">
    <xsl:param name="source"/>
    <xr:job-bag steps="{fn:addStepName($source/xr:job-bag, name())}">
      <xsl:namespace name="svg" select="'http://www.w3.org/2000/svg'"/>
      <xsl:sequence select="$source/xr:job-bag/xr:*"/>
      <xsl:sequence select="$source/xr:job-bag/svg:svg"/>
    </xr:job-bag>
    <xsl:message terminate="yes">Unsupported pipeline step: <xsl:value-of select="name()"/>
    </xsl:message>
  </xsl:template>

</xsl:transform>
