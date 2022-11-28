package;

import flixel.FlxSprite;

class Kissing extends FlxSprite
{
	public function new()
	{
		super();

		loadGraphic("assets/images/kisu2.png", true, Std.int(720 / 3), 180);
		animation.add("idle", [0, 1, 2], 12);
		animation.play("idle");
	}
}
