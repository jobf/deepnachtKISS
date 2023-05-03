package;

import engine.*;
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
	var projectiles:Array<Projectile>;
	var projectile_count_down:Int = 0;
	var projectile_cool_off:Int = 12;
	var input:Input;

	public function new(display:Display, input:Input, view_width:Int, view_height:Int) {
		this.input = input;

		var tile_map = [
			"##############################################################################",
			"#                                                                            #",
			"#                                                                            #",
			"#                          o                                                 #",
			"#                         ###        #  #  #  #   ###                        #",
			"#                                                                            #",
			"#               ########                               ########              #",
			"#                                      v                           # v       #",
			"#                                    ##########                    #####     #",
			"#     #####           v         v    v                                       #",
			"#               ##   ###       ###                        v                  #",
			"#                 #       ###                    ###      #                  #",
			"#                  #                                                 v       #",
			"#               ######               v                              ######## #",
			"#                              ################                              #",
			"#                                                      ########              #",
			"#                v           #                     #               #         #",
			"#               #######  #                                    #    #         #",
			"#     #####                                             #          #####     #",
			"#                         ###           v        ###                         #",
			"##############################################################################",
		];

		var tile_size = 16;
		level = new Level(display, tile_map, tile_size);

		var player_count = 1;
		var projectile_count = 50;
		var enemy_count = level.enemy_positions.length;
		var buffer_size = player_count + projectile_count + enemy_count;
		buffer = new Buffer<Sprite>(buffer_size);
		program = new Program(buffer);
		program.snapToPixel(1);
		display.addProgram(program);

		enemies = [];
		for (position in level.enemy_positions) {
			var enemy_grid_x = position[0];
			var enemy_grid_y = position[1];
			var enemy_sprite = new Sprite(enemy_grid_x, enemy_grid_y, tile_size);
			enemy_sprite.color = 0x77ff92FF;
			// rotate to be more distinctive (don't rely on color)
			enemy_sprite.angle = 45;
			buffer.addElement(enemy_sprite);
			enemies.push(new Actor(enemy_sprite, enemy_grid_x, enemy_grid_y, tile_size, level.has_tile_at));
		}

		var hero_sprite = new Sprite(level.player_x, level.player_y, tile_size);
		hero_sprite.color = 0xff7788FF;
		buffer.addElement(hero_sprite);
		hero = new Actor(hero_sprite, level.player_x, level.player_y, tile_size, level.has_tile_at);

		projectiles = [
			for (n in 0...projectile_count) {
				var size = 4;
				var x = -100;
				var y = -100;

				var sprite = new Sprite(x, y, size);
				sprite.color = 0xffd677FF;
				buffer.addElement(sprite);

				var position = new DeepnightPosition(x, y, tile_size, level.has_tile_at);
				position.gravity = 0;
				position.friction_x = 0;
				position.friction_y = 0;

				new Projectile(sprite, position);
			}
		];

		camera = new Camera(display, view_width, view_height);
		camera.zoom = camera_zoom;

		input.registerController({
			left: {
				on_press: () -> hero.change_direction_x(-1),
				on_release: () -> hero.stop_x()
			},
			right: {
				on_press: () -> hero.change_direction_x(1),
				on_release: () -> hero.stop_x()
			},
			a: {
				on_press: () -> hero.jump(),
				// on_release: () -> hero.drop()
			},
		});
	}

	function collide_with_group(actor:Actor, group:Array<Actor>, is_checking_line_of_sight:Bool = false) {
		for (other in enemies) {
			if (other == actor) {
				// do not check if comparing against same object
				continue;
			}
			var x_delta = actor.position.grid_x - other.position.grid_x;
			var x_grid_distance = Math.abs(x_delta);
			var y_delta = actor.position.grid_y - other.position.grid_y;
			var y_grid_distance = Math.abs(y_delta);

			// fast distance check - is other close enough to collide?
			final collision_grid_limit = 2;
			var do_collision_check = x_grid_distance <= collision_grid_limit && y_grid_distance <= collision_grid_limit;

			if (do_collision_check) {
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

			if (is_checking_line_of_sight) {
				// reset line of sight state
				other.sprite.color.a = 0xff;

				// fast distance check - is distance close enough to be seen?
				final sight_grid_limit = 5;
				var do_line_of_sight_check = x_grid_distance <= sight_grid_limit && y_grid_distance <= sight_grid_limit;

				if (do_line_of_sight_check) {
					var is_actor_in_sight = !Bresenham.is_line_blocked(actor.position.grid_x, actor.position.grid_y, other.position.grid_x,
						other.position.grid_y, level.has_tile_at);
					if (is_actor_in_sight) {
						other.sprite.color.a = 0x70;
						if (projectile_count_down <= 0) {
							// if only one enemy should shoot we could reset projectile_count_down here
							// projectile_count_down = projectile_cool_off;
							var projectile = get_projectile();
							if (projectile != null) {
								var x = other.position.grid_x;
								var y = other.position.grid_y;
								var angle = Math.atan2(actor.position.y - other.position.y, actor.position.x - other.position.x);
								var delta_x = Math.cos(angle);
								var delta_y = Math.sin(angle);
								var acceleration_x = delta_x * 0.05;
								var acceleration_y = delta_y * 0.05;
								projectile.fire(x, y, acceleration_x, acceleration_y);
							}
						}
					}
				}
			}
		}
	}

	function get_projectile():Null<Projectile> {
		for (projectile in projectiles) {
			if (projectile.is_active) {
				continue;
			}
			return projectile;
		}
		trace('out of projectiles');
		return null;
	}

	public function update() {
		projectile_count_down--;

		for (projectile in projectiles) {
			if (projectile.is_active) {
				projectile.update();
				var greater_than_top_left = projectile.position.grid_x > 0 && projectile.position.grid_y > 0;
				var less_than_bottom_right = projectile.position.grid_x < level.width_tiles
					&& projectile.position.grid_y < level.height_pixels;
				var is_out_of_bounds = !greater_than_top_left || !less_than_bottom_right;
				var is_stopped = projectile.position.delta_x + projectile.position.delta_x == 0;
				if (is_stopped || is_out_of_bounds) {
					projectile.is_active = false;
					projectile.sprite.color.a = 0;
				}
			}
		}

		final is_checking_line_of_sight:Bool = true;
		collide_with_group(hero, enemies, is_checking_line_of_sight);
		// resolve positions after collision to prevent repel from putting actors inside wall tiles
		hero.update();

		for (enemy in enemies) {
			collide_with_group(enemy, enemies);
			// resolve positions after collision to prevent repel from putting actors inside wall tiles
			enemy.update();
		}

		// reset projectile_count_down off after all the updates (this allows all enemies to shoot)
		if (projectile_count_down < 0) {
			projectile_count_down = projectile_cool_off;
		}

		var scroll_bounds_x = level.width_pixels;
		var scroll_bounds_y = level.height_pixels;
		camera.center_on_target(hero.position.x, hero.position.y, scroll_bounds_x, scroll_bounds_y);
	}

	public function on_key_down(key:KeyCode) {
		switch key {

			case NUMBER_1:
				var projectile = get_projectile();
				if (projectile != null) {
					var x = hero.position.grid_x;
					var y = hero.position.grid_y;
					var acceleration_x = 0.2 * hero.facing;
					var acceleration_y = 0.0;
					projectile.fire(x, y, acceleration_x, acceleration_y);
				}
			// camera.zoom = 1;
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

	public function draw() {
		buffer.update();
	}
}
