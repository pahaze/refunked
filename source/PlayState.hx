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
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
import themes.ThemeSupport;

using StringTools;

typedef Developers = {
	var devs:Array<String>;
}

class PlayState extends MusicBeatState {
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
	public static var camFollowPoint:FlxPoint;
	public static var camFollowSet:Bool = false;
	private static var prevCamFollow:FlxObject;
	private static var prevCamFollowPoint:FlxPoint;

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
	var scoreTxt:ThemeText;

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
	var accTxt:ThemeText;
	var accuracyThing:Float = 0;
	var botplaySine:Float = 0;
	var botplayTxt:ThemeText;
	public static var bubbyheight:Float;
	public static var bubbywidth:Float;
	var funnyMaxNPS:Int = 0;
	var funnyNPS:Int = 0;
	var gameMode:Int;
	var hitArrayThing:Array<Date> = [];
	var m:String;
	var missTxt:ThemeText;
	var npsTxt:ThemeText;
	var s:String;
	var scrollVersion:Int;
	var songLength:Float = 0;
	var songPercentage:Float = 0;
	var themeBounceTweens:Map<ThemeText, FlxTween> = new Map<ThemeText, FlxTween>();
	var themeScrollTweens:Map<ThemeText, FlxTween> = new Map<ThemeText, FlxTween>();
	public var timeBar:FlxBar;
	private var timeBarBG:FlxSprite;
	var timeTxt:ThemeText;
	public static var UITexts:Array<ThemeText> = [];
	public static var UIElements:Map<String, Dynamic> = new Map<String, Dynamic>();
	
	// Tweens
	var iconP1Tween:FlxTween;
	var iconP2Tween:FlxTween;

	// Watermark
	var refunkedWatermark:ThemeText;

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
	public static var dadEasterEggEnabled:Bool = false;
	public static var devEasterEggEnabled:Bool = false;
	var devSelector:Int;
	public static var duoDevEasterEggEnabled:Bool = false;
	public static var randomDevs:Array<String> = [];

	// Memory related stuff
	var comboCount:Int = 0;
	var loadingSongAlphaScreen:FlxSprite;
	var loadingSongText:FlxText;
	private var PSLoadedAssets:Array<FlxBasic> = [];
	static var PSLoadedMap:Map<String, Dynamic> = new Map<String, Dynamic>();
	var stuffLoaded:Bool = false;

	// Mods!
	public static var isModSong:Bool = false;
	public static var mod:String = "";

	// Modes
	public static var botplayIsEnabled:Bool = false;
	var botplayWasUsed:Bool = false;
	public static var PracticeMode:Bool = false;
	var practiceWasUsed:Bool = false;

	// Actual song name
	public static var songName:String;

	// UI
	var intro3:FlxSound;
	var intro2:FlxSound;
	var intro1:FlxSound;
	var introGo:FlxSound;
	static var prevUIStyle:String;
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
	public static var RFELuaArray:Array<ReFunkedLua> = [];
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
		unloadMBSassets();
		PSLoadedMap = new Map<String, Dynamic>();
		PlayStateThing = this;

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		FlxG.fixedTimestep = false;

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// Lets set up some Lua stuff
		setUpLua();

		// Prepares song name since it's static
		songName = "";

		// Theme stuff...
		setUpThemeSupport();

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

