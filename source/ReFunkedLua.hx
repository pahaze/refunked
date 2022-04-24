import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import openfl.display.BitmapData;
#if sys
import llua.Convert;
import llua.Lua;
import llua.LuaL;
import llua.State;
import sys.io.File;
import sys.FileSystem;
#else
import js.html.XMLHttpRequest;
import js.html.XMLHttpRequestResponseType;
import js.html.Response;
import js.html.FileReader;
#end

using StringTools;

class ReFunkedLua {
	#if sys
		public var luaState:State = null;
	#end
	public function new(luaScript:String) {
		// help LOL!
		#if sys
			// Bro.
			luaState = LuaL.newstate();
			LuaL.openlibs(luaState);
			Lua.init_callbacks(luaState);
			// Uh huh.
			var theResults:Dynamic = LuaL.dofile(luaState, luaScript);
			var theResultsButStringLol:String = Lua.tostring(luaState, theResults);
			// i rarely know lua Please
			setVar('boyfriend', 'boyfriend');
			setVar('boyfriendName', PlayState.SONG.player1);
			setVar('bpm', PlayState.SONG.bpm);
			setVar('crochet', Conductor.crochet);
			setVar('curBeat', 0);
			setVar('curStep', 0);
			setVar('girlfriend', 'girlfriend');
			setVar('girlfriendName', PlayState.SONG.gfPlayer);
			setVar('opponent', 'opponent');
			setVar('opponentName', PlayState.SONG.player2);
			setVar('optimized', false);
			setVar('notOptimized', true);
			if(PlayState.isModSong)
				setVar('rootDir', ModSupport.modsDirectories[PlayState.mod]);
			else
				setVar('rootDir', "assets/");
			setVar('songData', PlayState.SONG.song);
			setVar('songName', PlayState.songName);
			setVar('stepCrochet', Conductor.stepCrochet);
			// what Do This Do (functions moment)
			Lua_helper.add_callback(luaState, "addActor", function(actorName:String) {
				// Check if It Exists.
				if(PlayState.ActorSprites.exists(actorName))
					PlayState.PlayStateThing.add(PlayState.ActorSprites.get(actorName));
			});
			Lua_helper.add_callback(luaState, "addBackgroundGirls", function(spriteName:String) {
				// Check if It Exists.
				if(PlayState.LuaBackgroundGirls.exists(spriteName))
					PlayState.PlayStateThing.add(PlayState.LuaBackgroundGirls.get(spriteName));
			});
			Lua_helper.add_callback(luaState, "addSprite", function(spriteName:String, ?isActive:Bool = false) {
				// Check if It Exists.
				if(PlayState.LuaSprites.exists(spriteName)) {
					PlayState.PlayStateThing.add(PlayState.LuaSprites.get(spriteName));
					if(isActive != null)
						PlayState.LuaSprites.get(spriteName).active = isActive;
				}
			});
			Lua_helper.add_callback(luaState, "addSpriteIndiceAnimation", function(spriteName:String, nameForAnim:String, animationName:String, indiceList:Array<Int>, framerate:Int = 24) {
				// Check if It Exists.
				if(PlayState.LuaSprites.exists(spriteName)) {
					PlayState.LuaSprites.get(spriteName).animation.addByIndices(nameForAnim, animationName, indiceList, "", framerate);
				}
			});
			Lua_helper.add_callback(luaState, "addSpritePrefixAnimation", function(spriteName:String, nameForAnim:String, animationName:String, framerate:Int = 24, ?loop:Bool = false) {
				// Check if It Exists.
				if(PlayState.LuaSprites.exists(spriteName)) {
					PlayState.LuaSprites.get(spriteName).animation.addByPrefix(nameForAnim, animationName, framerate, loop);
				}
			});
			Lua_helper.add_callback(luaState, "addToBoyfriendCamFollow", function(x:Float, y:Float) {
				PlayState.camFollowAdd["bfX"] = x;
				PlayState.camFollowAdd["bfY"] = y;
			});
			Lua_helper.add_callback(luaState, "addToBoyfriendPosition", function(x:Int, y:Int) {
				PlayState.BoyfriendPositionAdd[0] = x;
				PlayState.BoyfriendPositionAdd[1] = y;
			});
			Lua_helper.add_callback(luaState, "addToGirlfriendPosition", function(x:Int, y:Int) {
				PlayState.GirlfriendPositionAdd[0] = x;
				PlayState.GirlfriendPositionAdd[1] = y;
			});
			Lua_helper.add_callback(luaState, "addToOpponentCamFollow", function(x:Float, y:Float) {
				PlayState.camFollowAdd["opponentX"] = x;
				PlayState.camFollowAdd["opponentY"] = y;
			});
			Lua_helper.add_callback(luaState, "addToOpponentPosition", function(x:Int, y:Int) {
				PlayState.OpponentPositionAdd[0] = x;
				PlayState.OpponentPositionAdd[1] = y;
			});
			Lua_helper.add_callback(luaState, "changeActor", function(actor:String, newChar:String, ?removeOldActor:Bool = true, ?addActor:Bool = true, ?changeIcon:Bool = true) {
				// char
				if(PlayState.ActorSprites.exists(actor)) {
					if(PlayState.ActorSprites.exists(newChar)) {
						if(removeOldActor)
							PlayState.ActorSprites[actor].visible = false;
						if(addActor)
							PlayState.PlayStateThing.add(PlayState.ActorSprites[newChar]);
						PlayState.TargetActors[actor] = newChar;
					} else {
						PlayState.ActorSprites[actor].changeCharacter(newChar, false);
					}
					// icon
					if(changeIcon && (actor == "opponent" || actor == "dad"))
						PlayState.PlayStateThing.changeIcon(newChar, false);
					else if(changeIcon && actor == "boyfriend")
						PlayState.PlayStateThing.changeIcon(newChar, true);
				}
			});
			Lua_helper.add_callback(luaState, "destroySprite", function(spriteName:String) {
				// Check if It Exists.
				if(PlayState.LuaSprites.exists(spriteName))
					PlayState.LuaSprites.get(spriteName).destroy();
			});
			Lua_helper.add_callback(luaState, "drainHealth", function(amount:Float) {
				if(amount != 0)
					PlayState.PlayStateThing.health -= amount;
			});
			Lua_helper.add_callback(luaState, "flipSpriteXY", function(spriteName:String, x:Bool, ?y:Bool) {
				// Check if It Exists.
				if(PlayState.LuaSprites.exists(spriteName)) {
					if(y == null) {
						PlayState.LuaSprites.get(spriteName).flipX = x;
					} else {
						PlayState.LuaSprites.get(spriteName).flipX = x;
						PlayState.LuaSprites.get(spriteName).flipY = y;
					}
				}
			});
			Lua_helper.add_callback(luaState, "giveActorHeight", function(actorName:String) {
				// Check if It Exists.
				if(PlayState.ActorSprites.exists(actorName))
					return PlayState.ActorSprites.get(actorName).height;
				return 0;
			});
			Lua_helper.add_callback(luaState, "giveActorWidth", function(actorName:String) {
				// Check if It Exists.
				if(PlayState.ActorSprites.exists(actorName))
					return PlayState.ActorSprites.get(actorName).width;
				return 0;
			});
			Lua_helper.add_callback(luaState, "giveActorX", function(actorName:String) {
				// Check if It Exists.
				if(PlayState.ActorSprites.exists(actorName))
					return PlayState.ActorSprites.get(actorName).x;
				return 0;
			});
			Lua_helper.add_callback(luaState, "giveActorY", function(actorName:String) {
				// Check if It Exists.
				if(PlayState.ActorSprites.exists(actorName))
					return PlayState.ActorSprites.get(actorName).y;
				return 0;
			});
			Lua_helper.add_callback(luaState, "giveHealth", function(amount:Float) {
				if(amount != 0)
					PlayState.PlayStateThing.health += amount;
			});
			Lua_helper.add_callback(luaState, "giveSpriteHeight", function(spriteName:String) {
				// Check if It Exists.
				if(PlayState.LuaSprites.exists(spriteName))
					return PlayState.LuaSprites.get(spriteName).height;
				return 0;
			});
			Lua_helper.add_callback(luaState, "giveSpriteWidth", function(spriteName:String) {
				// Check if It Exists.
				if(PlayState.LuaSprites.exists(spriteName))
					return PlayState.LuaSprites.get(spriteName).width;
				return 0;
			});
			Lua_helper.add_callback(luaState, "makeActor", function(actorName:String, ?isPlayer:Bool = false, ?x:Int = 0, ?y:Int = 0) {
				if(isPlayer) {
					var funnyActor:Boyfriend;
					funnyActor = new Boyfriend(x, y, actorName);
					PlayState.ActorSprites[actorName] = funnyActor;
				} else {
					var funnyActor:Character;
					funnyActor = new Character(x, y, actorName);
					PlayState.ActorSprites[actorName] = funnyActor;
				}
			});
			Lua_helper.add_callback(luaState, "makeAnimatedPackerSprite", function(spriteName:String, path:String, x:Int, y:Int, antialiasing:Bool) {
				var funnySprite:FlxSprite = new FlxSprite(x, y);
				if(PlayState.mod != null || PlayState.mod != "") {
					if(path.contains(".png"))
						funnySprite.frames = Paths.getPackerAtlasThing(path.replace(".png", ""), PlayState.mod);
					else
						funnySprite.frames = Paths.getPackerAtlasThing(path, PlayState.mod);
				} else {
					if(path.contains(".png"))
						funnySprite.frames = Paths.getPackerAtlasThing(path.replace(".png", ""));
					else
						funnySprite.frames = Paths.getPackerAtlasThing(path);
				}
				funnySprite.antialiasing = antialiasing;
				PlayState.LuaSprites[spriteName] = funnySprite;
			});
			Lua_helper.add_callback(luaState, "makeAnimatedSparrowSprite", function(spriteName:String, path:String, x:Int, y:Int, antialiasing:Bool) {
				var funnySprite:FlxSprite = new FlxSprite(x, y);
				if(PlayState.mod != null || PlayState.mod != "") {
					if(path.contains(".png"))
						funnySprite.frames = Paths.getSparrowAtlasThing(path.replace(".png", ""), PlayState.mod);
					else
						funnySprite.frames = Paths.getSparrowAtlasThing(path, PlayState.mod);
				} else {
					if(path.contains(".png"))
						funnySprite.frames = Paths.getSparrowAtlasThing(path.replace(".png", ""));
					else
						funnySprite.frames = Paths.getSparrowAtlasThing(path);
				}
				funnySprite.antialiasing = antialiasing;
				PlayState.LuaSprites[spriteName] = funnySprite;
			});
			Lua_helper.add_callback(luaState, "makePixelBackgroundGirls", function(girlsName:String, x:Int, y:Int) {
				var funnyBGGirls:BackgroundGirls = new BackgroundGirls(x, y);
				PlayState.LuaBackgroundGirls[girlsName] = funnyBGGirls;
			});
			Lua_helper.add_callback(luaState, "makeSprite", function(spriteName:String, path:String, x:Int, y:Int, antialiasing:Bool) {
				var funnySprite:FlxSprite = new FlxSprite(x, y);
				// only sys for now :pls:
				if(path.contains("mods") || path.contains("assets")) {
					funnySprite.loadGraphic(BitmapData.fromFile(path));
				} else {
					if(PlayState.mod != null || PlayState.mod != "") {
						if(!path.contains(".png"))
							funnySprite.loadGraphic(BitmapData.fromFile(Paths.mod(PlayState.mod) + path + ".png"));
						else
							funnySprite.loadGraphic(BitmapData.fromFile(Paths.mod(PlayState.mod) + path));
					} else {
						if(!path.contains(".png"))
							funnySprite.loadGraphic(BitmapData.fromFile("assets/" + path + ".png"));
						else
							funnySprite.loadGraphic(BitmapData.fromFile("assets/" + path));
					}
				}
				funnySprite.antialiasing = antialiasing;
				PlayState.LuaSprites[spriteName] = funnySprite;
			});
			Lua_helper.add_callback(luaState, "performCameraAngleTween", function(tweenName:String, cameraName:String, Angle:Float, ?speed:Float = 1, ?easeType:String) {
				// Check if It Exists.
				removeRemakeTween(tweenName);
				if(PlayState.LuaTweens.exists(tweenName)) {
					PlayState.LuaTweens.set(tweenName, FlxTween.tween(returnCamera(cameraName), {angle: Angle}, speed, {
						ease: returnEase(easeType),
						onComplete: function(twn:FlxTween) {
							PlayState.LuaTweens.remove(tweenName);
						}
					}));
				}
			});
			Lua_helper.add_callback(luaState, "performCameraXTween", function(tweenName:String, cameraName:String, X:Float, ?speed:Float = 1, ?easeType:String) {
				// Check if It Exists.
				removeRemakeTween(tweenName);
				if(PlayState.LuaTweens.exists(tweenName)) {
					PlayState.LuaTweens.set(tweenName, FlxTween.tween(returnCamera(cameraName), {x: X}, speed, {
						ease: returnEase(easeType),
						onComplete: function(twn:FlxTween) {
							PlayState.LuaTweens.remove(tweenName);
						}
					}));
				}
			});
			Lua_helper.add_callback(luaState, "performCameraYTween", function(tweenName:String, cameraName:String, Y:Float, ?speed:Float = 1, ?easeType:String) {
				// Check if It Exists.
				removeRemakeTween(tweenName);
				if(PlayState.LuaTweens.exists(tweenName)) {
					PlayState.LuaTweens.set(tweenName, FlxTween.tween(returnCamera(cameraName), {y: Y}, speed, {
						ease: returnEase(easeType),
						onComplete: function(twn:FlxTween) {
							PlayState.LuaTweens.remove(tweenName);
						}
					}));
				}
			});
			Lua_helper.add_callback(luaState, "performCameraZoom", function(cameraName:String, Zoom:Float) {
				if(PlayState.PlayStateThing.camZooming)
					returnCamera(cameraName).zoom += Zoom;
			});
			Lua_helper.add_callback(luaState, "performOpponentStrumAlphaTween", function(tweenName:String, strumNumber:Int, Alpha:Float, ?speed:Float = 1, ?easeType:String) {
				// Check if It Exists.
				removeRemakeTween(tweenName);
				if(strumNumber < 0)
					strumNumber = 0;
				if(strumNumber > 3)
					strumNumber = 3;
				var noteThing:FlxSprite = PlayState.PlayStateThing.cpuStrums.members[strumNumber];
				
				if(PlayState.LuaTweens.exists(tweenName)) {
					PlayState.LuaTweens.set(tweenName, FlxTween.tween(noteThing, {alpha: Alpha}, speed, {
						ease: returnEase(easeType),
						onComplete: function(twn:FlxTween) {
							PlayState.LuaTweens.remove(tweenName);
						}
					}));
				}
			});
			Lua_helper.add_callback(luaState, "performOpponentStrumAngleTween", function(tweenName:String, strumNumber:Int, Angle:Float, ?speed:Float = 1, ?easeType:String) {
				// Check if It Exists.
				removeRemakeTween(tweenName);
				if(strumNumber < 0)
					strumNumber = 0;
				if(strumNumber > 3)
					strumNumber = 3;
				var noteThing:FlxSprite = PlayState.PlayStateThing.cpuStrums.members[strumNumber];
				
				if(PlayState.LuaTweens.exists(tweenName)) {
					PlayState.LuaTweens.set(tweenName, FlxTween.tween(noteThing, {angle: Angle}, speed, {
						ease: returnEase(easeType),
						onComplete: function(twn:FlxTween) {
							PlayState.LuaTweens.remove(tweenName);
						}
					}));
				}
			});
			Lua_helper.add_callback(luaState, "performOpponentStrumXTween", function(tweenName:String, strumNumber:Int, X:Float, ?speed:Float = 1, ?easeType:String) {
				// Check if It Exists.
				removeRemakeTween(tweenName);
				if(strumNumber < 0)
					strumNumber = 0;
				if(strumNumber > 3)
					strumNumber = 3;
				var noteThing:FlxSprite = PlayState.PlayStateThing.cpuStrums.members[strumNumber];
				
				if(PlayState.LuaTweens.exists(tweenName)) {
					PlayState.LuaTweens.set(tweenName, FlxTween.tween(noteThing, {x: X}, speed, {
						ease: returnEase(easeType),
						onComplete: function(twn:FlxTween) {
							PlayState.LuaTweens.remove(tweenName);
						}
					}));
				}
			});
			Lua_helper.add_callback(luaState, "performOpponentStrumYTween", function(tweenName:String, strumNumber:Int, Y:Float, ?speed:Float = 1, ?easeType:String) {
				// Check if It Exists.
				removeRemakeTween(tweenName);
				if(strumNumber < 0)
					strumNumber = 0;
				if(strumNumber > 3)
					strumNumber = 3;
				var noteThing:FlxSprite = PlayState.PlayStateThing.cpuStrums.members[strumNumber];
				
				if(PlayState.LuaTweens.exists(tweenName)) {
					PlayState.LuaTweens.set(tweenName, FlxTween.tween(noteThing, {y: Y}, speed, {
						ease: returnEase(easeType),
						onComplete: function(twn:FlxTween) {
							PlayState.LuaTweens.remove(tweenName);
						}
					}));
				}
			});
			Lua_helper.add_callback(luaState, "performPlayerStrumAlphaTween", function(tweenName:String, strumNumber:Int, Alpha:Float, ?speed:Float = 1, ?easeType:String) {
				// Check if It Exists.
				removeRemakeTween(tweenName);
				if(strumNumber < 0)
					strumNumber = 0;
				if(strumNumber > 3)
					strumNumber = 3;
				var noteThing:FlxSprite = PlayState.PlayStateThing.playerStrums.members[strumNumber];
				
				if(PlayState.LuaTweens.exists(tweenName) && noteThing != null) {
					PlayState.LuaTweens.set(tweenName, FlxTween.tween(noteThing, {alpha: Alpha}, speed, {
						ease: returnEase(easeType),
						onComplete: function(twn:FlxTween) {
							PlayState.LuaTweens.remove(tweenName);
						}
					}));
				}
			});
			Lua_helper.add_callback(luaState, "performPlayerStrumAngleTween", function(tweenName:String, strumNumber:Int, Angle:Float, ?speed:Float = 1, ?easeType:String) {
				// Check if It Exists.
				removeRemakeTween(tweenName);
				if(strumNumber < 0)
					strumNumber = 0;
				if(strumNumber > 3)
					strumNumber = 3;
				var noteThing:FlxSprite = PlayState.PlayStateThing.playerStrums.members[strumNumber];
				
				if(PlayState.LuaTweens.exists(tweenName) && noteThing != null) {
					PlayState.LuaTweens.set(tweenName, FlxTween.tween(noteThing, {angle: Angle}, speed, {
						ease: returnEase(easeType),
						onComplete: function(twn:FlxTween) {
							PlayState.LuaTweens.remove(tweenName);
						}
					}));
				}
			});
			Lua_helper.add_callback(luaState, "performPlayerStrumXTween", function(tweenName:String, strumNumber:Int, X:Float, ?speed:Float = 1, ?easeType:String) {
				// Check if It Exists.
				removeRemakeTween(tweenName);
				if(strumNumber < 0)
					strumNumber = 0;
				if(strumNumber > 3)
					strumNumber = 3;
				var noteThing:FlxSprite = PlayState.PlayStateThing.playerStrums.members[strumNumber];
				
				if(PlayState.LuaTweens.exists(tweenName) && noteThing != null) {
					PlayState.LuaTweens.set(tweenName, FlxTween.tween(noteThing, {x: X}, speed, {
						ease: returnEase(easeType),
						onComplete: function(twn:FlxTween) {
							PlayState.LuaTweens.remove(tweenName);
						}
					}));
				}
			});
			Lua_helper.add_callback(luaState, "performPlayerStrumYTween", function(tweenName:String, strumNumber:Int, Y:Float, ?speed:Float = 1, ?easeType:String) {
				// Check if It Exists.
				removeRemakeTween(tweenName);
				if(strumNumber < 0)
					strumNumber = 0;
				if(strumNumber > 3)
					strumNumber = 3;
				var noteThing:FlxSprite = PlayState.PlayStateThing.playerStrums.members[strumNumber];
				
				if(PlayState.LuaTweens.exists(tweenName) && noteThing != null) {
					PlayState.LuaTweens.set(tweenName, FlxTween.tween(noteThing, {y: Y}, speed, {
						ease: returnEase(easeType),
						onComplete: function(twn:FlxTween) {
							PlayState.LuaTweens.remove(tweenName);
						}
					}));
				}
			});
			Lua_helper.add_callback(luaState, "performSpriteAngleTween", function(tweenName:String, spriteName:String, Angle:Float, ?speed:Float = 1, ?easeType:String) {
				// Check if It Exists.
				removeRemakeTween(tweenName);
				if(PlayState.LuaTweens.exists(tweenName) && PlayState.LuaSprites.exists(spriteName)) {
					PlayState.LuaTweens.set(tweenName, FlxTween.tween(PlayState.LuaSprites.get(spriteName), {angle: Angle}, speed, {
						ease: returnEase(easeType),
						onComplete: function(twn:FlxTween) {
							PlayState.LuaTweens.remove(tweenName);
						}
					}));
				}
			});
			Lua_helper.add_callback(luaState, "performSpriteXTween", function(tweenName:String, spriteName:String, X:Float, ?speed:Float = 1, ?easeType:String) {
				// Check if It Exists.
				removeRemakeTween(tweenName);
				if(PlayState.LuaTweens.exists(tweenName) && PlayState.LuaSprites.exists(spriteName)) {
					PlayState.LuaTweens.set(tweenName, FlxTween.tween(PlayState.LuaSprites.get(spriteName), {x: X}, speed, {
						ease: returnEase(easeType),
						onComplete: function(twn:FlxTween) {
							PlayState.LuaTweens.remove(tweenName);
						}
					}));
				}
			});
			Lua_helper.add_callback(luaState, "performSpriteYTween", function(tweenName:String, spriteName:String, Y:Float, ?speed:Float = 1, ?easeType:String) {
				// Check if It Exists.
				removeRemakeTween(tweenName);
				if(PlayState.LuaTweens.exists(tweenName) && PlayState.LuaSprites.exists(spriteName)) {
					PlayState.LuaTweens.set(tweenName, FlxTween.tween(PlayState.LuaSprites.get(spriteName), {y: Y}, speed, {
						ease: returnEase(easeType),
						onComplete: function(twn:FlxTween) {
							PlayState.LuaTweens.remove(tweenName);
						}
					}));
				}
			});
			Lua_helper.add_callback(luaState, "playActorAnimation", function(actorName:String, animation:String, ?forced:Bool = false) {
				// Check if It Exists.
				if(PlayState.ActorSprites.exists(actorName))
					PlayState.ActorSprites.get(actorName).playAnim(animation, forced);
			});
			Lua_helper.add_callback(luaState, "playSpriteAnimation", function(spriteName:String, animation:String) {
				// Check if It Exists.
				if(PlayState.LuaSprites.exists(spriteName))
					PlayState.LuaSprites.get(spriteName).animation.play(animation);
			});
			Lua_helper.add_callback(luaState, "resetCameraPosition", function(x:Float, ?y:Float) {
				if(y != null) {
					PlayState.camFollow.x = x;
					PlayState.camFollow.y = y;
				} else {
					PlayState.camFollow.x = x;
				}
				PlayState.camFollowSet = false;
			});
			Lua_helper.add_callback(luaState, "setActorGraphicSize", function(actorName:String, x:Int, ?y:Int) {
				// Check if It Exists.
				if(PlayState.ActorSprites.exists(actorName)) {
					if(y != null)
						PlayState.ActorSprites.get(actorName).setGraphicSize(x, y);
					else
						PlayState.ActorSprites.get(actorName).setGraphicSize(x);
				}
			});
			Lua_helper.add_callback(luaState, "setActorPosition", function(actorName:String, x:Float, y:Float) {
				// Check if It Exists.
				if(PlayState.ActorSprites.exists(actorName)) {
					PlayState.ActorSprites.get(actorName).x = x;
					PlayState.ActorSprites.get(actorName).y = y;
				}
			});
			Lua_helper.add_callback(luaState, "setActorScale", function(actorName:String, x:Float, ?y:Float) {
				// Check if It Exists.
				if(PlayState.ActorSprites.exists(actorName)) {
					if(y != null) {
						PlayState.ActorSprites.get(actorName).scale.x = x;
						PlayState.ActorSprites.get(actorName).scale.y = y;
					} else {
						PlayState.ActorSprites.get(actorName).scale.x = x;
					}
				}
			});
			Lua_helper.add_callback(luaState, "setActorScrollFactor", function(actorName:String, x:Float, ?y:Float) {
				// Check if It Exists.
				if(PlayState.ActorSprites.exists(actorName)) {
					if(y != null)
						PlayState.ActorSprites.get(actorName).scrollFactor.set(x, y);
					else
						PlayState.ActorSprites.get(actorName).scrollFactor.set(x);
				}
			});
			Lua_helper.add_callback(luaState, "setActorVisibility", function(actorName:String, ?visible:Bool = true) {
				// Check if It Exists.
				if(PlayState.ActorSprites.exists(actorName))
					PlayState.ActorSprites.get(actorName).visible = visible;
			});
			Lua_helper.add_callback(luaState, "setBGGirlsScrollFactor", function(spriteName:String, x:Int, y:Int) {
				// Check if It Exists.
				if(PlayState.LuaBackgroundGirls.exists(spriteName))
					PlayState.LuaBackgroundGirls.get(spriteName).scrollFactor.set(x, y);
			});
			Lua_helper.add_callback(luaState, "setBoyfriendCamFollowPosition", function(x:Float, y:Float) {
				PlayState.camFollowSetMap["bfX"] = x;
				PlayState.camFollowSetMap["bfY"] = y;
			});
			Lua_helper.add_callback(luaState, "setCameraAngle", function(camera:String, angle:Float) {
				returnCamera(camera).angle = angle;
			});
			Lua_helper.add_callback(luaState, "setCameraPosition", function(x:Float, ?y:Float) {
				if(y != null) {
					PlayState.camFollow.x = x;
					PlayState.camFollow.y = y;
				} else {
					PlayState.camFollow.x = x;
				}
				PlayState.camFollowSet = true;
			});
			Lua_helper.add_callback(luaState, "setCameraZooms", function(camHUD:Float, ?camGame:Float) {
				if(camGame != null) {
					PlayState.PlayStateThing.camHUDZoom = camHUD;
					PlayState.PlayStateThing.camGameZoom = camGame;
				} else {
					PlayState.PlayStateThing.camHUDZoom = camHUD;
				}
			});
			Lua_helper.add_callback(luaState, "setCamPosPosition", function(x:Float, y:Float) {
				PlayState.camPosSet["x"] = x;
				PlayState.camPosSet["y"] = y;
			});
			Lua_helper.add_callback(luaState, "setCurStage", function(stageName:String) {
				if(stageName != null)
					PlayState.PlayStateThing.pubCurStage = stageName;
			});
			Lua_helper.add_callback(luaState, "setDefaultCamZoom", function(zoom:Float) {
				PlayState.PlayStateThing.defaultCamZoom = zoom;
			});
			Lua_helper.add_callback(luaState, "setHealth", function(amount:Float) {
				PlayState.PlayStateThing.health = amount;
			});
			Lua_helper.add_callback(luaState, "setMinimumCamZoom", function(minzoom:Float) {
				PlayState.PlayStateThing.minCamGameZoom = minzoom;
			});
			Lua_helper.add_callback(luaState, "setNoteVisibility", function(player:Int, seeable:Bool = true) {
				if(player == 0)
					PlayState.opponentNotesSeeable = seeable;
				else
					PlayState.playerNotesSeeable = seeable;
			});
			Lua_helper.add_callback(luaState, "setOpponentCamFollowPosition", function(x:Float, y:Float) {
				PlayState.camFollowSetMap["opponentX"] = x;
				PlayState.camFollowSetMap["opponentY"] = y;
			});
			Lua_helper.add_callback(luaState, "setOpponentStrumAlpha", function(strumNumber:Int, alpha:Float) {
				if(strumNumber < 0)
					strumNumber = 0;
				if(strumNumber > 3)
					strumNumber = 3;
				if(PlayState.PlayStateThing.cpuStrums.members[strumNumber] != null)
					PlayState.PlayStateThing.cpuStrums.members[strumNumber].alpha = alpha;
			});
			Lua_helper.add_callback(luaState, "setOpponentStrumAngle", function(strumNumber:Int, angle:Float) {
				if(strumNumber < 0)
					strumNumber = 0;
				if(strumNumber > 3)
					strumNumber = 3;
				if(PlayState.PlayStateThing.cpuStrums.members[strumNumber] != null)
					PlayState.PlayStateThing.cpuStrums.members[strumNumber].angle = angle;
			});
			Lua_helper.add_callback(luaState, "setOpponentStrumX", function(strumNumber:Int, x:Float) {
				if(strumNumber < 0)
					strumNumber = 0;
				if(strumNumber > 3)
					strumNumber = 3;
				if(PlayState.PlayStateThing.cpuStrums.members[strumNumber] != null)
					PlayState.PlayStateThing.cpuStrums.members[strumNumber].x = x;
			});
			Lua_helper.add_callback(luaState, "setOpponentStrumY", function(strumNumber:Int, y:Float) {
				if(strumNumber < 0)
					strumNumber = 0;
				if(strumNumber > 3)
					strumNumber = 3;
				if(PlayState.PlayStateThing.cpuStrums.members[strumNumber] != null)
					PlayState.PlayStateThing.cpuStrums.members[strumNumber].y = y;
			});
			Lua_helper.add_callback(luaState, "setPlayerStrumAlpha", function(strumNumber:Int, alpha:Float) {
				if(strumNumber < 0)
					strumNumber = 0;
				if(strumNumber > 3)
					strumNumber = 3;
				if(PlayState.PlayStateThing.playerStrums.members[strumNumber] != null)
					PlayState.PlayStateThing.playerStrums.members[strumNumber].alpha = alpha;
			});
			Lua_helper.add_callback(luaState, "setPlayerStrumAngle", function(strumNumber:Int, angle:Float) {
				if(strumNumber < 0)
					strumNumber = 0;
				if(strumNumber > 3)
					strumNumber = 3;
				if(PlayState.PlayStateThing.playerStrums.members[strumNumber] != null)
					PlayState.PlayStateThing.playerStrums.members[strumNumber].angle = angle;
			});
			Lua_helper.add_callback(luaState, "setPlayerStrumX", function(strumNumber:Int, x:Float) {
				if(strumNumber < 0)
					strumNumber = 0;
				if(strumNumber > 3)
					strumNumber = 3;
				if(PlayState.PlayStateThing.playerStrums.members[strumNumber] != null)
					PlayState.PlayStateThing.playerStrums.members[strumNumber].x = x;
			});
			Lua_helper.add_callback(luaState, "setPlayerStrumY", function(strumNumber:Int, y:Float) {
				if(strumNumber < 0)
					strumNumber = 0;
				if(strumNumber > 3)
					strumNumber = 3;
				if(PlayState.PlayStateThing.playerStrums.members[strumNumber] != null)
					PlayState.PlayStateThing.playerStrums.members[strumNumber].y = y;
			});
			Lua_helper.add_callback(luaState, "setSpriteAlpha", function(spriteName:String, alpha:Float) {
				// Check if It Exists.
				if(PlayState.LuaSprites.exists(spriteName))
					PlayState.LuaSprites.get(spriteName).alpha = alpha;
			});
			Lua_helper.add_callback(luaState, "setSpriteCamera", function(spriteName:String, camera:String) {
				// Check if It Exists.
				if(PlayState.LuaSprites.exists(spriteName))
					PlayState.LuaSprites.get(spriteName).cameras = [returnCamera(camera)];

			});
			Lua_helper.add_callback(luaState, "setSpriteGraphicSize", function(spriteName:String, x:Int, ?y:Int) {
				// Check if It Exists.
				if(PlayState.LuaSprites.exists(spriteName)) {
					if(y != null)
						PlayState.LuaSprites.get(spriteName).setGraphicSize(x, y);
					else
						PlayState.LuaSprites.get(spriteName).setGraphicSize(x);
				}
			});
			Lua_helper.add_callback(luaState, "setSpriteOrder", function(spriteName:String, order:Int) {
				// Check if It Exists.
				if(PlayState.LuaSprites.exists(spriteName)) {
					var funnySprite:FlxSprite = PlayState.LuaSprites.get(spriteName);
					PlayState.PlayStateThing.remove(funnySprite, true);
					PlayState.PlayStateThing.insert(order, funnySprite);
				}
			});
			Lua_helper.add_callback(luaState, "setSpritePosition", function(spriteName:String, x:Int, ?y:Int) {
				// Check if It Exists.
				if(PlayState.LuaSprites.exists(spriteName)) {
					if(y != null) {
						PlayState.LuaSprites.get(spriteName).x = x;
						PlayState.LuaSprites.get(spriteName).y = y;
					} else {
						PlayState.LuaSprites.get(spriteName).x = x;
					}
				}
			});
			Lua_helper.add_callback(luaState, "setSpriteScale", function(spriteName:String, x:Float, ?y:Float) {
				// Check if It Exists.
				if(PlayState.LuaSprites.exists(spriteName)) {
					if(y != null) {
						PlayState.LuaSprites.get(spriteName).scale.x = x;
						PlayState.LuaSprites.get(spriteName).scale.y = y;
					} else {
						PlayState.LuaSprites.get(spriteName).scale.x = x;
					}
				}
			});
			Lua_helper.add_callback(luaState, "setSpriteScrollFactor", function(spriteName:String, x:Float, y:Float) {
				// Check if It Exists.
				if(PlayState.LuaSprites.exists(spriteName))
					PlayState.LuaSprites.get(spriteName).scrollFactor.set(x, y);
			});
			Lua_helper.add_callback(luaState, "shakeCamera", function(camera:String, intensity:Float, duration:Float) {
				returnCamera(camera).shake(intensity, duration);
			});
			Lua_helper.add_callback(luaState, "updateSpriteHitbox", function(spriteName:String) {
				// Check if It Exists.
				if(PlayState.LuaSprites.exists(spriteName))
					PlayState.LuaSprites.get(spriteName).updateHitbox();
			});

			luaCallback("create", []);
		#else
			trace("RFE on web does not support Lua yet : )");
		#end
	}

