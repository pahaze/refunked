package preview;

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
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
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

typedef Developers2 = {
	var devs:Array<String>;
}

class PreviewTheme extends MusicBeatState {
    public static var SONG:SwagSong;
    var inst:FlxSound;
	var vocals:FlxSound;
    private var generatedMusic:Bool = false;
    private var startingSong:Bool = false;
    public static var storyDifficulty:Int = 2;
	var beatHitCounter:Int = -1;

    private var notes:FlxTypedGroup<PreviewNote>;
	private var unspawnNotes:Array<PreviewNote> = [];

	private var strumLine:FlxSprite;
    private var strumLineNotes:FlxTypedGroup<FlxSprite>;
	private var playerStrums:FlxTypedGroup<FlxSprite>;
	private var cpuStrums:FlxTypedGroup<FlxSprite>;

    private var camZooming:Bool = false;

    private var health:Float = 1;
	private var combo:Int = 0;
	private var maxCombo:Int = 0;
    private var curSection:Int = 0;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;
    var scoreTxt:FlxText;

    private var curSong:String = "";
    private var iconP1:HealthIcon;
	private var iconP2:HealthIcon;
    var previousFrameTime:Int = 0;
	var songTime:Float = 0;
    var startedCountdown:Bool = false;
    var startTimer:FlxTimer;

	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;

	var loadingSongAlphaScreen:FlxSprite;
	var loadingSongText:FlxText;
	var stuffLoaded:Bool = false;
	var returnText:FlxText;
	var enabBotplayText:FlxText;

    // Stuff from PlayState
	// Camera zooms
	public var defaultCamZoom:Float = 1.05;
	public var camHUDZoom:Float = 0.03;
	public var camGameZoom:Float = 0.015;
	public var minCamGameZoom:Float = 1.35;

	// Song details
    var m:String;
	var s:String;
	var songLength:Float = 0;
	var songPercentage:Float = 0;
	
	// Related to themes
    public static var bubbywidth:Float;
	public static var bubbyheight:Float;
	
	// Accuracy/NPS
    var accuracyThing:Float = 0;
	var hitArrayThing:Array<Date> = [];
	var funnyNPS:Int = 0;
	var funnyMaxNPS:Int = 0;
	
	// Themes
	var accTxt:FlxText;
	var botplaySine:Float = 0;
	var botplayTxt:FlxText;
	var iconP1Tween:FlxTween;
	var iconP2Tween:FlxTween;
	var missTxt:FlxText;
	var npsTxt:FlxText;
	var refunkedWatermark:FlxText;
	var scoreTxtTween:FlxTween;
	var storyDifficultyText:String = "";
	public var timeBar:FlxBar;
	private var timeBarBG:FlxSprite;
	var timeTxt:FlxText;
	var timeTxtTween:FlxTween;
	var watermarkInPlace:Bool = false;
	var watermarkTween:FlxTween;
	
	// Related to gameplay
    var songScore:Int = 0;
    var funnyRating:String;
	var notesRating:String;
    var goods:Int = 0;
	var bads:Int = 0;
	var awfuls:Int = 0;
	var misses:Int = 0;
	var accNotesToDivide:Int = 0;
	var accNotesTotal:Int = 0;
	var sicks:Int = 0;
	
	// Easter eggs cause we lovin them
	public static var randomDevs:Array<String> = [];
	var broDevSelector:Int;
	
	// Memory related stuff
	var dunceCount:Int = 0;
	static var ExtTexts:Map<String, FlxText> = new Map<String, FlxText>();
	private var PSLoadedAssets:Array<FlxBasic> = [];
	static var PTLoadedMap:Map<String, Dynamic> = new Map<String, Dynamic>();
	
	// Modes
	public static var PracticeMode:Bool = false;
	public static var botplayIsEnabled:Bool = false;

    // BG Sprite
    var bg:FlxSprite;

