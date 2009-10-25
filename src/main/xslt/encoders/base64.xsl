<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="2.0"
      xmlns:math="http://exslt.org/math"
      xmlns:pxf="project.x.functions"
      xmlns:saxon="http://saxon.sf.net/"
      xmlns:xsd="http://www.w3.org/2001/XMLSchema"
      xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
      extension-element-prefixes="math saxon">

   <xsl:output method="text" indent="no" encoding="UTF-8" media-type="text/text"/>

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
   <xsl:template match="/">
      <xsl:apply-templates select="data"/>
   </xsl:template>
   
   
   <!--  -->
   <!-- <xsl:template match="data[@href][@type = 'text/text']">
      <xsl:variable name="url" select="@href"/>
      <xsl:value-of select="pxf:string2Base64(unparsed-text($url, 'UTF-8'))"/>
   </xsl:template> -->
   
   
   <!--  -->
   <xsl:template match="data">
      <xsl:value-of select="pxf:sequence2Base64(pxf:rampGen(0, 255))"/>
   </xsl:template>
   
   
   <!-- Convert an UTF-8 character string to base64 encoding. -->
   <xsl:function name="pxf:sequence2Base64">
      <xsl:param name="input"/>

      <!-- <xsl:variable name="sequence" as="item()*">
         <xsl:value-of select="for $i in 0 to (count($input) idiv 3) return pxf:triple2Base64(subsequence($input, ($i * 3) + 1, 3))"/>
      </xsl:variable> -->
      
      <!-- <xsl:value-of select="string-join($sequence, '')"/> -->
      
      <xsl:for-each select="0 to (count($input) idiv 3)">
         <xsl:value-of select="pxf:triple2Base64(subsequence($input, (current() * 3) + 1, 3))"/>
            
            <!-- insert a new line after the 76th (19 * 4) character to keep line lengths reasonable! -->
            <xsl:if test="position() mod 19 = 0">
               <xsl:text>
</xsl:text>
            </xsl:if>
      </xsl:for-each>
   </xsl:function>
   
   
   <!--  -->
   <xsl:function name="pxf:triple2Base64" as="xsd:string">
      <xsl:param name="triple"/>
      
      <xsl:variable name="threeCSV" select="string-join(for $i in $triple return string($i), ',')"/>
      
      <!-- <xsl:message>$threeCSV = "<xsl:value-of select="$threeCSV"/>"</xsl:message> -->
      
      <xsl:variable name="binaryTriplets" select="pxf:toBinaryTriplets($threeCSV)"/>
      <!-- <xsl:message>$binaryTriplets = <xsl:value-of select="$binaryTriplets"/>"</xsl:message> -->
      
      <xsl:variable name="binaryQuadruplets" select="pxf:toBinaryQuadruplets($binaryTriplets)"/>
      <!-- <xsl:message>$binaryQuadruplets = "<xsl:value-of select="$binaryQuadruplets"/>"</xsl:message> -->
      
      <xsl:variable name="uByteQuadruplets" select="pxf:toUByteQuadruplets($binaryQuadruplets)"/>
      <!-- <xsl:message>$uByteQuadruplets = "<xsl:value-of select="$uByteQuadruplets"/>"</xsl:message> -->
      
      <!-- <xsl:message terminate="yes">Stop!</xsl:message> -->
      
      <xsl:variable name="chars" select="pxf:toChars($uByteQuadruplets)"/>
      <xsl:value-of select="$chars"/>
   </xsl:function>
   
   
   <!-- Convert a sequence of bytes (uBytes) to Base64 encoding. -->
   <xsl:function name="pxf:csvString2Base64">
     <xsl:param name="input"/>
     
     <xsl:analyze-string select="$input" regex="\d+,\d+,\d+">
         <xsl:matching-substring>
            <xsl:value-of select="pxf:threeCSVs2Base64(current())"/>
            
            <!-- insert a new line after the 76th (19 * 4) character to keep line lengths reasonable! -->
            <xsl:if test="position() mod 19 = 0">
               <xsl:text>
