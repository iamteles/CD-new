package states;

import data.Conductor;
import gameObjects.MoneyCounter;
import gameObjects.hud.Shop;
import data.Discord.DiscordClient;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import data.GameData.MusicBeatState;
import data.SongData;
import flixel.FlxObject;
import flixel.FlxCamera;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.FlxState;
import openfl.filters.ShaderFilter;
import data.FlxRuntimeShader;
import data.ChartLoader;
import data.GameData.MusicBeatState;
import data.SongData.SwagSong;
import gameObjects.*;
import gameObjects.hud.*;
import gameObjects.hud.note.*;
import sys.thread.Mutex;
import sys.thread.Thread;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

#if sys
import sys.io.File;
#end

using StringTools;

class ShopState extends MusicBeatState
{
    public static var camGame:FlxCamera;
    public static var camHUD:FlxCamera;

    public static var camFollow:FlxObject = new FlxObject();

    var moneyCount:MoneyCounter;
    public static var hudTalk:ShopTalk;
    public static var hudBuy:ShopBuy;
    var bg:FlxSprite;
    public static var watts:FlxSprite;
    var desk:FlxSprite;

    var wattsSpeakin:Bool = false;

    public static var zoom:Float = 0.6;
    override function create()
    {
        super.create();

        CoolUtil.playMusic("WhatchaBuyin", 0.8);
        Conductor.setBPM(88);

        camGame = new FlxCamera();
        camHUD = new FlxCamera();
		camHUD.bgColor.alphaFloat = 0;

        FlxG.cameras.reset(camGame);
        FlxG.cameras.add(camHUD, false);

        // default camera
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

        camGame.zoom = zoom;

		bg = new FlxSprite(-121, -126.95).loadGraphic(Paths.image('hud/shop/back'));
		add(bg);

        watts = new FlxSprite(628.6, 17.3);
        watts.frames = Paths.getSparrowAtlas("hud/shop/watts");
        watts.animation.addByPrefix("idle", 'stand', 24, true);
        watts.animation.addByPrefix("neutral", 'neutral', 24, true);
        watts.animation.addByPrefix("sad", 'sad', 24, true);
        watts.animation.addByPrefix("happy", 'happy', 24, true);
        watts.animation.addByPrefix("angry", 'angry', 24, true);
        watts.animation.addByPrefix("confused", 'confused', 24, true);
        watts.animation.addByPrefix("neutralidle", 'stand0000', 24, true);
        watts.animation.addByPrefix("sadidle", 'sad0000', 24, true);
        watts.animation.addByPrefix("happyidle", 'happy0000', 24, true);
        watts.animation.addByPrefix("angryidle", 'angry0000', 24, true);
        watts.animation.addByPrefix("confusedidle", 'confused0000', 24, true);
        watts.animation.addByPrefix("neutralidle", 'stand0000', 24, true);
        watts.animation.addByPrefix("pull", 'pull out0', 24, true);
        watts.animation.addByPrefix("pullalt", 'pull out-alt', 24, true);
        watts.animation.play("idle");
        watts.updateHitbox();
        add(watts);

        desk = new FlxSprite(-74.4, 673.35).loadGraphic(Paths.image('hud/shop/desk'));
        desk.scale.set(1.1, 1.1);
		add(desk);

        camFollow.setPosition(watts.getMidpoint().x, watts.getMidpoint().y + 80);
		FlxG.camera.follow(camFollow, LOCKON, 1);
		FlxG.camera.focusOn(camFollow.getPosition());

        moneyCount = new MoneyCounter();
        moneyCount.cameras = [camHUD];
		add(moneyCount);

        hudTalk = new ShopTalk();
        hudTalk.cameras = [camHUD];
		add(hudTalk);

        hudBuy = new ShopBuy();
        hudBuy.cameras = [camHUD];
        hudBuy.tweenAlpha(0,0.01);
		add(hudBuy);

        var bloom = new FlxRuntimeShader(File.getContent(Paths.shader('bloom')));
        FlxG.camera.setFilters([new ShaderFilter(bloom)]);
    }
    override function update(elapsed:Float)
    {
        super.update(elapsed);

        camGame.followLerp = elapsed * 3;
        camGame.zoom = FlxMath.lerp(camGame.zoom, zoom, elapsed * 6);

        //if(Controls.justPressed("BACK"))
		//	Main.switchState(new MenuState());
    }

    public static function enterShop()
    {
        hudTalk.tweenAlpha(0, 1);

        var countTimer = new FlxTimer().start(1, function(tmr:FlxTimer)
        {
            camFollow.setPosition(watts.getMidpoint().x + 400, watts.getMidpoint().y + 80);
            var countTimer = new FlxTimer().start(0.7, function(tmr:FlxTimer)
            {
                hudBuy.tweenAlpha(1,0.7);
            });
        });
    }

