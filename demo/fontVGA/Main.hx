import haxe.CallStack;
import lime.app.Application;
import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Color;

class Main extends Application {
	override function onWindowCreate() {
		try {

			var peoteView = new PeoteView(window);
			var display = new Display(0, 0, window.width, window.height, Color.BLACK);
			peoteView.addDisplay(display);

			new Demo(display);

		} catch (_) {
			trace(CallStack.toString(CallStack.exceptionStack()), _);
		}
	}
}