		if(prevUIStyle != null) {
			if(prevUIStyle != uiStyle) {
				UIStyleSupport.loadUIStyle(uiStyle);
				prevUIStyle = uiStyle;
			} else
				prevUIStyle = uiStyle;
		} else if(prevUIStyle == null) {
			UIStyleSupport.loadUIStyle(uiStyle);
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
								RFELuaArray.push(new ReFunkedLua(Paths.modStage(mod, SONG.stage)));
								luaFiles++;
							}
						} else {
							if(Utilities.checkFileExists(Paths.stage(SONG.stage))) {
								RFELuaArray.push(new ReFunkedLua(Paths.stage(SONG.stage)));
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
		camFollowPoint = new FlxPoint();

		setCameraPosition(camPos.x, camPos.y, true);

		if (prevCamFollow != null) {
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		if(prevCamFollowPoint != null) {
			camFollowPoint = prevCamFollowPoint;
			prevCamFollowPoint = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollowPoint);

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		bubbywidth = FlxG.width;
		bubbyheight = FlxG.height;
		devSelector = Std.random(randomDevs.length);
		// Tells what items to use in arrays...
		scrollVersion = (Options.middlescroll ? (Options.downscroll ? 3 : 2) : (Options.downscroll ? 1 : 0));
		gameMode = (PracticeMode ? (botplayIsEnabled ? 3 : 2) : (botplayIsEnabled ? 1 : 0));
		ThemeSupport.loadTheme(Options.themeData);

		if(ThemeSupport.TimebarEnabled) {
			switch(ThemeSupport.Timebar.style.toLowerCase()) {
				case "kadeold":
					timeBarBG = new FlxSprite(ThemeSupport.Timebar.x[scrollVersion], ThemeSupport.Timebar.y[scrollVersion]).loadGraphic(#if desktop BitmapData.fromFile(ThemeSupport.WorkingDirectory + "images/" + ThemeSupport.Timebar.image + ".png") #else Paths.image(ThemeSupport.Timebar.image) #end);
					if(ThemeSupport.Timebar.center[0])
						timeBarBG.screenCenter(X);
					if(ThemeSupport.Timebar.center[1])
						timeBarBG.screenCenter(Y);
					timeBarBG.scrollFactor.set();
					if(ThemeSupport.Timebar.textOnly)
						timeBarBG.visible = false;
					add(timeBarBG);

					timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this, 'songPercentage', 0, 1);
					timeBar.scrollFactor.set();
					timeBar.createFilledBar(FlxColor.fromString(ThemeSupport.Timebar.colors[0]), FlxColor.fromString(ThemeSupport.Timebar.colors[1]));
					timeBar.numDivisions = 800;
					if(ThemeSupport.Timebar.textOnly)
						timeBar.visible = false;
					add(timeBar);

					timeTxt = new ThemeText(0, timeBarBG.y, 0, "", 16);
					timeTxt.setFormat(ThemeSupport.Timebar.text.customization.font, ThemeSupport.Timebar.text.customization.fontsize, FlxColor.fromString(ThemeSupport.Timebar.text.customization.color), Utilities.getTextAlignment(ThemeSupport.Timebar.text.customization.alignment), Utilities.getBorderStyle(ThemeSupport.Timebar.text.customization.border.style), FlxColor.fromString(ThemeSupport.Timebar.text.customization.border.color));
					timeTxt.borderSize = ThemeSupport.Timebar.text.customization.border.size;
					timeTxt.scrollFactor.set();
					add(timeTxt);
				case "leather":
					timeBarBG = new FlxSprite(ThemeSupport.Timebar.x[scrollVersion], ThemeSupport.Timebar.y[scrollVersion]).loadGraphic(#if desktop BitmapData.fromFile(ThemeSupport.WorkingDirectory + "images/" + ThemeSupport.Timebar.image + ".png") #else Paths.image(ThemeSupport.Timebar.image) #end);
					if(ThemeSupport.Timebar.center[0])
						timeBarBG.screenCenter(X);
					if(ThemeSupport.Timebar.center[1])
						timeBarBG.screenCenter(Y);
					timeBarBG.scrollFactor.set();
					timeBarBG.pixelPerfectPosition = true;
					if(ThemeSupport.Timebar.textOnly)
						timeBarBG.visible = false;
					add(timeBarBG);

					timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this, 'songPercentage', 0, 1);
					timeBar.scrollFactor.set();
					timeBar.createFilledBar(FlxColor.fromString(ThemeSupport.Timebar.colors[0]), FlxColor.fromString(ThemeSupport.Timebar.colors[1]));
					timeBar.pixelPerfectPosition = true;
					timeBar.numDivisions = 800;
					if(ThemeSupport.Timebar.textOnly)
						timeBar.visible = false;
					add(timeBar);

					timeTxt = new ThemeText(0, (Options.downscroll ? timeBarBG.y - timeBarBG.height - 1 : timeBarBG.y + timeBarBG.height + 1), 0, "", 16);
					timeTxt.setFormat(ThemeSupport.Timebar.text.customization.font, ThemeSupport.Timebar.text.customization.fontsize, FlxColor.fromString(ThemeSupport.Timebar.text.customization.color), Utilities.getTextAlignment(ThemeSupport.Timebar.text.customization.alignment), Utilities.getBorderStyle(ThemeSupport.Timebar.text.customization.border.style), FlxColor.fromString(ThemeSupport.Timebar.text.customization.border.color));
					timeTxt.borderSize = ThemeSupport.Timebar.text.customization.border.size;
					timeTxt.scrollFactor.set();
					add(timeTxt);
				case "psych":
					timeTxt = new ThemeText(ThemeSupport.Timebar.x[scrollVersion], ThemeSupport.Timebar.y[scrollVersion], 0, "", 32);
					timeTxt.setFormat(ThemeSupport.Timebar.text.customization.font, ThemeSupport.Timebar.text.customization.fontsize, FlxColor.fromString(ThemeSupport.Timebar.text.customization.color), Utilities.getTextAlignment(ThemeSupport.Timebar.text.customization.alignment), Utilities.getBorderStyle(ThemeSupport.Timebar.text.customization.border.style), FlxColor.fromString(ThemeSupport.Timebar.text.customization.border.color));
					timeTxt.borderSize = ThemeSupport.Timebar.text.customization.border.size;
					timeTxt.scrollFactor.set();

					timeBarBG = new FlxSprite(timeTxt.x, timeTxt.y + (timeTxt.height / 4)).loadGraphic(#if desktop BitmapData.fromFile(ThemeSupport.WorkingDirectory + "images/" + ThemeSupport.Timebar.image + ".png") #else Paths.image(ThemeSupport.Timebar.image) #end);
					if(ThemeSupport.Timebar.center[0])
						timeBarBG.screenCenter(X);
					if(ThemeSupport.Timebar.center[1])
						timeBarBG.screenCenter(Y);
					timeBarBG.scrollFactor.set();
					if(ThemeSupport.Timebar.textOnly)
						timeBarBG.visible = false;
					add(timeBarBG);

					timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this, 'songPercentage', 0, 1);
					timeBar.scrollFactor.set();
					timeBar.createFilledBar(FlxColor.fromString(ThemeSupport.Timebar.colors[0]), FlxColor.fromString(ThemeSupport.Timebar.colors[1]));
					timeBar.numDivisions = 800;
					if(ThemeSupport.Timebar.textOnly)
						timeBar.visible = false;
					add(timeBar);
					add(timeTxt);
				default:
					timeTxt = new ThemeText(ThemeSupport.Timebar.x[scrollVersion], ThemeSupport.Timebar.y[scrollVersion], 0, "", 32);
					timeTxt.setFormat(ThemeSupport.Timebar.text.customization.font, ThemeSupport.Timebar.text.customization.fontsize, FlxColor.fromString(ThemeSupport.Timebar.text.customization.color), Utilities.getTextAlignment(ThemeSupport.Timebar.text.customization.alignment), Utilities.getBorderStyle(ThemeSupport.Timebar.text.customization.border.style), FlxColor.fromString(ThemeSupport.Timebar.text.customization.border.color));
					timeTxt.borderSize = ThemeSupport.Timebar.text.customization.border.size;
					timeTxt.scrollFactor.set();

					timeBarBG = new FlxSprite(timeTxt.x, timeTxt.y + (timeTxt.height / 4)).loadGraphic(#if desktop BitmapData.fromFile(ThemeSupport.WorkingDirectory + "images/" + ThemeSupport.Timebar.image + ".png") #else Paths.image(ThemeSupport.Timebar.image) #end);
					if(ThemeSupport.Timebar.center[0])
						timeBarBG.screenCenter(X);
					if(ThemeSupport.Timebar.center[1])
						timeBarBG.screenCenter(Y);
					timeBarBG.scrollFactor.set();
					if(ThemeSupport.Timebar.textOnly)
						timeBarBG.visible = false;
					add(timeBarBG);

					timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this, 'songPercentage', 0, 1);
					timeBar.scrollFactor.set();
					timeBar.createFilledBar(FlxColor.fromString(ThemeSupport.Timebar.colors[0]), FlxColor.fromString(ThemeSupport.Timebar.colors[1]));
					timeBar.numDivisions = 800;
					if(ThemeSupport.Timebar.textOnly)
						timeBar.visible = false;
					add(timeBar);
					add(timeTxt);
			}
			// Afterwards...
			timeTxt.bounceTweenEnabled = ThemeSupport.Timebar.text.bouncetween.enabled;
			timeTxt.bounceTweenScale = ThemeSupport.Timebar.text.bouncetween.scale;
			timeTxt.bounceTweenType = ThemeSupport.Timebar.text.bouncetween.type;
			timeTxt.center = ThemeSupport.Timebar.center;
			timeTxt.fades = ThemeSupport.Timebar.text.fades;
			timeTxt.fromHeight = ThemeSupport.Timebar.text.fromheight;
			timeTxt.fromWidth = ThemeSupport.Timebar.text.fromwidth;
			timeTxt.ogX = timeTxt.x;
			timeTxt.ogY = timeTxt.y;
			timeTxt.scrolls = ThemeSupport.Timebar.text.scrolls;
			timeTxt.texts = ThemeSupport.Timebar.text.text;
			// This code is wacky.
			PSLoadedMap["timeTxt"] = timeTxt;
			UIElements["timetxt"] = timeTxt;
			UITexts.push(timeTxt);
			PSLoadedMap["timeBar"] = timeBar;
			UIElements["timebar"] = timeBar;
			PSLoadedMap["timeBarBG"] = timeBarBG;
			UIElements["timebarbg"] = timeBarBG;
		}

		if(ThemeSupport.HealthbarEnabled) {
			healthBarBG = new FlxSprite(ThemeSupport.Healthbar.x[scrollVersion], ThemeSupport.Healthbar.y[scrollVersion]).loadGraphic(#if desktop BitmapData.fromFile(ThemeSupport.WorkingDirectory + "images/" + ThemeSupport.Healthbar.image + ".png") #else Paths.image(ThemeSupport.Healthbar.image) #end);
			if(ThemeSupport.Healthbar.center[0])
				healthBarBG.screenCenter(X);
			if(ThemeSupport.Healthbar.center[1])
				healthBarBG.screenCenter(Y);
			healthBarBG.scrollFactor.set();
			add(healthBarBG);
			PSLoadedMap["healthBarBG"] = healthBarBG;
			UIElements["healthbarbg"] = healthBarBG;

			healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this, 'health', 0, 2);
			healthBar.scrollFactor.set();
			healthBar.createFilledBar(FlxColor.fromString(ThemeSupport.Healthbar.colors[0]), FlxColor.fromString(ThemeSupport.Healthbar.colors[1]));
			add(healthBar);
			PSLoadedMap["healthBar"] = healthBar;
			UIElements["healthbar"] = healthBar;

			if(ThemeSupport.Healthbar.showIcons[0]) {
				OGIconP1 = new HealthIcon(SONG.player1, true);
				add(OGIconP1);
				PSLoadedMap["OGIconP1"] = OGIconP1;
				OGIconP1.visible = false;
				oldbfIcon = new HealthIcon("bf-old", true);
				add(oldbfIcon);
				PSLoadedMap["oldbfIcon"] = oldbfIcon;
				oldbfIcon.visible = false;
				pahazeIcon = new HealthIcon("pahaze", true);
				add(pahazeIcon);
				PSLoadedMap["pahazeIcon"] = pahazeIcon;
				pahazeIcon.visible = false;
				pahazeRedwickIcon = new HealthIcon("redwick-pahaze", true);
				add(pahazeRedwickIcon);
				PSLoadedMap["pahazeRedwickIcon"] = pahazeRedwickIcon;
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
				UIElements["iconp1"] = iconP1;
			}

			if(ThemeSupport.Healthbar.showIcons[1]) {
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
				UIElements["iconp2"] = iconP2;
			}
		}

		if(ThemeSupport.AccuracyTextEnabled) {
			accTxt = new ThemeText(ThemeSupport.AccuracyText.x[scrollVersion], ThemeSupport.AccuracyText.y[scrollVersion], 0, "", 20);
			accTxt.setFormat(ThemeSupport.AccuracyText.customization.font, ThemeSupport.AccuracyText.customization.fontsize, FlxColor.fromString(ThemeSupport.AccuracyText.customization.color), Utilities.getTextAlignment(ThemeSupport.AccuracyText.customization.alignment), Utilities.getBorderStyle(ThemeSupport.AccuracyText.customization.border.style), FlxColor.fromString(ThemeSupport.AccuracyText.customization.border.color));
			accTxt.borderSize = ThemeSupport.AccuracyText.customization.border.size;
			accTxt.scrollFactor.set();
			add(accTxt);
			accTxt.bounceTweenEnabled = ThemeSupport.AccuracyText.bouncetween.enabled;
			accTxt.bounceTweenScale = ThemeSupport.AccuracyText.bouncetween.scale;
			accTxt.bounceTweenType = ThemeSupport.AccuracyText.bouncetween.type;
			accTxt.center = ThemeSupport.AccuracyText.center;
			accTxt.fades = ThemeSupport.AccuracyText.fades;
			accTxt.fromHeight = ThemeSupport.AccuracyText.fromheight;
			accTxt.fromWidth = ThemeSupport.AccuracyText.fromwidth;
			accTxt.ogX = accTxt.x;
			accTxt.ogY = accTxt.y;
			accTxt.scrolls = ThemeSupport.AccuracyText.scrolls;
			accTxt.texts = ThemeSupport.AccuracyText.text;
			PSLoadedMap["accTxt"] = accTxt;
			UIElements["acctxt"] = accTxt;
			UITexts.push(accTxt);
		}

		if(ThemeSupport.ExtraTextEnabled) {
			for(i in 0...ThemeSupport.ExtraText.length) {
				var extraTxt:ThemeText;
				extraTxt = new ThemeText(ThemeSupport.ExtraText[i].x[scrollVersion], ThemeSupport.ExtraText[i].y[scrollVersion], 0, "", 20);
				extraTxt.setFormat(ThemeSupport.ExtraText[i].customization.font, ThemeSupport.ExtraText[i].customization.fontsize, FlxColor.fromString(ThemeSupport.ExtraText[i].customization.color), Utilities.getTextAlignment(ThemeSupport.ExtraText[i].customization.alignment), Utilities.getBorderStyle(ThemeSupport.ExtraText[i].customization.border.style), FlxColor.fromString(ThemeSupport.ExtraText[i].customization.border.color));
				extraTxt.borderSize = ThemeSupport.ExtraText[i].customization.border.size;
				extraTxt.scrollFactor.set();
				add(extraTxt);
				extraTxt.bounceTweenEnabled = ThemeSupport.ExtraText[i].bouncetween.enabled;
				extraTxt.bounceTweenScale = ThemeSupport.ExtraText[i].bouncetween.scale;
				extraTxt.bounceTweenType = ThemeSupport.ExtraText[i].bouncetween.type;
				extraTxt.cameras = [camHUD];
				extraTxt.center = ThemeSupport.ExtraText[i].center;
				extraTxt.fades = ThemeSupport.ExtraText[i].fades;
				extraTxt.fromHeight = ThemeSupport.ExtraText[i].fromheight;
				extraTxt.fromWidth = ThemeSupport.ExtraText[i].fromwidth;
				extraTxt.ogX = extraTxt.x;
				extraTxt.ogY = extraTxt.y;
				extraTxt.scrolls = ThemeSupport.ExtraText[i].scrolls;
				extraTxt.texts = ThemeSupport.ExtraText[i].text;
				PSLoadedMap["extraTxt" + i] = extraTxt;
				UIElements["extratxt" + i] = extraTxt;
				UITexts.push(extraTxt);
			}
		}

		if(ThemeSupport.MissTextEnabled) {
			missTxt = new ThemeText(ThemeSupport.MissText.x[scrollVersion], ThemeSupport.MissText.y[scrollVersion], 0, "", 20);
			missTxt.setFormat(ThemeSupport.MissText.customization.font, ThemeSupport.MissText.customization.fontsize, FlxColor.fromString(ThemeSupport.MissText.customization.color), Utilities.getTextAlignment(ThemeSupport.MissText.customization.alignment), Utilities.getBorderStyle(ThemeSupport.MissText.customization.border.style), FlxColor.fromString(ThemeSupport.MissText.customization.border.color));
			missTxt.borderSize = ThemeSupport.MissText.customization.border.size;
			missTxt.scrollFactor.set();
			add(missTxt);
			missTxt.bounceTweenEnabled = ThemeSupport.MissText.bouncetween.enabled;
			missTxt.bounceTweenScale = ThemeSupport.MissText.bouncetween.scale;
			missTxt.bounceTweenType = ThemeSupport.MissText.bouncetween.type;
			missTxt.center = ThemeSupport.MissText.center;
			missTxt.fades = ThemeSupport.MissText.fades;
			missTxt.fromHeight = ThemeSupport.MissText.fromheight;
			missTxt.fromWidth = ThemeSupport.MissText.fromwidth;
			missTxt.ogX = missTxt.x;
			missTxt.ogY = missTxt.y;
			missTxt.scrolls = ThemeSupport.MissText.scrolls;
			missTxt.texts = ThemeSupport.MissText.text;
			PSLoadedMap["missTxt"] = missTxt;
			UIElements["misstxt"] = missTxt;
			UITexts.push(missTxt);
		}

		if(ThemeSupport.NPSTextEnabled == true) {
			npsTxt = new ThemeText(ThemeSupport.NPSText.x[scrollVersion], ThemeSupport.NPSText.y[scrollVersion], 0, "", 20);
			npsTxt.setFormat(ThemeSupport.NPSText.customization.font, ThemeSupport.NPSText.customization.fontsize, FlxColor.fromString(ThemeSupport.NPSText.customization.color), Utilities.getTextAlignment(ThemeSupport.NPSText.customization.alignment), Utilities.getBorderStyle(ThemeSupport.NPSText.customization.border.style), FlxColor.fromString(ThemeSupport.NPSText.customization.border.color));
			npsTxt.borderSize = ThemeSupport.NPSText.customization.border.size;
			npsTxt.scrollFactor.set();
			add(npsTxt);
			npsTxt.bounceTweenEnabled = ThemeSupport.NPSText.bouncetween.enabled;
			npsTxt.bounceTweenScale = ThemeSupport.NPSText.bouncetween.scale;
			npsTxt.bounceTweenType = ThemeSupport.NPSText.bouncetween.type;
			npsTxt.center = ThemeSupport.NPSText.center;
			npsTxt.fades = ThemeSupport.NPSText.fades;
			npsTxt.fromHeight = ThemeSupport.NPSText.fromheight;
			npsTxt.fromWidth = ThemeSupport.NPSText.fromwidth;
			npsTxt.ogX = npsTxt.x;
			npsTxt.ogY = npsTxt.y;
			npsTxt.scrolls = ThemeSupport.NPSText.scrolls;
			npsTxt.texts = ThemeSupport.NPSText.text;
			PSLoadedMap["npsTxt"] = npsTxt;
			UIElements["npstxt"] = npsTxt;
			UITexts.push(npsTxt);
		}

		if(ThemeSupport.ScoreEnabled == true) {
			scoreTxt = new ThemeText(ThemeSupport.Score.x[scrollVersion], ThemeSupport.Score.y[scrollVersion], 0, "", 20);
			scoreTxt.setFormat(ThemeSupport.Score.customization.font, ThemeSupport.Score.customization.fontsize, FlxColor.fromString(ThemeSupport.Score.customization.color), Utilities.getTextAlignment(ThemeSupport.Score.customization.alignment), Utilities.getBorderStyle(ThemeSupport.Score.customization.border.style), FlxColor.fromString(ThemeSupport.Score.customization.border.color));
			scoreTxt.borderSize = ThemeSupport.Score.customization.border.size;
			scoreTxt.scrollFactor.set();
			add(scoreTxt);
			scoreTxt.bounceTweenEnabled = ThemeSupport.Score.bouncetween.enabled;
			scoreTxt.bounceTweenScale = ThemeSupport.Score.bouncetween.scale;
			scoreTxt.bounceTweenType = ThemeSupport.Score.bouncetween.type;
			scoreTxt.center = ThemeSupport.Score.center;
			scoreTxt.fades = ThemeSupport.Score.fades;
			scoreTxt.fromHeight = ThemeSupport.Score.fromheight;
			scoreTxt.fromWidth = ThemeSupport.Score.fromwidth;
			scoreTxt.ogX = scoreTxt.x;
			scoreTxt.ogY = scoreTxt.y;
			scoreTxt.scrolls = ThemeSupport.Score.scrolls;
			scoreTxt.texts = ThemeSupport.Score.text;
			PSLoadedMap["scoreTxt"] = scoreTxt;
			UIElements["scoretxt"] = scoreTxt;
			UITexts.push(scoreTxt);
		}

		if(ThemeSupport.BotplayEnabled == true) {
			botplayTxt = new ThemeText(ThemeSupport.Botplay.x[scrollVersion], ThemeSupport.Botplay.y[scrollVersion], 0, "", 20);
			botplayTxt.setFormat(ThemeSupport.Botplay.customization.font, ThemeSupport.Botplay.customization.fontsize, FlxColor.fromString(ThemeSupport.Botplay.customization.color), Utilities.getTextAlignment(ThemeSupport.Botplay.customization.alignment), Utilities.getBorderStyle(ThemeSupport.Botplay.customization.border.style), FlxColor.fromString(ThemeSupport.Botplay.customization.border.color));
			botplayTxt.borderSize = ThemeSupport.Botplay.customization.border.size;
			botplayTxt.scrollFactor.set();
			botplayTxt.visible = botplayIsEnabled;
			add(botplayTxt);
			botplayTxt.bounceTweenEnabled = ThemeSupport.Botplay.bouncetween.enabled;
			botplayTxt.bounceTweenScale = ThemeSupport.Botplay.bouncetween.scale;
			botplayTxt.bounceTweenType = ThemeSupport.Botplay.bouncetween.type;
			botplayTxt.center = ThemeSupport.Botplay.center;
			botplayTxt.fades = ThemeSupport.Botplay.fades;
			botplayTxt.fromHeight = ThemeSupport.Botplay.fromheight;
			botplayTxt.fromWidth = ThemeSupport.Botplay.fromwidth;
			botplayTxt.ogX = botplayTxt.x;
			botplayTxt.ogY = botplayTxt.y;
			botplayTxt.scrolls = ThemeSupport.Botplay.scrolls;
			botplayTxt.texts = ThemeSupport.Botplay.text;
			PSLoadedMap["botplayTxt"] = botplayTxt;
			UIElements["botplaytxt"] = botplayTxt;
			UITexts.push(botplayTxt);
		}

		if(ThemeSupport.WatermarkEnabled == true) {
			refunkedWatermark = new ThemeText(ThemeSupport.Watermark.x[scrollVersion], ThemeSupport.Watermark.y[scrollVersion], 0, "", 20);
			refunkedWatermark.setFormat(ThemeSupport.Watermark.customization.font, ThemeSupport.Watermark.customization.fontsize, FlxColor.fromString(ThemeSupport.Watermark.customization.color), Utilities.getTextAlignment(ThemeSupport.Watermark.customization.alignment), Utilities.getBorderStyle(ThemeSupport.Watermark.customization.border.style), FlxColor.fromString(ThemeSupport.Watermark.customization.border.color));
			refunkedWatermark.borderSize = ThemeSupport.Watermark.customization.border.size;
			add(refunkedWatermark);
			refunkedWatermark.bounceTweenEnabled = ThemeSupport.Watermark.bouncetween.enabled;
			refunkedWatermark.bounceTweenScale = ThemeSupport.Watermark.bouncetween.scale;
			refunkedWatermark.bounceTweenType = ThemeSupport.Watermark.bouncetween.type;
			refunkedWatermark.center = ThemeSupport.Watermark.center;
			refunkedWatermark.fades = ThemeSupport.Watermark.fades;
			refunkedWatermark.fromHeight = ThemeSupport.Watermark.fromheight;
			refunkedWatermark.fromWidth = ThemeSupport.Watermark.fromwidth;
			refunkedWatermark.ogX = refunkedWatermark.x;
			refunkedWatermark.ogY = refunkedWatermark.y;
			refunkedWatermark.scrolls = ThemeSupport.Watermark.scrolls;
			refunkedWatermark.texts = ThemeSupport.Watermark.text;
			PSLoadedMap["RFEWatermark"] = refunkedWatermark;
			UIElements["watermarkTxt"] = refunkedWatermark;
			UITexts.push(refunkedWatermark);
		}

		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		if(ThemeSupport.AccuracyTextEnabled == true)
			accTxt.cameras = [camHUD];
		if(ThemeSupport.MissTextEnabled == true)
			missTxt.cameras = [camHUD];
		if(ThemeSupport.NPSTextEnabled == true)
			npsTxt.cameras = [camHUD];
		if(ThemeSupport.HealthbarEnabled) {
			healthBar.cameras = [camHUD];
			healthBarBG.cameras = [camHUD];
			if(ThemeSupport.Healthbar.showIcons[0]) {
				iconP1.cameras = [camHUD];
				OGIconP1.cameras = [camHUD];
				oldbfIcon.cameras = [camHUD];
				pahazeIcon.cameras = [camHUD];
				pahazeRedwickIcon.cameras = [camHUD];
			}
			if(ThemeSupport.Healthbar.showIcons[1]) {
				iconP2.cameras = [camHUD];
				dadIcon.cameras = [camHUD];
				OGIconP2.cameras = [camHUD];
			}
		}
		if(ThemeSupport.ScoreEnabled == true)
			scoreTxt.cameras = [camHUD];
		if(ThemeSupport.TimebarEnabled) {
			timeBar.cameras = [camHUD];
			timeBarBG.cameras = [camHUD];
			timeTxt.cameras = [camHUD];
		}
		if(ThemeSupport.BotplayEnabled == true)
			botplayTxt.cameras = [camHUD];
		if(ThemeSupport.WatermarkEnabled == true)
			refunkedWatermark.cameras = [camHUD];
		if(dialogue != null)
			doof.cameras = [camHUD];

		setUpTweens();

		#if sys
			if(isModSong) {
				if(Utilities.checkFileExists(Paths.modSongData(mod, SONG.song, "modchart.lua"))) {
					RFELuaArray.push(new ReFunkedLua(Paths.modSongData(mod, SONG.song, "modchart.lua")));
					luaFiles++;
				}
			} else {
				if(Utilities.checkFileExists(Paths.songData(SONG.song, "modchart.lua"))) {
					RFELuaArray.push(new ReFunkedLua(Paths.songData(SONG.song, "modchart.lua")));
					luaFiles++;
				}
			}

			noteLuaFiles = Utilities.readFolder("assets/notes");
			if(noteLuaFiles != null) {
				for(i in 0...noteLuaFiles.length) {
					if(noteLuaFiles[i].endsWith(".lua")) {
						RFELuaArray.push(new ReFunkedLua("assets/notes/" + noteLuaFiles[i]));
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
		if(FlxG.sound.music != null)
			FlxG.sound.music.stop();
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

	public function makeStuffInvisibleLol() {
		for(i in 0...UITexts.length) {
			UITexts[i].visible = false;
		}
		if(ThemeSupport.TimebarEnabled) {
			if(!ThemeSupport.Timebar.textOnly) {
				timeBarBG.visible = false;
				timeBar.visible = false;
			}
		}
		if(ThemeSupport.HealthbarEnabled) {
			healthBarBG.visible = false;
			healthBar.visible = false;
			if(ThemeSupport.Healthbar.showIcons[0])
				iconP1.visible = false;
			if(ThemeSupport.Healthbar.showIcons[1])
				iconP2.visible = false;
		}
	}

	public function makeStuffVisibleLol() {
		for(i in 0...UITexts.length) {
			UITexts[i].visible = true;
		}
		if(ThemeSupport.TimebarEnabled) {
			if(!ThemeSupport.Timebar.textOnly) {
				timeBarBG.visible = true;
				timeBar.visible = true;
			}
		}
		if(ThemeSupport.HealthbarEnabled) {
			healthBarBG.visible = true;
			healthBar.visible = true;
			if(ThemeSupport.Healthbar.showIcons[0])
				iconP1.visible = true;
			if(ThemeSupport.Healthbar.showIcons[1])
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
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy', 'week6');
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
		for(i in 0...playerStrums.length) {
			UIElements["playernote" + i] = playerStrums.members[i];
		}
		for(i in 0...cpuStrums.length) {
			// Protection of UI element alpha changing with Lua
			if(Options.middlescroll)
				cpuStrums.members[i].visible = false;
			else
				UIElements["cpunote" + i] = cpuStrums.members[i];
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
			luaCallback("preSongCountdown", []);
		#end

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			var introAlts:Array<String> = UIStyleSupport.uiStyleIntroAssets;

			switch (swagCounter)
			{
				case 0:
					intro3.play();
				case 1:
					#if sys
						var ready:FlxSprite = new FlxSprite().loadGraphic(BitmapData.fromFile(UIStyleSupport.image(introAlts[0])));
					#else
						var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					#end
					ready.scrollFactor.set();
					ready.updateHitbox();
					if(UIStyleSupport.uiStyleIsPixel)
						ready.setGraphicSize(Std.int(ready.width * UIStyleSupport.uiStylePixelZoom));

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					intro2.play();
				case 2:
					#if sys
						var set:FlxSprite = new FlxSprite().loadGraphic(BitmapData.fromFile(UIStyleSupport.image(introAlts[1])));
					#else
						var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					#end
					set.scrollFactor.set();
					if(UIStyleSupport.uiStyleIsPixel)
						set.setGraphicSize(Std.int(set.width * UIStyleSupport.uiStylePixelZoom));

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					intro1.play();
				case 3:
					#if sys
						var go:FlxSprite = new FlxSprite().loadGraphic(BitmapData.fromFile(UIStyleSupport.image(introAlts[2])));
					#else
						var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					#end
					go.scrollFactor.set();
					if(UIStyleSupport.uiStyleIsPixel)
						go.setGraphicSize(Std.int(go.width * UIStyleSupport.uiStylePixelZoom));

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
					introGo.play();
				case 4:
					#if sys
						luaCallback("postSongCountdown", []);
					#end
			}

			for(actor in ActorSprites) {
				if(tmr.loopsLeft % actor.speed == 0)
					actor.dance();
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
		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		// Intro stuff
		intro3 = new FlxSound().loadStream(UIStyleSupport.sound(UIStyleSupport.uiStyleIntroSounds[2]), false, true);
		intro2 = new FlxSound().loadStream(UIStyleSupport.sound(UIStyleSupport.uiStyleIntroSounds[1]), false, true);
		intro1 = new FlxSound().loadStream(UIStyleSupport.sound(UIStyleSupport.uiStyleIntroSounds[0]), false, true);
		introGo = new FlxSound().loadStream(UIStyleSupport.sound(UIStyleSupport.uiStyleIntroSounds[3]), false, true);

		if(isModSong)
			inst = new FlxSound().loadStream("./" + Paths.modInst(mod, PlayState.SONG.song), false);
		else
			inst = new FlxSound().loadStream("./" + Paths.inst(PlayState.SONG.song), false);

		if (SONG.needsVoices) {
			if(isModSong)
				vocals = new FlxSound().loadStream("./" + Paths.modVoices(mod, PlayState.SONG.song), false);
			else
				vocals = new FlxSound().loadStream("./" + Paths.voices(PlayState.SONG.song), false);
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
					noteType = UIStyleSupport.uiStyleNoteType;
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

					if (sustainNote.mustPress) {
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
		for(i in 0...unspawnNotes.length) {
			if(unspawnNotes[i].isSustainNote) {
				if(unspawnNotes[i].prevNote != null) {
					handleNoteAdding(unspawnNotes[i], unspawnNotes[i].prevNote);
				}
			}
		}
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
			if(boyfriend != null && boyfriend.getMidpoint() != null) {
				setLuaVar('boyfriendMidpointX', boyfriend.getMidpoint().x);
				setLuaVar('boyfriendMidpointY', boyfriend.getMidpoint().y);
			}
			if(dad != null && dad.getMidpoint() != null) {
				setLuaVar('opponentMidpointX', dad.getMidpoint().x);
				setLuaVar('opponentMidpointY', dad.getMidpoint().y);
			}
			// why did i even set curBeat/curStep here?
			setLuaVar('health', health);
			if(stuffLoaded) {
				setLuaVar('instPosition', inst.time);
				setLuaVar('songPosition', FlxMath.roundDecimal(Conductor.songPosition, 0));
				setLuaVar('songPositionExact', Conductor.songPosition);
				setLuaVar('vocalsPosition', vocals.time);
			}
			luaCallback("update", [elapsed]);
		#end

		// Game mode is constantly updating so the game knows what text to use.
		gameMode = (PracticeMode ? (botplayIsEnabled ? 3 : 2) : (botplayIsEnabled ? 1 : 0));

		if(botplayIsEnabled)
			botplayWasUsed = true;

		if(PracticeMode)
			practiceWasUsed = true;

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

		if(!inCutscene && stuffLoaded) {
			var lerpThing:Float = FlxMath.bound(elapsed * 3.5, 0, 1);
			camFollow.setPosition(FlxMath.lerp(camFollow.x, camFollowPoint.x, lerpThing), FlxMath.lerp(camFollow.y, camFollowPoint.y, lerpThing));
		}

		super.update(elapsed);

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

		if(ThemeSupport.TimebarEnabled) {
			switch (ThemeSupport.Timebar.style.toLowerCase()) {
				case "psych":
					timeBarBG.setPosition(timeBar.x - 4, timeBar.y - 4);
					timeBarBG.scrollFactor.set();
			}
		}
	
		if(accuracyThing >= 69 && accuracyThing < 70 && ThemeSupport.RatingStyle != "psych") {
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

		funnyRating = Utilities.calculateThemeRating(accuracyThing, ThemeSupport.RatingStyle);

		botplaySine += 180 * elapsed;
		var alpher:Float = 1 - Math.sin(botplaySine / 180);

		// beeg statement
		if(!inCutscene && stuffLoaded) {
			for(i in 0...UITexts.length) {
				var tempText:String = replaceStageVarsInTheme(UITexts[i].texts[gameMode]);
				if(UITexts[i].text != tempText) {
					UITexts[i].text = tempText;
					if(UITexts[i].center[0])
						UITexts[i].screenCenter(X);
					if(UITexts[i].center[1])
						UITexts[i].screenCenter(Y);
					if(UITexts[i].fromWidth)
						checkUITextX(UITexts[i]);
					if(UITexts[i].fromHeight)
						checkUITextY(UITexts[i]);
				}

				if(UITexts[i].fades)
					UITexts[i].alpha = alpher;

				if(UITexts[i].scrolls) {
					if(UITexts[i].x == UITexts[i].ogX) {
						UITexts[i].inPlace = true;
						if(themeScrollTweens[UITexts[i]] != null)
							themeScrollTweens[UITexts[i]].cancel();
						new FlxTimer().start(5, function(tmr:FlxTimer) {
							UITexts[i].inPlace = false;
							if(!paused) {
								if(UITexts[i].x < UITexts[i].ogX + 1 && UITexts[i].x > UITexts[i].ogX - 1)
									UITexts[i].x = UITexts[i].x - 1;
							}
						});
					}
					if(UITexts[i].inPlace == false) {
						if(UITexts[i].x < -1280) {
							UITexts[i].x = FlxG.width;
						} else {
							if(themeScrollTweens[UITexts[i]] != null)
								themeScrollTweens[UITexts[i]].cancel();
							themeScrollTweens[UITexts[i]] = FlxTween.tween(UITexts[i], {x: UITexts[i].x - 1}, (elapsed < 0.01 ? (elapsed / 2) / 10 : elapsed / 10));
						}
					}
				}
				
				if(UITexts[i].bounceTweenEnabled && UITexts[i].bounceTweenType.toLowerCase() == "beathit") {
					if(themeBounceTweens[UITexts[i]] != null) 
						themeBounceTweens[UITexts[i]].cancel();
					themeBounceTweens[UITexts[i]] = FlxTween.tween(UITexts[i].scale, {x: 1, y: 1}, (elapsed < 0.01 ? ((elapsed < 0.005 ? elapsed * 3 : elapsed * 2)) * 9 : elapsed * 9), {
						onComplete: function(bruh:FlxTween) {
							themeBounceTweens[UITexts[i]] = null;
						}
					});
				}
			}
		}

		if(ThemeSupport.BotplayEnabled == true) {
			if(!inCutscene)
				botplayTxt.visible = botplayIsEnabled;
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
			endingSong = true;
			FlxG.switchState(new ChartingState());
			new FlxTimer().start(transOut.duration, function(tmr:FlxTimer) {
				unloadLoadedAssets();
				unloadMBSassets();
				nullPSLoadedAssets();
			});

			#if desktop
				DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
		}

		if(ThemeSupport.HealthbarEnabled && ThemeSupport.Healthbar.showIcons[0]) {
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

		if(ThemeSupport.HealthbarEnabled && ThemeSupport.Healthbar.showIcons[1]) {
			if(iconP2Tween != null) {
				iconP2Tween.cancel();
			}
			iconP2Tween = FlxTween.tween(iconP2, {"scale.x": 1, "scale.y": 1}, (elapsed < 0.01 ? ((elapsed < 0.005 ? elapsed * 3 : elapsed * 2)) * 9 : elapsed * 9), {
				onComplete: function(twn:FlxTween) {
					iconP2Tween = null;
				}
			});
			iconP2.updateHitbox();
			iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width * iconP2.scale.x) / 2 - 52;
			iconP2.y = healthBar.y - (iconP2.height / 2);
		}

		if (health > 2)
			health = 2;
		if (health < 0 && PracticeMode)
			health = 0;
		if (songScore < 0)
			songScore = 0;

		if(ThemeSupport.HealthbarEnabled) {
			switch(SONG.song.toLowerCase()) {
				case "tutorial":
					if (healthBar.percent > 80) {
						if(ThemeSupport.Healthbar.showIcons[0]) {
							iconP1.animation.curAnim.curFrame = 2;
						}
						if(ThemeSupport.Healthbar.showIcons[1]) {
							iconP2.animation.curAnim.curFrame = 2;
						}
					} else if(healthBar.percent < 20) {
						if(ThemeSupport.Healthbar.showIcons[0]) {
							iconP1.animation.curAnim.curFrame = 1;
						}
						if(ThemeSupport.Healthbar.showIcons[1]) {
							iconP2.animation.curAnim.curFrame = 1;
						}
					} else {
						if(ThemeSupport.Healthbar.showIcons[0]) {
							iconP1.animation.curAnim.curFrame = 0;
							}
						if(ThemeSupport.Healthbar.showIcons[1]) {	
							iconP2.animation.curAnim.curFrame = 0;
						}
					}
				default:
					if (healthBar.percent > 80) {
						if(ThemeSupport.Healthbar.showIcons[0]) {
							iconP1.animation.curAnim.curFrame = 2;
						}
						if(ThemeSupport.Healthbar.showIcons[1]) {
							iconP2.animation.curAnim.curFrame = 1;
						}
					} else if(healthBar.percent < 20) {
						if(ThemeSupport.Healthbar.showIcons[0]) {
							iconP1.animation.curAnim.curFrame = 1;
						}
						if(ThemeSupport.Healthbar.showIcons[1]) {
							iconP2.animation.curAnim.curFrame = 2;
						}
					} else {
						if(ThemeSupport.Healthbar.showIcons[0]) {
							iconP1.animation.curAnim.curFrame = 0;
						}
						if(ThemeSupport.Healthbar.showIcons[1]) {
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
		
		// i am very sorry for this insane statement
		if ((SONG.needsVoices ? (inst.length > 0 && vocals.length > 0) : inst.length > 0) &&
		(intro3.length > 0 && intro2.length > 0 && intro1.length > 0 && introGo.length > 0) &&
		!startingSong && ThemeSupport.ThemeLoaded) {
			stuffLoaded = true;
			PSLoadedMap["inst"] = inst;
			PSLoadedMap["intro3"] = intro3;
			PSLoadedMap["intro2"] = intro2;
			PSLoadedMap["intro1"] = intro1;
			PSLoadedMap["introGo"] = introGo;
			PSLoadedMap["vocals"] = vocals;
			#if sys
				setLuaVar("instLength", inst.length);
				setLuaVar("vocalsLength", vocals.length);
			#end
		}

		if(stuffLoaded && !startedCountdown && !inCutscene) {
			loadingSongText.text = "Loaded! Have fun.";
			loadingSongText.screenCenter();
			new FlxTimer().start(0.5, function(tmr:FlxTimer) {
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

		if (startingSong) {
			if (startedCountdown) {
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else {
			if(!endingSong) {
				Conductor.songPosition += FlxG.elapsed * 1000;

				if (!paused)
				{
					songTime += FlxG.game.ticks - previousFrameTime;
					previousFrameTime = FlxG.game.ticks;

					if (Conductor.lastSongPos != Conductor.songPosition) {
						songTime = (songTime + Conductor.songPosition) / 2;
						Conductor.lastSongPos = Conductor.songPosition;
					}

					songPercentage = (Conductor.songPosition / songLength);
				}
			}
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null && camFollowSet == false)
		{
			if (!PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				var camAdd:Array<Int> = ActorSprites[TargetActors["opponent"]].cameraAdd;
				var xPos:Float;
				var yPos:Float;
				if(camFollowSetMap.exists("opponentX") && camFollowSetMap.exists("opponentY")) {
					xPos = camFollowSetMap["opponentX"];
					yPos = camFollowSetMap["opponentY"];
				} else {
					xPos = ActorSprites[TargetActors["opponent"]].getMidpoint().x + 150;
					yPos = ActorSprites[TargetActors["opponent"]].getMidpoint().y - 100;

					if(camAdd != null) {
						xPos += camAdd[0];
						yPos += camAdd[1];
					}

					if(camFollowAdd.exists("opponentX"))
						xPos += camFollowAdd["opponentX"];
					if(camFollowAdd.exists("opponentY"))
						yPos += camFollowAdd["opponentY"];
				}

				setCameraPosition(xPos, yPos);

				vocals.volume = 1;

				if (SONG.song.toLowerCase() == 'tutorial')
				{
					tweenCamIn();
				}
			}

			if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				var camAdd:Array<Int> = ActorSprites[TargetActors["boyfriend"]].cameraAdd;
				var xPos:Float;
				var yPos:Float;
				if(camFollowSetMap.exists("boyfriendX") && camFollowSetMap.exists("boyfriendY")) {
					xPos = camFollowSetMap["boyfriendX"];
					yPos = camFollowSetMap["boyfriendY"];
				} else {
					xPos = ActorSprites[TargetActors["boyfriend"]].getMidpoint().x - 100;
					yPos = ActorSprites[TargetActors["boyfriend"]].getMidpoint().y - 100;

					if(camAdd != null) {
						xPos += camAdd[0];
						yPos += camAdd[1];
					}

					if(camFollowAdd.exists("boyfriendX"))
						xPos += camFollowAdd["boyfriendX"];
					if(camFollowAdd.exists("boyfriendY"))
						yPos += camFollowAdd["boyfriendY"];
				}

				setCameraPosition(xPos, yPos);

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
		FlxG.watch.addQuick("songPosition", Conductor.songPosition);

		// RESET = Quick Game Over Screen
		if (controls.RESET && stuffLoaded && !inCutscene) {
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
			nullPSLoadedAssets();
		}

		if (controls.CHEAT) {
			health += 1;
			trace("User is cheating!");
		}

		if (health <= 0 && !PracticeMode) {
			boyfriend.stunned = true;
		
			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			FlxG.sound.music.stop();
			vocals.stop();
			inst.stop();
			unloadLoadedAssets();
			unloadMBSassets();
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
				
			openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			#if desktop
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("Game Over - " + detailsText, detailsStageText, iconRPC);
			#end
		}

		if(unspawnNotes[0] != null) {
			var dunceTime:Float = 2000;
			if(SONG.speed < 1)
				dunceTime = dunceTime / SONG.speed;

			while(unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < dunceTime) {
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			if (!inCutscene)
				keyStuff();

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
				
				var useNote:FlxSprite = (daNote.mustPress ? playerStrums.members[daNote.noteData] : cpuStrums.members[daNote.noteData]);

				daNote.x = useNote.x;
				if(!daNote.isSustainNote)
					daNote.angle = useNote.angle;
				if(daNote.isSustainNote)
					daNote.x += (useNote.width / 2) - (daNote.width / 2);

				if(Options.downscroll) {
					daNote.y = useNote.y + 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(SONG.speed, 2);

					if (daNote.isSustainNote) {
						if (daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= useNote.y + Note.swagWidth / 2 && (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
						{
							var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
							swagRect.height = (useNote.y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
							swagRect.y = daNote.frameHeight - swagRect.height;
							daNote.clipRect = swagRect;
						}
					}
				} else {
					daNote.y = useNote.y - 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(SONG.speed, 2);

					if(daNote.isSustainNote) {
						if (daNote.y + daNote.offset.y <= useNote.y + Note.swagWidth / 2 && (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
						{
							var swagRect = new FlxRect(0, useNote.y + Note.swagWidth / 2 - daNote.y, daNote.width * 2, daNote.height * 2);
							swagRect.y /= daNote.scale.y;
							swagRect.height -= swagRect.y;
							daNote.clipRect = swagRect;
						}
					}
				}

				if (!daNote.mustPress && daNote.wasGoodHit) {
					if (SONG.song != 'Tutorial')
						camZooming = true;
				
					dad.holdTimer = 0;
					if (SONG.needsVoices)
						vocals.volume = 1;
				
					#if sys
						if(daNote.noteType != "normal" && daNote.noteType != "pixel") {
							luaCallback("goodNoteHit", [Math.abs(daNote.noteData), daNote.isSustainNote, daNote.mustPress, daNote.noteType, daNote.ID]);
							luaCallback("opponentNoteHit", [Math.abs(daNote.noteData), daNote.isSustainNote, daNote.mustPress, daNote.noteType, daNote.ID]);
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
				
					for(i in 0...UITexts.length) {
						if(UITexts[i].bounceTweenEnabled && UITexts[i].bounceTweenType.toLowerCase() == "opponentnotehit") {
							if(themeBounceTweens[UITexts[i]] != null) {
								themeBounceTweens[UITexts[i]].cancel();
							}
							UITexts[i].scale.x = UITexts[i].bounceTweenScale;
							UITexts[i].scale.y = UITexts[i].bounceTweenScale;
							themeBounceTweens[UITexts[i]] = FlxTween.tween(UITexts[i].scale, {x: 1, y: 1}, 0.2, {
								onComplete: function(twn:FlxTween) {
									themeBounceTweens[UITexts[i]] = null;
								}
							});
						}
					}

					cpuStrums.forEach(function(spr:FlxSprite) {
						pressArrow(spr, spr.ID, daNote);
						if (spr.animation.curAnim.name == 'confirm' && !uiStyle.startsWith('pixel')) {
							spr.centerOffsets();
							spr.offset.x -= 13;
							spr.offset.y -= 13;
						}
						else
							spr.centerOffsets();
					});

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

				if ((Options.downscroll ? daNote.y > FlxG.height : daNote.y < 0 - daNote.height) && !botplayIsEnabled && daNote.mustPress)
				{
					if (daNote.tooLate || !daNote.wasGoodHit)
					{
						#if sys
							if(daNote.noteType != "normal" && daNote.noteType != "pixel") {
								luaCallback("noteMiss", [Math.abs(daNote.noteData), daNote.isSustainNote, daNote.mustPress, daNote.noteType, daNote.ID]);
							} else {
						#end
							luaCallback("noteMiss", [Math.abs(daNote.noteData), daNote.isSustainNote, daNote.mustPress, daNote.noteType, daNote.ID]);
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

		#if debug
			if (FlxG.keys.justPressed.THREE)
				endSong();
		#end

		#if sys
			luaCallback("postUpdate", [elapsed]);
		#end
	}

	function checkUITextX(UIText:ThemeText) {
		if(UIText.x != (FlxG.width - UIText.width - UIText.ogX))
			UIText.x = (FlxG.width - UIText.width - UIText.ogX);
	}

	function checkUITextY(UIText:ThemeText) {
		if(UIText.y != (FlxG.height - UIText.height - UIText.ogY))
			UIText.y = (FlxG.height - UIText.height - UIText.ogY);
	}

	public function setIconXValues() {
		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) + (150 * iconP1.scale.x - iconP1.width) / 2 - 26;
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width * iconP2.scale.x) / 2 - 52;
	}

	function getEndAddAmt(daNote:Note, prevNote:Note) {
		var daNoteY:Float;
		var prevNoteY:Float;
		if(Options.downscroll) {
			daNoteY = getNoteY(daNote) + daNote.height;
			prevNoteY = getNoteY(prevNote);
			var yIsGreater:Bool = daNoteY < prevNoteY;
			if(yIsGreater) {
				while(daNoteY < prevNoteY) {
					daNote.strumTime -= 1;
					daNoteY = getNoteY(daNote) + daNote.height;
				}
			} else {
				while(daNoteY > prevNoteY) {
					daNote.strumTime += 1;
					daNoteY = getNoteY(daNote) + daNote.height;
				}
			}
		} else {
			daNoteY = getNoteY(daNote);
			prevNoteY = getNoteY(prevNote) + prevNote.height;
			var yIsGreater:Bool = daNoteY > prevNoteY;
			if(yIsGreater) {
				while(daNoteY > prevNoteY) {
					daNote.strumTime -= 1;
					daNoteY = getNoteY(daNote);
				}
			} else {
				while(daNoteY < prevNoteY) {
					daNote.strumTime += 1;
					daNoteY = getNoteY(daNote);
				}
			}
		}
		daNote.endStrumAdded = true;
	}

	function getSustainAddAmt(daNote:Note, prevNote:Note) {
		var daNoteY:Float;
		var prevNoteY:Float;
		if(Options.downscroll) {
			daNoteY = getNoteY(daNote) + daNote.height;
			prevNoteY = getNoteY(prevNote) + (Note.swagWidth / 2);
			trace(daNoteY);
			trace(prevNoteY);
			var yIsGreater:Bool = daNoteY < prevNoteY;
			daNote.strumTime -= 1;
			trace(getNoteY(daNote) + daNote.height);
			if(yIsGreater) {
				while(daNoteY < prevNoteY) {
					daNote.strumTime -= 1;
					daNote.strumAdd += 1;
					daNoteY = getNoteY(daNote) + daNote.height;
				}
			} else {
				while(daNoteY > prevNoteY) {
					daNote.strumTime += 1;
					daNote.strumAdd -= 1;
					daNoteY = getNoteY(daNote) + daNote.height;
				}
			}
		} else {
			daNoteY = getNoteY(daNote);
			prevNoteY = getNoteY(prevNote) + (Note.swagWidth / 2);
			trace(daNoteY);
			trace(prevNoteY);
			var yIsGreater:Bool = daNoteY > prevNoteY;
			if(yIsGreater) {
				while(daNoteY > prevNoteY) {
					daNote.strumTime -= 1;
					daNote.strumAdd += 1;
					daNoteY = getNoteY(daNote);
				}
			} else {
				while(daNoteY < prevNoteY) {
					daNote.strumTime += 1;
					daNote.strumAdd -= 1;
					daNoteY = getNoteY(daNote);
				}
			}
		}
		daNote.baseStrumAdded = true;
	}

	function getNoteY(daNote:Note):Float {
		// General note values, just for simplicity sake
		if(Options.downscroll)
			return 50 + 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(SONG.speed, 2);
		else
			return 50 - 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(SONG.speed, 2);
	}

	function handleNoteAdding(daNote:Note, prevNote:Note) {
		if(!daNote.baseStrumAdded) {
			if(!prevNote.isSustainNote)
				getSustainAddAmt(daNote, prevNote);
			else {
				daNote.strumTime -= prevNote.strumAdd;
				daNote.strumAdd = prevNote.strumAdd;
				daNote.baseStrumAdded = true;
			}
		}
		if(!daNote.endStrumAdded) {
			if(daNote.animation.curAnim.name.endsWith("end")) {
				if(daNote.baseStrumAdded && prevNote.isSustainNote)
					getEndAddAmt(daNote, prevNote);
				else
					daNote.endStrumAdded = true;
			} else
				daNote.endStrumAdded = true;
		}
	}

	function setCameraPosition(x:Float, y:Float, ?snap:Bool = false) {
		camFollowPoint.set(x, y);
		if(snap)
			camFollow.setPosition(x, y);
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
				if(!botplayWasUsed && !practiceWasUsed)
					Highscore.saveScore(SONG.song, songScore, storyDifficultyText);
			#end
		}

		if (isStoryMode)
		{
			campaignScore += songScore;

			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0) {
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
				#if sys
					stopLua();
				#end
				fixModStuff();

				FlxG.switchState(new StoryMenuState());
				new FlxTimer().start(transOut.duration, function(tmr:FlxTimer) {
					unloadLoadedAssets();
					unloadMBSassets();
					nullPSLoadedAssets();
				});

				StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

				if (SONG.validScore && !botplayWasUsed && !practiceWasUsed) {
					Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficultyText);
				}
				FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
				FlxG.save.flush();
			} else {
				var difficulty:String = "";

				if(storyDifficultyText != "normal")
					difficulty = '-${storyDifficultyText}';

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

				prevCamFollow = camFollow;
				prevCamFollowPoint = camFollowPoint;

				PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
				FlxG.sound.music.stop();
				inst.stop();
				vocals.stop();
				#if sys
					stopLua();
				#end
				LoadingState.loadAndSwitchState(new PlayState());
				new FlxTimer().start(transOut.duration, function(tmr:FlxTimer) {
					unloadLoadedAssets();
					unloadMBSassets();
					nullPSLoadedAssets();
				});
			}
		} else {
			trace('WENT BACK TO FREEPLAY??');
			inst.stop();
			vocals.stop();
			fixModStuff();
			FlxG.switchState(new FreeplayState());
			#if sys
				stopLua();
			#end
			new FlxTimer().start(transOut.duration, function(tmr:FlxTimer) {
				unloadLoadedAssets();
				unloadMBSassets();
				nullPSLoadedAssets();
			});
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

		if (noteDiff > Conductor.safeZoneOffset * 0.8) {
			daRating = 'awful';
			score = 50;
			awfuls++;
			accNotesToDivide++;
			accNotesTotal++;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.65) {
			daRating = 'bad';
			score = 100;
			bads++;
			accNotesToDivide++;
			accNotesTotal++;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.45) {
			daRating = 'good';
			score = 200;
			goods++;
			accNotesToDivide++;
			accNotesTotal++;
		}
		if(daRating == "sick" ) {
			accNotesToDivide++;
			accNotesTotal++;
			sicks++;
		}

		for(i in 0...UITexts.length) {
			if(UITexts[i].bounceTweenEnabled && UITexts[i].bounceTweenType.toLowerCase() == "playernotehit") {
				if(themeBounceTweens[UITexts[i]] != null) {
					themeBounceTweens[UITexts[i]].cancel();
				}
				UITexts[i].scale.x = UITexts[i].bounceTweenScale;
				UITexts[i].scale.y = UITexts[i].bounceTweenScale;
				themeBounceTweens[UITexts[i]] = FlxTween.tween(UITexts[i].scale, {x: 1, y: 1}, 0.2, {
					onComplete: function(twn:FlxTween) {
						themeBounceTweens[UITexts[i]] = null;
					}
				});
			}
		}
		songScore += score;
	
		if(comboCount < 11) {
			comboCount++;
			#if sys
				rating.loadGraphic(BitmapData.fromFile(UIStyleSupport.image(UIStyleSupport.uiStyleRatingMap[daRating])));
			#else
				rating.loadGraphic(Paths.image(UIStyleSupport.uiStyleRatingMap[daRating]));
			#end
			rating.screenCenter();
			rating.x = coolText.x - 40;
			rating.y -= 60;
			rating.acceleration.y = 550;
			rating.velocity.y -= FlxG.random.int(140, 175);
			rating.velocity.x -= FlxG.random.int(0, 10);

			#if sys
				var comboSpr:FlxSprite = new FlxSprite().loadGraphic(BitmapData.fromFile(UIStyleSupport.image(UIStyleSupport.uiStyleComboAsset)));
			#else
				var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(UIStyleSupport.uiStyleComboAsset));
			#end
			comboSpr.screenCenter();
			comboSpr.x = coolText.x;
			comboSpr.acceleration.y = 600;
			comboSpr.velocity.y -= 150;
			comboSpr.velocity.x += FlxG.random.int(1, 10);

			if(combo >= 10)
				add(comboSpr);
			add(rating);

			if(UIStyleSupport.uiStyleIsPixel) {
				rating.setGraphicSize(Std.int(rating.width * UIStyleSupport.uiStylePixelZoom * UIStyleSupport.uiStyleGraphicSize));
				rating.antialiasing = UIStyleSupport.uiStyleAntialiasing;
				comboSpr.setGraphicSize(Std.int(comboSpr.width * UIStyleSupport.uiStylePixelZoom * UIStyleSupport.uiStyleGraphicSize));
				comboSpr.antialiasing = UIStyleSupport.uiStyleAntialiasing;
			} else {
				rating.setGraphicSize(Std.int(rating.width * UIStyleSupport.uiStyleGraphicSize));
				rating.antialiasing = UIStyleSupport.uiStyleAntialiasing;
				comboSpr.setGraphicSize(Std.int(comboSpr.width * UIStyleSupport.uiStyleGraphicSize));
				comboSpr.antialiasing = UIStyleSupport.uiStyleAntialiasing;
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
				#if sys
					var numScore:FlxSprite = new FlxSprite().loadGraphic(BitmapData.fromFile(UIStyleSupport.image(UIStyleSupport.uiStyleNumbers[i])));
				#else
					var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(UIStyleSupport.uiStyleNumbers[i]));
				#end
				numScore.screenCenter();
				numScore.x = coolText.x + (43 * daLoop) - 90;
				numScore.y += 80;

				numScore.antialiasing = UIStyleSupport.uiStyleAntialiasing;
				if (!UIStyleSupport.uiStyleIsPixel)
					numScore.setGraphicSize(Std.int(numScore.width * 0.5));
				else
					numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
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
					if(comboCount > 0)
						comboCount--;
				},
				startDelay: Conductor.crochet * 0.002
			});
		}

		curSection += 1;
	}

	private function keyStuff():Void {
		var controlArray:Array<Bool> = [controls.LEFT_P, controls.DOWN_P, controls.UP_P, controls.RIGHT_P];
		var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
		var releaseArray:Array<Bool> = [controls.LEFT_R, controls.DOWN_R, controls.UP_R, controls.RIGHT_R];

		// Based more towards 0.2.8, looks cleaner too
		if(holdArray.contains(true) && generatedMusic && !botplayIsEnabled) {
			notes.forEachAlive(function(daNote:Note) {
				if(daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData])
					goodNoteHit(daNote);
			});
		}
		if (controlArray.contains(true) && generatedMusic && !botplayIsEnabled)
		{
			boyfriend.holdTimer = 0;

			var badNotes:Array<Note> = [];
			var possibleNotes:Array<Note> = [];

			var ignoreList:Array<Int> = [];

			notes.forEachAlive(function(daNote:Note) {
				if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit) {
					if(ignoreList.contains(daNote.noteData)) {
						for(stupidNote in possibleNotes) {
							if(stupidNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - stupidNote.strumTime) < 10)
								badNotes.push(daNote);
							else if(stupidNote.noteData == daNote.noteData && daNote.strumTime < stupidNote.strumTime) {
								possibleNotes.remove(stupidNote);
								possibleNotes.push(daNote);
							}
						}
					} else {
						possibleNotes.push(daNote);
						ignoreList.push(daNote.noteData);
					}
				}
			});

			for(stupidBadNote in badNotes) {
				stupidBadNote.kill();
				notes.remove(stupidBadNote, true);
				stupidBadNote.destroy();
			}

			possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
			
			if (perfectMode)
				goodNoteHit(possibleNotes[0]);
			else if (possibleNotes.length > 0) {
				for(i in 0...controlArray.length) {
					if(controlArray[i] && !ignoreList.contains(i))
						badNoteCheck();
				}
				for(stupidNote in possibleNotes) {
					if(controlArray[stupidNote.noteData])
						goodNoteHit(stupidNote);
				}
			} else
				badNoteCheck();
		}

		if (ActorSprites[TargetActors["boyfriend"]].holdTimer > Conductor.stepCrochet * 4 * 0.001 && !holdArray.contains(true)) {
			if (ActorSprites[TargetActors["boyfriend"]].animation.curAnim.name.startsWith('sing') && !ActorSprites[TargetActors["boyfriend"]].animation.curAnim.name.endsWith('miss'))
				ActorSprites[TargetActors["boyfriend"]].dance();
		}

		if(!botplayIsEnabled) {
			playerStrums.forEach(function(spr:FlxSprite)
			{
				if(controlArray[spr.ID] && spr.animation.curAnim.name != 'confirm')
					spr.animation.play('pressed');
				else if(releaseArray[spr.ID])
					spr.animation.play('static');

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
			spr.animation.play('confirm', true);
		}
	}

	function noteMiss(direction:Int = 1):Void
	{
		if (!boyfriend.stunned && !botplayIsEnabled)
		{
			health -= 0.04;
			songScore -= 10;
			if (combo > 5 && ActorSprites[TargetActors["girlfriend"]].animOffsets.exists('sad'))
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
				if(note.noteType != "normal" && note.noteType != "pixel") {
					luaCallback("goodNoteHit", [Math.abs(note.noteData), note.isSustainNote, note.mustPress, note.noteType, note.ID]);
					luaCallback("playerNoteHit", [Math.abs(note.noteData), note.isSustainNote, note.mustPress, note.noteType, note.ID]);
				} else {
					luaCallback("playerNoteHit", [Math.abs(note.noteData), note.isSustainNote, note.mustPress, note.noteType, note.ID]);
			#end

				if (note.noteData >= 0)
					health += 0.023;
				else
					health += 0.004;

				switch (note.noteData) {
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

			if (!note.isSustainNote) {
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
		#if sys
			luaCallback("preStepHit", []);
		#end

		super.stepHit();

		if (inst.time > Conductor.songPosition + 20 || inst.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}

		#if sys
			setLuaVar('curStep', curStep);
			luaCallback("stepHit", []);
		#end
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	override function beatHit()
	{
		if(beatHitCounter <= (curBeat - 1)) {
			#if sys
				luaCallback("preBeatHit", []);
			#end
		}

		super.beatHit();

		if(beatHitCounter > (curBeat - 1)) {
			return;
		} else {
			if (generatedMusic) {
				notes.sort(FlxSort.byY, (Options.downscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING));
			}

			if (SONG.notes[Math.floor(curStep / 16)] != null) {
				if (SONG.notes[Math.floor(curStep / 16)].changeBPM) {
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

			if (curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < minCamGameZoom) {
				FlxG.camera.zoom += camGameZoom;
				camHUD.zoom += camHUDZoom;
			}
			if (curSong.toLowerCase() == 'mombattle' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < minCamGameZoom) {
				FlxG.camera.zoom += camGameZoom;
				camHUD.zoom += camHUDZoom;
			}

			if (camZooming && FlxG.camera.zoom < minCamGameZoom && curBeat % 4 == 0) {
				FlxG.camera.zoom += camGameZoom;
				camHUD.zoom += camHUDZoom;
			}

			for(i in 0...UITexts.length) {
				if(UITexts[i].bounceTweenEnabled && UITexts[i].bounceTweenType.toLowerCase() == "beathit")
					UITexts[i].scale.set(UITexts[i].bounceTweenScale, UITexts[i].bounceTweenScale);
			}

			if(ThemeSupport.HealthbarEnabled && ThemeSupport.Healthbar.showIcons[0]) {
				iconP1.scale.set(1.2, 1.2);
				iconP1.updateHitbox();
			}
			if(ThemeSupport.HealthbarEnabled && ThemeSupport.Healthbar.showIcons[1]) {
				iconP2.scale.set(1.2, 1.2);
				iconP2.updateHitbox();
			}

			for(actor in ActorSprites) {
				if(actor != null && actor.animation.curAnim != null) {
					if(curBeat % actor.speed == 0) {
						if(!actor.animation.curAnim.name.startsWith("sing") && !actor.isSpecialAnim)
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
				setLuaVar('curBeat', curBeat);
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
		RFELuaArray = null;
		RFELuaArray = [];
		TargetActors = null;
		TargetActors = new Map<String, String>();
	}

	function setUpThemeSupport() {
		UITexts = [];
		// No need to worry about destroying anything, another map takes care of it.
		UIElements = new Map<String, Dynamic>();
	}

	function setUpTweens() {
		if(themeBounceTweens != null) {
			for(tween in themeBounceTweens) {
				tween.destroy();
			}
		}
		themeBounceTweens = null;
		themeBounceTweens = new Map<ThemeText, FlxTween>();
		if(themeScrollTweens != null) {
			for(tween in themeScrollTweens) {
				tween.destroy();
			}
		}
		themeScrollTweens = null;
		themeScrollTweens = new Map<ThemeText, FlxTween>();
		for(i in 0...UITexts.length) {
			// nulls, other stuff takes care of this
			if(UITexts[i].bounceTweenEnabled)
				themeBounceTweens[UITexts[i]] = null;
			if(UITexts[i].scrolls)
				themeScrollTweens[UITexts[i]] = null;
		}
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
		for(i in 0...RFELuaArray.length) {
			RFELuaArray[i].setVar(variable, value);
		}
	}

	public function luaCallback(eventToCheck:String, arguments:Array<Dynamic>) {
		for(i in 0...RFELuaArray.length) {
			RFELuaArray[i].luaCallback(eventToCheck, arguments);
		}
	}

	public function stopLua() {
		for(i in 0...RFELuaArray.length) {
			RFELuaArray[i].stopLua();
		}
	}

	function replaceStageVarsInTheme(strung:String):String {
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
			uh = StringTools.replace(uh, "[version]", Application.current.meta.get('version'));
   	     	uh = StringTools.replace(uh, "[width]", Std.string(FlxG.width));
		}

        return uh;
	}

	function loadDevs() {
		var rawJsonFile:String;

		rawJsonFile = Utilities.getFileContents("./assets/data/devs.json");
		rawJsonFile = rawJsonFile.trim();

		while (!rawJsonFile.endsWith("}")) {
			rawJsonFile = rawJsonFile.substr(0, rawJsonFile.length - 1);
		}
	
		trace(rawJsonFile);
	
		var json:Developers = cast Json.parse(rawJsonFile);

		randomDevs = json.devs;

		json = null;
	}
}

class ThemeText extends FlxText {
	// I know this is a lot, but I swear it's worth it.
	public var bounceTweenEnabled:Bool;
	public var bounceTweenScale:Float;
	public var bounceTweenType:String;
	public var center:Array<Bool> = [];
	public var fades:Bool;
	public var fromHeight:Bool;
	public var fromWidth:Bool;
	public var inPlace:Bool = false;
	public var ogX:Float;
	public var ogY:Float;
	public var scrolls:Bool;
	public var texts:Array<String> = [];
}