</xsl:text>
            </xsl:if>
         </xsl:matching-substring>
         
         <xsl:non-matching-substring>
            <xsl:message>No match for: <xsl:value-of select="current()"/></xsl:message>
            
            <!-- Apply padding where byte sequence is not a multiple of 3. -->
            <xsl:choose>
               
               <!-- Ignore the occurence of single commas that fall between 
                  a set of three values (triplets). -->
               <xsl:when test="current() = ','">
                  <xsl:message>Skip!</xsl:message>
               </xsl:when>
               
               <!-- When only two values are matched, pad the set with a single 0. -->
               <xsl:when test="count(tokenize(current(), ',')) = 2">
                  <xsl:value-of select="pxf:threeCSVs2Base64(concat(current(), ',0'))"/>
                  <xsl:text>=</xsl:text>
               </xsl:when>
               
               <!-- When only one value is matched, pad the set with two 0s. -->
               <xsl:otherwise>
                  <xsl:value-of select="pxf:threeCSVs2Base64(concat(current(), ',0,0'))"/>
                  <xsl:text>==</xsl:text>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:non-matching-substring>
      </xsl:analyze-string>
   </xsl:function>
   
   
   <!-- Convert a CSV string of three bytes to a Base64 encoding representation. -->
   <xsl:function name="pxf:threeCSVs2Base64" as="xsd:string">
      <xsl:param name="threeCSV"/>
      <xsl:message>$threeCSV = "<xsl:value-of select="$threeCSV"/>"</xsl:message>
      
      <xsl:variable name="binaryTriplets" select="pxf:toBinaryTriplets($threeCSV)"/>
      <xsl:message>$binaryTriplets = <xsl:value-of select="$binaryTriplets"/>"</xsl:message>
      
      <xsl:variable name="binaryQuadruplets" select="pxf:toBinaryQuadruplets($binaryTriplets)"/>
      <xsl:message>$binaryQuadruplets = "<xsl:value-of select="$binaryQuadruplets"/>"</xsl:message>
      
      <xsl:variable name="uByteQuadruplets" select="pxf:toUByteQuadruplets($binaryQuadruplets)"/>
      <xsl:message>$uByteQuadruplets = "<xsl:value-of select="$uByteQuadruplets"/>"</xsl:message>
      
      <!-- <xsl:message terminate="yes">Stop!</xsl:message> -->
      
      <xsl:variable name="chars" select="pxf:toChars($uByteQuadruplets)"/>
      <xsl:value-of select="$chars"/>
      
   </xsl:function>
   
   
   <!-- Build the binary triple from the three values. -->
   <xsl:function name="pxf:toBinaryTriplets" as="xsd:string">
      <xsl:param name="threeCSV"/>
      
      <xsl:value-of select="string-join(for $i in tokenize($threeCSV, ',')
        return (if ($i != '') then pxf:uByte2Binary(number($i)) else ''), '')"/>
   </xsl:function>
   
   
   <!-- Break the binary stream into four 6bit pieces. -->
   <xsl:function name="pxf:toBinaryQuadruplets" as="xsd:string">
      <xsl:param name="binaryTriplets"/>
      
      <xsl:variable name="binaryQuadruplets">
        <xsl:analyze-string select="$binaryTriplets" regex="\d{{6}}">
            <xsl:matching-substring>
               <xsl:value-of select="current()"/>
               <xsl:if test="position() != 4">
                  <xsl:text>,</xsl:text>
               </xsl:if>
            </xsl:matching-substring>
         </xsl:analyze-string>
      </xsl:variable>
      <xsl:value-of select="$binaryQuadruplets"/>
   </xsl:function>
   
   
   <!-- Convert the 6bit binary number to an uByte. -->
   <xsl:function name="pxf:toUByteQuadruplets" as="xsd:string">
      <xsl:param name="binaryQuadruplets"/>
      
      <xsl:value-of select="string-join(for $i in tokenize($binaryQuadruplets, ',')
        return pxf:binary2Uchar(string($i)), ',')"/>
   </xsl:function>
   
   
   <!-- Convert the 6bit integer values to characters. -->
   <xsl:function name="pxf:toChars" as="xsd:string">
      <xsl:param name="uByteQuadruplets"/>
      
      <xsl:value-of select="string-join(for $i in tokenize($uByteQuadruplets, ',')
        return pxf:uByte2Character($i), '')"/>
   </xsl:function>
   
   
   <!-- Convert the 6bit integers to their Base64 character ecuivalents using 
      a LUT. -->
   <xsl:function name="pxf:uByte2Character" as="xsd:string">
      <xsl:param name="uByte"/>
      <xsl:variable name="lut-base64" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/='"/>
      
      <xsl:value-of select="substring($lut-base64, (number($uByte) + 1), 1)"/>
   </xsl:function>
   
   
   <!-- Convert a uByte (8 bit unsigned integer) to binary. -->
   <xsl:function name="pxf:uByte2Binary" as="xsd:string">
      <xsl:param name="uByte"/>
      <xsl:variable name="lut-8Bit" select="tokenize('128,64,32,16,8,4,2,1', ',')"/>
      
      <xsl:value-of select="string-join(for $i in $lut-8Bit return string(($uByte idiv number($i)) mod 2), '')"/>
   </xsl:function>
   
   
   <!-- Convert a binary number to a uByte (8 bit unsigned integer). -->
   <xsl:function name="pxf:binary2Uchar" as="xsd:string">
      <xsl:param name="binary"/>
      <xsl:variable name="lut-6bit" select="tokenize('32,16,8,4,2,1', ',')"/>
      
      <xsl:variable name="bitValues">
         <xsl:analyze-string select="$binary" regex="\d{{1}}">
            <xsl:matching-substring>
               <xsl:variable name="multiplier" select="number(subsequence($lut-6bit, position(), 1))"/>
               <xsl:value-of select="number($multiplier * number(current()))"/>
               <xsl:if test="position() != last()"><xsl:text>,</xsl:text></xsl:if>
            </xsl:matching-substring>
         </xsl:analyze-string>
      </xsl:variable>
      <xsl:value-of select="sum(for $i in tokenize($bitValues, ',') return number($i))"/>
   </xsl:function>
   
   
   <!-- Generate a ramp between 'start' and 'end'. -->
   <xsl:function name="pxf:rampGen" as="xsd:unsignedByte*">
      <xsl:param name="start"/>
      <xsl:param name="end"/>
      
      <xsl:sequence select="for $i in $start to $end return (xsd:unsignedByte($i), xsd:unsignedByte($i), xsd:unsignedByte($i))"/>
   </xsl:function>
   
</xsl:transform>
