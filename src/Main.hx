package;

import haxe.CallStack;
import lime.app.Application;
import lime.ui.Window;
import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Color;

class Main extends Application {
	var game:Game;
	var is_ready:Bool;

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
		var display = new Display(0, 0, window.width, window.height, Color.GREY1);
		peoteView.addDisplay(display);
		game = new Game(display, window.width, window.height);
		is_ready = true;
	}

	var frame_duration:Float = 1 / 30; // 30 frames per second
	var frame_time_remaining:Float = 0;

	override function update(deltaTime:Int):Void {
		// update is called at window refresh speed is 60 fps
		// game is running at 30 fps so don't update the game every frame
		frame_time_remaining -= deltaTime / 1000; // convert deltaTime from milliseconds to seconds
		if(frame_time_remaining <= 0){
			// when enough frame time has elapsed, update the game
			game.update();
			// reset the counter
			frame_time_remaining = frame_duration;
		}
	}

	override function onKeyDown(keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void {
		game.on_key_down(keyCode);
	}

	override function onKeyUp(keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void {
		game.on_key_up(keyCode);
	}

	override function render(context:lime.graphics.RenderContext):Void {
		if (is_ready) {
			game.draw();
		}
	}

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
