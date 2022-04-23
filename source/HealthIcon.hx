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

		#if sys
			if(modIcon != null && modIcon != "" && !Utilities.checkIfIsNormalChar(char)) {
				if(Utilities.checkFileExists(Paths.mod(modIcon) + "images/icons/" + char + ".png")) {
					#if sys
						loadGraphic(BitmapData.fromFile(Paths.mod(modIcon) + "images/icons/" + char + ".png"), true, 150, 150);
					#else
						loadGraphic(Paths.mod(modIcon) + "images/icons/" + char + ".png", true, 150, 150);
					#end
					isModIcon = true;
				} else if(Utilities.checkFileExists("./assets/images/icons/" + char + ".png")) {
					#if sys
						loadGraphic(BitmapData.fromFile("assets/images/icons/" + char + ".png"), true, 150, 150);
					#else
						loadGraphic("assets/images/icons/" + char + ".png", true, 150, 150);
					#end
					isModIcon = false;
				} else
					loadGraphic("assets/images/icons/face.png", true, 150, 150);
			} else 
		#end
		if(Utilities.checkFileExists("./assets/images/icons/" + char + ".png"))
			#if sys
				loadGraphic(BitmapData.fromFile("assets/images/icons/" + char + ".png"), true, 150, 150);
			#else
				loadGraphic("assets/images/icons/" + char + ".png", true, 150, 150);
			#end
		else
			loadGraphic("assets/images/icons/face.png", true, 150, 150);

		antialiasing = true;

		animation.add(char, [0, 1, 2], 0, false, isPlayer);
		animation.play(char);
		scrollFactor.set();

		character = char;
	}

	public function changeIcon(char:String = 'bf', isPlayer:Bool = false, ?mod:String = "") {
		if(char != character) {
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

			#if sys
				if(modIcon != null && modIcon != "" && !Utilities.checkIfIsNormalChar(char)) {
					if(Utilities.checkFileExists(Paths.mod(modIcon) + "images/icons/" + char + ".png")) {
						#if sys
							loadGraphic(BitmapData.fromFile(Paths.mod(modIcon) + "images/icons/" + char + ".png"), true, 150, 150);
						#else
							loadGraphic(Paths.mod(modIcon) + "images/icons/" + char + ".png", true, 150, 150);
						#end
						isModIcon = true;
					} else if(Utilities.checkFileExists("./assets/images/icons/" + char + ".png")) {
						#if sys
							loadGraphic(BitmapData.fromFile("assets/images/icons/" + char + ".png"), true, 150, 150);
						#else
							loadGraphic("assets/images/icons/" + char + ".png", true, 150, 150);
						#end
						isModIcon = false;
					} else
						loadGraphic("assets/images/icons/face.png", true, 150, 150);
				} else 
			#end
			if(Utilities.checkFileExists("./assets/images/icons/" + char + ".png")) {
				#if sys
					loadGraphic(BitmapData.fromFile("assets/images/icons/" + char + ".png"), true, 150, 150);
				#else
					loadGraphic("assets/images/icons/" + char + ".png", true, 150, 150);
				#end
				isModIcon = false;
			} else {
				loadGraphic("assets/images/icons/face.png", true, 150, 150);
			}

			antialiasing = true;

			animation.add(char, [0, 1, 2], 0, false, isPlayer);
			animation.play(char);
			scrollFactor.set();
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
