package;

import flixel.FlxSprite;
import flixel.group.FlxGroup;

/**
 * ...
 * @author TJ
 */
class Gun extends FlxSprite {
	
	private var owner: Dynamic;
	private var halfWidth: Int;
	private var halfHeight: Int;
	private var springiness: Float = 0.5;
	public var gunOffsetX: Float;
	public var gunOffsetY: Float;

	private var cooldownTime:Float = 0.0;
	private var cooldownBuffer:Float = 0.0;
	private var inCooldown:Bool = false;
	private var ammoCount:Int = 0;
	public var currentAmmo:Int = 0;
	public var type:String = '';

	override public function new(?X:Float=0, ?Y:Float=0) {
		super(X, Y);
	}
	
	override public function update(elapsed:Float):Void {
		if (!alive) {
			exists = false;
			return;
		}
		
		if(owner != null) {
			var targetX = owner.sprite.x + owner.halfWidth - halfWidth + (gunOffsetX * (owner.sprite.flipX?-1:1));
			var targetY = owner.sprite.y + owner.halfHeight - halfHeight + gunOffsetY;

			if(owner.direction == -90) {
				angle = -90;

				//XXX: Make this cleaner, its dirtah
				targetX -= (gunOffsetX * (owner.sprite.flipX?-1:1));
				targetY -= gunOffsetX;
			} else if(owner.direction == 90 && !owner.isProne) {
				angle = 90;
				targetX -= (gunOffsetX * (owner.sprite.flipX?-1:1));
				targetY += gunOffsetX;
			} else {
				angle = 0;
			}

			x += (targetX - x) * springiness;
			y += (targetY - y) * springiness;

			x = targetX;
			y = targetY;
		}

		if(inCooldown) {
			if(cooldownBuffer >= cooldownTime) {
				cooldownBuffer = 0;
				inCooldown = false;
			} else {
				cooldownBuffer += elapsed;
			}
		}
		
		super.update(elapsed);
	}
	
	override public function kill():Void {
		owner = null;
		super.kill();
	}
	
	public function giveGun(_owner:Dynamic):Void {
		super.reset(_owner.sprite.x, _owner.sprite.y);
		owner = _owner;
		owner.giveGun(this);
	}
	
	public function shootBullet(bullet: Bullet, direction: Float, offset: Float):Void {
		if(owner.direction == 90 && owner.isProne) {
			bullet.fireBullet(x+halfWidth, y+halfHeight, owner.sprite.flipX ? 180 + offset : 0 + offset, owner);
		} else {
			bullet.fireBullet(x+halfWidth, y+halfHeight, direction + offset, owner);
		}
	}

	public function shoot():Bool {
		if(currentAmmo <= 0) {
			return false;
		}
		currentAmmo--;
		return true;
	}

	public function setAmmo(newCount: Int):Void {
		ammoCount = newCount;
		currentAmmo = newCount;
	}
}