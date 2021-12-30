using StringTools;

class StageStuff {
    public static function checkStage(songName:String, songStage:String):String {
        if(songStage != null && songStage != "") {
            return songStage;
        } else {
            if(songName != null && songName != "") {
                switch(songName.toLowerCase()) {
                    case "bopeebo" | "dadbattle" | "dadbattle-sfw" | "fresh":
                        return "stage";
                    case "monster" | "south" | "spookeez":
                        return "spooky";
                    case "blammed" | "philly" | "pico":
                        return "philly";
                    case "high" | "milf" | "mombattle" | "satin-lovers" | "satin-panties":
                        return "limo";
                    case "coacoa" | "eggnog":
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