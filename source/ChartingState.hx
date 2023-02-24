package;

import Conductor.BPMChangeEvent;
import customFlixel.FlxUIDropDownMenuCustom;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import haxe.Json;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.FileReference;
import Section.SwagSection;
import Song.SwagSong;

using StringTools;

class ChartingState extends MusicBeatState {
	var cameraPosition:FlxObject;

	var _file:FileReference;
	var UI_box:FlxUITabMenu;

	/**
	 * Array of notes showing when each section STARTS in STEPS
	 * Usually rounded up??
	 */
	var curSection:Int = 0;


	public static var lastSection:Int = 0;

	var bpmTxt:FlxText;

	var strumLine:FlxSprite;
	var curSong:String = 'Test';
	var commonStagesLabel:String = "";
	var storyWeek:Int = 1;
	var amountSteps:Int = 0;
	var dumbUI:FlxGroup;

	var highlight:FlxSprite;

	var GRID_SIZE:Int = 40;

	var dummyArrow:FlxSprite;

	var curRenderedNotes:FlxTypedGroup<Note>;
	var curRenderedSustains:FlxTypedGroup<FlxSprite>;

	var gridBG:FlxSprite;

	var _song:SwagSong;

	var typingStuff:FlxInputText;
	var moreTypingStuff:FlxInputText;

	/*
	 * WILL BE THE CURRENT / LAST PLACED NOTE
	**/
	var curSelectedNote:Array<Dynamic>;

	var tempBpm:Float = 0;

	var vocals:FlxSound;

	var leftIcon:HealthIcon;
	var rightIcon:HealthIcon;

	var scrollBlockThing:Array<FlxUIDropDownMenuCustom> = [];
	var blockedScroll:Bool = false;

	override function create() {
		curSection = lastSection;

		gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 8, GRID_SIZE * 16);
		add(gridBG);

		leftIcon = new HealthIcon('bf');
		rightIcon = new HealthIcon('dad');
		leftIcon.scrollFactor.set(1, 1);
		rightIcon.scrollFactor.set(1, 1);

		leftIcon.setGraphicSize(0, 45);
		rightIcon.setGraphicSize(0, 45);

		add(leftIcon);
		add(rightIcon);

		leftIcon.setPosition(0, -100);
		rightIcon.setPosition(gridBG.width / 2, -100);

		var gridBlackLine:FlxSprite = new FlxSprite(gridBG.x + gridBG.width / 2).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
		add(gridBlackLine);

		curRenderedNotes = new FlxTypedGroup<Note>();
		curRenderedSustains = new FlxTypedGroup<FlxSprite>();

		if (PlayState.SONG != null)
			_song = PlayState.SONG; else {
			_song = {
				song: 'Test',
				songName: 'Test',
				notes: [],
				bpm: 150,
				needsVoices: true,
				player1: 'bf',
				player2: 'dad',
				gfPlayer: 'gf',
				speed: 1,
				stage: 'stage',
				uiStyle: 'normal',
				validScore: false
			};
		}

		switch(_song.song.toLowerCase()) {
			case 'bopeebo' | 'fresh' | 'dadbattle':
				commonStagesLabel = "stage";

			case 'spookeez' | 'monster' | 'south':
				commonStagesLabel = "spooky";

			case 'pico' | 'blammed' | 'philly':
				commonStagesLabel = "philly";

			case 'milf' | 'mombattle' | 'satin-lovers' | 'satin-panties' | 'high':
				commonStagesLabel = "limo";

			case 'cocoa' | 'eggnog':
				commonStagesLabel = "mall";

			case 'winter-horrorland':
				commonStagesLabel = "mallEvil";

			case 'senpai':
				commonStagesLabel = "school";

			case 'thorns':
				commonStagesLabel = "schoolEvil";

			case 'roses':
				commonStagesLabel = "schoolMad";

			default:
				commonStagesLabel = "stage";
		}

		FlxG.mouse.visible = true;
		#if (flixel < "5.0.0")
			FlxG.save.bind('refunked', 'pahaze');
		#else
			FlxG.save.bind('refunked');
		#end

