package;

import Section.SwagSection;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;

using StringTools;

typedef GameOver = {
	var boyfriend:String;
	var deathAnim:String;
	var deathFinishAnim:String;
}

typedef SwagSong = {
	var song:String;
	var songName:String;
	var notes:Array<SwagSection>;
	var bpm:Int;
	var needsVoices:Bool;
	var speed:Float;
	var stage:String;
	var uiStyle:String;

	var gameOver:GameOver;
	var player1:String;
	var player2:String;
	var gfPlayer:String;
	var validScore:Bool;
}

class Song {
	public static var rawJson:String;
	public static var swagSong:SwagSong;
	public var song:String;
	public var songName:String;
	public var notes:Array<SwagSection>;
	public var bpm:Int;
	public var needsVoices:Bool = true;
	public var speed:Float = 1;
	public var stage:String;

	public var player1:String = 'bf';
	public var player2:String = 'dad';
	public var gfPlayer:String = 'gf';

	// Game Over
	/// WIP
	public var gameOverBF:String = 'bf';
	public var gameOverAnim:String = 'firstDeath';
	public var gameOverFinishAnim:String = 'deathConfirm';

	public function new(song, notes, bpm, stage, songName) {
		this.song = song;
		this.notes = notes;
		this.bpm = bpm;
		this.stage = stage;
		this.songName = songName;
	}

	public static function loadFromJson(jsonInput:String, ?folder:String):SwagSong {
		rawJson = Utilities.getFileContents('./assets/data/' + folder.toLowerCase() + '/' + jsonInput.toLowerCase() + '.json');
		
		while (!rawJson.endsWith("}")) {
			rawJson = rawJson.substr(0, rawJson.length - 1);
		}
		
		return parseSongJSON(rawJson);
		rawJson = null;
		swagSong = null;
	}

	public static function loadFromModJson(mod:String, jsonInput:String, ?folder:String):SwagSong
	{
		rawJson = Utilities.getFileContents(ModSupport.modsDirectories[mod] + 'data/' + folder.toLowerCase() + '/' + jsonInput.toLowerCase() + '.json');
		
		while (!rawJson.endsWith("}")) {
			rawJson = rawJson.substr(0, rawJson.length - 1);
		}
		
		return parseSongJSON(rawJson);

		rawJson = null;
		swagSong = null;
	}

	public static function parseSongJSON(rawJson:String):SwagSong
	{
		swagSong = cast Json.parse(rawJson).song;
		swagSong.validScore = true;
		return swagSong;
	}
}
