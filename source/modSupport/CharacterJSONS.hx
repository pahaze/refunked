package modSupport;

typedef CharacterJSON = {
	var Anims:Array<CharacterAnimation>;
	var CharacterImage:String;
	var CharacterScale:Float;
	var CharacterPositionOffsets:Null<Array<Float>>;
	var CharacterCameraOffsets:Null<Array<Int>>;
	var CharacterFlipX:Bool;
	var CharacterAntialiasing:Bool;
}

typedef CharacterAnimation = {
	var Animation:String;
	var AnimPrefix:String;
	var AnimFPS:Int;
	var AnimLOOP:Bool;
	var AnimIndices:Array<Int>;
	var Offsets:Array<Int>;
}