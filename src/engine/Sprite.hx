package engine;

import peote.view.Element;
import peote.view.Color;

class Sprite implements Element {
	// position in pixel  (relative to upper left corner of Display)
	@posX public var x:Int;
	@posY public var y:Int;

	// offset center position
	@pivotX @formula("width * 0.5 + px_offset") public var px_offset:Float = 0.0;
	@pivotY @formula("height * 0.5 + py_offset") public var py_offset:Float = 0.0;

	// size of graphic element is 1 pixel
	@sizeX @formula("size_x * width") public var size_x:Int = 1;
	@sizeY @formula("size_y * height") public var size_y:Int = 1;
	
	@custom public var width:Float;
	@custom public var height:Float;

	@rotation public var angle:Float = 0.0;

	// color (RGBA)
	@color public var color:Color = 0xf0f0f0ff;
	
	var OPTIONS = {alpha: true};

	public function new(x:Int, y:Int, size:Int) {
		this.x = x;
		this.y = y;
		width = size;
		height = size;
	}
}
