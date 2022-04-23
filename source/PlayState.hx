package;

#if desktop
import Discord.DiscordClient;
#end
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.math.FlxAngle;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.app.Application;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
import openfl.display.BitmapData;
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

typedef Developers = {
	var devs:Array<String>;
}

class PlayState extends MusicBeatState
{
	public static var PlayStateThing:PlayState;
	public static var curStage:String = '';
	public var pubCurStage:String = "";
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	var beatHitCounter:Int = 0;

	var halloweenLevel:Bool = false;

	public var inst:FlxSound;
	public var vocals:FlxSound;

	public var dad:Character;
	public var gf:Character;
	public var boyfriend:Boyfriend;

	private var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];

	private var strumLine:FlxSprite;
	private var curSection:Int = 0;

	public static var camFollow:FlxObject;
	public static var camFollowSet:Bool = false;
	private static var prevCamFollow:FlxObject;

	public var strumLineNotes:FlxTypedGroup<FlxSprite>;
	public var playerStrums:FlxTypedGroup<FlxSprite>;
	public var cpuStrums:FlxTypedGroup<FlxSprite>;

	public var camZooming:Bool = false;
	private var curSong:String = "";

	public var health:Float = 1;
	private var combo:Int = 0;
	private var maxCombo:Int = 0;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;
	private var endingSong:Bool = false;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var OGIconP1:HealthIcon;
	public var OGIconP2:HealthIcon;
	var dadIcon:HealthIcon;
	var oldbfIcon:HealthIcon;
	var pahazeIcon:HealthIcon;
	var pahazeRedwickIcon:HealthIcon;

	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;

	var dialogue:Array<String>;

	// Week 2
	var halloweenBG:FlxSprite;
	var isHalloween:Bool = false;

	// Week 3
	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var phillyTrain:FlxSprite;
	var trainSound:FlxSound;

	// Week 4
	var limo:FlxSprite;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:FlxSprite;

	// Week 5
	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;

	// Week 6
	var bgGirls:BackgroundGirls;
	var wiggleStuff:WiggleEffect = new WiggleEffect();

	// Dialogue
	var doof:DialogueBox;
	var talking:Bool = true;

	// Scores
	var songScore:Int = 0;
	var scoreTxt:FlxText;

	// Score used for high scores
	public static var campaignScore:Int = 0;

	// Camera zooms
	public var defaultCamZoom:Float = 1.05;
	public var camHUDZoom:Float = 0.03;
	public var camGameZoom:Float = 0.015;
	public var minCamGameZoom:Float = 1.35;

	// How big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;

	// Tells whether you're in a cutscene or not
	var inCutscene:Bool = false;

	// Themes
	var accTxt:FlxText;
	var accuracyThing:Float = 0;
	var botplaySine:Float = 0;
	var botplayTxt:FlxText;
	public static var bubbyheight:Float;
	public static var bubbywidth:Float;
	var funnyMaxNPS:Int = 0;
	var funnyNPS:Int = 0;
	var hitArrayThing:Array<Date> = [];
	var m:String;
	var missTxt:FlxText;
	var npsTxt:FlxText;
	var s:String;
	var songLength:Float = 0;
	var songPercentage:Float = 0;
	public var timeBar:FlxBar;
	private var timeBarBG:FlxSprite;
	var timeTxt:FlxText;
	
	// Tweens
	var iconP1Tween:FlxTween;
	var iconP2Tween:FlxTween;
	var scoreTxtTween:FlxTween;
	var timeTxtTween:FlxTween;
	var watermarkTween:FlxTween;

	// Watermark
	var refunkedWatermark:FlxText;
	var watermarkInPlace:Bool = false;

	// RPC stuff
	var detailsStageText:String = "";
	public static var storyDifficultyText:String = "";

	// Ratings
	var accNotesToDivide:Int = 0;
	var accNotesTotal:Int = 0;
	var awfuls:Int = 0;
	var bads:Int = 0;
	var funnyRating:String;
	var goods:Int = 0;
	var misses:Int = 0;
	var notesRating:String;
	var sicks:Int = 0;

	// Easter eggs cause we lovin them
	public static var bfEasterEggEnabled:Bool = false;
	var devSelector:Int;
	public static var devEasterEggEnabled:Bool = false;
	public static var dadEasterEggEnabled:Bool = false;
	public static var duoDevEasterEggEnabled:Bool = false;
	public static var randomDevs:Array<String> = [];

	// Memory related stuff
	var comboCount:Int = 0;
	var dunceCount:Int = 0;
	var loadingSongAlphaScreen:FlxSprite;
	var loadingSongText:FlxText;
	var numCount:Int = 0;
	private var PSLoadedAssets:Array<FlxBasic> = [];
	static var PSLoadedMap:Map<String, Dynamic> = new Map<String, Dynamic>();
	var ratingCount:Int = 0;
	var stuffLoaded:Bool = false;

	// Mods!
	public static var isModSong:Bool = false;
	public static var mod:String = "";

	// Modes
	public static var PracticeMode:Bool = false;
	public static var botplayIsEnabled:Bool = false;
	var botplayWasUsed:Bool = false;

	// Actual song name
	public static var songName:String;

	// bleh
	public static var controlling:Bool = false;

	// UI
	public static var uiStyle:String;

	// Notes
	public var noteLuaFiles:Array<String>;
	public static var opponentNotesSeeable:Bool = true;
	public static var playerNotesSeeable:Bool = true;

	// Lua
	public static var ActorSprites:Map<String, Character> = new Map<String, Character>();
	public static var camFollowAdd:Map<String, Float> = new Map<String, Float>();
	public static var camFollowSetMap:Map<String, Float> = new Map<String, Float>();
	public static var BoyfriendPositionAdd:Array<Int> = [0, 0];
	public static var camPosSet:Map<String, Float> = new Map<String, Float>();
	public static var GirlfriendPositionAdd:Array<Int> = [0, 0];
	public static var LuaBackgroundGirls:Map<String, BackgroundGirls> = new Map<String, BackgroundGirls>();
	public var luaFiles:Int = 0;
	public static var LuaSprites:Map<String, FlxSprite> = new Map<String, FlxSprite>();
	public static var LuaTexts:Map<String, FlxText> = new Map<String, FlxText>();
	public static var LuaTweens:Map<String, FlxTween> = new Map<String, FlxTween>();
	public static var OpponentPositionAdd:Array<Int> = [0, 0];
	public static var RFELuaMap:Map<String, ReFunkedLua> = new Map<String, ReFunkedLua>();
	public static var TargetActors:Map<String, String> = new Map<String, String>();

	#if desktop
	// Discord RPC variables
	var iconRPC:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	override public function create()
	{
		destroyLuaObjects();
		nullPSLoadedAssets();
		unloadMBSassets();
		FreeplayState.nullFPLoadedAssets();
		Paths.nullPathsAssets();
		StoryMenuState.nullSMSLoadedAssets();
		PSLoadedMap = new Map<String, Dynamic>();
		PlayStateThing = this;

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// Lets set up some Lua stuff
		setUpLua();
		// Prepares song name since it's static
		songName = "";
		// Says when you're controlling
		controlling = false;

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');
		
		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		if(SONG.songName != null && SONG.songName != "")
			songName = SONG.songName;
		else
			songName = SONG.song;

		curStage = Utilities.checkStage(SONG.song, SONG.stage);

		if(SONG.uiStyle != null && SONG.uiStyle != "") {
			uiStyle = SONG.uiStyle;
		} else {
			if(curStage.startsWith("school"))
				uiStyle = "pixel";
			else
				uiStyle = "default";
		}
		
		if(Options.gameSFW) {
			if(Utilities.checkFileExists(Paths.songData(SONG.song, "dialogueSFW.txt")))
				dialogue = CoolUtil.coolTextFile(Paths.songData(SONG.song, "dialogueSFW.txt"));
			else if(Utilities.checkFileExists(Paths.songData(SONG.song, "dialogue.txt")))
				dialogue = CoolUtil.coolTextFile(Paths.songData(SONG.song, "dialogue.txt"));
		} else {
			if(Utilities.checkFileExists(Paths.songData(SONG.song, "dialogue.txt")))
				dialogue = CoolUtil.coolTextFile(Paths.songData(SONG.song, "dialogue.txt"));
		}
		
		if(isStoryMode) {
			switch (storyDifficulty)
			{
				case 0:
					storyDifficultyText = "EASY";
				case 1:
					storyDifficultyText = "NORMAL";
				case 2:
					storyDifficultyText = "HARD";
			}
		}

		#if desktop
		if (isStoryMode)
		{
			detailsText = "Story Mode: Week " + storyWeek;
		}
		else
		{
			detailsText = "Freeplay";
		}
		detailsPausedText = "Paused - " + detailsText;
		
		DiscordClient.changePresence(detailsText, detailsStageText);
		#end

		switch (curStage)
		{
	        case "spooky": 
			{
				halloweenLevel = true;

				var hallowTex = Paths.getSparrowAtlas('halloween_bg', "week2");
				halloweenBG = new FlxSprite(-200, -100);
				halloweenBG.frames = hallowTex;
				halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
				halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
				halloweenBG.animation.play('idle');
				halloweenBG.antialiasing = true;
				add(halloweenBG);
				PSLoadedMap["halloweenBG"] = halloweenBG;

				isHalloween = true;
	        }	
		    case "philly":
   	    	{
				var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('philly/sky', "week3"));
				bg.scrollFactor.set(0.1, 0.1);
				add(bg);
				PSLoadedMap["bg"] = bg;

				var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('philly/city', "week3"));
				city.scrollFactor.set(0.3, 0.3);
				city.setGraphicSize(Std.int(city.width * 0.85));
				city.updateHitbox();
				add(city);
				PSLoadedMap["city"] = city;

				phillyCityLights = new FlxTypedGroup<FlxSprite>();
				add(phillyCityLights);
				PSLoadedMap["phillyCityLights"] = phillyCityLights;

				for (i in 0...5)
				{
					var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.image('philly/win' + i, "week3"));
					light.scrollFactor.set(0.3, 0.3);
					light.visible = false;
					light.setGraphicSize(Std.int(light.width * 0.85));
					light.updateHitbox();
					light.antialiasing = true;
					phillyCityLights.add(light);
					PSLoadedMap["light" + i] = light;
				}

				var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image('philly/behindTrain', "week3"));
				add(streetBehind);
				PSLoadedMap["streetBehind"] = streetBehind;

				phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('philly/train'));
				add(phillyTrain);
				PSLoadedMap["phillyTrain"] = phillyTrain;

				trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
				FlxG.sound.list.add(trainSound);
				PSLoadedMap["trainSound"] = trainSound;

				var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.image('philly/street', "week3"));
				add(street);
				PSLoadedMap["street"] = street;
			}
			case "limo":
			{
				defaultCamZoom = 0.90;

				var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.image('limo/limoSunset', "week4"));
				skyBG.scrollFactor.set(0.1, 0.1);
				add(skyBG);
				PSLoadedMap["skyBG"] = skyBG;

				var bgLimo:FlxSprite = new FlxSprite(-200, 480);
				bgLimo.frames = Paths.getSparrowAtlas('limo/bgLimo', "week4");
				bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
				bgLimo.animation.play('drive');
				bgLimo.scrollFactor.set(0.4, 0.4);
				add(bgLimo);
				PSLoadedMap["bgLimo"] = bgLimo;

				grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
				add(grpLimoDancers);
				PSLoadedMap["grpLimoDancers"] = grpLimoDancers;
	
				for (i in 0...5)
				{
					var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
					dancer.scrollFactor.set(0.4, 0.4);
					grpLimoDancers.add(dancer);
					PSLoadedMap["dancer" + i] = dancer;
				}

				var overlayStuff:FlxSprite = new FlxSprite(-500, -600).loadGraphic(Paths.image('limo/limoOverlay', "week4"));
				overlayStuff.alpha = 0.5;
				PSLoadedMap["overlayStuff"] = overlayStuff;

				var limoTex = Paths.getSparrowAtlas('limo/limoDrive', "week4");

				limo = new FlxSprite(-120, 550);
				limo.frames = limoTex;
				limo.animation.addByPrefix('drive', "Limo stage", 24);
				limo.animation.play('drive');
				limo.antialiasing = true;
				PSLoadedMap["limo"] = limo;
	
				fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('limo/fastCarLol', "week4"));
				PSLoadedMap["fastCar"] = fastCar;
			}
			case "mall":
			{
				defaultCamZoom = 0.80;

				var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('christmas/bgWalls', "week5"));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.2, 0.2);
				bg.active = false;
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				add(bg);
				PSLoadedMap["bg"] = bg;

				upperBoppers = new FlxSprite(-240, -90);
				upperBoppers.frames = Paths.getSparrowAtlas('christmas/upperBop', "week5");
				upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
				upperBoppers.antialiasing = true;
				upperBoppers.scrollFactor.set(0.33, 0.33);
				upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
				upperBoppers.updateHitbox();
				add(upperBoppers);
				PSLoadedMap["upperBoppers"] = upperBoppers;

				var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.image('christmas/bgEscalator', "week5"));
				bgEscalator.antialiasing = true;
				bgEscalator.scrollFactor.set(0.3, 0.3);
				bgEscalator.active = false;
				bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
				bgEscalator.updateHitbox();
				add(bgEscalator);
				PSLoadedMap["bgEscalator"] = bgEscalator;

				var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.image('christmas/christmasTree', "week5"));
				tree.antialiasing = true;
				tree.scrollFactor.set(0.40, 0.40);
				add(tree);
				PSLoadedMap["tree"] = tree;

				bottomBoppers = new FlxSprite(-300, 140);
				bottomBoppers.frames = Paths.getSparrowAtlas('christmas/bottomBop', "week5");
				bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
				bottomBoppers.antialiasing = true;
				bottomBoppers.scrollFactor.set(0.9, 0.9);
				bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
				bottomBoppers.updateHitbox();
				add(bottomBoppers);
				PSLoadedMap["bottomBoppers"] = bottomBoppers;

				var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.image('christmas/fgSnow', "week5"));
				fgSnow.active = false;
				fgSnow.antialiasing = true;
				add(fgSnow);
				PSLoadedMap["fgSnow"] = fgSnow;

				santa = new FlxSprite(-840, 150);
				santa.frames = Paths.getSparrowAtlas('christmas/santa', "week5");
				santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
				santa.antialiasing = true;
				add(santa);
				PSLoadedMap["santa"] = santa;
			}
			case "mallEvil":
			{
				var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.image('christmas/evilBG', "week5"));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.2, 0.2);
				bg.active = false;
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				add(bg);
				PSLoadedMap["bg"] = bg;

				var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.image('christmas/evilTree', "week5"));
				evilTree.antialiasing = true;
				evilTree.scrollFactor.set(0.2, 0.2);
				add(evilTree);
				PSLoadedMap["evilTree"] = evilTree;

				var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.image("christmas/evilSnow", "week5"));
				evilSnow.antialiasing = true;
				add(evilSnow);
				PSLoadedMap["evilSnow"] = evilSnow;
			}
			case "school" | "schoolMad":
			{
				var bgSky = new FlxSprite().loadGraphic(Paths.image('weeb/weebSky'));
				bgSky.scrollFactor.set(0.1, 0.1);
				add(bgSky);
				PSLoadedMap["bgSky"] = bgSky;

				var repositionStuff = -200;	

				var bgSchool:FlxSprite = new FlxSprite(repositionStuff, 0).loadGraphic(Paths.image('weeb/weebSchool'));
				bgSchool.scrollFactor.set(0.6, 0.90);
				add(bgSchool);
				PSLoadedMap["bgSchool"] = bgSchool;

				var bgStreet:FlxSprite = new FlxSprite(repositionStuff).loadGraphic(Paths.image('weeb/weebStreet'));
				bgStreet.scrollFactor.set(0.95, 0.95);
				add(bgStreet);
				PSLoadedMap["bgStreet"] = bgStreet;

				var fgTrees:FlxSprite = new FlxSprite(repositionStuff + 170, 130).loadGraphic(Paths.image('weeb/weebTreesBack'));
				fgTrees.scrollFactor.set(0.9, 0.9);
				add(fgTrees);
				PSLoadedMap["fgTrees"] = fgTrees;

				var bgTrees:FlxSprite = new FlxSprite(repositionStuff - 380, -800);
				var treetex = Paths.getPackerAtlas('weeb/weebTrees');
				bgTrees.frames = treetex;
				bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
				bgTrees.animation.play('treeLoop');
				bgTrees.scrollFactor.set(0.85, 0.85);
				add(bgTrees);
				PSLoadedMap["bgTrees"] = bgTrees;

				var treeLeaves:FlxSprite = new FlxSprite(repositionStuff, -40);
				treeLeaves.frames = Paths.getSparrowAtlas('weeb/petals');
				treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
				treeLeaves.animation.play('leaves');
				treeLeaves.scrollFactor.set(0.85, 0.85);
				add(treeLeaves);
				PSLoadedMap["treeLeaves"] = treeLeaves;

				var widStuff = Std.int(bgSky.width * 6);

				bgSky.setGraphicSize(widStuff);
				bgSchool.setGraphicSize(widStuff);
				bgStreet.setGraphicSize(widStuff);
				bgTrees.setGraphicSize(Std.int(widStuff * 1.4));
				fgTrees.setGraphicSize(Std.int(widStuff * 0.8));
				treeLeaves.setGraphicSize(widStuff);

				fgTrees.updateHitbox();
				bgSky.updateHitbox();
				bgSchool.updateHitbox();
				bgStreet.updateHitbox();
				bgTrees.updateHitbox();
				treeLeaves.updateHitbox();

				bgGirls = new BackgroundGirls(-100, 190);
				bgGirls.scrollFactor.set(0.9, 0.9);	

				if (curStage == "schoolMad")
					bgGirls.getScared();
				bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
				bgGirls.updateHitbox();
				add(bgGirls);
				PSLoadedMap["bgGirls"] = bgGirls;
			}
			case "schoolEvil":
			{
				var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
				var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);
					
				var posX = 400;
				var posY = 200;

				var bg:FlxSprite = new FlxSprite(posX, posY);
				bg.frames = Paths.getSparrowAtlas('weeb/animatedEvilSchool');
				bg.animation.addByPrefix('idle', 'background 2', 24);
				bg.animation.play('idle');
				bg.scrollFactor.set(0.8, 0.9);
				bg.scale.set(6, 6);
				add(bg);
				PSLoadedMap["bg"] = bg;
			}
			case "stage":
			{
				defaultCamZoom = 0.9;

				var bg:FlxSprite = new FlxSprite(-600, -200);
				bg.loadGraphic(Paths.image('stageback'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = false;
				add(bg);
				PSLoadedMap["bg"] = bg;

				var stageFront:FlxSprite = new FlxSprite(-650, 600);
				stageFront.loadGraphic(Paths.image('stagefront'));
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				stageFront.antialiasing = true;
				stageFront.scrollFactor.set(0.9, 0.9);
				stageFront.active = false;
				add(stageFront);
				PSLoadedMap["stageFront"] = stageFront;

				var stageCurtains:FlxSprite = new FlxSprite(-500, -300);
				stageCurtains.loadGraphic(Paths.image('stagecurtains'));
				stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
				stageCurtains.updateHitbox();
				stageCurtains.antialiasing = true;
				stageCurtains.scrollFactor.set(1.3, 1.3);
				stageCurtains.active = false;
				add(stageCurtains);
				PSLoadedMap["stageCurtains"] = stageCurtains;
			}
			default:
			{
				#if sys
					if((isModSong ? !Utilities.checkFileExists(Paths.modStage(mod, SONG.stage)) : !Utilities.checkFileExists(Paths.stage(SONG.stage)))) {
						defaultCamZoom = 0.9;

						var bg:FlxSprite = new FlxSprite(-600, -200);
						bg.loadGraphic(Paths.image('stageback'));
						bg.antialiasing = true;
						bg.scrollFactor.set(0.9, 0.9);
						bg.active = false;
						add(bg);
						PSLoadedMap["bg"] = bg;

						var stageFront:FlxSprite = new FlxSprite(-650, 600);
						stageFront.loadGraphic(Paths.image('stagefront'));
						stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
						stageFront.updateHitbox();
						stageFront.antialiasing = true;
						stageFront.scrollFactor.set(0.9, 0.9);
						stageFront.active = false;
						add(stageFront);
						PSLoadedMap["stageFront"] = stageFront;

						var stageCurtains:FlxSprite = new FlxSprite(-500, -300);
						stageCurtains.loadGraphic(Paths.image('stagecurtains'));
						stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
						stageCurtains.updateHitbox();
						stageCurtains.antialiasing = true;
						stageCurtains.scrollFactor.set(1.3, 1.3);
						stageCurtains.active = false;
						add(stageCurtains);
						PSLoadedMap["stageCurtains"] = stageCurtains;
					} else {
						if(isModSong) {
							if(Utilities.checkFileExists(Paths.modStage(mod, SONG.stage))) {
								RFELuaMap[SONG.stage + luaFiles] = new ReFunkedLua(Paths.modStage(mod, SONG.stage));
								luaFiles++;
							}
						} else {
							if(Utilities.checkFileExists(Paths.stage(SONG.stage))) {
								RFELuaMap[SONG.stage + luaFiles] = new ReFunkedLua(Paths.stage(SONG.stage));
								luaFiles++;
							}
						}
					}
				#else
					defaultCamZoom = 0.9;

					var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
					bg.antialiasing = true;
					bg.scrollFactor.set(0.9, 0.9);
					bg.active = false;
					add(bg);
					PSLoadedMap["bg"] = bg;

					var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
					stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
					stageFront.updateHitbox();
					stageFront.antialiasing = true;
					stageFront.scrollFactor.set(0.9, 0.9);
					stageFront.active = false;
					add(stageFront);
					PSLoadedMap["stageFront"] = stageFront;

					var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					stageCurtains.antialiasing = true;
					stageCurtains.scrollFactor.set(1.3, 1.3);
					stageCurtains.active = false;
					add(stageCurtains);
					PSLoadedMap["stageCurtains"] = stageCurtains;
				#end
			}
		}

		var gfVersion:String;

		if(SONG.gfPlayer != null)
			gfVersion = SONG.gfPlayer;
		else
			gfVersion = Utilities.checkGf(curStage);

		gf = new Character(400, 130, gfVersion);
		gf.scrollFactor.set(0.95, 0.95);
		ActorSprites["girlfriend"] = gf;
		LuaSprites["gfSprite"] = gf;
		PSLoadedMap["girlfriend"] = gf;
		TargetActors["girlfriend"] = "girlfriend";

		dad = new Character(100, 100, SONG.player2);
		ActorSprites["opponent"] = dad;
		LuaSprites["dadSprite"] = dad;
		PSLoadedMap["dad"] = dad;
		TargetActors["opponent"] = "opponent";

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		boyfriend = new Boyfriend(770, 100, SONG.player1);
		ActorSprites["boyfriend"] = boyfriend;
		LuaSprites["bfSprite"] = boyfriend;
		PSLoadedMap["boyfriend"] = boyfriend;
		TargetActors["boyfriend"] = "boyfriend";

		switch (curStage)
		{
			case 'limo':
				boyfriend.y -= 220;
				boyfriend.x += 260;
				resetFastCar();
				add(fastCar);
			case 'mall':
				dad.x -= 500;
				boyfriend.x += 200;
			case 'mallEvil':
				boyfriend.x += 320;
				dad.y += 50;
			case 'philly':
				camPos.x += 600;
				dad.y += 300;
			case 'school' | 'schoolMad':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'schoolEvil':
				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
				add(evilTrail);
				dad.x -= 150;
				dad.y += 100;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'spooky':
				if(SONG.player2.startsWith("monster")) {
					dad.y += 100;
				} else if(SONG.player2.startsWith("spooky")) {
					dad.y += 200;
				}
			case 'stage':
				camPos.x += 400;
		}
		
		if(SONG.player2.startsWith("gf")) {
			dad.setPosition(gf.x, gf.y);
			gf.visible = false;
			if (isStoryMode)
			{
				camPos.x += 600;
				tweenCamIn();
			}
		}

		if(camPosSet.exists("x") && camPosSet.exists("y")) {
			camPos.x = camPosSet.get("x");
			camPos.y = camPosSet.get("y");
		}

		gf.x += gf.CharPositionUse[0] + GirlfriendPositionAdd[0];
		gf.y += gf.CharPositionUse[1] + GirlfriendPositionAdd[1];
		dad.x += dad.CharPositionUse[0] + OpponentPositionAdd[0];
		dad.y += dad.CharPositionUse[1] + OpponentPositionAdd[1];
		boyfriend.x += boyfriend.CharPositionUse[0] + BoyfriendPositionAdd[0];
		boyfriend.y += boyfriend.CharPositionUse[1] + BoyfriendPositionAdd[1];

		add(gf);

		if (curStage == 'limo')
			add(limo);

		add(dad);
		add(boyfriend);
		
		if(dialogue != null) {
			doof = new DialogueBox(false, dialogue);
			doof.scrollFactor.set();
			doof.finishThing = afterTextIntro;
		}

		Conductor.songPosition = -300000;

		strumLine = new FlxSprite((Options.middlescroll ? -282 : 40), (Options.downscroll ? FlxG.height - 150 : 50)).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();
		PSLoadedMap["strumLine"] = strumLine;

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<FlxSprite>();
		cpuStrums = new FlxTypedGroup<FlxSprite>();

		loadingSongAlphaScreen = new FlxSprite(-600,-600).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		loadingSongAlphaScreen.visible = false;
		loadingSongAlphaScreen.alpha = 0.5;
		loadingSongAlphaScreen.scrollFactor.set();
		add(loadingSongAlphaScreen);
		PSLoadedMap["loadingSongAlphaScreen"] = loadingSongAlphaScreen;

		loadingSongText = new FlxText(0, 0, 0, "Loading instrumental and vocals...");
		loadingSongText.visible = false;
		loadingSongText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		loadingSongText.scrollFactor.set();
		add(loadingSongText);
		PSLoadedMap["loadingSongText"] = loadingSongText;

		generateSong(SONG.song);
		loadDevs();

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		bubbywidth = FlxG.width;
		bubbyheight = FlxG.height;
		devSelector = Std.random(randomDevs.length);
		ThemeStuff.loadTheme();

		if(ThemeStuff.timeBarIsEnabled == true) {
			switch(ThemeStuff.timeBarStyle.toLowerCase()) {
				case "kadeold":
					timeBarBG = new FlxSprite(Std.int(ThemeStuff.timeBarX), (Options.downscroll ? Std.int(ThemeStuff.timeBarDSY) : Std.int(ThemeStuff.timeBarY))).loadGraphic(Paths.image('healthBar'));
					timeBarBG.screenCenter(X);
					timeBarBG.scrollFactor.set();
					if(ThemeStuff.timeBarIsTextOnly)
						timeBarBG.visible = false;
					add(timeBarBG);

					timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this, 'songPercentage', 0, 1);
					timeBar.scrollFactor.set();
					timeBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
					timeBar.numDivisions = 800;
					if(ThemeStuff.timeBarIsTextOnly)
						timeBar.visible = false;
					add(timeBar);

					timeTxt = new FlxText(0, timeBarBG.y, 0, SONG.song, 16);
					timeTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
					timeTxt.scrollFactor.set();
					add(timeTxt);
				case "leather":
					timeBarBG = new FlxSprite(Std.int(ThemeStuff.timeBarX), (Options.downscroll ? Std.int(ThemeStuff.timeBarDSY) : Std.int(ThemeStuff.timeBarY))).loadGraphic(Paths.image('leatherTimeBar'));
					if(ThemeStuff.timeBarCenter)
						timeBarBG.screenCenter(X);
					if(ThemeStuff.timeBarIsTextOnly)
						timeBarBG.visible = false;
					timeBarBG.scrollFactor.set();
					timeBarBG.pixelPerfectPosition = true;
					add(timeBarBG);
					trace(timeBarBG.height);

					timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this, 'songPercentage', 0, 1);
					timeBar.scrollFactor.set();
					timeBar.createFilledBar(FlxColor.BLACK, FlxColor.CYAN);
					timeBar.pixelPerfectPosition = true;
					timeBar.numDivisions = 800;
					if(ThemeStuff.timeBarIsTextOnly)
						timeBar.visible = false;
					add(timeBar);

					timeTxt = new FlxText(0, (Options.downscroll ? timeBarBG.y - timeBarBG.height - 1 : timeBarBG.y + timeBarBG.height + 1), 0, "", 16);
					timeTxt.screenCenter(X);
					timeTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
					timeTxt.scrollFactor.set();
					add(timeTxt);
				case "psych":
					timeTxt = new FlxText(Std.int(ThemeStuff.timeBarX), (Options.downscroll ? Std.int(ThemeStuff.timeBarDSY) : Std.int(ThemeStuff.timeBarY)), 400, "", 32);
					timeTxt.setFormat(Paths.font("vcr.ttf"), ThemeStuff.timeBarFontsize, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
					timeTxt.scrollFactor.set();
					timeTxt.borderSize = 2;

					timeBarBG = new FlxSprite(timeTxt.x, timeTxt.y + (timeTxt.height / 4)).loadGraphic(Paths.image('psychTimeBar'));
					timeBarBG.screenCenter(X);
					timeBarBG.scrollFactor.set();
					timeBarBG.color = FlxColor.BLACK;
					if(ThemeStuff.timeBarIsTextOnly)
						timeBarBG.visible = false;
					add(timeBarBG);

					timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this, 'songPercentage', 0, 1);
					timeBar.scrollFactor.set();
					timeBar.createFilledBar(0xFF000000, 0xFFFFFFFF);
					timeBar.numDivisions = 800;
					if(ThemeStuff.timeBarIsTextOnly)
						timeBar.visible = false;
					add(timeBar);
					add(timeTxt);
				default:
					timeTxt = new FlxText(Std.int(ThemeStuff.timeBarX), (Options.downscroll ? Std.int(ThemeStuff.timeBarDSY) : Std.int(ThemeStuff.timeBarY)), 400, "", 32);
					timeTxt.setFormat(Paths.font("vcr.ttf"), ThemeStuff.timeBarFontsize, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
					timeTxt.scrollFactor.set();
					timeTxt.borderSize = 2;

					timeBarBG = new FlxSprite(timeTxt.x, timeTxt.y + (timeTxt.height / 4)).loadGraphic(Paths.image('psychTimeBar'));
					timeBarBG.scrollFactor.set();
					timeBarBG.color = FlxColor.BLACK;
					if(ThemeStuff.timeBarIsTextOnly)
						timeBarBG.visible = false;
					add(timeBarBG);

					timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this, 'songPercentage', 0, 1);
					timeBar.scrollFactor.set();
					timeBar.createFilledBar(0xFF000000, 0xFFFFFFFF);
					timeBar.numDivisions = 800;
					if(ThemeStuff.timeBarIsTextOnly)
						timeBar.visible = false;
					add(timeBar);
					add(timeTxt);
			}
			PSLoadedMap["timeTxt"] = timeTxt;
			PSLoadedMap["timeBar"] = timeBar;
			PSLoadedMap["timeBarBG"] = timeBarBG;
		}

		if(ThemeStuff.healthBarIsEnabled == true) {
			healthBarBG = new FlxSprite(Std.int(ThemeStuff.healthBarX), (Options.downscroll ? Std.int(ThemeStuff.healthBarDSY) : Std.int(ThemeStuff.healthBarY))).loadGraphic(Paths.image('healthBar'));
			if(ThemeStuff.healthBarCenter == true)
				healthBarBG.screenCenter(X);
			healthBarBG.scrollFactor.set();
			add(healthBarBG);
			PSLoadedMap["healthBarBG"] = healthBarBG;

			healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this, 'health', 0, 2);
			healthBar.scrollFactor.set();
			healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
			add(healthBar);
			PSLoadedMap["healthBar"] = healthBar;

			if(ThemeStuff.healthBarShowP1 == true) {
				OGIconP1 = new HealthIcon(SONG.player1, true);
				PSLoadedMap["OGIconP1"] = OGIconP1;
				add(OGIconP1);
				OGIconP1.visible = false;
				oldbfIcon = new HealthIcon("bf-old", true);
				PSLoadedMap["oldbfIcon"] = oldbfIcon;
				add(oldbfIcon);
				oldbfIcon.visible = false;
				pahazeIcon = new HealthIcon("pahaze", true);
				PSLoadedMap["pahazeIcon"] = pahazeIcon;
				add(pahazeIcon);
				pahazeIcon.visible = false;
				pahazeRedwickIcon = new HealthIcon("redwick-pahaze", true);
				PSLoadedMap["pahazeRedwickIcon"] = pahazeRedwickIcon;
				add(pahazeRedwickIcon);
				pahazeRedwickIcon.visible = false;
				if(bfEasterEggEnabled) {
					iconP1 = oldbfIcon;
					oldbfIcon.visible = true;
				} else if(devEasterEggEnabled) {
					iconP1 = pahazeIcon;
					pahazeIcon.visible = true;
				} else if(duoDevEasterEggEnabled) {
					iconP1 = pahazeRedwickIcon;
					pahazeRedwickIcon.visible = true;
				} else {
					iconP1 = OGIconP1;
					OGIconP1.visible = true;
				}
				iconP1.y = healthBar.y - (iconP1.height / 2);
				add(iconP1);
				PSLoadedMap["iconP1"] = iconP1;
			}

			if(ThemeStuff.healthBarShowP2 == true) {
				OGIconP2 = new HealthIcon(SONG.player2, false);
				PSLoadedMap["OGIconP2"] = OGIconP2;
				add(OGIconP2);
				OGIconP2.visible = false;
				dadIcon = new HealthIcon("dad", false);
				PSLoadedMap["dadIcon"] = dadIcon;
				add(dadIcon);
				dadIcon.visible = false;
				if(dadEasterEggEnabled) {
					iconP2 = dadIcon;
					dadIcon.visible = true;
				} else {
					iconP2 = OGIconP2;
					OGIconP2.visible = true;
				}
				iconP2.y = healthBar.y - (iconP2.height / 2);
				add(iconP2);
				PSLoadedMap["iconP2"] = iconP2;
			}
		}

		if(ThemeStuff.accTextIsEnabled == true) {
			accTxt = new FlxText(ThemeStuff.accTextX, (Options.downscroll ? ThemeStuff.accTextDSY : ThemeStuff.accTextY), 0, "", 20);
			accTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			accTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 3, 1);
			accTxt.scrollFactor.set();
			add(accTxt);
			PSLoadedMap["accTxt"] = accTxt;
		}

		if(ThemeStuff.extraTextIsEnabled == true) {
			for(i in 0...ThemeStuff.extraTextLength) {
				var extraTxt:FlxText;
				extraTxt = new FlxText(ThemeStuff.extraTextX[i], (Options.downscroll ? ThemeStuff.extraTextDSY[i] : ThemeStuff.extraTextY[i]), 0, "", 20);
				extraTxt.setFormat(Paths.font("vcr.ttf"), ThemeStuff.extraFontsize[i], FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				extraTxt.scrollFactor.set();
				add(extraTxt);
				extraTxt.cameras = [camHUD];
				LuaTexts["extraTxt" + i] = extraTxt;
			}
		}

		if(ThemeStuff.missTextIsEnabled == true) {
			missTxt = new FlxText(ThemeStuff.missTextX, (Options.downscroll ? ThemeStuff.missTextDSY : ThemeStuff.missTextY), 0, "", 20);
			missTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			missTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 3, 1);
			missTxt.scrollFactor.set();
			add(missTxt);
			PSLoadedMap["missTxt"] = missTxt;
		}

		if(ThemeStuff.npsTextIsEnabled == true) {
			npsTxt = new FlxText(ThemeStuff.npsTextX, (Options.downscroll ? ThemeStuff.npsTextDSY : ThemeStuff.npsTextY), 0, "", 20);
			npsTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			npsTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 3, 1);
			npsTxt.scrollFactor.set();
			add(npsTxt);
			PSLoadedMap["npsTxt"] = npsTxt;
		}

		if(ThemeStuff.scoreTextIsEnabled == true) {
			scoreTxt = new FlxText(ThemeStuff.scoreTextX, (Options.downscroll ? ThemeStuff.scoreTextDSY : ThemeStuff.scoreTextY), 0, "", 20);
			scoreTxt.setFormat(Paths.font("vcr.ttf"), ThemeStuff.scoreTextFontsize, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			if(ThemeStuff.scoreTextBorder > 0)
				scoreTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, ThemeStuff.scoreTextBorder, 1);
			scoreTxt.scrollFactor.set();
			add(scoreTxt);
			PSLoadedMap["scoreTxt"] = scoreTxt;
		}

		if(ThemeStuff.botplayTextIsEnabled == true) {
			botplayTxt = new FlxText(ThemeStuff.botplayTextX, (Options.downscroll ? ThemeStuff.botplayTextDSY : ThemeStuff.botplayTextY), FlxG.width - 800, ThemeStuff.botplayText, 32);
			if(Options.themeData == "psych" && Options.middlescroll) {
				if(Options.downscroll == true)
					botplayTxt.y = botplayTxt.y - 78;
				else
					botplayTxt.y = botplayTxt.y + 78;
			}
			botplayTxt.setFormat(Paths.font("vcr.ttf"), ThemeStuff.botplayFontsize, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			botplayTxt.scrollFactor.set();
			botplayTxt.borderSize = 1.25;
			botplayTxt.visible = botplayIsEnabled;
			add(botplayTxt);
			PSLoadedMap["botplayTxt"] = botplayTxt;
		}

		if(ThemeStuff.watermarkIsEnabled == true) {
			refunkedWatermark = new FlxText(ThemeStuff.watermarkX, (Options.downscroll ? ThemeStuff.watermarkDSY : ThemeStuff.watermarkY), 0, "", 16);
			refunkedWatermark.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			refunkedWatermark.scrollFactor.set();
			add(refunkedWatermark);
			PSLoadedMap["RFEWatermark"] = refunkedWatermark;
		}

		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		if(ThemeStuff.accTextIsEnabled == true)
			accTxt.cameras = [camHUD];
		if(ThemeStuff.missTextIsEnabled == true)
			missTxt.cameras = [camHUD];
		if(ThemeStuff.npsTextIsEnabled == true)
			npsTxt.cameras = [camHUD];
		if(ThemeStuff.healthBarIsEnabled == true) {
			healthBar.cameras = [camHUD];
			healthBarBG.cameras = [camHUD];
			if(ThemeStuff.healthBarShowP1 == true) {
				iconP1.cameras = [camHUD];
				OGIconP1.cameras = [camHUD];
				oldbfIcon.cameras = [camHUD];
				pahazeIcon.cameras = [camHUD];
				pahazeRedwickIcon.cameras = [camHUD];
			}
			if(ThemeStuff.healthBarShowP2 == true) {
				iconP2.cameras = [camHUD];
				dadIcon.cameras = [camHUD];
				OGIconP2.cameras = [camHUD];
			}
		}
		if(ThemeStuff.scoreTextIsEnabled == true)
			scoreTxt.cameras = [camHUD];
		if(ThemeStuff.timeBarIsEnabled == true) {
			timeBar.cameras = [camHUD];
			timeBarBG.cameras = [camHUD];
			timeTxt.cameras = [camHUD];
		}
		if(ThemeStuff.botplayTextIsEnabled == true)
			botplayTxt.cameras = [camHUD];
		if(ThemeStuff.watermarkIsEnabled == true)
			refunkedWatermark.cameras = [camHUD];
		if(dialogue != null)
			doof.cameras = [camHUD];

		#if sys
			if(isModSong) {
				if(Utilities.checkFileExists(Paths.modSongData(mod, SONG.song, "modchart.lua"))) {
					RFELuaMap["modchart"  + luaFiles] = new ReFunkedLua(Paths.modSongData(mod, SONG.song, "modchart.lua"));
					luaFiles++;
				}
			} else {
				if(Utilities.checkFileExists(Paths.songData(SONG.song, "modchart.lua"))) {
					RFELuaMap["modchart"  + luaFiles] = new ReFunkedLua(Paths.songData(SONG.song, "modchart.lua"));
					luaFiles++;
				}
			}

			noteLuaFiles = Utilities.readFolder("assets/notes");
			if(noteLuaFiles != null) {
				for(i in 0...noteLuaFiles.length) {
					if(noteLuaFiles[i].endsWith(".lua")) {
						RFELuaMap[noteLuaFiles[i]] = new ReFunkedLua("assets/notes/" + noteLuaFiles[i]);
						luaFiles++;
					}
				}
			}
		#end

		super.create();

		#if sys
			luaCallback("postCreate", []);
		#end
	}

	function afterTextIntro():Void {
		startingSong = true;
		makeStuffVisibleLol();
		startCountdown();
	}

	function doDialogue(stage:String) {
		switch(stage) {
			case "school" | "schoolMad" | "schoolEvil":
				if(dialogue != null)
					schoolIntro(doof);
				else
					afterTextIntro();
			default:
				if(dialogue != null) {
					inCutscene = true;
					add(doof);
				} else {
					afterTextIntro();
				}
		}
	}

	function makeStuffInvisibleLol() {
		if(ThemeStuff.accTextIsEnabled)
			accTxt.visible = false;
		if(ThemeStuff.botplayTextIsEnabled)
			botplayTxt.visible = false;
		if(ThemeStuff.extraTextIsEnabled) {
			for(i in 0...ThemeStuff.extraTextLength) {
				LuaTexts["extraTxt" + i].visible = false;
			}
		}
		if(ThemeStuff.missTextIsEnabled)
			missTxt.visible = false;
		if(ThemeStuff.npsTextIsEnabled)
			npsTxt.visible = false;
		if(ThemeStuff.scoreTextIsEnabled)
			scoreTxt.visible = false;
		if(ThemeStuff.watermarkIsEnabled)
			refunkedWatermark.visible = false;
		if(ThemeStuff.timeBarIsEnabled) {
			if(!ThemeStuff.timeBarIsTextOnly) {
				timeBarBG.visible = false;
				timeBar.visible = false;
			}
			timeTxt.visible = false;
		}
		if(ThemeStuff.healthBarIsEnabled) {
			healthBarBG.visible = false;
			healthBar.visible = false;
			if(ThemeStuff.healthBarShowP1)
				iconP1.visible = false;
			if(ThemeStuff.healthBarShowP2)
				iconP2.visible = false;
		}
	}

	function makeStuffVisibleLol() {
		if(ThemeStuff.accTextIsEnabled)
			accTxt.visible = true;
		if(ThemeStuff.botplayTextIsEnabled)
			botplayTxt.visible = true;
		if(ThemeStuff.extraTextIsEnabled) {
			for(i in 0...ThemeStuff.extraTextLength) {
				LuaTexts["extraTxt" + i].visible = true;
			}
		}
		if(ThemeStuff.missTextIsEnabled)
			missTxt.visible = true;
		if(ThemeStuff.npsTextIsEnabled)
			npsTxt.visible = true;
		if(ThemeStuff.scoreTextIsEnabled)
			scoreTxt.visible = true;
		if(ThemeStuff.watermarkIsEnabled)
			refunkedWatermark.visible = true;
		if(ThemeStuff.timeBarIsEnabled) {
			if(!ThemeStuff.timeBarIsTextOnly) {
				timeBarBG.visible = true;
				timeBar.visible = true;
			}
			timeTxt.visible = true;
		}
		if(ThemeStuff.healthBarIsEnabled) {
			healthBarBG.visible = true;
			healthBar.visible = true;
			if(ThemeStuff.healthBarShowP1)
				iconP1.visible = true;
			if(ThemeStuff.healthBarShowP2)
				iconP2.visible = true;
		}
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		inCutscene = true;
		makeStuffInvisibleLol();

		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);
		PSLoadedMap["black"] = black;

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();
		PSLoadedMap["red"] = red;

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();
		PSLoadedMap["senpaiEvil"] = senpaiEvil;

		if (SONG.song.toLowerCase() == 'roses' || SONG.song.toLowerCase() == 'thorns')
		{
			remove(black);

			if (SONG.song.toLowerCase() == 'thorns')
			{
				add(red);
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					if (SONG.song.toLowerCase() == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					afterTextIntro();

				remove(black);
			}
		});
	}

	var startTimer:FlxTimer;
	var perfectMode:Bool = false;

	function startCountdown():Void
	{
		inCutscene = false;

		generateStaticArrows(0);
		generateStaticArrows(1);
		if(Options.middlescroll) {
			for(i in 0...cpuStrums.length) {
				cpuStrums.members[i].visible = false;
			}
		}
		#if sys
			for(i in 0...playerStrums.length) {
				setLuaVar("defaultPlayerStrumX" + i, playerStrums.members[i].x);
				setLuaVar("defaultPlayerStrumY" + i, playerStrums.members[i].y);
			}
			for(i in 0...cpuStrums.length) {
				setLuaVar("defaultOpponentStrumX" + i, cpuStrums.members[i].x);
				setLuaVar("defaultOpponentStrumY" + i, cpuStrums.members[i].y);
			}
		#end

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('pixel', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			for (value in introAssets.keys())
			{
				if (value == uiStyle)
				{
					introAlts = introAssets.get(value);
					altSuffix = '-pixel';
				}
			}

			switch (swagCounter)

			{
				case 0:
					switch (uiStyle) {
						case 'pixel':
							FlxG.sound.play(Paths.sound('intro3-pixel'), 0.6);
						default:
							FlxG.sound.play(Paths.sound('intro3'), 0.6);
					}
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (uiStyle.startsWith('pixel'))
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					switch (uiStyle) {
						case 'pixel':
							FlxG.sound.play(Paths.sound('intro2-pixel'), 0.6);
						default:
							FlxG.sound.play(Paths.sound('intro2'), 0.6);
					}
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					if (uiStyle.startsWith('pixel'))
						set.setGraphicSize(Std.int(set.width * daPixelZoom));

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					switch (uiStyle) {
						case 'pixel':
							FlxG.sound.play(Paths.sound('intro1-pixel'), 0.6);
						default:
							FlxG.sound.play(Paths.sound('intro1'), 0.6);
					}
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();

					if (uiStyle.startsWith('pixel'))
						go.setGraphicSize(Std.int(go.width * daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					switch (uiStyle) {
						case 'pixel':
							FlxG.sound.play(Paths.sound('introGo-pixel'), 0.6);
							FlxG.sound.music.stop();
						default:
							FlxG.sound.play(Paths.sound('introGo'), 0.6);
							FlxG.sound.music.stop();
					}
					gf.dance();
				case 4:
			}

			swagCounter += 1;
		}, 5);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused) {
			inst.play();
		}
		vocals.play();
		inst.onComplete = endSong;

		// Song duration in a float, useful for the time left feature
		songLength = inst.length;

		#if desktop
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength);
		#end
	}

	var debugNum:Int = 0;

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if(isModSong)
			inst = new FlxSound().loadStream("./" + Paths.modInst(mod, PlayState.SONG.song));
		else
			inst = new FlxSound().loadStream("./" + Paths.inst(PlayState.SONG.song));

		if (SONG.needsVoices) {
			if(isModSong)
				vocals = new FlxSound().loadStream("./" + Paths.modVoices(mod, PlayState.SONG.song));
			else
				vocals = new FlxSound().loadStream("./" + Paths.voices(PlayState.SONG.song));
		} else
			vocals = new FlxSound();

		FlxG.sound.list.add(inst);
		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);
		PSLoadedMap["notes"] = notes;

		var noteData:Array<SwagSection>;

		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);
				var noteType:String = songNotes[3];

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
					gottaHitNote = !section.mustHitSection;

				if (noteType == null || noteType == "") {
					if(uiStyle == "pixel")
						noteType = "pixel";
					else
						noteType = "normal";
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, noteType);
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);
				PSLoadedMap["swagNote" + section + songNotes] = swagNote;

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, noteType, true);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);
					PSLoadedMap["sustainNote" + susNote + section + songNotes] = sustainNote;

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
					{
						sustainNote.x += FlxG.width / 2; // general offset
					}
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress) {
					swagNote.x += FlxG.width / 2; // general offset
				}
			}
			daBeats += 1;
		}

		unspawnNotes.sort(sortByStuff);
		generatedMusic = true;
	}

	function sortByStuff(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			var babyArrow:FlxSprite = new FlxSprite((Options.middlescroll ? -282 : 40), strumLine.y);

			switch (uiStyle)
			{
				case 'pixel':
					babyArrow.loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.add('static', [0]);
							babyArrow.animation.add('pressed', [4, 8], 12, false);
							babyArrow.animation.add('confirm', [12, 16], 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.add('static', [1]);
							babyArrow.animation.add('pressed', [5, 9], 12, false);
							babyArrow.animation.add('confirm', [13, 17], 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.add('static', [2]);
							babyArrow.animation.add('pressed', [6, 10], 12, false);
							babyArrow.animation.add('confirm', [14, 18], 12, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.add('static', [3]);
							babyArrow.animation.add('pressed', [7, 11], 12, false);
							babyArrow.animation.add('confirm', [15, 19], 24, false);
					}
				default:
					babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');
					babyArrow.animation.addByPrefix('green', 'arrowUP');
					babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
					babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
					babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

					babyArrow.antialiasing = true;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.addByPrefix('static', 'arrow static instance 1');
							babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.addByPrefix('static', 'arrow static instance 2');
							babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.addByPrefix('static', 'arrow static instance 4');
							babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.addByPrefix('static', 'arrow static instance 3');
							babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
					}
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			babyArrow.ID = i;

			if (player == 1)
				playerStrums.add(babyArrow);
			else
				cpuStrums.add(babyArrow);

			cpuStrums.forEach(function(spr:FlxSprite)
			{
				spr.centerOffsets();
			});

			babyArrow.animation.play('static');
			babyArrow.x += 60;
			babyArrow.x += ((FlxG.width / 2) * player);

			strumLineNotes.add(babyArrow);
			PSLoadedMap["babyArrow" + player + i] = babyArrow;
		}
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (inst != null)
			{
				inst.pause();
				vocals.pause();
			}

			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (inst != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			#if desktop
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, detailsStageText, iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, detailsStageText, iconRPC);
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		super.onFocus();
	}
	
	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, detailsStageText, iconRPC);
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		vocals.pause();

		inst.play();
		Conductor.songPosition = inst.time;
		vocals.time = inst.time;
		vocals.play();
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	override public function update(elapsed:Float)
	{
		#if !debug
		perfectMode = false;
		#end

		#if sys
			if(boyfriend != null) {
				setLuaVar('boyfriendMidpointX', boyfriend.getMidpoint().x);
				setLuaVar('boyfriendMidpointY', boyfriend.getMidpoint().y);
			}
			if(dad != null) {
				setLuaVar('opponentMidpointX', dad.getMidpoint().x);
				setLuaVar('opponentMidpointY', dad.getMidpoint().y);
			}
			setLuaVar('curBeat', curBeat);
			setLuaVar('curStep', curStep);
			setLuaVar('health', health);
			setLuaVar('songPosition', Conductor.songPosition);
			luaCallback("update", []);
		#end

		if (FlxG.keys.justPressed.NINE) {
			if (iconP1.animation.curAnim.name == 'bf-old') {
				iconP1 = OGIconP1;
				OGIconP1.visible = true;
				oldbfIcon.visible = false;
				pahazeIcon.visible = false;
				pahazeRedwickIcon.visible = false;
			} else {
				iconP1 = oldbfIcon;
				OGIconP1.visible = false;
				oldbfIcon.visible = true;
				pahazeIcon.visible = false;
				pahazeRedwickIcon.visible = false;
			}
			bfEasterEggEnabled = !bfEasterEggEnabled;
			devEasterEggEnabled = false;
			duoDevEasterEggEnabled = false;
		}

		if (FlxG.keys.justPressed.EIGHT) {
			if (iconP2.animation.curAnim.name == 'dad') {
				iconP2 = OGIconP2;
				dadIcon.visible = false;
				OGIconP2.visible = true;
			} else {
				iconP2 = dadIcon;
				dadIcon.visible = true;
				OGIconP2.visible = false;
			}
			dadEasterEggEnabled = !dadEasterEggEnabled;
		}
		
		if (FlxG.keys.justPressed.TWO) {
			if (iconP1.animation.curAnim.name == 'redwick-pahaze') {
				iconP1 = OGIconP1;
				OGIconP1.visible = true;
				oldbfIcon.visible = false;
				pahazeIcon.visible = false;
				pahazeRedwickIcon.visible = false;
			} else {
				iconP1 = pahazeRedwickIcon;
				OGIconP1.visible = false;
				oldbfIcon.visible = false;
				pahazeIcon.visible = false;
				pahazeRedwickIcon.visible = true;
			}
			bfEasterEggEnabled = false;
			devEasterEggEnabled = false;
			duoDevEasterEggEnabled = !duoDevEasterEggEnabled;
		}

		if (FlxG.keys.justPressed.ONE) {
			if (iconP1.animation.curAnim.name == 'pahaze') {
				iconP1 = OGIconP1;
				OGIconP1.visible = true;
				oldbfIcon.visible = false;
				pahazeIcon.visible = false;
				pahazeRedwickIcon.visible = false;
			} else {
				iconP1 = pahazeIcon;
				OGIconP1.visible = false;
				oldbfIcon.visible = false;
				pahazeIcon.visible = true;
				pahazeRedwickIcon.visible = false;
			}
			bfEasterEggEnabled = false;
			devEasterEggEnabled = !devEasterEggEnabled;
			duoDevEasterEggEnabled = false;
		}

		if(botplayIsEnabled)
			botplayWasUsed = true;

		if(inst.playing) {
			var huh = hitArrayThing.length - 1;
			while(huh >= 0) {
				var bro:Date = hitArrayThing[huh];
				if(bro != null && bro.getTime() + 1000 < Date.now().getTime())
					hitArrayThing.remove(bro);
				else
					huh = 0;
				huh--;
			}
			funnyNPS = hitArrayThing.length; 
			if(funnyNPS > funnyMaxNPS)
				funnyMaxNPS = funnyNPS;
		}

		switch (curStage)
		{
			case 'philly':	
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
		}

		super.update(elapsed);

		if(ThemeStuff.timeBarIsEnabled) {
			switch (ThemeStuff.timeBarStyle) {
				case "psych":
					timeBarBG.setPosition(timeBar.x - 4, timeBar.y - 4);
					timeBarBG.scrollFactor.set();
				default:
					timeBarBG.setPosition(timeBar.x - 4, timeBar.y - 4);
					timeBarBG.scrollFactor.set();
			}
		}
	
		if(accuracyThing >= 69 && accuracyThing < 70 && ThemeStuff.ratingStyle != "psych") {
			notesRating = "Nice";
		} else {
			switch(misses) {
				case 0:
					if(awfuls > 0) {
						notesRating = "AFC";
					} else if(bads > 0) {
						notesRating = "FC";
					} else if(goods > 0) {
						notesRating = "GFC";
					} else {
						notesRating = "SFC";
					}
				default:
					if(misses < 10 && misses > 0) {
						notesRating = "SDCB";
						} else if(misses > 9) {
						notesRating = "Clear";
					}
			}
		}

		if(stuffLoaded && !inCutscene) {
			var min = Math.floor(((inst.length - Conductor.songPosition) % 3600000) / 60000);
			var sec = Math.floor(((inst.length - Conductor.songPosition) % 60000) / 1000);

			m = '$min'.lpad("0", 2);
			s = '$sec'.lpad("0", 2);

			if(Std.parseInt(m) <= 0) {
				m = "00";
			}
			if(Std.parseInt(s) <= 0) {
				s = "00";
			}
		} else {
			m = "??";
			s = "??";
		}

		if(accNotesToDivide > 0 && accNotesTotal > 0)
			accuracyThing = FlxMath.roundDecimal(((accNotesToDivide / accNotesTotal) * 100), 2);
		else if(accNotesToDivide == 0 && accNotesTotal > 0)
			accuracyThing = 0;
		else
			accuracyThing = 100;

		funnyRating = Utilities.calculateThemeRating(accuracyThing, ThemeStuff.ratingStyle);

		if(ThemeStuff.accTextIsEnabled) {
			accTxt.text = replaceStageVarsInTheme(ThemeStuff.accTextText);
		}

		if(ThemeStuff.extraTextIsEnabled) {
			for(i in 0...ThemeStuff.extraTextLength) {
				if(botplayIsEnabled)
					LuaTexts["extraTxt" + i].text = replaceStageVarsInTheme(ThemeStuff.extraBotplayText[i]);
				else
					LuaTexts["extraTxt" + i].text = replaceStageVarsInTheme(ThemeStuff.extraText[i]);
				if(ThemeStuff.extraCenterX[i])
					LuaTexts["extraTxt" + i].screenCenter(X);
				if(ThemeStuff.extraCenterY[i])
					LuaTexts["extraTxt" + i].screenCenter(Y);
			}
		}
		
		if(ThemeStuff.missTextIsEnabled) {
			missTxt.text = replaceStageVarsInTheme(ThemeStuff.missTextText);
		}

		if(ThemeStuff.npsTextIsEnabled) {
			npsTxt.text = replaceStageVarsInTheme(ThemeStuff.npsTextText);
		}

		if(ThemeStuff.scoreTextIsEnabled) {
			scoreTxt.text = replaceStageVarsInTheme(ThemeStuff.scoreText);
			if(ThemeStuff.scoreTextCenter) {
				scoreTxt.screenCenter(X);
			}
		}

		botplaySine += 180 * elapsed;
		if(ThemeStuff.botplayTextIsEnabled == true) {
			if(!inCutscene)
				botplayTxt.visible = botplayIsEnabled;
			if(botplayIsEnabled && ThemeStuff.botplayFadeInAndOut && !inCutscene) {
				var alpher:Float = 1 - Math.sin(botplaySine / 180);
				botplayTxt.alpha = alpher;
			}
			if(ThemeStuff.botplayCenter == true)
				botplayTxt.screenCenter(X);
		}

		if(ThemeStuff.timeBarIsEnabled == true) {
			timeTxt.text = replaceStageVarsInTheme(ThemeStuff.timeBarText);
			if(ThemeStuff.timeBarCenter)
				timeTxt.screenCenter(X);
		}

		if(ThemeStuff.watermarkIsEnabled == true) {
			if(!botplayIsEnabled && !PracticeMode) {
				refunkedWatermark.text = replaceStageVarsInTheme(ThemeStuff.watermarkText);
			} else if(botplayIsEnabled && !PracticeMode && ThemeStuff.watermarkBotplayText != null) {
				refunkedWatermark.text = replaceStageVarsInTheme(ThemeStuff.watermarkBotplayText);
			} else if(PracticeMode && !botplayIsEnabled && ThemeStuff.watermarkPracticeText != null) {
				refunkedWatermark.text = replaceStageVarsInTheme(ThemeStuff.watermarkPracticeText);
			} else {
				if(ThemeStuff.watermarkPracticeBotplayText != null) {
					refunkedWatermark.text = replaceStageVarsInTheme(ThemeStuff.watermarkPracticeBotplayText);
				}
			}
		}

		cpuStrums.forEach(function(spr:FlxSprite) {
			if(spr.animation.finished) {
				spr.animation.play('static');
				spr.centerOffsets();
			}
		});

		// lolol misses and Stuff
		if(!botplayIsEnabled) {
			#if debug
				detailsStageText = "DEBUG BUILD: RFE " + Application.current.meta.get('version') + "; ";
				detailsStageText += "Acc: " + accuracyThing + "% | Misses: " + misses + " | Score: " + songScore;
			#else
				detailsStageText = "Acc: " + accuracyThing + "% | Misses: " + misses + " | Score: " + songScore;
			#end
		} else {
			playerStrums.forEach(function(spr:FlxSprite) {
				if(spr.animation.finished) {
					spr.animation.play('static');
					spr.centerOffsets();
				}
			});
			#if debug
				detailsStageText = "DEBUG BUILD: RFE " + Application.current.meta.get('version') + "; ";
				detailsStageText += "Listening to the music.";
			#else
				detailsStageText = "Listening to the music.";
			#end
		}

		#if desktop
		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if(!botplayIsEnabled && !PracticeMode) {
			if (isStoryMode)
			{
				detailsText = "Week " + storyWeek + ": " + songName + " " + storyDifficultyText + " (" + notesRating + ")";
			}
			else
			{
				detailsText = "Freeplay: " + songName + " " + storyDifficultyText + " (" + notesRating + ")";
			}
		} else if(botplayIsEnabled && !PracticeMode) {
			detailsText = "BOTPLAY: Watching " + songName + " on " + storyDifficultyText;
		} else if(!botplayIsEnabled && PracticeMode) {
			if (isStoryMode)
			{
				detailsText = "Week " + storyWeek + ": Practicing " + songName + " on " + storyDifficultyText + " (" + notesRating + ")";
			}
			else
			{
				detailsText = "Freeplay: Practicing " + songName + " on " + storyDifficultyText + " (" + notesRating + ")";
			}
		} else {
			detailsText = "Watching BOTPLAY practice " + songName + " on " + storyDifficultyText + " (for some reason)";
		}

		// String for when the game is paused
		detailsPausedText = "Paused | " + detailsText;

		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, detailsStageText, iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, detailsStageText, iconRPC);
			}
		}
		#end 

		if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			if (FlxG.random.bool(0.01))
			{
				// gitaroo man easter egg
				unloadLoadedAssets();
				unloadMBSassets();
				FlxG.switchState(new GitarooPause());
			}
			else {
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			}

			#if desktop
			DiscordClient.changePresence(detailsPausedText, detailsStageText, iconRPC);
			#end
		}

		if (FlxG.keys.justPressed.SEVEN)
		{
			inst.stop();
			vocals.stop();
			FlxG.switchState(new ChartingState());

			#if desktop
				DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
		}

		if(ThemeStuff.watermarkDoesScroll && ThemeStuff.watermarkIsEnabled && !inCutscene && stuffLoaded) {
			if(refunkedWatermark.x == ThemeStuff.watermarkX) {
				watermarkInPlace = true;
				if(watermarkTween != null)
					watermarkTween.cancel();
				new FlxTimer().start(5, function(tmr:FlxTimer)
				{
					watermarkInPlace = false;
					if(!paused) {
						if(refunkedWatermark.x < ThemeStuff.watermarkX + 1 && refunkedWatermark.x > ThemeStuff.watermarkX - 1)
							refunkedWatermark.x = refunkedWatermark.x - 1;
					}
				});
			}
			if(watermarkInPlace == false) {
				if(refunkedWatermark.x < (botplayIsEnabled ? (PracticeMode ? -1600 : -1200) : -600)) {
					refunkedWatermark.x = FlxG.width;
				} else {
					if(watermarkTween != null)
						watermarkTween.cancel();
					watermarkTween = FlxTween.tween(refunkedWatermark, {x: refunkedWatermark.x - 1}, (elapsed < 0.01 ? (elapsed / 2) / 10 : elapsed / 10));
				}
			}
		}

		if(ThemeStuff.timeBarTextHasBounceTween && ThemeStuff.timeBarIsEnabled) {
			if(timeTxtTween != null) 
				timeTxtTween.cancel();
			timeTxtTween = FlxTween.tween(timeTxt.scale, {x: 1, y: 1}, (elapsed < 0.01 ? ((elapsed < 0.005 ? elapsed * 3 : elapsed * 2)) * 9 : elapsed * 9), {
				onComplete: function(bruh:FlxTween) {
					timeTxtTween = null;
				}
			});
		}

		if(ThemeStuff.healthBarIsEnabled && ThemeStuff.healthBarShowP1) {
			if(iconP1Tween != null) {
				iconP1Tween.cancel();
			}
			iconP1Tween = FlxTween.tween(iconP1, {"scale.x": 1, "scale.y": 1}, (elapsed < 0.01 ? ((elapsed < 0.005 ? elapsed * 3 : elapsed * 2)) * 9 : elapsed * 9), {
				onComplete: function(twn:FlxTween) {
					iconP1Tween = null;
				}
			});
			iconP1.updateHitbox();
			iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) + (150 * iconP1.scale.x - iconP1.width) / 2 - 26;
			iconP1.y = healthBar.y - (iconP1.height / 2);
		}

		if(ThemeStuff.healthBarIsEnabled && ThemeStuff.healthBarShowP2) {
			if(iconP2Tween != null) {
				iconP2Tween.cancel();
			}
			iconP2Tween = FlxTween.tween(iconP2, {"scale.x": 1, "scale.y": 1}, (elapsed < 0.01 ? ((elapsed < 0.005 ? elapsed * 3 : elapsed * 2)) * 9 : elapsed * 9), {
				onComplete: function(twn:FlxTween) {
					iconP2Tween = null;
				}
			});
			iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width * iconP2.scale.x) / 2 - 52;
			iconP2.y = healthBar.y - (iconP2.height / 2);
		}

		if (health > 2)
			health = 2;
		if (health < 0 && PracticeMode)
			health = 0;
		if (songScore < 0)
			songScore = 0;

		if(ThemeStuff.healthBarIsEnabled) {
			switch(SONG.song.toLowerCase()) {
				case "tutorial":
					if (healthBar.percent > 80) {
						if(ThemeStuff.healthBarShowP1) {
							iconP1.animation.curAnim.curFrame = 2;
						}
						if(ThemeStuff.healthBarShowP2) {
							iconP2.animation.curAnim.curFrame = 2;
						}
					} else if(healthBar.percent < 20) {
						if(ThemeStuff.healthBarShowP1) {
							iconP1.animation.curAnim.curFrame = 1;
						}
						if(ThemeStuff.healthBarShowP2) {
							iconP2.animation.curAnim.curFrame = 1;
						}
					} else {
						if(ThemeStuff.healthBarShowP1) {
							iconP1.animation.curAnim.curFrame = 0;
							}
						if(ThemeStuff.healthBarShowP2) {	
							iconP2.animation.curAnim.curFrame = 0;
						}
					}
				default:
					if (healthBar.percent > 80) {
							if(ThemeStuff.healthBarShowP1) {
							iconP1.animation.curAnim.curFrame = 2;
						}
						if(ThemeStuff.healthBarShowP2) {
							iconP2.animation.curAnim.curFrame = 1;
							}
					} else if(healthBar.percent < 20) {
						if(ThemeStuff.healthBarShowP1) {
							iconP1.animation.curAnim.curFrame = 1;
						}
							if(ThemeStuff.healthBarShowP2) {
							iconP2.animation.curAnim.curFrame = 2;
						}
					} else {
						if(ThemeStuff.healthBarShowP1) {
							iconP1.animation.curAnim.curFrame = 0;
						}
						if(ThemeStuff.healthBarShowP2) {
							iconP2.animation.curAnim.curFrame = 0;
						}
					}
			}
		}

		if (inst.length < 1 && (SONG.needsVoices ? vocals.length < 1 : inst.length < 1) && !startingSong) {
			loadingSongAlphaScreen.visible = true;
			loadingSongText.screenCenter();
			loadingSongText.visible = true;
		} 
		if (inst.length > 0 && (SONG.needsVoices ? vocals.length > 0 : inst.length > 0) && !startingSong) {
			stuffLoaded = true;
			PSLoadedMap["inst"] = inst;
			PSLoadedMap["vocals"] = vocals;
			#if sys
				setLuaVar("instLength", inst.length);
				setLuaVar("vocalsLength", vocals.length);
			#end
		}

		if(stuffLoaded && !startedCountdown && !inCutscene) {
			loadingSongText.text = "Loaded! Have fun.";
			loadingSongText.screenCenter();
			new FlxTimer().start(0.5, function(tmr:FlxTimer)
			{
				remove(loadingSongAlphaScreen);
				remove(loadingSongText);
			}, 1);
			if(isStoryMode) {
				doDialogue(curStage);
			} else {
				if(Options.freeplayDialogue)
					doDialogue(curStage);
				else
					afterTextIntro();
			}
		}

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			Conductor.songPosition += FlxG.elapsed * 1000;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
				}

				songPercentage = (Conductor.songPosition / songLength);
			}
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null && camFollowSet == false)
		{
			if (camFollow.x != dad.getMidpoint().x + 150 && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);

				switch (curStage)
				{
					case 'limo':
						camFollow.y = dad.getMidpoint().y;
					case 'school' | 'schoolMad':
						camFollow.y = dad.getMidpoint().y - 430;
						camFollow.x = dad.getMidpoint().x - 100;
				}

				if(camFollowAdd.exists("opponentX") && camFollowAdd.exists("opponentY")) {
					camFollow.x += camFollowAdd.get("opponentX");
					camFollow.y += camFollowAdd.get("opponentY");
				}

				if(camFollowSetMap.exists("opponentX") && camFollowSetMap.exists("opponentY")) {
					camFollow.x = camFollowSetMap.get("opponentX");
					camFollow.y = camFollowSetMap.get("opponentY");
				}

				vocals.volume = 1;

				if (SONG.song.toLowerCase() == 'tutorial')
				{
					tweenCamIn();
				}
			}

			if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && camFollow.x != boyfriend.getMidpoint().x - 100)
			{
				camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);

				switch (curStage)
				{
					case 'limo':
						camFollow.x = boyfriend.getMidpoint().x - 300;
					case 'mall':
						camFollow.y = boyfriend.getMidpoint().y - 200;
					case 'school' | 'schoolMad' | 'schoolEvil':
						camFollow.x = boyfriend.getMidpoint().x - 260;
						camFollow.y = boyfriend.getMidpoint().y - 260;
				}

				if(camFollowAdd.exists("bfX") && camFollowAdd.exists("bfY")) {
					camFollow.x += camFollowAdd.get("bfX");
					camFollow.y += camFollowAdd.get("bfY");
				}

				if(camFollowSetMap.exists("bfX") && camFollowSetMap.exists("bfY")) {
					camFollow.x = camFollowSetMap.get("bfX");
					camFollow.y = camFollowSetMap.get("bfY");
				}

				if (SONG.song.toLowerCase() == 'tutorial')
				{
					FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
				}
			}
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, FlxMath.bound(1 - (elapsed * 3), 0, 1));
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, FlxMath.bound(1 - (elapsed * 3), 0, 1));
		}

		FlxG.watch.addQuick("elapsed", elapsed);
		FlxG.watch.addQuick("beatStuff", curBeat);
		FlxG.watch.addQuick("stepStuff", curStep);

		// RESET = Quick Game Over Screen
		if (controls.RESET && stuffLoaded && !inCutscene)
		{
			health = 0;
			trace("RESET = True");
		}

		if (controls.BACK && !stuffLoaded) {
			if(isStoryMode) {
				FlxG.switchState(new StoryMenuState());
			} else {
				FlxG.switchState(new FreeplayState());
			}
			FlxG.sound.music.stop();
			if(inst.length > 0)
				inst.stop();
			if(vocals.length > 0)
				vocals.stop();
			unloadLoadedAssets();
			unloadMBSassets();
		}

		if (controls.CHEAT)
		{
			health += 1;
			trace("User is cheating!");
		}

		if (health <= 0 && !PracticeMode)
		{
			boyfriend.stunned = true;
		
			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			FlxG.sound.music.stop();
			vocals.stop();
			inst.stop();
			unloadLoadedAssets();
			unloadMBSassets();
				
			openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			#if desktop
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("Game Over - " + detailsText, detailsStageText, iconRPC);
			#end
		}

		while(unspawnNotes[0] != null) {
			if(unspawnNotes[0].strumTime - Conductor.songPosition < 1800 / SONG.speed) {
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.shift();
				dunceCount++;

				PSLoadedMap.set("dunceNote" + index + dunceCount, dunceNote);
			} else {
				break;
			}
		}

		if (generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if((!daNote.mustPress && Options.middlescroll) || (!daNote.mustPress && !opponentNotesSeeable) || (daNote.mustPress && !playerNotesSeeable)) {
					daNote.active = true;
					daNote.visible = false;
				} else if (daNote.y > FlxG.height) {
					daNote.active = false;
					daNote.visible = false;
				} else {
					daNote.visible = true;
					daNote.active = true;
				}

				var cpuNote:FlxSprite = cpuStrums.members[daNote.noteData];
				var playerNote:FlxSprite = playerStrums.members[daNote.noteData];

				if(daNote.mustPress) {
					daNote.x = playerNote.x;
					if(!daNote.isSustainNote)
						daNote.angle = playerNote.angle;
					if(daNote.isSustainNote)
						daNote.x += (playerNote.width / 2) - (daNote.width / 2);
				} else if(!daNote.mustPress) {
					daNote.x = cpuNote.x;
					if(!daNote.isSustainNote)
						daNote.angle = cpuNote.angle;
					if(daNote.isSustainNote)
						daNote.x += (cpuNote.width / 2) - (daNote.width / 2);
				}

				if(Options.downscroll) {
					daNote.y = (daNote.mustPress ? playerNote.y : cpuNote.y) + 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(SONG.speed, 2);

					if (daNote.isSustainNote) {
						if (daNote.animation.curAnim.name.endsWith('end') && daNote.prevNote != null) {
							daNote.y += daNote.prevNote.height / 1.5;
						}

						if (daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= (daNote.mustPress ? playerNote.y : cpuNote.y) + Note.swagWidth / 2 && (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
						{
							var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
							swagRect.height = ((daNote.mustPress ? playerNote.y : cpuNote.y) + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
							swagRect.y = daNote.frameHeight - swagRect.height;
							daNote.clipRect = swagRect;
						}
					}
				} else {
					daNote.y = ((daNote.mustPress ? playerNote.y : cpuNote.y) - (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(SONG.speed, 2)));

					if (daNote.isSustainNote && daNote.y + daNote.offset.y <= (daNote.mustPress ? playerNote.y : cpuNote.y) + Note.swagWidth / 2 && (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
					{
						var swagRect = new FlxRect(0, (daNote.mustPress ? playerNote.y : cpuNote.y) + Note.swagWidth / 2 - daNote.y, daNote.width * 2, daNote.height * 2);
						swagRect.y /= daNote.scale.y;
						swagRect.height -= swagRect.y;
						daNote.clipRect = swagRect;
					}
				}

				if (!daNote.mustPress && daNote.wasGoodHit)
				{
					#if sys
						luaCallback("opponentNoteHit", []);
					#end
					
					if (SONG.song != 'Tutorial')
						camZooming = true;

					dad.holdTimer = 0;

					if (SONG.needsVoices)
						vocals.volume = 1;

					#if sys
					if(RFELuaMap.exists(daNote.noteType + ".lua")) {
						setLuaVar("goodNoteData", daNote.noteData);
						setLuaVar("isSustainNote", daNote.isSustainNote);
						RFELuaMap.get(daNote.noteType + ".lua").luaCallback("goodNoteHit", []);
						luaCallback("playerNoteHit", []);
					} else {
					#end
						var altAnim:String = "";

						if (SONG.notes[Math.floor(curStep / 16)] != null)
						{
							if (SONG.notes[Math.floor(curStep / 16)].altAnim)
								altAnim = '-alt';
						}

						switch (Math.abs(daNote.noteData))
						{
							case 0:
								ActorSprites[TargetActors["opponent"]].playAnim('singLEFT' + altAnim, true);
							case 1:
								ActorSprites[TargetActors["opponent"]].playAnim('singDOWN' + altAnim, true);
							case 2:
								ActorSprites[TargetActors["opponent"]].playAnim('singUP' + altAnim, true);
							case 3:
								ActorSprites[TargetActors["opponent"]].playAnim('singRIGHT' + altAnim, true);
						}
					#if sys
					// cry about it part 2
					}
					#end

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();

					cpuStrums.forEach(function(spr:FlxSprite) {
						pressArrow(spr, spr.ID, daNote);
						if (spr.animation.curAnim.name == 'confirm' && !uiStyle.startsWith('pixel'))
							{
								spr.centerOffsets();
								spr.offset.x -= 13;
								spr.offset.y -= 13;
							}
							else
								spr.centerOffsets();
					});
				}

				if ((Options.downscroll ? daNote.y > FlxG.height : daNote.y < 0 - daNote.height) && !botplayIsEnabled)
				{
					if (daNote.tooLate || !daNote.wasGoodHit)
					{
						#if sys
						if(RFELuaMap.exists(daNote.noteType + ".lua")) {
							setLuaVar("missNoteData", daNote.noteData);
							setLuaVar("isSustainNote", daNote.isSustainNote);
							RFELuaMap.get(daNote.noteType + ".lua").luaCallback("noteMiss", []);
						} else {
						#end
							health -= 0.0475;
							misses++;
							accNotesTotal++;
							vocals.volume = 0;
							combo = 0;
							switch(Math.abs(daNote.noteData)) {
								case 0:
									ActorSprites[TargetActors["boyfriend"]].playAnim('singLEFTmiss', true);
								case 1:
									ActorSprites[TargetActors["boyfriend"]].playAnim('singDOWNmiss', true);
								case 2:
									ActorSprites[TargetActors["boyfriend"]].playAnim('singUPmiss', true);
								case 3:
									ActorSprites[TargetActors["boyfriend"]].playAnim('singRIGHTmiss', true);
							}
							FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
						#if sys
						// don't cry about it
						}
						#end
					}
					if (daNote.wasGoodHit) {
						accNotesToDivide++;
						accNotesTotal++;
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				} else if(daNote.mustPress && botplayIsEnabled) {
					if(daNote.canBeHit) {
						if(daNote.isSustainNote)
							goodNoteHit(daNote);
						else if(daNote.strumTime <= inst.time)
							goodNoteHit(daNote);
					}
				}
			});
		}

		if (!inCutscene)
			keyStuff();

		#if debug
		if (FlxG.keys.justPressed.THREE)
			endSong();
		#end
	}

	function endSong():Void
	{
		endingSong = true;

		#if sys
			luaCallback("endSong", []);
		#end

		canPause = false;
		if(inst != null || vocals != null) {
			inst.volume = 0;
			vocals.volume = 0;
		}
		if (SONG.validScore)
		{
			#if !switch
				if(!botplayWasUsed)
					Highscore.saveScore(SONG.song, songScore, storyDifficultyText);
			#end
		}

		if (isStoryMode)
		{
			campaignScore += songScore;

			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0)
			{
				FlxG.sound.playMusic(Paths.music('freakyMenu'));

				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;
				unloadLoadedAssets();
				unloadMBSassets();
				#if sys
					stopLua();
				#end
				fixModStuff();

				FlxG.switchState(new StoryMenuState());

				StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

				if (SONG.validScore && !botplayWasUsed)
				{
					Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficultyText);
				}
				FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
				FlxG.save.flush();
			}
			else
			{
				var difficulty:String = "";

				if (storyDifficulty == 0)
					difficulty = '-easy';

				if (storyDifficulty == 2)
					difficulty = '-hard';

				trace('LOADING NEXT SONG');
				trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

				if (SONG.song.toLowerCase() == 'eggnog')
				{
					var blackStuff:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
						-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
					blackStuff.scrollFactor.set();
					add(blackStuff);
					camHUD.visible = false;

					FlxG.sound.play(Paths.sound('Lights_Shut_off'));
				}

				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				prevCamFollow = camFollow;

				PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
				FlxG.sound.music.stop();
				inst.stop();
				vocals.stop();
				unloadLoadedAssets();
				unloadMBSassets();
				#if sys
					stopLua();
				#end
				LoadingState.loadAndSwitchState(new PlayState());
			}
		}
		else
		{
			trace('WENT BACK TO FREEPLAY??');
			inst.stop();
			vocals.stop();
			unloadLoadedAssets();
			unloadMBSassets();
			fixModStuff();
			FlxG.switchState(new FreeplayState());
			#if sys
				stopLua();
			#end
		}
	}

	private function popUpScore(strumtime:Float):Void
	{
		var noteDiff:Float = Math.abs(strumtime - Conductor.songPosition);
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		var daRating:String = "sick";

		if (noteDiff > Conductor.safeZoneOffset * 0.8)
		{
			daRating = 'shit';
			score -= 50;
			awfuls++;
			accNotesToDivide++;
			accNotesTotal++;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.65)
		{
			daRating = 'bad';
			score = 100;
			bads++;
			accNotesToDivide++;
			accNotesTotal++;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.45)
		{
			daRating = 'good';
			score = 200;
			goods++;
			accNotesToDivide++;
			accNotesTotal++;
		}
		if(daRating == "sick") {
			accNotesToDivide++;
			accNotesTotal++;
			sicks++;
		}

		if(ThemeStuff.scoreTextHasBounceTween && ThemeStuff.scoreTextIsEnabled) {
			if(scoreTxtTween != null) {
				scoreTxtTween.cancel();
			}
			scoreTxt.scale.x = 1.1;
			scoreTxt.scale.y = 1.1;
			scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2, {
				onComplete: function(twn:FlxTween) {
					scoreTxtTween = null;
				}
			});
		}
		songScore += score;

		var pixelStuffPart1:String = "";
		var pixelStuffPart2:String = '';

		if (uiStyle.startsWith('pixel'))
		{
			pixelStuffPart1 = 'weeb/pixelUI/';
			pixelStuffPart2 = '-pixel';
		}
	
		if(comboCount < 11) {
			comboCount++;
			rating.loadGraphic(Paths.image(pixelStuffPart1 + daRating + pixelStuffPart2));
			rating.screenCenter();
			rating.x = coolText.x - 40;
			rating.y -= 60;
			rating.acceleration.y = 550;
			rating.velocity.y -= FlxG.random.int(140, 175);
			rating.velocity.x -= FlxG.random.int(0, 10);
			PSLoadedMap["rating" + ratingCount + daRating] = rating;

			var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelStuffPart1 + 'combo' + pixelStuffPart2));
			comboSpr.screenCenter();
			comboSpr.x = coolText.x;
			comboSpr.acceleration.y = 600;
			comboSpr.velocity.y -= 150;
			comboSpr.velocity.x += FlxG.random.int(1, 10);
			PSLoadedMap["comboSpr" + ratingCount + daRating] = comboSpr;
			ratingCount++;

			if(combo >= 10)
				add(comboSpr);
			add(rating);

			if (!uiStyle.startsWith('pixel'))
			{
				rating.setGraphicSize(Std.int(rating.width * 0.7));
				rating.antialiasing = true;
				comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
				comboSpr.antialiasing = true;
			}
			else
			{
				rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
				comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
			}

			comboSpr.updateHitbox();
			rating.updateHitbox();

			var seperatedScore:Array<Int> = [];

			if(combo >= 10000)
				seperatedScore.push(Math.floor(combo / 10000) % 10);
			if(combo >= 1000)
				seperatedScore.push(Math.floor(combo / 1000) % 10);
			seperatedScore.push(Math.floor(combo / 100) % 10);
			seperatedScore.push(Math.floor(combo / 10) % 10);
			seperatedScore.push(combo % 10);

			var daLoop:Int = 0;
			for (i in seperatedScore)
			{
				var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelStuffPart1 + 'num' + Std.int(i) + pixelStuffPart2));
				numScore.screenCenter();
				numScore.x = coolText.x + (43 * daLoop) - 90;
				numScore.y += 80;
				PSLoadedMap["numScore" + numCount + i] = numScore;
				numCount++;

				if (!uiStyle.startsWith('pixel'))
				{
					numScore.antialiasing = true;
					numScore.setGraphicSize(Std.int(numScore.width * 0.5));
				}
				else
				{
					numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
				}
				numScore.updateHitbox();

				numScore.acceleration.y = FlxG.random.int(200, 300);
				numScore.velocity.y -= FlxG.random.int(140, 160);
				numScore.velocity.x = FlxG.random.float(-5, 5);

				if (combo >= 10 || combo == 0)
					add(numScore);

				FlxTween.tween(numScore, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						numScore.destroy();
					},
					startDelay: Conductor.crochet * 0.002
				});

				daLoop++;
			}

			coolText.text = Std.string(seperatedScore);

			FlxTween.tween(rating, {alpha: 0}, 0.2, {
				startDelay: Conductor.crochet * 0.001
			});

			FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					coolText.destroy();
					comboSpr.destroy();
					rating.destroy();
				},
				startDelay: Conductor.crochet * 0.001
			});

			new FlxTimer().start(1 - (SONG.speed / 10), function(timer:FlxTimer) {
				if(comboCount > 0)
					comboCount--;
			});
		}

		curSection += 1;
	}

	private function keyStuff():Void
	{
		var up = controls.UP;
		var right = controls.RIGHT;
		var down = controls.DOWN;
		var left = controls.LEFT;

		var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;

		var upR = controls.UP_R;
		var rightR = controls.RIGHT_R;
		var downR = controls.DOWN_R;
		var leftR = controls.LEFT_R;

		var controlArray:Array<Bool> = [leftP, downP, upP, rightP];

		if ((upP || rightP || downP || leftP) && !boyfriend.stunned && generatedMusic && !botplayIsEnabled)
		{
			boyfriend.holdTimer = 0;

			var possibleNotes:Array<Note> = [];

			var ignoreList:Array<Int> = [];

			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
				{
					// the sorting probably doesn't need to be in here? who cares lol
					possibleNotes.push(daNote);
					possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

					ignoreList.push(daNote.noteData);
				}
			});

			if (possibleNotes.length > 0)
			{
				var daNote = possibleNotes[0];

				if (perfectMode)
					noteCheck(true, daNote);

				// Jump notes
				if (possibleNotes.length >= 2)
				{
					if (possibleNotes[0].strumTime == possibleNotes[1].strumTime)
					{
						for (coolNote in possibleNotes)
						{
							if (controlArray[coolNote.noteData])
								goodNoteHit(coolNote);
							else
							{
								var inIgnoreList:Bool = false;
								for (stuff in 0...ignoreList.length)
								{
									if (controlArray[ignoreList[stuff]])
										inIgnoreList = true;
								}
								if (!inIgnoreList)
									badNoteCheck();
							}
						}
					}
					else if (possibleNotes[0].noteData == possibleNotes[1].noteData)
					{
						noteCheck(controlArray[daNote.noteData], daNote);
					}
					else
					{
						for (coolNote in possibleNotes)
						{
							noteCheck(controlArray[coolNote.noteData], coolNote);
						}
					}
				}
				else // regular notes?
				{
					noteCheck(controlArray[daNote.noteData], daNote);
				}
			}
			else
			{
				badNoteCheck();
			}
		}

		if ((up || right || down || left) && !boyfriend.stunned && generatedMusic && !botplayIsEnabled)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && daNote.isSustainNote)
				{
					switch (daNote.noteData)
					{
						// NOTES YOU ARE HOLDING
						case 0:
							if (left)
								goodNoteHit(daNote);
						case 1:
							if (down)
								goodNoteHit(daNote);
						case 2:
							if (up)
								goodNoteHit(daNote);
						case 3:
							if (right)
								goodNoteHit(daNote);
					}
				}
			});
		}

		if(left || down || up || right)
			controlling = true;
		else
			controlling = false;

		if (ActorSprites[TargetActors["boyfriend"]].holdTimer > Conductor.stepCrochet * 4 * 0.001 && !controlling)
		{
			if (ActorSprites[TargetActors["boyfriend"]].animation.curAnim.name.startsWith('sing') && !ActorSprites[TargetActors["boyfriend"]].animation.curAnim.name.endsWith('miss'))
			{
				ActorSprites[TargetActors["boyfriend"]].playAnim('idle');
			}
		}

		if(!botplayIsEnabled) {
			playerStrums.forEach(function(spr:FlxSprite)
			{
				switch (spr.ID)
				{
					case 0:
						if (leftP && spr.animation.curAnim.name != 'confirm')
							spr.animation.play('pressed');
						if (leftR)
							spr.animation.play('static');
					case 1:
						if (downP && spr.animation.curAnim.name != 'confirm')
							spr.animation.play('pressed');
						if (downR)
							spr.animation.play('static');
					case 2:
						if (upP && spr.animation.curAnim.name != 'confirm')
							spr.animation.play('pressed');
						if (upR)
							spr.animation.play('static');
					case 3:
						if (rightP && spr.animation.curAnim.name != 'confirm')
							spr.animation.play('pressed');
						if (rightR)
							spr.animation.play('static');
				}	

				if (spr.animation.curAnim.name == 'confirm' && !uiStyle.startsWith('pixel'))
				{
					spr.centerOffsets();
					spr.offset.x -= 13;
					spr.offset.y -= 13;
				}
				else
					spr.centerOffsets();
			});
		}
	}

	function pressArrow(spr:FlxSprite, idCheck:Int, daNote:Note)
	{
		if (Math.abs(daNote.noteData) == idCheck)
		{
			spr.animation.play('confirm');
		}
	}

	function noteMiss(direction:Int = 1):Void
	{
		if (!boyfriend.stunned && !botplayIsEnabled)
		{
			health -= 0.04;
			songScore -= 10;
			if (combo > 5 && gf.animOffsets.exists('sad'))
				ActorSprites[TargetActors["girlfriend"]].playAnim('sad');
			if(Options.noNoteMisses) {
				combo = 0;
				misses++;
				accNotesTotal++;
			}
			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			boyfriend.stunned = true;

			// get stunned for 5 seconds
			new FlxTimer().start(5 / 60, function(tmr:FlxTimer)
			{
				boyfriend.stunned = false;
			});

			switch (direction)
			{
				case 0:
					ActorSprites[TargetActors["boyfriend"]].playAnim('singLEFTmiss', true);
				case 1:
					ActorSprites[TargetActors["boyfriend"]].playAnim('singDOWNmiss', true);
				case 2:
					ActorSprites[TargetActors["boyfriend"]].playAnim('singUPmiss', true);
				case 3:
					ActorSprites[TargetActors["boyfriend"]].playAnim('singRIGHTmiss', true);
			}
		}
	}

	function badNoteCheck()
	{
		// DON'T REDO THIS SYSTEM! lol
		var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;

		if(!botplayIsEnabled) {
			if (leftP)
				noteMiss(0);
			if (downP)
				noteMiss(1);
			if (upP)
				noteMiss(2);
			if (rightP)
				noteMiss(3);
		}
	}

	function noteCheck(keyP:Bool, note:Note):Void
	{
		if (keyP && !botplayIsEnabled)
			goodNoteHit(note);
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			#if sys
			if(RFELuaMap.exists(note.noteType + ".lua")) {
				setLuaVar("goodNoteData", note.noteData);
				setLuaVar("isSustainNote", note.isSustainNote);
				RFELuaMap.get(note.noteType + ".lua").luaCallback("goodNoteHit", []);
				luaCallback("playerNoteHit", []);
			} else {
					luaCallback("playerNoteHit", []);
			#end

				if (note.noteData >= 0)
					health += 0.023;
				else
					health += 0.004;

				switch (note.noteData)
				{
					case 0:
						ActorSprites[TargetActors["boyfriend"]].playAnim('singLEFT', true);
					case 1:
						ActorSprites[TargetActors["boyfriend"]].playAnim('singDOWN', true);
					case 2:
						ActorSprites[TargetActors["boyfriend"]].playAnim('singUP', true);
					case 3:
						ActorSprites[TargetActors["boyfriend"]].playAnim('singRIGHT', true);
				}
			#if sys
			// cry about it
			}
			#end

			if (!note.isSustainNote) {
				if(!botplayIsEnabled)
					popUpScore(note.strumTime);
				else
					popUpScore(Conductor.songPosition);
				combo += 1;
				if(combo > 99999)
					combo = 99999;
				if(combo > maxCombo)
					maxCombo = combo;
			}

			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (Math.abs(note.noteData) == spr.ID)
				{
					spr.animation.play('confirm', true);
					if (spr.animation.curAnim.name == 'confirm' && !uiStyle.startsWith('pixel'))
					{
						spr.centerOffsets();
						spr.offset.x -= 13;
						spr.offset.y -= 13;
					}
					else
						spr.centerOffsets();
				}
			});

			note.wasGoodHit = true;
			vocals.volume = 1;
			
			if(botplayIsEnabled) {
				boyfriend.holdTimer = 0;
				if(note.isSustainNote) {
					accNotesToDivide++;
					accNotesTotal++;
				}
			}

			if (!note.isSustainNote)
			{
				hitArrayThing.unshift(Date.now());
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	function fastCarDrive()
	{
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
		});
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			ActorSprites[TargetActors["girlfriend"]].playAnim('hairBlow');
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void
	{
		ActorSprites[TargetActors["girlfriend"]].playAnim('hairFall');
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function lightningStrikeStuff():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		halloweenBG.animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		ActorSprites[TargetActors["boyfriend"]].playAnim('scared');
		ActorSprites[TargetActors["girlfriend"]].playAnim('scared');
	}

	override function stepHit()
	{
		super.stepHit();

		if (inst.time > Conductor.songPosition + 20 || inst.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}

		#if sys
			luaCallback("stepHit", []);
		#end
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	override function beatHit()
	{
		super.beatHit();

		if(beatHitCounter > (curBeat - 1)) {
			return;
		} else {
			if (generatedMusic)
			{
				notes.sort(FlxSort.byY, (Options.downscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING));
			}

			if (SONG.notes[Math.floor(curStep / 16)] != null)
			{
				if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
				{
					Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
					#if sys
						setLuaVar('crochet', Conductor.crochet);
						setLuaVar('curBPM', Conductor.bpm);
						setLuaVar('stepCrochet', Conductor.stepCrochet);
					#end
					FlxG.log.add('CHANGED BPM!');
				}
			}
			wiggleStuff.update(Conductor.crochet);

			if (curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < minCamGameZoom)
			{
				FlxG.camera.zoom += camGameZoom;
				camHUD.zoom += camHUDZoom;
			}
			if (curSong.toLowerCase() == 'mombattle' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < minCamGameZoom)
			{
				FlxG.camera.zoom += camGameZoom;
				camHUD.zoom += camHUDZoom;
			}

			if (camZooming && FlxG.camera.zoom < minCamGameZoom && curBeat % 4 == 0)
			{
				FlxG.camera.zoom += camGameZoom;
				camHUD.zoom += camHUDZoom;
			}

			if(ThemeStuff.timeBarTextHasBounceTween && ThemeStuff.timeBarIsEnabled) {
				timeTxt.scale.set(1.2, 1.2);
			}

			if(ThemeStuff.healthBarShowP1 && ThemeStuff.healthBarIsEnabled) {
				iconP1.scale.set(1.2, 1.2);
				iconP1.updateHitbox();
			}
			if(ThemeStuff.healthBarShowP2 && ThemeStuff.healthBarIsEnabled) {
				iconP2.scale.set(1.2, 1.2);
				iconP2.updateHitbox();
			}

			if (curBeat % 1 == 0) {
				for(actor in ActorSprites) {
					if(actor != null && actor.animation.curAnim != null) {
						if(!actor.animation.curAnim.name.startsWith("sing") && actor.IdleDancing)
							actor.dance();
					}
				}
			}
			if (curBeat % 2 == 0) {
				for(actor in ActorSprites) {
					if(actor != null && actor.animation.curAnim != null) {
						if(!actor.animation.curAnim.name.startsWith("sing") && actor.animation.curAnim.finished && !actor.IdleDancing)
							actor.dance();
					}
				}
			}

			if (curBeat % 8 == 7 && curSong == 'Bopeebo')
			{
				ActorSprites[TargetActors["boyfriend"]].playAnim('hey');
			}

			if (curBeat % 16 == 15 && SONG.song == 'Tutorial' && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
			{
				ActorSprites[TargetActors["boyfriend"]].playAnim('hey');
				ActorSprites[TargetActors["opponent"]].playAnim('cheer');
			}

			switch (curStage)
			{
				case 'limo':
					if(grpLimoDancers != null) {
						grpLimoDancers.forEach(function(dancer:BackgroundDancer)
						{
							dancer.dance();
						});
					}

					if (FlxG.random.bool(10) && fastCarCanDrive)
						fastCarDrive();
				case 'mall':
					if(upperBoppers != null && bottomBoppers != null && santa != null) {
						upperBoppers.animation.play('bop', true);
						bottomBoppers.animation.play('bop', true);
						santa.animation.play('idle', true);
					}
				case "philly":
					if (!trainMoving)
						trainCooldown += 1;

					if (curBeat % 4 == 0)
					{
						phillyCityLights.forEach(function(light:FlxSprite)
						{
							light.visible = false;
						});
				
						curLight = FlxG.random.int(0, phillyCityLights.length - 1);
						phillyCityLights.members[curLight].visible = true;
					}

					if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
					{
						trainCooldown = FlxG.random.int(-4, 0);
						trainStart();
					}
				case 'school' | 'schoolMad':
					if(bgGirls != null)
						bgGirls.dance();
			}

			if (isHalloween && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
			{
				lightningStrikeStuff();
			}

			#if sys
				luaCallback("beatHit", []);
			#end
		}

		beatHitCounter = curBeat;
	}

	var curLight:Int = 0;

	override function add(Object:flixel.FlxBasic):flixel.FlxBasic
	{
		PSLoadedAssets.insert(PSLoadedAssets.length, Object);
		return super.add(Object);
	}

	public function unloadLoadedAssets():Void
	{
		for (asset in PSLoadedAssets)
		{
			remove(asset);
		}
	}

	public static function nullPSLoadedAssets():Void
	{
		if(ActorSprites != null) {
			for(actor in ActorSprites) {
				actor.destroy();
			}
		}
		ActorSprites = null;
		if(PSLoadedMap != null) {
			for(sprite in PSLoadedMap) {
				sprite.destroy();
			}
		}
		PSLoadedMap = null;
	}

	public function destroyLuaObjects():Void
	{
		if(LuaSprites != null) {
			for(sprite in LuaSprites) {
				sprite.destroy();
			}
		}
		LuaSprites = null;
		if(LuaTexts != null) {
			for(sprite in LuaTexts) {
				sprite.destroy();
			}
		}
		LuaTexts = null;
		if(LuaTweens != null) {
			for(sprite in LuaTweens) {
				sprite.destroy();
			}
		}
		LuaTweens = null;
		if(LuaBackgroundGirls != null) {
			for(sprite in LuaBackgroundGirls) {
				sprite.destroy();
			}
		}
		LuaBackgroundGirls = null;
	}

	function setUpLua() {
		ActorSprites = new Map<String, Character>();
		BoyfriendPositionAdd = null;
		BoyfriendPositionAdd = [0, 0];
		camFollowAdd = null;
		camFollowAdd = new Map<String, Float>();
		camFollowSet = false;
		camFollowSetMap = null;
		camFollowSetMap = new Map<String, Float>();
		camPosSet = null; 
		camPosSet = new Map<String, Float>();
		GirlfriendPositionAdd = null;
		GirlfriendPositionAdd = [0, 0];
		LuaBackgroundGirls = new Map<String, BackgroundGirls>();
		LuaSprites = new Map<String, FlxSprite>();
		LuaTexts = new Map<String, FlxText>();
		LuaTweens = new Map<String, FlxTween>();
		opponentNotesSeeable = true;
		OpponentPositionAdd = null;
		OpponentPositionAdd = [0, 0];
		playerNotesSeeable = true;
		RFELuaMap = null;
		RFELuaMap = new Map<String, ReFunkedLua>();
		TargetActors = null;
		TargetActors = new Map<String, String>();
	}

	public function disableEasterEggs(isPlayer:Bool = false):Void {
		// used for icon changing (/ character changing)
		if(isPlayer) {
			// bf
			bfEasterEggEnabled = false;
			oldbfIcon.visible = false;
			// dev
			devEasterEggEnabled = false;
			pahazeIcon.visible = false;
			duoDevEasterEggEnabled = false;
			pahazeRedwickIcon.visible = false;
			// norm
			OGIconP1.visible = true;
		} else {
			// dad
			dadEasterEggEnabled = false;
			dadIcon.visible = false;
			// norm
			OGIconP2.visible = true;
		}
	}

	public function changeIcon(newChar:String, isPlayer:Bool = false):Void {
		if(isPlayer == true) {
			OGIconP1.changeIcon(newChar, isPlayer);
			iconP1 = OGIconP1;
		} else {
			OGIconP2.changeIcon(newChar, isPlayer);
			iconP2 = OGIconP2;
		}
		disableEasterEggs(isPlayer);
	}

	public function destoryBoyfriendLol():Void {
		dad.destroy();
		boyfriend.destroy();
		gf.destroy();
	}

	public function killLuaBruh():Void {
		#if sys
			stopLua();
		#end
	}

	public function fixModStuff():Void {
		mod = "";
		isModSong = false;
	}

	public function setLuaVar(variable:String, value:Dynamic) {
		for(lua in RFELuaMap) {
			lua.setVar(variable, value);
		}
	}

	public function luaCallback(eventToCheck:String, arguments:Array<Dynamic>) {
		for(lua in RFELuaMap) {
			lua.luaCallback(eventToCheck, arguments);
		}
	}

	public function stopLua() {
		for(lua in RFELuaMap) {
			lua.stopLua();
		}
	}

	function replaceStageVarsInTheme(strung:String) {
		var uh:String = strung;
		if(uh != null) {
			uh = StringTools.replace(uh, "[accuracy]", Std.string(accuracyThing));
			uh = StringTools.replace(uh, "[awfuls]", Std.string(awfuls));
			uh = StringTools.replace(uh, "[bads]", Std.string(bads));
			uh = StringTools.replace(uh, "[combo]", Std.string(combo));
			uh = StringTools.replace(uh, "[difficulty]", storyDifficultyText);
			uh = StringTools.replace(uh, "[funnyrating]", funnyRating);
			uh = StringTools.replace(uh, "[goods]", Std.string(goods));
			uh = StringTools.replace(uh, "[height]", Std.string(FlxG.height));
			uh = StringTools.replace(uh, "[maxcombo]", Std.string(maxCombo));
			uh = StringTools.replace(uh, "[maxnps]", Std.string(funnyMaxNPS));
			uh = StringTools.replace(uh, "[min]", m);
			uh = StringTools.replace(uh, "[misses]", Std.string(misses));
			uh = StringTools.replace(uh, "[noterating]", notesRating);
			uh = StringTools.replace(uh, "[nps]", Std.string(funnyNPS));
			uh = StringTools.replace(uh, "[randomdev]", randomDevs[devSelector]);
			uh = StringTools.replace(uh, "[score]", Std.string(songScore));
			uh = StringTools.replace(uh, "[sec]", s);
			uh = StringTools.replace(uh, "[sicks]", Std.string(sicks));
			uh = StringTools.replace(uh, "[song]", songName);
   	     	uh = StringTools.replace(uh, "[width]", Std.string(FlxG.width));
		}

        return uh;
	}

	function loadDevs() {
		var rawJsonFile:String;
        var pathToFileIg:String;

        #if sys
            pathToFileIg = "assets/data/devs.json";
			rawJsonFile = File.getContent(pathToFileIg);

            while (!rawJsonFile.endsWith("}"))
	    	{
	    		rawJsonFile = rawJsonFile.substr(0, rawJsonFile.length - 1);
	    	}

            var json:Developers = cast Json.parse(rawJsonFile);
    	#else
			rawJsonFile = Utilities.getFileContents("./assets/data/devs.json");
            rawJsonFile = rawJsonFile.trim();
        
            while (!rawJsonFile.endsWith("}"))
	    	{
	    		rawJsonFile = rawJsonFile.substr(0, rawJsonFile.length - 1);
	    	}

            trace(rawJsonFile);

            var json:Developers = cast Json.parse(rawJsonFile);
		#end

		randomDevs = json.devs;
	}
}
