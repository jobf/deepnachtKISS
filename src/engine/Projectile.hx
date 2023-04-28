package engine;

class Projectile {
	public var sprite(default, null):Sprite;
	public var position(default, null):DeepnightPosition;
	public var is_active:Bool = false;

	var acceleration_x:Float = 0.0;
	var acceleration_y:Float = 0.0;
	public var velocity_x_max:Float = 3.0;
	public var velocity_y_max:Float = 3.0;

	public function new(sprite:Sprite, position:DeepnightPosition) {
		this.sprite = sprite;
		this.position = position;
	}

	public function update() {
		position.delta_x += acceleration_x;

		if (position.delta_x > velocity_x_max) {
			position.delta_x = velocity_x_max;
		}
		if (position.delta_x < -velocity_x_max) {
			position.delta_x = -velocity_x_max;
		}


		position.delta_y += acceleration_y;

		if (position.delta_y > velocity_y_max) {
			position.delta_y = velocity_y_max;
		}
		if (position.delta_y < -velocity_y_max) {
			position.delta_y = -velocity_y_max;
		}

		position.update();

		sprite.x = Std.int(position.x);
		sprite.y = Std.int(position.y);
	}

	public function fire(grid_x:Int, grid_y:Int, acceleration_x:Float, acceleration_y:Float) {
		position.grid_x = grid_x;
		position.grid_y = grid_y;
		this.acceleration_x = acceleration_x;
		this.acceleration_y = acceleration_y;
		is_active = true;
		sprite.color.a = 0xff;
	}
}
