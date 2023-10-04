package states.cd;

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
    var actionBoxes:FlxTypedGroup<CDButton>;

    var week1:CDButton;
    var week2:CDButton;
    var weekVip:CDButton;

    override function create()
    {
        super.create();

        bg = new FlxSprite().loadGraphic(Paths.image('menu/main/bg'));
		bg.updateHitbox();
		bg.screenCenter();
        bg.alpha = 0.3;
		add(bg);

        actionBoxes = new FlxTypedGroup<CDButton>(3);
        add(actionBoxes);
        
        week1 = new CDButton(0, 100, "Week 1", function()
        {
            enterWeek(["euphoria", "nefarious", "divergence"], "week1");
        });
        actionBoxes.add(week1);

        week2 = new CDButton(0, 0, "Week 2", function()
        {
            enterWeek(["allegro", "panic-attack", "convergence", "desertion"], "week2");
        });
        actionBoxes.add(week2);

        weekVip = new CDButton(0, 0, "Week VIP", function()
        {
            enterWeek(["euphoria", "nefarious", "divergence"], "weekVip");
        });
        actionBoxes.add(weekVip);

        actionBoxes.forEach(function(item:CDButton){
            item.screenCenter();
        });

        week1.pos(0, -200);
        weekVip.pos(0, 200);
    }
    override function update(elapsed:Float)
    {
        super.update(elapsed);
    }

    function enterWeek(week:Array<String>, name:String) {
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