package engine;

/**
	Based on deepnight blog posts from 2013
	movemen logic - https://deepnight.net/tutorial/a-simple-platformer-engine-part-1-basics/
	overlap logic - https://deepnight.net/tutorial/a-simple-platformer-engine-part-2-collisions/
**/
class DeepnightMovement {
	public var position(default, null):Position;
	public var velocity(default, null):Velocity;
	public var size(default, null):Size;

	// velocity.delta_y is incremented by this each frame
	public var gravity:Float = 0.05;

	var has_wall_tile_at:(grid_x:Int, grid_y:Int) -> Bool;
	var is_wall_left:Bool;
	var is_wall_right:Bool;
	var is_wall_up:Bool;
	var is_wall_down:Bool;

	public function new(grid_x:Int, grid_y:Int, tile_size:Int, has_wall_tile_at:(grid_x:Int, grid_y:Int) -> Bool) {
		var grid_cell_ratio_x = 0.5;
		var grid_cell_ratio_y = 0.5;

		position = {
			grid_x: grid_x,
			grid_y: grid_y,
			grid_cell_ratio_x: grid_cell_ratio_x,
			grid_cell_ratio_y: grid_cell_ratio_y,
			x: Std.int((grid_x + grid_cell_ratio_x) * tile_size),
			y: Std.int((grid_y + grid_cell_ratio_y) * tile_size)
		}

		size = {
			tile_size: tile_size,
			radius: tile_size / 2
		}

		velocity = {}

		this.has_wall_tile_at = has_wall_tile_at;
	}

	public function set_coordinates(x:Float, y:Float, pos:Position, size:Size) {
		position.x = x;
		position.y = y;
		position.grid_x = Std.int(x / size.tile_size);
		position.grid_y = Std.int(y / size.tile_size);
		position.grid_cell_ratio_x = (x - position.grid_x * size.tile_size) / size.tile_size;
		position.grid_cell_ratio_y = (y - position.grid_y * size.tile_size) / size.tile_size;
	}

	public function overlaps(other:DeepnightMovement):Bool {
		var max_distance = size.radius + other.size.radius;
		var distance_squared = (other.position.x
			- position.x) * (other.position.x - position.x)
			+ (other.position.y - position.y) * (other.position.y - position.y);
		return distance_squared <= max_distance * max_distance;
	}

	public function overlaps_by(other:DeepnightMovement):Float {
		var max_distance = size.radius + other.size.radius;
		var distance_squared = (other.position.x
			- position.x) * (other.position.x - position.x)
			+ (other.position.y - position.y) * (other.position.y - position.y);
		return (max_distance * max_distance) - distance_squared;
	}

	public function update() {
		update_movement_horizontal();
		update_movement_vertical();
		update_neighbours();
		update_gravity();
		update_collision();
		update_position();
	}

	inline function update_movement_horizontal() {
		position.grid_cell_ratio_x += velocity.delta_x;
		velocity.delta_x *= (1.0 - velocity.friction_x);
	}

	inline function update_movement_vertical() {
		position.grid_cell_ratio_y += velocity.delta_y;
		velocity.delta_y *= (1.0 - velocity.friction_y);
	}

	inline function update_neighbours() {
		is_wall_left = has_wall_tile_at(position.grid_x + 1, position.grid_y);
		is_wall_right = has_wall_tile_at(position.grid_x - 1, position.grid_y);
		is_wall_up = has_wall_tile_at(position.grid_x, position.grid_y - 1);
		is_wall_down = has_wall_tile_at(position.grid_x, position.grid_y + 1);
	}

	inline function update_gravity() {
		velocity.delta_y += gravity;
	}

	inline function update_collision() {
		// Left collision
		if (position.grid_cell_ratio_x >= 0.7 && is_wall_left) {
			position.grid_cell_ratio_x = 0.7; // clamp position
			velocity.delta_x = 0; // stop horizontal movement
		}

		// Right collision
		if (position.grid_cell_ratio_x <= 0.3 && is_wall_right) {
			position.grid_cell_ratio_x = 0.3; // clamp position
			velocity.delta_x = 0; // stop horizontal movement
		}

		// Ceiling collision
		if (position.grid_cell_ratio_y < 0.2 && is_wall_up) {
			position.grid_cell_ratio_y = 0.2; // clamp position
			velocity.delta_y = 0; // stop vertical movement
		}

		// Floor collision
		if (position.grid_cell_ratio_y >= 0.5 && is_wall_down) {
			position.grid_cell_ratio_y = 0.5; // clamp position
			velocity.delta_y = 0; // stop vertical movement
		}
	}

	inline function update_position() {
		// advance position.grid position if crossing edge
		while (position.grid_cell_ratio_x > 1) {
			position.grid_cell_ratio_x--;
			position.grid_x++;
		}
		while (position.grid_cell_ratio_x < 0) {
			position.grid_cell_ratio_x++;
			position.grid_x--;
		}

		// resulting position
		position.x = Math.floor((position.grid_x + position.grid_cell_ratio_x) * size.tile_size);

		// advance position.grid position if crossing edge
		while (position.grid_cell_ratio_y > 1) {
			position.grid_y++;
			position.grid_cell_ratio_y--;
		}
		while (position.grid_cell_ratio_y < 0) {
			position.grid_y--;
			position.grid_cell_ratio_y++;
		}

		// resulting position
		position.y = Math.floor((position.grid_y + position.grid_cell_ratio_y) * size.tile_size);
	}
}

@:structInit
class Position {
	// tile map coordinates
	public var grid_x:Int;
	public var grid_y:Int;

	// ratios are 0.0 to 1.0  (position inside grid cell)
	public var grid_cell_ratio_x:Float;
	public var grid_cell_ratio_y:Float;

	// resulting pixel coordinates
	public var x:Float;
	public var y:Float;
}

@:structInit
class Velocity {
	// applied to grid cell ratio each frame
	public var delta_x:Float = 0;
	public var delta_y:Float = 0;

	// friction applied each frame 0.0 for none, 1.0 for maximum
	public var friction_x:Float = 0.10;
	public var friction_y:Float = 0.06;
}

@:structInit
class Size {
	public var tile_size:Int;
	public var radius:Float;
}