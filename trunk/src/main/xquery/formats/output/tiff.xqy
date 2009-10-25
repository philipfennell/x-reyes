module namespace tiff = "http://partners.adobe.com/public/developer/tiff/";

(:
@prefix dcterms <http:purl.org/dc/terms/>.
<> dcterms:source "$Source: $".
<> dcterms:creator "Philip A. R. Fennell".
<> dcterms:rights "Philip A. R. Fennell Copyright 2009 All Rights Reserved".
<> dcterms:hasVersion "$Revision: $".
<> dcterms:dateSubmitted "$Date: $".
<> dc:format "application/xquery".
<> dc:description "TIFF Image Serialiser.".
:)

declare namespace saxon="http://saxon.sf.net/";
declare namespace xr = "http://code.google.com/p/x-reyes/";

(: === Constants. =========================================================== :)

(: Header :)
declare variable $tiff:Identifier as xs:integer := 42;
declare variable $tiff:ByteOrder_II as xs:integer := 73;
declare variable $tiff:ByteOrder_MM as xs:integer := 77;
declare variable $tiff:headerCount as xs:integer := 8;

(: IFD Field Constants :)
declare variable $tiff:ResolutionUnit_None as xs:integer := 1;
declare variable $tiff:ResolutionUnit_Inch as xs:integer := 2;
declare variable $tiff:ResolutionUnit_Centimeter as xs:integer := 3;
declare variable $tiff:Compression_None as xs:integer := 1;
declare variable $tiff:Compression_CCITT as xs:integer := 2;
declare variable $tiff:Compression_PackBits as xs:integer := 32773;
declare variable $tiff:PhotoInterp_WhiteIsZero as xs:integer := 0;
declare variable $tiff:PhotoInterp_BlackIsZero as xs:integer := 1;
declare variable $tiff:PhotoInterp_RGB as xs:integer := 2;
declare variable $tiff:SamplesPerPixel_Bilevel as xs:integer := 1;
declare variable $tiff:SamplesPerPixel_Greyscale as xs:integer := 1;
declare variable $tiff:SamplesPerPixel_PaletteColor as xs:integer := 1;
declare variable $tiff:SamplesPerPixel_RGB as xs:integer := 3;
declare variable $tiff:optimumStripByteCount as xs:integer := 8000;
declare variable $tiff:PlanarConfig_Contig as xs:integer := 1;
declare variable $tiff:PlanarConfig_Planar as xs:integer := 2;

(:  IFD Data types. 
	1 = BYTE 8-bit 								xs:unsignedByte.
	2 = ASCII 8-bit byte that contains a 
		7-bit ASCII code; the last byte
		must be NUL (binary zero).				xs:string.
	3 = SHORT 16-bit (2-byte)					xs:unsignedShort.
	4 = LONG 32-bit (4-byte)					xs:unsignedInt.
	5 = RATIONAL Two LONGs: the 
		first represents the numerator of a
		fraction; the second, the denominator.	(xs:unsignedInt, xs:unsignedInt)
:)
declare variable $tiff:Type_BYTE as xs:integer := 1;
declare variable $tiff:Type_ASCII as xs:integer := 2;
declare variable $tiff:Type_SHORT as xs:integer := 3;
declare variable $tiff:Type_LONG as xs:integer := 4;
declare variable $tiff:Type_RATIONAL as xs:integer := 5;

(: TIFF Field tags. :)
declare variable $tiff:NewSubfileType as xs:integer := 254;
declare variable $tiff:SubfileType as xs:integer := 255;
declare variable $tiff:ImageWidth as xs:integer := 256;
declare variable $tiff:ImageLength as xs:integer := 257;
declare variable $tiff:BitsPerSample as xs:integer := 258;
declare variable $tiff:Compression as xs:integer := 259;
declare variable $tiff:PhotoInterp as xs:integer := 262;
declare variable $tiff:StripOffsets as xs:integer := 273;
declare variable $tiff:SamplesPerPixel as xs:integer := 277;
declare variable $tiff:RowsPerStrip as xs:integer := 278;
declare variable $tiff:StripByteCounts as xs:integer := 279;
declare variable $tiff:XResolution as xs:integer := 282;
declare variable $tiff:YResolution as xs:integer := 283;
declare variable $tiff:PlanarConfig as xs:integer := 284;
declare variable $tiff:ResolutionUnit as xs:integer := 296;
declare variable $tiff:TileWidth as xs:integer := 322;
declare variable $tiff:TileLength as xs:integer := 323;
declare variable $tiff:TileOffsets as xs:integer := 324;
declare variable $tiff:TileByteCounts as xs:integer := 325;

