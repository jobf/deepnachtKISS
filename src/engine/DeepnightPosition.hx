package engine;

/**
	Based on deepnight blog post from 2013 - https://deepnight.net/tutorial/a-simple-platformer-engine-part-1-basics/
**/
class DeepnightPosition {
	// aka tile size
	var grid_size:Int;

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


	public function new(grid_x:Int, grid_y:Int, grid_size:Int, has_collision:(grid_x:Int, grid_y:Int) -> Bool) {
		this.grid_x = grid_x;
		this.grid_y = grid_y;
		this.grid_size = grid_size;
		this.has_collision = has_collision;
		x = Std.int((grid_x + grid_cell_ratio_x) * grid_size);
		y = Std.int((grid_y + grid_cell_ratio_y) * grid_size);
		grid_cell_ratio_x = 0;
		grid_cell_ratio_y = 0;
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
		delta_x *= 0.84; // friction

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
		delta_y += 0.05; // gravity
		delta_y *= 0.94; // friction

		// Ceiling collision
		if (grid_cell_ratio_y < 0.2 && has_collision(grid_x, grid_y - 1)) {
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
}
