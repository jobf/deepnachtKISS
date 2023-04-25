package engine;

import lime.ui.KeyCode;
import peote.view.Display;
import peote.view.Program;
import peote.view.Buffer;

class Game {
	var buffer:Buffer<Sprite>;
	var program:Program;
	var actor:Actor;
	var camera:Camera;

	public function new(display:Display, view_width:Int, view_height:Int) {


		var tile_map = [
			"##################################################################################",
			"#                                 #                                              #",
			"#                 #        ####   #            #        ####      #          #####",
			"#    #     ###   #                      ####   #             ###   #             #",
			"#                ###            ##             ###                 ###           #",
			"#                       #             #               #                   #      #",
			"#  #    o               #          ####               #                   #      #",
			"#      ###              #             #               #                   #      #",
			"#               #                             #                   #              #",
			"#               #         #                   #         #         #         #    #",
			"##################################################################################",
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

		camera = new Camera(display, view_width, view_height);
		camera.zoom = 2;
	}

	public function update() {
		actor.update();
		camera.center_on_target(actor.position.xx, actor.position.yy);
	}

	public function on_key_down(key:KeyCode) {
		switch key {
			case A: actor.change_direction_x(-1);
			case LEFT: actor.change_direction_x(-1);

			case D: actor.change_direction_x(1);
			case RIGHT: actor.change_direction_x(1);
			
			case W: actor.jump();
			case UP: actor.jump();

			case NUMBER_1: camera.zoom = 1;
			case NUMBER_2: camera.zoom = 2;
			case NUMBER_3: camera.zoom = 4;
			case NUMBER_4: camera.zoom = 8;
			case NUMBER_5: camera.zoom = 16;

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
