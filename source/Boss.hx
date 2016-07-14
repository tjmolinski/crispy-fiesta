package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.addons.display.FlxNestedSprite;
import flixel.addons.util.FlxFSM;
import flixel.addons.util.FlxFSM;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

/**
 * ...
 * @author TJ
 */
class Boss extends FlxNestedSprite implements LivingThing {
	
	private var fsm:FlxFSM<Boss>;

	public var xMaxVel:Float = 20;
	public var yMaxVel:Float = 500;
	public var playerDrag:Float = 1600;
	
	public var runSpeed:Float = 100;
	public var gravity:Float = 700;
	public var jumpSpeed:Float = -300;
	public var direction:Float = 0;
	
	public var halfWidth:Float;
	public var halfHeight:Float;
	
	public var nameType:String = "boss";

	private var healthPoints:Int = 25;

	private var offsetObject:FlxObject;

	public var body:FlxNestedSprite;
	public var weakSpot:FlxNestedSprite;
	public var laser:FlxNestedSprite;
	
	override public function new() {
		super(0, 0);
		
		body = new FlxNestedSprite();
		body.makeGraphic(64, 256, FlxColor.ORANGE);
		add(body);

		weakSpot = new FlxNestedSprite();
		weakSpot.relativeY = 128;
		weakSpot.makeGraphic(64, 64, FlxColor.RED);
		add(weakSpot);

		laser = new FlxNestedSprite();
		laser.relativeY = 96;
		laser.makeGraphic(64, 32, FlxColor.GREEN);
		add(laser);

		halfWidth = 32;
		halfHeight = 128;
		
		fsm = new FlxFSM<Boss>(this, new Idle());
	}
	
	public function spawn(X:Float, Y:Float, offset:Float):Void {
		super.reset(X, Y);
		offsetObject = new FlxObject(x + offset, 0);
	}
	
	override public function update(elapsed:Float):Void {
		if (!alive) {
			exists = false;
			return;
		}

		if(isOnScreen()) {
			lockCamera();
			fsm.update(elapsed);
		}

		super.update(elapsed);
	}

	private function lockCamera() {
		if(FlxG.camera.target != offsetObject) {
			FlxG.camera.follow(offsetObject, FlxCameraFollowStyle.PLATFORMER, 0.05);
		}
	}

	private function unlockCamera() {
		if(FlxG.camera.target == offsetObject) {
			FlxG.camera.follow(GameObjects.instance.player.sprite, FlxCameraFollowStyle.PLATFORMER, 0.1);
			FlxG.camera.targetOffset.set(100, 0);
		}
	}
	
	override public function destroy():Void {
		fsm.destroy();
		fsm = null;
		super.destroy();
	}
	
	public function shootLaser(yOffset):Void {
		GameObjects.instance.lasers.recycle(Laser).fireLaser(x+halfWidth, y+yOffset, this);
	}
	
	public function hitByBullet(bullet: Bullet):Void {
		bullet.kill();
		FlxFlicker.flicker(this, 0.5);
		if(--healthPoints <= 0) {
			unlockCamera();
			kill();
		}
	}
	
	public function hitByLaser(laser: Laser):Void {
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
		if(ticker < 100) {
			owner.shootLaser(owner.laser.relativeY);
			fsm.state = new ShiftLaser();
		}
		super.update(elapsed, owner, fsm);
	}
}

private class ShiftLaser extends FlxFSMState<Boss> {
	private var startingHeight:Float;
	private var targetHeight:Float;

	override public function enter(owner:Boss, fsm:FlxFSM<Boss>):Void {
		startingHeight = owner.laser.relativeY;
		targetHeight = startingHeight == 96 ? 222 : 96;
	}

	override public function update(elapsed:Float, owner:Boss, fsm:FlxFSM<Boss>):Void {
		FlxTween.tween(owner.laser, { relativeY: targetHeight }, 2, {
			onComplete: function(tween:FlxTween) {
				fsm.state = new Idle();
			},
			ease: FlxEase.cubeInOut
		});
	}
}