package;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import openfl.utils.Assets;
import haxe.Json;
import haxe.format.JsonParser;

using StringTools;

typedef SongListJunk = {
	var songs:Array<SongList>;
	var weeks:Array<WeekList>;
}

typedef SongList = {
	var songData:String;
	var songName:String;
	var songWeekNumber:Int;
	var characterIcon:String;
}

typedef WeekList = {
	var songDatas:Array<String>;
	var songNames:Array<String>;
	var weekNumber:Int;
	var characterIcons:Array<String>;
}

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	var curSelected:Int = 0;
	var curDifficulty:Int = 1;

	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];
	var FPLoadedAssets:Array<Dynamic> = [];

	override function create()
	{
		// Lol
		if(PlayState.PlayStateThing != null)
			PlayState.PlayStateThing.destroy();
		unloadMBSassets();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		var songListJsonPath:String = "data/freeplaySonglist.json";
		var songListPath:String = "";
		var rawJson = "";
		#if sys
			var songListJsonPath:String;

			if(Options.gameSFW)
				songListJsonPath = "./assets/data/freeplaySonglistSFW.json";
			else
				songListJsonPath = "./assets/data/freeplaySonglist.json";
			
			songListPath = songListJsonPath;
			rawJson = Utilities.getFileContents(songListPath);
		#else
			var songListJsonPath:String;

			if(Options.gameSFW)
				songListJsonPath = "./assets/data/freeplaySonglistSFW.json";
			else
				songListJsonPath = "./assets/data/freeplaySonglist.json";

			songListPath = songListJsonPath;
			rawJson = Utilities.getFileContents(songListPath);
			rawJson = rawJson.trim();
		#end

		while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
		}

		var json:SongListJunk = cast Json.parse(rawJson);

		if(json.songs != null && json.songs.length > 0) {
			for(song in json.songs) {
				var songData:String = song.songData;
				var songName:String = song.songName;
				var songWeekNumber:Int = song.songWeekNumber;
				var characterIcon:String = song.characterIcon;

				addSong(songData, songName, songWeekNumber, characterIcon);
			}
		}
		if(json.weeks != null && json.weeks.length > 0) {
			for(week in json.weeks) {
				var songDatas:Array<String> = week.songDatas;
				var songNames:Array<String> = week.songNames;
				var weekNumber:Int = week.weekNumber;
				var characterIcons:Array<String> = week.characterIcons;

				addWeek(songDatas, songNames, weekNumber, characterIcons);
			}
		}

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBGBlue'));
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			iconArray.push(icon);
			add(icon);
		}

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

		var scoreBG:FlxSprite = new FlxSprite(scoreText.x - 6, 0).makeGraphic(Std.int(FlxG.width * 0.35), 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		add(scoreText);

		changeSelection();
		changeDiff();

		selector = new FlxText();

		selector.size = 40;
		selector.text = ">";

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		super.create();
	}

	public function addSong(songData:String, songName:String, weekNum:Int, songCharacter:String)
	{
		songs.push(new SongMetadata(songData, songName, weekNum, songCharacter));
	}

	public function addWeek(songDatas:Array<String>, songNames:Array<String>, weekNum:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];

		var num:Int = 0;
		var songNameNum:Int = 0;
		for (song in songDatas)
		{
			addSong(song, songNames[songNameNum], weekNum, songCharacters[num]);

			if (songCharacters.length != 1)
				num++;
			if (songNames.length != 1)
				songNameNum++;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		scoreText.text = "PERSONAL BEST:" + lerpScore;

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (controls.LEFT_P)
			changeDiff(-1);
		if (controls.RIGHT_P)
			changeDiff(1);

		if (controls.BACK)
		{
			FlxG.switchState(new MainMenuState());
		}

		if (accepted)
		{
			var poop:String = Highscore.formatSong(songs[curSelected].songData.toLowerCase(), curDifficulty);

			trace(poop);

			unloadLoadedAssets();
			unloadMBSassets();
			PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songData.toLowerCase());
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;

			PlayState.storyWeek = songs[curSelected].week;
			trace('CUR WEEK' + PlayState.storyWeek);
			LoadingState.loadAndSwitchState(new PlayState());
		}
	}

	override function add(Object:flixel.FlxBasic):flixel.FlxBasic
	{
		FPLoadedAssets.insert(FPLoadedAssets.length, Object);
		return super.add(Object);
	}

	function unloadLoadedAssets():Void
	{
		for (asset in FPLoadedAssets)
		{
			remove(asset);
		}
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 2;
		if (curDifficulty > 2)
			curDifficulty = 0;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		#end

		switch (curDifficulty)
		{
			case 0:
				diffText.text = "EASY";
			case 1:
				diffText.text = 'NORMAL';
			case 2:
				diffText.text = "HARD";
		}
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		#end

		#if PRELOAD_ALL
		FlxG.sound.playMusic(Paths.inst(songs[curSelected].songName), 0);
		#end

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;

			if (item.targetY == 0)
				item.alpha = 1;
		}
	}
}

class SongMetadata
{
	public var songData:String = "";
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";

	public function new(songData:String, songName:String, week:Int, songCharacter:String)
	{
		this.songData = songData;
		this.songName = songName;
		this.week = week;
		this.songCharacter = songCharacter;
	}
}

