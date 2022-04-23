package;

#if sys
import sys.io.File;
import sys.FileSystem;
#else
import js.html.XMLHttpRequest;
import js.html.XMLHttpRequestResponseType;
import js.html.Response;
import js.html.FileReader;
#end

using StringTools;

class Utilities {
    #if html5
		public static function checkFileExists(uh:String):Bool {
    		var bloob = new XMLHttpRequest();
    		bloob.open('GET', uh, false);
    		bloob.send(null);
    		if(bloob.status == 404) {
    			return false;
    		} else if(bloob.statusText == "Not Found") {
    			return false;
    		} else {
    			return true;
    		}
    		return false;
    	}

		// this sadly has to be the same for now idk how to use js
		public static function checkFolderExists(uh:String):Bool {
			return false;
		}

    	public static function getFileContents(uh:String):String {
    		var bloob = new XMLHttpRequest();
    		bloob.open('GET', uh, false);
    		bloob.send(null);
    		return bloob.responseText;
	    }

		public static function readFolder(uh:String):Array<String> {
			return [""];
		}
		
	#end
    #if desktop
		public static function checkFileExists(uh:String):Bool {
			if(FileSystem.exists(uh))
				return true;
			else
				return false;
			return false;
		}

		// basically the same as file checking lol
		public static function checkFolderExists(uh:String):Bool {
			if(FileSystem.exists(uh) && FileSystem.isDirectory(uh))
				return true;
			return false;
		}

        public static function getFileContents(uh:String):String {
            if(FileSystem.exists(uh)) {
                return File.getContent(uh);
            }
            return null;
        }

		public static function readFolder(folderToRead:String):Array<String> {
			var returnArray:Array<String> = [];
			if(FileSystem.exists(folderToRead)) {
				for(file in FileSystem.readDirectory(folderToRead)) {
					returnArray.push(file);
				}
			}
			return returnArray;
		}
    #end

	public static function calculateThemeRating(accuracy:Float, ratingStyle:String):String {
		switch(ratingStyle) {
			case "leather":
				if(accuracy < 4)
					return "G";
				else if(accuracy >= 5 && accuracy < 10)
					return "F";
				else if(accuracy >= 10 && accuracy < 50)
					return "E";
				else if(accuracy >= 50 && accuracy < 65)
					return "D";
				else if(accuracy >= 65 && accuracy < 70)
					return "C";
				else if(accuracy >= 70 && accuracy < 80)
					return "B";
				else if(accuracy >= 80 && accuracy < 85)
					return "B+";
				else if(accuracy >= 85 && accuracy < 89)
					return "A";
				else if(accuracy >= 89 && accuracy < 92)
					return "AA";
				else if(accuracy >= 92 && accuracy < 95)
					return "S";
				else if(accuracy >= 95 && accuracy < 98)
					return "SS";
				else if(accuracy >= 98 && accuracy < 100)
					return "SSS";
				else if(accuracy == 100)
					return "SSSS";
			case "psych":
				if(accuracy < 20)
					return "You Suck!";
				else if(accuracy >= 20 && accuracy < 40)
					return "Awful";
				else if(accuracy >= 40 && accuracy < 50)
					return "Bad";
				else if(accuracy >= 50 && accuracy < 60)
					return "Bruh";
				else if(accuracy >= 60 && accuracy < 69)
					return "Meh";
				else if(accuracy >= 69 && accuracy < 70)
					return "Nice";
				else if(accuracy >= 70 && accuracy < 80)
					return "Good";
				else if(accuracy >= 80 && accuracy < 90)
					return "Great";
				else if(accuracy >= 90 && accuracy < 100)
					return "Sick!";
				else if(accuracy == 100)
					return "Perfect!!";
			case "kadeold" | "kadenew":
				if(accuracy < 60)
					return "D";
				else if(accuracy >= 60 && accuracy < 70)
					return "C";
				else if(accuracy >= 70 && accuracy < 80)
					return "B";
				else if(accuracy >= 80 && accuracy < 85)
					return "A";
				else if(accuracy >= 85 && accuracy < 90)
					return "A.";
				else if(accuracy >= 90 && accuracy < 93)
					return "A:";
				else if(accuracy >= 93 && accuracy < 96.5)
					return "AA";
				else if(accuracy >= 96.5 && accuracy < 99)
					return "AA.";
				else if(accuracy >= 99 && accuracy < 99.7)
					return "AA:";
				else if(accuracy >= 99.7 && accuracy < 99.8)
					return "AAA";
				else if(accuracy >= 99.8 && accuracy < 99.9)
					return "AAA.";
				else if(accuracy >= 99.9 && accuracy < 99.95)
					return "AAA:";
				else if(accuracy >= 99.95 && accuracy < 99.97)
					return "AAAA";
				else if(accuracy >= 99.97 && accuracy < 99.98)
					return "AAAA.";
				else if(accuracy >= 99.98 && accuracy < 99.99)
					return "AAAA:";
				else if(accuracy >= 99.99)
					return "AAAAA";
			case "forever":
				if(accuracy < 66)
					return "F";
				else if(accuracy >= 66 && accuracy < 71)
					return "E";
				else if(accuracy >= 71 && accuracy < 76)
					return "D";
				else if(accuracy >= 76 && accuracy < 81)
					return "C";
				else if(accuracy >= 81 && accuracy < 86)
					return "B";
				else if(accuracy >= 86 && accuracy < 91)
					return "A";
				else if(accuracy >= 91 && accuracy < 96)
					return "S";
				else if(accuracy >= 96)
					return "S+";
			case "tr1ngle":
				if(accuracy < 21)
					return "F";
				else if(accuracy >= 21 && accuracy < 41)
					return "D";
				else if(accuracy >= 41 && accuracy < 61)
					return "C";
				else if(accuracy >= 61 && accuracy < 71)
					return "B";
				else if(accuracy >= 71 && accuracy < 86)
					return "A";
				else if(accuracy >= 86 && accuracy < 91)
					return "S-";
				else if(accuracy >= 91 && accuracy < 96)
					return "S";
				else if(accuracy >= 96 && accuracy < 100)
					return "S+";
				else if(accuracy == 100)
					return "S++";
		}
		return "N/A";
	}

	public static function checkIfIsNormalChar(character:String) {
		switch(character) {
			case "bf" | "bf-car" | "bf-christmas" | "bf-old" | "bf-pixel":
				return true;
			case "dad" | "dad-sfw":
				return true;
			case "face":
				return true;
			case "gf":
				return true;
			case "mom" | "mom-car" | "mom-car-sfw":
				return true;
			case "monster" | "monster-christmas":
				return true;
			case "pahaze" | "redwick-pahaze":
				return true;
			case "parents-christmas" | "parents-christmas-sfw":
				return true;
			case "pico":
				return true;
			case "spooky":
				return true;
			case "senpai" | "senpai-angry" | "spirit":
				return true;
			case "tankman":
				return true;
			default:
				return false;
		}
		return false;
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