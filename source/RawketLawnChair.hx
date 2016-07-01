package;

import flixel.util.FlxColor;

class RawketLawnChair extends Gun {

	override public function new(?X:Float=0, ?Y:Float=0) {
		super(X, Y);
		
		makeGraphic(32, 24, FlxColor.PINK);
		halfWidth = 16;
		halfHeight = 12;

		gunOffsetX = 6;
		gunOffsetY = 0;

		cooldownTime = 1.5;
	}
	
	override public function shoot():Void {
		if(!inCooldown) {
			inCooldown = true;
			shootBullet(GameObjects.instance.rawketBullets.recycle(RawketBullet), owner.direction, 0);
		}
	}
	
}