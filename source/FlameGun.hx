package;

import flixel.group.FlxGroup;
import flixel.util.FlxColor;

class FlameGun extends Gun {

	override public function new(?X:Float=0, ?Y:Float=0) {
		super(X, Y);
		
		makeGraphic(32, 12, FlxColor.GRAY);
		halfWidth = 16;
		halfHeight = 6;

		gunOffsetX = 0;
		gunOffsetY = 0;

		cooldownTime = 0.5;
	}
	
	override public function shoot():Void {
		if(!inCooldown) {
			inCooldown = true;
			shootBullet(GameObjects.instance.flameBullets.recycle(FlameBullet), owner.direction, 0);
		}
	}
}