package engine;

class Projectile {
	public var sprite(default, null):Sprite;
	public var movement(default, null):DeepnightMovement;
	public var is_active:Bool = false;

	var acceleration_x:Float = 0.0;
	var acceleration_y:Float = 0.0;

	public var velocity_x_max:Float = 3.0;
	public var velocity_y_max:Float = 3.0;

	public function new(sprite:Sprite, movement:DeepnightMovement) {
		this.sprite = sprite;
		this.movement = movement;
	}

	public function update() {
		movement.velocity.delta_x += acceleration_x;

		if (movement.velocity.delta_x > velocity_x_max) {
			movement.velocity.delta_x = velocity_x_max;
		}
		if (movement.velocity.delta_x < -velocity_x_max) {
			movement.velocity.delta_x = -velocity_x_max;
		}

		movement.velocity.delta_y += acceleration_y;

		if (movement.velocity.delta_y > velocity_y_max) {
			movement.velocity.delta_y = velocity_y_max;
		}
		if (movement.velocity.delta_y < -velocity_y_max) {
			movement.velocity.delta_y = -velocity_y_max;
		}

		movement.update();

		sprite.x = Std.int(movement.position.x);
		sprite.y = Std.int(movement.position.y);
	}

	public function fire(grid_x:Int, grid_y:Int, acceleration_x:Float, acceleration_y:Float) {
		movement.position.grid_x = grid_x;
		movement.position.grid_y = grid_y;
		movement.position.grid_cell_ratio_x = 0.5;
		movement.position.grid_cell_ratio_y = 0.5;
		this.acceleration_x = acceleration_x;
		this.acceleration_y = acceleration_y;
		is_active = true;
		sprite.color.a = 0xff;
	}
}
