package;

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

	var controlsStrings:Array<String> = [];
	var themesStuff:Array<ThemeUhhh> = [];
	private var grpControls:FlxTypedGroup<Alphabet>;
	var settingsStuff:Array<String> = [];
	#if desktop
		var FpsThing:FlxText;
		var FpsBGThing:FlxSprite;
	#end
	var ThemeThing:FlxText;
	var ThemeBGThing:FlxSprite;

	override function create()
	{
		FlxG.save.bind('refunked', 'pahaze');

		if(FlxG.save.data.useDS == null) {
			FlxG.save.data.useDS = false;
		}

		if(FlxG.save.data.useMS == null) {
			FlxG.save.data.useMS = false;
		}

		if(FlxG.save.data.FPS == null) {
			FlxG.save.data.FPS = 60;
		}

		loadThemes();

		if(FlxG.save.data.theme == null) {
			FlxG.save.data.theme = "default";
		}
		if(FlxG.save.data.themeName == null) {
			FlxG.save.data.themeName = "Default (RFE)";
		}
		if(FlxG.save.data.themeSelectedNo == null) {
			FlxG.save.data.themeSelectedNo = 0;
		}

		settingsStuff.push("Downscroll is " + (FlxG.save.data.useDS ? "Enabled" : "Disabled"));
		settingsStuff.push("Middlescroll is " + (FlxG.save.data.useMS ? "Enabled" : "Disabled"));
		
		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		controlsStrings = CoolUtil.coolTextFile(Paths.txt('controls'));
		menuBG.color = FlxColor.fromRGB(FlxG.random.int(0, 255), FlxG.random.int(0, 255), FlxG.random.int(0, 255));
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);

		grpControls = new FlxTypedGroup<Alphabet>();
		add(grpControls);

		for (i in 0...settingsStuff.length)
		{
			var Text:Alphabet = new Alphabet(0, (70 * i) + 30, settingsStuff[i], true, false);
			Text.isMenuItem = true;
			Text.targetY = i;
			grpControls.add(Text);
		}

		#if desktop
			FpsBGThing = new FlxSprite(0, (FlxG.height * 0.9) + 50).makeGraphic(FlxG.width, Std.int((FlxG.height * 0.9) - 50), FlxColor.BLACK);
			FpsBGThing.alpha = 0.5;
			FpsBGThing.scrollFactor.set();
			add(FpsBGThing);

			FpsThing = new FlxText(5, (FlxG.height * 0.9) + 50, 0, "FPS: " + FlxG.save.data.FPS, 12);
			FpsThing.scrollFactor.set();
			FpsThing.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			add(FpsThing);
		#end

		ThemeBGThing = new FlxSprite(0, 0).makeGraphic(FlxG.width, 20, FlxColor.BLACK);
		ThemeBGThing.alpha = 0.5;
		ThemeBGThing.scrollFactor.set();
		add(ThemeBGThing);

		ThemeThing = new FlxText(5, 1, 0, "Current theme: " + FlxG.save.data.themeName + ". Press A/D to change the theme. Press P to preview the theme.", 16);
		ThemeThing.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		ThemeThing.scrollFactor.set();
		ThemeThing.screenCenter(X);
		add(ThemeThing);

		curSelectedTheme = FlxG.save.data.themeSelectedNo;

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		ThemeThing.screenCenter(X);
			
		if (controls.BACK) {
			FlxG.save.flush();
			FlxG.switchState(new MainMenuState());
		}
		if (controls.UP_P)
			changeSelection(-1);
		if (controls.DOWN_P)
			changeSelection(1);

		if (controls.ACCEPT) {
			if(curSelected != 2) {
				grpControls.remove(grpControls.members[curSelected]);
			}
			switch(curSelected) {
				case 0:
					FlxG.save.data.useDS = !FlxG.save.data.useDS;
					var Text:Alphabet = new Alphabet(0, (70 * curSelected) + 30, "Downscroll is " + (FlxG.save.data.useDS ? "Enabled" : "Disabled"), true, false);
					Text.isMenuItem = true;
					Text.targetY = curSelected;
					grpControls.add(Text);
				case 1:
					FlxG.save.data.useMS = !FlxG.save.data.useMS;
					var Text:Alphabet = new Alphabet(0, (70 * curSelected) + 30, "Middlescroll is " + (FlxG.save.data.useMS ? "Enabled" : "Disabled"), true, false);
					Text.isMenuItem = true;
					Text.targetY = curSelected;
					grpControls.add(Text);
			}
		}

		if(FlxG.keys.justPressed.A) {
			changeThemeSelection(-1);
			FlxG.save.data.theme = themesStuff[curSelectedTheme].ThemeData;
			FlxG.save.data.themeName = themesStuff[curSelectedTheme].ThemeName;
			ThemeThing.text = "Current theme: " + FlxG.save.data.themeName + ". Press A/D to change the theme. Press P to preview the theme.";
		}
		if(FlxG.keys.justPressed.D) {
			changeThemeSelection(1);
			FlxG.save.data.theme = themesStuff[curSelectedTheme].ThemeData;
			FlxG.save.data.themeName = themesStuff[curSelectedTheme].ThemeName;
			ThemeThing.text = "Current theme: " + FlxG.save.data.themeName + ". Press A/D to change the theme. Press P to preview the theme.";
		}
		if(FlxG.keys.justPressed.P) {
			PreviewTheme.SONG = Song.loadFromJson('test-hard', 'test');
			BruhLoadingState.loadAndSwitchState(new PreviewTheme());
		}

		#if desktop
			if(FlxG.keys.justPressed.LEFT) {
				FlxG.save.data.FPS--;
				FpsThing.text = "FPS: " + FlxG.save.data.FPS;
				FlxG.updateFramerate = FlxG.save.data.FPS;
				FlxG.drawFramerate = FlxG.save.data.FPS;
			} else if(FlxG.keys.justPressed.RIGHT) {
				FlxG.save.data.FPS++;
				FpsThing.text = "FPS: " + FlxG.save.data.FPS;
				FlxG.drawFramerate = FlxG.save.data.FPS;
				FlxG.updateFramerate = FlxG.save.data.FPS;
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

		// selector.y = (70 * curSelected) + 30;

		var bullShit:Int = 0;

		for (item in grpControls.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}

	function changeThemeSelection(change:Int = 0) {
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		
		curSelectedTheme += change;

		if(curSelectedTheme < 0) {
			curSelectedTheme = themesStuff.length - 1;
		}
		if (curSelectedTheme >= themesStuff.length) {
			curSelectedTheme = 0;
		}

		FlxG.save.data.themeSelectedNo = curSelectedTheme;
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
			rawJsonFile = whyDoesThisWork("assets/themes/themes.json");
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

	#if html5
	public static function whyDoesThisWork(uh:String):String {
		var bloob = new XMLHttpRequest();
		bloob.open('GET', uh, false);
		bloob.send(null);
		return bloob.responseText;
	}
	#end
}
