package;

import lime.ui.Gamepad;
import engine.Input;
import haxe.CallStack;
import lime.app.Application;
import lime.ui.Window;
import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Color;

class Main extends Application {
	var game:Game;
	var is_ready:Bool;
	var window_width:Int;
	var window_height:Int;
	var game_width:Int;
	var game_height:Int;
	var display:Display;

	override function onPreloadComplete():Void {
		switch (window.context.type) {
			case WEBGL, OPENGL, OPENGLES:
				try
					startSample(window)
				catch (_)
					trace(CallStack.toString(CallStack.exceptionStack()), _);
			default:
				throw("Sorry, only works with OpenGL.");
		}
	}

	public function startSample(window:Window) {
		var peoteView = new PeoteView(window);
		display = new Display(0, 0, window.width, window.height, Color.GREY1);
		peoteView.addDisplay(display);
		var input = new Input(window);

		window_width = window.width;
		window_height = window.height;

		game_width = 256;
		game_height = 192;

		peoteView.window.onResize.add((width, height) -> {
			this.window_width = width;
			this.window_height = height;
			display.width = width;
			display.height = height;
			fit_to_window();
		});

		fit_to_window();

		game = new Game(display, input, window.width, window.height);

		is_ready = true;
	}

	function fit_to_window() {
		var scale = 1.0;
		var x = 0;
		var y = 0;

		if (game_height < game_width) {
			// use height to determine scale when height is smaller edge
			scale = window_height / game_height;

			// offset x by difference beween window width and scaled display width
			var width_scaled = game_width * scale;
			var gap = window_width - width_scaled;
			display.x = Std.int(gap / 2);
		} else {
			// use width to determine scale when width is smaller edge
			scale = window_width / game_width;

			// offset y by difference between window height and scaled display height
			var height_scaled = game_height * scale;
			var gap = game_width - height_scaled;
			display.y = Std.int(gap / 2);
		}

		display.zoom = scale;
		trace('scaled $scale x y $x $y');
	}

	override function update(deltaTime:Int) {
		if (is_ready) {
			game.frame(deltaTime);
		}
	}

	override function onKeyDown(keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void {
		if (is_ready) {
			game.on_key_down(keyCode);
		}
	}

	// override function render(context:lime.graphics.RenderContext):Void {}
	// override function onRenderContextLost ():Void trace(" --- WARNING: LOST RENDERCONTEXT --- ");
	// override function onRenderContextRestored (context:lime.graphics.RenderContext):Void trace(" --- onRenderContextRestored --- ");
	// ----------------- MOUSE EVENTS ------------------------------
	// override function onMouseMove (x:Float, y:Float):Void {}
	// override function onMouseDown (x:Float, y:Float, button:lime.ui.MouseButton):Void {}
	// override function onMouseUp (x:Float, y:Float, button:lime.ui.MouseButton):Void {}
	// override function onMouseWheel (deltaX:Float, deltaY:Float, deltaMode:lime.ui.MouseWheelMode):Void {}
	// override function onMouseMoveRelative (x:Float, y:Float):Void {}
	// ----------------- TOUCH EVENTS ------------------------------
	// override function onTouchStart (touch:lime.ui.Touch):Void {}
	// override function onTouchMove (touch:lime.ui.Touch):Void	{}
	// override function onTouchEnd (touch:lime.ui.Touch):Void {}
	// ----------------- KEYBOARD EVENTS ---------------------------
	// -------------- other WINDOWS EVENTS ----------------------------
	// override function onWindowResize (width:Int, height:Int):Void { trace("onWindowResize", width, height); }
	// override function onWindowLeave():Void { trace("onWindowLeave"); }
	// override function onWindowActivate():Void { trace("onWindowActivate"); }
	// override function onWindowClose():Void { trace("onWindowClose"); }
	// override function onWindowDeactivate():Void { trace("onWindowDeactivate"); }
	// override function onWindowDropFile(file:String):Void { trace("onWindowDropFile"); }
	// override function onWindowEnter():Void { trace("onWindowEnter"); }
	// override function onWindowExpose():Void { trace("onWindowExpose"); }
	// override function onWindowFocusIn():Void { trace("onWindowFocusIn"); }
	// override function onWindowFocusOut():Void { trace("onWindowFocusOut"); }
	// override function onWindowFullscreen():Void { trace("onWindowFullscreen"); }
	// override function onWindowMove(x:Float, y:Float):Void { trace("onWindowMove"); }
	// override function onWindowMinimize():Void { trace("onWindowMinimize"); }
	// override function onWindowRestore():Void { trace("onWindowRestore"); }
}
