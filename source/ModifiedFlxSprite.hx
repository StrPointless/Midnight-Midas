import Level.ObjectData;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import openfl.display.ShaderParameter;

class ModifiedFlxSprite extends FlxSprite
{
	public var spriteTag:String = '';
	public var scrollSet:Bool = false;
	public var shaderSet = false;
	public var customColor:CustomColorManipulation;
	public var customShader:TestShader;
	public var ogPath:String = "";

	public var ogDataCopy:ObjectData;

	public var subText:String;

	public var eventCalled:Bool;

	// got this one from unity
	public function new(_x:Float, _y:Float, ?_graphic:Null<FlxGraphicAsset>)
	{
		customShader = new TestShader();
		shader = customShader;
		customColor = new CustomColorManipulation();
		shaderSet = true;

		customShader.saturation.value = [0];
		customShader.contrast.value = [0];
		customShader.brightness.value = [0];

		resetColorValues();

		super(_x, _y);
		if (graphic != null)
			loadGraphic(_graphic);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		updateShaderColorValues();
	}
	public function resetColorValues()
	{
		customShader.saturation.value[0] = 1;
		customShader.contrast.value[0] = 1;
		customShader.brightness.value[0] = 0;
	}

	public function updateShaderColorValues()
	{
		customShader.saturation.value[0] = customColor.saturation;
		customShader.contrast.value[0] = customColor.contrast;
		customShader.brightness.value[0] = customColor.brightness;
	}

	public function setColorValues(_brightness:Float, _saturation:Float, _contrast:Float)
	{
		customColor.saturation = _saturation;
		customColor.contrast = _contrast;
		customColor.brightness = _brightness;
	}
}

class CustomColorManipulation
{
	public var saturation:Float = 1;
	public var contrast:Float = 1;
	public var brightness:Float = 0;

	public function new(_saturation:Float = 1, _contrast:Float = 1, _brightness:Float = 0)
	{
		saturation = _saturation;
		contrast = _contrast;
		brightness = _brightness;
	}
}