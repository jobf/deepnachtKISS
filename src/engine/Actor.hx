package engine;

import engine.body.physics.PhysicsPlatformer;
import engine.body.skin.SkinBasic;
import engine.body.Body;

class Actor extends Body<SkinBasic, PhysicsPlatformer> {
	public var direction_x:Int = 0;
	public var facing:Int = 0;

	var acceleration_x:Float = 0.15;

	public var velocity_x_max:Float = 0.62;
	public var velocity_y_max:Float = 0.7;

	var is_jumping:Bool = false;
	var jump_velocity:Float = -0.85;

	public function new(grid_x:Int, grid_y:Int, tile_size:Int, has_wall_tile_at:(grid_x:Int, grid_y:Int) -> Bool) {
		var x = grid_x * tile_size;
		var y = grid_x * tile_size;
		var skin = new SkinBasic(x, y, tile_size);

		var physics = new PhysicsPlatformer(grid_x, grid_y, tile_size, has_wall_tile_at);
		physics.velocity.friction_y = 0;

		super(skin, physics);
	}

	override function update() {
		if (direction_x != 0) {
			// accelerate horizontally
			physics.velocity.delta_x += (direction_x * acceleration_x);
		}

		// cap speed
		if (physics.velocity.delta_x > velocity_x_max) {
			physics.velocity.delta_x = velocity_x_max;
		}
		if (physics.velocity.delta_x < -velocity_x_max) {
			physics.velocity.delta_x = -velocity_x_max;
		}

		if (velocity_y_max > 0 && physics.velocity.delta_y > velocity_y_max) {
			physics.velocity.delta_y = velocity_y_max;
		}
		if (velocity_y_max < 0 && physics.velocity.delta_y < -velocity_y_max) {
			physics.velocity.delta_y = -velocity_y_max;
		}

		physics.position.x_previous = physics.position.x;
		physics.position.y_previous = physics.position.y;

		super.update();
	}

	public function change_direction_x(velocity:Int) {
		facing = velocity;
		direction_x = velocity;
	}

	public function stop_x() {
		direction_x = 0;
	}

	public function jump() {
		physics.press_jump();
	}

	public function drop() {
		physics.release_jump();
	}

	function on_collide(side_x:Int, side_y:Int) {}
}
