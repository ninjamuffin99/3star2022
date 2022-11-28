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
	public function new(facing:FlxDirectionFlags)
	{
		super();

		this.facing = facing;

		var word:String = this.facing == LEFT ? "left" : "right";

		loadGraphic("assets/images/" + word + "Move.png", true, Std.int(720 / 3), 180);
		animation.add("idle", [0, 1, 2], FlxG.random.int(11, 13));
		animation.play("idle", false, false, FlxG.random.int(0, 2));

		x = facing == LEFT ? FlxG.width * 0.1 : (FlxG.width * 0.9) - width;
		y = FlxG.height - height;

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
		trace(Type.getClassFields(FlxEase));

		FlxTween.tween(this, {y: FlxG.random.int(Std.int(y - 10), Std.int(y - Std.int(FlxG.height * 0.6)))}, FlxG.random.float(0.6, 1.9),
			{ease: FlxG.random.getObject(easeFunctions), type: PINGPONG});
	}
}
