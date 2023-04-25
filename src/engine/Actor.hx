package engine;

class Actor {
	var sprite:Sprite;
	var position:DeepnightPosition;
	var direction_x:Int;
	var acceleration_x:Float = 0.15;
	// var acceleration_y:Float = 0.20;
	var velocity_x_max:Float = 0.62;
	var jump_velocity:Float = -0.85;

	// var velocity_y_max:Float = -0.82;
	var is_jumping:Bool = false;

	public function new(sprite:Sprite, grid_x:Int, grid_y:Int, grid_size:Int, has_collision:(grid_x:Int, grid_y:Int) -> Bool) {
		this.sprite = sprite;
		sprite.c = 0xff7788FF;
		position = new DeepnightPosition(grid_x, grid_y, grid_size, has_collision);
	}

	public function update() {
		if (direction_x != 0) {
			position.dx += (direction_x * acceleration_x);
			// cap speed
			if (position.dx > velocity_x_max) {
				position.dx = velocity_x_max;
			}
			if (position.dx < -velocity_x_max) {
				position.dx = -velocity_x_max;
			}
		}

		position.update();

		sprite.x = Std.int(position.xx);
		sprite.y = Std.int(position.yy);
	}

	public function change_direction_x(direction:Int) {
		direction_x = direction;
	}

	public function stop_x() {
		direction_x = 0;
	}

	public function jump() {
		if(position.dy == 0) // it's on the ground
		{
			position.dy = jump_velocity;
		}
	}
}
