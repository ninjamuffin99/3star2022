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

	public function new(obType:ObstacleType)
	{
		super();

		this.obType = obType;

		switch (obType)
		{
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
}

enum ObstacleType
{
	FULP;
}
