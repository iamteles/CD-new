package states.cd.fault;

import data.Discord.DiscordClient;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import data.GameData.MusicBeatState;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.effects.FlxFlicker;
import flixel.input.keyboard.FlxKey;
import gameObjects.android.FlxVirtualPad;

class MainMenu extends MusicBeatState
{
	var list:Array<String> = ["freeplay", "options"];
    var hints:Array<String> = [
        "your fault", 
        "your fault"
    ];
	static var curSelected:Int = 0;

	var buttons:FlxTypedGroup<FlxSprite>;
    var texts:FlxTypedGroup<FlxSprite>;

    var bg:FlxSprite;
    var arrowL:FlxSprite;
    var arrowR:FlxSprite;
    var info:FlxText;
    var bar:FlxSprite;

    public static var virtualPad:FlxVirtualPad;

	override function create()
	{
        super.create();

        DiscordClient.changePresence("your fault.", null);
        CoolUtil.playMusic("fault");

        Main.setMouse(false);

        bg = new FlxSprite().loadGraphic(Paths.image('menu/main/bg'));
		bg.updateHitbox();
		bg.screenCenter();
        bg.alpha = 0.6;
		add(bg);

        buttons = new FlxTypedGroup<FlxSprite>();
		add(buttons);

        texts = new FlxTypedGroup<FlxSprite>();
		add(texts);

        for(i in 0...list.length)
        {
            var name = list[i];
            var index = i;
            if(!returnMenu(i)) {
                name = "box";
                index = 999;
            }

            var button = new FlxSprite();
			button.frames = Paths.getSparrowAtlas('menu/main/buttons');
			button.animation.addByPrefix('idle',  name + '0', 24, true);
			button.animation.play('idle');
            button.ID = i;

            var text = new FlxSprite();
			text.frames = Paths.getSparrowAtlas('menu/main/texts');
			text.animation.addByPrefix('idle',  list[i] + ' graphic', 24, true);
			text.animation.play('idle');
            text.ID = index;
            text.flipY = true;

            button.x = ((FlxG.width/2) - (button.width/2)) + ((curSelected - i)*-397.8);
            button.y = 379.75;

            text.updateHitbox();
            text.screenCenter(X);
            text.y = 47;

            if(i == curSelected) {
                text.alpha = 1;
                button.alpha = 1;
            }
            else {
                text.alpha = 0;
                button.alpha = 0.5;
            }

			buttons.add(button);
            texts.add(text);
        }

        arrowL = new FlxSprite().loadGraphic(Paths.image('menu/arrow'));
        arrowR = new FlxSprite().loadGraphic(Paths.image('menu/arrow'));

        arrowL.flipX = true;
        arrowR.flipX = false;

        arrowL.updateHitbox();
		arrowL.screenCenter(X);
		arrowR.updateHitbox();
		arrowR.screenCenter(X);

        arrowL.x -= 211.35;
        arrowL.y = 452.25;
        arrowR.x += 211.35;
        arrowR.y = 452.25;

        arrowL.alpha = 0.7;
        arrowR.alpha = 0.7;

        add(arrowL);
		add(arrowR);

        info = new FlxText(0,0,0,"Loading...");
		info.setFormat(Main.dsFont, 30, 0xFFFFFFFF, CENTER);
		info.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
        info.y = FlxG.height - info.height - 5;

        bar = new FlxSprite().makeGraphic(FlxG.width, Std.int(info.height) + 10, 0xFF000000);
		bar.y = FlxG.height - bar.height;
		add(bar);
        add(info);

        changeSelection();

        if(SaveData.data.get("Touch Controls")) {
            virtualPad = new FlxVirtualPad(LEFT_RIGHT, A_B);
            add(virtualPad);
        }

        var vg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('vignette')); //like the???
		vg.updateHitbox();
		vg.screenCenter();
        vg.alpha = 0.8;
		add(vg);
    }

    var shaking:Bool = false;
    var selected:Bool = false;
    override function update(elapsed:Float)
    {
        super.update(elapsed);

        //info.text = CoolUtil.posToTimer(SaveData.curTime());

        var left:Bool = Controls.justPressed("UI_LEFT") || (FlxG.mouse.wheel > 0);
        if(SaveData.data.get("Touch Controls"))
            left = (Controls.justPressed("UI_LEFT") || virtualPad.buttonLeft.justPressed || (FlxG.mouse.wheel > 0));

        var right:Bool = Controls.justPressed("UI_RIGHT") || (FlxG.mouse.wheel < 0);
        if(SaveData.data.get("Touch Controls"))
            right = (Controls.justPressed("UI_RIGHT") || virtualPad.buttonRight.justPressed || (FlxG.mouse.wheel < 0));

        #if mobile
        var accept:Bool = Controls.justPressed("ACCEPT");
        if(SaveData.data.get("Touch Controls"))
            accept = (Controls.justPressed("ACCEPT") || virtualPad.buttonA.justPressed);
        #else
        var accept:Bool = Controls.justPressed("ACCEPT") || FlxG.mouse.justPressed;
        if(SaveData.data.get("Touch Controls"))
            accept = (Controls.justPressed("ACCEPT") || virtualPad.buttonA.justPressed || FlxG.mouse.justPressed);
        #end

        var back:Bool = false;
        //if(SaveData.data.get("Touch Controls"))
        //    back = (Controls.justPressed("BACK") || virtualPad.buttonB.justPressed);

        if(back)
        {
            FlxG.sound.play(Paths.sound('menu/back'));
            Main.switchState(new states.cd.TitleScreen());
        }

		if(left)
			changeSelection(-1);
		if(right)
			changeSelection(1);

        if(Controls.pressed("UI_LEFT") && !selected)
            arrowL.alpha = 1;
        else if(!selected)
            arrowL.alpha = 0.7;
        if(Controls.pressed("UI_RIGHT") && !selected)
            arrowR.alpha = 1;
        else if(!selected)
            arrowR.alpha = 0.7;

        if(accept && !selected && focused)
        {
            if(returnMenu(curSelected)) {
                selected = true;
                FlxTween.tween(arrowL, {alpha: 0}, 0.4, {ease: FlxEase.cubeOut});
                FlxTween.tween(arrowR, {alpha: 0}, 0.4, {ease: FlxEase.cubeOut});
                FlxG.sound.play(Paths.sound("menu/select"));
                for(item in buttons.members)
                {
                    if(item.ID != curSelected)
                        FlxTween.tween(item, {alpha: 0}, 0.4, {ease: FlxEase.cubeOut});
                    else {
                        FlxFlicker.flicker(item, 1, 0.06, true, false, function(_)
                        {             
                            switch(list[curSelected])
                            {
                                case "story mode":
                                    Main.switchState(new states.cd.StoryMode());
                                case "menu":
                                    Main.switchState(new states.cd.MainMenu());
                                case "freeplay":
                                    Main.switchState(new states.cd.fault.Freeplay());
                                case "gallery":
                                    Main.switchState(new states.cd.Gallery());
                                case "shop":
                                    Main.switchState(new states.ShopState.LoadShopState());
                                case "music":
                                    Main.switchState(new states.cd.MusicPlayer());
                                case "options":
                                    Main.switchState(new states.menu.OptionsState(new states.cd.fault.MainMenu()));
                                default:
                                    Main.switchState(new states.DebugState());
                            }
                        });
                    }
                }
            }
            else {
                shaking = true;
                FlxG.sound.play(Paths.sound("menu/locked"));
                new FlxTimer().start(0.1, function(tmr:FlxTimer)
                {
                    shaking = false;
                    for(item in buttons.members)
                    {
                        if(item.ID == curSelected)
                            item.offset.set(0,0);
                    }
                });
            }
        }

        for(item in buttons.members)
        {
            if(!selected || item.ID == curSelected) item.x = FlxMath.lerp(item.x, ((FlxG.width/2) - (item.width/2)) + ((curSelected - item.ID)*-397.8), elapsed*6);

            if(item.ID == curSelected) {
                if (shaking)
                    item.offset.x = FlxG.random.float(-0.05 * item.width, 0.05 * item.width);
                if (shaking)
                    item.offset.y = FlxG.random.float(-0.05 * item.height, 0.05 * item.height);
                item.alpha = FlxMath.lerp(item.alpha, 1, elapsed*12);
            }
            else
                if(!selected) item.alpha = FlxMath.lerp(item.alpha, 0.5, elapsed*12);
        }

        for(item in texts.members)
        {
            item.y = FlxMath.lerp(item.y, 47, elapsed*6);
            if(item.ID == curSelected)
                item.alpha = 1;
            else
                item.alpha = 0;
        }

        //YLYL EASTER EGG
        if (FlxG.keys.firstJustPressed() != FlxKey.NONE && !selected)
		{
            var keyPressed:FlxKey = FlxG.keys.firstJustPressed();
            var keyName:String = Std.string(keyPressed);
            if(allowedKeys.contains(keyName)) {
                keysBuffer += keyName;
                if(keysBuffer.length >= 32) keysBuffer = keysBuffer.substring(1);
                for (wordRaw in easterEggKeys)
				{
                    var word:String = wordRaw.toUpperCase();
                    if (keysBuffer.contains(word))
					{
                        FlxG.sound.play(Paths.sound('secret/$word'));
                        switch (word) {
                            case "WEDNESDAY":
                                SaveData.buyItem("ylyl");
                        }
                        keysBuffer = '';
                    }
                }
            }
        }
    }

    var keysBuffer:String = "";
    var easterEggKeys:Array<String> = [
		'WEDNESDAY'
	];
	var allowedKeys:String = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

    public function changeSelection(change:Int = 0)
    {
        if(selected) return; //do not
        curSelected += change;
        curSelected = FlxMath.wrap(curSelected, 0, list.length - 1);
        if(change != 0)
            FlxG.sound.play(Paths.sound("menu/scroll"));

        for(item in texts.members)
        {
            item.y = 20;
        }

        if(!SaveData.progression.get("week2") && !returnMenu(curSelected))
            info.text = "Complete both weeks first!";
        else if(returnMenu(curSelected))
            info.text = hints[curSelected];
        else
            info.text = "Unlock this by buying something from Watts' Store!";
        info.screenCenter(X);
    }

    var unlockables:Array<String> = ["music", "gallery"];
    function returnMenu(num:Int):Bool
    {
        if(unlockables.contains(list[num]))
            return SaveData.shop.get(list[num]);
        else if(list[num] == "shop") {
            if(SaveData.progression.get("week2") == null)
                return false;
            else
                return SaveData.progression.get("week2");
        }
        else
            return true;
    }
}