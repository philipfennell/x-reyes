<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="2.0"
    xmlns:math="http://exslt.org/math"
    xmlns:pxf="project.x.functions"
    xmlns:tiff="graphics.2d.tiff6"
    xmlns:txt="project.x.text"
    xmlns:xr="project.x-reyes"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    extension-element-prefixes="math">
    
  <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
      xmlns:dc="http://purl.org/dc/elements/1.1/"
      xmlns:dcterms="http:purl.org/dc/terms/">
    <rdf:Description rdf:about="$Source: $">
      <dc:creator>Philip A. R. Fennell</dc:creator>
      <dcterms:hasVersion>$Revision: $</dcterms:hasVersion>
      <dcterms:dateSubmitted>$Date: $</dcterms:dateSubmitted>
      <dc:rights>Copyright 2005 All Rights Reserved.</dc:rights>
      <dc:format>text/xsl</dc:format>
      <dc:description>Tagged Image File Format (TIFF) output format functions.</dc:description>
    </rdf:Description>
  </rdf:RDF>
  
  
  
  <!-- === Constants. ====================================================== -->
  
  <!-- Header. -->
  <xsl:variable name="tiff:Identifier" select="42"/>
  <xsl:variable name="tiff:ByteOrder_II" select="73"/>
  <xsl:variable name="tiff:ByteOrder_MM" select="77"/>
  <xsl:variable name="tiff:headerCount" select="8"/>
  
  <!-- IFD Field Constants -->
  <xsl:variable name="tiff:ResolutionUnit_None" select="1"/>
  <xsl:variable name="tiff:ResolutionUnit_Inch" select="2"/>
  <xsl:variable name="tiff:ResolutionUnit_Centimeter" select="3"/>
  <xsl:variable name="tiff:Compression_None" select="1"/>
  <xsl:variable name="tiff:Compression_CCITT" select="2"/>
  <xsl:variable name="tiff:Compression_PackBits" select="32773"/>
  <xsl:variable name="tiff:PhotoInterp_WhiteIsZero" select="0"/>
  <xsl:variable name="tiff:PhotoInterp_BlackIsZero" select="1"/>
  <xsl:variable name="tiff:PhotoInterp_RGB" select="2"/>
  <xsl:variable name="tiff:SamplesPerPixel_Bilevel" select="1"/>
  <xsl:variable name="tiff:SamplesPerPixel_Greyscale" select="1"/>
  <xsl:variable name="tiff:SamplesPerPixel_PaletteColor" select="1"/>
  <xsl:variable name="tiff:SamplesPerPixel_RGB" select="3"/>
  <xsl:variable name="tiff:optimumStripByteCount" select="8000"/>
  <xsl:variable name="tiff:PlanarConfig_Contig" select="1"/>
  <xsl:variable name="tiff:PlanarConfig_Planar" select="2"/>
  
  <!-- IFD Data types. -->
  <xsl:variable name="tiff:Type_BYTE" select="1"/>
  <xsl:variable name="tiff:Type_ASCII" select="2"/>
  <xsl:variable name="tiff:Type_SHORT" select="3"/>
  <xsl:variable name="tiff:Type_LONG" select="4"/>
  <xsl:variable name="tiff:Type_RATIONAL" select="5"/>
  
  <!-- TIFF Field tags. -->
  <xsl:variable name="tiff:NewSubfileType" select="254"/>
  <xsl:variable name="tiff:SubfileType" select="255"/>
  <xsl:variable name="tiff:ImageWidth" select="256"/>
  <xsl:variable name="tiff:ImageLength" select="257"/>
  <xsl:variable name="tiff:BitsPerSample" select="258"/>
  <xsl:variable name="tiff:Compression" select="259"/>
  <xsl:variable name="tiff:PhotoInterp" select="262"/>
  <xsl:variable name="tiff:StripOffsets" select="273"/>
  <xsl:variable name="tiff:SamplesPerPixel" select="277"/>
  <xsl:variable name="tiff:RowsPerStrip" select="278"/>
  <xsl:variable name="tiff:StripByteCounts" select="279"/>
  <xsl:variable name="tiff:XResolution" select="282"/>
  <xsl:variable name="tiff:YResolution" select="283"/>
  <xsl:variable name="tiff:PlanarConfig" select="284"/>
  <xsl:variable name="tiff:ResolutionUnit" select="296"/>
  <xsl:variable name="tiff:TileWidth" select="322"/>
  <xsl:variable name="tiff:TileLength" select="323"/>
  <xsl:variable name="tiff:TileOffsets" select="324"/>
  <xsl:variable name="tiff:TileByteCounts" select="325"/>
  
  <!-- === Field entry lengths. ============================================ -->
  <xsl:variable name="bytes-2" select="2"/>
  <xsl:variable name="bytes-4" select="4"/>
  
  
  
  <!-- ===  ================================================================ -->
  
  <!-- Internal structure of the TIFF format. -->
  <xsl:variable name="structure">
    <image>
      <header>
        <byte-order value="{tiff:byteOrder(xs:integer($tiff:ByteOrder_II))}"/>
        <identifier value="{tiff:identifier(xs:integer($tiff:Identifier))}"/>
        <directory-offset value="{tiff:ifdOffset(count($image) + $tiff:headerCount)}"/>
      </header>
      <data/>
      <directory>
        <field tag="{$tiff:ImageWidth}" type="{$tiff:Type_LONG}" count="1" value="{$metadata/spatial/@width}"/>
        <field tag="{$tiff:ImageLength}" type="{$tiff:Type_LONG}" count="1" value="{$metadata/spatial/@height}"/>
        <field tag="{$tiff:BitsPerSample}" type="{$tiff:Type_SHORT}" count="{$tiff:SamplesPerPixel_RGB}" value="{8, 8, 8}"/>
        <field tag="{$tiff:Compression}" type="{$tiff:Type_SHORT}" count="1" value="{$tiff:Compression_None}"/>
        <field tag="{$tiff:PhotoInterp}" type="{$tiff:Type_SHORT}" count="1" value="{$tiff:PhotoInterp_RGB}"/>
        <!-- <field tag="{$tiff:StripOffsets}" type="{$tiff:Type_LONG}" count="{tiff:stripsPerImage()}" value="{tiff:stripOffsets()}"/> -->
        <field tag="{$tiff:SamplesPerPixel}" type="{$tiff:Type_SHORT}" count="1" value="{$tiff:SamplesPerPixel_RGB}"/>
        <!-- <field tag="{$tiff:RowsPerStrip}" type="{$tiff:Type_LONG}" count="1" value="{tiff:rowsPerStrip()}"/> -->
        <!-- <field tag="{$tiff:StripByteCounts}" type="{$tiff:Type_LONG}" count="{tiff:stripsPerImage()}" value="{tiff:stripByteCounts()}"/> -->
        <field tag="{$tiff:XResolution}" type="{$tiff:Type_RATIONAL}" count="1" value="{$metadata/spatial/@res}"/>
        <field tag="{$tiff:YResolution}" type="{$tiff:Type_RATIONAL}" count="1" value="{$metadata/spatial/@res}"/>
        <field tag="{$tiff:PlanarConfig}" type="{$tiff:Type_SHORT}" count="1" value="{$tiff:PlanarConfig_Contig}"/>
        <field tag="{$tiff:ResolutionUnit}" type="{$tiff:Type_SHORT}" count="1" value="{$tiff:ResolutionUnit_Inch}"/>
        <field tag="{$tiff:TileWidth}" type="{$tiff:Type_SHORT}" count="1" value="{$metadata/tile/@size}"/>
        <field tag="{$tiff:TileLength}" type="{$tiff:Type_SHORT}" count="1" value="{$metadata/tile/@size}"/>
        <field tag="{$tiff:TileOffsets}" type="{$tiff:Type_LONG}" count="{tiff:tilesPerImage()}" value="{tiff:tileOffsets()}"/>
        <field tag="{$tiff:TileByteCounts}" type="{$tiff:Type_LONG}" count="{tiff:tilesPerImage()}" value="{tiff:tileByteCounts()}"/>
        <directory-offset/>
      </directory>
      <field-values/>
    </image>
  </xsl:variable>
  
  
  
  <!-- ===  ================================================================ -->
  
  <!--  -->
  <xsl:function name="tiff:render" as="xs:integer*">
    
    <xsl:variable name="header" as="item()*">
      <xsl:apply-templates select="$structure/image/header" mode="header"/>
    </xsl:variable>
    
    <xsl:variable name="ifd" as="item()*">
      <xsl:apply-templates select="$structure/image/directory" mode="IFD">
        <xsl:with-param name="byteCount" select="count($image)" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:variable>
    
    <xsl:variable name="offsetValues" as="item()*">
      <xsl:apply-templates select="$structure/image/directory" mode="OffsetValues">
        <xsl:with-param name="byteCount" select="count($image)" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:variable>
    
    <xsl:message>$header       = '<xsl:value-of select="$header"/>'</xsl:message>
    <xsl:message>$ifdFields    = '<xsl:value-of select="$ifd"/>'</xsl:message>
    <xsl:message>$offsetValues = '<xsl:value-of select="$offsetValues"/>'</xsl:message>
    
    <xsl:message>image byte count = '<xsl:value-of select="count($image)"/>'</xsl:message>
    
    <xsl:sequence select="$header, $image, $ifd, $offsetValues"/>
  </xsl:function>
  
  
  <xsl:template match="image" mode="X">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  
  <xsl:template match="data" mode="X">
    
  </xsl:template>
  
  
  <xsl:template match="field-values" mode="X">
    
  </xsl:template>
  
  
  
  <!-- === Header. ========================================================= -->
  
  <!--  -->
  <xsl:template match="header" mode="header">
    <xsl:variable name="byteOrder" select="pxf:string2Ints(byte-order/@value)"/>
    <xsl:variable name="identifier" select="pxf:string2Ints(identifier/@value)"/>
    <xsl:variable name="directoryOffset" select="pxf:string2Ints(directory-offset/@value)"/>
    
    <xsl:sequence select="$byteOrder, $identifier, $directoryOffset"/>
  </xsl:template>
  
  
  <xsl:function name="pxf:string2Ints" as="xs:integer*">
    <xsl:param name="string" as="xs:string"/>
    <xsl:sequence select="for $i in tokenize($string, ' ') return xs:integer(number($i))"/>
  </xsl:function>
   
   
  <!-- The byte order used within the file. -->
  <xsl:function name="tiff:byteOrder" as="xs:integer*">
    <xsl:param name="byteOrder" as="xs:integer"/>

    <xsl:sequence select="$byteOrder, $byteOrder"/>
  </xsl:function>
   
   
  <!-- An arbitrary but carefully chosen number (42) that further identifies 
    the file as a TIFF file. -->
  <xsl:function name="tiff:identifier" as="xs:integer*">
    <xsl:param name="id" as="xs:integer"/>

    <xsl:sequence select="pxf:integer2octets($id, $bytes-2)"/>
  </xsl:function>
   
   
  <!-- The offset (in bytes) of the first IFD. -->
  <xsl:function name="tiff:ifdOffset" as="xs:integer*">
    <xsl:param name="offset" as="xs:integer"/>
    
    <xsl:sequence select="pxf:integer2octets($offset, $bytes-4)"/>
  </xsl:function>
   
   
   
  <!-- === IFD. ============================================================ -->
  
  <!-- Set the number of fields in the context IFD. -->
  <xsl:function name="tiff:setIFDFieldCount">
    <xsl:param name="count" as="xs:integer"/>
    <xsl:sequence select="pxf:integer2octets($count, 2)"/>
  </xsl:function>
  
  
  <!--  -->
  <xsl:template match="directory" mode="IFD">
    <xsl:param name="byteCount" tunnel="yes" as="xs:integer"/>
    
    <!-- <xsl:message>valuesOffset = <xsl:value-of select="8 + $byteCount + (2 + count(field) + 4)"/></xsl:message> -->
    
    <xsl:variable name="fields" as="item()*">
      <xsl:apply-templates select="field" mode="#current">
        <xsl:with-param name="valuesOffset" select="$tiff:headerCount + $byteCount + (2 + xs:integer(count(field) * 12) + 4)" as="xs:integer"/>
      </xsl:apply-templates>
    </xsl:variable>
    
    <!-- The offset of the next IFD or 0 (0 0 0 0) if none. -->
    <xsl:variable name="nextIFDOffset" select="pxf:integer2octets(0, $bytes-4)" as="xs:integer*"/>
    
    <xsl:sequence select="tiff:setIFDFieldCount(count(field)), $fields, $nextIFDOffset"/>
  </xsl:template>
  
  
  <!-- Inline field values. -->
  <xsl:template match="field[@count = '1']" mode="IFD">
    <xsl:param name="valuesOffset" as="xs:integer"/>
    
    <xsl:sequence select="tiff:generateIFDValueField(current())"/>
  </xsl:template>
  
  
  <!-- Offset field values. -->
  <xsl:template match="field[@type = $tiff:Type_RATIONAL]" mode="IFD" priority="2">
    <xsl:param name="valuesOffset" as="xs:integer"/>    
    <xsl:variable name="values" select="for $i in tokenize(@value, ' ') return xs:integer($i)" as="xs:integer*"/>
    
    <xsl:sequence select="tiff:generateIFDOffsetField($valuesOffset, current(), $values)"/>
  </xsl:template>
  
  
  <!-- Offset field values. -->
  <xsl:template match="field" mode="IFD">
    <xsl:param name="valuesOffset" as="xs:integer"/>    
    <xsl:variable name="values" select="for $i in tokenize(@value, ' ') return xs:integer($i)" as="xs:integer*"/>
    
    <xsl:sequence select="tiff:generateIFDOffsetField($valuesOffset, current(), $values)"/>
  </xsl:template>
  
  
  <!-- For the context field node(), calculate it's offset based on the length
      of it's preceding sibling(s). -->
  <xsl:function name="tiff:getValueOffset" as="xs:integer">
    <xsl:param name="contextField" as="element()"/>    
    <xsl:variable name="precedingFields" select="$contextField/preceding-sibling::field"/>
    
    <xsl:choose>
      <xsl:when test="count($precedingFields) &gt; 0">
        <xsl:value-of select="sum(for $i in $precedingFields return 
            if($i/@type = $tiff:Type_RATIONAL) then 
                xs:integer(pxf:getLengthOfType($i/@type)) * (xs:integer($i/@count) * 2) else 
                    xs:integer(pxf:getLengthOfType($i/@type)) * xs:integer($i/@count))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="0"/>
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:function>
  
  
  <!-- Generate a 12 byte field (with value) for the Image File Directory (IFD). -->
  <xsl:function name="tiff:generateIFDValueField">
    <xsl:param name="contextField" as="element()"/>
    <xsl:variable name="tag" select="$contextField/@tag" as="xs:integer"/>
    <xsl:variable name="type" select="$contextField/@type" as="xs:integer"/>
    <xsl:variable name="length" select="pxf:getLengthOfType($type)" as="xs:integer"/>
    <xsl:variable name="count" select="$contextField/@count" as="xs:integer"/>
    <xsl:variable name="value" select="$contextField/@value"/>
    
    <xsl:message> value: tag = <xsl:value-of select="$tag"/>, type = <xsl:value-of select="$type"/>, count = <xsl:value-of select="$count"/>, length = <xsl:value-of select="$length"/>, value = <xsl:value-of select="$value"/></xsl:message>
    
    <xsl:sequence select="pxf:integer2octets($tag, $bytes-2), pxf:integer2octets($type, $bytes-2), pxf:integer2octets($count, $bytes-4), pxf:integer2octets($value, $bytes-4)"/>
    
  </xsl:function>
  
  
  <!-- Generate a 12 byte field (with offset) for the Image File Directory (IFD). -->
  <xsl:function name="tiff:generateIFDOffsetField">
    <xsl:param name="valuesOffset" as="xs:integer"/>
    <xsl:param name="contextField" as="element()"/>
    <xsl:param name="value" as="item()*"/>    
    <xsl:variable name="tag" select="$contextField/@tag" as="xs:integer"/>
    <xsl:variable name="type" select="$contextField/@type" as="xs:integer"/>
    <xsl:variable name="count" select="$contextField/@count" as="xs:integer"/>
    <xsl:variable name="length" select="pxf:getLengthOfType($type)" as="xs:integer"/>
    <xsl:variable name="valueOffset" select="$valuesOffset + tiff:getValueOffset($contextField)" as="xs:integer"/>
    
    <xsl:message>offset: tag = <xsl:value-of select="$tag"/>, type = <xsl:value-of select="$type"/>, count = <xsl:value-of select="$count"/>, length = <xsl:value-of select="$length"/>, offset = <xsl:value-of select="$valueOffset"/></xsl:message>
    
    <xsl:sequence select="pxf:integer2octets($tag, $bytes-2), pxf:integer2octets($type, $bytes-2), pxf:integer2octets($count, $bytes-4), pxf:integer2octets($valueOffset, $bytes-4)"/>
    
  </xsl:function>
  
  
  
  <!-- === Offset Values. ================================================== -->
  
  <!--  -->
  <xsl:template match="directory" mode="OffsetValues">
    <xsl:param name="byteCount" tunnel="yes" as="xs:integer"/>
    
    <!-- <xsl:message>valuesOffset = <xsl:value-of select="8 + $byteCount + (2 + count(field) + 4)"/></xsl:message> -->
    
    <xsl:variable name="values" as="item()*">
      <xsl:apply-templates select="field" mode="#current"/>
    </xsl:variable>
    
    <xsl:sequence select="$values"/>
  </xsl:template>
  
  
  <!-- Default field processor. -->
  <xsl:template match="field" mode="OffsetValues">    
    <!-- If the number of values in the value array is to be greater than 1,
        tokenize the value string and create a sequence of string values. -->
    <xsl:variable name="value" select="if (number(@count) gt 1) then 
        tokenize(@value, ' ') else xs:integer(@value)"/>
    
    <xsl:sequence select="tiff:generateIFDOffsetValue(@type, @count, $value)"/>
  </xsl:template>
  
  
  <!-- The number of rows per strip. -->
  <xsl:function name="tiff:rowsPerStrip" as="xs:integer">
    <!-- Divide the 'fairly arbitrary, but seems to work well' optimumStripByteCount 
      (8000) by the number of bytes in a row (image width * bytes per pixel) and 
      the round upto the nearest integer. The last strip is not always full and 
      is not padded. Also note that if the number of rows is greater than the 
      image length rows equals the image length. -->
    <xsl:variable name="imageWidth" select="xs:integer($metadata/spatial/@width)"/>
    <xsl:variable name="imageLength" select="xs:integer($metadata/spatial/@height)"/>
    <xsl:variable name="rows" select="xs:integer(ceiling($tiff:optimumStripByteCount div ($imageWidth * $tiff:SamplesPerPixel_RGB)))"/>
    
    <xsl:value-of select="xs:integer(if($rows ge $imageLength) then $imageLength else $rows)"/>
  </xsl:function>
  
  
  <!-- Specifies the number of StripOffsets and StripByteCounts for the image. -->
  <xsl:function name="tiff:stripsPerImage" as="xs:integer">
    <xsl:variable name="imageLength" select="xs:integer($metadata/spatial/@height)"/>
    <xsl:variable name="rowsPerStrip" select="tiff:rowsPerStrip()"/>
    <xsl:value-of select="xs:integer(floor(($imageLength + $rowsPerStrip - 1) div $rowsPerStrip))"/>
  </xsl:function>
  
  
  <!-- For each strip, the number of bytes in the strip after compression. -->
  <xsl:function name="tiff:stripByteCounts" as="xs:integer*">
    <xsl:variable name="imageWidth" select="xs:integer($metadata/spatial/@width)" as="xs:integer"/>
    <xsl:variable name="imageLength" select="xs:integer($metadata/spatial/@height)" as="xs:integer"/>
    <xsl:variable name="rowsPerStrip" select="tiff:rowsPerStrip()" as="xs:integer"/>
    <xsl:variable name="stripsPerImage" select="tiff:stripsPerImage()" as="xs:integer"/>
    <xsl:variable name="remainder" select="$imageLength mod $rowsPerStrip"/>
    <xsl:variable name="wholeStripCounts" select="for $i in 1 to ($stripsPerImage - 1) return xs:integer($rowsPerStrip * ($imageWidth * $tiff:SamplesPerPixel_RGB))"/>
    <xsl:variable name="lastStripCount" select="if ($remainder gt 0) then xs:integer($remainder * ($imageWidth * $tiff:SamplesPerPixel_RGB)) else xs:integer($rowsPerStrip * ($imageWidth * $tiff:SamplesPerPixel_RGB))"/>
    <xsl:variable name="allStripCounts" select="($wholeStripCounts, $lastStripCount)"/>
    
    <xsl:sequence select="$allStripCounts"/>
  </xsl:function>
  
  
  <!-- For each strip, the byte offset of that strip. -->
  <xsl:function name="tiff:stripOffsets" as="xs:integer*">
    <xsl:variable name="startOffset" select="xs:integer(8)"/>
    <!-- Each offset is the sum of the preceding subsequence. -->
    <xsl:sequence select="($startOffset, (for $n in 1 to (count(tiff:stripByteCounts()) - 1) return 
        xs:integer($startOffset + sum(subsequence(tiff:stripByteCounts(), 1, $n)))))"/>
  </xsl:function>
  
  
  <!-- Calculate the number of tiles in an image. -->
  <xsl:function name="tiff:tilesPerImage" as="xs:integer">
    <xsl:variable name="imageWidth" select="xs:integer($metadata/spatial/@width)" as="xs:integer"/>
    <xsl:variable name="imageLength" select="xs:integer($metadata/spatial/@height)" as="xs:integer"/>
    <xsl:variable name="tileWidth" select="xs:integer($metadata/tile/@size)" as="xs:integer"/>
    <xsl:variable name="tileHeight" select="xs:integer($metadata/tile/@size)" as="xs:integer"/>
    <xsl:variable name="tilesAcross" select="xs:integer(floor(($imageWidth + $tileWidth - 1)) div $tileWidth)" as="xs:integer"/>
    <xsl:variable name="tilesDown" select="xs:integer(floor(($imageLength + $tileHeight - 1)) div $tileHeight)" as="xs:integer"/>
    
    <xsl:value-of select="$tilesAcross * $tilesDown"/>
  </xsl:function>
  
  
  <!-- Calculates the number of bytes in an image tile and generates a sequence 
      of this value, one for each tile in the image. -->
  <xsl:function name="tiff:tileByteCounts" as="xs:integer*">
    <xsl:variable name="tileWidth" select="xs:integer($metadata/tile/@size)" as="xs:integer"/>
    <xsl:variable name="tileHeight" select="xs:integer($metadata/tile/@size)" as="xs:integer"/>
    <xsl:variable name="bytesPerPixel" select="xs:integer($tiff:SamplesPerPixel_RGB)" as="xs:integer"/>
    <xsl:variable name="bytesPerTile" select="($tileWidth * $tileHeight) * $bytesPerPixel" as="xs:integer"/>
    
    <xsl:sequence select="for $n in 1 to tiff:tilesPerImage() return $bytesPerTile"/>
  </xsl:function>
  
  
  <!-- Generate a sequence of tile offsets relative to the start of the file. -->
  <xsl:function name="tiff:tileOffsets" as="xs:integer*">
    <xsl:variable name="startOffset" select="xs:integer(8)"/>
    <xsl:sequence select="($startOffset, (for $n in 1 to (tiff:tilesPerImage() - 1) return 
        xs:integer($startOffset + sum(subsequence(tiff:tileByteCounts(), 1, $n)))))"/>
  </xsl:function>
  
  
  <!-- Generate an offset field value for the Image File Directory (IFD). -->
  <xsl:function name="tiff:generateIFDOffsetValue" as="xs:integer*">
    <xsl:param name="type" as="xs:integer"/>
    <xsl:param name="count" as="xs:integer"/>
    <xsl:param name="value"/>    
    <xsl:variable name="length" select="pxf:getLengthOfType($type)" as="xs:integer"/>
    
    <xsl:message>*value: <xsl:value-of select="$type"/>, <xsl:value-of select="$count"/>, <xsl:value-of select="$value"/></xsl:message>
    
    <xsl:choose>
      <xsl:when test="$type = $tiff:Type_RATIONAL">
        <xsl:sequence select="pxf:integer2octets($value, $length)"/>
        <xsl:sequence select="pxf:integer2octets(1, $length)"/>
      </xsl:when>
      <xsl:when test="$value instance of xs:string+">
        <xsl:sequence select="for $v in $value return pxf:integer2octets(xs:integer($v), $length)"/>
      </xsl:when>
      <!-- <xsl:when test="$value instance of xs:integer">
        <xsl:message>xs:integer</xsl:message>
      </xsl:when> -->
      <xsl:otherwise>
        <xsl:sequence select="pxf:integer2octets($value, $length)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  
  <!-- Generate an offset field value for the Image File Directory (IFD). -->
  <xsl:function name="tiff:generateIFDOffsetValue2" as="xs:integer*">
    <xsl:param name="type" as="xs:integer"/>
    <xsl:param name="count" as="xs:integer"/>
    <xsl:param name="value"/>
    
    <!-- <xsl:message>value: <xsl:value-of select="$type"/>, <xsl:value-of select="$count"/>, <xsl:value-of select="$value"/></xsl:message> -->
    
    <xsl:choose>
      <xsl:when test="$type = $tiff:Type_RATIONAL">
        <xsl:sequence select="$value"/>
        <xsl:sequence select="1"/>
      </xsl:when>
      <xsl:when test="$value instance of xs:string+">
        <xsl:sequence select="for $v in $value return xs:integer($v)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$value"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  
  
  <!-- ===================================================================== -->
  
  <!-- Convert an integer number to a rational number. -->
  <xsl:function name="tiff:integer2Rational">
    <xsl:param name="number" as="xs:integer"/>

    <xsl:sequence select="pxf:integer2octets($number, $tiff:Type_LONG), pxf:integer2octets(1, $tiff:Type_LONG)"/>
  </xsl:function>
  
  
  <!-- Return the length (in bytes) of the passed data type. -->
  <xsl:function name="pxf:getLengthOfType">
    <xsl:param name="type" as="xs:integer"/>
    <!-- Type length Look-up Table: BYTE, ASCII, SHORT, LONG, RATIONAL. -->
    <xsl:variable name="typeLengthLUT" select="1, 1, 2, 4, 4" as="xs:integer*"/>
  
    <xsl:value-of select="subsequence($typeLengthLUT, $type, 1)"/>
  </xsl:function>
  
  
  <!-- Convert an integer into a sequence of octets (bytes) of the passed length -->
  <xsl:function name="pxf:integer2octets">
    <xsl:param name="number" as="xs:integer"/>
    <xsl:param name="length" as="xs:integer"/>
    <xsl:variable name="fieldValues" select="256, 65536, 16777216, 4294967296" as="xs:integer*"/>
    
    <xsl:sequence select="for $n in 1 to $length return xs:integer(number(floor((($number div subsequence($fieldValues, $n, 1)) - ($number idiv subsequence($fieldValues, $n, 1))) * 256)))"/>
  </xsl:function>

</xsl:transform>
