package;

import flixel.util.FlxColor;

class SpreaderGunPickup extends GunPickup {
	override public function new() {
		super();
		
		makeGraphic(32, 32, FlxColor.ORANGE);
		halfWidth = 16;
		halfHeight = 16;
	}

	override public function pickup(player: Player):Void {
		super.pickup(player);
		GameObjects.instance.shotguns.recycle(Shotgun).giveGun(player);
		kill();
	}
}