package;

import flixel.FlxObject;
import flixel.group.FlxGroup;

class NestedSprite extends FlxObject {
	public var parent: FlxGroup;

	override public function new(newParent: FlxGroup) {
		super();
		parent = newParent;
	}
}