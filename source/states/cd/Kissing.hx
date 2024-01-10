package states.cd;

import flixel.FlxG;
import flixel.FlxSprite;
import data.GameData.MusicBeatState;
import flixel.addons.text.FlxTypeText;
import flixel.util.FlxColor;
import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;

using StringTools;

class Kissing extends MusicBeatState
{
    var bxbNeutral:FlxSprite;
    var bxbKissing:FlxSprite;
    var breeLeft:FlxSprite;
    var breeRight:FlxSprite;
    var warning:FlxSprite;
    var scoreTxt:FlxText;

    var score:Int = 0;

    override function create()
    {
        super.create();

        CoolUtil.playMusic("kiss");
        Main.setMouse(false);

        var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(80,80,80));
		bg.screenCenter();
		add(bg);

        bxbNeutral = new FlxSprite().loadGraphic(Paths.image('minigame/bxbneutral'));
		bxbNeutral.updateHitbox();
		bxbNeutral.screenCenter();
		add(bxbNeutral);

        bxbKissing = new FlxSprite().loadGraphic(Paths.image('minigame/bxbkiss'));
		bxbKissing.updateHitbox();
		bxbKissing.screenCenter();
        bxbKissing.alpha = 0;
		add(bxbKissing);

        breeLeft = new FlxSprite().loadGraphic(Paths.image('minigame/breeleft'));
		breeLeft.updateHitbox();
		breeLeft.screenCenter();
		add(breeLeft);

        breeRight = new FlxSprite().loadGraphic(Paths.image('minigame/breeright'));
		breeRight.updateHitbox();
		breeRight.screenCenter();
		add(breeRight);

        warning = new FlxSprite().loadGraphic(Paths.image('minigame/warning'));
		warning.updateHitbox();
		warning.screenCenter();
        warning.alpha = 0;
		add(warning);

        scoreTxt = new FlxText(0,0,0,'Score: 0');
		scoreTxt.setFormat(Main.dsFont, 40, 0xFFFFFFFF, CENTER);
		scoreTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
        scoreTxt.y = FlxG.height - scoreTxt.height;
		scoreTxt.screenCenter(X);
		add(scoreTxt);

        loop();
    }

    var isKissing:Bool = false;
    var breeWaiting:Bool = true;
    var kissTimer:FlxTimer;
    override public function update(elapsed:Float)
    {
        super.update(elapsed);
        
        var click:Bool = FlxG.keys.justPressed.SPACE || FlxG.mouse.justPressed;

		if (click)
		{
            if(!breeWaiting) {
                Main.switchState(new states.DebugState());

            }
            else {
                bxbNeutral.alpha = 0;
                bxbKissing.alpha = 1;
                FlxG.sound.play(Paths.sound('minigame/kiss'));
    
                isKissing = true;
    
                if(kissTimer != null)
                    if(kissTimer.active)
                        kissTimer.cancel();
    
                kissTimer = new FlxTimer().start(0.2, function(tmr:FlxTimer)
                {
                    bxbNeutral.alpha = 1;
                    bxbKissing.alpha = 0;
    
                    isKissing = false;
                });
    
                score++;
    
                scoreTxt.text = "Score: " + score;
                scoreTxt.screenCenter(X);
            }
		}
    }

    function loop() {
        breeLeft.alpha = 1;
        breeRight.alpha = 0;

        warning.alpha = 0;

        breeWaiting = true;

        new FlxTimer().start(FlxG.random.float(calc(true), calc(false)), function(tmr:FlxTimer)
        {
            FlxG.sound.play(Paths.sound('minigame/surprised'));
            warning.alpha = 1;

            new FlxTimer().start(0.5, function(tmr:FlxTimer)
            {
                breeWaiting = false;
                breeLeft.alpha = 0;
                breeRight.alpha = 1;

                new FlxTimer().start(FlxG.random.float(1, 3), function(tmr:FlxTimer)
                {  
                    loop();
                });
            });
        });
    }

    function calc(minr:Bool = true):Float {
        var base:Float = 5;
        var min = 1 - ((score^2) * 0.00002);
        var max = base - ((score^2) * 0.00002);

        if(min<0)
            min = 0.02;

        if(max<0)
            max = 0.07;

        if(!minr)
            return max;
        else
            return min;
    }
}