    override public function create()
    {
		OptionsMenu.nullOMLoadedAssets();
		Paths.nullPathsAssets();
		nullPTLoadedAssets();
		PTLoadedMap = new Map<String, Dynamic>();

        if (FlxG.sound.music != null)
			FlxG.sound.music.stop();
		
        Conductor.mapBPMChanges(SONG);
        Conductor.changeBPM(SONG.bpm);

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
        bg.color = FlxColor.fromRGB(FlxG.random.int(0, 255), FlxG.random.int(0, 255), FlxG.random.int(0, 255));
        bg.setGraphicSize(Std.int(bg.width * 1.1));
        add(bg);
		PTLoadedMap["bg"] = bg;

		Conductor.songPosition = -300000;

        strumLine = new FlxSprite((Options.middlescroll ? -272 : 48), (Options.downscroll ? FlxG.height - 150 : 50)).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();
		PTLoadedMap["strumLine"] = strumLine;

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<FlxSprite>();
		cpuStrums = new FlxTypedGroup<FlxSprite>();

		inst = new FlxSound().loadStream("./" + Paths.inst(PreviewTheme.SONG.song));

		if (SONG.needsVoices)
			vocals = new FlxSound().loadStream("./" + Paths.voices(PreviewTheme.SONG.song));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(inst);
		FlxG.sound.list.add(vocals);

		loadingSongAlphaScreen = new FlxSprite(0,0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		loadingSongAlphaScreen.visible = false;
		loadingSongAlphaScreen.alpha = 0.5;
		loadingSongAlphaScreen.scrollFactor.set();
		add(loadingSongAlphaScreen);
		PTLoadedMap["loadingSongAlphaScreen"] = loadingSongAlphaScreen;

		loadingSongText = new FlxText(0, 0, 0, "Loading instrumental and vocals...");
		loadingSongText.visible = false;
		loadingSongText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		loadingSongText.scrollFactor.set();
		add(loadingSongText);
		PTLoadedMap["loadingSongText"] = loadingSongText;

        switch (storyDifficulty)
		{
			case 0:
				storyDifficultyText = "EASY";
			case 1:
				storyDifficultyText = "NORMAL";
			case 2:
				storyDifficultyText = "HARD";
		}

        generateSong(SONG.song);

		loadDevs();

        FlxG.camera.zoom = defaultCamZoom;

        bubbywidth = FlxG.width;
		bubbyheight = FlxG.height;
        ThemeStuff.loadTheme();
		broDevSelector = Std.random(randomDevs.length);

		if(ThemeStuff.timeBarIsEnabled == true) {
			switch(ThemeStuff.timeBarStyle.toLowerCase()) {
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
			PTLoadedMap["timeTxt"] = timeTxt;
			PTLoadedMap["timeBar"] = timeBar;
			PTLoadedMap["timeBarBG"] = timeBarBG;
		}

        if(ThemeStuff.healthBarIsEnabled == true) {
			healthBarBG = new FlxSprite(Std.int(ThemeStuff.healthBarX), (Options.downscroll ? Std.int(ThemeStuff.healthBarDSY) : Std.int(ThemeStuff.healthBarY))).loadGraphic(Paths.image('healthBar'));
			if(ThemeStuff.healthBarCenter == true) {
				healthBarBG.screenCenter(X);
			}
			healthBarBG.scrollFactor.set();
			add(healthBarBG);
			PTLoadedMap["healthBarBG"] = healthBarBG;

			healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
				'health', 0, 2);
			healthBar.scrollFactor.set();
			healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
			// healthBar
			add(healthBar);
			PTLoadedMap["healthBar"] = healthBar;

			if(ThemeStuff.healthBarShowP1 == true) {
				iconP1 = new HealthIcon(SONG.player1, true);
				iconP1.y = healthBar.y - (iconP1.height / 2);
				add(iconP1);
				PTLoadedMap["iconP1"] = iconP1;
			}

			if(ThemeStuff.healthBarShowP2 == true) {
				iconP2 = new HealthIcon(SONG.player2, false);
				iconP2.y = healthBar.y - (iconP2.height / 2);
				add(iconP2);
				PTLoadedMap["iconP2"] = iconP2;
			}
		}

		if(ThemeStuff.accTextIsEnabled == true) {
			accTxt = new FlxText(ThemeStuff.accTextX, (Options.downscroll ? ThemeStuff.accTextDSY : ThemeStuff.accTextY), 0, "", 20);
			accTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			accTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 3, 1);
			accTxt.scrollFactor.set();
			add(accTxt);
			PTLoadedMap["accTxt"] = accTxt;
		}

		if(ThemeStuff.extraTextIsEnabled == true) {
			for(i in 0...ThemeStuff.extraTextLength) {
				var extraTxt:FlxText;
				extraTxt = new FlxText(ThemeStuff.extraTextX[i], (Options.downscroll ? ThemeStuff.extraTextDSY[i] : ThemeStuff.extraTextY[i]), 0, "", 20);
				extraTxt.setFormat(Paths.font("vcr.ttf"), ThemeStuff.extraFontsize[i], FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				extraTxt.scrollFactor.set();
				add(extraTxt);
				extraTxt.cameras = [camHUD];
				ExtTexts["extraTxt" + i] = extraTxt;
			}
		}

		if(ThemeStuff.missTextIsEnabled == true) {
			missTxt = new FlxText(ThemeStuff.missTextX, (Options.downscroll ? ThemeStuff.missTextDSY : ThemeStuff.missTextY), 0, "", 20);
			missTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			missTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 3, 1);
			missTxt.scrollFactor.set();
			add(missTxt);
			PTLoadedMap["missTxt"] = missTxt;
		}

		if(ThemeStuff.npsTextIsEnabled == true) {
			npsTxt = new FlxText(ThemeStuff.npsTextX, (Options.downscroll ? ThemeStuff.npsTextDSY : ThemeStuff.npsTextY), 0, "", 20);
			npsTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			npsTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 3, 1);
			npsTxt.scrollFactor.set();
			add(npsTxt);
			PTLoadedMap["npsTxt"] = npsTxt;
		}

