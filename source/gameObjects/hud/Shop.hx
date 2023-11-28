package gameObjects.hud;

import flixel.math.FlxPoint;
import flixel.FlxBasic.FlxType;
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
import flixel.addons.text.FlxTypeText;
import flixel.tweens.FlxEase;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.input.keyboard.FlxKey;
import states.ShopState;
import flixel.util.FlxTimer;
import data.SongData;

typedef WattsDialog =
{
    var ident:String;
    var lines:Array<Dynamic>;
}


class ShopTalk extends FlxGroup
{
    var dialogBig:FlxSprite;
    var icon:FlxSprite;
    var tex:FlxTypeText;
    var hasScrolled:Bool = false;
    var activeg:Bool = true;

    var curLine:Int = 0;

    var dialogData:WattsDialog;

    var watts1:FlxSound;
    var watts2:FlxSound;
    var watts3:FlxSound;
    var watts4:FlxSound;

    var starting:String = 'post';

    public function new()
    {
        super();

        dialogBig = new FlxSprite(0, 0).loadGraphic(Paths.image('hud/shop/box'));
        dialogBig.scale.set(0.7, 0.7);
        dialogBig.updateHitbox();
        dialogBig.screenCenter(X);
        dialogBig.y = FlxG.height - dialogBig.height - 30;
		add(dialogBig);

        icon = new FlxSprite(0, 0);
        icon.frames = Paths.getSparrowAtlas("hud/shop/wattsicons");
        icon.animation.addByPrefix("neutral", 'watts text neutral', 24, true);
        icon.animation.addByPrefix("sad", 'watts text sad', 24, true);
        icon.animation.addByPrefix("happy", 'watts text happy', 24, true);
        icon.animation.addByPrefix("angry", 'watts text angry', 24, true);
        icon.animation.addByPrefix("confused", 'watts text confused', 24, true);
        icon.animation.play("neutral");
        icon.scale.set(0.7, 0.7);
        icon.updateHitbox();
        icon.x = dialogBig.x + 70;
        icon.y = dialogBig.y + 70;
        add(icon);

        watts1 = new FlxSound();
        watts1.loadEmbedded(Paths.sound("dialog/watts/watts1"), false, false);
        watts1.volume = 0.7;
        FlxG.sound.list.add(watts1);

        watts2 = new FlxSound();
        watts2.loadEmbedded(Paths.sound("dialog/watts/watts2"), false, false);
        watts2.volume = 0.7;
        FlxG.sound.list.add(watts2);

        watts3 = new FlxSound();
        watts3.loadEmbedded(Paths.sound("dialog/watts/watts3"), false, false);
        watts3.volume = 0.7;
        FlxG.sound.list.add(watts3);

        watts4 = new FlxSound();
        watts4.loadEmbedded(Paths.sound("dialog/watts/watts4"), false, false);
        watts4.volume = 0.7;
        FlxG.sound.list.add(watts4);

        tex = new FlxTypeText(icon.x + icon.width + 25, icon.y, Std.int(dialogBig.width - (icon.x + icon.width + 25) - 50), '', true);
		tex.alpha = 1;
		tex.setFormat(Paths.font("sylfaen.ttf"), 30, 0xFFFFFFFF, LEFT, FlxTextBorderStyle.OUTLINE, 0xFF000000);
		tex.borderSize = 1.4;
		tex.skipKeys = [FlxKey.SPACE];
		tex.delay = 0.05;
        tex.sounds = [watts1, watts2, watts3, watts4];
		tex.finishSounds = false;
        tex.start();
		add(tex);

        if(!SaveData.progression.get("shopentrance")) {
            trace(SaveData.progression.get("shopentrance"));
            starting = "intro";
            SaveData.progression.set("shopentrance", true);
            trace(SaveData.progression.get("shopentrance"));
            SaveData.save();
        }


        dialogData = haxe.Json.parse(Paths.getContent('data/watts/$starting.json').trim());
        scrollText(dialogData.lines[curLine], dialogData.ident);
    }

