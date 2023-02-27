package;

import customFlixel.FlxMarqueeText;
#if desktop
	import Discord.DiscordClient;
#end
import flixel.addons.effects.FlxTrail;
import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import Section.SwagSection;
import Song.SwagSong;

using StringTools;

class PlayState extends MusicBeatState {
	// Cutscenes --
	/// Dialogue
	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];

	/// In Cutscene?
	var inCutscene:Bool = false;
	// -- Cutscenes

	// Gameplay --
	/// BOTPLAY
	public var botplayMode:Bool = false;

	/// Current Scoring Information --
	var accuracy:Float = 0; //// "Pretty" Accuracy (Calculated Automatically)
	var accuracyData:Array<Int> = [0, 0]; //// 1st Entry - Hit Notes; 2nd Entry - Total Key Presses
	var combo:Int = 0; //// Combo
	var comboRating:String = ""; //// *FC Info
	var misses:Int = 0; //// Misses
	var ratings:Array<Int> = [0, 0, 0, 0]; //// [0] = Sicks, [1] = Goods, [2] = Bads, [3] = Awfuls
	var songScore:Int = 0; //// Score
	/// -- Current Scoring Information

	/// Health
	var health:Float = 1;

	/// Paused
	var canPause:Bool = true;
	var paused:Bool = false;

	/// Perfect Mode
	var perfectMode:Bool = false;

	/// Practice Mode
	public var practiceMode:Bool = false;

	/// Scored? (Have(n't) used Botplay/Practice Mode)
	public var scored:Bool = true;
	// -- Gameplay

	// Lua and Memory Management --
	/// Actors
	public var ActorSprites:Map<String, Character> = new Map<String, Character>();

	/// PlayState Instance
	public static var PlayStateInstance:PlayState;
	// -- Lua and Memory Management

	// Internal Song Information --
	/// Beat Hits
	var beatHitCounter:Int = 0;
	public static var isEvenBeat:Bool = false;

	/// Campaign Score (Story Mode)
	public static var campaignScore:Int = 0;

	/// Cameras
	public static var camFollow:FlxObject;
	public static var camFollowPoint:FlxPoint;
	public static var camFollowSet:Bool = false;
	var camFollowTween:FlxTween;
	public var camGame:FlxCamera;
	public var camHUD:FlxCamera;
	public var camShaders:FlxCamera;
	public var camShadersHUD:FlxCamera;
	var camZooming:Bool = false;
	var curSection:Int = 0;
	var defaultCamZoom:Float = 1.05;
	private static var prevCamFollow:FlxObject;
	private static var prevCamFollowPoint:FlxPoint;

	/// Characters
	var boyfriend:Boyfriend;
	var dad:Character;
	var gf:Character;

	/// Current Stage
	public static var curStage:String = '';

	/// Debug Number
	var debugNum:Int = 0;

	/// Frame Times
	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;

	/// Notes and Unspawn Notes
	var notes:FlxTypedGroup<Note>;
	var unspawnNotes:Array<Note> = [];

	/// Song
	var songTime:Float = 0;
	var vocals:FlxSound;

	/// Song Data
	public static var SONG:SwagSong;

	/// Song Information
	var timeLeft:Array<String> = ["0", "0"];

	/// Started Countdown?
	var startedCountdown:Bool = false;

	/// Starting Timer
	var startTimer:FlxTimer;

	/// Story Mode and Story Data
	public static var isStoryMode:Bool = false;
	public static var storyDifficulty:Int = 1;
	public static var storyPlaylist:Array<String> = [];
	public static var storyWeek:Int = 0;

	/// Strum Notes
	var opponentStrums:FlxTypedGroup<FlxSprite>;
	var playerStrums:FlxTypedGroup<FlxSprite>;
	var strumLine:FlxSprite;
	var strumLineNotes:FlxTypedGroup<FlxSprite>;
	// -- Internal Song Information

	// Song Information --
	/// Current Song
	var curSong:String = "";

	/// Currently Ending Song?
	var endingSong:Bool = false;

	/// Currently Starting Song?
	public static var startingSong:Bool = false;

	/// Is Halloween Level?
	var halloweenLevel:Bool = false;

	/// Music Is Generated?
	var generatedMusic:Bool = false;

	/// Song Name
	public var songName:String;

	/// UI Style
	public static var uiStyle:String;
	// -- Song Information

	// UI --
	/// Healthbar
	var healthBar:FlxBar;
	var healthBarBG:FlxSprite;

	/// Icons
	var iconP1:HealthIcon;
	var iconP2:HealthIcon;

	/// Score
	var scoreTxt:FlxText;

	/// Watermark
	var refunkedWatermark:FlxMarqueeText;
	// -- UI

	// Weeks --
	/// Week 2
	var halloweenBG:FlxSprite;
	var isHalloween:Bool = false;
	var lightningOffset:Int = 8;
	var lightningStrikeBeat:Int = 0;

	/// Week 3
	var curLight:Int = 0;
	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var phillyTrain:FlxSprite;
	var startedMoving:Bool = false;
	var trainCars:Int = 8;
	var trainCooldown:Int = 0;
	var trainFinishing:Bool = false;
	var trainFrameTiming:Float = 0;
	var trainMoving:Bool = false;
	var trainSound:FlxSound;

	/// Week 4
	var fastCar:FlxSprite;
	var fastCarCanDrive:Bool = true;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var limo:FlxSprite;

	/// Week 5
	var bottomBoppers:FlxSprite;
	var upperBoppers:FlxSprite;
	var santa:FlxSprite;

	/// Week 6
	var bgGirls:BackgroundGirls;
	public static var daPixelZoom:Float = 6;
	var wiggleStuff:WiggleEffect = new WiggleEffect();
	// -- Weeks

	#if desktop
		// Discord RPC variables
		var storyDifficultyText:String = "";
		var iconRPC:String = "";
		var songLength:Float = 0;
		var detailsText:String = "";
		var detailsPausedText:String = "";
	#end

	override public function create() {
		PlayStateInstance = this;

		if(FlxG.sound.music != null)
			FlxG.sound.music.stop();

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);

		persistentUpdate = true;
		persistentDraw = true;

		if(SONG == null)
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
			switch(SONG.song.toLowerCase()) {
				case 'senpai' | 'roses' | 'thorns':
					uiStyle = "pixel";
				default:
					uiStyle = "default";
			}
		}

		switch (SONG.song.toLowerCase()) {
			case 'senpai':
				dialogue = CoolUtil.coolTextFile(Paths.txt('senpai/senpaiDialogue'));

			case 'roses':
				dialogue = CoolUtil.coolTextFile(Paths.txt('roses/rosesDialogue'));

			case 'thorns':
				dialogue = CoolUtil.coolTextFile(Paths.txt('thorns/thornsDialogue'));
		}

		#if desktop
			// Making difficulty text for Discord Rich Presence.
			switch (storyDifficulty) {
				case 0:
					storyDifficultyText = "EASY";

				case 1:
					storyDifficultyText = "NORMAL";

				case 2:
					storyDifficultyText = "HARD";
			}

			iconRPC = SONG.player2;

			// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
			if(isStoryMode)
				detailsText = "Story Mode: Week " + storyWeek;
			else
				detailsText = "Freeplay";

			// String for when the game is paused
			detailsPausedText = "Paused - " + detailsText;

			// Updating Discord Rich Presence.
			DiscordClient.changePresence(detailsText, songName + " (" + storyDifficultyText + ")", iconRPC);
		#end

		switch (curStage) {
			case 'spooky': {
				halloweenLevel = true;

				halloweenBG = new FlxSprite(-200, -100);
				halloweenBG.frames = Paths.getSparrowAtlas('halloween_bg');
				halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
				halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
				halloweenBG.animation.play('idle');
				halloweenBG.antialiasing = true;
				add(halloweenBG);

				isHalloween = true;
			}
			case 'philly': {
				var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('philly/sky'));
				bg.scrollFactor.set(0.1, 0.1);
				add(bg);

				var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('philly/city'));
				city.scrollFactor.set(0.3, 0.3);
				city.setGraphicSize(Std.int(city.width * 0.85));
				city.updateHitbox();
				add(city);

				phillyCityLights = new FlxTypedGroup<FlxSprite>();
				add(phillyCityLights);

				for (i in 0...5) {
					var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.image('philly/win' + i));
					light.scrollFactor.set(0.3, 0.3);
					light.visible = false;
					light.setGraphicSize(Std.int(light.width * 0.85));
					light.updateHitbox();
					light.antialiasing = true;
					phillyCityLights.add(light);
				}

				var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image('philly/behindTrain'));
				add(streetBehind);

				phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('philly/train'));
				add(phillyTrain);

				trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
				FlxG.sound.list.add(trainSound);

				var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.image('philly/street'));
				add(street);
			}
			case 'limo': {
				defaultCamZoom = 0.90;

				var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.image('limo/limoSunset'));
				skyBG.scrollFactor.set(0.1, 0.1);
				add(skyBG);

				var bgLimo:FlxSprite = new FlxSprite(-200, 480);
				bgLimo.frames = Paths.getSparrowAtlas('limo/bgLimo');
				bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
				bgLimo.animation.play('drive');
				bgLimo.scrollFactor.set(0.4, 0.4);
				add(bgLimo);

				grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
				add(grpLimoDancers);

				for (i in 0...5) {
					var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
					dancer.scrollFactor.set(0.4, 0.4);
					grpLimoDancers.add(dancer);
				}

				limo = new FlxSprite(-120, 550);
				limo.frames = Paths.getSparrowAtlas('limo/limoDrive');
				limo.animation.addByPrefix('drive', "Limo stage", 24);
				limo.animation.play('drive');
				limo.antialiasing = true;

				fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('limo/fastCarLol'));
			}
			case 'mall': {
				defaultCamZoom = 0.80;

				var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('christmas/bgWalls'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.2, 0.2);
				bg.active = false;
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				add(bg);

				upperBoppers = new FlxSprite(-240, -90);
				upperBoppers.frames = Paths.getSparrowAtlas('christmas/upperBop');
				upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
				upperBoppers.antialiasing = true;
				upperBoppers.scrollFactor.set(0.33, 0.33);
				upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
				upperBoppers.updateHitbox();
				add(upperBoppers);

				var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.image('christmas/bgEscalator'));
				bgEscalator.antialiasing = true;
				bgEscalator.scrollFactor.set(0.3, 0.3);
				bgEscalator.active = false;
				bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
				bgEscalator.updateHitbox();
				add(bgEscalator);

				var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.image('christmas/christmasTree'));
				tree.antialiasing = true;
				tree.scrollFactor.set(0.40, 0.40);
				add(tree);

				bottomBoppers = new FlxSprite(-300, 140);
				bottomBoppers.frames = Paths.getSparrowAtlas('christmas/bottomBop');
				bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
				bottomBoppers.antialiasing = true;
				bottomBoppers.scrollFactor.set(0.9, 0.9);
				bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
				bottomBoppers.updateHitbox();
				add(bottomBoppers);

				var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.image('christmas/fgSnow'));
				fgSnow.active = false;
				fgSnow.antialiasing = true;
				add(fgSnow);

				santa = new FlxSprite(-840, 150);
				santa.frames = Paths.getSparrowAtlas('christmas/santa');
				santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
				santa.antialiasing = true;
				add(santa);
			}
			case 'mallEvil': {
				curStage = 'mallEvil';

				var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.image('christmas/evilBG'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.2, 0.2);
				bg.active = false;
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				add(bg);

				var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.image('christmas/evilTree'));
				evilTree.antialiasing = true;
				evilTree.scrollFactor.set(0.2, 0.2);
				add(evilTree);

				var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.image("christmas/evilSnow"));
				evilSnow.antialiasing = true;
				add(evilSnow);
			}
			case 'school' | 'schoolMad': {
				var bgSky = new FlxSprite().loadGraphic(Paths.image('weeb/weebSky'));
				bgSky.scrollFactor.set(0.1, 0.1);
				add(bgSky);

				var repositionStuff = -200;

				var bgSchool:FlxSprite = new FlxSprite(repositionStuff, 0).loadGraphic(Paths.image('weeb/weebSchool'));
				bgSchool.scrollFactor.set(0.6, 0.90);
				add(bgSchool);

				var bgStreet:FlxSprite = new FlxSprite(repositionStuff).loadGraphic(Paths.image('weeb/weebStreet'));
				bgStreet.scrollFactor.set(0.95, 0.95);
				add(bgStreet);

				var fgTrees:FlxSprite = new FlxSprite(repositionStuff + 170, 130).loadGraphic(Paths.image('weeb/weebTreesBack'));
				fgTrees.scrollFactor.set(0.9, 0.9);
				add(fgTrees);

				var bgTrees:FlxSprite = new FlxSprite(repositionStuff - 380, -800);
				var treetex = Paths.getPackerAtlas('weeb/weebTrees');
				bgTrees.frames = treetex;
				bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
				bgTrees.animation.play('treeLoop');
				bgTrees.scrollFactor.set(0.85, 0.85);
				add(bgTrees);

				var treeLeaves:FlxSprite = new FlxSprite(repositionStuff, -40);
				treeLeaves.frames = Paths.getSparrowAtlas('weeb/petals');
				treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
				treeLeaves.animation.play('leaves');
				treeLeaves.scrollFactor.set(0.85, 0.85);
				add(treeLeaves);

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

				if(curStage == 'schoolMad')
					bgGirls.getScared();

				bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
				bgGirls.updateHitbox();
				add(bgGirls);
			}
			case 'schoolEvil': {
				var posX = 400;
				var posY = 200;

				var bg:FlxSprite = new FlxSprite(posX, posY);
				bg.frames = Paths.getSparrowAtlas('weeb/animatedEvilSchool');
				bg.animation.addByPrefix('idle', 'background 2', 24);
				bg.animation.play('idle');
				bg.scrollFactor.set(0.8, 0.9);
				bg.scale.set(6, 6);
				add(bg);
			}
			case 'stage': {
				defaultCamZoom = 0.9;

				var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = false;
				add(bg);

				var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				stageFront.antialiasing = true;
				stageFront.scrollFactor.set(0.9, 0.9);
				stageFront.active = false;
				add(stageFront);

				var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
				stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
				stageCurtains.updateHitbox();
				stageCurtains.antialiasing = true;
				stageCurtains.scrollFactor.set(1.3, 1.3);
				stageCurtains.active = false;
				add(stageCurtains);
			}
			default: {
				defaultCamZoom = 0.9;

				var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = false;
				add(bg);

				var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				stageFront.antialiasing = true;
				stageFront.scrollFactor.set(0.9, 0.9);
				stageFront.active = false;
				add(stageFront);

				var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
				stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
				stageCurtains.updateHitbox();
				stageCurtains.antialiasing = true;
				stageCurtains.scrollFactor.set(1.3, 1.3);
				stageCurtains.active = false;
				add(stageCurtains);
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

		dad = new Character(100, 100, SONG.player2);
		ActorSprites["opponent"] = dad;

		var camPos:FlxPoint = new FlxPoint(ActorSprites["opponent"].getGraphicMidpoint().x, ActorSprites["opponent"].getGraphicMidpoint().y);

		boyfriend = new Boyfriend(770, 100, SONG.player1);
		ActorSprites["boyfriend"] = boyfriend;

		// REPOSITIONING PER STAGE
		switch (curStage) {
			case 'limo':
				ActorSprites["boyfriend"].y -= 220;
				ActorSprites["boyfriend"].x += 260;

				resetFastCar();
				add(fastCar);

			case 'mall':
				ActorSprites["boyfriend"].x += 200;
				ActorSprites["opponent"].x -= 500;

			case 'mallEvil':
				ActorSprites["boyfriend"].x += 320;
				ActorSprites["opponent"].y += 50;

			case 'philly':
				ActorSprites["opponent"].y += 300;

				camPos.x += 600;

			case 'school' | 'schoolMad':
				ActorSprites["boyfriend"].x += 200;
				ActorSprites["boyfriend"].y += 220;
				ActorSprites["girlfriend"].x += 180;
				ActorSprites["girlfriend"].y += 300;
				ActorSprites["opponent"].x += 150;
				ActorSprites["opponent"].y += 360;

				camPos.set(ActorSprites["opponent"].getGraphicMidpoint().x + 300, ActorSprites["opponent"].getGraphicMidpoint().y);

			case 'schoolEvil':
				var evilTrail = new FlxTrail(ActorSprites["opponent"], null, 4, 24, 0.3, 0.069);
				add(evilTrail);

				ActorSprites["boyfriend"].x += 200;
				ActorSprites["boyfriend"].y += 220;
				ActorSprites["girlfriend"].x += 180;
				ActorSprites["girlfriend"].y += 300;
				ActorSprites["opponent"].x -= 150;
				ActorSprites["opponent"].y += 100;

				camPos.set(ActorSprites["opponent"].getGraphicMidpoint().x + 300, ActorSprites["opponent"].getGraphicMidpoint().y);

			case 'spooky':
				if(SONG.player2.startsWith("monster"))
					ActorSprites["opponent"].y += 130;
				else if(SONG.player2.startsWith("spooky"))
					ActorSprites["opponent"].y += 200;

			case 'stage':
				camPos.x += 400;
		}

		if(SONG.player2.startsWith("gf")) {
			ActorSprites["opponent"].setPosition(ActorSprites["girlfriend"].x, ActorSprites["girlfriend"].y);
			ActorSprites["girlfriend"].visible = false;
			if(isStoryMode) {
				camPos.x += 600;
				tweenCamIn();
			}
		}

		add(gf);

		// Bad layering but whatev it works LOL
		if(curStage == 'limo')
			add(limo);

		add(dad);
		add(boyfriend);

		ActorSprites["girlfriend"].x += ActorSprites["girlfriend"].positionOffsets[0];
		ActorSprites["girlfriend"].y += ActorSprites["girlfriend"].positionOffsets[1];
		ActorSprites["opponent"].x += ActorSprites["opponent"].positionOffsets[0];
		ActorSprites["opponent"].y += ActorSprites["opponent"].positionOffsets[1];
		ActorSprites["boyfriend"].x += ActorSprites["boyfriend"].positionOffsets[0];
		ActorSprites["boyfriend"].y += ActorSprites["boyfriend"].positionOffsets[1];

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite((Options.middlescroll ? -272 : 40), (Options.downscroll ? FlxG.height - 150 : 50)).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		opponentStrums = new FlxTypedGroup<FlxSprite>();
		playerStrums = new FlxTypedGroup<FlxSprite>();

		generateSong(SONG.song);

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
		FlxG.fixedTimestep = false;

		healthBarBG = new FlxSprite(0, (Options.downscroll ? FlxG.height * 0.11 : FlxG.height * 0.9)).loadGraphic(Paths.image('healthBar'));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this, 'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		add(healthBar);

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		scoreTxt = new FlxText(0, (Options.downscroll ? healthBarBG.y + 42 : healthBarBG.y - 42), 0, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		add(scoreTxt);

		refunkedWatermark = new FlxMarqueeText(4, FlxG.height * 0.97, "", 16, 20, SONG.speed);
		refunkedWatermark.setFormat(Paths.font("vcr.ttf"), 16, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(refunkedWatermark);

		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		refunkedWatermark.cameras = [camHUD];
		doof.cameras = [camHUD];

		startingSong = true;

		if(isStoryMode) {
			switch (curSong.toLowerCase()) {
				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;

					new FlxTimer().start(0.1, function(tmr:FlxTimer) {
						remove(blackScreen);
						FlxG.sound.play(Paths.sound('Lights_Turn_On'));
						camFollow.y = -2050;
						camFollow.x += 200;
						FlxG.camera.focusOn(camFollow.getPosition());
						FlxG.camera.zoom = 1.5;

						new FlxTimer().start(0.8, function(tmr:FlxTimer) {
							camHUD.visible = true;
							remove(blackScreen);
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween) {
									startCountdown();
								}
							});
						});
					});

				case 'senpai':
					schoolIntro(doof);

				case 'roses':
					FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);

				case 'thorns':
					schoolIntro(doof);

				default:
					startCountdown();
			}
		} else {
			switch (curSong.toLowerCase()) {
				default:
					startCountdown();
			}
		}

		super.create();
	}

	function badNoteCheck() {
		var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;

		if(leftP)
			noteMiss(0);
		if(downP)
			noteMiss(1);
		if(upP)
			noteMiss(2);
		if(rightP)
			noteMiss(3);
	}

	override function beatHit() {
		super.beatHit();

		if(beatHitCounter > (curBeat - 1))
			return;

		if(generatedMusic)
			notes.sort(FlxSort.byY, (Options.downscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING));

		if(SONG.notes[Math.floor(curStep / 16)] != null) {
			if(SONG.notes[Math.floor(curStep / 16)].changeBPM) {
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
		}

		isEvenBeat = (curBeat % 2 == 0);

		wiggleStuff.update(Conductor.crochet);

		// HARDCODING FOR MILF ZOOMS!
		if(curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35) {
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		if(camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0) {
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		iconP1.scale.set(1.2, 1.2);
		setIconP1Positions();

		iconP2.scale.set(1.2, 1.2);
		setIconP2Positions();

		for(actor in ActorSprites) {
			if(actor != null && actor.animation.curAnim != null) {
				if(curBeat % actor.speed == 0) {
					if(!actor.animation.curAnim.name.startsWith("sing") && !actor.isSpecialAnim)
						actor.dance();
				}
			}
		}

		if(curBeat % 8 == 7 && curSong == 'Bopeebo') {
			ActorSprites["boyfriend"].playAnim('hey', true);
			ActorSprites["girlfriend"].playAnim('cheer', true);
		}

		if(curBeat % 16 == 15 && SONG.song == 'Tutorial' && ActorSprites["opponent"].curCharacter == 'gf' && curBeat > 16 && curBeat < 48) {
			ActorSprites["boyfriend"].playAnim('hey', true);
			ActorSprites["opponent"].playAnim('cheer', true);
		}

		switch (curStage) {
			case 'school' | 'schoolMad':
				bgGirls.dance();

			case 'mall':
				upperBoppers.animation.play('bop', true);
				bottomBoppers.animation.play('bop', true);
				santa.animation.play('idle', true);

			case 'limo':
				grpLimoDancers.forEach(function(dancer:BackgroundDancer) {
					dancer.dance();
				});

				if(FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();

			case "philly":
				if(!trainMoving)
					trainCooldown += 1;

				if(curBeat % 4 == 0) {
					phillyCityLights.forEach(function(light:FlxSprite) {
						light.visible = false;
					});

					curLight = FlxG.random.int(0, phillyCityLights.length - 1);

					phillyCityLights.members[curLight].visible = true;
				}

				if(curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8) {
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
		}

		if(isHalloween && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
			lightningStrikeStuff();

		beatHitCounter = curBeat;
	}

	override function closeSubState() {
		if(paused) {
			if(FlxG.sound.music != null && !startingSong)
				resyncVocals();

			if(!startTimer.finished)
				startTimer.active = true;

			paused = false;

			#if desktop
				if(startTimer.finished)
					DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
				else
					DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			#end
		}

		super.closeSubState();
	}

	function endSong():Void {
		endingSong = true;

		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;

		if(SONG.validScore && scored)
			Highscore.saveScore(SONG.song, songScore, storyDifficulty);

		if(isStoryMode) {
			if(scored)
				campaignScore += songScore;

			storyPlaylist.remove(storyPlaylist[0]);

			if(storyPlaylist.length <= 0) {
				FlxG.sound.playMusic(Paths.music('freakyMenu'));

				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;

				FlxG.switchState(new StoryMenuState());

				StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

				if(SONG.validScore)
					Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);

				FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
				FlxG.save.flush();
			} else {
				var difficulty:String = "";

				if(storyDifficulty == 0)
					difficulty = '-easy';

				if(storyDifficulty == 2)
					difficulty = '-hard';

				trace('LOADING NEXT SONG');
				trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

				if(SONG.song.toLowerCase() == 'eggnog') {
					var blackStuff:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom, -FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
					blackStuff.scrollFactor.set();
					add(blackStuff);
					camHUD.visible = false;

					FlxG.sound.play(Paths.sound('Lights_Shut_off'));
				}

				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;

				prevCamFollow = camFollow;
				prevCamFollowPoint = camFollowPoint;

				PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
				FlxG.sound.music.stop();

				LoadingState.loadAndSwitchState(new PlayState());
			}
		} else {
			trace('WENT BACK TO FREEPLAY??');
			FlxG.switchState(new FreeplayState());
		}
	}

	function fastCarDrive() {
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		new FlxTimer().start(2, function(tmr:FlxTimer) {
			resetFastCar();
		});
	}

	private function generateSong(dataPath:String):Void {
		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if(SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;
		noteData = songData.notes;

		var playerCounter:Int = 0;
		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

		for (section in noteData) {
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes) {
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);
				var gottaHitNote:Bool = section.mustHitSection;

				if(songNotes[1] > 3)
					gottaHitNote = !section.mustHitSection;

				var oldNote:Note;
				if(unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength)) {
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
					sustainNote.scrollFactor.set();
					sustainNote.mustPress = gottaHitNote;
					unspawnNotes.push(sustainNote);

					if(sustainNote.mustPress)
						sustainNote.x += FlxG.width / 2;
				}

				swagNote.mustPress = gottaHitNote;
				if(swagNote.mustPress)
					swagNote.x += FlxG.width / 2;
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

	private function generateStaticArrows(player:Int):Void {
		for (i in 0...4) {
			var babyArrow:FlxSprite = new FlxSprite((Options.middlescroll ? -272 : 40), strumLine.y);

			switch (uiStyle) {
				case 'pixel':
					babyArrow.loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					switch (Math.abs(i)) {
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

					switch (Math.abs(i)) {
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
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			if(!isStoryMode) {
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			babyArrow.ID = i;

			if(player == 1)
				playerStrums.add(babyArrow);
			else
				opponentStrums.add(babyArrow);

			opponentStrums.forEach(function(spr:FlxSprite) {
				spr.centerOffsets();
			});

			babyArrow.animation.play('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * player);

			strumLineNotes.add(babyArrow);
		}
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

	function getNoteY(daNote:Note):Float {
		// General note values, just for simplicity sake
		if(Options.downscroll)
			return 50 + 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(SONG.speed, 2);
		else
			return 50 - 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(SONG.speed, 2);
	}

	function getSustainAddAmt(daNote:Note, prevNote:Note) {
		var daNoteY:Float;
		var prevNoteY:Float;
		if(Options.downscroll) {
			daNoteY = getNoteY(daNote) + daNote.height;
			prevNoteY = getNoteY(prevNote) + (Note.swagWidth / 2);
			var yIsGreater:Bool = daNoteY < prevNoteY;
			daNote.strumTime -= 1;
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

	function goodNoteHit(note:Note):Void {
		if(!note.wasGoodHit) {
			if(!note.isSustainNote) {
				if(botplayMode)
					popUpScore(Conductor.songPosition);
				else
					popUpScore((note.strumTime + note.strumAdd));
				combo += 1;
			}

			if(note.noteData >= 0)
				health += 0.023;
			else
				health += 0.004;

			accuracyData[0] += 1;
			accuracyData[1] += 1;

			ActorSprites["boyfriend"].holdTimer = 0;

			switch (note.noteData) {
				case 0:
					ActorSprites["boyfriend"].playAnim('singLEFT', true);

				case 1:
					ActorSprites["boyfriend"].playAnim('singDOWN', true);

				case 2:
					ActorSprites["boyfriend"].playAnim('singUP', true);

				case 3:
					ActorSprites["boyfriend"].playAnim('singRIGHT', true);
			}

			playerStrums.forEach(function(spr:FlxSprite) {
				if(Math.abs(note.noteData) == spr.ID)
					spr.animation.play('confirm', true);
			});

			note.wasGoodHit = true;
			vocals.volume = 1;

			if(!note.isSustainNote) {
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
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
			} else {
				daNote.endStrumAdded = true;
			}
		}
	}

	function handleStrumLighting() {
		opponentStrums.forEach(function(spr:FlxSprite) {
			if(spr != null && spr.animation != null) {
				if(spr.animation.finished) {
					spr.animation.play('static');
					spr.centerOffsets();
				}
			}
		});

		if(botplayMode) {
			playerStrums.forEach(function(spr:FlxSprite) {
				if(spr != null && spr.animation != null) {
					if(spr.animation.finished) {
						spr.animation.play('static');
						spr.centerOffsets();
					}
				}
			});
		}
	}

	private function keyStuff():Void {
		var controlArray:Array<Bool> = [controls.LEFT_P, controls.DOWN_P, controls.UP_P, controls.RIGHT_P];
		var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
		var releaseArray:Array<Bool> = [controls.LEFT_R, controls.DOWN_R, controls.UP_R, controls.RIGHT_R];

		if(!botplayMode) {
			// Based more towards 0.2.8, looks cleaner too
			if(holdArray.contains(true) && generatedMusic) {
				notes.forEachAlive(function(daNote:Note) {
					if(daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData])
						goodNoteHit(daNote);
				});
			}

			if(controlArray.contains(true) && generatedMusic) {
				var badNotes:Array<Note> = [];
				var possibleNotes:Array<Note> = [];
				var sustainNotes:Array<Note> = [];

				var ignoreList:Array<Int> = [];

				notes.forEachAlive(function(daNote:Note) {
					if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit) {
						if(ignoreList.contains(daNote.noteData)) {
							for(stupidNote in possibleNotes) {
								if(stupidNote.noteData == daNote.noteData && Math.abs((daNote.strumTime + daNote.strumAdd) - (stupidNote.strumTime + stupidNote.strumAdd)) < 10)
									badNotes.push(daNote);
								else if(stupidNote.noteData == daNote.noteData && (daNote.strumTime + daNote.strumAdd) < (stupidNote.strumTime + stupidNote.strumAdd)) {
									possibleNotes.remove(stupidNote);
									possibleNotes.push(daNote);
								}
							}
						} else {
							possibleNotes.push(daNote);
							ignoreList.push(daNote.noteData);
						}
					}

					if(daNote.canBeHit && daNote.mustPress && daNote.isSustainNote)
						sustainNotes.push(daNote);
				});

				for(stupidBadNote in badNotes) {
					stupidBadNote.kill();
					notes.remove(stupidBadNote, true);
					stupidBadNote.destroy();
				}

				possibleNotes.sort((a, b) -> Std.int((a.strumTime + a.strumAdd) - (b.strumTime + b.strumAdd)));

				if(perfectMode)
					goodNoteHit(possibleNotes[0]);
				else if(possibleNotes.length > 0) {
					for(i in 0...controlArray.length) {
						if(controlArray[i] && !ignoreList.contains(i))
							badNoteCheck();
					}
					for(stupidNote in possibleNotes) {
						if(controlArray[stupidNote.noteData])
							goodNoteHit(stupidNote);
					}
				} else {
					if(sustainNotes.length <= 0)
						badNoteCheck();
				}
			}
		}

		if(ActorSprites["boyfriend"].holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!botplayMode && !holdArray.contains(true) || botplayMode)) {
			if(ActorSprites["boyfriend"].animation.curAnim.name.startsWith('sing') && !ActorSprites["boyfriend"].animation.curAnim.name.endsWith('miss'))
				ActorSprites["boyfriend"].dance();
		}

		playerStrums.forEach(function(spr:FlxSprite) {
			if(!botplayMode) {
				if(controlArray[spr.ID] && spr.animation.curAnim.name != 'confirm')
					spr.animation.play('pressed');
				else if(releaseArray[spr.ID])
					spr.animation.play('static');
			}

			if(spr.animation.curAnim.name == 'confirm' && !uiStyle.startsWith('pixel')) {
				spr.centerOffsets();
				spr.offset.x -= 13;
				spr.offset.y -= 13;
			} else {
				spr.centerOffsets();
			}
		});
	}

	function lateNoteMiss(daNote:Note) {
		health -= 0.0475;
		vocals.volume = 0;
		combo = 0;

		FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
		misses += 1;

		accuracyData[1] += 1;

		switch(Math.abs(daNote.noteData)) {
			case 0:
				ActorSprites["boyfriend"].playAnim('singLEFTmiss', true);

			case 1:
				ActorSprites["boyfriend"].playAnim('singDOWNmiss', true);

			case 2:
				ActorSprites["boyfriend"].playAnim('singUPmiss', true);

			case 3:
				ActorSprites["boyfriend"].playAnim('singRIGHTmiss', true);
		}
	}

	function lightningStrikeStuff():Void {
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		halloweenBG.animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		ActorSprites["boyfriend"].playAnim('scared', true);
		ActorSprites["girlfriend"].playAnim('scared', true);
	}

	function noteCheck(keyP:Bool, note:Note):Void {
		if(keyP)
			goodNoteHit(note);
	}

	function noteMiss(direction:Int = 1):Void {
		if(Options.ghostTapping)
			return;

		if(!ActorSprites["boyfriend"].stunned) {
			ActorSprites["boyfriend"].stunned = true;

			health -= 0.04;
			songScore -= 10;

			if(combo > 10 && ActorSprites["girlfriend"].animOffsets.exists('sad'))
				ActorSprites["girlfriend"].playAnim('sad');
			combo = 0;

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			misses += 1;

			accuracyData[1] += 1;

			new FlxTimer().start(5 / 60, function(tmr:FlxTimer) {
				ActorSprites["boyfriend"].stunned = false;
			});

			switch (direction) {
				case 0:
					ActorSprites["boyfriend"].playAnim('singLEFTmiss', true);

				case 1:
					ActorSprites["boyfriend"].playAnim('singDOWNmiss', true);

				case 2:
					ActorSprites["boyfriend"].playAnim('singUPmiss', true);

				case 3:
					ActorSprites["boyfriend"].playAnim('singRIGHTmiss', true);
			}
		}
	}

	override public function onFocus():Void {
		#if desktop
			if(health > 0 && !paused) {
				if(Conductor.songPosition > 0.0)
					DiscordClient.changePresence(detailsText, songName + " (" + storyDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
				else
					DiscordClient.changePresence(detailsText, songName + " (" + storyDifficultyText + ")", iconRPC);
			}
		#end

		super.onFocus();
	}

	override public function onFocusLost():Void {
		#if desktop
			if(health > 0 && !paused)
				DiscordClient.changePresence(detailsPausedText, songName + " (" + storyDifficultyText + ")", iconRPC);
		#end

		super.onFocusLost();
	}

	override function openSubState(SubState:FlxSubState) {
		if(paused) {
			if(FlxG.sound.music != null) {
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if(!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	function opponentNoteHit(daNote:Note) {
		if(SONG.song != 'Tutorial')
			camZooming = true;

		var altAnim:String = "";

		if(SONG.notes[Math.floor(curStep / 16)] != null) {
			if(SONG.notes[Math.floor(curStep / 16)].altAnim)
				altAnim = '-alt';
		}

		switch (Math.abs(daNote.noteData)) {
			case 0:
				ActorSprites["opponent"].playAnim('singLEFT' + altAnim, true);

			case 1:
				ActorSprites["opponent"].playAnim('singDOWN' + altAnim, true);

			case 2:
				ActorSprites["opponent"].playAnim('singUP' + altAnim, true);

			case 3:
				ActorSprites["opponent"].playAnim('singRIGHT' + altAnim, true);
		}

		ActorSprites["opponent"].holdTimer = 0;

		opponentStrums.forEach(function(spr:FlxSprite) {
			pressArrow(spr, spr.ID, daNote);
			if(spr.animation.curAnim.name == 'confirm' && !uiStyle.startsWith('pixel')) {
				spr.centerOffsets();
				spr.offset.x -= 13;
				spr.offset.y -= 13;
			} else {
				spr.centerOffsets();
			}
		});

		daNote.hasBeenHitByBot = true;

		if(SONG.needsVoices)
			vocals.volume = 1;

		if(!daNote.isSustainNote) {
			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();
		}
	}

	function pressArrow(spr:FlxSprite, idCheck:Int, daNote:Note) {
		if(Math.abs(daNote.noteData) == idCheck)
			spr.animation.play('confirm', true);
	}

	private function popUpScore(strumtime:Float):Void {
		var noteDiff:Float = Math.abs(strumtime - Conductor.songPosition);
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.35;

		var comboSpr:FlxSprite = new FlxSprite();
		var rating:FlxSprite = new FlxSprite();

		var score:Int = 350;
		var daRating:String = "sick";

		if(noteDiff > Conductor.safeZoneOffset * 0.8) {
			daRating = 'shit';
			ratings[3] += 1;
			score = 50;
		} else if(noteDiff > Conductor.safeZoneOffset * 0.65) {
			daRating = 'bad';
			ratings[2] += 1;
			score = 100;
		} else if(noteDiff > Conductor.safeZoneOffset * 0.45) {
			daRating = 'good';
			ratings[1] += 1;
			score = 200;
		} else if(daRating == "sick") {
			ratings[0] += 1;
		}

		songScore += score;

		var pixelStuffPart1:String = "";
		var pixelStuffPart2:String = '';

		if(curStage.startsWith('school')) {
			pixelStuffPart1 = 'weeb/pixelUI/';
			pixelStuffPart2 = '-pixel';
		}

		rating.loadGraphic(Paths.image(pixelStuffPart1 + daRating + pixelStuffPart2));
		rating.cameras = [camHUD];
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);

		comboSpr.loadGraphic(Paths.image(pixelStuffPart1 + 'combo' + pixelStuffPart2));
		comboSpr.cameras = [camHUD];
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 550;
		comboSpr.velocity.y -= FlxG.random.int(140, 175);
		comboSpr.velocity.x -= FlxG.random.int(1, 10);

		if(combo >= 10)
			insert(members.indexOf(strumLineNotes), comboSpr);
		insert(members.indexOf(strumLineNotes), rating);

		if(!curStage.startsWith('school')) {
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = true;

			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = true;
		} else {
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		if(combo >= 1000)
			seperatedScore.push(Math.floor(combo / 1000) % 10);
		seperatedScore.push(Math.floor(combo / 100));
		seperatedScore.push(Math.floor((combo - (seperatedScore[0] * 100)) / 10));
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		for (i in seperatedScore) {
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelStuffPart1 + 'num' + Std.int(i) + pixelStuffPart2));
			numScore.cameras = [camHUD];
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;

			if(!curStage.startsWith('school')) {
				numScore.antialiasing = true;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			} else {
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);

			if(combo >= 10 || combo == 0)
				insert(members.indexOf(strumLineNotes), numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween) {
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
			onComplete: function(tween:FlxTween) {
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});

		curSection += 1;
	}

	function resetFastCar():Void {
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	function resyncVocals():Void {
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void {
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();

		if(SONG.song.toLowerCase() == 'roses' || SONG.song.toLowerCase() == 'thorns') {
			remove(black);

			if(SONG.song.toLowerCase() == 'thorns')
				add(red);
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer) {
			black.alpha -= 0.15;

			if(black.alpha > 0) {
				tmr.reset(0.3);
			} else {
				if(dialogueBox != null) {
					inCutscene = true;

					if(SONG.song.toLowerCase() == 'thorns') {
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer) {
							senpaiEvil.alpha += 0.15;
							if(senpaiEvil.alpha < 1) {
								swagTimer.reset();
							} else {
								senpaiEvil.animation.play('idle');

								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function() {
									remove(senpaiEvil);
									remove(red);

									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function() {
										add(dialogueBox);
									}, true);
								});

								new FlxTimer().start(3.2, function(deadTime:FlxTimer) {
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					} else {
						add(dialogueBox);
					}
				} else {
					startCountdown();
				}

				remove(black);
			}
		});
	}

	function setCameraPosition(x:Float, y:Float, ?snap:Bool = false) {
		camFollowPoint.set(x, y);
		if(snap)
			camFollow.setPosition(x, y);
	}

	public function setIconP1Positions() {
		var iconOffset:Int = 26;

		iconP1.updateHitbox();
		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		if(Options.downscroll)
			iconP1.y = (healthBar.y + (healthBar.height / 2) + 75) - iconP1.height;
		else
			iconP1.y = (healthBar.y + (healthBar.height / 2) - 75);
	}

	public function setIconP2Positions() {
		var iconOffset:Int = 26;

		iconP2.updateHitbox();
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);
		if(Options.downscroll)
			iconP2.y = (healthBar.y + (healthBar.height / 2) + 75) - iconP2.height;
		else
			iconP2.y = (healthBar.y + (healthBar.height / 2) - 75);
	}

	function sortByStuff(Obj1:Note, Obj2:Note):Int {
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function startCountdown():Void {
		inCutscene = false;

		generateStaticArrows(0);
		generateStaticArrows(1);
		for(i in 0...opponentStrums.length) {
			// Protection of UI element alpha changing with Lua
			if(Options.middlescroll)
				opponentStrums.members[i].visible = false;
		}

		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer) {
			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('school', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);
			introAssets.set('schoolMad', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);
			introAssets.set('schoolEvil', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			for (value in introAssets.keys()) {
				if(value == curStage) {
					introAlts = introAssets.get(value);
					altSuffix = '-pixel';
				}
			}

			switch (swagCounter) {
				case 0:
					FlxG.sound.play(Paths.sound('intro3'), 0.6);

				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.cameras = [camHUD];
					ready.scrollFactor.set();
					ready.updateHitbox();

					if(curStage.startsWith('school'))
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

					ready.screenCenter();
					add(ready);

					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween) {
							ready.destroy();
						}
					});

					FlxG.sound.play(Paths.sound('intro2'), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.cameras = [camHUD];
					set.scrollFactor.set();

					if(curStage.startsWith('school'))
						set.setGraphicSize(Std.int(set.width * daPixelZoom));

					set.screenCenter();
					add(set);

					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween) {
							set.destroy();
						}
					});

					FlxG.sound.play(Paths.sound('intro1'), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.cameras = [camHUD];
					go.scrollFactor.set();

					if(curStage.startsWith('school'))
						go.setGraphicSize(Std.int(go.width * daPixelZoom));

					go.updateHitbox();
					go.screenCenter();
					add(go);

					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween) {
							go.destroy();
						}
					});

					FlxG.sound.play(Paths.sound('introGo'), 0.6);
				case 4:
			}

			for(actor in ActorSprites) {
				if(tmr.loopsLeft % actor.speed == 0)
					actor.dance();
			}

			swagCounter += 1;
		}, 5);
	}

	function startSong():Void {
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if(!paused)
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);

		FlxG.sound.music.onComplete = endSong;
		vocals.play();

		#if desktop
			// Song duration in a float, useful for the time left feature
			songLength = FlxG.sound.music.length;

			// Updating Discord Rich Presence (with Time Left)
			DiscordClient.changePresence(detailsText, songName + " (" + storyDifficultyText + ")", iconRPC, true, songLength);
		#end
	}

	override function stepHit() {
		super.stepHit();

		if(FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
			resyncVocals();
	}

	function trainReset():Void {
		ActorSprites["girlfriend"].playAnim('hairFall');
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function trainStart():Void {
		trainMoving = true;

		if(!trainSound.playing)
			trainSound.play(true);
	}

	function tweenCamIn():Void {
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override public function update(elapsed:Float) {
		#if !debug
			perfectMode = false;
		#end

		switch (curStage) {
			case 'philly':
				if(trainMoving) {
					trainFrameTiming += elapsed;

					if(trainFrameTiming >= 1 / 24) {
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
		}

		super.update(elapsed);

		if(!inCutscene) {
			// Same deal here as icons, borrowed from Psych Engine as I couldn't make tweens work how I wanted
			// I'll try to make this work with tweens later on
			var cameraTiming:Float = FlxMath.bound(elapsed * 3.5, 0, 1);
			camFollow.setPosition(FlxMath.lerp(camFollow.x, camFollowPoint.x, cameraTiming), FlxMath.lerp(camFollow.y, camFollowPoint.y, cameraTiming));
		}

		handleStrumLighting();

		// Current Scoring Information --
			/// Accuracy
			if(accuracyData[1] > 0) {
				if(accuracyData[0] > 0)
					accuracy = FlxMath.roundDecimal((accuracyData[0] / accuracyData[1]) * 100, 2);
				else
					accuracy = 0; //// I would hope 0 divided by anything is 0 :)
			} else {
				//// Default to 100 if both values are 0
				accuracy = 100;
			}

			/// Combo Rating (*FC Info)
			comboRating = Utilities.calculateComboRating(ratings, misses, accuracy);
		// -- Current Scoring Information

		// Song Info --
			/// Time Left --
			if(startingSong) {
				//// TODO: Make this work before song start.
				timeLeft[0] = "??";
				timeLeft[1] = "??";
			} else {
				//// Minutes Left
				var minLeft:String = Std.string(Math.floor(((FlxG.sound.music.length - Conductor.songPosition) % 3600000) / 60000)).lpad("0", 2);
				if(Std.parseInt(minLeft) < 0)
					minLeft = "00";

				timeLeft[0] = minLeft;

				//// Seconds Left
				var secLeft:String = Std.string(Math.floor(((FlxG.sound.music.length - Conductor.songPosition) % 60000) / 1000)).lpad("0", 2);
				if(Std.parseInt(secLeft) < 0)
					secLeft = "00";

				timeLeft[1] = secLeft;
			}
			/// -- Time Left
		// -- Song Info

		// UI --
			/// RFE Watermark
			refunkedWatermark.text = '${SONG.songName} (${CoolUtil.difficultyString()}) | ${timeLeft[0]}:${timeLeft[1]} left | FNF RFE';

			/// Score Text
			scoreTxt.text = 'Score: $songScore | Misses $misses | Accuracy: $accuracy% ($comboRating)';
			scoreTxt.screenCenter(X);
		// -- UI

		if(FlxG.keys.justPressed.ENTER && startedCountdown && canPause) {
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			openSubState(new PauseSubState(ActorSprites["boyfriend"].getScreenPosition().x, ActorSprites["boyfriend"].getScreenPosition().y));

			#if desktop
				DiscordClient.changePresence(detailsPausedText, songName + " (" + storyDifficultyText + ")", iconRPC);
			#end
		}

		if(FlxG.keys.justPressed.SEVEN) {
			FlxG.switchState(new ChartingState());

			#if desktop
				DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
		}

		// Borrowed from Psych Engine as I could not figure out how to get a tween to not be insanely fast despite using elapsed...
		var iconScaleTiming:Float = FlxMath.bound(1 - (elapsed * 10), 0, 1);
		var iconP1Scale:Float = FlxMath.lerp(1, iconP1.scale.x, iconScaleTiming);
		var iconP2Scale:Float = FlxMath.lerp(1, iconP2.scale.x, iconScaleTiming);

		iconP1.scale.set(iconP1Scale, iconP1Scale);
		setIconP1Positions();
		iconP2.scale.set(iconP2Scale, iconP2Scale);
		setIconP2Positions();

		if(health > 2)
			health = 2;

		if (healthBar.percent > 80) {
			iconP2.animation.curAnim.curFrame = 1;
			if(iconP1.hasWinningIcon)
				iconP1.animation.curAnim.curFrame = 2;
		} else if(healthBar.percent < 20) {
			iconP1.animation.curAnim.curFrame = 1;
			if(iconP2.hasWinningIcon)
				iconP2.animation.curAnim.curFrame = 2;
		} else {
			iconP1.animation.curAnim.curFrame = 0;
			iconP2.animation.curAnim.curFrame = 0;
		}

		if(startingSong) {
			if(startedCountdown) {
				Conductor.songPosition += FlxG.elapsed * 1000;
				if(Conductor.songPosition >= 0)
					startSong();
			}
		} else {
			if(!endingSong) {
				Conductor.songPosition += FlxG.elapsed * 1000;

				if(!paused) {
					songTime += FlxG.game.ticks - previousFrameTime;
					previousFrameTime = FlxG.game.ticks;

					// Interpolation type beat
					if(Conductor.lastSongPos != Conductor.songPosition) {
						songTime = (songTime + Conductor.songPosition) / 2;
						Conductor.lastSongPos = Conductor.songPosition;
					}
				}

				if(botplayMode || practiceMode)
					scored = false;
			}
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null && camFollowSet == false) {
			if (!PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection) {
				var camAdd:Array<Int> = ActorSprites["opponent"].cameraOffsets;
				var xPos:Float = ActorSprites["opponent"].getMidpoint().x + 150;
				var yPos:Float = ActorSprites["opponent"].getMidpoint().y - 100;

				if(camAdd != null) {
					xPos += camAdd[0];
					yPos += camAdd[1];
				}

				setCameraPosition(xPos, yPos);

				vocals.volume = 1;

				if (SONG.song.toLowerCase() == 'tutorial')
					tweenCamIn();
			}

			if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection) {
				var camAdd:Array<Int> = ActorSprites["boyfriend"].cameraOffsets;
				var xPos:Float = ActorSprites["boyfriend"].getMidpoint().x - 100;
				var yPos:Float = ActorSprites["boyfriend"].getMidpoint().y - 100;
				if(camAdd != null) {
					xPos += camAdd[0];
					yPos += camAdd[1];
				}

				setCameraPosition(xPos, yPos);

				if (SONG.song.toLowerCase() == 'tutorial')
					FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
			}
		}

		if(camZooming) {
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, FlxMath.bound(1 - (elapsed * 3), 0, 1));
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, FlxMath.bound(1 - (elapsed * 3), 0, 1));
		}

		FlxG.watch.addQuick("beatStuff", curBeat);
		FlxG.watch.addQuick("stepStuff", curStep);

		if(curSong == 'Fresh') {
			switch (curBeat) {
				case 16:
					camZooming = true;
					ActorSprites["girlfriend"].speed = 2;
				case 48:
					ActorSprites["girlfriend"].speed = 1;
				case 80:
					ActorSprites["girlfriend"].speed = 2;
				case 112:
					ActorSprites["girlfriend"].speed = 1;
			}
		}

		// RESET = Quick Game Over Screen
		if(controls.RESET) {
			health = 0;
			trace("RESET = True");
		}

		if(controls.CHEAT) {
			health += 1;
			trace("User is cheating!");
		}

		if(health <= 0) {
			if(practiceMode) {
				if(health < 0)
					health = 0;
			} else {
				ActorSprites["boyfriend"].stunned = true;

				persistentUpdate = false;
				persistentDraw = false;
				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();

				openSubState(new GameOverSubstate(ActorSprites["boyfriend"].getScreenPosition().x, ActorSprites["boyfriend"].getScreenPosition().y));

				#if desktop
					// Game Over doesn't get his own variable because it's only used here
					DiscordClient.changePresence("Game Over - " + detailsText, songName + " (" + storyDifficultyText + ")", iconRPC);
				#end
			}
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

		if(generatedMusic) {
			notes.forEachAlive(function(daNote:Note) {
				if(!daNote.mustPress && Options.middlescroll) {
					daNote.active = true;
					daNote.visible = false;
				} else if(daNote.y > FlxG.height) {
					daNote.active = false;
					daNote.visible = false;
				} else {
					daNote.visible = true;
					daNote.active = true;
				}

				var useNote:FlxSprite = (daNote.mustPress ? playerStrums.members[daNote.noteData] : opponentStrums.members[daNote.noteData]);

				daNote.x = useNote.x;
				if(!daNote.isSustainNote)
					daNote.angle = useNote.angle;
				if(daNote.isSustainNote)
					daNote.x += (useNote.width / 2) - (daNote.width / 2);

				if(Options.downscroll) {
					daNote.y = useNote.y + 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(SONG.speed, 2);

					if (daNote.isSustainNote) {
						if (daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= useNote.y + Note.swagWidth / 2) {
							var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
							swagRect.height = (useNote.y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
							swagRect.y = daNote.frameHeight - swagRect.height;
							daNote.clipRect = swagRect;
						}
					}
				} else {
					daNote.y = useNote.y - 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(SONG.speed, 2);

					if(daNote.isSustainNote) {
						if (daNote.y + daNote.offset.y <= useNote.y + Note.swagWidth / 2) {
							var swagRect = new FlxRect(0, useNote.y + Note.swagWidth / 2 - daNote.y, daNote.width * 2, daNote.height * 2);
							swagRect.y /= daNote.scale.y;
							swagRect.height -= swagRect.y;
							daNote.clipRect = swagRect;
						}
					}
				}

				if(!daNote.mustPress && daNote.wasGoodHit && !daNote.hasBeenHitByBot)
					opponentNoteHit(daNote);

				if(daNote.mustPress && (Options.downscroll ? daNote.y > FlxG.height : daNote.y < 0 - daNote.height) && !botplayMode) {
					if(daNote.tooLate || !daNote.wasGoodHit) {
						lateNoteMiss(daNote);
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				} else if(daNote.mustPress && botplayMode) {
					if(daNote.canBeHit) {
						if(daNote.isSustainNote)
							goodNoteHit(daNote);
						else if((daNote.strumTime + daNote.strumAdd) <= Conductor.songPosition)
							goodNoteHit(daNote);
					}
				}
			});
		}

		if(!inCutscene)
			keyStuff();

		#if debug
			if(FlxG.keys.justPressed.ONE)
				endSong();
		#end
	}

	function updateTrainPos():Void {
		if(trainSound.time >= 4700) {
			startedMoving = true;
			ActorSprites["girlfriend"].playAnim('hairBlow');
		}

		if(startedMoving) {
			phillyTrain.x -= 400;

			if(phillyTrain.x < -2000 && !trainFinishing) {
				phillyTrain.x = -1150;
				trainCars -= 1;

				if(trainCars <= 0)
					trainFinishing = true;
			}

			if(phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}
}