    public static function exitShop(question:Bool = false)
    {
        hudBuy.tweenAlpha(0, 1);

        var countTimer = new FlxTimer().start(1, function(tmr:FlxTimer)
        {
            camFollow.setPosition(watts.getMidpoint().x, watts.getMidpoint().y + 80);
            var countTimer = new FlxTimer().start(0.7, function(tmr:FlxTimer)
            {
                hudTalk.tweenAlpha(1, 1);
                if(question)
                    hudTalk.resetDial("entersong");
                else
                    hudTalk.resetDial("post");
            });
        });
    }
}

class LoadShopState extends MusicBeatState
{
	var threadActive:Bool = true;
	var mutex:Mutex;
	
	//var behind:FlxGroup;
	var bg:FlxSprite;
    var logo:FlxSprite;

	var loadBar:FlxSprite;
	var loadPercent:Float = 0;
	
	override function create()
	{
		super.create();
		mutex = new Mutex();
		
		//behind = new FlxGroup();
		//add(behind);
		
		var color = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFF000000);
		color.screenCenter();
		add(color);
		
		// loading image
		bg = new FlxSprite().loadGraphic(Paths.image('menu/main/bg'));
		bg.updateHitbox();
		bg.screenCenter();
		bg.alpha = 0.3;
		add(bg);

		logo = new FlxSprite().loadGraphic(Paths.image('menu/loading'));
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

		var conservation = SongData.loadFromJson("conservation", "normal");
        var irritation = SongData.loadFromJson("irritation", "normal");

        var songs:Array<SwagSong> = [conservation, irritation];

		var preloadThread = Thread.create(function()
		{
			mutex.acquire();
			Paths.preloadPlayStuff();
			Rating.preload(assetModifier);
			Paths.preloadGraphic('hud/base/healthBar');
			Paths.preloadGraphic('hud/base/blackBar');
			Paths.preloadGraphic('vignette');
			
			var stageBuild = new Stage();
			stageBuild.reloadStageFromSong("irritation"); //just the one

			trace('preloaded stage and hud');
			
			loadPercent = 0.2;

			var charList:Array<String> = ["watts", "watts-alt"];

			for(i in charList) {
				var char = new Character();
				char.isPlayer = false;
				char.reloadChar(i);
				//behind.add(char);
				
				//trace('preloaded $i');

				loadPercent += (0.6 - 0.2) / charList.length;
			}

            for (i in ["bella", "bex", "watts"]) {
                var icon = new HealthIcon();
				icon.setIcon(i, false);
            }
			
			trace('preloaded characters');
			loadPercent = 0.6;
			
            for (i in songs) {
                Paths.preloadSound('songs/${i.song}/Inst');
                if(i.needsVoices)
                    Paths.preloadSound('songs/${i.song}/Voices');
            }

			
			trace('preloaded music');
			loadPercent = 0.75;
			
			var thisStrumline = new Strumline(0, null, false, false, true, assetModifier);
			thisStrumline.ID = 0;
			//behind.add(thisStrumline);

            for (i in songs) {
                var noteList:Array<Note> = ChartLoader.getChart(i);
                for(note in noteList)
                {
                    note.reloadNote(note.songTime, note.noteData, note.noteType, assetModifier);
                    //behind.add(note);
                    
                    thisStrumline.addSplash(note);

                    loadPercent += (0.9 - 0.75) / noteList.length;
                }
            }
			
			trace('preloaded notes');
			loadPercent = 0.9;
			
			// shop preloads

            var preGraphics:Array<String> = [
                "hud/shop/watts",
                "hud/shop/wattsicons",
                'hud/shop/box',
                'hud/shop/small',
                'hud/shop/bix',
                "hud/shop/tabs",
                "hud/shop/ITEMS"
            ];
            var preSounds:Array<String> = [
                "dialog/watts/watts1",
                "dialog/watts/watts2",
                "dialog/watts/watts3",
                "dialog/watts/watts4"
            ];

            for(i in preGraphics)
                Paths.preloadGraphic(i);
    
            for(i in preSounds)
                Paths.preloadSound(i);

            for (i in Paths.readDir("data/watts", ".json"))
                Paths.json("data/watts/" + i);

            Paths.shader("shaders/bloom");
			
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
			Main.switchState(new ShopState());
		}

		loadBar.scale.x = FlxMath.lerp(loadBar.scale.x, loadPercent, elapsed * 6);
		loadBar.updateHitbox();
	}
}