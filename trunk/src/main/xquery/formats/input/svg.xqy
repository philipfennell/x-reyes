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
	attribute xr:bbox {fn:string-join(($primitive/@x, $primitive/@y, $primitive/@width, $primitive/@height), ', ')}
}; 