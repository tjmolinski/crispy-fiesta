package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;

/**
 * ...
 * @author TJ
 */
class Laser extends FlxSprite {
	
	private var lifeSpan:Float = 50;
	private var lifeBuffer:Float = 0;
	private var direction:Float = 0;
	private var halfWidth:Float;
	private var halfHeight:Float;
	public var owner:LivingThing;

	override public function new(?X:Float=0, ?Y:Float=0) {
		super(X, Y);
		
		makeGraphic(FlxG.width, 32, FlxColor.CYAN);
		halfWidth = width / 2;
		halfHeight = height / 2;
	}
	
	override public function update(elapsed:Float):Void {
		if (!alive) {
			exists = false;
			return;
		}
		
		if (lifeBuffer > lifeSpan) {
			kill();
		} else {
			lifeBuffer++;
		}
		
		super.update(elapsed);
	}
	
	override public function kill():Void {
		owner = null;
		super.kill();
	}
	
	public function fireLaser(X:Float, Y:Float, _owner:LivingThing):Void {
		super.reset(X-width, Y);
		owner = _owner;
	}
}