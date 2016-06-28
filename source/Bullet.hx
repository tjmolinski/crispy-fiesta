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
	private var direction:Float = 0;
	private var halfWidth:Float;
	private var halfHeight:Float;
	public var owner:LivingThing;

	override public function new(?X:Float=0, ?Y:Float=0) {
		super(X, Y);
		
		makeGraphic(8, 8, FlxColor.YELLOW);
		halfWidth = width / 2;
		halfHeight = height / 2;
	}
	
	override public function update(elapsed:Float):Void {
		if (!alive) {
			exists = false;
			return;
		}
		
		if (!isOnScreen()) {
			kill();
		}
		
		velocity.set(bulletSpeed, 0);
      	velocity.rotate(FlxPoint.weak(0, 0), direction);
		
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