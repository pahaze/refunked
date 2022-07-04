package themes;

import haxe.Json;
import flixel.util.FlxColor;

using StringTools;

typedef AverageText = {
	// Usage of bounce tween for text.
	var bouncetween:Null<BounceTween>;
	// Controls whether text centers or not. center[0] = Center X, center[1] = Center Y.
	var center:Null<Array<Bool>>;
	// Controls customization of text.
	var customization:Null<TextCustomization>;
	// Controls whether text fades (for botplay).
	var fades:Null<Bool>;
	// Controls whether text comes from the screen width subtracing x.
	var fromwidth:Null<Bool>;
	// Controls whether text comes from the screen height subtracing y.
	var fromheight:Null<Bool>;
	// Controls whether text scrolls or not.
	var scrolls:Null<Bool>;
	// Text to be used. text[0] = No Botplay/Practice, text[1] = Botplay, text[2] = Practice, text[3] = Botplay + Practice.
	var text:Null<Array<String>>;
	// Controls x of text. x[0] = X, x[1] = Downscroll X, x[2] = Middlescroll X, x[3] = Downscroll + Middlescroll X.
	var x:Null<Array<Float>>;
	// Controls y of text. y[0] = Y, y[1] = Downscroll Y, y[2] = Middlescroll Y, y[3] = Downscroll + Middlescroll Y.
	var y:Null<Array<Float>>;
}

typedef BounceTween = {
	// Enables or disables bounce tween.
	var enabled:Null<Bool>;
	// Controls scale of bounce tween.
	var scale:Null<Float>;
	// Controls type of bounce tween.
	var type:Null<String>;
}

// It's easier to define healthbar and timebar as separate sprite typedefes IMO.
typedef Healthbar = {
	// Controls whether healthbar centers or not. center[0] = Center X, center[1] = Center Y.
	var center:Null<Array<Bool>>;
	// Controls colors of healthbar.
	var colors:Null<Array<String>>;
	// Controls image used for healthbar.
	var image:Null<String>;
	// Controls whether healthbar shows icons or not. showIcons[0] = Show P1 Icon, showIcons[1] = Show P2 Icon.
	var showIcons:Null<Array<Bool>>;
	// Controls x of text. x[0] = X, x[1] = Downscroll X, x[2] = Middlescroll X, x[3] = Downscroll + Middlescroll X.
	var x:Null<Array<Float>>;
	// Controls y of text. y[0] = Y, y[1] = Downscroll Y, y[2] = Middlescroll Y, y[3] = Downscroll + Middlescroll Y.
	var y:Null<Array<Float>>;
}

typedef TextBorderCustomization = {
	// Controls color of border.
	var color:Null<String>;
	// Controls size of border.
	var size:Null<Float>;
	// Controls style of border.
	var style:Null<String>;
}

typedef TextCustomization = {
	// Controls alignment of text.
	var alignment:Null<String>;
	// Controls border of text.
	var border:Null<TextBorderCustomization>;
	// Controls color of text.
	var color:Null<String>;
	// Controls whether text uses an embedded font or not.
	var embeddedfont:Null<Bool>;
	// Font of text.
	var font:Null<String>;
	// Font size of text.
	var fontsize:Null<Int>;
}

typedef Timebar = {
	// Controls whether timebar centers or not. center[0] = Center X, center[1] = Center Y.
	var center:Null<Array<Bool>>;
	// Controls colors of timebar.
	var colors:Null<Array<String>>;
	// Controls image used for timebar.
	var image:Null<String>;
	// Controls style of timebar.
	var style:Null<String>;
	// Text typedef for timebar. Allows a lot more freedom, IMO.
	var text:Null<AverageText>;
	// Controls whether only the text will show or if everything will show.
	var textOnly:Null<Bool>;
	// Controls x of timebar. x[0] = X, x[1] = Downscroll X, x[2] = Middlescroll X, x[3] = Downscroll + Middlescroll X.
	var x:Null<Array<Float>>;
	// Controls y of timebar. y[0] = Y, y[1] = Downscroll Y, y[2] = Middlescroll Y, y[3] = Downscroll + Middlescroll Y.
	var y:Null<Array<Float>>;
}

