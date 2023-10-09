package subStates;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.FlxBasic;
import data.GameData.MusicBeatSubState;
import gameObjects.Character;
import states.*;

class GameOverSubState extends MusicBeatSubState
{
	var heart:FlxSprite;
	var text:FlxSprite;
	var char:String = "bella";
	var overSong:String = "reiterate";
	public function new(char:String)
	{
		super();
	
		this.char = char;
	}
	
	override function create()
	{
		super.create();

		heart = new FlxSprite();
		heart.frames = Paths.getSparrowAtlas("hud/base/gameover/heart");
		heart.animation.addByPrefix("idle", 'game over', 24, false);
		heart.animation.play('idle');
		heart.scale.set(0.5, 0.5);
		heart.updateHitbox();
		heart.screenCenter();
		heart.y += 270;
		add(heart);

		text = new FlxSprite();
		text.frames = Paths.getSparrowAtlas("hud/base/gameover/retry");
		text.animation.addByPrefix("idle", 'tex', 24, false);
		text.scale.set(0.6, 0.6);
		text.updateHitbox();
		text.screenCenter(X);
		text.alpha = 0;
		text.y -= 160;
		add(text);
	
		FlxG.sound.play(Paths.sound('death/${CoolUtil.formatChar(char)}_death_sound'));

		new FlxTimer().start(2.1, function(tmr:FlxTimer)
		{
			text.animation.play('idle');
			text.alpha = 1;
		});

		new FlxTimer().start(4.2, function(tmr:FlxTimer)
		{
			CoolUtil.playMusic(switch(PlayState.SONG.song)
			{
				case "panic-attack" | "convergence" | "desertion" | "sin": "death/bree";
				default: "death/reiterate";
			});
			
			canEnd = true;
		});
	}

	public var ended:Bool = false;
	public var canEnd:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var lastCam = FlxG.cameras.list[FlxG.cameras.list.length - 1];
		for(item in members)
		{
			if(Std.isOfType(item, FlxBasic))
				cast(item, FlxBasic).cameras = [lastCam];
		}

		if(!ended && canEnd)
		{
			if(Controls.justPressed("BACK"))
			{
				FlxG.camera.fade(FlxColor.BLACK, 0.2, false, function()
				{
					//Main.switchState(new MenuState());
					PlayState.sendToMenu();
				}, true);
				
			}

			if(Controls.justPressed("ACCEPT"))
				endBullshit();

			#if mobile
			for (touch in FlxG.touches.list)
			{
				if (touch.justPressed)
					endBullshit();
			}
			#end
		}
	}

	public function endBullshit()
	{
		ended = true;

		CoolUtil.playMusic();
		FlxG.sound.play(Paths.music(switch(PlayState.SONG.song)
		{
			case "panic-attack" | "convergence" | "desertion" | "sin": "death/bree_end";
			default: "death/reiterate_end";
		}));

		new FlxTimer().start(1.0, function(tmr:FlxTimer)
		{
			FlxG.camera.fade(FlxColor.BLACK, 1.0, false, null, true);

			new FlxTimer().start(2.0, function(tmr:FlxTimer)
			{
				Main.skipClearMemory = true;
				Main.switchState(new PlayState());
			});

		});
	}
}