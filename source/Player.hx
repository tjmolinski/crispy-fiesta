package;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.input.keyboard.FlxKey;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.addons.util.FlxFSM;

/**
 * ...
 * @author TJ
 */
class Player extends FlxSprite implements LivingThing {
	
	private var fsm:FlxFSM<Player>;

	private var moveSpeed:Float = 1000;
	private var xMaxVel:Float = 125;
	private var xCrouchMaxVel:Float = 50;
	private var yMaxVel:Float = 500;
	private var yMaxLadderVel:Float = 50;

	private var playerDrag:Float = 1600;
	private var gravity:Float = 700;
	private var jumpSpeed:Float = -300;
	
	public var singleJumped:Bool = false;
	public var doubleJumped:Bool = false;
	public var linearJumped:Bool = false;
	public var boosted:Bool = false;

	public var isInVehicle:Bool = false;
	public var vehicle:Vehicle;
	public var escapingVehicle:Bool = false;
	
	private var onLadder:Bool = false;
	private var ladderSpeed:Float = 30.0;
	
	public var direction:Float = 0;
	private var ladderX:Float;

	public var fallingThrough:Bool = false;
	public var fallThroughObj:FlxObject = null;
	
	public var halfWidth:Float;
	public var halfHeight:Float;
	
	public var isDead:Bool = false;
	public var isProne:Bool = false;
	
	public var shootBtn:FlxKey = FlxKey.Z;
	public var jumpBtn:FlxKey = FlxKey.X;
	public var escapeBtn:FlxKey = FlxKey.C;
	public var nameType:String = "player";
	public var tileMap:FlxTilemap;

	public var gun: Gun;
	
	override public function new(X:Int, Y:Int, _width:Float, _height:Float, _tileMap:FlxTilemap) {
		super(X, Y);
		
		tileMap = _tileMap;
		
		makeGraphic(cast(_width, Int), cast(_height, Int), FlxColor.RED);
		drag.set(playerDrag, playerDrag);
		acceleration.y = gravity;
		maxVelocity.set(xMaxVel, yMaxVel);
		
		halfWidth = _width / 2;
		halfHeight = _height / 2;
		
		fsm = new FlxFSM<Player>(this, new Standing());
		fsm.transitions
			.add(Prone, Standing, Conditions.isStanding)
			.add(Standing, Prone, Conditions.isProne)
			.add(Standing, DrivingVehicle, Conditions.isInVehice)
			.add(DrivingVehicle, Standing, Conditions.isEscapingVehicle)
			.addGlobal(Death, Conditions.isDead)
			.start(Standing);
	}

	override public function update(elapsed:Float):Void {
		fsm.update(elapsed);

		checkPlayerLevelBounds();

		super.update(elapsed);
	}

	private function checkPlayerLevelBounds() {
		if(x < FlxG.camera.minScrollX) {
			x = FlxG.camera.minScrollX;
			acceleration.x = 0;
		}

		if(x > FlxG.camera.minScrollX + FlxG.width - width) {
			x = FlxG.camera.minScrollX + FlxG.width - width;
			acceleration.x = 0;
		}
	}
	
	public function handleInput(elapsed:Float):Void {
		handleDirection();

		if (!linearJumped) {
			handleRunningMovement(elapsed);
		}

		handleLadderMovement();
	}
	
	private function handleFloorCheck():Void {
		if (this.isTouching(FlxObject.DOWN)) {
			this.hitFloor();
		}
	}

	public function handleDirection():Void {
		if(FlxG.keys.anyPressed([UP])) {
			direction = -90;
		} else if(FlxG.keys.anyPressed([DOWN])) {
			direction = 90;
		} else {
			direction = flipX ? 180 : 0;
		}
	}
	
	private function handleRunningMovement(elapsed:Float):Void {
		acceleration.x = 0;
		if (FlxG.keys.anyPressed([RIGHT])) {
			flipX = false;
			if(!isTouching(FlxObject.RIGHT) && !onLadder) {
			acceleration.x += moveSpeed;
			}
		} else if (FlxG.keys.anyPressed([LEFT])) {
			flipX = true;
			if(!isTouching(FlxObject.LEFT) && !onLadder) {
				acceleration.x -= moveSpeed;
			}
		}
		
		if (FlxG.keys.anyJustPressed([shootBtn])) {
			gun.shoot();
		}
	}

	public function handleLadderMovement() {
		if (onLadder) {
			x = ladderX;
			acceleration.y = 0;
			maxVelocity.set(0, yMaxLadderVel);
			if (FlxG.keys.anyPressed([UP]))
			{
				velocity.y -= ladderSpeed;
			}
			if (FlxG.keys.anyPressed([DOWN]))
			{
				velocity.y += ladderSpeed;
			}
		} else {
			acceleration.y = gravity;
			if (maxVelocity.x != xCrouchMaxVel) {
				maxVelocity.set(xMaxVel, yMaxVel);
			} else {
				maxVelocity.set(xCrouchMaxVel, yMaxVel);
			}
		}
	}
	
