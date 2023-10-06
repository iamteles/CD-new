package states.cd;

import data.GameData.MusicBeatSubState;
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
import flixel.input.keyboard.FlxKey;
import gameObjects.hud.CDButton;

class StoryMode extends MusicBeatState
{
    var bg:FlxSprite;
    var week1:FlxSprite;
    var week2:FlxSprite;

    var weeks:FlxTypedGroup<FlxSprite>;
    public static var weekData:Array<Array<Dynamic>> = [
        [["euphoria", "nefarious", "divergence"], "week1"],
        [["allegro", "panic-attack", "convergence", "desertion"], "week2"]
    ];
    public static var sliderActive:Int = -1; // -1 = none, 0 = w1, 1 = w2
    override function create()
    {
        super.create();

        sliderActive = -1;

        bg = new FlxSprite().loadGraphic(Paths.image('menu/story/bg'));
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

        weeks = new FlxTypedGroup<FlxSprite>();
		add(weeks);

        week1 = new FlxSprite().loadGraphic(Paths.image('menu/story/week1'));
        week1.scale.set(0.8,0.8);
        week1.updateHitbox();
        week1.ID = 0;
        weeks.add(week1);

        week2 = new FlxSprite().loadGraphic(Paths.image('menu/story/week2'));
        week2.scale.set(0.8,0.8);
        week2.updateHitbox();
        week2.ID = 1;
        weeks.add(week2);

        //enterWeek(["euphoria", "nefarious", "divergence"], "week1");
    }
    override function update(elapsed:Float)
    {
        super.update(elapsed);

        for(item in weeks) {
            if(sliderActive >= 0) {
                item.scale.x = FlxMath.lerp(item.scale.x, 0.9, elapsed*6);
                item.scale.y = FlxMath.lerp(item.scale.y, 0.9, elapsed*6);
            }
            else {
                if(CoolUtil.mouseOverlap(item, FlxG.camera)) {
                    item.scale.x = FlxMath.lerp(item.scale.x, 0.9, elapsed*6);
                    item.scale.y = FlxMath.lerp(item.scale.y, 0.9, elapsed*6);
                    if(FlxG.mouse.justPressed) {
                        FlxG.sound.play(Paths.sound("menu/select"));
                        sliderActive = item.ID;
                        if(item.ID == 1)
                            openSubState(new SliderL());
                        else
                            openSubState(new SliderR());
                    }
                        //enterWeek(weekData[item.ID][0], weekData[item.ID][1]);
                }
                else {
                    item.scale.x = FlxMath.lerp(item.scale.x, 0.8, elapsed*6);
                    item.scale.y = FlxMath.lerp(item.scale.y, 0.8, elapsed*6);
                }
            }
        }

        if(Controls.justPressed("BACK") && sliderActive == -1)
        {
            FlxG.sound.play(Paths.sound('menu/back'));
            Main.switchState(new states.cd.MainMenu());
        }


        updatePos();
    }

    function updatePos() {
        week1.screenCenter();
        week1.x -= 300;
        week1.y += 50;

        week2.screenCenter();
        week2.x += 300;
        week2.y += 50;
    }

    public static function enterWeek(id:Int) {
        var week = weekData[id][0];
        var name = weekData[id][1];
        PlayState.curWeek = name;
        PlayState.songDiff = "normal";
        PlayState.isStoryMode = true;
        PlayState.weekScore = 0;
        
        PlayState.SONG = SongData.loadFromJson(week[0], "normal");
        PlayState.playList = week;
        PlayState.playList.remove(week[0]);
        
        //CoolUtil.playMusic();
        Main.switchState(new LoadSongState());
    }
}

class SliderL extends MusicBeatSubState
{
    var thing:FlxSprite;
    var button:FlxSprite;
    var weekID:Int = 1;

    var weekName:FlxText;
    var songs:FlxText;
	public function new()
    {
        super();

        thing = new FlxSprite().loadGraphic(Paths.image('menu/story/slider'));
        thing.x -= 52;
        thing.alpha = 0;
		add(thing);

        button = new FlxSprite().loadGraphic(Paths.image('menu/story/start'));
        button.screenCenter();
        button.y += 171;
        button.alpha = 0;
        add(button);

        weekName = new FlxText(0, 0, 0, "Week 2");
		weekName.setFormat(Main.gFont, 120, 0xFFFFFFFF, CENTER);
        weekName.setBorderStyle(OUTLINE, FlxColor.BLACK, 3);
        weekName.screenCenter(X);
        weekName.x -= 320;
        weekName.y += 70;
        weekName.alpha = 0;
		add(weekName);

        songs = new FlxText(0, 0, 0, "Allegro\nPanic Attack\nConvergence\n???\n");
		songs.setFormat(Main.gFont, 60, 0xFFFFFFFF, CENTER);
        songs.setBorderStyle(OUTLINE, FlxColor.BLACK, 3);
        songs.screenCenter();
        songs.x -= 320;
        songs.y -= 30;
        songs.alpha = 0;
		add(songs);

        for (i in [thing, button, weekName, songs])
            FlxTween.tween(i, {alpha: 1}, 0.1);
    }

