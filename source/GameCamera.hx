import flixel.FlxCamera;
import flixel.FlxObject;
import flixel.math.FlxMath;

class GameCamera extends FlxCamera
{
	public var camZoom:Float = 1;
	public var camAngle:Float = 0;

	public var camZoomLerp:Float = 0.05;
	public var camAngleLerp:Float = 0.05;
	public var camFollowLerp:Float = 0.075;

	public var staticCamera:Bool = false;

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

		zoom = FlxMath.lerp(zoom, camZoom, camZoomLerp);
		angle = FlxMath.lerp(angle, camAngle, camAngleLerp);
	}

	public function shakeCamera(intensity:Float = 0.01, time:Float = 0.1)
	{
		if (!staticCamera)
		{
			shake(intensity, time);
		}
	}

	public function rotateCamera(angle:Float)
	{
		if (!staticCamera)
			this.angle = angle;
	}
}