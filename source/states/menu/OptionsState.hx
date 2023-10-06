package states.menu;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import data.GameData.MusicBeatState;
import gameObjects.menu.AlphabetMenu;
import gameObjects.menu.options.*;
import SaveData.SettingType;
import gameObjects.android.FlxVirtualPad;

class OptionsState extends MusicBeatState
{
	var optionShit:Map<String, Array<String>> =
	[
		"main" => [
			"Gameplay",
			"Appearance",
			"Controls",
		],
		"gameplay" => [
			"Ghost Tapping",
			"Downscroll",
			"Cutscenes",
			"Framerate Cap",
			"Preload Songs",
			"Touch Controls"
		],
		"appearance" => [
			"Skin",
			"Antialiasing",
			"Song Timer",
			"Note Splashes",
			"Smooth Healthbar",
			"Split Holds",
			"Shaders"
		],
	];

	public static var bgColors:Map<String, FlxColor> = [
		"main" 		=> 0xFFF85E4D,
		"gameplay"	=> 0xFF83e6aa,
		"appearance"=> 0xFFFEC404,
		"controls"  => 0xFF8295f5,
	];

	public static var curCat:String = "main";

	static var curSelected:Int = 0;
	static var storedSelected:Map<String, Int> = [];

	var grpTexts:FlxTypedGroup<FlxText>;
	var grpAttachs:FlxTypedGroup<FlxBasic>;
	var infoTxt:FlxText;

	// objects
	var bg:FlxSprite;

	// makes you able to go to the options and go back to the state you were before
	static var backTarget:FlxState;
	public function new(?newBackTarget:FlxState)
	{
		super();
		if(newBackTarget == null)
		{
			newBackTarget = new states.cd.MainMenu();
			if(backTarget == null)
				backTarget = newBackTarget;
		}
		else
			backTarget = newBackTarget;
	}

	var virtualPad:FlxVirtualPad;
	override function create()
	{
		super.create();
		CoolUtil.playMusic("movement");
		bg = new FlxSprite().loadGraphic(Paths.image('menu/menuDesat'));
		bg.scale.set(1.2,1.2); bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		grpTexts = new FlxTypedGroup<FlxText>();
		grpAttachs = new FlxTypedGroup<FlxBasic>();

		add(grpTexts);
		add(grpAttachs);
		
		infoTxt = new FlxText(0, 0, FlxG.width * 0.92, "");
		infoTxt.setFormat(Main.gFont, 28, 0xFFFFFFFF, CENTER);
		infoTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
		add(infoTxt);

		if(SaveData.data.get("Touch Controls")) {
            virtualPad = new FlxVirtualPad(LEFT_FULL, A_B);
            add(virtualPad);
        }


		reloadCat();
	}

	public function reloadCat(curCat:String = "main")
	{
		storedSelected.set(OptionsState.curCat, curSelected);

		OptionsState.curCat = curCat;
		grpTexts.clear();
		grpAttachs.clear();

		if(storedSelected.exists(curCat))
			curSelected = storedSelected.get(curCat);
		else
			curSelected = 0;

		if(bgColors.exists(curCat))
			bg.color = bgColors.get(curCat);
		else
			bg.color = bgColors.get("main");

		FlxG.sound.play(Paths.sound("menu/scroll"));

		if(curCat == "main")
		{
			for(i in 0...optionShit.get(curCat).length)
			{
				var item = new FlxText(0, 0, FlxG.width * 0.92, "");
				item.setFormat(Main.gFont, 70, 0xFFFFFFFF, CENTER);
				item.setBorderStyle(OUTLINE, FlxColor.BLACK, 4);
				item.text = optionShit.get(curCat)[i];
				grpTexts.add(item);

				item.ID = i;
				item.updateHitbox();

				var spaceY:Float = 36;

				item.screenCenter(X);
				item.y = (FlxG.height / 2) + ((item.height + spaceY) * i);
				item.y -= (item.height + spaceY) * (optionShit.get(curCat).length - 1) / 2;
				item.y -= (item.height / 2);
			}
		}
		else
		{
			for(i in 0...optionShit.get(curCat).length)
			{
				var daOption:String = optionShit.get(curCat)[i];
				var item = new FlxText(0, 0, FlxG.width * 0.92, "");
				item.setFormat(Main.gFont, 70, 0xFFFFFFFF, LEFT);
				item.setBorderStyle(OUTLINE, FlxColor.BLACK, 4);
				item.text = daOption;
				grpTexts.add(item);

				item.ID = i;

				item.scale.set(0.7,0.7);
				item.updateHitbox();

				item.x += 128;
				if(optionShit.get(curCat).length <= 9)
				{

					var spaceY:Float = 12;

					item.y = (FlxG.height / 2) + ((item.height + spaceY) * i);
					item.y -= (item.height + spaceY) * (optionShit.get(curCat).length - 1) / 2;
					item.y -= (item.height / 2);
				}

				if(SaveData.displaySettings.exists(daOption))
				{
					var daDisplay:Dynamic = SaveData.displaySettings.get(daOption);

					switch(daDisplay[1])
					{
						case CHECKMARK:
							var daCheck = new OptionCheckmark(SaveData.data.get(daOption), 0.7);
							daCheck.ID = i;
							daCheck.x = FlxG.width - 128 - daCheck.width;
							grpAttachs.add(daCheck);

						case SELECTOR:
							var array:Array<Dynamic> = daDisplay[3];
							if(daOption == "Skin")
								array = SaveData.returnSkins();
							var daSelec = new OptionSelector(
								daOption,
								SaveData.data.get(daOption),
								array
							);
							daSelec.xTo = FlxG.width - 128;
							daSelec.updateValue();
							daSelec.ID = i;
							grpAttachs.add(daSelec);

						default: // uhhh
					}
				}
			}
		}

		updateAttachPos();
		changeSelection();
	}

