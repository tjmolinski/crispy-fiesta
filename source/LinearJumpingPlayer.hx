package;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.FlxG;

/**
 * ...
 * @author TJ
 */
class LinearJumpingPlayer extends Player 
{
	private var linearJumpSpeed:Float = 150.0;

	override public function update(elapsed:Float):Void
	{	
		handleFloorCheck();
		handleLinearJumps(elapsed);
		super.update(elapsed);
	}
	
	private function handleLinearJumps(elapsed:Float):Void
	{
		if(fallingThrough)
		{
			return;
		}
		
		if (FlxG.keys.anyJustPressed([jumpBtn]) && (!singleJumped || !doubleJumped))
		{
			linearJumped = true;
			if (FlxG.keys.anyPressed([LEFT]))
			{
				acceleration.x = -linearJumpSpeed;
				velocity.x = -linearJumpSpeed;
				velocity.y = jumpSpeed;
			}
			else if (FlxG.keys.anyPressed([RIGHT]))
			{
				acceleration.x = linearJumpSpeed;
				velocity.x = linearJumpSpeed;
				velocity.y = jumpSpeed;
			}
			else
			{
				velocity.x = 0;
				acceleration.x = 0;
				velocity.y = jumpSpeed;
			}
			
			if (!singleJumped)
			{
				setLadderState(false);
				acceleration.y = gravity;
				maxVelocity.set(xMaxVel, yMaxVel);
				singleJumped = true;
			}
			else if (!doubleJumped)
			{
				doubleJumped = true;
			}
			
		}
	}
	
}