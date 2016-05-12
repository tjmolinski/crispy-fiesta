package;

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

using flixel.util.FlxSpriteUtil;

class PlayState extends FlxState
{
	private var player:Player;
	private var message:FlxTypeText;
	private var ladders:FlxGroup;
	private var enemies:FlxGroup;
	private var movingPlatforms:FlxGroup;
	private var bullets:FlxTypedGroup<Bullet>;
	
	private var OVERLAY_COLOR = 0xdd000000;
	private var shadowCanvas:FlxSprite;
	private var shadowOverlay:FlxSprite;
	
	private var _effectSprite:FlxEffectSprite;
	private var _trail:FlxTrailEffect;
	private var _glitch:FlxGlitchEffect;
	
	private var _map:FlxOgmoLoader;
	public var _mWalls:FlxTilemap;

	public static var TILE_WIDTH:Int = 32;
	public static var TILE_HEIGHT:Int = 32;

	override public function create():Void
	{
		FlxG.camera.bgColor = 0xff333333;
				
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
		
		_mWalls.setTileProperties(16, FlxObject.UP, handleFallThrough);
		_mWalls.setTileProperties(17, FlxObject.NONE);
		_mWalls.setTileProperties(18, FlxObject.NONE);
		_mWalls.setTileProperties(19, FlxObject.NONE);
		_mWalls.setTileProperties(20, FlxObject.NONE);
		_mWalls.setTileProperties(21, FlxObject.NONE);
		_mWalls.setTileProperties(22, FlxObject.NONE);
		_mWalls.setTileProperties(23, FlxObject.NONE);
		
		add(_mWalls);
		
		enemies = new FlxGroup();
		add(enemies);
		ladders = new FlxGroup();
		add(ladders);
		movingPlatforms = new FlxGroup();
		add(movingPlatforms);
		
		bullets = new FlxTypedGroup<Bullet>(100);
		add(bullets);
		
		_map.loadEntities(function(type:String, data:Xml) {
			var posX = Std.parseInt(data.get("x"));
			var posY = Std.parseInt(data.get("y"));
			switch(type) {
				case "player":
					//player = new LinearJumpingPlayer(posX, posY, bullets);
					//player = new VariableJumpingPlayer(posX, posY, bullets);
					player = new DoubleJumpingPlayer(posX, posY, TILE_WIDTH, TILE_HEIGHT, bullets);
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
					enemies.add(new BasicEnemy(posX, posY, TILE_WIDTH, TILE_HEIGHT, data.get("walkLeft") == "True", _mWalls));
					
			}
		});
		
		// Effect Sprite
		//add(_effectSprite = new FlxEffectSprite(player));
		// Effects
		//_trail = new FlxTrailEffect(_effectSprite, 2, 0.5, 1);
		//_glitch = new FlxGlitchEffect(5, 3, 0.05);
		//_effectSprite.effects = [_trail, _glitch];
		
		var levelBounds = _mWalls.getBounds();
		FlxG.worldBounds.set( levelBounds.x, levelBounds.y, levelBounds.width, levelBounds.height);
		
		shadowCanvas = new FlxSprite();
		shadowCanvas.blend = BlendMode.MULTIPLY;
		shadowCanvas.makeGraphic(cast(levelBounds.width, Int), cast(levelBounds.height, Int), FlxColor.TRANSPARENT, true);
		add(shadowCanvas);
		shadowOverlay = new FlxSprite();
		shadowOverlay.makeGraphic(cast(levelBounds.width, Int), cast(levelBounds.height, Int), FlxColor.TRANSPARENT, true);
		shadowOverlay.blend = BlendMode.MULTIPLY;
		add(shadowOverlay);
		
		/*message = new FlxTypeText(player.x, player.y - 100, 200, "testing a message that tests the messaging test", 16, true);
		add(message);
		message.showCursor = true;
		message.start(0.1, false, false, [ENTER], function() {
			message.showCursor = false;
		});*/
		
		FlxG.camera.follow(player, FlxCameraFollowStyle.PLATFORMER, 1);
		FlxG.camera.maxScrollX = levelBounds.right;
		FlxG.camera.minScrollX = levelBounds.left;
		FlxG.camera.maxScrollY = levelBounds.bottom;
		FlxG.camera.minScrollY = levelBounds.top;

		super.create();
	}

