package;

import flash.external.ExternalInterface;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxBasic;
import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmoLoader;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxGlitchEffect;
import flixel.addons.effects.chainable.FlxTrailEffect;
import flixel.addons.text.FlxTypeText;
import flixel.group.FlxGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
import openfl.display.BlendMode;
import flixel.FlxCamera;
import flixel.addons.util.FlxFSM;

using flixel.util.FlxSpriteUtil;

class PlayState extends FlxState {
	
	private var fsm:FlxFSM<PlayState>;
	private var player:Player;
	private var exits:FlxTypedGroup<Exit>;
	private var killPits:FlxTypedGroup<KillPit>;
	private var message:FlxTypeText;
	private var ladders:FlxGroup;
	private var movingPlatforms:FlxGroup;
	private var enemies:FlxTypedGroup<BasicEnemy>;
	private var bullets:FlxTypedGroup<Bullet>;
	private var pistols:FlxTypedGroup<Pistol>;
	private var lasers:FlxTypedGroup<Laser>;
	private var vehicles:FlxTypedGroup<Vehicle>;
	private var bosses:FlxTypedGroup<Boss>;
	
	private var OVERLAY_COLOR = 0xdd000000;
	private var shadowCanvas:FlxSprite;
	private var shadowOverlay:FlxSprite;
	
	private var _effectSprite:FlxEffectSprite;
	private var _trail:FlxTrailEffect;
	private var _glitch:FlxGlitchEffect;
	
	private var _map:FlxOgmoLoader;
	public var _mWalls:FlxTilemap;
	
	public var currentState:PlayingStates;

	public static var TILE_WIDTH:Int = 16;
	public static var TILE_HEIGHT:Int = 16;

	override public function create():Void {
		createTileMap();
		createEntities();
		createStateMachine();
		setupCamera();

		super.create();
	}
	
	override public function update(elapsed:Float):Void {
		updateEffects(elapsed);
		fsm.update(elapsed);
		super.update(elapsed);
	}
	
	private function createStateMachine():Void {
		fsm = new FlxFSM<PlayState>(this, new IntroState());
		fsm.transitions
			.add(IntroState, GamingState, Conditions.isPlaying)
			.add(GamingState, PausedState, Conditions.pressPause)
			.add(PausedState, GamingState, Conditions.pressPause)
			.add(GamingState, OutroState, Conditions.isOutro)
			.start(IntroState);
			
		currentState = PlayingStates.INTRO;
	}
	
	private function createTileMap():Void {	
		_map = new FlxOgmoLoader("assets/data/test_level.oel");
		_mWalls = _map.loadTilemap("assets/images/level_tiles.png", TILE_WIDTH, TILE_HEIGHT, "tiles");
		_mWalls.setTileProperties(0, FlxObject.NONE);
		_mWalls.setTileProperties(1, FlxObject.UP);
		_mWalls.setTileProperties(2, FlxObject.RIGHT);
		_mWalls.setTileProperties(3, FlxObject.DOWN);
		_mWalls.setTileProperties(4, FlxObject.LEFT);
		_mWalls.setTileProperties(5, FlxObject.UP | FlxObject.RIGHT);
		_mWalls.setTileProperties(6, FlxObject.RIGHT | FlxObject.DOWN);
		_mWalls.setTileProperties(7, FlxObject.DOWN | FlxObject.LEFT);
		
		_mWalls.setTileProperties(8, FlxObject.LEFT | FlxObject.UP);
		_mWalls.setTileProperties(9, FlxObject.LEFT | FlxObject.UP | FlxObject.RIGHT);
		_mWalls.setTileProperties(10, FlxObject.UP | FlxObject.RIGHT | FlxObject.DOWN);
		_mWalls.setTileProperties(11, FlxObject.RIGHT | FlxObject.DOWN | FlxObject.LEFT);
		_mWalls.setTileProperties(12, FlxObject.UP | FlxObject.DOWN | FlxObject.LEFT);
		_mWalls.setTileProperties(13, FlxObject.RIGHT | FlxObject.LEFT);
		_mWalls.setTileProperties(14, FlxObject.UP | FlxObject.DOWN);
		_mWalls.setTileProperties(15, FlxObject.NONE);
		
		_mWalls.setTileProperties(16, FlxObject.UP, handleFallThrough); //Blue is jump throughable floor
		_mWalls.setTileProperties(17, FlxObject.NONE); //Yellow	
		_mWalls.setTileProperties(18, FlxObject.NONE); //Purple
		_mWalls.setTileProperties(19, FlxObject.NONE); //Orange
		_mWalls.setTileProperties(20, FlxObject.NONE);
		_mWalls.setTileProperties(21, FlxObject.NONE);
		_mWalls.setTileProperties(22, FlxObject.NONE);
		_mWalls.setTileProperties(23, FlxObject.NONE);
		
		add(_mWalls);
	}
	
