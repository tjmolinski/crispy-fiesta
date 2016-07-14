package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.util.FlxFSM;
import flixel.addons.util.FlxFSM;
import flixel.group.FlxGroup;
import flixel.input.keyboard.FlxKey;
import spinehaxe.SkeletonData;

/**
 * ...
 * @author TJ
 */
class Player extends FlxGroup implements LivingThing {
	
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

	public var gun: Gun;
	public var sprite: FlxSprite;
	
	override public function new(skeletonData:SkeletonData, X:Int, Y:Int) {
		// super(skeletonData, X, Y);
		super();

		// stateData.setMixByName("walk", "jump", 0.2);
		// stateData.setMixByName("jump", "walk", 0.4);
		// stateData.setMixByName("jump", "jump", 0.2);
		
		// state.setAnimationByName(0, "walk", true);

		sprite = new FlxSprite();
		sprite.x = X;
		sprite.y = Y - 50;
		sprite.loadGraphic("assets/images/dog.png", true, 64, 64);
		sprite.animation.add("run", [0,1,2,3,4,5,6], 15, true);
		sprite.animation.add("idle", [8,9], 3, true);
		sprite.animation.add("jump", [7], 0, false);
		sprite.animation.frameIndex = 8;


		sprite.drag.set(playerDrag, playerDrag);
		sprite.acceleration.y = gravity;
		sprite.maxVelocity.set(xMaxVel, yMaxVel);
		add(sprite);

		setNormalHitDimensions();
		
		fsm = new FlxFSM<Player>(this, new Standing());
		fsm.transitions
			.add(Prone, Standing, Conditions.isStanding)
			.add(Standing, Prone, Conditions.isProne)
			.add(Standing, DrivingVehicle, Conditions.isInVehice)
			.add(DrivingVehicle, Standing, Conditions.isEscapingVehicle)
			.addGlobal(Death, Conditions.isDead)
			.start(Standing);

		GameObjects.instance.pistols.recycle(Pistol).giveGun(this);
	}

	override public function update(elapsed:Float):Void {
		fsm.update(elapsed);

		checkPlayerLevelBounds();

		super.update(elapsed);
	}

	public function springPlayer():Void {
		sprite.velocity.y = jumpSpeed;
		singleJumped = true;
		doubleJumped = false;
	}

	private function setNormalHitDimensions():Void {
		// width = 32;
		// height = 32;
		// offset.set(16, 32);
		halfWidth = sprite.width / 2;
		halfHeight = sprite.height / 2;
	}

	private function setJumpingHitDimensions():Void {
		// width = 32;
		// height = 32;
		// offset.set(16, 24);
		halfWidth = sprite.width / 2;
		halfHeight = sprite.height / 2;
	}

