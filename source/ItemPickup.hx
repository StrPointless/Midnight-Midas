class ItemPickup extends ModifiedFlxSprite
{
	public function new(daX:Float, daY:Float, Type:PickupType, ?graphic:FlxGraphic)
	{
		super(x, y, graphic);
	}
}

enum PickupType
{
	GOLDPICKUP;
}