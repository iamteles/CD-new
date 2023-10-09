package states.cd;

import gameObjects.Character;
import flixel.tweens.misc.ShakeTween;
import data.Discord.DiscordClient;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import data.GameData.MusicBeatState;
import data.SongData;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.effects.FlxFlicker;
import gameObjects.android.FlxVirtualPad;
import data.Highscore;
import data.Highscore.ScoreData;
import states.*;

class Freeplay extends MusicBeatState
{
    var songs:Array<Array<Dynamic>> = [
        ["euphoria", "bella", 0xFFF85E4D],
        ["nefarious", "bex", 0xFF5B7A9E],
        ["divergence", "duo", 0xFF970F00],
        ["allegro", "duo", 0xFF0C2E55],
        ["panic-attack", "bree", 0xFFF85EA4],
        ["convergence", "bree", 0xFFB6318E],
        ["desertion", "bree-angry", 0xFFFF0000],
        ["sin", "helica", 0xFFE17B00],
        ["conservation", "watts", 0xFFFEC404],
        ["irritation", "watts", 0xFFFEC404],
        ["kaboom", "spicy", 0xFFFF006A],
        ["intimidate", "bex-scared", 0xFF0A203B],
        ["heartpounder", "duo", 0xFFF85EA4],
        ["ripple", "drown", 0xFF049AFE],
        ["exotic", "cutenevil", 0xFFFFFFFF],
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
    var selected:Bool = false;

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

            if(!Paths.fileExists('images/menu/freeplay/names/${song}.png'))
                song = "euphoria";
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

            if(charN == "cutenevil" || charN == "duo")
                char.offset.set(50,0);
            else if(charN == "bex" || charN == "bex-scared")
                char.offset.set(-50,0);
            else if(charN == "spicy")
                char.offset.set(100,50);
                
            var text = new FlxSprite().loadGraphic(Paths.image('menu/freeplay/names/${song}'));
            text.ID = i;
            text.y = 40;
            text.x = FlxG.width - text.width - 60;
            text.alpha = 0;
            if(!SaveData.songs.get(songs[i][0]))
                text.color = 0xFF000000;
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
        arrows.x = 11.95;
        arrows.y = 637.2;
		add(arrows);

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

        var back:Bool = Controls.justPressed("BACK");
        if(SaveData.data.get("Touch Controls"))
            back = (Controls.justPressed("BACK") || virtualPad.buttonB.justPressed);

        var accept:Bool = Controls.justPressed("ACCEPT");
        if(SaveData.data.get("Touch Controls"))
            accept = (Controls.justPressed("ACCEPT") || virtualPad.buttonA.justPressed);

        if(up)
            changeSelection(-1);
        if(down)
            changeSelection(1);
        if(left)
			changeDiff(-1);
		if(right)
			changeDiff(1);

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

        if(accept)
        {
            try
            {
                switch(CoolUtil.getDiffs()[curDiff]) {
                    case "mania":
                        var diff = CoolUtil.getDiffs()[curDiff];
                
                        //trace('$diff');
                        //trace('songs/${songList[curSelected][0]}/${songList[curSelected][0]}-${diff}');
                        
                        ManiaPlayState.SONG = SongData.loadFromJson(songs[curSelected][0], diff);
                        
                        Main.switchState(new ManiaPlayState());
                    default:
                        var diff = CoolUtil.getDiffs()[curDiff];
                
                        //trace('$diff');
                        //trace('songs/${songList[curSelected][0]}/${songList[curSelected][0]}-${diff}');
                        
                        PlayState.playList = [];
                        PlayState.SONG = SongData.loadFromJson(songs[curSelected][0], diff);
                        //CoolUtil.playMusic();
                        
                        PlayState.songDiff = diff;
                        
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

        diff.text = '< ' + CoolUtil.getDiffs()[curDiff].toUpperCase() + ' >';
        diff.x = box.x + (box.width/2 - diff.width/2);
        
        updateScoreCount();
    }

    public function updateScoreCount() {
        realValues = Highscore.getScore('${songs[curSelected][0]}-${CoolUtil.getDiffs()[curDiff]}');
		//diffTxt.text = '< ${diff.toUpperCase()} >';
    }
}