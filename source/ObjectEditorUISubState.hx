import ObjectEditorMenuView.ObjectEditorData;
import ObjectEditorMenuView.ObjectEditorMainView;
import flixel.FlxG;
import flixel.FlxSubState;
import haxe.ui.Toolkit;
import haxe.ui.core.Screen;
import haxe.ui.focus.FocusManager;
import haxe.ui.themes.Theme;

class ObjectEditorUISubState extends FlxSubState
{
	public var objState:ObjectEditorState;

	public var mainView:ObjectEditorMainView;
	public var objData:ObjectEditorData;

	override public function create()
	{
		FlxG.mouse.useSystemCursor = true;
		FlxG.mouse.visible = true;

		if (!Toolkit.initialized)
		{
			Toolkit.init();
			Toolkit.theme = Theme.DARK;
		}

		mainView = new ObjectEditorMainView();
		mainView.cameras = this.cameras;
		Screen.instance.addComponent(mainView);

		mainView.newStuff.onClick = function(e)
		{
			objState.newRegistry();
		}
		mainView.newObj.onClick = function(e)
		{
			objState.newObject();
		}
		mainView.newHitBoxButton.onClick = function(e)
		{
			objState.newHitbox();
		}

		objData = new ObjectEditorData();
		objData.cameras = this.cameras;
		objData.x += 950;
		objData.y += 50;

		objData.imaePathField.onChange = function(e)
		{
			objState.updateImagePath(objData.imaePathField.text);
		}
		objData.h_height.onChange = function(e)
		{
			updateCurHitbox(-1, objData.h_height.value);
		}
		objData.h_width.onChange = function(e)
		{
			updateCurHitbox(objData.h_width.value);
		}
		objData.h_xPos.onChange = function(e)
		{
			updateCurHitbox(-1, -1, objData.h_xPos.value);
		}
		objData.h_yPos.onChange = function(e)
		{
			updateCurHitbox(-1, -1, -10000, objData.h_yPos.value);
		}
		Screen.instance.addComponent(objData);

		FocusManager.instance.enabled = false;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	public function updateSteppers()
	{
		if (objState.curHitBox != null)
		{
			objData.h_height.value = objState.curHitBox.height;
		}
	}

	public function updateCurHitbox(?width:Int = -1, ?height:Int = -1, ?xPos:Float = -10000, ?yPos:Float = -10000)
	{
		if (objState.curHitBox != null)
		{
			if (width != -1)
				objState.curHitBox.setGraphicSize(width, objState.curHitBox.height);
			if (height != -1)
				objState.curHitBox.setGraphicSize(objState.curHitBox.width, height);
			if (xPos != -10000)
				objState.curHitBox.offset.set(-xPos, objState.curHitBox.offset.y);
			if (yPos != -10000)
				objState.curHitBox.offset.set(objState.curHitBox.offset.x, yPos);
		}
	}

	public function increaseSteppers(?doIt:Bool = false)
	{
		if (objData != null)
		{
			switch (doIt)
			{
				case true:
					objData.h_width.step = 50;
					objData.h_height.step = 50;
					objData.h_xPos.step = 10;
					objData.h_yPos.step = 10;
					trace("BOOST");
				case false:
					objData.h_width.step = 10;
					objData.h_height.step = 10;
					objData.h_xPos.step = 1;
					objData.h_yPos.step = 1;
					trace("No BOOST");
			}
		}
	}
}