// The AverageText typedefs won't even be a nullable thing because why would you enable them and make them null anyway?
typedef ThemeSupportDef = {
	// Accuracy Text
	var AccuracyText:AverageText;
	var AccuracyTextEnabled:Null<Bool>;
	// Botplay Text
	var Botplay:AverageText;
	var BotplayEnabled:Null<Bool>;
	// Extra Text
	var ExtraText:Array<AverageText>;
	var ExtraTextEnabled:Null<Bool>;
	// Healthbar
	var Healthbar:Healthbar;
	var HealthbarEnabled:Null<Bool>;
	// Miss Text
	var MissText:AverageText;
	var MissTextEnabled:Null<Bool>;
	// NPS Text
	var NPSText:AverageText;
	var NPSTextEnabled:Null<Bool>;
	// Rating Style
	var RatingStyle:Null<String>;
	// Score Text
	var Score:AverageText;
	var ScoreEnabled:Null<Bool>;
	// Timebar
	var Timebar:Timebar;
	var TimebarEnabled:Null<Bool>;
	// Watermark Text
	var Watermark:AverageText;
	var WatermarkEnabled:Null<Bool>;
	// Working Directory (for assets)
	var WorkingDirectory:Null<String>;
}

// Latest Theme Support class.
class ThemeSupport {
	// Accuracy Text
	public static var AccuracyText:AverageText = {
		bouncetween: {
			enabled: false,
			scale: 1.2,
			type: "beathit"
		},
		center: [false, false],
		customization: {
			alignment: "CENTER",
			border: {
				color: "BLACK",
				size: 1,
				style: "OUTLINE"
			},
			color: "WHITE",
			embeddedfont: true,
			font: "VCR OSD Mono",
			fontsize: 8
		},
		fades: false,
		fromheight: false,
		fromwidth: false,
		scrolls: false,
		text: ["", "", "", ""],
		x: [0, 0, 0, 0],
		y: [0, 0, 0, 0]
	};
	public static var AccuracyTextEnabled:Bool = false;
	
	// Botplay Text
	public static var Botplay:AverageText = {
		bouncetween: {
			enabled: false,
			scale: 1.2,
			type: "beathit"
		},
		center: [false, false],
		customization: {
			alignment: "CENTER",
			border: {
				color: "BLACK",
				size: 1,
				style: "OUTLINE"
			},
			color: "WHITE",
			embeddedfont: true,
			font: "VCR OSD Mono",
			fontsize: 8
		},
		fades: false,
		fromheight: false,
		fromwidth: false,
		scrolls: false,
		text: ["", "", "", ""],
		x: [0, 0, 0, 0],
		y: [0, 0, 0, 0]
	};
	public static var BotplayEnabled:Bool = false;

	// Extra Text
	public static var ExtraText:Array<AverageText> = [];
	public static var ExtraTextEnabled:Bool = false;

	// Healthbar
	public static var Healthbar:Healthbar = {
		center: [true, false],
		colors: ["0xFFFF0000", "0xFF66FF33"],
		image: "healthBar",
		showIcons: [true, true],
		x: [0, 0, 0, 0],
		y: [648, 79, 648, 79]
	};
	public static var HealthbarEnabled:Bool = true;

	// Miss Text
	public static var MissText:AverageText = {
		bouncetween: {
			enabled: false,
			scale: 1.2,
			type: "beathit"
		},
		center: [false, false],
		customization: {
			alignment: "CENTER",
			border: {
				color: "BLACK",
				size: 1,
				style: "OUTLINE"
			},
			color: "WHITE",
			embeddedfont: true,
			font: "VCR OSD Mono",
			fontsize: 8
		},
		fades: false,
		fromheight: false,
		fromwidth: false,
		scrolls: false,
		text: ["", "", "", ""],
		x: [0, 0, 0, 0],
		y: [0, 0, 0, 0]
	};
	public static var MissTextEnabled:Bool = false;

