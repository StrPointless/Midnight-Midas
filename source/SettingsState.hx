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
import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import openfl.Assets;
import openfl.filters.ShaderFilter;

using StringTools;

class SettingsState extends BaseMenuState
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
    
    public var titleText:FlxText;
    public var optionMenus:Array<String> = ["Gameplay", "Speedrun", "Controls"];
    public var optionGroup:FlxTypedGroup<FlxText>;

    public var gameplayOptions:Array<SettingsMenuOption> = [];

    public var curSelected:Int = 0;

    public var playedSoundOnPlay:Bool = false;
    public var playedSoundOnLevels:Bool = false;
    public var playedSoundOnCredits:Bool = false;

	public var pagesMap:Map<String, SettingsPage>;
	public var curPage:SettingsPage;
	public var clicked:Bool;

	public var transing:Bool = false;

	override public function create()
	{
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


		fgObjects = new FlxTypedGroup<ModifiedFlxSprite>();
		add(fgObjects);

		FlxG.camera.bgColor = FlxColor.GRAY;

		var daStuff:Level.LevelData = Json.parse(Assets.getText("assets/data/level" + 1 + ".json"));
		levelData = daStuff;

		for (i in daStuff.objects)
		{
			if (i.graphicPath != "defenseMiddle")
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

        titleText = new FlxText(0,0, "Settings", 64);
        titleText.cameras = [camHUD];
        titleText.screenCenter();
        titleText.y -= 200;
        add(titleText);

        optionGroup = new FlxTypedGroup<FlxText>();
        add(optionGroup);

		pagesMap = new Map<String, SettingsPage>();

		var mainPage = new SettingsPage();
		mainPage.optionSpacing = 80;
		mainPage.optionSize = 38;
		mainPage.addOneshotMenuItem("Gameplay", function(dymamo:Dynamic)
		{
			changePage("gameplay");
		});
		mainPage.addOneshotMenuItem("Speedrun", function(dymamo:Dynamic)
		{
			changePage("speedrun");
		});
		mainPage.addOneshotMenuItem("Controls", function(dymamo:Dynamic)
		{
			changePage("controls");
		});
		mainPage.addOneshotMenuItem("Back", function(dymamo:Dynamic)
		{
			if (!transing)
			{
				transing = true;
				openingT = FlxTween.tween(topBar, {y: topBar.y + 500}, 1, {ease: FlxEase.circIn});
				openingB = FlxTween.tween(bottomBar, {y: bottomBar.y - 500}, 1, {
					ease: FlxEase.circIn,
					onComplete: function(twn:FlxTween)
					{
						FlxG.switchState(new MainMenuState());
					}
				});
			}
		});
		/*
					var gameplayPage = new SettingsPage();
					gameplayPage.optionSize = 28;
					gameplayPage.optionSpacing = 50;

					var curControlScheme = "";
					if (GameVariables.settings.cc_useController)
						curControlScheme = "controller";
					if (GameVariables.settings.cc_useKeyboard)
						curControlScheme = "full keyboard";
					if (GameVariables.settings.cc_useKeyboardMouse)
						curControlScheme = "keyboard + mouse";

					gameplayPage.addStringStepperMenuItem("Control Scheme: ", curControlScheme, ["full keyboard", "keyboard + mouse", "controller"], "Controls");
					gameplayPage.addOneshotMenuItem("Back", function(dymamo:Dynamic)
			{
						changePage("main");
			});
		 */
		var gameplayPage = createGameplayPage();
		var speedrunPage = createSpeedrunPage();
		var controlsPage = createControlsPage();
		pagesMap.set("main", mainPage);
		pagesMap.set("gameplay", gameplayPage);
		pagesMap.set("speedrun", speedrunPage);
		pagesMap.set("controls", controlsPage);

		mainPage.onChangeCallback = function(page:SettingsPage)
		{
			updateTexts(page);
		}
		curPage = mainPage;


		genPage();



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

	public function changePage(pageName:String)
	{
		if (!transing)
		{
			curPage = pagesMap.get(pageName);
			genPage();
		}
	}
	override public function update(elapsed:Float)
	{
        FlxG.camera.follow(camFollow, LOCKON, 0.05);
		FlxG.watch.addQuick("gameTime", FlxMath.remapToRange(gameTime, 6500, 0, 0, -1));
		FlxG.watch.addQuick("focus", daFocusAmount);
		FlxG.watch.addQuick("PageMap", pagesMap);

        if (FlxG.sound.music != null)
			curMusicTime = FlxG.sound.music.time;
		gameShader.saturation.value[0] = FlxMath.lerp(gameShader.saturation.value[0], gameSaturationValue, 0.05);
		gameShader.contrast.value[0] = FlxMath.lerp(gameShader.contrast.value[0], gameContrastValue, 0.05);
		camGame.angle = FlxMath.lerp(camGame.angle, cameraAngle, 0.05);
		FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, 0.55, 0.05);
		FlxG.camera.angle = FlxMath.lerp(FlxG.camera.angle, 0, 0.05);
		if (defenseMiddle != null)
			camFollow.setPosition((FlxG.mouse.screenX / 20), (FlxG.mouse.screenY / 20));

        
        super.update(elapsed);

        optionGroup.forEach(function(txt:FlxText)
            {
                if(FlxG.mouse.overlaps(txt, camHUD))
                {
                    curSelected = txt.ID;
				txt.scale.set(FlxMath.lerp(txt.scale.x, 1.1, 0.15), FlxMath.lerp(txt.scale.y, 1.1, 0.15));
                    txt.alpha = 1;
				if (FlxG.mouse.justPressed && !clicked)
				{
					txt.scale.set(1.2, 1.2);

					if (curPage.options[curSelected] != null)
					{
						switch (curPage.options[curSelected].type)
						{
							case ONESHOT:
								curPage.options[curSelected].pressFunction(null);

							case SETTINGBOOL:
								curPage.onOptionSelected(curSelected);
								updateSettings();
								updateTexts(curPage);
							case STEPPER:
							case STRINGSTEPPER:
						}
					}

					clicked = true;
				}
				if (FlxG.mouse.justReleased)
					clicked = false;

                }
                else
                {
                    txt.scale.set(FlxMath.lerp(txt.scale.x, 1, 0.05),FlxMath.lerp(txt.scale.y, 1, 0.05));
                    txt.alpha = 0.75;
                }
            });
		for (i in optionGroup)
		{
			if (curSelected == i.ID)
			{
				//	trace(curPage.options[curSelected].type);
				if (FlxG.keys.justPressed.RIGHT)
					if (curPage.options[curSelected].type == STRINGSTEPPER)
					{
						curPage.onOptionIncreased(curSelected);
						updateSettings();
					}
				if (FlxG.keys.justPressed.LEFT)
					if (curPage.options[curSelected].type == STRINGSTEPPER)
					{
						curPage.onOptionDecreased(curSelected);
						updateSettings();
					}
			}
		}
	}

	public function updateSettings()
	{
		for (i in curPage.options)
		{
			switch (i.id)
			{
				case "Controls":
					switch (i.value)
					{
						case "full keyboard":
							GameVariables.setControlType(Fullkeyboard);
						case "controller":
							GameVariables.setControlType(Controller);
						case "keyboard + mouse":
							GameVariables.setControlType(KeyboardMouse);
					}
				case "speedrunMode":
					switch (i.value)
					{
						case true:
							GameVariables.settings.speedrunMode = true;
						case false:
							GameVariables.settings.speedrunMode = false;
					}
			}
		}
	}

	public function updateTexts(daPage:SettingsPage)
	{
		trace("UPDATE");
		for (i in 0...daPage.options.length)
		{
			if (daPage.options[i].type == STRINGSTEPPER)
				optionGroup.members[i].text = daPage.options[i].name + ": < " + daPage.options[i].value + " >";
			if (daPage.options[i].type == SETTINGBOOL)
				optionGroup.members[i].text = daPage.options[i].name + ": " + daPage.options[i].value;
		}
	}

	public function genPage()
	{
		if (optionGroup.length > 0)
		{
			for (i in 0...optionGroup.length)
			{
				optionGroup.remove(optionGroup.members[i]);
			}
		}
		var lastYPos:Float = 0;
		for (i in 0...curPage.options.length)
		{
			var text = new FlxText(0, 0, 10000, curPage.options[i].name, curPage.optionSize);
			text.cameras = [camHUD];
			text.alignment = CENTER;
			text.screenCenter();
			if (i != 0)
				text.y = lastYPos + curPage.optionSpacing;
			lastYPos = text.y;
			text.updateHitbox();
			text.alpha = 0;
			text.y -= 100;
			FlxTween.tween(text, {alpha: 1, y: text.y + 100}, 1, {ease: FlxEase.expoOut});
			text.ID = i;
			optionGroup.add(text);
		}
		updateTexts(curPage);
	}

	public function createGameplayPage()
	{
		var page = new SettingsPage();
		page.addOneshotMenuItem("Back", function(dymamo:Dynamic)
		{
			changePage("main");
		});
		page.onChangeCallback = function(page:SettingsPage)
		{
			updateTexts(page);
		}

		return page;
	}

	public function createControlsPage()
	{
		var page = new SettingsPage();
		page.optionSize = 28;
		page.optionSpacing = 50;
		var curControlScheme = "";
		if (GameVariables.settings.cc_useController)
			curControlScheme = "controller";
		if (GameVariables.settings.cc_useKeyboard)
			curControlScheme = "full keyboard";
		if (GameVariables.settings.cc_useKeyboardMouse)
			curControlScheme = "keyboard + mouse";

		page.addStringStepperMenuItem("Control Scheme: ", curControlScheme, ["full keyboard", "keyboard + mouse", "controller"], "Controls");
		page.addOneshotMenuItem("Back", function(dymamo:Dynamic)
		{
			changePage("main");
		});
		page.onChangeCallback = function(page:SettingsPage)
		{
			updateTexts(page);
		}

		return page;
	}

	public function createSpeedrunPage()
	{
		var page = new SettingsPage();
		page.optionSize = 28;
		page.optionSpacing = 50;
		var spdRunMdVal = GameVariables.settings.speedrunMode;
		page.addBoolMenuItem("Speedrun Mode", spdRunMdVal, "speedrunMode");
		page.addOneshotMenuItem("Back", function(dymamo:Dynamic)
		{
			changePage("main");
		});
		page.onChangeCallback = function(page:SettingsPage)
		{
			updateTexts(page);
		}
		return page;
	}
}
typedef SettingsMenuOption =
{
    var name:String;
	var id:String;
    var type:SettingOptionType;
    var value:Dynamic;
	var increment:Float;

	var pressFunction:Dynamic->Void;
	var ss_options:Array<String>;
	var ss_curSec:Int;
}
typedef SCallback = Float->Void;
enum SettingOptionType 
{
    STEPPER;
	STRINGSTEPPER;
	SETTINGBOOL;    
	ONESHOT;
}