		tempBpm = _song.bpm;

		addSection();

		updateGrid();

		loadSong(_song.song);
		Conductor.changeBPM(_song.bpm);
		Conductor.mapBPMChanges(_song);

		bpmTxt = new FlxText(975, 50, 0, "", 16);
		bpmTxt.scrollFactor.set();
		add(bpmTxt);

		strumLine = new FlxSprite(0, 50).makeGraphic(Std.int(GRID_SIZE * 8), 4);
		add(strumLine);

		cameraPosition = new FlxObject(0, 0, 1, 1);
		cameraPosition.setPosition(strumLine.x + (GRID_SIZE * 8));

		dummyArrow = new FlxSprite().makeGraphic(GRID_SIZE, GRID_SIZE);
		add(dummyArrow);

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

		addSongUI();
		addSectionUI();
		addNoteUI();

		add(curRenderedNotes);
		add(curRenderedSustains);

		super.create();
	}

	function addSongUI():Void {
		var UI_songTitle = new FlxUIInputText(10, 25, 175, _song.song, 8);
		typingStuff = UI_songTitle;

		var UI_songTitleText = new FlxText(UI_songTitle.x, UI_songTitle.y - 15, 0, "Assets (Folder/Data) Name:");

		var UI_songNameTitle = new FlxUIInputText(10, 60, 175, (_song.songName != null ? _song.songName : _song.song), 8);
		moreTypingStuff = UI_songNameTitle;

		var UI_songNameTitleText = new FlxText(UI_songNameTitle.x, UI_songNameTitle.y - 15, 0, "Song Name (can use any characters):");

		var check_voices = new FlxUICheckBox(10, 80, null, null, "Song needs voices?", 100);
		check_voices.checked = _song.needsVoices;
		check_voices.callback = function() {
			_song.needsVoices = check_voices.checked;
			trace('CHECKED!');
		};

		var check_mute_inst = new FlxUICheckBox(10, 275, null, null, "Mute Instrumental (in editor)", 100);
		check_mute_inst.checked = false;
		check_mute_inst.callback = function() {
			var vol:Float = 1;

			if (check_mute_inst.checked)
				vol = 0;

			FlxG.sound.music.volume = vol;
		};

		var saveButton:FlxButton = new FlxButton(200, 8, "Save", function() {
			saveLevel();
		});

		var reloadSong:FlxButton = new FlxButton(saveButton.x, saveButton.y + 30, "Reload Audio", function() {
			loadSong(_song.song);
		});

		var reloadSongJson:FlxButton = new FlxButton(reloadSong.x, reloadSong.y + 30, "Reload JSON", function() {
			loadJson(_song.song.toLowerCase());
		});

		var stepperBPM:FlxUINumericStepper = new FlxUINumericStepper(10, 115, 1, 1, 1, 999, 3);
		stepperBPM.value = Conductor.bpm;
		stepperBPM.name = 'song_bpm';

		var stepperBPMText = new FlxText(stepperBPM.x, stepperBPM.y - 15, 0, "BPM:");

		var stepperSpeed:FlxUINumericStepper = new FlxUINumericStepper(stepperBPM.x + stepperBPM.width + 10, 115, 0.1, 1, 0.1, 999, 2);
		stepperSpeed.value = _song.speed;
		stepperSpeed.name = 'song_speed';

		var stepperSpeedText = new FlxText(stepperSpeed.x, stepperSpeed.y - 15, 0, "Note Speed:");

		var characters:Array<String> = CoolUtil.coolTextFile(Paths.file('chars/characterList.txt'));
		var stages:Array<String> = CoolUtil.coolTextFile(Paths.file('stages/stageList.txt'));
		var uiStyles:Array<String> = ["normal", "pixel"];

		var player2DropDown = new FlxUIDropDownMenuCustom(140, 165, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String) {
			_song.player2 = characters[Std.parseInt(character)];
			updateHeads();
		});

		player2DropDown.selectedLabel = _song.player2;

		var player2Text = new FlxText(player2DropDown.x, player2DropDown.y - 15, 0, "Player 2:");
		scrollBlockThing.push(player2DropDown);

		var gfPlayerDropDown = new FlxUIDropDownMenuCustom(10, 200, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String) {
			_song.gfPlayer = characters[Std.parseInt(character)];
		});

		if(_song.gfPlayer != null)
			gfPlayerDropDown.selectedLabel = _song.gfPlayer; else
			gfPlayerDropDown.selectedLabel = "gf";

		var gfPlayerText = new FlxText(gfPlayerDropDown.x, gfPlayerDropDown.y - 15, 0, "Girlfriend:");
		scrollBlockThing.push(gfPlayerDropDown);

		var player1DropDown = new FlxUIDropDownMenuCustom(10, 165, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String) {
			_song.player1 = characters[Std.parseInt(character)];
			updateHeads();
		});
		scrollBlockThing.push(player1DropDown);

		player1DropDown.selectedLabel = _song.player1;

		var player1Text = new FlxText(player1DropDown.x, player1DropDown.y - 15, 0, "Player 1:");

		var stageDropDown = new FlxUIDropDownMenuCustom(140, 200, FlxUIDropDownMenu.makeStrIdLabelArray(stages, true), function(stage:String) {
			_song.stage = stages[Std.parseInt(stage)];
			fixStoryWeek(stages[Std.parseInt(stage)]);
		});
		scrollBlockThing.push(stageDropDown);

		if(_song.stage != null) {
			stageDropDown.selectedLabel = _song.stage;
		} else {
			stageDropDown.selectedLabel = commonStagesLabel;
		}

		var stageText = new FlxText(stageDropDown.x, stageDropDown.y - 15, 0, "Stage:");

		var uiStyleDropDown = new FlxUIDropDownMenuCustom(10, 235, FlxUIDropDownMenu.makeStrIdLabelArray(uiStyles, true), function(uiStyle:String) {
			_song.uiStyle = uiStyles[Std.parseInt(uiStyle)];
		});
		scrollBlockThing.push(uiStyleDropDown);

		if(_song.uiStyle != null) {
			uiStyleDropDown.selectedLabel = _song.uiStyle;
		} else {
			uiStyleDropDown.selectedLabel = "normal";
		}

		var uiStyleText = new FlxText(uiStyleDropDown.x, uiStyleDropDown.y - 15, 0, "UI Style:");

		var tab_group_song = new FlxUI(null, UI_box);
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

	function fixStoryWeek(curStage:String) {
		switch(curStage) {
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

	function addSectionUI():Void {
		var tab_group_section = new FlxUI(null, UI_box);
		tab_group_section.name = 'Section';

		stepperLength = new FlxUINumericStepper(10, 10, 4, 0, 0, 999, 0);
		stepperLength.value = _song.notes[curSection].lengthInSteps;
		stepperLength.name = "section_length";

		stepperSectionBPM = new FlxUINumericStepper(10, 80, 1, Conductor.bpm, 0, 999, 0);
		stepperSectionBPM.value = Conductor.bpm;
		stepperSectionBPM.name = 'section_bpm';

		var stepperCopy:FlxUINumericStepper = new FlxUINumericStepper(110, 130, 1, 1, -999, 999, 0);

		var copyButton:FlxButton = new FlxButton(10, 130, "Copy last section", function() {
			copySection(Std.int(stepperCopy.value));
		});

		var clearSectionButton:FlxButton = new FlxButton(10, 150, "Clear", clearSection);

		var swapSection:FlxButton = new FlxButton(10, 170, "Swap section", function() {
			for (i in 0..._song.notes[curSection].sectionNotes.length) {
				var note = _song.notes[curSection].sectionNotes[i];
				note[1] = (note[1] + 4) % 8;
				_song.notes[curSection].sectionNotes[i] = note;
				updateGrid();
			}
		});

		check_mustHitSection = new FlxUICheckBox(10, 30, null, null, "Must hit section", 100);
		check_mustHitSection.name = 'check_mustHit';
		check_mustHitSection.checked = true;

		check_altAnim = new FlxUICheckBox(10, 400, null, null, "Alt Animation", 100);
		check_altAnim.name = 'check_altAnim';

		check_changeBPM = new FlxUICheckBox(10, 60, null, null, 'Change BPM', 100);
		check_changeBPM.name = 'check_changeBPM';

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

	function addNoteUI():Void {
		var tab_group_note = new FlxUI(null, UI_box);
		tab_group_note.name = 'Note';

		stepperSusLength = new FlxUINumericStepper(10, 10, Conductor.stepCrochet / 2, 0, 0, Conductor.stepCrochet * 16);
		stepperSusLength.value = 0;
		stepperSusLength.name = 'note_susLength';

		var applyLength:FlxButton = new FlxButton(100, 10, 'Apply');

		tab_group_note.add(stepperSusLength);
		tab_group_note.add(applyLength);

		UI_box.addGroup(tab_group_note);
	}

	function loadSong(daSong:String):Void {
		if (FlxG.sound.music != null) {
			FlxG.sound.music.stop();
		}

		FlxG.sound.playMusic(Paths.inst(daSong), 0.6);

		if(_song.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(daSong));
		else
			vocals = new FlxSound();
		FlxG.sound.list.add(vocals);

		FlxG.sound.music.pause();
		vocals.pause();

		FlxG.sound.music.onComplete = function() {
			vocals.pause();
			vocals.time = 0;
			FlxG.sound.music.pause();
			FlxG.sound.music.time = 0;
			changeSection();
		};
	}

	function generateUI():Void {
		while (dumbUI.members.length > 0) {
			dumbUI.remove(dumbUI.members[0], true);
		}

		var title:FlxText = new FlxText(UI_box.x + 20, UI_box.y + 20, 0);
		dumbUI.add(title);
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>) {
		if (id == FlxUICheckBox.CLICK_EVENT) {
			var check:FlxUICheckBox = cast sender;
			var label = check.getLabel().text;
			switch (label) {
				case 'Must hit section':
					_song.notes[curSection].mustHitSection = check.checked;
					updateHeads();

				case 'Change BPM':
					_song.notes[curSection].changeBPM = check.checked;
					FlxG.log.add('Changed BPM!');

				case "Alt Animation":
					_song.notes[curSection].altAnim = check.checked;
			}
		} else if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper)) {
			var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;
			FlxG.log.add(wname);
			if (wname == 'section_length') {
				_song.notes[curSection].lengthInSteps = Std.int(nums.value);
				updateGrid();
			} else if (wname == 'song_speed') {
				_song.speed = nums.value;
			} else if (wname == 'song_bpm') {
				tempBpm = nums.value;
				Conductor.mapBPMChanges(_song);
				Conductor.changeBPM(nums.value);
			} else if (wname == 'note_susLength') {
				curSelectedNote[2] = nums.value;
				updateGrid();
			} else if (wname == 'section_bpm') {
				_song.notes[curSection].bpm = nums.value;
				updateGrid();
			}
		}
	}

	var updatedSection:Bool = false;

	function sectionStartTime():Float {
		var daBPM:Float = _song.bpm;
		var daPos:Float = 0;
		for (i in 0...curSection) {
			if (_song.notes[i].changeBPM) {
				daBPM = _song.notes[i].bpm;
			}
			daPos += 4 * (1000 * 60 / daBPM);
		}
		return daPos;
	}

	override function update(elapsed:Float) {
		curStep = recalculateSteps();

		Conductor.songPosition = FlxG.sound.music.time;
		_song.song = typingStuff.text;
		_song.songName = moreTypingStuff.text;

		strumLine.y = getYfromStrum((Conductor.songPosition - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps));
		cameraPosition.y = strumLine.y;

		if (curBeat % 4 == 0 && curStep >= 16 * (curSection + 1)) {
			trace(curStep);
			trace((_song.notes[curSection].lengthInSteps) * (curSection + 1));

			if (_song.notes[curSection + 1] == null) {
				addSection();
			}

			changeSection(curSection + 1, false);
		}

		FlxG.watch.addQuick('daBeat', curBeat);
		FlxG.watch.addQuick('daStep', curStep);

		if (FlxG.mouse.justPressed) {
			if (FlxG.mouse.overlaps(curRenderedNotes)) {
				curRenderedNotes.forEach(function(note:Note) {
					if (FlxG.mouse.overlaps(note)) {
						if (FlxG.keys.pressed.CONTROL) {
							selectNote(note);
						} else {
							trace('tryin to delete note...');
							deleteNote(note);
						}
					}
				});
			} else {
				if (FlxG.mouse.x > gridBG.x
					&& FlxG.mouse.x < gridBG.x + gridBG.width
					&& FlxG.mouse.y > gridBG.y
					&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps)) {
					FlxG.log.add('added note');
					addNote();
				}
			}
		}

		if (FlxG.mouse.x > gridBG.x
			&& FlxG.mouse.x < gridBG.x + gridBG.width
			&& FlxG.mouse.y > gridBG.y
			&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps)) {
			dummyArrow.x = Math.floor(FlxG.mouse.x / GRID_SIZE) * GRID_SIZE;
			if (FlxG.keys.pressed.SHIFT)
				dummyArrow.y = FlxG.mouse.y; else
				dummyArrow.y = Math.floor(FlxG.mouse.y / GRID_SIZE) * GRID_SIZE;
		}

		if (FlxG.keys.justPressed.ENTER) {
			lastSection = curSection;

			PlayState.SONG = _song;
			PlayState.storyWeek = storyWeek;
			FlxG.sound.music.stop();
			vocals.stop();
			LoadingState.loadAndSwitchState(new PlayState());
		}

		if (FlxG.keys.justPressed.E) {
			changeNoteSustain(Conductor.stepCrochet);
		}
		if (FlxG.keys.justPressed.Q) {
			changeNoteSustain(-Conductor.stepCrochet);
		}

		if (FlxG.keys.justPressed.TAB) {
			if (FlxG.keys.pressed.SHIFT) {
				UI_box.selected_tab -= 1;
				if (UI_box.selected_tab < 0)
					UI_box.selected_tab = 2;
			} else {
				UI_box.selected_tab += 1;
				if (UI_box.selected_tab >= 3)
					UI_box.selected_tab = 0;
			}
		}

		if (!typingStuff.hasFocus && !moreTypingStuff.hasFocus) {
			if (FlxG.keys.justPressed.SPACE) {
				if (FlxG.sound.music.playing) {
					FlxG.sound.music.pause();
					vocals.pause();
				} else {
					vocals.play();
					FlxG.sound.music.play();
				}
			}

			if (FlxG.keys.justPressed.R) {
				if (FlxG.keys.pressed.SHIFT)
					resetSection(true); else
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
				FlxG.sound.music.pause();
				vocals.pause();

				FlxG.sound.music.time -= (FlxG.mouse.wheel * Conductor.stepCrochet * 0.4);
				vocals.time = FlxG.sound.music.time;
			}

			if (!FlxG.keys.pressed.SHIFT) {
				if (FlxG.keys.pressed.W || FlxG.keys.pressed.S) {
					FlxG.sound.music.pause();
					vocals.pause();

					var daTime:Float = 700 * FlxG.elapsed;

					if (FlxG.keys.pressed.W) {
						FlxG.sound.music.time -= daTime;
					} else
						FlxG.sound.music.time += daTime;

					vocals.time = FlxG.sound.music.time;
				}
			} else {
				if (FlxG.keys.justPressed.W || FlxG.keys.justPressed.S) {
					FlxG.sound.music.pause();
					vocals.pause();

					var daTime:Float = Conductor.stepCrochet * 2;

					if (FlxG.keys.justPressed.W)
						FlxG.sound.music.time -= daTime;
					else
						FlxG.sound.music.time += daTime;

					vocals.time = FlxG.sound.music.time;
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

		bpmTxt.text = Std.string("Current Pos: "
			+ FlxMath.roundDecimal(Conductor.songPosition / 1000, 2))
			+ " / "
			+ Std.string(FlxMath.roundDecimal(FlxG.sound.music.length / 1000, 2))
			+ "\nSection: "
			+ curSection
			+ "\ncurBeat: "
			+ curBeat
			+ "\ncurStep: "
			+ curStep;

		super.update(elapsed);
	}

	function changeNoteSustain(value:Float):Void {
		if (curSelectedNote != null) {
			if (curSelectedNote[2] != null) {
				curSelectedNote[2] += value;
				curSelectedNote[2] = Math.max(curSelectedNote[2], 0);
			}
		}

		updateNoteUI();
		updateGrid();
	}

	function recalculateSteps():Int {
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length) {
			if (FlxG.sound.music.time > Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((FlxG.sound.music.time - lastChange.songTime) / Conductor.stepCrochet);
		updateBeat();

		return curStep;
	}

	function resetSection(songBeginning:Bool = false):Void {
		updateGrid();

		FlxG.sound.music.pause();
		vocals.pause();

		FlxG.sound.music.time = sectionStartTime();

		if (songBeginning) {
			FlxG.sound.music.time = 0;
			curSection = 0;
		}

		vocals.time = FlxG.sound.music.time;
		updateCurStep();

		updateGrid();
		updateSectionUI();
	}

	function changeSection(sec:Int = 0, ?updateMusic:Bool = true):Void {
		trace('changing section' + sec);

		if (_song.notes[sec] != null) {
			curSection = sec;

			updateGrid();

			if (updateMusic) {
				FlxG.sound.music.pause();
				vocals.pause();

				FlxG.sound.music.time = sectionStartTime();
				vocals.time = FlxG.sound.music.time;
				updateCurStep();
			}

			updateGrid();
			updateSectionUI();
		}
	}

	function copySection(?sectionNum:Int = 1) {
		var daSec = FlxMath.maxInt(curSection, sectionNum);

		for (note in _song.notes[daSec - sectionNum].sectionNotes) {
			var strum = note[0] + Conductor.stepCrochet * (_song.notes[daSec].lengthInSteps * sectionNum);

			var copiedNote:Array<Dynamic> = [strum, note[1], note[2]];
			_song.notes[daSec].sectionNotes.push(copiedNote);
		}

		updateGrid();
	}

	function updateSectionUI():Void {
		var sec = _song.notes[curSection];

		stepperLength.value = sec.lengthInSteps;
		check_mustHitSection.checked = sec.mustHitSection;
		check_altAnim.checked = sec.altAnim;
		check_changeBPM.checked = sec.changeBPM;
		stepperSectionBPM.value = sec.bpm;

		updateHeads();
	}

	function updateHeads():Void {
		if (check_mustHitSection.checked) {
			leftIcon.changeIcon(_song.player1);
			rightIcon.changeIcon(_song.player2);
		} else {
			leftIcon.changeIcon(_song.player2);
			rightIcon.changeIcon(_song.player1);
		}
	}

	function updateNoteUI():Void {
		if (curSelectedNote != null)
			stepperSusLength.value = curSelectedNote[2];
	}

	function updateGrid():Void {
		while (curRenderedNotes.members.length > 0) {
			curRenderedNotes.remove(curRenderedNotes.members[0], true);
		}

		while (curRenderedSustains.members.length > 0) {
			curRenderedSustains.remove(curRenderedSustains.members[0], true);
		}

		var sectionInfo:Array<Dynamic> = _song.notes[curSection].sectionNotes;

		if (_song.notes[curSection].changeBPM && _song.notes[curSection].bpm > 0) {
			Conductor.changeBPM(_song.notes[curSection].bpm);
			FlxG.log.add('CHANGED BPM!');
		} else {
			var daBPM:Float = _song.bpm;
			for (i in 0...curSection)
				if (_song.notes[i].changeBPM)
					daBPM = _song.notes[i].bpm;
			Conductor.changeBPM(daBPM);
		}

		for (i in sectionInfo) {
			var daNoteInfo = i[1];
			var daStrumTime = i[0];
			var daSus = i[2];

			var note:Note = new Note(daStrumTime, daNoteInfo % 4);
			note.sustainLength = daSus;
			note.setGraphicSize(GRID_SIZE, GRID_SIZE);
			note.updateHitbox();
			note.x = Math.floor(daNoteInfo * GRID_SIZE);
			note.y = Math.floor(getYfromStrum((daStrumTime - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps)));

			curRenderedNotes.add(note);

			if (daSus > 0) {
				var sustainVis:FlxSprite = new FlxSprite(note.x + (GRID_SIZE / 2),
					note.y + GRID_SIZE).makeGraphic(8, Math.floor(FlxMath.remapToRange(daSus, 0, Conductor.stepCrochet * 16, 0, gridBG.height)));
				curRenderedSustains.add(sustainVis);
			}
		}
	}

	private function addSection(lengthInSteps:Int = 16):Void {
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

	function selectNote(note:Note):Void {
		var swagNum:Int = 0;

		for (i in _song.notes[curSection].sectionNotes) {
			if (i.strumTime == note.strumTime && i.noteData % 4 == note.noteData) {
				curSelectedNote = _song.notes[curSection].sectionNotes[swagNum];
			}

			swagNum += 1;
		}

		updateGrid();
		updateNoteUI();
	}

	function deleteNote(note:Note):Void {
		for (i in _song.notes[curSection].sectionNotes) {
			if (i[0] == note.strumTime && i[1] % 4 == note.noteData) {
				_song.notes[curSection].sectionNotes.remove(i);
			}
		}

		updateGrid();
	}

	function clearSection():Void {
		_song.notes[curSection].sectionNotes = [];

		updateGrid();
	}

	function clearSong():Void {
		for (daSection in 0..._song.notes.length) {
			_song.notes[daSection].sectionNotes = [];
		}

		updateGrid();
	}

	private function addNote():Void {
		var noteStrum = getStrumTime(dummyArrow.y) + sectionStartTime();
		var noteData = Math.floor(FlxG.mouse.x / GRID_SIZE);
		var noteSus = 0;

		_song.notes[curSection].sectionNotes.push([noteStrum, noteData, noteSus]);

		curSelectedNote = _song.notes[curSection].sectionNotes[_song.notes[curSection].sectionNotes.length - 1];

		if (FlxG.keys.pressed.CONTROL) {
			_song.notes[curSection].sectionNotes.push([noteStrum, (noteData + 4) % 8, noteSus]);
		}

		trace(noteStrum);
		trace(curSection);

		updateGrid();
		updateNoteUI();
	}

	function getStrumTime(yPos:Float):Float {
		return FlxMath.remapToRange(yPos, gridBG.y, gridBG.y + gridBG.height, 0, 16 * Conductor.stepCrochet);
	}

	function getYfromStrum(strumTime:Float):Float {
		return FlxMath.remapToRange(strumTime, 0, 16 * Conductor.stepCrochet, gridBG.y, gridBG.y + gridBG.height);
	}

	private var daSpacing:Float = 0.3;

	function loadLevel():Void {
		trace(_song.notes);
	}

	function getNotes():Array<Dynamic> {
		var noteData:Array<Dynamic> = [];

		for (i in _song.notes) {
			noteData.push(i.sectionNotes);
		}

		return noteData;
	}

	function loadJson(song:String):Void {
		PlayState.SONG = Song.loadFromJson(song.toLowerCase(), song.toLowerCase());
		FlxG.resetState();
	}

	private function saveLevel() {
		var json = {
			"song": _song
		};

		var data:String = Json.stringify(json);

		if ((data != null) && (data.length > 0)) {
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), _song.song.toLowerCase() + ".json");
		}
	}

	function onSaveComplete(_):Void {
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved LEVEL DATA.");
	}

	function onSaveCancel(_):Void {
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	function onSaveError(_):Void {
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving Level data");
	}
}
