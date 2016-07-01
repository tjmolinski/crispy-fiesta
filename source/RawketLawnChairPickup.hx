package;

import flixel.util.FlxColor;

class RawketLawnChairPickup extends GunPickup {
	override public function new() {
		super();
		
		makeGraphic(32, 32, FlxColor.BLACK);
		halfWidth = 16;
		halfHeight = 16;
	}

	override public function pickup(player: Player):Void {
		super.pickup(player);
		GameObjects.instance.rawketLawnChairs.recycle(RawketLawnChair).giveGun(player);
		kill();
	}
}