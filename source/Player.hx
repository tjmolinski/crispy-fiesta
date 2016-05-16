package;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.group.FlxGroup;

/**
 * ...
 * @author TJ
 */
class Player extends FlxSprite implements LivingThing
{

	private var runSpeed:Float = 1000;
	private var xMaxVel:Float = 100;
	private var yMaxVel:Float = 500;
	private var yMaxLadderVel:Float = 50;

	private var playerDrag:Float = 1600;
	private var gravity:Float = 700;
	private var jumpSpeed:Float = -300;
	
	private var singleJumped:Bool = false;
	private var doubleJumped:Bool = false;
	private var linearJumped:Bool = false;
	
	private var onLadder:Bool = false;
	private var ladderSpeed:Float = 30.0;
	
	private var bullets:FlxTypedGroup<Bullet>;
	private var direction:Float = 0;
	private var ladderX:Float;

	public var fallingThrough:Bool = false;
	public var fallThroughObj:FlxObject = null;
	
	private var halfWidth:Float;
	private var halfHeight:Float;
	
	private var shootBtn:FlxKey = FlxKey.X;
	private var jumpBtn:FlxKey = FlxKey.Z;
	public var nameType:String = "player";
	
	override public function new(X:Int, Y:Int, _width:Float, _height:Float, _bullets:FlxTypedGroup<Bullet>) 
	{
		super(X, Y);
		
		bullets = _bullets;
		
		makeGraphic(cast(_width, Int), cast(_height, Int), FlxColor.RED);
		drag.set(playerDrag, playerDrag);
		acceleration.set(0, gravity);
		maxVelocity.set(xMaxVel, yMaxVel);
		
		halfWidth = _width / 2;
		halfHeight = _height / 2;
	}

	override public function update(elapsed:Float):Void
	{
		handleDirection();

		if (!linearJumped)
		{
			handleRunningMovement(elapsed);
		}

		handleLadderMovement();

		super.update(elapsed);
	}
	
	private function handleFloorCheck():Void
	{
		if (this.isTouching(FlxObject.DOWN)) {
			this.hitFloor();
		}
	}

	private function handleDirection():Void
	{
		if(FlxG.keys.anyPressed([UP]))
		{
			direction = -90;
		}
		else if(FlxG.keys.anyPressed([DOWN]))
		{
			direction = 90;
		}
		else
		{
			direction = flipX ? 180 : 0;
		}
		
		if(FlxG.keys.anyPressed([LEFT]))
		{
			if(direction == 90)
			{
				direction = 155;
			}
			else if(direction == -90)
			{
				direction = -155;
			}
			else
			{
				direction = 180;
			}
		}
		else if(FlxG.keys.anyPressed([RIGHT]))
		{
			if(direction == 90)
			{
				direction = 25;
			}
			else if(direction == -90)
			{
				direction = -25;
			}
			else
			{
				direction = 0;
			}
		}
	}
	
	private function handleRunningMovement(elapsed:Float):Void
	{
		acceleration.x = 0;
		if (FlxG.keys.anyPressed([RIGHT]))
		{
			flipX = false;
			if(!isTouching(FlxObject.RIGHT) && !onLadder)
			{
			acceleration.x += runSpeed;
			}
		} 
		else if (FlxG.keys.anyPressed([LEFT]))
		{
			flipX = true;
			if(!isTouching(FlxObject.LEFT) && !onLadder)
			{
				acceleration.x -= runSpeed;
			}
		}
		
		if (FlxG.keys.anyJustPressed([shootBtn]))
		{
			bullets.recycle(Bullet).fireBullet(x+halfWidth, y+halfHeight, direction, this);
		}
	}

	public function handleLadderMovement()
	{
		if (onLadder)
		{
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
			maxVelocity.set(xMaxVel, yMaxVel);
		}
	}
	
	public function hitFloor():Void
	{
		singleJumped = false;
		doubleJumped = false;
		linearJumped = false;
	}
	
	public function setLadderState(tf:Bool, ?X:Float):Void
	{
		onLadder = tf;
		if (tf) {
			ladderX = X;
			singleJumped = false;
			doubleJumped = false;
			linearJumped = false;
		}
	}
	
	public function getLadderState():Bool
	{
		return onLadder;
	}
}