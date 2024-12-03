package;

import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public static var fmem:FMEM = new FMEM(10, 10, 0xffffff);
	public function new()
	{
		super();
		addChild(new FlxGame(1280, 720, MainMenuState));
		addChild(fmem);
	}
}
