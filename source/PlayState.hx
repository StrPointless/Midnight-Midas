package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.addons.editors.ogmo.FlxOgmoLoader;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxSplash;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import openfl.Assets;
import openfl.filters.ShaderFilter;

using StringTools;

class PlayState extends FlxState
{
	public var camGame:FlxCamera;
	public var camHUD:FlxCamera;

	public var envObjects:FlxTypedGroup<ModifiedFlxSprite>;
	public var fgObjects:FlxTypedGroup<ModifiedFlxSprite>;
	public var spikesObjs:FlxTypedGroup<ModifiedFlxSprite>;
	public var darkObjects:FlxTypedGroup<ModifiedFlxSprite>;
	public var camFollow:FlxObject;

	public var player:Player;
	public var playerRefPoint:FlxPoint;

	var map:FlxOgmo3Loader;
	var walls:FlxTilemap;

	public var delay:Float = 100;

	public var levelOffset:FlxPoint;
	public var topBar:FlxSprite;
	public var bottomBar:FlxSprite;
	public var plrDead:Bool = false;
	public var deathTmr:Float = 20;

	public var openingT:FlxTween;
	public var openingB:FlxTween;

	public var gameShader:TestShader;
	public var gameSaturationValue:Float = 1;
	public var gameContrastValue:Float = 1;

	public var cameraAngle:Float = 0;

	public var justFocused:Bool;
	public var curMusicTime:Float;
	public var curMusicState:String = "normal";

	public var levelData:Level.LevelData;

	public var shiftCamera:Bool = false;
	public var holdCam:Bool = false;
	public var camStopEventObj:ModifiedFlxSprite;

	public var defenseMiddle:ModifiedFlxSprite;

	public var gameTime:Float = 6500;
	public var gradient:ModifiedFlxSprite;

	public var defenseEnemies:FlxTypedGroup<DarkEnemy>;

	public var nextEnemySpawnTime:Float;
	public var collidingEnemy:DarkEnemy;
	public var defenseDeathTmr:Float = 10;
	public var combo:Int = 0;

	public var comboText:ModifiedFlxSprite;
	public var firstNumber:ModifiedFlxSprite;
	public var secondNumber:ModifiedFlxSprite;

	public var comboShakeAmout:Float;
	public var comboOffset:Float;

	public var comboTextPos:FlxPoint;
	public var firstNumberPos:FlxPoint;
	public var secondNumberPos:FlxPoint;

	public var comboActive:Bool = false;

	public var canSpawnEnemies:Bool = true;
	public var finale:Bool = false;
	public var bgDim:ModifiedFlxSprite;
	public var defaultTimeScale:Float = 1.0;
	public var enemiesToSpawn:Int;

	public var focusBarBG:ModifiedFlxSprite;
	public var focusBar:FlxBar;
	public var uiBar:ModifiedFlxSprite;
	public var uiIcon:ModifiedFlxSprite;
	public var goldGroup:Array<ModifiedFlxSprite>;

	public var focusAmount:Float;
	public var daFocusAmount:Int = 400;
	public var bossHits:Int = 0;

	public var subtitleText:FlxText;
	public var activeSubtitle:Bool;
	public var justChangedSubtitle:Bool;

	public var subtitleOGPosition:FlxPoint;

	public var curSubtitleField:ModifiedFlxSprite;
	public var win:Bool = false;

	override public function create()
	{
		if (GameVariables.playerHP == 0)
		{
			GameVariables.playerHP = 4;
			GameVariables.levelCount = 0;
			FlxG.switchState(new MainMenuState());
		}
		FlxG.sound.cache("assets/music/stageplayloop1.ogg");
		FlxG.sound.cache("assets/music/stageloopslow1.ogg");

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camGame];

		levelOffset = new FlxPoint(1200, 800);
		camFollow = new FlxObject();
		var bg = new FlxSprite().loadGraphic("assets/images/bg0.png");
		bg.scrollFactor.set(0.2, 0.2);
		bg.screenCenter();
		bg.x += 500;
		bg.y += 200;
		bg.scale.set(2, 2);
		add(bg);

		envObjects = new FlxTypedGroup<ModifiedFlxSprite>();
		add(envObjects);
		spikesObjs = new FlxTypedGroup<ModifiedFlxSprite>();
		add(spikesObjs);
		darkObjects = new FlxTypedGroup<ModifiedFlxSprite>();
		add(darkObjects);

		bgDim = new ModifiedFlxSprite(0, 0);
		bgDim.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bgDim.scale.set(2, 2);
		bgDim.scrollFactor.set();
		bgDim.alpha = 0;
		add(bgDim);

		defenseEnemies = new FlxTypedGroup<DarkEnemy>();
		add(defenseEnemies);

		// add(walls);

		// IDEA: ENEMIES COME FROM LEFT AND RIGHT, SOME FALL FROM THE TOP OR OBJECTS, CHAIN COMBOS TO FILL METER FASTER. Longer you take, darker it gets.

		// 2ND IDEA: LONGER TIME SPENT IN A LEVEL DARKER IT GETS

		player = new Player(0,0);
		// player.makeGraphic(50,100, FlxColor.WHITE);
		player.antialiasing = true;
		// player.updateHitbox();
		player.y -= 400;
		player.screenCenter();
		// player.color = 0xFFFFFF;
		player.gameRef = this;
		add(player);