	private function checkPlayerLevelBounds() {
		if(sprite.x < FlxG.camera.minScrollX) {
			sprite.x = FlxG.camera.minScrollX;
			sprite.acceleration.x = 0;
		}

		if(sprite.x > FlxG.camera.minScrollX + FlxG.width - sprite.width) {
			sprite.x = FlxG.camera.minScrollX + FlxG.width - sprite.width;
			sprite.acceleration.x = 0;
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
		if (sprite.isTouching(FlxObject.DOWN)) {
			hitFloor();
			if(!isProne) {
				setNormalHitDimensions();
			}
		}
	}

	public function handleDirection():Void {
		if(FlxG.keys.anyPressed([UP])) {
			direction = -90;
		} else if(FlxG.keys.anyPressed([DOWN])) {
			direction = 90;
		} else {
			direction = sprite.flipX ? 180 : 0;
		}
	}
	
	private function handleRunningMovement(elapsed:Float):Void {
		sprite.acceleration.x = 0;
		if (FlxG.keys.anyPressed([RIGHT])) {
			if (sprite.isTouching(FlxObject.DOWN)) {
				sprite.animation.play("run");
			}
			sprite.flipX = false;
			if(!sprite.isTouching(FlxObject.RIGHT) && !onLadder) {
				sprite.acceleration.x += moveSpeed;
			}
		} else if (FlxG.keys.anyPressed([LEFT])) {
			if (sprite.isTouching(FlxObject.DOWN)) {
				sprite.animation.play("run");
			}
			sprite.flipX = true;
			if(!sprite.isTouching(FlxObject.LEFT) && !onLadder) {
				sprite.acceleration.x -= moveSpeed;
			}
		} else if (sprite.isTouching(FlxObject.DOWN)) {
			sprite.animation.play("idle");
		}
		
		if (FlxG.keys.anyJustPressed([shootBtn])) {
			gun.shoot();
			if(gun.currentAmmo <= 0 && gun.type != "pistol") {
				GameObjects.instance.pistols.recycle(Pistol).giveGun(this);
				cast(FlxG.state, PlayState).ammoText.text = "Ammo: Infinity";
			} else if(gun.type != "pistol") {
				cast(FlxG.state, PlayState).ammoText.text = "Ammo: " + gun.currentAmmo;
			}
		}
	}

	public function handleLadderMovement() {
		if (onLadder) {
			sprite.x = ladderX;
			sprite.acceleration.y = 0;
			sprite.maxVelocity.set(0, yMaxLadderVel);
			if (FlxG.keys.anyPressed([UP]))
			{
				sprite.velocity.y -= ladderSpeed;
			}
			if (FlxG.keys.anyPressed([DOWN]))
			{
				sprite.velocity.y += ladderSpeed;
			}
		} else {
			sprite.acceleration.y = gravity;
			if (sprite.maxVelocity.x != xCrouchMaxVel) {
				sprite.maxVelocity.set(xMaxVel, yMaxVel);
			} else {
				sprite.maxVelocity.set(xCrouchMaxVel, yMaxVel);
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
		sprite.scale.y = 0.5;
		sprite.y += sprite.height * 0.5;
		sprite.height *= 0.5;
		halfHeight = sprite.height / 2;
		sprite.maxVelocity.set(xCrouchMaxVel, yMaxVel);
		isProne = true;
	}
	
	public function exitProneState() {
		sprite.scale.y = 1;
		sprite.y -= sprite.height;
		setNormalHitDimensions();
		sprite.maxVelocity.set(xMaxVel, yMaxVel);
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
		// vehicle.setDriver(this);
		gun.visible = false; //XXX: Maybe better to kill and recycle
	}

	public function escapeVehicle():Void {
		// vehicle.setDriver(null);
		isInVehicle = false;
		vehicle = null;
		singleJumped = true;
		doubleJumped = true;
		linearJumped = true;
		sprite.velocity.x = 0;
		sprite.velocity.y = jumpSpeed;
		sprite.acceleration.x = 0;
		escapingVehicle = true;
		gun.visible = true; //XXX: Maybe better to kill and recycle
	}

	public function giveGun(_gun: Gun) {
		if(gun != null) {
			gun.kill();
		}

		gun = _gun;
		if(gun.type == "pistol") {
			cast(FlxG.state, PlayState).ammoText.text = "Ammo: Infinity";
		} else {
			cast(FlxG.state, PlayState).ammoText.text = "Ammo: " + gun.currentAmmo;
		}
	}
}

private class Conditions {
	public static function isProne(owner:Player):Bool {
		return owner.sprite.isTouching(FlxObject.DOWN) && FlxG.keys.anyPressed([DOWN]);
	}
	
	public static function isStanding(owner:Player):Bool {
		var xLeftMostPos = Math.floor(owner.sprite.x / GameObjects.TILE_WIDTH);
		var xRightMostPos = Math.floor((owner.sprite.x + owner.sprite.width) / GameObjects.TILE_WIDTH);
		var yTile = Math.floor((owner.sprite.y) / GameObjects.TILE_HEIGHT);
		var leftSideTileId = GameObjects.instance.mapData.getTile(xLeftMostPos, yTile-1);
		var rightSideTileId = GameObjects.instance.mapData.getTile(xRightMostPos, yTile-1);
		
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
		owner.sprite.visible = false;
		owner.sprite.allowCollisions = FlxObject.NONE;
		super.enter(owner, fsm);
	}

	override public function update(elapsed:Float, owner:Player, fsm:FlxFSM<Player>):Void {
		super.update(elapsed, owner, fsm);
	}
	
	override public function exit(owner:Player):Void {
		owner.escapeVehicle();
		owner.sprite.visible = true;
		owner.sprite.allowCollisions = FlxObject.ANY;
		super.exit(owner);
	}
}