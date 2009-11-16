xquery version "1.0" encoding "utf-8";

import module namespace xr = "http://code.google.com/p/x-reyes/" 
	at "../../main/xquery/common.xqy";
	
import module namespace svg = "http://www.w3.org/2000/svg" 
	at "../../main/xquery/formats/input/svg.xqy";
	
declare default element namespace "http://www.w3.org/2000/svg";

let $primitives as element()* := 
	(
	<rect id="N01" height="64" color="rgb(128,192,255)" fill="currentColor"
	      	width="80" y="0" x="0" xr:bbox="0 80 64 0"/>,
	<rect id="N02" height="48" color="rgb(255,192,128)" fill="currentColor"
			width="64" y="8" x="8" xr:bbox="8 72 56 8"/>,
	<polygon id="N03" color="rgb(128,192,255)" fill="currentColor" 
			points="0,0 0,10 10,10 10,0" xr:bbox="0 10 10 0"/>
	)
return
	xr:transform($primitives, saxon:function('svg:on-screen', 2), '0 0 80 64')