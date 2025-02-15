import flixel.FlxCamera;
import flixel.FlxObject;
import flixel.math.FlxMath;
import flixel.util.FlxColor;

class GameCamera extends FlxCamera
{
	/**
	 * The zoom the camera returns to for lerp
	 */
	public var camZoom:Float = 1;
	/**
	 * The angle the camera returns to for lerp
	 */
	public var camAngle:Float = 0;

	public var camZoomLerp:Float = 0.05;
	public var camAngleLerp:Float = 0.05;
	public var camFollowLerp:Float = 0.075;

	/**
	 * whether to not change the camera during shake, zoom, or rotation effects
	 */
	public var staticCamera:Bool = false;
	/**
	 * prevents any flashing lights
	 */
	public var noFlashingLights:Bool = false;

	/**
	 * Whether the camera's independent to zoom or angle lerps
	 */
	public var independent:Bool;

	public function new()
	{
		super();
	}

	public function setFollowObject(object:FlxObject)
	{
		follow(object, LOCKON, camFollowLerp);
	}

	public function setFollowLerp(lerp:Float = 0.075)
	{
		followLerp = lerp;
	}

	public override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (!independent)
		{
			zoom = FlxMath.lerp(zoom, camZoom, camZoomLerp);
			angle = FlxMath.lerp(angle, camAngle, camAngleLerp);
		}
	}

	public function shakeCamera(intensity:Float = 0.01, time:Float = 0.1)
	{
		if (!staticCamera)
		{
			shake(intensity, time);
		}
	}

	public function rotateCamera(daAngle:Float)
	{
		this.angle = daAngle;
		camAngle = daAngle;
	}

	public function pulseZoom(zoom:Float = 1)
	{
		if (!staticCamera)
			this.zoom = zoom;
	}

	public function pulseRotate(daAngle)
	{
		if (!staticCamera)
			this.angle = daAngle;
	}

	public function camflash(color:FlxColor, time:Float)
	{
		if (!noFlashingLights)
			flash(color, time);
	}
}