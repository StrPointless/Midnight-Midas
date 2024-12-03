import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import openfl.Assets;

class LoadingState extends FlxState
{
	public var icon:FlxSprite;
	public var tipText:FlxText;
	public var loadingText:FlxText;
	public var canStart:Bool = false;
	public var bg:FlxSprite;

	public var topBlackBar:FlxSprite;
	public var bottomBlackBar:FlxSprite;

	public override function create()
	{
		super.create();

		var blackBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		blackBG.screenCenter();
		blackBG.scrollFactor.set();
		// add(blackBG);

		bg = new FlxSprite().loadGraphic("assets/images/loadingScreen/art/art0.png");
		bg.screenCenter();
		// bg.scrollFactor.set();
		bg.scale.set(1.15, 1.15);
		add(bg);

		topBlackBar = new FlxSprite().makeGraphic(1280, 500, FlxColor.BLACK);
		topBlackBar.scrollFactor.set();
		topBlackBar.screenCenter();
		topBlackBar.y -= 300;
		add(topBlackBar);

		bottomBlackBar = new FlxSprite().makeGraphic(1280, 500, FlxColor.BLACK);
		bottomBlackBar.scrollFactor.set();
		bottomBlackBar.screenCenter();
		bottomBlackBar.y += 200;
		add(bottomBlackBar);

		FlxTween.tween(topBlackBar, {y: topBlackBar.y - 200}, 2, {ease: FlxEase.expoOut, startDelay: 0.5});
		FlxTween.tween(bottomBlackBar, {y: bottomBlackBar.y + 300}, 2, {ease: FlxEase.expoOut, startDelay: 0.5});

		icon = new FlxSprite();
		icon.frames = FlxAtlasFrames.fromSparrow(Assets.getBitmapData("assets/images/loadingScreen/character.png"),
			Assets.getText("assets/images/loadingScreen/character.xml"));

		icon.animation.addByPrefix("idle", "loadingloop", 24, true);
		icon.animation.play("idle");
		icon.scrollFactor.set();
		icon.screenCenter();
		icon.scale.set(0.25, 0.25);
		icon.antialiasing = true;
		icon.y += 225;
		icon.x -= 700;
		add(icon);

		tipText = new FlxText(0, 0, 0, "-" + GameVariables.loadingScreenTips[FlxG.random.int(0, GameVariables.loadingScreenTips.length - 1)], 18);
		tipText.fieldWidth = 1000;
		tipText.fieldHeight = 200;
		tipText.scrollFactor.set();
		tipText.screenCenter();
		tipText.alignment = LEFT;
		tipText.y += 400;
		tipText.x -= 100;
		add(tipText);

		loadingText = new FlxText(0, 0, 0, "loading...", 16);
		loadingText.scrollFactor.set();
		loadingText.screenCenter();
		loadingText.x = tipText.x + 1100;
		loadingText.y = tipText.y;
		add(loadingText);

		FlxTween.tween(icon, {x: icon.x + 1250}, 2, {ease: FlxEase.expoOut, startDelay: 1});

		loadingText.y += 200;
		tipText.y += 200;

		FlxTween.tween(loadingText, {y: loadingText.y - 200}, 1, {ease: FlxEase.expoOut});
		FlxTween.tween(tipText, {y: tipText.y - 200}, 1, {ease: FlxEase.expoOut});

		GameVariables.levelCount++;
	}

	public override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.R)
			FlxG.resetState();
		if (FlxG.keys.justPressed.Y)
			doneLoading();

		if (!canStart && startTwn != null && startTwn.percent > 0.5)
		{
			canStart = true;
		}
		if (canStart && FlxG.keys.justPressed.ENTER)
		{
			if (startTwn != null)
				startTwn.percent = 1;
			FlxG.sound.play("assets/sounds/trueconfirm.ogg", 0.5);
			FlxG.camera.flash(FlxColor.WHITE, 1);
			FlxTween.tween(topBlackBar, {y: topBlackBar.y + 200}, 1, {ease: FlxEase.expoOut});
			FlxTween.tween(bottomBlackBar, {y: bottomBlackBar.y - 300}, 1, {ease: FlxEase.expoOut});
			FlxTween.tween(tipText, {y: tipText.y + 100, alpha: 0}, 1, {
				ease: FlxEase.expoIn,
				onComplete: function(twn:FlxTween)
				{
					if (GameVariables.levelCount == 1)
						FlxG.switchState(new DefenseTutorialState());
					else
						FlxG.switchState(new PlayState());
				}
			});
		}
		FlxG.camera.scroll.set((FlxG.mouse.screenX / 20), (FlxG.mouse.screenY / 20));
		super.update(elapsed);
	}

	var startTwn:FlxTween;

	public function doneLoading()
	{
		FlxTween.tween(loadingText, {y: loadingText.y + 15, alpha: 0}, 1, {ease: FlxEase.expoIn});
		FlxTween.tween(icon, {x: icon.x + 200}, 1, {ease: FlxEase.backIn});
		FlxTween.tween(tipText, {y: tipText.y + 100, alpha: 0}, 0.9, {ease: FlxEase.expoIn});
		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			tipText.alignment = CENTER;
			tipText.text = "- Press Space to Start -";
			tipText.size = 24;
			tipText.x += 100;
		});
		startTwn = FlxTween.tween(tipText, {y: tipText.y - 15, alpha: 1}, 1, {
			ease: FlxEase.expoOut,
			startDelay: 1,
			onComplete: function(twn:FlxTween)
			{
				// tipText.alignment = CENTER;
			}
		});
	}
}