class SettingsPage
{
	public var options:Array<SettingsMenuOption>;
	public var optionSpacing:Float = 50;
	public var optionSize:Int = 48;
	public var onChangeCallback:SettingsPage->Void;

	public function new()
	{
		options = new Array<SettingsMenuOption>();
	}

	public function addMenuItem(name:String, type:SettingOptionType, value:Dynamic, ?increment:Float = 0, ?pressfunc:Dynamic->Void = null,
			?optionsShiz:Array<String> = null, ?id:String = "")
	{
		if (id == "")
			id = name;
		options.push({
			name: name,
			id: id,
			type: type,
			value: value,
			increment: increment,
			pressFunction: pressfunc,
			ss_options: optionsShiz,
			ss_curSec: 0
		});
	}

	public function addBoolMenuItem(name:String, value:Bool, ?id:String = "")
	{
		if (id == "")
			id = name;
		options.push({
			name: name,
			id: id,
			type: SETTINGBOOL,
			value: value,
			increment: -1,
			pressFunction: null,
			ss_options: null,
			ss_curSec: 0
		});
	}

	public function addStepperMenuItem(name:String, value:Float, increment:Float = 0, ?id:String = "")
	{
		if (id == "")
			id = name;
		options.push({
			name: name,
			id: id,
			type: STEPPER,
			value: value,
			increment: increment,
			pressFunction: null,
			ss_options: null,
			ss_curSec: 0
		});
	}

