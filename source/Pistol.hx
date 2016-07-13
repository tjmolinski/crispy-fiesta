package;

import flixel.group.FlxGroup;
import flixel.util.FlxColor;

class Pistol extends Gun {

	override public function new(?X:Float=0, ?Y:Float=0) {
		super(X, Y);
		
		makeGraphic(12, 12, FlxColor.GRAY);
		halfWidth = 6;
		halfHeight = 6;

		gunOffsetX = 12;
		gunOffsetY = 0;

		cooldownTime = 0.1;
		setAmmo(-1);
		type = "pistol";
	}
	
	override public function shoot():Bool {
		if(!inCooldown) {
			super.shoot();
			inCooldown = true;
			shootBullet(GameObjects.instance.pistolBullets.recycle(PistolBullet), owner.direction, Math.random() * 2 - 1);
		}
		return false;
	}
}