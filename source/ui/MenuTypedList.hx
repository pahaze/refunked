package ui;

import flixel.effects.FlxFlicker;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxSignal;
import haxe.ds.StringMap;

class MenuTypedList<T:MenuItem> extends FlxTypedGroup<T> {
    public var selectedIndex:Int = 0;

    public var onChange:FlxTypedSignal<T -> Void> = new FlxTypedSignal<T -> Void>();
    public var onAcceptPress:FlxTypedSignal<T -> Void> = new FlxTypedSignal<T -> Void>();

    public var enabled:Bool = true;
    public var navControls:NavControls;
    public var wrapMode:WrapMode = Both;
    public var byName:StringMap<T> = new StringMap<T>();
    public var busy:Bool = false;

    public function new(dir:NavControls = Vertical, ?wrapDir:WrapMode) {
        navControls = dir;

        if(wrapDir != null) {
            wrapMode = wrapDir;
        } else {
            switch(dir) {
                case Horizontal:
                    wrapMode = Horizontal;

                case Vertical:
                    wrapMode = Vertical;

                default:
                    wrapMode = Both;
            }
        }

        super();
    }

	public function accept() {
		var selected:T = members[selectedIndex];
		onAcceptPress.dispatch(selected);

		if(selected.fireInstantly) {
			selected.callback();
		} else {
			busy = true;
			FlxG.sound.play(Paths.sound("confirmMenu"));
			FlxFlicker.flicker(selected, 1, 0.06, true, false, function(flicker) {
				busy = false;
				selected.callback();
			});
		}
	}

    public function addItem(name:String, item:T) {
        if(selectedIndex == length)
            item.select();

        byName.set(name, item);

        return add(item);
    }

	override function destroy() {
		super.destroy();

		byName = null;
		onChange = null;
		onAcceptPress = null;
	}

	public function getItem(name:String) {
		return byName.get(name);
	}

	public function has(name:String) {
		return byName.exists(name);
	}

	function navAxis(selected:Int, maxLength:Int, goBack:Bool, goForward:Bool, doWrap:Bool) {
		if(goBack == goForward)
			return selected;

		if(goBack) {
			if(selected > 0)
				selected--;
			else if(doWrap)
				selected = maxLength - 1;
		} else {
			if(selected < maxLength - 1)
				selected++;
			else if(doWrap)
				selected = 0;
		}

		return selected;
	}

	function navGrid(gridLength:Int, hBack:Bool, hForward:Bool, hWrap:Bool, vBack:Bool, vForward:Bool, vWrap:Bool) {
		var itemLength:Int = Math.ceil(length / gridLength);
		var curItem:Int = Math.floor(selectedIndex / gridLength);
		var curGrid:Int = selectedIndex % gridLength;
		var selectedX:Int = navAxis(curGrid, gridLength, hBack, hForward, hWrap);
		var selectedY:Int = navAxis(curItem, itemLength, vBack, vForward, vWrap);
		
		return Std.int(Math.min(length - 1, selectedY * gridLength + selectedX));
	}

    public function resetItem(name:String, newName:String, callback:Dynamic = null) {
        if(!byName.exists(name))
            throw('No item named \"$name\"!');

        var item:T = byName.get(name);
        byName.remove(name);
        byName.set(newName, item);

        return item;
    }

	public function selectItem(index:Int) {
		members[selectedIndex].idle();
		selectedIndex = index;
		members[selectedIndex].select();
		onChange.dispatch(members[selectedIndex]);
	}

    public override function update(elapsed:Float) {
        super.update(elapsed);

        if(enabled && !busy) {
            var controls:Controls = PlayerSettings.player1.controls;
            var wrapHorizontal:Bool;
            var wrapVertical:Bool;
            var nextIndex:Int;

            switch(wrapMode) {
                case Horizontal | Both:
                    wrapHorizontal = true;
                default:
                    wrapHorizontal = false;
            }

            switch(wrapMode) {
                case Vertical | Both:
                    wrapVertical = true;
                default:
                    wrapVertical = false;
            }

            switch(navControls) {
                case Horizontal:
                    var leftP:Bool = controls.LEFT_P;
                    var rightP:Bool = controls.RIGHT_P;
                    nextIndex = navAxis(selectedIndex, length, leftP, rightP, wrapHorizontal);

                case Vertical:
                    var downP:Bool = controls.DOWN_P;
                    var upP:Bool = controls.UP_P;
                    nextIndex = navAxis(selectedIndex, length, upP, downP, wrapVertical);
                
                case Both:
                    var backwards:Bool = controls.LEFT_P || controls.UP_P;
                    var forwards:Bool = controls.RIGHT_P || controls.DOWN_P;
                    nextIndex = navAxis(selectedIndex, length, backwards, forwards, wrapMode != None);
                
                case Columns(num):
                    nextIndex = navGrid(num, controls.LEFT_P, controls.RIGHT_P, wrapHorizontal, controls.UP_P, controls.DOWN_P, wrapVertical);
                
                case Rows(num):
                    nextIndex = navGrid(num, controls.LEFT_P, controls.RIGHT_P, wrapHorizontal, controls.UP_P, controls.DOWN_P, wrapVertical);
            }

			if(nextIndex != selectedIndex) {
				FlxG.sound.play(Paths.sound("scrollMenu"));
				selectItem(nextIndex);
			}

			if(controls.ACCEPT)
				accept();
        }
    }
}