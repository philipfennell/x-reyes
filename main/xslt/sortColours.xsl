<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="2.0"
    xmlns:color="project.x.functions.color"
    xmlns:math="http://exslt.org/math"
    xmlns:pxf="project.x.functions"
    xmlns:saxon="http://saxon.sf.net/"
    xmlns:svg="http://www.w3.org/2000/svg"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    extension-element-prefixes="math saxon">

  <xsl:output method="xml" indent="yes" encoding="UTF-8" media-type="text/xml"/>
  <xsl:strip-space elements="colours"/>

  <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
      xmlns:dc="http://purl.org/dc/elements/1.1/"
      xmlns:dcterms="http:purl.org/dc/terms/">
    <rdf:Description rdf:about="$Source: $">
      <dc:creator>Philip A. R. Fennell</dc:creator>
      <dcterms:hasVersion>$Revision: $</dcterms:hasVersion>
      <dcterms:dateSubmitted>$Date: $</dcterms:dateSubmitted>
      <dc:rights>Copyright 2005 All Rights Reserved.</dc:rights>
      <dc:format>text/xsl</dc:format>
      <dc:description></dc:description>
    </rdf:Description>
  </rdf:RDF>
  
  
  
  <xsl:variable name="palette" as="item()*">
    <xsl:apply-templates select="//color" mode="colorDef"/>
  </xsl:variable>
   
   
   <!--  -->
  <xsl:template match="/">
    <svg:svg x="0px" y="0px" width="260px" height="755px" viewBox="0 0 210 755">
      <xsl:apply-templates mode="byName"/>
      <xsl:apply-templates mode="byHue"/>
      <xsl:apply-templates mode="bySaturation"/>
      <xsl:apply-templates mode="byValue"/>
    </svg:svg>
  </xsl:template>
   
   
   <!-- Sort colours by name. -->
  <xsl:template match="colors" mode="byName">
    <svg:g transform="translate(10, 10)">
      <xsl:apply-templates select="$palette">
        <xsl:sort order="ascending" data-type="text" select="@name"/>
      </xsl:apply-templates>
    </svg:g>
  </xsl:template>
   
   
   <!-- Sort colours by their hue. -->
  <xsl:template match="colors" mode="byHue">
    <svg:g transform="translate(70, 10)">
      <xsl:apply-templates select="$palette">
        <xsl:sort order="ascending" data-type="number" select="@hue"/>
      </xsl:apply-templates>
    </svg:g>
  </xsl:template>
   
   
   <!-- Sort colours by their saturation. -->
  <xsl:template match="colors" mode="bySaturation">
    <svg:g transform="translate(130, 10)">
      <xsl:apply-templates select="$palette">
        <xsl:sort order="descending" data-type="number" select="@saturation"/>
      </xsl:apply-templates>
    </svg:g>
  </xsl:template>
   
   
   <!-- Sort colours by their hue. -->
  <xsl:template match="colors" mode="byValue">
    <svg:g transform="translate(190, 10)">
      <xsl:apply-templates select="$palette">
        <xsl:sort order="descending" data-type="number" select="@value"/>
      </xsl:apply-templates>
    </svg:g>
  </xsl:template>
   
   
   <!-- Generate a colour patch with name. -->
  <xsl:template match="color">
    <svg:g transform="translate(0, {(position() - 1) * 5}px)">
      <svg:rect x="0px" y="0px" width="5px" height="5px" color="{@name}" fill="currentColor" stroke="none"/>
      <svg:text x="10px" y="4.5px" font-size="4px">
        <xsl:value-of select="@name"/>
      </svg:text>
    </svg:g>
  </xsl:template>
   
   
   <!-- Transform the color node into one with additional colour metadata. -->
  <xsl:template match="color" mode="colorDef">
    <color>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="hue" select="color:getHSV(@rgb, 'H')"/>
      <xsl:attribute name="saturation" select="color:getHSV(@rgb, 'S')"/>
      <xsl:attribute name="value" select="color:getHSV(@rgb, 'V')"/>
    </color>
  </xsl:template>
   
   
   <!--  -->
  <xsl:function name="color:getHSV" as="xsd:double*">
    <xsl:param name="rgb"/>
    <xsl:param name="component"/>
    
    <xsl:variable name="channels" select="for $channel in tokenize($rgb, ',') return (number($channel) div 255)" as="xsd:double*"/>
    <xsl:variable name="r" select="subsequence($channels, 1, 1)"/>
    <xsl:variable name="g" select="subsequence($channels, 2, 1)"/>
    <xsl:variable name="b" select="subsequence($channels, 3, 1)"/>
    <!-- 
    <xsl:message>r = <xsl:value-of select="$r"/>, g = <xsl:value-of select="$g"/>, b = <xsl:value-of select="$b"/></xsl:message>
     -->
    <xsl:variable name="min" select="min($channels)" as="xsd:double"/>
    <xsl:variable name="max" select="max($channels)" as="xsd:double"/>
    <xsl:variable name="delta" select="$max - $min" as="xsd:double"/>
    
    <xsl:variable name="value" select="$max" as="xsd:double"/>

    <xsl:variable name="saturation" as="xsd:double">
      <xsl:choose>
        <xsl:when test="$max != 0">
          <xsl:value-of select="$delta div $max"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="0"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="tempHue" as="xsd:double">
      <xsl:choose>
        <xsl:when test="$r = $max">
          <xsl:value-of select="(($g - $b) div $delta) * 60"/>
        </xsl:when>
        <xsl:when test="$g = $max">
          <xsl:value-of select="(2 + ($b - $r) div $delta) * 60"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="(4 + ($r - $g) div $delta) * 60"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="hue">
      <xsl:choose>
        <xsl:when test="$tempHue lt 0">
          <xsl:value-of select="$tempHue + 360"/>
        </xsl:when>
        <xsl:when test="$saturation = 0">
          <xsl:value-of select="-1"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$tempHue"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:choose>
      <xsl:when test="$component = 'H'">
        <xsl:value-of select="$hue"/>
      </xsl:when>
      <xsl:when test="$component = 'S'">
        <xsl:value-of select="$saturation"/>
      </xsl:when>
      <xsl:when test="$component = 'V'">
        <xsl:value-of select="$value"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$hue, $saturation, $value"/>
      </xsl:otherwise>
    </xsl:choose>
  
    <!-- <xsl:message><xsl:value-of select="$hue"/>, <xsl:value-of select="$saturation"/>, <xsl:value-of select="$value"/></xsl:message> -->
  </xsl:function>
  
</xsl:transform>
