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

	override function onWindowCreate() {
		try {
			var peote_view = new PeoteView(window);
			var display = new Display(0, 0, window.width, window.height, Color.GREY1);
			peote_view.addDisplay(display);
			var input = new Input(window);
			game = new Game(display, input, window.width, window.height);
			is_ready = true;
		} catch (_) {
			trace(CallStack.toString(CallStack.exceptionStack()), _);
		}
	}

	override function update(deltaTime:Int) {
		if (is_ready) {
			game.frame(deltaTime);
		}
	}

	override function onKeyDown(keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void {
		game.on_key_down(keyCode);
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
