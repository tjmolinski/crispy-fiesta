package;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.FlxG;

/**
 * ...
 * @author TJ
 */
class VariableJumpingPlayer extends Player 
{
	private var spaceJam:Bool = false;
	private var holdJumpBuffer:Float = 0.0;
	private var holdJumpTime:Float = 0.1;
	private var jumpHoldAdder:Float = -15;
	
	override public function update(elapsed:Float):Void
	{
		handleFloorCheck();
		handleVariableJumping(elapsed);
		super.update(elapsed);
	}

	private function handleVariableJumping(elapsed:Float):Void
	{
		if(fallingThrough)
		{
			return;
		}
		
		if (FlxG.keys.anyPressed([SPACE]) && (!singleJumped || !doubleJumped) && !spaceJam)
		{
			if (FlxG.keys.anyJustPressed([jumpBtn]))
			{
				setLadderState(false);
				velocity.y = jumpSpeed;
			}
			else
			{
				velocity.y += jumpHoldAdder;
				if (holdJumpBuffer > holdJumpTime)
				{
					spaceJam = true;
				}
				else
				{
					holdJumpBuffer += elapsed;
				}
			}
		}
		else if (FlxG.keys.anyJustReleased([jumpBtn]))
		{
			spaceJam = false;
			holdJumpBuffer = 0.0;
			if (!singleJumped)
			{
				singleJumped = true;
			}
			else if (!doubleJumped)
			{
				doubleJumped = true;
			}
		}
	}
}