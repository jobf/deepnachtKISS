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

	function collide_with_group(actor:Actor, group:Array<Actor>){
		for (other in enemies) {
			if(other == actor){
				continue;
			}

			// fast distance check - is other close enough to care about collision?
			var is_within_2_tiles_x = Math.abs(actor.position.grid_x - other.position.grid_x) <= 2;
			var is_within_2_tiles_y = Math.abs(actor.position.grid_y - other.position.grid_y) <= 2;
			var can_other_collide = is_within_2_tiles_x && is_within_2_tiles_y;

			if (can_other_collide) {
				var overlap = other.position.overlaps_by(actor.position);
				if (overlap > 0) {
					// repel
					var angle = Math.atan2(other.position.y - actor.position.y, other.position.x - actor.position.x);
					var force = 0.1;
					var repel_power = (actor.position.radius + other.position.radius - overlap) / (actor.position.radius + other.position.radius);
					other.position.delta_x -= Math.cos(angle) * repel_power * force;
					other.position.delta_y -= Math.sin(angle) * repel_power * force;
				}
			}
		}
	}

	public function update() {
		collide_with_group(hero, enemies);
		// resolve positions after collision to prevent repel from putting actors inside wall tiles
		hero.update();

		for (enemy in enemies) {
			collide_with_group(enemy, enemies);
			// resolve positions after collision to prevent repel from putting actors inside wall tiles
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
