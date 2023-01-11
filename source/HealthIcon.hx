package;

import flixel.FlxSprite;
#if sys
	import openfl.display.BitmapData;
#end

class HealthIcon extends FlxSprite {
	public var hasWinningIcon:Bool = false;
	var character:String;
	public var sprTracker:FlxSprite;

	public function new(character:String = 'bf', isPlayer:Bool = false) {
		super();

		changeIcon(character, isPlayer);
		scrollFactor.set();
	}

	public function changeIcon(character:String = 'bf', isPlayer:Bool = false) {
		if(this.character != character) {
			this.character = character;

			loadGraphic(Paths.image('icons/$character'));
			if(width == 450)
				hasWinningIcon = true;
			loadGraphic(Paths.image('icons/$character'), true, 150, 150);

			antialiasing = true;

			animation.add(character, [0, 1, 2], 0, false, isPlayer);
			animation.play(character);
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