	public function hitFloor():Void {
		escapingVehicle = false;
		singleJumped = false;
		doubleJumped = false;
		linearJumped = false;
	}
	
	public function setLadderState(tf:Bool, ?X:Float):Void {
		onLadder = tf;
		if (tf) {
			ladderX = X;
			singleJumped = false;
			doubleJumped = false;
			linearJumped = false;
		}
	}
	
	public function getLadderState():Bool {
		return onLadder;
	}
	
	public function hitByBullet(bullet: Bullet):Void {
		bullet.kill();
		kill();
	}
	
	public function hitByLaser(laser: Laser):Void {
		kill();
	}
	
	public function overlappingEnemy(thing: Dynamic):Void {
		kill();
	}
	
	public function enterProneState() {
		scale.y = 0.5;
		y += height * 0.5;
		updateHitbox();
		halfHeight = height / 2;
		maxVelocity.set(xCrouchMaxVel, yMaxVel);
		isProne = true;
	}
	
	public function exitProneState() {
		scale.y = 1;
		y -= height;
		updateHitbox();
		halfHeight = height / 2;
		maxVelocity.set(xMaxVel, yMaxVel);
		isProne = false;
	}
	
	public override function kill():Void {
		isDead = true;
		gun.kill();
		super.kill();
	}

	public function jumpInVehicle(veh:Vehicle):Void {
		isInVehicle = true;
		vehicle = veh;
		vehicle.setDriver(this);
		gun.visible = false; //XXX: Maybe better to kill and recycle
	}

	public function escapeVehicle():Void {
		vehicle.setDriver(null);
		isInVehicle = false;
		vehicle = null;
		singleJumped = true;
		doubleJumped = true;
		linearJumped = true;
		velocity.x = 0;
		velocity.y = jumpSpeed;
		acceleration.x = 0;
		escapingVehicle = true;
		gun.visible = true; //XXX: Maybe better to kill and recycle
	}

	public function giveGun(_gun: Gun) {
		gun = _gun;
	}
}

private class Conditions {
	public static function isProne(owner:Player):Bool {
		return owner.isTouching(FlxObject.DOWN) && FlxG.keys.anyPressed([DOWN]);
	}
	
	public static function isStanding(owner:Player):Bool {
		var xLeftMostPos = Math.floor(owner.x / PlayState.TILE_WIDTH);
		var xRightMostPos = Math.floor((owner.x + owner.width) / PlayState.TILE_WIDTH);
		var yTile = Math.floor((owner.y) / PlayState.TILE_HEIGHT);
		var leftSideTileId = owner.tileMap.getTile(xLeftMostPos, yTile-1);
		var rightSideTileId = owner.tileMap.getTile(xRightMostPos, yTile-1);
		
		return !isProne(owner) && leftSideTileId == 0 && rightSideTileId == 0;
	}
	
	public static function isDead(owner:Player):Bool {
		return owner.isDead;
	}

	public static function isInVehice(owner:Player):Bool {
		return owner.isInVehicle;
	}

	public static function isEscapingVehicle(owner:Player):Bool {
		return FlxG.keys.anyPressed([owner.escapeBtn]);
	}
}

private class Prone extends FlxFSMState<Player> {
	override public function enter(owner:Player, fsm:FlxFSM<Player>):Void {
		owner.enterProneState();
		super.enter(owner ,fsm);
	}
	
	override public function update(elapsed:Float, owner:Player, fsm:FlxFSM<Player>):Void {
		owner.handleInput(elapsed);
		super.update(elapsed, owner, fsm);
	}
	
	override public function exit(owner:Player):Void {
		owner.exitProneState();
		super.exit(owner);
	}
}

private class Standing extends FlxFSMState<Player> {
	override public function update(elapsed:Float, owner:Player, fsm:FlxFSM<Player>):Void {
		owner.handleInput(elapsed);
		super.update(elapsed, owner, fsm);
	}
}

private class Death extends FlxFSMState<Player> {
	override public function enter(owner:Player, fsm:FlxFSM<Player>):Void {
		owner.kill();
		super.enter(owner, fsm);
	}
}

private class DrivingVehicle extends FlxFSMState<Player> {
	override public function enter(owner:Player, fsm:FlxFSM<Player>):Void {
		owner.visible = false;
		owner.allowCollisions = FlxObject.NONE;
		super.enter(owner, fsm);
	}

	override public function update(elapsed:Float, owner:Player, fsm:FlxFSM<Player>):Void {
		super.update(elapsed, owner, fsm);
	}
	
	override public function exit(owner:Player):Void {
		owner.escapeVehicle();
		owner.visible = true;
		owner.allowCollisions = FlxObject.ANY;
		super.exit(owner);
	}
}