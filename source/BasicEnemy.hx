package;

import flixel.FlxBasic;
import flixel.math.FlxPoint;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.group.FlxGroup;
	
import flixel.addons.util.FlxFSM;

/**
 * ...
 * @author TJ
 */
class BasicEnemy extends FlxSprite implements LivingThing
{
	
	private var fsm:FlxFSM<BasicEnemy>;

	public var xMaxVel:Float = 20;
	public var yMaxVel:Float = 500;
	public var playerDrag:Float = 1600;
	
	public var runSpeed:Float = 100;
	public var gravity:Float = 700;
	public var jumpSpeed:Float = -300;
	public var direction:Float = 0;
	
	public var halfWidth:Float;
	public var halfHeight:Float;
	
	private var bullets:FlxTypedGroup<Bullet>;
	public var nameType:String = "basic enemy";
	
	override public function new() {
		super(0, 0);
		
		makeGraphic(32, 32, FlxColor.PINK);
		halfWidth = 16;
		halfHeight = 16;
		
		drag.set(playerDrag, playerDrag);
		acceleration.set(0, gravity);
		maxVelocity.set(xMaxVel, yMaxVel);
		
		fsm = new FlxFSM<BasicEnemy>(this, new Scout());
		fsm.transitions
			.add(Scout, Attack, Conditions.seeEnemy)
			.add(Attack, Scout, Conditions.lostEnemy)
			.start(Scout);
	}
	
	public function spawn(X:Float, Y:Float, _isWalkingLeft:Bool):Void {
		super.reset(X, Y);
		
		flipX = _isWalkingLeft;
	}
	
	override public function update(elapsed:Float):Void {
		if (!alive) {
			exists = false;
			return;
		}

		if(isOnScreen()) {
			fsm.update(elapsed);
		}

		super.update(elapsed);
	}
	
	override public function destroy():Void {
		fsm.destroy();
		fsm = null;
		super.destroy();
	}
	
	public function shootBullet():Void {
		GameObjects.instance.pistolBullets.recycle(PistolBullet).fireBullet(x+halfWidth, y+halfHeight, flipX ? 180 : 0, this);
	}
	
	public function hitByBullet(bullet: Bullet):Void {
		bullet.kill();
		kill();
	}
	
	public function hitByLaser(laser: Laser):Void {
	}
}

private class Conditions {
	public static function seeEnemy(Owner:BasicEnemy):Bool {
		if (GameObjects.instance.player.sprite.x - Owner.x < 0 && !Owner.flipX) {
			return false;
		}
		
		if (GameObjects.instance.player.sprite.x - Owner.x > 0 && Owner.flipX) {
			return false;
		}
		
		return GameObjects.instance.mapData.ray(Owner.getMidpoint(), GameObjects.instance.player.sprite.getMidpoint());
	}
	
	public static function lostEnemy(Owner:BasicEnemy):Bool {
		return !GameObjects.instance.mapData.ray(Owner.getMidpoint(), GameObjects.instance.player.sprite.getMidpoint());
	}
}

private class Scout extends FlxFSMState<BasicEnemy> {
	override public function enter(owner:BasicEnemy, fsm:FlxFSM<BasicEnemy>):Void {
		super.enter(owner, fsm);
	}
	
	override public function update(elapsed:Float, owner:BasicEnemy, fsm:FlxFSM<BasicEnemy>):Void {
		var xTile = Math.floor((owner.x+owner.halfWidth) / GameObjects.TILE_WIDTH);
		var yTile = Math.floor((owner.y+owner.halfHeight) / GameObjects.TILE_HEIGHT);
		var tileId = GameObjects.instance.mapData.getTile(xTile+(owner.flipX?-1:1), yTile+1);
		if (tileId == 0) {
			owner.flipX = !owner.flipX;
		}
		if (owner.isTouching(FlxObject.WALL)) {
			owner.flipX = !owner.flipX;
		}
		
		owner.velocity.x = owner.flipX ? -owner.runSpeed : owner.runSpeed;
		
		super.update(elapsed, owner, fsm);
	}
}

private class Attack extends FlxFSMState<BasicEnemy> {
	private var ticker:Int = 0;
	
	override public function enter(owner:BasicEnemy, fsm:FlxFSM<BasicEnemy>):Void {
		super.enter(owner, fsm);
	}
	
	override public function update(elapsed:Float, owner:BasicEnemy, fsm:FlxFSM<BasicEnemy>):Void {
		if (ticker++ % 50 == 0) {
			owner.shootBullet();
		}
		super.update(elapsed, owner, fsm);
	}
}