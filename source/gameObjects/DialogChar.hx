package gameObjects;

import flixel.FlxSprite;
import flixel.math.FlxPoint;

using StringTools;

#if !mobile
class DialogChar extends FlxSprite
{
	public function new() {
		super();
	}

	public var curChar:String = "bf";
	public var isPlayer:Bool = false;

	public var globalOffset:FlxPoint = new FlxPoint();
	private var scaleOffset:FlxPoint = new FlxPoint();

	public var name:String = "Bella";

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
				animation.addByPrefix('ooh', 	'ooh', 10, true);
				animation.addByPrefix('mouthful', 	'mouthfull', 10, true);
				animation.addByPrefix('flustered', 	'flustered', 10, true);

				scale.set(0.65,0.65);

                addOffset('flustered', -28, -9);
				addOffset('ooh', -1, -9);
				addOffset('playful', 13, 0);
				addOffset('excited', 6, 5);
                playAnim("neutral");


				name = "Bella";

			case "bella-cv":
				frames = Paths.getSparrowAtlas("dialog/characters/bella");
				animation.addByPrefix('neutral', 		'conv neutral', 10, true);
				animation.addByPrefix('angry', 		'conv angry', 10, true);
				animation.addByPrefix('annoyed', 		'conv annoyed', 10, true);
				animation.addByPrefix('confused', 		'conv confused', 10, true);
				animation.addByPrefix('playful', 		'conv playful', 10, true);
				animation.addByPrefix('realize', 		'conv realize', 10, true);

				scale.set(0.65,0.65);

				//addOffset(animData[0], animData[1], animData[2]);
				addOffset('annoyed', 0, -2);
				addOffset('angry', 108, 0);
				addOffset('playful', 110, 0);
				playAnim("neutral");

				name = "Bella";

			case "bree":
				frames = Paths.getSparrowAtlas("dialog/characters/bree");
				animation.addByPrefix('neutral', 		'neutral', 10, true);
				animation.addByPrefix('shock', 		'shock', 10, true);
				animation.addByPrefix('annoyed', 		'annoyed', 10, true);
				animation.addByPrefix('confused', 		'confused', 10, true);
				animation.addByPrefix('smug', 		'smug', 10, true);
				animation.addByPrefix('stun talk', 		'stun talk', 10, true);
				animation.addByPrefix('stunned', 		'stunned', 10, true);
				animation.addByPrefix('very mad', 		'very mad', 10, true);
				animation.addByPrefix('yap', 		'yap', 10, true);

				scale.set(0.65,0.65);

				//addOffset(animData[0], animData[1], animData[2]);
				addOffset('smug', -3, 2);
				playAnim("neutral");

				name = "Bree";

			case "bree-sin":
				frames = Paths.getSparrowAtlas("dialog/characters/bree");
				animation.addByPrefix('neutral', 		'sin neutral', 10, true);
				animation.addByPrefix('annoyed', 		'sin annoyed', 10, true);
				animation.addByPrefix('very mad', 		'sin very mad', 10, true);
				animation.addByPrefix('yap', 		'sin yap', 10, true);

				scale.set(0.65,0.65);

				//addOffset(animData[0], animData[1], animData[2]);
				addOffset('yap', 74, 0);
				addOffset('very mad', 112, 0);
				playAnim("neutral");

				name = "Bree";

			case "drown":
				frames = Paths.getSparrowAtlas("dialog/characters/shack");
				animation.addByPrefix('neutral', 		'Drown normal', 10, true);
				animation.addByPrefix('sadder', 		'Drown sadder', 10, true);
				animation.addByPrefix('saddest', 		'Drown saddest', 10, true);
				scale.set(0.84,0.84);
				playAnim("neutral");
				name = "Drown";

			case "wave":
				frames = Paths.getSparrowAtlas("dialog/characters/shack");
				animation.addByPrefix('neutral', 		'wave chat', 10, true);
				animation.addByPrefix('mad', 		'wave mad', 10, true);
				scale.set(0.84,0.84);
				playAnim("neutral");
				name = "Wave";

			case "empitri":
				frames = Paths.getSparrowAtlas("dialog/characters/shack");
				animation.addByPrefix('neutral', 		'Empitri chat', 10, true);
				//offset.set(0,100);
				scale.set(0.84,0.84);
				playAnim("neutral");
				name = "Empitri";

