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

    private var notes:FlxTypedGroup<BruhNote>;
	private var unspawnNotes:Array<BruhNote> = [];

	private var strumLine:FlxSprite;
    private var strumLineNotes:FlxTypedGroup<FlxSprite>;
	private var playerStrums:FlxTypedGroup<FlxSprite>;
	private var cpuStrums:FlxTypedGroup<FlxSprite>;

    private var camZooming:Bool = false;
    var defaultCamZoom:Float = 1;

    private var health:Float = 1;
	private var combo:Int = 0;
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

	var loadingSongAlphaScreen:FlxSprite;
	var loadingSongText:FlxText;
	var stuffLoaded:Bool = false;
	var returnText:FlxText;
	var enabBotplayText:FlxText;

    // Stuff from PlayState
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
	var extraTxt:FlxText;
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
	// easter eggs cause we lovin them
	public static var bfEasterEggEnabled:Bool = false;
	public static var devEasterEggEnabled:Bool = false;
	public static var duoDevEasterEggEnabled:Bool = false;
	public static var dadEasterEggEnabled:Bool = false;
	public static var randomDevs:Array<String> = [];
	var broDevSelector:Int;
	// memory stuff ?
	private var PSLoadedAssets:Array<FlxBasic> = [];
	// funky modes
	public static var PracticeMode:Bool = false;
	public static var botplayIsEnabled:Bool = false;

    // sprites or whatever or something i don't even Know
    var bg:FlxSprite;

    override public function create()
    {
        if (FlxG.sound.music != null)
			FlxG.sound.music.stop();
		
        Conductor.mapBPMChanges(SONG);
        Conductor.changeBPM(SONG.bpm);

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
        bg.color = FlxColor.fromRGB(FlxG.random.int(0, 255), FlxG.random.int(0, 255), FlxG.random.int(0, 255));
        bg.setGraphicSize(Std.int(bg.width * 1.1));
        add(bg);

		Conductor.songPosition = -300000;

        strumLine = new FlxSprite((Options.middlescroll ? -272 : 48), (Options.downscroll ? FlxG.height - 150 : 50)).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

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

		loadingSongText = new FlxText(0, 0, 0, "Loading instrumental and vocals...");
		loadingSongText.visible = false;
		loadingSongText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		loadingSongText.scrollFactor.set();
		add(loadingSongText);

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
		}

        if(ThemeStuff.healthBarIsEnabled == true) {
			healthBarBG = new FlxSprite(Std.int(ThemeStuff.healthBarX), (Options.downscroll ? Std.int(ThemeStuff.healthBarDSY) : Std.int(ThemeStuff.healthBarY))).loadGraphic(Paths.image('previewAssets/healthBar'));
			if(ThemeStuff.healthBarCenter == true) {
				healthBarBG.screenCenter(X);
			}
			healthBarBG.scrollFactor.set();
			add(healthBarBG);

			healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
				'health', 0, 2);
			healthBar.scrollFactor.set();
			healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
			// healthBar
			add(healthBar);

			if(ThemeStuff.healthBarShowP1 == true) {
				if(bfEasterEggEnabled) {
					iconP1 = new HealthIcon('bf-old', true);
				} else if(devEasterEggEnabled) {
					iconP1 = new HealthIcon('pahaze', true);
				} else if(duoDevEasterEggEnabled) {
					iconP1 = new HealthIcon('redwick-pahaze', true);
				} else {
					iconP1 = new HealthIcon(SONG.player1, true);
				}
				iconP1.y = healthBar.y - (iconP1.height / 2);
				add(iconP1);
			}

			if(ThemeStuff.healthBarShowP2 == true) {
				if(dadEasterEggEnabled) {
					iconP2 = new HealthIcon('dad', false);
				} else {
					iconP2 = new HealthIcon(SONG.player2, false);
				}
				iconP2.y = healthBar.y - (iconP2.height / 2);
				add(iconP2);
			}
		}

		if(ThemeStuff.accTextIsEnabled == true) {
			accTxt = new FlxText(ThemeStuff.accTextX, (Options.downscroll ? ThemeStuff.accTextDSY : ThemeStuff.accTextY), 0, "", 20);
			accTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			accTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 3, 1);
			accTxt.scrollFactor.set();
			add(accTxt);
		}

		if(ThemeStuff.extraTextIsEnabled == true) {
			extraTxt = new FlxText(ThemeStuff.extraTextX, (Options.downscroll ? ThemeStuff.extraTextDSY : ThemeStuff.extraTextY), 0, "", 20);
			extraTxt.setFormat(Paths.font("vcr.ttf"), ThemeStuff.extraFontsize, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			extraTxt.scrollFactor.set();
			add(extraTxt);
		}

		if(ThemeStuff.missTextIsEnabled == true) {
			missTxt = new FlxText(ThemeStuff.missTextX, (Options.downscroll ? ThemeStuff.missTextDSY : ThemeStuff.missTextY), 0, "", 20);
			missTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			missTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 3, 1);
			missTxt.scrollFactor.set();
			add(missTxt);
		}

		if(ThemeStuff.npsTextIsEnabled == true) {
			npsTxt = new FlxText(ThemeStuff.npsTextX, (Options.downscroll ? ThemeStuff.npsTextDSY : ThemeStuff.npsTextY), 0, "", 20);
			npsTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			npsTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 3, 1);
			npsTxt.scrollFactor.set();
			add(npsTxt);
		}

		if(ThemeStuff.scoreTextIsEnabled == true) {
			scoreTxt = new FlxText(ThemeStuff.scoreTextX, (Options.downscroll ? ThemeStuff.scoreTextDSY : ThemeStuff.scoreTextY), 0, "", 20);
			scoreTxt.setFormat(Paths.font("vcr.ttf"), ThemeStuff.scoreTextFontsize, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			if(ThemeStuff.scoreTextBorder > 0)
				scoreTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, ThemeStuff.scoreTextBorder, 1);
			scoreTxt.scrollFactor.set();
			add(scoreTxt);
		}

		if(ThemeStuff.botplayTextIsEnabled == true) {
			botplayTxt = new FlxText(ThemeStuff.botplayTextX, (Options.downscroll ? ThemeStuff.botplayTextDSY : ThemeStuff.botplayTextY), FlxG.width - 800, ThemeStuff.botplayText, 32);
			if(Options.themeData == "psych" && Options.middlescroll) {
				if(Options.downscroll == true) {
					botplayTxt.y = botplayTxt.y -= 100;
				} else {
					botplayTxt.y = botplayTxt.y += 100;
				}
			}
			botplayTxt.setFormat(Paths.font("vcr.ttf"), ThemeStuff.botplayFontsize, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			botplayTxt.scrollFactor.set();
			botplayTxt.borderSize = 1.25;
			botplayTxt.visible = botplayIsEnabled;
			add(botplayTxt);
		}

		if(ThemeStuff.watermarkIsEnabled == true) {
			refunkedWatermark = new FlxText(ThemeStuff.watermarkX, (Options.downscroll ? ThemeStuff.watermarkDSY : ThemeStuff.watermarkY), 0, "", 16);
			refunkedWatermark.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			refunkedWatermark.scrollFactor.set();
			add(refunkedWatermark);
		}

		returnText = new FlxText(0, 0, 0, "This is a preview of your theme. Press ESC to return to the menu.", 32);
		returnText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		returnText.screenCenter();
		returnText.y = returnText.y - 16;
		returnText.visible = false;
		add(returnText);

		enabBotplayText = new FlxText(0, returnText.y + 32, 0, "Press B to see a preview of BOTPLAY enabled. Press P to see a preview of PRACTICE mode enabled.", 32);
		enabBotplayText.setFormat(Paths.font("vcr.ttf"), 22, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		enabBotplayText.screenCenter(X);
		enabBotplayText.visible = false;
		add(enabBotplayText);

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
			introAssets.set('default', ['previewAssets/ready', "previewAssets/set", "previewAssets/go"]);

			var introAlts:Array<String> = introAssets.get('default');

            switch (swagCounter)

			{
				case 0:
					FlxG.sound.play(Paths.sound('previewSounds/intro3'), 0.6);
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
					FlxG.sound.play(Paths.sound('previewSounds/intro2'), 0.6);
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
					FlxG.sound.play(Paths.sound('previewSounds/intro1'), 0.6);
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
					FlxG.sound.play(Paths.sound('previewSounds/introGo'), 0.6);
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
		if (FlxG.keys.justPressed.NINE) {
			if (iconP1.animation.curAnim.name == 'bf-old') {
				iconP1.animation.play(SONG.player1);
			} else {
				iconP1.animation.play('bf-old');
			}
			bfEasterEggEnabled = !bfEasterEggEnabled;
			devEasterEggEnabled = false;
			duoDevEasterEggEnabled = false;
		}

		if (FlxG.keys.justPressed.EIGHT) {
			if (iconP2.animation.curAnim.name == 'dad') {
				iconP2.animation.play(SONG.player2);
			} else {
				iconP2.animation.play('dad');
			}
			dadEasterEggEnabled = !dadEasterEggEnabled;
		}
		
		if (FlxG.keys.justPressed.TWO) {
			if (iconP1.animation.curAnim.name == 'redwick-pahaze') {
				iconP1.animation.play(SONG.player1);
			} else {
				iconP1.animation.play('redwick-pahaze');
			}
			bfEasterEggEnabled = false;
			devEasterEggEnabled = false;
			duoDevEasterEggEnabled = !duoDevEasterEggEnabled;
		}

		if (FlxG.keys.justPressed.ONE) {
			if (iconP1.animation.curAnim.name == 'pahaze') {
				iconP1.animation.play(SONG.player1);
			} else {
				iconP1.animation.play('pahaze');
			}
			bfEasterEggEnabled = false;
			devEasterEggEnabled = !devEasterEggEnabled;
			duoDevEasterEggEnabled = false;
		}

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
            inst.destroy();
			vocals.destroy();
            vocals.destroy();
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

		switch(ThemeStuff.ratingStyle) {
			case "psych":
				if(accuracyThing < 20) {
					funnyRating = "You Suck!";
				} else if(accuracyThing >= 20 && accuracyThing < 40) {
					funnyRating = "Awful";
				} else if(accuracyThing >= 40 && accuracyThing < 50) {
					funnyRating = "Bad";
				} else if(accuracyThing >= 50 && accuracyThing < 60) {
					funnyRating = "Bruh";
				} else if(accuracyThing >= 60 && accuracyThing < 69) {
					funnyRating = "Meh";
				} else if(accuracyThing >= 69 && accuracyThing < 70) {
					funnyRating = "Nice";
				} else if(accuracyThing >= 70 && accuracyThing < 80) {
					funnyRating = "Good";
				} else if(accuracyThing >= 80 && accuracyThing < 90) {
					funnyRating = "Great";
				} else if(accuracyThing >= 90 && accuracyThing < 100) {
					funnyRating = "Sick!";
				} else if(accuracyThing == 100) {
					funnyRating = "Perfect!!";
				}
			case "kadeold" | "kadenew":
				if(accuracyThing < 60) {
					funnyRating = "D";
				} else if(accuracyThing >= 60 && accuracyThing < 70) {
					funnyRating = "C";
				} else if(accuracyThing >= 70 && accuracyThing < 80) {
					funnyRating = "B";
				} else if(accuracyThing >= 80 && accuracyThing < 85) {
					funnyRating = "A";
				} else if(accuracyThing >= 85 && accuracyThing < 90) {
					funnyRating = "A.";
				} else if(accuracyThing >= 90 && accuracyThing < 93) {
					funnyRating = "A:";
				} else if(accuracyThing >= 93 && accuracyThing < 96.5) {
					funnyRating = "AA";
				} else if(accuracyThing >= 96.5 && accuracyThing < 99) {
					funnyRating = "AA.";
				} else if(accuracyThing >= 99 && accuracyThing < 99.7) {
					funnyRating = "AA:";
				} else if(accuracyThing >= 99.7 && accuracyThing < 99.8) {
					funnyRating = "AAA";
				} else if(accuracyThing >= 99.8 && accuracyThing < 99.9) {
					funnyRating = "AAA.";
				} else if(accuracyThing >= 99.9 && accuracyThing < 99.95) {
					funnyRating = "AAA:";
				} else if(accuracyThing >= 99.95 && accuracyThing < 99.97) {
					funnyRating = "AAAA";
				} else if(accuracyThing >= 99.97 && accuracyThing < 99.98) {
					funnyRating = "AAAA.";
				} else if(accuracyThing >= 99.98 && accuracyThing < 99.99) {
					funnyRating = "AAAA:";
				} else if(accuracyThing >= 99.99) {
					funnyRating = "AAAAA";
				}
			case "forever":
				if(accuracyThing < 66) {
					funnyRating = "F";
				} else if(accuracyThing >= 66 && accuracyThing < 70) {
					funnyRating = "E";
				} else if(accuracyThing >= 70 && accuracyThing < 76) {
					funnyRating = "D";
				} else if(accuracyThing >= 76 && accuracyThing < 81) {
					funnyRating = "C";
				} else if(accuracyThing >= 81 && accuracyThing < 86) {
					funnyRating = "B";
				} else if(accuracyThing >= 86 && accuracyThing < 91) {
					funnyRating = "A";
				} else if(accuracyThing >= 91 && accuracyThing < 96) {
					funnyRating = "S";
				} else if(accuracyThing >= 96) {
					funnyRating = "S+";
				}
			case "RFE":
				switch(misses) {
					case 0:
						if(awfuls > 0) {
							funnyRating = "AFC";
						} else if(bads > 0) {
							funnyRating = "FC";
						} else if(goods > 0) {
							funnyRating = "GFC";
						} else {
							funnyRating = "SFC";
						}
					default:
						if(misses < 10 && misses > 0) {
							funnyRating = "SDCB";
						} else if(misses > 9) {
							funnyRating = "Clear";
						}
				}
			case "tr1ngle":
				if(accuracyThing < 21) {
					funnyRating = "F";
				} else if(accuracyThing >= 21 && accuracyThing < 41) {
					funnyRating = "D";
				} else if(accuracyThing >= 41 && accuracyThing < 61) {
					funnyRating = "C";
				} else if(accuracyThing >= 61 && accuracyThing < 71) {
					funnyRating = "B";
				} else if(accuracyThing >= 71 && accuracyThing < 86) {
					funnyRating = "A";
				} else if(accuracyThing >= 86 && accuracyThing < 91) {
					funnyRating = "S-";
				} else if(accuracyThing >= 91 && accuracyThing < 96) {
					funnyRating = "S";
				} else if(accuracyThing >= 96 && accuracyThing < 100) {
					funnyRating = "S+";
				} else if(accuracyThing == 100) {
					funnyRating = "S++";
				}
			default:
				switch(misses) {
					case 0:
						if(awfuls > 0) {
							funnyRating = "AFC";
						} else if(bads > 0) {
							funnyRating = "FC";
						} else if(goods > 0) {
							funnyRating = "GFC";
						} else {
							funnyRating = "SFC";
						}
					default:
						if(misses < 10 && misses > 0) {
							funnyRating = "SDCB";
						} else if(misses > 9) {
							funnyRating = "Clear";
						}
				}
		}

		if(ThemeStuff.accTextIsEnabled) {
			accTxt.text = replaceStageVarsInTheme(ThemeStuff.accTextText);
		}

		if(ThemeStuff.extraTextIsEnabled) {
			extraTxt.text = replaceStageVarsInTheme(ThemeStuff.extraText);
			if(ThemeStuff.extraCenter) {
				extraTxt.screenCenter(X);
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

		if(ThemeStuff.watermarkDoesScroll && ThemeStuff.watermarkIsEnabled) {
			if(refunkedWatermark.x == 4) {
				watermarkInPlace = true;
				new FlxTimer().start(5, function(tmr:FlxTimer)
				{
					watermarkInPlace = false;
					if(refunkedWatermark.x < 5) {
						refunkedWatermark.x = refunkedWatermark.x - 1;
					}
				});
			} 
			if(watermarkInPlace == false) {		
				if(!botplayIsEnabled) { 
					if(refunkedWatermark.x < -600) {
						refunkedWatermark.x = FlxG.width + 4;
					} else {
						if((SONG.bpm / 45) < 3.5) {
							refunkedWatermark.x = refunkedWatermark.x - 2;
						} else if((SONG.bpm / 45) > 3.5) {
							refunkedWatermark.x = refunkedWatermark.x - 4;
						} else if(SONG.bpm > 300) { 
							refunkedWatermark.x = refunkedWatermark.x - Math.fround(SONG.bpm / 75);	
						} else { 
							refunkedWatermark.x = refunkedWatermark.x - Math.fround(SONG.bpm / 45);
						}
					} 
				} else {
					if(refunkedWatermark.x < -1000) {
						refunkedWatermark.x = FlxG.width + 4;
					} else {
						if((SONG.bpm / 45) < 3.5) {
							refunkedWatermark.x = refunkedWatermark.x - 2;
						} else if((SONG.bpm / 45) > 3.5) {
							refunkedWatermark.x = refunkedWatermark.x - 4;
						} else if(SONG.bpm > 300) { 
							refunkedWatermark.x = refunkedWatermark.x - Math.fround(SONG.bpm / 75);	
						} else { 
							refunkedWatermark.x = refunkedWatermark.x - Math.fround(SONG.bpm / 45);
						}
					} 
				}
			}
		}

		if(ThemeStuff.healthBarIsEnabled && ThemeStuff.healthBarShowP1) {
			if(curBeat > 0)
				iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) + (iconP1.width * iconP1.scale.x - iconP1.width) / 2 - 39;
			else
				iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - 26;
			iconP1.y = healthBar.y - (iconP1.height / 2);
		}
		if(ThemeStuff.healthBarIsEnabled && ThemeStuff.healthBarShowP2) {
			if(curBeat > 0)
				iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width * iconP2.scale.x) / 2 - 52;
			else
				iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - 26);
			iconP2.y = healthBar.y - (iconP2.height / 2);
		}

		if (health > 2)
			health = 2;

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
    		// Conductor.songPosition = FlxG.sound.music.time;
    		Conductor.songPosition += FlxG.elapsed * 1000;
			songTime += FlxG.game.ticks - previousFrameTime;
			previousFrameTime = FlxG.game.ticks;

			// Interpolation type beat
			if (Conductor.lastSongPos != Conductor.songPosition)
			{
				songTime = (songTime + Conductor.songPosition) / 2;
				Conductor.lastSongPos = Conductor.songPosition;
				// Conductor.songPosition += FlxG.elapsed * 1000;
				// trace('MISSED FRAME');
			}

			songPercentage = (Conductor.songPosition / songLength);
        
	    	// Conductor.lastSongPos = FlxG.sound.music.time;
        }

        if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
		}

		FlxG.watch.addQuick("beatStuff", curBeat);
		FlxG.watch.addQuick("stepStuff", curStep);

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 1500)
			{
				var dunceNote:BruhNote = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			notes.forEachAlive(function(daNote:BruhNote)
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

				var bruhThing:Bool = Options.downscroll;

				if(bruhThing == true) {
					daNote.y = (strumLine.y + (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(SONG.speed, 2)));

					if (daNote.isSustainNote && daNote.y + daNote.offset.y >= strumLine.y - Note.swagWidth / 2 && (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
					{
						var swagRect = new FlxRect(0, strumLine.y - Note.swagWidth / 2 + daNote.y, daNote.width * 2, daNote.height * 2);
						swagRect.y *= daNote.scale.y;
						swagRect.height += swagRect.y;
						daNote.clipRect = swagRect;
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

		notes = new FlxTypedGroup<BruhNote>();
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

				var oldNote:BruhNote;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:BruhNote = new BruhNote(daStrumTime, daNoteData, oldNote);
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:BruhNote = new BruhNote(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
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

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByStuff);

		generatedMusic = true;
	}

    function goodNoteHit(note:BruhNote):Void
	{
		if (!note.wasGoodHit)
		{
			if (!note.isSustainNote)
			{
				popUpScore(note.strumTime);
				combo += 1;
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

    function sortByStuff(Obj1:BruhNote, Obj2:BruhNote):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

    override function beatHit()
	{
		super.beatHit();
	
		if(beatHitCounter > curBeat - 1) {
			return;
		} else {
			if(ThemeStuff.timeBarTextHasBounceTween && ThemeStuff.timeBarIsEnabled) {
				if(curBeat % 1 == 0) {
					if(timeTxtTween != null) 
						timeTxtTween.cancel();

					timeTxt.scale.x = ThemeStuff.timeBarTextBounceTweenScale;
					timeTxt.scale.y = ThemeStuff.timeBarTextBounceTweenScale;
					timeTxtTween = FlxTween.tween(timeTxt.scale, {x: 1, y: 1}, 0.2, {
						onComplete: function(bruh:FlxTween) {
							timeTxtTween = null;
						}
					});
				}
			}
	
			if (generatedMusic)
			{
				notes.sort(FlxSort.byY, (Options.downscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING));
			}

			if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
			{
				FlxG.camera.zoom += 0.015;
			}

			if(ThemeStuff.healthBarShowP1 && ThemeStuff.healthBarIsEnabled) {
				if(iconP1Tween != null) {
					iconP1Tween.cancel();
				}
				iconP1.scale.x = 1.2;
				iconP1.scale.y = 1.2;
				iconP1Tween = FlxTween.tween(iconP1, {"scale.x": 1, "scale.y": 1}, 0.15, {
					onComplete: function(twn:FlxTween) {
						iconP1Tween = null;
					}
				});
				iconP1.updateHitbox();
			}
			if(ThemeStuff.healthBarShowP2 && ThemeStuff.healthBarIsEnabled) {
				if(iconP2Tween != null) {
					iconP2Tween.cancel();
				}
				iconP2.scale.x = 1.2;
				iconP2.scale.y = 1.2;
				iconP2Tween = FlxTween.tween(iconP2, {"scale.x": 1, "scale.y": 1}, 0.15, {
					onComplete: function(twn:FlxTween) {
						iconP2Tween = null;
					}
				});
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

		// PREVENT SCORE FROM GOING INTO NEGATIVE VALUES !!!!!!
		if(score < 0) {
			score = 0;
		}

		songScore += score;

		/* 
			if (combo > 60)
				daRating = 'sick';
			else if (combo > 12)
				daRating = 'good'
			else if (combo > 4)
				daRating = 'bad';
		 */

		rating.loadGraphic(Paths.image("previewAssets/" + daRating));
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image('previewAssets/combo'));
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;

		comboSpr.velocity.x += FlxG.random.int(1, 10);
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
		/* 
			trace(combo);
			trace(seperatedScore);
		 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

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
			// FlxG.log.add(i);
			var babyArrow:FlxSprite = new FlxSprite((Options.middlescroll ? -272 : 48), strumLine.y);

			babyArrow.frames = Paths.getSparrowAtlas('previewAssets/NOTE_assets');
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
					babyArrow.animation.addByPrefix('static', 'arrowLEFT');
					babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
				case 1:
					babyArrow.x += Note.swagWidth * 1;
					babyArrow.animation.addByPrefix('static', 'arrowDOWN');
					babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
				case 2:
					babyArrow.x += Note.swagWidth * 2;
					babyArrow.animation.addByPrefix('static', 'arrowUP');
					babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
				case 3:
					babyArrow.x += Note.swagWidth * 3;
					babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
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

	function pressArrow(spr:FlxSprite, idCheck:Int, daNote:BruhNote)
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
        inst.destroy();
        vocals.destroy();

        FlxG.switchState(new OptionsMenu());
    }

    function replaceStageVarsInTheme(strung:String) {
		var uh:String = strung;
		if(uh != null) {
			uh = StringTools.replace(uh, "[song]", SONG.song);
    	    uh = StringTools.replace(uh, "[difficulty]", storyDifficultyText);
			uh = StringTools.replace(uh, "[randomdev]", randomDevs[broDevSelector]);
			uh = StringTools.replace(uh, "[min]", m);
			uh = StringTools.replace(uh, "[sec]", s);
			uh = StringTools.replace(uh, "[height]", Std.string(FlxG.height));
   	     	uh = StringTools.replace(uh, "[width]", Std.string(FlxG.width));
			uh = StringTools.replace(uh, "[score]", Std.string(songScore));
			uh = StringTools.replace(uh, "[misses]", Std.string(misses));
			uh = StringTools.replace(uh, "[nps]", Std.string(funnyNPS));
			uh = StringTools.replace(uh, "[maxnps]", Std.string(funnyMaxNPS));
			uh = StringTools.replace(uh, "[noterating]", notesRating);
			uh = StringTools.replace(uh, "[funnyrating]", funnyRating);
			uh = StringTools.replace(uh, "[accuracy]", Std.string(accuracyThing));
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

    override function destroy() {
        FlxG.sound.music.stop();
        inst.stop();
        vocals.stop();
        inst.destroy();
        vocals.destroy();
        super.destroy();
	}
}