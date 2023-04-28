package engine;

import peote.view.Display;

class Camera {
	var display:Display;
	var view_width:Int;
	var view_height:Int;

	public var zoom(get, set):Float;

	public function new(display:Display, view_width:Int, view_height:Int) {
		this.display = display;
		this.view_width = view_width;
		this.view_height = view_height;
	}

	public function center_on_target(target_x:Float, target_y:Float, scroll_boundary_x:Int = 0, scroll_boundary_y:Int = 0) {
		var view_center_x = (view_width / 2) / zoom;
		var view_center_y = (view_height / 2) / zoom;

		if (scroll_boundary_x > 0) {
			// keep within boundary left
			var x_scroll_min = view_center_x;
			if (target_x < x_scroll_min) {
				view_center_x -= (x_scroll_min - target_x);
			}
			// keep within boundary right
			var x_scroll_max = (scroll_boundary_x - view_center_x);
			if (target_x > x_scroll_max) {
				view_center_x += (target_x - x_scroll_max);
			}
		}

		if (scroll_boundary_y > 0) {
			// keep within boundary top
			var y_scroll_min = view_center_y;
			if (target_y < y_scroll_min) {
				view_center_y -= (y_scroll_min - target_y);
			}
			// keep within boundary bottom
			var y_scroll_max = (scroll_boundary_y - view_center_y);
			if (target_y > y_scroll_max) {
				view_center_y += (target_y - y_scroll_max);
			}
		}

		display.yOffset = -Std.int((target_y - view_center_y) * zoom);
		display.xOffset = -Std.int((target_x - view_center_x) * zoom);
	}

	function get_zoom():Float {
		return display.zoom;
	}

	function set_zoom(value:Float):Float {
		display.zoom = value;
		return display.zoom;
	}
}