		if(ThemeStuff.scoreTextIsEnabled == true) {
			scoreTxt = new FlxText(ThemeStuff.scoreTextX, (Options.downscroll ? ThemeStuff.scoreTextDSY : ThemeStuff.scoreTextY), 0, "", 20);
			scoreTxt.setFormat(Paths.font("vcr.ttf"), ThemeStuff.scoreTextFontsize, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			if(ThemeStuff.scoreTextBorder > 0)
				scoreTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, ThemeStuff.scoreTextBorder, 1);
			scoreTxt.scrollFactor.set();
			add(scoreTxt);
			PTLoadedMap["scoreTxt"] = scoreTxt;
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
			PTLoadedMap["botplayTxt"] = botplayTxt;
		}

		if(ThemeStuff.watermarkIsEnabled == true) {
			refunkedWatermark = new FlxText(ThemeStuff.watermarkX, (Options.downscroll ? ThemeStuff.watermarkDSY : ThemeStuff.watermarkY), 0, "", 16);
			refunkedWatermark.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			refunkedWatermark.scrollFactor.set();
			add(refunkedWatermark);
			PTLoadedMap["RFEWatermark"] = refunkedWatermark;
		}

		returnText = new FlxText(0, 0, 0, "This is a preview of your theme. Press ESC to return to the menu.", 32);
		returnText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		returnText.screenCenter();
		returnText.y = returnText.y - 16;
		returnText.visible = false;
		add(returnText);
		PTLoadedMap["returnText"] = returnText;

