package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxColor;

class Vehicle extends FlxSprite {

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
		if(!alive || driver == null) {
			return;
		}

		handleMovement(elapsed);

		super.update(elapsed);
	}
	
	public function spawn(posX: Float, posY: Float) {
		super.reset(posX, posY);
	}

	public function handleMovement(elapsed: Float):Void {
		driver.x = x + halfWidth - driver.halfWidth;
		driver.y = y;

		if (this.isTouching(FlxObject.DOWN)) {
			hitFloor();
		}
		
		if(fallingThrough) {
			return;
		}

		acceleration.x = 0;
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
	}
	
	public function hitFloor():Void {
		singleJumped = false;
		doubleJumped = false;
	}

	public function setDriver(_driver:Player):Void {
		driver = _driver;
	}
}