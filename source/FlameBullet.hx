package;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;

/**
 * ...
 * @author TJ
 */
class FlameBullet extends Bullet {

	override public function new() {
		super();
		
		makeGraphic(8, 8, FlxColor.ORANGE);
		halfWidth = width / 2;
		halfHeight = height / 2;
	}

	override public function update(elapsed:Float):Void {
		velocity.set(fireBulletSpeed + (Math.cos(time*_angle - (Math.PI/2)) * _radius), (Math.sin(time*_angle - (Math.PI/2)) * _radius));
      	velocity.rotate(FlxPoint.weak(0, 0), direction);
		time += elapsed;
		super.update(elapsed);
	}
}