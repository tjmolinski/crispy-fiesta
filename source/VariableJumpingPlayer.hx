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
	private var jumpJammer:Bool = false;
	private var holdJumpBuffer:Float = 0.0;
	private var holdJumpTime:Float = 0.1;
	private var jumpHoldAdder:Float = -10;
	
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
		
		if (FlxG.keys.anyPressed([jumpBtn]) && (!singleJumped || !doubleJumped) && !jumpJammer)
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
					jumpJammer = true;
				}
				else
				{
					holdJumpBuffer += elapsed;
				}
			}
		}
		else if (FlxG.keys.anyJustReleased([jumpBtn]))
		{
			jumpJammer = false;
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