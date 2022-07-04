package;

using StringTools;

class ModSupport {
	public static var mods:Array<String> = [];
	public static var modsDirectories:Map<String, String> = new Map<String, String>();
	public static var modsLoaded:Int = 0;
	
	public static function addNormalModDir(i:Int) {
		modsDirectories["mods"] = "mods/";
		mods[i] = "mods";
		modsLoaded++;
	}

	public static function checkIfNormModFolder(folder:String):Bool {
		switch(folder) {
			case "chars":
				return true;
			case "data":
				return true;
			case "images":
				return true;
			// In case somebody tries to be funny
			case "mods":
				return true;
			case "notes":
				return true;
			case "songs":
				return true;
			case "sounds":
				return true;
			case "stages":
				return true;
			// wip, but still
			case "uistyles":
				return true;
			default:
				return false;
		}
		return false;
	}

	public static function loadModsFolders() {
		resetModStuff();
		var folders:Array<String> = Utilities.readFolder("./mods");
		for(i in 0...folders.length) {
			if(Utilities.checkFolderExists("./mods/" + folders[i]) && !checkIfNormModFolder(folders[i])) {
				modsDirectories[folders[i]] = "mods/" + folders[i] + "/";
				mods[i] = folders[i];
				modsLoaded++;
			}
		}
		addNormalModDir(folders.length + 1);
	}

	public static function resetModStuff() {
		mods = [];
		modsDirectories = null;
		modsDirectories = new Map<String, String>();
		modsLoaded = 0;
	}
}