package;
import flixel.FlxSprite;
import flixel.util.FlxColor;

/**
 * ...
 * @author TJ
 */
class Spike extends FlxSprite {

	override public function new() {
		super();
		
		makeGraphic(16, 16, FlxColor.RED);
	}
	
	override public function update(elapsed: Float):Void {
		if (!alive) {
			return;
		}
		
		super.update(elapsed);
	}
	
	public function spawn(posX: Float, posY: Float) {
		super.reset(posX, posY);
	}
}