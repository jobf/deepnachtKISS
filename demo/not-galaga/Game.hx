import engine.actor.Projectile;
import engine.ObjectCache;
import engine.Loop;
import engine.Input;
import peote.view.text.TextOptions;
import engine.graphics.elements.Basic;
import peote.view.text.TextProgram;
import peote.view.text.Text;
import peote.view.*;
import engine.body.physics.Physics;
import engine.body.Body;
import engine.body.skin.SkinBasic;

class Game {
	var hero:SpaceCraft;
	var loop:Loop;
	var targets:Array<SpaceCraft>;
	var sprites:Buffer<Basic>;
	var is_ready:Bool;
	var projectiles:ObjectCache<Projectile>;

	public function new(display:Display, input:Input) {
		var formation = ["   oooo   ", " oooooooo ", " oooooooo ", "oooooooooo", "oooooooooo",];

		var size = 48;
		var ctr = size * 0.5;

		var gap = 12;
		var space = size + gap;
		var edge = size * 1.5;

		var line_width = (space * formation[0].length);
		var x_display = display.width * 0.5;
		var y_display = display.height * 0.5;
		var x_ctr = x_display - (line_width * 0.5) + ctr;
		var y_ctr = y_display - (line_width * 0.5) + ctr + edge;

		sprites = SpaceCraft.init(display);

		var projectile_count = 50;
		var projectile_size = 8;
		projectiles = new ObjectCache(projectile_count, () -> {
			var projectile = new Projectile(4, projectile_size, (grid_x, grid_y) -> false);
			projectile.skin.change_tint(0xffd677F0);
			projectile.skin.add_to_buffer(sprites);
			projectile;
		}, projectile -> projectile.on_cache());

		targets = [];
		for (row => line in formation) {
			for (col in 0...line.length) {
				if (line.charAt(col) != ' ') {
					var x = (col * space) + x_ctr;
					var y = (row * space) + y_ctr;
					targets.push(new SpaceCraft(x, y, size, sprites, projectiles));
				}
			}
		}

		var x = x_display;
		var y = display.height - edge;

		hero = new SpaceCraft(x, y, size, sprites, projectiles);

		var hud = new Hud(display, 32);
		input.registerController({
			left: {
				on_press: () -> hero.change_direction_x(-1),
				on_release: () -> hero.stop_x()
			},
			right: {
				on_press: () -> hero.change_direction_x(1),
				on_release: () -> hero.stop_x()
			},
			a: {
				on_press: () -> hero.fire(),
				on_release: () -> hero.fire()
			},
		});

		var fixed_steps_per_second = 20;

		loop = new Loop({
			step: () -> fixed_step_update(),
			end: frame_ratio -> draw(frame_ratio),
		}, fixed_steps_per_second);

		is_ready = true;
	}

	public function frame(elapsed_ms:Int) {
		if (is_ready) {
			loop.frame(elapsed_ms);
		}
	}

	function fixed_step_update() {
		hero.update();
		for (ship in targets) {
			ship.update();
		}

		projectiles.iterate_active(projectile -> {
			projectile.update();
			return projectile.physics.position.y < 64;
		});
	}

	function draw(frame_ratio:Float) {
		hero.draw(frame_ratio);

		for (ship in targets) {
			ship.draw(frame_ratio);
		}

		projectiles.iterate_all(projectile -> projectile.draw(frame_ratio));

		sprites.update();
	}
}

class PhysicsGalaga extends Physics {
	public function new(x:Float, y:Float, size:Int) {
		super(0, 0, size, (grid_x, grid_y) -> false);
		velocity.friction_x = 0;
	}

	public function update() {
		position.x_previous = position.x;
		position.y_previous = position.y;
		position.x += velocity.delta_x;
	}
}

class SpaceCraft extends Body<SkinBasic, PhysicsGalaga> {
	function on_collide(side_x:Int, side_y:Int) {}

	var projectiles:ObjectCache<Projectile>;

	static function init(display:Display) {
		var buffer = new Buffer<Basic>(256);
		var program = new Program(buffer);
		program.addToDisplay(display);
		return buffer;
	}

	public function new(x:Float, y:Float, size:Int, buffer:Buffer<Basic>, projectiles:ObjectCache<Projectile>) {
		this.projectiles = projectiles;
		var skin = new SkinBasic(x, y, size);
		skin.add_to_buffer(buffer);
		super(skin, new PhysicsGalaga(x, y, size));
		physics.teleport_to(x, y);
	}

	public function change_direction_x(direction:Int) {
		physics.velocity.delta_x = 20 * direction;
	}

	public function stop_x() {
		physics.velocity.delta_x = 0;
	}

	public function fire() {
		var missile = projectiles.get_item();
		if (missile != null) {
			missile.revive();
			missile.physics.teleport_to(physics.position.x, physics.position.y);
			missile.acceleration_y = -100.8;
			missile.skin.change_alpha(1.0);
		}
	}
}

class Hud {
	var texts:TextProgram;
	var labels:Array<Text>;

	public function new(display:Display, letterSize:Int) {
		var options:TextOptions = {
			letterWidth: letterSize,
			letterHeight: letterSize,
		};

		texts = new TextProgram(options);
		texts.addToDisplay(display);

		var infos = ["000000000", " Top:", "000000000",];

		var x = 0;
		labels = [
			for (s in infos) {
				var t = new Text(x, 0, s);
				texts.add(t);
				x += (s.length * letterSize) + letterSize;
				t;
			}
		];
	}
}