	// NPS Text
	public static var NPSText:AverageText = {
		bouncetween: {
			enabled: false,
			scale: 1.2,
			type: "beathit"
		},
		center: [false, false],
		customization: {
			alignment: "CENTER",
			border: {
				color: "BLACK",
				size: 1,
				style: "OUTLINE"
			},
			color: "WHITE",
			embeddedfont: true,
			font: "VCR OSD Mono",
			fontsize: 8
		},
		fades: false,
		fromheight: false,
		fromwidth: false,
		scrolls: false,
		text: ["", "", "", ""],
		x: [0, 0, 0, 0],
		y: [0, 0, 0, 0]
	};
	public static var NPSTextEnabled:Bool = false;

	// Rating Style
	public static var RatingStyle:String = "RFE";

	// Score Text
	public static var Score:AverageText = {
		bouncetween: {
			enabled: false,
			scale: 1.2,
			type: "beathit"
		},
		center: [false, false],
		customization: {
			alignment: "CENTER",
			border: {
				color: "BLACK",
				size: 1,
				style: "OUTLINE"
			},
			color: "WHITE",
			embeddedfont: true,
			font: "VCR OSD Mono",
			fontsize: 8
		},
		fades: false,
		fromheight: false,
		fromwidth: false,
		scrolls: false,
		text: ["", "", "", ""],
		x: [0, 0, 0, 0],
		y: [0, 0, 0, 0]
	};
	public static var ScoreEnabled:Bool = true;

	// Theme's loaded?
	public static var ThemeLoaded:Bool = false;

	// Timebar
	public static var Timebar:Timebar = {
		center: [true, false],
		colors: ["0xFF000000", "0xFFFFFFFF"],
		image: "psychTimeBar",
		style: "psych",
		text: {
			bouncetween: {
				enabled: false,
				scale: 1.2,
				type: "beathit"
			},
			center: [false, false],
			customization: {
				alignment: "CENTER",
				border: {
					color: "BLACK",
					size: 1,
					style: "OUTLINE"
				},
				color: "WHITE",
				embeddedfont: true,
				font: "VCR OSD Mono",
				fontsize: 8
			},
			fades: false,
			fromheight: false,
			fromwidth: false,
			scrolls: false,
			text: ["", "", "", ""],
			x: [0, 0, 0, 0],
			y: [0, 0, 0, 0]
		},
		textOnly: false,
		x: [0, 0, 0, 0],
		y: [20, 675, 20, 675]
	};
	public static var TimebarEnabled:Bool = false;

	// Watermark Text
	public static var Watermark:AverageText = {
		bouncetween: {
			enabled: false,
			scale: 1.2,
			type: "beathit"
		},
		center: [false, false],
		customization: {
			alignment: "CENTER",
			border: {
				color: "BLACK",
				size: 1,
				style: "OUTLINE"
			},
			color: "WHITE",
			embeddedfont: true,
			font: "VCR OSD Mono",
			fontsize: 8
		},
		fades: false,
		fromheight: false,
		fromwidth: false,
		scrolls: false,
		text: ["", "", "", ""],
		x: [0, 0, 0, 0],
		y: [0, 0, 0, 0]
	};
	public static var WatermarkEnabled:Bool = true;

	// Working Directory
	public static var WorkingDirectory:String = "assets/shared/";

	// Map for text
	public static var Texts:Map<String, AverageText> = new Map<String, AverageText>();
	
