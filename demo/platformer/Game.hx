import engine.*;
import engine.Camera.ScrollConfig;
import engine.graphics.Basic;
import lime.ui.KeyCode;
import peote.view.*;

class Game {
	var tile_size:Int;
	var level:Level;

	var hero:Actor;
	var enemies:Array<Actor>;

	var projectile_cache:ObjectCache<Projectile>;
	var projectile_count_down:Int = 0;
	var projectile_cool_off:Int = 12;

	var buffer:Buffer<Basic>;
	var program:Program;

	var camera:Camera;
	var camera_zoom = 3;
	var input:Input;
	var loop:Loop;
	var frame_ratio:Float;

	public function new(display:Display, input:Input, view_width:Int, view_height:Int) {
		this.input = input;

		var tile_map = [
			"##############################################################################",
			"#                                                                            #",
			"#                                                                            #",
			"#                                                                            #",
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
			"#                                                       #          ###       #",
			"##                        ###  o        v        ###                        ##",
			"#          ########################################################          #",
			"#          #                                                      #          #",
			"##        ##                                                      ##        ##",
			"#          #                                                      #          #",
			"#          #                                                      #          #",
			"#          #                                                      #          #",
			"#          #                                                      #          #",
			"##        ##                                                      ##        ##",
			"#          #                                                      #          #",
			"#          #                                                      #          #",
			"#          #                                                      #          #",
			"#          #                                                      #          #",
			"##        ##                                                      ##        ##",
			"#          #                                                      #          #",
			"#          #                                                      #          #",
			"#          #                                                      #          #",
			"#          #                                                      #          #",
			"##        ##                                                      ##        ##",
			"#          #                                                      #          #",
			"#          #                                                      #          #",
			"#          #                                                      #          #",
			"#          #                                                      #          #",
			"##        ##                                                      ##        ##",
			"#          #                                                      #          #",
			"#          #                                                      #          #",
			"#          #                                                      #          #",
			"#          #                                                      #          #",
			"##        ##                                                      ##        ##",
			"#          #                                                      #          #",
			"#          #                                                      #          #",
			"#          #                                                      #          #",
			"#          #          v           v             v          v      #          #",
			"##        ##########################################################        ##",
			"#                                                                            #",
			"##############################################################################",
		];

		tile_size = 16;
		level = new Level(display, tile_map, tile_size);

		var player_count = 1;
		var projectile_count = 50;
		var enemy_count = level.enemy_positions.length;
		var buffer_size = player_count + projectile_count + enemy_count;
		buffer = new Buffer<Basic>(buffer_size);
		program = new Program(buffer);
		program.snapToPixel(1);
		display.addProgram(program);

		enemies = [
			for (position in level.enemy_positions) {
				var enemy_grid_x = position[0];
				var enemy_grid_y = position[1];
				var enemy = new Actor(enemy_grid_x, enemy_grid_y, tile_size, level.has_tile_at);
				enemy.skin.change_tint(0x77ff92FF);
				// rotate to be more distinctive (don't rely on tint)
				enemy.skin.rotate(45);
				enemy.skin.add_to_buffer(buffer);
				enemy;
			}
		];

		hero = new Actor(level.player_x, level.player_y, tile_size, level.has_tile_at);
		hero.skin.change_tint(0xff7788FF);
		hero.skin.add_to_buffer(buffer);
		hero.physics.velocity.friction_x = 0.25;
		hero.velocity_y_max = 0.99;
		hero.velocity_x_max = 0.7;

		projectile_cache = new ObjectCache(projectile_count, () -> {
			var projectile = new Projectile(4, tile_size, level.has_tile_at);
			projectile.skin.change_tint(0xffd677F0);
			projectile.skin.add_to_buffer(buffer);
			projectile;
		}, projectile -> projectile.on_cache());

		var scrolling:ScrollConfig = {
			view_width: view_width,
			view_height: view_height,

			boundary_right: level.width_pixels,
			boundary_floor: level.height_pixels,

			zone_center_x: Std.int(hero.physics.position.x),
			zone_center_y: Std.int(hero.physics.position.y),
			zone_width: 100,
			zone_height: 120,
			smoothing: 0.7
		}
		camera = new Camera(display, scrolling);
		camera.zoom = camera_zoom;
		camera.center_on(hero.physics.position.x, hero.physics.position.y);
		camera.toggle_debug();

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
				on_release: () -> hero.drop()
			},
		});

		var fixed_steps_per_second = 20;

		loop = new Loop({
			step: () -> fixed_step_update(),
			end: frame_ratio -> draw(frame_ratio),
		}, fixed_steps_per_second);
	}

	function collide_with_group(actor:Actor, group:Array<Actor>, is_checking_line_of_sight:Bool = false) {
		for (other in enemies) {
			if (other == actor) {
				// do not check if comparing against same object
				continue;
			}
			var x_delta = actor.physics.position.grid_x - other.physics.position.grid_x;
			var x_grid_distance = Math.abs(x_delta);
			var y_delta = actor.physics.position.grid_y - other.physics.position.grid_y;
			var y_grid_distance = Math.abs(y_delta);

			// fast distance check - is other close enough to collide?
			final collision_grid_limit = 2;
			var do_collision_check = x_grid_distance <= collision_grid_limit && y_grid_distance <= collision_grid_limit;

			if (do_collision_check) {
				var overlap = other.physics.overlaps_by(actor.physics);
				if (overlap > 0) {
					// repel
					var angle = Math.atan2(other.physics.position.y - actor.physics.position.y, other.physics.position.x - actor.physics.position.x);
					var force = 0.1;
					var repel_power = (actor.physics.size.radius + other.physics.size.radius - overlap) / (actor.physics.size.radius
						+ other.physics.size.radius);
					other.physics.velocity.delta_x -= Math.cos(angle) * repel_power * force;
					other.physics.velocity.delta_y -= Math.sin(angle) * repel_power * force;
				}
			}

			if (is_checking_line_of_sight) {
				// reset line of sight state
				other.skin.change_alpha(1.0);

				// fast distance check - is distance close enough to be seen?
				final sight_grid_limit = 5;
				var do_line_of_sight_check = x_grid_distance <= sight_grid_limit && y_grid_distance <= sight_grid_limit;

				if (do_line_of_sight_check) {
					var is_actor_in_sight = !Bresenham.is_line_blocked(actor.physics.position.grid_x, actor.physics.position.grid_y,
						other.physics.position.grid_x, other.physics.position.grid_y, level.has_tile_at);
					if (is_actor_in_sight) {
						other.skin.change_alpha(0.4);
						if (projectile_count_down <= 0) {
							// if only one enemy should shoot we could reset projectile_count_down here
							// projectile_count_down = projectile_cool_off;
							var projectile = projectile_cache.get_item();
							if (projectile != null) {
								var x = other.physics.position.grid_x;
								var y = other.physics.position.grid_y;
								var angle = Math.atan2(actor.physics.position.y - other.physics.position.y,
									actor.physics.position.x - other.physics.position.x);
								var delta_x = Math.cos(angle);
								var delta_y = Math.sin(angle);
								var acceleration_x = delta_x * 0.8;
								var acceleration_y = delta_y * 0.8;
								projectile.launch(x, y, acceleration_x, acceleration_y);
							}
						}
					}
				}
			}
		}
	}

	public function frame(elapsed_ms:Int) {
		loop.frame(elapsed_ms);
	}

	function fixed_step_update() {
		projectile_count_down--;

		projectile_cache.iterate_active(projectile -> {
			projectile.update();

			if (projectile.is_expired) {
				return true;
			}

			var greater_than_top_left = projectile.physics.position.grid_x >= 0 && projectile.physics.position.grid_y >= 0;
			var less_than_bottom_right = projectile.physics.position.grid_x < level.width_tiles
				&& projectile.physics.position.grid_y < level.height_pixels;
			var is_out_of_bounds = !greater_than_top_left || !less_than_bottom_right;

			return is_out_of_bounds;
		});

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

		var target_width_offset = (tile_size / 2);
		var target_height_offset = (tile_size / 2);
		var target_left = hero.physics.position.x - target_width_offset;
		var target_right = hero.physics.position.x + target_width_offset;
		var target_ceiling = hero.physics.position.y - target_height_offset;
		var target_floor = hero.physics.position.y + target_height_offset;

		camera.follow_target(target_left, target_right, target_ceiling, target_floor);
	}

	function draw(frame_ratio:Float) {
		hero.draw(frame_ratio);

		projectile_cache.iterate_all(projectile -> projectile.draw(frame_ratio));

		for (other in enemies) {
			other.draw(frame_ratio);
		}

		buffer.update();

		camera.draw(frame_ratio);
	}

	public function on_key_down(key:KeyCode) {
		switch key {
			case NUMBER_1:
				var projectile = projectile_cache.get_item();
				if (projectile != null) {
					var x = hero.physics.position.grid_x;
					var y = hero.physics.position.grid_y;
					var acceleration_x = 0.2 * hero.facing;
					var acceleration_y = 0.0;
					projectile.launch(x, y, acceleration_x, acceleration_y);
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
			case C:
				camera.toggle_debug();
			case _:
		}
	}
}
