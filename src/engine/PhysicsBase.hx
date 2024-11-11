package engine;

/**
	Based on deepnight blog posts from 2013
	movement logic - https://deepnight.net/tutorial/a-simple-platformer-engine-part-1-basics/
	overlap logic - https://deepnight.net/tutorial/a-simple-platformer-engine-part-2-collisions/
**/

class PhysicsSimple extends PhysicsBase {
	function update() {
		// change position within grid cell by velocity
		update_velocity();

		// check for adjacent tiles
		update_neighbours();

		// apply gravity 
		velocity.delta_y += velocity.gravity;

		// stop movement if colliding with a tile
		update_collision();

		// update position within grid and cell
		update_position();
	}
}

@:publicFields
abstract class PhysicsBase {
	var position(default, null):Position;
	var velocity(default, null):Velocity;
	var size(default, null):Size;
	var events(default, null):Events;

	var has_wall_tile_at:(grid_x:Int, grid_y:Int) -> Bool;
	var neighbours:Neighbours;

	function new(grid_x:Int, grid_y:Int, tile_size:Int, has_wall_tile_at:(grid_x:Int, grid_y:Int) -> Bool) {
		var grid_cell_ratio_x = 0.5;
		var grid_cell_ratio_y = 0.5;

		var x = (grid_x + grid_cell_ratio_x) * tile_size;
		var y = (grid_y + grid_cell_ratio_y) * tile_size;

		position = {
			grid_x: grid_x,
			grid_y: grid_y,
			grid_cell_ratio_x: grid_cell_ratio_x,
			grid_cell_ratio_y: grid_cell_ratio_y,
			x: x,
			y: y,
			x_previous: x,
			y_previous: y
		}

		size = {
			tile_size: tile_size,
			radius: tile_size / 2
		}

		velocity = {}

		neighbours = {}

		events = {}

		this.has_wall_tile_at = has_wall_tile_at;
	}

	inline function teleport_to(x:Float, y:Float) {
		position.x = x;
		position.y = y;
		position.grid_x = Std.int(x / size.tile_size);
		position.grid_y = Std.int(y / size.tile_size);
		position.grid_cell_ratio_x = 0.5;
		position.grid_cell_ratio_y = 0.5;
	}

	inline function overlaps(other:PhysicsBase):Bool {
		var max_distance = size.radius + other.size.radius;
		var distance_squared = (other.position.x
			- position.x) * (other.position.x - position.x)
			+ (other.position.y - position.y) * (other.position.y - position.y);
		return distance_squared <= max_distance * max_distance;
	}

	inline function overlaps_by(other:PhysicsBase):Float {
		var max_distance = size.radius + other.size.radius;
		var distance_squared = (other.position.x
			- position.x) * (other.position.x - position.x)
			+ (other.position.y - position.y) * (other.position.y - position.y);
		return (max_distance * max_distance) - distance_squared;
	}

	abstract function update():Void;

	inline function update_velocity() {
		position.grid_cell_ratio_x += velocity.delta_x;
		velocity.delta_x *= (1.0 - velocity.friction_x);
		position.grid_cell_ratio_y += velocity.delta_y;
		velocity.delta_y *= (1.0 - velocity.friction_y);
	}

	inline function update_neighbours() {
		neighbours.is_wall_left = has_wall_tile_at(position.grid_x - 1, position.grid_y);
		neighbours.is_wall_right = has_wall_tile_at(position.grid_x + 1, position.grid_y);
		neighbours.is_wall_up = has_wall_tile_at(position.grid_x, position.grid_y - 1);
		neighbours.is_wall_down = has_wall_tile_at(position.grid_x, position.grid_y + 1);
	}

	inline function update_collision() {
		// Left collision
		if (position.grid_cell_ratio_x < size.edge_left && neighbours.is_wall_left) {
			position.grid_cell_ratio_x = size.edge_left; // clamp position
			if (events.on_collide != null) {
				events.on_collide(-1, 0);
			}
			velocity.delta_x = 0; // stop horizontal movement
		}

		// Right collision
		if (position.grid_cell_ratio_x > size.edge_right && neighbours.is_wall_right) {
			position.grid_cell_ratio_x = size.edge_right; // clamp position
			if (events.on_collide != null) {
				events.on_collide(1, 0);
			}
			velocity.delta_x = 0; // stop horizontal movement
		}

		// Ceiling collision
		if (position.grid_cell_ratio_y < size.edge_top && neighbours.is_wall_up) {
			position.grid_cell_ratio_y = size.edge_top; // clamp position
			if (events.on_collide != null) {
				events.on_collide(0, -1);
			}
			velocity.delta_y = 0; // stop vertical movement
		}

		// Floor collision
		if (position.grid_cell_ratio_y > size.edge_bottom && neighbours.is_wall_down) {
			position.grid_cell_ratio_y = size.edge_bottom; // clamp position
			if (events.on_collide != null) {
				events.on_collide(0, 1);
			}
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
@:publicFields
class Position {
	// tile map coordinates
	var grid_x:Int;
	var grid_y:Int;

	// ratios are 0.0 to 1.0  (position inside grid cell)
	var grid_cell_ratio_x:Float;
	var grid_cell_ratio_y:Float;

	// previous pixel coordinates
	var x_previous:Float;
	var y_previous:Float;

	// current pixel coordinates
	var x:Float;
	var y:Float;
}

@:structInit
@:publicFields
class Velocity {
	// applied to grid cell ratio each frame
	var delta_x:Float = 0;
	var delta_y:Float = 0;

	// friction applied each frame 0.0 for none, 1.0 for maximum
	var friction_x:Float = 0.10;
	var friction_y:Float = 0.06;

	// applied to delta_y each frame
	var gravity:Float = 0.05;
}

@:structInit
@:publicFields
class Size {
	var edge_left:Float = 0.3;
	var edge_right:Float = 0.7;
	var edge_top:Float = 0.2;
	var edge_bottom:Float = 0.5;
	var tile_size:Int;
	var radius:Float;
}

@:structInit
@:publicFields
class Events {
	var on_collide:(side_x:Int, side_y:Int) -> Void = null;
}

@:structInit
@:publicFields
class Neighbours {
	var is_wall_left:Bool = false;
	var is_wall_right:Bool = false;
	var is_wall_up:Bool = false;
	var is_wall_down:Bool = false;
}
