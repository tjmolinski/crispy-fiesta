package;

import flixel.util.FlxColor;

class SpreaderGunPickup extends GunPickup {
	override public function new() {
		super();
		
		loadGraphic("assets/images/spreaderpickup.png", false, 32, 32);
		halfWidth = 16;
		halfHeight = 16;
	}

	override public function pickup(player: Player):Void {
		super.pickup(player);
		GameObjects.instance.shotguns.recycle(Shotgun).giveGun(player);
		kill();
	}
}