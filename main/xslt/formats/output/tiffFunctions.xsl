<?xml version="2.0" encoding="UTF-8"?>
<xsl:transform version="1.0"
      xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
      xmlns:xlink="http://www.w3.org/1999/xlink">


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
  
  
  <!--  -->
  <xsl:function name="tiff:setImageWidth" as="xsd:integer*">
    <xsl:param name="width"/>
    <xsl:variable name="tag" select="256"/>
    <xsl:variable name="type" select="$tiff:Type_LONG"/>

    <xsl:sequence select="tiff:generateIFDField($tag, $type, 1, $width)"/>
  </xsl:function>
  
  
  <!--  -->
  <xsl:function name="tiff:setImageLength" as="xsd:integer*">
    <xsl:param name="length"/>
    <xsl:variable name="tag" select="257"/>
    <xsl:variable name="type" select="$tiff:Type_LONG"/>

    <xsl:sequence select="tiff:generateIFDField($tag, $type, 1, $length)"/>
  </xsl:function>
  
  
  <!--  -->
  <xsl:function name="tiff:setBitsPerSample" as="xsd:integer*">
    <xsl:param name="bps"/>

    <xsl:variable name="tag" select="258"/>
    <xsl:variable name="type" select="$tiff:Type_SHORT"/>

    <xsl:sequence select="tiff:generateIFDField($tag, $type, 1, $bps)"/>
  </xsl:function>
  
  
  <!--  -->
  <xsl:function name="tiff:setCompression" as="xsd:integer*">
    <xsl:param name="comp"/>

    <xsl:variable name="tag" select="259"/>
    <xsl:variable name="type" select="$tiff:Type_SHORT"/>

    <xsl:sequence select="tiff:generateIFDField($tag, $type, 1, $comp)"/>
  </xsl:function>
  
  
  <!--  -->
  <xsl:function name="tiff:setPhotometricInterpretation" as="xsd:integer*">
    <xsl:param name="pi"/>

    <xsl:variable name="tag" select="262"/>
    <xsl:variable name="type" select="$tiff:Type_SHORT"/>

    <xsl:sequence select="tiff:generateIFDField($tag, $type, 1, $pi)"/>
  </xsl:function>
  
  
  <!--  -->
  <xsl:function name="tiff:setStripOffsets" as="xsd:integer*">
    <xsl:param name="so"/>

    <xsl:variable name="tag" select="273"/>
    <xsl:variable name="type" select="$tiff:Type_LONG"/>

    <xsl:sequence select="tiff:generateIFDField($tag, $type, 1, $so)"/>
  </xsl:function>
  
  
  <!--  -->
  <xsl:function name="tiff:setSamplesPerPixel" as="xsd:integer*">
    <xsl:param name="spp"/>

    <xsl:variable name="tag" select="277"/>
    <xsl:variable name="type" select="$tiff:Type_SHORT"/>

    <xsl:sequence select="tiff:generateIFDField($tag, $type, 1, $spp)"/>
  </xsl:function>
  
  
  <!--  -->
  <xsl:function name="tiff:setRowsPerStrip" as="xsd:integer*">
    <xsl:param name="rps"/>

    <xsl:variable name="tag" select="278"/>
    <xsl:variable name="type" select="$tiff:Type_LONG"/>

    <xsl:sequence select="tiff:generateIFDField($tag, $type, 1, $rps)"/>
  </xsl:function>
  
  
  <!--  -->
  <xsl:function name="tiff:setStripByteCounts" as="xsd:integer*">
    <xsl:param name="sbc"/>

    <xsl:variable name="tag" select="279"/>
    <xsl:variable name="type" select="$tiff:Type_LONG"/>

    <xsl:sequence select="tiff:generateIFDField($tag, $type, 1, $sbc)"/>
  </xsl:function>
  
  
  <!--  -->
  <xsl:function name="tiff:setXResolution" as="xsd:integer*">
    <xsl:param name="xRes"/>

    <xsl:variable name="tag" select="282"/>
    <xsl:variable name="type" select="$tiff:Type_RATIONAL"/>

    <xsl:variable name="value" select="tiff:integer2Rational($xRes)"/>
    <xsl:sequence select="tiff:generateIFDField($tag, $type, 1, $value)"/>
  </xsl:function>
  
  
  <!--  -->
  <xsl:function name="tiff:setYResolution" as="xsd:integer*">
    <xsl:param name="yRes" as="xsd:integer"/>

    <xsl:variable name="tag" select="283"/>
    <xsl:variable name="type" select="$tiff:Type_RATIONAL"/>

    <xsl:variable name="value" select="tiff:integer2Rational($yRes)"/>
    <xsl:sequence select="tiff:generateIFDField($tag, $type, 1, $value)"/>
  </xsl:function>
  
  
  <!--  -->
  <xsl:function name="tiff:setResolutionUnit" as="xsd:integer*">
    <xsl:param name="resUnit"/>

    <xsl:variable name="units">
      <xsl:choose>
        <xsl:when test="'dpi'">
          <xsl:value-of select="$tiff:ResolutionUnit_Inch"/>
        </xsl:when>
        <xsl:when test="'dpcm'">
          <xsl:value-of select="$tiff:ResolutionUnit_Centimeter"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$tiff:ResolutionUnit_None"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="tag" select="296"/>
    <xsl:variable name="type" select="$tiff:Type_SHORT"/>

    <xsl:sequence select="tiff:generateIFDField($tag, $type, 1, $units)"/>
  </xsl:function>

</xsl:transform>