	public function changeSelection(change:Int = 0)
	{
		curSelected += change;
		curSelected = FlxMath.wrap(curSelected, 0, optionShit.get(curCat).length - 1);

		for(item in grpTexts.members)
		{
			//item.focusY = item.ID;
			item.alpha = 0.4;
			if(item.ID == curSelected)
			{
				item.alpha = 1;
			}
			//if(curSelected > 9)
			//{
			//	item.focusY -= curSelected - 9;
			//}
		}
		for(item in grpAttachs.members)
		{
			var daAlpha:Float = 0.4;
			if(item.ID == curSelected)
				daAlpha = 1;

			if(Std.isOfType(item, OptionCheckmark))
			{
				var check = cast(item, OptionCheckmark);
				check.alpha = daAlpha;
			}
			
			if(Std.isOfType(item, OptionSelector))
			{
				var selector = cast (item, OptionSelector);
				for(i in selector.members)
				{
					i.alpha = daAlpha;
				}
			}
		}
		
		infoTxt.text = "";
		if(curCat != "main")
		{
			try{
				
				infoTxt.text = SaveData.displaySettings.get(optionShit.get(curCat)[curSelected])[2];
				infoTxt.y = FlxG.height - infoTxt.height - 16;
				infoTxt.screenCenter(X);
				
				infoTxt.y -= 30;
				
			} catch(e) {
				trace("no description found");
			}
		}

		if(change != 0)
			FlxG.sound.play(Paths.sound("menu/scroll"));

		// uhhh
		selectorTimer = Math.NEGATIVE_INFINITY;
	}

	function updateAttachPos()
	{
		for(item in grpAttachs.members)
		{
			for(text in grpTexts.members)
			{
				if(text.ID == item.ID)
				{
					if(Std.isOfType(item, OptionCheckmark))
					{
						var check = cast(item, OptionCheckmark);
						check.y = text.y + text.height / 2 - check.height / 2;
					}
					
					if(Std.isOfType(item, OptionSelector))
					{
						var selector = cast(item, OptionSelector);
						selector.setY(text);
					}
				}
			}
		}
	}

	var selectorTimer:Float = Math.NEGATIVE_INFINITY;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var up:Bool = Controls.justPressed("UI_UP");
        if(SaveData.data.get("Touch Controls"))
            up = (Controls.justPressed("UI_UP") || virtualPad.buttonUp.justPressed);

        var down:Bool = Controls.justPressed("UI_DOWN");
        if(SaveData.data.get("Touch Controls"))
            down = (Controls.justPressed("UI_DOWN") || virtualPad.buttonDown.justPressed);

        var left:Bool = Controls.justPressed("UI_LEFT");
        if(SaveData.data.get("Touch Controls"))
            left = (Controls.justPressed("UI_LEFT") || virtualPad.buttonLeft.justPressed);

