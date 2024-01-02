package states.cd;

import data.Discord.DiscordClient;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import data.GameData.MusicBeatState;
import data.SongData;
import flixel.tweens.FlxTween;
import gameObjects.android.FlxVirtualPad;
import data.Highscore;
import data.Highscore.ScoreData;
import data.GameData.MusicBeatSubState;
import states.*;

class Freeplay extends MusicBeatState
{
    var songs:Array<Array<Dynamic>> = [
        // default
        ["euphoria", "bella", 0xFFF85E4D],
        ["nefarious", "bex", 0xFF5B7A9E],
        ["divergence", "duo", 0xFF970F00],
    ];
    static var curSelected:Int = 0;
    static var curDiff:Int = 0;

    var texts:FlxTypedGroup<FlxSprite>;
    var characters:FlxTypedGroup<FlxSprite>;

    var bg:FlxSprite;
    var waves:FlxSprite; //like the????????????
    var box:FlxSprite;
    var arrows:FlxSprite;
    var shaking:Bool = false;
    public static var selected:Bool = false;

    var fr:FlxSprite;
    var shack:FlxSprite;

    var bgTween:FlxTween;

    public var realValues:ScoreData;
	public var lerpValues:ScoreData;
    var scores:FlxText;
    var diff:FlxText;
    override function create()
    {
        super.create();

        DiscordClient.changePresence("In the Freeplay Menu", null);
        CoolUtil.playMusic("movement");

        selected = false;

        if(SaveData.progression.get("week2")) {
            songs.push(["allegro", "duo", 0xFF0C2E55]);
            songs.push(["panic-attack", "bree", 0xFFF85EA4]);
            songs.push(["convergence", "bree", 0xFFB6318E]);
            songs.push(["desertion", "bree-angry", 0xFFFF0000]);
        }

        if(SaveData.progression.get("intimidated")) {
            songs.push(["sin", "helica", 0xFFE17B00]);
            songs.push(["intimidate", "bex-scared", 0xFF0A203B]);
        }

        if(SaveData.shop.get("mic")) {
            songs.push(["conservation", "watts", 0xFFFEC404]);
            songs.push(["irritation", "watts", 0xFFFEC404]);
        }

        if(SaveData.progression.get("vip")) {
            songs.push(["euphoria-vip", "bellavip", 0xFFFFCB1F]);
            songs.push(["nefarious-vip", "bexvip", 0xFFFFCB1F]);
            songs.push(["divergence-vip", "duovip", 0xFFFFCB1F]);
        }

        if(SaveData.shop.get("ticket")) {
            songs.push(["kaboom", "spicy-v2", 0xFFFF006A]);
        }

        if(SaveData.shop.get("shack")) {
            songs.push(["ripple", "drown", 0xFF049AFE]);
            songs.push(["customer-service", "empitri", 0xFFfdacbc]);
        }

        if(SaveData.progression.get("week2")) {
            songs.push(["heartpounder", "duo", 0xFFF85EA4]);
        }

        if(SaveData.progression.get("vip")) {
            songs.push(["exotic", "cutenevil", 0xFFFFFFFF]);
        }

        bg = new FlxSprite().loadGraphic(Paths.image('menu/freeplay/desat'));
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

        waves = new FlxSprite().loadGraphic(Paths.image('menu/freeplay/waves'));
		waves.updateHitbox();
		waves.screenCenter();
		add(waves);

        characters = new FlxTypedGroup<FlxSprite>();
		add(characters);

        texts = new FlxTypedGroup<FlxSprite>();
		add(texts);

        for(i in 0...songs.length)
        {
            var song:String = songs[i][0];
            var charN:String = songs[i][1];

            if(!Paths.fileExists('images/menu/freeplay/names/${song}.png') || !SaveData.songs.get(songs[i][0]))
                song = "nan";
            if(!Paths.fileExists('images/menu/freeplay/characters/${charN}.png'))
                charN = "bella";

            var char = new FlxSprite().loadGraphic(Paths.image('menu/freeplay/characters/${charN}'));
            char.ID = i;
            char.x = 30;
            char.y = 0;
            char.alpha = 0;
            if(!SaveData.songs.get(songs[i][0]))
                char.color = 0xFF000000;
            characters.add(char);

            if(charN == "cutenevil" || charN == "duo" || charN == "bellavip" || charN == "duovip")
                char.offset.set(50,0);
            else if(charN == "bex" || charN == "bex-scared")
                char.offset.set(-50,0);
            else if(charN == "spicy-v2")
                char.offset.set(100,100);
            else if(charN == "empitri")
                char.offset.set(50,50);
                
            var text = new FlxSprite().loadGraphic(Paths.image('menu/freeplay/names/${song}'));
            text.ID = i;
            text.y = 40;
            text.x = FlxG.width - text.width - 60;
            text.alpha = 0;
            texts.add(text);
        }

        box = new FlxSprite().loadGraphic(Paths.image('menu/freeplay/box'));
        box.x = 825.6;
        box.y = 333.9;
		add(box);

        scores = new FlxText(0, 0, 0, "");
		scores.setFormat(Main.gFont, 45, 0xFFFFFFFF, CENTER);
        scores.x = box.x + (box.width/2 - scores.width/2);
        scores.y = box.y + 64;
		add(scores);

        diff = new FlxText(0, 0, 0, "< FODASE >");
		diff.setFormat(Main.gFont, 55, 0xFFFFFFFF, CENTER);
        diff.x = box.x + (box.width/2 - diff.width/2);
        diff.y = scores.y + 168;
		add(diff);

        realValues = {score: 0, accuracy: 0, misses: 0};
		lerpValues = {score: 0, accuracy: 0, misses: 0};

        arrows = new FlxSprite().loadGraphic(Paths.image('menu/freeplay/arrows'));
        arrows.angle = 90;
        arrows.updateHitbox();
        arrows.x = 20;
        arrows.y = FlxG.height - arrows.height + 8;
		add(arrows);

        fr = new FlxSprite().loadGraphic(Paths.image('menu/freeplay/fr_collab'));
        fr.scale.set(0.66, 0.66);
        fr.updateHitbox();
		add(fr);

        shack = new FlxSprite().loadGraphic(Paths.image('menu/freeplay/fs_collab'));
        shack.scale.set(0.66, 0.66);
        shack.updateHitbox();
		add(shack);

        if(SaveData.data.get("Touch Controls")) {
            virtualPad = new FlxVirtualPad(LEFT_FULL, A_B);
            add(virtualPad);
        }

        changeSelection();
        changeDiff();
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
        //if(left)
		//	changeDiff(-1);
		//if(right)
		//	changeDiff(1);

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
                if(!selected) item.alpha = FlxMath.lerp(item.alpha, 0, elapsed*12);
        }

