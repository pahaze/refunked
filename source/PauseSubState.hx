package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class PauseSubState extends MusicBeatSubstate {
	// Menu Items --
	var grpMenuStuff:FlxTypedGroup<Alphabet>;
	var menuItems:Array<String> = ['Resume', 'Restart Song', 'Botplay', 'Practice Mode'];
	var curSelected:Int = 0;
	// -- Menu Items

	// Text / Music --
	var botplayText:FlxText;
	var pauseMusic:FlxSound;
	var practiceText:FlxText;
	var scoredText:FlxText;
	// -- Text / Music

	public function new(x:Float, y:Float) {
		super();

		if(PlayState.isStoryMode) {
			menuItems.push("Exit to Story Mode Menu");
			menuItems.push("Exit to Menu");
		} else {
			menuItems.push("Exit to Freeplay Menu");
			menuItems.push("Exit to Menu");
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
		levelInfo.text += PlayState.PlayStateInstance.songName;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat("VCR OSD Mono", 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, "", 32);
		levelDifficulty.text += CoolUtil.difficultyString();
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat("VCR OSD Mono", 32);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		botplayText = new FlxText(20, 47+32, 0, "BOTPLAY", 32);
		botplayText.scrollFactor.set();
		botplayText.setFormat("VCR OSD Mono", 32);
		botplayText.updateHitbox();
		botplayText.visible = PlayState.PlayStateInstance.botplayMode;
		add(botplayText);

		practiceText = new FlxText(20, (botplayText.visible ? 79+32 : 47+32), 0, "PRACTICE", 32);
		practiceText.scrollFactor.set();
		practiceText.setFormat("VCR OSD Mono", 32);
		practiceText.updateHitbox();
		practiceText.visible = PlayState.PlayStateInstance.practiceMode;
		add(practiceText);

		scoredText = new FlxText(20, FlxG.height - 52, 0, "NOT SCORED", 32);
		scoredText.scrollFactor.set();
		scoredText.setFormat("VCR OSD Mono", 32);
		scoredText.updateHitbox();
		scoredText.visible = !PlayState.PlayStateInstance.scored;
		add(scoredText);

		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;
		botplayText.alpha = 0;
		practiceText.alpha = 0;
		scoredText.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);
		botplayText.x = FlxG.width - (botplayText.width + 20);
		practiceText.x = FlxG.width - (practiceText.width + 20);
		scoredText.x = FlxG.width - (scoredText.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
		FlxTween.tween(botplayText, {alpha: 1, y: botplayText.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});
		FlxTween.tween(practiceText, {alpha: 1, y: practiceText.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: (botplayText.visible ? 0.9 : 0.7)});

		var scoredTextDelay:Float = 0.7;
		if(botplayText.visible && practiceText.visible)
			scoredTextDelay = 1.1;
		if((botplayText.visible && !practiceText.visible) || (!botplayText.visible && practiceText.visible))
			scoredTextDelay = 0.9;

		FlxTween.tween(scoredText, {alpha: 1, y: scoredText.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 1.1});

		grpMenuStuff = new FlxTypedGroup<Alphabet>();
		add(grpMenuStuff);

		for (i in 0...menuItems.length) {
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuStuff.add(songText);
		}

		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	function changeSelection(change:Int = 0):Void {
		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var currentItem:Int = 0;

		for (item in grpMenuStuff.members) {
			item.targetY = currentItem - curSelected;
			currentItem++;

			item.alpha = 0.6;

			if (item.targetY == 0)
				item.alpha = 1;
		}
	}

	override function destroy() {
		pauseMusic.destroy();

		super.destroy();
	}

	override function update(elapsed:Float) {
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);

		PlayState.PlayStateInstance.setIconP1Positions();
		PlayState.PlayStateInstance.setIconP2Positions();

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
			changeSelection(-1);
		if (downP)
			changeSelection(1);

		if (accepted) {
			var daSelected:String = menuItems[curSelected];

			switch (daSelected) {
				case "Botplay":
					PlayState.PlayStateInstance.botplayMode = !PlayState.PlayStateInstance.botplayMode;
					botplayText.visible = PlayState.PlayStateInstance.botplayMode;
					if(botplayText.visible)
						practiceText.y = 116;
					else
						practiceText.y = 84;

				case "Exit to Freeplay Menu":
					FlxG.switchState(new FreeplayState());

				case "Exit to Menu":
					FlxG.switchState(new MainMenuState());

				case "Exit to Story Mode Menu":
					FlxG.switchState(new StoryMenuState());

				case "Practice Mode":
					PlayState.PlayStateInstance.practiceMode = !PlayState.PlayStateInstance.practiceMode;
					practiceText.visible = PlayState.PlayStateInstance.practiceMode;
					if(botplayText.visible)
						practiceText.y = 116;
					else
						practiceText.y = 84;

				case "Restart Song":
					FlxG.resetState();

				case "Resume":
					close();
			}
		}
	}
}
