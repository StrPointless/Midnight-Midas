import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxDirectionFlags;

class Player extends ModifiedFlxSprite
{
	public var _sprintSpeed:Float = 500;
	public var _normalSpeed:Float = 350;
	public var _curSpeed:Float = 250;
	public var _drag:Float;
	public var _isSprinting:Bool = false;
	public var _isGrounded:Bool;
	public var _jumping:Bool = false;
	public var _jumpTimer:Float = 0;
	public var _wallJumping:Bool = false;
	public var _wallJumpTimer:Float = 0;
	public var _curJumpCount:Int = 0;
	public var _curMaxJumpCount:Int = 3;
	public var _wallSliding:Bool = false;
	public var _curWallLocation:FlxDirectionFlags = NONE;



	public function new(_x:Float, _y:Float)
	{
		super(_x, _y);
		spriteTag = 'Player';

		// animation.play('idle');
		setGravity(true);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		var left = FlxG.keys.anyPressed([LEFT, A]);
		var right = FlxG.keys.anyPressed([RIGHT, D]);
		var jumped = FlxG.keys.justPressed.SPACE;

		FlxG.watch.addQuick('speed', _curSpeed);
		FlxG.watch.addQuick('sprinting', _isSprinting);
		FlxG.watch.addQuick('grounded', _isGrounded);
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

		if (left)
		{
			velocity.x = -_curSpeed;
			flipX = false;
		}
		else if (right)
		{
			velocity.x = _curSpeed;
			flipX = true;
		}

		if (jumped && _curJumpCount >= 1)
		{
			_jumping = true;
			_curJumpCount--;
			animation.play('jump', true);
			if (_wallSliding)
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
		if (!_jumping && !_wallSliding && !_wallJumping)
		{
			setGravity(true);
			_jumpTimer = 0;
		}
		if (_jumpTimer > 1 && _jumping)
		{
			_jumping = false;
		}
		if (_wallSliding)
		{
			resetJumps();
			setGravity(false, 50, 50);
		}
		if (_wallJumping)
		{
			acceleration.y = -100;
			velocity.y = -500;
			_wallJumpTimer++;
		}
		if (_wallJumping && _wallJumpTimer > 2)
			_wallJumping = false;

		// trace(_curWallLocation);


	}

	public function setGravity(?reset:Bool = false, ?newAcceleration:Float, ?newMaxVelocity:Float)
	{
		if (reset)
		{
			acceleration.y = 1200;
			maxVelocity.y = 1000;
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
