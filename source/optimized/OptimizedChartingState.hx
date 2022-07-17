package optimized;

import flixel.FlxObject;
#if desktop
import Discord.DiscordClient;
#end
import Conductor.BPMChangeEvent;
import Section.SwagSection;
import Song.SwagSong;
import Song.GameOver;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.media.Sound;
import openfl.net.FileReference;
import openfl.utils.ByteArray;

using StringTools;

class OptimizedChartingState extends MusicBeatState
{
	var cameraPosition:FlxObject;

	var _file:FileReference;
	var UI_box:FlxUITabMenu;

	var curSection:Int = 0;
	public static var lastSection:Int = 0;

	var bpmTxt:FlxText;
	var strumLine:FlxSprite;
	var curSong:String = 'Dadbattle';
	var commonStagesLabel:String = "";
	var storyWeek:Int = 1;
	var amountSteps:Int = 0;
	var bullshitUI:FlxGroup;

	var highlight:FlxSprite;
	var GRID_SIZE:Int = 40;
	var dummyArrow:FlxSprite;

	var curRenderedNotes:FlxTypedGroup<Note>;
	var curRenderedSustains:FlxTypedGroup<FlxSprite>;

	var gridBG:FlxSprite;
	var _song:SwagSong;

	var typingStuff:FlxInputText;
	var moreTypingStuff:FlxInputText;
	var curSelectedNote:Array<Dynamic>;

	var tempBpm:Int = 0;

	var inst:FlxSound;
	var vocals:FlxSound;

	var leftIcon:HealthIcon;
	var rightIcon:HealthIcon;

	static var OCSLoadedMap:Map<String, Dynamic> = new Map<String, Dynamic>();

	var scrollBlockThing:Array<FlxUIDropDownMenuCustom> = [];
	var blockedScroll:Bool = false;

	var noteType:String = "";

	override function create()
	{
		OCSLoadedMap = new Map<String, Dynamic>();
		curSection = lastSection;

		gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 8, GRID_SIZE * 16);
		add(gridBG);

		if (OptimizedPlayState.SONG != null) {
			_song = OptimizedPlayState.SONG;
			storyWeek = OptimizedPlayState.storyWeek;
		} else {
			_song = {
				song: 'Untitled',
				songName: 'Untitled',
				notes: [],
				bpm: 150,
				needsVoices: true,
				gameOver: {
					boyfriend: 'bf',
					deathAnim: 'firstDeath',
					deathFinishAnim: 'deathConfirm'
				},
				player1: 'bf',
				player2: 'dad',
				gfPlayer: 'gf',
				stage: 'stage',
				speed: 1,
				uiStyle: 'normal',
				validScore: false
			};
			storyWeek = 7;
		}

		leftIcon = new HealthIcon(_song.player1);
		rightIcon = new HealthIcon(_song.player2);
		leftIcon.scrollFactor.set(1, 1);
		rightIcon.scrollFactor.set(1, 1);

		leftIcon.setGraphicSize(0, 45);
		rightIcon.setGraphicSize(0, 45);

		add(leftIcon);
		OCSLoadedMap["leftIcon"] = leftIcon;
		add(rightIcon);
		OCSLoadedMap["rightIcon"] = rightIcon;

		leftIcon.setPosition(0, -100);
		rightIcon.setPosition(gridBG.width / 2, -100);

		var gridBlackLine:FlxSprite = new FlxSprite(gridBG.x + gridBG.width / 2).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
		add(gridBlackLine);
		OCSLoadedMap["gridBlackLine"] = gridBlackLine;

		curRenderedNotes = new FlxTypedGroup<Note>();
		OCSLoadedMap["curRenderedNotes"] = curRenderedNotes;
		curRenderedSustains = new FlxTypedGroup<FlxSprite>();
		OCSLoadedMap["curRenderedSustains"] = curRenderedSustains;

		// lol
		switch(_song.song.toLowerCase()) {
			case 'bopeebo' | 'fresh' | 'dadbattle':
			{
				commonStagesLabel = "stage";
			}
			case 'spookeez' | 'monster' | 'south':
			{
				commonStagesLabel = "spooky";
			}
			case 'pico' | 'blammed' | 'philly':
			{
				commonStagesLabel = "philly";
			}
			case 'milf' | 'mombattle' | 'satin-lovers' | 'satin-panties' | 'high':
			{
				commonStagesLabel = "limo";
			}
			case 'cocoa' | 'eggnog':
			{
				commonStagesLabel = "mall";
			}
			case 'winter-horrorland':
			{
				commonStagesLabel = "mallEvil";
			}
			case 'senpai':
			{
				commonStagesLabel = "school";
			}
			case 'thorns':
			{
				commonStagesLabel = "schoolEvil";
			}
			case 'roses':
			{
				commonStagesLabel = "schoolMad";
			}
			default:
			{
				commonStagesLabel = "stage";
			}
		}

		FlxG.mouse.visible = true;
		FlxG.save.bind('refunked', 'pahaze');

		tempBpm = _song.bpm;

		addSection();

		// sections = _song.notes;

		updateGrid();

