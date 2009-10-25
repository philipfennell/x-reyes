xquery version "1.0" encoding "utf-8";

import module namespace xr = "http://code.google.com/p/x-reyes/" 
	at "../../main/xquery/common.xqy";

import module namespace svg = "http://www.w3.org/2000/svg" 
	at "../../main/xquery/formats/input/svg.xqy";

let $model as element() := 
	<svg xmlns="http://www.w3.org/2000/svg" width="80" height="64" viewBox="0 0 80 64">
		<title>Simple test image.</title>
		<rect x="0" y="0" width="80" height="64" fill="currentColor" color="rgb(128,192,255)"/>
		<rect x="8" y="8" width="64" height="48" fill="currentColor" color="rgb(255,192,128)"/>
		<g>
			<polyline>
				<metadata>
					<foo>boo hoo</foo>
				</metadata>
			</polyline>
		</g>
	</svg>
return
	xr:transform($model/svg:* except $model/(svg:title, svg:description, svg:def, svg:script, svg:style, svg:metadata),
			saxon:function('svg:read', 1))