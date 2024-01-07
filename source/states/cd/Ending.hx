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

class Ending extends MusicBeatState
{
    var tex:FlxTypeText;
    var hasScrolled:Bool = false;
    var panelGroup:FlxTypedGroup<FlxSprite>;

    var lines:Array<String> = ['Bree finally admitted defeat and left just as quickly as she came.', 
    "Almost like she was called by someone...", 
    "Bella and Bex were just glad to have her off their hands.", 
    "Their new love based powers surely came in handy.", 
    "However, Bex couldn’t shake away the feeling of dread.", 
    "Bree left a pretty bad mental scar on her and got her thinking things she didn’t want to think.",
    "But Bella was by her side, she had no need to worry, when she was around.",
    "They hugged tight, and it didn’t look like they were going to let go...",
    "So the girls continued their lives, savoring this momentous victory, and cherishing each other's love.",
    "While Bree wasn’t gone mentally... she was out of their hair then and there.",
    "At the end of the day...",
    "Love Wins.",
    "á"
    ];
    var imgs:Array<String> = ['cg-1', 'cg-1', 'cg-2', 'cg-2', 'cg-2', 'cg-2', 'cg-3', 'cg-3', 'cg-3', 'cg-3', 'cg-3', 'cg-3', 'cg-4'];
    var curLine:Int;
    override function create()
    {
        super.create();

        CoolUtil.playMusic("godsend");

        Main.setMouse(false);

        panelGroup = new FlxTypedGroup<FlxSprite>();
		add(panelGroup);

        for (i in 0...imgs.length) {
            var panel = new FlxSprite(0, 0).loadGraphic(Paths.image("panels/" + imgs[i]));
            panel.ID = i;
            panel.alpha = 0;
            panelGroup.add(panel);
        }


		tex = new FlxTypeText(0, 530, 800, 'placeholder', true);
		tex.alpha = 0;
		tex.setFormat(Main.gFont, 40, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		tex.screenCenter(X);
		tex.borderSize = 2;
		tex.skipKeys = [FlxKey.SPACE];
		tex.delay = 0.05;
		add(tex);

        textbox(lines[curLine]);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        for (panel in panelGroup) {
            if(panel.ID == curLine - 1) {
                panel.alpha = FlxMath.lerp(panel.alpha, 1, elapsed*12);
            }
            //else
            //    panel.alpha = FlxMath.lerp(panel.alpha, 0, elapsed*12);
        }

        var isTouch:Bool = false;
        #if mobile
        for (touch in FlxG.touches.list)
        {
            if (touch.justPressed)
                isTouch = true;
        }
        #end

        if((FlxG.keys.justPressed.SPACE || isTouch) && hasScrolled) {
                FlxG.sound.play(Paths.sound('dialog/skip'));
                FlxTween.tween(tex, {alpha: 0}, 0.4, {
                    ease: FlxEase.sineInOut,
                    onComplete: function(twn:FlxTween)
                    {
                        hasScrolled = false;

                        if(curLine == lines.length) {
                            if(!SaveData.progression.get("week2"))
                                states.cd.MainMenu.unlocks.push("Epilogue!\nWatts' Shop!\nSong: Heartpounder (FREEPLAY)");
                            SaveData.progression.set("week2", true);
                            SaveData.save();
                            Main.switchState(new states.cd.MainMenu());
                        }

                        else {
                            textbox(lines[curLine]);
                        }

                    }
                });
        }
    }

    function textbox(text:String, ?delay:Float = 0.05)
    {
        tex.delay = delay;
        tex.resetText(text);
        tex.alpha = 1;

        curLine ++;

        tex.start(false, function()
        {
            new FlxTimer().start(0.1, function(tmr:FlxTimer)
            {
                hasScrolled = true;
            });
        });
    }
}