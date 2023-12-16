package gameObjects;

import haxe.Json;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;

using StringTools;

class DialogChar extends FlxSprite
{
	public function new() {
		super();
	}

	public var curChar:String = "bf";
	public var isPlayer:Bool = false;

	public var globalOffset:FlxPoint = new FlxPoint();

	public function reloadChar(curChar:String = "bf"):DialogChar
	{
		this.curChar = curChar;

		flipX = false;
		scale.set(1,1);
		antialiasing = FlxSprite.defaultAntialiasing;

		globalOffset.set();

		animOffsets = []; // reset it

		switch(curChar)
		{
			case "bella":
				frames = Paths.getSparrowAtlas("dialog/characters/bella");
				animation.addByPrefix('neutral', 		'neutral', 10, true);
				animation.addByPrefix('shock', 	'shock', 10, true);
				animation.addByPrefix('realization', 	'realization', 10, true);
				animation.addByPrefix('playful', 	'playful', 10, true);
				animation.addByPrefix('excited', 	'excited', 10, true);
                animation.addByPrefix('blush', 	'blush', 10, true);

				scale.set(0.65,0.65);

				antialiasing = false;

                //addOffset(animData[0], animData[1], animData[2]);
                playAnim("neutral");

			default:
				return reloadChar(isPlayer ? "bella" : "bella");
		}
		
		updateHitbox();

		if(isPlayer)
			flipX = !flipX;

		return this;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	// animation handler
	public var animOffsets:Map<String, Array<Float>> = [];

	public function addOffset(animName:String, offX:Float = 0, offY:Float = 0):Void
		return animOffsets.set(animName, [offX, offY]);

	public function playAnim(animName:String, ?forced:Bool = false, ?reversed:Bool = false, ?frame:Int = 0)
	{
		animation.play(animName, forced, reversed, frame);

		try
		{
			var daOffset = animOffsets.get(animName);
			offset.set(daOffset[0] * scale.x, daOffset[1] * scale.y);
		}
		catch(e)
			offset.set(0,0);
	}
}