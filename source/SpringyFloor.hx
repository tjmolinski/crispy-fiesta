package;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxColor;

/**
 * ...
 * @author TJ
 */
class SpringyFloor extends FlxSprite {
	
	public var halfWidth:Float;
	public var halfHeight:Float;
	
	override public function new(_x:Int, _y:Int, _width:Int, _height:Int) {
		super(_x, _y);
		makeGraphic(_width, _height, FlxColor.GREEN);
		halfWidth = _width / 2;
		halfHeight = _height / 2;
		immovable = true;
	}
	
	override public function update(elapsed:Float):Void {
		super.update(elapsed);
	}
}