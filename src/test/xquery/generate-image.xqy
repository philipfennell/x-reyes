xquery version "1.0" encoding "utf-8";
	
import module namespace svg = "http://www.w3.org/2000/svg" 
	at "../../main/xquery/formats/input/svg.xqy";

import module namespace tiff = "http://partners.adobe.com/public/developer/tiff/"
		at "../../main/xquery/formats/output/tiff.xqy";

declare namespace saxon="http://saxon.sf.net/";
declare namespace xr = "http://code.google.com/p/x-reyes/";

declare option saxon:output "omit-xml-declaration=yes";

(: Declare external variables. :)
declare variable $width as xs:string external;
declare variable $height as xs:string external;
declare variable $red as xs:string external;
declare variable $green as xs:string external;
declare variable $blue as xs:string external;

(: Map external variables to typed in ternal variables. :)
declare variable $w as xs:integer := xs:integer(number($width));
declare variable $h as xs:integer := xs:integer(number($height));
declare variable $r as xs:integer := xs:integer(number($red));
declare variable $g as xs:integer := xs:integer(number($green));
declare variable $b as xs:integer := xs:integer(number($blue));

(: Generate the image data. :)
declare variable $imageStream as xs:unsignedByte* := 
		for $byte in 1 to ($w * $h) 
		return 
			(
			xs:unsignedByte($r), 
			xs:unsignedByte($g), 
			xs:unsignedByte($b)
			);

(: Generate the rendering options data. :)
declare variable $options as element()+ := 
		<options xmlns="http://code.google.com/p/x-reyes/" 
					pipeline="svg-reyes" mode="normal"><!-- normal | debug -->
			<pipeline/><!--  stop-after="svg:bucket-processor" -->
			<bucket size="16"/>
			<shading rate="1"/>
			<image resolution="72" resUnits="dpi" 
					format="tiff" channels="rgb" bitDepth="8"/>
		</options>;

(: Create a source SVG image (just the bare minimum. :)
declare variable $source as element() := 
		<svg xmlns="http://www.w3.org/2000/svg" 
				width="{$w}" height="{$h}" 
				viewBox="0 0 {$w} {$h}">
		  <title>Simple test image.</title>
		</svg>;

(: Generate the metadata structure from source image and renderer options. :)
declare variable $metadata as element() := svg:metadata($source, $options);

(: Generate the TIFF image structure from the image data and metadata. :)
declare variable $structure as element() := tiff:structure($imageStream, $metadata);

(: Serialise the TIFF structure as a sequence of bytes and Base64 encode it for output. :)
tiff:base64encode(tiff:serialise($structure))
