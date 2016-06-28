package;

import flixel.group.FlxGroup;
import flixel.util.FlxColor;

class Pistol extends Gun {

	override public function new(?X:Float=0, ?Y:Float=0) {
		super(X, Y);
		
		makeGraphic(24, 12, FlxColor.GRAY);
		halfWidth = 12;
		halfHeight = 6;

		gunOffsetX = 6;
		gunOffsetY = 0;
	}
	
	override public function shoot(bullets: FlxTypedGroup<Bullet>):Void {
		shootBullet(bullets, owner.direction);
	}
}