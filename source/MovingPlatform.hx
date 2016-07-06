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
	
	override public function new(_x:Int, _y:Int, _width:Int, _height:Int, _moveX:Float, _moveY:Float) 
	{
		super(_x, _y);
		
		makeGraphic(_width, _height, FlxColor.YELLOW);
		immovable = true;

		startX = _x;
		startY = _y;
		moveX = _moveX;
		moveY = _moveY;
		velocity.set(_moveX != 0 ? moveSpeed : 0,
					_moveY != 0 ? moveSpeed : 0);
		if(_moveX < 0) {
			velocity.x *= -1;
		}
		if(_moveY < 0) {
			velocity.y *= -1;
		}
		updateHitbox();
		allowCollisions = FlxObject.UP;
	}
	
	override public function update(elapsed:Float):Void
	{
		if(moveX < 0) {
			if (x < startX + moveX) {
				x = startX + moveX;
				velocity.x = moveSpeed;
			}
			if (x > startX) {
				x = startX;
				velocity.x = -moveSpeed;
			}
		} else {
			if (x < startX) {
				x = startX;
				velocity.x = moveSpeed;
			}
			if (x > startX + moveX) {
				x = startX + moveX;
				velocity.x = -moveSpeed;
			}
		}
		
		if(moveY < 0) {
			if (y < startY + moveY) {
				y = startY + moveY;
				velocity.y = moveSpeed;
			}
			if (y > startY) {
				y = startY;
				velocity.y = -moveSpeed;
			}
		} else {
			if (y < startY) {
				y = startY;
				velocity.y = moveSpeed;
			}
			if (y > startY + moveY) {
				y = startY + moveY;
				velocity.y = -moveSpeed;
			}
		}
		
		super.update(elapsed);
	}
}