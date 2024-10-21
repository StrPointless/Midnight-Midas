import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxDirectionFlags;
import openfl.Assets;

class Player extends ModifiedFlxSprite
{
	public var _sprintSpeed:Float = 600;
	public var _normalSpeed:Float = 500;
	public var _curSpeed:Float = 250;
	public var _drag:Float;
	public var _isSprinting:Bool = false;
	public var _isGrounded:Bool;
	public var _jumping:Bool = false;
	public var _jumpTimer:Float = 0;
	public var _wallJumping:Bool = false;
	public var _wallJumpTimer:Float = 0;
	public var _curJumpCount:Int = 0;
	public var _curMaxJumpCount:Int = 1;
	public var _wallSliding:Bool = false;
	public var _defWallSliding:Bool = false;
	public var _curWallLocation:FlxDirectionFlags = NONE;
	public var _handlingWallSlideJump:Bool = false;
	public var _wallSlidingCheckArray:Array<Bool>;
	public var _wsTCheck:Int;
	public var _wsFCheck:Int;
	public var _fastFall:Bool = false;
	public var _justFastFell:Bool = false;
	public var _justGrounded:Bool = false;
	public var _canMove:Bool = true;
	public var _hasGravity:Bool = true;

	public var _preppingAttack:Bool = false;
	public var dead:Bool = false;

	public var colorArray:Array<FlxColor> = [0x6E6262, 0xB1A0A0, 0xFFFFFF];

	public var characterScaleY:Float = 0.35;
	public var characterScaleX:Float = 0.35;

	public var animationTransitionDelay:Float = 10;

	public function new(_x:Float, _y:Float)
	{
		super(_x, _y);
		spriteTag = 'Player';

		frames = FlxAtlasFrames.fromSparrow(Assets.getBitmapData("assets/images/player.png"), Assets.getText("assets/images/player.xml"));

		animation.addByPrefix("idle", "idle", 24, true);
		animation.addByPrefix("walk", "walk", 24, true);
		animation.addByPrefix("run", "run", 24, true);
		animation.addByPrefix("jump", "jump", 24, true);
		animation.addByPrefix("dblJump", "dblJump", 18, false);
		animation.addByPrefix("fall", "fall0", 24, true);
		animation.addByPrefix("fallIntro", "fallIntro0", 24, true);
		animation.addByPrefix("prepAttack", "goldPrep0", 24, true);
		animation.addByPrefix("prepAttackAir", "goldAirPrep0", 24, true);
		animation.addByPrefix("attack0", "attack10", 24, false);
		animation.addByPrefix("attack1", "attack20", 24, false);
		animation.addByPrefix("attack0Air", "attack1Air0", 24, false);
		animation.addByPrefix("attack1Air", "attack2Air0", 24, false);
		animation.addByPrefix("death", "death", 24, true);
		animation.play("idle");

		// centerOffsets(true);
		width = (frameWidth / 1.25) * characterScaleX;
		height = (frameHeight / 1.25) * characterScaleY;
		centerOffsets(true);
		// updateHitbox();
		

		// animation.play('idle');
		setGravity(true);
		_wallSlidingCheckArray = new Array<Bool>();
	}

	public var left:Bool;
	public var right:Bool;
	public var down:Bool;
	public var jumped:Bool;
	public var focus:Bool = false;
	public var attack:Bool;
	public var curAttack:Int = 0;
	public var attacking:Bool = false;
	public var killBoost:Bool = false;
	public var killBoostTmr:Float;
	public var gameRef:PlayState;