        for(item in texts.members)
        {
            item.y = FlxMath.lerp(item.y, 8, elapsed*6);
            if(item.ID == curSelected)
                item.alpha = 1;
            else
                item.alpha = 0;
        }

        if(accept && focused)
        {
            try
            {
                selected = true;
                switch(CoolUtil.getDiffs()[curDiff]) {
                    default:
                        var diff = CoolUtil.getDiffs()[curDiff];
                
                        ////trace('$diff');
                        ////trace('songs/${songList[curSelected][0]}/${songList[curSelected][0]}-${diff}');
                        
                        PlayState.playList = [];
                        PlayState.SONG = SongData.loadFromJson(songs[curSelected][0], diff);
                        PlayState.isStoryMode = false;
                        //CoolUtil.playMusic();
                        
                        PlayState.songDiff = diff;
                        
                        if(songs[curSelected][0] == "kaboom")
                            openSubState(new CharacterSelect());
                        else
                            Main.switchState(new LoadSongState());
                }

            }
            catch(e)
            {
                FlxG.sound.play(Paths.sound('menu/back'));
            }
        }

        scores.text = "";

		scores.text +=   "SCORE: " + Math.floor(lerpValues.score);
		scores.text += "\nACCURACY:  " +(Math.floor(lerpValues.accuracy * 100) / 100) + "%";
		scores.text += "\nBREAKS:    " + Math.floor(lerpValues.misses);

		lerpValues.score 	= FlxMath.lerp(lerpValues.score, 	realValues.score, 	 elapsed * 8);
		lerpValues.accuracy = FlxMath.lerp(lerpValues.accuracy, realValues.accuracy, elapsed * 8);
		lerpValues.misses 	= FlxMath.lerp(lerpValues.misses, 	realValues.misses, 	 elapsed * 8);

