package states.cd.statics;

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

class Panic extends MusicBeatState
{
    var tex:FlxTypeText;
    var hasScrolled:Bool = false;
    var panelGroup:FlxTypedGroup<FlxSprite>;

    var imgs:Array<String> = ['1', '2', '3', '4', '5', '6', '7', '8', '9'];
    var curLine:Int = 0;
    override function create()
    {
        super.create();

        CoolUtil.playMusic("dialogue/22");

        Main.setMouse(false);

        panelGroup = new FlxTypedGroup<FlxSprite>();
		add(panelGroup);

        for (i in 0...imgs.length) {
            var panel = new FlxSprite(0, 0).loadGraphic(Paths.image("panels/pa/" + imgs[i]));
            panel.ID = i;
            panel.alpha = 0;
            panelGroup.add(panel);
        }
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        for (panel in panelGroup) {
            if(panel.ID == curLine) {
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

        if((FlxG.keys.justPressed.SPACE || isTouch)) {
            if(curLine == (imgs.length-1)) {
                states.cd.Dialog.dialog = "panic-attack";
                Main.switchState(new states.cd.Dialog());
            }
            else {
                curLine++;
            }

        }
    }
}