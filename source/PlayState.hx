package;

import flash.external.ExternalInterface;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxBasic;
import flixel.FlxState;
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
import flixel.addons.editors.ogmo.FlxOgmoLoader;

using flixel.util.FlxSpriteUtil;

class PlayState extends FlxState {
	
	private var fsm:FlxFSM<PlayState>;

	private var message:FlxTypeText;
	
	private var OVERLAY_COLOR = 0xdd000000;
	private var shadowCanvas:FlxSprite;
	private var shadowOverlay:FlxSprite;
	
	private var _effectSprite:FlxEffectSprite;
	private var _trail:FlxTrailEffect;
	private var _glitch:FlxGlitchEffect;
	
	public var currentState:PlayingStates;

	override public function create():Void {
		createTileMap();
		createEntities();
		createStateMachine();
		setupCamera();

		super.create();
	}

	override public function destroy():Void {
		GameObjects.instance.bullets.clear();
		GameObjects.instance.movingPlatforms.clear();
		GameObjects.instance.ladders.clear();
		GameObjects.instance.enemies.clear();
		GameObjects.instance.killPits.clear();
		GameObjects.instance.exits.clear();
		GameObjects.instance.vehicles.clear();
		GameObjects.instance.enemies.clear();
		GameObjects.instance.bosses.clear();
		GameObjects.instance.lasers.clear();
		GameObjects.instance.bullets.clear();
		GameObjects.instance.pistols.clear();
		GameObjects.instance.shotguns.clear();
		GameObjects.instance.machineguns.clear();
		remove(GameObjects.instance.mapData);
		remove(GameObjects.instance.ladders);
		remove(GameObjects.instance.movingPlatforms);
		remove(GameObjects.instance.killPits);
		remove(GameObjects.instance.exits);
		remove(GameObjects.instance.vehicles);
		remove(GameObjects.instance.enemies);
		remove(GameObjects.instance.bosses);
		remove(GameObjects.instance.lasers);
		remove(GameObjects.instance.bullets);
		remove(GameObjects.instance.pistols);
		remove(GameObjects.instance.shotguns);
		remove(GameObjects.instance.machineguns);
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
		GameObjects.instance.ogmoMap = new FlxOgmoLoader("assets/data/test_level.oel");
		GameObjects.instance.mapData = GameObjects.instance.ogmoMap.loadTilemap("assets/images/level_tiles.png", GameObjects.TILE_WIDTH, GameObjects.TILE_HEIGHT, "tiles");

		GameObjects.instance.mapData.setTileProperties(0, FlxObject.NONE);
		GameObjects.instance.mapData.setTileProperties(1, FlxObject.UP);
		GameObjects.instance.mapData.setTileProperties(2, FlxObject.RIGHT);
		GameObjects.instance.mapData.setTileProperties(3, FlxObject.DOWN);
		GameObjects.instance.mapData.setTileProperties(4, FlxObject.LEFT);
		GameObjects.instance.mapData.setTileProperties(5, FlxObject.UP | FlxObject.RIGHT);
		GameObjects.instance.mapData.setTileProperties(6, FlxObject.RIGHT | FlxObject.DOWN);
		GameObjects.instance.mapData.setTileProperties(7, FlxObject.DOWN | FlxObject.LEFT);
		
		GameObjects.instance.mapData.setTileProperties(8, FlxObject.LEFT | FlxObject.UP);
		GameObjects.instance.mapData.setTileProperties(9, FlxObject.LEFT | FlxObject.UP | FlxObject.RIGHT);
		GameObjects.instance.mapData.setTileProperties(10, FlxObject.UP | FlxObject.RIGHT | FlxObject.DOWN);
		GameObjects.instance.mapData.setTileProperties(11, FlxObject.RIGHT | FlxObject.DOWN | FlxObject.LEFT);
		GameObjects.instance.mapData.setTileProperties(12, FlxObject.UP | FlxObject.DOWN | FlxObject.LEFT);
		GameObjects.instance.mapData.setTileProperties(13, FlxObject.RIGHT | FlxObject.LEFT);
		GameObjects.instance.mapData.setTileProperties(14, FlxObject.UP | FlxObject.DOWN);
		GameObjects.instance.mapData.setTileProperties(15, FlxObject.NONE);
		
		GameObjects.instance.mapData.setTileProperties(16, FlxObject.UP, handleFallThrough); //Blue is jump throughable floor
		GameObjects.instance.mapData.setTileProperties(17, FlxObject.NONE); //Yellow	
		GameObjects.instance.mapData.setTileProperties(18, FlxObject.NONE); //Purple
		GameObjects.instance.mapData.setTileProperties(19, FlxObject.NONE); //Orange
		GameObjects.instance.mapData.setTileProperties(20, FlxObject.NONE);
		GameObjects.instance.mapData.setTileProperties(21, FlxObject.NONE);
		GameObjects.instance.mapData.setTileProperties(22, FlxObject.NONE);
		GameObjects.instance.mapData.setTileProperties(23, FlxObject.NONE);
	}
	
