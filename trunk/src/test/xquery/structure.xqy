xquery version "1.0" encoding "utf-8";

import module namespace tiff = "http://partners.adobe.com/public/developer/tiff/" at "../../main/xquery/formats/output/tiff.xqy";

declare namespace xr = "http://code.google.com/p/x-reyes/"; 

(:
 : Sample metadata for constructing the TIFF structure.
 :)
declare variable $xr:metadata as element() := 
<metadata xmlns="http://code.google.com/p/x-reyes/">
	<tile size="16"/>
	<spatial width="16" height="16" res="72" resUnits="dpi"/>
	<colour bitDepth="8" channels="rgb"/>
	<title>Test Metadata</title>
	<description>Test Description</description>
</metadata>;

let $pixel as xs:unsignedByte* := (xs:unsignedByte(128), xs:unsignedByte(192), xs:unsignedByte(255))
return
tiff:structure(for $n in 1 to (16 * 16) return $pixel, $xr:metadata)
