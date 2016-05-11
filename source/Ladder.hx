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
	
	override public function new(?X:Float=0, ?Y:Float=0, _isHead:Bool) 
	{
		super(X, Y);
		
		makeGraphic(8, 8, FlxColor.GREEN);
		immovable = true;
		isHead = _isHead;
		if (isHead) {
			allowCollisions = FlxObject.UP;
		}
	}
	
}