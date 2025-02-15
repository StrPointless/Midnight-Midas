import Level.LevelData;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxOutlineEffect;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import haxe.ui.Toolkit;
import haxe.ui.containers.dialogs.Dialogs;
import haxe.ui.themes.Theme;
import openfl.Assets;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.FileReference;
import sys.io.File;
import systools.Dialogs;

using StringTools;

class LevelEditorState extends FlxState
{
	public var uiSubState:CustomUISubstate;

	public var selectedObject:FlxSprite;

	public var curScale:Float = 1;

	public var objectMap:Map<String, String> = [
		"buildingA" => "assets/images/buildingA.png",
		"buildingB" => "assets/images/buildingB.png",
		"buildingC" => "assets/images/buildingC.png",
		"buildingD" => "assets/images/buildingD.png",
		"buildingE" => "assets/images/buildingE.png",
		"buildingF" => "assets/images/buildingF.png",
		"FloorRockA" => "assets/images/FloorRockA.png",
		"FloorRockB" => "assets/images/FloorRockB.png",
		"ceilingRockA" => "assets/images/ceilingRockA.png",
		"ceilingRockB" => "assets/images/ceilingRockB.png",
		"ceilingRockC" => "assets/images/ceilingRockC.png",
		"crateA" => "assets/images/crateA.png",
		"pipeA" => "assets/images/pipeA.png",
		"pipeB" => "assets/images/pipeB.png",
		"transformer" => "assets/images/transformer.png",
		"darkness" => "assets/images/darkness.png",
		"spikes0" => "assets/images/spikes0.png",
		"spikes1" => "assets/images/spikes1.png",
		"midBG0" => "assets/images/midBG0.png",
		"midBG1" => "assets/images/midBG1.png",
		"midBG2" => "assets/images/midBG2.png",
		//
		"buildingA_DARK" => "assets/images/buildingA_DARK.png",
		"buildingD_DARK" => "assets/images/buildingD_DARK.png",
		"crateA_DARK" => "assets/images/crateA_DARK.png",
		"FloorRockA_DARK" => "assets/images/FloorRockA_DARK.png",
		"FloorRockB_DARK" => "assets/images/FloorRockB_DARK.png",
		"ceilingRockA_DARK" => "assets/images/ceilingRockA_DARK.png",
		"ceilingRockB_DARK" => "assets/images/ceilingRockB_DARK.png",
		"sign" => "assets/images/sign.png",
		"black" => "black",
		//
		"playerRef" => "playerRef",
		"camShiftEvent" => "camShiftEvent",
		"camStopEvent" => "camStopEvent",
		"levelEndEvent" => "levelEndEvent",
		"defenseMiddle" => "defenseMiddle",
		"subtitlePart" => "subtitlePart"
	];

	public var objectList:Array<String> = [
		"buildingA", "buildingB", "buildingC", "buildingD", "buildingE", "buildingF", "FloorRockA", "FloorRockB", "ceilingRockA", "ceilingRockB",
		"ceilingRockC", "crateA", "pipeA", "pipeB", "transformer", "spikes0", "spikes1", "midBG0", "midBG1", "midBG2", "buildingA_DARK", "buildingD_DARK",
		"crateA_DARK", "FloorRockA_DARK", "FloorRockB_DARK", "ceilingRockA_DARK", "ceilingRockB_DARK", "sign", "black", "darkness", "playerRef",
		"camShiftEvent", "camStopEvent", "levelEndEvent", "defenseMiddle", "subtitlePart",
	];
	public var curObjectNumb:Int;

	public var camEditor:FlxCamera;
	public var camHUD:FlxCamera;

	public var camFollow:FlxObject;
	public var defaultMoveValue:Float = 5;
	public var moveValueMultiplier:Float = 2;

	public var levelData:LevelData;
	public var _file:FileReference;

	public var objectGroup:FlxTypedGroup<ModifiedFlxSprite>;

	public var curSelectedObject:ModifiedFlxSprite;
	public var curSelectedObjectOutline:FlxSprite;

	public var curSelectedObjects:FlxTypedGroup<ModifiedFlxSprite>;
	public var curSelectedObjectsOutlines:FlxTypedGroup<FlxSprite>;

	public var curMode:String = "draw";

	public var movingObject:Bool = false;

	//-1 All Visible, Else: specific stuff
	public var zLevel:Int = 0;
	public var zObjectGroups:FlxTypedGroup<FlxTypedGroup<ModifiedFlxSprite>>;
	public var hiddenLayerArray:Array<Bool>;
	public var clickrefPoint:FlxPoint;

