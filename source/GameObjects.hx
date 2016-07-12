package;

import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.group.FlxGroup;
import flixel.addons.editors.ogmo.FlxOgmoLoader;
import flixel.addons.tile.FlxTilemapExt;

class GameObjects {
	public static var instance(get, null):GameObjects;
    private static function get_instance():GameObjects {
        if(instance == null) {
            instance = new GameObjects();
        }
        return instance;
    }

	public var player:Player;

	public static var TILE_WIDTH:Int = 16;
	public static var TILE_HEIGHT:Int = 16;
	public var ogmoMap:FlxOgmoLoader;
	public var mapData:FlxTilemapExt;

	public var enemies:FlxTypedGroup<BasicEnemy>;
	public var bosses:FlxTypedGroup<Boss>;

	public var vehicles:FlxTypedGroup<Vehicle>;

	public var spikes:FlxTypedGroup<Spike>;
	public var killPits:FlxTypedGroup<KillPit>;
	public var exits:FlxTypedGroup<Exit>;

	public var pistolBullets:FlxTypedGroup<PistolBullet>;
	public var flameBullets:FlxTypedGroup<FlameBullet>;
	public var rawketBullets:FlxTypedGroup<RawketBullet>;

	public var lasers:FlxTypedGroup<Laser>;
	public var pistols:FlxTypedGroup<Pistol>;
	public var shotguns:FlxTypedGroup<Shotgun>;
	public var flameguns:FlxTypedGroup<FlameGun>;
	public var machineguns:FlxTypedGroup<MachineGun>;
	public var rawketLawnChairs:FlxTypedGroup<RawketLawnChair>;

	public var spreaderPickup:FlxTypedGroup<SpreaderGunPickup>;
	public var machinegunPickup:FlxTypedGroup<MachineGunPickup>;
	public var flamegunPickup:FlxTypedGroup<FlameGunPickup>;
	public var rawketlawnchairPickup:FlxTypedGroup<RawketLawnChairPickup>;

	public var ladders:FlxGroup;
	public var movingPlatforms:FlxGroup;

    public function new() {
		ladders = new FlxGroup();
		movingPlatforms = new FlxGroup();

		pistolBullets = new FlxTypedGroup<PistolBullet>(100);
		flameBullets = new FlxTypedGroup<FlameBullet>(100);
		rawketBullets = new FlxTypedGroup<RawketBullet>(100);

		spikes = new FlxTypedGroup<Spike>(100);
		killPits = new FlxTypedGroup<KillPit>(100);
		exits = new FlxTypedGroup<Exit>(3);

		vehicles = new FlxTypedGroup<Vehicle>(5);

		enemies = new FlxTypedGroup<BasicEnemy>(100);

		bosses = new FlxTypedGroup<Boss>(5);
		lasers = new FlxTypedGroup<Laser>(100);

		pistols = new FlxTypedGroup<Pistol>(10);
		shotguns = new FlxTypedGroup<Shotgun>(10);
		flameguns = new FlxTypedGroup<FlameGun>(10);
		machineguns = new FlxTypedGroup<MachineGun>(10);
		rawketLawnChairs = new FlxTypedGroup<RawketLawnChair>(10);

		spreaderPickup = new FlxTypedGroup<SpreaderGunPickup>(10);
		machinegunPickup = new FlxTypedGroup<MachineGunPickup>(10);
		flamegunPickup = new FlxTypedGroup<FlameGunPickup>(10);
		rawketlawnchairPickup = new FlxTypedGroup<RawketLawnChairPickup>(10);
    }
}