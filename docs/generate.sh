haxe docs.hxml

haxelib run dox \
	--input-path api/doc.xml \
	--output-path html \
	--toplevel-package engine \
	--keep-field-order \
	-D source-path https://github.com/jobf/deepnachtKISS/blob/master/src/ 

rm api/doc.xml
