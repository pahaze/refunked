package;

#if sys
	import sys.io.File;
	import sys.FileSystem;
#else
	import js.html.DOMParser;
	import js.html.HTMLCollection;
	import js.html.SupportedType;
	import js.html.XMLHttpRequest;
#end

using StringTools;

class Utilities {
	#if sys
		public static function checkFileExists(filePath:String):Bool {
			return (FileSystem.exists(filePath) && !FileSystem.isDirectory(filePath));
		}

		public static function checkFolderExists(folderPath:String):Bool {
			return (FileSystem.exists(folderPath) && FileSystem.isDirectory(folderPath));
		}

		public static function getFileContents(filePath:String):String {
			return File.getContent(filePath);
		}

		public static function getFolderContents(folderPath:String):Array<String> {
			var returnArray:Array<String> = [];
			if(checkFolderExists(folderPath)) {
				for(file in FileSystem.readDirectory(folderPath)) {
					returnArray.push(file);
				}
			}
			return returnArray;
		}
	#else
		public static function checkFileExists(filePath:String):Bool {
			var bloob = new XMLHttpRequest();
			bloob.open('GET', filePath, false);
			bloob.send(null);
			if(bloob.status == 404 || bloob.statusText == "Not Found")
				return false;
			else
				return true;
		}

		// Since web is the same...
		public static function checkFolderExists(folderPath:String):Bool {
			return checkFileExists(folderPath);
		}

		public static function getFileContents(filePath:String):String {
			var bloob = new XMLHttpRequest();
			bloob.open('GET', filePath, false);
			bloob.send(null);
			return bloob.responseText;
		}

		// This is awful. I HATE HAXE!!!
		public static function readFolder(folderPath:String):Array<String> {
			var bloob = new XMLHttpRequest();
			bloob.open('GET', folderPath, false);
			bloob.send(null);
			var bloobDOMParser = new DOMParser();
			var bloobPreParse = bloobDOMParser.parseFromString(bloob.responseText, SupportedType.TEXT_HTML).getElementsByTagName("td");
			var bloobPostParse:Array<HTMLCollection> = [];
			var bloobArray:Array<String> = [];
			for (i in 0...bloobPreParse.length) {
				bloobPostParse.push(bloobPreParse[i].getElementsByTagName("a"));
				for(j in 0...bloobPostParse.length) {
					if(bloobPostParse[i][j] != null) {
						if(bloobPostParse[i][j].innerHTML != null) {
							bloobArray.push(bloobPostParse[i][j].innerHTML);
						}
					}
				}
			}
			if(bloobArray.contains("../"))
				bloobArray.remove("../");
			for(i in 0...bloobArray.length) {
				while(bloobArray[i].endsWith("/")) {
					bloobArray[i] = bloobArray[i].substr(0, bloobArray[i].length - 1);
				}
				// Safety in case of files in folder. This is already messy enough...
				bloobArray[i] = StringTools.replace(bloobArray[i], ".", "");
			}
			return bloobArray;
		}
	#end

	public static function calculateComboRating(ratings:Array<Int>, misses:Int, accuracy:Float):String {
		var ratingToReturn = "???";

		/**
		 * Ratings:
		 * ratings[0] - Sicks
		 * ratings[1] - Goods
		 * ratings[2] - Bads
		 * ratings[3] - Awfuls
		 */

		if(ratings[0] > 0)
			ratingToReturn = "SFC";

		if(ratings[1] > 0)
			ratingToReturn = "GFC";

		if(ratings[2] > 0)
			ratingToReturn = "FC";

		if(ratings[3] > 0)
			ratingToReturn = "AFC";

		if(misses > 0) {
			if(misses < 11)
				ratingToReturn = "SDCB";
			else
				ratingToReturn = "Clear";
		}

		if(accuracy >= 69 && accuracy < 70)
			ratingToReturn = "Nice";

		return ratingToReturn;
	}

	public static function checkGf(stage:String):String {
		switch(stage) {
			case "limo":
				return "gf-car";
			case "mall" | "mallEvil":
				return "gf-christmas";
			case "school" | "schoolMad" | "schoolEvil":
				return "gf-pixel";
			default:
				return "gf";
		}
		return "gf";
	}

	public static function checkStage(songName:String, songStage:String):String {
		if(songStage != null && songStage != "") {
			return songStage;
		} else {
			if(songName != null && songName != "") {
				switch(songName.toLowerCase()) {
					case "bopeebo" | "bopeebo-sfw" | "dadbattle" | "dadbattle-sfw" | "fresh" | "fresh-sfw":
						return "stage";
					case "monster" | "south" | "spookeez":
						return "spooky";
					case "blammed" | "philly" | "pico":
						return "philly";
					case "chillflow" | "high" | "high-sfw" | "milf" | "mombattle" | "satin-panties":
						return "limo";
					case "cocoa" | "cocoa-sfw" | "eggnog" | "eggnog-sfw":
						return "mall";
					case "winter-horrorland":
						return "mallEvil";
					case "senpai":
						return "school";
					case "thorns":
						return "schoolEvil";
					case "roses":
						return "schoolMad";
					default:
						return "stage";
				}
			}
		}
		return "stage";
	}
}