(: === Field entry lengths. ================================================= :)
declare variable $tiff:bytes-2 as xs:integer := 2;
declare variable $tiff:bytes-4 as xs:integer := 4;

  
(: 
 : Generates the structure of the TIFF image represented as XML.
 : @param image
 : @param metadata
 : @return An XML structure.
 :)
declare function tiff:structure($image as xs:unsignedByte*, $metadata as element())
	as element()
{
<image xmlns="http://partners.adobe.com/public/developer/tiff/">
	<header>
		<byte-order value="{tiff:byteOrder(xs:integer($tiff:ByteOrder_II))}"/>
		<identifier value="{tiff:identifier(xs:integer($tiff:Identifier))}"/>
		<directory-offset value="{tiff:ifdOffset(count($image) + $tiff:headerCount)}"/>
	</header>
	<data>{$image}</data>
	<directory>
		<field tag="{$tiff:ImageWidth}" type="{$tiff:Type_LONG}" count="1" value="{$metadata/xr:spatial/@width}"/>
		<field tag="{$tiff:ImageLength}" type="{$tiff:Type_LONG}" count="1" value="{$metadata/xr:spatial/@height}"/>
		<field tag="{$tiff:BitsPerSample}" type="{$tiff:Type_SHORT}" count="{$tiff:SamplesPerPixel_RGB}" value="{8, 8, 8}"/>
		<field tag="{$tiff:Compression}" type="{$tiff:Type_SHORT}" count="1" value="{$tiff:Compression_None}"/>
		<field tag="{$tiff:PhotoInterp}" type="{$tiff:Type_SHORT}" count="1" value="{$tiff:PhotoInterp_RGB}"/>
		<field tag="{$tiff:SamplesPerPixel}" type="{$tiff:Type_SHORT}" count="1" value="{$tiff:SamplesPerPixel_RGB}"/>
		<field tag="{$tiff:XResolution}" type="{$tiff:Type_RATIONAL}" count="1" value="{$metadata/xr:spatial/@res}"/>
		<field tag="{$tiff:YResolution}" type="{$tiff:Type_RATIONAL}" count="1" value="{$metadata/xr:spatial/@res}"/>
		<field tag="{$tiff:PlanarConfig}" type="{$tiff:Type_SHORT}" count="1" value="{$tiff:PlanarConfig_Contig}"/>
		<field tag="{$tiff:ResolutionUnit}" type="{$tiff:Type_SHORT}" count="1" value="{$tiff:ResolutionUnit_Inch}"/>
		<field tag="{$tiff:TileWidth}" type="{$tiff:Type_SHORT}" count="1" value="{$metadata/xr:tile/@size}"/>
		<field tag="{$tiff:TileLength}" type="{$tiff:Type_SHORT}" count="1" value="{$metadata/xr:tile/@size}"/>
		<field tag="{$tiff:TileOffsets}" type="{$tiff:Type_LONG}" count="{tiff:tilesPerImage($metadata)}" value="{tiff:tileOffsets($metadata)}"/>
		<field tag="{$tiff:TileByteCounts}" type="{$tiff:Type_LONG}" count="{tiff:tilesPerImage($metadata)}" value="{tiff:tileByteCounts($metadata)}"/>
		<directory-offset/>
	</directory>
	<field-values/>
</image>
};


(:
 : Serialises the TIFF structure to a byte sequence (stream).
 : @param structure An XML representation of the tiff structure.
 : @return A sequence of bytes representing the image stream.
 :)
