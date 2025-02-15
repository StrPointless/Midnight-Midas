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

class MainMenuState extends FlxState
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







    public var levelsText:FlxText;
    public var playText:FlxText;
	public var settingsText:FlxText;
    public var logo:ModifiedFlxSprite;

    public var playedSoundOnPlay:Bool = false;
    public var playedSoundOnLevels:Bool = false;
    public var playedSoundOnCredits:Bool = false;
	public var curSelected:Int = 0;
	public var optionsGroup:Array<FlxText>;
	public var soundGroup:Array<Bool> = [false, false, false];
	public var analogTimer:Int = 20;
	public var holdTimer:Int = 20;


	override public function create()
	{
		FlxG.sound.cache("assets/music/stageplayloop1.ogg");
		FlxG.sound.cache("assets/music/stageloopslow1.ogg");

		trace("init" + " || " + GameVariables.initialized + " || " + GameVariables.settings);
		if (!GameVariables.initialized)
			GameVariables.resetSettings();
		// GameVariables.settings.cc_useKeyboard = true;
		// GameVariables.settings.cc_useController = true;

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


		fgObjects = new FlxTypedGroup<ModifiedFlxSprite>();
		add(fgObjects);

		FlxG.camera.bgColor = FlxColor.GRAY;

		var daStuff:Level.LevelData = Json.parse(Assets.getText("assets/data/level" + 1 + ".json"));
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
			else if (i.graphicPath == "levelEndEvent" || i.graphicPath == "subtitlePart")
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
            else if(i.graphicPath == "defenseMiddle" )
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
                defenseMiddle = sprite;
                trace("defenseMiddle created");
            }
		
		}

		FlxG.camera.zoom = 0.75;
		FlxG.camera.setScrollBounds(null, null, null, null);
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

        FlxG.sound.playMusic("assets/music/stageplayloop1.ogg", 0);
		FlxG.sound.music.fadeIn(1, 0, 1);

        logo = new ModifiedFlxSprite(0,0);
        logo.loadGraphic("assets/images/logo.png");
        logo.cameras = [camHUD];
        logo.scale.set(0.5, 0.5);
        logo.screenCenter();
        logo.y -= 100;
        add(logo);

		settingsText = new FlxText(0, 0, 0, "Settings", 56);
		settingsText.screenCenter();
		settingsText.cameras = [camHUD];
		settingsText.scale.set(0.5, 0.5);
		settingsText.y += 200;
		settingsText.x += 400;
		add(settingsText);

        levelsText = new FlxText(0,0,0,"Levels", 56);
        levelsText.screenCenter();
        levelsText.scale.set(0.5,0.5);
        levelsText.cameras = [camHUD];
        levelsText.y += 200;
        levelsText.x -= 400;
		add(levelsText);

        playText = new FlxText(0,0,0,"Play", 56);
        playText.screenCenter();
        playText.cameras = [camHUD];
        playText.y += 200;
        playText.x -= 0;
        add(playText);

		var verText = new FlxText(0, 0, 0, "Version: 0.5 (The pre-update)", 18);
		verText.fieldHeight = 100;
		verText.fieldWidth = 700;
		verText.alignment = CENTER;
		verText.cameras = [camHUD];
		verText.screenCenter();
		verText.alpha = 0.5;
		verText.y += 350;
		add(verText);

		var timeText = new FlxText(0, 0, 0, "Last time: " + GameVariables.timeDisplay, 12);
		if (GameVariables.incompleteTime)
			timeText.text += " | INCOMPLETE";
		timeText.fieldHeight = 100;
		timeText.fieldWidth = 700;
		timeText.alignment = CENTER;
		timeText.cameras = [camHUD];
		timeText.screenCenter();
		if (GameVariables.settings.speedrunMode)
			timeText.alpha = 0.5;
		else
			timeText.alpha = 0;
		timeText.y += 375;
		add(timeText);

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
		
		optionsGroup = new Array<FlxText>();


		levelsText.ID = 0;
		playText.ID = 1;
		settingsText.ID = 2;
		optionsGroup.push(levelsText);
		optionsGroup.push(playText);
		optionsGroup.push(settingsText);

		super.create();
		gameShader = new TestShader();
		gameShader.saturation.value = [0];
		gameShader.contrast.value = [0];
		gameShader.brightness.value = [0];

		camGame.filters = [new ShaderFilter(gameShader)];
		openingT = FlxTween.tween(topBar, {y: topBar.y - 500}, 2, {ease: FlxEase.expoOut, startDelay: 1});
		openingB = FlxTween.tween(bottomBar, {y: bottomBar.y + 500}, 2, {ease: FlxEase.expoOut, startDelay: 1});
	}

	var xPos:Float = 125;

	override public function update(elapsed:Float)
	{
		FlxG.watch.addQuick("curSelect", curSelected);
        FlxG.camera.follow(camFollow, LOCKON, 0.05);
		FlxG.watch.addQuick("gameTime", FlxMath.remapToRange(gameTime, 6500, 0, 0, -1));
		FlxG.watch.addQuick("focus", daFocusAmount);
	
		if (FlxG.sound.music != null)
			curMusicTime = FlxG.sound.music.time;
		gameShader.saturation.value[0] = FlxMath.lerp(gameShader.saturation.value[0], gameSaturationValue, 0.05);
		gameShader.contrast.value[0] = FlxMath.lerp(gameShader.contrast.value[0], gameContrastValue, 0.05);
		camGame.angle = FlxMath.lerp(camGame.angle, cameraAngle, 0.05);
		FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, 0.55, 0.05);
		FlxG.camera.angle = FlxMath.lerp(FlxG.camera.angle, 0, 0.05);
		if (defenseMiddle != null)
			camFollow.setPosition((FlxG.mouse.screenX / 20), (FlxG.mouse.screenY / 20));

		if (FlxG.keys.justPressed.EIGHT)
		{
			GameVariables.levelCount = 1;
			FlxG.switchState(new PlayState());
		}
		if (FlxG.keys.justPressed.NINE)
			FlxG.switchState(new ObjectEditorState());
		if (FlxG.keys.justPressed.ONE)
			FlxG.switchState(new CharacterEditorState());

		/*
			FlxG.camera.flash(FlxColor.WHITE, 1, function()
				{
					FlxTween.tween(playText, {alpha: 0}, 1);
					FlxTween.tween(settingsText, {alpha: 0}, 1);
					FlxTween.tween(levelsText, {alpha: 0}, 1);
					FlxTween.tween(logo, {alpha: 0}, 1);
					camHUD.fade(FlxColor.BLACK, 2, false);
					FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
					{
						FlxG.switchState(new PlayState());

					});
				});
		 */

		for (i in optionsGroup)
		{
			if (FlxG.mouse.visible)
			{
				if (FlxG.mouse.overlaps(i, camHUD))
				{
					i.scale.set(0.95, 0.95);
					curSelected = i.ID;
					if (FlxG.mouse.justPressed)
						doSelection();
				}
				else
				{
					i.scale.set(FlxMath.lerp(i.scale.x, 0.75, 0.05), FlxMath.lerp(i.scale.y, 0.75, 0.05));
				}
			}
			else
			{
				if (i.ID == curSelected)
					i.scale.set(0.95, 0.95);
				if (i.ID != curSelected)
					i.scale.set(FlxMath.lerp(i.scale.x, 0.75, 0.05), FlxMath.lerp(i.scale.y, 0.75, 0.05));
			}
		}
		super.update(elapsed);
		if (FlxG.mouse.deltaScreenX != 0 || FlxG.mouse.deltaScreenY != 0)
			FlxG.mouse.visible = true;
		if (FlxG.keys.anyJustPressed([ANY]) || GameVariables.settings.cc_useController && FlxG.gamepads.lastActive.anyJustPressed([ANY]))
			FlxG.mouse.visible = false;

		if (FlxG.keys.justPressed.TAB)
			FlxG.switchState(new LevelEditorState({objects: [], type: "normal"}));

		if (FlxG.keys.anyJustPressed([LEFT, A])
			|| GameVariables.settings.cc_useController
			&& FlxG.gamepads.lastActive.justPressed.DPAD_LEFT)
			changeSelection(-1);
		if (FlxG.keys.anyJustPressed([RIGHT, D])
			|| GameVariables.settings.cc_useController
			&& FlxG.gamepads.lastActive.justPressed.DPAD_RIGHT)
			changeSelection(1);

		if (GameVariables.settings.cc_useController && FlxG.gamepads.lastActive.getXAxis(LEFT_ANALOG_STICK) < -0.5)
		{
			analogTimer--;
			if (analogTimer < 0)
			{
				analogTimer = 20;
				changeSelection(-1);
			}
		}
		if (GameVariables.settings.cc_useController && FlxG.gamepads.lastActive.getXAxis(LEFT_ANALOG_STICK) > 0.5)
		{
			analogTimer--;
			if (analogTimer < 0)
			{
				analogTimer = 20;
				changeSelection(1);
			}
		}
		if (GameVariables.settings.cc_useController
			&& FlxG.gamepads.lastActive.getXAxis(LEFT_ANALOG_STICK) < 0.5
			&& GameVariables.settings.cc_useController
			&& FlxG.gamepads.lastActive.getXAxis(LEFT_ANALOG_STICK) > -0.5)
			analogTimer = -1;

		if (FlxG.keys.justPressed.ENTER)
			doSelection();

		if (GameVariables.settings.cc_useController
			&& FlxG.gamepads.lastActive.justPressed.A
			|| GameVariables.settings.cc_useController
			&& FlxG.gamepads.lastActive.justPressed.START)
			doSelection();
	}

	public function changeSelection(sec:Int = 0)
	{
		FlxG.sound.play("assets/sounds/scroll.ogg", 0.5);
		curSelected += sec;
		if (curSelected > 2)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = 2;

		optionsGroup[curSelected].scale.set(0.95, 0.95);
	}
	public function doSelection()
	{
		switch (curSelected)
		{
			case 0:
				FlxG.camera.flash(FlxColor.WHITE, 1, function()
				{
					FlxTween.tween(playText, {alpha: 0}, 1);
					FlxTween.tween(settingsText, {alpha: 0}, 1);
					FlxTween.tween(levelsText, {alpha: 0}, 1);
					FlxTween.tween(logo, {alpha: 0}, 1);
					camHUD.fade(FlxColor.BLACK, 2, false);
					FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
					{
						trace("nah");
					});
				});
				camHUD.flash(FlxColor.WHITE);
			case 1:
				FlxG.camera.flash(FlxColor.WHITE, 1, function()
				{
					FlxTween.tween(playText, {alpha: 0}, 1);
					FlxTween.tween(settingsText, {alpha: 0}, 1);
					FlxTween.tween(levelsText, {alpha: 0}, 1);
					FlxTween.tween(logo, {alpha: 0}, 1);
					camHUD.fade(FlxColor.BLACK, 2, false);
					FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
					{
						FlxG.switchState(new PlayState());
	
					});
				});
				camHUD.flash(FlxColor.WHITE);
			case 2:
				FlxG.camera.flash(FlxColor.WHITE, 1, function()
				{
					FlxTween.tween(playText, {alpha: 0}, 1);
					FlxTween.tween(settingsText, {alpha: 0}, 1);
					FlxTween.tween(levelsText, {alpha: 0}, 1);
					FlxTween.tween(logo, {alpha: 0}, 1);
					camHUD.fade(FlxColor.BLACK, 0.5, false);
					FlxG.camera.fade(FlxColor.BLACK, 0.5, false, function()
					{
						FlxG.switchState(new SettingsState());

					});
				});
				camHUD.flash(FlxColor.WHITE);
		}
	}
}
