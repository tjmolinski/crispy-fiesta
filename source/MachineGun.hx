package;

import flixel.group.FlxGroup;
import flixel.util.FlxColor;

class MachineGun extends Gun {

	private var burst1Time: Float = 0.05;
	private var burst2Time: Float = 0.1;
	private var burst3Time: Float = 0.15;
	private var burstIdx: Int = 0;

	override public function new(?X:Float=0, ?Y:Float=0) {
		super(X, Y);
		
		makeGraphic(24, 12, FlxColor.BLUE);
		halfWidth = 12;
		halfHeight = 6;

		gunOffsetX = 6;
		gunOffsetY = 0;

		cooldownTime = 0.25;
	}

	override public function update(elapsed: Float):Void {
		super.update(elapsed);

		if(inCooldown) {
			if(cooldownBuffer > burst1Time && burstIdx == 0) {
				shootBullet(GameObjects.instance.pistolBullets.recycle(PistolBullet), owner.direction, Math.random()*2 - 1);
				burstIdx++;
			} else if(cooldownBuffer > burst2Time && burstIdx == 1) {
				shootBullet(GameObjects.instance.pistolBullets.recycle(PistolBullet), owner.direction, Math.random()*2 - 1);
				burstIdx++;
			} else if(cooldownBuffer > burst3Time && burstIdx == 2) {
				shootBullet(GameObjects.instance.pistolBullets.recycle(PistolBullet), owner.direction, Math.random()*2 - 1);
				burstIdx++;
			}
		} else {
			burstIdx = 0;
		}
	}
	
	override public function shoot():Void {
		if(!inCooldown) {
			inCooldown = true;
			shootBullet(GameObjects.instance.pistolBullets.recycle(PistolBullet), owner.direction, Math.random()*2 - 1);
		}
	}
}