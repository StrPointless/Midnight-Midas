package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;

class PlayState extends FlxState
{

	public var envObjects:FlxTypedGroup<ModifiedFlxSprite>;

	public var player:Player;
	override public function create()
	{
		var ground = new ModifiedFlxSprite(0,0);
		ground.makeGraphic(500, 150, FlxColor.CYAN);
		ground.screenCenter();
		ground.immovable = true;
		ground.updateHitbox();
		envObjects.add(ground);

		player = new Player(0,0);
		player.makeGraphic(50,100, FlxColor.WHITE);
		player.antialiasing = true;
		player.updateHitbox();
		player.y -= 400;
		player.screenCenter();
		add(player);

		super.create();
	}

	override public function update(elapsed:Float)
	{
		//restart the game
		if(FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.R)
			FlxG.resetState();

		if (player.isTouching(LEFT))
			player._curWallLocation = LEFT;
		else if (player.isTouching(RIGHT))
			player._curWallLocation = RIGHT;
		else
			player._curWallLocation = NONE;

		FlxG.collide(envObjects, player)
		super.update(elapsed);
		

	}
}
