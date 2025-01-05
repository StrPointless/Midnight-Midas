import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;

class Level
{
	public var daData:LevelData;

	var objects:Array<ModifiedFlxSprite>;

	public function loadLevel(group:FlxTypedGroup<ModifiedFlxSprite>)
	{
		for (i in daData.objects)
		{
			var sprite = new ModifiedFlxSprite(i.position[0], i.position[1], i.graphicPath);
			sprite.scale.set(i.scale[0], i.scale[1]);
			group.add(sprite);
		}
	}
}

typedef LevelData =
{
	public var objects:Array<ObjectData>;
	public var type:String;
}

typedef ObjectData =
{
	public var graphicPath:String;
	public var position:Array<Float>;
	public var scale:Array<Float>;
	public var xFlip:Bool;
	public var yFlip:Bool;
	public var tint:Float;
	public var solid:Bool;
	public var daScroll:Array<Float>;
	public var scrollSet:Bool;
	public var daAngle:Float;
	public var text:String;
	public var zLevel:Int;
}