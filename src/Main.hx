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
		var input = new Input(window);
		game = new Game(display, input, window.width, window.height);
		is_ready = true;
	}

	var fixed_frame_rate = 1 / 30;
	var fixed_time_acumulator:Float = 0.0;
	#if debug
	var frames:Array<Int> = [];
	#end
	override function update(deltaTime:Int) {
		if (is_ready) {
			#if debug
			frames.push(0);
			#end
			// update is called at window frame rate - 60 fps ish
			// game frame rate is fixed to 30 fps
			// only update game if fixed_frame_rate has elapsed
			fixed_time_acumulator += (deltaTime / 1000);
			while (fixed_time_acumulator > fixed_frame_rate) {
				fixed_time_acumulator -= fixed_frame_rate;
				game.update();
				#if debug
				frames.push(1);
				#end
			}

			// draw every frame
			// todo - interpolation?
			game.draw();
		}
	}

	override function onKeyDown(keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void {
		game.on_key_down(keyCode);
		#if debug
		if(keyCode == F){
			// should trace 	0,0,1,0,0,1 on 60 hz monitor 
		   // or					0,1,0,1,0,1 on 30 hz monitor 
			trace(frames); 
		}
		#end
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
