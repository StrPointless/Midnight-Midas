import ObjectRegistry.GameObjectData;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxColor;
import sys.FileSystem;

class ObjectEditorState extends FlxState
{
	public var uiSubState:ObjectEditorUISubState;

	public var camHUD:FlxCamera;
	public var camEditor:FlxCamera;

	public var curRegistry:ObjectRegistry;
	public var curObject:GameObjectData;

	public var objectDisplay:ModifiedFlxSprite;

	public var curHitBox:FlxSprite;

	public override function create()
	{
		persistentDraw = true;
		persistentUpdate = true;
		super.create();

		camEditor = new FlxCamera();
		camHUD = new FlxCamera();
		FlxG.cameras.reset(camEditor);
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.add(camHUD);

		uiSubState = new ObjectEditorUISubState();
		uiSubState.cameras = [camHUD];
		uiSubState.objState = this;

		openSubState(uiSubState);

		curRegistry = new ObjectRegistry();

		objectDisplay = new ModifiedFlxSprite(0, 0);
		objectDisplay.screenCenter();
		add(objectDisplay);
	}

	public override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.pressed.SHIFT)
			uiSubState.increaseSteppers(true);
		else
			uiSubState.increaseSteppers(false);
	}

	public function newObject()
	{
		curObject = ObjectRegistry.createObjectData();
		trace("Object sucessfully created");
	}

	public function newRegistry()
	{
		curRegistry = new ObjectRegistry();
		trace("New Registry Created");
	}

	public function newHitbox()
	{
		curHitBox = new FlxSprite().makeGraphic(200, 200, FlxColor.RED);
		curHitBox.alpha = 0.5;
		curHitBox.setPosition(objectDisplay.getGraphicMidpoint().x, objectDisplay.getGraphicMidpoint().y);
		add(curHitBox);
	}

	public function updateImagePath(path:String)
	{
		if (FileSystem.exists("assets/images/" + path + ".png"))
		{
			objectDisplay.loadGraphic("assets/images/" + path + ".png");
			trace("OK YEAH");
		}
		else
		{
			trace("NUH UH");
		}
	}
}