xquery version "1.0" encoding "utf-8";

import module namespace xr = "http://code.google.com/p/x-reyes/" 
	at "../../main/xquery/common.xqy";
	
import module namespace svg = "http://www.w3.org/2000/svg" 
	at "../../main/xquery/formats/input/svg.xqy";

let $primitives as element()* := 
	(
	<rect id="N01" x="0" y="0" width="80" height="64" fill="currentColor" color="rgb(128,192,255)"/>,
	<rect id="N02" x="8" y="8" width="64" height="48" fill="currentColor" color="rgb(255,192,128)"/>
	)
return
	xr:transform($primitives, saxon:function('svg:bound', 1))