	public var curSelectedObjectDisplayText:FlxText;
	public var curSelectedObjectDisplayTextStartPos:FlxPoint;
	public var curSelectedObjectDisplaySubText:FlxText;
	public var curSelectedObjectDisplaySubTextStartPos:FlxPoint;

	

	// at the end, if you touch the gold it restarts


	public function new(data:LevelData)
	{
		levelData = data;
		super();
	}

	public override function create()
	{
		FlxG.mouse.visible = true;
		camEditor = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camEditor);
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camEditor];

		trace("State start");
		trace(Assets.exists("assets/images/buildingA.png"));


		objectGroup = new FlxTypedGroup<ModifiedFlxSprite>();
		add(objectGroup);

		zObjectGroups = new FlxTypedGroup<FlxTypedGroup<ModifiedFlxSprite>>();
		for (i in 0...10)
		{
			trace("Created group " + i);
			var group = new FlxTypedGroup<ModifiedFlxSprite>();
			group.ID = i;
			zObjectGroups.add(group);
		}
		add(zObjectGroups);
		hiddenLayerArray = new Array<Bool>();
		for (i in 0...10)
		{
			hiddenLayerArray.push(true);
		}
		// curSelectedObjects = new Array<ModifiedFlxSprite>();
		// curSelectedObjectsOutlines = new Array<FlxSprite>();

		selectedObject = new FlxSprite(0, 0, objectMap[objectList[0]]);
		selectedObject.alpha = 0.5;
		selectedObject.scrollFactor.set();
		// selectedObject.cameras = [camHUD];
		add(selectedObject);

		curSelectedObjectDisplayText = new FlxText(0, 0, 3000, "Selected Object: ", 28);
		curSelectedObjectDisplayText.setFormat(null, 28, FlxColor.WHITE, CENTER);
		curSelectedObjectDisplayText.screenCenter();
		curSelectedObjectDisplayText.y += 300;
		curSelectedObjectDisplayText.cameras = [camHUD];
		add(curSelectedObjectDisplayText);

		curSelectedObjectDisplaySubText = new FlxText(0, 0, 3000, "< Object: 0 / 999 >", 28);
		curSelectedObjectDisplaySubText.setFormat(null, 18, FlxColor.WHITE, CENTER);
		curSelectedObjectDisplaySubText.screenCenter();
		curSelectedObjectDisplaySubText.y += 330;
		curSelectedObjectDisplaySubText.alpha = 0.5;
		curSelectedObjectDisplaySubText.cameras = [camHUD];
		add(curSelectedObjectDisplaySubText);

		curSelectedObjectDisplaySubTextStartPos = new FlxPoint(curSelectedObjectDisplaySubText.x, curSelectedObjectDisplaySubText.y);
		curSelectedObjectDisplayTextStartPos = new FlxPoint(curSelectedObjectDisplayText.x, curSelectedObjectDisplayText.y);

		Toolkit.init();
		Toolkit.theme = Theme.DARK;
		uiSubState = new CustomUISubstate();
		uiSubState.cameras = [camHUD];
		uiSubState.levelEditorState = this;

		openSubState(uiSubState);

		persistentDraw = true;
		persistentUpdate = true;

		camFollow = new FlxObject();
		camFollow.solid = false;
		add(camFollow);

		super.create();
		camEditor.follow(camFollow, LOCKON, 0.05);

		reloadLevel(levelData);
		clickrefPoint = new FlxPoint();
	}

	public override function update(elasped:Float)
	{
		if (FlxG.keys.justPressed.TAB)
			switch (curMode)
			{
				case 'draw':
					curMode = 'edit';
					trace("swapped to edit mode");
					curSelectedObject = null;
				case 'edit':
					curMode = 'draw';
					trace("swapped to draw mode");
			}

		if (curMode == "draw")
		{
			curScale = 1;
			if (FlxG.keys.justPressed.N)
			{
				curObjectNumb++;
				if (curObjectNumb > objectList.length - 1)
					curObjectNumb = 0;

				if (objectMap[objectList[curObjectNumb]] == "playerRef")
					selectedObject.makeGraphic(50, 100, FlxColor.WHITE);
				else if (objectMap[objectList[curObjectNumb]] == "camShiftEvent")
					selectedObject.makeGraphic(100, 100, FlxColor.BLUE);
				else if (objectMap[objectList[curObjectNumb]] == "camStopEvent")
					selectedObject.makeGraphic(100, 100, FlxColor.YELLOW);
				else if (objectMap[objectList[curObjectNumb]] == "levelEndEvent")
					selectedObject.makeGraphic(100, 100, FlxColor.GREEN);
				else if (objectMap[objectList[curObjectNumb]] == "defenseMiddle")
					selectedObject.makeGraphic(100, 100, FlxColor.PINK);
				else if (objectMap[objectList[curObjectNumb]] == "black")
					selectedObject.makeGraphic(100, 100, FlxColor.BLACK);
				else if (objectMap.get(objectList[curObjectNumb]) == "subtitlePart")
					selectedObject.makeGraphic(100, 100, FlxColor.PURPLE);
				else if (objectMap.get(objectList[curObjectNumb]) == "playerRef")
					selectedObject.makeGraphic(50, 100, FlxColor.WHITE);
				else
					selectedObject.loadGraphic(objectMap[objectList[curObjectNumb]], false, 0, 0, true);
				trace("swapped to " + objectList[curObjectNumb]);
			}
			if (FlxG.keys.justPressed.M)
			{
				curObjectNumb--;
				if (curObjectNumb < 0)
					curObjectNumb = objectList.length - 1;

				if (objectMap[objectList[curObjectNumb]] == "playerRef")
					selectedObject.makeGraphic(50, 100, FlxColor.WHITE);
				else if (objectMap[objectList[curObjectNumb]] == "camShiftEvent")
					selectedObject.makeGraphic(100, 100, FlxColor.BLUE);
				else if (objectMap[objectList[curObjectNumb]] == "camStopEvent")
					selectedObject.makeGraphic(100, 100, FlxColor.YELLOW);
				else if (objectMap[objectList[curObjectNumb]] == "levelEndEvent")
					selectedObject.makeGraphic(100, 100, FlxColor.GREEN);
				else if (objectMap[objectList[curObjectNumb]] == "defenseMiddle")
					selectedObject.makeGraphic(100, 100, FlxColor.PINK);
				else if (objectMap[objectList[curObjectNumb]] == "black")
					selectedObject.makeGraphic(100, 100, FlxColor.BLACK);
				else if (objectMap.get(objectList[curObjectNumb]) == "subtitlePart")
					selectedObject.makeGraphic(100, 100, FlxColor.PURPLE);
				else if (objectMap.get(objectList[curObjectNumb]) == "playerRef")
					selectedObject.makeGraphic(50, 100, FlxColor.WHITE);
				else
					selectedObject.loadGraphic(objectMap[objectList[curObjectNumb]], false, 0, 0, true);
				trace("swapped to " + objectList[curObjectNumb]);
			}
			if (FlxG.mouse.justPressed)
			{
				var newSprite:ModifiedFlxSprite = new ModifiedFlxSprite(0, 0);
				if (objectMap.get(objectList[curObjectNumb]) != "playerRef")
					newSprite.loadGraphic(selectedObject.graphic);
				else if (objectMap.get(objectList[curObjectNumb]) == "camShiftEvent")
					newSprite.makeGraphic(100, 100, FlxColor.WHITE);
				else if (objectMap[objectList[curObjectNumb]] == "camStopEvent")
					newSprite.makeGraphic(100, 100, FlxColor.YELLOW);
				else if (objectMap[objectList[curObjectNumb]] == "levelEndEvent")
					newSprite.makeGraphic(100, 100, FlxColor.GREEN);
				else if (objectMap[objectList[curObjectNumb]] == "defenseMiddle")
					selectedObject.makeGraphic(100, 100, FlxColor.PINK);
				else if (objectMap.get(objectList[curObjectNumb]) == "black")
					newSprite.makeGraphic(100, 100, FlxColor.BLACK);
				else if (objectMap.get(objectList[curObjectNumb]) == "subtitlePart")
					newSprite.makeGraphic(100, 100, FlxColor.PURPLE);
				else if (objectMap.get(objectList[curObjectNumb]) == "playerRef")
					newSprite.makeGraphic(50, 100, FlxColor.WHITE);
				newSprite.spriteTag = objectMap.get(objectList[curObjectNumb]);
				newSprite.x = FlxG.mouse.getWorldPosition(camEditor).x;
				newSprite.y = FlxG.mouse.getWorldPosition(camEditor).y;
				newSprite.scale.set(curScale, curScale);
				newSprite.solid = true;
				if (zLevel == -1)
					newSprite.objectZLevel = 0;
				else
					newSprite.objectZLevel = zLevel;
				newSprite.updateHitbox();
				// trace(zObjectGroups);
				// add(newSprite);
				trace(zLevel);

				for (i in zObjectGroups.members)
				{
					if (i.ID == newSprite.objectZLevel)
						i.add(newSprite);
				}
				// zObjectGroups.members[newSprite.objectZLevel].add(newSprite);
				for (i in zObjectGroups)
				{
					if (i != null)
						trace("Not null Group");
					else
						trace("Null group");
				}
			}
			if (selectedObject != null)
			{
				selectedObject.setPosition(FlxG.mouse.screenX, FlxG.mouse.screenY);
				selectedObject.scale.set(curScale, curScale);
				selectedObject.alpha = 0.5;
			}
		}
		if (!uiSubState.hoveringOverUI && FlxG.mouse.justPressed && !FlxG.mouse.overlaps(objectGroup) && curSelectedObject != null)
		{
			trace("removed curSelected");
			curSelectedObject = null;
			remove(curSelectedObjectOutline);
		}
		if (curSelectedObjectOutline != null)
			curSelectedObjectOutline.alpha = FlxMath.lerp(curSelectedObjectOutline.alpha, 0.25, 0.09);
		if (curMode == "edit")
		{
			if (curSelectedObject != null && FlxG.mouse.overlaps(curSelectedObject) && FlxG.mouse.pressed)
				movingObject = true;
			if (movingObject && FlxG.mouse.released)
				movingObject = false;
			selectedObject.alpha = 0;
			if (getCurrentZlevelGroup() != null)
			{
				for (i in getCurrentZlevelGroup())
				{
					if (FlxG.mouse.justPressed && FlxG.mouse.overlaps(i) && !uiSubState.hoveringOverUI)
					{
						uiSubState.onSelectedObjChange(i);
						curSelectedObject = i;
						curScale = curSelectedObject.scale.x;
						trace("selected " + i);
					}
				}
			}
			if (curSelectedObject != null)
			{
				if (FlxG.keys.justPressed.NUMPADFIVE)
					movingObject = !movingObject;
				if (movingObject)
				{
					curSelectedObject.setPosition(curSelectedObject.x + FlxG.mouse.deltaX, curSelectedObject.y + FlxG.mouse.deltaY);
					curSelectedObject.scale.set(curScale, curScale);

				}
				if (FlxG.keys.justPressed.NUMPADONE)
				{
					for (index => value in objectGroup.members)
					{
						if (value == curSelectedObject && index - 1 - (FlxG.keys.pressed.SHIFT ? 1 : 0) > -1)
						{
							var daGuy = objectGroup.remove(value, true);
							objectGroup.insert(index - 1 - (FlxG.keys.pressed.SHIFT ? 1 : 0), daGuy);
						}
					}
				}
				if (FlxG.keys.justPressed.NUMPADSEVEN)
				{
					for (index => value in objectGroup.members)
					{
						if (value == curSelectedObject && index + 1 + (FlxG.keys.pressed.SHIFT ? 1 : 0) < objectGroup.length)
						{
							var daGuy = objectGroup.remove(value, true);
							objectGroup.insert(index + 1 + (FlxG.keys.pressed.SHIFT ? 1 : 0), daGuy);
						}
					}
				}
				if (FlxG.mouse.justPressedRight)
					curSelectedObject = null;

				if (FlxG.keys.justPressed.DELETE)
				{
					getCurrentZlevelGroup().remove(curSelectedObject);
					// remove(curSelectedObjectOutline);
					// objectGroup.remove(curSelectedObject, true);
					curSelectedObject = null;
				}
			}
		}

		if (FlxG.mouse.wheel != 0)
		{
			curScale += FlxG.mouse.wheel / 10;
			if (curSelectedObject != null)
				curSelectedObject.updateHitbox();
		}

		if (FlxG.keys.pressed.LEFT)
			camFollow.x -= defaultMoveValue * moveValueMultiplier;
		if (FlxG.keys.pressed.RIGHT)
			camFollow.x += defaultMoveValue * moveValueMultiplier;
		if (FlxG.keys.pressed.UP)
			camFollow.y -= defaultMoveValue * moveValueMultiplier;
		if (FlxG.keys.pressed.DOWN)
			camFollow.y += defaultMoveValue * moveValueMultiplier;

		// trace(camFollow);

		if (FlxG.keys.justPressed.Q)
			camEditor.zoom -= 0.1;
		if (FlxG.keys.justPressed.E)
			camEditor.zoom += 0.1;

		moveValueMultiplier = FlxG.keys.pressed.SHIFT ? 2 : 1;

		if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.S)
			saveLevel();
		if (FlxG.keys.justPressed.SEVEN)
			for (i in zObjectGroups.members)
			{
				trace(i.ID);
				if (i.length > 0)
				{
					trace("ITEMS:");
					for (b in i.members)
					{
						trace(b);
					}
				}
				else
				{
					trace("EMPTY");
				}
			}

		if (curMode == "draw")
		{
			curSelectedObjectDisplaySubText.y = FlxMath.lerp(curSelectedObjectDisplaySubText.y, curSelectedObjectDisplaySubTextStartPos.y, 0.05);
			curSelectedObjectDisplayText.y = FlxMath.lerp(curSelectedObjectDisplayText.y, curSelectedObjectDisplayTextStartPos.y, 0.05);
			curSelectedObjectDisplayText.text = "Selected Object: " + objectList[curObjectNumb];
			curSelectedObjectDisplaySubText.text = "< Object: " + curObjectNumb + " / " + (objectList.length - 1) + " >";
		}
		else
		{
			curSelectedObjectDisplaySubText.y = FlxMath.lerp(curSelectedObjectDisplaySubText.y, curSelectedObjectDisplaySubTextStartPos.y + 300, 0.02);
			curSelectedObjectDisplayText.y = FlxMath.lerp(curSelectedObjectDisplayText.y, curSelectedObjectDisplayTextStartPos.y + 300, 0.02);
		}
		super.update(elasped);
		reorderZLevel();
	}
	public function setZLevel(lvl:Int)
	{
		zLevel = lvl;

		trace("Setting z level to " + lvl);
		uiSubState.objectDataView.hiddenCheck.value = hiddenLayerArray[zLevel];

		for (i in zObjectGroups.members)
		{
			if (hiddenLayerArray[i.ID] == false)
				i.visible = false;
			else
				i.visible = true;
			if (i.ID != zLevel || zLevel != -1)
				for (a in i)
				
					{
						a.alpha = 0.5;
					}
			if (i.ID == zLevel || zLevel == -1)
				{
				for (a in i)
					{
						a.alpha = 1;
					}
				}

		}
	}

	public function reloadLevel(data:LevelData)
	{
		trace("reloading level data");
		for (i in objectGroup.members)
		{
			// remove(i);
			objectGroup.remove(i);
		}
		// objectGroup = new FlxTypedGroup<ModifiedFlxSprite>();
		if (data.objects.length > 0)
		{
			for (i in data.objects)
			{
				var newSprite:ModifiedFlxSprite = new ModifiedFlxSprite(i.position[0], i.position[1]);
				if (i.graphicPath != "playerRef")
					newSprite.loadGraphic(i.graphicPath);
				if (i.graphicPath == "playerRef")
					newSprite.makeGraphic(50, 100, FlxColor.WHITE);
				if (i.graphicPath == "black")
					newSprite.makeGraphic(100, 100, FlxColor.BLACK);
				if (i.graphicPath == "camStopEvent")
					newSprite.makeGraphic(100, 100, FlxColor.YELLOW);
				if (i.graphicPath == "levelEndEvent")
					newSprite.makeGraphic(100, 100, FlxColor.GREEN);
				if (i.graphicPath == "defenseMiddle")
					newSprite.makeGraphic(100, 100, FlxColor.PINK);
				if (i.graphicPath == "subtitlePart")
					newSprite.makeGraphic(100, 100, FlxColor.PURPLE);
				if (i.graphicPath == "camShiftEvent")
					newSprite.makeGraphic(100, 100, FlxColor.BLUE);
				newSprite.spriteTag = i.graphicPath;
				// newSprite.x = FlxG.mouse.getWorldPosition(camEditor).x;
				// newSprite.y = FlxG.mouse.getWorldPosition(camEditor).y;
				newSprite.flipX = i.xFlip;
				newSprite.flipY = i.yFlip;
				newSprite.setColorValues(0, 1, 1);
				newSprite.solid = i.solid;
				newSprite.subText = i.text;
				newSprite.angle = i.daAngle;
				newSprite.customColor.brightness = i.tint;
				newSprite.scale.set(i.scale[0], i.scale[1]);
				newSprite.objectZLevel = i.zLevel;
				if (i.daScroll[0] != 1 && !i.scrollSet)
					i.scrollSet = true;
				if (i.scrollSet)
					newSprite.scrollFactor.set(i.daScroll[0], i.daScroll[1]);
				newSprite.updateHitbox();
				// add(newSprite);
				for (b in zObjectGroups.members)
				{
					if (b.ID == i.zLevel)
						b.add(newSprite);
				}
			}
		}
	}

	public function saveLevel()
	{
		var daObjects = [];
		if (levelData.type == "" || levelData.type == null)
			levelData.type = "normal";
		var daData:LevelData = {
			objects: daObjects,
			type: levelData.type
		}
		for (a in zObjectGroups.members)
		{
			for (i in a.members)
			{
				if (daObjects == null)
					daObjects = [];
				if (i != null)
					daObjects.push({
						graphicPath: i.spriteTag,
						position: [i.x, i.y],
						scale: [i.scale.x, i.scale.y],
						xFlip: i.flipX,
						yFlip: i.flipY,
						tint: i.customColor.brightness,
						solid: i.solid,
						daScroll: [i.scrollFactor.x, i.scrollFactor.y],
						scrollSet: i.scrollSet,
						daAngle: i.angle,
						text: i.subText,
						zLevel: i.objectZLevel
					});
			}
			trace("objAdded");
		}
		levelData = daData;
		trace("getting levelData");

		var data:String = Json.stringify(daData);
		// trace(data);

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), "level.json");
		}
	}

	public function reorderZLevel()
	{
		// trace("reordering z level");

		// trace(zObjectGroups.members);
		zObjectGroups.sort((order, obj1, obj2) ->
		{
			return FlxSort.byValues(order, obj1.ID, obj2.ID);
		}, FlxSort.DESCENDING);
	}
	public function exitEditor()
	{
		FlxG.switchState(new PlayState());
	}

	public function newLevel()
	{
		var data:LevelData = {
			objects: [],
			type: "normal"
		}
		FlxG.switchState(new LevelEditorState(data));
	}

	function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved LEVEL DATA.");
	}

	function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving Level data");
	}

	public function openLoadDialog()
	{
		var filters:FILEFILTERS = {
			count: 1,
			descriptions: ["JSON files"],
			extensions: ["*.json"]
		};
		var result:Array<String> = Dialogs.openFile("Select a file please!", "Please select one or more files, so we can see if this method works", filters);

		_onSelect(result);
	}

	function _onSelect(arr:Array<String>):Void
	{
		if (arr != null && arr.length > 0)
		{
			trace(arr[0]);
			var data:Level.LevelData = Json.parse(File.getContent(arr[0]));
			FlxG.switchState(new LevelEditorState(data));
			// reloadLevel(data);
		}
		else
		{
			_onCancel(null);
		}
	}

	function _onCancel(_):Void
	{
		trace("Cancelled!");
	}

	function _onCancelEvent(_):Void
	{
		trace("Cancelled!");
	}
	public function getCurrentZlevelGroup()
	{
		var daGroup = null;
		for (i in zObjectGroups.members)
		{
			if (i.ID == zLevel)
			{
				daGroup = i;
			}
		}
		return daGroup;
	}

	public function testLevel()
	{
		var daObjects = [];
		if (levelData.type == "" || levelData.type == null)
			levelData.type = "normal";
		var daData:LevelData = {
			objects: daObjects,
			type: levelData.type
		}
		for (a in zObjectGroups.members)
		{
			if (daObjects == null)
				daObjects = [];
			for (i in a)
			{
				if (i != null)
					daObjects.push({
						graphicPath: i.spriteTag,
						position: [i.x, i.y],
						scale: [i.scale.x, i.scale.y],
						xFlip: i.flipX,
						yFlip: i.flipY,
						tint: i.customColor.brightness,
						solid: i.solid,
						daScroll: [i.scrollFactor.x, i.scrollFactor.y],
						scrollSet: i.scrollSet,
						daAngle: i.angle,
						text: i.subText,
						zLevel: i.objectZLevel
					});
			}
			trace("objAdded");
		}
		levelData = daData;
		trace(levelData);
		var daPlayState = new PlayState();
		daPlayState.forcedLevel = true;
		daPlayState.forcedLevelData = daData;

		FlxG.switchState(daPlayState);
	}
}