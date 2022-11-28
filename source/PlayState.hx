package;

import flixel.FlxSprite;
import flixel.FlxState;

class PlayState extends FlxState
{
	var personL:FlxSprite;
	var personR:FlxSprite;

	override public function create()
	{
		personL = new FlxSprite().loadGraphic()

		super.create();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
