import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class DefenseTutorialState extends FlxState
{
	public var delay:Float = 100;

	public var image1:ModifiedFlxSprite;
	public var image2:ModifiedFlxSprite;
	public var image3:ModifiedFlxSprite;

	public var spawnImages:Bool;

	public var image1ShakeTmr:Float;
	public var image2ShakeTmr:Float;
	public var image3ShakeTmr:Float;

	public var image1OgPoint:FlxPoint;
	public var image2OgPoint:FlxPoint;
	public var image3OgPoint:FlxPoint;

	public var image1Shake:Bool = false;
	public var image2Shake:Bool = false;
	public var image3Shake:Bool = false;

	public var levelTitle:FlxText;
	public var levelDescription:FlxText;
	public var levelHint:FlxText;
	public var pressText:FlxText;

	public var canEnd:Bool = false;

	public override function create()
	{
		super.create();

		image1 = new ModifiedFlxSprite(0, 0);
		image1.loadGraphic("assets/images/defenseSS3.png");
		image1.antialiasing = true;
		image1.scale.set(0.75, 0.75);
		image1.x += 100;
		image1.y += 100;
		image1.angle = -5;
		image1.alpha = 0;
		add(image1);

		image2 = new ModifiedFlxSprite(0, 0);
		image2.loadGraphic("assets/images/defenseSS2.png");
		image2.antialiasing = true;
		image2.scale.set(0.75, 0.75);
		image2.x += 600;
		image2.y += 100;
		image2.angle = 5;
		image2.alpha = 0;
		add(image2);

		image3 = new ModifiedFlxSprite(0, 0);
		image3.loadGraphic("assets/images/defenseSS1.png");
		image3.antialiasing = true;
		image3.scale.set(0.85, 0.85);
		image3.x += 300;
		image3.y += 50;
		image3.angle = 0;
		image3.alpha = 0;
		add(image3);

		image1OgPoint = new FlxPoint(image1.x, image1.y);
		image2OgPoint = new FlxPoint(image2.x, image2.y);
		image3OgPoint = new FlxPoint(image3.x, image3.y);

		levelTitle = new FlxText(425, 25, "Dark Defense", 48);
		levelTitle.y -= 100;
		levelTitle.alpha = 0;
		add(levelTitle);

		levelDescription = new FlxText(200, 500,
			"Dark enemies will be coming from the top, left, and right side of the screen. You can attack them with Left Click (Left Mouse Button).", 24);
		levelDescription.fieldWidth = 800;
		levelDescription.fieldHeight = 200;
		levelDescription.alignment = CENTER;

		levelDescription.alpha = 0;
		levelDescription.y += 100;
		add(levelDescription);

		levelHint = new FlxText(400, 600, "There is a boss at the end", 24);
		levelHint.fieldWidth = 400;
		levelHint.fieldHeight = 100;
		levelHint.alignment = CENTER;
		levelHint.alpha = 0.5;

		levelHint.alpha = 0;
		levelHint.y += 100;
		add(levelHint);

		pressText = new FlxText(350, 650, 'Press "Enter" to Start', 30);
		pressText.fieldWidth = 500;
		pressText.fieldHeight = 100;
		pressText.alignment = CENTER;
		// pressText.alpha = 0.5;
		pressText.y += 100;
		pressText.alpha = 0;
		add(pressText);
	}

	public override function update(elapsed:Float)
	{
		if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.R)
			FlxG.resetState();
		if (delay > 0)
			delay--;
		if (delay < 1 && !spawnImages)
		{
			spawnImages = true;
			doImages();
		}

		if (spawnImages)
		{
			if (image1.scale.x < 0.75)
				image1.scale.set(FlxMath.lerp(image1.scale.x, 0.75, 0.08), FlxMath.lerp(image1.scale.y, 0.75, 0.08));
			if (image2.scale.x < 0.75)
				image2.scale.set(FlxMath.lerp(image2.scale.x, 0.75, 0.08), FlxMath.lerp(image2.scale.y, 0.75, 0.08));
			if (image3.scale.x < 0.85)
				image3.scale.set(FlxMath.lerp(image3.scale.x, 0.75, 0.08), FlxMath.lerp(image3.scale.y, 0.75, 0.08));

			image1.angle = FlxMath.lerp(image1.angle, -5, 0.05);
			image2.angle = FlxMath.lerp(image2.angle, 5, 0.05);
			image3.angle = FlxMath.lerp(image3.angle, 0, 0.05);

			image1.setColorValues(FlxMath.lerp(image1.customColor.brightness, 0, 0.05), 1, 1);
			image2.setColorValues(FlxMath.lerp(image2.customColor.brightness, 0, 0.05), 1, 1);
			image3.setColorValues(FlxMath.lerp(image3.customColor.brightness, 0, 0.05), 1, 1);

			image1.updateShaderColorValues();
			image2.updateShaderColorValues();
			image3.updateShaderColorValues();

			FlxG.camera.angle = FlxMath.lerp(FlxG.camera.angle, 0, 0.05);
			FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, 1, 0.05);
		}

		if (image1Shake)
		{
			if (image1ShakeTmr > 0)
			{
				image1ShakeTmr--;
				image1.setPosition(image1OgPoint.x, image1OgPoint.y);
				image1.setPosition(image1.x + FlxG.random.int(-5, 5), image1.y + FlxG.random.int(-5, 5));
			}
			else
				image1Shake = false;
		}

		if (image2Shake)
		{
			if (image2ShakeTmr > 0)
			{
				image2ShakeTmr--;
				image2.setPosition(image2OgPoint.x, image2OgPoint.y);
				image2.setPosition(image2.x + FlxG.random.int(-5, 5), image2.y + FlxG.random.int(-5, 5));
			}
			else
				image2Shake = false;
		}

		if (image3Shake)
		{
			if (image3ShakeTmr > 0)
			{
				image3ShakeTmr--;
				image3.setPosition(image3OgPoint.x, image3OgPoint.y);
				image3.setPosition(image3.x + FlxG.random.int(-5, 5), image3.y + FlxG.random.int(-5, 5));
			}
			else
				image3Shake = false;
		}
		if (canEnd && FlxG.keys.justPressed.ENTER)
		{
			FlxG.camera.flash();
			FlxG.sound.play("assets/sounds/trueconfirm.ogg", 0.5);
			canEnd = false;
			FlxTween.tween(image1, {alpha: 0}, 1);
			FlxTween.tween(image2, {alpha: 0}, 1);
			FlxTween.tween(image3, {alpha: 0}, 1);
			FlxTween.tween(levelTitle, {alpha: 0}, 2, {ease: FlxEase.expoOut});
			FlxTween.tween(levelDescription, {alpha: 0}, 2, {ease: FlxEase.expoOut, startDelay: 0.05});
			FlxTween.tween(levelHint, {alpha: 0}, 2, {ease: FlxEase.expoOut, startDelay: 0.25});
			FlxTween.tween(pressText, {alpha: 0}, 2, {
				ease: FlxEase.expoOut,
				startDelay: 0.5,
				onComplete: function(twn:FlxTween)
				{
					FlxG.switchState(new PlayState());
				}
			});
		}
	}

	public function doImages()
	{
		image1.alpha = 1;
		image1.scale.set(1, 1);
		FlxG.sound.play("assets/sounds/scroll.ogg", 0.5);

		new FlxTimer().start(0.25, function(tmr:FlxTimer)
		{
			image1.scale.set(0.65, 0.65);
			image1.resetColorValues();
			image1.setColorValues(1, 1, 1);
			image1.angle = -7;
			image1ShakeTmr = 10;
			image1Shake = true;
			FlxG.camera.angle = -2;
			FlxG.camera.zoom += 0.1;
		});

		new FlxTimer().start(0.35, function(tmr:FlxTimer)
		{
			image2.alpha = 1;
			image2.scale.set(1, 1);
			FlxG.sound.play("assets/sounds/scroll.ogg", 0.5);
		});

		new FlxTimer().start(0.55, function(tmr:FlxTimer)
		{
			image2.scale.set(0.65, 0.65);
			image2.resetColorValues();
			image2.setColorValues(1, 1, 1);
			image2.angle = 7;
			image2ShakeTmr = 10;
			image2Shake = true;
			FlxG.camera.angle = 2;
			FlxG.camera.zoom += 0.1;
		});

		new FlxTimer().start(0.75, function(tmr:FlxTimer)
		{
			image3.alpha = 1;
			image3.scale.set(1, 1);
			FlxG.sound.play("assets/sounds/scroll.ogg", 0.5);
		});

		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			image3.scale.set(0.65, 0.65);
			image3.resetColorValues();
			image3.setColorValues(1, 1, 1);
			image3ShakeTmr = 10;
			image3Shake = true;
			FlxG.camera.angle = 0;
			FlxG.camera.zoom += 0.1;
			FlxG.camera.shake(0.01, 0.1);
			FlxG.camera.flash(FlxColor.WHITE);
			FlxG.sound.play("assets/sounds/trueconfirm.ogg", 0.5);

			FlxTween.tween(levelTitle, {y: levelTitle.y + 100, alpha: 1}, 2, {ease: FlxEase.expoOut});
			FlxTween.tween(levelDescription, {y: levelDescription.y - 100, alpha: 1}, 2, {ease: FlxEase.expoOut, startDelay: 0.05});
			FlxTween.tween(levelHint, {y: levelHint.y - 100, alpha: 0.5}, 2, {ease: FlxEase.expoOut, startDelay: 0.25});
			FlxTween.tween(pressText, {y: pressText.y - 100, alpha: 1}, 2, {
				ease: FlxEase.expoOut,
				startDelay: 0.5,
				onComplete: function(twm:FlxTween)
				{
					canEnd = true;
				}
			});
		});
	}
}