package optimized;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.input.gamepad.FlxGamepad;
import flixel.system.FlxSound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class OptimizedGameOverSubstate extends MusicBeatSubstate
{
	var lossSound:FlxSound;
	var stageSuffix:String = "";

	var loser:FlxSprite;
	var restart:FlxSprite;

	public function new(x:Float, y:Float)
	{
		Paths.nullPathsAssets();
		if(OptimizedPlayState.uiStyle == "pixel")
			stageSuffix = "-pixel";

		super();

		loser = new FlxSprite(100, 100);
		loser.frames = Paths.getSparrowAtlas("lose", "shared");
		loser.animation.addByPrefix('lose', 'lose', 24, false);
		loser.animation.play('lose');
		add(loser);

		restart = new FlxSprite(500, 50).loadGraphic(Paths.image("restart", "shared"));
		restart.setGraphicSize(Std.int(restart.width * 0.6));
		restart.updateHitbox();
		restart.alpha = 0;
		restart.antialiasing = true;
		add(restart);

		Conductor.changeBPM(100);
		lossSound = new FlxSound().loadEmbedded(Paths.sound('fnf_loss_sfx' + stageSuffix));
		lossSound.play();

		FlxTween.tween(restart, {alpha: 1}, 1, {ease: FlxEase.quartInOut});
		FlxTween.tween(restart, {y: restart.y + 40}, 7, {ease: FlxEase.quartInOut, type: PINGPONG});
	}

	private var fading:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.ACCEPT)
		{
			endBull();
		}

		if (controls.BACK)
		{
			FlxG.sound.music.stop();

			if (OptimizedPlayState.isStoryMode)
				FlxG.switchState(new StoryMenuState());
			else
				FlxG.switchState(new FreeplayState());
		}

		lossSound.onComplete = function() {
			FlxG.sound.playMusic(Paths.music('gameOver' + stageSuffix));
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
	}

	override function beatHit()
	{
		super.beatHit();

		FlxG.log.add('beat');
	}

	var isEnding:Bool = false;
	function endBull():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music('gameOverEnd' + stageSuffix));
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					loser.destroy();
					restart.destroy();
					OptimizedLoadingState.loadAndSwitchState(new OptimizedPlayState());
				});
			});
		}
	}
}
