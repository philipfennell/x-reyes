xquery version "1.0" encoding "utf-8";

import module namespace tiff = "http://partners.adobe.com/public/developer/tiff/" at "../../main/xquery/formats/output/tiff.xqy"; 

tiff:integer2octets(4294967295, $tiff:bytes-4) = (255, 255, 255, 255)