<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="2.0"
      xmlns:math="http://exslt.org/math"
      xmlns:pxf="project.x.functions"
      xmlns:saxon="http://saxon.sf.net/"
      xmlns:xsd="http://www.w3.org/2001/XMLSchema"
      xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
      extension-element-prefixes="math saxon">

   <!-- <xsl:output method="text" indent="no" encoding="UTF-8" media-type="text/text"/> -->

   <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
         xmlns:dc="http://purl.org/dc/elements/1.1/"
         xmlns:dcterms="http:purl.org/dc/terms/">
      <rdf:Description rdf:about="$Source: $">
         <dc:creator>Philip A. R. Fennell</dc:creator>
         <dcterms:hasVersion>$Revision: $</dcterms:hasVersion>
         <dcterms:dateSubmitted>$Date: $</dcterms:dateSubmitted>
         <dc:rights>Copyright 2005 All Rights Reserved.</dc:rights>
         <dc:format>text/xsl</dc:format>
         <dc:description>Generates a Base64 encoded stream from the input 
            source data (sequence of uByte (unsigned char (0 - 255))).</dc:description>
      </rdf:Description>
   </rdf:RDF>
   
   
   <!--  -->
   <!-- <xsl:template match="/">
      <xsl:apply-templates/>
   </xsl:template> -->
   
   
   <!--  -->
   <xsl:template match="data">
      <xsl:value-of select="pxf:sequence2Base64(pxf:rampGen(0, 255))"/>
   </xsl:template>
   
   
   <!-- Convert an UTF-8 character string to base64 encoding. -->
   <xsl:function name="pxf:sequence2Base64">
      <xsl:param name="input"/>
      
      <!-- Split the stream of values in the ramp into groups of three and
         convert them to a Base64 encoding. Wrap the resulting string into lines
         no longer than 76 characters-->
      <xsl:value-of select="string-join(for $i in 0 to ((count($input) idiv 3) - 1) return 
            if (($i + 1) mod (76 idiv 4) = 0) then 
                  (pxf:triple2Base64(subsequence($input, ($i * 3) + 1, 3)), codepoints-to-string(10)) else 
                        pxf:triple2Base64(subsequence($input, ($i * 3) + 1, 3)), '')"/>
   </xsl:function>
   
   
   <!--  -->
   <xsl:function name="pxf:triple2Base64" as="xsd:string">
      <xsl:param name="triple"/>
      
      <xsl:variable name="binaryTriplets" select="pxf:toBinaryTriplets($triple)"/>
      
      <xsl:variable name="uByteQuadruplets" select="pxf:toUByteQuadruplets($binaryTriplets)"/>
      
      <xsl:variable name="chars" select="pxf:toChars($uByteQuadruplets)"/>
      <xsl:value-of select="$chars"/>
   </xsl:function>
   
   
   <!-- Build the binary triple from the three values. -->
   <xsl:function name="pxf:toBinaryTriplets" as="item()*">
      <xsl:param name="triple"/>
      
      <xsl:sequence select="for $i in $triple return pxf:uByte2Binary(number($i))"/>
   </xsl:function>
   
   
   <!-- Convert the 6bit binary number to an uByte. -->
   <xsl:function name="pxf:toUByteQuadruplets" as="item()*">
      <xsl:param name="binaryTriplets"/>
      
      <xsl:sequence select="for $i in 0 to ((count($binaryTriplets) idiv 6) - 1) return 
           pxf:binary2Uchar(subsequence($binaryTriplets, ($i * 6) + 1, 6))"/>
   </xsl:function>
   
   
   <!-- Convert the 6bit integer values to characters. -->
   <xsl:function name="pxf:toChars" as="xsd:string">
      <xsl:param name="uByteQuadruplets"/>
      
      <xsl:value-of select="string-join(for $i in $uByteQuadruplets return 
           pxf:uByte2Character($i), '')"/>
   </xsl:function>
   
   
   <!-- Convert the 6bit integers to their Base64 character equivalents using 
      a LUT. -->
   <xsl:function name="pxf:uByte2Character" as="xsd:string">
      <xsl:param name="uByte"/>
      <xsl:variable name="lut-base64" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/='"/>
      
      <xsl:value-of select="substring($lut-base64, (number($uByte) + 1), 1)"/>
   </xsl:function>
   
   
   <!-- Convert a uByte (8 bit unsigned integer) to binary. -->
   <xsl:function name="pxf:uByte2Binary" as="item()*">
      <xsl:param name="uByte"/>
      <xsl:variable name="lut-8Bit" select="128,64,32,16,8,4,2,1"/>
      
      <xsl:sequence select="for $i in $lut-8Bit return 
           string(($uByte idiv number($i)) mod 2)"/>
   </xsl:function>
   
   
   <!-- Convert a binary number to a uByte (8 bit unsigned integer). -->
   <xsl:function name="pxf:binary2Uchar" as="xsd:string">
      <xsl:param name="binary"/>
      <xsl:variable name="lut-6bit" select="32,16,8,4,2,1"/>
      
      <xsl:value-of select="sum(for $i in 1 to count($binary), $j in $binary[$i] return 
           number(number(subsequence($lut-6bit, $i, 1)) * number($j)))"/>
   </xsl:function>
   
   
   <!-- Generate a ramp between 'start' and 'end'. -->
   <xsl:function name="pxf:rampGen" as="xsd:integer*">
      <xsl:param name="start"/>
      <xsl:param name="end"/>
      
      <xsl:sequence select="for $i in $start to $end return 
           (xsd:integer($i), xsd:integer($i), xsd:integer($i))"/>
   </xsl:function>
   
</xsl:transform>
