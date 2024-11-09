package engine;

import lime.ui.Gamepad;
import input2action.*;
import lime.ui.KeyCode;
import lime.ui.GamepadButton;
import lime.ui.Window;

@:structInit
class Controller {
	public var left:Action = {};
	public var right:Action = {};
	public var up:Action = {};
	public var down:Action = {};
	public var a:Action = {};
	public var b:Action = {};
	public var start:Action = {};
	public var select:Action = {};
}

@:structInit
class Action {
	public var on_press:Void->Void = () -> return;
	public var on_release:Void->Void = () -> return;
}

class Input {
	var actionConfig:ActionConfig;
	var actionMap:ActionMap;
	var controllers:Array<Controller> = [];

	public function new(window:Window) {
		actionConfig = [
			{
				gamepad: GamepadButton.DPAD_LEFT,
				keyboard: [KeyCode.LEFT, KeyCode.A],
				action: "left"
			},
			{
				gamepad: GamepadButton.DPAD_RIGHT,
				keyboard: [KeyCode.RIGHT, KeyCode.D],
				action: "right"
			},
			{
				gamepad: GamepadButton.DPAD_UP,
				keyboard: [KeyCode.UP, KeyCode.W],
				action: "up"
			},
			{
				gamepad: GamepadButton.DPAD_DOWN,
				keyboard: [KeyCode.DOWN, KeyCode.S],
				action: "down"
			},
			{
				gamepad: GamepadButton.B,
				keyboard: KeyCode.O,
				action: "b"
			},
			{
				gamepad: GamepadButton.A,
				keyboard: [KeyCode.LEFT_CTRL, KeyCode.RIGHT_CTRL],
				action: "a"
			},
			{
				gamepad: GamepadButton.BACK,
				keyboard: KeyCode.BACKSPACE,
				action: "back"
			},
			{
				gamepad: GamepadButton.START,
				keyboard: KeyCode.RETURN,
				action: "start"
			}
		];

		actionMap = [
			"left" => {
				action: (isDown, player) -> {
					if (isDown) {
						controllers[player].left.on_press();
					} else {
						controllers[player].left.on_release();
					}
				},
				up: true
			},
			"right" => {
				action: (isDown, player) -> {
					if (isDown) {
						controllers[player].right.on_press();
					} else {
						controllers[player].right.on_release();
					}
				},
				up: true
			},
			"up" => {
				action: (isDown, player) -> {
					if (isDown) {
						controllers[player].up.on_press();
					} else {
						controllers[player].up.on_release();
					}
				},
				up: true
			},
			"down" => {
				action: (isDown, player) -> {
					if (isDown) {
						controllers[player].down.on_press();
					} else {
						controllers[player].down.on_release();
					}
				},
				up: true
			},
			"b" => {
				action: (isDown, player) -> {
					if (isDown) {
						controllers[player].b.on_press();
					} else {
						controllers[player].b.on_release();
					}
				},
				up: true
			},
			"a" => {
				action: (isDown, player) -> {
					if (isDown) {
						controllers[player].a.on_press();
					} else {
						controllers[player].a.on_release();
					}
				},
				up: true
			},
			"back" => {
				action: (isDown, player) -> {
					if (isDown) {
						controllers[player].select.on_press();
					} else {
						controllers[player].select.on_release();
					}
				},
				up: true
			},
			"start" => {
				action: (isDown, player) -> {
					if (isDown) {
						controllers[player].start.on_press();
					} else {
						controllers[player].start.on_release();
					}
				},
				up: true
			},
		];

		var input2Action = new Input2Action();
		var keyboard_action = new KeyboardAction(actionConfig, actionMap);
		input2Action.addKeyboard(keyboard_action);

		Gamepad.onConnect.add(gamepad ->
		{
			var gamepad_action = new GamepadAction(gamepad.id, actionConfig, actionMap);
			input2Action.addGamepad(gamepad, gamepad_action);
			gamepad.onDisconnect.add(() -> input2Action.removeGamepad(gamepad));
		});

		input2Action.registerKeyboardEvents(window);
	}

	public function registerController(controller:Controller) {
		controllers.push(controller);
	}
}
