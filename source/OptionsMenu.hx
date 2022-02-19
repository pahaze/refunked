package;

#if desktop
import Discord.DiscordClient;
#end
import Controls.Control;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import openfl.Lib;
#if sys
import sys.io.File;
import sys.FileSystem;
#else
import js.html.XMLHttpRequest;
import js.html.XMLHttpRequestResponseType;
import js.html.Response;
import js.html.FileReader;
#end
import haxe.Json;
import haxe.format.JsonParser;

using StringTools;

typedef ThemesStuff = {
	var themes:Array<ThemeUhhh>;
}

typedef ThemeUhhh = {
	var ThemeName:String;
	var ThemeData:String;
}

class OptionsMenu extends MusicBeatState
{
	var selector:FlxText;
	var curSelected:Int = 0;
	var curSelectedTheme:Int = 0;
	var curTab:Int = 0;

	var themesStuff:Array<ThemeUhhh> = [];
	var fpsExtraText:String = " - Press LEFT/RIGHT to change the value by 5 (hold SHIFT to change it by 1). Press T to change tabs. Press ENTER to change options.";
	var fpsWebExtraText:String = "Press T to change tabs. Press ENTER to change options.";
	var grpControls:FlxTypedGroup<FlxText>;
	var grpControlsBools:FlxTypedGroup<FlxText>;
	var grpControlsTabs:FlxTypedGroup<FlxText>;
	var settingsBools:Array<String> = [];
	var settingsStuff:Array<String> = [];
	var settingsTabs:Array<String> = [];
	var FpsThing:FlxText;
	var FpsBGThing:FlxSprite;
	var ThemeThing:FlxText;
	var ThemeBGThing:FlxSprite;

	// Memory
	static var OMLoadedMap:Map<String, Dynamic> = new Map<String, Dynamic>();
	var textCounter:Int = 0;

	override function create()
	{
		MainMenuState.nullMMLoadedAssets();
		Options.loadOptions();
		Paths.nullPathsAssets();
		PreviewTheme.nullPTLoadedAssets();
		loadThemes();
		nullOMLoadedAssets();
		OMLoadedMap = new Map<String, Dynamic>();

		settingsTabs.push("Gameplay");
		settingsTabs.push("User Experience");	

		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		menuBG.color = FlxColor.fromRGB(FlxG.random.int(0, 255), FlxG.random.int(0, 255), FlxG.random.int(0, 255));
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);
		OMLoadedMap["menuBG"] = menuBG;

		var menuGray:FlxSprite = new FlxSprite(30, 60).makeGraphic(1220, 600, FlxColor.BLACK);
		menuGray.alpha = 0.5;
		menuGray.scrollFactor.set();
		add(menuGray);
		OMLoadedMap["menuGray"] = menuGray;

