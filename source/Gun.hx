package;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;

/**
 * ...
 * @author TJ
 */
class Gun extends FlxSprite {
	
	private var owner: Dynamic;
	private var halfWidth: Int;
	private var halfHeight: Int;
	private var springiness: Float = 0.5;

	override public function new(?X:Float=0, ?Y:Float=0) {
		super(X, Y);
	}
	
	override public function update(elapsed:Float):Void {
		if (!alive) {
			exists = false;
			return;
		}
		
		if(owner != null) {
			var targetX = owner.x + owner.gunOffsetX;
			var targetY = owner.y + owner.gunOffsetY;

			x += (targetX - x) * springiness;
			y += (targetY - y) * springiness;
		}
		
		super.update(elapsed);
	}
	
	override public function kill():Void {
		owner = null;
		super.kill();
	}
	
	public function giveGun(_owner:Dynamic):Void {
		super.reset(_owner.x, _owner.y);
		owner = _owner;
		owner.giveGun(this);
	}
}