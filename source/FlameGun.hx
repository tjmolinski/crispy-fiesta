package;

import flixel.group.FlxGroup;
import flixel.util.FlxColor;

class FlameGun extends Gun {

	override public function new(?X:Float=0, ?Y:Float=0) {
		super(X, Y);
		
		makeGraphic(12, 12, FlxColor.GRAY);
		halfWidth = 6;
		halfHeight = 6;

		gunOffsetX = 12;
		gunOffsetY = 0;

		cooldownTime = 0.1;
	}
	
	override public function shoot(bullets: FlxTypedGroup<Bullet>):Void {
		if(!inCooldown) {
			inCooldown = true;
			shootBullet(bullets, owner.direction);
		}
	}
}