	private function createEntities():Void {
		ladders = new FlxGroup();
		add(ladders);
		
		killPits = new FlxTypedGroup<KillPit>(100);
		add(killPits);
		
		exits = new FlxTypedGroup<Exit>(3);
		add(exits);

		vehicles = new FlxTypedGroup<Vehicle>(5);
		add(vehicles);
		
		movingPlatforms = new FlxGroup();
		add(movingPlatforms);
		
		enemies = new FlxTypedGroup<BasicEnemy>(100);
		add(enemies);

		bosses = new FlxTypedGroup<Boss>(5);
		add(bosses);

		lasers = new FlxTypedGroup<Laser>(100);
		add(lasers);

		bullets = new FlxTypedGroup<Bullet>(100);
		add(bullets);
		
		_map.loadEntities(function(type:String, data:Xml) {
			var posX = Std.parseInt(data.get("x"));
			var posY = Std.parseInt(data.get("y"));
			switch(type) {
				case "player":
					//XXX: Need to decouple bullets and tilemap from constructor
					//player = new LinearJumpingPlayer(posX, posY, 32, 32, bullets, _mWalls);
					player = new VariableJumpingPlayer(posX, posY, 32, 32, bullets, _mWalls);
					//player = new DoubleJumpingPlayer(posX, posY, 32, 32, bullets, _mWalls);
					add(player);
				case "ladder":
					ladders.add(new Ladder(posX, posY, data.get("isHead") == "True"));
				case "movingPlatform":
					var width : Int = Std.parseInt(data.get("width"));
					var height : Int = Std.parseInt(data.get("height"));
					var moveX : Float = Std.parseInt(data.get("xMove"));
					var moveY : Float = Std.parseInt(data.get("yMove"));
					movingPlatforms.add(new MovingPlatform(posX, posY, width, height, moveX, moveY));
				case "basicEnemy":
					enemies.recycle(BasicEnemy).spawn(posX, posY, data.get("walkLeft") == "True");
				case "boss":
					var offsetX : Float = Std.parseFloat(data.get("offsetX"));
					bosses.recycle(Boss).spawn(posX, posY, offsetX);
				case "exit":
					var width : Int = Std.parseInt(data.get("width"));
					var height : Int = Std.parseInt(data.get("height"));
					exits.recycle(Exit).spawn(posX, posY, width, height);
				case "killPit":
					var width : Int = Std.parseInt(data.get("width"));
					var height : Int = Std.parseInt(data.get("height"));
					killPits.recycle(KillPit).spawn(posX, posY, width, height);
				case "vehicle":
					vehicles.recycle(Vehicle).spawn(posX, posY, bullets);
					
			}
		});

		pistols = new FlxTypedGroup<Pistol>(10);
		add(pistols);
		pistols.recycle(Pistol).giveGun(player);
		
		//XXX: This is weird fix this in the future
		enemies.forEach(function(enemy:BasicEnemy) {
			enemy.setDependencies(player, _mWalls, bullets);
		});

		bosses.forEach(function(boss:Boss) {
			boss.setDependencies(player, lasers);
		});
		
		toggleEntitiesActive(false);
	}
	
