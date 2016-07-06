package;
import flixel.FlxSprite;
import flixel.util.FlxColor;

/**
 * ...
 * @author TJ
 */
class Exit extends FlxSprite {

	override public function new() {
		super();
		
		loadGraphic("assets/images/exit.png", false, 70, 70);
	}
	
	override public function update(elapsed: Float):Void {
		if (!alive) {
			return;
		}
		
		super.update(elapsed);
	}
	
	public function spawn(posX: Float, posY: Float, _width: Float, _height: Float) {
		super.reset(posX, posY);
		scale.set( _width / width, _height / height );
		updateHitbox();
	}
}