		fgObjects = new FlxTypedGroup<ModifiedFlxSprite>();
		add(fgObjects);

		FlxG.camera.bgColor = FlxColor.GRAY;

		var daStuff:Level.LevelData = Json.parse(Assets.getText("assets/data/level" + GameVariables.levelCount + ".json"));
		levelData = daStuff;

		for (i in daStuff.objects)
		{
			if (i.graphicPath != "playerRef" && i.graphicPath != "camShiftEvent" && i.graphicPath != "black" && i.graphicPath != "camStopEvent"
				&& i.graphicPath != "levelEndEvent" && i.graphicPath != "defenseMiddle" && i.graphicPath != "subtitlePart")
			{
				var sprite = new ModifiedFlxSprite(i.position[0] + levelOffset.x, i.position[1] + levelOffset.y);
				sprite.loadGraphic(i.graphicPath);
				sprite.scale.set(i.scale[0], i.scale[1]);
				sprite.setColorValues(0, 1, 1);
				sprite.updateHitbox();
				sprite.flipX = i.xFlip;
				sprite.ogDataCopy = i;
				sprite.flipY = i.yFlip;
				sprite.angle = i.daAngle;
				sprite.ogPath = i.graphicPath;
				sprite.antialiasing = true;
				sprite.customColor.brightness = i.tint;
				sprite.immovable = true;
				if (i.daScroll[0] != 1 && !i.scrollSet)
					i.scrollSet = true;
				if (i.scrollSet)
					sprite.scrollFactor.set(i.daScroll[0], i.daScroll[1]);
				sprite.solid = i.solid;
				if (i.graphicPath.endsWith("spikes0.png")
					|| i.graphicPath.endsWith("spikes1.png")
					|| i.graphicPath.endsWith("darkness.png"))
					spikesObjs.add(sprite);
				else if (i.graphicPath.endsWith("_DARK.png"))
					darkObjects.add(sprite);
				else
					envObjects.add(sprite);
			}
			else if (i.graphicPath == "camShiftEvent")
			{
				var sprite = new ModifiedFlxSprite(i.position[0] + levelOffset.x, i.position[1] + levelOffset.y);
				sprite.makeGraphic(100, 100, FlxColor.BLUE);
				sprite.scale.set(i.scale[0], i.scale[1]);
				sprite.setColorValues(0, 1, 1);
				sprite.updateHitbox();
				sprite.flipX = i.xFlip;
				sprite.flipY = i.yFlip;
				sprite.ogDataCopy = i;
				sprite.spriteTag = "camEvent";
				sprite.ogPath = i.graphicPath;
				sprite.antialiasing = true;
				sprite.customColor.brightness = i.tint;
				sprite.solid = false;
				sprite.immovable = true;
				sprite.alpha = 0;
				envObjects.add(sprite);
			}
			else if (i.graphicPath == "black")
			{
				var sprite = new ModifiedFlxSprite(i.position[0] + levelOffset.x, i.position[1] + levelOffset.y);
				sprite.makeGraphic(100, 100, FlxColor.BLACK);
				sprite.scale.set(i.scale[0], i.scale[1]);
				sprite.setColorValues(0, 1, 1);
				sprite.updateHitbox();
				sprite.flipX = i.xFlip;
				sprite.ogDataCopy = i;
				sprite.flipY = i.yFlip;
				sprite.ogPath = i.graphicPath;
				sprite.antialiasing = true;
				sprite.customColor.brightness = i.tint;
				sprite.solid = false;
				sprite.immovable = true;
				envObjects.add(sprite);
			}
			else if (i.graphicPath == "camStopEvent")
			{
				var sprite = new ModifiedFlxSprite(i.position[0] + levelOffset.x, i.position[1] + levelOffset.y);
				sprite.makeGraphic(100, 100, FlxColor.YELLOW);
				sprite.scale.set(i.scale[0], i.scale[1]);
				sprite.setColorValues(0, 1, 1);
				sprite.updateHitbox();
				sprite.flipX = i.xFlip;
				sprite.ogDataCopy = i;
				sprite.flipY = i.yFlip;
				sprite.ogPath = i.graphicPath;
				sprite.antialiasing = true;
				sprite.customColor.brightness = i.tint;
				sprite.solid = false;
				sprite.immovable = true;
				sprite.alpha = 0;
				envObjects.add(sprite);
			}
			else if (i.graphicPath == "levelEndEvent" || i.graphicPath == "defenseMiddle" || i.graphicPath == "subtitlePart")
			{
				var sprite = new ModifiedFlxSprite(i.position[0] + levelOffset.x, i.position[1] + levelOffset.y);
				sprite.makeGraphic(100, 100, FlxColor.GREEN);
				sprite.scale.set(i.scale[0], i.scale[1]);
				sprite.setColorValues(0, 1, 1);
				sprite.updateHitbox();
				sprite.flipX = i.xFlip;
				sprite.ogDataCopy = i;
				sprite.flipY = i.yFlip;
				sprite.subText = i.text;
				sprite.ogPath = i.graphicPath;
				sprite.antialiasing = true;
				sprite.customColor.brightness = i.tint;
				sprite.solid = false;
				sprite.immovable = true;
				sprite.alpha = 0;
				envObjects.add(sprite);
			}
			else if (i.graphicPath == "playerRef")
			{
				player.setPosition(i.position[0] + levelOffset.x, i.position[1] + levelOffset.y - 400);
			}
		}

		