	public function luaCallback(eventToCheck:String, arguments:Array<Dynamic>) {
		#if sys
			if(luaState == null) {
				return 0;
			} else {
				Lua.getglobal(luaState, eventToCheck);
				for(args in arguments) {
					Convert.toLua(luaState, args);
				}
				var luaResult:Null<Int> = Lua.pcall(luaState, arguments.length, 1, 0);
				if (luaResult != null) {
					var funnyResult:Dynamic = Convert.fromLua(luaState, luaResult);
					return funnyResult;
				}
			}
			return 0;
		#else
			return 0;
		#end
	}

	public function removeRemakeTween(tween:String) {
		if(PlayState.LuaTweens.exists(tween)) {
			if(PlayState.LuaTweens.get(tween) != null) {
				PlayState.LuaTweens.get(tween).cancel();
				PlayState.LuaTweens.get(tween).destroy();
				PlayState.LuaTweens.remove(tween);
			}
		}
		var funnyTween:FlxTween = null;
		PlayState.LuaTweens[tween] = funnyTween;
	}

	public function returnCamera(cam:String) {
		switch(cam.toLowerCase()) {
			case "camhud":
				return PlayState.PlayStateThing.camHUD;
			case "camgame":
				return PlayState.PlayStateThing.camGame;
			case "bgcam" | "flxgcamera":
				return FlxG.camera;
			default:
				return PlayState.PlayStateThing.camGame;
		}
	}

	public function returnEase(ease:String) {
		switch(ease.toLowerCase()) {
			case "circin":
				return FlxEase.circIn;
			case "circinout":
				return FlxEase.circInOut;
			case "circout":
				return FlxEase.circOut;
			case "linear":
				return FlxEase.linear;
		}
		// idk what to set here Lol
		return FlxEase.linear;
	}

	public function stopLua() {
		#if sys
			if(luaState != null) {
				return;
			} else {
				Lua.close(luaState);
				luaState = null;
			}
		#else
			return;
		#end
	}

	public function setVar(variable:String, value:Dynamic) {
		#if sys
			if(luaState == null) {
				return;
			} else {
				Convert.toLua(luaState, value);
				Lua.setglobal(luaState, variable);
			}
		#else
			return;
		#end
	}
}