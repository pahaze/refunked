package;

#if desktop
import cpp.abi.Abi;
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
import flixel.util.FlxTimer;
import lime.utils.Assets;
import openfl.utils.Assets;
import optimized.OptimizedLoadingState;
import optimized.OptimizedPlayState;
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
	var songWeekNumber:Null<Int>;
	var diffs:Null<Array<String>>;
	var characterIcon:String;
}

typedef WeekList = {
	var songDatas:Array<String>;
	var songNames:Array<String>;
	var weekNumber:Null<Int>;
	var diffs:Null<Array<Array<String>>>;
	var characterIcons:Array<String>;
}

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	static var curSelected:Int = 0;
	static var curDifficulty:Int = 1;
	static var curDifficultyText:String = "";
	static var diffsAvailable:Map<String, Array<String>> = new Map<String, Array<String>>();

	static var scoreText:FlxText;
	static var diffText:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];
	var FPLoadedAssets:Array<Dynamic> = [];
	static var FPLoadedMap:Map<String, Dynamic> = new Map<String, Dynamic>();

	// yeah why reload when not needed
	var areModSongs:Bool;
	var characterIcon:String;
	var characterIcons:Array<String>;
	var json:SongListJunk;
	var isModSong:Bool;
	var mod:String;
	var nonExistantBG:FlxSprite;
	var nonExistantText:FlxText;
	static var rawJson:String;
	var songData:String;
	var songDatas:Array<String>;
	var singleSongDiffs:Array<String>;
	var multiSongDiffs:Array<Array<String>>;
	var songName:String;
	var songNames:Array<String>;
	var songWeekNumber:Int;
	static var songListJsonPath:String;
	var weekNumber:Int;

	override function create()
	{
		nullFPLoadedAssets();
		diffsAvailable = new Map<String, Array<String>>();
		FPLoadedMap = new Map<String, Dynamic>();
		unloadMBSassets();
		MainMenuState.nullMMLoadedAssets();
		PlayState.nullPSLoadedAssets();
		PlayState.SONG = null;
		OptimizedPlayState.nullOPSLoadedAssets();
		OptimizedPlayState.SONG = null;
		rawJson = null;

		#if desktop
			// Updating Discord Rich Presence
			DiscordClient.changePresence("In the Freeplay Menu", null);
		#end

		if (!FlxG.sound.music.playing)
			FlxG.sound.playMusic(Paths.music('freakyMenu'));

		readVanillaWeeks();
		readModWeeks();

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBGBlue'));
		add(bg);
		FPLoadedMap["bg"] = bg;

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);
		FPLoadedMap["grpSongs"] = grpSongs;

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);
			FPLoadedMap["songText" + i] = songText;

			var icon:HealthIcon;

			if(songs[i].isModSong)
				icon = new HealthIcon(songs[i].songCharacter, false, songs[i].mod);
			else
				icon = new HealthIcon(songs[i].songCharacter, false);
			icon.sprTracker = songText;

			iconArray.push(icon);
			add(icon);
			FPLoadedMap["icon" + i] = icon;
		}

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

		var scoreBG:FlxSprite = new FlxSprite(scoreText.x - 6, 0).makeGraphic(Std.int(FlxG.width * 0.35), 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);
		FPLoadedMap["scoreBG"] = scoreBG;

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);
		FPLoadedMap["diffText"] = diffText;

		add(scoreText);
		FPLoadedMap["scoreText"] = scoreText;

		changeSelection();
		changeDiff();

		selector = new FlxText();
		FPLoadedMap["selector"] = selector;

		nonExistantBG = new FlxSprite(-600,-600).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		nonExistantBG.visible = false;
		nonExistantBG.alpha = 0.5;
		nonExistantBG.scrollFactor.set();
		add(nonExistantBG);
		FPLoadedMap["nonExistantBG"] = nonExistantBG;

		nonExistantText = new FlxText(0, 0, 0, "Error: Song JSON doesn't exist!");
		nonExistantText.visible = false;
		nonExistantText.setFormat("VCR OSD Mono", 48, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		nonExistantText.scrollFactor.set();
		nonExistantText.screenCenter();
		add(nonExistantText);
		FPLoadedMap["nonExistantText"] = nonExistantText;

		selector.size = 40;
		selector.text = ">";

		super.create();
	}

	public function addSong(songData:String, songName:String, weekNum:Int, diffs:Array<String>, isModSong:Bool, mod:String, songCharacter:String)
	{
		songs.push(new SongMetadata(songData, songName, weekNum, isModSong, mod, songCharacter));
		diffsAvailable[songData] = diffs;
	}

	public function addWeek(songDatas:Array<String>, songNames:Array<String>, weekNum:Int, songDiffs:Array<Array<String>>, areModSongs:Bool, mod:String, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['face'];

		var num:Int = 0;
		var diffNum:Int = 0;
		var songNameNum:Int = 0;
		for (song in songDatas)
		{
			addSong(song, songNames[songNameNum], weekNum, songDiffs[diffNum], areModSongs, mod, songCharacters[num]);

			if (songCharacters.length != 1)
				num++;
			if (songNames.length != 1)
				songNameNum++;
			if (songDiffs.length != 1)
				diffNum++;
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
			var poop:String = Highscore.formatSong(songs[curSelected].songData.toLowerCase(), curDifficultyText.toLowerCase());
			trace(poop);

			if(songs[curSelected].isModSong)
				loadModSong(poop);
			else
				loadSong(poop);
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

	function loadModSong(poop:String) {
		if(Utilities.checkFileExists(Paths.modSongData(songs[curSelected].mod, songs[curSelected].songData.toLowerCase(), poop + ".json"))) {
			new FlxTimer().start(transOut.duration, function(tmr:FlxTimer) {
				unloadLoadedAssets();
				unloadMBSassets();
			});
			if(Options.useOptimized) {
				OptimizedPlayState.SONG = Song.loadFromModJson(songs[curSelected].mod, poop, songs[curSelected].songData.toLowerCase());
				OptimizedPlayState.isStoryMode = false;
				OptimizedPlayState.isModSong = true;
				OptimizedPlayState.mod = songs[curSelected].mod;
				OptimizedPlayState.storyDifficulty = curDifficulty;
				OptimizedPlayState.storyDifficultyText = curDifficultyText;
				OptimizedPlayState.storyWeek = songs[curSelected].week;
				trace('CUR WEEK' + OptimizedPlayState.storyWeek);
				OptimizedLoadingState.loadAndSwitchState(new OptimizedPlayState());
			} else {
				PlayState.SONG = Song.loadFromModJson(songs[curSelected].mod, poop, songs[curSelected].songData.toLowerCase());
				PlayState.isStoryMode = false;
				PlayState.isModSong = true;
				PlayState.mod = songs[curSelected].mod;
				PlayState.storyDifficulty = curDifficulty;
				PlayState.storyDifficultyText = curDifficultyText;
				PlayState.storyWeek = songs[curSelected].week;
				trace('CUR WEEK' + PlayState.storyWeek);
				LoadingState.loadAndSwitchState(new PlayState());
			}
		} else {
			trace("Song JSON" + poop + "doesn't exist!");
			nonExistantBG.visible = true;
			nonExistantText.visible = true;
			new FlxTimer().start(2, function(tmr:FlxTimer) {
				nonExistantBG.visible = false;
				nonExistantText.visible = false;
			}, 1);
		}
	}

	function loadSong(poop:String) {
		if(Utilities.checkFileExists(Paths.songData(songs[curSelected].songData.toLowerCase(), poop + ".json"))) {
			new FlxTimer().start(transOut.duration, function(tmr:FlxTimer) {
				unloadLoadedAssets();
				unloadMBSassets();
			});
			if(Options.useOptimized) {
				OptimizedPlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songData.toLowerCase());
				OptimizedPlayState.isStoryMode = false;
				OptimizedPlayState.isModSong = false;
				OptimizedPlayState.mod = "";
				OptimizedPlayState.storyDifficulty = curDifficulty;
				OptimizedPlayState.storyDifficultyText = curDifficultyText;
				OptimizedPlayState.storyWeek = songs[curSelected].week;
				trace('CUR WEEK' + OptimizedPlayState.storyWeek);
				OptimizedLoadingState.loadAndSwitchState(new OptimizedPlayState());
			} else {
				PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songData.toLowerCase());
				PlayState.isStoryMode = false;
				PlayState.isModSong = false;
				PlayState.mod = "";
				PlayState.storyDifficulty = curDifficulty;
				PlayState.storyDifficultyText = curDifficultyText;
				PlayState.storyWeek = songs[curSelected].week;
				trace('CUR WEEK' + PlayState.storyWeek);
				LoadingState.loadAndSwitchState(new PlayState());
			}
		} else {
			trace("Song JSON" + poop + "doesn't exist!");
			nonExistantBG.visible = true;
			nonExistantText.visible = true;
			new FlxTimer().start(2, function(tmr:FlxTimer) {
				nonExistantBG.visible = false;
				nonExistantText.visible = false;
			}, 1);
		}
	}

	public static function nullFPLoadedAssets():Void
	{
		diffsAvailable = null;
		if(FPLoadedMap != null) {
			for(sprite in FPLoadedMap) {
				sprite.destroy();
			}
		}
		FPLoadedMap = null;
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = diffsAvailable[songs[curSelected].songData].length - 1;
		if (curDifficulty >= diffsAvailable[songs[curSelected].songData].length)
			curDifficulty = 0;

		curDifficultyText = diffsAvailable[songs[curSelected].songData][curDifficulty];

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficultyText);
		#end

		diffText.text = curDifficultyText;
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		if(diffsAvailable[songs[curSelected].songData][curDifficulty] != null && diffsAvailable[songs[curSelected].songData][curDifficulty] != "") {
			curDifficultyText = diffsAvailable[songs[curSelected].songData][curDifficulty];
			diffText.text = diffsAvailable[songs[curSelected].songData][curDifficulty];
		} else {
			curDifficulty = 0;
			// ¯\_(ツ)_/¯
			curDifficultyText = diffsAvailable[songs[curSelected].songData][0];
			diffText.text = diffsAvailable[songs[curSelected].songData][0];
		}

		#if !switch
			intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficultyText);
		#end

		var bullStuff:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullStuff - curSelected;
			bullStuff++;

			item.alpha = 0.6;

			if (item.targetY == 0)
				item.alpha = 1;
		}
	}

	function readModWeeks() {
		for(i in ModSupport.modsDirectories.keys()) {
			rawJson = null;
			if(Options.gameSFW)
				songListJsonPath = "./" + ModSupport.modsDirectories[i] + "/data/freeplaySonglistSFW.json";
			else
				songListJsonPath = "./" + ModSupport.modsDirectories[i] + "/data/freeplaySonglist.json";

			if(Utilities.checkFileExists(songListJsonPath)) {
				rawJson = Utilities.getFileContents(songListJsonPath);
				rawJson = rawJson.trim();

				while (!rawJson.endsWith("}")) {
					rawJson = rawJson.substr(0, rawJson.length - 1);
				}

				json = cast Json.parse(rawJson);

				if(json.songs != null && json.songs.length > 0) {
					for(song in json.songs) {
						songData = song.songData;
						songName = song.songName;
						songWeekNumber = song.songWeekNumber;
						isModSong = true;
						mod = i;
						if(song.diffs != null)
							singleSongDiffs = song.diffs;
						else
							singleSongDiffs = ["EASY", "NORMAL", "HARD"];
						characterIcon = song.characterIcon;

						addSong(songData, songName, songWeekNumber, singleSongDiffs, isModSong, mod, characterIcon);
					}
				}
				if(json.weeks != null && json.weeks.length > 0) {
					for(week in json.weeks) {
						songDatas = week.songDatas;
						songNames = week.songNames;
						weekNumber = week.weekNumber;
						areModSongs = true;
						characterIcons = week.characterIcons;
						mod = i;
						if(week.diffs != null)
							multiSongDiffs = week.diffs;
						else
							multiSongDiffs = [["EASY", "NORMAL", "HARD"]];

						addWeek(songDatas, songNames, weekNumber, multiSongDiffs, areModSongs, mod, characterIcons);
					}
				}
				
				json = null;
			} else {
				trace('MOD ${i} FREEPLAY LISTS DONT EXIST!');
			}
		}
	}

	function readVanillaWeeks() {
		if(rawJson == null || rawJson == "") {
			if(Options.gameSFW)
				songListJsonPath = "./assets/data/freeplaySonglistSFW.json";
			else
				songListJsonPath = "./assets/data/freeplaySonglist.json";

			rawJson = Utilities.getFileContents(songListJsonPath);
			rawJson = rawJson.trim();

			while (!rawJson.endsWith("}")) {
				rawJson = rawJson.substr(0, rawJson.length - 1);
			}
		}

		json = cast Json.parse(rawJson);

		if(json.songs != null && json.songs.length > 0) {
			for(song in json.songs) {
				songData = song.songData;
				songName = song.songName;
				songWeekNumber = song.songWeekNumber;
				isModSong = false;
				mod = "";
				if(song.diffs != null)
					singleSongDiffs = song.diffs;
				else
					singleSongDiffs = ["EASY", "NORMAL", "HARD"];
				characterIcon = song.characterIcon;

				addSong(songData, songName, songWeekNumber, singleSongDiffs, isModSong, mod, characterIcon);
			}
		}
		if(json.weeks != null && json.weeks.length > 0) {
			for(week in json.weeks) {
				songDatas = week.songDatas;
				songNames = week.songNames;
				weekNumber = week.weekNumber;
				areModSongs = false;
				mod = "";
				if(week.diffs != null)
					multiSongDiffs = week.diffs;
				else
					multiSongDiffs = [["EASY", "NORMAL", "HARD"]];
				characterIcons = week.characterIcons;

				addWeek(songDatas, songNames, weekNumber, multiSongDiffs, areModSongs, mod, characterIcons);
			}
		}

		json = null;
	}
}

class SongMetadata
{
	public var songData:String = "";
	public var songName:String = "";
	public var week:Int = 0;
	public var isModSong:Bool = false;
	public var mod:String = "";
	public var songCharacter:String = "";

	public function new(songData:String, songName:String, week:Int, isModSong:Bool, mod:String, songCharacter:String)
	{
		this.songData = songData;
		this.songName = songName;
		this.week = week;
		this.isModSong = isModSong;
		this.mod = mod;
		this.songCharacter = songCharacter;
	}
}

