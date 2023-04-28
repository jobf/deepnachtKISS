package engine;

/**
	Based on deepnight blog posts from 2013
	position logic - https://deepnight.net/tutorial/a-simple-platformer-engine-part-1-basics/
	overlap logic - https://deepnight.net/tutorial/a-simple-platformer-engine-part-2-collisions/
**/
class DeepnightPosition {
	// aka tile size
	var grid_size:Int;
	public var radius:Float;

	// tile map grid x / y
	public var grid_x:Int;
	public var grid_y:Int;

	// ratios are 0.0 to 1.0  (position inside cell)
	public var grid_cell_ratio_x:Float;
	public var grid_cell_ratio_y:Float;

	// Resulting coordinates
	public var x:Float;
	public var y:Float;

	// Movements
	public var delta_x:Float;
	public var delta_y:Float;

	// delta_x and delta_y mutiplied by this each frame
	public var friction_x:Float = 0.90;
	public var friction_y:Float = 0.94;

	// delta_y is incremented by this each frame
	public var gravity:Float = 0.05;

	public function new(grid_x:Int, grid_y:Int, grid_size:Int, has_collision:(grid_x:Int, grid_y:Int) -> Bool) {
		this.grid_x = grid_x;
		this.grid_y = grid_y;
		this.grid_size = grid_size;
		this.has_collision = has_collision;
		
		radius = grid_size / 2;
		
		// start in center of cell
		grid_cell_ratio_x = 0.5; 
		grid_cell_ratio_y = 0.5;
		
		x = Std.int((grid_x + grid_cell_ratio_x) * grid_size);
		y = Std.int((grid_y + grid_cell_ratio_y) * grid_size);
		
		delta_x = 0;
		delta_y = 0;
	}

	var has_collision:(grid_x:Int, grid_y:Int) -> Bool;

	public function setCoordinates(x:Float, y:Float) {
		this.x = x;
		this.y = y;
		grid_x = Std.int(x / grid_size);
		grid_y = Std.int(y / grid_size);
		grid_cell_ratio_x = (x - grid_x * grid_size) / grid_size;
		grid_cell_ratio_y = (y - grid_y * grid_size) / grid_size;
	}

	public function update() {
		// x movement
		grid_cell_ratio_x += delta_x;
		if(friction_x != 0){
			delta_x *= friction_x;
		}

		// Left collision
		if (has_collision(grid_x + 1, grid_y) && grid_cell_ratio_x >= 0.7) {
			grid_cell_ratio_x = 0.7;
			delta_x = 0; // stop horizontal movement
		}

		// Right collision
		if (has_collision(grid_x - 1, grid_y) && grid_cell_ratio_x <= 0.3) {
			grid_cell_ratio_x = 0.3;
			delta_x = 0;
		}

		// advance grid position if crossing edge
		while (grid_cell_ratio_x > 1) {
			grid_cell_ratio_x--;
			grid_x++;
		}
		while (grid_cell_ratio_x < 0) {
			grid_cell_ratio_x++;
			grid_x--;
		}

		// resulting position
		x = Std.int((grid_x + grid_cell_ratio_x) * grid_size);

		// y movement
		grid_cell_ratio_y += delta_y;
		delta_y += gravity;
		if(friction_y != 0){
			delta_y *= friction_y;
		}

		// Ceiling collision
		if (grid_cell_ratio_y < 0.2 && has_collision(grid_x, grid_y - 1)) {
			delta_y = 0; // stop vertical movement
			grid_cell_ratio_y = 0.2;
		}

		// Floor collision
		if (has_collision(grid_x, grid_y + 1) && grid_cell_ratio_y >= 0.5) {
			delta_y = 0; // stop vertical movement
			grid_cell_ratio_y = 0.5;
		}

		// advance grid position if crossing edge
		while (grid_cell_ratio_y > 1) {
			grid_y++;
			grid_cell_ratio_y--;
		}
		while (grid_cell_ratio_y < 0) {
			grid_y--;
			grid_cell_ratio_y++;
		}

		// resulting position
		y = Std.int((grid_y + grid_cell_ratio_y) * grid_size);
	}

	public function overlaps(test:DeepnightPosition):Bool {
		var max_distance = radius + test.radius;
		var distance_squared = (test.x - x) * (test.x - x) + (test.y - y) * (test.y - y);
		return distance_squared <= max_distance * max_distance;
	}

	public function overlaps_by(test:DeepnightPosition):Float {
		var max_distance = radius + test.radius;
		var distance_squared = (test.x - x) * (test.x - x) + (test.y - y) * (test.y - y);
		return (max_distance * max_distance) - distance_squared;
	}
}
