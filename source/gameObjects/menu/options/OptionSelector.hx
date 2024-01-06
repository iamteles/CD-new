package gameObjects.menu.options;

import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;

class OptionSelector extends FlxTypedGroup<FlxSprite>
{
	public var label:String = "";
	public var value:Dynamic;
	public var bounds:Array<Dynamic>;

	public var xTo:Float = 0;

	public var arrowL:FlxSprite;
	public var text:FlxText;
	public var arrowR:FlxSprite;

	public function new(label:String, value:Dynamic, bounds:Array<Dynamic>)
	{
		super();
		this.label = label;
		this.value = value;
		this.bounds = bounds;

        arrowL = new FlxSprite().loadGraphic(Paths.image('menu/arrow'));
		arrowL.scale.set(0.4,0.4); arrowL.updateHitbox();

        arrowR = new FlxSprite().loadGraphic(Paths.image('menu/arrow'));
		arrowR.scale.set(0.4,0.4); arrowR.updateHitbox();

		arrowL.flipX = true;
        arrowR.flipX = false;

		// value display
		text = new FlxText(0, 0, 0, "");
		text.setFormat(Main.gFont, 49, 0xFFFFFFFF, CENTER);
		text.setBorderStyle(OUTLINE, 0xFF000000, 2.7);
		text.text = label;
		//text.scale.set(0.7,0.7);
		text.updateHitbox();

		add(arrowL);
		add(text);
		add(arrowR);

		updateValue();
	}

	public function updateValue(change:Int = 0)
	{
		if(Std.isOfType(bounds[0], String))
		{
			var curSelected = bounds.indexOf(value) + change;
			curSelected = FlxMath.wrap(curSelected, 0, bounds.length - 1);
			value = bounds[curSelected];
		}
		else
		{
			value += change;
			if(value < bounds[0]) value = bounds[1];
			if(value > bounds[1]) value = bounds[0];
		}

		text.text = Std.string(value);

		arrowR.x = xTo - arrowR.width;
		text.x   = arrowR.x - text.width - 4;
		arrowL.x = text.x - arrowL.width - 4;

		SaveData.data.set(label, value);
		SaveData.save();
	}

	public function setY(item:FlxSprite)
	{
		for(i in [arrowL, arrowR])
			i.y = item.y + item.height / 2 - i.height / 2;

		text.y = item.y;
	}
}

class ControlSelector extends FlxTypedGroup<FlxSprite>
{
    public var arrowL:FlxSprite;
    public var text:FlxText;
    public var arrowR:FlxSprite;

    public var holdTimer:Float = 0;

    public var label:String = '';
    public var value:Dynamic;
    public var options:Array<Dynamic> = [];

    public function new(label:String, ?isSaveData:Bool = true)
    {
        super();
        this.label = label;
        if(isSaveData)
        {
            this.value = SaveData.data.get(label);
            this.options = SaveData.displaySettings.get(label)[3];
        }
        else
            this.value = label;

        arrowL = getArrow('left');
        arrowR = getArrow('right');

		text = new FlxText(0, 0, 0, "");
        text.setFormat(Main.gFont, 70, 0xFFFFFFFF, CENTER);
        text.setBorderStyle(OUTLINE, 0xFF000000, 4);
        text.scale.set(0.75,0.75);
        text.updateHitbox();
        text.text = value;
        add(text);

        add(arrowL);
        add(text);
        add(arrowR);
        setX(0);
    }

    private function getArrow(direc:String = 'left'):FlxSprite
    {
		var arrow = new FlxSprite();
		arrow = new FlxSprite().loadGraphic(Paths.image('menu/arrow'));
		arrow.scale.set(0.4,0.4); arrow.updateHitbox();
		
		if(direc == "left")
			arrow.flipX = true;
		else
			arrow.flipX = false;

        return arrow;
    }

    public function changeSelection(change:Int = 0):Void
    {
        if(Std.isOfType(options[0], Int))
        {
            value += change;
            value = FlxMath.wrap(value, options[0], options[1]);
        }
        else
        {
            var curSelected = options.indexOf(value);
            curSelected += change;
            curSelected = FlxMath.wrap(curSelected, 0, options.length - 1);
            value = options[curSelected];
        }
        var oldWidth = getWidth();
        text.text = Std.string(value);
        text.updateHitbox();
        setX(arrowL.x);
        setX(arrowL.x + oldWidth - getWidth());
    }

    public function setX(x:Float):Void
    {
        arrowL.x = x;
        text.x = arrowL.x + arrowL.width + 4;
        arrowR.x = text.x + text.width + 4;
    }
    public function setY(y:Float):Void
    {
        for(item in [arrowL, text, arrowR])
            item.y = y - (item.height / 2);

		text.y += 8;
    }

    public function getWidth():Float
        return (arrowR.x + arrowR.width - arrowL.x);
}