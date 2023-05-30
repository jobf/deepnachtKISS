package engine;

class Constant {
	public static var milliseconds_per_second = 1000;
	public static var render_steps_per_second = 60;
}

@:structInit
class Update {
	/** called at start of every frame update **/
	public var start:() -> Void = () -> {}
	
	/** called for every game step at fixed rate, e.g. if frame update is 60 frames per second and fixed step is 30 per second  this will be called approximately every 2nd frame **/
	public var step:() -> Void = () -> {}

	/** called at end up update frame, step_ratio is a measurement of progress through the game step between 0 and 1, used for interpolation **/
	public var end:(step_ratio:Float) -> Void = (step_ratio) -> {}
}

@:access(Update)
class Loop {
	var update:Update;
	var step_duration:Float;
	var step_time_accumulator:Float;
	var step_ratio:Float;

	public function new(update:Update, steps_per_second:Int) {
		this.update = update;
		step_duration = Constant.milliseconds_per_second / steps_per_second;
		step_time_accumulator = 0;
		step_ratio = 0;
	}

	public function frame(elapsed_ms:Int) {
		update.start();

		step_time_accumulator += elapsed_ms;

		while (step_time_accumulator > step_duration) {
			update.step();
			step_time_accumulator -= step_duration;
		}

		step_ratio = step_time_accumulator / step_duration;

		update.end(step_ratio);
	}
}
