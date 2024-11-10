package engine;

class Projectile {
	public var sprite(default, null):Sprite;
	public var movement(default, null):DeepnightMovement;
	var position_x_previous:Float;
	var position_y_previous:Float;
	public var is_active:Bool = false;

	var acceleration_x:Float = 0.0;
	var acceleration_y:Float = 0.0;

	public var velocity_x_max:Float = 0.2;
	public var velocity_y_max:Float = 0.2;

	public function new(sprite:Sprite, movement:DeepnightMovement) {
		this.sprite = sprite;
		this.movement = movement;
		position_x_previous = movement.position.x;
		position_y_previous = movement.position.y;
		movement.events.on_collide = (side_x, side_y) -> {
			
			if(movement.velocity.delta_x < 0 && side_x < 0){
				is_active = false;
				sprite.color.a = 0x00;
				sprite.x = -999;
				sprite.y = -999;
			}

			if(movement.velocity.delta_x > 0 && side_x > 0){
				is_active = false;
				sprite.color.a = 0x00;
				sprite.x = -999;
				sprite.y = -999;
			}

			if(movement.velocity.delta_y < 0 && side_y < 0){
				is_active = false;
				sprite.color.a = 0x00;
				sprite.x = -999;
				sprite.y = -999;
			}

			if(movement.velocity.delta_y > 0 && side_y > 0){
				is_active = false;
				sprite.color.a = 0x00;
				sprite.x = -999;
				sprite.y = -999;
			}

		}
	}

	public function update() {
		if(!is_active) return;

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

		position_x_previous = movement.position.x;
		position_y_previous = movement.position.y;

		movement.update();

	}
	
	public function draw(step_ratio:Float)
	{
		sprite.x = Calculate.lerp(position_x_previous, movement.position.x, step_ratio);
		sprite.y = Calculate.lerp(position_y_previous, movement.position.y, step_ratio);
	}

	public function launch(grid_x:Int, grid_y:Int, acceleration_x:Float, acceleration_y:Float) {
		movement.position.grid_x = grid_x;
		movement.position.grid_y = grid_y;
		movement.position.grid_cell_ratio_x = 0.5;
		movement.position.grid_cell_ratio_y = 0.5;
		this.acceleration_x = acceleration_x;
		this.acceleration_y = acceleration_y;
		is_active = true;
		sprite.color.a = 0xff;
		movement.update();
		position_x_previous = movement.position.x;
		position_y_previous = movement.position.y;
	}
}
