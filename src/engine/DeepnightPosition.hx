package engine;

class DeepnightPosition {
	// Base coordinates
	public var cx:Int;
	public var cy:Int;
	public var xr:Float;
	public var yr:Float;

	// Resulting coordinates
	public var xx:Float;
	public var yy:Float;

	// Movements
	public var dx:Float;
	public var dy:Float;

	var grid_size:Int;

	public function new(grid_x:Int, grid_y:Int, grid_size:Int, has_collision:(grid_x:Int, grid_y:Int) -> Bool) {
		cx = grid_x;
		cy = grid_y;
		this.grid_size = grid_size;
		this.has_collision = has_collision;
		xx = Std.int((cx + xr) * grid_size);
		yy = Std.int((cy + yr) * grid_size);
		xr = 0;
		yr = 0;
		dx = 0;
		dy = 0;
	}

	var has_collision:(grid_x:Int, grid_y:Int) -> Bool;

	public function setCoordinates(x, y) {
		xx = x;
		yy = y;
		cx = Std.int(xx / grid_size);
		cy = Std.int(yy / grid_size);
		xr = (xx - cx * grid_size) / grid_size;
		yr = (yy - cy * grid_size) / grid_size;
	}

	public function update() {
		// x movement
		xr += dx;
		dx *= 0.84; // friction

		// left collision
		if (has_collision(cx + 1, cy) && xr >= 0.7) {
			xr = 0.7;
			dx = 0; // stop movement
		}
		
		// right collision
		if (has_collision(cx - 1, cy) && xr <= 0.3) {
			xr = 0.3;
			dx = 0;
		}

		while (xr > 1) {
			xr--;
			cx++;
		}
		while (xr < 0) {
			xr++;
			cx--;
		}

		xx = Std.int((cx + xr) * grid_size);

		// y movement
		yr += dy;
		dy += 0.05; // gravity
		dy *= 0.94; // friction

		// Ceiling collision
		if (yr < 0.2 && has_collision(cx, cy - 1)) {
			yr = 0.2;
		}

		if (has_collision(cx, cy + 1) && yr >= 0.5) {
			dy = 0;
			yr = 0.5;
		}

		while (yr > 1) {
			cy++;
			yr--;
		}
		while (yr < 0) {
			cy--;
			yr++;
		}

		yy = Std.int((cy + yr) * grid_size);
	}
}
