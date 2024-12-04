import peote.view.text.TextOptions;
import engine.graphics.elements.Basic;
import peote.view.text.TextProgram;
import peote.view.text.Text;
import haxe.Timer;
import peote.view.*;
import engine.body.physics.Physics;
import engine.body.Body;
import engine.body.skin.SkinBasic;

class Demo {
	public function new(display:Display) {
		var ship_sprites = SpaceCraft.init(display);
		
		

		
		var formation = [
			"   oooo   ",
			" oooooooo ",
			" oooooooo ",
			"oooooooooo",
			"oooooooooo",
		];

		
		var size = 48;
		var ctr = size * 0.5;
		
		var gap = 12;
		var space = size + gap;
		var edge = size * 1.5;

		var line_width = (space * formation[0].length);
		var x_display = display.width * 0.5;
		var y_display = display.height * 0.5;
		var x_ctr = x_display - (line_width * 0.5) + ctr;
		var y_ctr = y_display - (line_width * 0.5) + ctr + edge;


		var targets = [];
		for (row => line in formation) {
			for (col in 0...line.length) {
				if(line.charAt(col) != ' '){
					var x = (col * space) + x_ctr;
					var y = (row * space) + y_ctr;
					
					var skin = new SkinBasic(x, y, size);
					skin.add_to_buffer(ship_sprites);

					var moves = new PhysicsGalaga(x, y, size);
					
					targets.push(new SpaceCraft(skin, moves));
				}
			}
		}


		
		var x = x_display;
		var y = display.height - edge;
		
		var skin = new SkinBasic(x, y, size);
		skin.add_to_buffer(ship_sprites);

		var moves = new PhysicsGalaga(x, y, size);
		
		var hero = new SpaceCraft(skin, moves);

		var hud = new Hud(display, 32);
	}
}

class PhysicsGalaga extends Physics {

	public function new(x:Float, y:Float, size:Int)
	{
		super(0,0,size, (grid_x, grid_y) -> false);
	}

	public function update() {

	}
}

class SpaceCraft extends Body<SkinBasic, PhysicsGalaga> {
	function on_collide(side_x:Int, side_y:Int) {}

	static function init(display:Display){
		var buffer = new Buffer<Basic>(64);
		var program = new Program(buffer);
		program.addToDisplay(display);
		return buffer;
	}
}

class Hud
{
	var texts:TextProgram;
	var labels:Array<Text>;

	public function new(display:Display, letterSize:Int){
		
		var options:TextOptions = {
			letterWidth: letterSize,
			letterHeight: letterSize,
		};

		texts = new TextProgram(options);
		texts.addToDisplay(display);
		
		var infos = [
			"000000000",
			" Top:",
			"000000000",
		];
	
		var x = 0;
		labels = [for (s in infos) {
			var t = new Text(x, 0, s);
			texts.add(t);
			x += (s.length * letterSize) + letterSize;
			t;
		}];
	}
}