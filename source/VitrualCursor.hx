import flixel.FlxG;
import flixel.FlxSprite;

class VitrualCursor extends FlxSprite
{
	public var cursorSpeed:Float = 10;

	public function new(x:Float, y:Float)
	{
		super(x, y, "assets/images/icons/vCursorIcon.png");
		scale.set(0.25, 0.25);
		updateHitbox();
	}

	public override function update(elapsed:Float)
	{
		super.update(elapsed);
		setPosition(x + FlxG.gamepads.lastActive.getXAxis(RIGHT_ANALOG_STICK) * cursorSpeed,
			y + FlxG.gamepads.lastActive.getYAxis(RIGHT_ANALOG_STICK) * cursorSpeed);
	}
}