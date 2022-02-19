package;

#if desktop
import Discord.DiscordClient;
import sys.thread.Thread;
#end
import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Assets;
import openfl.Lib;

using StringTools;

class TitleState extends MusicBeatState
{
	private var TSLoadedAssets:Array<FlxBasic> = [];
	private static var TSLoadedMap:Map<String, Dynamic> = new Map<String, Dynamic>();

	static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextStuff:Alphabet;
	var textGroup:FlxGroup;

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;

	override public function create():Void
	{
		unloadMBSassets();
		nullTSLoadedAssets();
		Paths.nullPathsAssets();
		TSLoadedMap = new Map<String, Dynamic>();

		PlayerSettings.init();

		curWacky = FlxG.random.getObject(getIntroTextStuff());

		super.create();

		Highscore.load();
		Options.loadOptions();

		if (FlxG.save.data.weekUnlocked != null)
		{
			if (StoryMenuState.weekUnlocked.length < 4)
				StoryMenuState.weekUnlocked.insert(0, true);

			if (!StoryMenuState.weekUnlocked[0])
				StoryMenuState.weekUnlocked[0] = true;
		}
		
		#if FREEPLAY
		unloadLoadedAssets();
		unloadMBSassets();
		FlxG.switchState(new FreeplayState());
		#elseif CHARTING
		unloadLoadedAssets();
		unloadMBSassets();
		FlxG.switchState(new ChartingState());
		#else
		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			startIntro();
		});
		#end

		#if desktop
		if(Options.enableRPC)
			DiscordClient.initialize();
		
		Application.current.onExit.add (function (exitCode) {
			DiscordClient.shutdown();
		});
		#end
	}

	var logoBl:FlxSprite;
	var titleCharDance:FlxSprite;
	static var CharNames:Array<String> = [
		"gf",
		"bf",
		"dad",
		"spooky_kids",
		"monster",
		"pico",
		"mom",
		"bf_christmas",
		"gf_christmas",
		"mom_dad_christmas",
		"monster_christmas",
		"bf_pixel",
		"gf_pixel",
		"senpai",
		"angry_senpai",
		"spirit_senpai"
	];
	var charUse:String;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;
	var coolTextAmt:Int;

	function startIntro()
	{
		if (!initialized)
		{
			var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
			diamond.persist = true;
			diamond.destroyOnNoUse = false;

			FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
				new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
			FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1),
				{asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;

			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);

			FlxG.sound.music.fadeIn(4, 0, 0.7);
		}

		Conductor.changeBPM(102);
		persistentUpdate = true;

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);
		TSLoadedMap["bg"] = bg;

		logoBl = new FlxSprite(-150, -100);
		logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
		logoBl.antialiasing = true;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24);
		logoBl.updateHitbox();

		charUse = CharNames[Std.random(15)];
		switch(charUse) {
			case "gf":
				titleCharDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
				titleCharDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
				titleCharDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				titleCharDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				titleCharDance.antialiasing = true;
			case "bf":
				titleCharDance = new FlxSprite(FlxG.width * 0.575, 200);
				titleCharDance.frames = Paths.getSparrowAtlas('characters/BOYFRIEND');
				titleCharDance.animation.addByPrefix('idle', 'BF idle dance', 24, false);
				titleCharDance.antialiasing = true;
			case "dad":
				titleCharDance = new FlxSprite(FlxG.width * 0.6, -20);
				titleCharDance.scale.set(0.9, 0.9);
				titleCharDance.frames = Paths.getSparrowAtlas('characters/DADDY_DEAREST_SFW');
				titleCharDance.animation.addByPrefix('idle', 'Dad idle dance', 24, false);
				titleCharDance.antialiasing = true;
				titleCharDance.flipX = true;
			case "spooky_kids":
				titleCharDance = new FlxSprite(FlxG.width * 0.55, FlxG.height * 0.07);
				titleCharDance.frames = Paths.getSparrowAtlas('characters/spooky_kids_assets');
				titleCharDance.animation.addByIndices('danceLeft', 'spooky dance idle', [0, 2, 6], "", 12, false);
				titleCharDance.animation.addByIndices('danceRight', 'spooky dance idle', [8, 10, 12, 14], "", 12, false);
				titleCharDance.antialiasing = true;
				titleCharDance.flipX = true;
			case "monster":
				titleCharDance = new FlxSprite(FlxG.width * 0.6, FlxG.height * 0.04);
				titleCharDance.frames = Paths.getSparrowAtlas('characters/Monster_Assets');
				titleCharDance.animation.addByPrefix('idle', 'monster idle', 24, false);
				titleCharDance.antialiasing = true;
				titleCharDance.flipX = true;
			case "pico":
				titleCharDance = new FlxSprite(FlxG.width * 0.575, 160);
				titleCharDance.frames = Paths.getSparrowAtlas('characters/Pico_FNF_assetss');
				titleCharDance.animation.addByPrefix('idle', "Pico Idle Dance", 24, false);
				titleCharDance.antialiasing = true;
			case "mom":
				titleCharDance = new FlxSprite(FlxG.width * 0.5, -30);
				titleCharDance.scale.set(0.85, 0.85);
				titleCharDance.frames = Paths.getSparrowAtlas('characters/momCarSFW');
				titleCharDance.animation.addByPrefix('idle', "Mom Idle", 24, false);
				titleCharDance.antialiasing = true;
				titleCharDance.flipX = true;
			case "bf_christmas":
				titleCharDance = new FlxSprite(FlxG.width * 0.575, 200);
				titleCharDance.frames = Paths.getSparrowAtlas('characters/bfChristmas');
				titleCharDance.animation.addByPrefix('idle', 'BF idle dance', 24, false);
				titleCharDance.antialiasing = true;
			case "gf_christmas":
				titleCharDance = new FlxSprite(FlxG.width * 0.375, FlxG.height * 0.07);
				titleCharDance.frames = Paths.getSparrowAtlas('characters/gfChristmas');
				titleCharDance.animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				titleCharDance.animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				titleCharDance.antialiasing = true;
			case "mom_dad_christmas":
				titleCharDance = new FlxSprite(FlxG.width * 0.415, -30);
				titleCharDance.frames = Paths.getSparrowAtlas('characters/mom_dad_christmas_assets_SFW');
				titleCharDance.scale.set(0.7, 0.7);
				titleCharDance.animation.addByPrefix('idle', "Parent Christmas Idle", 24, false);
				titleCharDance.antialiasing = true;
				titleCharDance.flipX = true;
			case "monster_christmas":
				titleCharDance = new FlxSprite(FlxG.width * 0.6, FlxG.height * 0.02);
				titleCharDance.frames = Paths.getSparrowAtlas('characters/monsterChristmas');
				titleCharDance.scale.set(0.9, 0.9);
				titleCharDance.animation.addByPrefix('idle', 'monster idle', 24, false);
				titleCharDance.antialiasing = true;
				titleCharDance.flipX = true;
			case "bf_pixel":
				titleCharDance = new FlxSprite(FlxG.width * 0.55, FlxG.height * 0.07);
				titleCharDance.frames = Paths.getSparrowAtlas('characters/bfPixel');
				titleCharDance.setGraphicSize(Std.int(titleCharDance.width * 8));
				titleCharDance.updateHitbox();
				titleCharDance.animation.addByPrefix('idle', 'BF IDLE', 24, false);
				titleCharDance.antialiasing = false;
			case "gf_pixel":
				titleCharDance = new FlxSprite(FlxG.width * 0.45, FlxG.height * 0.03);
				titleCharDance.frames = Paths.getSparrowAtlas('characters/gfPixel');
				titleCharDance.setGraphicSize(Std.int(titleCharDance.width * PlayState.daPixelZoom));
				titleCharDance.updateHitbox();
				titleCharDance.animation.addByIndices('danceLeft', 'GF IDLE', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				titleCharDance.animation.addByIndices('danceRight', 'GF IDLE', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				titleCharDance.antialiasing = false;
			case "senpai":
				titleCharDance = new FlxSprite(FlxG.width * 0.45, -170);
				titleCharDance.frames = Paths.getSparrowAtlas('characters/senpai');
				titleCharDance.setGraphicSize(Std.int(titleCharDance.width * 6));
				titleCharDance.updateHitbox();
				titleCharDance.animation.addByPrefix('idle', 'Senpai Idle', 24, false);
				titleCharDance.antialiasing = false;
			case "angry_senpai":
				titleCharDance = new FlxSprite(FlxG.width * 0.45, -170);
				titleCharDance.frames = Paths.getSparrowAtlas('characters/senpai');
				titleCharDance.setGraphicSize(Std.int(titleCharDance.width * 6));
				titleCharDance.updateHitbox();
				titleCharDance.animation.addByPrefix('idle', 'Angry Senpai Idle', 24, false);
				titleCharDance.antialiasing = false;
				titleCharDance.flipX = true;
			case 'spirit_senpai':
				titleCharDance = new FlxSprite(FlxG.width * 0.45, -50);
				titleCharDance.frames = Paths.getPackerAtlas('characters/spirit');
				titleCharDance.setGraphicSize(Std.int(titleCharDance.width * 6));
				titleCharDance.updateHitbox();
				titleCharDance.animation.addByPrefix('idle', "idle spirit_", 24, false);
				titleCharDance.antialiasing = false;
				titleCharDance.flipX = true;
			default:
				titleCharDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
				titleCharDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
				titleCharDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				titleCharDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				titleCharDance.antialiasing = true;
		}
		add(titleCharDance);
		TSLoadedMap["titleCharDance"] = titleCharDance;
		add(logoBl);
		TSLoadedMap["logoBl"] = logoBl;

		titleText = new FlxSprite(100, FlxG.height * 0.8);
		titleText.frames = Paths.getSparrowAtlas('titleEnter');
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.antialiasing = true;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		add(titleText);
		TSLoadedMap["titleText"] = titleText;

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);
		TSLoadedMap["blackScreen"] = blackScreen;

		credTextStuff = new Alphabet(0, 0, "pahaze \n CryptoCANINE \n Johnny Redwick \n and other contributors \n present to you", true);
		credTextStuff.screenCenter();
		credTextStuff.visible = false;
		TSLoadedMap["credTextStuff"] = credTextStuff;

		FlxTween.tween(credTextStuff, {y: credTextStuff.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		FlxG.mouse.visible = false;

		if (initialized)
			skipIntro();
		else
			initialized = true;
	}

	function getIntroTextStuff():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (FlxG.keys.justPressed.F)
		{
			FlxG.fullscreen = !FlxG.fullscreen;
		}

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.A)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		if (pressedEnter && !transitioning && skippedIntro)
		{
			titleText.animation.play('press');

			FlxG.camera.flash(FlxColor.WHITE, 1);
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

			transitioning = true;

			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				unloadLoadedAssets();
				unloadMBSassets();
				FlxG.switchState(new MainMenuState());
			});
		}

		if (pressedEnter && !skippedIntro)
		{
			skipIntro();
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200;
			credGroup.add(money);
			textGroup.add(money);
			TSLoadedMap["money" + i] = money;
		}
	}

	function addMoreText(text:String)
	{
		var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
		coolText.screenCenter(X);
		coolText.y += (textGroup.length * 60) + 200;
		credGroup.add(coolText);
		textGroup.add(coolText);
		coolTextAmt++;
		TSLoadedMap["coolText" + coolTextAmt] = coolText;
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	override function beatHit()
	{
		super.beatHit();

		if(curBeat % 1 == 0)
			logoBl.animation.play('bump', true);
			if(titleCharDance.animation.getByName('danceLeft') != null && titleCharDance.animation.getByName('danceRight') != null) {
				danceLeft = !danceLeft;
				if (danceLeft)
					titleCharDance.animation.play('danceRight');
				else
					titleCharDance.animation.play('danceLeft');
			}
		if(curBeat % 2 == 0) {
			if(titleCharDance.animation.getByName('danceLeft') == null && titleCharDance.animation.getByName('danceRight') == null)
				titleCharDance.animation.play('idle');
		}

		FlxG.log.add(curBeat);

		switch (curBeat)
		{
			case 2:
				createCoolText([curWacky[0]]);
			case 3:
				addMoreText(curWacky[1]);
			case 5:
				deleteCoolText();
			case 6:
				createCoolText(['pahaze']);
			case 7:
				addMoreText('CryptoCANINE');
			case 8:
				addMoreText('Johnny Redwick');
			case 9:
				addMoreText('and any other contributors');
			case 10:
				addMoreText('present to you');
			case 11:
				deleteCoolText();
			case 12:
				addMoreText('Friday');
			case 13:
				addMoreText('Night');
			case 14:
				addMoreText('Funkin');
			case 15:
				addMoreText('ReFunked'); 
			case 16:
				skipIntro();
		}
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			FlxG.camera.flash(FlxColor.WHITE, 4);
			remove(credGroup);
			skippedIntro = true;
		}
	}

	override function add(Object:flixel.FlxBasic):flixel.FlxBasic
	{
		TSLoadedAssets.insert(TSLoadedAssets.length, Object);
		return super.add(Object);
	}

	public static function nullTSLoadedAssets():Void
	{
		if(TSLoadedMap != null) {
			for(sprite in TSLoadedMap) {
				sprite.destroy();
			}
		}
		TSLoadedMap = null;
	}
	
	public function unloadLoadedAssets():Void
	{
		for (asset in TSLoadedAssets)
		{
			remove(asset);
		}
	}
}
