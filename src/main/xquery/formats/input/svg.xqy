module namespace svg = "http://www.w3.org/2000/svg";

(:
@prefix dcterms <http:purl.org/dc/terms/>.
<> dcterms:source "$Source: $".
<> dcterms:creator "Philip A. R. Fennell".
<> dcterms:rights "Philip A. R. Fennell Copyright 2009 All Rights Reserved".
<> dcterms:hasVersion "$Revision: $".
<> dcterms:dateSubmitted "$Date: $".
<> dc:format "application/xquery".
<> dc:description "SVG Reyes Renderer.".
:)

import module namespace xr = "http://code.google.com/p/x-reyes/" 
	at "../../common.xqy";
	
declare namespace saxon = "http://saxon.sf.net/";
declare default element namespace "http://www.w3.org/2000/svg";

declare variable $svg:POINTS_DELIMITER as xs:string := '\s';
declare variable $svg:COORDS_DELIMITER as xs:string := ',';
declare variable $svg:X as xs:integer := 1;
declare variable $svg:Y as xs:integer := 2;
declare variable $svg:W as xs:integer := 3;
declare variable $svg:H as xs:integer := 4;

(:
 : Render the source SVG model.
 : @param $source The source image document to be rendered.
 : @param $options The render options document.
 :)
declare function svg:render ($source as element(), $options as element())
	as xs:unsignedByte* 
{

svg:metadata($source, $options)
};


(:
 : Returns a metadata XML structure for the context source image and renderer 
 : options.
 : @param $source The source image document to be rendered.
 : @param $options The render options document.
 : @return An XML structure carrying metadata required for the rendering.
 :)
declare function svg:metadata ($source as element(), $options as element())
	as element() 
{
<metadata xmlns="http://code.google.com/p/x-reyes/">
	<tile size="{$options/xr:bucket/@size}"/>
	<spatial width="{$source/@width}"
			height="{$source/@height}"
			res="{$options/xr:image/@resolution}" 
			resUnits="{$options/xr:image/@resUnits}"/>
	<colour bitDepth="{$options/xr:image/@bitDepth}"
			channels="{$options/xr:image/@channels}"/>
	<title>{$source/svg:title/text()}</title>
	<description>{$source/svg:description/text()}</description>
</metadata>
};




(: === Read Model. ========================================================== :)

(:
 : Recursively process nodes, adding an 'id' attribute where one does not 
 : already exist.
 : @param $primitives the sequence of nodes to be processed.
 : @return A sequence of nodes.
 :)
declare function svg:read($primitives as element()) 
	as element()*
{
	for $p in $primitives 
	return
		element {fn:node-name($p)}
		{
			$p/@*,
			if (not($p/@id)) 
			then 
				attribute id {fn:concat('N', fn:count($p/preceding::*) + fn:count($p/ancestor-or-self::*))}
			else
				(),
			$p/*
		}
};




(: === Depth Sort. ========================================================== :)

(:
 : Apply depth sorting to the primitives in the model.
 : @param $primitives The un-depth-sorted SVG model.
 : @return An SVG model.
 :)
declare function svg:depth-sort($primitives as element()*)
	as element()* 
{
	fn:reverse($primitives)
};




(: === Bound Primitives. ==================================================== :)

(:
 : 
 : @param $primitives
 : @return
 :)
declare function svg:bound($primitive as element())
	as element() 
{
	let $bboxAttr as attribute()? := typeswitch ($primitive)
		case $contextItem as element(svg:rect)
		return
			svg:bound-xywh($primitive)
		case $contextItem as element(svg:polygon)
		return
			svg:bound-points($primitive)
		default
		return
			()
	return
		element {fn:node-name($primitive)} {
			$primitive/(@*,	$bboxAttr, *)
		}
}; 


(:
 : Calculates a bounding box for elements with x, y, width and height attributes.
 : @param $primitive
 : @return 
 :)
declare function svg:bound-xywh($primitive as element()) 
	as attribute() 
{
	attribute xr:bbox {fn:string-join($primitive/(fn:data(@y), 
			fn:string(number(@x) + number(@width)), 
					fn:string(number(@y) + number(@height)) ,fn:data(@x)), $xr:DELIMITER)}
}; 


(:
 : Calculates a bounding box for elements with vertex coordinates (points attribute).
 : @param $primitive
 : @return 
 :)
declare function svg:bound-points($primitive as element()) 
	as attribute() 
{
	let $points as xs:string* := fn:tokenize($primitive/@points, $svg:POINTS_DELIMITER)
	let $xCoords as xs:double* := for $p in $points return 
        fn:number(fn:subsequence(fn:tokenize($p, $svg:COORDS_DELIMITER), $svg:X, 1))
    let $yCoords as xs:double* := for $p in $points return 
        fn:number(fn:subsequence(fn:tokenize($p, $svg:COORDS_DELIMITER), $svg:Y, 1))
	return
	attribute xr:bbox {(fn:min($yCoords), fn:max($xCoords), fn:max($yCoords), fn:min($xCoords))}
};




(: === On Screen? =========================================================== :)

(:
 : Returns the primitive if it is within the screen's view-port.
 : @param $primitive
 : @return 
 :)
declare function svg:on-screen($primitive as element(), $viewBox as xs:string) 
	as element()? 
{
	let $viewBoxValues as xs:double* := for $n in fn:tokenize($viewBox, $xr:DELIMITER) 
		return number($n)
	let $vbTop 		as xs:double := fn:subsequence($viewBoxValues, $svg:Y, 1)
	let $vbLeft 	as xs:double := fn:subsequence($viewBoxValues, $svg:X, 1)
	let $vbRight 	as xs:double := fn:subsequence($viewBoxValues, $svg:W, 1) + $vbLeft
	let $vbBottom 	as xs:double := fn:subsequence($viewBoxValues, $svg:H, 1) + $vbTop
	
	let $boundingBoxValues as xs:double* := for $n in fn:tokenize($viewBox, $xr:DELIMITER) 
		return number($n)
	let $bbTop 		as xs:double := fn:subsequence($boundingBoxValues, $xr:TOP, 1)
	let $bbRight 	as xs:double := fn:subsequence($boundingBoxValues, $xr:RIGHT, 1)
	let $bbBottom 	as xs:double := fn:subsequence($boundingBoxValues, $xr:BOTTOM, 1)
	let $bbLeft 	as xs:double := fn:subsequence($boundingBoxValues, $xr:LEFT, 1)
	
	let $horizontalOverlap	as xs:double := ($vbRight - $bbLeft) * ($bbRight - $vbLeft)
    let $verticalOverlap	as xs:double := ($vbTop - $bbBottom) * ($bbTop - $vbBottom)
    
    return
    	if (($horizontalOverlap gt 0) and ($verticalOverlap gt 0)) then $primitive
    	else ()
}; 