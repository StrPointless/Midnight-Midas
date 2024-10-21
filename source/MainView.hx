package ;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxImageFrame;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import haxe.ui.components.Button;
import haxe.ui.components.DropDown.DropDownBuilder;
import haxe.ui.components.DropDown.DropDownEvents;
import haxe.ui.components.DropDown.DropDownHandler;
import haxe.ui.components.DropDown;
import haxe.ui.components.Label;
import haxe.ui.containers.VBox;
import haxe.ui.containers.dialogs.Dialog;
import haxe.ui.containers.menus.Menu;
import haxe.ui.core.Component;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.notifications.NotificationManager;
import haxe.ui.notifications.NotificationType;

using StringTools;

@:build(haxe.ui.ComponentBuilder.build("assets/ui/main-view.xml"))
class MainView extends VBox {

    public function new() {
        super();
    }
}
@:build(haxe.ui.ComponentBuilder.build("assets/ui/object-data.xml"))
class ObjectDataView extends VBox {

    public function new() {
        super();
    }
}



