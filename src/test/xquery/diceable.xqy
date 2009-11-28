xquery version "1.0" encoding "utf-8";

import module namespace xr = "http://code.google.com/p/x-reyes/" 
	at "../../main/xquery/common.xqy";
	
import module namespace svg = "http://www.w3.org/2000/svg" 
	at "../../main/xquery/formats/input/svg.xqy";
	
declare default element namespace "http://www.w3.org/2000/svg";

let $bucketOption := <bucket xmlns="http://code.google.com/p/xq-reyes/" size="16"/>
let $primitives as element()* := 
	<rect id="N01" height="64" color="rgb(128,192,255)" fill="currentColor"
			width="80" y="0" x="0" xr:bbox="0 80 64 0"/>
return
	xr:transform($primitives, saxon:function('svg:dice', 2), xs:integer($bucketOption/@size))
	