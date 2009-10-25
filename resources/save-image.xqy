xquery version "1.0-ml";

declare function local:process-img($i as node(), $uri as xs:string) as node()* {
	for $img in $i//w:binData
	let $img-name := fn:substring-after($img/@w:name, "//")
	let $log := xdmp:log(fn:concat("image name: ", $img-name))
	let $uri :=
		if (fn:ends-with($uri, ".xml")) then
			fn:substring($uri, 1, fn:string-length($uri) - 4)
		else
			$uri
	let $img-uri  := fn:concat("/images" , $uri, "/", $img-name)
	let $save-image :=
		if (fn:contains($img-uri, ".wmz")) then xdmp:log("wmz")
		else if (fn:contains($img-uri, ".emz")) then xdmp:log("emz")
		else
			let $binData := 
				try
				{
					let $bin := binary{xs:hexBinary(xs:base64Binary($img))}
					let $log := xdmp:log(fn:concat("converted original image ", $img-uri))
					return $bin
				}
				catch ($e)
				{
					(: local:fix-image($img, $img-uri, (-1,1,-2,2,-3,3,-4,4,-5,5,-6,6,-7,7)) :)
					let $img2 := local:fix-base64($img, -1)
					return
						try
						{
							let $bin := binary{xs:hexBinary(xs:base64Binary($img2))}
							let $log := xdmp:log(fn:concat("converted with offset -1, image ", $img-uri))
							return $bin
						}
						catch ($e)
						{
							let $img3 := local:fix-base64($img, -4)
							return
								try
								{
									let $bin := binary{xs:hexBinary(xs:base64Binary($img3))}
									let $log := xdmp:log(fn:concat("converted with offset -4, image ", $img-uri))
									return $bin
								}
								catch ($e)
								{
									let $img4 := local:fix-base64($img, -7)
									return
										try
										{
											let $bin := binary{xs:hexBinary(xs:base64Binary($img4))}
											let $log := xdmp:log(fn:concat("converted with offset -7, image ", $img-uri))
											return $bin
										}
										catch ($e)
										{
											let $img5 := local:fix-base64($img, -3)
											return
												try
												{
													let $bin := binary{xs:hexBinary(xs:base64Binary($img5))}
													let $log := xdmp:log(fn:concat("converted with offset -3, image ", $img-uri))
													return $bin
												}
												catch ($e)
												{

													let $log := xdmp:log(fn:concat("Invalid image ", $img-uri))
													return ()
												}
										}
								}
						}
				}
			return
				if (fn:not(fn:empty($binData))) then
					let $log := xdmp:log(fn:concat("Saving image ", $img-uri))
					return (xdmp:document-insert($img-uri, $binData))
				else
					()
	return
			element img {attribute src {fn:concat("get-file.xqy?uri=", $img-uri)}} };