		super.create();
		gameShader = new TestShader();
		gameShader.saturation.value = [0];
		gameShader.contrast.value = [0];
		gameShader.brightness.value = [0];

		camGame.filters = [new ShaderFilter(gameShader)];
		FlxG.camera.zoom = 0.75;
		FlxG.camera.setScrollBounds(null, null, null, null);
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		if (levelData.type != "defense")
			FlxG.sound.playMusic("assets/music/stageplayloop1.ogg", 0);
		if (levelData.type == "defense")
			FlxG.sound.playMusic("assets/music/defensenorm.ogg", 0);
		FlxG.sound.music.fadeIn(1, 0, 1);

		gradient = new ModifiedFlxSprite(0, 0);
		gradient.loadGraphic("assets/images/darkGradient.png");
		gradient.scrollFactor.set(0, 0);
		gradient.screenCenter();
		fgObjects.add(gradient);

		comboText = new ModifiedFlxSprite(0, 0);
		comboText.cameras = [camHUD];
		comboText.frames = FlxAtlasFrames.fromSparrow("assets/images/comboText.png", Assets.getText("assets/images/comboText.xml"));
		comboText.animation.addByPrefix("idle", "comboText", 12, true);
		comboText.scale.set(0.35, 0.35);
		comboText.animation.play("idle");

