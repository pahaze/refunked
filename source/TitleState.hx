package;

#if desktop
import Discord.DiscordClient;
import sys.thread.Thread;
#end
import flixel.FlxG;
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
import io.newgrounds.NG;
import lime.app.Application;
import openfl.Assets;

using StringTools;

class TitleState extends MusicBeatState
{
	static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;

	override public function create():Void
	{
		#if polymod
		polymod.Polymod.init({modRoot: "mods", dirs: ['introMod']});
		#end

		PlayerSettings.init();

		curWacky = FlxG.random.getObject(getIntroTextShit());

		// DEBUG BULLSHIT

		super.create();

		NGio.noLogin(APIStuff.API);

		#if ng
		var ng:NGio = new NGio(APIStuff.API, APIStuff.EncKey);
		trace('NEWGROUNDS LOL');
		#end

		FlxG.save.bind('funkin', 'ninjamuffin99');

		Highscore.load();

		if (FlxG.save.data.weekUnlocked != null)
		{
			// FIX LATER!!!
			// WEEK UNLOCK PROGRESSION!!
			// StoryMenuState.weekUnlocked = FlxG.save.data.weekUnlocked;

			if (StoryMenuState.weekUnlocked.length < 4)
				StoryMenuState.weekUnlocked.insert(0, true);

			// QUICK PATCH OOPS!
			if (!StoryMenuState.weekUnlocked[0])
				StoryMenuState.weekUnlocked[0] = true;
		}

		#if FREEPLAY
		FlxG.switchState(new FreeplayState());
		#elseif CHARTING
		FlxG.switchState(new ChartingState());
		#else
		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			startIntro();
		});
		#end

		#if desktop
		DiscordClient.initialize();
		
		Application.current.onExit.add (function (exitCode) {
			DiscordClient.shutdown();
		 });
		#end
	}

	var logoBl:FlxSprite;
	var titleCharDance:FlxSprite;
	var CharNames:Array<String> = [
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

			// HAD TO MODIFY SOME BACKEND SHIT
			// IF THIS PR IS HERE IF ITS ACCEPTED UR GOOD TO GO
			// https://github.com/HaxeFlixel/flixel-addons/pull/348

			// var music:FlxSound = new FlxSound();
			// music.loadStream(Paths.music('freakyMenu'));
			// FlxG.sound.list.add(music);
			// music.play();
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);

			FlxG.sound.music.fadeIn(4, 0, 0.7);
		}

		Conductor.changeBPM(102);
		persistentUpdate = true;

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		// bg.antialiasing = true;
		// bg.setGraphicSize(Std.int(bg.width * 0.6));
		// bg.updateHitbox();
		add(bg);

		logoBl = new FlxSprite(-150, -100);
		logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
		logoBl.antialiasing = true;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();
		// logoBl.screenCenter();
		// logoBl.color = FlxColor.BLACK;

		charUse = CharNames[Std.random(16)];
		switch(charUse) {
			case "gf":
				titleCharDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
				titleCharDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
				titleCharDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				titleCharDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				titleCharDance.antialiasing = true;
			case "bf":
				titleCharDance = new FlxSprite(FlxG.width * 0.575, 200);
				titleCharDance.frames = Paths.getSparrowAtlas('BOYFRIEND');
				titleCharDance.animation.addByPrefix('idle', 'BF idle dance', 24, true);
				titleCharDance.antialiasing = true;
			case "dad":
				titleCharDance = new FlxSprite(FlxG.width * 0.6, -20);
				titleCharDance.scale.set(0.9, 0.9);
				titleCharDance.frames = Paths.getSparrowAtlas('DADDY_DEAREST');
				titleCharDance.animation.addByPrefix('idle', 'Dad idle dance', 24, true);
				titleCharDance.antialiasing = true;
				titleCharDance.flipX = true;
			case "spooky_kids":
				titleCharDance = new FlxSprite(FlxG.width * 0.55, FlxG.height * 0.07);
				titleCharDance.frames = Paths.getSparrowAtlas('spooky_kids_assets');
				titleCharDance.animation.addByIndices('danceLeft', 'spooky dance idle', [0, 2, 6], "", 12, false);
				titleCharDance.animation.addByIndices('danceRight', 'spooky dance idle', [8, 10, 12, 14], "", 12, false);
				titleCharDance.antialiasing = true;
				titleCharDance.flipX = true;
			case "monster":
				titleCharDance = new FlxSprite(FlxG.width * 0.6, FlxG.height * 0.04);
				titleCharDance.frames = Paths.getSparrowAtlas('Monster_Assets');
				titleCharDance.animation.addByPrefix('idle', 'monster idle', 24, true);
				titleCharDance.antialiasing = true;
				titleCharDance.flipX = true;
			case "pico":
				titleCharDance = new FlxSprite(FlxG.width * 0.575, 160);
				titleCharDance.frames = Paths.getSparrowAtlas('Pico_FNF_assetss');
				titleCharDance.animation.addByPrefix('idle', "Pico Idle Dance", 24, true);
				titleCharDance.antialiasing = true;
			case "mom":
				titleCharDance = new FlxSprite(FlxG.width * 0.6, -30);
				titleCharDance.scale.set(0.85, 0.85);
				titleCharDance.frames = Paths.getSparrowAtlas('Mom_Assets');
				titleCharDance.animation.addByPrefix('idle', "Mom Idle", 24, true);
				titleCharDance.antialiasing = true;
				titleCharDance.flipX = true;
			case "bf_christmas":
				titleCharDance = new FlxSprite(FlxG.width * 0.575, 200);
				titleCharDance.frames = Paths.getSparrowAtlas('bfChristmas');
				titleCharDance.animation.addByPrefix('idle', 'BF idle dance', 24, true);
				titleCharDance.antialiasing = true;
			case "gf_christmas":
				titleCharDance = new FlxSprite(FlxG.width * 0.375, FlxG.height * 0.07);
				titleCharDance.frames = Paths.getSparrowAtlas('gfChristmas');
				titleCharDance.animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				titleCharDance.animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				titleCharDance.antialiasing = true;
			case "mom_dad_christmas":
				titleCharDance = new FlxSprite(FlxG.width * 0.415, -30);
				titleCharDance.frames = Paths.getSparrowAtlas('mom_dad_christmas_assets');
				titleCharDance.scale.set(0.7, 0.7);
				titleCharDance.animation.addByPrefix('idle', "Parent Christmas Idle", 24, true);
				titleCharDance.antialiasing = true;
				titleCharDance.flipX = true;
			case "monster_christmas":
				titleCharDance = new FlxSprite(FlxG.width * 0.6, FlxG.height * 0.02);
				titleCharDance.frames = Paths.getSparrowAtlas('monsterChristmas');
				titleCharDance.scale.set(0.9, 0.9);
				titleCharDance.animation.addByPrefix('idle', 'monster idle', 24, true);
				titleCharDance.antialiasing = true;
				titleCharDance.flipX = true;
			case "bf_pixel":
				titleCharDance = new FlxSprite(FlxG.width * 0.55, FlxG.height * 0.07);
				titleCharDance.frames = Paths.getSparrowAtlas('bfPixel');
				titleCharDance.setGraphicSize(Std.int(titleCharDance.width * 8));
				titleCharDance.updateHitbox();
				titleCharDance.animation.addByPrefix('idle', 'BF IDLE', 24, true);
				titleCharDance.antialiasing = false;
			case "gf_pixel":
				titleCharDance = new FlxSprite(FlxG.width * 0.45, FlxG.height * 0.03);
				titleCharDance.frames = Paths.getSparrowAtlas('gfPixel');
				titleCharDance.setGraphicSize(Std.int(titleCharDance.width * PlayState.daPixelZoom));
				titleCharDance.updateHitbox();
				titleCharDance.animation.addByIndices('danceLeft', 'GF IDLE', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				titleCharDance.animation.addByIndices('danceRight', 'GF IDLE', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				titleCharDance.antialiasing = false;
			case "senpai":
				titleCharDance = new FlxSprite(FlxG.width * 0.45, -170);
				titleCharDance.frames = Paths.getSparrowAtlas('senpai');
				titleCharDance.setGraphicSize(Std.int(titleCharDance.width * 6));
				titleCharDance.updateHitbox();
				titleCharDance.animation.addByPrefix('idle', 'Senpai Idle', 24, true);
				titleCharDance.antialiasing = false;
			case "angry_senpai":
				titleCharDance = new FlxSprite(FlxG.width * 0.45, -170);
				titleCharDance.frames = Paths.getSparrowAtlas('senpai');
				titleCharDance.setGraphicSize(Std.int(titleCharDance.width * 6));
				titleCharDance.updateHitbox();
				titleCharDance.animation.addByPrefix('idle', 'Angry Senpai Idle', 24, true);
				titleCharDance.antialiasing = false;
				titleCharDance.flipX = true;
			case 'spirit_senpai':
				titleCharDance = new FlxSprite(FlxG.width * 0.45, -50);
				titleCharDance.frames = Paths.getPackerAtlas('spirit');
				titleCharDance.setGraphicSize(Std.int(titleCharDance.width * 6));
				titleCharDance.updateHitbox();
				titleCharDance.animation.addByPrefix('idle', "idle spirit_", 24, true);
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
		add(logoBl);

		/*
		gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
		gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
		gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gfDance.antialiasing = true;
		add(gfDance);
		*/

		titleText = new FlxSprite(100, FlxG.height * 0.8);
		titleText.frames = Paths.getSparrowAtlas('titleEnter');
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.antialiasing = true;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		// titleText.screenCenter(X);
		add(titleText);

		var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('logo'));
		logo.screenCenter();
		logo.antialiasing = true;
		// add(logo);

		// FlxTween.tween(logoBl, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});
		// FlxTween.tween(logo, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 0.1});

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "ninjamuffin99\nPhantomArcade\nkawaisprite\nevilsk8er", true);
		credTextShit.screenCenter();

		// credTextShit.alignment = CENTER;

		credTextShit.visible = false;

		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('newgrounds_logo'));
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = true;

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		FlxG.mouse.visible = false;

		if (initialized)
			skipIntro();
		else
			initialized = true;

		// credGroup.add(credTextShit);
	}

	function getIntroTextShit():Array<Array<String>>
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
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

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
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		if (pressedEnter && !transitioning && skippedIntro)
		{
			#if !switch
			NGio.unlockMedal(60960);

			// If it's Friday according to da clock
			if (Date.now().getDay() == 5)
				NGio.unlockMedal(61034);
			#end

			titleText.animation.play('press');

			FlxG.camera.flash(FlxColor.WHITE, 1);
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

			transitioning = true;
			// FlxG.sound.music.stop();

			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				//TODO - Fix version checking, but for now, nobody cares!
				FlxG.switchState(new MainMenuState());
			});
			// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
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
		}
	}

	function addMoreText(text:String)
	{
		var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
		coolText.screenCenter(X);
		coolText.y += (textGroup.length * 60) + 200;
		credGroup.add(coolText);
		textGroup.add(coolText);
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

		logoBl.animation.play('bump');
		
		switch(charUse) {
			case 'gf' | 'gf_christmas' | 'gf_pixel' | 'spooky_kids':
				danceLeft = !danceLeft;

				if (danceLeft)
					titleCharDance.animation.play('danceRight');
				else
					titleCharDance.animation.play('danceLeft');
			default:
				titleCharDance.animation.play('idle');
		}

		FlxG.log.add(curBeat);

		switch (curBeat)
		{
			case 1:
				createCoolText(['ninjamuffin99', 'phantomArcade', 'kawaisprite', 'evilsk8er']);
			// credTextShit.visible = true;
			case 3:
				addMoreText('present');
			// credTextShit.text += '\npresent...';
			// credTextShit.addText();
			case 4:
				deleteCoolText();
			// credTextShit.visible = false;
			// credTextShit.text = 'In association \nwith';
			// credTextShit.screenCenter();
			case 5:
				createCoolText(['In association', 'with']);
			case 7:
				addMoreText('newgrounds');
				ngSpr.visible = true;
			// credTextShit.text += '\nNewgrounds';
			case 8:
				deleteCoolText();
				ngSpr.visible = false;
			// credTextShit.visible = false;

			// credTextShit.text = 'Shoutouts Tom Fulp';
			// credTextShit.screenCenter();
			case 9:
				createCoolText([curWacky[0]]);
			// credTextShit.visible = true;
			case 11:
				addMoreText(curWacky[1]);
			// credTextShit.text += '\nlmao';
			case 12:
				deleteCoolText();
			// credTextShit.visible = false;
			// credTextShit.text = "Friday";
			// credTextShit.screenCenter();
			case 13:
				addMoreText('Friday');
			// credTextShit.visible = true;
			case 14:
				addMoreText('Night');
			// credTextShit.text += '\nNight';
			case 15:
				addMoreText('Funkin'); // credTextShit.text += '\nFunkin';

			case 16:
				skipIntro();
		}
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			remove(ngSpr);

			FlxG.camera.flash(FlxColor.WHITE, 4);
			remove(credGroup);
			skippedIntro = true;
		}
	}
}
