package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;

class PlayState extends FlxState
{
	var personL:Kisser;
	var personR:Kisser;

	override public function create()
	{
		FlxG.sound.playMusic("assets/music/kissykiss.ogg", 1);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFFcc99bb);
		bg.scrollFactor.set();
		add(bg);

		personL = new Kisser(LEFT);
		personR = new Kisser(RIGHT);

		add(personL);
		add(personR);

		super.create();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