    function scrollText(info:Array<Dynamic>, ident:String = 'doesntmatter') {
        if(ident == 'wattsphoto' && curLine == 1) {
            FlxTween.tween(ShopState.watts, {alpha: 0}, 0.5, {ease: FlxEase.sineInOut});
            ShopState.zoom = 1;
            ShopState.camFollow.setPosition(ShopState.watts.getMidpoint().x, ShopState.watts.getMidpoint().y - 100);
        }
        if(ident == 'wattsphoto' && curLine == 6) {
            FlxTween.tween(ShopState.watts, {alpha: 1}, 0.5, {ease: FlxEase.sineInOut});
            ShopState.zoom = 0.6;
            ShopState.camFollow.setPosition(ShopState.watts.getMidpoint().x, ShopState.watts.getMidpoint().y + 80);
        }
        ShopState.watts.animation.play(info[1]);
        icon.animation.play(info[1]);
        tex.delay = info[2];
        tex.resetText('* ' + info[0]);
        curLine++;
        tex.start(false, function()
        {
            new FlxTimer().start(0.1, function(tmr:FlxTimer)
            {
                ShopState.watts.animation.play(info[1] + "idle");
                hasScrolled = true;
            });
        });
    }


    public function tweenAlpha(alpha:Float, time:Float) {
        if(alpha == 1)
            activeg = true;
        if(alpha == 0)
            activeg = false;
        FlxTween.tween(dialogBig, {alpha: alpha}, time, {ease: FlxEase.sineInOut});
        FlxTween.tween(icon, {alpha: alpha}, time, {ease: FlxEase.sineInOut});
        FlxTween.tween(tex, {alpha: alpha}, time, {ease: FlxEase.sineInOut});
    }

    public function resetDial(newd:String) {
        dialogData = haxe.Json.parse(Paths.getContent('data/watts/$newd.json').trim());
        curLine = 0;
        hasScrolled = false;
        scrollText(dialogData.lines[curLine], dialogData.ident);
    }
    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if(activeg) {
            if(hasScrolled) {
                if(curLine >= dialogData.lines.length) {
                    switch(dialogData.ident) {
                        case "sel":
                            if(ShopState.A) {
                                resetDial("bellasel");
                            }
                            if(ShopState.B) {
                                resetDial("bexsel");
                            }
                            if(ShopState.C) {
                                resetDial("bree");
                            }
                            if(ShopState.X) {
                                resetDial("wattssel");
                            }
                            if(ShopState.Y) {
                                resetDial("post");
                            }
                        case "entersong":
                            if(ShopState.A) {
                                resetDial("conservation");
                            }
                            if(ShopState.B) {
                                resetDial("irritation");
                            }
                        case "conservation":
                            if(FlxG.keys.justPressed.SPACE || FlxG.mouse.justPressed) {
                                ShopState.watts.animation.play("pull");
                                new FlxTimer().start(0.6, function(tmr:FlxTimer)
                                {
                                    CoolUtil.playMusic();
                                    PlayState.SONG = SongData.loadFromJson("conservation");
                                    Main.skipTrans = true;
                                    Main.skipClearMemory = true;
                                    Main.switchState(new PlayState());
                                });
                            }
                        case "irritation":
                            if(FlxG.keys.justPressed.SPACE || FlxG.mouse.justPressed) {
                                ShopState.watts.animation.play("pullalt");
                                new FlxTimer().start(0.6, function(tmr:FlxTimer)
                                {
                                    CoolUtil.playMusic();
                                    PlayState.SONG = SongData.loadFromJson("irritation");
                                    Main.skipTrans = true;
                                    Main.skipClearMemory = true;
                                    Main.switchState(new PlayState());
                                });
                            }
                        case "bellasel":
                            if(ShopState.A) {
                                resetDial("bellaA");
                            }
                            if(ShopState.B) {
                                resetDial("bellaB");
                            }
                            if(ShopState.Y) {
                                resetDial("sel");
                            }
                        case "bexsel":
                            if(ShopState.A) {
                                resetDial("bexA");
                            }
                            if(ShopState.B) {
                                resetDial("bexB");
                            }
                            if(ShopState.Y) {
                                resetDial("sel");
                            }
                        case "wattssel":
                            if(ShopState.A) {
                                resetDial("wattsA");
                            }
                            if(ShopState.B) {
                                resetDial("wattsB");
                            }
                            if(ShopState.C) {
                                resetDial("wattsC");
                            }
                            if(ShopState.X) {
                                resetDial("wattsD");
                            }
                            if(ShopState.Y) {
                                resetDial("sel");
                            }
                        case "wattsphoto":
                            if(ShopState.A) {
                                resetDial("wattsA");
                            }
                            if(ShopState.B) {
                                resetDial("wattsB");
                            }
                            if(ShopState.C) {
                                resetDial("wattsC");
                            }
                            if(ShopState.X) {
                                resetDial("wattsD");
                            }
                            if(ShopState.Y) {
                                resetDial("sel");
                            }
                        case "buy":
                            if(FlxG.keys.justPressed.SPACE || ShopState.A)
                                ShopState.enterShop();
                            if(FlxG.keys.justPressed.CONTROL || ShopState.B) {
                                resetDial("sel");
                            }
                            if(ShopState.Y) {
                                Main.switchState(new states.cd.MainMenu());
                            }

                    }

                }
                else {
                    if(FlxG.keys.justPressed.SPACE || FlxG.mouse.justPressed) {
                        FlxG.sound.play(Paths.sound('click'));
    
                        hasScrolled = false;
        
                        scrollText(dialogData.lines[curLine], dialogData.ident);
                    }
                }

            }
        }
    }
}

