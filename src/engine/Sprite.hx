package engine;

import peote.view.Element;
import peote.view.Color;

class Sprite implements Element {
	// position in pixel  (relative to upper left corner of Display)
	@posX public var x:Int = 0;
	@posY public var y:Int = 0;

	// offset center position
	@pivotX @formula("w * 0.5 + px_offset") public var px_offset:Float;
	@pivotY @formula("h * 0.5 + py_offset") public var py_offset:Float;

	// size in pixel
	@sizeX public var w:Int;
	@sizeY public var h:Int;

	// color (RGBA)
	@color public var c:Color = 0xffffff90;

	public function new(size:Int) {
		this.w = size;
		this.h = size;
	}
}
