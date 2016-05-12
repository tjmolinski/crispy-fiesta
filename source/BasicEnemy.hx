package;

import flixel.math.FlxPoint;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.tile.FlxTilemap;

/**
 * ...
 * @author TJ
 */
class BasicEnemy extends FlxSprite 
{

	private var runSpeed:Float = 100;
	private var xMaxVel:Float = 20;
	private var yMaxVel:Float = 500;

	private var playerDrag:Float = 1600;
	private var gravity:Float = 700;
	private var jumpSpeed:Float = -300;
	
	private var tileMap:FlxTilemap;
	
	private var halfWidth:Float;
	private var halfHeight:Float;
	
	override public function new(X:Float, Y:Float, _width:Float, _height:Float, _isWalkingLeft:Bool, _map:FlxTilemap) 
	{
		tileMap = _map;
		
		super(X, Y);
		
		makeGraphic(cast(_width, Int), cast(_height, Int), FlxColor.PINK);
		drag.set(playerDrag, playerDrag);
		acceleration.set(0, gravity);
		maxVelocity.set(xMaxVel, yMaxVel);
		flipX = _isWalkingLeft;
		
		halfWidth = width / 2;
		halfHeight = height / 2;
	}
	
	override public function update(elapsed:Float):Void
	{
		//TODO: Make the sizing more dynamic
		var xTile = Math.floor((x+halfWidth) / PlayState.TILE_WIDTH);
		var yTile = Math.floor((y+halfHeight) / PlayState.TILE_HEIGHT);
		var a = tileMap.getTile(xTile+(flipX?-1:1), yTile+1);
		if (a == 0)
		{
			flipX = !flipX;
		}
		if (this.isTouching(FlxObject.WALL))
		{
			flipX = !flipX;
		}
		
		velocity.x = flipX ? -runSpeed : runSpeed;
		
		super.update(elapsed);
	}
}