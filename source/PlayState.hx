package;

import Obstacle.ObstacleType;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxVelocity;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

class PlayState extends FlxState
{
	var obstacleGrp:FlxTypedGroup<Obstacle>;

	var personL:Kisser;
	var personR:Kisser;

	var kissing:Kissing;

	var sndStretch:FlxSound;

	override public function create()
	{
		if (FlxG.sound.music == null)
			FlxG.sound.playMusic("assets/music/kissykiss.ogg", 0.5);

		var bg:FlxSprite = new FlxSprite().loadGraphic("assets/images/bg" + FlxG.random.int(1, 3) + ".png", true, 300, 177);
		bg.animation.add("idle", [0, 1, 2], 6);
		bg.animation.play("idle");
		bg.scrollFactor.set();
		add(bg);

		FlxTween.tween(bg, {y: -7}, 1.6, {ease: FlxEase.circInOut, type: PINGPONG});

		obstacleGrp = new FlxTypedGroup<Obstacle>();
		add(obstacleGrp);

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

	var obstacleTmr:Float = 0;

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		obstacleUpdate();

		var tchBtn:Bool = false;
		var tchP:Bool = false;

		for (tch in FlxG.touches.list)
		{
			if (tch.pressed)
				tchBtn = true;

			if (tch.justPressed)
				tchP = true;
		}

		var btnKiss:Bool = FlxG.keys.pressed.SPACE || FlxG.mouse.pressed || tchBtn;
		var btnKissP:Bool = FlxG.keys.justPressed.SPACE || FlxG.mouse.justPressed || tchP;

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
			FlxG.sound.music.volume = FlxMath.lerp(FlxG.sound.music.volume, 0.04, 0.09);
		}
		else
		{
			if (sndStretch.playing)
				sndStretch.pause();

			if (kissTmr > 0 && !isKissing)
				kissTmr -= elapsed;

			personL.x = FlxMath.lerp(personL.x, personL.getDefaultX(), 0.7);
			personR.x = FlxMath.lerp(personR.x, personL.getDefaultX(), 0.7);

			if (!isKissing)
				FlxG.sound.music.volume = FlxMath.lerp(FlxG.sound.music.volume, 0.5, 0.4);

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
					var daObstacle:Obstacle = null;

					var endTimer:Float = 0.9;

					obstacleGrp.forEachAlive(function(obstacle)
					{
						// only get the first one?
						if (daObstacle == null)
							daObstacle = obstacle;
					});

					if (daObstacle != null
						&& daObstacle.getGraphicMidpoint().x > FlxG.width * 0.35
						&& daObstacle.getGraphicMidpoint().x < FlxG.width * 0.65)
					{
						switch (daObstacle.obType)
						{
							case FULP:
								kissing.animation.play("tom");
								daObstacle.kill();
								FlxG.sound.play('assets/sounds/sfx_TOMFULP.ogg');
								endTimer = 1.7;
							case CHEESE:
								FlxG.sound.play('assets/sounds/sfx_rats.ogg');

								kissing.animation.play("cheese");
								daObstacle.kill();
							case BOMB:
								FlxG.sound.play('assets/sounds/sfx_bombxplode.ogg');

								kissing.animation.play("bomb");
								daObstacle.kill();
						}
					}
					else
					{
						if (personL.y < personR.y - 20)
						{
							kissing.animation.play("head");
							FlxG.sound.play("assets/sounds/sfx_kiss_headding.ogg");
							FlxG.sound.play("assets/sounds/sfx_kiss_default.ogg");
						}
						else if (personL.y > personR.y + 20)
						{
							kissing.animation.play("body");
							FlxG.sound.play("assets/sounds/sfx_kiss_default.ogg");
							FlxG.sound.play("assets/sounds/sfx_kiss_neckscream.ogg");
						}
						else
						{
							kissing.animation.play("idle");
							FlxG.sound.play("assets/sounds/sfx_kiss_onlips.ogg");
						}
					}

					new FlxTimer().start(endTimer, function(_)
					{
						isKissing = false;
						kissTmr = 0;

						personL.regenTween();
						personR.regenTween();
					});
				}

				isKissing = true;
			}
		}

		FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, isKissing ? 1.3 : 1, 0.1);

		personL.visible = personR.visible = !isKissing;
		kissing.visible = isKissing;
	}

	var rndObCheck:Float = 10;

	function obstacleUpdate()
	{
		obstacleTmr += FlxG.elapsed;

		if (obstacleTmr >= rndObCheck)
		{
			var obstacle:Obstacle = new Obstacle();
			obstacleGrp.add(obstacle);

			obstacleTmr = 0;
			rndObCheck = FlxG.random.float(8, 13);
		}
	}
}