declare function tiff:serialise($structure as element())
		as xs:unsignedByte*
{
	let $byteCount		:= count(tokenize($structure/tiff:data, ' '))
	let $header 		:= tiff:header($structure/tiff:header)
	let $image 			:= tiff:image-data($structure/tiff:data)
	let $ifd 			:= tiff:ifd($structure/tiff:directory, $byteCount)
	let $offsetValues	:= tiff:processOffsetValues($structure/tiff:directory/tiff:field, $byteCount)
	return
		($header, $image, $ifd, $offsetValues)
};


(:
 : Base64 encodes a tiff byte stream.
 : @param $byteStream
 : @return A Base64 encoded string.
 :)
declare function tiff:base64encode($byteStream as xs:unsignedByte*)
		as xs:base64Binary
{
	saxon:octets-to-base64Binary($byteStream)
}; 


(:
 : Returns the TIFF header sequence of bytes.
 : @param $header 
 : @return A sequence of bytes representing the TIFF header.
 :)
declare function tiff:header($header as element()) 
		as xs:unsignedByte* 
{
	(
	tiff:string2bytes($header/tiff:byte-order/@value),
	tiff:string2bytes($header/tiff:identifier/@value),
	tiff:string2bytes($header/tiff:directory-offset/@value)
	)
};


(:
 : Retrieves the image data stream from the TIFF structure
 : @param $data The image data stream.
 : @return A sequence of bytes
 :)
declare function tiff:image-data($data as element()) 
		as xs:unsignedByte* 
{
	for $byte in tokenize($data/text(), ' ')
	return xs:unsignedByte(fn:number($byte))
}; 


(:
 : Returns the Image Field Directory from the passed TIFF structure.
 : @param $directory The XML representation of a TIFF Image Field Directory. 
 : @return
 :)
declare function tiff:ifd ($directory as element(), $byteCount as xs:integer) 
		as xs:unsignedByte* 
{
	let $fields as item()* := tiff:processIFDFields($directory/tiff:field, $byteCount)
	let $nextIFDOffset as xs:unsignedInt* := tiff:integer2octets(0, $tiff:bytes-4)
	return
		(
		tiff:integer2octets(fn:count($directory/tiff:field), $tiff:bytes-2),
		$fields,
		$nextIFDOffset
		)
}; 


(:
 : Transforms a sequence of IFD Field elements into there data equivalent.
 : @param $fields
 : @param $byteCount 
 : @return A sequence of encoded IFD fields.
 :)
declare function tiff:processIFDFields($fields as element()*, $byteCount as xs:integer) 
		as xs:unsignedByte* 
{
	let $valuesOffset as xs:integer := $tiff:headerCount + $byteCount + (2 + xs:integer(count($fields) * 12) + 4)
	return
		for $field in $fields
		return
			if ($field/@count = 1) 
			then
				tiff:generateIFDValueField($field)
			else if ($field/@type = $tiff:Type_RATIONAL)
			then
				tiff:generateIFDOffsetField($valuesOffset, $field)
			else
				tiff:generateIFDOffsetField($valuesOffset, $field)
};


(:
 : Generate a 12 byte field (with value) for the Image File Directory (IFD).
 : @param $field 
 : @return
:)
declare function tiff:generateIFDValueField($field as element())
		as xs:unsignedByte* 
{
	let $tag as xs:integer := xs:integer($field/@tag)
    let $type as xs:integer := xs:integer($field/@type)
    let $length as xs:integer := tiff:getLengthOfType($type)
    let $count as xs:integer := xs:integer($field/@count)
    let $value as xs:integer := xs:integer($field/@value)
    return
    	(
    	tiff:integer2octets($tag, $tiff:bytes-2), 
    	tiff:integer2octets($type, $tiff:bytes-2), 
    	tiff:integer2octets($count, $tiff:bytes-4), 
    	tiff:integer2octets($value, $tiff:bytes-4)
    	)
}; 


(: 
 : Generate a 12 byte field (with offset) for the Image File Directory (IFD).
 : @param $valueOffset
 : @param $field 
 : @return A sequence of 12 bytes representing an 'offset' IFD field.
 :)
