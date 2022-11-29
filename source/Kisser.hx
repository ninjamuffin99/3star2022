package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxDirection;
import flixel.util.FlxDirectionFlags;

class Kisser extends FlxSprite
{
	var curTween:FlxTween;

	public function new(facing:FlxDirectionFlags)
	{
		super();

		this.facing = facing;

		var word:String = this.facing == LEFT ? "left" : "right";

		loadGraphic("assets/images/" + word + "Move.png", true, Std.int(720 / 3), 180);
		animation.add("idle", [0, 1, 2], FlxG.random.int(11, 13));
		animation.play("idle", false, false, FlxG.random.int(0, 2));

		regenTween();
	}

	public function getDefaultX():Float
	{
		return facing == LEFT ? FlxG.width * 0.06 : (FlxG.width * 0.94) - width;
	}

	public function regenTween()
	{
		var classFields:Array<String> = Type.getClassFields(FlxEase);
		var easeFunctions:Array<EaseFunction> = [];

		for (field in classFields)
		{
			if (Reflect.isFunction(Reflect.getProperty(FlxEase, field)))
			{
				easeFunctions.push(Reflect.getProperty(FlxEase, field));
			}
		}

		classFields = classFields.filter(function(str)
		{
			// mega maniac bullshit
			return Reflect.isFunction(Reflect.getProperty(FlxEase, str));
		});

		x = getDefaultX();
		y = FlxG.height - (height * FlxG.random.float(0.6, 0.9));

		curTween = FlxTween.tween(this, {y: FlxG.random.int(Std.int(y - 20), Std.int(y - Std.int(FlxG.height * 0.6)))}, FlxG.random.float(0.6, 1.9),
			{ease: FlxG.random.getObject(easeFunctions), type: PINGPONG});
	}
}
