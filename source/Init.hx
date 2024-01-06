package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import data.GameData.MusicBeatState;
import states.cd.*;

class Init extends MusicBeatState
{
	override function create()
	{
		super.create();
		SaveData.init();
				
		FlxG.fixedTimestep = false;
		//FlxG.mouse.useSystemCursor = true;
		//FlxG.mouse.visible = false;
		#if android
		FlxG.android.preventDefaultKeys = [BACK];
		#end
		FlxGraphic.defaultPersist = true;

		var cursor:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menu/cursor"));
		FlxG.mouse.load(cursor.pixels);

		for(i in 0...Paths.dumpExclusions.length)
			Paths.preloadGraphic(Paths.dumpExclusions[i].replace('.png', ''));

		Main.randomizeTitle();
		
		if(SaveData.progression.get("firstboot"))
			Main.switchState(new Intro());
		else
			Main.switchState(new Intro.Warning());
	}
}