declare function tiff:generateIFDOffsetField($valuesOffset as xs:integer, $field as element())
		as xs:unsignedByte* 
{
	let $values as xs:integer* := for $i in tokenize($field/@value, ' ')
	return xs:integer($i)
	let $tag as xs:integer := xs:integer($field/@tag)
    let $type as xs:integer := xs:integer($field/@type)
    let $count as xs:integer := xs:integer($field/@count)
    let $length as xs:integer := tiff:getLengthOfType($type)
	return
		(
		tiff:integer2octets($tag, $tiff:bytes-2), 
		tiff:integer2octets($type, $tiff:bytes-2), 
		tiff:integer2octets($count, $tiff:bytes-4), 
		tiff:integer2octets($valuesOffset + tiff:getValueOffset($field), $tiff:bytes-4)
		)
};


(:
 : Process the IFD fields to generate the 'offset' field values.
 : @param $fields
 : @param $byteCount
 : @return
:)
declare function tiff:processOffsetValues($fields as element()*, $byteCount as xs:integer) 
		as xs:unsignedByte*
{
	for $field in $fields
		let $value as item()* := if (fn:number($field/@count) gt 1) then 
        		fn:tokenize($field/@value, ' ') else xs:integer($field/@value)
	return
		tiff:generateIFDOffsetValue($field/@type, $field/@count, $value)
};


(:
 : Generate an offset field value for the Image File Directory (IFD).
 : @param $type Field type
 : @param $count Number of values in the field
 : @param $value the actual value
 : @return A sequence of bytes representing the value that is to be 'offset'.
 :)
declare function tiff:generateIFDOffsetValue($type as xs:integer, $count as xs:integer, $value as item()*)
		as xs:unsignedByte* 
{
	let $length as xs:integer := tiff:getLengthOfType($type)
	return
		if ($type = $tiff:Type_RATIONAL)
		then
			(
			tiff:integer2octets($value, $length),
        	tiff:integer2octets(1, $length)
        	)
		else if ($value instance of xs:string+)
			then
				for $v in $value return tiff:integer2octets(xs:integer($v), $length)
			else
				tiff:integer2octets($value, $length)
};


(:
 : For the context field node(), calculate it's offset based on the length 
 : of it's preceding sibling(s).
 : @param $field 
 : @return 
 :)
declare function tiff:getValueOffset ($field as element()) 
		as xs:integer
{
	let $precedingFields as element()* := $field/preceding-sibling::tiff:field
    return
    	if (fn:count($precedingFields) gt 0)
    	then
    		fn:sum(for $i in $precedingFields 
    			return 
            		if($i/@type = $tiff:Type_RATIONAL) then 
                		xs:integer(tiff:getLengthOfType($i/@type)) * (xs:integer($i/@count) * 2) else 
                    		xs:integer(tiff:getLengthOfType($i/@type)) * xs:integer($i/@count))
    	else
    		xs:integer(0)
}; 


(:
 : Return the length (in bytes) of the passed data type. 
 : @param $type 
 : @return 
:)
declare function tiff:getLengthOfType($type as xs:integer) 
		as xs:integer 
{
	let $typeLengthLUT as xs:integer* := (1, 1, 2, 4, 4)
	return
		subsequence($typeLengthLUT, $type, 1)
}; 


(:
 : Takes a string representation of a number and returns it as a byte.
 :@param $string
 :@return 
 :)
declare function tiff:string2bytes($string as xs:string) 
		as xs:unsignedByte*
{
	for $i in fn:tokenize($string, ' ') return xs:unsignedByte(fn:number($i))
}; 


(: 
 : The byte order used within the file.
 :)
 declare function tiff:byteOrder($byteOrder as xs:integer)
 	as xs:unsignedByte+
{
	(xs:unsignedByte($byteOrder), xs:unsignedByte($byteOrder))
};


(: 
 : An arbitrary but carefully chosen number (42) that further identifies 
 : the file as a TIFF file.
 :)
