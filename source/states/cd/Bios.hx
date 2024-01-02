package states.cd;

import data.Discord.DiscordClient;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import data.GameData.MusicBeatState;
import gameObjects.android.FlxVirtualPad;

class Bios extends MusicBeatState
{
    var songs:Array<Array<Dynamic>> = [
        ["bella", "Bella Wright", "20", "Female", "5'10", "The bubbly, loveable, huggable bundle of sweets hailing from New Jersey. Bella loves to interact and make friends with others. She is a lesbian, which helped her find her current forever girlfriend, Bex. She is incredibly loyal to Bex and wouldn’t trade her for the world. Her favorite pastime is drawing. She has whole sketchbooks filled with art, though most of it is of her beloved."],
        ["bex", "Bex Parker", "20", "Female", "5'9", "The shy, emo, rock and roll ready gal from New Jersey. Bex is more shy and introverted compared to her girlfriend Bella. However, she loves her to death, and will go to the ends of the earth for her. Bex likes to play guitar, and even has a gig and the bar she works at. She likes to smoke, as it helps her release a lot of stress from her anxiety."],
        ["bree", "Bree", "21", "Female", "5'11", "The daughter of Zeus herself, Bree lives in the Pantheon, a moving pack of islands about the clouds where the gods reside. Bree was demoted from her status of higher god and moved to the lowest class, where she works to get her position back. From birth, she was given the title of “god of balance” and she adopted this rule by killing anyone she deemed as a “balance ruiner” because of her twisted perception of Earth."],
        ["watts", "Watts", "21", "Female", "5'11", "Real name is Kecia Johnson, but everyone calls her Watts. The shopkeeper with a motherly attitude. Watts runs her store “Johnson’s” on her own with support from her family. She aspires to be a mother and treats other people, especially her friends, as she is theirs. She loves to give to her community and help those in need. However she does have anger issues..and a gun under desk. Don’t get on her bad side now!"],
        ["helica", "Helica", "22", "Female", "6'0", "The guardian angel for all. Helica is a high class god hailing from the Pantheon. She teaches other gods in the status below her how to use their powers, in preparation to help look after after earth one day. One of her students is Bree. The 2 hate each other, and Helica always ends up cleaning after her. Stopping Bree’s rein of terror is one of her ultimate goals and she will stop at nothing to get it done."],
        ["drown", "Drown", "18", "Female", "5'1", "Naomi Liu, nickname Drown, is college dropout roaming the streets of Maryland. She is desperate for attention and will do anything for it. Surprisingly, she doesn’t have a lot of friends. She can be really shy when you first meet her, but once you get to know her she is a whole different demon. Her favorite place to spend time, to the dismay of the employees, is a music store called “The Shack”."],
        ["wave", "Wave", "17", "Female", "5'8", "Wave, short for Waverly Baker. The bully with a penchant for pranks. Wave loves to pick fights with everyone and everyone thing. She is a rowdy teen who doesn’t really know what she wants to do with her life. She works at a music store called “The Shack” since her parents wanted her to go outside and do literary anything else but sit at home. She has a crush on her coworker Empitri, but is too chicken to tell her."],
        ["empitri", "Empitri Palmer", "21", "Female", "6'4", "The chronically online cashier. Empitri is an employee at a music store called “The Shack”. She likes to play on her phone, talk on her phone, and watch her phone (I’m noticing a trend here). While it may look like she’s never paying attention she actually listens and will respect you. She quite enjoys her job and her life and is a really good friend. Break that trust though, and you’ll never see the end of her."],
        ["spicy-v2", "Spicy", "???", "Female", "???", "Woah! Looks like we don’t have much data on this character… They must be from some other universe…"],
        ["cutenevil", "Cute n' Evil", "???", "Females", "???", "An alternate retro reality of Bella and Bex… Mysterious…"]
    ];
    static var curSelected:Int = 0;

    var characters:FlxTypedGroup<FlxSprite>;

    var bg:FlxSprite;
    var box:FlxSprite;
    var arrows:FlxSprite;

