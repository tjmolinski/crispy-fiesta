package;

/**
 * ...
 * @author TJ
 */
interface LivingThing 
{
	public var nameType: String;
	public var direction: Float;
	
	public function hitByBullet(bullet:Bullet): Void;
	public function hitByLaser(laser:Laser): Void;
}