		loadSong(_song.song);
		Conductor.changeBPM(_song.bpm);
		Conductor.mapBPMChanges(_song);

		bpmTxt = new FlxText(975, 50, 0, "", 16);
		bpmTxt.scrollFactor.set();
		add(bpmTxt);
		OCSLoadedMap["bpmTxt"] = bpmTxt;

		strumLine = new FlxSprite(0, 50).makeGraphic(Std.int(GRID_SIZE * 8), 4);
		add(strumLine);
		OCSLoadedMap["strumLine"] = strumLine;

		cameraPosition = new FlxObject(0, 0, 1, 1);
		cameraPosition.setPosition(strumLine.x + (GRID_SIZE * 8));

		dummyArrow = new FlxSprite().makeGraphic(GRID_SIZE, GRID_SIZE);
		add(dummyArrow);
		OCSLoadedMap["dummyArrow"] = dummyArrow;

		var tabs = [
			{name: "Song", label: 'Song'},
			{name: "Section", label: 'Section'},
			{name: "Note", label: 'Note'}
		];

		UI_box = new FlxUITabMenu(null, tabs, true);

		UI_box.resize(300, 400);
		UI_box.x = (FlxG.width / 2) + (GRID_SIZE / 2);
		UI_box.y = 20;
		add(UI_box);
		OCSLoadedMap["UI_box"] = UI_box;

		addSongUI();
		addSectionUI();
		addNoteUI();

		add(curRenderedNotes);
		add(curRenderedSustains);

		#if desktop
			DiscordClient.changePresence("Chart Editor", _song.songName, null, true);
		#end

