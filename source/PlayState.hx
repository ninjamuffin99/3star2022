package;

import Obstacle.ObstacleType;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxVelocity;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxBitmapText;
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
	var sprLives:FlxSprite;
	var txtScore:FlxBitmapText;
	var score:Int = 0;

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

		sprLives = new FlxSprite(2, 2).loadGraphic("assets/images/lives.png", true, 90, 30);
		sprLives.animation.add('idle', [0, 1, 2], 0);
		sprLives.animation.play("idle");
		sprLives.health = 3;
		add(sprLives);

		var txtLetters:String = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
		var fontMonospace = FlxBitmapFont.fromMonospace('assets/images/font.png', txtLetters, FlxPoint.get(30, 30));

		txtScore = new FlxBitmapText(fontMonospace);
		txtScore.letterSpacing = -8;
		txtScore.autoUpperCase = true;
		txtScore.text = "";
		txtScore.alignment = RIGHT;
		txtScore.x = FlxG.width - 100;
		txtScore.setGraphicSize(Std.int(txtScore.width / 2));
		txtScore.updateHitbox();
		add(txtScore);

		FlxTween.tween(sprLives.scale, {y: 1.1}, 0.7, {ease: FlxEase.quartInOut, type: PINGPONG});

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

		txtScore.text = Std.string(score);

		if (sprLives.health <= 0)
		{
			FlxG.resetGame();
		}

		sprLives.animation.curAnim.curFrame = Math.round(sprLives.health - 1);

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

				FlxG.camera.scroll.y = kissing.y + 20;

				if (!isKissing)
				{
					kissing.y = personL.y;

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
								score += 100;
								kissing.animation.play("tom");
								daObstacle.kill();
								FlxG.sound.play('assets/sounds/sfx_TOMFULP.ogg');
								endTimer = 1.7;
							case CHEESE:
								sprLives.health -= 1;

								FlxFlicker.flicker(sprLives, 2, 0.02, true);

								FlxG.sound.play('assets/sounds/sfx_rats.ogg');

								kissing.animation.play("cheese");
								daObstacle.kill();
							case BOMB:
								sprLives.health -= 1;
								FlxFlicker.flicker(sprLives, 2, 0.02, true);

								FlxG.sound.play('assets/sounds/sfx_bombxplode.ogg');

								kissing.animation.play("bomb");
								daObstacle.kill();
						}
					}
					else
					{
						if (personL.y < personR.y - 20)
						{
							score += 100;

							kissing.animation.play("head");
							FlxG.sound.play("assets/sounds/sfx_kiss_headding.ogg");
							FlxG.sound.play("assets/sounds/sfx_kiss_default.ogg");
						}
						else if (personL.y > personR.y + 20)
						{
							score += 500;

							kissing.animation.play("body");
							FlxG.sound.play("assets/sounds/sfx_kiss_default.ogg");
							FlxG.sound.play("assets/sounds/sfx_kiss_neckscream.ogg");
						}
						else
						{
							score += 1000;

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
