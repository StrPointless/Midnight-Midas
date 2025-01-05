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

	public var speed:Float = 5;
	public var originalPostion:FlxPoint;
	public var spriteType:Int = 0;
	public var outline:FlxSprite;

	public var isBoss:Bool = false;

	public var hp:Int = 15;

	public var stunTmr:Int = 0;

	public var playedPreHit:Bool = false;
	public var playedGoldHit:Bool = false;

	public var slowMoDead:Bool = false;
	public var stunTimer:Int = 0;

	public function new(x:Float, y:Float, ?boss:Bool = false, ?player:Player)
	{
		super(x, y);
		speed = speed + FlxG.random.float(5, 11);

		spriteType = FlxG.random.int(0, 1);

		frames = FlxAtlasFrames.fromSparrow("assets/images/darkEnemies.png", Assets.getText("assets/images/darkEnemies.xml"));
		animation.addByPrefix("idle0", "darKEnemy0idle", 12, true);
		animation.addByPrefix("death0", "darKEnemy0Death", 24, false);
		animation.addByPrefix("idle1", "darKEnemy1idle", 12, true);
		animation.addByPrefix("death1", "darKEnemy1Death", 24, false);

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
		// trace(Math.atan2((player.y - y), (player.x - x)) * 100);
	}


	public override function update(elapsed:Float)
	{
		/*
			if (!dead && stunTimer < 1)
				angle = (flipX) ? (Math.atan2((player.getGraphicMidpoint().y - getGraphicMidpoint().y),
					(player.getGraphicMidpoint()
						.x - getGraphicMidpoint().x)) * 100) : Math.atan2((player.getGraphicMidpoint().y - getGraphicMidpoint().y),
						(player.getGraphicMidpoint().x - getGraphicMidpoint().x)) * 100
		 */
		if (player != null && !dead)
		{
			if (stunTimer < 1)
			{
				if (player.x > x)
					x += speed * FlxG.timeScale;
				if (player.x < x)
					x -= speed * FlxG.timeScale;
				y = FlxMath.lerp(y, player.y, 0.005 * (speed / 2) * FlxG.timeScale);
			}
		}
		if (stunTimer > 0)
			stunTimer--;
		if (!isBoss && player.overlaps(this) && !dead && player.attacking)
		{
			death();
		}
		if (isBoss && player.overlaps(this) && !dead && player.attacking)
		{
			hp--;
			customColor.contrast = 2;
			customColor.saturation = 2;
			customColor.brightness = 0.25;
			player.attacking = false;
			if (hp <= 0)
			{
				death();
				player.onBossHurt(true);
				player._canMove = false;
				stunTimer = 100;
			}
			else
			{
				player.onBossHurt();
				stunTimer = 100;
			}
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
		customColor.contrast = FlxMath.lerp(customColor.contrast, 1.55, 0.09);
		customColor.saturation = FlxMath.lerp(customColor.saturation, 1.55, 0.09);
		customColor.brightness = FlxMath.lerp(customColor.brightness, 0, 0.09);

		super.update(elapsed);
	}

	public function death(?slowMo:Bool = false)
	{
		customColor.contrast = 2;
		customColor.saturation = 2;
		customColor.brightness = 0.25;
		slowMoDead = slowMo;
		dead = true;
		player.onEnemyKilled(this);
		originalPostion = new FlxPoint(x, y);
		shakeTmr = 100;
		alpha = 0.45;
		if (flipX)
			FlxTween.tween(originalPostion, {x: originalPostion.x + 400}, 1, {ease: FlxEase.expoOut});
		if (!flipX)
			FlxTween.tween(originalPostion, {x: originalPostion.x - 400}, 1, {ease: FlxEase.expoOut});
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