		super.create();
	}

	function addSongUI():Void
	{
		var UI_songTitle = new FlxUIInputText(10, 25, 175, _song.song, 8);
		typingStuff = UI_songTitle;
		OCSLoadedMap["UI_songTitle"] = UI_songTitle;

		var UI_songTitleText = new FlxText(UI_songTitle.x, UI_songTitle.y - 15, 0, "Assets (Folder/Data) Name:");
		OCSLoadedMap["UI_songTitleText"] = UI_songTitleText;

		var UI_songNameTitle = new FlxUIInputText(10, 60, 175, (_song.songName != null ? _song.songName : _song.song), 8);
		moreTypingStuff = UI_songNameTitle;
		OCSLoadedMap["UI_songNameTitle"] = UI_songNameTitle;

		var UI_songNameTitleText = new FlxText(UI_songNameTitle.x, UI_songNameTitle.y - 15, 0, "Song Name (can use any characters):");
		OCSLoadedMap["UI_songNameTitleText"] = UI_songNameTitleText;

		var check_voices = new FlxUICheckBox(10, 80, null, null, "Song needs voices?", 100);
		OCSLoadedMap["check_voices"] = check_voices;
		check_voices.checked = _song.needsVoices;
		check_voices.callback = function()
		{
			_song.needsVoices = check_voices.checked;
			trace('CHECKED!');
		};

		var check_mute_inst = new FlxUICheckBox(10, 275, null, null, "Mute Instrumental (in editor)", 100);
		OCSLoadedMap["check_mute_inst"] = check_mute_inst;
		check_mute_inst.checked = false;
		check_mute_inst.callback = function()
		{
			var vol:Float = 1;

			if (check_mute_inst.checked)
				vol = 0;

			inst.volume = vol;
		};

		var saveButton:FlxButton = new FlxButton(200, 8, "Save", function()
		{
			saveLevel();
		});
		OCSLoadedMap["saveButton"] = saveButton;

		var reloadSong:FlxButton = new FlxButton(saveButton.x, saveButton.y + 30, "Reload Audio", function()
		{
			loadSong(_song.song);
		});
		OCSLoadedMap["reloadSong"] = reloadSong;

		var reloadSongJson:FlxButton = new FlxButton(reloadSong.x, reloadSong.y + 30, "Reload JSON", function()
		{
			loadJson(_song.song.toLowerCase());
		});
		OCSLoadedMap["reloadSongJson"] = reloadSongJson;
		
		var stepperBPM:FlxUINumericStepper = new FlxUINumericStepper(10, 115, 1, 1, 1, 999, 0);
		OCSLoadedMap["stepperBPM"] = stepperBPM;
		stepperBPM.value = Conductor.bpm;
		stepperBPM.name = 'song_bpm';

		var stepperBPMText = new FlxText(stepperBPM.x, stepperBPM.y - 15, 0, "BPM:");
		OCSLoadedMap["stepperBPMText"] = stepperBPMText;

		var stepperSpeed:FlxUINumericStepper = new FlxUINumericStepper(stepperBPM.x + stepperBPM.width + 10, 115, 0.1, 1, 0.1, 999, 1);
		OCSLoadedMap["stepperSpeed"] = stepperSpeed;
		stepperSpeed.value = _song.speed;
		stepperSpeed.name = 'song_speed';

		var stepperSpeedText = new FlxText(stepperSpeed.x, stepperSpeed.y - 15, 0, "Note Speed:");
		OCSLoadedMap["stepperSpeedText"] = stepperSpeedText;

		var characters:Array<String> = CoolUtil.coolTextFile(Paths.txt('characterList'));
		if(OptimizedPlayState.mod != null && OptimizedPlayState.mod != "") {
			if(Utilities.checkFileExists(Paths.mod(OptimizedPlayState.mod) + "data/characterList.txt")) {
				var modCharacters:Array<String> = CoolUtil.coolTextFile(Paths.mod(OptimizedPlayState.mod) + "data/characterList.txt");
				for(i in 0...modCharacters.length) {
					characters.insert(characters.length + i, modCharacters[i]);
				}
			}
		}
		var stages:Array<String> = CoolUtil.coolTextFile(Paths.txt('stageList'));
		if(OptimizedPlayState.mod != null && OptimizedPlayState.mod != "") {
			if(Utilities.checkFileExists(Paths.mod(OptimizedPlayState.mod) + "data/stageList.txt")) {
				var modStages:Array<String> = CoolUtil.coolTextFile(Paths.mod(OptimizedPlayState.mod) + "data/stageList.txt");
				for(i in 0...modStages.length) {
					stages.insert(stages.length + i, modStages[i]);
				}
			}
		}
		var uiStyles:Array<String> = ["normal", "pixel"];

		var player2DropDown = new FlxUIDropDownMenuCustom(140, 165, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String)
		{
			_song.player2 = characters[Std.parseInt(character)];
			updateHeads();
		});
		OCSLoadedMap["player2DropDown"] = player2DropDown;

		player2DropDown.selectedLabel = _song.player2;

		var player2Text = new FlxText(player2DropDown.x, player2DropDown.y - 15, 0, "Player 2:");
		OCSLoadedMap["player2Text"] = player2Text;
		scrollBlockThing.push(player2DropDown);

		var gfPlayerDropDown = new FlxUIDropDownMenuCustom(10, 200, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String)
		{
			_song.gfPlayer = characters[Std.parseInt(character)];
		});
		OCSLoadedMap["gfPlayerDropDown"] = gfPlayerDropDown;

		if(_song.gfPlayer != null) 
			gfPlayerDropDown.selectedLabel = _song.gfPlayer;
		else
			gfPlayerDropDown.selectedLabel = "gf";

		var gfPlayerText = new FlxText(gfPlayerDropDown.x, gfPlayerDropDown.y - 15, 0, "Girlfriend:");
		OCSLoadedMap["gfPlayerText"] = gfPlayerText;
		scrollBlockThing.push(gfPlayerDropDown);

		var player1DropDown = new FlxUIDropDownMenuCustom(10, 165, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String)
		{
			_song.player1 = characters[Std.parseInt(character)];
			updateHeads();
		});
		OCSLoadedMap["player1DropDown"] = player1DropDown;
		scrollBlockThing.push(player1DropDown);
		
		player1DropDown.selectedLabel = _song.player1;

		var player1Text = new FlxText(player1DropDown.x, player1DropDown.y - 15, 0, "Player 1:");
		OCSLoadedMap["player1Text"] = player1Text;

		var stageDropDown = new FlxUIDropDownMenuCustom(140, 200, FlxUIDropDownMenu.makeStrIdLabelArray(stages, true), function(stage:String)
		{
			_song.stage = stages[Std.parseInt(stage)];
			fixStoryWeek(stages[Std.parseInt(stage)]);
		});
		OCSLoadedMap["stageDropDown"] = stageDropDown;
		scrollBlockThing.push(stageDropDown);

		if(_song.stage != null) {
			stageDropDown.selectedLabel = _song.stage;
		} else {
			stageDropDown.selectedLabel = commonStagesLabel;
		}

		var stageText = new FlxText(stageDropDown.x, stageDropDown.y - 15, 0, "Stage:");
		OCSLoadedMap["stageText"] = stageText;

		var uiStyleDropDown = new FlxUIDropDownMenuCustom(10, 235, FlxUIDropDownMenu.makeStrIdLabelArray(uiStyles, true), function(uiStyle:String)
		{
			_song.uiStyle = uiStyles[Std.parseInt(uiStyle)];
		});
		OCSLoadedMap["uiStyleDropDown"] = uiStyleDropDown;
		scrollBlockThing.push(uiStyleDropDown);

		if(_song.uiStyle != null) {
			uiStyleDropDown.selectedLabel = _song.uiStyle;
		} else {
			uiStyleDropDown.selectedLabel = "normal";
		}

		var uiStyleText = new FlxText(uiStyleDropDown.x, uiStyleDropDown.y - 15, 0, "UI Style:");
		OCSLoadedMap["uiStyle"] = uiStyleText;

		var tab_group_song = new FlxUI(null, UI_box);
		OCSLoadedMap["tab_group_song"] = tab_group_song;
		tab_group_song.name = "Song";
		tab_group_song.add(UI_songTitle);
		tab_group_song.add(UI_songTitleText);
		tab_group_song.add(UI_songNameTitle);
		tab_group_song.add(UI_songNameTitleText);
		tab_group_song.add(check_voices);
		tab_group_song.add(check_mute_inst);
		tab_group_song.add(saveButton);
		tab_group_song.add(reloadSong);
		tab_group_song.add(reloadSongJson);
		tab_group_song.add(stepperBPM);
		tab_group_song.add(stepperBPMText);
		tab_group_song.add(stepperSpeed);
		tab_group_song.add(stepperSpeedText);
		tab_group_song.add(uiStyleDropDown);
		tab_group_song.add(uiStyleText);
		tab_group_song.add(gfPlayerDropDown);
		tab_group_song.add(gfPlayerText);
		tab_group_song.add(stageDropDown);
		tab_group_song.add(stageText);
		tab_group_song.add(player1DropDown);
		tab_group_song.add(player1Text);
		tab_group_song.add(player2DropDown);
		tab_group_song.add(player2Text);

		UI_box.addGroup(tab_group_song);
		UI_box.scrollFactor.set();

		FlxG.camera.follow(cameraPosition);
	}

	function fixStoryWeek(broStage:String) {
		// i hate haxe
		switch(broStage) {
			case "limo":
				storyWeek = 4;
			case "mallEvil":
				storyWeek = 5;
			case "mall":
				storyWeek = 5;
			case "philly":
				storyWeek = 3;
			case "school":
				storyWeek = 6;
			case "schoolEvil":
				storyWeek = 6;
			case "schoolMad":
				storyWeek = 6;
			case "spooky":
				storyWeek = 2;
			case "stage":
				storyWeek = 1;
			default:
				storyWeek = 7; 
		}
	}

	var stepperLength:FlxUINumericStepper;
	var check_mustHitSection:FlxUICheckBox;
	var check_changeBPM:FlxUICheckBox;
	var stepperSectionBPM:FlxUINumericStepper;
	var check_altAnim:FlxUICheckBox;

	function addSectionUI():Void
	{
		var tab_group_section = new FlxUI(null, UI_box);
		tab_group_section.name = 'Section';
		OCSLoadedMap["tab_group_section"] = tab_group_section;

		stepperLength = new FlxUINumericStepper(10, 10, 4, 0, 0, 999, 0);
		stepperLength.value = _song.notes[curSection].lengthInSteps;
		stepperLength.name = "section_length";
		OCSLoadedMap["stepperLength"] = stepperLength;

		stepperSectionBPM = new FlxUINumericStepper(10, 80, 1, Conductor.bpm, 0, 999, 0);
		stepperSectionBPM.value = Conductor.bpm;
		stepperSectionBPM.name = 'section_bpm';
		OCSLoadedMap["stepperSectionBPM"] = stepperSectionBPM;

		var stepperCopy:FlxUINumericStepper = new FlxUINumericStepper(110, 130, 1, 1, -999, 999, 0);
		OCSLoadedMap["stepperCopy"] = stepperCopy;

		var copyButton:FlxButton = new FlxButton(10, 130, "Copy last section", function()
		{
			copySection(Std.int(stepperCopy.value));
		});
		OCSLoadedMap["copyButton"] = copyButton;

		var clearSectionButton:FlxButton = new FlxButton(10, 150, "Clear", clearSection);
		OCSLoadedMap["clearSectionButton"] = clearSectionButton;

		var swapSection:FlxButton = new FlxButton(10, 170, "Swap section", function()
		{
			for (i in 0..._song.notes[curSection].sectionNotes.length)
			{
				var note = _song.notes[curSection].sectionNotes[i];
				note[1] = (note[1] + 4) % 8;
				_song.notes[curSection].sectionNotes[i] = note;
				updateGrid();
			}
		});
		OCSLoadedMap["swapSection"] = swapSection;

		check_mustHitSection = new FlxUICheckBox(10, 30, null, null, "Must hit section", 100);
		check_mustHitSection.name = 'check_mustHit';
		check_mustHitSection.checked = true;
		OCSLoadedMap["check_mustHitSection"] = check_mustHitSection;

		check_altAnim = new FlxUICheckBox(10, 400, null, null, "Alt Animation", 100);
		check_altAnim.name = 'check_altAnim';
		OCSLoadedMap["check_altAnim"] = check_altAnim;

		check_changeBPM = new FlxUICheckBox(10, 60, null, null, 'Change BPM', 100);
		check_changeBPM.name = 'check_changeBPM';
		OCSLoadedMap["check_changeBPM"] = check_changeBPM;

		tab_group_section.add(stepperLength);
		tab_group_section.add(stepperSectionBPM);
		tab_group_section.add(stepperCopy);
		tab_group_section.add(check_mustHitSection);
		tab_group_section.add(check_altAnim);
		tab_group_section.add(check_changeBPM);
		tab_group_section.add(copyButton);
		tab_group_section.add(clearSectionButton);
		tab_group_section.add(swapSection);

		UI_box.addGroup(tab_group_section);
	}

	var stepperSusLength:FlxUINumericStepper;

	function addNoteUI():Void
	{
		var notes:Array<String> = CoolUtil.coolTextFile("assets/notes/noteTypes.txt");
		if(OptimizedPlayState.mod != null && OptimizedPlayState.mod != "") {
			if(Utilities.checkFileExists(Paths.mod(OptimizedPlayState.mod) + "notes/noteTypes.txt")) {
				var modNotes:Array<String> = CoolUtil.coolTextFile(Paths.mod(OptimizedPlayState.mod) + "notes/noteTypes.txt");
				for(i in 0...modNotes.length) {
					notes.insert(notes.length + i, modNotes[i]);
				}
			}
		}

		var tab_group_note = new FlxUI(null, UI_box);
		tab_group_note.name = 'Note';
		OCSLoadedMap["tab_group_note"] = tab_group_note;

		stepperSusLength = new FlxUINumericStepper(10, 10, Conductor.stepCrochet / 2, 0, 0, Conductor.stepCrochet * 16);
		stepperSusLength.value = 0;
		stepperSusLength.name = 'note_susLength';
		OCSLoadedMap["stepperSusLength"] = stepperSusLength;

		var applyLength:FlxButton = new FlxButton(100, 10, 'Apply');
		OCSLoadedMap["applyLength"] = applyLength;

		var noteDropDown = new FlxUIDropDownMenuCustom(10, 45, FlxUIDropDownMenu.makeStrIdLabelArray(notes, true), function(note:String)
		{
			noteType = notes[Std.parseInt(note)];
		});
		OCSLoadedMap["noteDropDown"] = noteDropDown;
		scrollBlockThing.push(noteDropDown);

		var noteText = new FlxText(noteDropDown.x, noteDropDown.y - 15, 0, "Note Type:");
		OCSLoadedMap["noteText"] = noteText;

		tab_group_note.add(stepperSusLength);
		tab_group_note.add(applyLength);
		tab_group_note.add(noteDropDown);
		tab_group_note.add(noteText);
		UI_box.addGroup(tab_group_note);
	}

	function loadSong(daSong:String):Void
	{
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.stop();
		}

		if(OptimizedPlayState.mod != null && OptimizedPlayState.mod != "")
			inst = new FlxSound().loadStream(Paths.modInst(OptimizedPlayState.mod, daSong));
		else
			inst = new FlxSound().loadStream(Paths.inst(daSong));
		FlxG.sound.list.add(inst);
		OCSLoadedMap["inst"] = inst;

		if(OptimizedPlayState.mod != null && OptimizedPlayState.mod != "")
			vocals = new FlxSound().loadStream(Paths.modVoices(OptimizedPlayState.mod, daSong));
		else
			vocals = new FlxSound().loadStream(Paths.voices(daSong));
		FlxG.sound.list.add(vocals);
		OCSLoadedMap["vocals"] = vocals;

		FlxG.sound.music.pause();
		inst.pause();
		vocals.pause();

		inst.onComplete = function()
		{
			vocals.pause();
			vocals.time = 0;
			inst.pause();
			inst.time = 0;
			changeSection();
		};
	}

	function generateUI():Void
	{
		while (bullshitUI.members.length > 0)
		{
			bullshitUI.remove(bullshitUI.members[0], true);
		}

		var title:FlxText = new FlxText(UI_box.x + 20, UI_box.y + 20, 0);
		OCSLoadedMap["title"] = title;
		bullshitUI.add(title);
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		if (id == FlxUICheckBox.CLICK_EVENT)
		{
			var check:FlxUICheckBox = cast sender;
			var label = check.getLabel().text;
			switch (label)
			{
				case 'Must hit section':
					_song.notes[curSection].mustHitSection = check.checked;

					updateHeads();

				case 'Change BPM':
					_song.notes[curSection].changeBPM = check.checked;
					FlxG.log.add('changed bpm shit');
				case "Alt Animation":
					_song.notes[curSection].altAnim = check.checked;
			}
		}
		else if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper))
		{
			var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;
			FlxG.log.add(wname);
			if (wname == 'section_length')
			{
				_song.notes[curSection].lengthInSteps = Std.int(nums.value);
				updateGrid();
			}
			else if (wname == 'song_speed')
			{
				_song.speed = nums.value;
			}
			else if (wname == 'song_bpm')
			{
				tempBpm = Std.int(nums.value);
				Conductor.mapBPMChanges(_song);
				Conductor.changeBPM(Std.int(nums.value));
			}
			else if (wname == 'note_susLength')
			{
				curSelectedNote[2] = nums.value;
				updateGrid();
			}
			else if (wname == 'section_bpm')
			{
				_song.notes[curSection].bpm = Std.int(nums.value);
				updateGrid();
			}
		}

		// FlxG.log.add(id + " WEED " + sender + " WEED " + data + " WEED " + params);
	}

	var updatedSection:Bool = false;

	/* this function got owned LOL
		function lengthBpmBullshit():Float
		{
			if (_song.notes[curSection].changeBPM)
				return _song.notes[curSection].lengthInSteps * (_song.notes[curSection].bpm / _song.bpm);
			else
				return _song.notes[curSection].lengthInSteps;
	}*/
	function sectionStartTime():Float
	{
		var daBPM:Int = _song.bpm;
		var daPos:Float = 0;
		for (i in 0...curSection)
		{
			if (_song.notes[i].changeBPM)
			{
				daBPM = _song.notes[i].bpm;
			}
			daPos += 4 * (1000 * 60 / daBPM);
		}
		return daPos;
	}

	override function update(elapsed:Float)
	{
		curStep = recalculateSteps();

		Conductor.songPosition = inst.time;
		_song.song = typingStuff.text;
		_song.songName = moreTypingStuff.text;

		#if desktop
			DiscordClient.changePresence("Chart Editor", _song.songName, null);
		#end

		strumLine.y = getYfromStrum((Conductor.songPosition - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps));
		cameraPosition.y = strumLine.y;
		
		if (curBeat % 4 == 0 && curStep >= 16 * (curSection + 1))
		{
			trace(curStep);
			trace((_song.notes[curSection].lengthInSteps) * (curSection + 1));
			trace('DUMBSHIT');

			if (_song.notes[curSection + 1] == null)
			{
				addSection();
			}

			changeSection(curSection + 1, false);
		}

		FlxG.watch.addQuick('daBeat', curBeat);
		FlxG.watch.addQuick('daStep', curStep);

		if (FlxG.mouse.justPressed)
		{
			if (FlxG.mouse.overlaps(curRenderedNotes))
			{
				curRenderedNotes.forEach(function(note:Note)
				{
					if (FlxG.mouse.overlaps(note))
					{
						if (FlxG.keys.pressed.CONTROL)
						{
							selectNote(note);
						}
						else
						{
							trace('tryin to delete note...');
							deleteNote(note);
						}
					}
				});
			}
			else
			{
				if (FlxG.mouse.x > gridBG.x
					&& FlxG.mouse.x < gridBG.x + gridBG.width
					&& FlxG.mouse.y > gridBG.y
					&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps))
				{
					FlxG.log.add('added note');
					addNote();
				}
			}
		}

		if (FlxG.mouse.x > gridBG.x
			&& FlxG.mouse.x < gridBG.x + gridBG.width
			&& FlxG.mouse.y > gridBG.y
			&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps))
		{
			dummyArrow.x = Math.floor(FlxG.mouse.x / GRID_SIZE) * GRID_SIZE;
			if (FlxG.keys.pressed.SHIFT)
				dummyArrow.y = FlxG.mouse.y;
			else
				dummyArrow.y = Math.floor(FlxG.mouse.y / GRID_SIZE) * GRID_SIZE;
		}

		if (FlxG.keys.justPressed.ENTER)
		{
			lastSection = curSection;

			OptimizedPlayState.SONG = _song;
			inst.stop();
			vocals.stop();
			if(storyWeek > 1 && storyWeek < 7) {
				if(!LoadingState.isLibraryLoaded("week" + storyWeek))
					LoadingState.loadAndSwitchStateWithWeek(new OptimizedPlayState(), storyWeek);
				else
					FlxG.switchState(new OptimizedPlayState());
			} else {
				FlxG.switchState(new OptimizedPlayState());
			}
			new FlxTimer().start(transOut.duration, function(tmr:FlxTimer) {
				nullOCSLoadedAssets();
			});
		}

		if (FlxG.keys.justPressed.E)
		{
			changeNoteSustain(Conductor.stepCrochet);
		}
		if (FlxG.keys.justPressed.Q)
		{
			changeNoteSustain(-Conductor.stepCrochet);
		}

		if (FlxG.keys.justPressed.TAB)
		{
			if (FlxG.keys.pressed.SHIFT)
			{
				UI_box.selected_tab -= 1;
				if (UI_box.selected_tab < 0)
					UI_box.selected_tab = 2;
			}
			else
			{
				UI_box.selected_tab += 1;
				if (UI_box.selected_tab >= 3)
					UI_box.selected_tab = 0;
			}
		}

		if (!typingStuff.hasFocus && !moreTypingStuff.hasFocus)
		{
			if (FlxG.keys.justPressed.SPACE)
			{
				if (inst.playing)
				{
					inst.pause();
					vocals.pause();
				}
				else
				{
					vocals.play();
					inst.play();
				}
			}

			if (FlxG.keys.justPressed.R)
			{
				if (FlxG.keys.pressed.SHIFT)
					resetSection(true);
				else
					resetSection();
			}

			blockedScroll = false;
			for(menu in scrollBlockThing) {
				if(menu.dropPanel.visible) {
					blockedScroll = true;
					break;
				}
			}

			if (FlxG.mouse.wheel != 0 && !blockedScroll)
			{
				inst.pause();
				vocals.pause();

				inst.time -= (FlxG.mouse.wheel * Conductor.stepCrochet * 0.4);
				vocals.time = inst.time;
			}

			if (!FlxG.keys.pressed.SHIFT)
			{
				if (FlxG.keys.pressed.W || FlxG.keys.pressed.S)
				{
					inst.pause();
					vocals.pause();

					var daTime:Float = 700 * FlxG.elapsed;

					if (FlxG.keys.pressed.W)
					{
						inst.time -= daTime;
					}
					else
						inst.time += daTime;

					vocals.time = inst.time;
				}
			}
			else
			{
				if (FlxG.keys.justPressed.W || FlxG.keys.justPressed.S)
				{
					inst.pause();
					vocals.pause();

					var daTime:Float = Conductor.stepCrochet * 2;

					if (FlxG.keys.justPressed.W)
					{
						inst.time -= daTime;
					}
					else
						inst.time += daTime;

					vocals.time = inst.time;
				}
			}
		}

		_song.bpm = tempBpm;

		var shiftThing:Int = 1;
		if (FlxG.keys.pressed.SHIFT)
			shiftThing = 4;
		if (FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.D)
			changeSection(curSection + shiftThing);
		if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.A)
			changeSection(curSection - shiftThing);

		bpmTxt.text = bpmTxt.text = Std.string("Current Pos: "
			+ FlxMath.roundDecimal(Conductor.songPosition / 1000, 2))
			+ " / "
			+ Std.string(FlxMath.roundDecimal(inst.length / 1000, 2))
			+ "\nSection: "
			+ curSection
			+ "\ncurBeat: "
			+ curBeat
			+ "\ncurStep: "
			+ curStep;
		super.update(elapsed);
	}

	function changeNoteSustain(value:Float):Void
	{
		if (curSelectedNote != null)
		{
			if (curSelectedNote[2] != null)
			{
				curSelectedNote[2] += value;
				curSelectedNote[2] = Math.max(curSelectedNote[2], 0);
			}
		}

		updateNoteUI();
		updateGrid();
	}

	function recalculateSteps():Int
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (inst.time > Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((inst.time - lastChange.songTime) / Conductor.stepCrochet);
		updateBeat();

		return curStep;
	}

	function resetSection(songBeginning:Bool = false):Void
	{
		updateGrid();

		inst.pause();
		vocals.pause();

		// Basically old shit from changeSection???
		inst.time = sectionStartTime();

		if (songBeginning)
		{
			inst.time = 0;
			curSection = 0;
		}

		vocals.time = inst.time;
		updateCurStep();

		updateGrid();
		updateSectionUI();
	}

	function changeSection(sec:Int = 0, ?updateMusic:Bool = true):Void
	{
		trace('changing section' + sec);

		if (_song.notes[sec] != null)
		{
			curSection = sec;

			updateGrid();

			if (updateMusic)
			{
				inst.pause();
				vocals.pause();

				/*var daNum:Int = 0;
					var daLength:Float = 0;
					while (daNum <= sec)
					{
						daLength += lengthBpmBullshit();
						daNum++;
				}*/

				inst.time = sectionStartTime();
				vocals.time = inst.time;
				updateCurStep();
			}

			updateGrid();
			updateSectionUI();
		}
	}

	function copySection(?sectionNum:Int = 1)
	{
		var daSec = FlxMath.maxInt(curSection, sectionNum);

		for (note in _song.notes[daSec - sectionNum].sectionNotes)
		{
			var strum = note[0] + Conductor.stepCrochet * (_song.notes[daSec].lengthInSteps * sectionNum);

			var copiedNote:Array<Dynamic> = [strum, note[1], note[2]];
			_song.notes[daSec].sectionNotes.push(copiedNote);
		}

		updateGrid();
	}

	function updateSectionUI():Void
	{
		var sec = _song.notes[curSection];

		stepperLength.value = sec.lengthInSteps;
		check_mustHitSection.checked = sec.mustHitSection;
		check_altAnim.checked = sec.altAnim;
		check_changeBPM.checked = sec.changeBPM;
		stepperSectionBPM.value = sec.bpm;

		updateHeads();
	}

	function updateHeads():Void
	{
		if (check_mustHitSection.checked)
		{
			leftIcon.changeIcon(_song.player1);
			rightIcon.changeIcon(_song.player2);
		}
		else
		{
			leftIcon.changeIcon(_song.player2);
			rightIcon.changeIcon(_song.player1);
		}
	}

	function updateNoteUI():Void
	{
		if (curSelectedNote != null)
			stepperSusLength.value = curSelectedNote[2];
	}

	function updateGrid():Void
	{
		while (curRenderedNotes.members.length > 0)
		{
			curRenderedNotes.remove(curRenderedNotes.members[0], true);
		}

		while (curRenderedSustains.members.length > 0)
		{
			curRenderedSustains.remove(curRenderedSustains.members[0], true);
		}

		var sectionInfo:Array<Dynamic> = _song.notes[curSection].sectionNotes;

		if (_song.notes[curSection].changeBPM && _song.notes[curSection].bpm > 0)
		{
			Conductor.changeBPM(_song.notes[curSection].bpm);
			FlxG.log.add('CHANGED BPM!');
		}
		else
		{
			// get last bpm
			var daBPM:Int = _song.bpm;
			for (i in 0...curSection)
				if (_song.notes[i].changeBPM)
					daBPM = _song.notes[i].bpm;
			Conductor.changeBPM(daBPM);
		}

		/* // PORT BULLSHIT, INCASE THERE'S NO SUSTAIN DATA FOR A NOTE
			for (sec in 0..._song.notes.length)
			{
				for (notesse in 0..._song.notes[sec].sectionNotes.length)
				{
					if (_song.notes[sec].sectionNotes[notesse][2] == null)
					{
						trace('SUS NULL');
						_song.notes[sec].sectionNotes[notesse][2] = 0;
					}
				}
			}
		 */

		for (i in sectionInfo)
		{
			var daNoteInfo = i[1];
			var daStrumTime = i[0];
			var daSus = i[2];

			var note:Note = new Note(daStrumTime, daNoteInfo % 4);
			note.sustainLength = daSus;
			note.setGraphicSize(GRID_SIZE, GRID_SIZE);
			note.updateHitbox();
			note.x = Math.floor(daNoteInfo * GRID_SIZE);
			note.y = Math.floor(getYfromStrum((daStrumTime - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps)));
			OCSLoadedMap["note" + i] = note;

			curRenderedNotes.add(note);

			if (daSus > 0)
			{
				var sustainVis:FlxSprite = new FlxSprite(note.x + (GRID_SIZE / 2),
					note.y + GRID_SIZE).makeGraphic(8, Math.floor(FlxMath.remapToRange(daSus, 0, Conductor.stepCrochet * 16, 0, gridBG.height)));
				OCSLoadedMap["sustainVis" + i] = sustainVis;
				curRenderedSustains.add(sustainVis);
			}
		}
	}

	private function addSection(lengthInSteps:Int = 16):Void
	{
		var sec:SwagSection = {
			lengthInSteps: lengthInSteps,
			bpm: _song.bpm,
			changeBPM: false,
			mustHitSection: true,
			sectionNotes: [],
			typeOfSection: 0,
			altAnim: false
		};

		_song.notes.push(sec);
	}

	function selectNote(note:Note):Void
	{
		var swagNum:Int = 0;

		for (i in _song.notes[curSection].sectionNotes)
		{
			if (i.strumTime == note.strumTime && i.noteData % 4 == note.noteData)
			{
				curSelectedNote = _song.notes[curSection].sectionNotes[swagNum];
			}

			swagNum += 1;
		}

		updateGrid();
		updateNoteUI();
	}

	function deleteNote(note:Note):Void
	{
		for (i in _song.notes[curSection].sectionNotes)
		{
			if (i[0] == note.strumTime && i[1] % 4 == note.noteData)
			{
				FlxG.log.add('FOUND EVIL NUMBER');
				_song.notes[curSection].sectionNotes.remove(i);
			}
		}

		updateGrid();
	}

	function clearSection():Void
	{
		_song.notes[curSection].sectionNotes = [];

		updateGrid();
	}

	function clearSong():Void
	{
		for (daSection in 0..._song.notes.length)
		{
			_song.notes[daSection].sectionNotes = [];
		}

		updateGrid();
	}

	private function addNote():Void
	{
		var noteStrum = getStrumTime(dummyArrow.y) + sectionStartTime();
		var noteData = Math.floor(FlxG.mouse.x / GRID_SIZE);
		var noteSus = 0;

		_song.notes[curSection].sectionNotes.push([noteStrum, noteData, noteSus, noteType]);

		curSelectedNote = _song.notes[curSection].sectionNotes[_song.notes[curSection].sectionNotes.length - 1];

		if (FlxG.keys.pressed.CONTROL)
		{
			_song.notes[curSection].sectionNotes.push([noteStrum, (noteData + 4) % 8, noteSus, noteType]);
		}

		trace(noteStrum);
		trace(curSection);

		updateGrid();
		updateNoteUI();
	}

	function getStrumTime(yPos:Float):Float
	{
		return FlxMath.remapToRange(yPos, gridBG.y, gridBG.y + gridBG.height, 0, 16 * Conductor.stepCrochet);
	}

	function getYfromStrum(strumTime:Float):Float
	{
		return FlxMath.remapToRange(strumTime, 0, 16 * Conductor.stepCrochet, gridBG.y, gridBG.y + gridBG.height);
	}

	/*
		function calculateSectionLengths(?sec:SwagSection):Int
		{
			var daLength:Int = 0;

			for (i in _song.notes)
			{
				var swagLength = i.lengthInSteps;

				if (i.typeOfSection == Section.COPYCAT)
					swagLength * 2;

				daLength += swagLength;

				if (sec != null && sec == i)
				{
					trace('swag loop??');
					break;
				}
			}

			return daLength;
	}*/
	private var daSpacing:Float = 0.3;

	function loadLevel():Void
	{
		trace(_song.notes);
	}

	function getNotes():Array<Dynamic>
	{
		var noteData:Array<Dynamic> = [];

		for (i in _song.notes)
		{
			noteData.push(i.sectionNotes);
		}

		return noteData;
	}

	function loadJson(song:String):Void
	{
		OptimizedPlayState.SONG = Song.loadFromJson(song.toLowerCase(), song.toLowerCase());
		FlxG.resetState();
	}

	private function saveLevel()
	{
		var json = {
			"song": _song
		};

		var data:String = Json.stringify(json);

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), _song.song.toLowerCase() + ".json");
		}
	}

	function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved LEVEL DATA.");
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving Level data");
	}

	public static function nullOCSLoadedAssets():Void
	{
		if(OCSLoadedMap != null) {
			for(sprite in OCSLoadedMap) {
				sprite.destroy();
			}
		}
		OCSLoadedMap = null;
	}
}