	public function addStringStepperMenuItem(name:String, value:String, optionsShiz:Array<String>, ?id:String = "")
	{
		if (id == "")
			id = name;
		options.push({
			name: name,
			id: id,
			type: STRINGSTEPPER,
			value: value,
			increment: 0,
			pressFunction: null,
			ss_options: optionsShiz,
			ss_curSec: 0
		});
	}

	public function addOneshotMenuItem(name:String, pressFunc:Dynamic->Void, ?id:String = "")
	{
		if (id == "")
			id = name;
		options.push({
			name: name,
			id: id,
			type: ONESHOT,
			value: null,
			increment: -1,
			pressFunction: pressFunc,
			ss_options: null,
			ss_curSec: 0
		});
		trace("options are now " + options);
	}

	public function onOptionSelected(curSelected:Int)
	{
		if (options[curSelected].type == SETTINGBOOL)
		{
			var tmpVal:Bool = options[curSelected].value;
			options[curSelected].value = !tmpVal;
		}
	}

	public function onOptionIncreased(curSelected:Int)
	{
		if (options[curSelected].type == STEPPER)
		{
			if (options[curSelected].increment != 0 || options[curSelected].increment != -1)
			{
				var tmpVal:Float = options[curSelected].value + options[curSelected].increment;
				options[curSelected].value = tmpVal;
			}
		}
		if (options[curSelected].type == STRINGSTEPPER)
		{
			if (options[curSelected].ss_curSec + 1 > options[curSelected].ss_options.length - 1)
				options[curSelected].ss_curSec = 0;
			else
				options[curSelected].ss_curSec++;

			options[curSelected].value = options[curSelected].ss_options[options[curSelected].ss_curSec];
		}
		if (onChangeCallback != null)
			onChangeCallback(this);
	}

	public function onOptionDecreased(curSelected:Int)
	{
		if (options[curSelected].type == STEPPER)
		{
			if (options[curSelected].increment != 0 || options[curSelected].increment != -1)
			{
				var tmpVal:Float = options[curSelected].value - options[curSelected].increment;
				options[curSelected].value = tmpVal;
			}
		}
		if (options[curSelected].type == STRINGSTEPPER)
		{
			if (options[curSelected].ss_curSec - 1 < 0)
				options[curSelected].ss_curSec = options[curSelected].ss_options.length - 1;
			else
				options[curSelected].ss_curSec--;

			options[curSelected].value = options[curSelected].ss_options[options[curSelected].ss_curSec];
		}
		if (onChangeCallback != null)
			onChangeCallback(this);
	}

	public function getCurObjectType(curSelected:Int)
	{
		return options[curSelected].type;
	}
}
