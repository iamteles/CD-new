package gameObjects.hud.note;

import flixel.FlxG;
import flixel.FlxSprite;
import shaders.ColorSwap;

class SplashNote extends FlxSprite
{
	public function new()
	{
		super();
		visible = false;
	}

	/*
	**	these are used so each note gets their own splash
	**	but if that splash already exists, then it spawns
	**	the same splash, so there are not
	** 	8204+ splashes created each song
	*/
	public static var existentModifiers:Array<String> = [];
	public static var existentTypes:Array<String> = [];

	public static function resetStatics()
	{
		existentModifiers = [];
		existentTypes = [];
	}

	public var assetModifier:String = "";
	public var hasSplash:Bool = true;
	public var noteType:String = "";
	public var noteData:Int = 0;

	var unavailable:Array<String> = ["pixel", "taiko", "fitdon"];

	var colorSwap:ColorSwap;
	public function reloadSplash(note:Note, noteColor:Array<Int>)
	{
		var direction:String = CoolUtil.getDirection(note.noteData);

		assetModifier = note.assetModifier;
		noteType = note.noteType;
		noteData = note.noteData;

		if(note.noteType == "beam")
			assetModifier = "cd";

		if(unavailable.contains(assetModifier)) {
			assetModifier = "base";
			hasSplash = false;
		}

		switch(note.assetModifier)
		{
			default:
				switch(note.noteType)
				{
					default:
						frames = Paths.getSparrowAtlas('notes/$assetModifier/splashes');

						switch (assetModifier) {
							case "mlc":
								animation.addByPrefix("splash1", '$direction splash', 24, false);
								animation.addByPrefix("splash2", '$direction splash', 24, false);
		
							case "shack":
								animation.addByPrefix("splash1", '$direction spr', 24, false);
								animation.addByPrefix("splash2", '$direction spr', 24, false);
							case "tails":
								animation.addByPrefix("splash1", 'note splash $direction', 24, false);
								animation.addByPrefix("splash2", 'note splash $direction', 24, false);
							case "ylyl":
								animation.addByPrefix("splash1", '$direction splash', 24, false);
								animation.addByPrefix("splash2", '$direction splash', 24, false);
							case 'doido':
								animation.addByPrefix('splash1', '$direction splash', 24, false);
								animation.addByPrefix('splash2', '$direction splash', 24, false);
							case 'cd':
								if(note.noteType == "beam")	{
									animation.addByPrefix("splash1", 'THUNDER', 24, false);
									animation.addByPrefix("splash2", 'THUNDER', 24, false);
								}
								else {
									animation.addByPrefix("splash1", 'splash $direction 1', 24, false);
									animation.addByPrefix("splash2", 'splash $direction 1', 24, false);
								}
							default:
								animation.addByPrefix("splash1", '$direction splash 1', 24, false);
								animation.addByPrefix("splash2", '$direction splash 2', 24, false);

						}

						switch (assetModifier) {
							case "base":
								scale.set(0.7,0.7);
							case "cd":
								scale.set(0.8,0.8);
							case "doido":
								scale.set(0.95,0.95);
							default:
								//
						}


						updateHitbox();
				}
		}

		playAnim();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if(animation.finished)
		{
			visible = false;
		}
	}

	// plays a random animation
	public function playAnim()
	{
		visible = true;
		var animList = animation.getNameList();
		animation.play(animList[FlxG.random.int(0, animList.length - 1)], true, false, 0);
	}
}