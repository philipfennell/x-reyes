xquery version "1.0" encoding "utf-8";

(:
@prefix dcterms <http:purl.org/dc/terms/>.
<> dcterms:source "$Source: $".
<> dcterms:creator "Philip A. R. Fennell".
<> dcterms:rights "Philip A. R. Fennell Copyright 2009 All Rights Reserved".
<> dcterms:hasVersion "$Revision: $".
<> dcterms:dateSubmitted "$Date: $".
<> dc:format "application/xquery".
<> dc:description "SVg Metadata Test.".
:)
	
import module namespace svg = "http://www.w3.org/2000/svg" 
	at "../../main/xquery/formats/input/svg.xqy";

declare namespace xr = "http://code.google.com/p/x-reyes/";

(::)
svg:metadata(doc('../resources/test01.svg')/*, doc('../resources/options/svg-reyes.xml')/*)