class ShopBuy extends FlxGroup
{
    public static var defaultTab:String = 'songs';
    var dialogBig:FlxSprite;
    var holder:FlxSprite;
    var icon:FlxSprite;
    public static var tex:FlxTypeText;
    
    var tabs:FlxTypedGroup<FlxSprite>;
    var curTab:ShopTab;
    var curId:Int = 0;

    var songGroup:ShopTab;
    var extrasGroup:ShopTab;
    var skinsGroup:ShopTab;

    var tabPos:Array<Float>;

    public static var itemDesc = "What are you looking for?";

    public static var activeg:Bool = false;

    public function new()
    {
        super();

        dialogBig = new FlxSprite(0, 0).loadGraphic(Paths.image('hud/shop/small'));
        dialogBig.scale.set(0.6, 0.6);
        dialogBig.updateHitbox();
        dialogBig.x = 25;
        dialogBig.y = FlxG.height - dialogBig.height - 30;
		add(dialogBig);

        holder = new FlxSprite(0, 0).loadGraphic(Paths.image('hud/shop/bix')); //man what the fuck is a bix
        holder.scale.set(0.6, 0.6);
        holder.updateHitbox();
        holder.x = FlxG.width - holder.width - 25;
        holder.y = FlxG.height - holder.height - 30;

        var tabsar:Array<String> = ["songs", "skins", "extras"];

        tabs = new FlxTypedGroup<FlxSprite>();
		add(tabs);

        tabPos = [holder.x - 130, holder.x - 200];

        for(i in tabsar)
        {
            var tab = new FlxSprite(0, 0); 
            tab.frames = Paths.getSparrowAtlas("hud/shop/tabs");
            tab.animation.addByPrefix("idle", '$i tab', 24, true);
            tab.animation.play("idle");
            tab.scale.set(0.6, 0.6);
            tab.updateHitbox();
            tab.ID = tabsar.indexOf(i);
            tab.x = tabPos[0];
            if(i == defaultTab)
                tab.x = tabPos[1];
            tab.y = holder.y + ((tabsar.indexOf(i)+1) * 70);
            tabs.add(tab);
        }
            
		add(holder);

        icon = new FlxSprite(0, 0);
        icon.frames = Paths.getSparrowAtlas("hud/shop/wattsicons");
        icon.animation.addByPrefix("neutral", 'watts text neutral', 24, true);
        icon.animation.addByPrefix("sad", 'watts text sad', 24, true);
        icon.animation.addByPrefix("happy", 'watts text happy', 24, true);
        icon.animation.addByPrefix("angry", 'watts text angry', 24, true);
        icon.animation.addByPrefix("confused", 'watts text confused', 24, true);
        icon.animation.play("neutral");
        icon.scale.set(0.6, 0.6);
        icon.updateHitbox();
        icon.x = dialogBig.x + 70;
        icon.y = dialogBig.y + 60;
        add(icon);

        tex = new FlxTypeText(icon.x + icon.width + 25, icon.y, Std.int(dialogBig.width - (icon.x + icon.width + 25) - 50), '* What are you looking for?', true);
		tex.alpha = 1;
		tex.setFormat(Paths.font("sylfaen.ttf"), 24, 0xFFFFFFFF, LEFT, FlxTextBorderStyle.OUTLINE, 0xFF000000);
		tex.borderSize = 1.4;
		tex.skipKeys = [];
		tex.delay = 0.05;
		tex.finishSounds = false;
        tex.start();
		add(tex);

        songGroup = new ShopTab("songs", holder.x, holder.y);
		add(songGroup);

        skinsGroup = new ShopTab("skins", holder.x, holder.y);
		add(skinsGroup);

        extrasGroup = new ShopTab("extras", holder.x, holder.y);
		add(extrasGroup);

        curTab = songGroup;
    }

