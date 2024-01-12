package states.cd;

import data.Discord.DiscordClient;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import data.GameData.MusicBeatState;
import flixel.tweens.FlxTween;
import gameObjects.android.FlxVirtualPad;
import data.GameData.MusicBeatSubState;
import flixel.input.keyboard.FlxKey;

class Credits extends MusicBeatState
{
    var bg:FlxSprite;
    var bubble:FlxSprite;
    var info:FlxText;
    var arrowL:FlxSprite;
    var arrowR:FlxSprite;

    var boxes:FlxTypedGroup<FlxSprite>;
    var icons:FlxTypedGroup<FlxSprite>;
    var names:FlxTypedGroup<FlxText>;
    var jobs:FlxTypedGroup<FlxText>;
    var socials:FlxTypedGroup<FlxText>;

	static var curSelected:Int = 0;
    var list:Array<Array<String>> = [
        ["Coco Puffs", "coco", "@file_corruption", "Artist\nComposer\nCharter", "Eat the brown part of this banana.", "https://twitter.com/file_corruption"],
        ["teles", "starry", "@telesfnf", "Coder\nComposer", "i passed out like 3 times but your cake is ready :3", "https://www.youtube.com/@telesfnf/"],
        ["CharaWhy", "chara", "@CharaWhyy", "Composer\nSFX", "Ill Bree your freakazoid, come on and wind me up", "https://twitter.com/CharaWhyy"],
        ["DiamondDiglett", "diamond", "@DiamonDiglett42", "Charter", "Do you ever just sit back", "https://twitter.com/DiamonDiglett42"],
        ["YaBoiJustin", "justin", "@YaBoiJustinGG", "Composer", "welcome back king of pop <3", "https://twitter.com/YaBoiJustinGG"],
        ["Leebert", "leebert", "@Bruh_Leebert", "Composer", "i'm making dubstep cus i'm depressed", "https://twitter.com/Bruh_Leebert"],
        ["HighPoweredKeyz", "hpk", "@HighPoweredKeyz", "Composer", "Stay kind, stay creative, and stay powerful!", "https://www.youtube.com/@HighPoweredKeyz"],
        ["Jospi", "jospi", "@jospi_music", "Composer", "boo", "https://twitter.com/jospi_music"],
        ["Linguini", "linguini", "@linguini7294", "Animation Helper", "make baby daisy meta again mario kart eight", "https://www.youtube.com/@linguini7294"],
        ["GeefAnon", "dalilah", "N/A", "Art Help", "When the beat drops I'm going to fucking kill myself", "https://www.google.com"],
        ["FiveKimz", "kim", "@FiveKimz", "Charter", "hej", "https://twitter.com/FiveKimz"],
        ["Sandy Can", "sandy-can", "@msparadoxspace", "Voice Acting", "Voices: Spicy", "https://twitter.com/msparadoxspace"],
        ["Special Thanks", "special", "Lots'a people!", "Special Thanks", "Press ACCEPT to read Special Thanks!", "SPECIALTHANKS"],
    ];

    public static var virtualPad:FlxVirtualPad;
    override function create()
    {
        super.create();

        DiscordClient.changePresence("In the Credits Menu...", null);
        CoolUtil.playMusic("credits");

        Main.setMouse(false);

        bg = new FlxSprite().loadGraphic(Paths.image('menu/bios/bio-bg'));
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

        bubble = new FlxSprite().loadGraphic(Paths.image('menu/credits/chat_box'));
        bubble.scale.set(0.67,0.67);
		bubble.updateHitbox();
		bubble.screenCenter();
        bubble.y -= 210;
		add(bubble);

        boxes = new FlxTypedGroup<FlxSprite>();
		add(boxes);
        icons = new FlxTypedGroup<FlxSprite>();
		add(icons);
        names = new FlxTypedGroup<FlxText>();
		add(names);
        socials = new FlxTypedGroup<FlxText>();
		add(socials);
        jobs = new FlxTypedGroup<FlxText>();
		add(jobs);

        for(i in 0...list.length)
        {
            var box = new FlxSprite().loadGraphic(Paths.image('menu/credits/block'));
            box.x = ((FlxG.width/2) - (box.width/2)) + ((curSelected - i)*-897.8);
            box.screenCenter(Y);
            box.y += 80;
            box.ID = i;
            boxes.add(box);

            var iconName = list[i][1];
            if(iconName == "diamond" && FlxG.random.bool(30))
                iconName = "oh-dear-god";

            var icon = new FlxSprite().loadGraphic(Paths.image('menu/credits/icons/' + iconName));
            icon.scale.set(1.7,1.7);
            icon.updateHitbox();
            icon.x = box.x + 40;
            icon.y = box.y + (box.height/2) - (icon.height/2);
            icon.ID = i;
            icons.add(icon);

            var social = new FlxText(0,0,0,list[i][2]);
            social.setFormat(Main.gFont, 33, 0xFFFFFFFF, RIGHT);
            social.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.4);
            social.x = box.x + box.width - social.width - 10;
            social.y = box.y + box.height - social.height - 7;
            social.ID = i;
            socials.add(social);

            var name = new FlxText(0,0,0,list[i][0]);
            name.setFormat(Main.gFont, 49, 0xFFFFFFFF, RIGHT);
            name.setBorderStyle(OUTLINE, FlxColor.BLACK, 2.4);
            name.x = box.x + box.width - name.width - 10;
            name.y = social.y - name.height - 4;
            name.ID = i;
            names.add(name);

            var job = new FlxText(0,0,0,list[i][3]);
            job.setFormat(Main.gFont, 40, 0xFFFFFFFF, RIGHT);
            job.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
            job.x = box.x + box.width - job.width - 10;
            job.y = box.y + 7;
            job.ID = i;
            jobs.add(job);
        }

