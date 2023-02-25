package;

#if desktop
	import Discord.DiscordClient;
#end
import Controls.Control;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.utils.Assets;
import openfl.Lib;
import haxe.Json;
import haxe.format.JsonParser;

using StringTools;

class OptionsMenu extends MusicBeatState {
	// Keybind Setting --
	var checkingKey:Bool = false;
	var isAltKey:Bool = false;
	var isSettingControl:Bool = false;
	var keybindToReplace:String = null;
	var keybindAlphaScreen:FlxSprite = null;
	var keybindAlphaText:FlxText = null;
	// -- Keybind Setting

	// FPS --
	var fpsExtraText:String = "- Press LEFT/RIGHT to change the value by 5 (hold SHIFT to change it by 1). Press E/R to change tabs. Press ENTER to change options.";
	var FpsThing:FlxText;
	var FpsBGThing:FlxSprite;
	var fpsWebExtraText:String = "Press E/R to change tabs. Press ENTER to change options.";
	// -- FPS

	// Tabs and Settings --
	var curSelected:Int = 0;
	var curTab:Int = 0;
	var grpControls:FlxTypedGroup<FlxText>;
	var grpControlsBools:FlxTypedGroup<FlxText>;
	var grpControlsTabs:FlxTypedGroup<FlxText>;
	var settingsBools:Array<String> = [];
	var settingsStuff:Array<String> = [];
	var settingsTabs:Array<String> = [];
	// -- Tabs and Settings

	// Themes --
	var ThemeBGThing:FlxSprite;
	var ThemeThing:FlxText;
	// -- Themes

	override function create() {
		Options.loadOptions();

		settingsTabs.push("Gameplay");
		#if desktop
			// This will be back on web later.
			settingsTabs.push("User Experience");
		#end
		settingsTabs.push("Keybinds");

		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		menuBG.color = FlxColor.fromRGB(FlxG.random.int(0, 255), FlxG.random.int(0, 255), FlxG.random.int(0, 255));
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);

		var menuGray:FlxSprite = new FlxSprite(30, 60).makeGraphic(1220, 600, FlxColor.BLACK);
		menuGray.alpha = 0.5;
		menuGray.scrollFactor.set();
		add(menuGray);

		var tabDividerSprite:FlxSprite = new FlxSprite(30, 112).makeGraphic(1220, 5, FlxColor.BLACK);
		tabDividerSprite.scrollFactor.set();
		add(tabDividerSprite);

		keybindAlphaScreen = new FlxSprite(-600,-600).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		keybindAlphaScreen.visible = false;
		keybindAlphaScreen.alpha = 0.5;
		keybindAlphaScreen.scrollFactor.set();
		add(keybindAlphaScreen);

		keybindAlphaText = new FlxText(0, 0, 0, "");
		keybindAlphaText.visible = false;
		keybindAlphaText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		keybindAlphaText.scrollFactor.set();
		add(keybindAlphaText);

		grpControls = new FlxTypedGroup<FlxText>();
		add(grpControls);
		grpControlsBools = new FlxTypedGroup<FlxText>();
		add(grpControlsBools);
		grpControlsTabs = new FlxTypedGroup<FlxText>();
		add(grpControlsTabs);

		setupGameplayTab();

		for (i in 0...settingsTabs.length) {
			var Text:FlxText = new FlxText(50, 70, 0, settingsTabs[i]);
			Text.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			Text.borderSize = 1.25;
			if(i != 0) {
				Text.x = grpControlsTabs.members[i - 1].x + grpControlsTabs.members[i - 1].width + 32;
				Text.alpha = 0.6;
			}
			grpControlsTabs.add(Text);
		}

		FpsBGThing = new FlxSprite(0, (FlxG.height * 0.9) + 50).makeGraphic(FlxG.width, Std.int((FlxG.height * 0.9) - 50), FlxColor.BLACK);
		FpsBGThing.alpha = 0.5;
		FpsBGThing.scrollFactor.set();
		add(FpsBGThing);

		FpsThing = new FlxText(5, (FlxG.height * 0.9) + 50, 0, "", 12);
		#if desktop
			FpsThing.text = 'FPS: ${Options.FPS} $fpsExtraText';
		#else
			FpsThing.text = fpsWebExtraText;
		#end
		FpsThing.scrollFactor.set();
		FpsThing.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(FpsThing);

