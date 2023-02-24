package;

#if desktop
	import Discord.DiscordClient;
#end
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.events.IOErrorEvent;
import openfl.events.SecurityErrorEvent;
import openfl.net.URLLoader;
import openfl.net.URLRequest;
import ui.AtlasMenuItem;
import ui.MenuItem;
import ui.MenuTypedList;

using StringTools;

class MainMenuState extends MusicBeatState {
	// Menu Items --
	var curSelected:Int = 0;
	var menuItems:MainMenuList;
	var optionShit:Array<String> = ['story mode', 'freeplay', 'options'];
	var selectedSomethin:Bool = false;
	// -- Menu Items

	// Camera Stuff --
	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPoint:FlxObject;
	// -- Camera Stuff

	// Updating --
	var refunkedVersion:FlxText;
	var updateAvailabilityText:FlxText;
	var updateChecker:URLLoader;
	var vanillaVersion:FlxText;
	// -- Updating

	override function create() {
		#if desktop
			// Updating Discord Rich Presence
			DiscordClient.changePresence("In the Main Menu", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		if (!FlxG.sound.music.playing)
			FlxG.sound.playMusic(Paths.music('freakyMenu'));

		persistentUpdate = true;
		persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.18;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		camFollowPoint = new FlxObject(0, 0, 1, 1);
		add(camFollowPoint);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.x = 0;
		magenta.scrollFactor.y = 0.18;
		magenta.setGraphicSize(Std.int(magenta.width * 1.1));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = true;
		magenta.color = 0xFFfd719b;
		add(magenta);

		menuItems = new MainMenuList();
		add(menuItems);
		menuItems.onChange.add(onMenuItemChange);
		menuItems.onAcceptPress.add(function(item:MenuItem) {
			FlxFlicker.flicker(magenta, 1.1, 0.15, false, true);
		});
		menuItems.enabled = false;

		// Story Mode
		menuItems.createItem(0, 0, "story mode", function() {
			startExitState(new StoryMenuState());
		});

		// Freeplay
		menuItems.createItem(0, 0, "freeplay", function() {
			startExitState(new FreeplayState());
		});

		// Options
		menuItems.createItem(0, 0, "options", function() {
			startExitState(new OptionsMenu());
		});

		var pos:Float = (FlxG.height - 280 * (menuItems.length - 1)) / 2;
		for (i in 0...menuItems.length) {
			var item:MainMenuItem = menuItems.members[i];
			item.x = FlxG.width / 2;
			item.y = pos + (180 * i);
		}

		FlxG.camera.follow(camFollowPoint, null, 0.06);

		vanillaVersion = new FlxText(5, FlxG.height - 54, 0, "Friday Night Funkin v0.2.8", 12);
		vanillaVersion.scrollFactor.set();
		vanillaVersion.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(vanillaVersion);

		refunkedVersion = new FlxText(5, FlxG.height - 36, 0, 'ReFunked v${Application.current.meta.get('version')}', 12);
		refunkedVersion.scrollFactor.set();
		refunkedVersion.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(refunkedVersion);

		updateAvailabilityText = new FlxText(5, FlxG.height - 18, 0, "Checking for updates...", 12);
		updateAvailabilityText.scrollFactor.set();
		updateAvailabilityText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(updateAvailabilityText);

		updateChecker = new URLLoader();
		updateChecker.dataFormat = TEXT;
		updateChecker.load(new URLRequest("https://raw.githubusercontent.com/pahaze/refunked/rewrite/CurrentVersion.txt"));
		updateChecker.addEventListener(openfl.events.Event.COMPLETE, checkUpdateAvailability);
		updateChecker.addEventListener(IOErrorEvent.IO_ERROR, failedUpdateCheck);
		updateChecker.addEventListener(SecurityErrorEvent.SECURITY_ERROR, failedUpdateCheck);

		changeItem();

		super.create();
	}

	function changeItem(huh:Int = 0) {
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite) {
			spr.animation.play('idle');

			if (spr.ID == curSelected) {
				spr.animation.play('selected');
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
			}

			spr.updateHitbox();
		});
	}

	function checkUpdateAvailability(event:openfl.events.Event) {
		var gitVersion:String = Std.string(updateChecker.data);
		if(gitVersion == Application.current.meta.get('version'))
			updateAvailabilityText.text = "No updates available!";
		else
			updateAvailabilityText.text = 'Update available! New version: $gitVersion';
	}

	function failedUpdateCheck(event:openfl.events.Event) {
		updateAvailabilityText.text = "Unable to check for updates!";
	}

	function onMenuItemChange(item:MenuItem) {
		camFollow.setPosition(item.getGraphicMidpoint().x, item.getGraphicMidpoint().y);
	}

	function startExitState(nextState:FlxState) {
		menuItems.enabled = false;
		menuItems.forEach(function(item:MainMenuItem) {
			if (menuItems.selectedIndex != item.ID)
				FlxTween.tween(item, { alpha: 0 }, 0.4, { ease: FlxEase.quadOut });
			else
				item.visible = false;
		});
		new FlxTimer().start(0.4, function(tmr:FlxTimer) {
			FlxG.switchState(nextState);
		});
	}


	override function update(elapsed:Float) {
		if (FlxG.sound.music.volume < 0.8)
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

		var cameraTiming:Float = FlxMath.bound(elapsed * 3.5, 0, 1);
		camFollowPoint.setPosition(FlxMath.lerp(camFollow.x, camFollowPoint.x, cameraTiming), FlxMath.lerp(camFollow.y, camFollowPoint.y, cameraTiming));

		if (!selectedSomethin) {
			if (controls.UP_P) {
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.DOWN_P) {
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
				FlxG.switchState(new TitleState());

			if (controls.ACCEPT) {
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));

				FlxFlicker.flicker(magenta, 1.1, 0.15, false);

				menuItems.forEach(function(spr:FlxSprite) {
					if (curSelected != spr.ID) {
						FlxTween.tween(spr, {alpha: 0}, 0.4, {
							ease: FlxEase.quadOut,
							onComplete: function(twn:FlxTween) {
								spr.kill();
							}
						});
					} else {
						FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker) {
							var daChoice:String = optionShit[curSelected];
							switch (daChoice) {
								case 'story mode':
									FlxG.switchState(new StoryMenuState());
									trace("Story Mode Menu Selected");
								case 'freeplay':
									FlxG.switchState(new FreeplayState());
									trace("Freeplay Menu Selected");
								case 'options':
									FlxG.switchState(new OptionsMenu());
									trace("Options Menu Selected");
							}
						});
					}
				});
			}
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite) {
			spr.screenCenter(X);
		});
	}
}

class MainMenuItem extends AtlasMenuItem {
	public function new(?x:Float = 0, ?y:Float = 0, name:String, atlas:FlxAtlasFrames, callback:Dynamic) {
		super(x, y, name, atlas, callback);

		this.scrollFactor.set();
	}

	override public function changeAnim(anim:String) {
		super.changeAnim(anim);
		origin.set(frameWidth * 0.5, frameHeight * 0.5);
		origin.copyFrom(origin);
	}
}

class MainMenuList extends MenuTypedList<MainMenuItem> {
	var atlas:FlxAtlasFrames;

	public function new() {
		atlas = Paths.getSparrowAtlas('mainmenu/main_menu');
		super(Vertical);
	}

	public function createItem(?x:Float = 0, ?y:Float = 0, name:String, callback:Dynamic = null, fireInstantly:Bool = false) {
		var item:MainMenuItem = new MainMenuItem(x, y, name, atlas, callback);
		item.fireInstantly = fireInstantly;
		item.ID = length;
		return addItem(name, item);
	}
}
