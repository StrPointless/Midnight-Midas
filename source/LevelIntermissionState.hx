import flixel.FlxG;
import flixel.FlxState;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class LevelIntermissionState extends FlxState
{
	public var levelText:FlxText;
	public var levelNumberText:FlxText;

	public var pressText:FlxText;

	public var levelNumberPosition:Float;
	public var doneTween:Bool = false;

	public override function create()
	{
		FlxG.camera.bgColor = FlxColor.BLACK;
		super.create();

		levelText = new FlxText(0, 0, 0, "Level", 64);
		levelText.screenCenter();
		levelText.y -= 250;
		levelText.x -= 15;
		levelText.alpha = 0;
		levelText.y -= 100;
		add(levelText);

		levelNumberText = new FlxText(0, 0, 0, "" + GameVariables.levelCount, 64 * 4);
		levelNumberText.screenCenter();
		levelNumberPosition = levelNumberText.y;
		levelNumberText.alpha = 0;
		add(levelNumberText);

		pressText = new FlxText(0, 0, 0, 'Press "ENTER" to continue ', 48);
		pressText.screenCenter();
		pressText.y += 250;
		pressText.x -= 25;

		pressText.y += 100;
		pressText.alpha = 0;
		add(pressText);

		FlxTween.tween(pressText, {y: pressText.y - 100, alpha: 1}, 2, {ease: FlxEase.expoOut, startDelay: 1.1});
		FlxTween.tween(levelNumberText, {alpha: 1}, 2, {ease: FlxEase.expoOut, startDelay: 1});
		FlxTween.tween(levelText, {y: levelText.y + 100, alpha: 1}, 2, {
			ease: FlxEase.expoOut,
			startDelay: 1.1,
			onComplete: function(twn:FlxTween)
			{
				doneTween = true;
				addLevelCount();
			}
		});
	}

	public override function update(elapsed:Float)
	{
		FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, 1, 0.05);

		if (doneTween)
			levelNumberText.y = FlxMath.lerp(levelNumberText.y, levelNumberPosition, 0.05);
		if (FlxG.keys.justPressed.ENTER)
		{
			FlxG.sound.play("assets/sounds/trueconfirm.ogg", 0.5);
			doneTween = false;
			FlxG.camera.zoom = 1.25;
			var cloneText = levelNumberText.clone();
			cloneText.setPosition(levelNumberText.x, levelNumberText.y);
			add(cloneText);
			cloneText.alpha = 0.45;
			FlxTween.tween(cloneText, {'scale.x': 1.5, 'scale.y': 1.5, alpha: 0}, 1, {ease: FlxEase.expoOut});
			FlxTween.tween(pressText, {y: pressText.y + 100, alpha: 0}, 2, {ease: FlxEase.expoOut, startDelay: 1.1});
			FlxTween.tween(levelNumberText, {alpha: 0}, 2, {ease: FlxEase.expoOut, startDelay: 1});
			FlxTween.tween(levelText, {y: levelText.y - 100, alpha: 0}, 2, {
				ease: FlxEase.expoOut,
				startDelay: 1.1,
				onComplete: function(twn:FlxTween)
				{
					if (GameVariables.levelCount == 1)
						FlxG.switchState(new DefenseTutorialState());
					else
						FlxG.switchState(new PlayState());
				}
			});
		}

		super.update(elapsed);
	}

	public function addLevelCount()
	{
		FlxG.sound.play("assets/sounds/scroll.ogg", 0.5);
		FlxG.camera.zoom = 1.15;
		GameVariables.levelCount++;

		levelNumberText.y += 100;
		levelNumberText.text = GameVariables.levelCount + "";
	}
}