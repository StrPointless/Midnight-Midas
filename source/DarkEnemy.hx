import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.utils.Assets;

class DarkEnemy extends ModifiedFlxSprite
{
	public var player:Player;
	public var dead:Bool = false;
	public var readyToDelete:Bool = false;
	public var shakeTmr:Int = 0;

	public var speed:Float = 1.5;
	public var originalPostion:FlxPoint;
	public var spriteType:Int = 0;
	public var outline:FlxSprite;

	public var isBoss:Bool = false;

	public var hp:Int = 15;

	public var stunTmr:Int = 0;

	public var playedPreHit:Bool = false;
	public var playedGoldHit:Bool = false;

	public var slowMoDead:Bool = false;

	public function new(x:Float, y:Float, ?boss:Bool = false)
	{
		super(x, y);
		speed = speed + FlxG.random.float(-0.1, 3);

		spriteType = FlxG.random.int(0, 1);

		frames = FlxAtlasFrames.fromSparrow("assets/images/darkEnemies.png", Assets.getText("assets/images/darkEnemies.xml"));
		animation.addByPrefix("idle0", "darKEnemy0idle", 12, true);
		animation.addByPrefix("death0", "darKEnemy0Death", 24, false);
		animation.addByPrefix("idle1", "darKEnemy1idle", 12, true);
		animation.addByPrefix("death1", "darKEnemy1Death", 24, false);

		var daShader = new TestShader();
		daShader.saturation.value = [0];
		daShader.contrast.value = [0];

		daShader.contrast.value[0] = 1.55;
		daShader.saturation.value[0] = 1.55;

		shader = daShader;
		isBoss = boss;

		if (!isBoss)
		{
			var daScale = FlxG.random.float(0.15, 0.35);
			scale.set(0.75 + daScale, 0.75 + daScale);
		}
		if (isBoss)
		{
			scale.set(2, 2);
		}
		updateHitbox();

		animation.play("idle" + spriteType, true);
		// makeGraphic(100, 100, FlxColor.CYAN);
		alpha = 0;
		FlxTween.tween(this, {alpha: 1}, 0.25);
	}

	public override function update(elapsed:Float)
	{
		if (player != null && !dead)
			setPosition(FlxMath.lerp(x, player.x, (0.005 * speed) * FlxG.timeScale), FlxMath.lerp(y, player.y, (0.005 * speed) * FlxG.timeScale));
		if (!isBoss && player.overlaps(this) && !dead && player.attacking)
		{
			death();
		}
		if (isBoss && player.overlaps(this) && !dead && player.attacking)
		{
			hp--;
			player.attacking = false;
			if (hp <= 0)
			{
				death();
				player.onBossHurt(true);
				player._canMove = false;
			}
			else
				player.onBossHurt();
			stunTmr = 30;
		}
		if (stunTmr > 0)
			stunTmr--;

		if (shakeTmr > 0)
		{
			setPosition(originalPostion.x, originalPostion.y);
			x += FlxG.random.int(-10, 10);
			y += FlxG.random.int(-10, 10);
			shakeTmr--;
		}

		if (x < player.x)
			flipX = false;
		else
			flipX = true;

		if (animation.curAnim.name == "death" + spriteType && animation.curAnim.curFrame < 10 && !playedPreHit && slowMoDead)
		{
			playedPreHit = true;
			FlxG.sound.play("assets/sounds/prehit.ogg", 0.45);
		}
		if (animation.curAnim.name == "death" + spriteType && animation.curAnim.finished && !playedGoldHit && slowMoDead)
		{
			playedGoldHit = true;
			FlxG.sound.play("assets/sounds/slowhit.ogg", 0.45);
		}
		if (!slowMoDead && animation.curAnim.name == "death" + spriteType && !playedGoldHit)
		{
			playedGoldHit = true;
			FlxG.sound.play("assets/sounds/slowhit.ogg", 0.45);
		}

		super.update(elapsed);
	}

	public function death(?slowMo:Bool = false)
	{
		slowMoDead = slowMo;
		dead = true;
		player.onEnemyKilled();
		originalPostion = new FlxPoint(x, y);
		shakeTmr = 100;
		alpha = 0.45;
		if (flipX)
			FlxTween.tween(originalPostion, {x: originalPostion.x + 200}, 1, {ease: FlxEase.expoOut});
		if (!flipX)
			FlxTween.tween(originalPostion, {x: originalPostion.x - 200}, 1, {ease: FlxEase.expoOut});
		animation.play("death" + spriteType);
		new FlxTimer().start(0.5, function(tmr:FlxTimer)
		{
			shakeTmr = 0;
			FlxTween.tween(this, {
				alpha: 0,
				angle: FlxG.random.int(-7, 7),
				y: y + FlxG.random.int(-100, 100),
				x: x + FlxG.random.int(-100, 100)
			}, 1, {
				ease: FlxEase.expoOut,
				onComplete: function(twm:FlxTween)
				{
					new FlxTimer().start(0.2, function(tmr:FlxTimer)
					{
						readyToDelete = true;
					});
				}
			});
		});
	}
}