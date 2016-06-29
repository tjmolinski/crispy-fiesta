package;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;

/**
 * ...
 * @author TJ
 */
class FlameBullet extends Bullet {

	override public function update(elapsed:Float):Void {
		if (!alive) {
			exists = false;
			return;
		}
		
		if (!isOnScreen()) {
			kill();
		}
		
		velocity.set(fireBulletSpeed + (Math.cos(time*_angle - (Math.PI/2)) * _radius), (Math.sin(time*_angle - (Math.PI/2)) * _radius));
      	velocity.rotate(FlxPoint.weak(90, 0), direction);
	}
}