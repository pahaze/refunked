package;

import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import lime.utils.Assets;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import openfl.display.BitmapData;
import flixel.graphics.FlxGraphic;
#if sys
import sys.io.File;
import sys.FileSystem;
#else
import openfl.utils.ByteArray;
import openfl.utils.Future;
import lime._internal.format.Base64;
import js.html.XMLHttpRequest;
import js.html.XMLHttpRequestResponseType;
import lime.graphics.Image;
import lime.utils.Bytes;
#end

class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;

	static var currentLevel:String;

	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	static public function getPath(file:String, type:AssetType, ?library:Null<String> = null)
	{
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath = getLibraryPathForce(file, currentLevel);
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;

			levelPath = getLibraryPathForce(file, "shared");
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	static public function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String)
	{
		return '$library:assets/$library/$file';
	}

	inline static public function getPreloadPath(file:String)
	{
		return 'assets/$file';
	}

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String)
	{
		return getPath(file, type, library);
	}

	inline static public function txt(key:String, ?library:String)
	{
		return getPath('data/$key.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String)
	{
		return getPath('data/$key.json', TEXT, library);
	}

	static public function sound(key:String, ?library:String)
	{
		return getPath('sounds/$key.$SOUND_EXT', SOUND, library);
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function music(key:String, ?library:String)
	{
		return getPath('music/$key.$SOUND_EXT', MUSIC, library);
	}

	inline static public function voices(song:String)
	{
		return 'assets/songs/${song.toLowerCase()}/Voices.$SOUND_EXT';
	}

	inline static public function inst(song:String)
	{
		return 'assets/songs/${song.toLowerCase()}/Inst.$SOUND_EXT';
	}

	inline static public function image(key:String, ?library:String)
	{
		return getPath('images/$key.png', IMAGE, library);
	}

	inline static public function broImage(key:String, ?library:String) {
		if(library == null) {
			return 'images/$key';
		} else {
			return '$library/images/$key';
		}
	}

	inline static public function font(key:String)
	{
		return 'assets/fonts/$key';
	}

	static public function getSparrowAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
	}

	#if html5
	public static function whyDoesThisWork(uh:String):String {
		var bloob = new XMLHttpRequest();
		bloob.open('GET', uh, false);
		bloob.send(null);
		return bloob.responseText;
	}
	#end

	static public function getSparrowAtlasThing(key:String)
	{
		#if sys
			return FlxAtlasFrames.fromSparrow(BitmapData.fromFile("assets/" + key + ".png"), File.getContent("assets/" + key + ".xml"));
		#else
			// we'll get there one day 
			return FlxAtlasFrames.fromSparrow("assets/" + key + ".png", whyDoesThisWork("./assets/" + key + ".xml"));
		#end
	}

	static public function getPackerAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
	}

	static public function getPackerAtlasThing(key:String, ?library:String)
	{
		#if sys
			return FlxAtlasFrames.fromSpriteSheetPacker(BitmapData.fromFile("assets/" + key + ".png"), File.getContent("assets/" + key + ".txt"));
		#else
			// we'll get there one day 
			return FlxAtlasFrames.fromSpriteSheetPacker("assets/" + key + ".png", whyDoesThisWork("./assets/" + key + ".txt"));
		#end
	}
}