		ThemeBGThing = new FlxSprite(0, 0).makeGraphic(FlxG.width, 20, FlxColor.BLACK);
		ThemeBGThing.alpha = 0.5;
		ThemeBGThing.scrollFactor.set();
		add(ThemeBGThing);

		ThemeThing = new FlxText(5, 1, 0, "Themes will be re-integrated later! For now, you can have the RFE theme :)", 16);
		ThemeThing.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		ThemeThing.scrollFactor.set();
		ThemeThing.screenCenter(X);
		add(ThemeThing);

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		super.create();
	}

	function changeSelection(change:Int = 0) {
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;
		if (curSelected < 0)
			curSelected = grpControls.length - 1;
		if (curSelected >= grpControls.length)
			curSelected = 0;

		for (i in 0...grpControls.length) {
			grpControls.members[i].alpha = 0.6;
		}
		grpControls.members[curSelected].alpha = 1;

		for (i in 0...grpControlsBools.length) {
			grpControlsBools.members[i].alpha = 0.6;
		}
		grpControlsBools.members[curSelected].alpha = 1;
	}

	function changeTab(tabChoice:Int) {
		curTab += tabChoice;

		if(curTab < 0)
			curTab = grpControlsTabs.length - 1;
		if(curTab >= grpControlsTabs.length)
			curTab = 0;

		for(i in 0...grpControlsTabs.length) {
			if(i != curTab)
				grpControlsTabs.members[i].alpha = 0.6;
			else
				grpControlsTabs.members[i].alpha = 1;
		}

		switch(curTab) {
			case 0:
				setupGameplayTab();
			#if desktop
				case 1:
					setupUETab();
				case 2:
					setupKBTab();
			#else
				case 1:
					setupKBTab();
			#end
			default:
				setupGameplayTab();
		}
	}

	function setupGameplayTab() {
		grpControls.clear();
		grpControlsBools.clear();
		untyped settingsStuff.length = 0;
		untyped settingsBools.length = 0;
		curSelected = 0;

		settingsStuff.push("Downscroll");
		settingsBools.push((Options.downscroll ? "< ON >" : "< OFF >"));
		settingsStuff.push("Middlescroll");
		settingsBools.push((Options.middlescroll ? "< ON >" : "< OFF >"));
		settingsStuff.push("Ghost Tapping");
		settingsBools.push((Options.ghostTapping ? "< ON >" : "< OFF >"));

		for (i in 0...settingsBools.length) {
			var Text:FlxText = new FlxText(FlxG.width - 40, 122 + (32 * i), 0, settingsBools[i]);
			Text.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			Text.borderSize = 1.25;
			Text.x = Text.x - Text.width;
			if(i != 0)
				Text.alpha = 0.6;
			grpControlsBools.add(Text);
		}

		for (i in 0...settingsStuff.length) {
			var Text:FlxText = new FlxText(40, 122 + (32 * i), 0, settingsStuff[i]);
			Text.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			Text.borderSize = 1.25;
			if(i != 0)
				Text.alpha = 0.6;
			grpControls.add(Text);
		}
	}

	function setupKBTab() {
		grpControls.clear();
		grpControlsBools.clear();
		untyped settingsStuff.length = 0;
		untyped settingsBools.length = 0;
		curSelected = 0;

		settingsStuff.push("Left");
		settingsBools.push("< " + Options.keybindMap.get("LEFT")[0].toString() + " >");
		settingsStuff.push("Left (Alt)");
		settingsBools.push("< " + Options.keybindMap.get("LEFT")[1].toString() + " >");
		settingsStuff.push("Down");
		settingsBools.push("< " + Options.keybindMap.get("DOWN")[0].toString() + " >");
		settingsStuff.push("Down (Alt)");
		settingsBools.push("< " + Options.keybindMap.get("DOWN")[1].toString() + " >");
		settingsStuff.push("Up");
		settingsBools.push("< " + Options.keybindMap.get("UP")[0].toString() + " >");
		settingsStuff.push("Up (Alt)");
		settingsBools.push("< " + Options.keybindMap.get("UP")[1].toString() + " >");
		settingsStuff.push("Right");
		settingsBools.push("< " + Options.keybindMap.get("RIGHT")[0].toString() + " >");
		settingsStuff.push("Right (Alt)");
		settingsBools.push("< " + Options.keybindMap.get("RIGHT")[1].toString() + " >");

		for (i in 0...settingsBools.length) {
			var Text:FlxText = new FlxText(FlxG.width - 40, 122 + (32 * i), 0, settingsBools[i]);
			Text.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			Text.borderSize = 1.25;
			Text.x = Text.x - Text.width;
			if(i != 0)
				Text.alpha = 0.6;
			grpControlsBools.add(Text);
		}

		for (i in 0...settingsStuff.length) {
			var Text:FlxText = new FlxText(40, 122 + (32 * i), 0, settingsStuff[i]);
			Text.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			Text.borderSize = 1.25;
			if(i != 0)
				Text.alpha = 0.6;
			grpControls.add(Text);
		}
	}

	function setupUETab() {
		grpControls.clear();
		grpControlsBools.clear();
		untyped settingsStuff.length = 0;
		untyped settingsBools.length = 0;
		curSelected = 0;

		#if desktop
			settingsStuff.push("Discord Rich Presence");
			settingsBools.push((Options.enableRPC ? "< ON >" : "< OFF >"));
		#end

		for (i in 0...settingsBools.length) {
			var Text:FlxText = new FlxText(FlxG.width - 40, 122 + (32 * i), 0, settingsBools[i]);
			Text.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			Text.borderSize = 1.25;
			Text.x = Text.x - Text.width;
			if(i != 0)
				Text.alpha = 0.6;
			grpControlsBools.add(Text);
		}

		for (i in 0...settingsStuff.length) {
			var Text:FlxText = new FlxText(40, 122 + (32 * i), 0, settingsStuff[i]);
			Text.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			Text.borderSize = 1.25;
			if(i != 0)
				Text.alpha = 0.6;
			grpControls.add(Text);
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if(!checkingKey) {
			if (controls.BACK) {
				Options.saveOptions();
				Options.reloadControls();
				FlxG.switchState(new MainMenuState());
			}

			if (controls.UP_P)
				changeSelection(-1);

			if (controls.DOWN_P)
				changeSelection(1);

			if (controls.ACCEPT) {
				switch(curTab) {
					case 0:
						switch(curSelected) {
							case 0:
								Options.downscroll = !Options.downscroll;
								Options.saveOptions();
								grpControlsBools.members[curSelected].text = (Options.downscroll ? "< ON >" : "< OFF >");
								grpControlsBools.members[curSelected].x = FlxG.width - grpControlsBools.members[curSelected].width - 40;
							case 1:
								Options.middlescroll = !Options.middlescroll;
								Options.saveOptions();
								grpControlsBools.members[curSelected].text = (Options.middlescroll ? "< ON >" : "< OFF >");
								grpControlsBools.members[curSelected].x = FlxG.width - grpControlsBools.members[curSelected].width - 40;
							case 2:
								Options.ghostTapping = !Options.ghostTapping;
								Options.saveOptions();
								grpControlsBools.members[curSelected].text = (Options.ghostTapping ? "< ON >" : "< OFF >");
								grpControlsBools.members[curSelected].x = FlxG.width - grpControlsBools.members[curSelected].width - 40;
						}
					#if desktop
						case 1:
							switch(curSelected) {
								// Seems weird to have 2 if desktops here, but I'm adding things back later.
								#if desktop
									case 0:
										Options.enableRPC = !Options.enableRPC;
										if(Options.enableRPC) {
											if(!DiscordClient.initialized)
												DiscordClient.initialize();
										} else {
											if(DiscordClient.initialized)
												DiscordClient.shutdown();
										}
										Options.saveOptions();
										grpControlsBools.members[curSelected].text = (Options.enableRPC ? "< ON >" : "< OFF >");
										grpControlsBools.members[curSelected].x = FlxG.width - grpControlsBools.members[curSelected].width - 40;
								#end
							}
						case 2:
							switch(curSelected) {
								case 0:
									checkingKey = true;
									keybindToReplace = "LEFT";
									isAltKey = false;
								case 1:
									checkingKey = true;
									keybindToReplace = "LEFT";
									isAltKey = true;
								case 2:
									checkingKey = true;
									keybindToReplace = "DOWN";
									isAltKey = false;
								case 3:
									checkingKey = true;
									keybindToReplace = "DOWN";
									isAltKey = true;
								case 4:
									checkingKey = true;
									keybindToReplace = "UP";
									isAltKey = false;
								case 5:
									checkingKey = true;
									keybindToReplace = "UP";
									isAltKey = true;
								case 6:
									checkingKey = true;
									keybindToReplace = "RIGHT";
									isAltKey = false;
								case 7:
									checkingKey = true;
									keybindToReplace = "RIGHT";
									isAltKey = true;
							}
					#else
						case 1:
							switch(curSelected) {
								case 0:
									checkingKey = true;
									keybindToReplace = "LEFT";
									isAltKey = false;
								case 1:
									checkingKey = true;
									keybindToReplace = "LEFT";
									isAltKey = true;
								case 2:
									checkingKey = true;
									keybindToReplace = "DOWN";
									isAltKey = false;
								case 3:
									checkingKey = true;
									keybindToReplace = "DOWN";
									isAltKey = true;
								case 4:
									checkingKey = true;
									keybindToReplace = "UP";
									isAltKey = false;
								case 5:
									checkingKey = true;
									keybindToReplace = "UP";
									isAltKey = true;
								case 6:
									checkingKey = true;
									keybindToReplace = "RIGHT";
									isAltKey = false;
								case 7:
									checkingKey = true;
									keybindToReplace = "RIGHT";
									isAltKey = true;
							}
					#end
				}
			}

			if(FlxG.keys.justPressed.E)
				changeTab(-1);

			if(FlxG.keys.justPressed.R)
				changeTab(1);

			#if desktop
				if(FlxG.keys.justPressed.LEFT) {
					if(FlxG.keys.pressed.SHIFT)
						Options.FPS -= 1;
					else
						Options.FPS -= 5;

					if(Options.FPS < 60)
						Options.FPS = 60;

					Options.saveOptions();
					FpsThing.text = 'FPS: ${Options.FPS} $fpsExtraText';
					if(Options.FPS > FlxG.drawFramerate) {
						FlxG.updateFramerate = Options.FPS;
						FlxG.drawFramerate = Options.FPS;
					} else {
						FlxG.drawFramerate = Options.FPS;
						FlxG.updateFramerate = Options.FPS;
					}
				}
				if(FlxG.keys.justPressed.RIGHT) {
					if(FlxG.keys.pressed.SHIFT)
						Options.FPS += 1;
					else
						Options.FPS += 5;

					if(Options.FPS > 450)
						Options.FPS = 450;

					Options.saveOptions();
					FpsThing.text = 'FPS: ${Options.FPS} $fpsExtraText';
					if(Options.FPS > FlxG.drawFramerate) {
						FlxG.updateFramerate = Options.FPS;
						FlxG.drawFramerate = Options.FPS;
					} else {
						FlxG.drawFramerate = Options.FPS;
						FlxG.updateFramerate = Options.FPS;
					}
				}
			#end
		} else {
			keybindAlphaScreen.visible = true;
			keybindAlphaText.text = "Setting keybind for " + grpControls.members[curSelected].text;
			keybindAlphaText.screenCenter();
			keybindAlphaText.visible = true;
			var funnyKey:Int = FlxG.keys.firstJustPressed();
			if(funnyKey > -1) {
				var theArray:Array<FlxKey> = Options.keybindMap.get(keybindToReplace);
				theArray[isAltKey ? 1 : 0] = funnyKey;
				Options.keybindMap.set(keybindToReplace, theArray);
				Options.saveOptions();
				Options.reloadControls();

				grpControlsBools.members[curSelected].text = "< " + theArray[isAltKey ? 1 : 0].toString() + " >";
				grpControlsBools.members[curSelected].x = FlxG.width - grpControlsBools.members[curSelected].width - 40;
				checkingKey = false;
				isAltKey = false;
				keybindToReplace = null;
				keybindAlphaScreen.visible = false;
				keybindAlphaText.visible = false;
			}
		}
	}
}
