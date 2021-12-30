package;

import flixel.FlxSprite;
import openfl.utils.Assets;
import haxe.Json;
import haxe.format.JsonParser;

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

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		loadGraphic(Paths.image('iconGrid'), true, 150, 150);

		antialiasing = true;

		var iconJsonPath:String = "chars/healthicons.json";
		var iconPath:String = Paths.getPreloadPath(iconJsonPath);

		var rawJson = Assets.getText(iconPath).trim();

		while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
		}

		var json:IconJunk = cast Json.parse(rawJson);

		if(json.icons != null && json.icons.length > 0) {
			for(icon in json.icons) {
				var characterIcon:String = icon.character;
				var bruhIcons:Array<Int> = icon.iconGridIcons;

				animation.add(characterIcon, bruhIcons, 0, false, isPlayer);
			}
		}

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