	public static function loadTheme(theme:String) {
		// Reset the array
		ExtraText = [];

		// Reset the map
		Texts = null;
		Texts = new Map<String, AverageText>();
		
		// Theme is NOT loaded
		ThemeLoaded = false;

		// Put the texts in the map...
		Texts["AccuracyText"] = AccuracyText;
		Texts["Botplay"] = Botplay;
		Texts["MissText"] = MissText;
		Texts["NPSText"] = NPSText;
		Texts["Score"] = Score;
		Texts["Watermark"] = Watermark;

		// Load the file
		var rawJSONFile:String;

		rawJSONFile = Utilities.getFileContents('./assets/themes/$theme.json');
		while(!rawJSONFile.endsWith("}")) {
			rawJSONFile = rawJSONFile.substr(0, rawJSONFile.length - 1);
		}

		var JSON:ThemeSupportDef = cast Json.parse(rawJSONFile);

		// Accuracy Text
		if(JSON.AccuracyTextEnabled && JSON.AccuracyText != null) {
			setTextValues(AccuracyText, JSON.AccuracyText);
			AccuracyTextEnabled = true;
		} else {
			if(JSON.AccuracyTextEnabled)
				AccuracyTextEnabled = true;
			else
				AccuracyTextEnabled = false;
		}

		// Botplay Text
		if(JSON.BotplayEnabled && JSON.Botplay != null) {
			setTextValues(Botplay, JSON.Botplay);
			BotplayEnabled = true;
		} else {
			if(JSON.BotplayEnabled)
				BotplayEnabled = true;
			else
				BotplayEnabled = false;
		}

		// Extra Text
		if(JSON.ExtraTextEnabled && JSON.ExtraText != null) {
			for(i in 0...JSON.ExtraText.length) {
				ExtraText[i] = {
					bouncetween: {
						enabled: false,
						scale: 1.2,
						type: "beathit"
					},
					center: [false, false],
					customization: {
						alignment: "CENTER",
						border: {
							color: "BLACK",
							size: 1,
							style: "OUTLINE"
						},
						color: "WHITE",
						embeddedfont: true,
						font: "VCR OSD Mono",
						fontsize: 8
					},
					fades: false,
					fromheight: false,
					fromwidth: false,
					scrolls: false,
					text: ["", "", "", ""],
					x: [0, 0, 0, 0],
					y: [0, 0, 0, 0]
				};
				setTextValues(ExtraText[i], JSON.ExtraText[i]);
			}
			for(i in 0...ExtraText.length) {
				Texts["ExtraText" + i] = ExtraText[i];
			}
			ExtraTextEnabled = true;
		} else {
			if(JSON.ExtraTextEnabled)
				ExtraTextEnabled = true;
			else
				ExtraTextEnabled = false;
		}

		// Healthbar
		if(JSON.HealthbarEnabled && JSON.Healthbar != null) {
			setHealthbarValues(Healthbar, JSON.Healthbar);
		} else {
			if(JSON.HealthbarEnabled)
				HealthbarEnabled = true;
			else
				HealthbarEnabled = false;
		}

		// Miss Text
		if(JSON.MissTextEnabled && JSON.MissText != null) {
			setTextValues(MissText, JSON.MissText);
			MissTextEnabled = true;
		} else {
			if(JSON.MissTextEnabled)
				MissTextEnabled = true;
			else
				MissTextEnabled = false;
		}

		// NPS Text
		if(JSON.NPSTextEnabled && JSON.NPSText != null) {
			setTextValues(NPSText, JSON.NPSText);
			NPSTextEnabled = true;
		} else {
			if(JSON.NPSTextEnabled)
				NPSTextEnabled = true;
			else
				NPSTextEnabled = false;
		}

		// Rating Style
		if(JSON.RatingStyle != null)
			RatingStyle = JSON.RatingStyle;

		// Score Text
		if(JSON.ScoreEnabled && JSON.Score != null) {
			setTextValues(Score, JSON.Score);
			ScoreEnabled = true;
		} else {
			if(JSON.ScoreEnabled)
				ScoreEnabled = true;
			else
				ScoreEnabled = false;
		}

		// Timebar
		if(JSON.TimebarEnabled && JSON.Timebar != null) {
			setTimebarValues(Timebar, JSON.Timebar);
			TimebarEnabled = true;
		} else {
			if(JSON.TimebarEnabled)
				TimebarEnabled = true;
			else
				TimebarEnabled = false;
		}

		// Watermark Text
		if(JSON.WatermarkEnabled && JSON.Watermark != null) {
			setTextValues(Watermark, JSON.Watermark);
			WatermarkEnabled = true;
		} else {
			if(JSON.WatermarkEnabled)
				WatermarkEnabled = true;
			else
				WatermarkEnabled = false;
		}

		// Working Directory
		if(JSON.WorkingDirectory != null)
			WorkingDirectory = JSON.WorkingDirectory;

		// Theme is set up
		ThemeLoaded = true;

		// Get rid of all the unneccesary variables
		JSON = null;
		rawJSONFile = null;
	}