	private function createEntities():Void {
		add(GameObjects.instance.mapData);
		add(GameObjects.instance.ladders);
		add(GameObjects.instance.killPits);
		add(GameObjects.instance.exits);
		add(GameObjects.instance.vehicles);
		add(GameObjects.instance.movingPlatforms);
		add(GameObjects.instance.enemies);
		add(GameObjects.instance.bosses);

		GameObjects.instance.ogmoMap.loadEntities(function(type:String, data:Xml) {
			var posX = Std.parseInt(data.get("x"));
			var posY = Std.parseInt(data.get("y"));
			switch(type) {
				case "player":
					//player = new LinearJumpingPlayer(posX, posY, 32, 32);
					GameObjects.instance.player = new VariableJumpingPlayer(posX, posY, 32, 32);
					//player = new DoubleJumpingPlayer(posX, posY, 32, 32);
					add(GameObjects.instance.player);
				case "ladder":
					GameObjects.instance.ladders.add(new Ladder(posX, posY, data.get("isHead") == "True"));
				case "movingPlatform":
					var width : Int = Std.parseInt(data.get("width"));
					var height : Int = Std.parseInt(data.get("height"));
					var moveX : Float = Std.parseInt(data.get("xMove"));
					var moveY : Float = Std.parseInt(data.get("yMove"));
					GameObjects.instance.movingPlatforms.add(new MovingPlatform(posX, posY, width, height, moveX, moveY));
				case "basicEnemy":
					GameObjects.instance.enemies.recycle(BasicEnemy).spawn(posX, posY, data.get("walkLeft") == "True");
				case "boss":
					var offsetX : Float = Std.parseFloat(data.get("offsetX"));
					GameObjects.instance.bosses.recycle(Boss).spawn(posX, posY, offsetX);
				case "exit":
					var width : Int = Std.parseInt(data.get("width"));
					var height : Int = Std.parseInt(data.get("height"));
					GameObjects.instance.exits.recycle(Exit).spawn(posX, posY, width, height);
				case "killPit":
					var width : Int = Std.parseInt(data.get("width"));
					var height : Int = Std.parseInt(data.get("height"));
					GameObjects.instance.killPits.recycle(KillPit).spawn(posX, posY, width, height);
				case "vehicle":
					GameObjects.instance.vehicles.recycle(Vehicle).spawn(posX, posY);
					
			}
		});

		add(GameObjects.instance.lasers);
		add(GameObjects.instance.pistols);
		add(GameObjects.instance.shotguns);
		add(GameObjects.instance.machineguns);
		add(GameObjects.instance.bullets);

		// shotguns.recycle(Shotgun).giveGun(GameObjects.instance.player);
		// machineguns.recycle(MachineGun).giveGun(GameObjects.instance.player);
		GameObjects.instance.pistols.recycle(Pistol).giveGun(GameObjects.instance.player);
		
		toggleEntitiesActive(false);
	}
	
