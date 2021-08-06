<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="2.0"
    xmlns:fn="http://www.w3.org/2005/02/xpath-functions"
    xmlns:math="http://exslt.org/math"
    xmlns:pxf="project.x.functions"
    xmlns:saxon="http://saxon.sf.net/"
    xmlns:svg="http://www.w3.org/2000/svg"
    xmlns:tiff="graphics.2d.tiff6"
    xmlns:xdt="http://www.w3.org/2005/xpath-datatypes"
    xmlns:xr="project.x-reyes"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    extension-element-prefixes="math saxon"
    exclude-result-prefixes="fn pxf svg tiff xdt xr xs">

  <xsl:output method="saxon:hexBinary" media-type="image/tiff"/>
  <!--<xsl:output method="text" indent="no" encoding="UTF-8" media-type="application/base64"/>-->
    
  <xsl:output name="debug" method="xml" indent="yes" encoding="UTF-8" media-type="text/xml"/>
  <xsl:output name="structure" method="xml" indent="yes" encoding="UTF-8" media-type="text/xml"/>

  <xsl:strip-space elements="*"/>

  <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
      xmlns:dc="http://purl.org/dc/elements/1.1/"
      xmlns:dcterms="http:purl.org/dc/terms/">
    <rdf:Description rdf:about="$Source: $">
      <dc:creator>Philip A. R. Fennell</dc:creator>
      <dcterms:hasVersion>$Revision: $</dcterms:hasVersion>
      <dcterms:dateSubmitted>$Date: $</dcterms:dateSubmitted>
      <dc:rights>Copyright 2006 All Rights Reserved.</dc:rights>
      <dc:format>text/xsl</dc:format>
      <dc:description>Reyes pipeline processing templates.</dc:description>
    </rdf:Description>
  </rdf:RDF>
  
  
  
  <!-- Core pipeline processing templates. -->
  <xsl:include href="core-pipeline.xsl"/>
  
  <!-- Input processing templates -->
  <xsl:include href="../formats/input/prev-svg.xsl"/>
  
  <!-- Output format templates. -->
  <xsl:include href="../formats/output/tiff.xsl"/>
  
  <!-- Image stream encoder. -->
  <xsl:include href="../encoders/base64Optimized.xsl"/>
  
  
  <!-- URL pointing to an options file to be used for the context transformation. -->
  <xsl:param name="localOptions" select="''"/>
  
  
  
  <!-- The file defining the steps in the processing pipeline. -->
  <xsl:variable name="pipeline" as="document-node()" select="document('../../resources/pipelines/svg-reyes.xml')"/>
  
  
  <!-- Pipeline processing options, independent of the model being transformed. -->
  <xsl:function name="xr:pipelineOptions" as="element()">
    
    <!-- If local options have not been identified then use the 'default' options
        identified in the context pipeline. -->
    <xsl:choose>
      <xsl:when test="$localOptions = ''">
        <xsl:message>Default options: <xsl:value-of select="$pipeline/pipeline/options/@href"/>
        </xsl:message>
        <!--<xsl:sequence select="document($pipeline/pipeline/options/@href)/options"/>-->
        <options pipeline="svg-reyes" mode="normal"><!-- normal | debug -->
          <pipeline/><!--  stop-after="svg:bucket-processor" -->
          <bucket size="16"/>
          <shading rate="1"/>
          <image resolution="72" resUnits="dpi" format="tiff" channels="rgb" bitDepth="8"/>
        </options>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>Local options: <xsl:value-of select="$localOptions"/>
        </xsl:message>
        <xsl:sequence select="document($localOptions)/*:options"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  
  <!-- The model's metadata. -->
  <xsl:variable name="metadata" as="element()">
    <xsl:apply-templates select="/" mode="svg:metadata">
      <xsl:with-param name="options" select="xr:pipelineOptions()" tunnel="yes" as="element()"/>
    </xsl:apply-templates>
  </xsl:variable>
  
  
  <!-- The rendered colour values triplet sequence. -->
  <xsl:variable name="image" as="xs:integer*">
    <xsl:variable name="imageStream" as="xs:string*">
      <xsl:apply-templates select="$pipeline" mode="pipeline">
        <xsl:with-param name="model" select="/"/>
        <xsl:with-param name="options" select="xr:pipelineOptions()" tunnel="yes" as="element()"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:sequence select="for $i in tokenize($imageStream, ' ') return xs:integer($i)"/>
  </xsl:variable>
    
  
  <!-- Catch-all to be used when you are not specifying an initial mode. -->
  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="xr:pipelineOptions()/@mode eq 'debug'">
        <xsl:apply-templates mode="debug"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="/" mode="tiff"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  
  <!--  -->
  <xsl:template match="/" mode="debug">
    <xsl:result-document href="output/reyes-debug.xml" format="debug">
      <debug date="{current-dateTime()}">
        <xsl:apply-templates select="$pipeline" mode="pipeline">
          <xsl:with-param name="model" select="/"/>
          <xsl:with-param name="options" select="xr:pipelineOptions()" tunnel="yes" as="element()"/>
        </xsl:apply-templates>
      </debug>
    </xsl:result-document>
    <xsl:text>Pipeline is running in debug mode. See 'output/reyes-debug.xml' for results.</xsl:text>
  </xsl:template>
  
  
  <!--  -->
  <xsl:template match="/" mode="tiff">
    <xsl:variable name="formatedImageStream" as="xs:integer*">
      <xsl:sequence select="tiff:render()"/>
    </xsl:variable>
    <xsl:message>stream count = <xsl:value-of select="count($formatedImageStream)"/></xsl:message>
    
    <xsl:result-document href="structure.xml" format="structure">
      <xsl:copy-of select="$structure"/>
    </xsl:result-document>
    
    <xsl:sequence select="saxon:octets-to-hexBinary($formatedImageStream)"/>
    <!--<xsl:value-of select="saxon:octets-to-base64Binary($formatedImageStream)"/>-->
    <!-- <xsl:value-of select="pxf:sequence2Base64(tokenize($formatedImageStream, ' '))"/> -->
  </xsl:template>
  
  
  <!-- Read the source model. -->
  <xsl:template match="svg:read" mode="step">
    <xsl:param name="source"/>
    
    <xr:job-bag xmlns:svg="http://www.w3.org/2000/svg" steps="{name()}">
      <xsl:namespace name="svg" select="'http://www.w3.org/2000/svg'"/>
      <xsl:copy-of select="$source/xr:job-bag/xr:*"/>
      <xsl:apply-templates select="$source/svg:svg" mode="svg:read"/>
    </xr:job-bag>
  </xsl:template>
  
  
  <!-- Depth sort primitives, nearest first (reverse document order). -->
  <xsl:template match="svg:depth-sort" mode="step">
    <xsl:param name="options" tunnel="yes" as="element()"/>
    <xsl:param name="source"/>
    
    <xr:job-bag steps="{fn:addStepName($source/xr:job-bag, name())}">
      <xsl:namespace name="svg" select="'http://www.w3.org/2000/svg'"/>
      <xsl:copy-of select="$source/xr:job-bag/xr:*"/>
      <xsl:apply-templates select="$source/xr:job-bag/svg:svg" mode="svg:depth-sort"/>     
    </xr:job-bag>
  </xsl:template>
  
  
  <!-- Bound the primitives in the model. -->
  <xsl:template match="svg:bound" mode="step">
    <xsl:param name="source"/>
    
    <xr:job-bag steps="{fn:addStepName($source/(xr:job-bag, xr:bucket)[1], name())}">
      <xsl:namespace name="svg" select="'http://www.w3.org/2000/svg'"/>
      <xsl:copy-of select="$source/xr:job-bag/xr:*"/>
      <xsl:apply-templates select="$source/xr:job-bag/svg:svg" mode="svg:bound"/>
    </xr:job-bag>
  </xsl:template>
  
  
  <!-- Sort primitives into buckets. -->
  <xsl:template match="svg:bucket-sort" mode="step">
    <xsl:param name="source"/>
    
    <xr:job-bag steps="{fn:addStepName($source/xr:job-bag, name())}">
      <xsl:namespace name="svg" select="'http://www.w3.org/2000/svg'"/>
      <xsl:copy-of select="$source/xr:job-bag/xr:*"/>
      <xsl:apply-templates select="$source/xr:job-bag/svg:svg" mode="svg:bucket-sort"/>
    </xr:job-bag>
  </xsl:template>
  
  
  <!-- Check to see if the primitives are within the screen area, throw away the
      ones that are not. -->
  <xsl:template match="svg:on-screen" mode="step">
    <xsl:param name="source"/>
    
    <xr:job-bag steps="{fn:addStepName($source/xr:job-bag, name())}">
      <xsl:namespace name="svg" select="'http://www.w3.org/2000/svg'"/>
      <xsl:copy-of select="$source/xr:job-bag/xr:*"/>
      <xsl:apply-templates select="$source/xr:job-bag/svg:svg" mode="svg:on-screen"/>
    </xr:job-bag>
  </xsl:template>
  
  
  <!-- Test the size of a primitive to see if it is small enough to be diced
      (turned into a grid). If not, split it, bound it, on-screen it and test 
      for diceability again, and again until it is diceable! -->
  <xsl:template match="svg:diceable" mode="step">
    <xsl:param name="source"/>
    
    <xr:job-bag steps="{fn:addStepName($source/xr:job-bag, name())}">
      <xsl:namespace name="svg" select="'http://www.w3.org/2000/svg'"/>
      <xsl:copy-of select="$source/xr:job-bag/xr:*"/>
      <xsl:apply-templates select="$source/xr:job-bag/svg:svg" mode="svg:diceable"/>
    </xr:job-bag>
  </xsl:template>
  
  
  <!-- Start processing the buckets. -->
  <xsl:template match="svg:bucket-processor" mode="step">
    <xsl:param name="source"/>
    <xsl:param name="options" tunnel="yes" as="element()"/>
    <xsl:variable name="buckets" select="$source/xr:job-bag/xr:bucket-list/element()" as="element()*"/>
    <xsl:variable name="steps" select="element()" as="element()*"/>
    
    <xr:job-bag steps="{fn:addStepName($source/xr:job-bag, name())}">
      <xsl:namespace name="svg" select="'http://www.w3.org/2000/svg'"/>
      <xsl:namespace name="xr" select="'project.x-reyes'"/>
      <xsl:namespace name="dcterms" select="'http:purl.org/dc/terms/'"/>
      <xsl:for-each select="$buckets">
        <xsl:call-template name="processStep">
          <xsl:with-param name="source" select="current()" as="node()"/>
          <xsl:with-param name="steps" select="$steps" as="element()*"/>
        </xsl:call-template>
      </xsl:for-each>
    </xr:job-bag>
  </xsl:template>
  
  
  <!-- Convert the primitive into a grid. -->
  <xsl:template match="svg:dice" mode="step">
    <xsl:param name="source"/>
    
    <xsl:apply-templates select="$source" mode="svg:dice"/>
  </xsl:template>
  
  
  <!-- Apply shading to grid(s) in the context bucket. -->
  <xsl:template match="svg:shade" mode="step">
    <xsl:param name="source"/>
    
    <!-- <xsl:copy-of select="$source"/> -->
    <xr:bucket step="{name()}">
      <xsl:copy-of select="$source/xr:bucket[1]/@* except $source/xr:bucket[1]/@step"/>
      <xsl:apply-templates select="$source/xr:bucket" mode="svg:shade"/>
    </xr:bucket>
  </xsl:template>
  
  
  <!-- Break the context grid into micropolygons. -->
  <xsl:template match="svg:bust" mode="step">
    <xsl:param name="source"/>
    
    <xr:bucket step="{name()}">
      <xsl:copy-of select="$source/xr:bucket[1]/@* except $source/xr:bucket[1]/@step"/>
      <xsl:apply-templates select="$source/xr:bucket" mode="svg:bust"/>
    </xr:bucket>
  </xsl:template>
  
  
  <!-- Obtain the bounding box for each micropolygon in the context bucket. -->
  <xsl:template match="svg:bound-micropolygons" mode="step">
    <xsl:param name="source"/>
    
    <xr:bucket step="{name()}">
      <xsl:copy-of select="$source/xr:bucket[1]/@* except $source/xr:bucket[1]/@step"/>
      <xsl:apply-templates select="$source/xr:bucket" mode="svg:bound"/>
    </xr:bucket>
  </xsl:template>
  
  
  <!-- Sort the micropolygons into their repspective buckets.
       Note: this is in effect culling micropolygons that are outside the 
       context bucket. Not very efficient because you should really put them
       in a list for sorting into future buckets. -->
  <xsl:template match="svg:bucket-sort-micropolygons" mode="step">
    <xsl:param name="source"/>
    
    <xr:bucket step="{name()}">
      <xsl:copy-of select="$source/xr:bucket[1]/@* except $source/xr:bucket[1]/@step"/>
      <xsl:apply-templates select="$source/xr:bucket" mode="svg:bucket-sort-micropolygons"/>
    </xr:bucket>
  </xsl:template>
  
  
  <!-- Sample the micropolygons. -->
  <xsl:template match="svg:sample" mode="step">
    <xsl:param name="source"/>
    
    <xr:bucket step="{name()}">
      <xsl:copy-of select="$source/xr:bucket[1]/@*"/>
      <xsl:apply-templates select="$source" mode="svg:sample"/>
    </xr:bucket>
  </xsl:template>
  
  
  <!--  -->
  <xsl:template match="svg:visibility" mode="step">
    <xsl:param name="source"/>
    
    <xsl:copy-of select="$source"/>
  </xsl:template>
  
  
  <!--  -->
  <xsl:template match="svg:filter" mode="step">
    <xsl:param name="source"/>
    
    <xsl:copy-of select="$source"/>
  </xsl:template>
  
  
  <!--  -->
  <!-- <xsl:template match="svg:format" mode="step">
    <xsl:param name="source"/>
    <xr:job-bag steps="{fn:addStepName($source/xr:job-bag, name())}">
      <xsl:namespace name="svg" select="'http://www.w3.org/2000/svg'"/>
      <xsl:copy-of select="$metadata"/>
      <xsl:copy-of select="$source/xr:job-bag/xr:*"/>
      <xsl:copy-of select="$source/xr:job-bag/svg:svg"/>
    </xr:job-bag>
  </xsl:template> -->
  
  <xsl:template match="svg:format" mode="step">
    <xsl:param name="source"/>
    <xsl:value-of select="string-join($source/xr:job-bag/xr:bucket, ' ')"/>
  </xsl:template>
  

  <xsl:template match="svg:*" mode="step">
    <xsl:param name="source"/>
    <xr:job-bag steps="{fn:addStepName($source/xr:job-bag, name())}">
      <xsl:namespace name="svg" select="'http://www.w3.org/2000/svg'"/>
      <xsl:copy-of select="$source/xr:job-bag/xr:*"/>
      <xsl:copy-of select="$source/xr:job-bag/svg:svg"/>
    </xr:job-bag>
    <xsl:message terminate="yes">Unsupported pipeline step: <xsl:value-of select="name()"/>
    </xsl:message>
  </xsl:template>

</xsl:transform>