    var name:FlxText;
    var desc:FlxText;
    override function create()
    {
        super.create();

        DiscordClient.changePresence("In the Bios Menu", null);
        CoolUtil.playMusic("LoveLetter");

        bg = new FlxSprite().loadGraphic(Paths.image('menu/bios/bio-bg'));
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

        characters = new FlxTypedGroup<FlxSprite>();
		add(characters);

        for(i in 0...songs.length)
        {
            var charN:String = songs[i][0];

            if(!Paths.fileExists('images/menu/freeplay/characters/${charN}.png'))
                charN = "bella";

            var char = new FlxSprite().loadGraphic(Paths.image('menu/freeplay/characters/${charN}'));
            char.ID = i;
            char.x = 30;
            char.y = 0;
            char.alpha = 0;
            characters.add(char);

            if(charN == "cutenevil" || charN == "duo")
                char.offset.set(100,0);
            else if(charN == "bex" || charN == "bex-scared")
                char.offset.set(-50,0);
            else if(charN == "spicy-v2")
                char.offset.set(100,100);
            else if(charN == "empitri")
                char.offset.set(50,50);
        }

        box = new FlxSprite().loadGraphic(Paths.image('menu/bios/bio-box'));
        box.screenCenter(Y);
        box.x = FlxG.width - box.width - 30;
		add(box);

        arrows = new FlxSprite().loadGraphic(Paths.image('menu/freeplay/arrows'));
        arrows.angle = 90;
        arrows.updateHitbox();
        arrows.x = 20;
        arrows.y = FlxG.height - arrows.height + 8;
		add(arrows);

        name = new FlxText(0,0,0,"Name");
		name.setFormat(Main.dsFont, 90, 0xFFFFFFFF, CENTER);
		name.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
        name.x = box.x + 18;
        name.y = box.y + 18;
        add(name);

        desc = new FlxText(0,0,box.width-(18*2),"Desc");
		desc.setFormat(Main.dsFont, 44, 0xFFFFFFFF, LEFT);
		desc.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
        desc.x = box.x + 18;
        desc.y = name.y + name.height;
        add(desc);

        if(SaveData.data.get("Touch Controls")) {
            virtualPad = new FlxVirtualPad(LEFT_FULL, A_B);
            add(virtualPad);
        }

        changeSelection();
    }
    var virtualPad:FlxVirtualPad;
    override function update(elapsed:Float)
    {
        super.update(elapsed);

        var left:Bool = Controls.justPressed("UI_LEFT") || (FlxG.mouse.wheel > 0);
        if(SaveData.data.get("Touch Controls"))
            left = (Controls.justPressed("UI_LEFT") || virtualPad.buttonLeft.justPressed || (FlxG.mouse.wheel > 0));

        var right:Bool = Controls.justPressed("UI_RIGHT") || (FlxG.mouse.wheel < 0);
        if(SaveData.data.get("Touch Controls"))
            right = (Controls.justPressed("UI_RIGHT") || virtualPad.buttonRight.justPressed || (FlxG.mouse.wheel < 0));

        var accept:Bool = Controls.justPressed("ACCEPT") || FlxG.mouse.justPressed;
        if(SaveData.data.get("Touch Controls"))
            accept = (Controls.justPressed("ACCEPT") || virtualPad.buttonA.justPressed || FlxG.mouse.justPressed);

        var back:Bool = Controls.justPressed("BACK") || FlxG.mouse.justPressedRight;
        if(SaveData.data.get("Touch Controls"))
            back = (Controls.justPressed("BACK") || virtualPad.buttonB.justPressed) || FlxG.mouse.justPressedRight;

        if(left)
            changeSelection(-1);
        if(right)
            changeSelection(1);

        if(back)
        {
            FlxG.sound.play(Paths.sound('menu/back'));
            Main.switchState(new states.cd.MainMenu());
        }

        for(item in characters.members)
        {
            item.x = FlxMath.lerp(item.x, 30 + ((curSelected - item.ID)*-300), elapsed*6);

            if(item.ID == curSelected) {
                item.alpha = FlxMath.lerp(item.alpha, 1, elapsed*12);
            }
            else
                item.alpha = FlxMath.lerp(item.alpha, 0, elapsed*12);
        }
    }

    final separator:String = "\n";

    public function changeSelection(change:Int = 0)
    {
        curSelected += change;
        curSelected = FlxMath.wrap(curSelected, 0, characters.length - 1);
        if(change != 0)
            FlxG.sound.play(Paths.sound("menu/scroll"));

        name.text = songs[curSelected][1];

        desc.text = "";
        desc.text += "Age: " + songs[curSelected][2] + separator;
        desc.text += "Gender: " + songs[curSelected][3] + separator;
        desc.text += "Height: " + songs[curSelected][4] + separator;
        desc.text += songs[curSelected][5] + separator;
    }
}