	private function setupCamera():Void {
		/* Effect Sprite and Message Text
		add(_effectSprite = new FlxEffectSprite(GameObjects.instance.player));
		// Effects
		_trail = new FlxTrailEffect(_effectSprite, 2, 0.5, 1);
		_glitch = new FlxGlitchEffect(5, 3, 0.05);
		_effectSprite.effects = [_trail, _glitch];
		
		message = new FlxTypeText(GameObjects.instance.player.x, GameObjects.instance.player.y - 100, 200, "testing a message that tests the messaging test", 16, true);
		add(message);
		message.showCursor = true;
		message.start(0.1, false, false, [ENTER], function() {
			message.showCursor = false;
		});*/
		
		var levelBounds = GameObjects.instance.mapData.getBounds();
		FlxG.worldBounds.set(levelBounds.x, levelBounds.y, levelBounds.width, levelBounds.height);
		
		/*shadowCanvas = new FlxSprite();
		shadowCanvas.blend = BlendMode.MULTIPLY;
		shadowCanvas.makeGraphic(cast(levelBounds.width, Int), cast(levelBounds.height, Int), FlxColor.TRANSPARENT, true);
		add(shadowCanvas);
		shadowOverlay = new FlxSprite();
		shadowOverlay.makeGraphic(cast(levelBounds.width, Int), cast(levelBounds.height, Int), FlxColor.TRANSPARENT, true);
		shadowOverlay.blend = BlendMode.MULTIPLY;
		add(shadowOverlay);*/
		
		FlxG.camera.follow(GameObjects.instance.player, FlxCameraFollowStyle.PLATFORMER, 0.05);
		FlxG.camera.targetOffset.set(100, 0);
		FlxG.camera.maxScrollX = levelBounds.right;
		FlxG.camera.minScrollX = levelBounds.left;
		FlxG.camera.maxScrollY = levelBounds.bottom;
		FlxG.camera.minScrollY = levelBounds.top;
		
		FlxG.camera.bgColor = 0xff333333;
	}
	
	private function fellInDeathPit(Tile:FlxObject, Object:FlxObject):Void {
		GameObjects.instance.player.kill();
	}
	
