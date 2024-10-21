import MainView.ObjectDataView;
import flixel.FlxG;
import flixel.FlxSubState;
import haxe.ui.core.Screen;
import haxe.ui.focus.FocusManager;

class CustomUISubstate extends FlxSubState
{
	public var mainView:MainView;
	public var objectDataView:ObjectDataView;
	public var levelEditorState:LevelEditorState;

	public var hoveringOverUI:Bool = false;

	override public function create()
	{
		FlxG.mouse.useSystemCursor = true;

		mainView = new MainView();
		mainView.cameras = this.cameras;
		mainView.loadLevelBttn.onClick = function(e)
		{
			levelEditorState.openLoadDialog();
		}
		mainView.saveLevelBttn.onClick = function(e)
		{
			levelEditorState.saveLevel();
		}
		mainView.newLevelBttn.onClick = function(e)
		{
			levelEditorState.newLevel();
		}
		mainView.exitEditorBttn.onClick = function(e)
		{
			levelEditorState.exitEditor();
		}
		Screen.instance.addComponent(mainView);

		objectDataView = new ObjectDataView();
		objectDataView.cameras = this.cameras;
		objectDataView.x += 950;
		objectDataView.y += 50;

		objectDataView.scrollXStepper.onChange = function(e)
		{
			if (levelEditorState.curSelectedObject != null && !levelEditorState.curSelectedObject.scrollSet)
				levelEditorState.curSelectedObject.scrollSet = true;
		}
		objectDataView.scrollYStepper.onChange = function(e)
		{
			if (levelEditorState.curSelectedObject != null && !levelEditorState.curSelectedObject.scrollSet)
				levelEditorState.curSelectedObject.scrollSet = true;
		}

		objectDataView.curModeDisplay.text = "Cur Mode: " + levelEditorState.curMode;
		Screen.instance.addComponent(objectDataView);

		FocusManager.instance.enabled = false;
	}

	override public function update(elapsed:Float)
	{
		FlxG.watch.addQuick("hovering", hoveringOverUI);
		objectDataView.curModeDisplay.text = "Cur Mode: " + levelEditorState.curMode;

		if (levelEditorState.curSelectedObject != null)
		{
			levelEditorState.curSelectedObject.flipX = objectDataView.flipXBox.selected;
			levelEditorState.curSelectedObject.flipY = objectDataView.flipYBox.selected;
			levelEditorState.curSelectedObject.customColor.brightness = objectDataView.tintStepper.value;
			levelEditorState.curSelectedObject.solid = objectDataView.solidCheck.selected;
			levelEditorState.curSelectedObject.angle = objectDataView.angleStepper.value;
			levelEditorState.curSelectedObject.scrollFactor.set(objectDataView.scrollXStepper.value, objectDataView.scrollYStepper.value);
			levelEditorState.curSelectedObject.subText = objectDataView.subTextField.text;
		}

		hoveringOverUI = (FlxG.mouse.overlaps(objectDataView, levelEditorState.camHUD)
			|| FlxG.mouse.overlaps(mainView, levelEditorState.camHUD)) ? true : false;

		super.update(elapsed);
	}

	public function onSelectedObjChange(obj:ModifiedFlxSprite)
	{
		objectDataView.flipXBox.selected = obj.flipX;
		objectDataView.flipYBox.selected = obj.flipY;
		objectDataView.tintStepper.value = (obj.customColor != null) ? obj.customColor.brightness : 0;
		objectDataView.solidCheck.selected = obj.solid;
		objectDataView.scrollXStepper.value = obj.scrollFactor.x;
		objectDataView.scrollYStepper.value = obj.scrollFactor.y;
		objectDataView.angleStepper.value = obj.angle;
		objectDataView.subTextField.text = obj.subText;
	}
}