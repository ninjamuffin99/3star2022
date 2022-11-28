package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxMath;
import flixel.math.FlxVelocity;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

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

	var kissTmr:Float = 0;
	var isKissing:Bool = false;

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		var btnKiss:Bool = FlxG.keys.pressed.SPACE;
		var btnKissP:Bool = FlxG.keys.justPressed.SPACE;

		if (btnKissP) {}

		if (btnKiss)
		{
			kissTmr += elapsed;
			personL.x = FlxMath.lerp(personL.x, personL.getDefaultX() + 20, 0.09);
			personR.x = FlxMath.lerp(personR.x, personL.getDefaultX() - 20, 0.09);
		}
		else
		{
			if (kissTmr > 0)
				kissTmr -= elapsed;

			personL.x = FlxMath.lerp(personL.x, personL.getDefaultX(), 0.7);
			personR.x = FlxMath.lerp(personR.x, personL.getDefaultX(), 0.7);

			// FlxG.camera.follow(null);
			FlxG.camera.scroll.set(0, 0);
		}

		if (kissTmr > 0)
		{
			if (kissTmr > 0.6 || isKissing)
			{
				kissing.screenCenter(X);
				kissing.y = personL.y;
				FlxG.camera.scroll.y = kissing.y + 20;
				isKissing = true;

				new FlxTimer().start(0.9, function(_)
				{
					isKissing = false;
					kissTmr = 0;

					personL.regenTween();
					personR.regenTween();
				});
			}
		}

		FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, isKissing ? 1.3 : 1, 0.1);

		personL.visible = personR.visible = !isKissing;
		kissing.visible = isKissing;
	}
}
