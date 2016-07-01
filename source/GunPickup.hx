package;

import flixel.FlxSprite;

class GunPickup extends FlxSprite {
	private var halfWidth:Float;
	private var halfHeight:Float;

	override public function new() {
		super();
	}
	
	override public function update(elapsed:Float):Void {
		if (!alive) {
			exists = false;
			return;
		}

		super.update(elapsed);
	}
	
	override public function kill():Void {
		super.kill();
	}
	
	public function spawn(X:Float, Y:Float):Void {
		super.reset(X, Y);
	}

	public function pickup(player: Player):Void {}
}