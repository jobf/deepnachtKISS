package engine;

import engine.PhysicsBase;

class Projectile {
	public var sprite(default, null):Sprite;
	public var movement(default, null):PhysicsSimple;

	var acceleration_x:Float = 0.0;
	var acceleration_y:Float = 0.0;

	public var velocity_x_max:Float = 0.2;
	public var velocity_y_max:Float = 0.2;

	public var is_expired:Bool = false;

	public function new(sprite:Sprite, movement:PhysicsSimple) {
		this.sprite = sprite;
		this.movement = movement;
		movement.events.on_collide = on_collide;
		movement.size.edge_bottom = 0.7;
	}

	function on_collide(side_x:Int, side_y:Int) {
		if (movement.velocity.delta_x < 0 && side_x < 0 && movement.position.grid_cell_ratio_x <= movement.size.edge_left ) {
			#if debug
			trace('hit left');
			#end
			expire();
		}

		if (movement.velocity.delta_x > 0 && side_x > 0 && movement.position.grid_cell_ratio_x >= movement.size.edge_right) {
			#if debug
			trace('hit right');
			#end
			expire();
		}

		if (movement.velocity.delta_y < 0 && side_y < 0 && movement.position.grid_cell_ratio_y <= movement.size.edge_top) {
			#if debug
			trace('hit top');
			#end
			expire();
		}

		if (movement.velocity.delta_y > 0 && side_y > 0 && movement.position.grid_cell_ratio_y >= movement.size.edge_bottom) {
			#if debug
			trace('bottom');
			#end
			expire();
		}
	}

	public function revive() {
		is_expired = false;
	}

	public function expire() {
		is_expired = true;
	}

	public function on_cache() {
		sprite.color.a = 0x00;
		sprite.x = -999;
		sprite.y = -999;
		acceleration_x = 0;
		acceleration_y = 0;
		movement.velocity.delta_x = 0;
		movement.velocity.delta_y = 0;
		movement.teleport_to(sprite.x, sprite.y);
		movement.update();
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

		movement.position.x_previous = movement.position.x;
		movement.position.y_previous = movement.position.y;

		movement.update();
	}

	public function draw(step_ratio:Float) {
		sprite.x = Calculate.lerp(movement.position.x_previous, movement.position.x, step_ratio);
		sprite.y = Calculate.lerp(movement.position.y_previous, movement.position.y, step_ratio);
		sprite.angle += 15 * movement.velocity.delta_x;
		if (sprite.angle > 360)
			sprite.angle -= 360;
	}

	public function launch(grid_x:Int, grid_y:Int, acceleration_x:Float, acceleration_y:Float) {
		revive();
		movement.position.grid_x = grid_x;
		movement.position.grid_y = grid_y;
		movement.position.grid_cell_ratio_x = 0.5;
		movement.position.grid_cell_ratio_y = 0.5;
		this.acceleration_x = acceleration_x;
		this.acceleration_y = acceleration_y;
		sprite.color.a = 0xff;
		movement.update();
		movement.position.x_previous = movement.position.x;
		movement.position.y_previous = movement.position.y;
	}
}
