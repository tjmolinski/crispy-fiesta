package;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.FlxObject;

/**
 * ...
 * @author TJ
 */
class MovingPlatform extends FlxSprite 
{
	private var startX:Float;
	private var startY:Float;
	private var moveX:Float;
	private var moveY:Float;
	
	private var moveSpeed:Float = 50;
	
	override public function new(_x:Float, _y:Float, _width:Int, _height:Int, _moveX:Float, _moveY:Float) 
	{
		super(_x, _y);
		
		makeGraphic(_width, _height, FlxColor.YELLOW);
		immovable = true;
		startX = _x;
		startY = _y;
		moveX = _moveX;
		moveY = _moveY;
		velocity.set(_moveX != 0 ? moveSpeed : 0, _moveY != 0 ? moveSpeed : 0);
	}
	
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		if (x < startX) {
			x = startX;
			velocity.x = moveX;
		}
		if (y < startY) {
			y = startY;
			velocity.y = moveY;
		}
		if (x > startX + moveX) {
			x = startX + moveX;
			velocity.x = -moveX;
		}
		if (y > startY + moveY) {
			y = startY + moveY;
			velocity.y = -moveY;
		}
	}
}