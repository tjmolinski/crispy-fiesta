package;

import flixel.util.FlxColor;

class MachineGunPickup extends GunPickup {
	override public function new() {
		super();
		
		loadGraphic("assets/images/machinegunpickup.png", false, 32, 32);
		halfWidth = 16;
		halfHeight = 16;
	}

	override public function pickup(player: Player):Void {
		super.pickup(player);
		GameObjects.instance.machineguns.recycle(MachineGun).giveGun(player);
		kill();
	}
}