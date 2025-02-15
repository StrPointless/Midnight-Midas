import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.system.FlxAssets.FlxGraphicAsset;
import openfl.Assets;
import openfl.display.ShaderParameter;

class ParticleEffect extends ModifiedFlxSprite
{
	public var playing:Bool = false;
	public var destroying:Bool = false;
	public var fallingAfterSpawn:Bool;

	public function new(x:Float, y:Float, effectType:ParticleType, ?graphic:FlxGraphic)
	{
		super(x, y, graphic);

		frames = FlxAtlasFrames.fromSparrow(Assets.getBitmapData("assets/images/particles/particles.png"),
			Assets.getText("assets/images/particles/particles.xml"));
		switch (effectType)
		{
			case HIT:
				animation.addByPrefix("mainAnim", "particle_Hit", 24, false);
				fallingAfterSpawn = true;
			case JUMP:
				fallingAfterSpawn = false;
				animation.addByPrefix("mainAnim", "particle_Jump", 24, false);
			case SPLASH:
				animation.addByPrefix("mainAnim", "particle_Splash", 24, false);
		}

		animation.play("mainAnim");
		playing = true;
	}

	public override function update(elapsed:Float)
	{
		if (playing && !destroying)
		{
			alpha = FlxMath.lerp(alpha, 0, 0.1);
			y++;
			angle += (flipX ? -0.5 : 0.5);
			if (alpha < 0.05)
			{
				playing = false;
				alpha = 0;
				destroying = true;
				destroy();
			}
			if (!destroying)
				super.update(elapsed);
		}
	}
}

enum ParticleType
{
	HIT;
	JUMP;
	SPLASH;
}