package;

import flixel.FlxSprite;
import haxe.Json;
import modSupport.CharacterJSONS.CharacterJSON;

using StringTools;

class Character extends FlxSprite {
	// Character Data --
	var rawJson:String = "";
	var characterPath:String = "";
	var characterJSON:CharacterJSON;
	// -- Character Data
	
	// Character Information --
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var cameraOffsets:Array<Int> = [];
	public var curCharacter:String = 'bf';
	var dancedLeft:Bool = false;
	public var holdTimer:Float = 0;
	public var IdleDancing:Bool = false;
	public var isPlayer:Bool = false;
	public var isSpecialAnim:Bool = false;
	public var positionOffsets:Array<Float> = [];
	public var speed:Int = 1;
	public var stunned:Bool = false;
	// -- Character Information

	// Debug Mode
	public var debugMode:Bool = false;

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false) {
		super(x, y);

		animOffsets = new Map<String, Array<Dynamic>>();
		curCharacter = character;
		this.isPlayer = isPlayer;

		switch(curCharacter) {
			default:
				#if sys
					characterPath = "assets/chars/" + curCharacter + ".json";
					if(!Utilities.checkFileExists(characterPath))
						characterPath = "assets/chars/bf.json";
				#else
					characterPath = "./assets/chars/" + curCharacter + ".json";
					if(!Utilities.checkFileExists(characterPath))
						characterPath = "./assets/chars/bf.json";
				#end

				rawJson = Utilities.getFileContents(characterPath);
				rawJson = rawJson.trim();

				while (!rawJson.endsWith("}")) {
					rawJson = rawJson.substr(0, rawJson.length - 1);
				}

				characterJSON = cast Json.parse(rawJson);

				#if sys
					if(Utilities.checkFileExists("assets/shared/images/" + characterJSON.CharacterImage + ".txt"))
						frames = Paths.getPackerAtlas(characterJSON.CharacterImage);
					else
						frames = Paths.getSparrowAtlas(characterJSON.CharacterImage);
				#else
					if(Utilities.checkFileExists("./assets/shared/images/" + characterJSON.CharacterImage + ".txt"))
						frames = Paths.getPackerAtlas(characterJSON.CharacterImage);
					else
						frames = Paths.getSparrowAtlas(characterJSON.CharacterImage);
				#end

				if(characterJSON.CharacterScale != 1) {
					setGraphicSize(Std.int(width * characterJSON.CharacterScale));
					updateHitbox();
				}

				flipX = characterJSON.CharacterFlipX;
				if(characterJSON.CharacterPositionOffsets != null)
					positionOffsets = characterJSON.CharacterPositionOffsets;
				else
					positionOffsets = [0, 0];

				if(characterJSON.CharacterCameraOffsets != null)
					cameraOffsets = characterJSON.CharacterCameraOffsets;
				else
					cameraOffsets = [0, 0];

				if(characterJSON.Anims != null && characterJSON.Anims.length > 0) {
					for(anim in characterJSON.Anims) {
						var AnimationThing:String = anim.Animation;
						var AnimationNameThing:String = anim.AnimPrefix;
						var AnimationFps:Int = anim.AnimFPS;
						var AnimationLoop:Bool = anim.AnimLOOP;
						var AnimationIndices:Array<Int> = anim.AnimIndices;
						
						if(AnimationIndices != null && AnimationIndices.length > 0) {
							animation.addByIndices(AnimationThing, AnimationNameThing, AnimationIndices, "", AnimationFps, AnimationLoop);
						} else {
							animation.addByPrefix(AnimationThing, AnimationNameThing, AnimationFps, AnimationLoop);
						}

						if(anim.Offsets != null && anim.Offsets.length > 1) {
							addOffset(anim.Animation, anim.Offsets[0], anim.Offsets[1]);
						}
					}
				} else {
					animation.addByPrefix('idle', 'BF idle dance', 24, false);
				} 

				antialiasing = characterJSON.CharacterAntialiasing;

				trace("Character " + curCharacter + " loaded with the file " + characterPath + "!");

				characterJSON = null;
				rawJson = null;
				characterPath = null;
		}

		checkIdle();
		dance();

		if(isPlayer) {
			flipX = !flipX;

			// Doesn't flip for BF, since his are already in the right place???
			if(!curCharacter.startsWith('bf')) {
				// var animArray
				var oldRight = animation.getByName('singRIGHT').frames;
				animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;
				animation.getByName('singLEFT').frames = oldRight;

				// IF THEY HAVE MISS ANIMATIONS??
				if(animation.getByName('singRIGHTmiss') != null) {
					var oldMiss = animation.getByName('singRIGHTmiss').frames;
					animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
					animation.getByName('singLEFTmiss').frames = oldMiss;
				}
			}
		}
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0) {
		animOffsets[name] = [x, y];
	}

	public function checkIdle() {
		if(animation.getByName('danceLeft') != null && animation.getByName('danceRight') != null) {
			IdleDancing = true;
			speed = 1;
		} else {
			IdleDancing = false;
			speed = 2;
		}
	}

	public function dance() {
		if(IdleDancing) {
			dancedLeft = !dancedLeft;
			if(dancedLeft)
				playAnim('danceRight');
			else
				playAnim('danceLeft');
		} else if(animation.getByName('idle') != null) {
			playAnim('idle');
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void {
		if(animation.getByName(AnimName) != null)
			animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(AnimName);
		if(animOffsets.exists(AnimName))
			offset.set(daOffset[0], daOffset[1]);
		else
			offset.set(0, 0);

		if(IdleDancing) {
			if(AnimName.startsWith("sing"))
				dancedLeft = !PlayState.isEvenBeat;
		}
	}

	override function update(elapsed:Float) {
		if(!isSpecialAnim) {
			if(!isPlayer && animation.curAnim != null) {
				if(animation.curAnim.name.startsWith('sing'))
					holdTimer += elapsed;

				var dadVar:Float = 4;
				if(curCharacter == 'dad')
					dadVar = 6.1;

				if(holdTimer >= Conductor.stepCrochet * dadVar * 0.001) {
					dance();
					holdTimer = 0;
				}
			}
			if(animation.curAnim != null) {
				if(IdleDancing && (animation.curAnim.name != "danceLeft" && animation.curAnim.name != "danceRight") && animation.curAnim.finished) {
					playAnim('danceRight');
				}
			}
		} else {
			if(animation.curAnim != null) {
				if(animation.curAnim.finished) {
					if(IdleDancing)
						dancedLeft = !PlayState.isEvenBeat;
					isSpecialAnim = false;
				}
			}
		}

		super.update(elapsed);
	}
}