        var right:Bool = Controls.justPressed("UI_RIGHT");
        if(SaveData.data.get("Touch Controls"))
            right = (Controls.justPressed("UI_RIGHT") || virtualPad.buttonRight.justPressed);

		var leftP:Bool = Controls.pressed("UI_LEFT");
        if(SaveData.data.get("Touch Controls"))
            leftP = (Controls.pressed("UI_LEFT") || virtualPad.buttonLeft.pressed);

        var rightP:Bool = Controls.pressed("UI_RIGHT");
        if(SaveData.data.get("Touch Controls"))
            rightP = (Controls.pressed("UI_RIGHT") || virtualPad.buttonRight.pressed);

		var leftR:Bool = Controls.released("UI_LEFT");
        if(SaveData.data.get("Touch Controls"))
            leftR = (Controls.released("UI_LEFT") || virtualPad.buttonLeft.released);

        var rightR:Bool = Controls.justPressed("UI_RIGHT");
        if(SaveData.data.get("Touch Controls"))
            rightR = (Controls.released("UI_RIGHT") || virtualPad.buttonRight.released);

        var back:Bool = Controls.justPressed("BACK");
        if(SaveData.data.get("Touch Controls"))
            back = (Controls.justPressed("BACK") || virtualPad.buttonB.justPressed);

        var accept:Bool = Controls.justPressed("ACCEPT");
        if(SaveData.data.get("Touch Controls"))
            accept = (Controls.justPressed("ACCEPT") || virtualPad.buttonA.justPressed);

		updateAttachPos();
		if(infoTxt.text != "")
			infoTxt.y = FlxMath.lerp(infoTxt.y, FlxG.height - infoTxt.height - 16, elapsed * 8);

		if(back)
		{
			if(curCat == "main")
			{
				storedSelected.set("main", curSelected);
				FlxG.sound.play(Paths.sound("menu/back"));
				Main.switchState(backTarget);
				backTarget = null;
			}
			else
				reloadCat("main");
		}

		if(up)
			changeSelection(-1);
		if(down)
			changeSelection(1);

		if(accept)
		{
			if(curCat == "main")
			{
				storedSelected.set("main", curSelected);
				var daOption:String = grpTexts.members[curSelected].text.toLowerCase();
				switch(daOption)
				{
					default:
						if(optionShit.exists(daOption))
							reloadCat(daOption);

					case "controls":
						new FlxTimer().start(0.1, function(tmr:FlxTimer)
						{
							Main.skipStuff();
							Main.switchState(new ControlsState());
						});
				}
			}
			else
			{
				var curAttach = grpAttachs.members[curSelected];
				if(Std.isOfType(curAttach, OptionCheckmark))
				{
					var checkmark = cast(curAttach, OptionCheckmark);
					checkmark.setValue(!checkmark.value);

					SaveData.data.set(optionShit[curCat][curSelected], checkmark.value);
					SaveData.save();

					FlxG.sound.play(Paths.sound("menu/scroll"));
				}
			}
		}
		
		if(leftP || rightP)
		{
			var curAttach = grpAttachs.members[curSelected];
			if(Std.isOfType(curAttach, OptionSelector))
			{
				var selector = cast(curAttach, OptionSelector);

				if(left || right)
				{
					selectorTimer = -0.5;
					FlxG.sound.play(Paths.sound("menu/scroll"));

					if(leftP)
						selector.updateValue(-1);
					else
						selector.updateValue(1);
				}

				if(leftP)
					selector.arrowL.alpha = 1;

				if(rightP)
					selector.arrowR.alpha = 1;

				if(selectorTimer != Math.NEGATIVE_INFINITY && !Std.isOfType(selector.bounds[0], String))
				{
					selectorTimer += elapsed;
					if(selectorTimer >= 0.02)
					{
						selectorTimer = 0;
						if(leftP)
							selector.updateValue(-1);
						if(rightP)
							selector.updateValue(1);
					}
				}
			}
		}
		if(leftR || rightR)
		{
			selectorTimer = Math.NEGATIVE_INFINITY;
			for(attach in grpAttachs.members)
			{
				if(Std.isOfType(attach, OptionSelector))
				{
					var selector = cast(attach, OptionSelector);
					if(leftR)
						selector.arrowL.animation.play("idle");

					if(rightR)
						selector.arrowR.animation.play("idle");
				}
			}
		}
	}
}