package optimized;

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

class OptimizedReFunkedLua {
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
			setVar('boyfriendName', OptimizedPlayState.SONG.player1);
			setVar('bpm', OptimizedPlayState.SONG.bpm);
			setVar('crochet', Conductor.crochet);
			setVar('curBeat', 0);
			setVar('curStep', 0);
			setVar('girlfriend', 'girlfriend');
			setVar('girlfriendName', OptimizedPlayState.SONG.gfPlayer);
			setVar('opponent', 'opponent');
			setVar('opponentName', OptimizedPlayState.SONG.player2);
			setVar('optimized', true);
			setVar('notOptimized', false);
			if(OptimizedPlayState.isModSong)
				setVar('rootDir', ModSupport.modsDirectories[OptimizedPlayState.mod]);
			else
				setVar('rootDir', "assets/");
			setVar('songData', OptimizedPlayState.SONG.song);
			setVar('songName', OptimizedPlayState.songName);
			setVar('stepCrochet', Conductor.stepCrochet);
			// what Do This Do (functions moment)
			Lua_helper.add_callback(luaState, "drainHealth", function(amount:Float) {
				if(amount != 0)
					OptimizedPlayState.OptimizedPlayStateThing.health -= amount;
			});
			Lua_helper.add_callback(luaState, "giveHealth", function(amount:Float) {
				if(amount != 0)
					OptimizedPlayState.OptimizedPlayStateThing.health += amount;
			});
			Lua_helper.add_callback(luaState, "performCameraAngleTween", function(tweenName:String, cameraName:String, Angle:Float, ?speed:Float = 1, ?easeType:String) {
				// Check if It Exists.
				removeRemakeTween(tweenName);
				if(OptimizedPlayState.LuaTweens.exists(tweenName)) {
					OptimizedPlayState.LuaTweens.set(tweenName, FlxTween.tween(returnCamera(cameraName), {angle: Angle}, speed, {
						ease: returnEase(easeType),
						onComplete: function(twn:FlxTween) {
							OptimizedPlayState.LuaTweens.remove(tweenName);
						}
					}));
				}
			});
			Lua_helper.add_callback(luaState, "performCameraXTween", function(tweenName:String, cameraName:String, X:Float, ?speed:Float = 1, ?easeType:String) {
				// Check if It Exists.
				removeRemakeTween(tweenName);
				if(OptimizedPlayState.LuaTweens.exists(tweenName)) {
					OptimizedPlayState.LuaTweens.set(tweenName, FlxTween.tween(returnCamera(cameraName), {x: X}, speed, {
						ease: returnEase(easeType),
						onComplete: function(twn:FlxTween) {
							OptimizedPlayState.LuaTweens.remove(tweenName);
						}
					}));
				}
			});
			Lua_helper.add_callback(luaState, "performCameraYTween", function(tweenName:String, cameraName:String, Y:Float, ?speed:Float = 1, ?easeType:String) {
				// Check if It Exists.
				removeRemakeTween(tweenName);
				if(OptimizedPlayState.LuaTweens.exists(tweenName)) {
					OptimizedPlayState.LuaTweens.set(tweenName, FlxTween.tween(returnCamera(cameraName), {y: Y}, speed, {
						ease: returnEase(easeType),
						onComplete: function(twn:FlxTween) {
							OptimizedPlayState.LuaTweens.remove(tweenName);
						}
					}));
				}
			});
			Lua_helper.add_callback(luaState, "performCameraZoom", function(cameraName:String, Zoom:Float) {
				if(OptimizedPlayState.OptimizedPlayStateThing.camZooming)
					returnCamera(cameraName).zoom += Zoom;
			});
			Lua_helper.add_callback(luaState, "performOpponentStrumAngleTween", function(tweenName:String, strumNumber:Int, Angle:Float, ?speed:Float = 1, ?easeType:String) {
				// Check if It Exists.
				removeRemakeTween(tweenName);
				if(strumNumber < 0)
					strumNumber = 0;
				if(strumNumber > 3)
					strumNumber = 3;
				var noteThing:FlxSprite = OptimizedPlayState.OptimizedPlayStateThing.cpuStrums.members[strumNumber];
				
				if(OptimizedPlayState.LuaTweens.exists(tweenName)) {
					OptimizedPlayState.LuaTweens.set(tweenName, FlxTween.tween(noteThing, {angle: Angle}, speed, {
						ease: returnEase(easeType),
						onComplete: function(twn:FlxTween) {
							OptimizedPlayState.LuaTweens.remove(tweenName);
						}
					}));
				}
			});
			Lua_helper.add_callback(luaState, "performOpponentStrumAlphaTween", function(tweenName:String, strumNumber:Int, Alpha:Float, ?speed:Float = 1, ?easeType:String) {
				// Check if It Exists.
				removeRemakeTween(tweenName);
				if(strumNumber < 0)
					strumNumber = 0;
				if(strumNumber > 3)
					strumNumber = 3;
				var noteThing:FlxSprite = OptimizedPlayState.OptimizedPlayStateThing.cpuStrums.members[strumNumber];
				
				if(OptimizedPlayState.LuaTweens.exists(tweenName)) {
					OptimizedPlayState.LuaTweens.set(tweenName, FlxTween.tween(noteThing, {alpha: Alpha}, speed, {
						ease: returnEase(easeType),
						onComplete: function(twn:FlxTween) {
							OptimizedPlayState.LuaTweens.remove(tweenName);
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
				var noteThing:FlxSprite = OptimizedPlayState.OptimizedPlayStateThing.cpuStrums.members[strumNumber];
				
				if(OptimizedPlayState.LuaTweens.exists(tweenName)) {
					OptimizedPlayState.LuaTweens.set(tweenName, FlxTween.tween(noteThing, {x: X}, speed, {
						ease: returnEase(easeType),
						onComplete: function(twn:FlxTween) {
							OptimizedPlayState.LuaTweens.remove(tweenName);
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
				var noteThing:FlxSprite = OptimizedPlayState.OptimizedPlayStateThing.cpuStrums.members[strumNumber];
				
				if(OptimizedPlayState.LuaTweens.exists(tweenName)) {
					OptimizedPlayState.LuaTweens.set(tweenName, FlxTween.tween(noteThing, {y: Y}, speed, {
						ease: returnEase(easeType),
						onComplete: function(twn:FlxTween) {
							OptimizedPlayState.LuaTweens.remove(tweenName);
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
				var noteThing:FlxSprite = OptimizedPlayState.OptimizedPlayStateThing.playerStrums.members[strumNumber];
				
				if(OptimizedPlayState.LuaTweens.exists(tweenName) && noteThing != null) {
					OptimizedPlayState.LuaTweens.set(tweenName, FlxTween.tween(noteThing, {angle: Angle}, speed, {
						ease: returnEase(easeType),
						onComplete: function(twn:FlxTween) {
							OptimizedPlayState.LuaTweens.remove(tweenName);
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
				var noteThing:FlxSprite = OptimizedPlayState.OptimizedPlayStateThing.playerStrums.members[strumNumber];
				
				if(OptimizedPlayState.LuaTweens.exists(tweenName) && noteThing != null) {
					OptimizedPlayState.LuaTweens.set(tweenName, FlxTween.tween(noteThing, {alpha: Alpha}, speed, {
						ease: returnEase(easeType),
						onComplete: function(twn:FlxTween) {
							OptimizedPlayState.LuaTweens.remove(tweenName);
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
				var noteThing:FlxSprite = OptimizedPlayState.OptimizedPlayStateThing.playerStrums.members[strumNumber];
				
				if(OptimizedPlayState.LuaTweens.exists(tweenName) && noteThing != null) {
					OptimizedPlayState.LuaTweens.set(tweenName, FlxTween.tween(noteThing, {x: X}, speed, {
						ease: returnEase(easeType),
						onComplete: function(twn:FlxTween) {
							OptimizedPlayState.LuaTweens.remove(tweenName);
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
				var noteThing:FlxSprite = OptimizedPlayState.OptimizedPlayStateThing.playerStrums.members[strumNumber];
				
				if(OptimizedPlayState.LuaTweens.exists(tweenName) && noteThing != null) {
					OptimizedPlayState.LuaTweens.set(tweenName, FlxTween.tween(noteThing, {y: Y}, speed, {
						ease: returnEase(easeType),
						onComplete: function(twn:FlxTween) {
							OptimizedPlayState.LuaTweens.remove(tweenName);
						}
					}));
				}
			});
			Lua_helper.add_callback(luaState, "setCameraAngle", function(camera:String, angle:Float) {
				returnCamera(camera).angle = angle;
			});
			Lua_helper.add_callback(luaState, "setCameraPosition", function(x:Float, ?y:Float) {
				if(y != null) {
					OptimizedPlayState.camFollow.x = x;
					OptimizedPlayState.camFollow.y = y;
				} else {
					OptimizedPlayState.camFollow.x = x;
				}
				OptimizedPlayState.camFollowSet = true;
			});
			Lua_helper.add_callback(luaState, "setCameraZooms", function(camHUD:Float, ?camGame:Float) {
				if(camGame != null) {
					OptimizedPlayState.OptimizedPlayStateThing.camHUDZoom = camHUD;
					OptimizedPlayState.OptimizedPlayStateThing.camGameZoom = camGame;
				} else {
					OptimizedPlayState.OptimizedPlayStateThing.camHUDZoom = camHUD;
				}
			});
			Lua_helper.add_callback(luaState, "setCurStage", function(stageName:String) {
				if(stageName != null)
					OptimizedPlayState.OptimizedPlayStateThing.pubCurStage = stageName;
			});
			Lua_helper.add_callback(luaState, "setHealth", function(amount:Float) {
				OptimizedPlayState.OptimizedPlayStateThing.health = amount;
			});
			Lua_helper.add_callback(luaState, "setMinimumCamZoom", function(minzoom:Float) {
				OptimizedPlayState.OptimizedPlayStateThing.minCamGameZoom = minzoom;
			});
			Lua_helper.add_callback(luaState, "setNoteVisibility", function(player:Int, seeable:Bool = true) {
				if(player == 0)
					OptimizedPlayState.opponentNotesSeeable = seeable;
				else
					OptimizedPlayState.playerNotesSeeable = seeable;
			});
			Lua_helper.add_callback(luaState, "setOpponentStrumAlpha", function(strumNumber:Int, alpha:Float) {
				if(strumNumber < 0)
					strumNumber = 0;
				if(strumNumber > 3)
					strumNumber = 3;
				if(OptimizedPlayState.OptimizedPlayStateThing.cpuStrums.members[strumNumber] != null)
					OptimizedPlayState.OptimizedPlayStateThing.cpuStrums.members[strumNumber].alpha = alpha;
			});
			Lua_helper.add_callback(luaState, "setOpponentStrumAngle", function(strumNumber:Int, angle:Float) {
				if(strumNumber < 0)
					strumNumber = 0;
				if(strumNumber > 3)
					strumNumber = 3;
				if(OptimizedPlayState.OptimizedPlayStateThing.cpuStrums.members[strumNumber] != null)
					OptimizedPlayState.OptimizedPlayStateThing.cpuStrums.members[strumNumber].angle = angle;
			});
			Lua_helper.add_callback(luaState, "setOpponentStrumX", function(strumNumber:Int, x:Float) {
				if(strumNumber < 0)
					strumNumber = 0;
				if(strumNumber > 3)
					strumNumber = 3;
				if(OptimizedPlayState.OptimizedPlayStateThing.cpuStrums.members[strumNumber] != null)
					OptimizedPlayState.OptimizedPlayStateThing.cpuStrums.members[strumNumber].x = x;
			});
			Lua_helper.add_callback(luaState, "setOpponentStrumY", function(strumNumber:Int, y:Float) {
				if(strumNumber < 0)
					strumNumber = 0;
				if(strumNumber > 3)
					strumNumber = 3;
				if(OptimizedPlayState.OptimizedPlayStateThing.cpuStrums.members[strumNumber] != null)
					OptimizedPlayState.OptimizedPlayStateThing.cpuStrums.members[strumNumber].y = y;
			});
			Lua_helper.add_callback(luaState, "setPlayerStrumAlpha", function(strumNumber:Int, alpha:Float) {
				if(strumNumber < 0)
					strumNumber = 0;
				if(strumNumber > 3)
					strumNumber = 3;
				if(OptimizedPlayState.OptimizedPlayStateThing.playerStrums.members[strumNumber] != null)
					OptimizedPlayState.OptimizedPlayStateThing.playerStrums.members[strumNumber].alpha = alpha;
			});
			Lua_helper.add_callback(luaState, "setPlayerStrumAngle", function(strumNumber:Int, angle:Float) {
				if(strumNumber < 0)
					strumNumber = 0;
				if(strumNumber > 3)
					strumNumber = 3;
				if(OptimizedPlayState.OptimizedPlayStateThing.playerStrums.members[strumNumber] != null)
					OptimizedPlayState.OptimizedPlayStateThing.playerStrums.members[strumNumber].angle = angle;
			});
			Lua_helper.add_callback(luaState, "setPlayerStrumX", function(strumNumber:Int, x:Float) {
				if(strumNumber < 0)
					strumNumber = 0;
				if(strumNumber > 3)
					strumNumber = 3;
				if(OptimizedPlayState.OptimizedPlayStateThing.playerStrums.members[strumNumber] != null)
					OptimizedPlayState.OptimizedPlayStateThing.playerStrums.members[strumNumber].x = x;
			});
			Lua_helper.add_callback(luaState, "setPlayerStrumY", function(strumNumber:Int, y:Float) {
				if(strumNumber < 0)
					strumNumber = 0;
				if(strumNumber > 3)
					strumNumber = 3;
				if(OptimizedPlayState.OptimizedPlayStateThing.playerStrums.members[strumNumber] != null)
					OptimizedPlayState.OptimizedPlayStateThing.playerStrums.members[strumNumber].y = y;
			});
			Lua_helper.add_callback(luaState, "shakeCamera", function(camera:String, intensity:Float, duration:Float) {
				returnCamera(camera).shake(intensity, duration);
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
		if(OptimizedPlayState.LuaTweens.exists(tween)) {
			if(OptimizedPlayState.LuaTweens.get(tween) != null) {
				OptimizedPlayState.LuaTweens.get(tween).cancel();
				OptimizedPlayState.LuaTweens.get(tween).destroy();
				OptimizedPlayState.LuaTweens.remove(tween);
			}
		}
		var funnyTween:FlxTween = null;
		OptimizedPlayState.LuaTweens[tween] = funnyTween;
	}

	public function returnCamera(cam:String) {
		switch(cam.toLowerCase()) {
			case "camhud":
				return OptimizedPlayState.OptimizedPlayStateThing.camHUD;
			case "camgame":
				return OptimizedPlayState.OptimizedPlayStateThing.camGame;
			case "bgcam" | "flxgcamera":
				return FlxG.camera;
			default:
				return OptimizedPlayState.OptimizedPlayStateThing.camGame;
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