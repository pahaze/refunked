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
    var Extra:Extra;
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
    var x:Float;
    var y:Float;
    var dsy:Float;
    var text:String;
}

typedef Botplay = {
    var x:Float;
    var y:Float;
    var dsy:Float;
    var text:String;
    var center:Bool;
    var fontsize:Float;
    var fadeinout:Bool;
}

typedef Extra = {
    var x:Float;
    var y:Float;
    var center:Bool;
    var dsy:Float;
    var fontsize:Int;
    var text:String;
}

typedef Healthbar = {
    var x:Float;
    var y:Float;
    var dsy:Float;
    var center:Bool;
    var showP1:Bool;
    var showP2:Bool;
}

typedef MissText = {
    var x:Float;
    var y:Float;
    var dsy:Float;
    var text:String;
}

typedef NPSText = {
    var x:Float;
    var y:Float;
    var dsy:Float;
    var text:String;
}

typedef Score = {
    var x:Float;
    var y:Float;
    var border:Float;
    var dsy:Float;
    var text:String;
    var center:Bool;
    var fontsize:Float;
    var bouncetween:Bool;
}

typedef Timebar = {
    var x:Float;
    var y:Float;
    var dsy:Float;
    var text:String;
    var center:Bool;
    var fontsize:Float;
    var style:String;
    var bouncetween:Bool;
    var bouncetweenscale:Float;
    var textOnly:Bool;
}

typedef Watermark = {
    var x:Float;
    var y:Float;
    var dsy:Float;
    var text:String;
    var bottext:String;
    var practext:String;
    var pracbottext:String;
    var center:Bool;
    var scrolls:Bool;
}

class ThemeStuff {
    // acc text
    public static var accTextIsEnabled:Bool = false;
    public static var accTextX:Float;
    public static var accTextY:Float;
    public static var accTextDSY:Float;
    // what
    public static var accTextText:String;

    // botplay text (this won't apply to RFE's default theme)
    public static var botplayTextIsEnabled:Bool;
    public static var botplayTextX:Float;
    public static var botplayTextDSY:Float;
    public static var botplayTextY:Float;
    public static var botplayCenter:Bool;
    public static var botplayFontsize:Int;
    // psych has the funny
    public static var botplayFadeInAndOut:Bool;
    public static var botplayText:String;

    // extra text
    public static var extraTextIsEnabled:Bool;
    public static var extraTextX:Float;
    public static var extraTextDSY:Float;
    public static var extraTextY:Float;
    public static var extraCenter:Bool = false;
    public static var extraFontsize:Int;
    public static var extraText:String;

    // healthbar
    public static var healthBarIsEnabled:Bool;
    public static var healthBarX:Float;
    public static var healthBarDSY:Float;
    public static var healthBarY:Float;
    public static var healthBarCenter:Bool;
    public static var healthBarShowP1:Bool;
    public static var healthBarShowP2:Bool;

    // miss text
    public static var missTextIsEnabled:Bool = false;
    public static var missTextX:Float;
    public static var missTextY:Float;
    public static var missTextDSY:Float;
    // what
    public static var missTextText:String;

    // nps text
    public static var npsTextIsEnabled:Bool = false;
    public static var npsTextX:Float;
    public static var npsTextY:Float;
    public static var npsTextDSY:Float;
    // what
    public static var npsTextText:String;

    // ratings
    public static var ratingStyle:String = "RFE";

    // score txt
    public static var scoreTextIsEnabled:Bool;
    public static var scoreTextX:Float;
    public static var scoreTextDSY:Float;
    public static var scoreTextY:Float;
    public static var scoreTextBorder:Float = 0;
    public static var scoreTextCenter:Bool;
    public static var scoreTextFontsize:Int;
    public static var scoreText:String;
    public static var scoreTextHasBounceTween:Bool;
    // Psych like stuff ig ^ (bounces on NOTE HIT, DISABLED by default)

    // time bar stuff
    public static var timeBarIsEnabled:Bool;
    public static var timeBarTextHasBounceTween:Bool = false;
    public static var timeBarTextBounceTweenScale:Float;
    public static var timeBarIsTextOnly:Bool = false;
    public static var timeBarX:Float;
    public static var timeBarDSY:Float;
    public static var timeBarY:Float;
    public static var timeBarCenter:Bool;
    public static var timeBarText:String;
    public static var timeBarStyle:String;
    public static var timeBarFontsize:Int;

    // watermark
    public static var watermarkIsEnabled:Bool;
    public static var watermarkX:Float;
    public static var watermarkDSY:Float;
    public static var watermarkY:Float;
    public static var watermarkDoesScroll:Bool;
    public static var watermarkText:String;
    public static var watermarkBotplayText:String;
    public static var watermarkPracticeText:String;
    public static var watermarkPracticeBotplayText:String;

    // functions
    public static function loadTheme() {
        var rawJsonFile:String;
        var pathToFileIg:String;

        #if sys
            pathToFileIg = "assets/themes/" + FlxG.save.data.theme + ".json";
			if(!FileSystem.exists(pathToFileIg)) {
				pathToFileIg = "assets/themes/default.json";
			}

			rawJsonFile = File.getContent(pathToFileIg);

            while (!rawJsonFile.endsWith("}"))
	    	{
	    		rawJsonFile = rawJsonFile.substr(0, rawJsonFile.length - 1);
	    	}

            var json:ThemeJunk = cast Json.parse(rawJsonFile);
    	#else
			rawJsonFile = whyDoesThisWork("assets/themes/" + FlxG.save.data.theme + ".json");
            rawJsonFile = rawJsonFile.trim();
        
            while (!rawJsonFile.endsWith("}"))
	    	{
	    		rawJsonFile = rawJsonFile.substr(0, rawJsonFile.length - 1);
	    	}

            trace(rawJsonFile);

            var json:ThemeJunk = cast Json.parse(rawJsonFile);
		#end

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
            extraCenter = json.Extra.center;
            extraFontsize = json.Extra.fontsize;
            extraText = json.Extra.text;
            extraTextDSY = json.Extra.dsy;
            extraTextIsEnabled = true;
            extraTextX = json.Extra.x;
            extraTextY = json.Extra.y;
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

    public static function replaceStuffsString(strung:String) {
        var uh:String = strung;
        if(uh != null) {
            uh = StringTools.replace(uh, "[version]", Application.current.meta.get('version'));
        }

        return uh;
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
