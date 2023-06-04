package engine;

import peote.view.Color;
import peote.view.Buffer;
import peote.view.Display;
import peote.view.Element;
import peote.view.PeoteView;
import peote.view.Program;
import peote.view.Texture;

class Screen {
	public var display(get, never):Display;

	var view_display:Display;
	var view_buffer:Buffer<ViewElement>;
	var view_program:Program;
	var view_element:ViewElement;

	var texture_display:TextureDisplay;
	var texture_palette:Texture;

	public var unscaled_width(default, null):Int;
	public var unscaled_height(default, null):Int;

	var window_width:Int;
	var window_height:Int;

	public function new(peote_view:PeoteView, width:Int, height:Int)
	{
		this.unscaled_width = width;
		this.unscaled_height = height;
		this.window_width = peote_view.window.width;
		this.window_height = peote_view.window.height;

		view_display = new Display(0, 0, window_width, window_height, Color.GREY1);

		peote_view.addDisplay(view_display);
		view_buffer = new Buffer<ViewElement>(1);
		view_program = new Program(view_buffer);
		view_display.addProgram(view_program);

		// display rendered to texture
		texture_display = new TextureDisplay(peote_view, width, height);
		view_program.addTexture(texture_display.texture, "display");
		// the element which renders the texture
		view_element = new ViewElement(0, 0, width, height);
		view_buffer.addElement(view_element);

		fit_to_window();

		peote_view.window.onResize.add((window_width, window_height) -> {
			this.window_width = window_width;
			this.window_height = window_height;
			view_display.width = window_width;
			view_display.height = window_height;
			fit_to_window();
		});
	}

	/**
		scales the view of the game to the largest size that fits the window
		maintains aspect ratio and scales to an integer so no rounding errors
	**/
	function fit_to_window() {
		var scaled_width = window_width / unscaled_width;
		var scaled_height = window_height / unscaled_height;
		var scale:Int = Math.floor(Math.min(scaled_width, scaled_height));

		if (scale < 1){
			scale = 1;
		}

		view_element.w = Std.int(unscaled_width * scale);
		view_element.h = Std.int(unscaled_height * scale);
		view_element.x = Std.int(window_width / 2);
		view_element.y = Std.int(window_height / 2);
		view_buffer.updateElement(view_element);

		trace('window $window_width x $window_height, scale $scale, view ${view_element.w} x ${view_element.h} view pos ${view_element.x} ${view_element.y}');
	}

	function get_display():Display {
		return texture_display.display;
	}
}

/** Display which is rendered to a Texture **/
class TextureDisplay {
	public var display(default, null):Display;
	public var texture(default, null):Texture;

	public function new(peote_view:PeoteView, width:Int, height:Int) {
		display = new Display(0, 0, width, height);
		peote_view.addFramebufferDisplay(display);
		texture = new Texture(width, height);
		display.setFramebuffer(texture, peote_view);
	}
}
/** ELement which renders the Display Texture **/
class ViewElement implements Element {
	@posX public var x:Int;
	@posY public var y:Int;
	@sizeX public var w:Int;
	@sizeY public var h:Int;
	@pivotX @formula("w * 0.5") var x_offset:Float;
	@pivotY @formula("h * 0.5") var y_offset:Float;

	public function new(x:Int, y:Int, width:Int, height:Int) {
		this.x = x;
		this.y = y;
		this.w = width;
		this.h = height;
	}
}
