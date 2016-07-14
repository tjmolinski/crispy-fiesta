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

	private var lastBoostBtn: FlxKey = FlxKey.NONE;
	private var lastBoostPress: Int = 0;

	private var doubleTapFrameLimit: Int = 15;
	private var horizontalBoostSpeed: Float = 450;
	private var verticalBoostSpeed: Float = -450;
	private var horizontalLiftSpeed: Float = -150;
	
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
				sprite.velocity.x = horizontalBoostSpeed;

			case FlxKey.LEFT:
				sprite.velocity.x = -horizontalBoostSpeed;

			default:
		}
	}

	private function handleVariableJumping(elapsed:Float):Void {
		if(fallingThrough || boosted) {
			return;
		}
		
		if (FlxG.keys.anyPressed([jumpBtn]) && (!singleJumped || !doubleJumped) && !jumpJammer) {
			setJumpingHitDimensions();
			sprite.animation.play("jump");
			if (FlxG.keys.anyJustPressed([jumpBtn])) {
				setLadderState(false);
				sprite.velocity.y = jumpSpeed;
			} else {
				sprite.velocity.y += jumpHoldAdder;
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
		if(isInVehicle) {
			return;
		}

		if(lastBoostBtn != FlxKey.NONE) {
			performRocketBoost();
		} else {
			setupRocketBoost();
		}
	}

	private function performRocketBoost():Void {
		if(lastBoostPress > doubleTapFrameLimit && !boosted) {
			lastBoostBtn = FlxKey.NONE;
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
				sprite.velocity.y = verticalBoostSpeed;

			case FlxKey.RIGHT:
				boosted = true;
				sprite.velocity.y = horizontalLiftSpeed;

			case FlxKey.LEFT:
				boosted = true;
				sprite.velocity.y = horizontalLiftSpeed;

			case FlxKey.DOWN:
				boosted = true;
				sprite.velocity.y = -verticalBoostSpeed;

			default:
		}
	}
	
	override public function hitFloor():Void {
		super.hitFloor();
		if(boosted) {
			lastBoostPress = 0;
			lastBoostBtn = FlxKey.NONE;
			boosted = false;
		}
	}
	override public function jumpInVehicle(veh:Vehicle):Void {
		super.jumpInVehicle(veh);
		boosted = false;
	}
}