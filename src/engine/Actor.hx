package engine;

class Actor {
	public var sprite(default, null):Sprite;
	public var position(default, null):DeepnightPosition;

	var direction_x:Int = 0;
	var acceleration_x:Float = 0.15;
	var velocity_x_max:Float = 0.62;

	var is_jumping:Bool = false;
	var jump_velocity:Float = -0.85;


	public function new(sprite:Sprite, grid_x:Int, grid_y:Int, grid_size:Int, has_collision:(grid_x:Int, grid_y:Int) -> Bool) {
		this.sprite = sprite;
		position = new DeepnightPosition(grid_x, grid_y, grid_size, has_collision);
	}

	public function update() {
		if (direction_x != 0) {
			position.delta_x += (direction_x * acceleration_x);
			// cap speed
			if (position.delta_x > velocity_x_max) {
				position.delta_x = velocity_x_max;
			}
			if (position.delta_x < -velocity_x_max) {
				position.delta_x = -velocity_x_max;
			}
		}

		position.update();

		sprite.x = Std.int(position.x);
		sprite.y = Std.int(position.y);
	}

	public function change_direction_x(direction:Int) {
		direction_x = direction;
	}

	public function stop_x() {
		direction_x = 0;
	}

	public function jump() {
		if(position.delta_y == 0) // it's on the ground
		{
			position.delta_y = jump_velocity;
		}
	}
}
