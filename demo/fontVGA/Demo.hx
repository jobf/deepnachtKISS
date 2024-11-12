import haxe.Timer;
import engine.FontVGA;
import engine.graphics.Tile;
import peote.view.*;

class Demo {
	public function new(display:Display) {

		var buffer = new Buffer<Tile>(1024);
		var program = new Program(buffer);
		display.addProgram(program);
		// add the texture generated from VGA bits
		program.addTexture(new FontVGA());

		/// write a line of characters ...
		//////////////////////////////////

		var message = "hello world HALLO WELT";
		var size = 24;

		for (c in 0...message.length) {
			var x = c * size;
			var y = 0;
			var tile_index = message.charCodeAt(c);
			var glyph = new Tile(x, y, size, tile_index);
			glyph.tint = Color.LIME;
			buffer.addElement(glyph);
		}

		/// make a grid of characters and animate them
		//////////////////////////////////////////////

		// dimensions for the grid
		var columns = 25;
		var rows = 25;
		var x = 62;
		var y = 40;
		var size = 16;
		
		// initial ascii character code
		var char_code = "!".charCodeAt(0);

		var glyphs:Array<Tile> = [
			for (index in 0...columns * rows) {
				var c = index % columns;
				var r = Std.int(index / columns);
				buffer.addElement(new Tile(x + (c * size), y + (r * size), size, char_code));
			}
		];

		// timer to increment character every 2 milliseconds
		var index = 0;
		new Timer(2).run = () -> {
			var glyph = glyphs[index];

			// increment char code
			glyph.tile_index = (glyph.tile_index + 1) % 128;

			// increment element index (wrapped to max index)
			index = (index + 1) % glyphs.length;
		}

		// timer to set a random tint in increasingly longer sections
		var index = 0;
		var section_length = 1;
		new Timer(2 * columns).run = () -> {
			// random tint (clamped to keep it visible against black display)
			var tint = Color.random() | 0x202020FF;

			for (i in index...index + section_length) {
				// keep element index within max range
				var n = i % glyphs.length;

				// set the tint
				glyphs[n].tint = tint;

				// increment element index (wrapped to max index)
				index = (index + 1) % glyphs.length;
			}

			// increment the section length (wrapped to max index)
			section_length = (section_length + 1) % glyphs.length;

			buffer.update();
		}
	}
}
