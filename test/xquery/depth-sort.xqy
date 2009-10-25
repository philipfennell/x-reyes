xquery version "1.0" encoding "utf-8";

import module namespace svg = "http://www.w3.org/2000/svg" 
	at "../../main/xquery/formats/input/svg.xqy";

let $primitives as element()* := 
	(
	<rect height="64" color="rgb(128,192,255)"
	      fill="currentColor"
	      width="80"
	      y="0"
	      x="0"
	      id="N3"/>,
	<rect height="48" color="rgb(255,192,128)"
	      fill="currentColor"
	      width="64"
	      y="8"
	      x="8"
	      id="N4"/>,
	<g id="N5">
	   <polyline id="N6">
	      <metadata>
	         <foo>boo hoo</foo>
	      </metadata>
	   </polyline>
	</g>,
	<rect id="N7"/>
	)
return
	svg:depth-sort($primitives)