			case "helica":
				frames = Paths.getSparrowAtlas("dialog/characters/helica");
				animation.addByPrefix('neutral', 		'neutral', 10, true);
				animation.addByPrefix('angry', 		'angry', 10, true);

				scale.set(0.65,0.65);

				//addOffset(animData[0], animData[1], animData[2]);
				playAnim("neutral");

				name = "???";
			
			case "bex":
				frames = Paths.getSparrowAtlas("dialog/characters/bex");
				animation.addByPrefix('neutral', 		'neutral', 10, true);
				animation.addByPrefix('shy', 	'shy0', 10, true);
				animation.addByPrefix('shy2', 	'shy 2', 10, true);
				animation.addByPrefix('ooh', 	'ooh', 10, true);
				animation.addByPrefix('mad', 	'mad', 10, true);
				animation.addByPrefix('loving', 	'loving', 10, true);
				animation.addByPrefix('happy', 	'happy', 10, true);
				animation.addByPrefix('excited', 	'excited', 10, true);
				animation.addByPrefix('mouthful', 	'mouthful', 10, true);
				animation.addByPrefix('conv hurt', 	'conv hurt', 10, true);
				animation.addByPrefix('conv blank', 	'conv blank', 10, true);
				animation.addByPrefix('confused', 	'confused', 10, true);
				animation.addByPrefix('annoyed', 	'annoyed', 10, true);
				animation.addByPrefix('tired', 	'tired', 10, true);

				scale.set(0.65,0.65);
				//flipX = true;

				//addOffset(animData[0], animData[1], animData[2]);
				addOffset('conv blank', 5, -17);
				addOffset('conv hurt', 4, -18);
				addOffset('excited', 96, 0);
				addOffset('shy', 0, -2);
				playAnim("neutral");

				name = "Bex";

			case "bex-cv":
				frames = Paths.getSparrowAtlas("dialog/characters/bex");
				animation.addByPrefix('conv hurt', 	'conv hurt', 10, true);
				animation.addByPrefix('conv blank', 	'conv blank', 10, true);

				scale.set(0.65,0.65);
				//flipX = true;

				//addOffset(animData[0], animData[1], animData[2]);
				addOffset('conv blank', 5, -17);
				addOffset('conv hurt', 4, -18);
				playAnim("conv blank");

				name = "Bex";
			default:
				return reloadChar(isPlayer ? "bella" : "bella");
		}
		
		updateHitbox();
		scaleOffset.set(offset.x, offset.y);


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

		offset.x += scaleOffset.x;
		offset.y += scaleOffset.y;
		
	}
}
#else
class DialogChar extends FlxSprite
{
	public function new() {
		super();
	}

	public var curChar:String = "bf";
	public var isPlayer:Bool = false;

	public var globalOffset:FlxPoint = new FlxPoint();

	public var name:String = "Bella";

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
				animation.addByPrefix('ooh', 	'ooh', 10, true);
				animation.addByPrefix('mouthful', 	'mouthfull', 10, true);
				animation.addByPrefix('flustered', 	'flustered', 10, true);

				scale.set(0.65,0.65);

                //addOffset(animData[0], animData[1], animData[2]);
                playAnim("neutral");


				name = "Bella";

			case "bella-cv":
				frames = Paths.getSparrowAtlas("dialog/characters/bella");
				animation.addByPrefix('neutral', 		'conv neutral', 10, true);
				animation.addByPrefix('angry', 		'conv angry', 10, true);
				animation.addByPrefix('annoyed', 		'conv annoyed', 10, true);
				animation.addByPrefix('confused', 		'conv confused', 10, true);
				animation.addByPrefix('playful', 		'conv playful', 10, true);
				animation.addByPrefix('realize', 		'conv realize', 10, true);

				scale.set(0.65,0.65);

				//addOffset(animData[0], animData[1], animData[2]);
				playAnim("neutral");

				name = "Bella";

			case "bree":
				frames = Paths.getSparrowAtlas("dialog/characters/bree");
				animation.addByPrefix('neutral', 		'neutral', 10, true);
				animation.addByPrefix('shock', 		'shock', 10, true);
				animation.addByPrefix('annoyed', 		'annoyed', 10, true);
				animation.addByPrefix('confused', 		'confused', 10, true);
				animation.addByPrefix('smug', 		'smug', 10, true);
				animation.addByPrefix('stun talk', 		'stun talk', 10, true);
				animation.addByPrefix('stunned', 		'stunned', 10, true);
				animation.addByPrefix('very mad', 		'very mad', 10, true);
				animation.addByPrefix('yap', 		'yap', 10, true);

