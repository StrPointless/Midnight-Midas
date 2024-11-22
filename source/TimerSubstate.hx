import flixel.FlxSubState;
import flixel.math.FlxMath;
import flixel.text.FlxText;

class TimerSubstate extends FlxSubState
{
	public var timerDisplay:FlxText;
	public var levelTimerDisplay:FlxText;

	public override function create()
	{
		super.create();
		timerDisplay = new FlxText(-400, 400, 0, "", 12);
		timerDisplay.fieldWidth = 700;
		timerDisplay.fieldHeight = 100;
		timerDisplay.alignment = CENTER;
		timerDisplay.cameras = this.cameras;
		timerDisplay.screenCenter();
		timerDisplay.x -= 500;
		timerDisplay.y += 375;
		add(timerDisplay);

		levelTimerDisplay = new FlxText(-400, 400, 0, "", 12);
		levelTimerDisplay.fieldWidth = 700;
		levelTimerDisplay.fieldHeight = 100;
		levelTimerDisplay.alignment = CENTER;
		levelTimerDisplay.cameras = this.cameras;
		levelTimerDisplay.screenCenter();
		levelTimerDisplay.x += 500;
		levelTimerDisplay.y += 375;
		add(levelTimerDisplay);
	}

	public override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (!GameVariables.paused)
		{
			GameVariables.timeFames++;
			GameVariables.timeDisplay = "Time: "
				+ Std.string((GameVariables.timeFames / 3600) % 3600).split(".")[0]
				+ ":"
				+ FlxMath.roundDecimal((GameVariables.timeFames / 60) % 60, 0)
				+ "."
				+ (GameVariables.timeFames % 60);
			timerDisplay.text = GameVariables.timeDisplay;

			GameVariables.leveltimeFames++;
			GameVariables.leveltimeDisplay = "Time: "
				+ Std.string((GameVariables.leveltimeFames / 3600) % 3600).split(".")[0]
				+ ":"
				+ FlxMath.roundDecimal((GameVariables.leveltimeFames / 60) % 60, 0)
				+ "."
				+ (GameVariables.leveltimeFames % 60);
			levelTimerDisplay.text = GameVariables.leveltimeDisplay;
		}
		trace(GameVariables.timeDisplay);
	}
}