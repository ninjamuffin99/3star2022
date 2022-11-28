package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
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
	}
}
