<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="2.0"
    xmlns:dcterms="http:purl.org/dc/terms/"
    xmlns:fn="http://www.w3.org/2005/02/xpath-functions"
    xmlns:math="http://exslt.org/math"
    xmlns:pxf="project.x.functions"
    xmlns:svg="http://www.w3.org/2000/svg"
    xmlns:xdt="http://www.w3.org/2005/xpath-datatypes"
    xmlns:xr="project.x-reyes"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    extension-element-prefixes="math"
    exclude-result-prefixes="fn pxf xdt xs">
    
  <xsl:strip-space elements="svg:svg"/>

  <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
      xmlns:dc="http://purl.org/dc/elements/1.1/"
      xmlns:dcterms="http:purl.org/dc/terms/">
    <rdf:Description rdf:about="$Source: $">
      <dc:creator>Philip A. R. Fennell</dc:creator>
      <dcterms:hasVersion>$Revision: $</dcterms:hasVersion>
      <dcterms:dateSubmitted>$Date: $</dcterms:dateSubmitted>
      <dc:rights>Copyright 2005 All Rights Reserved.</dc:rights>
      <dc:format>text/xsl</dc:format>
      <dc:description>Scalable Vector Graphics (SVG) source transforms.</dc:description>
    </rdf:Description>
  </rdf:RDF>
  
  
  <!-- Constants that identify the position of the bbox values (top, right, bottom, left)
    in a sequence created by tokenizing the xr:bbox attribute. -->
  <xsl:variable name="xr:top" select="1" as="xs:integer"/>
  <xsl:variable name="xr:right" select="2" as="xs:integer"/>
  <xsl:variable name="xr:bottom" select="3" as="xs:integer"/>
  <xsl:variable name="xr:left" select="4" as="xs:integer"/>
  
  <!-- Delimiter character used for parameter sequences. -->
  <xsl:variable name="xr:delimiter" select="' '" as="xs:string"/>
  
  <!-- Delimiter characters used to separate points (x,y) in point lists. -->
  <xsl:variable name="svg:pointDelimiter" select="' '" as="xs:string"/>
  <xsl:variable name="svg:coordDelimiter" select="','" as="xs:string"/>
  <xsl:variable name="X" select="1" as="xs:integer"/>
  <xsl:variable name="Y" select="2" as="xs:integer"/>
  
  
  
  <!-- === SVG Metadata =================================================== -->
  
  <!--  -->
  <xsl:template match="svg:svg" mode="svg:metadata">
    <metadata>
      <tile size="{$options/options/bucket/@size}"/>
      <spatial width="{@width}" height="{@height}" res="{$options/options/image/@resolution}" resUnits="{$options/options/image/@resUnits}"/>
      <colour bitDepth="{$options/options/image/@bitDepth}" channels="{$options/options/image/@channels}"/>
      <title>
        <xsl:value-of select="svg:title"/>
      </title>
      <description>
        <xsl:value-of select="svg:description"/>
      </description>
    </metadata>
  </xsl:template>
  
  
  
  <!-- === Read model. ===================================================== -->
  
  <!-- Replicate the root element and any non-graphical content. Then insert all
      graphical primitives (and containers) into a container. -->
  <xsl:template match="svg:svg" mode="svg:read">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:copy-of select="svg:title | svg:description | svg:def | svg:script | svg:style | svg:metadata"/>
      <svg:g id="primitives">
        <xsl:apply-templates select="svg:* except (svg:title, svg:description, svg:def, svg:script, svg:style, svg:metadata)" mode="svg:read-primitives"/>
      </svg:g>
    </xsl:copy>
  </xsl:template>
  
  
  <!-- Read the model's primitives and add an ID attribute, if missing, to each 
      primitive/group node. -->
  <xsl:template match="svg:*" mode="svg:read-primitives">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:if test="not(@id)">
        <xsl:attribute name="id" select="generate-id()"/><!-- For schema aware processors type="xs:ID". -->
      </xsl:if>
      <xsl:apply-templates select="svg:* except (svg:title, svg:description, svg:def, svg:script, svg:style, svg:metadata)" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  
  
  <!-- === Depth sort. ===================================================== -->
  
  <!-- Depth sort primitives (reverse the document order). -->
  <xsl:template match="svg:svg" mode="svg:depth-sort">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="svg:*" mode="svg:depth-sort"/>
    </xsl:copy>
  </xsl:template>
  
  
  <!--  -->
  <xsl:template match="svg:*" mode="svg:depth-sort">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:copy-of select="node() | text()"/>
    </xsl:copy>
  </xsl:template>
  
  
  <!--  -->
  <xsl:template match="svg:g[@id = 'primitives']" mode="svg:depth-sort">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:for-each select="svg:* except (svg:title, svg:description, svg:def, svg:script, svg:style, svg:metadata)">
        <xsl:sort order="descending" select="position()"/>
        <xsl:copy-of select="."/>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>
  
  
  
  <!-- === Bound primitives. ============================================== -->
  
  <!-- SVG Root element. -->
  <xsl:template match="svg:svg" mode="svg:bound">
    <svg:svg>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="current()" mode="svg:bbox"/>
      <xsl:apply-templates mode="#current"/>
    </svg:svg>
  </xsl:template>
   
   
  <!-- SVG elements (but overridden by svg:svg template above). -->
  <xsl:template match="svg:*" mode="svg:bound">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="current()" mode="svg:bbox"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>
   
   
  <!-- SVG elements (but overridden by svg:svg template above). -->
  <xsl:template match="svg:g" mode="svg:bound">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  
  <!-- Bounding box for rectangular elements e.g. svg, rect, img, text. -->
  <xsl:template match="svg:*[@x][@y][@width][@height]" mode="svg:bbox" priority="1">
    <xsl:attribute name="xr:bbox" select="string-join((@y,string(number(@x) + number(@width)),string(number(@y) + number(@height)),@x), $xr:delimiter)"/>
  </xsl:template>
  
  
  <!-- Bounding box for rectangular elements e.g. rect, img, text. -->
  <xsl:template match="svg:*[@width][@height]" mode="svg:bbox">
    <xsl:attribute name="xr:bbox" select="string-join(('0',@width,@height,'0'), $xr:delimiter)"/>
  </xsl:template>
  
  
  <!-- Bounding box for circular elements e.g. circle. -->
  <xsl:template match="svg:*[@cx][@cy][@r]" mode="svg:bbox">
    <xsl:attribute name="xr:bbox" select="string-join((string(number(@cy) - 
      (number(@r) div 2)),string(number(@cx) + (number(@r) div 2)),
          string(number(@cy) + (number(@r) div 2)),string(number(@cx) - 
              (number(@r) div 2))), $xr:delimiter)"/>
  </xsl:template>
  
  
  <!-- Bounding box for polygon elements e.g. polygon and polyline. -->
  <xsl:template match="svg:*[@points]" mode="svg:bbox" priority="1">
    <xsl:variable name="points" select="tokenize(@points, $svg:pointDelimiter)" as="xs:string*"/>
    <xsl:variable name="xCoords" select="for $p in $points return 
        number(subsequence(tokenize($p, $svg:coordDelimiter), $X, 1))" as="xs:double*"/>
    <xsl:variable name="yCoords" select="for $p in $points return 
        number(subsequence(tokenize($p, $svg:coordDelimiter), $Y, 1))" as="xs:double*"/>
    <xsl:attribute name="xr:bbox" select="(min($yCoords), max($xCoords), max($yCoords), min($xCoords))"/>
  </xsl:template>
  
  
  <!-- Suppress text node processing for this mode. -->
  <xsl:template match="text()" mode="svg:bbox"/>
  
  <!-- Ignore these elements. -->
  <xsl:template match="svg:metadata" mode="svg:bound"/>
  
  
  
  <!-- === On screen?. ===================================================== -->
  
  <!-- SVG elements (but overridden by svg:svg template above). -->
  <xsl:template match="svg:*" mode="svg:on-screen">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>
   
   
  <!-- SVG elements (but overridden by svg:svg template above). -->
  <xsl:template match="svg:g[@id = 'primitives']" mode="svg:on-screen">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="svg:off-screen-cull"/>
    </xsl:copy>
  </xsl:template>
  
  
  <!-- If the element has a bounding-box, check to see if the primitive overlaps 
      the image viewBox. Copy it if it does. -->
  <xsl:template match="svg:*[@xr:bbox]" mode="svg:off-screen-cull">
    <xsl:variable name="viewBox" select="ancestor::svg:svg[position() = last()]/@viewBox" as="xs:string"/>
    <xsl:variable name="viewBoxTop" select="number(subsequence(tokenize($viewBox, ' '), 2, 1))" as="xs:double"/>
    <xsl:variable name="viewBoxLeft" select="number(subsequence(tokenize($viewBox, ' '), 1, 1))" as="xs:double"/>
    <xsl:variable name="viewBoxRight" select="number(subsequence(tokenize($viewBox, ' '), 3, 1)) + $viewBoxLeft" as="xs:double"/>
    <xsl:variable name="viewBoxBottom" select="number(subsequence(tokenize($viewBox, ' '), 4, 1)) + $viewBoxTop" as="xs:double"/>
    <xsl:variable name="bbox" select="tokenize(@xr:bbox, $xr:delimiter)" as="xs:string*"/>
    <xsl:variable name="bboxTop" select="number(subsequence($bbox, $xr:top, 1))" as="xs:double"/>
    <xsl:variable name="bboxRight" select="number(subsequence($bbox, $xr:right, 1))" as="xs:double"/>
    <xsl:variable name="bboxBottom" select="number(subsequence($bbox, $xr:bottom, 1))" as="xs:double"/>
    <xsl:variable name="bboxLeft" select="number(subsequence($bbox, $xr:left, 1))" as="xs:double"/>
    <xsl:variable name="horizontalOverlap" select="($viewBoxRight - $bboxLeft) * ($bboxRight - $viewBoxLeft)" as="xs:double"/>
    <xsl:variable name="verticalOverlap" select="($viewBoxTop - $bboxBottom) * ($bboxTop - $viewBoxBottom)" as="xs:double"/>
    
    <xsl:if test="($horizontalOverlap gt 0) and ($verticalOverlap gt 0)">
      <xsl:copy-of select="."/>
    </xsl:if>
  </xsl:template>
  
  
  <!-- Copy all other svg elements. -->
  <xsl:template match="svg:*" mode="svg:off-screen-cull">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="svg:off-screen-cull"/>
    </xsl:copy>
  </xsl:template>
  
  
  
  <!-- === Diceable?. ===================================================== -->
  
  <!-- Replicate SVG root. -->
  <xsl:template match="svg:svg" mode="svg:diceable">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="svg:*" mode="#current"/>
    </xsl:copy>
  </xsl:template>
   
   
  <!-- SVG group containg all primitives to be rendered. -->
  <xsl:template match="svg:g[@id = 'primitives']" mode="svg:diceable">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="child::element()" mode="svg:diceableTest"/>
    </xsl:copy>
  </xsl:template>
  
  
  <!-- SVG elements (but overridden by svg:svg template above). -->
  <xsl:template match="svg:*" priority="1" mode="svg:diceableTest">
    
    <xsl:call-template name="svg:diceable">
      <xsl:with-param name="primitives" select="current()" as="element()*"/>
    </xsl:call-template>
  </xsl:template>
  
  
  <!-- Default template to ensure all other nodes are replicated. -->
  <xsl:template match="svg:*" mode="svg:diceable">
    <xsl:copy-of select="."/>
  </xsl:template>
  
  
  <!-- Applies the diceable? test to each primitive in the 'primitives' sequence. -->
  <xsl:template name="svg:diceable">
    <xsl:param name="primitives" as="element()*"/>
    
    <xsl:variable name="bucketSize" select="number($options/options/bucket/@size)" as="xs:double"/>
    <xsl:variable name="maxGridSize" select="$bucketSize * $bucketSize" as="xs:double"/>
    <xsl:variable name="bbox" select="tokenize($primitives[1]/@xr:bbox, $xr:delimiter)" as="xs:string*"/>
    <xsl:variable name="bboxTop" select="number(subsequence($bbox, $xr:top, 1))" as="xs:double"/>
    <xsl:variable name="bboxRight" select="number(subsequence($bbox, $xr:right, 1))" as="xs:double"/>
    <xsl:variable name="bboxBottom" select="number(subsequence($bbox, $xr:bottom, 1))" as="xs:double"/>
    <xsl:variable name="bboxLeft" select="number(subsequence($bbox, $xr:left, 1))" as="xs:double"/>
    <xsl:variable name="width" select="number($bboxRight) - number($bboxLeft)" as="xs:double"/>
    <xsl:variable name="height" select="number($bboxBottom) - number($bboxTop)" as="xs:double"/>
    <xsl:variable name="area" select="$width * $height" as="xs:double"/>
    
    <!-- <xsl:message>[Debug] area () = <xsl:value-of select="$area"/></xsl:message> -->
    
    <xsl:variable name="result">
      <xsl:choose>
        <!-- If it's marked as not diceable, take no further action. -->
        <xsl:when test="$primitives[1]/svg:metadata/xr:diceable = 'false'">
          <xsl:copy-of select="$primitives"/>
        </xsl:when>
        
        <!-- If the primitive's area is greater than the maximum grid size, split
            it into smaller primitives (of not necessarily the same type!).-->
        <xsl:when test="$area gt $maxGridSize">
          
          <!-- Split primitives that are too large to dice. -->
          <xsl:variable name="splitPrimitives" as="element()*">
            <xsl:apply-templates select="$primitives" mode="svg:split"/>
          </xsl:variable>
          
          <!-- Bound the new 'split' primitives. -->
          <xsl:variable name="splitAndBoundPrimitives" as="element()*">
            <xsl:apply-templates select="$splitPrimitives" mode="svg:bound"/>
          </xsl:variable>
          
          <!-- Recursively call this template to keep splitting the primitives 
              until they are of an acceptable size for dicing. -->
          <xsl:call-template name="svg:diceable">
            <xsl:with-param name="primitives" select="$splitAndBoundPrimitives" as="element()*"/>
          </xsl:call-template>
          
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="$primitives" mode="svg:diceableTrue"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <!-- Return the sequence of, potentially, split primitive(s). -->
    <xsl:copy-of select="$result"/>
  </xsl:template>
  
  
  <!-- When the context primitive is small enough to have been diced, tag it as such. -->
  <xsl:template match="svg:*" mode="svg:diceableTrue">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="xr:diceable" select="'yes'"/>
    </xsl:copy>
  </xsl:template>
  
  
  <!-- Split a rectangle across it's long edge (this should give alternate 
      splits across the longest edge - width then height. -->
  <xsl:template match="svg:rect" mode="svg:split">
    <xsl:choose>
      <xsl:when test="@height gt @width">
        <xsl:call-template name="svg:rectSplitHeight"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="svg:rectSplitWidth"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  
  <!-- Split the rectangle vertically (ensure no overlaps). -->
  <xsl:template name="svg:rectSplitWidth">
    <xsl:variable name="newID" select="generate-id()"/>
    
    <xsl:copy>
      <xsl:copy-of select="@* except (@id, @width, @xr:bbox)"/>
      <xsl:attribute name="id" select="concat($newID, 'A')"/>
      <xsl:attribute name="dcterms:isPartOf" select="@id"/>
      <!-- Round-up width of first half. -->
      <xsl:attribute name="width" select="ceiling(number(@width) div 2)"/>
    </xsl:copy>
    <xsl:copy>
      <xsl:copy-of select="@* except (@id, @x, @width, @xr:bbox)"/>
      <xsl:attribute name="id" select="concat($newID, 'B')"/>
      <xsl:attribute name="dcterms:isPartOf" select="@id"/>
      <!-- Round-up x of second half. -->
      <xsl:attribute name="x" select="number(@x) + ceiling(number(@width) div 2)"/>
      <!-- Round-down width of second half. -->
      <xsl:attribute name="width" select="floor(number(@width) div 2)"/>
    </xsl:copy>
  </xsl:template>
  
  
  <!-- Split the rectangle horizontally (ensure no overlaps). -->
  <xsl:template name="svg:rectSplitHeight">
    <xsl:variable name="newID" select="generate-id()"/>
    
    <xsl:copy>
      <xsl:copy-of select="@* except (@id, @height, @xr:bbox)"/>
      <xsl:attribute name="id" select="concat($newID, 'A')"/>
      <xsl:attribute name="dcterms:isPartOf" select="@id"/>
      <!-- Round-up height of first half. -->
      <xsl:attribute name="height" select="ceiling(number(@height) div 2)"/>
    </xsl:copy>
    <xsl:copy>
      <xsl:copy-of select="@* except (@id, @y, @height, @xr:bbox)"/>
      <xsl:attribute name="id" select="concat($newID, 'B')"/>
      <xsl:attribute name="dcterms:isPartOf" select="@id"/>
      <!-- Round-up y of second half. -->
      <xsl:attribute name="y" select="number(@y) + ceiling((number(@height) div 2))"/>
      <!-- Round-down height of second half. -->
      <xsl:attribute name="height" select="floor(number(@height) div 2)"/>
    </xsl:copy>
  </xsl:template>
  
  
  <!-- Fallback template that marks all unsupported primitives as being not diceable'. -->
  <xsl:template match="svg:*" mode="svg:split">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="xr:diceable" select="'no'"/>
    </xsl:copy>
  </xsl:template>
  
  
  
  <!-- === Bucket sort. ===================================================== -->
  
  <xsl:template match="svg:svg" mode="svg:bucket-sort">
    <xsl:call-template name="xr:buildBucketList"/>
    <xsl:copy-of select="."/>
  </xsl:template>
  
  
  <!-- Create a list of processing buckets. -->
  <xsl:template name="xr:buildBucketList">
    <xsl:variable name="model" select="current()" as="element()"/>
    <xsl:variable name="bucketSize" select="xs:integer($options/options/bucket/@size)" as="xs:integer"/>
    <xsl:variable name="bucket-set">
      <xsl:for-each select="for $i in 1 to svg:bucketCount($model, $bucketSize) return $i">
        <xsl:variable name="top" select="svg:bucketPosition('top', current(), $bucketSize, $model)" as="xs:double"/>
        <xsl:variable name="left" select="svg:bucketPosition('left', current(), $bucketSize, $model)" as="xs:double"/>
        <xr:bucket step="" xr:bbox="{string-join((string($top), string($left + $bucketSize), string($top + $bucketSize), string($left)), $xr:delimiter)}" col="{$left div $bucketSize}" row="{$top div $bucketSize}"/>
      </xsl:for-each>
    </xsl:variable>
    
    <xr:bucket-list bucket-size="{$bucketSize}">
      <xsl:apply-templates select="$bucket-set" mode="svg:bucket-sort">
        <xsl:with-param name="model" select="$model"/>
      </xsl:apply-templates>
    </xr:bucket-list>
  </xsl:template>
  
  
  <!-- Find overlapping primitives. -->
  <xsl:template match="xr:bucket" mode="svg:bucket-sort">
    <xsl:param name="model" as="element()"/>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="overlaps" 
          select="svg:referenceOverlappedPrimitives(current(), $model)"/>
    </xsl:copy>
  </xsl:template>
  
  
  <!-- Calculate the number of buckets required to cover the image's viewBox. -->
  <xsl:function name="svg:bucketCount" as="xs:integer">
    <xsl:param name="modelRoot" as="element()"/>
    <xsl:param name="bucketSize" as="xs:integer"/>
    
    <xsl:variable name="viewBoxParams" select="for $i in tokenize($modelRoot/@viewBox, ' ') return number($i)" as="xs:double*"/>
    <xsl:variable name="viewBoxWidth" select="subsequence($viewBoxParams, 3, 1)" as="xs:double"/>
    <xsl:variable name="viewBoxHeight" select="subsequence($viewBoxParams, 4, 1)" as="xs:double"/>
    
    <xsl:value-of select="ceiling($viewBoxWidth div $bucketSize) * 
        ceiling($viewBoxHeight div $bucketSize)"/>
  </xsl:function>
  
  
  <!-- Returns the top or left edge position of the context bucket. -->
  <xsl:function name="svg:bucketPosition" as="xs:integer">
    <xsl:param name="edge" as="xs:string"/>
    <xsl:param name="position" as="xs:integer"/>
    <xsl:param name="bucketSize" as="xs:integer"/>
    <xsl:param name="modelRoot" as="element()"/>
    
    <xsl:variable name="viewBoxParams" select="for $i in tokenize($modelRoot/@viewBox, ' ') return number($i)" as="xs:double*"/>
    <xsl:variable name="viewBoxWidth" select="subsequence($viewBoxParams, 3, 1)" as="xs:double"/>
    <xsl:variable name="viewBoxHeight" select="subsequence($viewBoxParams, 4, 1)" as="xs:double"/>
    <xsl:variable name="bucketsPerRow" select="ceiling($viewBoxWidth div $bucketSize)"/>
    
    <xsl:if test="$edge = 'left'">
      <xsl:value-of select="(($position - 1) mod $bucketsPerRow) * $bucketSize"/>
    </xsl:if>
    <xsl:if test="$edge = 'top'">
      <xsl:value-of select="(floor(($position - 1) div $bucketsPerRow)) * $bucketSize"/>
    </xsl:if>
  </xsl:function>
  
  
  <!-- Returns a list of IDREFs that identify which primitives the context 
      bucket overlaps. -->
  <xsl:function name="svg:referenceOverlappedPrimitives" as="xs:string">
    <xsl:param name="contextBucket" as="element()"/>
    <xsl:param name="model" as="element()"/>
    
    <xsl:variable name="primitiveRefs">
      <xsl:for-each select="$model//svg:g[@id = 'primitives']/svg:*">
        <xsl:variable name="bucket" select="tokenize($contextBucket/@xr:bbox, $xr:delimiter)" as="xs:string*"/>
        <xsl:variable name="bucketTop" select="number(subsequence($bucket, $xr:top, 1))" as="xs:double"/>
        <xsl:variable name="bucketRight" select="number(subsequence($bucket, $xr:right, 1))" as="xs:double"/>
        <xsl:variable name="bucketBottom" select="number(subsequence($bucket, $xr:bottom, 1))" as="xs:double"/>
        <xsl:variable name="bucketLeft" select="number(subsequence($bucket, $xr:left, 1))" as="xs:double"/>
        <xsl:variable name="bbox" select="tokenize(current()/@xr:bbox, $xr:delimiter)" as="xs:string*"/>
        <xsl:variable name="bboxTop" select="number(subsequence($bbox, $xr:top, 1))" as="xs:double"/>
        <xsl:variable name="bboxRight" select="number(subsequence($bbox, $xr:right, 1))" as="xs:double"/>
        <xsl:variable name="bboxBottom" select="number(subsequence($bbox, $xr:bottom, 1))" as="xs:double"/>
        <xsl:variable name="bboxLeft" select="number(subsequence($bbox, $xr:left, 1))" as="xs:double"/>
        <xsl:variable name="horizontalOverlap" select="($bucketRight - $bboxLeft) * ($bboxRight - $bucketLeft)" as="xs:double"/>
        <xsl:variable name="verticalOverlap" select="($bucketTop - $bboxBottom) * ($bboxTop - $bucketBottom)" as="xs:double"/>
        <xsl:if test="($horizontalOverlap gt 0) and ($verticalOverlap gt 0)">
          <xsl:value-of select="@id"/><xsl:text> </xsl:text>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    
    <xsl:value-of select="normalize-space($primitiveRefs)"/>
  </xsl:function>
  
  
  
  <!-- === Dice primitives. ================================================ -->
  
  <!--  -->
  <xsl:template match="xr:bucket" mode="svg:dice">
    <xsl:variable name="primitives" select="for $i in tokenize(@overlaps, ' ') return //svg:*[@id = $i]" as="element()*"/>
    <!-- <xsl:variable name="diceablePrimitives" select="for $i in $primitives return $i[@xr:diceable = 'yes']" as="element()*"/> -->
    <xsl:variable name="diceablePrimitives" select="$primitives"/>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:for-each select="$primitives">
        <xsl:apply-templates select="current()" mode="svg:grid"/>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>
  
  
  <!-- Only generate grids for 'diceable' primitives. -->
  <xsl:template match="svg:*" mode="svg:grid" priority="2">
    <xsl:if test="@xr:diceable = 'yes'">
      <xsl:next-match/>
    </xsl:if>
  </xsl:template>
  
  
  <!-- Dice a rectangle. -->
  <xsl:template match="svg:rect" mode="svg:grid">
    <xsl:variable name="contextPrimitive" select="current()"/>
    <xr:grid dcterms:replaces="{@id}">
      <xsl:copy-of select="(@dcterms:*, @color, @fill, @opacity, @visibility, @stroke)"/>
      <xsl:for-each select="0 to xs:integer(ceiling(number($contextPrimitive/@height)))">
        <xsl:variable name="y" select="current()"/>
        <xr:row>
          <xsl:for-each select="0 to xs:integer(ceiling(number($contextPrimitive/@width)))">
            <xsl:variable name="x" select="current()"/>
            <xr:vertex x="{number($contextPrimitive/@x) + $x}" y="{$contextPrimitive/number(@y) + $y}"/>
          </xsl:for-each>
        </xr:row>
      </xsl:for-each>
    </xr:grid>
  </xsl:template>
  
  
  <!-- Ignore text nodes. -->
  <xsl:template match="text()" mode="svg:grid"/>
  
  
  
  <!-- === Shade. ========================================================== -->
  
  <!--  -->
  <xsl:template match="xr:grid" mode="svg:shade">
    <xsl:copy-of select="."/>
  </xsl:template>
  
  
  
  <!-- === Bust. =========================================================== -->
  
  <!-- Bust the grid into microploygons. -->
  <xsl:template match="xr:grid" mode="svg:bust">
    <xsl:apply-templates select="xr:row" mode="#current"/>
  </xsl:template>
  
  
  <!--  -->
  <xsl:template match="xr:row" mode="svg:bust">
    <xsl:if test="following-sibling::xr:row">
      <xsl:apply-templates select="xr:vertex[following-sibling::xr:vertex]" mode="#current"/>
    </xsl:if>
  </xsl:template>
  
  
  <!-- Convert a pair of opposite vertices into a micropolygon (svg:rect). -->
  <xsl:template match="xr:vertex" mode="svg:bust">
    <xsl:variable name="resScale" select="1.0" as="xs:double"/>
    <xsl:variable name="gridProperties" select="ancestor::xr:grid[last()]/(@dcterms:isPartOf, @color, @fill, @opacity, @visibility, @stroke)" as="attribute()*"/>
    <xsl:variable name="oppositeVertex" select="svg:getOppositeVertex(current(), position())" as="element()"/>
    <svg:polygon points="{svg:vertices2points(current(), $oppositeVertex, $resScale)}">
      <xsl:copy-of select="$gridProperties"/>
    </svg:polygon>
  </xsl:template>
  
  
  <!-- Busting a grid requires a pair of opposite vertices: top-left, bottom-right. -->
  <xsl:function name="svg:getOppositeVertex" as="element()">
    <xsl:param name="contextVertex" as="element()"/>
    <xsl:param name="contextPosition" as="xs:integer"/>
    <xsl:variable name="nextRow" select="$contextVertex/parent::xr:row/following-sibling::xr:row[1]" as="element()"/>
    <xsl:sequence select="$nextRow/xr:vertex[position() = ($contextPosition + 1)]"/>
  </xsl:function>
  
  
  <!-- Given a pair of opposite vertices and the resolution scaling factor, return
      a sequence of polygon points as a string. -->
  <xsl:function name="svg:vertices2points" as="xs:string">
    <xsl:param name="contextVertex" as="element()"/>
    <xsl:param name="oppositeVertex" as="element()"/>
    <xsl:param name="resScale" as="xs:double"/>
    <xsl:variable name="top" select="number($contextVertex/@y) * $resScale" as="xs:double"/>
    <xsl:variable name="left" select="number($contextVertex/@x) * $resScale" as="xs:double"/>
    <xsl:variable name="bottom" select="number($oppositeVertex/@y) * $resScale" as="xs:double"/>
    <xsl:variable name="right" select="number($oppositeVertex/@x) * $resScale" as="xs:double"/>
    
    <xsl:value-of select="concat($left, ',', $top, ' ', $right, ',', $top, ' ', $right, ',', $bottom, ' ', $left, ',', $bottom)"/>
  </xsl:function>
  
  
  
  <!-- === Bucket Sort Microploygons. ====================================== -->
  
  <!-- <xsl:template match="xr:bucket" mode="svg:bucket-sort-micropolygons">
    <xsl:apply-templates select="svg:*"/>
  </xsl:template> -->
  
  <!--  -->
  <xsl:template match="svg:*" mode="svg:bucket-sort-micropolygons">
    <xsl:variable name="contextBucket" select="parent::xr:bucket" as="element()"/>
    <xsl:variable name="bucket" select="tokenize($contextBucket/@xr:bbox, $xr:delimiter)" as="xs:string*"/>
    <xsl:variable name="bucketTop" select="number(subsequence($bucket, $xr:top, 1))" as="xs:double"/>
    <xsl:variable name="bucketRight" select="number(subsequence($bucket, $xr:right, 1))" as="xs:double"/>
    <xsl:variable name="bucketBottom" select="number(subsequence($bucket, $xr:bottom, 1))" as="xs:double"/>
    <xsl:variable name="bucketLeft" select="number(subsequence($bucket, $xr:left, 1))" as="xs:double"/>
    <xsl:variable name="bbox" select="tokenize(current()/@xr:bbox, $xr:delimiter)" as="xs:string*"/>
    <xsl:variable name="bboxTop" select="number(subsequence($bbox, $xr:top, 1))" as="xs:double"/>
    <xsl:variable name="bboxRight" select="number(subsequence($bbox, $xr:right, 1))" as="xs:double"/>
    <xsl:variable name="bboxBottom" select="number(subsequence($bbox, $xr:bottom, 1))" as="xs:double"/>
    <xsl:variable name="bboxLeft" select="number(subsequence($bbox, $xr:left, 1))" as="xs:double"/>
    <xsl:variable name="horizontalOverlap" select="($bucketRight - $bboxLeft) * ($bboxRight - $bucketLeft)" as="xs:double"/>
    <xsl:variable name="verticalOverlap" select="($bucketTop - $bboxBottom) * ($bboxTop - $bucketBottom)" as="xs:double"/>
    
    <xsl:if test="($horizontalOverlap gt 0) and ($verticalOverlap gt 0)">
      <xsl:copy-of select="current()"/>
    </xsl:if>
  </xsl:template>
  
  
  
  <!-- === Sample. ========================================================= -->
  
  <!--  -->
  <xsl:template match="xr:bucket" mode="svg:sample">
    <xsl:variable name="bucketBBox" select="tokenize(@xr:bbox, $xr:delimiter)" as="xs:string*"/>
    <xsl:variable name="bucketTop" select="xs:integer(subsequence($bucketBBox, $xr:top, 1))" as="xs:integer"/>
    <xsl:variable name="bucketLeft" select="xs:integer(subsequence($bucketBBox, $xr:left, 1))" as="xs:integer"/>
    <xsl:variable name="sampleOffset" select="number(0.5)" as="xs:double"/>
    <!-- Make a sequence of sample locations, for the context bucket, to be used 
        as a look-up table. -->
    <xsl:variable name="sampleLUT" as="element()*">
      <xsl:for-each select="$bucketTop to (xs:integer($options/options/bucket/@size) - 1) + $bucketTop">
        <xsl:variable name="y" select="current()" as="xs:integer"/>
        <xsl:for-each select="$bucketLeft to (xs:integer($options/options/bucket/@size) - 1) + $bucketLeft">
          <xsl:variable name="x" select="current()" as="xs:integer"/>
          <xr:sample x="{$x + $sampleOffset}" y="{$y + $sampleOffset}"/>
        </xsl:for-each>
      </xsl:for-each>
    </xsl:variable>
    
    <xsl:apply-templates select="$sampleLUT" mode="#current">
      <xsl:with-param name="bucket" select="current()"/>
    </xsl:apply-templates>
  </xsl:template>
  
  
  <!--  -->
  <xsl:template match="xr:sample" mode="svg:sample">
    <xsl:param name="bucket" as="element()"/>
    <xsl:variable name="contextSample" select="current()"/>
    <xsl:variable name="sampledPolygons" as="element()*">
      <xsl:for-each-group select="$bucket/svg:*" group-by="@dcterms:isPartOf">
        <xsl:sequence select="svg:sampledPolygons(current-group(), $contextSample/@x, $contextSample/@y)"/>
      </xsl:for-each-group>
    </xsl:variable>
    
    <!--<xsl:if test="$sampledPolygons">-->
      <!-- If the top-most polygon has an opacity setting, calculate the composite
          colour for the whole set of polygons under the sample... -->
      <xsl:choose>
        <xsl:when test="subsequence($sampledPolygons, 1, 1)/@opacity">
          <xsl:sequence select="svg:getColor(svg:getCompositeColor($sampledPolygons, 'rgb(255,255,255)'))"/>
        </xsl:when>
        <!-- ...otherwise just sample the top one. -->
        <xsl:otherwise>
          <xsl:sequence select="svg:getColor(subsequence($sampledPolygons, 1, 1)/@color)"/>
        </xsl:otherwise>
      </xsl:choose>
    <!--</xsl:if>-->
  </xsl:template>
  
  
  <!-- Returns the polygon element(s) for which the passed (x,y) coord lies inside. -->
  
  <!-- Somewhere in this function we are not finding any polygons
       that overlap the passed coords! -->
  
  <xsl:function name="svg:sampledPolygons" as="element()*">
    <xsl:param name="polygons" as="element()*"/>
    <xsl:param name="sampleX" as="xs:double"/>
    <xsl:param name="sampleY" as="xs:double"/>
    <xsl:variable name="contextPolygon" select="subsequence($polygons, 1, 1)" as="element()"/>
    <xsl:variable name="points" select="tokenize($contextPolygon/@points, $svg:pointDelimiter)" as="xs:string*"/>
    <xsl:variable name="xCoords" select="for $p in $points return 
        number(subsequence(tokenize($p, $svg:coordDelimiter), $X, 1))" as="xs:double*"/>
    <xsl:variable name="yCoords" select="for $p in $points return 
        number(subsequence(tokenize($p, $svg:coordDelimiter), $Y, 1))" as="xs:double*"/>
    
    <xsl:variable name="insideXRange" select="if ($sampleX le max($xCoords) and $sampleX ge min($xCoords)) then true() else false()" as="xs:boolean"/>
    <xsl:variable name="insideYRange" select="if ($sampleY le max($yCoords) and $sampleY ge min($yCoords)) then true() else false()" as="xs:boolean"/>
    
    <!-- <xsl:if test="$insideXRange and $insideYRange">
      <xsl:sequence select="$polygon"/>
      </xsl:if> -->
    
    <!--<xsl:message>viewBox = '<xsl:value-of select="$contextPolygon/@xr:bbox"/>'</xsl:message>-->
    
    <xsl:choose>
      <xsl:when test="$insideXRange and $insideYRange">
        <xsl:sequence select="$contextPolygon"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="svg:sampledPolygons(remove($polygons, 1), $sampleX, $sampleY)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  
  <!-- Sample the colour values of each micropolygon. What you see here is 
      rather simplisitc as it only takes a single sample from each micropolygon.
      Therefore, no correction is taken of aliasing by stochatic sampling for 
      example. -->
  <xsl:template match="svg:*" mode="svg:sample">
    <xsl:sequence select="svg:getColor(@color)"/>
  </xsl:template>
  
  
  
  <!-- === Visibility. ===================================================== -->
  
  
  
  
  
  <!-- === Filter. ========================================================= -->
  
  
  
  
  
  <!-- === Image rendering. ================================================ -->
   
  <!-- SVG Root element. -->
  <xsl:template match="svg:svg" mode="render">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
   
   
  <!-- SVG Rectangle -->
  <xsl:template match="svg:rect" mode="render">
    <xsl:variable name="pixelCount" select="xs:integer(number(@width) * number(@height))"/>
    <xsl:sequence select="for $p in 1 to $pixelCount return svg:getColor(@color)"/>
  </xsl:template>
   
   
  <!-- SVG Circle -->
  <xsl:template match="svg:circle" mode="render"/>
   
   
  <!-- Extract colour values from the color attribute and return them as a 
       sequence of integers. -->
  <xsl:function name="svg:getColor" as="xs:integer*">
    <xsl:param name="color" as="xs:string"/>

    <xsl:analyze-string select="$color" regex="\d+">
      <xsl:matching-substring>
        <xsl:sequence select="xs:integer(number(current()))"/>
      </xsl:matching-substring>
    </xsl:analyze-string>
  </xsl:function>
   
   
  <!-- Calculate the composite colour of the sampled polygons that have an
      opacity setting and return them as a sequence of integers. -->
  <xsl:function name="svg:getCompositeColor" as="xs:string">
    <xsl:param name="sampledPolygons" as="element()*"/>
    <xsl:param name="precedingColour" as="xs:string"/>
    
    <xsl:variable name="precedingRGB" select="svg:getColor($precedingColour)" as="xs:integer*"/>
    <xsl:choose>
      <xsl:when test="count($sampledPolygons) gt 0">
        <xsl:variable name="currentPolygon" select="subsequence($sampledPolygons, count($sampledPolygons), 1)" as="element()"/>
        <xsl:variable name="currentColour" select="svg:getColor($currentPolygon/@color)" as="xs:integer*"/>
        <xsl:variable name="currentOpacity" select="($currentPolygon/@opacity, 1.0)[1]" as="xs:double"/>
        <xsl:variable name="compositeColour" as="xs:string*">
          <xsl:for-each select="1 to 3">
            <xsl:variable name="currentChannel" select="subsequence($currentColour, current(), 1)" as="xs:integer"/>
            <xsl:variable name="precedingChannel" select="subsequence($precedingRGB, current(), 1)" as="xs:integer"/>
            <!-- Transparency calculation: I = k * I + (1 - k) * I' -->
            <xsl:value-of select="string(floor($currentOpacity * $currentChannel + ((1 - $currentOpacity) * $precedingChannel)))"/>
          </xsl:for-each>
        </xsl:variable>
        
        <xsl:value-of select="svg:getCompositeColor(remove($sampledPolygons, count($sampledPolygons)), concat('rgb(', string-join($compositeColour, ','), ')'))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$precedingColour"/>
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:function>

</xsl:transform>
