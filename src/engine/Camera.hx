package engine;

import peote.view.Display;

class Camera {
	var display:Display;
	var view_width:Int;
	var view_height:Int;

	public function new(display:Display, view_width:Int, view_height:Int) {
		this.display = display;
		this.view_width = view_width;
		this.view_height = view_height;
	}

	public function center_on_target(target_x:Float, target_y:Float){
		var center_x = view_width * 0.5;
		var center_y = view_height * 0.5;
		display.xOffset = -Std.int(target_x - center_x);
		display.yOffset = -Std.int(target_y - center_y);
	}
}
