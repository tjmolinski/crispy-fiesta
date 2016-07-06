package;

import flixel.util.FlxColor;

class FlameGunPickup extends GunPickup {
	override public function new() {
		super();
		
		loadGraphic("assets/images/firepickup.png", false, 32, 32);
		halfWidth = 16;
		halfHeight = 16;
	}

	override public function pickup(player: Player):Void {
		super.pickup(player);
		GameObjects.instance.flameguns.recycle(FlameGun).giveGun(player);
		kill();
	}
}