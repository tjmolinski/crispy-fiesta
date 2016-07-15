package;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmoLoader;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxGlitchEffect;
import flixel.addons.effects.chainable.FlxTrailEffect;
import flixel.addons.text.FlxTypeText;
import flixel.addons.tile.FlxTilemapExt;
import flixel.addons.util.FlxFSM;
import flixel.addons.util.FlxFSM;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.addons.editors.spine.FlxSpine;
import spinehaxe.SkeletonData;

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

	public var ammoText: FlxText;

	override public function create():Void {
		createTileMap();
		createEntities();
		createStateMachine();
		setupCamera();

		super.create();
	}

	override public function destroy():Void {
		GameObjects.instance.pistolBullets.clear();
		GameObjects.instance.flameBullets.clear();
		GameObjects.instance.movingPlatforms.clear();
		GameObjects.instance.disappearingPlatforms.clear();
		GameObjects.instance.springyFloors.clear();
		GameObjects.instance.ladders.clear();
		GameObjects.instance.enemies.clear();
		GameObjects.instance.spikes.clear();
		GameObjects.instance.killPits.clear();
		GameObjects.instance.exits.clear();
		GameObjects.instance.vehicles.clear();
		GameObjects.instance.enemies.clear();
		GameObjects.instance.bosses.clear();
		GameObjects.instance.lasers.clear();
		GameObjects.instance.pistols.clear();
		GameObjects.instance.shotguns.clear();
		GameObjects.instance.machineguns.clear();
		GameObjects.instance.flameguns.clear();
		GameObjects.instance.rawketLawnChairs.clear();
		GameObjects.instance.spreaderPickup.clear();
		GameObjects.instance.machinegunPickup.clear();
		GameObjects.instance.rawketlawnchairPickup.clear();
		remove(GameObjects.instance.mapData);
		remove(GameObjects.instance.ladders);
		remove(GameObjects.instance.movingPlatforms);
		remove(GameObjects.instance.disappearingPlatforms);
		remove(GameObjects.instance.springyFloors);
		remove(GameObjects.instance.spikes);
		remove(GameObjects.instance.killPits);
		remove(GameObjects.instance.exits);
		remove(GameObjects.instance.vehicles);
		remove(GameObjects.instance.enemies);
		remove(GameObjects.instance.bosses);
		remove(GameObjects.instance.lasers);
		remove(GameObjects.instance.pistolBullets);
		remove(GameObjects.instance.flameBullets);
		remove(GameObjects.instance.pistols);
		remove(GameObjects.instance.shotguns);
		remove(GameObjects.instance.machineguns);
		remove(GameObjects.instance.flameguns);
		remove(GameObjects.instance.spreaderPickup);
		remove(GameObjects.instance.machinegunPickup);
		remove(GameObjects.instance.flamegunPickup);
		remove(GameObjects.instance.rawketlawnchairPickup);

		remove(ammoText);
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
		GameObjects.instance.ogmoMap = new FlxOgmoLoader("assets/data/test_level3.oel");
		var ogmoData = GameObjects.instance.ogmoMap.loadTilemap("assets/images/level_tile.png", GameObjects.TILE_WIDTH, GameObjects.TILE_HEIGHT, "tiles");
		GameObjects.instance.mapData = new FlxTilemapExt();
		GameObjects.instance.mapData.loadMapFromArray(
			ogmoData.getData(false),
			ogmoData.widthInTiles,
			ogmoData.heightInTiles,
			"assets/images/level_tile.png",
			GameObjects.TILE_WIDTH, GameObjects.TILE_HEIGHT
			);

		GameObjects.instance.mapData.setTileProperties(0, FlxObject.NONE);
		GameObjects.instance.mapData.setTileProperties(1, FlxObject.UP);
		GameObjects.instance.mapData.setTileProperties(2, FlxObject.RIGHT);
		GameObjects.instance.mapData.setTileProperties(3, FlxObject.DOWN);
		GameObjects.instance.mapData.setTileProperties(4, FlxObject.LEFT);

		GameObjects.instance.mapData.setTileProperties(5, FlxObject.NONE);
		GameObjects.instance.mapData.setTileProperties(6, FlxObject.UP | FlxObject.LEFT);
		GameObjects.instance.mapData.setTileProperties(7, FlxObject.UP | FlxObject.RIGHT);
		GameObjects.instance.mapData.setTileProperties(8, FlxObject.DOWN | FlxObject.LEFT);
		GameObjects.instance.mapData.setTileProperties(9, FlxObject.DOWN | FlxObject.RIGHT);

		GameObjects.instance.mapData.setTileProperties(10, FlxObject.NONE);
		GameObjects.instance.mapData.setTileProperties(11, FlxObject.UP | FlxObject.DOWN);
		GameObjects.instance.mapData.setTileProperties(12, FlxObject.RIGHT | FlxObject.LEFT);
		GameObjects.instance.mapData.setTileProperties(13, FlxObject.NONE);
		GameObjects.instance.mapData.setTileProperties(14, FlxObject.NONE);

		GameObjects.instance.mapData.setTileProperties(15, FlxObject.NONE);
		GameObjects.instance.mapData.setTileProperties(16, FlxObject.UP, handleFallThrough);
		GameObjects.instance.mapData.setTileProperties(17, FlxObject.UP, handleFallThrough);
		GameObjects.instance.mapData.setTileProperties(18, FlxObject.UP, handleFallThrough);

		GameObjects.instance.mapData.setSlopes([21,22,23],[26,27,28],[36,37,38],[31,32,33]);
		GameObjects.instance.mapData.setGentle([22,23,26,27,31,32,37,38],[21,28,33,36]);
	}
	
	private function createEntities():Void {
		add(GameObjects.instance.mapData);
		add(GameObjects.instance.ladders);
		add(GameObjects.instance.spikes);
		add(GameObjects.instance.killPits);
		add(GameObjects.instance.exits);
		add(GameObjects.instance.vehicles);
		add(GameObjects.instance.movingPlatforms);
		add(GameObjects.instance.disappearingPlatforms);
		add(GameObjects.instance.springyFloors);
		add(GameObjects.instance.enemies);
		add(GameObjects.instance.bosses);
		add(GameObjects.instance.spreaderPickup);
		add(GameObjects.instance.machinegunPickup);
		add(GameObjects.instance.flamegunPickup);
		add(GameObjects.instance.rawketlawnchairPickup);

		ammoText = new FlxText(0, 0, "Ammo: Infinity", 20);
		add(ammoText);

		GameObjects.instance.ogmoMap.loadEntities(function(type:String, data:Xml) {
			var posX = Std.parseInt(data.get("x"));
			var posY = Std.parseInt(data.get("y"));
			switch(type) {
				case "player":
					//player = new LinearJumpingPlayer(posX, posY);
					GameObjects.instance.player = new VariableJumpingPlayer(FlxSpine.readSkeletonData("spineboy", "spineboy", "assets/images/", 0.1), posX, posY);
					//player = new DoubleJumpingPlayer(posX, posY);
					add(GameObjects.instance.player);
				case "ladder":
					GameObjects.instance.ladders.add(new Ladder(posX, posY, data.get("isHead") == "True"));
				case "movingPlatform":
					var width : Int = Std.parseInt(data.get("width"));
					var height : Int = Std.parseInt(data.get("height"));
					var moveX : Float = Std.parseInt(data.get("xMove"));
					var moveY : Float = Std.parseInt(data.get("yMove"));
					GameObjects.instance.movingPlatforms.add(new MovingPlatform(posX, posY, width, height, moveX, moveY));
				case "disappearingPlatform":
					var width : Int = Std.parseInt(data.get("width"));
					var height : Int = Std.parseInt(data.get("height"));
					GameObjects.instance.disappearingPlatforms.add(new DisappearingPlatform(posX, posY, width, height));
				case "springyFloor":
					var width : Int = Std.parseInt(data.get("width"));
					var height : Int = Std.parseInt(data.get("height"));
					GameObjects.instance.springyFloors.add(new SpringyFloor(posX, posY, width, height));
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
				case "spike":
					GameObjects.instance.spikes.recycle(Spike).spawn(posX, posY);
				case "vehicle":
					// GameObjects.instance.vehicles.recycle(Vehicle).spawn(posX, posY);
				case "spreaderPickup":
					GameObjects.instance.spreaderPickup.recycle(SpreaderGunPickup).spawn(posX, posY);
				case "machinegunPickup":
					GameObjects.instance.machinegunPickup.recycle(MachineGunPickup).spawn(posX, posY);
				case "flamegunPickup":
					GameObjects.instance.flamegunPickup.recycle(FlameGunPickup).spawn(posX, posY);
				case "rawketLawnChairPickup":
					GameObjects.instance.rawketlawnchairPickup.recycle(RawketLawnChairPickup).spawn(posX, posY);
					
			}
		});

		add(GameObjects.instance.lasers);
		add(GameObjects.instance.pistols);
		add(GameObjects.instance.shotguns);
		add(GameObjects.instance.machineguns);
		add(GameObjects.instance.flameguns);
		add(GameObjects.instance.rawketLawnChairs);
		add(GameObjects.instance.pistolBullets);
		add(GameObjects.instance.flameBullets);
		add(GameObjects.instance.rawketBullets);
		
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
		
		FlxG.camera.follow(GameObjects.instance.player.sprite, FlxCameraFollowStyle.PLATFORMER, 0.05);
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
		if (Object == GameObjects.instance.player.sprite) {
			var _pl = cast(Object, Player);
			
			if (FlxG.keys.anyPressed([DOWN]) && FlxG.keys.anyJustPressed([_pl.jumpBtn])) {
				_pl.fallThroughObj = Tile;
				_pl.fallingThrough = true;
			}
		// } else if(Object == GameObjects.instance.player.vehicle) {
		// 	var _veh = cast(Object, Vehicle);
			
		// 	if (FlxG.keys.anyPressed([DOWN]) && FlxG.keys.anyJustPressed([GameObjects.instance.player.jumpBtn])) {
		// 		_veh.fallThroughObj = Tile;
		// 		_veh.fallingThrough = true;
		// 	}
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
				GameObjects.instance.player.sprite.x + (GameObjects.instance.player.sprite.width/2) + FlxG.random.float( -.6, .6),
				GameObjects.instance.player.sprite.y + (GameObjects.instance.player.sprite.height/2) + FlxG.random.float( -.6, .6),
				(FlxG.random.bool(5) ? radius : radius + studderEffect), col);
			/*var size = (FlxG.random.bool(5) ? radius : radius + 0.5);
			shadowOverlay.drawRect(
				GameObjects.instance.player.x - (size / 2) + (GameObjects.instance.player.width/2) + FlxG.random.float( -.6, .6),
				GameObjects.instance.player.y - (size / 2) + (GameObjects.instance.player.width/2) + FlxG.random.float( -.6, .6),
				size, size, col);*/
		}

		var bulletColor = new FlxColor(0xffffffcc);
		GameObjects.instance.pistolBullets.forEachExists(function(bullet: Bullet) {
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

	private function playerBulletCollision(bullet:Bullet, thing:NestedSprite):Void {
		var pl = cast(thing.parent, Player);
		if(pl.nameType == "player" && pl.alive) {
			if (pl.nameType != bullet.owner.nameType) {
				pl.hitByBullet(bullet);
			}
		}
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
	
	// private function enemyCollision(_player:Player, thing:LivingThing):Void {
	// 	if(cast(thing, FlxBasic).alive && _player.alive) {
	// 		_player.overlappingEnemy(thing);
	// 	}
	// }
	
	private function pickupCollision(thing:GunPickup, _player:NestedSprite):Void {
		if(cast(thing, FlxBasic).alive && _player.parent.alive) {
			thing.pickup(cast(_player.parent, Player));
		}
	}
	
	public function updateGamingState(elapsed):Void {
		FlxG.camera.minScrollX = FlxG.camera.scroll.x;

		//TODO: Remove this and make the hud render to camera from a different position
		ammoText.x = FlxG.camera.scroll.x;

		FlxG.overlap(GameObjects.instance.pistolBullets, GameObjects.instance.player, playerBulletCollision);
		FlxG.overlap(GameObjects.instance.pistolBullets, GameObjects.instance.enemies, bulletCollision);
		FlxG.overlap(GameObjects.instance.pistolBullets, GameObjects.instance.vehicles, bulletCollision);
		FlxG.overlap(GameObjects.instance.flameBullets, GameObjects.instance.player, playerBulletCollision);
		FlxG.overlap(GameObjects.instance.flameBullets, GameObjects.instance.enemies, bulletCollision);
		FlxG.overlap(GameObjects.instance.flameBullets, GameObjects.instance.vehicles, bulletCollision);
		FlxG.overlap(GameObjects.instance.rawketBullets, GameObjects.instance.player, playerBulletCollision);
		FlxG.overlap(GameObjects.instance.rawketBullets, GameObjects.instance.enemies, bulletCollision);
		FlxG.overlap(GameObjects.instance.rawketBullets, GameObjects.instance.vehicles, bulletCollision);

		FlxG.overlap(GameObjects.instance.lasers, GameObjects.instance.player, laserCollision);
		FlxG.overlap(GameObjects.instance.lasers, GameObjects.instance.vehicles, laserCollision);

		FlxG.overlap(GameObjects.instance.spreaderPickup, GameObjects.instance.player, pickupCollision);
		FlxG.overlap(GameObjects.instance.machinegunPickup, GameObjects.instance.player, pickupCollision);
		FlxG.overlap(GameObjects.instance.flamegunPickup, GameObjects.instance.player, pickupCollision);
		FlxG.overlap(GameObjects.instance.rawketlawnchairPickup, GameObjects.instance.player, pickupCollision);

		GameObjects.instance.bosses.forEach(function(boss: Boss) {
			//XXX: DRY it up
			FlxG.overlap(GameObjects.instance.pistolBullets, boss.weakSpot, function(bullet:Bullet, thing:FlxSprite) {
				bulletCollision(bullet, boss);
			});
			FlxG.overlap(GameObjects.instance.flameBullets, boss.weakSpot, function(bullet:Bullet, thing:FlxSprite) {
				bulletCollision(bullet, boss);
			});
			FlxG.overlap(GameObjects.instance.rawketBullets, boss.weakSpot, function(bullet:Bullet, thing:FlxSprite) {
				bulletCollision(bullet, boss);
			});
			// FlxG.overlap(GameObjects.instance.player, boss.body, function(_pl:Player, thing:FlxSprite) {
			// 	enemyCollision(_pl, boss);
			// });
		});

		// FlxG.overlap(GameObjects.instance.player, GameObjects.instance.enemies, enemyCollision);

		// FlxG.overlap(GameObjects.instance.player, GameObjects.instance.vehicles, function(_pl:Player, veh:Vehicle) {
		// }, function(_pl:Player, veh:Vehicle) {
		// 	if(!_pl.escapingVehicle &&
		// 		_pl.y + _pl.halfHeight < veh.y && 
		// 		_pl.velocity.y > 0 &&
		// 		Math.abs((_pl.x + _pl.halfWidth) - (veh.x + veh.halfWidth)) < _pl.halfWidth) {
		// 		_pl.jumpInVehicle(veh);
		// 	}
		// 	return false;
		// });
		

		///XXX: DRY these two functions up//////////////////////////////////////////////////
		FlxG.overlap(GameObjects.instance.player, GameObjects.instance.movingPlatforms, function(_pl:Dynamic, obj:MovingPlatform) {
			handleFallThrough(obj, _pl.parent.sprite);
			
			if (_pl.parent.sprite.isTouching(FlxObject.DOWN)) {
				_pl.parent.hitFloor();
			}
		}, function(_pl:Dynamic, obj:MovingPlatform) {
			
			if (_pl.parent.fallThroughObj != null && _pl.parent.fallThroughObj.y < _pl.parent.sprite.y) {
				_pl.parent.fallThroughObj = null;
				_pl.parent.fallingThrough = false;
			} else if (_pl.parent.fallingThrough) {
				return false;
			}
			
			return FlxObject.separate(_pl.parent.sprite, obj);
		});
		// FlxG.overlap(GameObjects.instance.vehicles, GameObjects.instance.movingPlatforms, function(veh:Vehicle, obj:MovingPlatform) {
		// 	handleFallThrough(obj, veh);
			
		// 	if (veh.isTouching(FlxObject.DOWN)) {
		// 		veh.hitFloor();
		// 	}
		// }, function(veh:Vehicle, obj:MovingPlatform) {
			
		// 	if (veh.fallThroughObj != null && veh.fallThroughObj.y < veh.y) {
		// 		veh.fallThroughObj = null;
		// 		veh.fallingThrough = false;
		// 	} else if (veh.fallingThrough) {
		// 		return false;
		// 	}
			
		// 	return FlxObject.separate(veh, obj);
		// });
		////////////////////////////////////////////////////////////////////////////////////////
		///XXX: DRY these two functions up//////////////////////////////////////////////////
		FlxG.overlap(GameObjects.instance.player, GameObjects.instance.disappearingPlatforms, function(_pl:Player, obj:DisappearingPlatform) {
			obj.startDisappear();
		}, function(_pl:Player, obj:DisappearingPlatform) {
			
			if (obj.alpha <= 0.0) {
				return false;
			}
			
			return FlxObject.separate(_pl.sprite, obj);
		});
		FlxG.overlap(GameObjects.instance.player, GameObjects.instance.springyFloors, function(_pl:Player, obj:SpringyFloor) {
			if(_pl.sprite.velocity.y > 0 && (_pl.sprite.y+_pl.halfHeight) < (obj.y)) {
				_pl.springPlayer();
			}
		});
		////////////////////////////////////////////////////////////////////////////////////////

		
		var onLadder = false;
		FlxG.overlap(GameObjects.instance.player, GameObjects.instance.ladders, function(_pl:Player, obj:Ladder) {}, function(_pl:Player, obj:Ladder) {
			if (FlxG.keys.anyPressed([UP]) && (_pl.sprite.y+_pl.sprite.height) < obj.y && obj.isHead) {
				return FlxObject.separate(_pl.sprite, obj);
			} else if (FlxG.keys.anyPressed([DOWN, UP]) || _pl.getLadderState()) {
				_pl.setLadderState(true, obj.x);
				onLadder = true;
				return false;
			} else {
				if (obj.isHead) 
				{
					return FlxObject.separate(_pl.sprite, obj);
				}
				else
				{
					return false;
				}
			}
		});
		
		FlxG.overlap(GameObjects.instance.player, GameObjects.instance.killPits, function(_pl:Player, killPit:KillPit) {
			if (_pl.sprite.y > killPit.y) {
				_pl.kill();
			}
		});

		FlxG.overlap(GameObjects.instance.player, GameObjects.instance.spikes, function(_pl:Player, spike:Spike) {
			_pl.kill();
		});
		
		FlxG.overlap(GameObjects.instance.player, GameObjects.instance.exits, function(_pl:Player, exit:Exit) {
			if (Math.abs(_pl.sprite.x - exit.x) < 5) {
				currentState = OUTRO;
			}
		});
				
		GameObjects.instance.mapData.overlapsWithCallback(GameObjects.instance.player.sprite, function(_tile: FlxObject, _player: FlxObject) {
			// var castedPlayer = cast(_player, Player);
			
			if (GameObjects.instance.player.fallThroughObj != null && GameObjects.instance.player.fallThroughObj.y < GameObjects.instance.player.sprite.y) {
				GameObjects.instance.player.fallThroughObj = null;
				GameObjects.instance.player.fallingThrough = false;
			} else if (GameObjects.instance.player.fallingThrough) {
				return false;
			}
			
			return FlxObject.separate(_tile, GameObjects.instance.player.sprite);
		});
		GameObjects.instance.enemies.forEach(function(enemy:BasicEnemy) {
			GameObjects.instance.mapData.overlapsWithCallback(enemy, FlxObject.separate);
		});
		GameObjects.instance.bosses.forEach(function(boss:Boss) {
			GameObjects.instance.mapData.overlapsWithCallback(boss.body, FlxObject.separate);
		});
		// GameObjects.instance.vehicles.forEach(function(vehicle:Vehicle) {
		// 	GameObjects.instance.mapData.overlapsWithCallback(vehicle, function(_tile: FlxObject, veh: FlxObject) {
		// 		var _veh = cast(veh, Vehicle);
				
		// 		if (_veh.fallThroughObj != null && _veh.fallThroughObj.y < _veh.y) {
		// 			_veh.fallThroughObj = null;
		// 			_veh.fallingThrough = false;
		// 		} else if (_veh.fallingThrough) {
		// 			return false;
		// 		}
				
		// 		return FlxObject.separate(_tile, _veh);
		// 	});
		// });
		
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
		GameObjects.instance.disappearingPlatforms.active = tf;
		GameObjects.instance.springyFloors.active = tf;
		GameObjects.instance.enemies.active = tf;
		GameObjects.instance.pistolBullets.active = tf;
		GameObjects.instance.flameBullets.active = tf;
		GameObjects.instance.rawketBullets.active = tf;
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