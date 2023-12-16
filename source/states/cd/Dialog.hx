package states.cd;

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
import data.GameData.MusicBeatSubState;
import states.*;
import gameObjects.DialogChar;

class Dialog extends MusicBeatState
{
    var bg:FlxSprite;
    var box:FlxSprite;

    var name:FlxText;

    public static var left:DialogChar;
    public static var right:DialogChar;
    override function create()
    {
        super.create();

        bg = new FlxSprite().loadGraphic(Paths.image('dialog/bgs/allegro'));
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

        left = new DialogChar();
        left.reloadChar("bella");
		left.setPosition(
            50,
            30
		);
        add(left);

        right = new DialogChar();
        right.reloadChar("bella");
		right.flipX = true;
		right.setPosition(
            FlxG.width - right.width - 56,
            30
		);
        right.alpha = 0.6;
        add(right);

        box = new FlxSprite().loadGraphic(Paths.image('dialog/dialogue-box'));
        box.scale.set(0.65,0.65);
		box.updateHitbox();
		box.screenCenter(X);
        box.y = FlxG.height - box.height - 10;
		add(box);

        name = new FlxText(box.x + 38,box.y + 20,0,"Bella");
		name.setFormat("lmao", 55, 0xFFFFFFFF, CENTER);
		name.setBorderStyle(OUTLINE, FlxColor.BLACK, 2.3);
        add(name);
    }
}