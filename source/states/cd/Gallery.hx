package states.cd;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.addons.display.FlxBackdrop;
import flixel.math.FlxMath;
import data.GameData.MusicBeatState;
import gameObjects.android.FlxVirtualPad;
import data.Discord.DiscordClient;

class Gallery extends MusicBeatState
{
	public var curSelected:Int = 0;
	public var menuItems:FlxTypedGroup<FlxSprite>;

	var tipTextArray:Array<String> = "E/Q - Camera Zoom
	\nR - Reset Camera Zoom
	\nArrow Keys - Scroll
    \nENTER - Set as Menu
	\nSPACE - Reset Background\n".split('\n');

	var zoomAmmount:Int = 100;

	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	var itemScale:Float = 0.7;

	var descText:FlxText;
	var descTextTwo:FlxText;
    var bg:FlxSprite;

    var items:Array<Array<String>> = [
        ["menu/gallery/fanart/" + "daiseydraws", "", "@daiseydraws on Instagram"],
        ["menu/gallery/fanart/" + "sammy_jiru", "", "@sammy_jiru on Instagram"],
        ["menu/gallery/fanart/" + "Pankiepoo", "", "@Pankiepoo on Twitter"],
        ["menu/gallery/fanart/" + "Spamtune", "", "@thesound_crows (Spamtune) on Twitter"],
        ["menu/gallery/fanart/" + "OOBO3310", "", "@OOBO3310 on Twitter"]
    ];
	public override function create()
	{
		super.create();
		menuItems = new FlxTypedGroup<FlxSprite>();

		Main.setMouse(false);

		DiscordClient.changePresence("In the Gallery...", null);

        bg = new FlxSprite().loadGraphic(Paths.image('menu/gallery/bg'));
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		for(i in 0...items.length)
		{
			var item:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image(items[i][0]));
			item.screenCenter(X);
			item.screenCenter(Y);
			menuItems.add(item);

			item.ID = i;
		}

		add(menuItems);

        leftArrow = new FlxSprite().loadGraphic(Paths.image("menu/gallery/arrow"));
		rightArrow = new FlxSprite().loadGraphic(Paths.image("menu/gallery/arrow"));
		rightArrow.flipX = true;
		leftArrow.scale.set(0.7, 0.7);
		rightArrow.scale.set(0.7, 0.7);
		leftArrow.updateHitbox();
		rightArrow.updateHitbox();
        leftArrow.screenCenter(Y);
        rightArrow.screenCenter(Y);
        rightArrow.x = FlxG.width - rightArrow.width;
		add(leftArrow);
		add(rightArrow);

		descText = new FlxText(50, 600, 1180, "", 32);
		descText.setFormat(Main.gFont, 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();
		descText.borderSize = 2.4;
		add(descText);

		descTextTwo = new FlxText(50, 640, 1180, "", 32);
		descTextTwo.setFormat(Main.gFont, 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descTextTwo.scrollFactor.set();
		descTextTwo.borderSize = 2.4;
		add(descTextTwo);

		if(SaveData.data.get("Touch Controls")) {
			tipTextArray = "A - Set as Menu Background
			\nB - Back
			\nC - Reset Background\n".split('\n');
        }

		for (i in 0...tipTextArray.length-1)
		{
			var tipText:FlxText = new FlxText(FlxG.width - 320, FlxG.height - 15 - 16 * (tipTextArray.length - i), 300, tipTextArray[i], 12);
			tipText.setFormat(Main.gFont, 20, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
			tipText.scrollFactor.set();
			tipText.borderSize = 2;
			add(tipText);
		}
		if(SaveData.data.get("Touch Controls")) {
            virtualPad = new FlxVirtualPad(LEFT_RIGHT, A_B_C);
            add(virtualPad);
        }
	}
	var virtualPad:FlxVirtualPad;
	public override function update(elapsed:Float)
	{
		super.update(elapsed);

        var left:Bool = Controls.justPressed("UI_LEFT") || (FlxG.mouse.wheel > 0);
        if(SaveData.data.get("Touch Controls"))
            left = (Controls.justPressed("UI_LEFT") || virtualPad.buttonLeft.justPressed || (FlxG.mouse.wheel > 0));

        var right:Bool = Controls.justPressed("UI_RIGHT") || (FlxG.mouse.wheel < 0);
        if(SaveData.data.get("Touch Controls"))
            right = (Controls.justPressed("UI_RIGHT") || virtualPad.buttonRight.justPressed || (FlxG.mouse.wheel < 0));

        var back:Bool = Controls.justPressed("BACK") || FlxG.mouse.justPressedRight;
        if(SaveData.data.get("Touch Controls"))
            back = (Controls.justPressed("BACK") || virtualPad.buttonB.justPressed) || FlxG.mouse.justPressedRight;

		var set:Bool = FlxG.keys.pressed.ENTER;
        if(SaveData.data.get("Touch Controls"))
            set = (FlxG.keys.pressed.ENTER || virtualPad.buttonA.justPressed);

		var reset:Bool = FlxG.keys.pressed.SPACE;
        if(SaveData.data.get("Touch Controls"))
            reset = (FlxG.keys.pressed.SPACE || virtualPad.buttonC.justPressed);

        if(left)
			changeItem(-1);
		if(right)
			changeItem(1);

        if(back)
        {
            FlxG.sound.play(Paths.sound('menu/back'));
            Main.switchState(new states.cd.MainMenu());
        }

		if (FlxG.keys.justPressed.R) {
			itemScale = 1;
		}
		
		if (FlxG.keys.pressed.E && itemScale < 3) {
			itemScale += elapsed * itemScale;
			if(itemScale > 3) itemScale = 3;
		}
		if (FlxG.keys.pressed.Q && itemScale > 0.1) {
			itemScale -= elapsed * itemScale;
			if(itemScale < 0.1) itemScale = 0.1;
		}

		if (set)
		{
			SaveData.menuBg = items[curSelected][0];
			SaveData.save();
		}

		if (reset)
		{
			SaveData.menuBg = 'menu/main/bg';
			SaveData.save();
		}

		menuItems.forEach(function(item:FlxSprite)
		{
			if(item.ID == curSelected)
			{
				item.visible = true;

				item.setGraphicSize(Std.int(item.width * itemScale));
			}
			else
			{
				item.visible = false;
			}
		});

		descText.text = items[curSelected][1];
		descTextTwo.text = items[curSelected][2];
	}
	function changeItem(val:Int = 0)
	{
		curSelected += val;
        curSelected = FlxMath.wrap(curSelected, 0, items.length - 1);

        if(val != 0)
            FlxG.sound.play(Paths.sound("menu/scroll"));
	}
}