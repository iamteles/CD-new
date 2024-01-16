package states.cd;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.addons.display.FlxBackdrop;
import data.GameData.MusicBeatState;
import flixel.text.FlxText;
import hxcodec.flixel.FlxVideo;
import flixel.system.FlxSound;
#if !html5
import sys.thread.Mutex;
import sys.thread.Thread;
#end

class Intro extends MusicBeatState
{
	var sprite:FlxSprite;
	var spriteSD:FlxSprite;
	override public function create():Void 
	{
		super.create();

        var color = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFFFFFFF);
		color.screenCenter();
		add(color);
        
		sprite = new FlxSprite();
		sprite.frames = Paths.getSparrowAtlas("menu/intros/flixel");
		sprite.animation.addByPrefix('start', 		'haxe', 24, false);
		sprite.animation.addByPrefix('startI', 		'haxe0000', 24, false);
		sprite.animation.play('startI');
		sprite.updateHitbox();
		sprite.screenCenter();
		//sprite.x += 30;
		sprite.alpha = 0;
		add(sprite);

		/*

		spriteSD = new FlxSprite();
		spriteSD.frames = Paths.getSparrowAtlas("menu/intros/shatterdisk");
		spriteSD.animation.addByPrefix('start', 		'opening', 24, false);
		spriteSD.animation.addByPrefix('startI', 		'opening0000', 24, false);
		spriteSD.animation.play('startI');
		spriteSD.updateHitbox();
		spriteSD.screenCenter();
		spriteSD.x -= 110;
		spriteSD.alpha = 0;
		add(spriteSD);

		*/


		new FlxTimer().start(0.5, function(tmr:FlxTimer)
		{
			sprite.alpha = 1;
			sprite.animation.play('start');
			FlxG.sound.play(Paths.sound("intro/haxe"), 1, false, null, true);
		});

		new FlxTimer().start(3.2, function(tmr:FlxTimer)
		{
			finish();
			/*
			FlxTween.tween(sprite, {alpha: 0}, 0.5, {ease: FlxEase.circInOut, onComplete: function(twn:FlxTween)
			{
				finish();
				/*
				FlxTween.tween(spriteSD, {alpha: 1}, 0.4);
				spriteSD.animation.play('start');
				FlxG.sound.play(Paths.sound("intro/shatterdisk"), 1, false, null, true);

				new FlxTimer().start(4, function(tmr:FlxTimer)
				{
					finish();
				});
			}});
			*/
		});
	
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);

		var click:Bool = FlxG.keys.justPressed.SPACE || FlxG.keys.justPressed.ENTER || FlxG.mouse.justPressed;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed && SaveData.progression.get("firstboot"))
				finish();
		}
		#end

		if (click && SaveData.progression.get("firstboot"))
		{
			finish();
		}
	}
	
	private function finish():Void
	{
		Main.skipClearMemory = true;
		Main.switchState(new states.cd.Intro.Video());
	}
	
}

class Warning extends MusicBeatState
{
	var isPlaytester:Bool = false;
	override public function create():Void 
	{
		super.create();

        var color = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFF000000);
		color.screenCenter();
		add(color);

		var tiles = new FlxBackdrop(Paths.image('all'), XY, 0, 0);
        tiles.velocity.set(30, 30);
        tiles.screenCenter();
		tiles.alpha = 0.7;
        add(tiles);

		var tex:String = "Warning!\n\nThis mod features flashing lights that may\nbe harmful to those with photosensitivity.\nYou can disable them in the Options menu.\n\nPress ENTER to continue!";
		if(isPlaytester)
			tex = "Hello playtester!\n\nThank you so much for helping us ensure\nthe mod has a bug-free experience.\nWe ask you that you NOT share anything in this\nbuild to anyone to keep the surprise!\nPlease report any bugs in the Google Forms\nthat was sent with the build.\n\nPress ENTER to continue!";
		var popUpTxt = new FlxText(0,0,0,tex);
		popUpTxt.setFormat(Main.gFont, 43, 0xFFFFFFFF, CENTER);
		popUpTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 2.5);
		popUpTxt.screenCenter();
		add(popUpTxt);
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);

		var click:Bool = FlxG.keys.justPressed.SPACE || FlxG.keys.justPressed.ENTER || FlxG.mouse.justPressed;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
				finish();
		}
		#end

		if (click)
		{
			finish();
		}
	}
	
	private function finish():Void
	{
		#if mobile
		Main.switchState(new TitleScreen());
		#else
		Main.switchState(new Intro.IntroLoading());
		#end
	}
	
}



class Video extends MusicBeatState
{
    var video:FlxVideo;

    public static var name:String = "intro";
	override public function create():Void
	{
		video = new FlxVideo();
		video.onEndReached.add(onComplete);
		video.play(Paths.video(name));

		CoolUtil.playMusic("intro");

		super.create();
	}

    public function onComplete():Void
    {
        video.dispose();

		Main.skipStuff();
		Main.switchState(new states.cd.TitleScreen());
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        
		var click:Bool = FlxG.keys.justPressed.SPACE || FlxG.keys.justPressed.ENTER || FlxG.mouse.justPressed;

        if(click && SaveData.progression.get("firstboot")) {
            onComplete();
        }
    }
}

class IntroLoading extends MusicBeatState
{
	var threadActive:Bool = true;

	#if !html5
	var mutex:Mutex;
	#end

	var bg:FlxSprite;
	var logo:FlxSprite;

	var loadBar:FlxSprite;
	var loadPercent:Float = 0;
	
	override function create()
	{
		super.create();

		#if !html5
		mutex = new Mutex();
		#end
		
		var color = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFF000000);
		color.screenCenter();
		add(color);

		logo = new FlxSprite().loadGraphic(Paths.image('menu/loading'));
		logo.scale.set(0.3,0.3);
		logo.updateHitbox();
		logo.x = FlxG.width - logo.width - 10;
		logo.y = FlxG.height - logo.height - 10;
		add(logo);
		
		var oldAnti:Bool = FlxSprite.defaultAntialiasing;
		FlxSprite.defaultAntialiasing = false;

		#if !html5
		var preloadThread = Thread.create(function()
		{
			mutex.acquire();
			#end

			Paths.preloadGraphic('menu/title/gradients/' + Main.possibleTitles[Main.randomized][0]);
			Paths.preloadGraphic('menu/title/tiles/' + Main.possibleTitles[Main.randomized][0]);
			Paths.preloadGraphic('menu/title/logo');
			Paths.preloadSound("intro/end");
			Paths.preloadGraphic("menu/intros/flixel");
			Paths.preloadSound("intro/haxe");

			var video = new FlxVideo();
			video.play(Paths.video("video"));
			video.pause();
			video.dispose();


			loadPercent = 1.0;
			//trace('finished loading');

			FlxSprite.defaultAntialiasing = oldAnti;
			#if !html5
			threadActive = false;
			mutex.release();
		});
		#else
		Main.skipClearMemory = true;
		Main.switchState(new states.cd.Intro());
		#end
	}
	
	var byeLol:Bool = false;
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		#if !html5
		if(!threadActive && !byeLol)
		{
			byeLol = true;
			Main.skipClearMemory = true;
			Main.switchState(new states.cd.Intro());
		}
		#end
	}
}