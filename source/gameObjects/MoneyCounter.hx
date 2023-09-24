package gameObjects;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import data.Timings;
import states.PlayState;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.math.FlxMath;
import flixel.system.FlxSound;

class MoneyCounter extends FlxGroup
{
    var icon:FlxSprite;
    var text:FlxText;

    var lerpValue:Float;

    var beep:FlxSound;

    public var x:Float;
    public var y:Float;

    public function new(x:Float = 0, y:Float = 0)
    {
        super();

        this.x = x;
        this.y = y;

        icon = new FlxSprite(x + 14, y + 14).loadGraphic(Paths.image("hud/base/money"));
        add(icon);

        lerpValue = SaveData.money;
		text = new FlxText(0, 0, 0, Std.string(lerpValue));
		text.setFormat(Main.gFont, 40, 0xFFFFFFFF, CENTER);
		text.setBorderStyle(OUTLINE, FlxColor.BLACK, 2.2);
        text.x = icon.x + icon.width + 5;
        text.y = icon.y+3;
		add(text);

        beep = new FlxSound();
		beep.loadEmbedded(Paths.sound('cget'), false, false);
		FlxG.sound.list.add(beep);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        icon.x = x+14;
        icon.y = y+14;
        text.x = icon.x + icon.width + 5;
        text.y = icon.y+3;

        lerpValue = FlxMath.lerp(lerpValue, 	SaveData.money, 	 elapsed * 8);

        if(lerpValue != SaveData.money && !beep.playing && SaveData.money > lerpValue)
            beep.play();

        if(Math.abs(lerpValue - SaveData.money) <= 1)
            lerpValue = SaveData.money;

        text.text = Std.string(Math.floor(lerpValue));
    }
}