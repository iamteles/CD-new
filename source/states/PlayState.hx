package states;

import data.Discord.DiscordClient;
import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.addons.effects.FlxTrail;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;
import data.*;
import data.SongData.SwagSong;
import data.SongData.SwagSection;
import data.chart.*;
import data.GameData.MusicBeatState;
import gameObjects.*;
import gameObjects.hud.*;
import gameObjects.hud.note.*;
import shaders.*;
import states.editors.*;
import states.menu.*;
import subStates.*;
import openfl.filters.ShaderFilter;
import gameObjects.BGChar.CharGroup;
import data.Highscore.ScoreData;
import gameObjects.android.*;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

class PlayState extends MusicBeatState
{
	// song stuff
	public static var SONG:SwagSong;
	public static var songDiff:String = "normal";
	// more song stuff
	public var inst:FlxSound;
	public var vocals:FlxSound;
	public var musicList:Array<FlxSound> = [];
	
	public static var songLength:Float = 0;
	
	// story mode stuff
	public static var playList:Array<String> = [];
	public static var curWeek:String = '';
	public static var isStoryMode:Bool = false;
	public static var weekScore:Int = 0;

	// extra stuff
	public static var assetModifier:String = "base";
	public static var health:Float = 1;
	public static var blueballed:Int = 0;
	// score, misses, accuracy and other stuff
	// are on the Timings.hx class!!

	// objects
	public var stageBuild:Stage;

	public var characters:Array<Character> = [];
	public static var third:Character;
	public static var dad:Character;
	public static var boyfriend:Character;

	// strumlines
	public var strumlines:FlxTypedGroup<Strumline>;
	public var bfStrumline:Strumline;
	public var dadStrumline:Strumline;

	public var taikoStrumline:Strumline;

	public static var botplay:Bool = false;
	public static var validScore:Bool = true;

	// hud
	public var hudBuild:HudClass;
	public var moneyCount:MoneyCounter;
	public var countdown:Countdown;

	// cameras!!
	public var camGame:FlxCamera;
	public var camVg:FlxCamera;
	public var camHUD:FlxCamera;
	public var camStrum:FlxCamera;
	public var camTaiko:FlxCamera;
	public var camOther:FlxCamera; // used so substates dont collide with camHUD.alpha or camHUD.visible
	
	public static var cameraSpeed:Float = 1.0;
	public static var defaultCamZoom:Float = 1.0;
	public static var extraCamZoom:Float = 0.0;
	public static var forcedCamPos:Null<FlxPoint>;

	public static var camFollow:FlxObject = new FlxObject();

	public static var daSong:String;
	
	// paused
	public static var paused:Bool = false;

	public var barUp:FlxSprite;
	public var barDown:FlxSprite;
	public var vgblack:FlxSprite;

	public static var charGroup:CharGroup;

	var strumPos:Array<Float>;

	var conTxt:FlxSprite;
	var divTxt:FlxSprite;
	var bellaPop:FlxSprite;
	var bexPop:FlxSprite;
	var vhs:FlxSprite;

	var songLogo:FlxSprite;
	var underlay:FlxSprite;

	var bellasings:Bool = false;

	var bloom:ShaderFilter;
	var chrom:ShaderFilter;
	var echo:ShaderFilter;
	var anime:ShaderFilter;

	var playArea:FlxSprite;

	var songHasTaiko:Bool = false;
	var taikoTutorial:FlxSprite;
	var sinStarted:Null<Bool>;

	public static var invertedCharacters:Bool = false;

	public static function resetStatics()
	{
		beatSpeed = 4;
		beatZoom = 0;
		health = 1;
		cameraSpeed = 1.0;
		defaultCamZoom = 1.0;
		extraCamZoom = 0.0;
		forcedCamPos = null;
		paused = false;
		botplay = false;
		validScore = true;
		endedSong = false;

		Timings.init();
		SplashNote.resetStatics();

		assetModifier = SaveData.skin();
		if(SONG == null) return;
	}

	public static function resetSongStatics()
	{
		blueballed = 0;
	}

