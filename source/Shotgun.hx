package;

import flixel.group.FlxGroup;
import flixel.util.FlxColor;

class Shotgun extends Gun {

	override public function new(?X:Float=0, ?Y:Float=0) {
		super(X, Y);
		
		makeGraphic(24, 12, FlxColor.GREEN);
		halfWidth = 12;
		halfHeight = 6;

		gunOffsetX = 6;
		gunOffsetY = 0;

		cooldownTime = 1.0;
	}
	
	override public function shoot():Void {
		if(!inCooldown) {
			inCooldown = true;
			shootBullet(owner.direction - 20);
			shootBullet(owner.direction - 10);
			shootBullet(owner.direction);
			shootBullet(owner.direction + 10);
			shootBullet(owner.direction + 20);
		}
	}
}