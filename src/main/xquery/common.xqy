module namespace xr = "http://code.google.com/p/x-reyes/"; 

(:
@prefix dcterms <http:purl.org/dc/terms/>.
<> dcterms:source "$Source: $".
<> dcterms:creator "Philip A. R. Fennell".
<> dcterms:rights "Philip A. R. Fennell Copyright 2009 All Rights Reserved".
<> dcterms:hasVersion "$Revision: $".
<> dcterms:dateSubmitted "$Date: $".
<> dc:format "application/xquery".
<> dc:description "Common functions.".
:)


(:
 : Recursively apply the operation to the context item(s).
 : @param 
 : @return
 :)
declare function xr:transform($contextItems as item()*, $operation) 
	as item()*
{
	for $item in $contextItems
	return
		saxon:call($operation, $item)
};


(:
 : Identity transform.
 : @param $item The item to be copied.
 : @return The copied item.
 :)
declare function xr:identity($contextItem as item())
	as item() 
{
	typeswitch ($contextItem)
		case $contextItem as element()
		return
			element {fn:node-name($contextItem)} {
				$contextItem/@*,
				xr:transform($contextItem/(* | text()), saxon:function('xr:identity', 1))
			}
		default
		return
			$contextItem
}; 