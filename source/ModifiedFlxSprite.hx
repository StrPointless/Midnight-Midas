import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;

class ModifiedFlxSprite extends FlxSprite
{
	public var spriteTag:String = '';

	// got this one from unity
	public function new(_x:Float, _y:Float, ?_graphic:Null<FlxGraphicAsset>)
	{
		super(_x, _y, graphic);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