	private function setupCamera():Void {
		/* Effect Sprite and Message Text
		add(_effectSprite = new FlxEffectSprite(player));
		// Effects
		_trail = new FlxTrailEffect(_effectSprite, 2, 0.5, 1);
		_glitch = new FlxGlitchEffect(5, 3, 0.05);
		_effectSprite.effects = [_trail, _glitch];
		
		message = new FlxTypeText(player.x, player.y - 100, 200, "testing a message that tests the messaging test", 16, true);
		add(message);
		message.showCursor = true;
		message.start(0.1, false, false, [ENTER], function() {
			message.showCursor = false;
		});*/
		
		var levelBounds = _mWalls.getBounds();
		FlxG.worldBounds.set( levelBounds.x, levelBounds.y, levelBounds.width, levelBounds.height);
		
		/*shadowCanvas = new FlxSprite();
		shadowCanvas.blend = BlendMode.MULTIPLY;
		shadowCanvas.makeGraphic(cast(levelBounds.width, Int), cast(levelBounds.height, Int), FlxColor.TRANSPARENT, true);
		add(shadowCanvas);
		shadowOverlay = new FlxSprite();
		shadowOverlay.makeGraphic(cast(levelBounds.width, Int), cast(levelBounds.height, Int), FlxColor.TRANSPARENT, true);
		shadowOverlay.blend = BlendMode.MULTIPLY;
		add(shadowOverlay);*/
		
		FlxG.camera.follow(player, FlxCameraFollowStyle.PLATFORMER, 0.05);
		FlxG.camera.targetOffset.set(100, 0);
		FlxG.camera.maxScrollX = levelBounds.right;
		FlxG.camera.minScrollX = levelBounds.left;
		FlxG.camera.maxScrollY = levelBounds.bottom;
		FlxG.camera.minScrollY = levelBounds.top;
		
		FlxG.camera.bgColor = 0xff333333;
	}
	
	private function fellInDeathPit(Tile:FlxObject, Object:FlxObject):Void {
		player.kill();
	}
	
	private function handleFallThrough(Tile:FlxObject, Object:FlxObject):Void {
		if (Object == player) {
			var _pl = cast(Object, Player);
			
			if (FlxG.keys.anyPressed([DOWN]) && FlxG.keys.anyJustPressed([_pl.jumpBtn])) {
				_pl.fallThroughObj = Tile;
				_pl.fallingThrough = true;
			}
		} else if(Object == player.vehicle) {
			var _veh = cast(Object, Vehicle);
			
			if (FlxG.keys.anyPressed([DOWN]) && FlxG.keys.anyJustPressed([player.jumpBtn])) {
				_veh.fallThroughObj = Tile;
				_veh.fallingThrough = true;
			}
		}
	}
	
	private function processShadows():Void {
		shadowCanvas.fill(FlxColor.TRANSPARENT);
		shadowOverlay.fill(OVERLAY_COLOR);

		var col = new FlxColor(0xffcc77ee);
		var studderEffect = 1;
		for (i in 0...2) {
			col.alpha = 100 + (50 * i);
			
			var radius = 200 - (50 * i);
		
			shadowOverlay.drawCircle(
				player.x + (player.width/2) + FlxG.random.float( -.6, .6),
				player.y + (player.height/2) + FlxG.random.float( -.6, .6),
				(FlxG.random.bool(5) ? radius : radius + studderEffect), col);
			/*var size = (FlxG.random.bool(5) ? radius : radius + 0.5);
			shadowOverlay.drawRect(
				player.x - (size / 2) + (player.width/2) + FlxG.random.float( -.6, .6),
				player.y - (size / 2) + (player.width/2) + FlxG.random.float( -.6, .6),
				size, size, col);*/
		}

		var bulletColor = new FlxColor(0xffffffcc);
		bullets.forEachExists(function(bullet: Bullet) {
			for (i in 0...2) {
				bulletColor.alpha = 100 + (50 * i);

				var radius = 50 - (10 * i);
			
				shadowOverlay.drawCircle(
					bullet.x + (bullet.width/2) + FlxG.random.float( -.6, .6),
					bullet.y + (bullet.height/2) + FlxG.random.float( -.6, .6),
					(FlxG.random.bool(5) ? radius : radius + studderEffect), bulletColor);
			}
		});
	}

	private function updateEffects(elapsed):Void {
		//XXX: Heavy framerate loss on neko for effects
		//processShadows();
		//_effectSprite.setPosition(player.x, player.y);
		//message.x = player.x - (message.width/2);
		//message.y = player.y - 100;
	}
	
	private function bulletCollision(bullet:Bullet, thing:LivingThing):Void {
		if(cast(thing, FlxBasic).alive) {
			if (thing.nameType != bullet.owner.nameType) {
				thing.hitByBullet(bullet);
			}
		}
	}
	