	public var killBoostModifier:Float = 1;
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (!dead)
		{
			if (_canMove)
			{
				left = FlxG.keys.anyPressed([LEFT, A]);
				right = FlxG.keys.anyPressed([RIGHT, D]);
				down = FlxG.keys.anyPressed([DOWN, S]);
				jumped = FlxG.keys.justPressed.SPACE;
				if (gameRef.daFocusAmount >= 400)
				{
					_preppingAttack = FlxG.mouse.pressedRight;
					focus = FlxG.mouse.pressedRight;
				}
				else
				{
					_preppingAttack = false;
					focus = false;
				}
				attack = FlxG.mouse.justPressed;
				if (attack)
					handleAttack();
			}
			else
			{
				left = false;
				right = false;
				down = false;
				jumped = false;
				focus = false;
				_preppingAttack = false;
			}

			// color = colorArray[_curJumpCount];

			FlxG.watch.addQuick('speed', _curSpeed);
			FlxG.watch.addQuick('jumps', _curJumpCount);
			FlxG.watch.addQuick('sprinting', _isSprinting);
			FlxG.watch.addQuick('grounded', _isGrounded);
			FlxG.watch.addQuick('wallSliding', _defWallSliding);
			FlxG.watch.addQuick('wallJumping', _wallJumping);
			FlxG.watch.addQuick('fast falling', _fastFall);
			FlxG.watch.addQuick('jumping', _jumping);
			// FlxG.watch.addQuick('curJumpCount', _curJumpCount);
			// FlxG.watch.addQuick('jumpTimer', _jumpTimer);
			// FlxG.watch.addQuick('wallSliding', _wallSliding);
			// FlxG.watch.addQuick('velocity', velocity);
			// FlxG.watch.addQuick('cur Animation', animation.curAnim.name);
			_drag = _curSpeed * 5;
			drag.x = _drag;
			// trace(offset);

			_isSprinting = FlxG.keys.pressed.SHIFT;
			if (_isSprinting)
			{
				_curSpeed = _sprintSpeed;
			}
			else
			{
				_curSpeed = _normalSpeed;
			}

			if (left && !_handlingWallSlideJump)
			{
				velocity.x = -_curSpeed;
				flipX = true;
			}
			else if (right && !_handlingWallSlideJump)
			{
				velocity.x = _curSpeed;
				flipX = false;
			}

			if (jumped && _curJumpCount > 0)
			{
				_jumping = true;
				_curJumpCount--;
				switch (_curJumpCount)
				{
					case 1:
						FlxG.sound.play("assets/sounds/jumpSfx.ogg", 0.5);
					case 0:
						FlxG.sound.play("assets/sounds/jumpSfx.ogg", 0.25);
				}
				if (_defWallSliding)
					_wallJumping = true;
			}
			if (_isGrounded)
				resetJumps();
			if (_jumping)
			{
				acceleration.y = -100;
				velocity.y = -500;
				_jumpTimer++;
			}
			if (!_jumping && !_fastFall)
			{
				setGravity(true);
				_jumpTimer = 0;
			}
			if (_jumpTimer > 1 && _jumping)
			{
				_jumping = false;
			}
			if (!_isGrounded && FlxG.keys.anyJustPressed([DOWN, S]))
			{
				velocity.y = 0;
			}
			if (!_isGrounded && !_jumping)
				_fastFall = down
			else
				_fastFall = false;

			if (_fastFall)
			{
				killBoost = false;
				killBoostTmr = 0;
				_jumpTimer = 0;
				_jumping = false;
				setGravity(false, 2400, 2200);
			}
			if (_justGrounded != _isGrounded)
			{
				_justGrounded = _isGrounded;
				if (_isGrounded == true)
				{
					scale.set(characterScaleX + 0.01, characterScaleY - 0.01);
					FlxG.sound.play("assets/sounds/landSfx.ogg", 0.5);
				}
			}
			if (this != null)
			{
				if (!_isGrounded)
					scale.set(FlxMath.lerp(scale.x, characterScaleX - 0.01, 0.1), FlxMath.lerp(scale.y, characterScaleY + 0.01, 0.1));
				else
					scale.set(FlxMath.lerp(scale.x, characterScaleX, 0.15), FlxMath.lerp(scale.y, characterScaleY, 0.25));
			}
			if (attacking && !_isGrounded)
				setGravity(false, 1200, 800);

			if (killBoost)
			{
				acceleration.y = -100 * killBoostModifier;
				velocity.y = -500 * killBoostModifier;
				killBoostTmr++;
			}
			if (killBoostTmr > 0.5 && killBoost)
			{
				killBoost = false;
				killBoostTmr = 0;
			}

			updateAnimations();
		}
		if (dead)
			animation.play("death");
	}

	public function handleAttack()
	{
		attacking = true;
		if (curAttack == 0)
		{
			if (_isGrounded && !left && !right)
				animation.play("attack0");
			if (!_isGrounded)
				animation.play("attack0Air");
			curAttack = 1;
			return;
		}
		if (curAttack == 1)
		{
			if (_isGrounded && !left && !right)
				animation.play("attack1");
			if (!_isGrounded)
				animation.play("attack1Air");
			curAttack = 0;
			return;
		}
	}

	public function updateAnimations()
	{
		if (!left && !right && _isGrounded && !_preppingAttack && !attacking)
		{
			animation.play("idle");
			attacking = false;
		}
		if (!left && !right && _isGrounded && _preppingAttack)
		{
			animation.play("prepAttack");
			attacking = false;
		}
		if (left && _isGrounded || right && _isGrounded)
		{
			if (_isSprinting)
				animation.play("run");
			else
				animation.play("walk");
			attacking = false;
		}
		if (_isGrounded && velocity.y < 0 && !_preppingAttack && !attacking)
		{
			animation.play("jump", false);
			attacking = false;
		}
		if (!_isGrounded && velocity.y > 0 && !_preppingAttack && !attacking)
		{
			animation.play("fall");
			attacking = false;
		}
		if (jumped && !_isGrounded && velocity.y < 0 && !_preppingAttack && _curJumpCount == 0)
		{
			animation.play("dblJump", false);
			attacking = false;
		}
		if (!_isGrounded && _preppingAttack)
		{
			animation.play("prepAttackAir");
			attacking = false;
		}
		if (animation.curAnim.name == "attack0"
			&& animation.curAnim.finished
			|| animation.curAnim.name == "attack1"
			&& animation.curAnim.finished
			|| animation.curAnim.name == "attack0Air"
			&& animation.curAnim.finished
			|| animation.curAnim.name == "attack1Air"
			&& animation.curAnim.finished)
			attacking = false;
		if (animation.curAnim.name == "attack0Air" && _isGrounded || animation.curAnim.name == "attack1Air" && _isGrounded)
			attacking = false;
	}

	public function playAnim() {

	}

	public function onEnemyKilled()
	{
		killBoost = true;
		killBoostModifier = 1;
		gameRef.onEnemyKilled();
		attacking = false;
	}

	public function onBossHurt(isFinal:Bool = false)
	{
		killBoost = true;
		if (isFinal)
		{
			killBoostModifier = 2;
			FlxG.camera.flash(FlxColor.WHITE, 1);
			gameRef.endFinale();
		}
		else
			killBoostModifier = 0.25;
		gameRef.onBossHurt();
		attacking = false;
	}

	public function setGravity(?reset:Bool = false, ?newAcceleration:Float, ?newMaxVelocity:Float)
	{
		if (reset && _hasGravity)
		{
			acceleration.y = 1800;
			maxVelocity.y = 1400;
		}
		else
		{
			acceleration.y = newAcceleration;
			maxVelocity.y = newMaxVelocity;
		}
	}

	public function resetJumps()
	{
		_curJumpCount = _curMaxJumpCount;
	}
}
