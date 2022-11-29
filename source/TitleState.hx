package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.math.FlxPoint;
import flixel.text.FlxBitmapText;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class TitleState extends FlxState
{
	override function create()
	{
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFFFFFFFF);
		add(bg);
		bg.visible = false;

		var chars:FlxSprite = new FlxSprite().loadGraphic("assets/images/title.png", true, 240, 180);
		chars.animation.add("idle", [0, 1, 2], 6);
		chars.animation.play("idle");
		chars.screenCenter(X);
		FlxTween.tween(chars, {y: chars.y + 10}, 1, {ease: FlxEase.quartInOut, type: PINGPONG});
		FlxTween.tween(chars.scale, {x: -1}, 1, {ease: FlxEase.quartInOut, type: PINGPONG, loopDelay: 0.8});
		add(chars);
		chars.visible = false;

		var logo:FlxSprite = new FlxSprite().loadGraphic("assets/images/logo.png");
		logo.screenCenter();
		logo.y = -logo.height;
		add(logo);

		var txtLetters:String = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
		var fontMonospace = FlxBitmapFont.fromMonospace('assets/images/font.png', txtLetters, FlxPoint.get(30, 30));

		FlxG.mouse.visible = false;

		FlxG.sound.play("assets/sounds/sfx_rats.ogg");

		FlxTween.tween(logo, {y: (FlxG.height / 2) - (logo.height / 2), angle: 360 * 2}, 6, {
			onComplete: _ ->
			{
				bg.visible = true;
				logo.visible = false;

				var txt:FlxBitmapText = new FlxBitmapText(fontMonospace);
				txt.letterSpacing = -9;
				txt.setGraphicSize(Std.int(txt.width * 0.5));
				txt.updateHitbox();
				txt.autoUpperCase = true;
				txt.text = "game by\ndigimin\npankakidaan\nninjamuffin99\nr3tronaut";
				txt.alignment = CENTER;
				txt.screenCenter();
				txt.color = 0xFF0000FF;
				add(txt);

				FlxG.sound.play("assets/sounds/sfx_kiss_headding.ogg");

				new FlxTimer().start(0.9, _ ->
				{
					remove(txt);

					canSwitch = true;

					logo.visible = true;

					FlxG.sound.play("assets/sounds/sfx_kiss_onlips.ogg");
					FlxG.sound.playMusic("assets/music/kissykiss.ogg", 0);
					FlxG.sound.music.fadeIn(3, 0, 0.9);

					FlxG.camera.flash(FlxColor.WHITE, 4);

					logo.setGraphicSize(Std.int(logo.width * 2));
					logo.updateHitbox();
					// logo.x = FlxG.width * 0.6;
					logo.screenCenter(X);
					logo.y = FlxG.height * 0.02;

					logo.angle = -30;

					FlxTween.tween(logo, {angle: 30}, 0.9, {ease: FlxEase.quadInOut, type: PINGPONG});

					chars.visible = true;
				});
			}
		});

		super.create();
	}

	var canSwitch:Bool = false;

	override function update(elapsed:Float)
	{
		if ((FlxG.keys.justPressed.SPACE || FlxG.mouse.justPressed) && canSwitch)
		{
			canSwitch = false;

			FlxG.sound.music.fadeOut(0.5, 0.5);

			FlxG.camera.fade(FlxColor.WHITE, 0.5, false, () ->
			{
				FlxG.switchState(new PlayState());
			});
		}

		super.update(elapsed);
	}
}
