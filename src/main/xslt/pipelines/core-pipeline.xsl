<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="2.0"
    xmlns:fn="http://www.w3.org/2005/02/xpath-functions"
    xmlns:math="http://exslt.org/math"
    xmlns:svg="http://www.w3.org/2000/svg"
    xmlns:tiff="graphics.2d.tiff6"
    xmlns:xdt="http://www.w3.org/2005/xpath-datatypes"
    xmlns:xr="project.x-reyes"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    extension-element-prefixes="math"
    exclude-result-prefixes="fn svg tiff xdt xr xs">

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
      <dc:description>Core pipeline processing templates.</dc:description>
    </rdf:Description>
  </rdf:RDF>
  
  
  
  <!-- Starts pipeline processing. -->
  <xsl:template match="pipeline" mode="pipeline">
    <xsl:param name="model" as="document-node()"/>
    
    <xsl:message>Pipeline: <xsl:value-of select="@name"/>
    </xsl:message>
    <xsl:message>Start...</xsl:message>

    <xsl:variable name="steps" select="steps/element()" as="element()*"/>
    
    <xsl:call-template name="processStep">
      <xsl:with-param name="source" select="$model" as="node()"/>
      <xsl:with-param name="steps" select="$steps" as="element()*"/>
    </xsl:call-template>

    <xsl:message>...Finish</xsl:message>
  </xsl:template>
  
  
  <!-- Pipeline step processor. -->
  <xsl:template name="processStep">
    <xsl:param name="source"/>
    <xsl:param name="steps"/>
    <xsl:variable name="contextStep" select="subsequence($steps, 1, 1)"/>
        
    <xsl:choose>
      
      <!-- Stop 'after' the context step, as defined inthe pipeline options file. -->
      <!--<xsl:when test="name($contextStep) = $options/pipeline/@stop-after">
        <xsl:message>Stopping after: <xsl:value-of select="name($contextStep)"/></xsl:message>
        <xsl:variable name="result">
          <xsl:apply-templates select="$contextStep" mode="step">
            <xsl:with-param name="source" select="$source"/>
            <xsl:with-param name="options" select="$options" tunnel="yes" as="element()"/>
          </xsl:apply-templates>
        </xsl:variable>
        <xsl:copy-of select="$result"/>
      </xsl:when>-->
      
      <!-- Stop 'after' the context step, as defined in the context step. -->
      <xsl:when test="$contextStep/@stop = 'after'">
        <xsl:message>Stopping after: <xsl:value-of select="name($contextStep)"/></xsl:message>
        <xsl:variable name="result">
          <xsl:apply-templates select="$contextStep" mode="step">
            <xsl:with-param name="source" select="$source"/>
          </xsl:apply-templates>
        </xsl:variable>
        <xsl:copy-of select="$result"/>
      </xsl:when>
      
      <!-- Skip the context step. -->
      <xsl:when test="$contextStep/@skip = 'yes'">
        <xsl:message>Skipping: <xsl:value-of select="name($contextStep)"/></xsl:message>
        <xsl:call-template name="processStep">
          <xsl:with-param name="source" select="$source" as="node()"/>
          <xsl:with-param name="steps" select="remove($steps, 1)" as="element()*"/>
        </xsl:call-template>
      </xsl:when>
      
      <!-- Exit at end of steps. -->
      <xsl:when test="count($steps) gt 0">
        <xsl:message>Step: <xsl:value-of select="name($contextStep)"/></xsl:message>
        <xsl:variable name="result">
          <xsl:apply-templates select="$contextStep" mode="step">
            <xsl:with-param name="source" select="$source"/>
          </xsl:apply-templates>
        </xsl:variable>
        <xsl:call-template name="processStep">
          <xsl:with-param name="source" select="$result" as="node()"/>
          <xsl:with-param name="steps" select="remove($steps, 1)" as="element()*"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="$source"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  
  <!-- A branch in the pipeline that has it's own 'localised' processing steps. -->
  <!-- Not sure now what use this is! -->
  <xsl:template match="branch" mode="step">
    <xsl:param name="source"/>
    
    <xsl:call-template name="processStep">
      <xsl:with-param name="source" select="$source" as="node()"/>
      <xsl:with-param name="steps" select="element()" as="element()*"/>
    </xsl:call-template>
  </xsl:template>
  
  
  <!-- Add the name of the context step to the list of steps held in the job-bag. -->
  <xsl:function name="fn:addStepName" as="xs:string">
    <xsl:param name="contextStep" as="element()"/>
    <xsl:param name="stepName" as="xs:string"/>
    
    <xsl:value-of select="concat($contextStep/@steps, ' ', $stepName)"/>
  </xsl:function>
  
  
  <!-- [john.lumley@hp.com] 2006-01-05
  <xsl:function name="step:pipe" as="node()*">
    <xsl:param name="source" as="node()*"/>
    <xsl:param name="steps" as="node()*"/>
    
    <xsl:choose>
      <xsl:when test="$steps">
        <xsl:variable name="step" as="node()">
          <xsl:element name="{name($steps[1])}">
            <xsl:sequence select="$source"/>
          </xsl:element>
        </xsl:variable>
        <xsl:variable name="new-source" as="node()*">
          <xsl:apply-templates select="$step" mode="step:step"/>
          <xsl:sequence select="step:pipe($new-source,remove($steps,1)"/>
        </xsl:variable>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$source"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function> -->

</xsl:transform>
