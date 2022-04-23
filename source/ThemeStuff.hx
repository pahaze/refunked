package;

import flixel.FlxG;
import flixel.util.FlxSave;
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
import lime.app.Application;

using StringTools;

/// this file is messy Please

typedef ThemeJunk = {
	var AccuracyText:AccuracyText;
	var AccuracyTextEnabled:Bool;
	var BotplayEnabled:Bool;
	var Botplay:Botplay;
	var ExtraEnabled:Bool;
	var Extra:Array<Extra>;
	var HealthbarEnabled:Bool;
	var Healthbar:Healthbar;
	var MissText:MissText;
	var MissTextEnabled:Bool;
	var NPSText:NPSText;
	var NPSTextEnabled:Bool;
	var RatingStyle:String;
	var ScoreEnabled:Bool;
	var Score:Score;
	var TimebarEnabled:Bool;
	var Timebar:Timebar;
	var WatermarkEnabled:Bool;
	var Watermark:Watermark;
}

typedef AccuracyText = {
	var x:Null<Float>;
	var y:Null<Float>;
	var dsy:Null<Float>;
	var text:Null<String>;
}

typedef Botplay = {
	var x:Null<Float>;
	var y:Null<Float>;
	var dsy:Null<Float>;
	var text:Null<String>;
	var center:Null<Bool>;
	var fontsize:Null<Float>;
	var fadeinout:Null<Bool>;
}

typedef Extra = {
	var x:Null<Float>;
	var y:Null<Float>;
	var bottext:Null<String>;
	var centerX:Null<Bool>;
	var centerY:Null<Bool>;
	var dsy:Null<Float>;
	var fontsize:Null<Int>;
	var text:Null<String>;
}

typedef Healthbar = {
	var x:Null<Float>;
	var y:Null<Float>;
	var dsy:Null<Float>;
	var center:Null<Bool>;
	var showP1:Null<Bool>;
	var showP2:Null<Bool>;
}

typedef MissText = {
	var x:Null<Float>;
	var y:Null<Float>;
	var dsy:Null<Float>;
	var text:Null<String>;
}

typedef NPSText = {
	var x:Null<Float>;
	var y:Null<Float>;
	var dsy:Null<Float>;
	var text:Null<String>;
}

typedef Score = {
	var x:Null<Float>;
	var y:Null<Float>;
	var border:Null<Float>;
	var dsy:Null<Float>;
	var text:Null<String>;
	var center:Null<Bool>;
	var fontsize:Null<Float>;
	var bouncetween:Null<Bool>;
}

typedef Timebar = {
	var x:Null<Float>;
	var y:Null<Float>;
	var dsy:Null<Float>;
	var text:Null<String>;
	var center:Null<Bool>;
	var fontsize:Null<Float>;
	var style:Null<String>;
	var bouncetween:Null<Bool>;
	var bouncetweenscale:Null<Float>;
	var textOnly:Null<Bool>;
}

typedef Watermark = {
	var x:Null<Float>;
	var y:Null<Float>;
	var dsy:Null<Float>;
	var text:Null<String>;
	var bottext:Null<String>;
	var practext:Null<String>;
	var pracbottext:Null<String>;
	var center:Null<Bool>;
	var scrolls:Null<Bool>;
}

class ThemeStuff {
	// acc text
	public static var accTextIsEnabled:Bool = false;
	public static var accTextX:Float = 0;
	public static var accTextY:Float = 0;
	public static var accTextDSY:Float = 0;
	// what
	public static var accTextText:String = "";

	// botplay text (this won't apply to RFE's default theme)
	public static var botplayTextIsEnabled:Bool;
	public static var botplayTextX:Float = 0;
	public static var botplayTextDSY:Float = 0;
	public static var botplayTextY:Float = 0;
	public static var botplayCenter:Bool;
	public static var botplayFontsize:Int;
	// psych has the funny
	public static var botplayFadeInAndOut:Bool;
	public static var botplayText:String = "";

	// extra text
	public static var extraTextIsEnabled:Bool;
	public static var extraTextLength:Int;
	public static var extraTextX:Array<Float>;
	public static var extraTextDSY:Array<Float>;
	public static var extraTextY:Array<Float>;
	public static var extraCenterX:Array<Bool>;
	public static var extraCenterY:Array<Bool>;
	public static var extraFontsize:Array<Int>;
	public static var extraText:Array<String>;
	public static var extraBotplayText:Array<String>;

