xquery version "1.0" encoding "utf-8";

import module namespace xr = "http://code.google.com/p/x-reyes/" 
	at "../../main/xquery/common.xqy";
	
import module namespace svg = "http://www.w3.org/2000/svg" 
	at "../../main/xquery/formats/input/svg.xqy";
	
declare default element namespace "http://www.w3.org/2000/svg";

let $primitives as element()* := 
	(
	<rect id="N01" x="-20" y="0" width="10" height="10" xr:bbox="0 -10 10 -20"/>,
	<rect id="N02" x="0" y="-20" width="10" height="10" xr:bbox="-20 10 -10 0"/>,
	<rect id="N03" x="20" y="0" width="10" height="10" xr:bbox="0 30 10 20"/>,
	<rect id="N04" x="0" y="20" width="10" height="10" xr:bbox="20 10 30 0"/>,
	<rect id="N05" x="0" y="0" width="10" height="10" xr:bbox="0 10 10 0"/>
	)
return
	xr:transform($primitives, saxon:function('svg:on-screen', 2), '0 0 16 16')