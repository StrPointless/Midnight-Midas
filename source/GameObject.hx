import flixel.FlxSprite;
import flixel.math.FlxPoint;

/**
 * Handles the most of the static stage elements
 */
class GameObject extends FlxSprite
{
	// General Variables
	public var general_objectTag:String;
	public var general_objectZLevel:Int;
	public var general_objectImagePath:String;

	// Game-Used Variables (For win conditions, cam changes, etc)
	// Camera
	public var camera_cameraHoldOnCollision:Bool;
	public var camera_cameraHoldPoint:FlxPoint;
	// Event
	public var event_eventType:GameObjectEventType;
	public var event_called:Bool;

	// Subtitle
	public var event_subtitle_hasSubtitle:Bool;
	public var event_subtitle_text:String;
	public var event_subtitle_textSize:Int;

	// Win
	public var event_win_isWinEvent:Bool;

	public function new()
	{
		super();
	}
}

enum GameObjectEventType
{
	ONESHOT;
	ONENTER;
	ONEXIT;
	ONUPDATE;
	NONE;
}