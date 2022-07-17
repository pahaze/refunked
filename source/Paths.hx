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

	inline static public function modVoices(mod:String, song:String)
	{
		return ModSupport.modsDirectories[mod] + 'songs/${song.toLowerCase()}/Voices.ogg';
	}

	inline static public function voices(song:String)
	{
		return 'assets/songs/${song.toLowerCase()}/Voices.$SOUND_EXT';
	}

	inline static public function modInst(mod:String, song:String)
	{
		return ModSupport.modsDirectories[mod] + 'songs/${song.toLowerCase()}/Inst.ogg';
	}

	inline static public function inst(song:String)
	{
		return 'assets/songs/${song.toLowerCase()}/Inst.$SOUND_EXT';
	}

	inline static public function image(key:String, ?library:String)
	{
		return getPath('images/$key.png', IMAGE, library);
	}

	inline static public function font(key:String)
	{
		return 'assets/fonts/$key';
	}

	inline static public function modSongData(mod:String, song:String, key:String) {
		return ModSupport.modsDirectories[mod] + 'data/${song.toLowerCase()}/' + key;
	}

	inline static public function songData(song:String, key:String) {
		return 'assets/data/${song.toLowerCase()}/' + key;
	}

	inline static public function stage(stage:String) {
		return './assets/stages/${stage}.lua';
	}

	inline static public function modStage(mod:String, stage:String) {
		return ModSupport.modsDirectories[mod] + 'stages/${stage}.lua';
	}

	inline static public function mod(mod:String) {
		return ModSupport.modsDirectories[mod];
	}

	static public function getSparrowAtlas(key:String, ?library:String)
	{
		var result;
		result = FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
		return result;
	}
	
	static public function getSparrowAtlasThing(key:String, ?mod:String)
	{
		var result;
		#if sys
			if(mod != null)
				result = FlxAtlasFrames.fromSparrow(BitmapData.fromFile(ModSupport.modsDirectories[mod] + key + ".png"), Utilities.getFileContents(ModSupport.modsDirectories[mod] + key + ".xml"));
			else
				result = FlxAtlasFrames.fromSparrow(BitmapData.fromFile("assets/" + key + ".png"), Utilities.getFileContents("assets/" + key + ".xml"));
		#else
			// we'll get there one day
			result = FlxAtlasFrames.fromSparrow("assets/" + key + ".png", Utilities.getFileContents("./assets/" + key + ".xml"));
		#end
		return result;
	}

	static public function getPackerAtlas(key:String, ?library:String)
	{
		var result;
		result = FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
		return result;
	}

	static public function getPackerAtlasThing(key:String, ?mod:String)
	{
		var result;
		#if sys
			if(mod != null)
				result = FlxAtlasFrames.fromSpriteSheetPacker(BitmapData.fromFile(ModSupport.modsDirectories[mod] + key + ".png"), Utilities.getFileContents(ModSupport.modsDirectories[mod] + key + ".txt"));
			else
				result = FlxAtlasFrames.fromSpriteSheetPacker(BitmapData.fromFile("assets/" + key + ".png"), Utilities.getFileContents("assets/" + key + ".txt"));
		#else
			// we'll get there one day 
			result = FlxAtlasFrames.fromSpriteSheetPacker("assets/" + key + ".png", Utilities.getFileContents("./assets/" + key + ".txt"));
		#end
		return result;
	}
}