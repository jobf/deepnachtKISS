package engine.actor;

import engine.body.Body;
import engine.body.skin.SkinBasic;
import engine.body.physics.Physics.PhysicsSimple;

class Projectile extends Body<SkinBasic, PhysicsSimple> {
	var acceleration_x:Float = 0.0;
	var acceleration_y:Float = 0.0;
	var angle:Float = 0;

	public var velocity_x_max:Float = 0.2;
	public var velocity_y_max:Float = 0.2;

	public var is_expired:Bool = false;

	public function new(body_size:Int, tile_size:Int, has_wall_tile_at:(grid_x:Int, grid_y:Int) -> Bool) {
		var skin = new SkinBasic(-999, -999, body_size);
		var physics = new PhysicsSimple(-10, -10, tile_size, has_wall_tile_at);
		physics.velocity.gravity = 0;
		physics.velocity.friction_x = 0;
		physics.velocity.friction_y = 0;
		physics.size.edge_bottom = 0.7;

		super(skin, physics);
	}

	function on_collide(side_x:Int, side_y:Int) {
		if (physics.velocity.delta_x < 0 && side_x < 0 && physics.position.grid_cell_ratio_x <= physics.size.edge_left) {
			#if debug
			trace('hit left');
			#end
			expire();
		}

		if (physics.velocity.delta_x > 0 && side_x > 0 && physics.position.grid_cell_ratio_x >= physics.size.edge_right) {
			#if debug
			trace('hit right');
			#end
			expire();
		}

		if (physics.velocity.delta_y < 0 && side_y < 0 && physics.position.grid_cell_ratio_y <= physics.size.edge_top) {
			#if debug
			trace('hit top');
			#end
			expire();
		}

		if (physics.velocity.delta_y > 0 && side_y > 0 && physics.position.grid_cell_ratio_y >= physics.size.edge_bottom) {
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
		var x = -999;
		var y = -999;
		skin.change_alpha(0.0);
		skin.move(x, y);
		acceleration_x = 0;
		acceleration_y = 0;
		physics.velocity.delta_x = 0;
		physics.velocity.delta_y = 0;
		physics.teleport_to(x, y);
		physics.update();
	}

	override function update() {
		physics.velocity.delta_x += acceleration_x;

		if (physics.velocity.delta_x > velocity_x_max) {
			physics.velocity.delta_x = velocity_x_max;
		}
		if (physics.velocity.delta_x < -velocity_x_max) {
			physics.velocity.delta_x = -velocity_x_max;
		}

		physics.velocity.delta_y += acceleration_y;

		if (physics.velocity.delta_y > velocity_y_max) {
			physics.velocity.delta_y = velocity_y_max;
		}
		if (physics.velocity.delta_y < -velocity_y_max) {
			physics.velocity.delta_y = -velocity_y_max;
		}

		physics.position.x_previous = physics.position.x;
		physics.position.y_previous = physics.position.y;

		physics.update();
	}

	override function draw(frame_ratio:Float) {
		angle += 15 * physics.velocity.delta_x;
		if (angle > 360)
			angle -= 360;
		skin.rotate(angle);
		super.draw(frame_ratio);
	}

	public function launch(grid_x:Int, grid_y:Int, acceleration_x:Float, acceleration_y:Float) {
		revive();
		physics.position.grid_x = grid_x;
		physics.position.grid_y = grid_y;
		physics.position.grid_cell_ratio_x = 0.5;
		physics.position.grid_cell_ratio_y = 0.5;
		this.acceleration_x = acceleration_x;
		this.acceleration_y = acceleration_y;
		skin.change_alpha(1.0);
		physics.update();
		physics.position.x_previous = physics.position.x;
		physics.position.y_previous = physics.position.y;
	}

}

