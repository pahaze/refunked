package;

import flixel.FlxSprite;

class HealthIcon extends FlxSprite
{
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		loadGraphic(Paths.image('iconGrid'), true, 150, 150);

		antialiasing = true;
		animation.add('bf', [0, 1, 2], 0, false, isPlayer);
		animation.add('bf-car', [0, 1, 2], 0, false, isPlayer);
		animation.add('bf-christmas', [0, 1, 2], 0, false, isPlayer);
		animation.add('bf-pixel', [33, 34, 35], 0, false, isPlayer);
		animation.add('spooky', [3, 4, 5], 0, false, isPlayer);
		animation.add('pico', [6, 7, 8], 0, false, isPlayer);
		animation.add('mom', [9, 10, 11], 0, false, isPlayer);
		animation.add('mom-car', [9, 10, 11], 0, false, isPlayer);
		animation.add('tankman', [12, 13, 14], 0, false, isPlayer);
		animation.add('face', [15, 16, 17], 0, false, isPlayer);
		animation.add('dad', [18, 19, 20], 0, false, isPlayer);
		animation.add('senpai', [36, 37, 38], 0, false, isPlayer);
		animation.add('senpai-angry', [39, 40, 41], 0, false, isPlayer);
		animation.add('spirit', [42, 43, 44], 0, false, isPlayer);
		animation.add('bf-old', [21, 22, 23], 0, false, isPlayer);
		animation.add('gf', [24, 25, 26], 0, false, isPlayer);
		animation.add('parents-christmas', [27, 28, 29], 0, false, isPlayer);
		animation.add('monster', [30, 31, 32], 0, false, isPlayer);
		animation.add('monster-christmas', [30, 31, 32], 0, false, isPlayer);
		animation.play(char);
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
