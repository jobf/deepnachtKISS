package engine.graphics.elements;

import peote.view.Element;
import peote.view.Color;

class Basic implements Element {
	// position in pixel
	@posX public var x:Float;
	@posY public var y:Float;

	// size in pixel
	@sizeX public var width:Int;
	@sizeY public var height:Int;

	// offset pivot (e.g. 0.5 is center)
	@pivotX @formula("width * pivot_x") public var pivot_x:Float = 0.5;
	@pivotY @formula("height * pivot_y") public var pivot_y:Float = 0.5;

	// degrees of rotation
	@rotation public var angle:Float = 0.0;

	// tint (RGBA)
	@color public var tint:Color = 0xf0f0f0ff;
	
	// auto-enable blend (for alpha and more)
	var OPTIONS = {blend: true};

	public function new(x:Float, y:Float, size:Float) {
		this.x = Std.int(x);
		this.y = Std.int(y);
		width = Std.int(size);
		height = Std.int(size);
	}
}
