package;

import flixel.FlxGame;
import flixel.FlxG;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		addChild(new FlxGame(640, 480, MenuState, 1, 60, 60, true, false));
	}
}