    public static function scrollText(text:String, ?delay:Float = 0.05) {
        if(text == itemDesc)
            return;
        
        ShopState.watts.animation.play("neutral");
        itemDesc = text;
        tex.delay = delay;
        tex.resetText('* ' + text);
        tex.start(false, function()
        {
            new FlxTimer().start(0.1, function(tmr:FlxTimer)
            {
                ShopState.watts.animation.play("idle");
            });
        });
    }

    public function tweenAlpha(alpha:Float, time:Float) {
        if(alpha == 1)
            activeg = true;
        if(alpha == 0)
            activeg = false;
        FlxTween.tween(dialogBig, {alpha: alpha}, time, {ease: FlxEase.sineInOut});
        FlxTween.tween(icon, {alpha: alpha}, time, {ease: FlxEase.sineInOut});
        FlxTween.tween(tex, {alpha: alpha}, time, {ease: FlxEase.sineInOut});
        FlxTween.tween(holder, {alpha: alpha}, time, {ease: FlxEase.sineInOut});

        for(i in tabs) {
            FlxTween.tween(i, {alpha: alpha}, time, {ease: FlxEase.sineInOut});
        }

        alphaTab(alpha, time);
    }

    public function alphaTab(alpha:Float, time:Float) {
        for(i in curTab) {
            var alphaF = alpha;
            if(SaveData.shop.get(i.info[0])) {
                if (alpha > 0.3)
                    alphaF = 0.3;
            }
            else
                alphaF = alpha;
            FlxTween.tween(i, {alpha: (alphaF > 0.7 ? 0.7 : alphaF)}, time, {
                ease: FlxEase.sineInOut, onComplete: function(twn:FlxTween)
                    {
                        i.overAlpha = (alphaF >= 0.7 ? false : true);
                    }
                });
        }
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if(activeg) {
            if(ShopState.Y)
                ShopState.exitShop();
    
            for(i in tabs) {
                if(i.ID == curId) {
                    i.x = tabPos[1];
                }
                else if(CoolUtil.mouseOverlap(i, ShopState.camHUD, new FlxPoint(holder.x + 10, i.y + i.height))) {
                    i.x = tabPos[1];
                    if(FlxG.mouse.justPressed) {
                        curId = i.ID;
                        alphaTab(0, 0.4);
                        switch (i.ID) {
                            case 0:
                                curTab = songGroup;
                            case 1:
                                curTab = skinsGroup;
                            case 2:
                                curTab = extrasGroup;
                        }
                        alphaTab(0.7, 0.4);
                    }
                }
                else {
                    i.x = tabPos[0];
                }
    
                //i.x = FlxMath.lerp(i.x, 	lerpPos, 	 elapsed * 30);
            }
        }
    }
}

