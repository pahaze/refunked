package;

import flixel.addons.ui.FlxUI.NamedBool;
import haxe.format.JsonParser;
import haxe.Json;
import optimized.OptimizedPlayState;

using StringTools;

typedef UIStyle = {
    var antialiasing:Null<Bool>;
    var comboAsset:Null<String>;
    var graphicSize:Null<Float>;
    var introAssets:Null<Array<String>>;
    var introSounds:Null<Array<String>>;
    var isPixel:Null<Bool>;
    var noteType:Null<String>;
    var numbers:Null<Array<String>>;
    var pixelZoom:Null<Int>;
    var ratingAssets:Null<Array<String>>;
}

class UIStyleSupport {
    static var isModUIStyle:Bool = false;
    static var json:UIStyle;
    static var rawJson:String;

    public static var uiStyleAntialiasing:Bool = true;
    public static var uiStyleComboAsset:String = "combo";
    public static var uiStyleGraphicSize:Float = 0.7;
    public static var uiStyleNoteType:String = "normal";
    public static var uiStyleImageDirectory:String = "assets/shared/images/";
    public static var uiStyleIntroAssets:Array<String> = [
        "ready",
        "set",
        "go"
    ];
    public static var uiStyleIntroSounds:Array<String> = [
        "intro1",
        "intro2",
        "intro3",
        "introGo"
    ];
    public static var uiStyleIsPixel:Bool = false;
    public static var uiStylePixelZoom:Float = 1;
    public static var uiStyleNumbers:Array<String> = [
        "num0",
        "num1",
        "num2",
        "num3",
        "num4",
        "num5",
        "num6",
        "num7",
        "num8",
        "num9"
    ];
    public static var uiStyleRatingMap:Map<String, String> = [
        "sick" => "sick",
        "good" => "good",
        "bad" => "bad",
        "shit" => "shit"
    ];
    public static var uiStyleSoundDirectory:String = "assets/shared/sounds/";

    public static function closeJson() {
        json = null;
        rawJson = "";
    }

    public static function loadUIStyle(uiStyle:String) {
        var mod:String;
        var path:String;
        var uiStyle:String;
        if(Options.useOptimized) {
            mod = OptimizedPlayState.mod;
            uiStyle = OptimizedPlayState.uiStyle;
        } else {
            mod = PlayState.mod;
            uiStyle = PlayState.uiStyle;
        }

        if(mod != null && mod != "") {
            path = ModSupport.modsDirectories[mod] + "uistyles/" + uiStyle + ".json";
            
            if(!Utilities.checkFileExists(path))
                path = "assets/uistyles/" + uiStyle + ".json";

            // repeated lol
            if(!Utilities.checkFileExists(path))
                path = "assets/uistyles/normal.json";

            loadUIJson(path, mod);
        } else {
            path = "assets/uistyles/" + uiStyle + ".json";

            if(!Utilities.checkFileExists(path))
                path = "assets/uistyles/normal.json";

            loadUIJson(path);
            closeJson();
        }
    }

    static function loadUIJson(path:String, ?mod:String) {
        rawJson = Utilities.getFileContents(path);
        rawJson = rawJson.trim();
        while (!rawJson.endsWith("}")) {
            rawJson = rawJson.substr(0, rawJson.length - 1);
        }

        json = Json.parse(rawJson);

        if(mod != null) {
            isModUIStyle = true;
            uiStyleImageDirectory = ModSupport.modsDirectories[mod] + "images/";
            uiStyleSoundDirectory = ModSupport.modsDirectories[mod] + "sounds/";
        }

        if(json.antialiasing != null)
            uiStyleAntialiasing = json.antialiasing;
        if(json.comboAsset != null)
            uiStyleComboAsset = json.comboAsset;
        if(json.graphicSize != null)
            uiStyleGraphicSize = json.graphicSize;
        if(json.introAssets != null)
            uiStyleIntroAssets = json.introAssets;
        if(json.introSounds != null)
            uiStyleIntroSounds = json.introSounds;
        if(json.isPixel != null)
            uiStyleIsPixel = json.isPixel;
        if(json.noteType != null)
            uiStyleNoteType = json.noteType;
        if(json.numbers != null)
            uiStyleNumbers = json.numbers;
        if(json.pixelZoom != null)
            uiStylePixelZoom = json.pixelZoom;
        if(json.ratingAssets != null) {
            uiStyleRatingMap["sick"] = json.ratingAssets[0];
            uiStyleRatingMap["good"] = json.ratingAssets[1];
            uiStyleRatingMap["bad"] = json.ratingAssets[2];
            uiStyleRatingMap["awful"] = json.ratingAssets[3];
        }
    }

    inline public static function image(key:String) {
        var pather:String = uiStyleImageDirectory + key + ".png";
        if(isModUIStyle && Utilities.checkFileExists(pather))
            return uiStyleImageDirectory + key + ".png";
        else
            return "assets/shared/images/" + key + ".png";
    }

    inline public static function sound(key:String) {
        var pather:String = "./" + uiStyleSoundDirectory + key + '.${Paths.SOUND_EXT}';
        if(isModUIStyle && Utilities.checkFileExists(pather))
            return "./" + uiStyleSoundDirectory + key + '.${Paths.SOUND_EXT}';
        else
            return "./assets/shared/sounds/" + key + '.${Paths.SOUND_EXT}';
    }
}