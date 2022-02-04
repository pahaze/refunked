using StringTools;

class StageStuff {
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