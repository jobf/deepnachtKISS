package engine.graphics.elements;

import peote.view.Element;
import peote.view.Color;

class Basic implements Element {
	
	/** Position of the element on x axis. Relative to top left of Display.**/
	@posX public var x:Float;

	/** Position of the element on y axis. Relative to top left of Display.**/
	@posY public var y:Float;

	/** Size of the element on x axis. **/
	@sizeX public var width:Int;

	/** Size of the element on y axis. **/
	@sizeY public var height:Int;

	/** The pivot point around with the element will rotate on the x axis - 0.5 is the center. **/	
	@pivotX @formula("width * pivot_x") public var pivot_x:Float = 0.5;

	/** The pivot point around with the element will rotate on the y axis - 0.5 is the center. **/	
	@pivotY @formula("height * pivot_y") public var pivot_y:Float = 0.5;

	/** Degrees of rotation. **/
	@rotation public var angle:Float = 0.0;

	/** Tint the element with RGBA color. **/
	@color public var tint:Color = 0xf0f0f0ff;

	/** Auto-enable blend in the Program the element is rendered by (for alpha and more) **/
	var OPTIONS = {blend: true};

	/** 
		@param x the starting x position in the Display.
		@param y the starting x position in the Display.
		@param size the starting width and height.
		@param height (optional) the starting height, in case it is different to the width.
	**/
	public function new(x:Float, y:Float, size:Float, height:Null<Float> = null) {
		this.x = Std.int(x);
		this.y = Std.int(y);
		width = Std.int(size);
		this.height = Std.int(height ?? size);
	}
}
