package;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.util.FlxFSM;
import flixel.util.FlxColor;

/**
 * ...
 * @author TJ
 */
class DisappearingPlatform extends FlxSprite 
{
	private var fsm:FlxFSM<DisappearingPlatform>;
	public var visibleState:Bool = true;
	
	override public function new(_x:Int, _y:Int, _width:Int, _height:Int) 
	{
		super(_x, _y);
		
		makeGraphic(_width, _height, FlxColor.MAGENTA);
		immovable = true;

		fsm = new FlxFSM<DisappearingPlatform>(this, new Visible());
		fsm.transitions
			.add(Visible, Invisible, Conditions.isInvisible)
			.add(Invisible, Visible, Conditions.isVisible)
			.start(Visible);
	}
	
	override public function update(elapsed:Float):Void
	{
		fsm.update(elapsed);

		super.update(elapsed);
	}

	public function startDisappear():Void {
		visibleState = false;
	}
}

private class Conditions {
	public static function isInvisible(owner:DisappearingPlatform):Bool {
		return !owner.visibleState;
	}
	
	public static function isVisible(owner:DisappearingPlatform):Bool {
		return owner.visibleState;
	}
}

private class Visible extends FlxFSMState<DisappearingPlatform> {
	override public function enter(owner:DisappearingPlatform, fsm:FlxFSM<DisappearingPlatform>):Void {
		super.enter(owner ,fsm);
	}
	
	override public function update(elapsed:Float, owner:DisappearingPlatform, fsm:FlxFSM<DisappearingPlatform>):Void {
		if(owner.alpha <= 0.9) {
			owner.alpha += 0.1;
			if(owner.alpha > 1.0) {
				owner.alpha = 1.0;
			}
		}
		super.update(elapsed, owner, fsm);
	}
	
	override public function exit(owner:DisappearingPlatform):Void {
		super.exit(owner);
	}
}

private class Invisible extends FlxFSMState<DisappearingPlatform> {
	private var ticks:Int = 0;
	private var respawnTime:Int = 250;

	override public function enter(owner:DisappearingPlatform, fsm:FlxFSM<DisappearingPlatform>):Void {
		super.enter(owner ,fsm);
		ticks = 0;
	}
	
	override public function update(elapsed:Float, owner:DisappearingPlatform, fsm:FlxFSM<DisappearingPlatform>):Void {
		if(owner.alpha >= 0.1) {
			owner.alpha -= 0.1;
			if(owner.alpha < 0.1) {
				owner.alpha = 0.0;
			}
		}

		if(owner.alpha == 0.0) {
			if(ticks++ > respawnTime) {
				owner.visibleState = true;
			}
		}

		super.update(elapsed, owner, fsm);
	}
	
	override public function exit(owner:DisappearingPlatform):Void {
		super.exit(owner);
	}
}