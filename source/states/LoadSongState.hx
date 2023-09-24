package states;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import data.ChartLoader;
import data.GameData.MusicBeatState;
import data.SongData.SwagSong;
import gameObjects.*;
import gameObjects.hud.*;
import gameObjects.hud.note.*;
import sys.thread.Mutex;
import sys.thread.Thread;

/*
*	preloads all the stuff before going into playstate
*	i would advise you to put your custom preloads inside here!!
*/
class LoadSongState extends MusicBeatState
{
	var threadActive:Bool = true;
	var mutex:Mutex;
	
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
		mutex = new Mutex();
		
		behind = new FlxGroup();
		add(behind);
		
		var color = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFF000000);
		color.screenCenter();
		add(color);
		
		// loading image
		bg = new FlxSprite().loadGraphic(Paths.image('loading/loading-screen-bg'));
		bg.updateHitbox();
		bg.screenCenter();
		bg.alpha = 0.3;
		add(bg);

		logo = new FlxSprite().loadGraphic(Paths.image('loading/loading'));
		logo.updateHitbox();
		logo.screenCenter();
		var storeY:Float = logo.y;
		logo.y -= 50;
		FlxTween.tween(logo, {y: storeY + 50}, 1.6, {type: FlxTweenType.PINGPONG, ease: FlxEase.sineInOut});
		add(logo);

		loadBar = new FlxSprite().makeGraphic(FlxG.width, 20, 0xFFFFFFFF);
		loadBar.y = FlxG.height - loadBar.height + 10;
		loadBar.scale.x = 0;
		add(loadBar);
		
		var oldAnti:Bool = FlxSprite.defaultAntialiasing;
		FlxSprite.defaultAntialiasing = false;
		
		PlayState.resetStatics();
		var assetModifier = PlayState.assetModifier;
		var SONG = PlayState.SONG;
		
		var preloadThread = Thread.create(function()
		{
			mutex.acquire();
			Paths.preloadPlayStuff();
			Rating.preload(assetModifier);
			Paths.preloadGraphic('hud/base/healthBar');
			Paths.preloadGraphic('hud/base/blackBar');
			Paths.preloadGraphic('vignette');
			
			var stageBuild = new Stage();
			addBehind(stageBuild);
			var stages:Array<String> = [SONG.song];
			switch(SONG.song)
			{
				case 'desertion':
					stages.push("desertion2");
				case 'intimidate': //insane
					stages.push("divergence-e");
					stages.push("panic-attack-e");
					stages.push("wake");
				default:
					//
			}
			for (stage in stages) {
				stageBuild.reloadStageFromSong(stage);
			}

			trace('preloaded stage and hud');
			
			loadPercent = 0.2;

			var charList:Array<String> = [SONG.player1, SONG.player2];

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
				default:
					//trace('loaded lol');
			}

			for(i in charList) {
				var char = new Character();
				char.isPlayer = (i == SONG.player1);
				char.reloadChar(i);
				addBehind(char);
				
				//trace('preloaded $i');

				var icon = new HealthIcon();
				icon.setIcon(i, false);
				addBehind(icon);
				loadPercent += (0.6 - 0.2) / charList.length;
			}
			
			trace('preloaded characters');
			loadPercent = 0.6;
			
			Paths.preloadSound('songs/${SONG.song}/Inst');
			if(SONG.needsVoices)
				Paths.preloadSound('songs/${SONG.song}/Voices');
			
			trace('preloaded music');
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
			
			trace('preloaded notes');
			loadPercent = 0.9;
			
			// add custom preloads here!!
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
					//trace('loaded lol');
			}
			
			loadPercent = 1.0;
			trace('finished loading');
			threadActive = false;
			FlxSprite.defaultAntialiasing = oldAnti;
			mutex.release();
		});
	}
	
	var byeLol:Bool = false;
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
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
	}
}