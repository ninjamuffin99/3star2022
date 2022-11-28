package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxMath;
import flixel.math.FlxVelocity;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

class PlayState extends FlxState
{
	var personL:Kisser;
	var personR:Kisser;

	var kissing:Kissing;

	var sndStretch:FlxSound;

	override public function create()
	{
		FlxG.sound.playMusic("assets/music/kissykiss.ogg", 0.8);

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

		sndStretch = new FlxSound().loadEmbedded("assets/sounds/stretch.ogg");
		FlxG.sound.defaultSoundGroup.add(sndStretch);
		super.create();
	}

	var kissTmr:Float = 0;
	var isKissing:Bool = false;

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		var btnKiss:Bool = FlxG.keys.pressed.SPACE || FlxG.mouse.pressed;
		var btnKissP:Bool = FlxG.keys.justPressed.SPACE || FlxG.mouse.justPressed;

		if (btnKissP)
		{
			if (!isKissing)
				sndStretch.play(true, FlxG.random.float(0, 0.2));
		}

		if (btnKiss)
		{
			kissTmr += elapsed;
			personL.x = FlxMath.lerp(personL.x, personL.getDefaultX() + 20, 0.09);
			personR.x = FlxMath.lerp(personR.x, personL.getDefaultX() - 20, 0.09);
		}
		else
		{
			if (sndStretch.playing)
				sndStretch.pause();

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
				sndStretch.pause();

				kissing.screenCenter(X);
				kissing.y = personL.y;
				FlxG.camera.scroll.y = kissing.y + 20;

				if (!isKissing)
				{
					new FlxTimer().start(0.9, function(_)
					{
						isKissing = false;
						kissTmr = 0;

						personL.regenTween();
						personR.regenTween();
					});

					if (personL.y < personR.y - 20)
						kissing.animation.play("head");
					else if (personL.y > personR.y + 20)
						kissing.animation.play("body");
					else
						kissing.animation.play("idle");
				}

				isKissing = true;
			}
		}

		FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, isKissing ? 1.3 : 1, 0.1);

		personL.visible = personR.visible = !isKissing;
		kissing.visible = isKissing;
	}
}