class ShopTab extends FlxTypedGroup<ShopItem>
{
    var itemList:Map<String, Array<Array<Dynamic>>> =
    [
        "songs" => [
            ["crown", "Golden Crown", 100],
            ["mic", "Used Microphone", 50],
            ["ticket", "Rave Ticket", 50]
        ],
        "skins" => [
            ["base", "Classic FNF", 15],
            ["tails", "Tails.EXE", 15],
            ["shack", "The Funk Shack", 15],
            ["mlc", "Mirror Life Crisis", 15]
        ],
        "extras" => [
            //["mania", "Mania Mode", 75],
            ["music", "Legit Disc", 25],
            ["gallery", "Gallery", 25]
        ]
    ];

    var tab:String = 'songs';

    public function new(name:String, x:Float, y:Float)
    {
        super();
        
        tab = name;

        for(i in 0...itemList.get(tab).length) {
            var itemX:Float = x + 40;
            var itemY:Float = y + 30;
            if(i >= 2)
                itemY = y + 30 + 200;
            if(i == 1 || i == 3)
                itemX = x + 40 + 200;
            var item = new ShopItem(itemList.get(tab)[i], itemX, itemY);
            item.ident = i;
            add(item);
        }
    }
}

class ShopItem extends FlxGroup
{
    public var alpha:Float = 0;
    public var tempalpha:Float = 1;
    public var ident:Int;
    public var display:FlxSprite;
    public var icon:FlxSprite;

    public var name:FlxText;
    public var price:FlxText;

    public var info:Array<Dynamic>;

    public var overAlpha:Bool = true;
    public function new(info:Array<Dynamic>, x:Float, y:Float)
    {
        super();
        this.info = info;

        display = new FlxSprite(x, y);
        display.frames = Paths.getSparrowAtlas("hud/shop/ITEMS");
        display.animation.addByPrefix("idle", info[0], 24, true);
        display.animation.play("idle");
        display.scale.set(0.6, 0.6);
        display.updateHitbox();
        add(display);

        name = new FlxText(x, y+140, 0, info[1]);
		name.setFormat(Main.gFont, 22, 0xFFFFFFFF, LEFT);
		name.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.4);
		add(name);

        icon = new FlxSprite().loadGraphic(Paths.image("hud/base/money"));
        icon.scale.set(0.6, 0.6);
        icon.updateHitbox();
        icon.x = x;
        icon.y = name.y+name.height;
        add(icon);

		price = new FlxText(0, 0, 0, Std.string(info[2]));
		price.setFormat(Main.gFont, 22, 0xFFFFFFFF, LEFT);
		price.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.4);
        price.x = icon.x+icon.width;
        price.y = name.y+name.height;
		add(price);
    }

    var overlapinTest:Bool = false;

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        display.alpha = alpha;
        name.alpha = alpha;
        icon.alpha = alpha;
        price.alpha = alpha;

        if(CoolUtil.mouseOverlap(display, ShopState.camHUD))
            overlapinTest = true;
        else
            overlapinTest = false;

        if(overlapinTest) {
            tempalpha = 1;
            if(alpha != 0) {
                ShopBuy.scrollText(SaveData.displayShop.get(info[0])[1]);

                if(FlxG.mouse.justPressed) {
                    trace('PRESSED' + info[0]);

                    if(!SaveData.shop.get(info[0]) && SaveData.money >= info[2]) {
                        FlxG.sound.play(Paths.sound("csin"));
                        SaveData.buyItem(info[0]);
                        SaveData.transaction(-Std.int(info[2]));
                    }

                    if(info[0] == 'mic' && (SaveData.money >= info[2] || SaveData.shop.get(info[0]))) {
                        ShopState.exitShop(true);
                    }
                }
            }
        }
        else {
                tempalpha = 0.7;
        }

        if(!overAlpha)
            alpha = tempalpha;

        if(SaveData.shop.get(info[0])) {
            if (alpha > 0.3)
                alpha = 0.3;

            if(name.text != "SOLD")
                name.text = "SOLD";
        }
    }
}