		firstNumber = new ModifiedFlxSprite(55, 55);
		firstNumber.cameras = [camHUD];
		firstNumber.frames = FlxAtlasFrames.fromSparrow("assets/images/numbers.png", Assets.getText("assets/images/numbers.xml")); // THE NUMBERS MASON!
		firstNumber.animation.addByIndices("numbers", "Number", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9], "", 0, true);
		firstNumber.scale.set(0.35, 0.35);
		firstNumber.animation.play("numbers");

		secondNumber = new ModifiedFlxSprite(firstNumber.x + 65, firstNumber.y - 25);
		secondNumber.cameras = [camHUD];
		secondNumber.frames = FlxAtlasFrames.fromSparrow("assets/images/numbers.png", Assets.getText("assets/images/numbers.xml")); // THE NUMBERS MASON! again
		secondNumber.animation.addByIndices("numbers", "Number", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9], "", 0, true);
		secondNumber.scale.set(0.35, 0.35);
		secondNumber.animation.play("numbers");

		firstNumber.x += comboOffset;
		secondNumber.x += comboOffset;
		comboText.x += comboOffset;

		firstNumberPos = new FlxPoint(firstNumber.x, firstNumber.y);
		secondNumberPos = new FlxPoint(secondNumber.x, secondNumber.y);
		comboTextPos = new FlxPoint(comboText.x, comboText.y);

		comboText.alpha = 0;
		firstNumber.alpha = 0;
		secondNumber.alpha = 0;

		comboText.y += 100;
		firstNumber.y += 100;
		secondNumber.y += 100;

		add(comboText);
		add(firstNumber);
		add(secondNumber);

		uiIcon = new ModifiedFlxSprite(0, 0);
		uiIcon.loadGraphic("assets/images/characterIcon.png");
		uiIcon.scale.set(0.5, 0.5);
		uiIcon.x -= 50;
		uiIcon.y -= 50;
		uiIcon.cameras = [camHUD];
		add(uiIcon);
		uiIcon.alpha = 0;
		FlxTween.tween(uiIcon, {alpha: 1}, 2, {startDelay: 1});

		uiBar = new ModifiedFlxSprite(0, 0);
		uiBar.loadGraphic("assets/images/uiBar.png");
		uiBar.scale.set(0.5, 0.5);
		uiBar.cameras = [camHUD];
		uiBar.y += 75;
		add(uiBar);
		uiBar.alpha = 0;
		FlxTween.tween(uiBar, {alpha: 1}, 2, {startDelay: 1});

		goldGroup = new Array<ModifiedFlxSprite>();
		for (i in 0...4)
		{
			var goldBar = new ModifiedFlxSprite(xPos, uiBar.y - 80);
			goldBar.loadGraphic("assets/images/uiGold.png");
			goldBar.scale.set(0.5, 0.5);
			goldBar.cameras = [camHUD];
			add(goldBar);
			switch (GameVariables.playerHP)
			{
				case 4:

				case 3:
					if (i == 3)
						goldBar.alpha = 0.25;
				case 2:
					if (i == 3 || i == 2)
						goldBar.alpha = 0.25;
				case 1:
					if (i == 3 || i == 2 || i == 1)
						goldBar.alpha = 0.25;
			}

			xPos += 80;

			goldGroup.push(goldBar);
			var ogAlpha = goldBar.alpha;
			goldBar.alpha = 0;
			FlxTween.tween(goldBar, {alpha: ogAlpha}, 2, {startDelay: 1});
		}

		focusBarBG = new ModifiedFlxSprite(0, 0);
		focusBarBG.loadGraphic("assets/images/uiFocusBar.png");
		focusBarBG.scale.set(0.5, 0.5);
		focusBarBG.cameras = [camHUD];
		focusBarBG.y += 100;
		add(focusBarBG);
		focusBarBG.alpha = 0;
		FlxTween.tween(focusBarBG, {alpha: 1}, 2, {startDelay: 1});

		focusBar = new FlxBar(focusBarBG.x + 4, focusBarBG.y + 4, LEFT_TO_RIGHT, Std.int(focusBarBG.width - 8), Std.int(focusBarBG.height - 8), this,
			'focusAmount', 0, 2);
		focusBar.createFilledBar(0xFF0E2CA0, 0xFF5C92EB);
		// focusBar.createFilledBar(0x0E2CA0, 0x5C92EB);
		focusBar.scale.set(0.5, 0.5);
		focusBar.cameras = [camHUD];
		// healthBar
		add(focusBar);
		focusBar.alpha = 0;
		FlxTween.tween(focusBar, {alpha: 1}, 2, {startDelay: 1});

		subtitleText = new FlxText(0, 0, 0, "Test Text", 48);
		subtitleText.fieldWidth = 500;
		subtitleText.fieldHeight = 100;
		subtitleText.setFormat(null, 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, false);
		subtitleText.cameras = [camHUD];
		subtitleText.screenCenter();
		subtitleText.y += 300;
		add(subtitleText);

		subtitleOGPosition = new FlxPoint(subtitleText.x, subtitleText.y);
		subtitleText.y += 200;

		switch (GameVariables.levelCount)
		{
			case 1:
				enemiesToSpawn = GameVariables.defenseEnemyCount1;
			case 3:
				enemiesToSpawn = GameVariables.defenseEnemyCount2;
			case 5:
				enemiesToSpawn = GameVariables.defenseEnemyCount3;
		}

		topBar = new FlxSprite().makeGraphic(FlxG.width, Std.int(FlxG.height / 1.5), FlxColor.BLACK);
		topBar.cameras = [camHUD];
		topBar.screenCenter();
		topBar.y -= 210;
		add(topBar);
		bottomBar = new FlxSprite().makeGraphic(FlxG.width, Std.int(FlxG.height / 1.5), FlxColor.BLACK);
		bottomBar.cameras = [camHUD];
		bottomBar.screenCenter();
		bottomBar.y += 210;
		add(bottomBar);

		openingT = FlxTween.tween(topBar, {y: topBar.y - 500}, 2, {ease: FlxEase.expoOut, startDelay: 1});
		openingB = FlxTween.tween(bottomBar, {y: bottomBar.y + 500}, 2, {ease: FlxEase.expoOut, startDelay: 1});
	}

	var xPos:Float = 125;

	override public function update(elapsed:Float)
	{
		if (daFocusAmount <= 400)
			daFocusAmount++;

		focusAmount = FlxMath.remapToRange(daFocusAmount, 400, 0, 2, 0);
		focusBar.value = FlxMath.lerp(focusBar.value, focusAmount, 0.05);

		FlxG.watch.addQuick("gameTime", gameTime);
		FlxG.watch.addQuick("focus", daFocusAmount);
		gameShader.brightness.value[0] = FlxMath.remapToRange(gameTime, 6500, 0, 0, -1);
		gradient.alpha = FlxMath.remapToRange(gameTime, 6500, 0, 0, 1);
		if (gameTime > 1)
			gameTime--;

		if (FlxG.sound.music != null)
			curMusicTime = FlxG.sound.music.time;
		gameShader.saturation.value[0] = FlxMath.lerp(gameShader.saturation.value[0], gameSaturationValue, 0.05);
		gameShader.contrast.value[0] = FlxMath.lerp(gameShader.contrast.value[0], gameContrastValue, 0.05);
		camGame.angle = FlxMath.lerp(camGame.angle, cameraAngle, 0.05);
		if (player._isGrounded && !plrDead && !player.focus && levelData.type != "defense")
			FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, 0.65, 0.05);
		if (!player._isGrounded && !plrDead && !player.focus && levelData.type != "defense")
			FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, 0.75, 0.05);

		if (levelData.type == "defense")
		{
			if (finale)
				FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, 0.75, 0.05);
			else
				FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, 0.55, 0.05);
			FlxG.camera.angle = FlxMath.lerp(FlxG.camera.angle, 0, 0.05);
			if (defenseMiddle != null)
				camFollow.setPosition(defenseMiddle.x + (FlxG.mouse.screenX / 20), defenseMiddle.y + FlxG.mouse.screenY / 20);
		}
		if (FlxG.keys.justPressed.TAB)
			FlxG.switchState(new LevelEditorState(levelData));
		//restart the game
		if (FlxG.keys.justPressed.U)
		{
			player.setColorValues(1, 0, 50);
		}
		if(FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.R)
			FlxG.resetState();

		player._isGrounded = player.isTouching(DOWN);

		if (player.isTouching(LEFT))
			player._curWallLocation = LEFT;
		else if (player.isTouching(RIGHT))
			player._curWallLocation = RIGHT;
		else
			player._curWallLocation = NONE;
		super.update(elapsed);
		player._wallSliding = (player.isTouching(RIGHT) && !player._isGrounded || player.isTouching(LEFT) && !player._isGrounded) ? true : false;
		// trace(player._wallSliding);

		if (player.left && !plrDead && !player.focus && levelData.type != "defense")
			FlxG.camera.angle = FlxMath.lerp(FlxG.camera.angle, 1, 0.05);
		if (player.right && !plrDead && !player.focus && levelData.type != "defense")
			FlxG.camera.angle = FlxMath.lerp(FlxG.camera.angle, -1, 0.05);

		FlxG.camera.follow(camFollow, LOCKON, 0.05);
		if (!plrDead && !holdCam && levelData.type != "defense" && !player.focus)
			camFollow.setPosition((!shiftCamera) ? player.x + 300 : player.x - 300, player.y - 50);

		FlxG.worldBounds.set(player.x, player.y, FlxG.width * 5, FlxG.height * 5);
		if (player.overlaps(spikesObjs) && !plrDead)
		{
			deathTmr--;
			if (deathTmr < 1)
				deathSequence();
		}
		else if (player.overlaps(darkObjects) && !plrDead)
		{
			deathSequence();
		}
		else
			deathTmr = 20;
		if (plrDead)
		{
			player._canMove = false;
			player._hasGravity = false;
			player.immovable = true;
			player.setGravity(false, 0, 0);
		}
		FlxG.collide(envObjects, player);
		FlxG.collide(darkObjects, player);
		// FlxG.collide(walls, player);

		if (gameTime < 3000)
			deathSequence();

		FlxG.timeScale = (player.focus) ? 0.3 : defaultTimeScale;
		if (player.focus && !plrDead)
		{
			gameSaturationValue = 1.25;
			gameContrastValue = 1.25;
			cameraAngle = 2;
			FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, 0.75, 0.05);
			camFollow.setPosition((!shiftCamera) ? player.x + 300 + (FlxG.mouse.screenX / 2) : player.x - 300, player.y - 50 + (FlxG.mouse.screenY / 2));
		}
		if (!player.focus && !plrDead)
		{
			gameSaturationValue = 1;
			gameContrastValue = 1;
			cameraAngle = 0;
		}
		if (justFocused != player.focus)
		{
			justFocused = player.focus;
			changeMusic();
		}

		for (i in darkObjects.members)
		{
			if (FlxG.mouse.overlaps(i) && FlxG.mouse.pressedRight && player.focus)
			{
				i.scale.set(FlxMath.lerp(i.scale.x, i.ogDataCopy.scale[0] + 0.25, 0.1), FlxMath.lerp(i.scale.y, i.ogDataCopy.scale[1] + 0.25, 0.1));
				i.setColorValues(FlxMath.lerp(i.customColor.brightness, 0.5, 0.05), 1, 1.5);
				i.color = 0xFF1EFF00;
			}
			if (!FlxG.mouse.overlaps(i) && player.focus)
			{
				i.scale.set(FlxMath.lerp(i.scale.x, i.ogDataCopy.scale[0] + 0, 0.025), FlxMath.lerp(i.scale.y, i.ogDataCopy.scale[1] + 0, 0.025));
				i.setColorValues(FlxMath.lerp(i.customColor.brightness, 0.5, 0.05), 1, 1);
				i.color = 0xFF257008;
			}
			else
			{
				i.scale.set(FlxMath.lerp(i.scale.x, i.ogDataCopy.scale[0] + 0, 0.025), FlxMath.lerp(i.scale.y, i.ogDataCopy.scale[1] + 0, 0.025));
				i.setColorValues(0, 1, 1);
				i.color = 0xFFFFFFFF;
			}
			if (FlxG.mouse.overlaps(i) && FlxG.mouse.pressedRight && FlxG.mouse.justPressed && player.focus)
			{
				var ogWidth = i.frameWidth;
				var ogHeight = i.frameHeight;
				trace(i.ogPath);
				gameShader.saturation.value[0] = 2;
				gameShader.contrast.value[0] = 2;
				FlxG.camera.shake(0.01, 0.1);
				FlxG.camera.zoom = 0.55;
				FlxG.camera.angle = -2;
				if (gameTime + 500 < 6500)
					gameTime += 500;
				if (GameVariables.levelCount > 1)
					daFocusAmount = Std.int(daFocusAmount / 1.5);
				FlxTween.num(1, 0, 1, {ease: FlxEase.expoOut}, function(flt:Float)
				{
					i.customColor.brightness = flt;
					trace(flt);
				});
				trace(i.frameWidth + " || " + i.frameHeight);
				i.loadGraphic(i.ogPath.replace("_DARK", "_GOLD"));
				trace(i.frameWidth + " || " + i.frameHeight);
				i.y += (((i.frameHeight - i.height) * 0.5) + ogHeight - i.frameHeight) * 2.05;
				i.x += (((i.frameWidth - i.width) * 0.5) + ogWidth - i.frameWidth) * 1.65;
				darkObjects.remove(i, true);
				envObjects.add(i);
				i.updateHitbox();
				i.color = 0xFFFFFFFF;
				// i.centerOffsets(false);
			}
		}

		for (i in defenseEnemies.members)
		{
			if (!i.isBoss && FlxG.mouse.overlaps(i) && FlxG.mouse.pressedRight && FlxG.mouse.justPressed && player.focus)
			{
				i.death(true);
				daFocusAmount = 0;
				player.focus = false;
			}
		}

		for (i in envObjects)
		{
			if (player.overlaps(i) && i.ogPath == "camShiftEvent" && !i.eventCalled)
			{
				i.eventCalled = true;
				shiftCamera = !shiftCamera;
			}
			if (player.overlaps(i) && i.ogPath == "camStopEvent" && !i.eventCalled)
			{
				i.eventCalled = true;
				camStopEventObj = i;
			}

			if (player.overlaps(i) && i.ogPath == "subtitlePart")
			{
				curSubtitleField = i;
			}
			if (player.overlaps(i) && i.ogPath == "levelEndEvent" && !i.eventCalled)
			{
				i.eventCalled = true;
				player.immovable = true;
				player._canMove = false;
				player._hasGravity = false;
				player.velocity.set(0, 0);
				player.acceleration.set(0, 0);
				endLevelSequence();
			}
			if (levelData.type == "defense" && i.ogPath == "defenseMiddle")
			{
				defenseMiddle = i;
			}
		}
		if (camStopEventObj != null)
		{
			if (player.overlaps(camStopEventObj))
				holdCam = true;
			else
			{
				holdCam = false;
				camStopEventObj.eventCalled = false;
				camStopEventObj = null;
			}
		}
		#if debug
		if (FlxG.keys.justPressed.F5)
		{
			FlxG.switchState(new LevelIntermissionState());
		}
		#end

		if (levelData.type == "defense")
		{
			if (nextEnemySpawnTime > 1)
				nextEnemySpawnTime--;
			if (nextEnemySpawnTime <= 1 && canSpawnEnemies && enemiesToSpawn > 0)
			{
				var newEnm = new DarkEnemy(FlxG.width * (FlxG.random.bool(50) ? -2 : 2), FlxG.height * (FlxG.random.bool(50) ? 0 : 2));
				newEnm.player = player;
				defenseEnemies.add(newEnm);
				nextEnemySpawnTime = FlxG.random.float(10, 80);
				enemiesToSpawn--;
			}
			if (enemiesToSpawn == 0 && defenseEnemies.length == 0 && canSpawnEnemies)
			{
				canSpawnEnemies = false;
				new FlxTimer().start(2, function(tmr:FlxTimer)
				{
					FlxG.camera.shake(0.01, 0.05);
					FlxG.camera.flash(FlxColor.RED, 0.5);
					var newEnm = new DarkEnemy(FlxG.width * (FlxG.random.bool(50) ? -2 : 2), FlxG.height * -2, true);
					newEnm.player = player;
					defenseEnemies.add(newEnm);
				});
			}
			if (FlxG.keys.justPressed.O)
			{
				var newEnm = new DarkEnemy(FlxG.width * (FlxG.random.bool(50) ? -2 : 2), FlxG.height * -2, true);
				newEnm.player = player;
				defenseEnemies.add(newEnm);
				canSpawnEnemies = false;
			}
		}
		if (GameVariables.levelCount == 0)
			canSpawnEnemies = false;
		if (levelData.type == "normal"
			|| levelData.type != "defense"
			&& GameVariables.levelCount != 0
			&& GameVariables.levelCount != 1)
		{
			if (nextEnemySpawnTime > 1)
				nextEnemySpawnTime--;
			if (nextEnemySpawnTime <= 1 && canSpawnEnemies)
			{
				var newEnm = new DarkEnemy(FlxG.width * (FlxG.random.bool(50) ? -2 : 2), FlxG.height * (FlxG.random.bool(50) ? 0 : 2));
				newEnm.player = player;
				defenseEnemies.add(newEnm);
				nextEnemySpawnTime = FlxG.random.float(50, 300);
				// enemiesToSpawn--;
			}
		}

		for (i in defenseEnemies)
		{
			if (i != null && i.readyToDelete)
			{
				defenseEnemies.remove(i, true);
			}
			if (i.overlaps(player))
			{
				if (collidingEnemy == null)
					collidingEnemy = i;
			}
		}
		if (collidingEnemy != null && collidingEnemy.overlaps(player))
		{
			defenseDeathTmr--;
			if (defenseDeathTmr < 0 && !plrDead && !collidingEnemy.dead && collidingEnemy.stunTmr < 1 && !win)
				deathSequence();
		}
		if (collidingEnemy != null && !collidingEnemy.overlaps(player))
		{
			defenseDeathTmr = 10;
			collidingEnemy = null;
		}
		if (player._isGrounded)
			combo = 0;

		if (combo == 0 && comboActive)
			dropCombo();

		updateComboShake();

		if (combo < 10)
			comboOffset = 0;
		if (combo >= 10)
			comboOffset = 2;
		if (combo >= 20)
			comboOffset = 5;
		if (combo >= 50)
			comboOffset = 10;

		if (finale && FlxG.timeScale < 1.0 && player._isGrounded)
		{
			finale = false;
			defaultTimeScale = 1;
			FlxTween.tween(bgDim, {alpha: 0}, 1);
			dropCombo();
			FlxTween.tween(topBar, {y: topBar.y - 200}, 2, {ease: FlxEase.expoOut, startDelay: 1});
			FlxTween.tween(bottomBar, {y: bottomBar.y + 200}, 2, {ease: FlxEase.expoOut, startDelay: 1});
			new FlxTimer().start(2, function(twn:FlxTimer)
			{
				FlxTween.tween(topBar, {y: topBar.y + 500}, 2, {ease: FlxEase.expoOut});
				FlxTween.tween(bottomBar, {y: bottomBar.y - 500}, 2, {
					ease: FlxEase.expoOut,
					onComplete: function(twn:FlxTween)
					{
						if (GameVariables.levelCount == 3)
						{
							FlxG.switchState(new MainMenuState());
							GameVariables.levelCount = 0;
						}
						else
							FlxG.switchState(new LevelIntermissionState());
					}
				});
			});
		}

		if (curSubtitleField != null && !finale)
		{
			if (player.overlaps(curSubtitleField))
			{
				subtitleText.y = FlxMath.lerp(subtitleText.y, subtitleOGPosition.y, 0.05);
				subtitleText.text = curSubtitleField.subText;
			}
			else
			{
				curSubtitleField = null;
			}
		}
		else
		{
			if (!finale)
				subtitleText.y = FlxMath.lerp(subtitleText.y, subtitleOGPosition.y + 200, 0.05);
		}

		if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.sound.music.pause();
			var substate = new PauseSubstate();
			substate.cameras = [camHUD];
			substate.closeCallback = substateClosed;
			openSubState(substate);
		}
		if (finale)
		{
			subtitleText.y = FlxMath.lerp(subtitleText.y, subtitleOGPosition.y - 100, 0.05);
			subtitleText.text = "CLICK RAPIDLY!!!!";
		}
	}

	public function substateClosed()
	{
		FlxG.sound.music.resume();
	}

	public var cbTwn:FlxTween;
	public var fnTwn:FlxTween;
	public var snTwn:FlxTween;

	public function dropCombo()
	{
		comboActive = false;

		if (cbTwn != null)
			cbTwn.cancel();
		if (fnTwn != null)
			fnTwn.cancel();
		if (snTwn != null)
			snTwn.cancel();

		cbTwn = FlxTween.tween(comboText, {y: comboText.y + 100, alpha: 0}, 1, {ease: FlxEase.expoOut});
		fnTwn = FlxTween.tween(firstNumber, {y: firstNumber.y + 100, alpha: 0}, 1, {ease: FlxEase.expoOut});
		snTwn = FlxTween.tween(secondNumber, {y: secondNumber.y + 100, alpha: 0}, 1, {ease: FlxEase.expoOut});
	}

	public function updateComboShake()
	{
		comboText.setPosition(comboTextPos.x, comboTextPos.y);
		firstNumber.setPosition(firstNumberPos.x, firstNumberPos.y);
		secondNumber.setPosition(secondNumberPos.x, secondNumberPos.y);

		comboText.x += FlxG.random.float(-comboOffset, comboOffset);
		comboText.y += FlxG.random.float(-comboOffset, comboOffset);

		firstNumber.x += FlxG.random.float(-comboOffset, comboOffset);
		firstNumber.y += FlxG.random.float(-comboOffset, comboOffset);

		secondNumber.x += FlxG.random.float(-comboOffset, comboOffset);
		secondNumber.y += FlxG.random.float(-comboOffset, comboOffset);
	}

	public function endLevelSequence()
	{
		win = true;
		trace("GAME");
		FlxTween.tween(uiBar, {alpha: 0}, 1);
		FlxTween.tween(uiIcon, {alpha: 0}, 1);
		FlxTween.tween(focusBar, {alpha: 0}, 1);
		FlxTween.tween(focusBarBG, {alpha: 0}, 1);
		for (i in goldGroup)
		{
			FlxTween.tween(i, {alpha: 0}, 1);
		}
		if (FlxG.sound.music != null)
			FlxG.sound.music.fadeOut(1.8, 0);
		FlxTween.tween(topBar, {y: topBar.y + 500}, 2, {ease: FlxEase.expoOut});
		FlxTween.tween(bottomBar, {y: bottomBar.y - 500}, 2, {
			ease: FlxEase.expoOut,
			onComplete: function(twn:FlxTween)
			{
				FlxG.switchState(new LevelIntermissionState());
			}
		});
	}

	public function onEnemyKilled()
	{
		if (gameTime + 100 < 6500)
			gameTime += 10 * ((combo * 5.5) / 2);
		daFocusAmount += 75;
		FlxG.camera.shake(0.01, 0.1);
		player._curJumpCount = 1;
		nextEnemySpawnTime -= 5;
		FlxG.camera.zoom = 0.6;
		FlxG.camera.angle = FlxG.random.int(-2, 2);
		combo++;
		trace(combo);

		popupCombo();
	}

	public function onBossHurt()
	{
		if (!finale)
			startFinale();
		if (gameTime + 100 < 6500)
			gameTime += 10 * ((combo * 5.5) / 2);
		FlxG.camera.shake(0.01, 0.1);
		player._curJumpCount = 1;
		nextEnemySpawnTime -= 5;
		FlxG.camera.zoom += 0.05;
		FlxG.camera.angle = FlxG.random.int(-2, 2);
		combo++;
		trace(combo);

		bossHits++;

		if (bossHits > 0)
			FlxG.sound.play("assets/sounds/combo/combo" + bossHits + ".ogg", 0.5);

		popupCombo();
	}

	public function startFinale()
	{
		finale = true;
		FlxTween.tween(uiBar, {alpha: 0}, 1);
		FlxTween.tween(uiIcon, {alpha: 0}, 1);
		FlxTween.tween(focusBar, {alpha: 0}, 1);
		FlxTween.tween(focusBarBG, {alpha: 0}, 1);
		for (i in goldGroup)
		{
			FlxTween.tween(i, {alpha: 0}, 1);
		}
		cameraAngle = 5;
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		bgDim.alpha = 0.45;
		FlxG.camera.flash(FlxColor.WHITE, 1);

		FlxTween.tween(topBar, {y: topBar.y + 200}, 1, {ease: FlxEase.expoOut});
		FlxTween.tween(bottomBar, {y: bottomBar.y - 200}, 1, {
			ease: FlxEase.expoOut,
			onComplete: function(twn:FlxTween)
			{
				FlxTween.cancelTweensOf(topBar);
				FlxTween.cancelTweensOf(bottomBar);
			}
		});
	}

	public function endFinale()
	{
		cameraAngle = 0;
		bgDim.alpha = 1;

		defaultTimeScale = 0.45;
	}

	public function popupCombo()
	{
		if (!comboActive)
		{
			comboActive = true;
			if (cbTwn != null)
				cbTwn.cancel();
			if (fnTwn != null)
				fnTwn.cancel();
			if (snTwn != null)
				snTwn.cancel();

			firstNumber.animation.curAnim.curFrame = 0;
			secondNumber.animation.curAnim.curFrame = 0;

			cbTwn = FlxTween.tween(comboText, {y: comboTextPos.y, alpha: 1}, 1, {ease: FlxEase.expoOut});
			fnTwn = FlxTween.tween(firstNumber, {y: firstNumberPos.y, alpha: 1}, 1, {ease: FlxEase.expoOut});
			snTwn = FlxTween.tween(secondNumber, {y: secondNumberPos.y, alpha: 1}, 1, {ease: FlxEase.expoOut});
		}

		var string = Std.string(combo);
		if (combo <= 9)
		{
			if (string.charAt(0) != "" || string.charAt(0) != null)
				secondNumber.animation.curAnim.curFrame = Std.parseInt(string.charAt(0));
			if (string.charAt(1) != "" || string.charAt(1) != null)
				firstNumber.animation.curAnim.curFrame = Std.parseInt(string.charAt(1));
		}
		else
		{
			if (string.charAt(1) != "" || string.charAt(1) != null)
				secondNumber.animation.curAnim.curFrame = Std.parseInt(string.charAt(1));
			if (string.charAt(0) != "" || string.charAt(0) != null)
				firstNumber.animation.curAnim.curFrame = Std.parseInt(string.charAt(0));
		}
	}

	public function changeMusic()
	{
		if (player.focus)
		{
			if (curMusicState == "normal")
			{
				if (levelData.type != "defense")
					FlxG.sound.playMusic("assets/music/stageloopslow1.ogg", 0.5, true);
				if (levelData.type == "defense")
					FlxG.sound.playMusic("assets/music/defenseslow.ogg", 0.5, true);
				// FlxG.sound.music.time = curMusicTime * 2;
				FlxG.sound.play("assets/sounds/slowMo.ogg", 0.75);
				FlxG.camera.shake(0.01, 0.1);
				curMusicState = "slowed";
			}
		}
		if (!player.focus)
		{
			if (curMusicState == "slowed")
			{
				// FlxG.sound.music.time = curMusicTime / 2;
				if (levelData.type != "defense")
					FlxG.sound.playMusic("assets/music/stageplayloop1.ogg", 0.5, true);
				if (levelData.type == "defense")
					FlxG.sound.playMusic("assets/music/defensenorm.ogg", 0.5, true);
				FlxG.sound.play("assets/sounds/reSlowMo.ogg", 0.75);
				FlxG.camera.shake(0.01, 0.1);
				curMusicState = "normal";
			}
		}
	}

	public function deathSequence()
	{
		FlxG.sound.play("assets/sounds/death.ogg", 0.5);
		FlxG.sound.play("assets/sounds/deathguylol.ogg", 0.5);
		player.dead = true;
		FlxG.sound.music.fadeOut(1, 0);

		if (comboActive)
			dropCombo();

		FlxTween.tween(uiBar, {alpha: 0}, 1);
		FlxTween.tween(uiIcon, {alpha: 0}, 1);
		FlxTween.tween(focusBar, {alpha: 0}, 1);
		FlxTween.tween(focusBarBG, {alpha: 0}, 1);
		GameVariables.playerHP--;
		for (i in goldGroup)
		{
			FlxTween.tween(i, {alpha: 0}, 1);
		}
		plrDead = true;
		if (openingT != null)
			openingT.percent = 1;
		if (openingB != null)
			openingB.percent = 1;
		FlxTween.tween(topBar, {y: topBar.y + 200}, 2, {ease: FlxEase.expoOut});
		FlxTween.tween(bottomBar, {y: bottomBar.y - 200}, 2, {ease: FlxEase.expoOut});
		FlxG.camera.shake(0.005, 0.25);
		gameSaturationValue = 2;
		gameContrastValue = 2;
		cameraAngle = 5;
		FlxTween.tween(FlxG.camera, {zoom: 0.8});
		camHUD.flash(FlxColor.RED, 1);
		new FlxTimer().start(2.1, function(tmr:FlxTimer)
		{
			FlxTween.tween(topBar, {y: topBar.y + 300}, 2, {ease: FlxEase.expoOut});
			FlxTween.tween(bottomBar, {y: bottomBar.y - 300}, 2, {
				ease: FlxEase.expoOut,
				onComplete: function(twn:FlxTween)
				{
					FlxG.resetState();
				}
			});
		});
	}

}
