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

	public function center_on_target(target_x:Float, target_y:Float) {
		var center_x = view_width / 2;
		var center_y = view_height / 2;
		display.xOffset = -((target_x * zoom) - center_x);
		display.yOffset = -((target_y * zoom) - center_y);
	}

	function get_zoom():Float {
		return display.zoom;
	}

	function set_zoom(value:Float):Float {
		display.zoom = value;
		return display.zoom;
	}
}