	// Set values
	static function setHealthbarValues(Healthbar:Healthbar, JSONHealthbar:Healthbar) {
		if(JSONHealthbar != null) {
			// Center
			if(JSONHealthbar.center == null)
				Healthbar.center = [true, false];
			else
				Healthbar.center = JSONHealthbar.center;
		
			// Colors
			if(JSONHealthbar.colors == null)
				Healthbar.colors = ["0xFFFF0000", "0xFF66FF33"];
			else
				Healthbar.colors = JSONHealthbar.colors;
		
			// Image
			if(JSONHealthbar.image == null)
				Healthbar.image = "healthBar";
			else
				Healthbar.image = JSONHealthbar.image;
		
			// Icons
			if(JSONHealthbar.showIcons == null)
				Healthbar.showIcons = [true, true];
			else
				Healthbar.showIcons = JSONHealthbar.showIcons;
		
			// X
			if(JSONHealthbar.x == null)
				Healthbar.x = [0, 0, 0, 0];
			else
				Healthbar.x = JSONHealthbar.x;
		
			// Y
			if(JSONHealthbar.y == null)
				Healthbar.y = [648, 79, 648, 79];
			else
				Healthbar.y = JSONHealthbar.y;
		}
	}

	static function setTimebarValues(Timebar:Timebar, JSONTimebar:Timebar) {
		if(JSONTimebar != null) {
			// Center
			if(JSONTimebar.center == null)
				Timebar.center = [true, false];
			else
				Timebar.center = JSONTimebar.center;

			// Colors
			if(JSONTimebar.colors == null)
				Timebar.colors = ["0xFF000000", "0xFFFFFFFF"];
			else
				Timebar.colors = JSONTimebar.colors;

			// Image
			if(JSONTimebar.image == null)
				Timebar.image = "psychTimeBar";
			else
				Timebar.image = JSONTimebar.image;

			// Style
			if(JSONTimebar.style == null)
				Timebar.style = "psych";
			else
				Timebar.style = JSONTimebar.style;

			// Text (this one doesn't even need to be null to be checked...)
			setTextValues(Timebar.text, JSONTimebar.text);

			// Text Only?
			if(JSONTimebar.textOnly == null)
				Timebar.textOnly = false;
			else
				Timebar.textOnly = JSONTimebar.textOnly;

			// X
			if(JSONTimebar.x == null)
				Timebar.x = [0, 0, 0, 0];
			else
				Timebar.x = JSONTimebar.x;

			// Y
			if(JSONTimebar.y == null)
				Timebar.y = [20, 675, 20, 675];
			else
				Timebar.y = JSONTimebar.y;
		}
	}