		if(Math.abs(lerpValues.score - realValues.score) <= 10)
			lerpValues.score = realValues.score;
		if(Math.abs(lerpValues.accuracy - realValues.accuracy) <= 0.4)
			lerpValues.accuracy = realValues.accuracy;
		if(Math.abs(lerpValues.misses - realValues.misses) <= 0.4)
			lerpValues.misses = realValues.misses;

        scores.x = box.x + (box.width/2 - scores.width/2);
        scores.y = box.y + 64;

        if(songs[curSelected][0] == "kaboom")
            fr.alpha = 1;
        else
            fr.alpha = 0;

        if(songs[curSelected][0] == "ripple" || songs[curSelected][0] == "customer-service")
            shack.alpha = 1;
        else
            shack.alpha = 0;
    }

    public function changeSelection(change:Int = 0)
    {
        if(selected) return; //do not
        curSelected += change;
        curSelected = FlxMath.wrap(curSelected, 0, characters.length - 1);
        if(change != 0)
            FlxG.sound.play(Paths.sound("menu/scroll"));

        for(item in texts.members)
        {
            item.y -= 20;
        }

        if(bgTween != null) bgTween.cancel();
		bgTween = FlxTween.color(bg, 0.4, bg.color, songs[curSelected][2]);

        updateScoreCount();
    }

    public function changeDiff(change:Int = 0)
    {
        curDiff += change;
        curDiff = FlxMath.wrap(curDiff, 0, CoolUtil.getDiffs().length - 1);

        diff.text = CoolUtil.getDiffs()[curDiff].toUpperCase();
        diff.x = box.x + (box.width/2 - diff.width/2);
        
        updateScoreCount();
    }

    public function updateScoreCount() {
        realValues = Highscore.getScore('${songs[curSelected][0]}-${CoolUtil.getDiffs()[curDiff]}');
		//diffTxt.text = '< ${diff.toUpperCase()} >';
    }
}

class CharacterSelect extends MusicBeatSubState
{
    var spicy:FlxSprite;
    var bree:FlxSprite;
	public function new()
    {
        super();

        var banana = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		add(banana);

		banana.alpha = 0;

        var select:FlxSprite = new FlxSprite(408.15, 28.4).loadGraphic(Paths.image('menu/freeplay/select/select'));
        select.scale.set(0.9,0.9);
        select.updateHitbox();
        select.screenCenter(X);
		add(select);

        spicy = new FlxSprite(18.3, 240.85).loadGraphic(Paths.image('menu/freeplay/select/spicy'));
        spicy.scale.set(0.9,0.9);
        spicy.updateHitbox();
		add(spicy);

        bree = new FlxSprite(670.75, 261.1).loadGraphic(Paths.image('menu/freeplay/select/bree'));
        bree.scale.set(0.9,0.9);
        bree.updateHitbox();
		add(bree);
        
		FlxTween.tween(banana, {alpha: 0.4}, 0.1);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if(Controls.justPressed("BACK") || FlxG.mouse.justPressedRight)
        {
            FlxG.sound.play(Paths.sound('menu/back'));
            Freeplay.selected = false;
            close();
        }

        for(button in [spicy, bree]) {
            if(CoolUtil.mouseOverlap(button, FlxG.camera)) {
                button.scale.x = FlxMath.lerp(button.scale.x, 1, elapsed*6);
                button.scale.y = FlxMath.lerp(button.scale.y, 1, elapsed*6);
                if(FlxG.mouse.justPressed) {
                    FlxG.sound.play(Paths.sound("menu/select"));

                    PlayState.invertedCharacters = (button == spicy);
                    Main.switchState(new LoadSongState());
                    //sliderActive = true;
                    //openSubState(new SliderL());
                }
                    //enterWeek(weekData[item.ID][0], weekData[item.ID][1]);
            }
            else {
                button.scale.x = FlxMath.lerp(button.scale.x, 0.9, elapsed*6);
                button.scale.y = FlxMath.lerp(button.scale.y, 0.9, elapsed*6);
            }
        }
    }
}