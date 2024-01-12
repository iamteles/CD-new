package gameObjects;

import flixel.FlxSprite;
import flixel.math.FlxPoint;

using StringTools;

typedef CharacterFile = {
	var animations:Array<AnimArray>;
	var image:String;
	var scale:Float;
	var sing_duration:Float;
	var healthicon:String;

	var position:Array<Float>;
	var camera_position:Array<Float>;
	var rating_position:Null<Array<Float>>;

	var flip_x:Bool;
	var no_antialiasing:Bool;
	var healthbar_colors:Array<Int>;
	var note_colors:Array<Int>;

	var scoreQuirk:Null<Array<String>>;
}

typedef AnimArray = {
	var anim:String;
	var name:String;
	var fps:Int;
	var loop:Bool;
	var indices:Array<Int>;
	var offsets:Array<Int>;
}

class Character extends FlxSprite
{
	public function new() {
		super();
	}

	public var curChar:String = "bf";
	public var isPlayer:Bool = false;

	public var holdTimer:Float = Math.NEGATIVE_INFINITY;
	public var holdLength:Float = 1;

	public var idleAnims:Array<String> = [];
	public var singAnims:Array<String> = [];
	public var missAnims:Array<String> = [];

	public var quickDancer:Bool = false;
	public var specialAnim:Bool = false;

	// warning, only uses this
	// if the current character doesnt have game over anims
	public var deathChar:String = "bf";

	public var globalOffset:FlxPoint = new FlxPoint();
	public var cameraOffset:FlxPoint = new FlxPoint();
	private var scaleOffset:FlxPoint = new FlxPoint();
	public var ratingsOffset:FlxPoint = new FlxPoint();

	var charData:CharacterFile;
	public var healthIcon:String = 'face';
	public var healthColor:Array<Int> = [100, 100, 100];
	public var noteColor:Array<Int> = [0, 0, 0];

	var loop:Bool = true;

	public var hasMiss:Bool = false;

	var dialChar:Bool = true;

	public function reloadChar(curChar:String = "bf"):Character
	{
		this.curChar = curChar;

		holdLength = 1;
		idleAnims = ["idle"];
		addSingPrefix(); // none

		quickDancer = false;

		flipX = false;
		scale.set(1,1);
		antialiasing = FlxSprite.defaultAntialiasing;
		deathChar = "bf";

		var storedPos:Array<Float> = [x, y];
		globalOffset.set();
		cameraOffset.set();
		ratingsOffset.set();

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

                addOffset('neutral', 0, 0);
                playAnim("neutral");


				//name = "Bella";

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

				//name = "Bella";

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

				//name = "Bree";

			case "bree-sin":
				frames = Paths.getSparrowAtlas("dialog/characters/bree");
				animation.addByPrefix('neutral', 		'sin neutral', 10, true);
				animation.addByPrefix('annoyed', 		'sin annoyed', 10, true);
				animation.addByPrefix('very mad', 		'sin very mad', 10, true);
				animation.addByPrefix('yap', 		'sin yap', 10, true);

				scale.set(0.65,0.65);

				//addOffset(animData[0], animData[1], animData[2]);
				playAnim("neutral");

				//name = "Bree";

			case "drown":
				frames = Paths.getSparrowAtlas("dialog/characters/shack");
				animation.addByPrefix('neutral', 		'Drown normal', 10, true);
				animation.addByPrefix('sadder', 		'Drown sadder', 10, true);
				animation.addByPrefix('saddest', 		'Drown saddest', 10, true);
				scale.set(0.84,0.84);
				playAnim("neutral");
				//name = "Drown";

			case "wave":
				frames = Paths.getSparrowAtlas("dialog/characters/shack");
				animation.addByPrefix('neutral', 		'wave chat', 10, true);
				animation.addByPrefix('mad', 		'wave mad', 10, true);
				scale.set(0.84,0.84);
				playAnim("neutral");
				//name = "Wave";

			case "empitri":
				frames = Paths.getSparrowAtlas("dialog/characters/shack");
				animation.addByPrefix('neutral', 		'Empitri chat', 10, true);
				//offset.set(0,100);
				scale.set(0.84,0.84);
				playAnim("neutral");
				//name = "Empitri";

			case "helica":
				frames = Paths.getSparrowAtlas("dialog/characters/helica");
				animation.addByPrefix('neutral', 		'neutral', 10, true);
				animation.addByPrefix('angry', 		'angry', 10, true);

				scale.set(0.65,0.65);

				//addOffset(animData[0], animData[1], animData[2]);
				playAnim("neutral");

				//name = "???";
			
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

				//name = "Bex";

			case "bex-cv":
				frames = Paths.getSparrowAtlas("dialog/characters/bex");
				animation.addByPrefix('conv hurt', 	'conv hurt', 10, true);
				animation.addByPrefix('conv blank', 	'conv blank', 10, true);

				scale.set(0.65,0.65);
				//flipX = true;

				//addOffset(animData[0], animData[1], animData[2]);
				playAnim("conv blank");

				//name = "Bex";
			default:
				try
				{
					charData = haxe.Json.parse(Paths.getContent(('data/chars/' + curChar + '.json')).trim());
				}
				catch (e)
				{
					//trace(e);
					charData = haxe.Json.parse(Paths.getContent(('data/chars/' + "bella-2a" + '.json')).trim());
				}
		
				frames = Paths.getSparrowAtlas(charData.image);
				
				if(charData.animations != null) {
					for (anim in charData.animations)
					{
						if(anim.indices != null && anim.indices.length > 0) {
							animation.addByIndices(anim.anim, anim.name, anim.indices, "", anim.fps, anim.loop);
						} else {
							animation.addByPrefix(anim.anim, anim.name, anim.fps, anim.loop);
						}
						if(anim.offsets != null && anim.offsets.length > 1) {
							addOffset(anim.anim, anim.offsets[0], anim.offsets[1]);
						}
					}
				}
		
				//holdLength = charData.sing_duration/4;
				flipX = charData.flip_x;
		
				if(charData.scale != 1) {
					setGraphicSize(Std.int(width * charData.scale));
					updateHitbox();
				}
				
				globalOffset.set(charData.position[0], charData.position[1]);
				cameraOffset.set(charData.camera_position[0], charData.camera_position[1]);
				if(charData.rating_position != null)
					ratingsOffset.set(charData.rating_position[0], charData.rating_position[1]);
				else
					ratingsOffset.set(-100, 100);
		
				healthIcon = charData.healthicon;
				healthColor = charData.healthbar_colors;
				noteColor = charData.note_colors;
				dialChar = false;
		}

