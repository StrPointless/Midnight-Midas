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
		super.create();
	}

	public override function update(elapsed:Float)
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
		super.update(elapsed);
	}
}