package;

import Controls.KeyboardScheme;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;

class Options {
	// Volume (Past)
	public static var masterVolume:Float = 1;
	// New Options
	public static var downscroll:Bool = false;
	public static var enableRPC:Bool = true;
	public static var FPS:Int = 60;
	public static var ghostTapping:Bool = false;
	public static var keybindMap:Map<String, Array<FlxKey>> = new Map<String, Array<FlxKey>>();
	public static var middlescroll:Bool = false;

	static var defaultKeybinds:Map<String, Array<FlxKey>> = [
		"UP" => [W, FlxKey.UP],
		"DOWN" => [S, FlxKey.DOWN],
		"LEFT" => [A, FlxKey.LEFT],
		"RIGHT" => [D, FlxKey.RIGHT],
	];

	public static function checkControls() {
		if(FlxG.save.data.keybinds != null)
			keybindMap = FlxG.save.data.keybinds;
		else
			keybindMap = defaultKeybinds.copy();
	}

	public static function loadOptions() {
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

		// Ghost Tapping
		if(FlxG.save.data.ghostTapping != null)
			ghostTapping = FlxG.save.data.ghostTapping;
		else
			ghostTapping = false;

		// Middlescroll
		if(FlxG.save.data.useMS != null)
			middlescroll = FlxG.save.data.useMS;
		else
			middlescroll = false;

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
		FlxG.save.data.useDS = downscroll;
		FlxG.save.data.enableRPC = enableRPC;
		FlxG.save.data.FPS = FPS;
		FlxG.save.data.ghostTapping = ghostTapping;
		FlxG.save.data.keybinds = keybindMap;
		FlxG.save.data.useMS = middlescroll;
		FlxG.save.flush();
	}
}
