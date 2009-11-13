xquery version "1.0" encoding "utf-8";

import module namespace tiff = "http://partners.adobe.com/public/developer/tiff/"
		at "../../main/xquery/formats/output/tiff.xqy";

declare namespace saxon="http://saxon.sf.net/";
declare namespace xr = "http://code.google.com/p/x-reyes/";

declare option saxon:output "omit-xml-declaration=yes";

declare variable $xr:structure as element() := 
<image xmlns="http://partners.adobe.com/public/developer/tiff/">
	<header>
		<byte-order value="73 73"/>
		<identifier value="42 0"/>
		<directory-offset value="8 3 0 0"/>
	</header>
	<data>128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255 128 192 255</data>
	<directory>
		<field count="1" tag="256" value="16" type="4"/>
		<field count="1" tag="257" value="16" type="4"/>
		<field count="3" tag="258" value="8 8 8" type="3"/>
		<field count="1" tag="259" value="1" type="3"/>
		<field count="1" tag="262" value="2" type="3"/>
		<!-- <field tag="{$tiff:StripOffsets}" type="{$tiff:Type_LONG}" count="{tiff:stripsPerImage()}" value="{tiff:stripOffsets()}"/> --><field count="1" tag="277" value="3" type="3"/>
		<!-- <field tag="{$tiff:RowsPerStrip}" type="{$tiff:Type_LONG}" count="1" value="{tiff:rowsPerStrip()}"/> --><!-- <field tag="{$tiff:StripByteCounts}" type="{$tiff:Type_LONG}" count="{tiff:stripsPerImage()}" value="{tiff:stripByteCounts()}"/> --><field count="1" tag="282" value="72" type="5"/>
		<field count="1" tag="283" value="72" type="5"/>
		<field count="1" tag="284" value="1" type="3"/>
		<field count="1" tag="296" value="2" type="3"/>
		<field count="1" tag="322" value="16" type="3"/>
		<field count="1" tag="323" value="16" type="3"/>
		<field count="1" tag="324" value="8" type="4"/>
		<field count="1" tag="325" value="768" type="4"/>
		<directory-offset/>
	</directory>
	<field-values/>
</image>;

tiff:base64encode(tiff:serialise($xr:structure))
