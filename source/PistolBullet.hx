package;

import flixel.math.FlxPoint;
import flixel.util.FlxColor;

class PistolBullet extends Bullet {

	override public function new() {
		super();
		
		loadGraphic("assets/images/bullet.png", true, 6, 6);
		animation.add("life", [0,1,2,3,4], 10, true);
		animation.play("life");
		scale.set(1.5, 1.5);
		halfWidth = width / 2;
		halfHeight = height / 2;
	}
	
	override public function update(elapsed:Float):Void {
		velocity.set(bulletSpeed, 0);
		velocity.rotate(FlxPoint.weak(0, 0), direction);
		super.update(elapsed);
	}
}