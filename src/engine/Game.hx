package engine;

import lime.ui.KeyCode;
import peote.view.Display;
import peote.view.Program;
import peote.view.Buffer;

class Game {
	var buffer:Buffer<Sprite>;
	var program:Program;
	var actor:Actor;

	public function new(display:Display) {


		var tile_map = [
			"##########################################",
			"#             #                          #",
			"#             #       o     #        #####",
			"#    #              ####   #             #",
			"#           ##             ###           #",
			"#                 #               #      #",
			"#  #           ####               #      #",
			"#      ###        #               #      #",
			"#                         #              #",
			"#                         #         #    #",
			"##########################################",
		];

		var tile_size = 16;
		var level = new Level(display, tile_map, tile_size);

		buffer = new Buffer<Sprite>(1);
		program = new Program(buffer);
		program.snapToPixel(1);
		display.addProgram(program);
		var sprite = new Sprite(tile_size);
		buffer.addElement(sprite);

		actor = new Actor(sprite, level.player_x, level.player_y, tile_size, level.has_tile_at);
	}

	public function update() {
		actor.update();
	}

	public function on_key_down(key:KeyCode) {
		switch key {
			case A: actor.change_direction_x(-1);
			case LEFT: actor.change_direction_x(-1);

			case D: actor.change_direction_x(1);
			case RIGHT: actor.change_direction_x(1);
			
			case W: actor.jump();
			case UP: actor.jump();

			case _:
		}
	}

	public function on_key_up(key:KeyCode) {
		switch key {
			case A: actor.stop_x();
			case LEFT: actor.stop_x();

			case D: actor.stop_x();
			case RIGHT: actor.stop_x();
			
			case _:
		}
	}

	public function draw() {
		buffer.update();
	}
}
