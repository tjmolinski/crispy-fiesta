package;

import flixel.FlxSprite;
import flixel.util.FlxColor;

class Pistol extends Gun {

	override public function new(?X:Float=0, ?Y:Float=0) {
		super(X, Y);
		
		makeGraphic(24, 12, FlxColor.GRAY);
		halfWidth = 12;
		halfHeight = 6;
	}
	
	override public function update(elapsed:Float):Void {
		super.update(elapsed);
	}
}