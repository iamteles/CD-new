package;

import states.cd.Intro.IntroLoading;
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
		Main.setMouse(false);
		#if android
		FlxG.android.preventDefaultKeys = [BACK];
		#end
		FlxGraphic.defaultPersist = true;

		var cursor:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menu/cursor"));
		FlxG.mouse.load(cursor.pixels);

		for(i in 0...Paths.dumpExclusions.length)
			Paths.preloadGraphic(Paths.dumpExclusions[i].replace('.png', ''));

		Main.randomizeTitle();

		Main.skipTrans = true;
		if(SaveData.progression.get("firstboot"))
			#if mobile
			Main.switchState(new TitleScreen());
			#else
			Main.switchState(new Intro.IntroLoading());
			#end
		else
			Main.switchState(new Intro.Warning());
	}
}