package;

import flixel.FlxG;
import flixel.FlxObject;

/**
 * ...
 * @author TJ
 */
class DoubleJumpingPlayer extends Player 
{
	
	override public function update(elapsed:Float):Void
	{
		handleFloorCheck();
		handleDoubleJumping(elapsed);
		super.update(elapsed);
	}
	
	private function handleDoubleJumping(elapsed:Float):Void
	{
		if(fallingThrough)
		{
			return;
		}

		if (FlxG.keys.anyJustPressed([SPACE]))
		{
			if (!singleJumped)
			{
				setLadderState(false);
				singleJumped = true;
				velocity.y = jumpSpeed;
			}
			else if (singleJumped && !doubleJumped)
			{
				doubleJumped = true;
				velocity.y = jumpSpeed;
			}
			
		}
		
	}
	
}