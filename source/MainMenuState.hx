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
    public var creditsText:FlxText;
    public var logo:ModifiedFlxSprite;

    public var playedSoundOnPlay:Bool = false;
    public var playedSoundOnLevels:Bool = false;
    public var playedSoundOnCredits:Bool = false;


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

        creditsText = new FlxText(0,0,0,"Credits", 56);
        creditsText.screenCenter();
        creditsText.cameras = [camHUD];
        creditsText.scale.set(0.5,0.5);
        creditsText.y += 200;
        creditsText.x += 400;
        //add(creditsText);

        levelsText = new FlxText(0,0,0,"Levels", 56);
        levelsText.screenCenter();
        levelsText.scale.set(0.5,0.5);
        levelsText.cameras = [camHUD];
        levelsText.y += 200;
        levelsText.x -= 400;
        //add(levelsText);

        playText = new FlxText(0,0,0,"Play", 56);
        playText.screenCenter();
        playText.cameras = [camHUD];
        playText.y += 200;
        playText.x -= 0;
        add(playText);

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

	override public function update(elapsed:Float)
	{
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


        if(FlxG.mouse.overlaps(playText, camHUD))
        {
            playText.scale.set(1.2,1.2);
            if(!playedSoundOnPlay)
            {
                playedSoundOnPlay = true;
                FlxG.sound.play("assets/sounds/scroll.ogg", 0.5);
            }
            if(FlxG.mouse.justPressed)
            {
                FlxG.sound.play("assets/sounds/trueconfirm.ogg", 0.5);
                FlxG.camera.zoom += 0.1;
                camHUD.flash(FlxColor.WHITE, 1);
                FlxG.camera.flash(FlxColor.WHITE, 1, function()
                {
                    FlxTween.tween(playText, {alpha: 0}, 1);
                    FlxTween.tween(creditsText, {alpha: 0}, 1);
                    FlxTween.tween(levelsText, {alpha: 0}, 1);
                    FlxTween.tween(logo, {alpha: 0}, 1);
                    camHUD.fade(FlxColor.BLACK, 2, false);
                    FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
                        {
                            FlxG.switchState(new PlayState());

                            
                        });
                });
            }
        }
        else
        {   
            playedSoundOnPlay = false;
            playText.scale.set(FlxMath.lerp(playText.scale.x, 1, 0.05), FlxMath.lerp(playText.scale.y, 1, 0.05));
        }
        if(FlxG.mouse.overlaps(levelsText, camHUD))
        {
            levelsText.scale.set(0.95,0.95);
            if(!playedSoundOnLevels)
            {
                playedSoundOnLevels = true;
                FlxG.sound.play("assets/sounds/scroll.ogg", 0.5);
            }
        }
        else
        {
            playedSoundOnLevels = false;
            levelsText.scale.set(FlxMath.lerp(levelsText.scale.x, 0.75, 0.05), FlxMath.lerp(levelsText.scale.y, 0.75, 0.05));
        }

        if(FlxG.mouse.overlaps(creditsText, camHUD))
        {
            creditsText.scale.set(0.95,0.95);
            if(!playedSoundOnCredits)
            {
                playedSoundOnCredits = true;
                FlxG.sound.play("assets/sounds/scroll.ogg", 0.5);
            }
        }
        else
        {
            playedSoundOnCredits = false;
            creditsText.scale.set(FlxMath.lerp(creditsText.scale.x, 0.75, 0.05), FlxMath.lerp(creditsText.scale.y, 0.75, 0.05));
        }

        
        super.update(elapsed);
	}

    
}
