package states.cd;

import data.GameData.MusicBeatSubState;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import data.GameData.MusicBeatState;
import data.SongData;
import flixel.tweens.FlxTween;

class StoryMode extends MusicBeatState
{
    var bg:FlxSprite;
    var week1:FlxSprite;
    var week2:FlxSprite;
    var epilogue:FlxSprite;
    var text:FlxSprite;

    var weeks:FlxTypedGroup<FlxSprite>;
    public static var weekData:Array<Array<Dynamic>> = [];
    public static var sliderActive:Int = -1; // -1 = none, 0 = w1, 1 = w2
    override function create()
    {
        super.create();

        CoolUtil.playMusic("LoveLetter");

        Main.setMouse(true);

        weekData = [
            [["euphoria", "nefarious", "divergence"], "week1"],
            [["allegro", "panic-attack", "convergence", "desertion"], "week2"],
            [["euphoria-vip", "nefarious-vip", "divergence-vip"], "week-vip"],
            [["sin"], "epilogue"],
        ];

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

        var huh:String = "";
        if(!SaveData.progression.get("week1"))
            huh = "lock";
        week2 = new FlxSprite().loadGraphic(Paths.image('menu/story/week2' + huh));
        week2.scale.set(0.8,0.8);
        week2.updateHitbox();
        week2.ID = 1;
        if(SaveData.progression.get("week1")) weeks.add(week2);
        else add(week2);

        epilogue = new FlxSprite().loadGraphic(Paths.image('menu/story/epilogue'));
        epilogue.scale.set(0.4,0.4);
        epilogue.updateHitbox();
        epilogue.visible = SaveData.progression.get("week2");
        add(epilogue);

        text = new FlxSprite(127, 15).loadGraphic(Paths.image('menu/story/text')); //i have not put a position here in a while lol
        text.updateHitbox();
        add(text);

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
                    if(FlxG.mouse.justPressed && focused) {
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

        if(SaveData.progression.get("week2")) {
            if(CoolUtil.mouseOverlap(epilogue, FlxG.camera)) {
                epilogue.scale.x = FlxMath.lerp(epilogue.scale.x, 0.4, elapsed*6);
                epilogue.scale.y = FlxMath.lerp(epilogue.scale.y, 0.4, elapsed*6);
                if(FlxG.mouse.justPressed) {
                    FlxG.sound.play(Paths.sound("menu/select"));
                    enterWeek(3);
                }
                    
            }
            else {
                epilogue.scale.x = FlxMath.lerp(epilogue.scale.x, 0.3, elapsed*6);
                epilogue.scale.y = FlxMath.lerp(epilogue.scale.y, 0.3, elapsed*6);
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
        week1.y += 150;

        week2.screenCenter();
        week2.x += 300;
        week2.y += 150;

        epilogue.screenCenter();
        epilogue.y += 320;
    }

    public static function enterWeek(id:Int) {
        if(id == 0) {
            Dialog.dialog = "euphoria";
            Main.switchState(new Dialog());
        }
        else if(id == 1) {
            Dialog.dialog = "allegro";
            Main.switchState(new Dialog());
        }
        else if(id == 3) {
            Dialog.dialog = "sin";
            Main.switchState(new Dialog());
        }
        else {
            PlayState.playList = [];

            //trace(PlayState.playList);
    
            var week = weekData[id][0];
            var name = weekData[id][1];
    
            //trace(week);
    
            PlayState.curWeek = name;
            PlayState.songDiff = "normal";
            PlayState.isStoryMode = true;
            PlayState.weekScore = 0;
            
            PlayState.SONG = SongData.loadFromJson(week[0], "normal");
            PlayState.playList = week;
            PlayState.playList.remove(week[0]);
    
            //trace(PlayState.playList);
            
            //CoolUtil.playMusic();
            Main.switchState(new LoadSongState());
        }
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
        weekName.setBorderStyle(OUTLINE, FlxColor.BLACK, 5);
        weekName.screenCenter(X);
        weekName.x -= 320;
        weekName.y += 70;
        weekName.alpha = 0;
		add(weekName);

        songs = new FlxText(0, 0, 0, "Allegro\nPanic Attack\nConvergence\n???\n");
		songs.setFormat(Main.gFont, 60, 0xFFFFFFFF, CENTER);
        songs.setBorderStyle(OUTLINE, FlxColor.BLACK, 4);
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
                if(FlxG.mouse.justPressed && focused) {
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
    var vipButton:FlxSprite;
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

        vipButton = new FlxSprite();
		vipButton.frames = Paths.getSparrowAtlas('menu/story/vip');
		vipButton.animation.addByPrefix('lock',  "vip locked", 24, true);
		vipButton.animation.addByPrefix('on',  "vip selected", 14, true);
        if(SaveData.shop.get("crown"))
		    vipButton.animation.play('on');
        else
            vipButton.animation.play('lock');
		vipButton.updateHitbox();
		add(vipButton);

        weekName = new FlxText(0, 0, 0, "Week 1");
		weekName.setFormat(Main.gFont, 120, 0xFFFFFFFF, CENTER);
        weekName.setBorderStyle(OUTLINE, FlxColor.BLACK, 5);
        weekName.screenCenter(X);
        weekName.x += 320;
        weekName.y += 70;
        weekName.alpha = 0;
		add(weekName);

        songs = new FlxText(0, 0, 0, "Euphoria\nNefarious\nDivergence\n");
		songs.setFormat(Main.gFont, 60, 0xFFFFFFFF, CENTER);
        songs.setBorderStyle(OUTLINE, FlxColor.BLACK, 4);
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
        button.x += 410;

        vipButton.screenCenter();
        vipButton.y += 211;
        vipButton.x += 140;
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if(StoryMode.sliderActive == 0) {
            if(CoolUtil.mouseOverlap(button, FlxG.camera)) {
                button.scale.x = FlxMath.lerp(button.scale.x, 1.1, elapsed*6);
                button.scale.y = FlxMath.lerp(button.scale.y, 1.1, elapsed*6);
                if(FlxG.mouse.justPressed && focused) {
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

            if(SaveData.shop.get("crown")) {
                if(CoolUtil.mouseOverlap(vipButton, FlxG.camera)) {
                    vipButton.scale.x = FlxMath.lerp(vipButton.scale.x, 1.1, elapsed*6);
                    vipButton.scale.y = FlxMath.lerp(vipButton.scale.y, 1.1, elapsed*6);
                    if(FlxG.mouse.justPressed && focused) {
                        FlxG.sound.play(Paths.sound("menu/select"));
                        StoryMode.enterWeek(2);
                        //sliderActive = true;
                        //openSubState(new SliderL());
                    }
                        //enterWeek(weekData[item.ID][0], weekData[item.ID][1]);
                }
                else {
                    vipButton.scale.x = FlxMath.lerp(vipButton.scale.x, 1, elapsed*6);
                    vipButton.scale.y = FlxMath.lerp(vipButton.scale.y, 1, elapsed*6);
                }
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