	// healthbar
	public static var healthBarIsEnabled:Bool;
	public static var healthBarX:Float = 0;
	public static var healthBarDSY:Float = 0;
	public static var healthBarY:Float = 0;
	public static var healthBarCenter:Bool;
	public static var healthBarShowP1:Bool;
	public static var healthBarShowP2:Bool;

	// miss text
	public static var missTextIsEnabled:Bool = false;
	public static var missTextX:Float = 0;
	public static var missTextY:Float = 0;
	public static var missTextDSY:Float = 0;
	// what
	public static var missTextText:String = "";

	// nps text
	public static var npsTextIsEnabled:Bool = false;
	public static var npsTextX:Float = 0;
	public static var npsTextY:Float = 0;
	public static var npsTextDSY:Float = 0;
	// what
	public static var npsTextText:String = "";

	// ratings
	public static var ratingStyle:String = "RFE";

	// score txt
	public static var scoreTextIsEnabled:Bool;
	public static var scoreTextX:Float = 0;
	public static var scoreTextDSY:Float = 0;
	public static var scoreTextY:Float = 0;
	public static var scoreTextBorder:Float = 0;
	public static var scoreTextCenter:Bool;
	public static var scoreTextFontsize:Int;
	public static var scoreText:String = "";
	public static var scoreTextHasBounceTween:Bool;
	// Psych like stuff ig ^ (bounces on NOTE HIT, DISABLED by default)

	// time bar stuff
	public static var timeBarIsEnabled:Bool;
	public static var timeBarTextHasBounceTween:Bool = false;
	public static var timeBarTextBounceTweenScale:Float = 0;
	public static var timeBarIsTextOnly:Bool = false;
	public static var timeBarX:Float = 0;
	public static var timeBarDSY:Float = 0;
	public static var timeBarY:Float = 0;
	public static var timeBarCenter:Bool;
	public static var timeBarText:String = "";
	public static var timeBarStyle:String = "";
	public static var timeBarFontsize:Int;

	// watermark
	public static var watermarkIsEnabled:Bool;
	public static var watermarkX:Float = 0;
	public static var watermarkDSY:Float = 0;
	public static var watermarkY:Float = 0;
	public static var watermarkDoesScroll:Bool;
	public static var watermarkText:String = "";
	public static var watermarkBotplayText:String = "";
	public static var watermarkPracticeText:String = "";
	public static var watermarkPracticeBotplayText:String = "";

