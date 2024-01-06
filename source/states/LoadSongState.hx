package states;

import states.cd.MusicPlayer;
import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import data.ChartLoader;
import data.GameData.MusicBeatState;
import gameObjects.*;
import gameObjects.hud.*;
import gameObjects.hud.note.*;
import flixel.addons.display.FlxBackdrop;

#if !html5
import sys.thread.Mutex;
import sys.thread.Thread;
#end

/*
*	preloads all the stuff before going into playstate
*	i would advise you to put your custom preloads inside here!!
*/
class LoadSongState extends MusicBeatState
{
	var threadActive:Bool = true;

	#if !html5
	var mutex:Mutex;
	#end
	
	//var behind:FlxGroup;
	var behind:FlxGroup;
	var bg:FlxSprite;
	var logo:FlxSprite;

	var loadBar:FlxSprite;
	var loadPercent:Float = 0;

	function addBehind(item:FlxBasic)
	{
		behind.add(item);
		behind.remove(item);
	}
	
	override function create()
	{
		super.create();

		#if !html5
		mutex = new Mutex();
		#end

		behind = new FlxGroup();
		add(behind);
		
		var color = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFF000000);
		color.screenCenter();
		add(color);

		var tiles = new FlxBackdrop(Paths.image('all'), XY, 0, 0);
        tiles.velocity.set(30, 30);
        tiles.screenCenter();
		tiles.alpha = 0.7;
        add(tiles);

		logo = new FlxSprite().loadGraphic(Paths.image('menu/loading'));
		logo.scale.set(0.3,0.3);
		logo.updateHitbox();
		logo.x = FlxG.width - logo.width - 10;
		logo.y = FlxG.height - logo.height - 10;
		add(logo);

		loadBar = new FlxSprite().makeGraphic(FlxG.width, 20, 0xFFFFFFFF);
		loadBar.y = FlxG.height - loadBar.height + 10;
		loadBar.scale.x = 0;
		loadBar.alpha = 0;
		add(loadBar);
		
		var oldAnti:Bool = FlxSprite.defaultAntialiasing;
		FlxSprite.defaultAntialiasing = false;
		
		PlayState.resetStatics();
		var assetModifier = PlayState.assetModifier;
		var SONG = PlayState.SONG;

		#if !html5
		var preloadThread = Thread.create(function()
		{
			mutex.acquire();
			#end
			Paths.preloadPlayStuff(SONG.song);
			Rating.preload(assetModifier);

			if(!SaveData.data.get("Low Quality")) {
				Paths.preloadGraphic('hud/base/healthBar');
				Paths.preloadGraphic('vignette');
			}

			Paths.preloadGraphic('hud/base/blackBar');

			Paths.preloadGraphic("hud/pause/botplay");
			Paths.preloadGraphic("hud/pause/buttons");
			Paths.preloadGraphic("hud/pause/pause");
			Paths.preloadGraphic("hud/pause/selector");
			
			var stageBuild = new Stage();
			addBehind(stageBuild);
			var stages:Array<String> = [SONG.song];

			if(!SaveData.data.get("Low Quality")) {
				switch(SONG.song)
				{
					case 'desertion':
						stages.push("desertion2");
					case 'intimidate': //insane
						stages.push("divergence-e");
						stages.push("panic-attack-e");
						stages.push("wake");
					case 'cupid':
						stages.push("cupid2");
					default:
						//
				}
			}
			for (stage in stages) {
				stageBuild.reloadStageFromSong(stage);
			}

			//trace('preloaded stage and hud');
			
			loadPercent = 0.2;

			var charList:Array<String> = [SONG.player1, SONG.player2];

			if(!SaveData.data.get("Low Quality")) {
				switch(SONG.song)
				{
					case 'nefarious':
						charList.push("bex-1alt");
					case 'divergence':
						charList.push("bella-1alt");
					case 'panic-attack':
						charList.push("bree-2bf");
						charList.push("bex-2bf");
						charList.push("bex-2balt");
					case 'desertion':
						charList.push("bella-2dp");
						charList.push("bella-2d");
						charList.push("bree-2dp");
						charList.push("bex-2dp");
					case 'intimidate':
						charList.push("bex-1e");
						charList.push("bex-2e");
						charList.push("bree-2e");
					case 'cupid':
						charList.push("bella-hp2");
						charList.push("bex-hp2");
					default:
						////trace('loaded lol');
				}
			}

			for(i in charList) {
				var char = new Character();
				char.isPlayer = (i == SONG.player1);
				char.reloadChar(i);
				addBehind(char);
				
				////trace('preloaded $i');

				var icon = new HealthIcon();
				icon.setIcon(i, false);
				addBehind(icon);
				loadPercent += (0.6 - 0.2) / charList.length;
			}
			
			//trace('preloaded characters');
			loadPercent = 0.6;
			
			Paths.preloadSound('songs/${SONG.song}/Inst');
			if(SONG.needsVoices)
				Paths.preloadSound('songs/${SONG.song}/Voices');
			
			//trace('preloaded music');
			loadPercent = 0.75;
			
			var thisStrumline = new Strumline(0, null, false, false, true, assetModifier);
			thisStrumline.ID = 0;
			addBehind(thisStrumline);
			
			var noteList:Array<Note> = ChartLoader.getChart(SONG);
			for(note in noteList)
			{
				note.reloadNote(note.songTime, note.noteData, note.noteType, assetModifier);
				addBehind(note);
				
				thisStrumline.addSplash(note);

				loadPercent += (0.9 - 0.75) / noteList.length;
			}
			
			//trace('preloaded notes');
			loadPercent = 0.9;
			
			// add custom preloads here!!
			if(!SaveData.data.get("Low Quality")) {
				switch(SONG.song)
				{
					case "divergence":
						Paths.preloadGraphic("hud/base/divergence");
						Paths.preloadGraphic('backgrounds/week1/bgchars');
					case "convergence":
						Paths.preloadGraphic("hud/base/shes going to kill you");
						Paths.preloadGraphic("hud/base/convergence");
					case "desertion":
						Paths.preloadGraphic("hud/base/divergence");
					case "nefarious" | "euphoria":
						Paths.preloadGraphic('backgrounds/week1/bgchars');
					default:
						////trace('loaded lol');
				}
			}
			
			loadPercent = 1.0;
			//trace('finished loading');

			FlxSprite.defaultAntialiasing = oldAnti;
			#if !html5
			threadActive = false;
			mutex.release();
		});
		#else
		Main.skipClearMemory = true;
		Main.switchState(new PlayState());
		#end
	}
	
	var byeLol:Bool = false;
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		#if !html5
		if(!threadActive && !byeLol && loadBar.scale.x >= 0.98)
		{
			byeLol = true;
			loadBar.scale.x = 1.0;
			loadBar.updateHitbox();
			Main.skipClearMemory = true;
			Main.switchState(new PlayState());
		}

		loadBar.scale.x = FlxMath.lerp(loadBar.scale.x, loadPercent, elapsed * 6);
		loadBar.updateHitbox();
		#end
	}
}


