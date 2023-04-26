package engine;

import peote.view.Display;
import peote.view.Program;
import peote.view.Buffer;

class Level {
	var tile_map:Array<String>;

	public var player_x(default, null):Int;
	public var player_y(default, null):Int;
	public var width(get, never):Int;
	public var height(get, never):Int;
	var tile_size:Int;

	public function new(display:Display, tile_map:Array<String>, tile_size:Int) {
		this.tile_map = tile_map;
		this.tile_size = tile_size;
		var tile_count = tile_map.length * tile_map[0].length;

		var buffer = new Buffer<Sprite>(tile_count, true);
		var program = new Program(buffer);
		display.addProgram(program);

		for (y => row in tile_map) {
			for (x in 0...row.length) {
				if (is_wall_tile(row, x)) {
					var sprite = new Sprite(tile_size);
					sprite.w = tile_size;
					sprite.h = tile_size;
					sprite.x = x * tile_size;
					sprite.y = y * tile_size;
					sprite.px_offset = -(tile_size / 2);
					sprite.py_offset = -(tile_size / 2);
					buffer.addElement(sprite);
				} else if (is_player_tile(row, x)) {
					player_x = x;
					player_y = y;
				}
			}
		}
	}

	public function has_tile_at(grid_x:Int, grid_y:Int):Bool {
		if (grid_y > tile_map.length || grid_y < 0) {
			return false;
		}
		if (grid_x > tile_map[0].length || grid_x < 0) {
			return false;
		}

		var row = tile_map[grid_y];
		return is_wall_tile(row, grid_x);
	}

	inline function is_wall_tile(row:String, x:Int):Bool {
		return row.charAt(x) == "#";
	}

	inline function is_player_tile(row:String, x:Int):Bool {
		return row.charAt(x) == "o";
	}

	function get_width():Int {
		return tile_size + tile_map[0].length * tile_size;
	}

	function get_height():Int {
		return tile_map.length * tile_size;
	}
}
