package;

import flixel.math.FlxPoint;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.tile.FlxTilemap;
import flixel.FlxG;
import flixel.group.FlxGroup;
	
import flixel.addons.util.FlxFSM;

/**
 * ...
 * @author TJ
 */
class BasicEnemy extends FlxSprite implements LivingThing
{
	
	public var fsm:FlxFSM<BasicEnemy>;

	public var xMaxVel:Float = 20;
	public var yMaxVel:Float = 500;
	public var playerDrag:Float = 1600;
	
	public var runSpeed:Float = 100;
	public var gravity:Float = 700;
	public var jumpSpeed:Float = -300;
	
	public var tileMap:FlxTilemap;
	
	public var halfWidth:Float;
	public var halfHeight:Float;
	
	public var playerRef:Player;
	private var bullets:FlxTypedGroup<Bullet>;
	public var nameType:String = "basic enemy";
	
	override public function new(X:Float, Y:Float, _width:Float, _height:Float, _isWalkingLeft:Bool, _map:FlxTilemap, _bullets:FlxTypedGroup<Bullet>) 
	{
		tileMap = _map;
		
		super(X, Y);
		
		bullets = _bullets;
		
		makeGraphic(cast(_width, Int), cast(_height, Int), FlxColor.PINK);
		drag.set(playerDrag, playerDrag);
		acceleration.set(0, gravity);
		maxVelocity.set(xMaxVel, yMaxVel);
		flipX = _isWalkingLeft;
		
		halfWidth = width / 2;
		halfHeight = height / 2;
		
		fsm = new FlxFSM<BasicEnemy>(this);
		fsm.transitions
			.add(Scout, Attack, Conditions.seeEnemy)
			.add(Attack, Scout, Conditions.lostEnemy)
			.start(Scout);
	}
	
	override public function update(elapsed:Float):Void
	{
		fsm.update(elapsed);
		super.update(elapsed);
	}
	
	override public function destroy():Void 
	{
		fsm.destroy();
		fsm = null;
		super.destroy();
	}
	
	public function setPlayerReference(player:Player):Void
	{
		playerRef = player;
	}
	
	public function shootBullet():Void
	{
		bullets.recycle(Bullet).fireBullet(x+halfWidth, y+halfHeight, flipX ? 180 : 0, this);
	}
}

class Conditions
{
	public static function seeEnemy(Owner:BasicEnemy):Bool
	{
		if (Owner.playerRef.x - Owner.x < 0 && !Owner.flipX)
			return false;
		
		if (Owner.playerRef.x - Owner.x > 0 && Owner.flipX)
			return false;
		
		return Owner.tileMap.ray(Owner.getMidpoint(), Owner.playerRef.getMidpoint());
	}
	
	public static function lostEnemy(Owner:BasicEnemy):Bool
	{
		return !Owner.tileMap.ray(Owner.getMidpoint(), Owner.playerRef.getMidpoint());
	}
}

class Scout extends FlxFSMState<BasicEnemy>
{
	override public function enter(owner:FlxSprite, fsm:FlxFSM<BasicEnemy>):Void 
	{
		//Start animation here
	}
	
	override public function update(elapsed:Float, owner:BasicEnemy, fsm:FlxFSM<BasicEnemy>):Void 
	{
		var xTile = Math.floor((owner.x+owner.halfWidth) / PlayState.TILE_WIDTH);
		var yTile = Math.floor((owner.y+owner.halfHeight) / PlayState.TILE_HEIGHT);
		var tileId = owner.tileMap.getTile(xTile+(owner.flipX?-1:1), yTile+1);
		if (tileId == 0)
		{
			owner.flipX = !owner.flipX;
		}
		if (owner.isTouching(FlxObject.WALL))
		{
			owner.flipX = !owner.flipX;
		}
		
		owner.velocity.x = owner.flipX ? -owner.runSpeed : owner.runSpeed;
	}
}

class Attack extends FlxFSMState<BasicEnemy>
{
	private var ticker:Int = 0;
	
	override public function enter(owner:FlxSprite, fsm:FlxFSM<BasicEnemy>):Void 
	{
		//Start animation here
	}
	
	override public function update(elapsed:Float, owner:BasicEnemy, fsm:FlxFSM<BasicEnemy>):Void 
	{
		if (ticker++ % 50 == 0)
		{
			owner.shootBullet();
		}
	}
}