class LoadMusicPlayer extends MusicBeatState
{
	var threadActive:Bool = true;

	#if !html5
	var mutex:Mutex;
	#end
	
	//var behind:FlxGroup;
	var behind:FlxGroup;
	var bg:FlxSprite;
	var logo:FlxSprite;

	var loadBar:FlxSprite;
	var loadPercent:Float = 0;

	function addBehind(item:FlxBasic)
	{
		behind.add(item);
		behind.remove(item);
	}
	
	override function create()
	{
		super.create();

		#if !html5
		mutex = new Mutex();
		#end

		behind = new FlxGroup();
		add(behind);
		
		var color = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFF000000);
		color.screenCenter();
		add(color);

		var tiles = new FlxBackdrop(Paths.image('all'), XY, 0, 0);
        tiles.velocity.set(30, 30);
        tiles.screenCenter();
		tiles.alpha = 0.7;
        add(tiles);

		logo = new FlxSprite().loadGraphic(Paths.image('menu/loading'));
		logo.scale.set(0.3,0.3);
		logo.updateHitbox();
		logo.x = FlxG.width - logo.width - 10;
		logo.y = FlxG.height - logo.height - 10;
		add(logo);

		loadBar = new FlxSprite().makeGraphic(FlxG.width, 20, 0xFFFFFFFF);
		loadBar.y = FlxG.height - loadBar.height + 10;
		loadBar.scale.x = 0;
		loadBar.alpha = 0;
		add(loadBar);
		
		var oldAnti:Bool = FlxSprite.defaultAntialiasing;
		FlxSprite.defaultAntialiasing = false;

		var songList = MusicPlayer.songs;
		var percentageCalc = (1 - 0.2) / songList.length;

		#if !html5
		var preloadThread = Thread.create(function()
		{
			mutex.acquire();
			#end

			Paths.preloadGraphic('menu/music/sky');
			Paths.preloadGraphic('menu/music/song');
			Paths.preloadGraphic('menu/music/list-overlay');
			Paths.preloadGraphic('menu/music/arrow');
			Paths.preloadGraphic('menu/music/buttons');
			Paths.preloadGraphic('menu/music/cursor');

			loadPercent = 0.2;

			for(i in 0...songList.length) {
				Paths.preloadMusicPlayer(songList[i][2]);
                if(songList[i][3] != null)
                    Paths.preloadMusicPlayer(songList[i][3]);

				loadPercent += percentageCalc;
			}

			loadPercent = 1.0;
			//trace('finished loading');

			FlxSprite.defaultAntialiasing = oldAnti;
			#if !html5
			threadActive = false;
			mutex.release();
		});
		#else
		Main.skipClearMemory = true;
		Main.switchState(new states.cd.MusicPlayer());
		#end
	}
	
	var byeLol:Bool = false;
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		#if !html5
		if(!threadActive && !byeLol && loadBar.scale.x >= 0.98)
		{
			byeLol = true;
			loadBar.scale.x = 1.0;
			loadBar.updateHitbox();
			Main.skipClearMemory = true;
			Main.switchState(new states.cd.MusicPlayer());
		}

		loadBar.scale.x = FlxMath.lerp(loadBar.scale.x, loadPercent, elapsed * 6);
		loadBar.updateHitbox();
		#end
	}
}