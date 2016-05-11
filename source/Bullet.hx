package;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;

/**
 * ...
 * @author TJ
 */
class Bullet extends FlxSprite 
{
	
	private var bulletSpeed:Float = 250;
	private var direction:Float = 0;

	override public function new(?X:Float=0, ?Y:Float=0) 
	{
		super(X, Y);
		
		makeGraphic(8, 8, FlxColor.YELLOW);
	}
	
	override public function update(elapsed:Float):Void
	{
		if (!alive)
		{
			exists = false;
		}
		
		if (!isOnScreen())
		{
			kill();
		}
		
		velocity.set(bulletSpeed, 0);
      	velocity.rotate(FlxPoint.weak(0, 0), direction);
		
		super.update(elapsed);
	}
	
	public function fireBullet(X:Float, Y:Float, dir:Float):Void
	{
		super.reset(X, Y);
		direction = dir;
	}
	
}