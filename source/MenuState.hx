package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;

class MenuState extends FlxState
{	
	override public function create():Void
	{
		var title:FlxText = new FlxText(0, 0, FlxG.width, "TITLE GOES HERE", 20);
		add(title);
		var instructions:FlxText = new FlxText(0, FlxG.height * 0.5, FlxG.width, "Z TO START", 20);
		add(instructions);
		super.create();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		if (FlxG.keys.anyJustPressed([Z]))
		{
				FlxG.switchState(new PlayState());
		}
	}
}