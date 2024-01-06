package states.cd;

import data.Discord.DiscordClient;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import data.GameData.MusicBeatState;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.effects.FlxFlicker;
import flixel.addons.display.FlxBackdrop;

class TitleScreen extends MusicBeatState
{
    var bg:FlxSprite;
    var tiles:FlxBackdrop;
    var logo:FlxSprite;
    var info:FlxText;

    override public function create():Void 
    {
        super.create();

        //CoolUtil.playMusic("MENU");
        CoolUtil.playMusic("intro");
        SaveData.progression.set("firstboot", true);
        SaveData.save();

        FlxG.mouse.visible = false;

        CoolUtil.flash(FlxG.camera, 0.5);

        bg = new FlxSprite().loadGraphic(Paths.image('menu/title/gradients/' + Main.possibleTitles[Main.randomized][0]));
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);
        
		tiles = new FlxBackdrop(Paths.image('menu/title/tiles/' + Main.possibleTitles[Main.randomized][0]), XY, 0, 0);
        tiles.velocity.set(40,40);
        tiles.screenCenter();
        add(tiles);

        logo = new FlxSprite(204.05, 46.7).loadGraphic(Paths.image('menu/title/logo'));
        logo.screenCenter(X);
        var storeY:Float = logo.y;
		logo.y -= 20;
		FlxTween.tween(logo, {y: storeY + 20}, 1.6, {type: FlxTweenType.PINGPONG, ease: FlxEase.sineInOut});
		add(logo);

        var text:String = "Press ENTER to start!";
        if(SaveData.data.get("Touch Controls"))
            text = "Touch Screen to start!";

        info = new FlxText(0,0,0,text);
		info.setFormat(Main.gFont, 50, 0xFFFFFFFF, CENTER);
		info.setBorderStyle(OUTLINE, FlxColor.BLACK, 2.4);
        info.screenCenter(X);
        info.y = 599.95;
        add(info);
    }

    var isTouch:Bool = false;
    var started:Bool = false;
    override function update(elapsed:Float)
    {
        super.update(elapsed);

        #if mobile
        for (touch in FlxG.touches.list)
        {
            if (touch.justPressed)
                isTouch = true;
        }
        #end

        if(Controls.justPressed("ACCEPT") || isTouch || (FlxG.mouse.justPressed && focused))
            end();
    }

    function end()
    {
        if(started) return;
        started = true;
        CoolUtil.playMusic("");
        FlxG.sound.play(Paths.sound("intro/end"));
        CoolUtil.flash(FlxG.camera, 1, 0xffffffff); 
        FlxFlicker.flicker(info, 2, 0.06, true, false, function(_)
        {
            Main.switchState(new states.cd.MainMenu());
        });
    }
}