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
		setAmmo(5);
		type = "rawket lawn chair";
	}
	
	override public function shoot():Bool {
		if(!inCooldown) {
			if(!super.shoot()) {
				return false;
			}
			inCooldown = true;
			shootBullet(GameObjects.instance.rawketBullets.recycle(RawketBullet), owner.direction, 0);
		}
		return false;
	}
	
}