declare function tiff:identifier($id as xs:integer)
	as xs:unsignedByte+
{
	tiff:integer2octets($id, $tiff:bytes-2)
}; 


(:
 : The offset (in bytes) of the first IFD.
 :)
declare function tiff:ifdOffset($offset as xs:integer)
	as  xs:unsignedByte+
{
	tiff:integer2octets($offset, $tiff:bytes-4)
}; 


(:
 : Converts the passed $number to a sequence of $length octets.
 : @param $number
 : @param $length
 : @return A sequence of octet values.
 :)
declare function tiff:integer2octets($number as xs:integer, $length as xs:integer)
	as xs:unsignedByte+
{
	let $fieldValues as xs:integer+ := (256, 65536, 16777216, 4294967296)
	for $n in 1 to $length 
	return 
		xs:unsignedByte(
			number(
				floor(
					(
						($number div subsequence($fieldValues, $n, 1)) - 
						($number idiv subsequence($fieldValues, $n, 1))
					) * 256
				)
			)
		)
};


(:
 : Convert an integer number to a rational number.
 : @param $number
 : @return 
 :)
declare function tiff:integer2Rational($number as xs:integer)
		as xs:unsignedByte* 
{
	(
	tiff:integer2octets($number, $tiff:Type_LONG),
	tiff:integer2octets(1, $tiff:Type_LONG)
	)
}; 


(:
 : Returms the number of tiles that make up the image
 : @param $metadata The XML structure carrying image related metadata.
 : @return The number of tiles in the image. 
 :)
declare function tiff:tilesPerImage($metadata as element())
	as xs:unsignedInt
{
	let $tiff:imageWidth as xs:integer := xs:integer($metadata/xr:spatial/@width)
    let $tiff:imageLength as xs:integer := xs:integer($metadata/xr:spatial/@height)
    let $tiff:tileWidth as xs:integer := xs:integer($metadata/xr:tile/@size)
    let $tiff:tileHeight as xs:integer := xs:integer($metadata/xr:tile/@size)
    let $tiff:tilesAcross as xs:integer := xs:integer(floor(($tiff:imageWidth + $tiff:tileWidth - 1)) div $tiff:tileWidth)
    let $tiff:tilesDown as xs:integer := xs:integer(floor(($tiff:imageLength + $tiff:tileHeight - 1)) div $tiff:tileHeight)
    
    return xs:unsignedInt($tiff:tilesAcross * $tiff:tilesDown)
}; 


(:
 : For each tile, the byte offset of that tile, as compressed and stored on 
 : disk. The offset is specified with respect to the beginning of the TIFF file.
 : @param $metadata The XML structure carrying image related metadata.
 : @return A sequence of tile byte offsets.
 :)
declare function tiff:tileOffsets($metadata as element())
	as xs:unsignedInt* 
{
	let $tiff:startOffset as xs:unsignedInt := xs:unsignedInt($tiff:headerCount)
    return ($tiff:startOffset, (
    	for $n in 1 to (tiff:tilesPerImage($metadata) - 1) 
    	return 
        	xs:unsignedInt($tiff:startOffset + 
        		sum(subsequence(tiff:tileByteCounts($metadata), 1, $n)))))
}; 


(:
 : Calculates the number of bytes in an image tile and generates a sequence 
 : of this value, one for each tile in the image.
 : @param $metadata The XML structure carrying image related metadata.
 : @return 
 :)
declare function tiff:tileByteCounts($metadata as element())
	as xs:unsignedInt*
{
	let $tiff:tileWidth as xs:integer := xs:integer($metadata/xr:tile/@size)
    let $tiff:tileHeight as xs:integer := xs:integer($metadata/xr:tile/@size)
    let $tiff:bytesPerPixel as xs:integer := xs:integer($tiff:SamplesPerPixel_RGB)
    let $tiff:bytesPerTile := xs:unsignedInt(($tiff:tileWidth * $tiff:tileHeight) * $tiff:bytesPerPixel)
    
    for $n in 1 to tiff:tilesPerImage($metadata)
    return
    	$tiff:bytesPerTile
};

