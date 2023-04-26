package engine;

import lime.ui.KeyCode;
import peote.view.Display;
import peote.view.Program;
import peote.view.Buffer;

class Game {
	var buffer:Buffer<Sprite>;
	var program:Program;
	var hero:Actor;
	var enemies:Array<Actor>;
	var camera:Camera;
	var level:Level;
	var camera_zoom = 3;

	public function new(display:Display, view_width:Int, view_height:Int) {
		var tile_map = [
			"##################################################################################",
			"#                       v         #                                              #",
			"#      ###              #             #               #                   #      #",
			"#               #                                   ####          #              #",
			"#    o      v     #        ####   #            #        ####      ################",
			"#    #   ####   #                      ####    #             ###   #             #",
			"#                ###            ##      ##########                 ###           #",
			"#      ###      v       #             #               #                   #      #",
			"#        ########               ###############       v           #              #",
			"#                                     #               #            ########      #",
			"#####                    ###############              #                   #      #",
			"#                    ####             #               #    v              #      #",
			"#  #  v                 #          ####               ##############      ########",
			"#  #######              #             #               #                   #      #",
			"#                                             #                         ###      #",
			"#    #     ###                  v       ####   #             #######             #",
			"#                ###            ##             ###                 ###           #",
			"#        v       v      ###############               #                   #      #",
			"##################################################################################",
		];

		var tile_size = 16;
		level = new Level(display, tile_map, tile_size);

		var buffer_size = 1 + level.enemy_positions.length;
		buffer = new Buffer<Sprite>(buffer_size);
		program = new Program(buffer);
		program.snapToPixel(1);
		display.addProgram(program);

		enemies = [];
		for (position in level.enemy_positions) {
			var enemy_grid_x = position[0];
			var enemy_grid_y = position[1];
			var enemy_sprite = new Sprite(tile_size);
			enemy_sprite.c = 0x77ff92FF;
			buffer.addElement(enemy_sprite);
			enemies.push(new Actor(enemy_sprite, enemy_grid_x, enemy_grid_y, tile_size, level.has_tile_at));
		}

		var hero_sprite = new Sprite(tile_size);
		hero_sprite.c = 0xff7788FF;
		buffer.addElement(hero_sprite);
		hero = new Actor(hero_sprite, level.player_x, level.player_y, tile_size, level.has_tile_at);

		camera = new Camera(display, view_width, view_height);
		camera.zoom = camera_zoom;
	}

	public function update() {
		hero.update();
		for (enemy in enemies) {
			// reset collided state
			enemy.sprite.c.a = 0xff;

			// fast distance check - is enemy close enough to care about collision?
			var can_enemy_collide = Math.abs(hero.position.grid_x - enemy.position.grid_x) <= 2
				&& Math.abs(hero.position.grid_y - enemy.position.grid_y) <= 2;
			if (can_enemy_collide) {
				var overlap = enemy.position.overlaps_by(hero.position);
				if (overlap > 0) {
					enemy.sprite.c.a = 0x80;
				}
			}

			// resolve positions after collisions because after a repel you want to make sure is no level tile collision
			enemy.update();
		}
		var scroll_bounds_x = level.width;
		var scroll_bounds_y = level.height;
		camera.center_on_target(hero.position.x, hero.position.y, scroll_bounds_x, scroll_bounds_y);
	}

	public function on_key_down(key:KeyCode) {
		switch key {
			case A:
				hero.change_direction_x(-1);
			case LEFT:
				hero.change_direction_x(-1);

			case D:
				hero.change_direction_x(1);
			case RIGHT:
				hero.change_direction_x(1);

			case W:
				hero.jump();
			case UP:
				hero.jump();

			case NUMBER_1:
				camera.zoom = 1;
			case NUMBER_2:
				camera.zoom = 2;
			case NUMBER_3:
				camera.zoom = 4;
			case NUMBER_4:
				camera.zoom = 8;
			case NUMBER_5:
				camera.zoom = 16;
			case NUMBER_0:
				camera.zoom = camera_zoom;

			case _:
		}
	}

	public function on_key_up(key:KeyCode) {
		switch key {
			case A:
				hero.stop_x();
			case LEFT:
				hero.stop_x();

			case D:
				hero.stop_x();
			case RIGHT:
				hero.stop_x();

			case _:
		}
	}

	public function draw() {
		buffer.update();
	}
}
