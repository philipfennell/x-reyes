<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="2.0"
    xmlns:a3="http://ns.adobe.com/AdobeSVGViewerExtensions/3.0/"
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
    exclude-result-prefixes="dcterms fn pxf xdt xs">
    
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
      <dc:description>SMIL Animation interpretation transforms.</dc:description>
    </rdf:Description>
  </rdf:RDF>
  
  
  
  <!-- === Read model. ===================================================== -->
  
  <!-- Replicate the root element and any non-graphical content. Then insert all
      graphical primitives (and containers) into a container. -->
  <xsl:template match="svg:svg" mode="svg:read">
    <xsl:copy>
      <xsl:sequence select="@*"/>
      <xsl:sequence select="svg:title | svg:description | svg:def | svg:script | svg:style | svg:metadata"/>
      <xsl:apply-templates select="svg:* except (svg:title, svg:description, svg:def, svg:script, svg:style, svg:metadata)" mode="svg:read-primitives"/>
    </xsl:copy>
  </xsl:template>
  
  
  <!-- Read the model's primitives and add an ID attribute, if missing, to each 
      primitive/group node. -->
  <xsl:template match="svg:*" mode="svg:read-primitives">
    <xsl:copy>
      <xsl:sequence select="@*"/>
      <xsl:if test="not(@id)">
        <xsl:attribute name="id" select="generate-id()"/><!-- For schema aware processors type="xs:ID". -->
      </xsl:if>
      <xsl:apply-templates select="svg:* except (svg:title, svg:description, svg:def, svg:script, svg:style, svg:metadata)" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  
  
  <!-- === Place animated primitives into their own layer. ================= -->
  
  <!--  -->
  <xsl:template match="svg:svg" mode="svg:layer">
    <xsl:copy>
      <xsl:sequence select="@*"/>
      <xsl:apply-templates select="* | text()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  
  <!--  -->
  <xsl:template match="svg:*[svg:animate | svg:set]" mode="svg:layer">
    <svg:g id="{@id}" class="{$options/options/view/@mode}">
      <svg:metadata>
        <xr:sequence ref="{@id}" view-mode="{$options/options/view/@mode}" animate="yes"/>
        <xsl:sequence select="svg:animate | svg:set"/>
      </svg:metadata>
      <xsl:copy>
        <xsl:sequence select="@*"/>
        <xsl:apply-templates select="* | text()" mode="#current"/>
      </xsl:copy>
    </svg:g>
  </xsl:template>
  
  
  <!--  -->
  <xsl:template match="svg:animate" mode="svg:layer"/>
  
  
  <!--  -->
  <xsl:template match="svg:set" mode="svg:layer"/>
  
  
  <!--  -->
  <xsl:template match="svg:*" mode="svg:layer">
    <xsl:copy>
      <xsl:sequence select="@*"/>
      <xsl:apply-templates select="* | text()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  
  
  <!-- === Tween each animated primitive. ================================== -->
  
  <!--  -->
  <xsl:template match="svg:svg" mode="svg:animate">
    <xsl:copy>
      <xsl:sequence select="@*"/>
      <xsl:apply-templates select="* | text()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  
  <!--  -->
  <xsl:template match="svg:*[svg:metadata/svg:animate | svg:metadata/svg:set]" mode="svg:animate">
    <xsl:copy>
      <xsl:sequence select="@*"/>
      <xsl:apply-templates select="* | text()" mode="svg:tween"/>
    </xsl:copy>
  </xsl:template>
  
  
  <!--  -->
  <xsl:template match="svg:*" mode="svg:tween">
    <xsl:variable name="contextPrimitive" select="current()" as="element()"/>
    <xsl:variable name="animators" select="../svg:metadata/svg:animate | ../svg:metadata/svg:set" as="element()+"/>
    <xsl:variable name="begin" select="xr:getBeginTime($animators)" as="xs:double"/>
    <xsl:variable name="duration" select="xr:getDuration($animators)" as="xs:double"/>
    <xsl:variable name="beginFrame" select="xs:integer(ceiling(($begin) div 0.04))" as="xs:integer"/>
    <xsl:variable name="endFrame" select="xs:integer(ceiling(($begin + $duration) div 0.04))" as="xs:integer"/>
    <xsl:variable name="frameCount" select="xs:integer(ceiling($duration * 
        number($options/options/frame/@rate)))" as="xs:integer"/>
    
    <xsl:for-each select="$beginFrame to $endFrame">
      <xsl:apply-templates select="$contextPrimitive" mode="svg:tween-2">
        <xsl:with-param name="animators" select="$animators" as="element()+"/>
        <xsl:with-param name="frameCount" select="$frameCount" as="xs:integer"/>
        <xsl:with-param name="frame" select="current()" as="xs:integer"/>
      </xsl:apply-templates>
    </xsl:for-each>
  </xsl:template>
  
  
  <!-- Obtain the earlist begin time of (all) the context animate element(s). -->
  <xsl:function name="xr:getBeginTime" as="xs:double">
    <xsl:param name="animators" as="element()+"/>
    
    <xsl:value-of select="min(for $i in $animators return number(substring-before($i/@begin, 's')))"/>
  </xsl:function>
  
  
  <!-- Obtain the total duration from (all) the context animate element(s). -->
  <xsl:function name="xr:getDuration" as="xs:double">
    <xsl:param name="animators" as="element()+"/>
    
    <xsl:value-of select="max(for $i in $animators return if ($i/@dur) then (number(substring-before($i/@begin, 's')) + 
        number(substring-before($i/@dur, 's'))) else if ($i/@end) then number(substring-before($i/@end, 's')) else 0)"/>
  </xsl:function>
  
  
  <!-- Calculate the change in position as an interpolation over time (frames). -->
  <xsl:function name="xr:interpolatedPosition" as="xs:double">
    <xsl:param name="underlyingValue" as="xs:double"/>
    <xsl:param name="animator" as="element()"/>
    <xsl:param name="frameCount" as="xs:integer"/>
    
    <xsl:choose>
      <xsl:when test="$animator/@from">
        <xsl:if test="$animator/@to">
          <!-- from-to -->
          <xsl:value-of select="(number($animator/@to) - number($animator/@from)) div $frameCount"/>
        </xsl:if>
        <xsl:if test="$animator/@by">
          <!-- from-by -->
          <xsl:value-of select="number($animator/@by) div $frameCount"/>
        </xsl:if>
      </xsl:when>
      <xsl:when test="$animator/@by">
        <!-- by -->
        <xsl:value-of select="number($animator/@by) div $frameCount"/>
      </xsl:when>
      <xsl:when test="$animator/@to">
        <!-- to -->
        <xsl:value-of select="(number($animator/@to) - $underlyingValue) div $frameCount"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="0"/>
      </xsl:otherwise>
    </xsl:choose>
    <!-- <xsl:value-of select="(number($animator/@to) - number($animator/@from)) div $frameCount"/> -->
  </xsl:function>
  
  
  <!-- Calculate the change in position as a single discrete step. -->
  <xsl:function name="xr:discretePosition" as="xs:double">
    <xsl:param name="underlyingValue" as="xs:double"/>
    <xsl:param name="animator" as="element()"/>
    <xsl:param name="frameCount" as="xs:integer"/>
    
    <xsl:value-of select="number($animator/@to) - $underlyingValue"/>
  </xsl:function>
  
  
  <!-- Removes the unit of time from the end of the value e.g. 10s -> 10.0 -->
  <xsl:function name="xr:time2Double" as="xs:double">
    <xsl:param name="time" as="xs:string"/>
    
    <xsl:value-of select="number(substring-before($time, 's'))"/>
  </xsl:function>
  
  
  <!--  -->
  <xsl:template match="svg:*" mode="svg:tween-2">
    <xsl:param name="animators" as="element()+"/>
    <xsl:param name="frameCount" as="xs:integer"/>
    <xsl:param name="frame" as="xs:integer"/>
    
    <xsl:variable name="contextPrimitive" select="current()" as="element()"/>
    
    <xsl:copy>
      <xsl:sequence select="@*"/>
      
      <xsl:attribute name="id" select="concat(@id, '_', $frame)"/>
      
      <xsl:attribute name="xr:frame" select="$frame"/>
      
      <!-- Onion-skin view mode displays all positions in outline. -->
      <xsl:if test="$options/options/view/@mode = 'onionSkin'">
        <xsl:attribute name="fill" select="'none'"/>
        <xsl:attribute name="stroke-width" select="'1px'"/>
        <xsl:attribute name="stroke" select="'grey'"/>
      </xsl:if>
      
      <!-- Ghost view mode displays all positions but with a light opacity setting. -->
      <xsl:if test="$options/options/view/@mode = 'ghost'">
        <xsl:attribute name="opacity" select="0.3"/>
      </xsl:if>
      
      <xsl:for-each select="$animators">
        <xsl:variable name="animator" select="current()" as="element()"/>
        <xsl:variable name="timeIndex" select="$frame * 0.04" as="xs:double"/>
        <xsl:variable name="begin" select="xr:time2Double($animator/@begin)" as="xs:double"/>
        <xsl:variable name="end" as="xs:double">
          <!-- The time the context animation ends can be defined as a duration starting from the begin,
              or a specific end time after the document was loaded. -->
          <xsl:choose>
            <xsl:when test="@dur">
              <xsl:value-of select="xr:time2Double($animator/@begin) + xr:time2Double($animator/@dur)"/>
            </xsl:when>
            <xsl:when test="@end">
              <xsl:value-of select="xr:time2Double($animator/@end)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="0"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="beginKey" select="xs:integer(ceiling($begin div 0.04))" as="xs:integer"/>
        <xsl:variable name="endKey" select="xs:integer(ceiling($end div 0.04))" as="xs:integer"/>
        <xsl:variable name="underlyingValue" select="number($contextPrimitive/attribute::node()[name() = $animator/@attributeName])" as="xs:double"/>
        <xsl:variable name="startValue" select="if (@from) then number(@from) else $underlyingValue" as="xs:double"/>
        
        <!-- Depending upon the animation element the change in position can be
            either an multiple steps interpolation between extremes or a single 
            jump to the extreme. -->
        <xsl:variable name="delta" as="xs:double">
          <xsl:choose>
            <xsl:when test="name($animator) = 'svg:set'">
              <xsl:value-of select="xr:discretePosition($underlyingValue, $animator, xs:integer(ceiling(($end - $begin) div 0.04)))"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="xr:interpolatedPosition($underlyingValue, $animator, xs:integer(ceiling(($end - $begin) div 0.04)))"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        
        <xsl:choose>
          <!-- Whilst the context frame is within the active duration. -->
          <xsl:when test="$begin le $timeIndex and $end gt $timeIndex">
            <xsl:variable name="frameOffset" select="if (name($animator) = 'svg:set') then 1 else ($frame - $beginKey)" as="xs:integer"/>
            <xsl:attribute name="{$animator/@attributeName}" select="format-number($startValue + ($delta * $frameOffset), $options/options/precision)"/>
          </xsl:when>
          <!-- When the frame is beyond the active duration. -->
          <xsl:when test="$timeIndex ge $end">
            <xsl:variable name="frameOffset" select="if (name($animator) = 'svg:set') then 1 else ($endKey - $beginKey)" as="xs:integer"/>
            <!-- The animation effect  F(t) is defined to 'freeze' the effect 
                value at the last value of the active duration. -->
            <xsl:choose>
              <xsl:when test="$animator/@fill = 'freeze'">
                <xsl:attribute name="{$animator/@attributeName}" select="format-number($startValue + ($delta * $frameOffset), $options/options/precision)"/>
              </xsl:when>
              <xsl:otherwise>
                <!--  The animation effect is removed (no longer applied) when 
                    the active duration of the animation is over. -->
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise/>
        </xsl:choose>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>
  
  
  <!--  -->
  <xsl:template match="svg:metadata" mode="svg:tween">
    <xsl:sequence select="current()"/>
  </xsl:template>
  
  
  <!--  -->
  <xsl:template match="svg:*" mode="svg:animate">
    <xsl:copy>
      <xsl:sequence select="@*"/>
      <xsl:apply-templates select="* | text()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  
  
  <!-- === Create a timeline structure to marshall and control playback. -->
  
  <!--  -->
  <xsl:template match="svg:svg" mode="svg:timeline">
    <xsl:apply-templates select="current()" mode="xr:timeline"/>
    <xsl:sequence select="current()"/>
  </xsl:template>
  
  
  <!--  -->
  <xsl:template match="svg:svg" mode="xr:timeline">
    <xsl:variable name="context" select="current()" as="element()"/>
    <xsl:variable name="animators" select="//svg:metadata/svg:animate | //svg:metadata/svg:set" as="element()+"/>
    <xsl:variable name="begin" select="xr:getBeginTime($animators)" as="xs:double"/>
    <xsl:variable name="duration" select="xr:getDuration($animators)" as="xs:double"/>
    <xsl:variable name="beginFrame" select="xs:integer(ceiling(($begin) div 0.04))" as="xs:integer"/>
    <xsl:variable name="endFrame" select="xs:integer(ceiling(($begin + $duration) div 0.04))" as="xs:integer"/>
    <xsl:variable name="frameCount" select="xs:integer(ceiling($duration * 
        number($options/options/frame/@rate)))" as="xs:integer"/>
    <xr:timeline>
      <xsl:for-each select="$beginFrame to $endFrame">
        <xsl:variable name="objects" select="$context//svg:*[xs:integer(@xr:frame) = current()]" as="element()*"/>
        <xr:frame ref="{string-join($objects/@id, ' ')}" number="{current()}"
            timeIndex="{format-number((1.0 div number($options/options/frame/@rate)) * (current()), $options/options/precision)}"/>
      </xsl:for-each>
    </xr:timeline>
  </xsl:template>
  
  
  <!--  -->
  <!-- <xsl:template match="svg:g" mode="xr:timeline">
    <xsl:apply-templates select="svg:* except svg:metadata" mode="#current"/>
  </xsl:template> -->
  
  
  <!--  -->
  <!-- <xsl:template match="svg:*" mode="xr:timeline">
    <xr:frame ref="{@id}" number="{position()}"
        timeIndex="{format-number((1.0 div number($options/options/frame/@rate)) * (position() - 1), $options/options/precision)}"/>
  </xsl:template> -->
  
  
  <!-- Suppress unwanted text nodes. -->
  <xsl:template match="text()" mode="xr:timeline"/>
  
  
  
  <!-- === Wrap the animated model into an application framework. ========== -->
  
  <!--  -->
  <xsl:template match="svg:svg" mode="svg:app-wrap">
    <xsl:processing-instruction name="xml-stylesheet">
      <xsl:text>href="interface/appearance/scene.css" type="text/css"</xsl:text>
    </xsl:processing-instruction>
    <svg:svg xmlns:xlink="http://www.w3.org/1999/xlink"
        a3:scriptImplementation="Adobe"
        width="{number(@width) + 56}" height="{number(@height) + 56}" onload="init(evt);">
      <svg:description>An SVG animation playback controller application</svg:description>
      <svg:title>inBetween</svg:title>
      <svg:metadata id="pipeline-options">
        <xsl:sequence select="$options"/>
      </svg:metadata>
      <svg:metadata>
        <xsl:sequence select="parent::element()/child::element()[1]"/>
      </svg:metadata>
      <svg:script a3:scriptImplementation="Adobe" type="text/ecmascript" 
          xlink:href="interface/scripts/XPath.js"/>
      <svg:script a3:scriptImplementation="Adobe" type="text/ecmascript" 
          xlink:href="interface/scripts/Playback.js"/>
      <svg:script a3:scriptImplementation="Adobe" type="text/ecmascript" 
          xlink:href="interface/scripts/Application.js"/>
      <svg:g class="interface">
        <svg:g class="scene">
          <xsl:sequence select="current()"/>
        </svg:g>
        <svg:g class="group" transform="translate(0, {@height})">
          <svg:g class="controls">
            <svg:rect x="4" y="4" width="48" height="30" rx="4" ry="4" onmousedown="app.playback.start();"/>
          </svg:g>
          <svg:g class="controls">
            <svg:rect x="56" y="4" width="48" height="30" rx="4" ry="4" onmousedown="app.playback.frameBack();"/>
          </svg:g>
          <svg:g class="controls">
            <svg:rect x="108" y="4" width="48" height="30" rx="4" ry="4" onmousedown="app.playback.pause();"/>
          </svg:g>
          <svg:g class="controls">
            <svg:rect x="160" y="4" width="48" height="30" rx="4" ry="4" onmousedown="app.playback.frameForward();"/>
          </svg:g>
          <svg:g class="controls">
            <svg:rect x="212" y="4" width="48" height="30" rx="4" ry="4" onmousedown="app.playback.stop();"/>
          </svg:g>
        </svg:g>
        <svg:g class="group" transform="translate(4, {number(@height) + 52})">
          <svg:text id="timeIndex">0.000</svg:text>
        </svg:g>
      </svg:g>
    </svg:svg>
  </xsl:template>
  
</xsl:transform>