	private function handleFallThrough(Tile:FlxObject, Object:FlxObject):Void {
		if (Object == GameObjects.instance.player) {
			var _pl = cast(Object, Player);
			
			if (FlxG.keys.anyPressed([DOWN]) && FlxG.keys.anyJustPressed([_pl.jumpBtn])) {
				_pl.fallThroughObj = Tile;
				_pl.fallingThrough = true;
			}
		} else if(Object == GameObjects.instance.player.vehicle) {
			var _veh = cast(Object, Vehicle);
			
			if (FlxG.keys.anyPressed([DOWN]) && FlxG.keys.anyJustPressed([GameObjects.instance.player.jumpBtn])) {
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
				GameObjects.instance.player.x + (GameObjects.instance.player.width/2) + FlxG.random.float( -.6, .6),
				GameObjects.instance.player.y + (GameObjects.instance.player.height/2) + FlxG.random.float( -.6, .6),
				(FlxG.random.bool(5) ? radius : radius + studderEffect), col);
			/*var size = (FlxG.random.bool(5) ? radius : radius + 0.5);
			shadowOverlay.drawRect(
				GameObjects.instance.player.x - (size / 2) + (GameObjects.instance.player.width/2) + FlxG.random.float( -.6, .6),
				GameObjects.instance.player.y - (size / 2) + (GameObjects.instance.player.width/2) + FlxG.random.float( -.6, .6),
				size, size, col);*/
		}

		var bulletColor = new FlxColor(0xffffffcc);
		GameObjects.instance.bullets.forEachExists(function(bullet: Bullet) {
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
		//_effectSprite.setPosition(GameObjects.instance.player.x, GameObjects.instance.player.y);
		//message.x = GameObjects.instance.player.x - (message.width/2);
		//message.y = GameObjects.instance.player.y - 100;
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

		FlxG.overlap(GameObjects.instance.bullets, GameObjects.instance.player, bulletCollision);
		FlxG.overlap(GameObjects.instance.bullets, GameObjects.instance.enemies, bulletCollision);
		FlxG.overlap(GameObjects.instance.bullets, GameObjects.instance.vehicles, bulletCollision);

		FlxG.overlap(GameObjects.instance.lasers, GameObjects.instance.player, laserCollision);
		FlxG.overlap(GameObjects.instance.lasers, GameObjects.instance.vehicles, laserCollision);

		GameObjects.instance.bosses.forEach(function(boss: Boss) {
			FlxG.overlap(GameObjects.instance.bullets, boss.weakSpot, function(bullet:Bullet, thing:FlxSprite) {
				bulletCollision(bullet, boss);
			});
			FlxG.overlap(GameObjects.instance.player, boss.body, function(_pl:Player, thing:FlxSprite) {
				enemyCollision(_pl, boss);
			});
		});

		FlxG.overlap(GameObjects.instance.player, GameObjects.instance.enemies, enemyCollision);

		FlxG.overlap(GameObjects.instance.player, GameObjects.instance.vehicles, function(_pl:Player, veh:Vehicle) {
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
		FlxG.overlap(GameObjects.instance.player, GameObjects.instance.movingPlatforms, function(_pl:Player, obj:MovingPlatform) {
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
		FlxG.overlap(GameObjects.instance.vehicles, GameObjects.instance.movingPlatforms, function(veh:Vehicle, obj:MovingPlatform) {
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
		FlxG.overlap(GameObjects.instance.player, GameObjects.instance.ladders, function(_pl:Player, obj:Ladder) {}, function(_pl:Player, obj:Ladder) {
			if (FlxG.keys.anyPressed([UP]) && (_pl.y+_pl.height) < obj.y && obj.isHead) {
				return FlxObject.separate(_pl, obj);
			} else if (FlxG.keys.anyPressed([DOWN, UP]) || _pl.getLadderState()) {
				_pl.setLadderState(true, obj.x);
				onLadder = true;
				return false;
			} else {
				if (obj.isHead) 
				{
					return FlxObject.separate(_pl, obj);
				}
				else
				{
					return false;
				}
			}
		});
		
		FlxG.overlap(GameObjects.instance.player, GameObjects.instance.killPits, function(_pl:Player, killPit:KillPit) {
			if (_pl.y > killPit.y) {
				_pl.kill();
			}
		});
		
		FlxG.overlap(GameObjects.instance.player, GameObjects.instance.exits, function(_pl:Player, exit:Exit) {
			if (Math.abs(_pl.x - exit.x) < 5) {
				currentState = OUTRO;
			}
		});
				
		GameObjects.instance.mapData.overlapsWithCallback(GameObjects.instance.player, function(_tile: FlxObject, _player: FlxObject) {
			var castedPlayer = cast(_player, Player);
			
			if (castedPlayer.fallThroughObj != null && castedPlayer.fallThroughObj.y < castedPlayer.y) {
				castedPlayer.fallThroughObj = null;
				castedPlayer.fallingThrough = false;
			} else if (castedPlayer.fallingThrough) {
				return false;
			}
			
			return FlxObject.separate(_tile, castedPlayer);
		});
		GameObjects.instance.enemies.forEach(function(enemy:BasicEnemy) {
			GameObjects.instance.mapData.overlapsWithCallback(enemy, FlxObject.separate);
		});
		GameObjects.instance.bosses.forEach(function(boss:Boss) {
			GameObjects.instance.mapData.overlapsWithCallback(boss.body, FlxObject.separate);
		});
		GameObjects.instance.vehicles.forEach(function(vehicle:Vehicle) {
			GameObjects.instance.mapData.overlapsWithCallback(vehicle, function(_tile: FlxObject, veh: FlxObject) {
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
			GameObjects.instance.player.setLadderState(false);
		}
		
		if (GameObjects.instance.player.isDead) {
			currentState = OUTRO;
		}
	}

	public function toggleEntitiesActive(tf: Bool):Void {
		GameObjects.instance.ladders.active = tf;
		GameObjects.instance.movingPlatforms.active = tf;
		GameObjects.instance.enemies.active = tf;
		GameObjects.instance.bullets.active = tf;
		GameObjects.instance.player.active = tf;
		GameObjects.instance.vehicles.active = tf;
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