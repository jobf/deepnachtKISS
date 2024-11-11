package engine;

class Actor {
	public var sprite(default, null):Sprite;
	public var movement(default, null):PhysicsPlatformer;
	public var velocity_x:Int = 0;
	public var facing:Int = 0;

	var acceleration_x:Float = 0.15;

	public var velocity_x_max:Float = 0.62;
	public var velocity_y_max:Float = 0.7;

	var is_jumping:Bool = false;
	var jump_velocity:Float = -0.85;

	public function new(sprite:Sprite, grid_x:Int, grid_y:Int, tile_size:Int, has_wall_tile_at:(grid_x:Int, grid_y:Int) -> Bool) {
		this.sprite = sprite;
		movement = new PhysicsPlatformer(grid_x, grid_y, tile_size, has_wall_tile_at);
		movement.velocity.friction_y = 0;
	}

	public function update() {
		if (velocity_x != 0) {
			// accelerate horizontally
			movement.velocity.delta_x += (velocity_x * acceleration_x);
		}

		// cap speed
		if (movement.velocity.delta_x > velocity_x_max) {
			movement.velocity.delta_x = velocity_x_max;
		}
		if (movement.velocity.delta_x < -velocity_x_max) {
			movement.velocity.delta_x = -velocity_x_max;
		}

		if (velocity_y_max > 0 && movement.velocity.delta_y > velocity_y_max) {
			movement.velocity.delta_y = velocity_y_max;
		}
		if (velocity_y_max < 0 && movement.velocity.delta_y < -velocity_y_max) {
			movement.velocity.delta_y = -velocity_y_max;
		}

		movement.position.x_previous = movement.position.x;
		movement.position.y_previous = movement.position.y;

		movement.update();
	}

	public function draw(step_ratio:Float) {
		sprite.x = Calculate.lerp(movement.position.x_previous, movement.position.x, step_ratio);
		sprite.y = Calculate.lerp(movement.position.y_previous, movement.position.y, step_ratio);
	}

	public function change_velocity_x(velocity:Int) {
		facing = velocity;
		velocity_x = velocity;
	}

	public function stop_x() {
		velocity_x = 0;
	}

	public function jump() {
		movement.press_jump();
	}

	public function drop() {
		movement.release_jump();
	}
}
