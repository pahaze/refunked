package;

import customFlixel.openfl.display.FPS;
#if desktop
	import Discord.DiscordClient;
#end
import flixel.FlxGame;
import lime.app.Application;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.Lib;

class Main extends Sprite {
	var gameInfo = {
		width: 1280, 		  	  // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
		height: 720, 		  	  // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
		initialState: TitleState, // The FlxState the game starts with.
		zoom: -1.0, 			  // If -1, zoom is automatically calculated to fit the window dimensions.
		framerate: 60, 			  // How many frames per second the game should run at.
		skipSplash: true, 		  // Whether to skip the flixel splash screen that appears in release mode.
		startFullscreen: false    // Whether to start the game in fullscreen on desktop targets
	}

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void {
		Lib.current.addChild(new Main());
	}

	public function new() {
		super();

		if (stage != null)
			init();
		else
			addEventListener(Event.ADDED_TO_STAGE, init);
	}

	private function init(?E:Event):Void {
		if (hasEventListener(Event.ADDED_TO_STAGE))
			removeEventListener(Event.ADDED_TO_STAGE, init);

		setupGame();
	}

	private function setupGame():Void {
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (gameInfo.zoom == -1.0) {
			var ratioX:Float = stageWidth / gameInfo.width;
			var ratioY:Float = stageHeight / gameInfo.height;

			gameInfo.zoom = Math.min(ratioX, ratioY);
			gameInfo.width = Math.ceil(stageWidth / gameInfo.zoom);
			gameInfo.height = Math.ceil(stageHeight / gameInfo.zoom);
		}

		#if (flixel < "5.0.0")
			addChild(new FlxGame(gameInfo.width, gameInfo.height, gameInfo.initialState, gameInfo.zoom, gameInfo.framerate, gameInfo.framerate, gameInfo.skipSplash, gameInfo.startFullscreen));
		#else
			addChild(new FlxGame(gameInfo.width, gameInfo.height, gameInfo.initialState, gameInfo.framerate, gameInfo.framerate, gameInfo.skipSplash, gameInfo.startFullscreen));
		#end

		#if !mobile
			addChild(new FPS(10, 3, 0xFFFFFF));
		#end

		#if desktop
			if(!DiscordClient.initialized) {
				DiscordClient.initialize();

				Application.current.onExit.add (function (exitCode) {
					if(DiscordClient.initialized)
						DiscordClient.shutdown();
				});
			}
		#end
	}
}
