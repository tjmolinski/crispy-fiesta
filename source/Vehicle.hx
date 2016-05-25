package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;

class Vehicle extends FlxSprite implements LivingThing {

	private var moveSpeed:Float = 1000;
	private var xMaxVel:Float = 100;
	private var yMaxVel:Float = 500;

	private var vehicleDrag:Float = 1600;
	private var gravity:Float = 700;
	private var jumpSpeed:Float = -300;
	
	public var halfWidth:Float;
	public var halfHeight:Float;
	public var singleJumped:Bool = false;
	public var doubleJumped:Bool = false;

	public var fallingThrough:Bool = false;
	public var fallThroughObj:FlxObject = null;

	private var driver:Player;
	private var bullets:FlxTypedGroup<Bullet>;
	public var nameType:String = "vehicle";

	private var healthPoints:Int = 3;
	private var isBlowingUp:Bool = false;
	private var blowingUpTicks:Int = 0;
	private var blowingUpTime:Int = 100;

	override public function new() {
		super();

		makeGraphic(64, 32, FlxColor.MAGENTA);

		drag.set(vehicleDrag, vehicleDrag);
		acceleration.set(0, gravity);
		maxVelocity.set(xMaxVel, yMaxVel);

		halfWidth = width / 2;
		halfHeight = height / 2;
	}
	
	override public function update(elapsed: Float):Void {
		if(!alive) {
			return;
		}

		handleMovement(elapsed);

		if(isBlowingUp) {
			if(++blowingUpTicks > blowingUpTime) {
				if(driver != null) {
					driver.kill();
					driver = null;
				}
				kill();
			} else {
				visible = !visible;
			}
		}

		if(driver != null) {
			checkVehicleLevelBounds();
		}

		super.update(elapsed);
	}

	private function checkVehicleLevelBounds() {
		if(x < FlxG.camera.minScrollX) {
			x = FlxG.camera.minScrollX;
			acceleration.x = 0;
		}

		if(x > FlxG.camera.minScrollX + FlxG.width - width) {
			x = FlxG.camera.minScrollX + FlxG.width - width;
			acceleration.x = 0;
		}
	}
	
	public function spawn(posX: Float, posY: Float, _bullets:FlxTypedGroup<Bullet>) {
		super.reset(posX, posY);
		bullets = _bullets;
	}

	public function handleMovement(elapsed: Float):Void {
		acceleration.x = 0;

		if(driver == null) {
			return;
		}

		driver.x = x + halfWidth - driver.halfWidth;
		driver.y = y;
		driver.flipX = flipX;

		if (this.isTouching(FlxObject.DOWN)) {
			hitFloor();
		}

		driver.handleDirection();
		
		if(fallingThrough) {
			return;
		}


		if(!isBlowingUp) {
			if (FlxG.keys.anyPressed([RIGHT])) {
				flipX = false;
				if(!isTouching(FlxObject.RIGHT))
				{
				acceleration.x += moveSpeed;
				}
			} else if (FlxG.keys.anyPressed([LEFT])) {
				flipX = true;
				if(!isTouching(FlxObject.LEFT)) {
					acceleration.x -= moveSpeed;
				}
			}

			if (FlxG.keys.anyJustPressed([driver.jumpBtn])) {
				if (!singleJumped) {
					singleJumped = true;
					velocity.y = jumpSpeed;
				} else if (singleJumped && !doubleJumped) {
					doubleJumped = true;
					velocity.y = jumpSpeed;
				}
			}
			
			if (FlxG.keys.anyJustPressed([driver.shootBtn])) {
				bullets.recycle(Bullet).fireBullet(x+halfWidth, y+halfHeight, driver.direction, this);
			}
		}
	}
	
	public function hitFloor():Void {
		singleJumped = false;
		doubleJumped = false;
	}

	public function setDriver(_driver:Player):Void {
		driver = _driver;
	}

	public function diverEscaped():Void {
		driver = null;
	}

	public function hitByBullet(bullet:Bullet): Void {
		bullet.kill();
		if(--healthPoints <= 0 && !isBlowingUp) {
			isBlowingUp = true;
		}
	}
}