		var tabDividerSprite:FlxSprite = new FlxSprite(30, 112).makeGraphic(1220, 5, FlxColor.BLACK);
		tabDividerSprite.scrollFactor.set();
		add(tabDividerSprite);
		OMLoadedMap["tabDividerSprite"] = tabDividerSprite;

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
			OMLoadedMap["text" + i + settingsTabs[i] + textCounter] = Text;
			textCounter++;
		}

		#if desktop
			FpsBGThing = new FlxSprite(0, (FlxG.height * 0.9) + 50).makeGraphic(FlxG.width, Std.int((FlxG.height * 0.9) - 50), FlxColor.BLACK);
			FpsBGThing.alpha = 0.5;
			FpsBGThing.scrollFactor.set();
			add(FpsBGThing);
			OMLoadedMap["FpsBGThing"] = FpsBGThing;

			FpsThing = new FlxText(5, (FlxG.height * 0.9) + 50, 0, "FPS: " + Options.FPS + fpsExtraText, 12);
			FpsThing.scrollFactor.set();
			FpsThing.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			add(FpsThing);
			OMLoadedMap["FpsThing"] = FpsThing;
		#else
			FpsBGThing = new FlxSprite(0, (FlxG.height * 0.9) + 50).makeGraphic(FlxG.width, Std.int((FlxG.height * 0.9) - 50), FlxColor.BLACK);
			FpsBGThing.alpha = 0.5;
			FpsBGThing.scrollFactor.set();
			add(FpsBGThing);
			OMLoadedMap["FpsBGThing"] = FpsBGThing;

			FpsThing = new FlxText(5, (FlxG.height * 0.9) + 50, 0, fpsWebExtraText, 12);
			FpsThing.scrollFactor.set();
			FpsThing.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			add(FpsThing);
			OMLoadedMap["FpsThing"] = FpsThing;
		#end

		ThemeBGThing = new FlxSprite(0, 0).makeGraphic(FlxG.width, 20, FlxColor.BLACK);
		ThemeBGThing.alpha = 0.5;
		ThemeBGThing.scrollFactor.set();
		add(ThemeBGThing);
		OMLoadedMap["ThemeBGThing"] = ThemeBGThing;

		ThemeThing = new FlxText(5, 1, 0, "Current theme: " + Options.themeName + ". Press A/D to change the theme. Press P to preview the theme.", 16);
		ThemeThing.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		ThemeThing.scrollFactor.set();
		ThemeThing.screenCenter(X);
		add(ThemeThing);
		OMLoadedMap["ThemeThing"] = ThemeThing;

		curSelectedTheme = Options.themeNumber;

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		ThemeThing.screenCenter(X);
			
		if (controls.BACK) {
			Options.saveOptions();
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
							Options.freeplayDialogue = !Options.freeplayDialogue;
							Options.saveOptions();
							grpControlsBools.members[curSelected].text = (Options.freeplayDialogue ? "< ON >" : "< OFF >");
							grpControlsBools.members[curSelected].x = FlxG.width - grpControlsBools.members[curSelected].width - 40;
					}
				case 1:
					switch(curSelected) {
						case 0:
							Options.gameSFW = !Options.gameSFW;
							Options.saveOptions();
							grpControlsBools.members[curSelected].text = (Options.gameSFW ? "< YES >" : "< NO >");
							grpControlsBools.members[curSelected].x = FlxG.width - grpControlsBools.members[curSelected].width - 40;
						#if desktop
							case 1:
								Options.enableRPC = !Options.enableRPC;
								if(Options.enableRPC)
									DiscordClient.initialize();
								else
									DiscordClient.shutdown();
								Options.saveOptions();
								grpControlsBools.members[curSelected].text = (Options.enableRPC ? "< ON >" : "< OFF >");
								grpControlsBools.members[curSelected].x = FlxG.width - grpControlsBools.members[curSelected].width - 40;
						#end
					}
			}
		}

		if(FlxG.keys.justPressed.A) {
			changeThemeSelection(-1);
			Options.themeData = themesStuff[curSelectedTheme].ThemeData;
			Options.themeName = themesStuff[curSelectedTheme].ThemeName;
			Options.saveOptions();
			ThemeThing.text = "Current theme: " + Options.themeName + ". Press A/D to change the theme. Press P to preview the theme.";
		}

		if(FlxG.keys.justPressed.D) {
			changeThemeSelection(1);
			Options.themeData = themesStuff[curSelectedTheme].ThemeData;
			Options.themeName = themesStuff[curSelectedTheme].ThemeName;
			Options.saveOptions();
			ThemeThing.text = "Current theme: " + Options.themeName + ". Press A/D to change the theme. Press P to preview the theme.";
		}

		if(FlxG.keys.justPressed.P) {
			PreviewTheme.SONG = Song.loadFromJson('test-hard', 'test');
			BruhLoadingState.loadAndSwitchState(new PreviewTheme());
		}

		if(FlxG.keys.justPressed.T) {
			changeTab();
		}

		#if desktop
			if(FlxG.keys.justPressed.LEFT) {
				if(FlxG.keys.pressed.SHIFT)
					Options.FPS -= 1;
				else
					Options.FPS -= 5;
				if(Options.FPS < 60)
					Options.FPS = 60;
				Options.saveOptions();
				FpsThing.text = "FPS: " + Options.FPS + fpsExtraText;
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
				FpsThing.text = "FPS: " + Options.FPS + fpsExtraText;
				if(Options.FPS > FlxG.drawFramerate) {
					FlxG.updateFramerate = Options.FPS;
					FlxG.drawFramerate = Options.FPS;
				} else {
					FlxG.drawFramerate = Options.FPS;
					FlxG.updateFramerate = Options.FPS;
				}
			}
		#end
	}

	var isSettingControl:Bool = false;

	function changeSelection(change:Int = 0)
	{
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

	function changeTab() {
		curTab += 1;
		if(curTab > grpControlsTabs.length - 1)
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
			case 1:
				setupUETab();
			default:
				setupGameplayTab();
		}
	}

	function changeThemeSelection(change:Int = 0) {
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		
		curSelectedTheme += change;
		if(curSelectedTheme < 0)
			curSelectedTheme = themesStuff.length - 1;
		if (curSelectedTheme >= themesStuff.length)
			curSelectedTheme = 0;

		Options.themeNumber = curSelectedTheme;
	}

	function loadThemes() {
		var rawJsonFile:String;
        var pathToFileIg:String;

        #if sys
            pathToFileIg = "assets/themes/themes.json";

			rawJsonFile = File.getContent(pathToFileIg);

            while (!rawJsonFile.endsWith("}"))
	    	{
	    		rawJsonFile = rawJsonFile.substr(0, rawJsonFile.length - 1);
	    	}

            var json:ThemesStuff = cast Json.parse(rawJsonFile);
    	#else
			rawJsonFile = Utilities.getFileContents("./assets/themes/themes.json");
            rawJsonFile = rawJsonFile.trim();
        
            while (!rawJsonFile.endsWith("}"))
	    	{
	    		rawJsonFile = rawJsonFile.substr(0, rawJsonFile.length - 1);
	    	}

            trace(rawJsonFile);

            var json:ThemesStuff = cast Json.parse(rawJsonFile);
		#end

		themesStuff = json.themes;
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
		settingsStuff.push("Freeplay Dialogue");
		settingsBools.push((Options.freeplayDialogue ? "< ON >" : "< OFF >"));
		
		for (i in 0...settingsBools.length) {
			var Text:FlxText = new FlxText(FlxG.width - 40, 122 + (32 * i), 0, settingsBools[i]);
			Text.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			Text.borderSize = 1.25;
			Text.x = Text.x - Text.width;
			if(i != 0)
				Text.alpha = 0.6;
			grpControlsBools.add(Text);
			OMLoadedMap["text" + i + settingsBools[i] + textCounter] = Text;
			textCounter++;
		}

		for (i in 0...settingsStuff.length) {
			var Text:FlxText = new FlxText(40, 122 + (32 * i), 0, settingsStuff[i]);
			Text.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			Text.borderSize = 1.25;
			if(i != 0)
				Text.alpha = 0.6;
			grpControls.add(Text);
			OMLoadedMap["text" + i + settingsStuff[i] + textCounter] = Text;
			textCounter++;
		}
	}

	function setupUETab() {
		grpControls.clear();
		grpControlsBools.clear();
		untyped settingsStuff.length = 0;
		untyped settingsBools.length = 0;
		curSelected = 0;

		settingsStuff.push("Game is Kid-friendly?");
        settingsBools.push((Options.gameSFW ? "< YES >" : "< NO >"));
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
			OMLoadedMap["text" + i + settingsBools[i] + textCounter] = Text;
			textCounter++;
		}

		for (i in 0...settingsStuff.length) {
			var Text:FlxText = new FlxText(40, 122 + (32 * i), 0, settingsStuff[i]);
			Text.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			Text.borderSize = 1.25;
			if(i != 0)
				Text.alpha = 0.6;
			grpControls.add(Text);
			OMLoadedMap["text" + i + settingsStuff[i] + textCounter] = Text;
			textCounter++;
		}
	}

	public static function nullOMLoadedAssets():Void
	{
		if(OMLoadedMap != null) {
			for(sprite in OMLoadedMap) {
				sprite.destroy();
			}
		}
		OMLoadedMap = null;
	}
}