		enabBotplayText = new FlxText(0, returnText.y + 32, 0, "Press B to see a preview of BOTPLAY enabled. Press P to see a preview of PRACTICE mode enabled.", 32);
		enabBotplayText.setFormat(Paths.font("vcr.ttf"), 22, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		enabBotplayText.screenCenter(X);
		enabBotplayText.visible = false;
		add(enabBotplayText);
		PTLoadedMap["enabBotplayText"] = enabBotplayText;

		enabBotplayText.cameras = [camHUD];
		notes.cameras = [camHUD];
		returnText.cameras = [camHUD];
		strumLineNotes.cameras = [camHUD];
		if(ThemeStuff.accTextIsEnabled == true)
			accTxt.cameras = [camHUD];
		if(ThemeStuff.missTextIsEnabled == true)
			missTxt.cameras = [camHUD];
		if(ThemeStuff.npsTextIsEnabled == true)
			npsTxt.cameras = [camHUD];
		if(ThemeStuff.healthBarIsEnabled == true) {
			healthBar.cameras = [camHUD];
			healthBarBG.cameras = [camHUD];
			if(ThemeStuff.healthBarShowP1 == true)
				iconP1.cameras = [camHUD];
			if(ThemeStuff.healthBarShowP2 == true)
				iconP2.cameras = [camHUD];
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

        super.create();
    }

    function startCountdown():Void
	{	
        if(Options.middlescroll) {
			for(i in 0...cpuStrums.length) {
				cpuStrums.members[i].visible = false;
			}
			generateStaticArrows(1);
		} else {
			generateStaticArrows(0);
			generateStaticArrows(1);
		}

		startedCountdown = true;
        Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;
		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);

			var introAlts:Array<String> = introAssets.get('default');

            switch (swagCounter)

			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3'), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro2'), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro1'), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();

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
					FlxG.sound.play(Paths.sound('introGo'), 0.6);
					FlxG.sound.music.stop();
				case 4:
					returnText.visible = true;
					enabBotplayText.visible = true;
			}

			swagCounter += 1;
		}, 5);
	}

    override public function update(elapsed:Float)
	{
		if(inst.playing) {
			var huh = hitArrayThing.length - 1;
			while(huh >= 0) {
				var bro:Date = hitArrayThing[huh];
				if(bro != null && bro.getTime() + 1000 < Date.now().getTime()) {
					hitArrayThing.remove(bro);
				} else {
					huh = 0;
				}
				huh--;
			}
			funnyNPS = hitArrayThing.length; 
			if(funnyNPS > funnyMaxNPS) {
				funnyMaxNPS = funnyNPS;
			}
		}

		if (FlxG.keys.justPressed.B) {
			botplayIsEnabled = !botplayIsEnabled;
		}

		if (FlxG.keys.justPressed.P) {
			PracticeMode = !PracticeMode;
		}

		super.update(elapsed);

        if (controls.BACK) {
			FlxG.switchState(new OptionsMenu());
            unloadLoadedAssets();
            unloadMBSassets();
			inst.stop();
			vocals.stop();
        }

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

		if(stuffLoaded) {
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
				ExtTexts["extraTxt" + i].text = replaceStageVarsInTheme(ThemeStuff.extraText[i]);
				if(ThemeStuff.extraCenterX[i])
					ExtTexts["extraTxt" + i].screenCenter(X);
				if(ThemeStuff.extraCenterY[i])
					ExtTexts["extraTxt" + i].screenCenter(Y);
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
			botplayTxt.visible = botplayIsEnabled;
			if(botplayIsEnabled && ThemeStuff.botplayFadeInAndOut) {
				botplayTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);
			}
			if(ThemeStuff.botplayCenter == true) {
				botplayTxt.screenCenter(X);
			}
		}

		if(ThemeStuff.timeBarIsEnabled == true) {
			timeTxt.text = replaceStageVarsInTheme(ThemeStuff.timeBarText);
			if(ThemeStuff.timeBarCenter) {
				timeTxt.screenCenter(X);
			}
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


		playerStrums.forEach(function(spr:FlxSprite) {
			if(spr.animation.finished) {
				spr.animation.play('static');
				spr.centerOffsets();
			}
		});

        cpuStrums.forEach(function(spr:FlxSprite) {
            if(spr.animation.finished) {
                spr.animation.play('static');
                spr.centerOffsets();
            }
        });

		if(ThemeStuff.watermarkDoesScroll && ThemeStuff.watermarkIsEnabled && stuffLoaded) {
			if(refunkedWatermark.x == ThemeStuff.watermarkX) {
				watermarkInPlace = true;
				if(watermarkTween != null)
					watermarkTween.cancel();
				new FlxTimer().start(5, function(tmr:FlxTimer)
				{
					watermarkInPlace = false;
					if(refunkedWatermark.x < ThemeStuff.watermarkX + 1 && refunkedWatermark.x > ThemeStuff.watermarkX - 1)
						refunkedWatermark.x = refunkedWatermark.x - 1;
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

		if (inst.length < 1 && vocals.length < 1 && !startingSong) {
			loadingSongAlphaScreen.visible = true;
			loadingSongText.screenCenter();
			loadingSongText.visible = true;
		} 
		if (inst.length > 0 && vocals.length > 0 && !startingSong) {
			stuffLoaded = true;
			PTLoadedMap["inst"] = inst;
			PTLoadedMap["vocals"] = vocals;
		}

		if(stuffLoaded && !startedCountdown) {
			loadingSongText.text = "Loaded! Have fun.";
			loadingSongText.screenCenter();
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				remove(loadingSongAlphaScreen);
				remove(loadingSongText);
			}, 1);
			startingSong = true;
			startCountdown();
		}

        if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		} else {
    		Conductor.songPosition += FlxG.elapsed * 1000;
			songTime += FlxG.game.ticks - previousFrameTime;
			previousFrameTime = FlxG.game.ticks;
			if (Conductor.lastSongPos != Conductor.songPosition)
			{
				songTime = (songTime + Conductor.songPosition) / 2;
				Conductor.lastSongPos = Conductor.songPosition;
			}
			songPercentage = (Conductor.songPosition / songLength);
        }

        if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, FlxMath.bound(1 - (elapsed * 3), 0, 1));
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, FlxMath.bound(1 - (elapsed * 3), 0, 1));
		}

		FlxG.watch.addQuick("elapsed", elapsed);
		FlxG.watch.addQuick("beatStuff", curBeat);
		FlxG.watch.addQuick("stepStuff", curStep);

		while(unspawnNotes[0] != null) {
			if(unspawnNotes[0].strumTime - Conductor.songPosition < 1800 / SONG.speed) {
				var dunceNote:PreviewNote = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.shift();
				dunceCount++;

				PTLoadedMap.set("dunceNote" + index + dunceCount, dunceNote);
			} else {
				break;
			}
		}

		if (generatedMusic)
		{
			notes.forEachAlive(function(daNote:PreviewNote)
			{
				if(!daNote.mustPress && Options.middlescroll) {
					daNote.active = true;
					daNote.visible = false;
				} else if (daNote.y > FlxG.height) {
					daNote.active = false;
					daNote.visible = false;
				} else {
					daNote.visible = true;
					daNote.active = true;
				}

				if(Options.downscroll) {
					daNote.y = strumLine.y + 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(SONG.speed, 2);

					if(daNote.isSustainNote) {
						if (daNote.animation.curAnim.name.endsWith('end') && daNote.prevNote != null) {
							daNote.y += daNote.prevNote.height / 1.5;
						}

						if (daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= strumLine.y + Note.swagWidth / 2 && (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
						{
							var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
							swagRect.height = (strumLine.y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
							swagRect.y = daNote.frameHeight - swagRect.height;
							daNote.clipRect = swagRect;
						}
					}
				} else {
					daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(SONG.speed, 2)));

					if (daNote.isSustainNote && daNote.y + daNote.offset.y <= strumLine.y + Note.swagWidth / 2 && (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
					{
						var swagRect = new FlxRect(0, strumLine.y + Note.swagWidth / 2 - daNote.y, daNote.width * 2, daNote.height * 2);
						swagRect.y /= daNote.scale.y;
						swagRect.height -= swagRect.y;
						daNote.clipRect = swagRect;
					}
				}

				if (!daNote.mustPress && daNote.wasGoodHit)
				{
					camZooming = true;

					cpuStrums.forEach(function(spr:FlxSprite) {
						pressArrow(spr, spr.ID, daNote);
						if (spr.animation.curAnim.name == 'confirm')
							{
								spr.centerOffsets();
								spr.offset.x -= 13;
								spr.offset.y -= 13;
							}
					});

					if (SONG.needsVoices && vocals != null)
						vocals.volume = 1;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

				if(daNote.mustPress) {
					if(daNote.isSustainNote && daNote.canBeHit) {
						goodNoteHit(daNote);
					} else if(daNote.strumTime < inst.time && daNote.canBeHit) {
						goodNoteHit(daNote);
					}
				}
			});
		}
	}

    private function generateSong(dataPath:String):Void
	{
		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		notes = new FlxTypedGroup<PreviewNote>();
		add(notes);

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

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:PreviewNote;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:PreviewNote = new PreviewNote(daStrumTime, daNoteData, oldNote);
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:PreviewNote = new PreviewNote(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
					{
						sustainNote.x += FlxG.width / 2; // general offset
					}
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else {}
			}
			daBeats += 1;
		}

		unspawnNotes.sort(sortByStuff);

		generatedMusic = true;
	}

    function goodNoteHit(note:PreviewNote):Void
	{
		if (!note.wasGoodHit)
		{
			if (!note.isSustainNote)
			{
				popUpScore(note.strumTime);
				combo += 1;
				if(combo > 999)
					combo = 999;
				if(combo > maxCombo)
					maxCombo = combo;
			}

			if (note.noteData >= 0)
				health += 0.023;
			else
				health += 0.004;

			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (Math.abs(note.noteData) == spr.ID)
				{
					pressArrow(spr, spr.ID, note);
					if (spr.animation.curAnim.name == 'confirm')
					{
						spr.centerOffsets();
						spr.offset.x -= 13;
						spr.offset.y -= 13;
					}
				}
			});

			note.wasGoodHit = true;
			if(vocals != null)
				vocals.volume = 1;
			
			if (!note.isSustainNote)
			{
				hitArrayThing.unshift(Date.now());
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

    function sortByStuff(Obj1:PreviewNote, Obj2:PreviewNote):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

    override function beatHit()
	{
		super.beatHit();
	
		if(beatHitCounter > curBeat - 1) {
			return;
		} else {
			if (generatedMusic)
			{
				notes.sort(FlxSort.byY, (Options.downscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING));
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
		}
			
		beatHitCounter = curBeat;
	}

    override function stepHit()
	{
		super.stepHit();

		if (inst.time > Conductor.songPosition + 20 || inst.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}
    }

    private function popUpScore(strumtime:Float):Void
	{
		var noteDiff:Float = Math.abs(strumtime - Conductor.songPosition);
		if(vocals != null)
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

		rating.loadGraphic(Paths.image("" + daRating));
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image('combo'));
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;
		comboSpr.velocity.x += FlxG.random.int(1, 10);

		if(combo >= 10)
			add(comboSpr);
		add(rating);

		rating.setGraphicSize(Std.int(rating.width * 0.7));
		comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		seperatedScore.push(Math.floor(combo / 100));
		seperatedScore.push(Math.floor((combo - (seperatedScore[0] * 100)) / 10));
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image('num' + Std.int(i)));
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 160;
            numScore.antialiasing = true;
			numScore.setGraphicSize(Std.int(numScore.width * 0.5));
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

		curSection += 1;
	}

    private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			var babyArrow:FlxSprite = new FlxSprite((Options.middlescroll ? -272 : 50), strumLine.y);

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
			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			if (player == 1)
			{
				playerStrums.add(babyArrow);
			} else {
				if(!Options.middlescroll)
					cpuStrums.add(babyArrow);
			}

			cpuStrums.forEach(function(spr:FlxSprite)
			{
				spr.centerOffsets(); // CPU arrows start out slightly off-center
			});

			babyArrow.animation.play('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * player);

			strumLineNotes.add(babyArrow);
		}
    }

	function pressArrow(spr:FlxSprite, idCheck:Int, daNote:PreviewNote)
	{
		if (Math.abs(daNote.noteData) == idCheck)
		{
			spr.animation.play('confirm');
		}
	}

    function resyncVocals():Void
	{
		vocals.pause();

		inst.play();
		Conductor.songPosition = inst.time;
		vocals.time = inst.time;
		vocals.play();
	}

    function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;

		inst.play();
		vocals.play();
		inst.onComplete = endSong;

		// Song duration in a float, useful for the time left feature
		songLength = inst.length;
	}

    function endSong():Void {
        if(inst != null || vocals != null) {
			inst.volume = 0;
			vocals.volume = 0;
		}

        unloadLoadedAssets();
        unloadMBSassets();

        FlxG.switchState(new OptionsMenu());
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
			uh = StringTools.replace(uh, "[randomdev]", randomDevs[broDevSelector]);
			uh = StringTools.replace(uh, "[score]", Std.string(songScore));
			uh = StringTools.replace(uh, "[sec]", s);
			uh = StringTools.replace(uh, "[sicks]", Std.string(sicks));
			uh = StringTools.replace(uh, "[song]", SONG.song);
   	     	uh = StringTools.replace(uh, "[width]", Std.string(FlxG.width));
		}

        return uh;
	}

	function replaceStageFloatVarsInTheme(strung:String) {
		var uh:String = strung;
		if(uh != null) {
			uh = StringTools.replace(uh, "[min]", m);
			uh = StringTools.replace(uh, "[sec]", s);
			uh = StringTools.replace(uh, "[height]", Std.string(bubbywidth));
        	uh = StringTools.replace(uh, "[width]", Std.string(bubbyheight));
		}

        return Std.parseFloat(uh);
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

            var json:Developers2 = cast Json.parse(rawJsonFile);
    	#else
			rawJsonFile = Utilities.getFileContents("./assets/data/devs.json");
            rawJsonFile = rawJsonFile.trim();
        
            while (!rawJsonFile.endsWith("}"))
	    	{
	    		rawJsonFile = rawJsonFile.substr(0, rawJsonFile.length - 1);
	    	}

            trace(rawJsonFile);

            var json:Developers2 = cast Json.parse(rawJsonFile);
		#end

		randomDevs = json.devs;
	}

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

	public static function nullPTLoadedAssets():Void
	{
		if(PTLoadedMap != null) {
			for(sprite in PTLoadedMap) {
				sprite.destroy();
			}
		}
		PTLoadedMap = null;
	}

    override function destroy() {
        FlxG.sound.music.stop();
        inst.stop();
        vocals.stop();
        super.destroy();
	}
}
