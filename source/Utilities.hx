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

class Utilities {
    #if html5
    	public static function getFileContents(uh:String):String {
    		var bloob = new XMLHttpRequest();
    		bloob.open('GET', uh, false);
    		bloob.send(null);
    		return bloob.responseText;
	    }

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
	#end
    #if desktop
        public static function getFileContents(uh:String):String {
            if(FileSystem.exists(uh)) {
                return File.getContent(uh);
            }
            return null;
        }
		
		public static function checkFileExists(uh:String):Bool {
			if(FileSystem.exists(uh))
				return true;
			else
				return false;
			return false;
		}
    #end
}