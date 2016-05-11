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
		var title:FlxText = new FlxText(0, 0, FlxG.width, "TEST", 20);
		add(title);
		super.create();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		if (FlxG.keys.anyJustPressed([SHIFT]))
		{
				FlxG.switchState(new PlayState());
		}
	}
}