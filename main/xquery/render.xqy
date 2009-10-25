xquery version "1.0" encoding "utf-8";

(:
@prefix dcterms <http:purl.org/dc/terms/>.
<> dcterms:source "$Source: $".
<> dcterms:creator "Philip A. R. Fennell".
<> dcterms:rights "Philip A. R. Fennell Copyright 2009 All Rights Reserved".
<> dcterms:hasVersion "$Revision: $".
<> dcterms:dateSubmitted "$Date: $".
<> dc:format "application/xquery".
<> dc:description "Reyes Renderer.".
:)

import module namespace tiff = "http://partners.adobe.com/public/developer/tiff/" 
	at "formats/output/tiff.xqy";
	
import module namespace svg = "http://www.w3.org/2000/svg" 
	at "formats/input/svg.xqy";

declare namespace xr = "http://code.google.com/p/x-reyes/";


(:
 : Renders the source image.
 : @return A string representation of the source image encoded as Base64.
 :)
declare function xr:render($source as document-node())
	as item()? 
{
	tiff:structure(
			svg:render($source), 
			svg:metadata(
					$source, 
					doc('../resources/options/svg-reyes.xml')
			)
	)
};


xr:render(/)
