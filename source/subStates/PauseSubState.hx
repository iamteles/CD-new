package subStates;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.system.FlxSound;
import data.Conductor;
import data.GameData.MusicBeatSubState;
import gameObjects.menu.AlphabetMenu;
import states.*;
import gameObjects.android.FlxVirtualPad;
import flixel.addons.display.FlxBackdrop;

class PauseSubState extends MusicBeatSubState
{
	var optionShit:Array<Array<Dynamic>> = [
		["resume", 0, 0],
		["restart", 0, 0],
		["options", 0, 0],
		["exit", 0, 0],
	];

	var curSelected:Int = 0;

	var pauseSong:FlxSound;

	var tiles:FlxBackdrop;
	var buttons:FlxTypedGroup<FlxSprite>;
	var left:FlxSprite;
	var right:FlxSprite;
	var bpButton:FlxSprite;
	public function new()
	{
		super();
		var banana = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		add(banana);

		banana.alpha = 0;
		FlxTween.tween(banana, {alpha: 0.4}, 0.1);

		pauseSong = new FlxSound().loadEmbedded(Paths.inst(PlayState.SONG.song.toLowerCase()), true, false);
		if(Conductor.songPos > 0)
		{
			pauseSong.play(Conductor.songPos);
			pauseSong.pitch = 0.9;
			pauseSong.volume = 0;
			FlxTween.tween(pauseSong, {volume: 0.45}, 3, {startDelay: 1});
		}
		FlxG.sound.list.add(pauseSong);

		tiles = new FlxBackdrop(Paths.image('menu/title/tiles/main'), XY, 0, 0);
        tiles.velocity.set(FlxG.random.bool(50) ? 90 : -90, FlxG.random.bool(50) ? 90 : -90);
        tiles.screenCenter();
		tiles.alpha = 0;
		FlxTween.tween(tiles, {alpha: 0.4}, 0.1);
        add(tiles);

		buttons = new FlxTypedGroup<FlxSprite>();
		add(buttons);

		for(i in 0...optionShit.length)
		{
			var name = optionShit[i][0];
			var index = i;

			var button = new FlxSprite();
			button.frames = Paths.getSparrowAtlas('hud/pause/buttons');
			button.animation.addByPrefix('idle',  name + '0', 24, true);
			button.animation.play('idle');
			button.ID = i;

			button.scale.set(0.65,0.65);
			button.updateHitbox();


			switch(index) {
				case 0:
					button.screenCenter(X);
					button.y += 20;
				case 1:
					button.screenCenter(Y);
					button.x = 275.35;
				case 2:
					button.screenCenter(Y);
					button.x = 1004.65 - button.width;
				case 3:
					button.screenCenter(X);
					button.y = FlxG.height - button.height - 20;
			}

			buttons.add(button);
		}

		left = new FlxSprite();
		left.frames = Paths.getSparrowAtlas('hud/pause/selector');
		left.animation.addByPrefix('idle',  "selectors left", 24, true);
		left.animation.play('idle');
		left.scale.set(0.65,0.65);
		left.updateHitbox();
		add(left);

		right = new FlxSprite();
		right.frames = Paths.getSparrowAtlas('hud/pause/selector');
		right.animation.addByPrefix('idle',  "selectors right", 24, true);
		right.animation.play('idle');
		right.scale.set(0.65,0.65);
		right.updateHitbox();
		add(right);

		bpButton = new FlxSprite();
		bpButton.frames = Paths.getSparrowAtlas('hud/pause/botplay');
		bpButton.animation.addByPrefix('off',  "off", 24, true);
		bpButton.animation.addByPrefix('on',  "on", 24, true);
		bpButton.animation.play('off');
		bpButton.scale.set(0.65,0.65);
		bpButton.updateHitbox();
		bpButton.x = 1004 + 138 - (bpButton.width/2);
		bpButton.y = FlxG.height - bpButton.height - 20;
		add(bpButton);

		var grphic:FlxSprite;
		grphic = new FlxSprite().loadGraphic(Paths.image("hud/pause/pause"));
		grphic.scale.set(0.65,0.65);
		grphic.updateHitbox();
		grphic.screenCenter(Y);
		grphic.x = 138 - (grphic.width/2);
		add(grphic);

		changeSelection();
	}

	override function close()
	{
		pauseSong.stop();
		super.close();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		var lastCam = FlxG.cameras.list[FlxG.cameras.list.length - 1];
		for(item in members)
		{
			if(Std.isOfType(item, FlxBasic))
				cast(item, FlxBasic).cameras = [lastCam];
		}

		// remainders from the old pause menu
		var up:Bool = Controls.justPressed("UI_UP") || Controls.justPressed("UI_LEFT");
        var down:Bool = Controls.justPressed("UI_DOWN") || Controls.justPressed("UI_RIGHT");
        var back:Bool = Controls.justPressed("BACK");
        var accept:Bool = Controls.justPressed("ACCEPT");

		if(up)
			changeSelection(-1);
		if(down)
			changeSelection(1);

		if(accept)
			select(curSelected);

		for(item in buttons) {
			if(CoolUtil.mouseOverlap(item, lastCam)) {
				if(FlxG.mouse.justPressed && focused) {
					select(item.ID);
				}
			}
        }

		if(CoolUtil.mouseOverlap(bpButton, lastCam)) {
			if(FlxG.mouse.justPressed && focused) {
				botplay();
			}
		}

		if(PlayState.botplay)
			bpButton.animation.play('on');
		else
			bpButton.animation.play('off');

		// works the same as resume
		if(back)
		{
			PlayState.paused = false;
			close();
		}

		for(item in buttons.members)
		{
			if(item.ID == curSelected) {
				left.x = FlxMath.lerp(left.x, item.x - 6, elapsed*12);
				left.y = FlxMath.lerp(left.y, item.y - 8, elapsed*12);

				right.x = FlxMath.lerp(right.x, item.x + item.width - 24, elapsed*12);
				right.y = FlxMath.lerp(right.y, item.y - 8, elapsed*12);
			}

		}
	}

	function changeSelection(change:Int = 0)
	{
		curSelected += change;
		curSelected = FlxMath.wrap(curSelected, 0, optionShit.length - 1);

		if(change != 0)
			FlxG.sound.play(Paths.sound("menu/scroll"));
	}

	function select(what:Int = 0)
	{
		switch(optionShit[what][0])
		{
			default:
				FlxG.sound.play(Paths.sound("menu/back"));
		
			case "resume":
				FlxG.sound.play(Paths.sound("menu/select"));
				PlayState.paused = false;
				close();

			case "restart":
				FlxG.sound.play(Paths.sound("menu/back"));
				Main.skipStuff();
				Main.switchState();

			case "botplay": //unused from here
				botplay();

			case "options":
				FlxG.sound.play(Paths.sound("menu/select"));
				Main.switchState(new states.menu.OptionsState(new LoadSongState()));

			case "exit":
				//Main.switchState(new MenuState());
				FlxG.sound.play(Paths.sound("menu/back"));
				PlayState.sendToMenu();
		}
	}

	function botplay()
	{
		PlayState.botplay = !PlayState.botplay;

		var thing:String = (PlayState.botplay ? "On" : "Off");
		FlxG.sound.play(Paths.sound("botplay" + thing));
	}
}