package engine.body;

import engine.body.skin.Skin;
import engine.body.physics.Physics;

@:publicFields
abstract class Body<TSkin:Skin, TPhysics:Physics> {
    var skin(default, null):TSkin;
    var physics(default, null):TPhysics;

    abstract private function on_collide(side_x:Int, side_y:Int):Void;
        
    function new(skin:TSkin, physics:TPhysics) {
        this.skin = skin;
        this.physics = physics;
        this.physics.events.on_collide = on_collide;
    }

    function update() {
        physics.update();
    }

    function draw(frame_ratio:Float) {
        var x = lerp(physics.position.x_previous, physics.position.x, frame_ratio);
        var y = lerp(physics.position.y_previous, physics.position.y, frame_ratio);
        skin.move(x, y);
    }
}