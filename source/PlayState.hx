package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;

class PlayState extends FlxState
{
	var personL:Kisser;
	var personR:Kisser;

	var kissing:Kissing;

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

		kissing = new Kissing();
		add(kissing);

		super.create();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		var btnKiss:Bool = FlxG.keys.pressed.SPACE;
		var btnKissP:Bool = FlxG.keys.justPressed.SPACE;

		if (btnKissP)
		{
			kissing.screenCenter();
			kissing.y = personL.y;
		}

		personL.visible = personR.visible = !btnKiss;
		kissing.visible = btnKiss;
	}
}
