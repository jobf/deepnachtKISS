package engine.graphics.elements;

import peote.view.Element;
import peote.view.Color;

class Tile implements Element {

	/** Position of the element on x axis. Relative to top left of Display.**/
	@posX public var x:Float;

	/** Position of the element on y axis. Relative to top left of Display.**/
	@posY public var y:Float;

	/** Size of the element on x axis. **/
	@sizeX public var width:Int;

	/** Size of the element on y axis. **/
	@sizeY public var height:Int;

	/** Tint the element with RGBA color. **/
	@color public var tint:Color = 0xffffffFF;
	
	/** Index of tile in texture. Tiles are arranged left to right, row by row. **/
	@texTile public var tile_index:Int;

	/** Auto-enable blend in the Program the element is rendered by (for alpha and more) **/
	var OPTIONS = {blend: true};

	/**
		@param x the starting x position in the Display.
		@param y the starting x position in the Display.
		@param size the starting width and height.
		@param index the starting tile index.
		@param height (optional) the starting height, in case it is different to the width.
	**/
	public function new(x:Float, y:Float, size:Float, index:Int, height:Null<Int>=null) {
		this.x = Std.int(x);
		this.y = Std.int(y);
		width = Std.int(size);
		this.height = height ?? width;
		tile_index = index;
	}
}
