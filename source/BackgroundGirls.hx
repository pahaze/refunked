package;

import flixel.FlxSprite;

class BackgroundGirls extends FlxSprite {
	// Dance --
	var danceDir:Bool = false;
	// -- Dance

	public function new(x:Float, y:Float) {
		super(x, y);

		frames = Paths.getSparrowAtlas('weeb/bgFreaks');

		animation.addByIndices('danceLeft', 'BG girls group', CoolUtil.numberArray(14), "", 24, false);
		animation.addByIndices('danceRight', 'BG girls group', CoolUtil.numberArray(30, 15), "", 24, false);

		animation.play('danceLeft');
	}

	public function dance():Void {
		danceDir = !danceDir;

		if (danceDir)
			animation.play('danceRight', true);
		else
			animation.play('danceLeft', true);
	}

	public function getScared():Void {
		animation.addByIndices('danceLeft', 'BG fangirls dissuaded', CoolUtil.numberArray(14), "", 24, false);
		animation.addByIndices('danceRight', 'BG fangirls dissuaded', CoolUtil.numberArray(30, 15), "", 24, false);
		dance();
	}
}