	private function laserCollision(laser:Laser, thing:LivingThing):Void {
		if(cast(thing, FlxBasic).alive) {
			if (thing.nameType != laser.owner.nameType) {
				thing.hitByLaser(laser);
			}
		}
	}
	
	private function enemyCollision(_player:Player, thing:LivingThing):Void {
		if(cast(thing, FlxBasic).alive && _player.alive) {
			_player.overlappingEnemy(thing);
		}
	}
	
	public function updateGamingState(elapsed):Void {
		FlxG.camera.minScrollX = FlxG.camera.scroll.x;

		FlxG.overlap(bullets, player, bulletCollision);
		FlxG.overlap(bullets, enemies, bulletCollision);
		FlxG.overlap(bullets, vehicles, bulletCollision);

		FlxG.overlap(lasers, player, laserCollision);
		FlxG.overlap(lasers, vehicles, laserCollision);

		bosses.forEach(function(boss: Boss) {
			FlxG.overlap(bullets, boss.weakSpot, function(bullet:Bullet, thing:FlxSprite) {
				bulletCollision(bullet, boss);
			});
			FlxG.overlap(player, boss.body, function(player:Player, thing:FlxSprite) {
				enemyCollision(player, boss);
			});
		});

		FlxG.overlap(player, enemies, enemyCollision);

		FlxG.overlap(player, vehicles, function(_pl:Player, veh:Vehicle) {
		}, function(_pl:Player, veh:Vehicle) {
			if(!_pl.escapingVehicle &&
				_pl.y + _pl.halfHeight < veh.y && 
				_pl.velocity.y > 0 &&
				Math.abs((_pl.x + _pl.halfWidth) - (veh.x + veh.halfWidth)) < _pl.halfWidth) {
				_pl.jumpInVehicle(veh);
			}
			return false;
		});
		

		///XXX: DRY these two functions up//////////////////////////////////////////////////
		FlxG.overlap(player, movingPlatforms, function(_pl:Player, obj:MovingPlatform) {
			handleFallThrough(obj, _pl);
			
			if (_pl.isTouching(FlxObject.DOWN)) {
				_pl.hitFloor();
			}
		}, function(_pl:Player, obj:MovingPlatform) {
			
			if (_pl.fallThroughObj != null && _pl.fallThroughObj.y < _pl.y) {
				_pl.fallThroughObj = null;
				_pl.fallingThrough = false;
			} else if (_pl.fallingThrough) {
				return false;
			}
			
			return FlxObject.separate(_pl, obj);
		});
		FlxG.overlap(vehicles, movingPlatforms, function(veh:Vehicle, obj:MovingPlatform) {
			handleFallThrough(obj, veh);
			
			if (veh.isTouching(FlxObject.DOWN)) {
				veh.hitFloor();
			}
		}, function(veh:Vehicle, obj:MovingPlatform) {
			
			if (veh.fallThroughObj != null && veh.fallThroughObj.y < veh.y) {
				veh.fallThroughObj = null;
				veh.fallingThrough = false;
			} else if (veh.fallingThrough) {
				return false;
			}
			
			return FlxObject.separate(veh, obj);
		});
		////////////////////////////////////////////////////////////////////////////////////////

		
		var onLadder = false;
		FlxG.overlap(player, ladders, function(player:Player, obj:Ladder) {}, function(player:Player, obj:Ladder) {
			if (FlxG.keys.anyPressed([UP]) && (player.y+player.height) < obj.y && obj.isHead) {
				return FlxObject.separate(player, obj);
			} else if (FlxG.keys.anyPressed([DOWN, UP]) || player.getLadderState()) {
				player.setLadderState(true, obj.x);
				onLadder = true;
				return false;
			} else {
				if (obj.isHead) 
				{
					return FlxObject.separate(player, obj);
				}
				else
				{
					return false;
				}
			}
		});
		
		FlxG.overlap(player, killPits, function(_player:Player, killPit:KillPit) {
			if (_player.y > killPit.y) {
				_player.kill();
			}
		});
		
		FlxG.overlap(player, exits, function(_player:Player, exit:Exit) {
			if (Math.abs(_player.x - exit.x) < 5) {
				currentState = OUTRO;
			}
		});
				
		_mWalls.overlapsWithCallback(player, function(_tile: FlxObject, _player: FlxObject) {
			var _pl = cast(_player, Player);
			
			if (_pl.fallThroughObj != null && _pl.fallThroughObj.y < _pl.y) {
				_pl.fallThroughObj = null;
				_pl.fallingThrough = false;
			} else if (_pl.fallingThrough) {
				return false;
			}
			
			return FlxObject.separate(_tile, _player);
		});
		enemies.forEach(function(enemy:BasicEnemy) {
			_mWalls.overlapsWithCallback(enemy, FlxObject.separate);
		});
		bosses.forEach(function(boss:Boss) {
			_mWalls.overlapsWithCallback(boss.body, FlxObject.separate);
		});
		vehicles.forEach(function(vehicle:Vehicle) {
			_mWalls.overlapsWithCallback(vehicle, function(_tile: FlxObject, veh: FlxObject) {
				var _veh = cast(veh, Vehicle);
				
				if (_veh.fallThroughObj != null && _veh.fallThroughObj.y < _veh.y) {
					_veh.fallThroughObj = null;
					_veh.fallingThrough = false;
				} else if (_veh.fallingThrough) {
					return false;
				}
				
				return FlxObject.separate(_tile, _veh);
			});
		});
		
		if (!onLadder) {
			player.setLadderState(false);
		}
		
		if (player.isDead) {
			currentState = OUTRO;
		}
	}

