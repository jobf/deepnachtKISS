package;

import engine.Loop;
import engine.Camera;
import engine.*;
import lime.ui.KeyCode;
import peote.view.Display;
import peote.view.Program;
import peote.view.Buffer;

class Game {
	var tile_size:Int;
	var level:Level;

	var hero:Actor;
	var enemies:Array<Actor>;

	var projectiles:Array<Projectile>;
	var projectile_count_down:Int = 0;
	var projectile_cool_off:Int = 12;

	var buffer:Buffer<Sprite>;
	var program:Program;

	var camera:Camera;
	var camera_zoom = 3;
	var input:Input;
	var loop:Loop;
	var step_ratio:Float;

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
		buffer = new Buffer<Sprite>(buffer_size);
		program = new Program(buffer);
		program.snapToPixel(1);
		display.addProgram(program);

		var image = lime.utils.Assets.getImage("assets/sprite-shit.png");
		var texture = new peote.view.Texture(image.width, image.height);
		texture.setImage(image);
		texture.tilesX = Std.int(image.width / tile_size);
		texture.tilesY = Std.int(image.height / tile_size);

		program.addTexture(texture, "sprites");

		enemies = [];
		for (position in level.enemy_positions) {
			var enemy_grid_x = position[0];
			var enemy_grid_y = position[1];
			var enemy_sprite = new Sprite(enemy_grid_x, enemy_grid_y, tile_size);
			enemy_sprite.color = 0x77ff92FF;
			// rotate to be more distinctive (don't rely on color)
			enemy_sprite.angle = 45;
			enemy_sprite.tile_index = 2;
			buffer.addElement(enemy_sprite);
			enemies.push(new Actor(enemy_sprite, enemy_grid_x, enemy_grid_y, tile_size, level.has_tile_at));
		}

		var hero_sprite = new Sprite(level.player_x, level.player_y, tile_size);
		hero_sprite.color = 0xff7788FF;
		hero_sprite.tile_index = 1;
		buffer.addElement(hero_sprite);
		hero = new Actor(hero_sprite, level.player_x, level.player_y, tile_size, level.has_tile_at);
		hero.movement.velocity.friction_x = 0.25;
		hero.velocity_y_max = 0.99;
		hero.velocity_x_max = 0.7;

		projectiles = [
			for (n in 0...projectile_count) {
				var size = 4;
				var x = -100;
				var y = -100;

				var sprite = new Sprite(x, y, size);
				sprite.color = 0xffd677FF;
				buffer.addElement(sprite);

				var movement = new DeepnightMovement(x, y, tile_size, level.has_tile_at);
				movement.gravity = 0;
				movement.velocity.friction_x = 0;
				movement.velocity.friction_y = 0;

				new Projectile(sprite, movement);
			}
		];

		var view_width_center = view_width / 2;
		var view_height_center = view_height / 2;
		var scrolling:ScrollConfig = {
			view_width: view_width,
			view_height: view_height,

			boundary_right: level.width_pixels,
			boundary_floor: level.height_pixels,

			zone_center_x: Std.int(hero.movement.position.x),
			zone_center_y: Std.int(hero.movement.position.y),
			zone_width: 100,
			zone_height: 120,
		}
		camera = new Camera(display, scrolling);
		camera.zoom = camera_zoom;
		camera.center_on(hero.movement.position.x, hero.movement.position.y);
		camera.toggle_debug();

		input.registerController({
			left: {
				on_press: () -> hero.change_velocity_x(-1),
				on_release: () -> hero.stop_x()
			},
			right: {
				on_press: () -> hero.change_velocity_x(1),
				on_release: () -> hero.stop_x()
			},
			a: {
				on_press: () -> hero.jump(),
				on_release: () -> hero.drop()
			},
		});

		var fixed_steps_per_second = 30;


