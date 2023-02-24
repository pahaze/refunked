package customFlixel;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

/**
 * Small class that creates a marquee text using FlxText, FlxTween, and FlxTimer.
 * Made by pahaze.
 */

class FlxMarqueeText extends FlxText {
	// Currently Stuck In Place? --
	var currentlyInPlace:Bool = true;
	// -- Currently Stuck In Place?

	// Has scrolled once? (used for non-stopping marquee)
	var scrolledOnce:Bool = false;

	// Length in seconds for text to scroll across the screen
	var length:Float = 10;

	// Original Placement
	var originalX:Float;

	// Scroll Tween
	var scrollTween:FlxTween;

	// Speed
	var speed:Float;

	// Stop Support --
	var stopLength:Float = 5;
	var stops:Bool;
	// -- Stop Support

	// Target Placement
	var targetX:Float;

	override public function new(X:Float = 0, Y:Float = 0, ?Text:String, Size:Int = 8, Length:Float = 10, Speed:Float = 1, Stops:Bool = true, StopLength:Float = 5, EmbeddedFont:Bool = true) {
		length = Length;
		originalX = X;
		speed = Speed;
		stops = Stops;
		stopLength = StopLength;
		
		super(X, Y, FlxG.width + (X < 0 ? X : -X), Text, Size, EmbeddedFont);

		stopKeepingInPlace();
	}

	function doScroll() {
		if(stops && !currentlyInPlace) {
			scrollTween = FlxTween.tween(this, {x: targetX}, ((length / 2) / speed), {
				onComplete: function(twn:FlxTween) {
					scrollTween = null;
					x = FlxG.width + (originalX < 0 ? -originalX : originalX);
	
					scrollBackToOGX();
				}
			});
		} else if(!stops) {
			if(!scrolledOnce) {
				scrollTween = FlxTween.tween(this, {x: targetX}, ((length / 2) / speed), {
					onComplete: function(twn:FlxTween) {
						scrollTween = null;
						scrolledOnce = true;
					}
				});
			} else {
				x = FlxG.width + (originalX < 0 ? -originalX : originalX);

				scrollBackToTargetX();
			}
		}
	}

	public function setText(?Text:String) {
		if(Text != null && Text != "") {
			text = Text;
			updateHitbox();
		}
	}
	
	function scrollBackToOGX() {
		scrollTween = FlxTween.tween(this, {x: originalX}, ((length / 2) / speed), {
			onComplete: function(twn:FlxTween) {
				scrollTween = null;
				currentlyInPlace = true;
					
				stopKeepingInPlace();
			}
		});
	}

	function scrollBackToTargetX() {
		scrollTween = FlxTween.tween(this, {x: targetX}, (length / speed), {
			onComplete: function(twn:FlxTween) {
				scrollTween = null;
			}
		});
	}

	function stopKeepingInPlace() {
		new FlxTimer().start(stopLength, function(tmr:FlxTimer) {
			currentlyInPlace = false;
		});
	}

	override function update(elapsed:Float) {
		updateHitbox();
		targetX = 0 - FlxG.width + (originalX < 0 ? originalX : -originalX);

		if(scrollTween == null)
			doScroll();

		super.update(elapsed);
	}
}