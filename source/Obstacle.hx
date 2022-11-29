package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

class Obstacle extends FlxSprite
{
	public var obType:ObstacleType;
	public var rndObj:Array<ObstacleType> = [CHEESE, FULP, BOMB];

	public function new()
	{
		super();

		this.obType = FlxG.random.getObject(rndObj);

		facing = FlxG.random.bool() ? LEFT : RIGHT;

		switch (obType)
		{
			case CHEESE:
				loadGraphic("assets/images/cheese.png", true, 60, 37);
				animation.add("idle", [0, 1, 2], 6);
				animation.play("idle");

				x = facing == LEFT ? -width : FlxG.width;
				y = FlxG.height * FlxG.random.float(0.3, 1);

				acceleration.y = 300;
				velocity.x = facing == LEFT ? 120 : -120;
				drag.x = FlxG.random.float(0, 50);
				velocity.y = FlxG.random.float(-100, -310);

			case BOMB:
				loadGraphic('assets/images/bomb.png', true, 60, 46);
				animation.add("idle", [0, 1, 2], 6);
				animation.play("idle");

				x = facing == LEFT ? -width : FlxG.width;
				y = FlxG.height * FlxG.random.float(0.3, 1);

				acceleration.y = 300;
				velocity.x = facing == LEFT ? 160 : -160;
				drag.x = FlxG.random.float(0, 50);
				velocity.y = FlxG.random.float(-100, -310);

				angularVelocity = FlxG.random.float(360, -360);

			case FULP:
				loadGraphic("assets/images/fulp.png");
				x = FlxG.random.bool() ? -width : FlxG.width;
				y = FlxG.height * 0.2;
				FlxTween.tween(this, {x: (FlxG.width / 2) - (width / 2), angle: 360 * FlxG.random.int(-4, 4)}, FlxG.random.float(0.8, 2),
					{ease: FlxEase.bounceOut, onComplete: randomFulpKill});
		}
	}

	function randomFulpKill(_)
	{
		function tweenDown()
		{
			FlxTween.tween(this, {y: FlxG.height}, FlxG.random.float(0.4, 1), {ease: FlxEase.quadIn, onComplete: _ -> kill()});
		}

		function fulpFlicker()
		{
			FlxFlicker.flicker(this, FlxG.random.float(0.4, 1), FlxG.random.float(0.05, 0.2), true, true, _ -> kill());
		}

		var rndFuncs:Array<Void->Void> = [tweenDown, fulpFlicker];

		new FlxTimer().start(FlxG.random.float(0.3, 1), _ ->
		{
			FlxG.random.getObject(rndFuncs)();
		});
	}

	override function update(elapsed:Float)
	{
		if ((obType == CHEESE || obType == BOMB) && y >= FlxG.height)
			kill();

		super.update(elapsed);
	}
}

enum ObstacleType
{
	FULP;
	CHEESE;
	BOMB;
}
