package;

import flixel.FlxG;
import flixel.input.keyboard.FlxKey;

/**
 * ...
 * @author TJ
 */
class VariableJumpingPlayer extends Player {
	private var jumpJammer:Bool = false;
	private var holdJumpBuffer:Float = 0.0;
	private var holdJumpTime:Float = 0.1;
	private var jumpHoldAdder:Float = -10;

	private var lastBoostBtn: FlxKey = null;
	private var lastBoostPress: Int = 0;

	private var boostSpeed: Float = 450;
	
	override public function update(elapsed:Float):Void {
		handleFloorCheck();
		handleVariableJumping(elapsed);
		if(boosted) {
			boosting();
		} else {
			handleRocketBoosting(elapsed);
		}
		super.update(elapsed);
	}

	private function boosting() {
		switch(lastBoostBtn) {
			case FlxKey.RIGHT:
				velocity.x = boostSpeed;

			case FlxKey.LEFT:
				velocity.x = -boostSpeed;

			default:
		}
	}

	private function handleVariableJumping(elapsed:Float):Void {
		if(fallingThrough || boosted) {
			return;
		}
		
		if (FlxG.keys.anyPressed([jumpBtn]) && (!singleJumped || !doubleJumped) && !jumpJammer) {
			if (FlxG.keys.anyJustPressed([jumpBtn])) {
				setLadderState(false);
				velocity.y = jumpSpeed;
			} else {
				velocity.y += jumpHoldAdder;
				if (holdJumpBuffer > holdJumpTime) {
					jumpJammer = true;
				} else {
					holdJumpBuffer += elapsed;
				}
			}
		} else if (FlxG.keys.anyJustReleased([jumpBtn])) {
			jumpJammer = false;
			holdJumpBuffer = 0.0;
			if (!singleJumped) {
				singleJumped = true;
			} else if (!doubleJumped) {
				doubleJumped = true;
			}
		}
	}

	private function handleRocketBoosting(elapsed:Float):Void {
		if(lastBoostBtn != null) {
			performRocketBoost();
		} else {
			setupRocketBoost();
		}
	}

	private function performRocketBoost():Void {
		if(lastBoostPress > 25 && !boosted) {
			lastBoostBtn = null;
			return;
		}

		if (FlxG.keys.anyJustPressed([lastBoostBtn])) {
			setLadderState(false);
			singleJumped = true;
			doubleJumped = true;
			rocketBoost(lastBoostBtn);
		}
		lastBoostPress++;
	}

	private function setupRocketBoost():Void {
		if (FlxG.keys.anyJustPressed([FlxKey.UP])) {
			lastBoostBtn = FlxKey.UP;
			lastBoostPress = 0;
		}
		if (FlxG.keys.anyJustPressed([FlxKey.LEFT])) {
			lastBoostBtn = FlxKey.LEFT;
			lastBoostPress = 0;
		}
		if (FlxG.keys.anyJustPressed([FlxKey.RIGHT])) {
			lastBoostBtn = FlxKey.RIGHT;
			lastBoostPress = 0;
		}
		if (FlxG.keys.anyJustPressed([FlxKey.DOWN])) {
			lastBoostBtn = FlxKey.DOWN;
			lastBoostPress = 0;
		}
	}

	private function rocketBoost(key:FlxKey):Void {
		switch(key) {
			case FlxKey.UP:
				boosted = true;
				velocity.y = jumpSpeed * 1.5;

			case FlxKey.RIGHT:
				boosted = true;
				velocity.y = jumpSpeed * 0.75;

			case FlxKey.LEFT:
				boosted = true;
				velocity.y = jumpSpeed * 0.75;

			case FlxKey.DOWN:
				boosted = true;
				velocity.y = jumpSpeed * -2.5;

			default:
		}
	}
	
	override public function hitFloor():Void {
		super.hitFloor();
		if(boosted) {
			lastBoostPress = 0;
			lastBoostBtn = null;
			boosted = false;
		}
	}
}