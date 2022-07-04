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
import lime.app.Application;
import lime.utils.Assets;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
import themes.ThemeSupport;

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
    var scoreTxt:PreviewThemeText;

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

	// Themes
	var accTxt:PreviewThemeText;
	var accuracyThing:Float = 0;
	var botplaySine:Float = 0;
	var botplayTxt:PreviewThemeText;
	public static var bubbyheight:Float;
	public static var bubbywidth:Float;
	var funnyMaxNPS:Int = 0;
	var funnyNPS:Int = 0;
	var gameMode:Int;
	var hitArrayThing:Array<Date> = [];
	var m:String;
	var missTxt:PreviewThemeText;
	var npsTxt:PreviewThemeText;
	var s:String;
	var scrollVersion:Int;
	var songLength:Float = 0;
	var songPercentage:Float = 0;
	var storyDifficultyText:String;
	var tempText:String;
	var themeBounceTweens:Map<PreviewThemeText, FlxTween> = new Map<PreviewThemeText, FlxTween>();
	var themeScrollTweens:Map<PreviewThemeText, FlxTween> = new Map<PreviewThemeText, FlxTween>();
	public var timeBar:FlxBar;
	private var timeBarBG:FlxSprite;
	var timeTxt:PreviewThemeText;
	public var UITexts:Array<PreviewThemeText> = [];
	public var UIElements:Map<String, Dynamic> = new Map<String, Dynamic>();
	
	// Tweens
	var iconP1Tween:FlxTween;
	var iconP2Tween:FlxTween;

	// Watermark
	var refunkedWatermark:PreviewThemeText;

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
	var devSelector:Int;
	
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

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		FlxG.fixedTimestep = false;

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

					timeTxt = new PreviewThemeText(0, timeBarBG.y, 0, "", 16);
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

					timeTxt = new PreviewThemeText(0, (Options.downscroll ? timeBarBG.y - timeBarBG.height - 1 : timeBarBG.y + timeBarBG.height + 1), 0, "", 16);
					timeTxt.setFormat(ThemeSupport.Timebar.text.customization.font, ThemeSupport.Timebar.text.customization.fontsize, FlxColor.fromString(ThemeSupport.Timebar.text.customization.color), Utilities.getTextAlignment(ThemeSupport.Timebar.text.customization.alignment), Utilities.getBorderStyle(ThemeSupport.Timebar.text.customization.border.style), FlxColor.fromString(ThemeSupport.Timebar.text.customization.border.color));
					timeTxt.borderSize = ThemeSupport.Timebar.text.customization.border.size;
					timeTxt.scrollFactor.set();
					add(timeTxt);
				case "psych":
					timeTxt = new PreviewThemeText(ThemeSupport.Timebar.x[scrollVersion], ThemeSupport.Timebar.y[scrollVersion], 0, "", 32);
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
					timeTxt = new PreviewThemeText(ThemeSupport.Timebar.x[scrollVersion], ThemeSupport.Timebar.y[scrollVersion], 0, "", 32);
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
			PTLoadedMap["timeTxt"] = timeTxt;
			UIElements["timetxt"] = timeTxt;
			UITexts.push(timeTxt);
			PTLoadedMap["timeBar"] = timeBar;
			UIElements["timebar"] = timeBar;
			PTLoadedMap["timeBarBG"] = timeBarBG;
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
			PTLoadedMap["healthBarBG"] = healthBarBG;
			UIElements["healthbarbg"] = healthBarBG;

			healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this, 'health', 0, 2);
			healthBar.scrollFactor.set();
			healthBar.createFilledBar(FlxColor.fromString(ThemeSupport.Healthbar.colors[0]), FlxColor.fromString(ThemeSupport.Healthbar.colors[1]));
			add(healthBar);
			PTLoadedMap["healthBar"] = healthBar;
			UIElements["healthbar"] = healthBar;

			if(ThemeSupport.Healthbar.showIcons[0]) {
				iconP1 = new HealthIcon(SONG.player1, true);
				iconP1.y = healthBar.y - (iconP1.height / 2);
				add(iconP1);
				PTLoadedMap["iconP1"] = iconP1;
				UIElements["iconp1"] = iconP1;
			}

			if(ThemeSupport.Healthbar.showIcons[1]) {
				iconP2 = new HealthIcon(SONG.player2, false);
				iconP2.y = healthBar.y - (iconP2.height / 2);
				add(iconP2);
				PTLoadedMap["iconP2"] = iconP2;
				UIElements["iconp2"] = iconP2;
			}
		}

		if(ThemeSupport.AccuracyTextEnabled) {
			accTxt = new PreviewThemeText(ThemeSupport.AccuracyText.x[scrollVersion], ThemeSupport.AccuracyText.y[scrollVersion], 0, "", 20);
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
			PTLoadedMap["accTxt"] = accTxt;
			UIElements["acctxt"] = accTxt;
			UITexts.push(accTxt);
		}

		if(ThemeSupport.ExtraTextEnabled) {
			for(i in 0...ThemeSupport.ExtraText.length) {
				var extraTxt:PreviewThemeText;
				extraTxt = new PreviewThemeText(ThemeSupport.ExtraText[i].x[scrollVersion], ThemeSupport.ExtraText[i].y[scrollVersion], 0, "", 20);
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
				PTLoadedMap["extraTxt" + i] = extraTxt;
				UIElements["extratxt" + i] = extraTxt;
				UITexts.push(extraTxt);
			}
		}

		if(ThemeSupport.MissTextEnabled) {
			missTxt = new PreviewThemeText(ThemeSupport.MissText.x[scrollVersion], ThemeSupport.MissText.y[scrollVersion], 0, "", 20);
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
			PTLoadedMap["missTxt"] = missTxt;
			UIElements["misstxt"] = missTxt;
			UITexts.push(missTxt);
		}

		if(ThemeSupport.NPSTextEnabled == true) {
			npsTxt = new PreviewThemeText(ThemeSupport.NPSText.x[scrollVersion], ThemeSupport.NPSText.y[scrollVersion], 0, "", 20);
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
			PTLoadedMap["npsTxt"] = npsTxt;
			UIElements["npstxt"] = npsTxt;
			UITexts.push(npsTxt);
		}

		if(ThemeSupport.ScoreEnabled == true) {
			scoreTxt = new PreviewThemeText(ThemeSupport.Score.x[scrollVersion], ThemeSupport.Score.y[scrollVersion], 0, "", 20);
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
			PTLoadedMap["scoreTxt"] = scoreTxt;
			UIElements["scoretxt"] = scoreTxt;
			UITexts.push(scoreTxt);
		}

		if(ThemeSupport.BotplayEnabled == true) {
			botplayTxt = new PreviewThemeText(ThemeSupport.Botplay.x[scrollVersion], ThemeSupport.Botplay.y[scrollVersion], 0, "", 20);
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
			PTLoadedMap["botplayTxt"] = botplayTxt;
			UIElements["botplaytxt"] = botplayTxt;
			UITexts.push(botplayTxt);
		}

		if(ThemeSupport.WatermarkEnabled == true) {
			refunkedWatermark = new PreviewThemeText(ThemeSupport.Watermark.x[scrollVersion], ThemeSupport.Watermark.y[scrollVersion], 0, "", 20);
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
			PTLoadedMap["RFEWatermark"] = refunkedWatermark;
			UIElements["watermarkTxt"] = refunkedWatermark;
			UITexts.push(refunkedWatermark);
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
		returnText.cameras = [camHUD];
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
			if(ThemeSupport.Healthbar.showIcons[0])
				iconP1.cameras = [camHUD];
			if(ThemeSupport.Healthbar.showIcons[1])
				iconP2.cameras = [camHUD];
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

		setUpTweens();

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
		// Game mode is constantly updating so the game knows what text to use.
		gameMode = (PracticeMode ? (botplayIsEnabled ? 3 : 2) : (botplayIsEnabled ? 1 : 0));

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

		funnyRating = Utilities.calculateThemeRating(accuracyThing, ThemeSupport.RatingStyle);

		for(i in 0...UITexts.length) {
			tempText = replaceStageVarsInTheme(UITexts[i].texts[gameMode]);
			if(UITexts[i].text != tempText)
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

		botplaySine += 180 * elapsed;
		var alpher:Float = 1 - Math.sin(botplaySine / 180);
		for(i in 0...UITexts.length) {
			if(UITexts[i].fades) {
				UITexts[i].alpha = alpher;
			}
		}

		if(ThemeSupport.BotplayEnabled == true) {
			botplayTxt.visible = botplayIsEnabled;
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

		if(stuffLoaded) {
			for(i in 0...UITexts.length)
				if(UITexts[i].scrolls) {
					if(UITexts[i].x == UITexts[i].ogX) {
						UITexts[i].inPlace = true;
						if(themeScrollTweens[UITexts[i]] != null)
							themeScrollTweens[UITexts[i]].cancel();
						new FlxTimer().start(5, function(tmr:FlxTimer) {
							UITexts[i].inPlace = false;
							if(UITexts[i].x < UITexts[i].ogX + 1 && UITexts[i].x > UITexts[i].ogX - 1)
								UITexts[i].x = UITexts[i].x - 1;
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
		}

		for(i in 0...UITexts.length) {
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

					if (daNote.isSustainNote) {
						if (daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= strumLine.y + PreviewNote.swagWidth / 2 && (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
						{
							var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
							swagRect.height = (strumLine.y + PreviewNote.swagWidth / 2 - daNote.y) / daNote.scale.y;
							swagRect.y = daNote.frameHeight - swagRect.height;
							daNote.clipRect = swagRect;
						}
					}
				} else {
					daNote.y = strumLine.y - 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(SONG.speed, 2);

					if(daNote.isSustainNote) {
						if (daNote.y + daNote.offset.y <= strumLine.y + PreviewNote.swagWidth / 2 && (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
						{
							var swagRect = new FlxRect(0, strumLine.y + PreviewNote.swagWidth / 2 - daNote.y, daNote.width * 2, daNote.height * 2);
							swagRect.y /= daNote.scale.y;
							swagRect.height -= swagRect.y;
							daNote.clipRect = swagRect;
						}
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

	function checkUITextX(UIText:PreviewThemeText) {
		if(UIText.x != (FlxG.width - UIText.width - UIText.ogX))
			UIText.x = (FlxG.width - UIText.width - UIText.ogX);
	}

	function checkUITextY(UIText:PreviewThemeText) {
		if(UIText.y != (FlxG.height - UIText.height - UIText.ogY))
			UIText.y = (FlxG.height - UIText.height - UIText.ogY);
	}

	function getEndAddAmt(daNote:PreviewNote, prevNote:PreviewNote) {
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

	function getSustainAddAmt(daNote:PreviewNote, prevNote:PreviewNote) {
		var daNoteY:Float;
		var prevNoteY:Float;
		if(Options.downscroll) {
			daNoteY = getNoteY(daNote) + daNote.height;
			prevNoteY = getNoteY(prevNote) + (PreviewNote.swagWidth / 2);
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
			prevNoteY = getNoteY(prevNote) + (PreviewNote.swagWidth / 2);
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

	function getNoteY(daNote:PreviewNote):Float {
		// General note values, just for simplicity sake
		if(Options.downscroll)
			return 50 + 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(SONG.speed, 2);
		else
			return 50 - 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(SONG.speed, 2);
	}

	function handleNoteAdding(daNote:PreviewNote, prevNote:PreviewNote) {
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
		for(i in 0...unspawnNotes.length) {
			if(unspawnNotes[i].isSustainNote) {
				if(unspawnNotes[i].prevNote != null) {
					handleNoteAdding(unspawnNotes[i], unspawnNotes[i].prevNote);
				}
			}
		}
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
			if (generatedMusic) {
				notes.sort(FlxSort.byY, (Options.downscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING));
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
					babyArrow.x += PreviewNote.swagWidth * 0;
					babyArrow.animation.addByPrefix('static', 'arrow static instance 1');
					babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
				case 1:
					babyArrow.x += PreviewNote.swagWidth * 1;
					babyArrow.animation.addByPrefix('static', 'arrow static instance 2');
					babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
				case 2:
					babyArrow.x += PreviewNote.swagWidth * 2;
					babyArrow.animation.addByPrefix('static', 'arrow static instance 4');
					babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
				case 3:
					babyArrow.x += PreviewNote.swagWidth * 3;
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
		themeBounceTweens = new Map<PreviewThemeText, FlxTween>();
		if(themeScrollTweens != null) {
			for(tween in themeScrollTweens) {
				tween.destroy();
			}
		}
		themeScrollTweens = null;
		themeScrollTweens = new Map<PreviewThemeText, FlxTween>();
		for(i in 0...UITexts.length) {
			// nulls, other stuff takes care of this
			if(UITexts[i].bounceTweenEnabled)
				themeBounceTweens[UITexts[i]] = null;
			if(UITexts[i].scrolls)
				themeScrollTweens[UITexts[i]] = null;
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
			uh = StringTools.replace(uh, "[song]", SONG.song);
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
	
		var json:Developers2 = cast Json.parse(rawJsonFile);

		randomDevs = json.devs;

		json = null;
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

class PreviewThemeText extends FlxText {
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
