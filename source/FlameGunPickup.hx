package;

import flixel.util.FlxColor;

class FlameGunPickup extends GunPickup {
	override public function new() {
		super();
		
		makeGraphic(32, 32, FlxColor.GRAY);
		halfWidth = 16;
		halfHeight = 16;
	}

	override public function pickup(player: Player):Void {
		super.pickup(player);
		GameObjects.instance.flameguns.recycle(FlameGun).giveGun(player);
		kill();
	}
}