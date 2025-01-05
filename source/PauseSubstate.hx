import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class PauseSubstate extends FlxSubState
{
	public var pausedText:FlxText;
	public var resume:FlxText;
	public var quit:FlxText;

	var bg:FlxSprite;

	public var curSelected:Int = 0;

	public var playedResumeSound:Bool = false;
	public var playedQuitSound:Bool = false;

	public var optionsGroup:Array<FlxText>;

	public var acceptCatch:Bool = false;

	public var controlType:String;

	public override function create()
	{
		bg = new FlxSprite().makeGraphic(1920, 1080, FlxColor.BLACK);
		bg.screenCenter();
		bg.alpha = 0.5;
		add(bg);
		pausedText = new FlxText(0, 0, 0, "PAUSED", 64);
		pausedText.screenCenter();
		pausedText.y -= 200;
		add(pausedText);

		resume = new FlxText(0, 0, 0, "Resume", 48);
		resume.screenCenter();
		resume.y += 0;
		add(resume);

		quit = new FlxText(0, 0, 0, "Quit", 48);
		quit.screenCenter();
		quit.y += 150;
		add(quit);
		resume.ID = 0;
		quit.ID = 1;

		optionsGroup = new Array<FlxText>();
		optionsGroup.push(resume);
		optionsGroup.push(quit);
		super.create();
		if (GameVariables.settings.cc_useController)
			controlType == "Controller";
		if (GameVariables.settings.cc_useKeyboardMouse)
			controlType == "KeyboardMouse";
		if (GameVariables.settings.cc_useKeyboard)
			controlType == "Keyboard";
	}

	public override function update(elapsed:Float)
	{
		FlxG.watch.addQuick("curSelect", curSelected);
		FlxG.watch.addQuick("ControlType", controlType);
		if (FlxG.mouse.justMoved)
			controlType = "KeyboardMouse";
		if (FlxG.keys.anyJustPressed([ANY]))
			controlType = "Keyboard";
		if (FlxG.gamepads.lastActive != null && FlxG.gamepads.anyInput())
			controlType = "Controller";

		if (GameVariables.settings.cc_useKeyboardMouse || controlType == "KeyboardMouse")
		{
			if (FlxG.mouse.overlaps(resume, this.camera))
			{
				resume.scale.set(1.1, 1.1);
				if (!playedResumeSound)
				{
					playedResumeSound = true;
					FlxG.sound.play("assets/sounds/scroll.ogg", 0.5);
				}
				if (FlxG.mouse.justPressed)
				{
					close();
					GameVariables.paused = false;
					GameVariables.timeFames = 0;
					FlxG.state.persistentUpdate = true;
					FlxG.sound.play("assets/sounds/trueconfirm.ogg", 0.5);
				}
			}
			else
			{
				playedResumeSound = false;
				resume.scale.set(FlxMath.lerp(resume.scale.x, 1, 0.05), FlxMath.lerp(resume.scale.y, 1, 0.05));
			}
			if (FlxG.mouse.overlaps(quit, this.camera))
			{
				quit.scale.set(1.1, 1.1);
				if (!playedQuitSound)
				{
					playedQuitSound = true;
					FlxG.sound.play("assets/sounds/scroll.ogg", 0.5);
				}
				if (FlxG.mouse.justPressed)
				{
					FlxG.sound.play("assets/sounds/trueconfirm.ogg", 0.5);
					this.camera.fade(FlxColor.BLACK, 1);
					FlxG.camera.fade(FlxColor.BLACK, 1, function()
					{
						GameVariables.playerHP = 4;
						GameVariables.levelCount = 0;
						GameVariables.timeFames = 0;
						GameVariables.incompleteTime = true;
						FlxG.switchState(new MainMenuState());
					});
				}
			}
			else
			{
				playedQuitSound = false;
				quit.scale.set(FlxMath.lerp(quit.scale.x, 1, 0.05), FlxMath.lerp(quit.scale.y, 1, 0.05));
			}
		}
		if (GameVariables.settings.cc_useKeyboard || controlType == "Keyboard")
		{
			if (FlxG.keys.anyJustPressed([S, DOWN]))
				changeSelection(1);
			if (FlxG.keys.anyJustPressed([W, UP]))
				changeSelection(-1);
			for (i in optionsGroup)
			{
				if (i.ID == curSelected)
				{
					i.scale.set(1.2, 1.2);
				}
				else
				{
					i.scale.set(FlxMath.lerp(i.scale.x, 1, 0.09), FlxMath.lerp(i.scale.y, 1, 0.09));
				}
			}
			if (FlxG.keys.anyJustPressed([ENTER, C]))
				doSelection();

			if (FlxG.keys.anyJustPressed([BACKSPACE, ESCAPE]))
			{
				close();
				GameVariables.paused = false;
				GameVariables.timeFames = 0;
				FlxG.state.persistentUpdate = true;
				FlxG.sound.play("assets/sounds/trueconfirm.ogg", 0.5);
			}
		}
		if (GameVariables.settings.cc_useController || controlType == "Controller")
		{
			if (FlxG.gamepads.lastActive.analog.justMoved.LEFT_STICK_Y && FlxG.gamepads.lastActive.getYAxis(LEFT_ANALOG_STICK) < 0)
				changeSelection(-1);
			if (FlxG.gamepads.lastActive.analog.justMoved.LEFT_STICK_Y && FlxG.gamepads.lastActive.getYAxis(LEFT_ANALOG_STICK) > 0)
				changeSelection(1);

			if (FlxG.gamepads.lastActive.justPressed.DPAD_DOWN)
				changeSelection(1);
			if (FlxG.gamepads.lastActive.justPressed.DPAD_UP)
				changeSelection(-1);

			for (i in optionsGroup)
			{
				if (i.ID == curSelected)
				{
					i.scale.set(1.2, 1.2);
				}
				else
				{
					i.scale.set(FlxMath.lerp(i.scale.x, 1, 0.09), FlxMath.lerp(i.scale.y, 1, 0.09));
				}
			}
			if (FlxG.gamepads.lastActive.justPressed.A || FlxG.gamepads.lastActive.justPressed.START)
				doSelection();

			if (FlxG.gamepads.lastActive.justPressed.B || FlxG.gamepads.lastActive.justPressed.BACK)
			{
				close();
				GameVariables.paused = false;
				GameVariables.timeFames = 0;
				FlxG.state.persistentUpdate = true;
				FlxG.sound.play("assets/sounds/trueconfirm.ogg", 0.5);
			}
		}

		super.update(elapsed);
	}
	public function doSelection()
	{
		if (acceptCatch)
		{
			switch (curSelected)
			{
				case 1:
					FlxG.sound.play("assets/sounds/trueconfirm.ogg", 0.5);
					this.camera.fade(FlxColor.BLACK, 1);
					FlxG.camera.fade(FlxColor.BLACK, 1, function()
					{
						GameVariables.playerHP = 4;
						GameVariables.levelCount = 0;
						GameVariables.timeFames = 0;
						GameVariables.incompleteTime = true;
						FlxG.switchState(new MainMenuState());
					});
				case 0:
					close();
					GameVariables.paused = false;
					GameVariables.timeFames = 0;
					FlxG.state.persistentUpdate = true;
					FlxG.sound.play("assets/sounds/trueconfirm.ogg", 0.5);
			}
		}
		if (!acceptCatch)
			acceptCatch = true;
	}

	public function changeSelection(sec:Int = 0)
	{
		curSelected += sec;
		if (curSelected > optionsGroup.length - 1)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = optionsGroup.length - 1;

		FlxG.sound.play("assets/sounds/scroll.ogg", 0.5);
	}

}