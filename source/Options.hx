package;

import Controls.KeyboardScheme;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;

class Options
{
	// volume / past
	public static var masterVolume:Float = 1;
	// new
	public static var downscroll:Bool = false;
	public static var enableRPC:Bool = true;
	public static var FPS:Int = 60;
	public static var freeplayDialogue:Bool = false;
	public static var gameSFW:Bool = true;
	public static var keybindMap:Map<String, Array<FlxKey>> = new Map<String, Array<FlxKey>>();
	public static var middlescroll:Bool = false;
	public static var themeData:String = "default";
	public static var themeName:String = "Default (RFE)";
	public static var themeNumber:Int = 0;

	static var defaultKeybinds:Map<String, Array<FlxKey>> = [
		"UP" => [W, FlxKey.UP],
		"DOWN" => [S, FlxKey.DOWN],
		"LEFT" => [A, FlxKey.LEFT],
		"RIGHT" => [D, FlxKey.RIGHT],
	];

	public static function checkControls() {
		FlxG.save.bind('refunked', 'pahaze');
		if(FlxG.save.data.keybinds != null)
			keybindMap = FlxG.save.data.keybinds;
		else
			keybindMap = defaultKeybinds.copy();
	}

	public static function loadOptions() {
		FlxG.save.bind('refunked', 'pahaze');
		// Downscroll
		if(FlxG.save.data.useDS != null)
			downscroll = FlxG.save.data.useDS;
		else
			downscroll = false;
		// Enable Discord RPC
		if(FlxG.save.data.enableRPC != null)
			enableRPC = FlxG.save.data.enableRPC;
		else
			enableRPC = true;
		// FPS
		if(FlxG.save.data.FPS != null) {
			FPS = FlxG.save.data.FPS;
			if(FPS > FlxG.drawFramerate) {
				FlxG.updateFramerate = FPS;
				FlxG.drawFramerate = FPS;
			} else {
				FlxG.drawFramerate = FPS;
				FlxG.updateFramerate = FPS;
			}
		}
		// Freeplay dialogue
		if(FlxG.save.data.freeplayDialogue != null)
			freeplayDialogue = FlxG.save.data.freeplayDialogue;
		else
			freeplayDialogue = false;
		// Game is safe for work / kid friendly
		if(FlxG.save.data.gameSFW != null)
			gameSFW = FlxG.save.data.gameSFW;
		else
			gameSFW = true;
		// Middlescroll
		if(FlxG.save.data.useMS != null)
			middlescroll = FlxG.save.data.useMS;
		else 
			middlescroll = false;
		// Themes
		// - Data (JSON file)
		if(FlxG.save.data.theme != null)
			themeData = FlxG.save.data.theme;
		else
			themeData = "default";
		// - Names (Theme name)
		if(FlxG.save.data.themeName != null)
			themeName = FlxG.save.data.themeName;
		else
			themeName = "Default (RFE)";
		// - Selected Theme
		if(FlxG.save.data.themeSelectedNo != null)
			themeNumber = FlxG.save.data.themeSelectedNo;
		else
			themeNumber = 0;
		// Keybinds
		if(FlxG.save.data.keybinds != null)
			keybindMap = FlxG.save.data.keybinds;
		else
			keybindMap = defaultKeybinds.copy();
		PlayerSettings.player1.setKeyboardScheme(KeyboardScheme.Solo);
	}

	public static function reloadControls() {
		PlayerSettings.player1.setKeyboardScheme(KeyboardScheme.Solo);
	}

	public static function saveOptions() {
		FlxG.save.bind('refunked', 'pahaze');
		FlxG.save.data.useDS = downscroll;
		FlxG.save.data.enableRPC = enableRPC;
		FlxG.save.data.FPS = FPS;
		FlxG.save.data.freeplayDialogue = freeplayDialogue;
		FlxG.save.data.gameSFW = gameSFW;
		FlxG.save.data.keybinds = keybindMap;
		FlxG.save.data.useMS = middlescroll;
		FlxG.save.data.theme = themeData;
		FlxG.save.data.themeName = themeName;
		FlxG.save.data.themeSelectedNo = themeNumber;
		FlxG.save.flush();
	}
}