package;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;

/**
 * ...
 * @author TJ
 */
class Bullet extends FlxSprite {
	
	private var bulletSpeed:Float = 300;
	private var fireBulletSpeed:Float = 200;
	private var direction:Float = 0;
	private var halfWidth:Float;
	private var halfHeight:Float;
	public var owner:LivingThing;
	private var time:Float = 0;
	private var _angle:Float = 10;
	private var _radius:Float = 300;

	override public function new() {
		super();
	}
	
	override public function update(elapsed:Float):Void {
		if (!alive) {
			exists = false;
			return;
		}
		
		if (!isOnScreen()) {
			kill();
		}

		super.update(elapsed);
	}
	
	override public function kill():Void {
		owner = null;
		super.kill();
	}
	
	public function fireBullet(X:Float, Y:Float, dir:Float, _owner:LivingThing):Void {
		super.reset(X-halfWidth, Y-halfHeight);
		direction = dir;
		owner = _owner;
	}
}