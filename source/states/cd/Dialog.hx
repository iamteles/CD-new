package states.cd;

import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import data.GameData.MusicBeatState;
import data.SongData;
import flixel.util.FlxTimer;
import states.*;
import gameObjects.DialogChar;
import flixel.addons.text.FlxTypeText;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;

// same dialog code as mlc btw
typedef Dialogue =
{
	var characters:Array<String>;
	var lines:Array<DialogueLine>;
	var finisher:Null<String>;
    var background:Null<String>;
    var song:Null<String>;
}

typedef DialogueLine =
{
	var character:String;
	var frame:String;
	var text:String;
	var delay:Null<Float>;
    var thing:Null<String>;
}

class Dialog extends MusicBeatState
{
    var bg:FlxSprite;
    var box:FlxSprite;

    var name:FlxText;
    var tex:FlxTypeText;

    var left:DialogChar;
    var right:DialogChar;
    var right2:DialogChar;
    var log:Dialogue;

    var curLine:Int = 0;
	var loaded:Bool = false;
    var hasScrolled:Bool = false;
    public static var dialog:String = 'log';
    public static var introCenterAlpha:Float = 0;

    var clickSfx:FlxSound;
    override function create()
    {
        super.create();

        try
        {
            log = haxe.Json.parse(Paths.getContent('data/log/' + dialog + '.json').trim());

            loaded = true;
        }
        catch (e)
        {
            //
        }

        if(log.song != null)
            CoolUtil.playMusic("dialogue/" + log.song);

        bg = new FlxSprite().loadGraphic(Paths.image('dialog/bgs/' + log.background));
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

        var ypos:Int = 30;
        var thirdpos:Int = 30;

        if(dialog == "ripple" || dialog == "customer-service") {
            ypos = 120;
            thirdpos = 90;
            introCenterAlpha = 0.6;
        }

        left = new DialogChar();
        left.reloadChar(log.characters[0]);
		left.setPosition(
            50,
            ypos
		);
        add(left);

        right = new DialogChar();
        right.reloadChar(log.characters[1]);
		//right.flipX = true;
		right.setPosition(
            FlxG.width - right.width - 56,
            ypos
		);
        right.alpha = 0.6;
        add(right);

        if(log.characters[2] != null) {
            right2 = new DialogChar();
            right2.reloadChar(log.characters[2]);
            //right.flipX = true;
            right2.setPosition(
                (FlxG.width/2) - (right2.width/2),
                thirdpos
            );
            right2.alpha = introCenterAlpha;
            add(right2);
        }

        box = new FlxSprite().loadGraphic(Paths.image('dialog/dialogue-box'));
        box.scale.set(0.65,0.65);
		box.updateHitbox();
		box.screenCenter(X);
        box.y = FlxG.height - box.height - 10;
		add(box);

        clickSfx = new FlxSound();
		clickSfx.loadEmbedded(Paths.sound('menu/scroll'), false, false);
		FlxG.sound.list.add(clickSfx);

        tex = new FlxTypeText(box.x + 25, box.y + 123, Std.int(FlxG.width - 110), 'placeholder', true);
		tex.alpha = 1;
		tex.setFormat(Main.gFont, 36, 0xFFFFFFFF, LEFT, FlxTextBorderStyle.OUTLINE, 0xFF000000);
		tex.borderSize = 2;
		tex.skipKeys = [FlxKey.SPACE];
		tex.delay = 0.05;
		tex.sounds = [clickSfx];
		tex.finishSounds = false;
		add(tex);

        name = new FlxText(box.x + 38,box.y + 18,0,"Bella");
		name.setFormat(Main.gFont, 55, 0xFFFFFFFF, CENTER);
		name.setBorderStyle(OUTLINE, FlxColor.BLACK, 2.3);
        add(name);

        var skipTxt = new FlxText(0,0,0,"Press ESCAPE to skip.");
		skipTxt.setFormat(Main.dsFont, 34, 0xFFFFFFFF, CENTER);
		skipTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
        skipTxt.y = FlxG.height - skipTxt.height;
		skipTxt.screenCenter(X);
		add(skipTxt);

        if(loaded)
            textbox();
        
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if(FlxG.keys.justPressed.ESCAPE)
            end();

        if(FlxG.keys.justPressed.SPACE && hasScrolled) {
            FlxG.sound.play(Paths.sound('dialog/skip'));

            if(curLine == log.lines.length) {
                if(log.finisher != null) {
                    end();
                }
                //else
                    //close();
            }
            else
                textbox();
        }
    }

    function textbox()
    {
        hasScrolled = false;
        if (log.lines[curLine].delay != null)
            tex.delay = log.lines[curLine].delay;
        tex.resetText(log.lines[curLine].text);

        if(log.lines[curLine].thing != null) {
            switch(log.lines[curLine].thing) {
                case 'hideleft':
                    left.visible = false;
            }
        }

        switch (log.lines[curLine].character) {
            case 'left':
                left.playAnim(log.lines[curLine].frame);
                right.alpha = 0.6;
                left.alpha = 1;
                name.text = left.name;
                if(log.characters[2] != null && right2.alpha != 0) right2.alpha = 0.6;
            case 'right':
                right.playAnim(log.lines[curLine].frame);
                left.alpha = 0.6;
                right.alpha = 1;
                name.text = right.name;
                if(log.characters[2] != null && right2.alpha != 0) right2.alpha = 0.6;
            case 'center':
                if(log.characters[2] != null) {
                    right2.playAnim(log.lines[curLine].frame);
                    right2.alpha = 1;
                    left.alpha = 0.6;
                    right.alpha = 0.6;
                    name.text = right2.name;
                }
        }

        new FlxTimer().start(0.1, function(tmr:FlxTimer)
        {
            tex.start(false, function()
                {
                    new FlxTimer().start(0.1, function(tmr:FlxTimer)
                    {
                        hasScrolled = true;
                    });
                });
        });

        curLine ++;
    }

    function end() {
        switch (log.finisher) {
            case "euphoria":
                PlayState.isStoryMode = true;
                PlayState.SONG = SongData.loadFromJson("euphoria", "normal");
                Main.switchState(new LoadSongState());
            case "nefarious":
                PlayState.isStoryMode = true;
                PlayState.SONG = SongData.loadFromJson("nefarious", "normal");
                Main.switchState(new LoadSongState());
            case "divergence":
                PlayState.isStoryMode = true;
                PlayState.SONG = SongData.loadFromJson("divergence", "normal");
                Main.switchState(new LoadSongState());
            case "allegro":
                PlayState.isStoryMode = true;
                PlayState.SONG = SongData.loadFromJson("allegro", "normal");
                Main.switchState(new LoadSongState());
            case "panic-attack":
                PlayState.isStoryMode = true;
                PlayState.SONG = SongData.loadFromJson("panic-attack", "normal");
                Main.switchState(new LoadSongState());
            case "convergence":
                PlayState.isStoryMode = true;
                PlayState.SONG = SongData.loadFromJson("convergence", "normal");
                Main.switchState(new LoadSongState());
            case "desertion":
                PlayState.isStoryMode = true;
                PlayState.SONG = SongData.loadFromJson("desertion", "normal");
                Main.switchState(new LoadSongState());
            case "sin":
                PlayState.isStoryMode = true;
                PlayState.SONG = SongData.loadFromJson("sin", "normal");
                Main.switchState(new LoadSongState());
            case "song":
                Main.switchState(new LoadSongState());
            default:
                //close();
        }
    }
}