	override public function create()
	{
		super.create();
		CoolUtil.playMusic();

		resetStatics();
		if(SONG == null)
			SONG = SongData.loadFromJson("ugh");
		
		daSong = SONG.song.toLowerCase();

		if(daSong != "kaboom" || songDiff == "mania")
			invertedCharacters = false;

		SaveData.songs.set(daSong, true);
		//trace(SaveData.songs.get(daSong));
		SaveData.save();
		
		// adjusting the conductor
		Conductor.setBPM(SONG.bpm);
		Conductor.mapBPMChanges(SONG);
		
		// setting up the cameras
		camGame = new FlxCamera();

		camVg = new FlxCamera();
		camVg.bgColor.alpha = 0;
		
		camHUD = new FlxCamera();
		camHUD.bgColor.alphaFloat = 0;
		
		camStrum = new FlxCamera();
		camStrum.bgColor.alpha = 0;

		camTaiko = new FlxCamera();
		camTaiko.bgColor.alpha = 0;
		//camTaiko.alpha = 0;
		
		camOther = new FlxCamera();
		camOther.bgColor.alpha = 0;
		
		// adding the cameras
		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camVg, false);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camStrum, false);
		FlxG.cameras.add(camTaiko, false);
		FlxG.cameras.add(camOther, false);
		
		// default camera
		FlxG.cameras.setDefaultDrawTarget(camGame, true);
		
		//camGame.zoom = 0.6;
		
		stageBuild = new Stage();
		stageBuild.reloadStageFromSong(SONG.song);
		add(stageBuild);

		if(!SaveData.data.get("Low Quality")) {
			if(daSong == 'euphoria' || daSong == 'nefarious' || daSong == 'divergence')
			{
				charGroup = new CharGroup();
				add(charGroup);
			}
			else if(daSong == 'euphoria-vip' || daSong == 'nefarious-vip' || daSong == 'divergence-vip')
			{
				charGroup = new CharGroup(true);
				add(charGroup);
	
				conTxt = new FlxSprite(-700, -300);
				conTxt.loadGraphic(Paths.image("backgrounds/vip/" + daSong));
				conTxt.setGraphicSize(Std.int(conTxt.width * 1.5));
				conTxt.updateHitbox();
				conTxt.alpha = 0;
				conTxt.scrollFactor.set(0, 0);
				add(conTxt);
			}
		}
		
		camGame.zoom = defaultCamZoom + extraCamZoom;
		hudBuild = new HudClass();
		hudBuild.setAlpha(0);
		
		dad = new Character();
		changeChar(dad, SONG.player2);
		
		boyfriend = new Character();
		boyfriend.isPlayer = true;
		changeChar(boyfriend, SONG.player1);

		if (daSong == 'desertion') {
			third = new Character();
			changeChar(third, "bella-2d");
		}
		else if(daSong == "ripple") {
			third = new Character();
			changeChar(third, "empitri");
		}
		else if(daSong == "customer-service") {
			third = new Character();
			changeChar(third, "bella-cs");
		}
		
		// also updates the characters positions
		changeStage(stageBuild.curStage);
		
		if(daSong != "sin") {
			characters.push(dad);
			characters.push(boyfriend);
		}
		else {
			characters.push(boyfriend);
			characters.push(dad);
		}

		if(daSong == "desertion" || daSong == "ripple" || daSong == "customer-service") {
			characters.push(third);
		}
		
		// basic layering ig
		var addList:Array<FlxBasic> = [];
		
		for(char in characters)
		{
			addList.push(char);
		}
		addList.push(stageBuild.foreground);
		
		for(item in addList)
			add(item);

		if(!SaveData.data.get("Low Quality")) {
			if(daSong == 'convergence') {
				conTxt = new FlxSprite();
				conTxt.frames = Paths.getSparrowAtlas("hud/base/shes going to kill you");
				conTxt.animation.addByPrefix("idle", 'Breeh Idle', 24, true);
				conTxt.animation.play("idle");
				conTxt.scale.set(0.5, 0.5);
				conTxt.updateHitbox();
				conTxt.screenCenter();
				conTxt.alpha = 0;
				conTxt.cameras = [camHUD];
				add(conTxt);
	
				divTxt = new FlxSprite().loadGraphic(Paths.image("hud/base/convergence"));
				divTxt.screenCenter();
				divTxt.cameras = [camHUD];
				divTxt.alpha = 0;
				add(divTxt);
			}
			else if(daSong == 'desertion') {
				bexPop = new FlxSprite();
				bexPop.frames = Paths.getSparrowAtlas("backgrounds/desertion/power up");
				bexPop.animation.addByPrefix("idle", 'Bex Power Up0000', 24, true);
				bexPop.animation.play('idle');
				bexPop.scale.set(0.5, 0.5);
				bexPop.updateHitbox();
				bexPop.x -= bexPop.width;
				bexPop.y += 50;
				bexPop.cameras = [camOther];
				add(bexPop);
	
				bellaPop = new FlxSprite();
				bellaPop.frames = Paths.getSparrowAtlas("backgrounds/desertion/power up");
				bellaPop.animation.addByPrefix("idle", 'Bella Power Up0000', 24, true);
				bellaPop.animation.play('idle');
				bellaPop.scale.set(0.5, 0.5);
				bellaPop.updateHitbox();
				bellaPop.x = FlxG.width;
				bellaPop.y += 250;
				bellaPop.cameras = [camOther];
				add(bellaPop);
			}
			else if(daSong == 'divergence') {
				divTxt = new FlxSprite().loadGraphic(Paths.image("hud/base/divergence"));
				divTxt.screenCenter();
				divTxt.cameras = [camHUD];
				divTxt.alpha = 0;
				add(divTxt);
			}
			else if(daSong == 'intimidate') {
				vhs = new FlxSprite();
				vhs.frames = Paths.getSparrowAtlas("backgrounds/cave/vhs");
				vhs.animation.addByPrefix("idle", 'idle', 16, true);
				vhs.animation.play('idle');
				vhs.scale.set(3, 3);
				vhs.updateHitbox();
				vhs.screenCenter();
				vhs.alpha = 0;
				vhs.blend = LAYER;
				vhs.cameras = [camOther]; 
				add(vhs);
			}
			else if(daSong == 'sin') {
				conTxt = new FlxSprite();
				conTxt.frames = Paths.getSparrowAtlas("backgrounds/helica/eyes");
				conTxt.animation.addByPrefix("idle", 'helica eyes closed', 24, true);
				conTxt.animation.play("idle");
				conTxt.scale.set(0.7, 0.7);
				conTxt.updateHitbox();
				conTxt.screenCenter();
				conTxt.alpha = 0;
				conTxt.cameras = [camOther];
				add(conTxt);
	
				divTxt = new FlxSprite();
				divTxt.frames = Paths.getSparrowAtlas("backgrounds/helica/eyes");
				divTxt.animation.addByPrefix("idle", 'helica eyes open', 24, false);
				divTxt.animation.play("idle");
				divTxt.scale.set(0.7, 0.7);
				divTxt.updateHitbox();
				divTxt.screenCenter();
				divTxt.alpha = 0;
				divTxt.cameras = [camOther];
				add(divTxt);
			}
		}


		else if(daSong == "heartpounder")
		{
			var sideBars = new FlxSprite().loadGraphic(Paths.image('hud/base/sidebars'));
			sideBars.screenCenter();
			sideBars.cameras = [camOther];
			add(sideBars);

			if(!SaveData.data.get("Low Quality")) {
				var sd = new FlxSprite().loadGraphic(Paths.image('backgrounds/gfd/sd-tv'));
				sd.x = FlxG.width - sd.width - (160 + 25);
				if(!SaveData.data.get("Downscroll"))
					sd.y = FlxG.height - sd.height - 16;
				else
					sd.y = 16;
				sd.cameras = [camOther];
				sd.alpha = 0.5;
				add(sd);
			}
		}
		
		hudBuild.cameras = [camHUD];
		add(hudBuild);

		moneyCount = new MoneyCounter(0, -70); //shoutout to the day i accidentally deleted this
		moneyCount.cameras = [camOther];
		add(moneyCount);

		var the:String = daSong;
		var logoExists:Bool = true;
		if(!Paths.fileExists('images/hud/songnames/${daSong}.png')) {
			the = "allegro";
			logoExists = false;
		}

		underlay = new FlxSprite().loadGraphic(Paths.image('hud/base/underlay 2'));
		underlay.screenCenter(Y);
		underlay.x = -2000;
		underlay.cameras = [camOther];
		underlay.visible = logoExists;
		add(underlay);

		songLogo = new FlxSprite().loadGraphic(Paths.image('hud/songnames/$daSong'));
		songLogo.screenCenter(Y);
		songLogo.x = -2000;
		songLogo.cameras = [camOther];
		songLogo.visible = logoExists;
		add(songLogo);

		
		if(!SaveData.data.get("Low Quality")) {
			vgblack = new FlxSprite().loadGraphic(Paths.image("vignette"));
			vgblack.alpha = 0;
			vgblack.cameras = [camOther];
			add(vgblack);
		}


		countdown = new Countdown();
		countdown.cameras = [camOther];
		add(countdown);

		barUp = new FlxSprite().loadGraphic(Paths.image("hud/base/blackbar"));
		barUp.y = 0 - barUp.height + 25;
		barDown = new FlxSprite().loadGraphic(Paths.image("hud/base/blackbar"));
		barDown.y = FlxG.height -25;

		barUp.cameras = [camVg];
		barDown.cameras = [camVg];

		var barsByDefault = ['allegro', 'euphoria', 'nefarious', 'divergence', "intimidate", "exotic", "ripple", 'euphoria-vip', 'nefarious-vip', 'divergence-vip', "customer-service"];
		if(barsByDefault.contains(daSong)) {
			barUp.y = 0-55;
			barDown.y = FlxG.height - barDown.height+55;
		}
		else if(daSong == "heartpounder") {
			barUp.alpha = 0;
			barDown.alpha = 0;
		}

		var taikoSongs = ['sin', 'zanta'];
		if(taikoSongs.contains(daSong)) {
			songHasTaiko = true;
		}

		add(barUp);
		add(barDown);

		// strumlines
		strumlines = new FlxTypedGroup();
		strumlines.cameras = [camStrum];
		add(strumlines);
		
		//strumline.scrollSpeed = 4.0; // 2.8
		strumPos = [FlxG.width / 2, FlxG.width / 4];
		if(daSong == "heartpounder")
			strumPos = [160 + (960 / 2), 960 / 4]; //lmao?

		var downscroll:Bool = SaveData.data.get("Downscroll");
		var isSwapped:Bool = ((daSong == 'nefarious' || daSong == 'divergence') || (daSong == 'euphoria-vip'));
		var noteColors:Array<Array<Int>> = [dad.noteColor, boyfriend.noteColor];

		if(isSwapped)
			noteColors = [boyfriend.noteColor, dad.noteColor];

		var positions:Array<Float> = [strumPos[0] - strumPos[1], strumPos[0] + strumPos[1]];
		if(daSong == "divergence")
			positions = [strumPos[0] + strumPos[1], strumPos[0] - strumPos[1]];
		
		dadStrumline = new Strumline(positions[0], (isSwapped ? boyfriend : dad), downscroll, invertedCharacters, !invertedCharacters, assetModifier);
		dadStrumline.ID = 0;
		strumlines.add(dadStrumline);
		
		bfStrumline = new Strumline(positions[1], (isSwapped ? dad : boyfriend), downscroll, !invertedCharacters, invertedCharacters, assetModifier);
		bfStrumline.ID = 1;
		strumlines.add(bfStrumline);

		var isit:String = "";
		if(!SaveData.data.get("Downscroll"))
			isit = "-upscroll";

		var you:FlxSprite = new FlxSprite().loadGraphic(Paths.image("hud/base/you" + isit));
		you.scale.set(0.35, 0.35);
		you.updateHitbox();
		if((isSwapped || invertedCharacters) && daSong != "divergence")
			you.x = dadStrumline.x - (you.width/2);
		else
			you.x = bfStrumline.x - (you.width/2);

		if(SaveData.data.get("Downscroll"))
			you.y = 430;
		else
			you.y = 165;
		you.alpha = 0;
		you.cameras = [camStrum];
		add(you);

		if(daSong == "nefarious" || daSong == "kaboom") {
			FlxTween.tween(you, {alpha: 1}, 0.6, {
				ease: FlxEase.cubeOut,
				startDelay: 0.8,
				onComplete: function(twn:FlxTween)
				{
					FlxTween.tween(you, {alpha: 0}, 0.6, {
						ease: FlxEase.cubeIn,
						startDelay: 2.8
					});
				}
			});
		}

		if(daSong == "divergence") {
			FlxTween.tween(you, {alpha: 1}, 0.6, {
				ease: FlxEase.cubeOut,
				startDelay: 0.5,
				onComplete: function(twn:FlxTween)
				{
					FlxTween.tween(you, {alpha: 0}, 0.6, {
						ease: FlxEase.cubeIn,
						startDelay: 6.7
					});
				}
			});
		}

		if(songHasTaiko) {
			taikoStrumline = new Strumline(100, boyfriend, downscroll, true, false, "taiko", true);
			strumlines.add(taikoStrumline);
			taikoStrumline.scrollSpeed = 2.3;

			taikoStrumline.cameras = [camTaiko];

			playArea = new FlxSprite().loadGraphic(Paths.image("notes/taiko/play"));
			playArea.scale.set(0.7, 0.7);
			playArea.updateHitbox();
			playArea.x = 100 + 100;
			//playArea.x += 100;
			playArea.y = (!downscroll ? 40 : FlxG.height - playArea.height - 40);
			playArea.cameras = [camTaiko];
			add(playArea);
		}
		
		var middlescroll:Bool = (daSong == 'conservation' || daSong == 'irritation');
		if(middlescroll)
		{
			dadStrumline.x += strumPos[1]; // goes offscreen //IF I ever want to make something else, set to - for going offscreen
			bfStrumline.x  -= strumPos[1]; // goes to the middle

			for (thing in dadStrumline.strumGroup) {
				thing.alpha = 0.25;
			}

			for (thing in dadStrumline.allNotes) {
				thing.alpha = 0.25;
			}
			dadStrumline.noteAlpha = 0.25;

			dadStrumline.doSplash = false;

			/*
			// whatever
			var guitar = new DistantNoteShader();
			guitar.downscroll = downscroll;
			camStrum.setFilters([new openfl.filters.ShaderFilter(cast guitar.shader)]);
			*/
		}
		else if(daSong == 'divergence') {

			for (thing in dadStrumline.strumGroup) {
				thing.alpha = 0.5;
			}
	
			for (thing in dadStrumline.allNotes) {
				thing.alpha = 0.5;
			}
	
			dadStrumline.noteAlpha = 0.5;
		}
		else if(daSong == 'intimidate' || daSong == 'sin' || daSong == 'ripple' ||  daSong == 'convergence' || daSong == 'desertion' || daSong == 'customer-service')
			dadStrumline.x -= 2000;
		
		for(strumline in strumlines.members)
		{
			if(!strumline.isTaiko) strumline.scrollSpeed = SONG.speed;
			strumline.updateHitbox();
		}

		hudBuild.updateHitbox(bfStrumline.downscroll);
		
		/*for(strumline in strumlines.members)
		{
			strumline.isPlayer = !strumline.isPlayer;
			strumline.botplay = !strumline.botplay;
			if(!strumline.isPlayer)
			{
				strumline.downscroll = !strumline.downscroll;
				strumline.scrollSpeed = 1.0;
			}
			strumline.updateHitbox();
		}*/

		inst = new FlxSound();
		inst.loadEmbedded(Paths.inst(daSong), false, false);

		vocals = new FlxSound();
		if(SONG.needsVoices)
		{
			vocals.loadEmbedded(Paths.vocals(daSong), false, false);
		}

		songLength = inst.length;
		function addMusic(music:FlxSound):Void
		{
			FlxG.sound.list.add(music);

			if(music.length > 0)
			{
				musicList.push(music);

				if(music.length < songLength)
					songLength = music.length;
			}

			music.play();
			music.stop();
		}

		addMusic(inst);
		addMusic(vocals);

		//Conductor.setBPM(160);
		Conductor.songPos = -Conductor.crochet * 5;
		
		// setting up the camera following
		//followCamera(dad);
		followCamSection(SONG.notes[0]);
		//FlxG.camera.follow(camFollow, LOCKON, 1); // broken on lower/higher fps than 120
		FlxG.camera.focusOn(camFollow.getPosition());

		var unspawnNotesAll:Array<Note> = ChartLoader.getChart(SONG);

		for(note in unspawnNotesAll)
		{
			var thisStrumline = dadStrumline;
			for(strumline in strumlines)
			{
				if(note.strumlineID == strumline.ID)
					thisStrumline = strumline;
			}

			/*var thisStrum = thisStrumline.strumGroup.members[note.noteData];
			var thisChar = thisStrumline.character;*/

			var noteAssetMod:String = assetModifier;

			if(thisStrumline.isTaiko)
				noteAssetMod = "taiko";
			
			// the funny
			/*noteAssetMod = ["base", "pixel"][FlxG.random.int(0, 1)];
			if(note.isHold && note.parentNote != null)
				noteAssetMod = note.parentNote.assetModifier;*/

			var whichcolor:Bool = thisStrumline.isPlayer;

			note.reloadNote(note.songTime, note.noteData, note.noteType, noteAssetMod, (whichcolor ? noteColors[1] : noteColors[0]));

			// oop

			if(thisStrumline.isTaiko && !note.isHold && !note.isHoldEnd) {
				thisStrumline.addSplash(note);
				thisStrumline.unspawnNotes.push(note);
			}
			else if(!thisStrumline.isTaiko) {
				thisStrumline.addSplash(note);
				thisStrumline.unspawnNotes.push(note);
			}
		}

		if(songHasTaiko) {
			var taikoData = SongData.loadFromJson(daSong, "taiko");
			var unspawnNotesTaiko:Array<Note> = ChartLoader.getChart(taikoData);

			for(note in unspawnNotesTaiko)
			{
				var thisStrumline = taikoStrumline;
				var noteAssetMod:String = assetModifier;
				var whichcolor:Bool = thisStrumline.isPlayer;
	
				note.reloadNote(note.songTime, note.noteData, note.noteType, "taiko");
	
				// oop
	
				if(!note.isHold && !note.isHoldEnd) {
					thisStrumline.addSplash(note);
					thisStrumline.unspawnNotes.push(note);
				}
			}
		}
		
		// sliding notes
		/*for(strumline in strumlines)
		{
			strumline._update = function(elapsed:Float)
			{
				var sinStrum = Math.sin((Conductor.songPos / Conductor.crochet) / 2);
				
				for(strum in strumline.strumGroup)
				{
					strum.screenCenter(Y);
					strum.y += sinStrum * FlxG.height * 0.4;
				}
				
				strumline.downscroll = (sinStrum > 0);
				
				var daSpeed:Float = SONG.speed * Math.abs(sinStrum);
				if(daSpeed <= 0) daSpeed = 0.01;
				strumline.scrollSpeed = daSpeed;
			}
		}*/

		switch(SONG.song.toLowerCase())
		{
			case "disruption":
				// faz o dad voar só na disruption
				var initialPos = [dad.x - (dad.width / 2) + 100, dad.y - 100];
				var flyTime:Float = 0;
				dad._update = function(elapsed:Float)
				{
					flyTime += elapsed * Math.PI;
					dad.y = initialPos[1] + Math.sin(flyTime) * 100;
					dad.x = initialPos[0] + Math.cos(flyTime) * 100;
					
					if(startedSong)
					{
						for(strum in dadStrumline.strumGroup)
						{
							var fuckyoubambi:Int = ((strum.strumData % 2 == 0) ? -1 : 1);
						
							strum.x = strum.initialPos.x + Math.sin(flyTime / 2) * 20 * fuckyoubambi;
							strum.y = strum.initialPos.y + Math.cos(flyTime / 2) * 20 * fuckyoubambi;
							strum.scale.x = strum.strumSize + Math.sin(flyTime / 2) * 0.3;
							strum.scale.y = strum.strumSize - Math.sin(flyTime / 2) * 0.3;
						}
						for(uNote in dadStrumline.unspawnNotes)
						{
							if(uNote.visible)
							{
								var daStrum = dadStrumline.strumGroup.members[uNote.noteData];
								uNote.scale.x = daStrum.scale.x;
								if(!uNote.isHold)
									uNote.scale.y = daStrum.scale.y;
							}
						}
					}
				}
		}

		// Updating Discord Rich Presence
		DiscordClient.changePresence("Playing: " + SONG.song.toUpperCase().replace("-", " "), null);
		for(strumline in strumlines.members)
		{
			var strumMult:Int = (strumline.downscroll ? 1 : -1);
			for(strum in strumline.strumGroup)
			{
				strum.y += FlxG.height / 4 * strumMult;
			}
		}

		var bloomSongs:Array<String> = ["heartpounder"];
		var echoSongs:Array<String> = ["ripple", "intimidate", "divergence", "divergence-vip"];
		var chromSongs:Array<String> = ["convergence", "desertion"];

		if(SaveData.data.get("Shaders")) {
			if(bloomSongs.contains(daSong)){
				var bloomR = new FlxRuntimeShader('
					#pragma header

					const float amount = 2.0;

					// GAUSSIAN BLUR SETTINGS
					float dim = 1.8;
					float Directions = 16.0;
					float Quality = 8.0;
					float Size = 8.0;

					vec2 Radius = Size/openfl_TextureSize.xy;

					void main(void)
					{
						vec2 uv = openfl_TextureCoordv.xy;
						vec2 pixel  = uv * openfl_TextureSize.xy;
					float Pi = 6.28318530718; // Pi*2
					vec4 Color = texture2D(bitmap, uv);
					for(float d = 0.0; d < Pi; d += Pi / Directions)
					{
						for(float i=1.0/Quality; i <= 1.0; i += 1.0 / Quality)
						{		
						float ex = (cos(d) * Size * i) / openfl_TextureSize.x;
						float why = (sin(d) * Size * i) / openfl_TextureSize.y;
						Color += flixel_texture2D(bitmap, uv + vec2(ex, why));	
						}
					}
					Color /= (dim * Quality) * Directions - 15.0;
					vec4 bloom =  (flixel_texture2D( bitmap, uv) / dim) + Color;
					gl_FragColor = bloom;
					}
				');
				bloom = new ShaderFilter(bloomR);
			}
			
			if(chromSongs.contains(daSong)) {
				var chromR = new FlxRuntimeShader('
				#pragma header
		
				void main()
				{
					vec4 col1 = texture2D(bitmap, openfl_TextureCoordv.st - vec2(0.002, 0.0));
					vec4 col2 = texture2D(bitmap, openfl_TextureCoordv.st - vec2(0.0, 0.0));
					vec4 col3 = texture2D(bitmap, openfl_TextureCoordv.st - vec2(0.002, 0.0));
					vec4 toUse = texture2D(bitmap, openfl_TextureCoordv);
					toUse.r = col1.r;
					toUse.g = col2.g;
					toUse.b = col3.b;
					//float someshit = col4.r + col4.g + col4.b;
		
					gl_FragColor = toUse;
				}
				');
				chrom = new ShaderFilter(chromR);
			}

			if(echoSongs.contains(daSong)) {
				var echoR = new FlxRuntimeShader('
				#pragma header
				vec2 uv = openfl_TextureCoordv.xy;
				vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
				vec2 iResolution = openfl_TextureSize;
				uniform float iTime;
				#define iChannel0 bitmap
				#define texture flixel_texture2D
				#define fragColor gl_FragColor
				#define mainImage main
				
				int sampleCount = 50;
				float blur = 0.25; 
				float falloff = 3.0; 
				
				// use iChannel0 for video, iChannel1 for test grid
				#define INPUT iChannel0
				
				void mainImage()
				{
					vec2 destCoord = fragCoord.xy / iResolution.xy;
				
					vec2 direction = normalize(destCoord - 0.5); 
					vec2 velocity = direction * blur * pow(length(destCoord - 0.5), falloff);
					float inverseSampleCount = 1.0 / float(sampleCount); 
					
					mat3x2 increments = mat3x2(velocity * 1.0 * inverseSampleCount,
											   velocity * 2.0 * inverseSampleCount,
											   velocity * 4.0 * inverseSampleCount);
				
					vec3 accumulator = vec3(0);
					mat3x2 offsets = mat3x2(0); 
					
					for (int i = 0; i < sampleCount; i++) {
						accumulator.r += texture(INPUT, destCoord + offsets[0]).r; 
						accumulator.g += texture(INPUT, destCoord + offsets[1]).g; 
						accumulator.b += texture(INPUT, destCoord + offsets[2]).b; 
						
						offsets -= increments;
					}
				
					fragColor = vec4(accumulator / float(sampleCount), 1.0);
				}
				');
				echo = new ShaderFilter(echoR);
			}
		}

		switch(daSong) {
			case "heartpounder":
				if(SaveData.data.get("Shaders"))FlxG.camera.setFilters([bloom]);
			case "customer-service":
				if(!SaveData.data.get("Low Quality")) {
					camHUD.alpha = 0;
					camStrum.alpha = 0;
					third.alpha = 0;
					bellasings = false;
				}
				else {
					bellasings = true;
				}
			case "ripple":
				if(!SaveData.data.get("Low Quality")) {
					camHUD.alpha = 0;
				}
				zoomInOpp = true;
				zoomOppVal = -0.2;

			case "divergence":
				if(!SaveData.data.get("Low Quality")) {
					camHUD.alpha = 0;
					camStrum.alpha = 0;
				}

			case "sin":
				if(!SaveData.data.get("Low Quality")) {
					dad.alpha = 0;
					camHUD.alpha = 0;
					vgblack.alpha = 0.8;
					FlxG.camera.fade(0xFF000000, 0.01, false);
					stageBuild.tweenStage(0, 0.01);
				}

				camTaiko.alpha = 0;

			case 'convergence':
				if(!SaveData.data.get("Low Quality")) {
					vgblack.alpha = 0.4;
					camHUD.alpha = 0;
					camStrum.alpha = 0;
					camVg.fade(0x00000000, 0.01, false);
				}

				if(SaveData.data.get("Shaders"))FlxG.camera.setFilters([chrom]);
				zoomInOpp = true;
				zoomOppVal = 0.97 - 0.8;
			case 'desertion':
				if(!SaveData.data.get("Low Quality")) {
					vgblack.alpha = 0.6;
					dad.alpha = 0;
					camHUD.alpha = 0;
					camVg.fade(0x00000000, 0.01, false);
				}

				zoomInOpp = true;
				zoomOppVal = 0.2;
			case 'irritation':
				if(!SaveData.data.get("Low Quality")) {
					camHUD.alpha = 0;
					camStrum.alpha = 0;
					camVg.alpha = 0;
				}
				boyfriend.alpha = 0;
			case 'conservation':
				if(!SaveData.data.get("Low Quality")) {
					camHUD.alpha = 0;
					camStrum.alpha = 0;
					camVg.alpha = 0;
				}

				boyfriend.alpha = 0;
				zoomInOpp = true;
				zoomOppVal = 0.06;
			case 'panic-attack':
				if(!SaveData.data.get("Low Quality")) {
					camHUD.alpha = 0;
					camStrum.alpha = 0;
					FlxG.camera.fade(0xFF000000, 0.01, false);
				}

				zoomInOpp = true;
				zoomOppVal = 0.05;

			case 'intimidate':
				if(!SaveData.data.get("Low Quality")) {
					dad.alpha = 0;
					vgblack.alpha = 0.8;
					FlxG.camera.fade(0xFF000000, 0.01, false);
				}

			case 'divergence-vip':
				if(!SaveData.data.get("Low Quality")) {
					FlxG.camera.fade(0xFF000000, 0.01, false);
				}

		}

		
		if(hasCutscene())
		{
			switch(SONG.song)
			{
				case "sin":
					var thing:String = "menu/story/Taiko-tutorial";
					if(SaveData.data.get("Touch Controls"))
						thing += "-touch";
					taikoTutorial = new FlxSprite().loadGraphic(Paths.image(thing));
					taikoTutorial.cameras = [camOther];
					taikoTutorial.scrollFactor.set();
					taikoTutorial.screenCenter();
					add(taikoTutorial);

					sinStarted = false;

				default:
					startCountdown();
			}
		}
		else
			startCountdown();

		if(SaveData.data.get("Touch Controls")) {
			hitbox = new Hitbox();
			hitbox.cameras = [camOther];
			add(hitbox);
		}
	}

	var hitbox:Hitbox;
	
	public var startedCountdown:Bool = false;
	public var startedSong:Bool = false;

	var skipCountdown:Array<String> = ["panic-attack", "convergence", "desertion"];

	public function startCountdown()
	{
		var daCount:Int = 0;

		if(skipCountdown.contains(daSong)) { //does everything important in the countdown but directly
			var countTimer = new FlxTimer().start(0.5, function(tmr:FlxTimer)
			{
				startedCountdown = true;
				for(strumline in strumlines.members)
				{
					if(!strumline.isTaiko) {
						for(strum in strumline.strumGroup)
						{
							var strumData:Int = (strumline.isPlayer ? strum.strumData : 3 - strum.strumData);
							FlxTween.tween(strum, {y: strum.initialPos.y}, Conductor.crochet / 1000, {
								ease: FlxEase.cubeOut,
								startDelay: Conductor.crochet / 2 / 1000 * strumData,
							});
						}
					}
				}

				hudBuild.setAlpha(1, Conductor.crochet * 2 / 1000);

				startSong();

				if(daSong != "desertion")
					startLogo();
			});
		}
		else {
			var countTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
			{
				Conductor.songPos = -Conductor.crochet * (4 - daCount);
	
				if(daCount == 1 && (daSong == "nefarious")) {
					noteSwap(false);
				}
	
				if(daCount == 0)
				{
					startedCountdown = true;
					for(strumline in strumlines.members)
					{
						if(!strumline.isTaiko) {
							for(strum in strumline.strumGroup)
							{
								var strumData:Int = (strumline.isPlayer ? strum.strumData : 3 - strum.strumData);
								FlxTween.tween(strum, {y: strum.initialPos.y}, Conductor.crochet / 1000, {
									ease: FlxEase.cubeOut,
									startDelay: Conductor.crochet / 2 / 1000 * strumData,
								});
							}
						}
					}
				}
				
				// when the girl say "one" the hud appears
				if(daCount == 2 && daSong != 'intimidate')
				{
					hudBuild.setAlpha(1, Conductor.crochet * 2 / 1000);
				}
	
				if(daCount == 4)
				{
					startSong();

					if(daSong != "intimidate") {
						startLogo();
					}
				}
	
				if(daCount != 4)
				{
					var soundName:String = ["intro3", "intro2", "intro1", "introGo"][daCount];
					
					var soundPath:String = assetModifier;
					if(!Paths.fileExists('sounds/countdown/$soundPath/$soundName.ogg'))
						soundPath = 'base';
					
					FlxG.sound.play(Paths.sound('countdown/$soundPath/$soundName'));
				}
	
				////trace(daCount);

				countdown.cycle(daCount);
	
				daCount++;
			}, 5);
		}
	}

	function startLogo()
	{
		FlxTween.tween(songLogo, {x: (FlxG.width/2) - (songLogo.width/2)}, 1.3, {
			ease: FlxEase.cubeOut,
			startDelay: 0.2,
			onComplete: function(twn:FlxTween)
			{
				FlxTween.tween(songLogo, {x: 2000}, 1.3, {
					ease: FlxEase.cubeIn,
					startDelay: 1.3
				});
			}
		});

		FlxTween.tween(underlay, {x: (FlxG.width/2) - (underlay.width/2)}, 1.3, {
			ease: FlxEase.cubeOut,
			startDelay: 0.2,
			onComplete: function(twn:FlxTween)
			{
				FlxTween.tween(underlay, {x: 2000}, 1.3, {
					ease: FlxEase.cubeIn,
					startDelay: 1.3
				});
			}
		});
	}
	
	public function hasCutscene():Bool
	{
		return switch(SaveData.data.get('Cutscenes'))
		{
			default: true;
			case "FREEPLAY OFF": isStoryMode;
			case "OFF": false;
		}
	}

	public function startSong()
	{
		startedSong = true;
		for(music in musicList)
		{
			music.stop();
			music.play();

			if(paused) {
				music.pause();
			}
		}
	}

	override function openSubState(state:FlxSubState)
	{
		super.openSubState(state);
		if(startedSong)
		{
			for(music in musicList)
			{
				music.pause();
			}
		}
	}

	override function closeSubState()
	{
		activateTimers(true);
		super.closeSubState();
		if(startedSong)
		{
			for(music in musicList)
			{
				music.play();
			}
			syncSong();
		}
	}

	// for pausing timers and tweens
	function activateTimers(apple:Bool = true)
	{
		FlxTimer.globalManager.forEach(function(tmr:FlxTimer)
		{
			if(!tmr.finished)
				tmr.active = apple;
		});

		FlxTween.globalManager.forEach(function(twn:FlxTween)
		{
			if(!twn.finished)
				twn.active = apple;
		});
	}

	// check if you actually hit it
	public function checkNoteHit(note:Note, strumline:Strumline)
	{
		if(!note.mustMiss)
			onNoteHit(note, strumline);
		else
			onNoteMiss(note, strumline);
	}
	
	var helicaPunch:Bool = false;
	var breePunch:Bool = false;
	// actual note functions
	function onNoteHit(note:Note, strumline:Strumline)
	{
		var thisStrum = strumline.strumGroup.members[note.noteData];
		var thisChar = strumline.character;

		// anything else
		note.gotHeld = true;
		note.gotHit = true;
		note.missed = false;
		if(!note.isHold)
			note.visible = false;
		
		if(note.mustMiss) return;

		thisStrum.playAnim("confirm");

		// when the player hits notes
		vocals.volume = 1;
		if(strumline.isPlayer)
		{
			popUpRating(note, strumline, false);
		}

		if(!note.isHold)
		{
			var noteDiff:Float = Math.abs(note.songTime - Conductor.songPos);
			if(noteDiff <= Timings.timingsMap.get("sick")[0] || strumline.botplay)
			{
				strumline.playSplash(note);
			}
		}

		if(thisChar != null && !note.isHold)
		{
			if(note.noteType != "no animation" && !singList.contains(thisChar.animation.curAnim.name))
			{
				switch (note.noteType) {
					case 'beam':
						boyfriend.playAnim("dodge", true);
						boyfriend.holdTimer = 0;

						dad.playAnim("shoot", true);
						dad.holdTimer = 0;

						stageBuild.objectMap.get("bex").animation.play("flinch");

						FlxG.sound.play(Paths.sound("thunder"));
					case 'bella':
						if(third != null) {
							third.playAnim(third.singAnims[note.noteData], true);
							third.holdTimer = 0;
							if(daSong != "customer-service") bellasings = true;
						}
					case 'alt':
						thisChar.playAnim(thisChar.singAnims[note.noteData] + "alt", true);
						thisChar.holdTimer = 0;
					default:
						if(strumline.isTaiko) {
							FlxG.sound.play(Paths.sound('punch/punch_' + FlxG.random.int(1, 4)), 0.55);
							switch(note.noteData) {
								case 0 | 1:
									boyfriend.playAnim((breePunch ? "pright" : "pleft"), true);
									boyfriend.holdTimer = 0;
			
									dad.playAnim("block", true);
									dad.holdTimer = 0;
									breePunch = !breePunch;
								case 2 | 3:
									dad.playAnim((helicaPunch ? "pright" : "pleft"), true);
									dad.holdTimer = 0;
			
									boyfriend.playAnim("block", true);
									boyfriend.holdTimer = 0;
									helicaPunch = !helicaPunch;
							}

						}
						else {
							thisChar.playAnim(thisChar.singAnims[note.noteData], true);
							thisChar.holdTimer = 0;
							if(daSong != "ripple" && daSong != "customer-service") bellasings = false;
	
							if(daSong == "desertion" && !strumline.isPlayer) {
								if (health > 0.1)
								{
									if (note.isHold || note.isHoldEnd)
									{
										health -= 0.010;
									}
									else
										health -= 0.050;
								}
							}
						}
				}
			}
		}
	}
	function onNoteMiss(note:Note, strumline:Strumline)
	{
		var thisStrum = strumline.strumGroup.members[note.noteData];
		var thisChar = strumline.character;

		note.gotHit = false;
		note.missed = true;
		note.setAlpha();

		// put stuff inside onlyOnce
		var onlyOnce:Bool = false;
		if(!note.isHold)
			onlyOnce = true;
		else
		{
			if(note.isHoldEnd && note.holdHitLength > 0)
				onlyOnce = true;
		}

		if(onlyOnce)
		{
			vocals.volume = 0;

			if(!strumline.isTaiko)
				FlxG.sound.play(Paths.sound('miss/miss' + FlxG.random.int(1, 3)), 0.55);
			else
				FlxG.sound.play(Paths.sound('punch/punch_' + FlxG.random.int(1, 4)), 0.55);

			if(thisChar != null && note.noteType != "no animation" && !singList.contains(thisChar.animation.curAnim.name))
			{
				if(strumline.isTaiko) {
					boyfriend.playAnim("hit", true);
					boyfriend.holdTimer = 0;

					dad.playAnim((helicaPunch ? "pright" : "pleft"), true);
					dad.holdTimer = 0;
					helicaPunch = !helicaPunch;
				}
				else {
					switch (note.noteType) {
						case 'beam':
							health -= 0.16;
	
							dad.playAnim("shoot", true);
							dad.holdTimer = 0;
	
							stageBuild.objectMap.get("bex").animation.play("flinch");
	
							FlxG.sound.play(Paths.sound("thunder"));
					}
	
					thisChar.miss(note.noteData);
				}
			}

			// when the player misses notes
			if(strumline.isPlayer)
			{
				popUpRating(note, strumline, true);
			}
		}
	}
	function onNoteHold(note:Note, strumline:Strumline)
	{
		// runs until you hold it enough
		if(note.holdHitLength > note.holdLength) return;
		
		var thisStrum = strumline.strumGroup.members[note.noteData];
		var thisChar = strumline.character;
		
		vocals.volume = 1;
		thisStrum.playAnim("confirm");
		
		// DIE!!!
		if(note.mustMiss)
			health -= 0.005;

		if(note.gotHit) return;

		if(note.noteType != "no animation"  && !singList.contains(thisChar.animation.curAnim.name))
		{
			switch (note.noteType) {
				case 'beam':
					boyfriend.playAnim("dodge", true);
					boyfriend.holdTimer = 0;

					dad.playAnim("shoot", true);
					dad.holdTimer = 0;

					stageBuild.objectMap.get("bex").animation.play("flinch");
				case 'bella':
					if(third != null) {
						third.playAnim(third.singAnims[note.noteData], true);
						third.holdTimer = 0;
						if(daSong != "customer-service") bellasings = true;
					}
				default:
					thisChar.playAnim(thisChar.singAnims[note.noteData], true);
					thisChar.holdTimer = 0;
					if(daSong != "ripple" && daSong != "customer-service") bellasings = false;
			}
		}
	}

	public function popUpRating(note:Note, strumline:Strumline, miss:Bool = false)
	{
		var noteDiff:Float = Math.abs(note.songTime - Conductor.songPos);
		if((note.isHold && !miss) || strumline.botplay)
			noteDiff = 0;

		var rating:String = Timings.diffToRating(noteDiff);
		var judge:Float = Timings.diffToJudge(noteDiff);
		if(miss)
		{
			rating = "miss";
			judge = Timings.timingsMap.get('miss')[1];
		}

		// handling stuff
		health += 0.05 * judge;
		Timings.score += Math.floor(100 * judge);
		Timings.addAccuracy(judge);

		if(miss)
		{
			Timings.misses++;

			if(Timings.combo > 0)
				Timings.combo = 0;
			Timings.combo--;
		}
		else
		{
			if(Timings.combo < 0)
				Timings.combo = 0;
			Timings.combo++;

			if(note.isHold)
				health += 0.05 * (note.holdLength / note.noteCrochet) / 2;

			if(rating == "shit")
			{
				//note.onMiss();
				// forces a miss anyway
				onNoteMiss(note, strumline);
			}
		}

		var daRating = new Rating(rating, Timings.combo, note.assetModifier);

		/*
		if(SaveData.data.get("Ratings on HUD"))
		{
			hudBuild.add(daRating);
			
			for(item in daRating.members)
				item.cameras = [camHUD];

			var daX:Float = (FlxG.width / 2) - 64;
			if(SaveData.data.get("Middlescroll"))
				daX -= FlxG.width / 4;

			daRating.setPos(daX, FlxG.height / 2);
		}
		else
		{*/
			add(daRating);

			daRating.setPos(
				boyfriend.x + boyfriend.ratingsOffset.x,
				boyfriend.y + boyfriend.ratingsOffset.y
			);
		//}

		hudBuild.updateText();
	}
	
	var pressed:Array<Bool> 	= [];
	var justPressed:Array<Bool> = [];
	var released:Array<Bool> 	= [];
	
	var playerSinging:Bool = false;

	var isTouch:Bool = false;
	
	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		var followLerp:Float = cameraSpeed * 5 * elapsed;
		if(followLerp > 1) followLerp = 1;

		CoolUtil.dumbCamPosLerp(camGame, camFollow, followLerp);

		if(Controls.justPressed("PAUSE"))
		{
			pauseSong();
		}

		if(Controls.justPressed("RESET"))
			startGameOver();

		if(botplay && startedSong)
			validScore = false;

		if(SaveData.progression.get("debug")) {
			if(FlxG.keys.justPressed.ONE) {
				endSong();
			}
			if(FlxG.keys.justPressed.SEVEN)
			{
				if(ChartingState.SONG.song != SONG.song)
					ChartingState.curSection = 0;
				
				ChartingState.songDiff = songDiff;
	
				ChartingState.SONG = SONG;
				Main.switchState(new ChartingState());
			}
			if(FlxG.keys.justPressed.EIGHT)
			{
				var char = dad;
				if(FlxG.keys.pressed.SHIFT)
					char = boyfriend;
	
				Main.switchState(new CharacterEditorState(char.curChar));
			}
		}

		if(sinStarted != null) {
			if(!sinStarted) {
				#if mobile
				for (touch in FlxG.touches.list)
				{
					if (touch.justPressed)
						isTouch = true;
				}
				#end
		
				if(Controls.justPressed("ACCEPT") || isTouch) {
					FlxTween.tween(taikoTutorial, {alpha: 0}, 1, {ease: FlxEase.circInOut, onComplete: function(twn:FlxTween)
					{
						startCountdown();
					}});

					sinStarted = true;
				}
			}
		}

		/*if(FlxG.keys.justPressed.SPACE)
		{
			for(strumline in strumlines.members)
			{
				strumline.downscroll = !strumline.downscroll;
				strumline.updateHitbox();
			}
			hudBuild.updateHitbox(bfStrumline.downscroll);
		}*/

		//strumline.scrollSpeed = 2.8 + Math.sin(FlxG.game.ticks / 500) * 1.5;

		//if(song.playing)
		//	Conductor.songPos = song.time;
		// syncSong
		if(startedCountdown)
			Conductor.songPos += elapsed * 1000;

		#if mobile
		if(FlxG.android.justReleased.BACK)
		{
			pauseSong();
		}
		#end

		if(SaveData.data.get("Touch Controls")) {
			pressed = [
				hitbox.buttonLeft.pressed,
				hitbox.buttonDown.pressed,
				hitbox.buttonUp.pressed,
				hitbox.buttonRight.pressed
			];
			justPressed = [
				hitbox.buttonLeft.justPressed,
				hitbox.buttonDown.justPressed,
				hitbox.buttonUp.justPressed,
				hitbox.buttonRight.justPressed
			];
			released = [
				hitbox.buttonLeft.released,
				hitbox.buttonDown.released,
				hitbox.buttonUp.released,
				hitbox.buttonRight.released
			];
		}
		else {
			pressed = [
				Controls.pressed("LEFT"),
				Controls.pressed("DOWN"),
				Controls.pressed("UP"),
				Controls.pressed("RIGHT")
			];
			justPressed = [
				Controls.justPressed("LEFT"),
				Controls.justPressed("DOWN"),
				Controls.justPressed("UP"),
				Controls.justPressed("RIGHT")
			];
			released = [
				Controls.released("LEFT"),
				Controls.released("DOWN"),
				Controls.released("UP"),
				Controls.released("RIGHT")
			];
		}

		
		playerSinging = false;
		
		// strumline handler!!
		for(strumline in strumlines.members)
		{
			if(strumline.isPlayer)
				strumline.botplay = botplay;

			for(strum in strumline.strumGroup)
			{
				if(strumline.isPlayer && !strumline.botplay)
				{
					if(pressed[strum.strumData])
					{
						if(!["pressed", "confirm"].contains(strum.animation.curAnim.name))
							strum.playAnim("pressed");
					}
					else
						strum.playAnim("static");
					
					if(strum.animation.curAnim.name == "confirm")
						playerSinging = true;
				}
				else
				{
					// how botplay handles it
					if(strum.animation.curAnim.name == "confirm"
					&& strum.animation.curAnim.finished)
						strum.playAnim("static");
				}
			}

			for(unsNote in strumline.unspawnNotes)
			{
				var spawnTime:Int = 1000;
				if(strumline.scrollSpeed <= 1.5)
					spawnTime = 5000;

				if(unsNote.songTime - Conductor.songPos <= spawnTime && !unsNote.spawned)
				{
					if(strumline.isTaiko)
						unsNote.x = FlxG.height * 4;
					else
						unsNote.y = FlxG.height * 4;
					unsNote.spawned = true;
					strumline.addNote(unsNote);
				}
			}
			for(note in strumline.allNotes)
			{
				var despawnTime:Int = 300;
				
				if(Conductor.songPos >= note.songTime + note.holdLength + Conductor.crochet + despawnTime)
				{
					if(!note.gotHit && !note.missed && !note.mustMiss && !strumline.botplay)
						onNoteMiss(note, strumline);
					
					strumline.removeNote(note);
				}
			}

			// downscroll
			var downMult:Int = (strumline.downscroll ? -1 : 1);

			for(note in strumline.noteGroup)
			{
				var thisStrum = strumline.strumGroup.members[note.noteData];
				
				// follows the strum
				if(strumline.isTaiko) {
					note.y = playArea.y + note.noteOffset.y;
					note.x = playArea.x + (thisStrum.width / 12 * downMult) + (note.noteOffset.x * downMult);
					
					// adjusting according to the song position
					note.x += ((note.songTime - Conductor.songPos) * (strumline.scrollSpeed * 0.45));
				}
				else {
					note.x = thisStrum.x + note.noteOffset.x;
					note.y = thisStrum.y + (thisStrum.height / 12 * downMult) + (note.noteOffset.y * downMult);
					
					// adjusting according to the song position
					note.y += downMult * ((note.songTime - Conductor.songPos) * (strumline.scrollSpeed * 0.45));
				}
				
				if(strumline.botplay)
				{
					// hitting notes automatically
					if(note.songTime - Conductor.songPos <= 0 && !note.gotHit && !note.mustMiss)
					{
						checkNoteHit(note, strumline);
					}
				}
				else
				{
					// missing notes automatically
					if(Conductor.songPos >= note.songTime + Timings.timingsMap.get("good")[0]
					&& !note.gotHit && !note.missed && !note.mustMiss)
					{
						onNoteMiss(note, strumline);
					}
				}

				// doesnt actually do anything
				if (note.scrollSpeed != strumline.scrollSpeed)
					note.scrollSpeed = strumline.scrollSpeed;
			}
			
			for(hold in strumline.holdGroup)
			{
				if(hold.scrollSpeed != strumline.scrollSpeed)
				{
					hold.scrollSpeed = strumline.scrollSpeed;

					if(!hold.isHoldEnd)
					{
						var newHoldSize:Array<Float> = [
							hold.frameWidth * hold.scale.x,
							hold.noteCrochet * (strumline.scrollSpeed * 0.45)
						];
						
						if(SaveData.data.get("Split Holds"))
							newHoldSize[1] -= 20;

						hold.setGraphicSize(
							Math.floor(newHoldSize[0]),
							Math.floor(newHoldSize[1])
						);
					}

					hold.updateHitbox();
				}

				hold.flipY = strumline.downscroll;
				if(hold.assetModifier == "base")
					hold.flipX = hold.flipY;
				
				var holdParent = hold.parentNote;
				if(holdParent != null)
				{
					var thisStrum = strumline.strumGroup.members[hold.noteData];
					
					hold.x = holdParent.x;
					hold.y = holdParent.y;
					if(!holdParent.isHold)
					{
						hold.x += holdParent.width / 2 - hold.width / 2;
						hold.y = holdParent.y + holdParent.height / 2;
						if(strumline.downscroll)
							hold.y -= hold.height;
					}
					else
					{
						if(strumline.downscroll)
							hold.y -= hold.height;
						else
							hold.y += holdParent.height;
					}
					
					if(SaveData.data.get('Split Holds'))
						hold.y += 20 * downMult;
					
					if(holdParent.gotHeld && !hold.missed)
					{
						hold.gotHeld = true;
						
						hold.holdHitLength = (Conductor.songPos - hold.songTime);
							
						var daRect = new FlxRect(
							0,
							0,
							hold.frameWidth,
							hold.frameHeight
						);
						
						var center:Float = (thisStrum.y + thisStrum.height / 2);
						if(!strumline.downscroll)
						{
							if(hold.y < center)
								daRect.y = (center - hold.y) / hold.scale.y;
						}
						else
						{
							if(hold.y + hold.height > center)
								daRect.y = ((hold.y + hold.height) - center) / hold.scale.y;
						}
						hold.clipRect = daRect;
						
						if(hold.isHoldEnd)
							onNoteHold(hold, strumline);
						
						if(hold.holdHitLength >= holdParent.holdLength - Conductor.stepCrochet)
						{
							if(hold.isHoldEnd && !hold.gotHit)
								onNoteHit(hold, strumline);
							hold.missed = false;
							hold.gotHit = true;
						}
						else if(!pressed[hold.noteData] && !strumline.botplay && strumline.isPlayer)
						{
							onNoteMiss(hold, strumline);
						}
					}
					
					if(holdParent.missed && !hold.missed)
						onNoteMiss(hold, strumline);
				}
			}

			// this right here is the input code
			if(justPressed.contains(true) && !strumline.botplay && strumline.isPlayer)
			{
				if(!strumline.isTaiko) {
					for(i in 0...justPressed.length)
					{
						if(justPressed[i])
						{
							var possibleHitNotes:Array<Note> = []; // gets the possible ones
							var canHitNote:Note = null;
							
							for(note in strumline.noteGroup)
							{
								var noteDiff:Float = (note.songTime - Conductor.songPos);
								
								var minTiming:Float = Timings.minTiming;
								if(note.mustMiss)
									minTiming = Timings.timingsMap.get("good")[0];
	
								if(noteDiff <= minTiming && !note.missed && !note.gotHit && note.noteData == i)
								{
									if(note.mustMiss && Conductor.songPos >= note.songTime + Timings.timingsMap.get("sick")[0])
									{
										continue;
									}
									possibleHitNotes.push(note);
									canHitNote = note;
								}
							}
							
							// if the note actually exists then you got it
							if(canHitNote != null)
							{
								for(note in possibleHitNotes)
								{
									if(note.songTime < canHitNote.songTime)
										canHitNote = note;
								}
	
								checkNoteHit(canHitNote, strumline);
							}
							else
							{
								if(!songHasTaiko) {
									var thisChar = strumline.character;
									if(thisChar != null)
									{
										thisChar.miss(i);
									}
									// you ghost tapped lol
									if(!SaveData.data.get("Ghost Tapping") && startedCountdown)
									{
										vocals.volume = 0;
		
										var note = new Note();
										note.reloadNote(0, i, "none", assetModifier);
										onNoteMiss(note, strumline);
									}
								}
							}
						}
					}
				}
				else{
					for(i in 0...justPressed.length)
					{
						if(justPressed[i])
						{
							var possibleHitNotes:Array<Note> = []; // gets the possible ones
							var canHitNote:Note = null;

							var noteIndex:Int = taikoShit(i);

							if(noteIndex == -1)
								continue;
							
							for(note in strumline.noteGroup)
							{
								var noteDiff:Float = (note.songTime - Conductor.songPos);
								
								var minTiming:Float = Timings.minTiming;
								if(note.mustMiss)
									minTiming = Timings.timingsMap.get("good")[0];
	
								if(noteDiff <= minTiming && !note.missed && !note.gotHit && note.noteData == noteIndex)
								{
									if(note.mustMiss && Conductor.songPos >= note.songTime + Timings.timingsMap.get("sick")[0])
									{
										continue;
									}
									possibleHitNotes.push(note);
									canHitNote = note;
								}
							}
							
							// if the note actually exists then you got it
							if(canHitNote != null)
							{
								for(note in possibleHitNotes)
								{
									if(note.songTime < canHitNote.songTime)
										canHitNote = note;
								}
	
								checkNoteHit(canHitNote, strumline);
							}
							else
							{
								// you ghost tapped lol
								if(!SaveData.data.get("Ghost Tapping") && startedCountdown)
								{
									var thisChar = strumline.character;
									if(thisChar != null)
									{
										thisChar.miss(i);
									}

									vocals.volume = 0;
	
									var note = new Note();
									note.reloadNote(0, i, "none", assetModifier);
									onNoteMiss(note, strumline);
								}
							}
						}
					}
				}
			}
			
			if(SONG.song == "exploitation")
			{
				for(note in strumline.allNotes)
				{
					//var noteSine:Float = (Conductor.songPos / 1000);
					//hold.scale.x = 0.7 + Math.sin(noteSine) * 0.8;
					if(!note.gotHeld)
					note.x += Math.sin((Conductor.songPos - note.songTime) / 100) * 80 * (strumline.isPlayer ? 1 : -1);
				}
			}
		}

		for(char in characters)
		{
			if(char.holdTimer != Math.NEGATIVE_INFINITY)
			{
				if(char.holdTimer < char.holdLength)
					char.holdTimer += elapsed;
				else
				{
					if(char.isPlayer && playerSinging)
						continue;

					char.holdTimer = Math.NEGATIVE_INFINITY;
					char.dance();
				}
			}
		}
		
		if(startedCountdown)
		{
			var lastSteps:Int = 0;
			var curSect:SwagSection = null;
			for(section in SONG.notes)
			{
				if(curStep >= lastSteps)
					curSect = section;

				lastSteps += section.lengthInSteps;
			}
			if(curSect != null)
			{
				followCamSection(curSect);
			}
		}
		// stuff
		if(forcedCamPos != null)
			camFollow.setPosition(forcedCamPos.x, forcedCamPos.y);

		if(health <= 0)
		{
			startGameOver();
		}
		
		function lerpCamZoom(daCam:FlxCamera, target:Float = 1.0, speed:Int = 6)
			daCam.zoom = FlxMath.lerp(daCam.zoom, target, elapsed * speed);
			
		lerpCamZoom(camGame, defaultCamZoom + extraCamZoom);
		lerpCamZoom(camVg);
		lerpCamZoom(camHUD);
		lerpCamZoom(camStrum);
		
		health = FlxMath.bound(health, 0, 2); // bounds the health
	}

	var camDisplaceX:Float;
	var camDisplaceY:Float;
	var cameraMoveItensity:Float = 25;
	var zoomInOpp:Bool = false;
	var zoomOppVal:Float = 0.2;
	var bleh:Float = 90;

	public static var beatSpeed:Int = 4;
	public static var beatZoom:Float = 0;
	
	public function followCamSection(sect:SwagSection):Void
	{
		followCamera(dadStrumline.character);
		
		if(sect != null)
		{
			var mustHit:Bool = sect.mustHitSection;
			//if(daSong == 'nefarious' || daSong == 'divergence')
			//	mustHit = !sect.mustHitSection;
			if(mustHit) {
				if(bellasings && daSong == "ripple")
					followCamera(third);
				else
					followCamera(bfStrumline.character);

				extraCamZoom = 0;

				if(third != null && bellasings && daSong != "customer-service") {
					switch (third.animation.curAnim.name)
					{
						case 'singLEFT':
							camDisplaceX = - cameraMoveItensity;
							camDisplaceY = 0;
						case 'singRIGHT':
							camDisplaceX = cameraMoveItensity;
							 camDisplaceY = 0;
						case 'singUP':
							camDisplaceX = 0;
							camDisplaceY = -cameraMoveItensity;
						case 'singDOWN':
							camDisplaceX = 0;
							camDisplaceY = cameraMoveItensity;
						default:
							camDisplaceX = 0;
							camDisplaceY = 0;
					}
				}
				else {
					switch (boyfriend.animation.curAnim.name)
					{
						case 'singLEFT':
							camDisplaceX = - cameraMoveItensity;
							camDisplaceY = 0;
						case 'singRIGHT':
							camDisplaceX = cameraMoveItensity;
							camDisplaceY = 0;
						case 'singUP':
							camDisplaceX = 0;
							camDisplaceY = -cameraMoveItensity;
						case 'singDOWN':
							camDisplaceX = 0;
							camDisplaceY = cameraMoveItensity;
						default:
							camDisplaceX = 0;
							camDisplaceY = 0;
					}
				}
			}
			else {
				if(bellasings && daSong == "ripple")
					followCamera(third);
				else if(daSong == "customer-service" && bellasings)
					followCamera(third);
				else
					followCamera(dadStrumline.character);

				if(zoomInOpp)
					extraCamZoom = zoomOppVal;
				else
					extraCamZoom = 0;

				if(third != null && bellasings && daSong == "customer-service") {
					switch (third.animation.curAnim.name)
					{
						case 'singLEFT':
							camDisplaceX = - cameraMoveItensity;
							camDisplaceY = 0;
						case 'singRIGHT':
							camDisplaceX = cameraMoveItensity;
							 camDisplaceY = 0;
						case 'singUP':
							camDisplaceX = 0;
							camDisplaceY = -cameraMoveItensity;
						case 'singDOWN':
							camDisplaceX = 0;
							camDisplaceY = cameraMoveItensity;
						default:
							camDisplaceX = 0;
							camDisplaceY = 0;
					}
				}
				else {
					switch (dadStrumline.character.animation.curAnim.name)
					{
						case 'singLEFT':
							camDisplaceX = - cameraMoveItensity;
							camDisplaceY = 0;
						case 'singRIGHT':
							camDisplaceX = cameraMoveItensity;
							camDisplaceY = 0;
						case 'singUP':
							camDisplaceX = 0;
							camDisplaceY = -cameraMoveItensity;
						case 'singDOWN':
							camDisplaceX = 0;
							camDisplaceY = cameraMoveItensity;
						default:
							camDisplaceX = 0;
							camDisplaceY = 0;
					}
				}
			}
		}
	}
	var focusMiddle:Bool = false;
	public function followCamera(?char:Character, ?offsetX:Float = 0, ?offsetY:Float = 0)
	{
		camFollow.setPosition(0,0);

		if(focusMiddle) {
			camFollow.setPosition(stageBuild.camMiddle.x, stageBuild.camMiddle.y);
		}
		else {
			if(char != null && (daSong == "irritation" || daSong == "conservation")) {
				camFollow.setPosition(dad.getMidpoint().x, dad.getMidpoint().y + bleh);
			}
			else if(char != null)
			{
				var playerMult:Int = (char.isPlayer ? -1 : 1);
				var which:FlxPoint = (char.isPlayer ? stageBuild.bfCam : stageBuild.dadCam);
	
				if(char == third)
					which = stageBuild.thirdCam;
	
				camFollow.setPosition(char.getMidpoint().x + (200 * playerMult), char.getMidpoint().y - 20);
	
				camFollow.x += char.cameraOffset.x * playerMult;
				camFollow.y += char.cameraOffset.y;
	
				camFollow.x += which.x;
				camFollow.y += which.y;
			}
	
			camFollow.x += offsetX;
			camFollow.y += offsetY;
	
			camFollow.x += camDisplaceX;
			camFollow.y += camDisplaceY;
		}
	}

	var banList:Array<String> = ['snap', 'panic', 'neck'];
	var singList:Array<String> = ['neck'];

	override function beatHit()
	{
		super.beatHit();
		for(change in Conductor.bpmChangeMap)
		{
			if(curStep >= change.stepTime && Conductor.bpm != change.bpm)
				Conductor.setBPM(change.bpm);
		}
		hudBuild.beatHit(curBeat);

		if(curBeat % beatSpeed == 0)
		{
			zoomCamera(0.05, 0.025);
		}
		for(char in characters)
		{
			if(curBeat % 2 == 0 || char.quickDancer)
			{
				var canIdle = (char.holdTimer == Math.NEGATIVE_INFINITY);
				
				if(char.isPlayer && playerSinging)
					canIdle = false;

				if(banList.contains(char.animation.curAnim.name))
					canIdle = false;
				else if(daSong == "customer-service" && (curStep > 607 && curStep < 647))
					canIdle = false;

				if(canIdle)
					char.dance();
			}
		}
	}

	override function stepHit()
	{
		super.stepHit();
		stageBuild.stepHit(curStep);
		syncSong();

		if(!SaveData.data.get("Low Quality")) {
			switch(daSong) {
				case "kaboom":
					switch(curStep) {
						case 1:
							CoolUtil.flash(camStrum, 0.5);
							defaultCamZoom = 0.64;
						case 256:
							CoolUtil.flash(camStrum, 0.5);
							defaultCamZoom = 0.55;
							beatSpeed = 1;
							beatZoom = 0.02;
						case 512:
							CoolUtil.flash(camStrum, 0.5);
							defaultCamZoom = 0.6;
							beatSpeed = 2;
						case 768:
							//CoolUtil.flash(camStrum, 0.5);ill
							defaultCamZoom = 0.65;
							beatSpeed = 1;
						case 1024:
							defaultCamZoom = 0.6;
							beatSpeed = 4;
							FlxG.camera.fade(0xFF000000, 1.5, false);
	
							dadStrumline.doSplash = false;
	
							for (strum in strumlines) {
								strum.updatePls = true;
								FlxTween.tween(strum, {x: strumPos[0]}, 1, {ease: FlxEase.circInOut, onComplete: function(twn:FlxTween)
								{
									strum.updatePls = false;
								}});
							}
	
							for (thing in dadStrumline.strumGroup) {
								FlxTween.tween(thing, {alpha: 0}, 1, {ease: FlxEase.circOut});
							}
	
							for (thing in dadStrumline.allNotes) {
								FlxTween.tween(thing, {alpha: 0.14}, 1, {ease: FlxEase.circOut});
							}
							dadStrumline.noteAlpha = 0.25;
						case 1088:
							FlxG.camera.fade(0xFF000000, 0.01, true);
							CoolUtil.flash(camStrum, 0.5);
							defaultCamZoom = 0.55;
							beatSpeed = 2;
						case 1600:
							CoolUtil.flash(camStrum, 0.5);
							defaultCamZoom = 0.65;
							beatSpeed = 4;
						case 1792:
							CoolUtil.flash(camStrum, 0.5);
							defaultCamZoom = 0.55;
							beatSpeed = 1;
						case 2048:
							CoolUtil.flash(camStrum, 0.5);
							defaultCamZoom = 0.6;
						case 2304:
							CoolUtil.flash(camStrum, 0.5);
							beatSpeed = 4;
							defaultCamZoom = 0.55;
						case 2336:
							FlxG.camera.fade(0xFF000000, 3, false);
							FlxTween.tween(camHUD, {alpha: 0}, 3, {ease: FlxEase.expoOut});
							FlxTween.tween(camStrum, {alpha: 0}, 3, {ease: FlxEase.expoOut});
	
					}	
				case "divergence-vip":
					switch(curStep) {
						case 64:
							FlxG.camera.fade(0xFF000000, 1.5, true);
						case 320:
							CoolUtil.flash(camStrum, 0.5);
							defaultCamZoom = 0.64;
							for (strum in strumlines)
								FlxTween.tween(strum, {scrollSpeed: 3.1}, 0.4, {ease: FlxEase.linear});
						case 424:
							FlxG.camera.fade(0xFFFFFFFF, 1, false);
						case 432:
							dadStrumline.doSplash = false;
	
							for (strum in strumlines) {
								strum.updatePls = true;
								FlxTween.tween(strum, {x: strumPos[0]}, 1, {ease: FlxEase.circInOut, onComplete: function(twn:FlxTween)
								{
									strum.updatePls = false;
								}});
							}
	
							for (thing in dadStrumline.strumGroup) {
								FlxTween.tween(thing, {alpha: 0}, 1, {ease: FlxEase.circOut});
							}
	
							for (thing in dadStrumline.allNotes) {
								FlxTween.tween(thing, {alpha: 0.14}, 1, {ease: FlxEase.circOut});
							}
							dadStrumline.noteAlpha = 0.25;
						case 448:
							FlxG.camera.fade(0xFFFFFFFF, 0.01, true);
							CoolUtil.flash(camStrum, 0.5);
							defaultCamZoom = 0.55;
							beatSpeed = 1;
							beatZoom = 0.08;
	
							for (strum in strumlines)
								FlxTween.tween(strum, {scrollSpeed: 3.3}, 0.4, {ease: FlxEase.linear});
						case 576:
							defaultCamZoom = 0.6;
							beatSpeed = 2;
						case 640:
							beatSpeed = 2;
							defaultCamZoom = 0.55;
						case 704:
							CoolUtil.flash(camStrum, 0.5);
							defaultCamZoom = 0.55;
						case 816:
							beatSpeed = 4;
						case 832:
							CoolUtil.flash(camStrum, 0.5);
							defaultCamZoom = 0.64;
							beatSpeed = 2;
							for (strum in strumlines)
								FlxTween.tween(strum, {scrollSpeed: 3}, 0.4, {ease: FlxEase.linear});
						case 960:
							CoolUtil.flash(camStrum, 0.5);
							defaultCamZoom = 0.55;
							for (strum in strumlines)
								FlxTween.tween(strum, {scrollSpeed: 3.3}, 0.4, {ease: FlxEase.linear});
						case 1280:
							CoolUtil.flash(camStrum, 0.5);
							defaultCamZoom = 0.65;
							beatSpeed = 1;
							for (strum in strumlines)
								FlxTween.tween(strum, {scrollSpeed: 3.6}, 0.4, {ease: FlxEase.linear});
						case 1408:
							defaultCamZoom = 0.55;
							beatSpeed = 2;
							for (strum in strumlines)
								FlxTween.tween(strum, {scrollSpeed: 3.1}, 0.4, {ease: FlxEase.linear});
						case 1472: 
							CoolUtil.flash(camStrum, 0.5);
							defaultCamZoom = 0.65;
							beatSpeed = 1;
							for (strum in strumlines)
								FlxTween.tween(strum, {scrollSpeed: 3.6}, 0.4, {ease: FlxEase.linear});
						case 1608:
							defaultCamZoom = 0.55;
							beatSpeed = 2;
							for (strum in strumlines)
								FlxTween.tween(strum, {scrollSpeed: 3.1}, 0.4, {ease: FlxEase.linear});
						case 1728:
							CoolUtil.flash(camStrum, 0.5);
							defaultCamZoom = 0.6;
							beatSpeed = 4;
							for (strum in strumlines)
								FlxTween.tween(strum, {scrollSpeed: 2.7}, 0.4, {ease: FlxEase.linear});
						case 1983:
							CoolUtil.flash(camStrum, 0.5);
							defaultCamZoom = 0.55;
							beatSpeed = 2;
							for (strum in strumlines)
								FlxTween.tween(strum, {scrollSpeed: 3.3}, 0.4, {ease: FlxEase.linear});
						case 2272:
							CoolUtil.flash(camStrum, 0.5);
							defaultCamZoom = 0.62;
							conTxt.alpha = 1;
						case 2560:
							CoolUtil.flash(camStrum, 0.5);
							defaultCamZoom = 0.55;
							conTxt.alpha = 0;
							beatSpeed = 4;
							for (strum in strumlines)
								FlxTween.tween(strum, {scrollSpeed: 3.5}, 0.4, {ease: FlxEase.linear});
						case 2944:
							CoolUtil.flash(camStrum, 0.5);
							defaultCamZoom = 0.65;
							beatSpeed = 1;
							for (strum in strumlines)
								FlxTween.tween(strum, {scrollSpeed: 3.7}, 0.4, {ease: FlxEase.linear});
							if(SaveData.data.get("Shaders"))FlxG.camera.setFilters([echo]);
						case 3488:
							CoolUtil.flash(camStrum, 0.5);
							defaultCamZoom = 0.69;
							for (strum in strumlines)
								FlxTween.tween(strum, {scrollSpeed: 3.9}, 0.4, {ease: FlxEase.linear});
						case 3584:
							CoolUtil.flash(camStrum, 0.5);
							beatSpeed = 4;
							defaultCamZoom = 0.6;
							FlxG.camera.fade(0xFF000000, 0.1, false);
							for (strum in strumlines)
								FlxTween.tween(strum, {scrollSpeed: 3.1}, 0.4, {ease: FlxEase.linear});
							if(SaveData.data.get("Shaders"))FlxG.camera.setFilters([]);
						case 3648:
							FlxG.camera.fade(0xFF000000, 1.5, true);
						case 3904:
							CoolUtil.flash(camStrum, 0.5);
							defaultCamZoom = 0.55;
							FlxG.camera.fade(0xFF000000, 3, false);
					}
				case "nefarious-vip":
					switch(curStep) {
						case 1:
							CoolUtil.flash(camStrum, 0.5);
							defaultCamZoom = 0.64;
						case 128:
							CoolUtil.flash(camStrum, 0.5);
							defaultCamZoom = 0.55;
							beatSpeed = 1;
						case 256:
							CoolUtil.flash(camStrum, 0.5);
							defaultCamZoom = 0.62;
						case 376:
							FlxG.camera.fade(0xFFFFFFFF, 1, false);
						case 384:
							beatSpeed = 4;
						case 420:
							FlxG.camera.fade(0xFFFFFFFF, 0.01, true);
							CoolUtil.flash(camStrum, 0.5);
							defaultCamZoom = 0.55;
							beatSpeed = 1;
							beatZoom = 0.02;
						case 548:
							CoolUtil.flash(camStrum, 0.5);
						case 676:
							CoolUtil.flash(camStrum, 0.5);
							defaultCamZoom = 0.62;
						case 932:
							CoolUtil.flash(camStrum, 0.5); // nef event
							beatSpeed = 4;
							conTxt.alpha = 1;
						case 1176:
							FlxG.camera.fade(0xFFFFFFFF, 1, false);
						case 1200:
							conTxt.alpha = 0;
						case 1220:
							FlxG.camera.fade(0xFFFFFFFF, 0.01, true);
							CoolUtil.flash(camStrum, 0.5);
							defaultCamZoom = 0.55;
							beatSpeed = 1;
							beatZoom = 0.02;
						case 1472:
							CoolUtil.flash(camStrum, 0.5);
						case 1600:
							CoolUtil.flash(camStrum, 0.5);
							beatSpeed = 4;
							FlxTween.tween(camHUD, {alpha: 0}, 0.8, {ease: FlxEase.expoOut});
							FlxTween.tween(camStrum, {alpha: 0}, 0.8, {ease: FlxEase.expoOut});
							
					}
				case "heartpounder":
					switch(curStep) {
						case 128:
							CoolUtil.flash(camStrum, 0.5); 
							defaultCamZoom = 0.64;
							beatSpeed = 1;
						case 512:
							CoolUtil.flash(camStrum, 0.5);
							defaultCamZoom = 0.72;
							beatSpeed = 2;
						case 768:
							CoolUtil.flash(camStrum, 0.5); 
							defaultCamZoom = 0.64;
							beatSpeed = 1;
						case 912:
							defaultCamZoom = 0.75;
							beatSpeed = 4;
						case 928:
							defaultCamZoom = 0.64;
							beatSpeed = 1;
						case 976:
							defaultCamZoom = 0.75;
							beatSpeed = 2;
						case 988:
							beatSpeed = 1;
							defaultCamZoom = 0.64;
						case 1280:
							CoolUtil.flash(camStrum, 0.5);
							defaultCamZoom = 0.72;
							beatSpeed = 2;
						case 1376:
							beatSpeed = 1;
							defaultCamZoom = 0.75;
						case 1408:
							CoolUtil.flash(camStrum, 0.5); 
							defaultCamZoom = 0.54;
							beatSpeed = 1;
						case 1616:
							beatSpeed = 2;
							defaultCamZoom = 0.64;
						case 1632:
							defaultCamZoom = 0.70;
						case 1648:
							defaultCamZoom = 0.75;
						case 1664:
							CoolUtil.flash(camStrum, 0.5); 
							defaultCamZoom = 0.54;
							beatSpeed = 4;
						case 1792:
							CoolUtil.flash(camStrum, 0.5); 
							defaultCamZoom = 0.64;
					}
				case "customer-service":
					switch(curStep) {
						case 128:
							CoolUtil.flash(camOther, 0.5);
							FlxTween.tween(camHUD, {alpha: 1}, 1.6, {ease: FlxEase.expoOut});
							FlxTween.tween(camStrum, {alpha: 1}, 1.6, {ease: FlxEase.expoOut});
						case 608:
							dad.playAnim("ring");
						case 648:
							FlxTween.tween(third, {alpha: 1}, Conductor.crochet / 1000, {
								ease: FlxEase.cubeOut
							});
							bellasings = true;
						case 656:
							CoolUtil.flash(camOther, 0.5);
							hudBuild.changeIcon(0, "duo2");
						case 912:
							CoolUtil.flash(camOther, 0.5);
						case 1296:
							FlxTween.tween(camHUD, {alpha: 0}, 3.5, {ease: FlxEase.expoOut});
							FlxTween.tween(camStrum, {alpha: 0}, 3.5, {ease: FlxEase.expoOut});
					}
				case 'ripple':
					switch(curStep) {
						case 128:
							CoolUtil.flash(camOther, 0.5);
							camHUD.alpha = 1;
							defaultCamZoom = 0.7;
							zoomOppVal = -0.1;
						case 436:
							dad.miss(2);
							boyfriend.miss(3);
						case 448:
							bellasings = false;
						case 512:
							defaultCamZoom = 0.8;
						case 528:
							defaultCamZoom = 0.7;
						case 560:
							defaultCamZoom = 0.9;
						case 576:
							defaultCamZoom = 0.8;
						case 592:
							defaultCamZoom = 0.7;
						case 624:
							defaultCamZoom = 0.9;
						case 640:
							defaultCamZoom = 0.7;
						case 648:
							defaultCamZoom = 0.8;
						case 656:
							CoolUtil.flash(camOther, 0.5);
							defaultCamZoom = 0.7;
						case 788:
							defaultCamZoom = 0.9;
						case 800:
							defaultCamZoom = 0.7;
						case 916:
							CoolUtil.flash(camOther, 0.5);
							defaultCamZoom = 0.9;
							if(SaveData.data.get("Shaders"))FlxG.camera.setFilters([echo]);
						case 1172:
							CoolUtil.flash(camOther, 0.5);
							defaultCamZoom = 0.8;
							if(SaveData.data.get("Shaders"))FlxG.camera.setFilters([]);
						case 1300:
							CoolUtil.flash(camOther, 0.5);
							defaultCamZoom = 0.7;
							beatSpeed = 1;
							beatZoom = 0.01;
						case 1556:
							CoolUtil.flash(camOther, 0.5);
							defaultCamZoom = 0.9;
							beatSpeed = 4;
							beatZoom = 0;
						case 1620:
							CoolUtil.flash(camOther, 0.5);
							defaultCamZoom = 0.8;
						case 1752:
							CoolUtil.flash(camOther, 0.5);
							camHUD.alpha = 0;
							camStrum.alpha = 0;
					}
				case 'sin':
					switch(curStep) {
						case 64:
							FlxG.camera.fade(0x00000000, 1.6, true);
						case 192:
							CoolUtil.flash(camOther, 0.5);
							vgblack.alpha = 0;
							camHUD.alpha = 1;
							defaultCamZoom = 0.4;
							dad.alpha = 1;
							stageBuild.tweenStage(1, 0.001);
							beatZoom = 0.01;
						case 320:
							defaultCamZoom = 0.5;
						case 352:
							CoolUtil.flash(camOther, 0.5);
							defaultCamZoom = 0.6;
							beatSpeed = 1;
						case 704:
							defaultCamZoom = 0.7;
							beatSpeed = 4;
						case 736:
							CoolUtil.flash(camOther, 0.5);
							defaultCamZoom = 0.5;
							beatSpeed = 1;
						case 992:
							defaultCamZoom = 0.6;
							beatSpeed = 2;
						case 1056:
							CoolUtil.flash(camOther, 0.5);
							defaultCamZoom = 0.5;
							beatSpeed = 1;
						case 1312: //1312
							//EYES
							CoolUtil.flash(camOther, 0.5);
							FlxG.camera.fade(0x00000000, 0.01, false);
							beatSpeed = 4;
							conTxt.alpha = 1;
							camStrum.alpha = 0;
						case 1328: //1328
							//OPEN
							conTxt.alpha = 0;
							divTxt.alpha = 1;
							divTxt.animation.play("idle");
							camTaiko.alpha = 1;
							changeStage("sin2");
							for(strum in taikoStrumline.strumGroup) {
								FlxTween.tween(strum, {y: strum.initialPos.y}, Conductor.crochet / 1000, {
									ease: FlxEase.cubeOut
								});
							}
						case 1344: //1344
							//taiko start
							CoolUtil.flash(camOther, 0.5);
							FlxG.camera.fade(0x00000000, 0.01, true);
							beatSpeed = 1;
							divTxt.alpha = 0;
	
						case 1856:
							beatSpeed = 4;
							CoolUtil.flash(camOther, 0.5);
							changeStage("sin");
							camTaiko.alpha = 0;
							camStrum.alpha = 1;
							defaultCamZoom = 0.4;
						case 1888: 
							CoolUtil.flash(camOther, 0.5);
							beatSpeed = 1;
							defaultCamZoom = 0.4;
						case 1892: //1892
							//fall - lich
							FlxTween.tween(stageBuild.objectMap.get("city"), {y: stageBuild.objectMap.get("city").y + 2000}, 3, {
								ease: FlxEase.cubeInOut,
								startDelay: 0
							});
	
							FlxTween.tween(stageBuild.objectMap.get("island"), {y: stageBuild.objectMap.get("island").y + 2000}, 2.7, {
								ease: FlxEase.cubeInOut,
								startDelay: 0.3
							});
	
							FlxTween.tween(stageBuild.objectMap.get("island-2"), {y: stageBuild.objectMap.get("island-2").y + 2000}, 2.6, {
								ease: FlxEase.cubeInOut,
								startDelay: 0.5
							});
	
						case 2144:
							defaultCamZoom = 0.6;
						case 2400: 
							CoolUtil.flash(camOther, 0.5);
							defaultCamZoom = 0.5;
							beatSpeed = 4;
						case 2528:
							FlxG.camera.fade(0x00000000, 1, false);
							defaultCamZoom = 0.5;
	
					}
				case 'intimidate':
					switch(curStep) {
						case 1:
							FlxG.camera.fade(0x00000000, 1.6, true);
						case 16:
							defaultCamZoom = 0.67;
						case 272:
							defaultCamZoom = 0.72;
							CoolUtil.flash(camOther, 0.5);
						case 446:
							defaultCamZoom = 0.8;
						case 464:
							defaultCamZoom = 0.72;
							CoolUtil.flash(camOther, 0.5);
						case 656: //656
							defaultCamZoom = 0.6;
							CoolUtil.flash(camOther, 0.5);
							beatSpeed = 1;
							if(SaveData.data.get("Shaders"))
								FlxG.camera.setFilters([echo]);
						case 912:
							CoolUtil.flash(camOther, 0.5);
							defaultCamZoom = 0.7;
							beatSpeed = 4;
							if(SaveData.data.get("Shaders"))
								FlxG.camera.setFilters([]);
						case 928:
							defaultCamZoom = 0.8;
						case 944:
							defaultCamZoom = 0.72;
							CoolUtil.flash(camOther, 0.5);
						case 1200:
							FlxG.camera.fade(0x00000000, 1.6, false);
						case 1264: // 1264
							CoolUtil.flash(camOther, 0.5);
							FlxG.camera.fade(0x00000000, 0.01, true);
							changeChar(boyfriend, "bex-1e");
							dad.alpha = 1;
							changeStage("divergence-e");
							cameraSpeed = 500;
							beatSpeed = 2;
							vhs.alpha = 0.5;
							vgblack.alpha = 0.4;
						case 1265:
							cameraSpeed = 1;
						case 1392: //1392
							CoolUtil.flash(camOther, 0.5);
							changeChar(boyfriend, "bex-2e");
							changeChar(dad, "bree-2e");
							changeStage("panic-attack-e");
							cameraSpeed = 500;
							beatSpeed = 1;
						case 1393:
							cameraSpeed = 1;
						case 1648:
							beatSpeed = 2;
							defaultCamZoom = 0.8;
						case 1680: //1680
							CoolUtil.flash(camOther, 0.5);
							changeChar(boyfriend, "bex-e");
							beatSpeed = 4;
							dad.alpha = 0;
							vhs.alpha = 0;
							boyfriend.alpha = 0;
							changeStage("wake");
							stageBuild.objectMap.get("bex").animation.play("wake");
							//end
						case 1704:
							FlxTween.tween(camHUD, {alpha: 1}, 1.6, {ease: FlxEase.expoOut});
							FlxTween.tween(camStrum, {alpha: 1}, 1.6, {ease: FlxEase.expoOut});
							FlxG.camera.fade(0x00000000, 1.6, false);
					}
				case 'conservation':
					switch(curStep) {
						case 128:
							FlxTween.tween(camHUD, {alpha: 1}, 6, {ease: FlxEase.expoOut});
							FlxTween.tween(camStrum, {alpha: 1}, 6, {ease: FlxEase.expoOut});
							defaultCamZoom = 0.63;
						case 384:
							defaultCamZoom = 0.7;
						case 416:
							beatSpeed = 1;
						case 512:
							defaultCamZoom = 0.63;
							beatSpeed = 2;
						case 640:
							beatSpeed = 1;
						case 768:
							beatSpeed = 2;
						case 800:
							beatSpeed = 1;
						case 1024:
							beatSpeed = 4;
						case 1040:
							FlxTween.tween(camHUD, {alpha: 0}, 3, {ease: FlxEase.expoOut});
							FlxTween.tween(camStrum, {alpha: 0}, 3, {ease: FlxEase.expoOut});
					}
				case 'irritation':
					switch(curStep) {
						case 1:
							CoolUtil.flash(camGame, 0.5);
							defaultCamZoom = 0.7;
							FlxTween.tween(camHUD, {alpha: 1}, 3, {ease: FlxEase.expoOut});
							FlxTween.tween(camStrum, {alpha: 1}, 3, {ease: FlxEase.expoOut});
						case 128:
							beatSpeed = 1;
						case 256:
							CoolUtil.flash(camOther, 0.5);
							bleh = 80;
							defaultCamZoom = 0.65;
						case 512:
							CoolUtil.flash(camOther, 0.5);
							bleh = 60;
							defaultCamZoom = 0.75;
						case 640:
							bleh = 50;
							defaultCamZoom = 0.8;
						case 768:
							CoolUtil.flash(camOther, 0.5);
							beatSpeed = 2;
							bleh = 80;
							defaultCamZoom = 0.65;
						case 896:
							CoolUtil.flash(camOther, 0.5);
							bleh = 60;
							defaultCamZoom = 0.75;
							beatSpeed = 1;
						case 1024:
							CoolUtil.flash(camOther, 0.5);
							defaultCamZoom = 0.65;
							bleh = 80;
						case 1152:
							CoolUtil.flash(camOther, 0.5);
							beatSpeed = 2;
							defaultCamZoom = 0.6;
							bleh = 90;
						case 1184:
							CoolUtil.flash(camOther, 0.5);
							defaultCamZoom = 0.8;
							bleh = 50;
						case 1312:
							CoolUtil.flash(camOther, 0.5);
							defaultCamZoom = 0.85;
							bleh = 40;
						case 1440:
							CoolUtil.flash(camOther, 0.5);
							defaultCamZoom = 0.75;
							bleh = 60;
						case 1568:
							defaultCamZoom = 0.7;
						case 1696:
							CoolUtil.flash(camOther, 0.5);
							defaultCamZoom = 0.6;
							bleh = 90;
							FlxTween.tween(camHUD, {alpha: 0}, 3, {ease: FlxEase.expoOut});
							FlxTween.tween(camStrum, {alpha: 0}, 3, {ease: FlxEase.expoOut});
					}
				case 'divergence':
					switch(curStep) {
						case 1:
							CoolUtil.flash(camTaiko, 20);
							camHUD.alpha = 1;
							camStrum.alpha = 1;
						//case 8:
						//	noteSwap(true);
						case 256:
							CoolUtil.flash(camOther);
							defaultCamZoom = 0.7;
						case 384:
							beatSpeed = 1;
							beatZoom = 0.01;
							defaultCamZoom = 0.76;
						case 512:
							beatSpeed = 2;
							defaultCamZoom = 0.66;
						case 608:
							beatSpeed = 1;
							defaultCamZoom = 0.7;
						case 640:
							FlxG.camera.fade(0x00000000, 0.17, false);
						case 644:
							FlxTween.tween(divTxt, {alpha: 1}, 0.3, {ease: FlxEase.expoOut});
						case 656:
							FlxG.camera.fade(0x00000000, 0.05, true);
							divTxt.alpha = 0;
							CoolUtil.flash(camOther, 1);
							defaultCamZoom = 0.76;
							beatZoom = 0.02;
						case 912:
							defaultCamZoom = 0.63;
							beatSpeed = 4;
						case 928: 
							beatSpeed = 1;
							defaultCamZoom = 0.76;
						case 1184:
							FlxG.camera.fade(0x00000000, 0.33, false);
							beatSpeed = 4;
						case 1312:
							FlxG.camera.fade(0x00000000, 1.3, true);
						case 1440:
							dadStrumline.doSplash = false;
	
							for (strum in strumlines) {
								strum.updatePls = true;
								FlxTween.tween(strum, {x: strumPos[0]}, 1, {ease: FlxEase.circInOut, onComplete: function(twn:FlxTween)
								{
									strum.updatePls = false;
								}});
							}
	
							for (thing in dadStrumline.strumGroup) {
								FlxTween.tween(thing, {alpha: 0}, 1, {ease: FlxEase.circOut});
							}
	
							for (thing in dadStrumline.allNotes) {
								FlxTween.tween(thing, {alpha: 0.14}, 1, {ease: FlxEase.circOut});
							}
							dadStrumline.noteAlpha = 0.25;
							FlxG.camera.fade(0x00000000, 0.17, false);
							//glitch
						case 1472:
							FlxG.camera.fade(0x00000000, 0.001, true);
							CoolUtil.flash(camOther, 1);
							if(SaveData.data.get("Shaders"))FlxG.camera.setFilters([echo]);
							changeChar(dad, "bella-1alt");
							beatSpeed = 2;
						case 1600:
							CoolUtil.flash(camOther, 1);
							defaultCamZoom = 0.63;
							beatSpeed = 1;
						case 1712:
							beatSpeed = 4;
							defaultCamZoom = 0.8;
						case 1728:
							defaultCamZoom = 0.7;
							beatSpeed = 1;
							if(SaveData.data.get("Shaders"))FlxG.camera.setFilters([]);
							CoolUtil.flash(camOther, 1);
						case 2240:
							defaultCamZoom = 0.6;
							beatSpeed = 4;
							beatZoom = 0;
							focusMiddle = true;
						case 2635:
							FlxG.camera.fade(0x00000000, 0.33, false);
					}
				case 'nefarious':
					switch(curStep) {
						case 64:
							defaultCamZoom = 0.65;
						case 128:
							beatSpeed = 2;
							beatZoom = 0.01;
						case 256:
							CoolUtil.flash(camOther);
							defaultCamZoom = 0.7;
							beatSpeed = 1;
						case 496:
							defaultCamZoom = 0.8;
							beatSpeed = 4;
						case 512:
							CoolUtil.flash(camOther);
							defaultCamZoom = 0.65;
							beatSpeed = 2;
						case 1024:
							CoolUtil.flash(camOther);
							defaultCamZoom = 0.75;
							beatSpeed = 4;
						case 1152:
							beatSpeed = 2;
						case 1216:
							beatSpeed = 1;
						case 1280:
							beatSpeed = 4;
							defaultCamZoom = 0.8;
						case 1296:
							defaultCamZoom = 0.85;
						case 1312:
							CoolUtil.flash(camOther);
							defaultCamZoom = 0.7;
							beatSpeed = 1;
							changeChar(boyfriend, "bex-1alt");
							for (strum in strumlines)
								FlxTween.tween(strum, {scrollSpeed: 3.3}, 0.4, {ease: FlxEase.linear});
						case 1696:
							CoolUtil.flash(camOther);
							defaultCamZoom = 0.6;
							beatSpeed = 4;
							focusMiddle = true;
					}
				case 'euphoria':
					switch (curStep) {
						case 2:
							defaultCamZoom = 0.65;
						case 128:
							beatSpeed = 1;
						case 224:
							beatSpeed = 4;
							defaultCamZoom = 0.7;
						case 256:
							CoolUtil.flash(camOther);
							defaultCamZoom = 0.6;
							beatSpeed = 1;
							beatZoom = 0.01;
						case 512:
							defaultCamZoom = 0.7;
						case 640:
							defaultCamZoom = 0.76;
							beatSpeed = 4;
						case 656:
							CoolUtil.flash(camOther);
							defaultCamZoom = 0.6;
							beatSpeed = 1;
						case 784:
							defaultCamZoom = 0.65;
						case 912: //fade vignette? -912
							FlxTween.tween(vgblack, {alpha: 0.3}, 0.7, {ease: FlxEase.sineInOut});
							defaultCamZoom = 0.76;
							beatSpeed = 4;
						case 1040:
							beatSpeed = 2;
						case 1168:
							beatSpeed = 4;
							defaultCamZoom = 0.8;
						case 1184:
							defaultCamZoom = 0.85;
						case 1200:
							FlxTween.tween(vgblack, {alpha: 0}, 0.7, {ease: FlxEase.sineInOut});
							CoolUtil.flash(camOther);
							defaultCamZoom = 0.6;
							beatSpeed = 1;
						case 1456:
							defaultCamZoom = 0.67;
						case 1464:
							defaultCamZoom = 0.73;
						case 1472:
							CoolUtil.flash(camOther);
							defaultCamZoom = 0.6;
							beatSpeed = 4;
							focusMiddle = true;
	
					}
				case 'desertion':
					switch(curStep) {
						case 1:
							camVg.fade(0x00000000, 1, true);
							
						case 16:
							CoolUtil.flash(camOther);
						case 144:
							defaultCamZoom = 0.65;
						case 176:
							defaultCamZoom = 0.7;
						case 208:
							defaultCamZoom = 0.75;
						case 240:
							defaultCamZoom = 0.8;
						case 272:
							defaultCamZoom = 0.6;
							camHUD.alpha = 1;
							dad.alpha = 1;
							beatSpeed = 2;
							beatZoom = 0.02;
							CoolUtil.flash(camOther);
							startLogo();
						case 400:
							defaultCamZoom = 0.72;
							beatSpeed = 1;
							CoolUtil.flash(camOther);
						case 576:
							beatSpeed = 4;
							defaultCamZoom = 0.78;
						case 592:
							beatSpeed = 1;
							defaultCamZoom = 0.72;
						case 624:
							beatSpeed = 4;
							defaultCamZoom = 0.78;
						case 656:
							beatSpeed = 2;
							defaultCamZoom = 0.75;
						case 784:
							beatSpeed = 1;
						case 912:
							beatSpeed = 4;
							defaultCamZoom = 0.72;
						case 928:
							beatSpeed = 4;
							defaultCamZoom = 0.63;
							CoolUtil.flash(camOther);
						case 1056:
							beatSpeed = 2;
							defaultCamZoom = 0.69;
							CoolUtil.flash(camOther);
						case 1184:
							beatSpeed = 4;
							defaultCamZoom = 0.60;
						case 1200:
							defaultCamZoom = 0.72;
							beatSpeed = 1;
							CoolUtil.flash(camOther);
						case 1456:
							defaultCamZoom = 0.6;
							beatSpeed = 2;
							CoolUtil.flash(camOther);
						case 1648:
							beatSpeed = 1;
						case 1712: //1712
							FlxTween.tween(camHUD, {alpha: 0}, 0.7, {ease: FlxEase.sineInOut});
							FlxTween.tween(camStrum, {alpha: 0}, 0.7, {ease: FlxEase.sineInOut});
							beatSpeed = 4;
							powerUp(true);
						case 1740:
							bfStrumline.updatePls = true;
							FlxTween.tween(bfStrumline, {x: strumPos[0]}, 0.01, {ease: FlxEase.circInOut, onComplete: function(twn:FlxTween)
							{
								bfStrumline.updatePls = false;
							}});
						case 1744: //1744
							powerUp(false);
							beatSpeed = 1;
							FlxTween.tween(camHUD, {alpha: 1}, 0.7, {ease: FlxEase.sineInOut});
							FlxTween.tween(camStrum, {alpha: 1}, 0.7, {ease: FlxEase.sineInOut});
							CoolUtil.flash(camVg);
							zoomInOpp = false;
							if(SaveData.data.get("Shaders"))FlxG.camera.setFilters([chrom]);
							changeChar(boyfriend, "bex-2dp");
							changeChar(dad, "bree-2dp");
							changeChar(third, "bella-2dp");
							changeStage("desertion2");
						case 2000:
							CoolUtil.flash(camOther);
							defaultCamZoom = 0.6;
						case 2256:
							beatSpeed = 2;
							CoolUtil.flash(camOther);
							defaultCamZoom = 0.69;
						case 2512:
							beatSpeed = 4;
							defaultCamZoom = 0.75;
						case 2528:
							defaultCamZoom = 0.83;
						case 2544:
							CoolUtil.flash(camOther);
							defaultCamZoom = 0.5;
						case 2568:
							camVg.fade(0x00000000, 0.6, false);
							FlxTween.tween(camHUD, {alpha: 0}, 0.6, {ease: FlxEase.sineInOut});
					}
				case 'convergence':
					switch(curStep) {
						case 1:
							camVg.fade(0x00000000, 13, true);
						case 224:
							FlxTween.tween(camHUD, {alpha: 1}, 4, {ease: FlxEase.sineInOut});
							FlxTween.tween(camStrum, {alpha: 1}, 4, {ease: FlxEase.sineInOut});
						case 256:
							CoolUtil.flash(camOther);
							conTxt.alpha = 1;
							camVg.fade(0x00000000, 0.01, false);
						case 288:
							conTxt.alpha = 0;
							camVg.fade(0x00000000, 0.01, true);
							CoolUtil.flash(camOther);
							defaultCamZoom = 0.72;
							beatSpeed = 1;
						case 544:
							CoolUtil.flash(camOther);
							defaultCamZoom = 0.8;
							beatSpeed = 4;
						case 864:
							camVg.fade(0x00000000, 0.4, false);
						case 880:
							bfStrumline.updatePls = true;
							FlxTween.tween(bfStrumline, {x: strumPos[0]}, 1, {ease: FlxEase.circInOut, onComplete: function(twn:FlxTween)
							{
								bfStrumline.updatePls = false;
							}});
	
							/*
							for (strum in strumlines) {
								strum.updatePls = true;
								FlxTween.tween(strum, {x: strumPos[0]}, 1, {ease: FlxEase.circInOut, onComplete: function(twn:FlxTween)
								{
									strum.updatePls = false;
								}});
							}
	
							for (thing in dadStrumline.strumGroup) {
								FlxTween.tween(thing, {alpha: 0}, 1, {ease: FlxEase.circOut});
							}
	
							for (thing in dadStrumline.allNotes) {
								FlxTween.tween(thing, {alpha: 0.14}, 1, {ease: FlxEase.circOut});
							}
							dadStrumline.noteAlpha = 0.25;
							*/
						case 884:
							FlxTween.tween(divTxt, {alpha: 1}, 0.3, {ease: FlxEase.expoOut});
						case 896:
							camVg.fade(0x00000000, 0.01, true);
							CoolUtil.flash(camOther);
							divTxt.alpha = 0;
							beatSpeed = 1;
							defaultCamZoom = 0.72;
							beatZoom = 0.02;
						case 1152:
							CoolUtil.flash(camOther);
							defaultCamZoom = 0.8;
							beatSpeed = 2;
							bar(true, 0.3);
						case 1392:
							defaultCamZoom = 0.9;
						case 1408:
							defaultCamZoom = 0.72;
							beatSpeed = 1;
							CoolUtil.flash(camOther);
							beatZoom = 0.03;
							for (strum in strumlines) {
								FlxTween.tween(strum, {scrollSpeed: 3}, 0.4, {ease: FlxEase.linear});
							}
							bar(false, 0.3);
						case 1984:
							for (strum in strumlines) {
								FlxTween.tween(strum, {scrollSpeed: 3.2}, 0.4, {ease: FlxEase.linear});
							}
						case 1920:
							CoolUtil.flash(camOther);
							beatSpeed = 4;
							beatZoom = 0;
						case 2080:
							CoolUtil.flash(camOther);
							beatSpeed = 1;
							beatZoom = 0.03;
							defaultCamZoom = 0.8;
						case 2592:
							CoolUtil.flash(camOther);
							beatSpeed = 4;
							beatZoom = 0;
							defaultCamZoom = 0.72;
						case 2608:
							camVg.fade(0x00000000, 0.6, false);
							FlxTween.tween(camHUD, {alpha: 0}, 0.6, {ease: FlxEase.sineInOut});
					}
				case 'panic-attack':
					switch(curStep) {
						case 1:
							FlxG.camera.fade(0x00000000, 1.6, true);
						case 120:
							defaultCamZoom = 0.72;
							FlxTween.tween(camHUD, {alpha: 1}, 1.5, {ease: FlxEase.expoOut});
							FlxTween.tween(camStrum, {alpha: 1}, 1.5, {ease: FlxEase.expoOut});
						case 128:
							defaultCamZoom = 0.76;
						case 256:
							defaultCamZoom = 0.69;
						case 272:
							defaultCamZoom = 0.79;
						case 336:
							defaultCamZoom = 0.73;
							CoolUtil.flash(camOther);
							beatSpeed = 2;
						case 496:
							defaultCamZoom = 0.79;
						case 502:
							defaultCamZoom = 0.84;
						case 508:
							defaultCamZoom = 0.73;
						case 560:
							defaultCamZoom = 0.79;
						case 566:
							defaultCamZoom = 0.84;
						case 572:
							defaultCamZoom = 0.73;
						case 592:
							defaultCamZoom = 0.78;
						case 848:
							defaultCamZoom = 0.83;
						case 880:
							defaultCamZoom = 0.7;
							CoolUtil.flash(camOther, 0.2);
							bar(true, 0.3, 14);
							beatSpeed = 1;
						case 1136: //1136
							bar(false, 0.3);
							CoolUtil.flash(camOther, 0.2);
							defaultCamZoom = 0.7;
							beatSpeed = 4;
							stageBuild.objectMap.get("outsidenight").alpha = 1;
							stageBuild.objectMap.get("rain").alpha = 0.16;
							stageBuild.objectMap.get("outsidenight").animation.play("thunder");
							vgblack.alpha = 0.5;
						case 1137:
							dad.playAnim("snap", true);
						case 1168:
							defaultCamZoom = 0.78;
						case 1424: // 1424
							CoolUtil.flash(camOther, 0.5);
							camVg.fade(0x00000000, 0.01, false);
							//defaultCamZoom = 0.6;
							changeChar(boyfriend, "bex-2bf");
							changeChar(dad, "bree-2bf");
							changeStage("nan");
						case 1440: // 1440
							CoolUtil.flash(camOther, 0.5);
							camVg.fade(0x00ffffff, 0.01, true);
						case 1664:
							FlxTween.tween(dad, {alpha: 0}, 0.6, {ease: FlxEase.sineInOut});
						case 1685: //1680
							defaultCamZoom = 0.72;
							boyfriend.playAnim("neck", true);
							focusMiddle = true;
						case 1696: //1696
							dad.alpha = 1;
							CoolUtil.flash(camOther, 0.5);
							changeChar(dad, "bree-2b");
							changeStage("panic-attack");
							changeChar(boyfriend, "bex-2balt");
							stageBuild.objectMap.get("outsidenight").alpha = 1;
							stageBuild.objectMap.get("rain").alpha = 0.16;
							stageBuild.objectMap.get("outsidenight").animation.play("thunder");
							boyfriend.playAnim("panic", true);
							focusMiddle = false;
							cameraSpeed = 500;
						case 1697: 
							cameraSpeed = 1;
						case 2000:
							defaultCamZoom = 0.72;
						case 2016:
							defaultCamZoom = 0.76;
							stageBuild.objectMap.get("outsidenight").animation.play("thunder");
					}
				case 'allegro':
					switch(curStep) {
						case 1:
							defaultCamZoom = 0.6;
						case 128:
							defaultCamZoom = 0.7;
							CoolUtil.flash(camOther);
						case 384:
							defaultCamZoom = 0.76;
						case 672:
							defaultCamZoom = 0.64;
							CoolUtil.flash(camOther);
						case 896:
							defaultCamZoom = 0.6;
							CoolUtil.flash(camOther);
						case 1296:
							focusMiddle = true;
							defaultCamZoom = 0.7;
						case 1302:
							defaultCamZoom = 0.6;
						case 1308:
							defaultCamZoom = 0.8;
					}
			}
		}
		else {
			switch(daSong) {
				case "sin":
					switch(curStep) {
						case 1312: //1312
							//EYES
							CoolUtil.flash(camOther, 0.5);
							camStrum.alpha = 0;
						case 1328: //1328
							camTaiko.alpha = 1;
							changeStage("sin2");
							for(strum in taikoStrumline.strumGroup) {
								FlxTween.tween(strum, {y: strum.initialPos.y}, Conductor.crochet / 1000, {
									ease: FlxEase.cubeOut
								});
							}
		
						case 1856:
							CoolUtil.flash(camOther, 0.5);
							changeStage("sin");
							camTaiko.alpha = 0;
							camStrum.alpha = 1;
				}
			}
		}
	}

	public function syncSong():Void
	{
		if(!startedSong) return;

		if(!inst.playing && Conductor.songPos > 0 && !paused)
			endSong();
		
		if(inst.playing)
		{
			// syncs the conductor
			if(Math.abs(Conductor.songPos - inst.time) >= 40 && Conductor.songPos - inst.time <= 5000)
			{
				//trace('synced song ${Conductor.songPos} to ${inst.time}');
				Conductor.songPos = inst.time;
			}
			
			// syncs the other music to the inst
			for(music in musicList)
			{
				if(music == inst) return;
				
				if(music.playing)
				{
					if(Math.abs(music.time - inst.time) >= 40)
					{
						music.time = inst.time;
						//music.play();
					}
				}
			}
		}
		
		// checks if the song is allowed to end
		if(Conductor.songPos >= songLength)
			endSong();
	}
	
	// ends it all
	public static var endedSong:Bool = false;
	public function endSong()
	{
		if(endedSong) return;
		
		endedSong = true;
		resetSongStatics();
		FlxTween.tween(moneyCount, {y: 0}, 0.5, {
			ease: FlxEase.cubeInOut,
			onComplete: function(twn:FlxTween)
			{
				if(validScore)
				{
					var oldScore:ScoreData = Highscore.getScore(daSong);
					var givenMoney:Int = 10;
					var timer:Float = 1.4;
					if(Timings.score >= oldScore.score) {
						givenMoney = 25;
						timer = 2;
					}

					SaveData.transaction(givenMoney);
					//moneyCount.realValue += givenMoney;

					Highscore.addScore(SONG.song.toLowerCase() + '-' + songDiff, {
						score: 		Timings.score,
						accuracy: 	Timings.accuracy,
						misses: 	Timings.misses,
					});
					
					weekScore += Timings.score;

					var countTimer = new FlxTimer().start(timer, function(tmr:FlxTimer)
					{
						exit();
					});
				}
				else {
					exit();
				}
			}
		});	
		
	}

	function exit()
	{
		if(playList.length <= 0)
		{
			resetSongStatics();
			if(isStoryMode)
			{
				switch(daSong) {
					case "divergence-vip":
						SaveData.progression.set("vip", true);
						SaveData.save();
						sendToMenu();
					case "euphoria":
						states.cd.Dialog.dialog = "nefarious";
						Main.switchState(new states.cd.Dialog());
					case "nefarious":
						states.cd.Dialog.dialog = "divergence";
						Main.switchState(new states.cd.Dialog());
					case "divergence":
						states.VideoState.name = "divergence";
						Main.switchState(new states.VideoState());
					case "allegro":
						states.VideoState.name = "panic";
						Main.switchState(new states.VideoState());
					case "panic-attack":
						states.cd.Dialog.dialog = "convergence";
						states.cd.Dialog.introCenterAlpha = 0.6;
						Main.switchState(new states.cd.Dialog());
					case "convergence":
						states.cd.Dialog.dialog = "desertion";
						Main.switchState(new states.cd.Dialog());
					case "desertion":
						Main.switchState(new states.cd.Ending());
					case "intimidate":
						if(!SaveData.progression.get("intimidated"))
							states.cd.MainMenu.unlocks.push("Song: Exotic! (FREEPLAY)");
						SaveData.progression.set("intimidated", true);
						SaveData.save();
						Main.switchState(new states.cd.MainMenu());
					case "sin":
						Main.switchState(new states.cd.fault.MainMenu());
					default:
						sendToMenu();
				}
			}
			else
				sendToMenu();
		}
		else {
			SONG = SongData.loadFromJson(playList[0], songDiff);
			playList.remove(playList[0]);
			
			////trace(playList);
			Main.switchState(new LoadSongState());
		}
	}

	override function onFocusLost():Void
	{
		pauseSong();
		super.onFocusLost();
	}

	public function pauseSong()
	{
		if(!startedCountdown || paused || isDead) return;
		
		paused = true;
		activateTimers(false);
		openSubState(new PauseSubState());
	}
	
	public var isDead:Bool = false;
	
	public function startGameOver()
	{
		if(isDead || !startedCountdown) return;
		if(daSong == "heartpounder") return;
		
		isDead = true;
		blueballed++;
		activateTimers(false);
		persistentDraw = false;
		var soundChar:String = bfStrumline.character.curChar;
		if(invertedCharacters)
			soundChar = dadStrumline.character.curChar + "-what";
		switch(daSong) {
			case 'customer-service' | 'ripple':
				soundChar = "drown-what";
			case "exotic":
				soundChar = "bex-what";
		}
		openSubState(new GameOverSubState(soundChar));
	}

	public function zoomCamera(gameZoom:Float = 0, hudZoom:Float = 0)
	{
		camGame.zoom += gameZoom;
		camVg.zoom += hudZoom;
		camHUD.zoom += hudZoom;
		camStrum.zoom += hudZoom;
	}
	
	// funny thingy
	public function changeChar(char:Character, newChar:String = "bf", ?iconToo:Bool = true)
	{
		// gets the original position
		var storedPos = new FlxPoint(
			char.x - char.globalOffset.x,
			char.y + char.height - char.globalOffset.y
		);
		// changes the character
		char.reloadChar(newChar);
		// returns it to the correct position
		char.setPosition(
			storedPos.x + char.globalOffset.x,
			storedPos.y - char.height + char.globalOffset.y
		);

		if(iconToo && char != third)
		{
			// updating icons
			var daID:Int = (char.isPlayer ? 1 : 0);
			hudBuild.changeIcon(daID, char.curChar);
		}
		
		var evilTrail = char._dynamic["evilTrail"];
		if(evilTrail != null)
		{
			remove(evilTrail);
			evilTrail = null;
		}
		switch(newChar)
		{
			case 'spirit':
				evilTrail = new FlxTrail(char, null, 4, 24, 0.3, 0.069);
				add(evilTrail);
		}
	}

	// funny thingy
	public function changeStage(newStage:String = "stage")
	{
		stageBuild.reloadStage(newStage);

		dad.setPosition(stageBuild.dadPos.x, stageBuild.dadPos.y);
		dad.y -= dad.height;

		boyfriend.setPosition(stageBuild.bfPos.x, stageBuild.bfPos.y);
		boyfriend.y -= boyfriend.height;

		var chars:Array<Dynamic> = [dad, boyfriend];
		if(third != null) {
			third.setPosition(stageBuild.thirdPos.x, stageBuild.thirdPos.y);
			third.y -= third.height;
			chars.push(third);
		}

		for(char in [dad, boyfriend])
		{
			char.x += char.globalOffset.x;
			char.y += char.globalOffset.y;
		}
		
		switch(newStage)
		{
			default:
				// add your custom stuff here
		}
	}
	
	//substates also use this
	public static function sendToMenu()
	{
		Main.randomizeTitle();
		CoolUtil.playMusic();
		resetSongStatics();
		if(isStoryMode)
		{
			isStoryMode = false;
			Main.switchState(new states.cd.StoryMode());
		}
		else
		{
			var watts:Array<String> = ["conservation", "irritation"];
			if(watts.contains(daSong) && !SaveData.progression.get("oneofthem")) {
				SaveData.progression.set("oneofthem", true);
				SaveData.save();
				states.cd.MainMenu.unlocks.push("Song: Conservation (FREEPLAY)\nSong: Irritation (FREEPLAY)");
				Main.switchState(new states.cd.MainMenu());
			}
			else
				Main.switchState(new states.cd.Freeplay());
		}
	}

	public function bar(inOrOut:Bool = true, time:Float = 1, ?size:Float = 20)
	{
		if(inOrOut) {
			FlxTween.tween(barUp, {y: 0 - size}, time, {ease: FlxEase.cubeOut});
			FlxTween.tween(barDown, {y: FlxG.height - barDown.height + size}, time, {ease: FlxEase.cubeOut});

			FlxTween.tween(camHUD, {alpha: 0}, 0.3, {ease: FlxEase.sineInOut});

			for(line in strumlines) 
			{
				for(strum in line.strumGroup)
				{
					if(SaveData.data.get("Downscroll"))
						FlxTween.tween(strum, {y: strum.initialPos.y - size - 95}, time, {ease: FlxEase.cubeOut});
					else
						FlxTween.tween(strum, {y: strum.initialPos.y + size + 95}, time, {ease: FlxEase.cubeOut});
				}
			}

		}
		else {
			FlxTween.tween(barUp, {y: 0 - barUp.height + 25}, time, {ease: FlxEase.cubeOut});
			FlxTween.tween(barDown, {y: FlxG.height -25}, time, {ease: FlxEase.cubeOut});
			
			FlxTween.tween(camHUD, {alpha: 1}, 0.3, {ease: FlxEase.sineInOut});

			for(line in strumlines) 
			{
				for(strum in line.strumGroup)
				{
					FlxTween.tween(strum, {y: strum.initialPos.y}, time, {ease: FlxEase.cubeOut});
				}
			}
		}
	}

	function powerUp(isBegin:Bool)
	{
		if(daSong != 'desertion' && startedSong) return;

		if(isBegin) {
			FlxTween.tween(bellaPop, {x: FlxG.width - bellaPop.width}, 0.7, {ease: FlxEase.cubeOut});
			FlxTween.tween(bexPop, 	 {x: 0}, 						   0.7, {ease: FlxEase.cubeOut});
		}
		else {
			bellaPop.alpha = 0;
			bexPop.alpha = 0;
		}
	}

	function noteSwap(skip:Bool) {
		if(!skip) {
			for(strum in dadStrumline.strumGroup)
			{
				FlxTween.tween(strum, {angle: strum.angle+360}, 1, {ease: FlxEase.circOut});
			}
	
			for(strum in bfStrumline.strumGroup)
			{
				FlxTween.tween(strum, {angle: strum.angle-360}, 1, {ease: FlxEase.circOut});
			}
		}

		var speed:Float = (skip ? 0.01 : 1);

		bfStrumline.updatePls = true;
		FlxTween.tween(bfStrumline, {x: strumPos[0] - strumPos[1]}, speed, {ease: FlxEase.circOut, onComplete: function(twn:FlxTween)
		{
			bfStrumline.updatePls = false;
		}});

		dadStrumline.updatePls = true;
		FlxTween.tween(dadStrumline, {x: strumPos[0] + strumPos[1]}, speed, {ease: FlxEase.circOut, onComplete: function(twn:FlxTween)
		{
			dadStrumline.updatePls = false;
		}});

		for (thing in dadStrumline.strumGroup) {
			FlxTween.tween(thing, {alpha: 0.5}, 1, {ease: FlxEase.circOut});
		}

		for (thing in dadStrumline.allNotes) {
			FlxTween.tween(thing, {alpha: 0.5}, 1, {ease: FlxEase.circOut});
		}

		dadStrumline.noteAlpha = 0.5;
	}

	function taikoShit(index:Int):Int
	{
		if(index == 0) {
			if(pressed[3])
				return 3;
			else
				return 2;
		}
		else if(index == 1) {
			if(pressed[2])
				return 0;
			else
				return 1;
		}
		else if(index == 2) {
			if(pressed[1])
				return 0;
			else
				return 1;
		}
		else if(index == 3) {
			if(pressed[0])
				return 3;
			else
				return 2;
		}
		else
			return -1;
	}
}