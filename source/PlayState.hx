package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class PlayState extends FlxState
{
	var personL:Kisser;
	var personR:Kisser;

	var kissing:Kissing;

	override public function create()
	{
		FlxG.sound.playMusic("assets/music/kissykiss.ogg", 1);

		var bg:FlxSprite = new FlxSprite().loadGraphic("assets/images/bg" + FlxG.random.int(1, 3) + ".png", true, 300, 177);
		bg.animation.add("idle", [0, 1, 2], 6);
		bg.animation.play("idle");
		bg.scrollFactor.set();
		add(bg);

		FlxTween.tween(bg, {y: -7}, 1.6, {ease: FlxEase.circInOut, type: PINGPONG});

		personL = new Kisser(LEFT);
		personR = new Kisser(RIGHT);

		add(personL);
		add(personR);

		kissing = new Kissing();
		add(kissing);

		FlxG.camera.followLerp = 0.02;

		super.create();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		var btnKiss:Bool = FlxG.keys.pressed.SPACE;
		var btnKissP:Bool = FlxG.keys.justPressed.SPACE;

		if (btnKissP)
		{
			kissing.screenCenter(X);
			kissing.y = personL.y;
		}

		if (btnKiss)
		{
			FlxG.camera.scroll.y = kissing.y + 20;
		}
		else
		{
			// FlxG.camera.follow(null);
			FlxG.camera.scroll.set(0, 0);
		}

		FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, btnKiss ? 1.3 : 1, 0.1);

		personL.visible = personR.visible = !btnKiss;
		kissing.visible = btnKiss;
	}
}