				scale.set(0.65,0.65);

				//addOffset(animData[0], animData[1], animData[2]);
				playAnim("neutral");

				name = "Bree";

			case "bree-sin":
				frames = Paths.getSparrowAtlas("dialog/characters/bree");
				animation.addByPrefix('neutral', 		'sin neutral', 10, true);
				animation.addByPrefix('annoyed', 		'sin annoyed', 10, true);
				animation.addByPrefix('very mad', 		'sin very mad', 10, true);
				animation.addByPrefix('yap', 		'sin yap', 10, true);

				scale.set(0.65,0.65);

				//addOffset(animData[0], animData[1], animData[2]);
				playAnim("neutral");

				name = "Bree";

			case "drown":
				frames = Paths.getSparrowAtlas("dialog/characters/shack");
				animation.addByPrefix('neutral', 		'Drown normal', 10, true);
				animation.addByPrefix('sadder', 		'Drown sadder', 10, true);
				animation.addByPrefix('saddest', 		'Drown saddest', 10, true);
				scale.set(0.84,0.84);
				playAnim("neutral");
				name = "Drown";

			case "wave":
				frames = Paths.getSparrowAtlas("dialog/characters/shack");
				animation.addByPrefix('neutral', 		'wave chat', 10, true);
				animation.addByPrefix('mad', 		'wave mad', 10, true);
				scale.set(0.84,0.84);
				playAnim("neutral");
				name = "Wave";

			case "empitri":
				frames = Paths.getSparrowAtlas("dialog/characters/shack");
				animation.addByPrefix('neutral', 		'Empitri chat', 10, true);
				//offset.set(0,100);
				scale.set(0.84,0.84);
				playAnim("neutral");
				name = "Empitri";

			case "helica":
				frames = Paths.getSparrowAtlas("dialog/characters/helica");
				animation.addByPrefix('neutral', 		'neutral', 10, true);
				animation.addByPrefix('angry', 		'angry', 10, true);

				scale.set(0.65,0.65);

				//addOffset(animData[0], animData[1], animData[2]);
				playAnim("neutral");

				name = "???";
			
			case "bex":
				frames = Paths.getSparrowAtlas("dialog/characters/bex");
				animation.addByPrefix('neutral', 		'neutral', 10, true);
				animation.addByPrefix('shy', 	'shy0', 10, true);
				animation.addByPrefix('shy2', 	'shy 2', 10, true);
				animation.addByPrefix('ooh', 	'ooh', 10, true);
				animation.addByPrefix('mad', 	'mad', 10, true);
				animation.addByPrefix('loving', 	'loving', 10, true);
				animation.addByPrefix('happy', 	'happy', 10, true);
				animation.addByPrefix('excited', 	'excited', 10, true);
				animation.addByPrefix('mouthful', 	'mouthful', 10, true);
				animation.addByPrefix('conv hurt', 	'conv hurt', 10, true);
				animation.addByPrefix('conv blank', 	'conv blank', 10, true);
				animation.addByPrefix('confused', 	'confused', 10, true);
				animation.addByPrefix('annoyed', 	'annoyed', 10, true);
				animation.addByPrefix('tired', 	'tired', 10, true);

				scale.set(0.65,0.65);
				//flipX = true;

				//addOffset(animData[0], animData[1], animData[2]);
				playAnim("neutral");

				name = "Bex";

			case "bex-cv":
				frames = Paths.getSparrowAtlas("dialog/characters/bex");
				animation.addByPrefix('conv hurt', 	'conv hurt', 10, true);
				animation.addByPrefix('conv blank', 	'conv blank', 10, true);

				scale.set(0.65,0.65);
				//flipX = true;

				//addOffset(animData[0], animData[1], animData[2]);
				playAnim("conv blank");

				name = "Bex";
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

		/*
		try
		{
			var daOffset = animOffsets.get(animName);
			offset.set(daOffset[0] * scale.x, daOffset[1] * scale.y);
		}
		catch(e)
			offset.set(0,0);
		*/
	}
}
#end