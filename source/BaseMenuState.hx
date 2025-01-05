import flixel.FlxG;
import flixel.FlxState;

class BaseMenuState extends FlxState
{
	public var curControlType:String;
	public var activeMouse:Bool = false;

	public override function create()
	{
		trace("Building A MenuState");
		super.create();
	}

	public override function update(elapsed:Float)
	{
		if (FlxG.keys.anyJustPressed([ANY]))
			curControlType = "Keyboard";
		if (FlxG.gamepads.lastActive != null && FlxG.gamepads.lastActive.anyInput())
			curControlType = "Controller";

		switch (curControlType)
		{
			case "ArrowKeys":
				updateArrowKeys();
			case "Mouse":
				updateMouse();
			case "Controller":
				updateController();
		}

		super.update(elapsed);
	}

	public function updateArrowKeys()
	{
		// Arrow Logic
	}

	public function updateMouse()
	{
		// Mouse Logic
	}

	public function updateController()
	{
		// Controller Logic
	}
}