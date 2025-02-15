import flixel.input.keyboard.FlxKey;

class GameVariables
{
	public static var initialized:Bool = false;
	public static var levelCount:Int = 0;
	public static var defenseEnemyCount1:Int = 25;
	public static var defenseEnemyCount2:Int = 50;
	public static var defenseEnemyCount3:Int = 75;
	public static var playerHP:Int = 4;
	public static var timeFames:Int = 0;
	public static var timeDisplay:String = "";

	public static var leveltimeFames:Int = 0;
	public static var leveltimeDisplay:String = "";
	public static var paused:Bool = false;
	public static var incompleteTime:Bool = false;

	public static var settings:PlayerSettings;

	public static var loadingScreenTips:Array<String> = [
		"Pressing space twice allows you to double Jump! You should know this by now...",
		"The original version of this game was made in 8 days! It wasn't that great",
		"2ND PLACE, 2ND PLACE, WE TAKE THOSEEEEEEE!!!",
		"Hi Mom, Hi Dad",
		"Heh",
		"Wild",
		"Eclipse knows the speedrun techs.",
		"OPTIMAL, IT NEEDS TO BE OPTIMAL!",
		"King: . -.",
		"Friday Night Funkin'"
	];
	public static function resetSettings()
	{
		var tempSet:PlayerSettings = {
			sr_bestTime: "0.00.00",
			sr_lastTime: "0.00.00",
			gp_skipMenus: false,
			gp_tips: true,
			gp_subtitles: true,
			gp_flashingLights: true,
			gp_staticCamera: false,
			cc_reset: R,
			cc_useKeyboard: false,
			useBackgroundShaders: true,
			cc_useController: false,
			cc_useKeyboardMouse: true,
			speedrunMode: false
		}
		settings = tempSet;
		initialized = true;
		trace("RESET SETTINGS");
	}

	public static function setControlType(controlType:ControlType)
	{
		trace("setting control type to " + controlType);
		switch (controlType)
		{
			case Controller:
				GameVariables.settings.cc_useController = true;
				GameVariables.settings.cc_useKeyboard = false;
				GameVariables.settings.cc_useKeyboardMouse = false;
			case Fullkeyboard:
				GameVariables.settings.cc_useController = false;
				GameVariables.settings.cc_useKeyboard = true;
				GameVariables.settings.cc_useKeyboardMouse = false;
			case KeyboardMouse:
				GameVariables.settings.cc_useController = false;
				GameVariables.settings.cc_useKeyboard = false;
				GameVariables.settings.cc_useKeyboardMouse = true;
		}
	}
}

typedef PlayerSettings =
{
	var sr_bestTime:String;
	var sr_lastTime:String;

	var gp_subtitles:Bool;
	var gp_tips:Bool;
	var gp_skipMenus:Bool;
	var gp_staticCamera:Bool;
	var gp_flashingLights:Bool;

	var cc_reset:FlxKey;

	var cc_useKeyboard:Bool;
	var cc_useKeyboardMouse:Bool;
	var cc_useController:Bool;

	var useBackgroundShaders:Bool;
	var speedrunMode:Bool;

}
enum ControlType
{
	Controller;
	Fullkeyboard;
	KeyboardMouse;
}
