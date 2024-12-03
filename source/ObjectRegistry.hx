class ObjectRegistry
{
	public var objects:Array<GameObjectData>;

	public function new()
	{
		objects = new Array<GameObjectData>();
	}

	public static function createObjectData()
	{
		var data:GameObjectData = {
			hitboxData: [],
			spritePath: "",
			e_isEvent: false,
			e_eventCalled: false,
			s_text: "",
			canBeGolden: false,
			objectTag: ""
		}
		return data;
	}
}

typedef GameObjectData =
{
	var hitboxData:Array<Array<Float>>; // hitbox 1 -> width height x y;
	var spritePath:String; // Path to image File;

	// Event
	var e_isEvent:Bool;
	var e_eventCalled:Bool;

	// subtitle
	var s_text:String;

	var canBeGolden:Bool;

	var objectTag:String;
}