	private function handleFallThrough(Tile:FlxObject, Object:FlxObject):Void
	{
		if (Object != player) {
			return;
		}
		
		var _pl = cast(Object, Player);
		
		if (FlxG.keys.anyPressed([DOWN]) && FlxG.keys.anyJustPressed([SPACE]))
		{
			_pl.fallThroughObj = Tile;
			_pl.fallingThrough = true;
		}
	}

	override public function update(elapsed:Float):Void
	{
		processShadows();
		//_effectSprite.setPosition(player.x, player.y);
		
		//message.x = player.x - (message.width/2);
		//message.y = player.y - 100;

		FlxG.overlap(player, movingPlatforms, function(_pl:Player, obj:MovingPlatform)
		{
			handleFallThrough(obj, _pl);
			
			if (_pl.isTouching(FlxObject.DOWN)) 
			{
				_pl.hitFloor();
			}

		}, function(_pl:Player, obj:MovingPlatform) {
			
			if (_pl.fallThroughObj != null && _pl.fallThroughObj.y < _pl.y)
			{
				_pl.fallThroughObj = null;
				_pl.fallingThrough = false;
			} 
			else if (_pl.fallingThrough)
			{
				return false;
			}
			
			return FlxObject.separate(player, obj);
		});
		
		var onLadder = false;
		FlxG.overlap(player, ladders, function(player:Player, obj:Ladder) {}, 
		function(player:Player, obj:Ladder)
		{
			if (FlxG.keys.anyPressed([UP]) && (player.y+player.height) < obj.y && obj.isHead)
			{
				return FlxObject.separate(player, obj);
			}
			else if (FlxG.keys.anyPressed([DOWN, UP]) || player.getLadderState()) 
			{
				player.setLadderState(true, obj.x);
				onLadder = true;
				return false;
			}
			else 
			{
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
				
		_mWalls.overlapsWithCallback(player, function(_tile: FlxObject, _player: FlxObject)
		{
			var _pl = cast(_player, Player);
			
			if (_pl.fallThroughObj != null && _pl.fallThroughObj.y < _pl.y)
			{
				_pl.fallThroughObj = null;
				_pl.fallingThrough = false;
			} 
			else if (_pl.fallingThrough)
			{
				return false;
			}
			
			return FlxObject.separate(_tile, _player);
		});
		enemies.forEach(function(enemy:FlxBasic) {
			_mWalls.overlapsWithCallback(cast(enemy, FlxObject), FlxObject.separate);
		});
		
		if (!onLadder) {
			player.setLadderState(false);
		}
		
		super.update(elapsed);
	}
	
	public function processShadows():Void
	{
		shadowCanvas.fill(FlxColor.TRANSPARENT);
		shadowOverlay.fill(OVERLAY_COLOR);

		var col = new FlxColor(0xffcc77ee);
		var studderEffect = 1;
		for (i in 0...5)
		{
			col.alpha = 10 + (25 * i);
			
			var radius = 100 + (25 * i);
		
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
		bullets.forEachExists(function(bullet: Bullet)
		{
			for (i in 0...5)
			{
				bulletColor.alpha = 10 + (25 * i);

				var radius = 5 + (2.5 * i);
			
				shadowOverlay.drawCircle(
					bullet.x + (bullet.width/2) + FlxG.random.float( -.6, .6),
					bullet.y + (bullet.height/2) + FlxG.random.float( -.6, .6),
					(FlxG.random.bool(5) ? radius : radius + studderEffect), bulletColor);
			}
		});
	}
}