		updateHitbox();
		scaleOffset.set(offset.x, offset.y);

		if(isPlayer)
			flipX = !flipX;

		if(animation.getByName('danceLeft') != null && animation.getByName('danceRight') != null) {
			quickDancer = true;
			if(curChar == "bella-vip-slow" || curChar == "bex-vip-slow")
				quickDancer = false;
			idleAnims = ['danceLeft', 'danceRight'];
		}

		if(animation.getByName('singLEFTmiss') != null) {
			hasMiss = true;
		}

		if(animation.getByName('miss') != null) {
			missAnims = ["miss", "miss", "miss", "miss"];
			hasMiss = true;
		}

		dance();

		setPosition(storedPos[0], storedPos[1]);

		return this;
	}

	public function addSingPrefix(prefix:String = "")
	{
		singAnims = ["singLEFT", "singDOWN", "singUP", "singRIGHT"];

		for(i in 0...singAnims.length)
		{
			missAnims[i] = singAnims[i] + "miss";

			singAnims[i] += prefix;
			missAnims[i] += prefix;
		}
	}

	private var curDance:Int = 0;

	var banList:Array<String> = ['snap', 'panic', 'neck'];
	public function dance(forced:Bool = false)
	{
		if(specialAnim) return;
		if(dialChar) return;

		switch(curChar)
		{
			default:
				playAnim(idleAnims[curDance]);
				curDance++;

				if (curDance >= idleAnims.length)
					curDance = 0;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if(holdTimer < holdLength)
		{
			holdTimer += elapsed;
		}

		

		if(banList.contains(animation.curAnim.name))
			specialAnim = true;
		else
			specialAnim = false;

		

		//if(loop && animation.curAnim.finished && singAnims.contains(animation.curAnim.name)) {
		//	dance();
		//}
	}

	// animation handler
	public var animOffsets:Map<String, Array<Float>> = [];

	public function addOffset(animName:String, offX:Float = 0, offY:Float = 0):Void
		return animOffsets.set(animName, [offX, offY]);

	public function playAnim(animName:String, ?forced:Bool = false, ?reversed:Bool = false, ?frame:Int = 0, ?miss:Bool = true)
	{
		animation.play(animName, forced, reversed, frame);

		try
		{
			var daOffset = animOffsets.get(animName);
			offset.set(daOffset[0] * scale.x, daOffset[1] * scale.y);
		}
		catch(e)
			offset.set(0,0);

		// useful for pixel notes since their offsets are not 0, 0 by default
		offset.x += scaleOffset.x;
		offset.y += scaleOffset.y;

		if(!hasMiss && isPlayer) {
			this.color = (!miss ? 0xFF070068 : 0xFFFFFFFF);
		}
	}

	public function miss(direction:Int) {
		var animstemp:Array<String> = missAnims;
		if(!hasMiss)
			animstemp = singAnims;
		playAnim(animstemp[direction], true, false, 0, hasMiss);
		holdTimer = 0;
	}
}