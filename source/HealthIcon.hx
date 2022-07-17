package;

import flixel.FlxSprite;
import openfl.utils.Assets;
import haxe.Json;
import haxe.format.JsonParser;
#if sys
import openfl.display.BitmapData;
#end
import optimized.OptimizedPlayState;

using StringTools;

typedef IconJunk = {
	var icons:Array<IconInfo>;
}

typedef IconInfo = {
	var character:String;
	var iconGridIcons:Array<Int>;
}

class HealthIcon extends FlxSprite
{
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;
	var character:String;
	var modIcon:String;
	var isModIcon:Bool = false;

	public function new(char:String = 'bf', isPlayer:Bool = false, ?mod:String = "")
	{
		super();

		if(mod != null && mod != "")
			modIcon = mod;
		else {
			if(Options.useOptimized) {
				modIcon = OptimizedPlayState.mod;
			} else {
				modIcon = PlayState.mod;
			}
		}

		changeIcon(char, isPlayer, modIcon);
		scrollFactor.set();
	}

	public function changeIcon(char:String = 'bf', isPlayer:Bool = false, ?mod:String = "") {
		if(character != char) {
			character = char;
			
			if(mod != null && mod != "")
				modIcon = mod;
			else {
				if(Options.useOptimized) {
					modIcon = OptimizedPlayState.mod;
				} else {
					modIcon = PlayState.mod;
				}
			}

			var path:String = "";
			if(modIcon != null && modIcon != "")
				path = Paths.mod(modIcon) + 'images/icons/${char}.png';
			if(!Utilities.checkFileExists(path))
				path = 'assets/images/icons/${char}.png';
			if(!Utilities.checkFileExists(path))
				path = 'assets/images/icons/face.png';

			#if sys
				loadGraphic(BitmapData.fromFile(path), true, 150, 150);
			#else
				loadGraphic(Std.string(path), true, 150, 150);
			#end

			antialiasing = true;

			animation.add(char, [0, 1, 2], 0, false, isPlayer);
			animation.play(char);
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