		loop = new Loop({
			step: () -> fixed_step_update(),
			end: step_ratio -> draw(step_ratio),
		}, fixed_steps_per_second);
	}


	function collide_with_group(actor:Actor, group:Array<Actor>, is_checking_line_of_sight:Bool = false) {
		for (other in enemies) {
			if (other == actor) {
				// do not check if comparing against same object
				continue;
			}
			var x_delta = actor.movement.position.grid_x - other.movement.position.grid_x;
			var x_grid_distance = Math.abs(x_delta);
			var y_delta = actor.movement.position.grid_y - other.movement.position.grid_y;
			var y_grid_distance = Math.abs(y_delta);

			// fast distance check - is other close enough to collide?
			final collision_grid_limit = 2;
			var do_collision_check = x_grid_distance <= collision_grid_limit && y_grid_distance <= collision_grid_limit;

			if (do_collision_check) {
				var overlap = other.movement.overlaps_by(actor.movement);
				if (overlap > 0) {
					// repel
					var angle = Math.atan2(other.movement.position.y - actor.movement.position.y, other.movement.position.x - actor.movement.position.x);
					var force = 0.1;
					var repel_power = (actor.movement.size.radius + other.movement.size.radius - overlap) / (actor.movement.size.radius
						+ other.movement.size.radius);
					other.movement.velocity.delta_x -= Math.cos(angle) * repel_power * force;
					other.movement.velocity.delta_y -= Math.sin(angle) * repel_power * force;
				}
			}

			if (is_checking_line_of_sight) {
				// reset line of sight state
				other.sprite.color.a = 0xff;

				// fast distance check - is distance close enough to be seen?
				final sight_grid_limit = 5;
				var do_line_of_sight_check = x_grid_distance <= sight_grid_limit && y_grid_distance <= sight_grid_limit;

				if (do_line_of_sight_check) {
					var is_actor_in_sight = !Bresenham.is_line_blocked(actor.movement.position.grid_x, actor.movement.position.grid_y,
						other.movement.position.grid_x, other.movement.position.grid_y, level.has_tile_at);
					if (is_actor_in_sight) {
						other.sprite.color.a = 0x70;
						if (projectile_count_down <= 0) {
							// if only one enemy should shoot we could reset projectile_count_down here
							// projectile_count_down = projectile_cool_off;
							var projectile = get_projectile();
							if (projectile != null) {
								var x = other.movement.position.grid_x;
								var y = other.movement.position.grid_y;
								var angle = Math.atan2(actor.movement.position.y - other.movement.position.y,
									actor.movement.position.x - other.movement.position.x);
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

	public function frame(elapsed_ms:Int) {
		loop.frame(elapsed_ms);
	}

	function fixed_step_update() {
		projectile_count_down--;

		for (projectile in projectiles) {
			if (projectile.is_active) {
				projectile.update();
				var greater_than_top_left = projectile.movement.position.grid_x > 0 && projectile.movement.position.grid_y > 0;
				var less_than_bottom_right = projectile.movement.position.grid_x < level.width_tiles
					&& projectile.movement.position.grid_y < level.height_pixels;
				var is_out_of_bounds = !greater_than_top_left || !less_than_bottom_right;
				var is_stopped = projectile.movement.velocity.delta_x + projectile.movement.velocity.delta_x == 0;
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

		var target_width_offset = (tile_size / 2);
		var target_height_offset = (tile_size / 2);
		var target_left = hero.movement.position.x - target_width_offset;
		var target_right = hero.movement.position.x + target_width_offset;
		var target_ceiling = hero.movement.position.y - target_height_offset;
		var target_floor = hero.movement.position.y + target_height_offset;

		camera.follow_target(target_left, target_right, target_ceiling, target_floor);
	}

	function draw(step_ratio:Float) {

		hero.draw(step_ratio);
		for (other in enemies) {
			other.draw(step_ratio);
		}

		buffer.update();

		camera.draw(step_ratio);
	}

	public function on_key_down(key:KeyCode) {
		switch key {
			case NUMBER_1:
				var projectile = get_projectile();
				if (projectile != null) {
					var x = hero.movement.position.grid_x;
					var y = hero.movement.position.grid_y;
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
			case C:
				camera.toggle_debug();
			case _:
		}
	}
}
