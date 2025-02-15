import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import haxe.Json;
import json2object.JsonParser;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import sys.FileSystem;
import sys.io.File;

class CharacterEditorState extends FlxState
{
	var player:Player;

	var animArray:Array<String> = [
		"idle",
		"walk",
		"run",
		"jump",
		"dblJump",
		"fall",
		"fallIntro",
		"prepAttack",
		"prepAttackAir",
		"attack0",
		"attack1",
		"attack0Air",
		"attack1Air",
		"death",
		"confused",
		"lockin",
		"shit",
	];
	var offsets:Map<String, Array<Float>>;

	var curAnimCount:Int = 0;

	var camFollow:FlxObject;

	var shiftMultiplier:Int = 1;

	var animationGhost:Player;

	var p_yKey:KeyboardEvent;
	var r_yKey:KeyboardEvent;

	public override function create()
	{
		super.create();

		animationGhost = new Player(0, 0);
		animationGhost.isDebug = true;
		animationGhost.setGravity(false, 0, 0);
		animationGhost.screenCenter();
		animationGhost.alpha = 0.5;
		add(animationGhost);

		player = new Player(0, 0);
		player.isDebug = true;
		player.setGravity(false, 0, 0);
		player.screenCenter();

		add(player);

		animationGhost.setPosition(player.x, player.y);

		offsets = new Map<String, Array<Float>>();

		camFollow = new FlxObject();

		FlxG.camera.follow(camFollow, LOCKON, 0.05);

		setOffset();

		FlxG.camera.zoom = 0.5;
	}

	public override function update(elapsed:Float)
	{
		super.update(elapsed);
		FlxG.watch.addQuick("offsets", offsets);

		camFollow.setPosition(player.getGraphicMidpoint().x, player.getGraphicMidpoint().y);

		if (FlxG.keys.justPressed.ONE)
			changeAnim(-1);
		if (FlxG.keys.justPressed.TWO)
			changeAnim(1);

		if (FlxG.keys.pressed.SHIFT)
			shiftMultiplier = 5;
		else
			shiftMultiplier = 1;

		if (FlxG.keys.justPressed.LEFT)
			changeOffset(1 * shiftMultiplier, 0);
		if (FlxG.keys.justPressed.RIGHT)
			changeOffset(-1 * shiftMultiplier, 0);
		if (FlxG.keys.justPressed.UP)
			changeOffset(0, 1 * shiftMultiplier);
		if (FlxG.keys.justPressed.DOWN)
			changeOffset(0, -1 * shiftMultiplier);

		if (FlxG.keys.justPressed.NINE)
			updateGhost();

		if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.S)
		{
			saveOffsets();
		}
		if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.L)
			loadOffsets();
	}

	public function changeOffset(x:Float = 0, y:Float = 0)
	{
		player.offset.set(offsets.get(animArray[curAnimCount])[0], offsets.get(animArray[curAnimCount])[1]);

		offsets.get(animArray[curAnimCount])[0] += x;
		offsets.get(animArray[curAnimCount])[1] += y;

		player.offset.set(offsets.get(animArray[curAnimCount])[0], offsets.get(animArray[curAnimCount])[1]);
	}

	public function updateGhost()
	{
		animationGhost.animation.play(animArray[curAnimCount], true);
		animationGhost.offset.set(offsets.get(animArray[curAnimCount])[0], offsets.get(animArray[curAnimCount])[1]);
	}

	public function updateOffset()
	{
		player.offset.set(offsets.get(animArray[curAnimCount])[0], offsets.get(animArray[curAnimCount])[1]);
	}

	public function changeAnim(ani:Int = 0)
	{
		curAnimCount += ani;

		if (curAnimCount > animArray.length - 1)
			curAnimCount = 0;
		if (curAnimCount < 0)
			curAnimCount = animArray.length - 1;

		player.animation.play(animArray[curAnimCount], true);
		setOffset();
	}

	public function setOffset()
	{
		if (offsets.get(animArray[curAnimCount]) == null)
			offsets.set(animArray[curAnimCount], [0, 0]);

		player.offset.set(offsets.get(animArray[curAnimCount])[0], offsets.get(animArray[curAnimCount])[1]);
	}

	public function saveOffsets()
	{
		var jsonData = Json.stringify(offsets);
		File.saveContent("assets/images/playerOffsets.json", jsonData);
		trace("Offsets saved");
	}

	public function loadOffsets()
	{
		trace(Json.parse(File.getContent("assets/images/playerOffsets.json")));
		var parser = new JsonParser<Map<String, Array<Float>>>();
		parser.fromJson(File.getContent("assets/images/playerOffsets.json"));
		offsets = parser.value;
	}
}