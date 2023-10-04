package gameObjects.hud;

import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxAxes;

class CDButton extends FlxGroup
{
    public var alpha:Float = 1;

    public var button:FlxSprite;
    public var label:FlxText;

    public var callback:Void->Void;
    public function new(x:Float, y:Float, text:String, ?Callback:Void->Void, ?color:FlxColor = FlxColor.WHITE)
    {
        super();

        callback = Callback;

        button = new FlxSprite(x, y);
        button.frames = Paths.getSparrowAtlas("hud/base/button");
        button.animation.addByPrefix("idle", "button idle", 24, true);
        button.animation.addByPrefix("highlighed", "button highlighed", 24, true);
        button.animation.addByPrefix("selected", "button selected", 24, true);
        button.animation.play("idle");
        button.scale.set(0.35, 0.35);
        button.updateHitbox();
        button.color = color;
        add(button);

        label = new FlxText(0, 0, 0, text);
		label.setFormat(Main.gFont, 18, 0xFFFFFFFF, CENTER);
		label.setBorderStyle(OUTLINE, 0xFF000000, 1.4);
        label.fieldWidth = button.width;
        updateLabel();
		add(label);
    }

	public inline function screenCenter(axes:FlxAxes = XY)
    {
        if (axes.x)
            button.screenCenter(X);

        if (axes.y)
            button.screenCenter(Y);

        updateLabel();
    }

    public inline function pos(nx:Float = 0, ny:Float = 0) {
        button.x += nx;
        button.y += ny;
        updateLabel();
    }

    function updateLabel() {
        label.x = (button.x + (button.width/2) - (label.width/2));
        label.y = (button.y + (button.height/2) - (label.height/2));
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        button.alpha = alpha;
        label.alpha = alpha;

        if(CoolUtil.mouseOverlap(button, FlxG.camera)) {
            if(FlxG.mouse.pressed)
                button.animation.play("selected");
            else
                button.animation.play("highlighed");

            if (FlxG.mouse.justReleased) {
                if (callback != null)
                    callback();
            }
        }
        else {
            button.animation.play("idle");
        }
    }
}