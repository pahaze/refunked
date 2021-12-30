import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
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
            setVar('curBeat', 0);
            setVar('curStep', 0);
            setVar('boyfriendName', PlayState.SONG.player1);
            setVar('girlfriendName', PlayState.SONG.gfPlayer);
            setVar('opponentName', PlayState.SONG.player2);
            // what Do This Do (functions moment)
            Lua_helper.add_callback(luaState, "addBackgroundGirls", function(spriteName:String) {
            // Check if It Exists.
            if(PlayState.LuaBackgroundGirls.exists(spriteName)) {
                PlayState.PlayStateThing.add(PlayState.LuaBackgroundGirls.get(spriteName));
            }
            });
            Lua_helper.add_callback(luaState, "addSprite", function(spriteName:String, ?isActive:Bool = false) {
                // Check if It Exists.
                if(PlayState.LuaSprites.exists(spriteName)) {
                    PlayState.PlayStateThing.add(PlayState.LuaSprites.get(spriteName));
                    if(isActive != null) {
                        PlayState.LuaSprites.get(spriteName).active = isActive;
                    }
                }
            });
            Lua_helper.add_callback(luaState, "addSpriteIndiceAnimation", function(spriteName:String, nameForAnim:String, animationName:String, indiceList:Array<Int>, playAnimOnCreate:Bool = false, loop:Bool = false, loopOnCreatePlay:Bool = false, ?framerate:Int = 24) {
                var funnyFramerate:Int;

                if(framerate == null) {
                   funnyFramerate = 24;
               } else {
                    funnyFramerate = framerate;
                }

               // Check if It Exists.
                if(PlayState.LuaSprites.exists(spriteName)) {
                    PlayState.LuaSprites.get(spriteName).animation.addByIndices(nameForAnim, animationName, indiceList, "", funnyFramerate, loop);
                    if(playAnimOnCreate) {
                        PlayState.LuaSprites.get(spriteName).animation.play(nameForAnim, loopOnCreatePlay);
                    }
                }
            });
            Lua_helper.add_callback(luaState, "addSpritePrefixAnimation", function(spriteName:String, nameForAnim:String, animationName:String, playAnimOnCreate:Bool = false, loop:Bool = false, loopOnCreatePlay:Bool = false, ?framerate:Int = 24) {
                var funnyFramerate:Int;

                if(framerate == null) {
                   funnyFramerate = 24;
                } else {
                    funnyFramerate = framerate;
                }

                // Check if It Exists.
                if(PlayState.LuaSprites.exists(spriteName)) {
                    PlayState.LuaSprites.get(spriteName).animation.addByPrefix(nameForAnim, animationName, funnyFramerate, loop);
                    if(playAnimOnCreate) {
                        PlayState.LuaSprites.get(spriteName).animation.play(nameForAnim, loopOnCreatePlay);
                    }
                }
            });
            Lua_helper.add_callback(luaState, "addToBoyfriendPosition", function(x:Int, y:Int) {
                PlayState.BoyfriendPositionAdd[0] = x;
                PlayState.BoyfriendPositionAdd[1] = y;
            });
            Lua_helper.add_callback(luaState, "addToGirlfriendPosition", function(x:Int, y:Int) {
                PlayState.GirlfriendPositionAdd[0] = x;
                PlayState.GirlfriendPositionAdd[1] = y;
            });
            Lua_helper.add_callback(luaState, "addToOpponentPosition", function(x:Int, y:Int) {
                PlayState.OpponentPositionAdd[0] = x;
                PlayState.OpponentPositionAdd[1] = y;
            });
            Lua_helper.add_callback(luaState, "destroySprite", function(funnyName:String) {
                // Check if It Exists.
                if(PlayState.LuaSprites.exists(funnyName)) {
                    PlayState.LuaSprites.get(funnyName).destroy();
                }
            });
            Lua_helper.add_callback(luaState, "drainHealth", function(funnyNumber:Float) {
                if(funnyNumber > 0)
                    PlayState.PlayStateThing.health -= funnyNumber;
            });
            Lua_helper.add_callback(luaState, "giveActorHeight", function(actorName:String) {
                // Check if It Exists.
                if(PlayState.ActorSprites.exists(actorName)) {
                    return PlayState.ActorSprites.get(actorName).height;
                }
                return 0;
            });
            Lua_helper.add_callback(luaState, "giveActorWidth", function(actorName:String) {
                // Check if It Exists.
                if(PlayState.ActorSprites.exists(actorName)) {
                    return PlayState.ActorSprites.get(actorName).width;
                }
                return 0;
            });
            Lua_helper.add_callback(luaState, "giveSpriteHeight", function(spriteName:String) {
                // Check if It Exists.
                if(PlayState.LuaSprites.exists(spriteName)) {
                    return PlayState.LuaSprites.get(spriteName).height;
                }
                return 0;
            });
            Lua_helper.add_callback(luaState, "giveSpriteWidth", function(spriteName:String) {
                // Check if It Exists.
                if(PlayState.LuaSprites.exists(spriteName)) {
                    return PlayState.LuaSprites.get(spriteName).width;
                }
                return 0;
            });
            Lua_helper.add_callback(luaState, "makeAnimatedPackerSprite", function(funnyName:String, path:String, x:Int, y:Int, antialiasing:Bool, ?scale:Int = 1) {
                var funnySprite:FlxSprite = new FlxSprite(x, y);
                funnySprite.frames = Paths.getPackerAtlasThing(path);
                funnySprite.antialiasing = antialiasing;
                if(scale != null && scale > 1) {
                    funnySprite.setGraphicSize(Std.int(funnySprite.width * Std.int(scale)));
                }
                PlayState.LuaSprites[funnyName] = funnySprite;
            });
            Lua_helper.add_callback(luaState, "makeAnimatedSparrowSprite", function(funnyName:String, path:String, x:Int, y:Int, antialiasing:Bool, ?scale:Int = 1) {
                var funnySprite:FlxSprite = new FlxSprite(x, y);
                funnySprite.frames = Paths.getSparrowAtlasThing(path);
                funnySprite.antialiasing = antialiasing;
                if(scale != null && scale > 1) {
                    funnySprite.setGraphicSize(Std.int(funnySprite.width * Std.int(scale)));
                }
                PlayState.LuaSprites[funnyName] = funnySprite;
            });
            Lua_helper.add_callback(luaState, "makePixelBackgroundGirls", function(funnyName:String, x:Int, y:Int) {
                var funnyBGGirls:BackgroundGirls = new BackgroundGirls(x, y);
                PlayState.LuaBackgroundGirls[funnyName] = funnyBGGirls;
            });
            Lua_helper.add_callback(luaState, "makeSprite", function(funnyName:String, path:String, x:Int, y:Int, antialiasing:Bool, ?scale:Int = 1) {
                var funnySprite:FlxSprite = new FlxSprite(x, y);
                // only sys for now :pls:
                funnySprite.loadGraphic(BitmapData.fromFile(path));
                funnySprite.antialiasing = antialiasing;
                if(scale != null && scale > 1) {
                    funnySprite.setGraphicSize(Std.int(funnySprite.width * Std.int(scale)));
                }
                PlayState.LuaSprites[funnyName] = funnySprite;
            });
            Lua_helper.add_callback(luaState, "playActorAnimation", function(actorName:String, animation:String) {
                if(PlayState.ActorSprites.exists(actorName)) {
                    PlayState.ActorSprites.get(actorName).playAnim(animation);
                }
            });
            Lua_helper.add_callback(luaState, "playSpriteAnimation", function(spriteName:String, animation:String) {
                // Check if It Exists.
                if(PlayState.LuaSprites.exists(spriteName)) {
                    PlayState.LuaSprites.get(spriteName).animation.play(animation);
                }
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
                if(PlayState.ActorSprites.exists(actorName)) {
                    PlayState.ActorSprites.get(actorName).x = x;
                    PlayState.ActorSprites.get(actorName).y = y;
                }
            });
            Lua_helper.add_callback(luaState, "setActorScale", function(actorName:String, x:Float, ?y:Float) {
                if(PlayState.ActorSprites.exists(actorName)) {
                    if(y != null) {
                        PlayState.ActorSprites.get(actorName).scale.x = x;
                        PlayState.ActorSprites.get(actorName).scale.y = y;
                    } else {
                        PlayState.ActorSprites.get(actorName).scale.x = x;
                    }
                }
            });
            Lua_helper.add_callback(luaState, "setBGCamAngle", function(angle:Float) {
                FlxG.camera.angle = angle;
            });
            Lua_helper.add_callback(luaState, "setBGGirlsScrollFactor", function(spriteName:String, x:Int, y:Int) {
                // Check if It Exists.
                if(PlayState.LuaBackgroundGirls.exists(spriteName)) {
                    PlayState.LuaBackgroundGirls.get(spriteName).scrollFactor.set(x, y);
                }
            });
            Lua_helper.add_callback(luaState, "setBoyfriendCamFollowPosition", function(x:Float, y:Float) {
                PlayState.camFollowAdd["bfX"] = x;
                PlayState.camFollowAdd["bfY"] = y;
            });
            Lua_helper.add_callback(luaState, "setCamHUDAngle", function(angle:Float) {
                PlayState.PlayStateThing.camHUD.angle = angle;
            });
            Lua_helper.add_callback(luaState, "setCamPosition", function(x:Float, y:Float) {
                PlayState.camPosSet["x"] = x;
                PlayState.camPosSet["y"] = y;
            });
            Lua_helper.add_callback(luaState, "setCurStage", function(stageName:String) {
                if(stageName != null) {
                    PlayState.PlayStateThing.pubCurStage = stageName;
                }
            });
            Lua_helper.add_callback(luaState, "setOpponentCamFollowPosition", function(x:Float, y:Float) {
                PlayState.camFollowAdd["opponentX"] = x;
                PlayState.camFollowAdd["opponentY"] = y;
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
            Lua_helper.add_callback(luaState, "setSpriteScale", function(spriteName:String, x:Int, ?y:Int) {
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
                if(PlayState.LuaSprites.exists(spriteName)) {
                    PlayState.LuaSprites.get(spriteName).scrollFactor.set(x, y);
                }
            });
            Lua_helper.add_callback(luaState, "shakeBGCam", function(intensity:Float, duration:Float) {
                FlxG.camera.shake(intensity, duration);
            });
            Lua_helper.add_callback(luaState, "shakeCamHUD", function(intensity:Float, duration:Float) {
                PlayState.PlayStateThing.camHUD.shake(intensity, duration);
            });
            Lua_helper.add_callback(luaState, "updateSpriteHitbox", function(spriteName:String) {
                // Check if It Exists.
                if(PlayState.LuaSprites.exists(spriteName)) {
                    PlayState.LuaSprites.get(spriteName).updateHitbox();
                }
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