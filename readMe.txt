Project X-Reyes: Read Me
========================


Command line
------------


Windows:

java -jar c:\Projects\Saxon\saxon8.jar -t Source\test01.svg Transforms\render.xsl >Output\test01.txt
java -jar c:\Projects\Saxon\saxon8.jar -t src\test01.svg transforms\pipelines\svg-reyes.xslt >output\reyes.xml localOptions=../../options/reyes.xml
java -jar c:\Projects\Saxon8.7\saxon8.jar -t -im smil -o output/animApp.svg src\animate.svg transforms\pipelines\svg-smil.xslt


Unix:

java -jar ../Saxon8/saxon8.jar -t -im tiff -o output/test01.mm src/test01.svg transforms/render.xsl
java -jar ../Saxon8/saxon8.jar -im bound -t -o output/bound.svg src/test01.svg transforms/bound.xsl
java -jar ../Saxon8/saxon8.jar -t -o output/reyes.xml src/test01.svg transforms/pipelines/svg-reyes.xslt

java -jar ../saxon8.7.1/saxon8.jar -t -im smil -o app/inBetween.svg src/animate.svg transforms/pipelines/svg-smil.xslt
