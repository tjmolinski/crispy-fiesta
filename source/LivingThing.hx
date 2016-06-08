package;

/**
 * ...
 * @author TJ
 */
interface LivingThing 
{
	public var nameType: String;
	
	public function hitByBullet(bullet:Bullet): Void;
	public function hitByLaser(laser:Laser): Void;
}