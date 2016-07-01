package;

import flixel.math.FlxPoint;
import flixel.util.FlxColor;

class PistolBullet extends Bullet {

	override public function new() {
		super();
		
		makeGraphic(8, 8, FlxColor.YELLOW);
		halfWidth = width / 2;
		halfHeight = height / 2;
	}
	
	override public function update(elapsed:Float):Void {
		velocity.set(bulletSpeed, 0);
		velocity.rotate(FlxPoint.weak(0, 0), direction);
		super.update(elapsed);
	}
}