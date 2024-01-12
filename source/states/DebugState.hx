package states;

import data.Discord.DiscordClient;
import data.GameTransition;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import data.GameData.MusicBeatState;
import gameObjects.menu.Alphabet;
import gameObjects.android.FlxVirtualPad;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

using StringTools;

class DebugState extends MusicBeatState
{
	var optionShit:Array<String> = ["menu", "video", "ending", "kiss"];
	static var curSelected:Int = 0;

	var optionGroup:FlxTypedGroup<Alphabet>;

	override function create()
	{
		super.create();
		CoolUtil.playMusic("MENU");

		Main.setMouse(true);

		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Debug Menu...", null);

		var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(80,80,80));
		bg.screenCenter();
		add(bg);

		optionGroup = new FlxTypedGroup<Alphabet>();
		add(optionGroup);

		for(i in 0...optionShit.length)
		{
			var item = new Alphabet(0,0, "nah", false);
			item.align = CENTER;
			item.text = optionShit[i].toUpperCase();
			item.x = FlxG.width / 2;
			item.y = 50 + ((item.height + 100) * i);
			item.ID = i;
			optionGroup.add(item);
		}

		var gif = new FlxSprite();
		gif.frames = Paths.getSparrowAtlas("menu/bios/text");
		gif.animation.addByPrefix("idle", 'Símbolo 1', 24, false);
		gif.animation.play("idle");
		gif.scale.set(2.3, 2.4);
		gif.updateHitbox();
		gif.screenCenter();
		add(gif);

		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			FlxTween.tween(gif, {alpha: 0}, 0.6, {
				ease: FlxEase.cubeOut,
				startDelay: 0.8
			});
		});

        if(SaveData.data.get("Touch Controls")) {
            virtualPad = new FlxVirtualPad(UP_DOWN, A_B_C);
            add(virtualPad);
        }

		changeSelection();
	}
    var virtualPad:FlxVirtualPad;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var up:Bool = Controls.justPressed("UI_UP");
        if(SaveData.data.get("Touch Controls"))
            up = (Controls.justPressed("UI_UP") || virtualPad.buttonUp.justPressed);

        var down:Bool = Controls.justPressed("UI_DOWN");
        if(SaveData.data.get("Touch Controls"))
            down = (Controls.justPressed("UI_DOWN") || virtualPad.buttonDown.justPressed);

        var back:Bool = Controls.justPressed("BACK");
        if(SaveData.data.get("Touch Controls"))
            back = (Controls.justPressed("BACK") || virtualPad.buttonB.justPressed);

        var accept:Bool = Controls.justPressed("ACCEPT");
        if(SaveData.data.get("Touch Controls"))
            accept = (Controls.justPressed("ACCEPT") || virtualPad.buttonA.justPressed);

		var HAX:Bool = Controls.justPressed("ACCEPT");
        if(SaveData.data.get("Touch Controls"))
            HAX = (Controls.justPressed("ACCEPT") || virtualPad.buttonC.justPressed);

		if(up)
			changeSelection(-1);
		if(down)
			changeSelection(1);

		if(HAX) { // INFINITE MONEY HAX
			SaveData.transaction(99999);
		}

		if(accept)
		{
			switch(optionShit[curSelected])
			{
				//case "story mode":
				//	Main.switchState(new states.menu.StoryMenuState());
				case "menu":
					Main.switchState(new states.cd.MainMenu());
				case "dialog":
					Main.switchState(new states.cd.Dialog());
				case "ending":
					Main.switchState(new states.cd.Ending());
				case "kiss":
					Main.switchState(new states.cd.Kissing());
				case "intimidating":
					Main.switchState(new states.cd.fault.MainMenu());
				case "video":
					Main.switchState(new states.VideoState());
				case "shop":
					Main.switchState(new states.ShopState.LoadShopState());
				case "transition":
					openSubState(new GameTransition(false));
				case "options":
					Main.switchState(new states.menu.OptionsState());
			}
		}
	}

	public function changeSelection(change:Int = 0)
	{
		curSelected += change;
		curSelected = FlxMath.wrap(curSelected, 0, optionShit.length - 1);

		for(item in optionGroup.members)
		{
			var daText:String = optionShit[item.ID].toUpperCase().replace("-", " ");

			var daBold = (curSelected == item.ID);

			if(item.bold != daBold)
			{
				item.bold = daBold;
				if(daBold)
					item.text = '> ' + daText + ' <';
				else
					item.text = daText;
				item.x = FlxG.width / 2;
			}
		}
	}
}