	// Thankfully this will work for all of the AverageTexts...
	static function setTextValues(TextDef:AverageText, JSONTextDef:AverageText) {
		if(JSONTextDef != null) {
			if(JSONTextDef.bouncetween != null) {
				// Bounce tween
				if(JSONTextDef.bouncetween.enabled == null)
					TextDef.bouncetween.enabled = false;
				else
					TextDef.bouncetween.enabled = JSONTextDef.bouncetween.enabled;

				if(JSONTextDef.bouncetween.scale == null)
					TextDef.bouncetween.scale = 1.2;
				else
					TextDef.bouncetween.scale = JSONTextDef.bouncetween.scale;

				if(JSONTextDef.bouncetween.type == null)
					TextDef.bouncetween.type = "beathit";
				else
					TextDef.bouncetween.type = JSONTextDef.bouncetween.type;
			} else {
				TextDef.bouncetween = {
					enabled: false,
					scale: 1.2,
					type: "beathit"
				}
			}

			// Center
			if(JSONTextDef.center == null)
				TextDef.center = [false, false];
			else
				TextDef.center = JSONTextDef.center;

			// Customization
			if(JSONTextDef.customization != null) {
				/// Alignment
				if(JSONTextDef.customization.alignment == null)
					TextDef.customization.alignment = "CENTER";
				else
					TextDef.customization.alignment = JSONTextDef.customization.alignment;

				if(JSONTextDef.customization.border != null) {
					/// Border
					if(JSONTextDef.customization.border.color == null)
						TextDef.customization.border.color = "BLACK";
					else
						TextDef.customization.border.color = JSONTextDef.customization.border.color;

					if(JSONTextDef.customization.border.size == null)
						TextDef.customization.border.size = 1;
					else
						TextDef.customization.border.size = JSONTextDef.customization.border.size;

					if(JSONTextDef.customization.border.style == null)
						TextDef.customization.border.style = "OUTLINE";
					else
						TextDef.customization.border.style = JSONTextDef.customization.border.style;
				} else {
					TextDef.customization.border = {
						color: "BLACK",
						size: 1,
						style: "OUTLINE"
					}
				}

				/// Color
				if(JSONTextDef.customization.color == null)
					TextDef.customization.color = "WHITE";
				else
					TextDef.customization.color = JSONTextDef.customization.color;

				/// Embedded font
				if(JSONTextDef.customization.embeddedfont == null)
					TextDef.customization.embeddedfont = true;
				else
					TextDef.customization.embeddedfont = JSONTextDef.customization.embeddedfont;

				/// Font
				if(JSONTextDef.customization.font == null)
					TextDef.customization.font = "VCR OSD Mono";
				else
					TextDef.customization.font = JSONTextDef.customization.font;

				/// Font size
				if(JSONTextDef.customization.fontsize == null)
					TextDef.customization.fontsize = 8;
				else
					TextDef.customization.fontsize = JSONTextDef.customization.fontsize;
			} else {
				TextDef.customization = {
					alignment: "CENTER",
					border: {
						color: "BLACK",
						size: 1,
						style: "OUTLINE"
					},
					color: "WHITE",
					embeddedfont: true,
					font: "VCR OSD Mono",
					fontsize: 8
				}
			}

			// Fades?
			if(JSONTextDef.fades == null)
				TextDef.fades = false;
			else
				TextDef.fades = JSONTextDef.fades;

			// From height?
			if(JSONTextDef.fromheight == null)
				TextDef.fromheight = false;
			else
				TextDef.fromheight = JSONTextDef.fromheight;

			// From width?
			if(JSONTextDef.fromwidth == null)
				TextDef.fromwidth = false;
			else
				TextDef.fromwidth = JSONTextDef.fromwidth;

			// Scrolling
			if(JSONTextDef.scrolls == null)
				TextDef.scrolls = false;
			else
				TextDef.scrolls = JSONTextDef.scrolls;

			// Text
			if(JSONTextDef.text == null)
				TextDef.text = ["", "", "", ""];
			else
				TextDef.text = JSONTextDef.text;

			// X
			if(JSONTextDef.x == null)
				TextDef.x = [0, 0, 0, 0];
			else
				TextDef.x = JSONTextDef.x;

			// Y
			if(JSONTextDef.y == null)
				TextDef.y = [0, 0, 0, 0];
			else
				TextDef.y = JSONTextDef.y;
		}
	}
}