package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.util.FlxFSM;
import flixel.addons.util.FlxFSM;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;

/**
 * ...
 * @author TJ
 */
class Boss extends FlxSprite implements LivingThing {
	
	private var fsm:FlxFSM<Boss>;

	public var xMaxVel:Float = 20;
	public var yMaxVel:Float = 500;
	public var playerDrag:Float = 1600;
	
	public var runSpeed:Float = 100;
	public var gravity:Float = 700;
	public var jumpSpeed:Float = -300;
	
	public var halfWidth:Float;
	public var halfHeight:Float;
	
	public var playerRef:Player;
	private var bullets:FlxTypedGroup<Bullet>;
	public var nameType:String = "boss";

	private var healthPoints:Int = 25;

	private var offsetX:Float;
	
	override public function new() {
		super(0, 0);
		
		makeGraphic(64, 256, FlxColor.ORANGE);
		halfWidth = 32;
		halfHeight = 128;
		
		fsm = new FlxFSM<Boss>(this, new Idle());
	}
	
	public function spawn(X:Float, Y:Float, offset:Float):Void {
		super.reset(X, Y);
		offsetX = offset;
	}
	
	override public function update(elapsed:Float):Void {
		if (!alive) {
			exists = false;
			return;
		}

		if(isOnScreen() && reachedLockingPosition()) {
			lockCamera();
			fsm.update(elapsed);
		}

		super.update(elapsed);
	}

	private function reachedLockingPosition() {
		return FlxG.camera.scroll.x > x + offsetX - (FlxG.width / 2);
	}

	private function lockCamera() {
		if(FlxG.camera.target != null) {
			FlxG.camera.follow(null);
		}
	}

	private function unlockCamera() {
		if(FlxG.camera.target == null) {
			FlxG.camera.follow(playerRef, FlxCameraFollowStyle.PLATFORMER, 0.1);
			FlxG.camera.targetOffset.set(100, 0);
		}
	}
	
	override public function destroy():Void {
		fsm.destroy();
		fsm = null;
		super.destroy();
	}
	
	public function setDependencies(player:Player, _bullets:FlxTypedGroup<Bullet>):Void {
		playerRef = player;
		bullets = _bullets;
	}
	
	public function shootBullet(yOffset):Void {
		bullets.recycle(Bullet).fireBullet(x+halfWidth, y+yOffset, 180, this);
	}
	
	public function hitByBullet(bullet: Bullet):Void {
		if(bullet.y < y + halfHeight) {
			bullet.kill();
			FlxFlicker.flicker(this, 0.5);
			if(--healthPoints <= 0) {
				unlockCamera();
				kill();
			}
		}
	}
}

private class Idle extends FlxFSMState<Boss> {
	private var ticker:Int = 0;
	
	override public function enter(owner:Boss, fsm:FlxFSM<Boss>):Void {
		ticker = 0;
		super.enter(owner, fsm);
	}
	
	override public function update(elapsed:Float, owner:Boss, fsm:FlxFSM<Boss>):Void {
		if (ticker++ > 200) {
			fsm.state = new Attack();
		}
		super.update(elapsed, owner, fsm);
	}
}

private class Attack extends FlxFSMState<Boss> {
	private var ticker:Int = 0;
	
	override public function enter(owner:Boss, fsm:FlxFSM<Boss>):Void {
		ticker = 0;
		super.enter(owner, fsm);
	}
	
	override public function update(elapsed:Float, owner:Boss, fsm:FlxFSM<Boss>):Void {
		if(ticker < 25) {
			if (ticker++ % 5 == 0) {
				owner.shootBullet(owner.halfHeight);
			}
		} else if(ticker < 50) {
			if (ticker++ % 5 == 0) {
				owner.shootBullet(owner.height);
			}
		} else if(ticker < 75) {
			if (ticker++ % 5 == 0) {
				owner.shootBullet(owner.halfHeight);
			}
		} else {
			if (ticker++ % 5 == 0) {
				owner.shootBullet(owner.height);
			}
		}
		if(ticker > 100) {
			fsm.state = new Idle();
		}
		super.update(elapsed, owner, fsm);
	}
}