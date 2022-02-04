package;

import Section.SwagSection;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;
#if sys
import sys.io.File;
import sys.FileSystem;
#else
import js.html.XMLHttpRequest;
import js.html.XMLHttpRequestResponseType;
import js.html.Response;
import js.html.FileReader;
#end

using StringTools;

typedef SwagSong =
{
	var song:String;
	var songName:String;
	var notes:Array<SwagSection>;
	var bpm:Int;
	var needsVoices:Bool;
	var speed:Float;
	var stage:String;

	var player1:String;
	var player2:String;
	var gfPlayer:String;
	var validScore:Bool;
}

class Song
{
	public static var rawJson:String;
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

	public function new(song, notes, bpm, stage, songName)
	{
		this.song = song;
		this.notes = notes;
		this.bpm = bpm;
		this.stage = stage;
		this.songName = songName;
	}

	public static function loadFromJson(jsonInput:String, ?folder:String):SwagSong
	{
		#if sys
			rawJson = Utilities.getFileContents('assets/data/' + folder.toLowerCase() + '/' + jsonInput.toLowerCase() + '.json').trim();

			while (!rawJson.endsWith("}"))
			{
				rawJson = rawJson.substr(0, rawJson.length - 1);
			}

			return parseJSONshit(rawJson);
			rawJson = null;
		#else
			rawJson = Utilities.getFileContents('./assets/data/' + folder.toLowerCase() + '/' + jsonInput.toLowerCase() + '.json');

			while (!rawJson.endsWith("}"))
			{
				rawJson = rawJson.substr(0, rawJson.length - 1);
			}

			return parseJSONshit(rawJson);
			rawJson = null;
		#end
	}

	public static function parseJSONshit(rawJson:String):SwagSong
	{
		var swagShit:SwagSong = cast Json.parse(rawJson).song;
		swagShit.validScore = true;
		return swagShit;
	}
}
