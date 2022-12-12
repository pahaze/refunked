package;

import Section.SwagSection;
import haxe.Json;
import lime.utils.Assets;

using StringTools;

typedef SwagSong = {
	var song:String;
	var songName:String;
	var notes:Array<SwagSection>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;
	var stage:String;
	var uiStyle:String;

	var gfPlayer:String;
	var player1:String;
	var player2:String;
	var validScore:Bool;
}

class Song {
	public var song:String;
	public var songName:String;
	public var notes:Array<SwagSection>;
	public var bpm:Float;
	public var needsVoices:Bool = true;
	public var speed:Float = 1;
	public var stage:String;

	public var gfPlayer:String = 'gf';
	public var player1:String = 'bf';
	public var player2:String = 'dad';

	public function new(bpm, notes, song, songName, stage) {
		this.bpm = bpm;
		this.notes = notes;
		this.song = song;
		this.songName = songName;
		this.stage = stage;
	}

	public static function loadFromJson(jsonInput:String, ?folder:String):SwagSong {
		var rawJson = Assets.getText(Paths.json(folder.toLowerCase() + '/' + jsonInput.toLowerCase())).trim();

		while (!rawJson.endsWith("}")) {
			rawJson = rawJson.substr(0, rawJson.length - 1);
		}

		return parseJSONstuff(rawJson);
	}

	public static function parseJSONstuff(rawJson:String):SwagSong {
		var swagShit:SwagSong = cast Json.parse(rawJson).song;
		swagShit.validScore = true;
		return swagShit;
	}
}
