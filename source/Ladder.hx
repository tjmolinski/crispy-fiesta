package;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.FlxObject;

/**
 * ...
 * @author TJ
 */
class Ladder extends FlxSprite 
{
	public var isHead:Bool;
	
	override public function new(?X:Int=0, ?Y:Int=0, _isHead:Bool) 
	{
		super(X, Y);
		
		makeGraphic(32, 32, FlxColor.GREEN);
		immovable = true;
		isHead = _isHead;
		if (isHead) {
			allowCollisions = FlxObject.UP;
		}
	}
	
}