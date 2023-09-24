package gameObjects.hud.note;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import shaders.ColorSwap;

class StrumNote extends FlxSprite
{
	public function new()
	{
		super();
		//reloadStrum(0, "base");
	}

	public var strumData:Int = 0;
	public var assetModifier:String = "base";

	// use these to modchart
	public var strumSize:Float = 1.0;
	public var scaleOffset:FlxPoint = new FlxPoint(0,0);
	public var initialPos:FlxPoint = new FlxPoint(0,0);

	private var direction:String = "left";

	public function reloadStrum(strumData:Int, ?assetModifier:String = "base", ?noteColor:Array<Int>):StrumNote
	{
		this.strumData = strumData;
		this.assetModifier = assetModifier;
		strumSize = 1.0;

		direction = CoolUtil.getDirection(strumData);

		switch(assetModifier)
		{
			case "pixel":
				strumSize = 6;
				loadGraphic(Paths.image("notes/pixel/notesPixel"), true, 17, 17);

				animation.add("static",  [strumData], 						12, false);
				animation.add("pressed", [strumData + 8], 					12, false);
				animation.add("confirm", [strumData + 12, strumData + 16], 	12, false);

				antialiasing = false;

				addOffset("static");
				addOffset("pressed");
				addOffset("confirm");

			case "anime":
				strumSize = 0.7;
				frames = Paths.getSparrowAtlas('notes/$assetModifier/notes');

				addDefaultAnims();

				switch(direction) {
					case 'up':
						angle = 90;
						updateHitbox();
						addOffset("pressed", -2, -2);
						addOffset("confirm", -36, 36);
					case 'down':
						angle = -90;
						updateHitbox();
						addOffset("pressed", -2, -2);
						addOffset("confirm", 36, -32);
					case 'right':
						angle = 180;
						updateHitbox();
						addOffset("pressed", -2, -2);
						addOffset("confirm", -36, -36);
					default:
						updateHitbox();
						addOffset("static", 0, 0);
						addOffset("pressed", -2, -2);
						addOffset("confirm", 36, 36);
				}

			default:
				strumSize = 0.7;
				frames = Paths.getSparrowAtlas('notes/$assetModifier/strums');

				addDefaultAnims();
				
				addOffset("static", 0, 0);
				addOffset("pressed", -2, -2);
				addOffset("confirm", 36, 36);
				
				// i hate up and down strum
				if(strumData == 1)
					addOffset("confirm", 37, 38);
				if(strumData == 2)
					addOffset("confirm", 38, 36);

				switch(assetModifier)
				{
					case "doido":
						frames = Paths.getSparrowAtlas("notes/doido/strums");
						addDefaultAnims();
						strumSize = 0.95;
						addOffset("confirm", 6.5, 8);
				}
		}
		playAnim("static"); // once to get the scale offset

		scale.set(strumSize, strumSize);
		updateHitbox();
		scaleOffset.set(offset.x, offset.y);

		playAnim("static"); // twice to use the scale offset

		return this;
	}

	// just so i dont have to type everything over and over again
	public function addDefaultAnims()
	{
		switch(assetModifier) {
			case "anime": 
				animation.addByPrefix("static",  'strum',  24, false);
				animation.addByPrefix("pressed", 'press', 12, false);
				animation.addByPrefix("confirm", 'confirm', 24, false);
			default:
				animation.addByPrefix("static",  'strum $direction static',  24, false);
				animation.addByPrefix("pressed", 'strum $direction pressed', 12, false);
				animation.addByPrefix("confirm", 'strum $direction confirm', 24, false);
		}
	}

	public var animOffsets:Map<String, Array<Float>> = [];

	public function addOffset(animName, offX:Float = 0, offY:Float = 0):Void
		return animOffsets.set(animName, [offX, offY]);

	public function playAnim(animName:String, ?forced:Bool = false, ?reversed:Bool = false, ?frame:Int = 0)
	{
		animation.play(animName, forced, reversed, frame);

		if(animOffsets.exists(animName))
		{
			var daOffset = animOffsets.get(animName);
			offset.set(daOffset[0] * scale.x, daOffset[1] * scale.y);
		}
		else
			offset.set(0,0);

		// useful for pixel notes since their offsets are not 0, 0 by default
		offset.x += scaleOffset.x;
		offset.y += scaleOffset.y;
	}
}