	// functions
	public static function loadTheme() {
		var rawJsonFile:String;
		var pathToFileIg:String;

		rawJsonFile = Utilities.getFileContents("./assets/themes/" + Options.themeData + ".json");
		rawJsonFile = rawJsonFile.trim();
		
		while (!rawJsonFile.endsWith("}"))
		{
			rawJsonFile = rawJsonFile.substr(0, rawJsonFile.length - 1);
		}

		trace(rawJsonFile);

		var json:ThemeJunk = cast Json.parse(rawJsonFile);

		if(json.AccuracyTextEnabled == true) {
			accTextDSY = json.AccuracyText.dsy;
			accTextText = json.AccuracyText.text;
			accTextX = json.AccuracyText.x;
			accTextY = json.AccuracyText.y;
			accTextIsEnabled = true;
		} else {
			accTextIsEnabled = false;
		}

		if(json.BotplayEnabled == true) {
			botplayCenter = json.Botplay.center;
			botplayFadeInAndOut = json.Botplay.fadeinout;
			botplayFontsize = Std.int(json.Botplay.fontsize);
			botplayText = json.Botplay.text;
			botplayTextDSY = json.Botplay.dsy;
			botplayTextIsEnabled = true;
			botplayTextX = json.Botplay.x;
			botplayTextY = json.Botplay.y;
		} else if (json.BotplayEnabled == false) {
			botplayTextIsEnabled = false;
		}

		if(json.ExtraEnabled == true) {
			resetExtraArrays();
			for(i in 0...json.Extra.length) {
				if(json.Extra[i].centerX != null)
					extraCenterX.push(json.Extra[i].centerX);
				else
					extraCenterX.push(false);
				if(json.Extra[i].centerY != null)
					extraCenterY.push(json.Extra[i].centerY);
				else
					extraCenterY.push(false);
				if(json.Extra[i].fontsize != null)
					extraFontsize.push(json.Extra[i].fontsize);
				else
					extraFontsize.push(16);
				if(json.Extra[i].text != null)
					extraText.push(json.Extra[i].text);
				else
					extraText.push("");
				if(json.Extra[i].bottext != null) {
					extraBotplayText.push(json.Extra[i].bottext);
				} else {
					extraBotplayText.push(extraText[i]);
				}
				if(json.Extra[i].dsy != null)
					extraTextDSY.push(json.Extra[i].dsy);
				else
					extraTextDSY.push(0);
				extraTextIsEnabled = true;
				if(json.Extra[i].x != null)
					extraTextX.push(json.Extra[i].x);
				else
					extraTextX.push(0);
				if(json.Extra[i].y != null)
					extraTextY.push(json.Extra[i].y);
				else
					extraTextY.push(0);
			}
			extraTextLength = json.Extra.length;
		} else if (json.ExtraEnabled == false) {
			extraTextIsEnabled = false;
		}

		if(json.HealthbarEnabled == true) {
			healthBarCenter = json.Healthbar.center;
			healthBarDSY = json.Healthbar.dsy;
			healthBarIsEnabled = true;
			healthBarShowP1 = json.Healthbar.showP1;
			healthBarShowP2 = json.Healthbar.showP2;
			healthBarX = json.Healthbar.x;
			healthBarY = json.Healthbar.y;
		} else if (json.HealthbarEnabled == false) {
			healthBarIsEnabled = false;
		}

		if(json.MissTextEnabled == true) {
			missTextDSY = json.MissText.dsy;
			missTextText = json.MissText.text;
			missTextX = json.MissText.x;
			missTextY = json.MissText.y;
			missTextIsEnabled = true;
		} else {
			missTextIsEnabled = false;
		}

		if(json.NPSTextEnabled == true) {
			npsTextDSY = json.NPSText.dsy;
			npsTextText = json.NPSText.text;
			npsTextX = json.NPSText.x;
			npsTextY = json.NPSText.y;
			npsTextIsEnabled = true;
		} else {
			npsTextIsEnabled = false;
		}
		
		if(json.RatingStyle != null) {
			ratingStyle = json.RatingStyle;
		}

		if(json.ScoreEnabled == true) {
			scoreText = replaceStuffsString(json.Score.text);
			scoreTextBorder = json.Score.border;
			scoreTextCenter = json.Score.center;
			scoreTextDSY = json.Score.dsy;
			scoreTextFontsize = Std.int(json.Score.fontsize);
			scoreTextHasBounceTween = json.Score.bouncetween;
			scoreTextIsEnabled = true;
			scoreTextX = json.Score.x;
			scoreTextY = json.Score.y;
		} else if (json.ScoreEnabled == false) {
			scoreTextIsEnabled = false;
		}

		if(json.TimebarEnabled == true) {
			timeBarCenter = json.Timebar.center;
			timeBarDSY = json.Timebar.dsy;
			timeBarFontsize = Std.int(json.Timebar.fontsize);
			timeBarIsEnabled = true;
			timeBarIsTextOnly = json.Timebar.textOnly;
			timeBarStyle = json.Timebar.style;
			timeBarText = replaceStuffsString(json.Timebar.text);
			timeBarTextBounceTweenScale = json.Timebar.bouncetweenscale;
			timeBarTextHasBounceTween = json.Timebar.bouncetween;
			timeBarX = json.Timebar.x;
			timeBarY = json.Timebar.y;
		} else if(json.TimebarEnabled == false) {
			timeBarIsEnabled = false;
		}

		if(json.WatermarkEnabled == true) {
			watermarkBotplayText = replaceStuffsString(json.Watermark.bottext);
			watermarkDoesScroll = json.Watermark.scrolls;
			watermarkDSY = json.Watermark.dsy;
			watermarkIsEnabled = true;
			watermarkPracticeBotplayText = replaceStuffsString(json.Watermark.pracbottext);
			watermarkPracticeText = replaceStuffsString(json.Watermark.practext);
			watermarkText = replaceStuffsString(json.Watermark.text);
			watermarkX = json.Watermark.x;
			watermarkY = json.Watermark.y;
		} else if (json.WatermarkEnabled == false) {
			watermarkIsEnabled = false;
		}

		rawJsonFile = null;
		pathToFileIg = null;
	}

	static function resetExtraArrays() {
		extraTextLength = 0;
		extraCenterX = [];
		extraCenterY = [];
		extraFontsize = [];
		extraBotplayText = [];
		extraText = [];
		extraTextDSY = [];
		extraTextX = [];
		extraTextY = [];
	}

	public static function replaceStuffsString(strung:String) {
		var uh:String = strung;
		if(uh != null) {
			uh = StringTools.replace(uh, "[version]", Application.current.meta.get('version'));
		}

		return uh;
	}
}
