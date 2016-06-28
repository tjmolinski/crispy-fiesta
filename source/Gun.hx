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

	override public function new(?X:Float=0, ?Y:Float=0) {
		super(X, Y);
	}
	
	override public function update(elapsed:Float):Void {
		if (!alive) {
			exists = false;
			return;
		}
		
		if(owner != null) {
			var targetX = owner.x + owner.halfWidth - halfWidth + (gunOffsetX * (owner.flipX?-1:1));
			var targetY = owner.y + owner.halfHeight - halfHeight + gunOffsetY;

			if(owner.direction == -90) {
				angle = -90;

				//XXX: Make this cleaner, its dirtah
				targetX -= (gunOffsetX * (owner.flipX?-1:1));
				targetY -= gunOffsetX;
			} else if(owner.direction == 90 && !owner.isProne) {
				angle = 90;
				targetX -= (gunOffsetX * (owner.flipX?-1:1));
				targetY += gunOffsetX;
			} else {
				angle = 0;
			}

			x += (targetX - x) * springiness;
			y += (targetY - y) * springiness;

			x = targetX;
			y = targetY;
		}
		
		super.update(elapsed);
	}
	
	override public function kill():Void {
		owner = null;
		super.kill();
	}
	
	public function giveGun(_owner:Dynamic):Void {
		super.reset(_owner.x, _owner.y);
		owner = _owner;
		owner.giveGun(this);
	}

	public function shootBullet(bullets: FlxTypedGroup<Bullet>, direction: Float):Void {
		if(owner.direction == 90 && owner.isProne) {
			bullets.recycle(Bullet).fireBullet(x+halfWidth, y+halfHeight, owner.flipX ? 180 : 0, owner);
		} else {
			bullets.recycle(Bullet).fireBullet(x+halfWidth, y+halfHeight, direction, owner);
		}
	}

	public function shoot(bullets: FlxTypedGroup<Bullet>): Void {}
}