package engine;

import peote.view.Element;
import peote.view.Color;

class Sprite implements Element {
	// position in pixel  (relative to upper left corner of Display)
	@posX public var x:Int;
	@posY public var y:Int;

	// offset center position
	@pivotX @formula("w * 0.5 + px_offset") public var px_offset:Float;
	@pivotY @formula("h * 0.5 + py_offset") public var py_offset:Float;

	// size in pixel
	@sizeX public var w:Int;
	@sizeY public var h:Int;

	// color (RGBA)
	@color public var c:Color = 0xf0f0f0ff;
	
	var OPTIONS = {alpha: true};

	public function new(x:Int, y:Int, size:Int) {
		this.x = x;
		this.y = y;
		this.w = size;
		this.h = size;
	}
}
