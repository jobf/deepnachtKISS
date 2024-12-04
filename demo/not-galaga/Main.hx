import engine.Input;
import haxe.CallStack;
import lime.app.Application;
import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Color;

class Main extends Application {
	var game:Game;

	override function onWindowCreate() {
		try {

			var peote_view = new PeoteView(window);
			var display = new Display(0, 0, window.width, window.height, Color.BLACK);
			peote_view.addDisplay(display);

			var input = new Input(window);
			game = new Game(display, input);

		} catch (_) {
			trace(CallStack.toString(CallStack.exceptionStack()), _);
		}
	}


	override function update(deltaTime:Int) {
		game.frame(deltaTime);
	}

}
