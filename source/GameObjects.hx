package;

import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;
import flixel.addons.editors.ogmo.FlxOgmoLoader;

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
	public var mapData:FlxTilemap;

	public var bullets:FlxTypedGroup<Bullet>;
	public var killPits:FlxTypedGroup<KillPit>;
	public var exits:FlxTypedGroup<Exit>;
	public var vehicles:FlxTypedGroup<Vehicle>;
	public var enemies:FlxTypedGroup<BasicEnemy>;
	public var bosses:FlxTypedGroup<Boss>;
	public var lasers:FlxTypedGroup<Laser>;
	public var pistols:FlxTypedGroup<Pistol>;
	public var shotguns:FlxTypedGroup<Shotgun>;
	public var machineguns:FlxTypedGroup<MachineGun>;
	public var ladders:FlxGroup;
	public var movingPlatforms:FlxGroup;

    public function new() {
		ladders = new FlxGroup();
		movingPlatforms = new FlxGroup();
		bullets = new FlxTypedGroup<Bullet>(10);
		killPits = new FlxTypedGroup<KillPit>(100);
		exits = new FlxTypedGroup<Exit>(3);
		vehicles = new FlxTypedGroup<Vehicle>(5);
		enemies = new FlxTypedGroup<BasicEnemy>(100);
		bosses = new FlxTypedGroup<Boss>(5);
		lasers = new FlxTypedGroup<Laser>(100);
		pistols = new FlxTypedGroup<Pistol>(10);
		shotguns = new FlxTypedGroup<Shotgun>(10);
		machineguns = new FlxTypedGroup<MachineGun>(10);
    }
}