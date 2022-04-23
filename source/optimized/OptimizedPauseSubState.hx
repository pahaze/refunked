package optimized;

import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class OptimizedPauseSubState extends MusicBeatSubstate
{
	var grpMenuStuff:FlxTypedGroup<Alphabet>;

	var curSelected:Int = 0;
	public static var PSSLoadedAssets:Array<Dynamic> = [];
	var menuItems:Array<String> = ['Resume', 'Restart Song', 'Botplay', 'Practice Mode'];
	var botplayText:FlxText;
	var practiceText:FlxText;

	var pauseMusic:FlxSound;

	public function new(x:Float, y:Float)
	{
		super();
		
		if(OptimizedPlayState.isStoryMode) {
			menuItems.push("Exit to Story Mode Menu");
			menuItems.push("Exit to menu");
		} else {
			menuItems.push("Exit to Freeplay Menu");
			menuItems.push("Exit to menu");
		}

		pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += OptimizedPlayState.songName;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, "", 32);
		levelDifficulty.text += OptimizedPlayState.storyDifficultyText;
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		botplayText = new FlxText(20, 47+32, 0, "BOTPLAY", 32);
		botplayText.scrollFactor.set();
		botplayText.setFormat(Paths.font("vcr.ttf"), 32);
		botplayText.updateHitbox();
		botplayText.visible = OptimizedPlayState.botplayIsEnabled;
		add(botplayText);

		practiceText = new FlxText(20, (botplayText.visible ? 79+32 : 47+32), 0, "PRACTICE", 32);
		practiceText.scrollFactor.set();
		practiceText.setFormat(Paths.font("vcr.ttf"), 32);
		practiceText.updateHitbox();
		practiceText.visible = OptimizedPlayState.PracticeMode;
		add(practiceText);

		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;
		botplayText.alpha = 0;
		practiceText.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);
		botplayText.x = FlxG.width - (botplayText.width + 20);
		practiceText.x = FlxG.width - (practiceText.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
		FlxTween.tween(botplayText, {alpha: 1, y: botplayText.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});
		FlxTween.tween(practiceText, {alpha: 1, y: practiceText.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: (botplayText.visible ? 0.9 : 0.7)});

		grpMenuStuff = new FlxTypedGroup<Alphabet>();
		add(grpMenuStuff);

		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuStuff.add(songText);
		}

		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function add(Object:flixel.FlxBasic):flixel.FlxBasic
	{
		PSSLoadedAssets.insert(PSSLoadedAssets.length, Object);
		return super.add(Object);
	}

	override function update(elapsed:Float)
	{
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (accepted)
		{
			var daSelected:String = menuItems[curSelected];

			switch (daSelected)
			{
				case "Resume":
					close();
				case "Restart Song":
					close();
					FlxG.switchState(new OptimizedPlayState());
				case "Exit to menu":
					unloadPlayStateLoadedAssets();
					unloadLoadedAssets();
					#if sys
							OptimizedPlayState.OptimizedPlayStateThing.luaCallback("endSong", []);
					#end
					OptimizedPlayState.OptimizedPlayStateThing.unloadMBSassets();
					OptimizedPlayState.OptimizedPlayStateThing.destroyLuaObjects();
					OptimizedPlayState.OptimizedPlayStateThing.killLuaBruh();
					OptimizedPlayState.OptimizedPlayStateThing.fixModStuff();
					FlxG.switchState(new MainMenuState());
				case "Botplay":
					OptimizedPlayState.botplayIsEnabled = !OptimizedPlayState.botplayIsEnabled;
					botplayText.visible = OptimizedPlayState.botplayIsEnabled;
					if(botplayText.visible) {
						practiceText.y = 116;
					} else {
						practiceText.y = 84;
					}
				case "Practice Mode":
					OptimizedPlayState.PracticeMode = !OptimizedPlayState.PracticeMode;
					practiceText.visible = OptimizedPlayState.PracticeMode;
					if(botplayText.visible) {
						practiceText.y = 116;
					} else {
						practiceText.y = 84;
					}
				case "Exit to Story Mode Menu":
					unloadPlayStateLoadedAssets();
					unloadLoadedAssets();
					#if sys
						OptimizedPlayState.OptimizedPlayStateThing.luaCallback("endSong", []);
					#end
					OptimizedPlayState.OptimizedPlayStateThing.unloadMBSassets();
					OptimizedPlayState.OptimizedPlayStateThing.destroyLuaObjects();
					OptimizedPlayState.OptimizedPlayStateThing.killLuaBruh();
					OptimizedPlayState.OptimizedPlayStateThing.fixModStuff();
					FlxG.switchState(new StoryMenuState());
				case "Exit to Freeplay Menu":
					unloadPlayStateLoadedAssets();
					unloadLoadedAssets();
					#if sys
						OptimizedPlayState.OptimizedPlayStateThing.luaCallback("endSong", []);
					#end
					OptimizedPlayState.OptimizedPlayStateThing.unloadMBSassets();
					OptimizedPlayState.OptimizedPlayStateThing.destroyLuaObjects();
					OptimizedPlayState.OptimizedPlayStateThing.killLuaBruh();
					OptimizedPlayState.OptimizedPlayStateThing.fixModStuff();
					FlxG.switchState(new FreeplayState());
			}
		}
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bull:Int = 0;

		for (item in grpMenuStuff.members)
		{
			item.targetY = bull - curSelected;
			bull++;

			item.alpha = 0.6;

			if (item.targetY == 0)
			{
				item.alpha = 1;
			}
		}
	}

	function unloadPlayStateLoadedAssets():Void
	{
		OptimizedPlayState.OptimizedPlayStateThing.unloadLoadedAssets();
	}

	function unloadLoadedAssets():Void
	{
		for (asset in PSSLoadedAssets)
		{
			remove(asset);
		}
	}
}