    function updatePos() {
        button.screenCenter();
        button.y += 201;
        button.x -= 320;
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if(StoryMode.sliderActive == 1) {
            if(CoolUtil.mouseOverlap(button, FlxG.camera)) {
                button.scale.x = FlxMath.lerp(button.scale.x, 1.1, elapsed*6);
                button.scale.y = FlxMath.lerp(button.scale.y, 1.1, elapsed*6);
                if(FlxG.mouse.justPressed) {
                    FlxG.sound.play(Paths.sound("menu/select"));
                    StoryMode.enterWeek(weekID);
                    //sliderActive = true;
                    //openSubState(new SliderL());
                }
                    //enterWeek(weekData[item.ID][0], weekData[item.ID][1]);
            }
            else {
                button.scale.x = FlxMath.lerp(button.scale.x, 1, elapsed*6);
                button.scale.y = FlxMath.lerp(button.scale.y, 1, elapsed*6);
            }
    
            updatePos();
    
            if(Controls.justPressed("BACK"))
            {
                FlxG.sound.play(Paths.sound('menu/back'));
                StoryMode.sliderActive = -1;
                close();
            }
        }
    }
}

class SliderR extends MusicBeatSubState
{
    var thing:FlxSprite;
    var button:FlxSprite;
    var weekID:Int = 0;

    var weekName:FlxText;
    var songs:FlxText;
	public function new()
    {
        super();

        thing = new FlxSprite().loadGraphic(Paths.image('menu/story/slider'));
        thing.flipX = true;
        thing.x = FlxG.width - thing.width + 52;
        thing.alpha = 0;
		add(thing);

        button = new FlxSprite().loadGraphic(Paths.image('menu/story/start'));
        button.screenCenter();
        button.y += 171;
        button.alpha = 0;
        add(button);

        weekName = new FlxText(0, 0, 0, "Week 1");
		weekName.setFormat(Main.gFont, 120, 0xFFFFFFFF, CENTER);
        weekName.setBorderStyle(OUTLINE, FlxColor.BLACK, 3);
        weekName.screenCenter(X);
        weekName.x += 320;
        weekName.y += 70;
        weekName.alpha = 0;
		add(weekName);

        songs = new FlxText(0, 0, 0, "Euphoria\nNefarious\nDivergence\n");
		songs.setFormat(Main.gFont, 60, 0xFFFFFFFF, CENTER);
        songs.setBorderStyle(OUTLINE, FlxColor.BLACK, 3);
        songs.screenCenter();
        songs.x += 320;
        songs.y -= 30;
        songs.alpha = 0;
		add(songs);

        for (i in [thing, button, weekName, songs])
            FlxTween.tween(i, {alpha: 1}, 0.1);
    }

    function updatePos() {
        button.screenCenter();
        button.y += 201;
        button.x += 320;
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if(StoryMode.sliderActive == 0) {
            if(CoolUtil.mouseOverlap(button, FlxG.camera)) {
                button.scale.x = FlxMath.lerp(button.scale.x, 1.1, elapsed*6);
                button.scale.y = FlxMath.lerp(button.scale.y, 1.1, elapsed*6);
                if(FlxG.mouse.justPressed) {
                    FlxG.sound.play(Paths.sound("menu/select"));
                    StoryMode.enterWeek(weekID);
                    //sliderActive = true;
                    //openSubState(new SliderL());
                }
                    //enterWeek(weekData[item.ID][0], weekData[item.ID][1]);
            }
            else {
                button.scale.x = FlxMath.lerp(button.scale.x, 1, elapsed*6);
                button.scale.y = FlxMath.lerp(button.scale.y, 1, elapsed*6);
            }
    
            updatePos();
    
            if(Controls.justPressed("BACK"))
            {
                FlxG.sound.play(Paths.sound('menu/back'));
                StoryMode.sliderActive = -1;
                close();
            }
        }
    }
}