	public function toggleEntitiesActive(tf: Bool):Void {
		ladders.active = tf;
		movingPlatforms.active = tf;
		enemies.active = tf;
		bullets.active = tf;
		player.active = tf;
		vehicles.active = tf;
	}
}

private class Conditions {
	public static function isIntro(owner:PlayState):Bool {
		return owner.currentState == PlayingStates.INTRO;
	}
	public static function isPlaying(owner:PlayState):Bool {
		return owner.currentState == PlayingStates.GAMING;
	}
	public static function isOutro(owner:PlayState):Bool {
		return owner.currentState == PlayingStates.OUTRO;
	}
	public static function pressPause(owner:PlayState):Bool {
		return FlxG.keys.anyJustPressed([ENTER]);
	}
}

private class IntroState extends FlxFSMState<PlayState> {
	private var ticks:Int = 0;
	
	override public function enter(owner:PlayState, fsm:FlxFSM<PlayState>):Void {
		owner.toggleEntitiesActive(false);
		super.enter(owner, fsm);
	}
	
	override public function update(elapsed:Float, owner:PlayState, fsm:FlxFSM<PlayState>):Void 
	{
		if (ticks++ > 100) {
			owner.currentState = GAMING;
		}
		
		super.update(elapsed, owner, fsm);
	}
	
	override public function exit(owner:PlayState):Void
	{
		owner.toggleEntitiesActive(true);
		super.exit(owner);
	}
}

private class GamingState extends FlxFSMState<PlayState> {
	override public function update(elapsed:Float, owner:PlayState, fsm:FlxFSM<PlayState>):Void {
		owner.updateGamingState(elapsed);
		super.update(elapsed, owner, fsm);
	}
}

private class PausedState extends FlxFSMState<PlayState> {
	override public function enter(owner:PlayState, fsm:FlxFSM<PlayState>):Void {
		owner.toggleEntitiesActive(false);
		super.enter(owner, fsm);
	}

	override public function exit(owner:PlayState):Void {
		owner.toggleEntitiesActive(true);
		super.exit(owner);
	}
}

private class OutroState extends FlxFSMState<PlayState> {
	private var ticks:Int = 0;
	
	override public function enter(owner:PlayState, fsm:FlxFSM<PlayState>):Void {
		owner.toggleEntitiesActive(false);
		super.enter(owner, fsm);
	}
	
	override public function update(elapsed:Float, owner:PlayState, fsm:FlxFSM<PlayState>):Void {
		if (ticks++ > 100) {
			FlxG.resetState();
		}
		
		owner.updateGamingState(elapsed);
		super.update(elapsed, owner, fsm);
	}
}

private enum PlayingStates {
	INTRO;
	GAMING;
	PAUSED;
	OUTRO;
}