        info = new FlxText(0,0,0,"Loading...");
		info.setFormat(Main.gFont, 38, 0xFFFFFFFF, CENTER);
		info.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
        info.y = bubble.y + (bubble.height/2) - (info.height/2);
        add(info);

        arrowL = new FlxSprite().loadGraphic(Paths.image('menu/arrow'));
        arrowR = new FlxSprite().loadGraphic(Paths.image('menu/arrow'));

        arrowL.flipX = true;
        arrowR.flipX = false;

        arrowL.updateHitbox();
		arrowL.screenCenter();
		arrowR.updateHitbox();
		arrowR.screenCenter();

        arrowL.x -= 411.35;
        arrowR.x += 411.35;
        arrowL.y += 80;
        arrowR.y += 80;

        arrowL.alpha = 0.7;
        arrowR.alpha = 0.7;

        add(arrowL);
		add(arrowR);

        if(SaveData.data.get("Touch Controls")) {
            virtualPad = new FlxVirtualPad(LEFT_RIGHT, A_B);
            add(virtualPad);
        }

        changeSelection(0);
    }

    var keysBuffer:String = "";
    var easterEggKeys:Array<String> = [
		'AZURE'
	];
	var allowedKeys:String = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (FlxG.keys.firstJustPressed() != FlxKey.NONE)
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
                        switch (word) {
                            case "AZURE":
                                SaveData.progression.set("debug", true);
                                SaveData.save();
                                Main.switchState(new states.DebugState());
                        }
                        keysBuffer = '';
                    }
                }
            }
        }

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

        var back:Bool = Controls.justPressed("BACK") || FlxG.mouse.justPressedRight;
        if(SaveData.data.get("Touch Controls"))
            back = (Controls.justPressed("BACK") || virtualPad.buttonB.justPressed) || FlxG.mouse.justPressedRight;

        if(back)
        {
            FlxG.sound.play(Paths.sound('menu/back'));
            Main.switchState(new states.cd.MainMenu());
        }

        if(accept && focused) {
            switch(list[curSelected][5])
            {
                case "SPECIALTHANKS":
                    openSubState(new SpecialThanks());
                default:
                    FlxG.openURL(list[curSelected][5]);
            }
        }

		if(left)
			changeSelection(-1);
		if(right)
			changeSelection(1);

        if(Controls.pressed("UI_LEFT"))
            arrowL.alpha = 1;
        else
            arrowL.alpha = 0.7;
        if(Controls.pressed("UI_RIGHT"))
            arrowR.alpha = 1;
        else
            arrowR.alpha = 0.7;

        for(box in boxes.members)
        {
            box.x = FlxMath.lerp(box.x, ((FlxG.width/2) - (box.width/2)) + ((curSelected - box.ID)*-897.8), elapsed*6);
            if(box.ID == curSelected)
                box.alpha = FlxMath.lerp(box.alpha, 1, elapsed*12);
            else
                box.alpha = FlxMath.lerp(box.alpha, 0.5, elapsed*12);

            for(icon in icons.members) {
                if(icon.ID == box.ID)
                    icon.x = box.x + 70;
            }

            for (social in socials.members) {
                if(social.ID == box.ID)
                    social.x = box.x + box.width - social.width - 10;
            }
        
            for(name in names.members) {
                if(name.ID == box.ID)
                    name.x = box.x + box.width - name.width - 10;
            }

            for(job in jobs.members) {
                if(job.ID == box.ID)
                    job.x = box.x + box.width - job.width - 10;
            }
        }
    }

    public function changeSelection(change:Int = 0)
    {
        //if(selected) return; //do yes
        curSelected += change;
        curSelected = FlxMath.wrap(curSelected, 0, list.length - 1);
        if(change != 0)
            FlxG.sound.play(Paths.sound("menu/scroll"));

        info.text = list[curSelected][4];
        info.y = bubble.y + (bubble.height/2) - (info.height/2) - 8;
        info.screenCenter(X);
    }
}

class SpecialThanks extends MusicBeatSubState
{
	public function new()
    {
        super();

        var banana = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		add(banana);

        var popUpTxt = new FlxText(0,0,0,"> Special Thanks <\n\nDiogoTV - Creator of Doido Engine\n\nPlaytesters\nBepixel, Kal, DiogoTV, Leozito\n\nTeam Shatterdisk\nParallax, Whisper, Shaya, Astro\n\nDusterBuster and the rest of Team TBD\nTurtle Pals Tapes\nThe Funkin Crew\n\nGuest Cameos\nAntonyR, YairLK7, LukasP, The Neko No Ni Dansu Team, Top 10 Portugal\n\nYou and everyone who supported us through the development!");
		popUpTxt.setFormat(Main.gFont, 37, 0xFFFFFFFF, CENTER);
		popUpTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 2.5);
		popUpTxt.screenCenter();
		add(popUpTxt);

        FlxTween.tween(banana, {alpha: 0.8}, 0.1);
        FlxTween.tween(popUpTxt, {alpha: 1}, 0.1);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if(Controls.justPressed("BACK"))
        {
            FlxG.sound.play(Paths.sound('menu/back'));
            //StoryMode.sliderActive = -1;
            close();
        }
    }
}