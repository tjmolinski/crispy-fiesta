package;

import flixel.util.FlxColor;

class RawketLawnChairPickup extends GunPickup {
	override public function new() {
		super();
		
		loadGraphic("assets/images/rawketpickup.png", false, 32, 32);
		halfWidth = 16;
		halfHeight = 16;
	}

	override public function pickup(player: Player):Void {
		super.pickup(player);
		GameObjects.instance.rawketLawnChairs.recycle(RawketLawnChair).giveGun(player);
		kill();
	}
}